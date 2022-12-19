defmodule Astarte.Core.Triggers.SimpleEvents.DeviceDisconnectedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "DeviceDisconnectedEvent"
end
