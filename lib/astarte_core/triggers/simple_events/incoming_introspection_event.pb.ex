defmodule Astarte.Core.Triggers.SimpleEvents.InterfaceVersion do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :major, 1, type: :int32
  field :minor, 2, type: :int32
end

defmodule Astarte.Core.Triggers.SimpleEvents.IncomingIntrospectionEvent.IntrospectionMapEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Astarte.Core.Triggers.SimpleEvents.InterfaceVersion
end

defmodule Astarte.Core.Triggers.SimpleEvents.IncomingIntrospectionEvent do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :introspection, 1, proto3_optional: true, type: :string, deprecated: true

  field :introspection_map, 2,
    repeated: true,
    type: Astarte.Core.Triggers.SimpleEvents.IncomingIntrospectionEvent.IntrospectionMapEntry,
    json_name: "introspectionMap",
    map: true
end
