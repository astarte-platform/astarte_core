defmodule Astarte.Core.InterfaceDocument do
  defstruct descriptor: %Astarte.Core.InterfaceDescriptor{},
    mappings: [],
    source: ""

  defp check_mappings([mapping | tail]) do
    Astarte.Core.Mapping.is_valid?(mapping) and check_mappings(tail)
  end

  defp check_mappings([]) do
    true
  end

  def from_json(json_doc) do
    {:ok, interface_object} = Poison.decode(json_doc)

    %{"interface_name" => name,
      "version_major" => major_version,
      "version_minor" => minor_version,
      "type" => type} = interface_object

    descriptor = %Astarte.Core.InterfaceDescriptor {
      name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: Astarte.Core.Interface.Type.from_string(type),
      ownership: Astarte.Core.Interface.Ownership.from_string(interface_object["ownership"] || interface_object["quality"]),
      aggregation: Astarte.Core.Interface.Aggregation.from_string((if interface_object["aggregate"], do: "object", else: nil)
                                                                  || Map.get(interface_object, "aggregation", "individual")),
      has_metadata: Map.get(interface_object, "has_metadata", false),
      explicit_timestamp: Map.get(interface_object, "explicit_timestamp", false)
    }

    maps = for mapping <- interface_object["mappings"] do
      %Astarte.Core.Mapping {
        endpoint: mapping["endpoint"] || mapping["path"],
        value_type: Astarte.Core.Mapping.ValueType.from_string(mapping["type"]),
        reliability: Astarte.Core.Mapping.Reliability.from_string(Map.get(mapping, "reliability", "unreliable")),
        retention: Astarte.Core.Mapping.Retention.from_string(Map.get(mapping, "retention", "discard")),
        expiry: Map.get(mapping, "expiry", 0),
        allow_unset: Map.get(mapping, "allow_unset", false)
      }
    end

    if (check_mappings(maps) and Astarte.Core.InterfaceDescriptor.is_valid?(descriptor)) do
      %Astarte.Core.InterfaceDocument {
        descriptor: descriptor,
        mappings: maps,
        source: json_doc
      }
    else
      nil
    end
  end

end
