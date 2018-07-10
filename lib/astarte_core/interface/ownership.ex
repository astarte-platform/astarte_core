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

defmodule Astarte.Core.Interface.Ownership do
  @behaviour Ecto.Type

  @interface_ownership_device 1
  @interface_ownership_server 2
  @valid_atoms [
    :device,
    :server
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
      "device" ->
        {:ok, :device}

      "server" ->
        {:ok, :server}

      # deprecated names
      "producer" ->
        {:ok, :device}

      "consumer" ->
        {:ok, :server}

      _ ->
        :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(ownership) when is_atom(ownership) do
    case ownership do
      :device -> {:ok, @interface_ownership_device}
      :server -> {:ok, @interface_ownership_server}
      _ -> :error
    end
  end

  def to_int(ownership) when is_atom(ownership) do
    case dump(ownership) do
      {:ok, ownership_int} -> ownership_int
      :error -> raise ArgumentError, message: "#{inspect(ownership)} is not a valid ownership"
    end
  end

  @impl true
  def load(ownership_int) when is_integer(ownership_int) do
    case ownership_int do
      @interface_ownership_device -> {:ok, :device}
      @interface_ownership_server -> {:ok, :server}
      _ -> :error
    end
  end

  def from_int(ownership_int) when is_integer(ownership_int) do
    case load(ownership_int) do
      {:ok, ownership} ->
        ownership

      :error ->
        raise ArgumentError,
          message: "#{ownership_int} is not a valid ownership int representation"
    end
  end
end
