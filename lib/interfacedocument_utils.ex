defmodule AstarteCore.InterfaceDocument.Utils do

  defp choose_string(a, b) do
    if (a != nil) and (String.strip(a) != "") do
      a
    else
      b
    end
  end

  def from_json(json_doc) do
    {:ok, interface_object} = Poison.decode(json_doc)

    descriptor = %AstarteCore.InterfaceDescriptor {
      name: interface_object["interface_name"],
      major_version: interface_object["version_major"],
      minor_version: interface_object["version_minor"],
      type: AstarteCore.Interface.Type.from_string(interface_object["type"]),
      ownership: AstarteCore.Interface.Ownership.from_string(choose_string(interface_object["ownership"], interface_object["quality"])),
      aggregation: AstarteCore.Interface.Aggregation.from_string(choose_string(
                                                                  (if interface_object["aggregate"], do: "object", else: nil),
                                                                  Map.get(interface_object, "aggregation", "individual")))
    }

    maps = for mapping <- interface_object["mappings"] do
      %AstarteCore.Mapping {
        endpoint: choose_string(mapping["endpoint"], mapping["path"]),
        value_type: AstarteCore.Mapping.ValueType.from_string(mapping["type"]),
        reliability: AstarteCore.Mapping.Reliability.from_string(Map.get(mapping, "reliability", "unreliable")),
        retention: AstarteCore.Mapping.Retention.from_string(Map.get(mapping, "retention", "discard")),
        expiry: Map.get(mapping, "expiry", 0),
        allow_unset: Map.get(mapping, "allow_unset", false)
      }
    end

    %AstarteCore.InterfaceDocument {
      descriptor: descriptor,
      mappings: maps,
      source: json_doc
    }
  end

end
