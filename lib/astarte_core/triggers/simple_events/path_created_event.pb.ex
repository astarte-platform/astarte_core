defmodule Astarte.Core.Triggers.SimpleEvents.PathCreatedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "PathCreatedEvent"

  field :interface, 1, proto3_optional: true, type: :string
  field :path, 2, proto3_optional: true, type: :string
  field :bson_value, 3, proto3_optional: true, type: :bytes, json_name: "bsonValue"
end
