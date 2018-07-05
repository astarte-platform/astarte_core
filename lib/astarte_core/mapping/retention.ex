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

defmodule Astarte.Core.Mapping.Retention do
  @behaviour Ecto.Type

  @mapping_retention_discard 1
  @mapping_retention_volatile 2
  @mapping_retention_stored 3
  @valid_atoms [
    :discard,
    :volatile,
    :stored
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
      "discard" -> {:ok, :discard}
      "volatile" -> {:ok, :volatile}
      "stored" -> {:ok, :stored}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(retention) when is_atom(retention) do
    case retention do
      :discard -> {:ok, @mapping_retention_discard}
      :volatile -> {:ok, @mapping_retention_volatile}
      :stored -> {:ok, @mapping_retention_stored}
      _ -> :error
    end
  end

  def to_int(retention) when is_atom(retention) do
    case dump(retention) do
      {:ok, int} -> int
      :error -> raise ArgumentError, message: "#{inspect(retention)} is not a valid retention"
    end
  end

  @impl true
  def load(retention_int) when is_integer(retention_int) do
    case retention_int do
      @mapping_retention_discard -> {:ok, :discard}
      @mapping_retention_volatile -> {:ok, :volatile}
      @mapping_retention_stored -> {:ok, :stored}
      _ -> :error
    end
  end

  def from_int(retention_int) when is_integer(retention_int) do
    case load(retention_int) do
      {:ok, retention} ->
        retention

      :error ->
        raise ArgumentError,
          message: "#{retention_int} is not a valid retention int representation"
    end
  end
end
