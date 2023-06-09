defmodule Astarte.Core.Triggers.SimpleEvents.InterfaceRemovedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "InterfaceRemovedEvent"

  field :interface, 1, proto3_optional: true, type: :string
  field :major_version, 2, type: :int32, json_name: "majorVersion"
end
