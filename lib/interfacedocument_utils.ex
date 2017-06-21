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
      aggregation: AstarteCore.Interface.Aggregation.from_string(Map.get(interface_object, "aggregation", "individual"))
    }

    maps = for mapping <- interface_object["mappings"] do
      %AstarteCore.Mapping {
        endpoint: choose_string(mapping["endpoint"], mapping["path"]),
        value_type: AstarteCore.Mapping.ValueType.from_string(mapping["type"]),
        reliability: :unique,
        #string_to_mapping_reliability(mapping["reliability"]),
        retention: :stored,
        expiry: 0,
        allow_unset: false
      }
    end

    %AstarteCore.InterfaceDocument {
      descriptor: descriptor,
      mappings: maps
    }
  end

end
