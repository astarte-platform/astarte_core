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

defmodule Astarte.Core.Mapping do
  alias Astarte.Core.Mapping
  alias Astarte.Core.Mapping.ValueType
  alias Astarte.Core.Mapping.Reliability
  alias Astarte.Core.Mapping.Retention

  defstruct endpoint: "",
            value_type: nil,
            reliability: nil,
            retention: nil,
            expiry: 0,
            allow_unset: false,
            endpoint_id: nil,
            interface_id: nil

  def is_valid?(mapping) do
    if mapping != nil and mapping != "" and mapping != [] do
      String.match?(
        mapping.endpoint,
        mapping_regex()
      ) and mapping.value_type != nil and is_atom(mapping.value_type)
    else
      false
    end
  end

  def mapping_regex do
    ~r/^((\/%{[a-zA-Z]+[a-zA-Z0-9]*})*(\/[a-zA-Z]+[a-zA-Z0-9]*)*)+$/
  end

  @doc """
  Deserializes a `%Mapping{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `%Mapping{}` on success,
  raises on failure
  """
  def from_db_result!(db_result) when not is_map(db_result) do
    db_result
    |> Enum.into(%{})
    |> from_db_result!()
  end

  def from_db_result!(db_result) do
    %{
      endpoint: endpoint,
      value_type: value_type,
      reliabilty: reliability,
      retention: retention,
      expiry: expiry,
      allow_unset: allow_unset,
      endpoint_id: endpoint_id,
      interface_id: interface_id
    } = db_result

    %Mapping{
      endpoint: endpoint,
      value_type: ValueType.from_int(value_type),
      reliability: Reliability.from_int(reliability),
      retention: Retention.from_int(retention),
      expiry: expiry,
      allow_unset: allow_unset,
      endpoint_id: endpoint_id,
      interface_id: interface_id
    }
  end
end
