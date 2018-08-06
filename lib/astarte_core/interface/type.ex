#
# Copyright (C) 2017-2018 Ispirata Srl
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

defmodule Astarte.Core.Interface.Type do
  @behaviour Ecto.Type

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
