defmodule Astarte.Core.Triggers.PolicyProtobuf.Policy do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "Policy"

  field :name, 1, proto3_optional: true, type: :string
  field :maximum_capacity, 2, type: :int32, json_name: "maximumCapacity"
  field :retry_times, 3, type: :int32, json_name: "retryTimes"
  field :event_ttl, 4, type: :int32, json_name: "eventTtl"

  field :error_handlers, 5,
    repeated: true,
    type: Astarte.Core.Triggers.PolicyProtobuf.Handler,
    json_name: "errorHandlers"
end
