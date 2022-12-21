defmodule Astarte.Core.AstarteReference do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "AstarteReference"

  field :object_type, 1, type: :int32, json_name: "objectType"
  field :object_uuid, 2, proto3_optional: true, type: :bytes, json_name: "objectUuid"
end
