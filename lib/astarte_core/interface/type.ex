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

defmodule Astarte.Core.Interface.Type do
  use Ecto.Type

  @interface_type_properties 1
  @interface_type_datastream 2
  @valid_atoms [
    :properties,
    :datastream
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

  def cast(string) when is_binary(string) do
    case string do
      "properties" -> {:ok, :properties}
      "datastream" -> {:ok, :datastream}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(type) when is_atom(type) do
    case type do
      :properties -> {:ok, @interface_type_properties}
      :datastream -> {:ok, @interface_type_datastream}
      _ -> :error
    end
  end

  def to_int(type) when is_atom(type) do
    case dump(type) do
      {:ok, type_int} -> type_int
      :error -> raise ArgumentError, message: "#{inspect(type)} is not a valid interface type"
    end
  end

  @impl true
  def load(type_int) when is_integer(type_int) do
    case type_int do
      @interface_type_properties -> {:ok, :properties}
      @interface_type_datastream -> {:ok, :datastream}
      _ -> :error
    end
  end

  def from_int(type_int) when is_integer(type_int) do
    case load(type_int) do
      {:ok, type} ->
        type

      :error ->
        raise ArgumentError,
          message: "#{type_int} is not a valid interface type int representation"
    end
  end
end
