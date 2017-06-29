defmodule Astarte.Core.InterfaceDocument.Utils do

  defp choose_string(a, b) do
    if (a != nil) and (String.strip(a) != "") do
      a
    else
      b
    end
  end

  def from_json(json_doc) do
    {:ok, interface_object} = Poison.decode(json_doc)

    descriptor = %Astarte.Core.InterfaceDescriptor {
      name: interface_object["interface_name"],
      major_version: interface_object["version_major"],
      minor_version: interface_object["version_minor"],
      type: Astarte.Core.Interface.Type.from_string(interface_object["type"]),
      ownership: Astarte.Core.Interface.Ownership.from_string(choose_string(interface_object["ownership"], interface_object["quality"])),
      aggregation: Astarte.Core.Interface.Aggregation.from_string(choose_string(
                                                                  (if interface_object["aggregate"], do: "object", else: nil),
                                                                  Map.get(interface_object, "aggregation", "individual")))
    }

    maps = for mapping <- interface_object["mappings"] do
      %Astarte.Core.Mapping {
        endpoint: choose_string(mapping["endpoint"], mapping["path"]),
        value_type: Astarte.Core.Mapping.ValueType.from_string(mapping["type"]),
        reliability: Astarte.Core.Mapping.Reliability.from_string(Map.get(mapping, "reliability", "unreliable")),
        retention: Astarte.Core.Mapping.Retention.from_string(Map.get(mapping, "retention", "discard")),
        expiry: Map.get(mapping, "expiry", 0),
        allow_unset: Map.get(mapping, "allow_unset", false)
      }
    end

    %Astarte.Core.InterfaceDocument {
      descriptor: descriptor,
      mappings: maps,
      source: json_doc
    }
  end

end
