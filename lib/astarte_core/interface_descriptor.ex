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

defmodule Astarte.Core.InterfaceDescriptor do
  alias Astarte.Core.InterfaceDescriptor

  defstruct name: "",
    major_version: 0,
    minor_version: 0,
    type: nil,
    ownership: nil,
    aggregation: nil,
    explicit_timestamp: false,
    has_metadata: false,
    interface_id: nil,
    automaton: nil,
    storage: nil,
    storage_type: nil

  def validate(interface_descriptor) do
    cond do
      interface_descriptor == nil ->
        {:error, :null_interface_descriptor}

      interface_descriptor == "" ->
        {:error, :not_an_interface_descriptor}

      interface_descriptor == [] ->
        {:error, :not_an_interface_descriptor}

      String.length(interface_descriptor.name <> "_v" <> Integer.to_string(interface_descriptor.major_version)) >= 48 ->
        {:error, :too_long_interface_name}

      String.match?(interface_descriptor.name, ~r/^[a-zA-Z]+(\.[a-zA-Z0-9]+)*$/) == false ->
        {:error, :invalid_interface_name}

      interface_descriptor.major_version < 0 ->
        {:error, :invalid_major_version}

      interface_descriptor.major_version < 0 ->
        {:error, :invalid_minor_version}

      (interface_descriptor.major_version == 0) and (interface_descriptor.minor_version == 0) ->
        {:error, :invalid_minor_version}

      ((interface_descriptor.type == :properties) or (interface_descriptor.type == :datastream)) == false ->
        {:error, :invalid_interface_type}

      ((interface_descriptor.ownership == :thing) or (interface_descriptor.ownership == :server)) == false ->
        {:error, :invalid_interface_ownership}

      ((interface_descriptor.aggregation == :individual) or (interface_descriptor.aggregation == :object)) == false ->
        {:error, :invalid_interface_aggregation}

      (interface_descriptor.type != :datastream) and interface_descriptor.explicit_timestamp ->
        {:error, :explicit_timestamp_not_allowed}

      ((interface_descriptor.aggregation != :individual) or (interface_descriptor.type != :datastream)) and interface_descriptor.has_metadata ->
        {:error, :metadata_not_allowed}

      true ->
        :ok
    end
  end

  def is_valid?(interface_descriptor) do
    validate(interface_descriptor) == :ok
  end

  @doc """
  Deserializes an `%InterfaceDescriptor{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `%InterfaceDescriptor{}` on success,
  raises on failure
  """
  def from_db_result!(db_result) when not is_map(db_result) do
    db_result
    |> Enum.into(%{})
    |> from_db_result!()
  end

  def from_db_result!(db_result) do
    %{name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: type,
      quality: ownership,

      flags: flags,
      automaton_accepting_states: automaton_accepting_states,
      automaton_transitions: automaton_transitions,
      storage: storage,
      storage_type: storage_type,
      interface_id: interface_id,
    } = db_result

    %InterfaceDescriptor{
      name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: Astarte.Core.Interface.Type.from_int(type),
      ownership: Astarte.Core.Interface.Ownership.from_int(ownership),
      aggregation: Astarte.Core.Interface.Aggregation.from_int(flags),
      storage: storage,
      storage_type: storage_type,
      automaton: {:erlang.binary_to_term(automaton_transitions), :erlang.binary_to_term(automaton_accepting_states)},
      interface_id: interface_id
    }
  end
end
