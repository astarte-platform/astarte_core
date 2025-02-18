#
# This file is part of Astarte.
#
# Copyright 2017-2024 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Core.InterfaceDescriptor do
  alias Astarte.Core.Interface
  alias Astarte.Core.Interface.Aggregation
  alias Astarte.Core.Interface.Ownership
  alias Astarte.Core.Interface.Type
  alias Astarte.Core.InterfaceDescriptor
  alias Astarte.Core.StorageType

  defstruct name: "",
            major_version: 0,
            minor_version: 0,
            type: nil,
            ownership: nil,
            aggregation: nil,
            interface_id: nil,
            automaton: nil,
            storage: nil,
            storage_type: nil

  @doc """
  Deserializes an `%InterfaceDescriptor{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `{:ok, %InterfaceDescriptor{}}` on success,
  `{:error, :invalid_interface_descriptor_data}` on failure.
  """
  def from_db_result(db_result) when not is_map(db_result) do
    db_result
    |> Enum.into(%{})
    |> from_db_result()
  end

  def from_db_result(db_result) do
    with %{
           name: name,
           major_version: major_version,
           minor_version: minor_version,
           type: type,
           ownership: ownership,
           aggregation: aggregation,
           automaton_accepting_states: automaton_accepting_states,
           automaton_transitions: automaton_transitions,
           storage: storage,
           storage_type: storage_type,
           interface_id: interface_id
         } <- db_result do
      interface_descriptor = %InterfaceDescriptor{
        name: name,
        major_version: major_version,
        minor_version: minor_version,
        type: Type.cast!(type),
        ownership: Ownership.cast!(ownership),
        aggregation: Aggregation.cast!(aggregation),
        storage: storage,
        storage_type: StorageType.cast!(storage_type),
        automaton:
          {:erlang.binary_to_term(automaton_transitions),
           :erlang.binary_to_term(automaton_accepting_states)},
        interface_id: interface_id
      }

      {:ok, interface_descriptor}
    else
      _ ->
        {:error, :invalid_interface_descriptor_data}
    end
  end

  @doc """
  Deserializes an `%InterfaceDescriptor{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `%InterfaceDescriptor{}` on success,
  raises on failure
  """
  def from_db_result!(db_result) do
    with {:ok, interface_descriptor} <- from_db_result(db_result) do
      interface_descriptor
    else
      _ ->
        raise ArgumentError
    end
  end

  @doc """
  Builds an `%InterfaceDescriptor{}` starting from an `%Interface{}`

  Returns the `%InterfaceDescriptor{}`
  """
  def from_interface(%Interface{} = interface) do
    %Interface{
      interface_id: interface_id,
      name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: type,
      ownership: ownership,
      aggregation: aggregation
    } = interface

    %InterfaceDescriptor{
      interface_id: interface_id,
      name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: type,
      ownership: ownership,
      aggregation: aggregation
    }
  end
end
