#
# This file is part of Astarte.
#
# Copyright 2017-2018 Ispirata Srl
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

defmodule Astarte.Core.StorageType do
  @behaviour Ecto.Type

  @multi_interface_individual_properties_dbtable 1
  @multi_interface_individual_datastream_dbtable 2
  @one_individual_properties_dbtable 3
  @one_individual_datastream_dbtable 4
  @one_object_datastream_dbtable 5
  @valid_atoms [
    :multi_interface_individual_properties_dbtable,
    :multi_interface_individual_datastream_dbtable,
    :one_individual_properties_dbtable,
    :one_individual_datastream_dbtable,
    :one_object_datastream_dbtable
  ]

  @impl true
  def type, do: :integer

  @impl true
  def cast(nil), do: {:ok, nil}

  def cast(atom) when is_atom(atom) do
    if Enum.member?(@valid_atoms, atom) do
      {:ok, atom}
    else
      :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(storage_type) when is_atom(storage_type) do
    case storage_type do
      :multi_interface_individual_properties_dbtable ->
        {:ok, @multi_interface_individual_properties_dbtable}

      :multi_interface_individual_datastream_dbtable ->
        {:ok, @multi_interface_individual_datastream_dbtable}

      :one_individual_properties_dbtable ->
        {:ok, @one_individual_properties_dbtable}

      :one_individual_datastream_dbtable ->
        {:ok, @one_individual_datastream_dbtable}

      :one_object_datastream_dbtable ->
        {:ok, @one_object_datastream_dbtable}

      _ ->
        :error
    end
  end

  @doc """
  returns storage_type associated int value.
  """
  def to_int(storage_type) when is_atom(storage_type) do
    case dump(storage_type) do
      {:ok, storage_type_int} ->
        storage_type_int

      :error ->
        raise ArgumentError, message: "#{inspect(storage_type)} is not a valid storage type"
    end
  end

  @impl true
  def load(storage_type_int) when is_integer(storage_type_int) do
    case storage_type_int do
      @multi_interface_individual_properties_dbtable ->
        {:ok, :multi_interface_individual_properties_dbtable}

      @multi_interface_individual_datastream_dbtable ->
        {:ok, :multi_interface_individual_datastream_dbtable}

      @one_individual_properties_dbtable ->
        {:ok, :one_individual_properties_dbtable}

      @one_individual_datastream_dbtable ->
        {:ok, :one_individual_datastream_dbtable}

      @one_object_datastream_dbtable ->
        {:ok, :one_object_datastream_dbtable}

      _ ->
        :error
    end
  end

  @doc """
  returns storage_type atom from a valid storage type int value.
  """
  def from_int(storage_type_int) when is_integer(storage_type_int) do
    case load(storage_type_int) do
      {:ok, storage_type} ->
        storage_type

      :error ->
        raise ArgumentError,
          message: "#{storage_type_int} is not a valid storage type int representation"
    end
  end
end
