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

defmodule Astarte.Core.Interface.Aggregation do
  @behaviour Ecto.Type

  @interface_aggregation_individual 1
  @interface_aggregation_object 2
  @valid_atoms [
    :individual,
    :object
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
      "individual" -> {:ok, :individual}
      "object" -> {:ok, :object}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(aggregation) when is_atom(aggregation) do
    case aggregation do
      :individual -> {:ok, @interface_aggregation_individual}
      :object -> {:ok, @interface_aggregation_object}
      _ -> :error
    end
  end

  def to_int(aggregation) when is_atom(aggregation) do
    case dump(aggregation) do
      {:ok, aggregation_int} -> aggregation_int
      :error -> raise ArgumentError, message: "#{inspect(aggregation)} is not a valid aggregation"
    end
  end

  @impl true
  def load(aggregation_int) when is_integer(aggregation_int) do
    case aggregation_int do
      @interface_aggregation_individual -> {:ok, :individual}
      @interface_aggregation_object -> {:ok, :object}
      _ -> :error
    end
  end

  def from_int(aggregation_int) when is_integer(aggregation_int) do
    case load(aggregation_int) do
      {:ok, aggregation} ->
        aggregation

      :error ->
        raise ArgumentError,
          message: "#{aggregation_int} is not a valid aggregation int representation"
    end
  end
end
