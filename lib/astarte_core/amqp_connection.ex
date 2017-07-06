defmodule Astarte.Core.AMQPConnection do
  require Logger
  use GenServer
  use AMQP

  @connection_backoff 10000

  def start_link(amqp_opts, consumer_opts, name \\ nil) do
    GenServer.start_link(__MODULE__, {amqp_opts, consumer_opts}, name: name)
  end

  def init({amqp_opts, consumer_opts}) do
    consumer_queue = Keyword.get(consumer_opts, :queue)
    consumer_callback = Keyword.get(consumer_opts, :callback)
    state = %{amqp_opts: amqp_opts,
              consumer_queue: consumer_queue,
              consumer_callback: consumer_callback,
              chan: nil
            }
    rabbitmq_connect(state, false)
  end

  def publish(pid, exchange, routing_key, payload, options \\ []) do
    GenServer.call(pid, {:publish, exchange, routing_key, payload, options})
  end

  defp rabbitmq_connect(state, retry \\ true) do
    with {:ok, options} <- Map.fetch(state, :amqp_opts),
         {:ok, conn} <- Connection.open(options),
         # Get notifications when the connection goes down
         Process.monitor(conn.pid),
         # We link the connection to this process, that way if we die the connection dies too
         # This is useful since unacked messages are requeued only after the connection is dead
         Process.link(conn.pid),
         {:ok, chan} <- Channel.open(conn),
         {:ok, queue} <- Map.fetch(state, :consumer_queue),
         {:ok, _consumer_tag} <- Basic.consume(chan, queue) do
      {:ok, %{state | chan: chan}}

    else
      {:error, reason} ->
        Logger.warn("RabbitMQ Connection error: " <> inspect(reason))
        maybe_retry(state, retry)
      :error ->
        Logger.warn("Unknown RabbitMQ connection error")
        maybe_retry(state, retry)
    end
  end

  defp maybe_retry(state, retry) do
    if retry do
      :timer.sleep(@connection_backoff)
      rabbitmq_connect(state)
    else
      {:ok, state}
    end
  end

  # Server callbacks

  def handle_call({:publish, exchange, routing_key, payload, options}, _from, state) do
    Basic.publish(Map.get(state, :chan), exchange, routing_key, payload, options)
    {:reply, :ok, state}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, state) do
    # We process the message asynchronously
    spawn_link fn -> consume(Map.get(state, :chan), tag, redelivered, payload, Map.get(state, :consumer_callback)) end
    {:noreply, state}
  end

  # This callback should try to reconnect to the server
  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    {:ok, state} = rabbitmq_connect(state)
    {:noreply, state}
  end

  defp consume(chan, tag, redelivered, payload, callback) do
    case callback.(payload) do
      :ok -> Basic.ack(chan, tag)
      # We don't want to keep failing on the same message
      {:error, reason} ->
        Basic.reject(chan, tag, [requeue: not redelivered])
        # TODO: we want to be notified in some other way of failing messages
        Logger.warn("Message rejected with reason #{inspect(reason)}")
    end
  end
end
