defmodule Astarte.Core.Triggers.SimpleEvents.PathRemovedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  def fully_qualified_name, do: "PathRemovedEvent"

  field :interface, 1, proto3_optional: true, type: :string
  field :path, 2, proto3_optional: true, type: :string
end
