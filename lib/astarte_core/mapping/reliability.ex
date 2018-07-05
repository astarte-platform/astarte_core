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

defmodule Astarte.Core.Mapping.Reliability do
  @behaviour Ecto.Type

  @mapping_reliability_unreliable 1
  @mapping_reliability_guaranteed 2
  @mapping_reliability_unique 3
  @valid_atoms [
    :unreliable,
    :guaranteed,
    :unique
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
      "unreliable" -> {:ok, :unreliable}
      "guaranteed" -> {:ok, :guaranteed}
      "unique" -> {:ok, :unique}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(reliability) when is_atom(reliability) do
    case reliability do
      :unreliable -> {:ok, @mapping_reliability_unreliable}
      :guaranteed -> {:ok, @mapping_reliability_guaranteed}
      :unique -> {:ok, @mapping_reliability_unique}
      _ -> :error
    end
  end

  def to_int(reliability) when is_atom(reliability) do
    case dump(reliability) do
      {:ok, int} -> int
      :error -> raise ArgumentError, message: "#{inspect(reliability)} is not a valid reliability"
    end
  end

  @impl true
  def load(reliability_int) when is_integer(reliability_int) do
    case reliability_int do
      @mapping_reliability_unreliable -> {:ok, :unreliable}
      @mapping_reliability_guaranteed -> {:ok, :guaranteed}
      @mapping_reliability_unique -> {:ok, :unique}
      _ -> :error
    end
  end

  def from_int(reliability_int) when is_integer(reliability_int) do
    case load(reliability_int) do
      {:ok, reliability} ->
        reliability

      :error ->
        raise ArgumentError,
          message: "#{reliability_int} is not a valid reliability int representation"
    end
  end
end
