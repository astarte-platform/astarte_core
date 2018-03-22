#
# Copyright (C) 2017 Ispirata Srl
#
# This file is part of Astarte.
# Astarte is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Astarte is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Astarte.  If not, see <http://www.gnu.org/licenses/>.
#

defmodule Astarte.Core.InterfaceDocument do
  defstruct descriptor: %Astarte.Core.InterfaceDescriptor{},
            mappings: [],
            source: ""

  @doc """
  Creates an `%InterfaceDocument{}` starting from its JSON description.

  Returns `{:ok, %InterfaceDocument{}}` on success and `:error` on failure.
  """
  def from_json(json_doc) do
    case Poison.decode(json_doc) do
      {:error, _} ->
        :error

      {:ok, interface_object} ->
        %{
          "interface_name" => name,
          "version_major" => major_version,
          "version_minor" => minor_version,
          "type" => type
        } = interface_object

        descriptor = %Astarte.Core.InterfaceDescriptor{
          name: name,
          major_version: major_version,
          minor_version: minor_version,
          type: Astarte.Core.Interface.Type.from_string(type),
          ownership:
            Astarte.Core.Interface.Ownership.from_string(
              interface_object["ownership"] || interface_object["quality"]
            ),
          aggregation:
            Astarte.Core.Interface.Aggregation.from_string(
              if(interface_object["aggregate"], do: "object", else: nil) ||
                Map.get(interface_object, "aggregation", "individual")
            ),
          has_metadata: Map.get(interface_object, "has_metadata", false),
          explicit_timestamp: Map.get(interface_object, "explicit_timestamp", false)
        }

        maps =
          for mapping <- interface_object["mappings"] do
            %Astarte.Core.Mapping{
              endpoint: mapping["endpoint"] || mapping["path"],
              value_type: Astarte.Core.Mapping.ValueType.from_string(mapping["type"]),
              reliability:
                Astarte.Core.Mapping.Reliability.from_string(
                  Map.get(mapping, "reliability", "unreliable")
                ),
              retention:
                Astarte.Core.Mapping.Retention.from_string(
                  Map.get(mapping, "retention", "discard")
                ),
              expiry: Map.get(mapping, "expiry", 0),
              allow_unset: Map.get(mapping, "allow_unset", false)
            }
          end

        if check_mappings(maps) and Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) do
          doc = %Astarte.Core.InterfaceDocument{
            descriptor: descriptor,
            mappings: maps,
            source: json_doc
          }

          {:ok, doc}
        else
          :error
        end
    end
  end

  defp check_mappings(mappings) do
    Enum.all?(mappings, &Astarte.Core.Mapping.is_valid?/1)
  end
end
