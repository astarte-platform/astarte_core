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
