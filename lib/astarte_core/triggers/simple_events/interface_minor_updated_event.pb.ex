defmodule Astarte.Core.Triggers.SimpleEvents.InterfaceMinorUpdatedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "InterfaceMinorUpdatedEvent"

  field :interface, 1, proto3_optional: true, type: :string
  field :major_version, 2, type: :int32, json_name: "majorVersion"
  field :old_minor_version, 3, type: :int32, json_name: "oldMinorVersion"
  field :new_minor_version, 4, type: :int32, json_name: "newMinorVersion"
end
