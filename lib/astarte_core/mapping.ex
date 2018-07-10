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

defmodule Astarte.Core.Mapping do
  @moduledoc """
  This module handles Interface Mappings using Ecto Changesets
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Astarte.Core.Mapping
  alias Astarte.Core.Mapping.ValueType
  alias Astarte.Core.Mapping.Reliability
  alias Astarte.Core.Mapping.Retention

  @required_fields [
    :endpoint,
    :type
  ]
  @permitted_fields [
    :reliability,
    :retention,
    :expiry,
    :allow_unset,
    :path
    | @required_fields
  ]

  @primary_key false
  embedded_schema do
    field :endpoint
    field :value_type, ValueType
    field :reliability, Reliability, default: :unreliable
    field :retention, Retention, default: :discard
    field :expiry, :integer, default: 0
    field :allow_unset, :boolean, default: false
    field :endpoint_id, :binary
    field :interface_id, :binary
    # Legacy support
    field :path, :string, virtual: true
    # Different input naming
    field :type, ValueType, virtual: true
  end

  def changeset(%Mapping{} = mapping, params \\ %{}) do

    mapping
    |> cast(params, @permitted_fields)
    |> handle_legacy_endpoint()
    |> validate_required(@required_fields)
    |> validate_format(:endpoint, mapping_regex())
    |> validate_number(:expiry, greater_than_or_equal_to: 0)
    |> normalize_fields()
  end

  defp handle_legacy_endpoint(%Ecto.Changeset{} = changeset) do
    if get_field(changeset, :endpoint) do
      changeset
    else
      path = get_change(changeset, :path)
      put_change(changeset, :endpoint, path)
    end
  end

  defp normalize_fields(changeset) do
    type_change = get_change(changeset, :type)

    changeset
    |> delete_change(:type)
    |> put_change(:value_type, type_change)
  end

  def is_valid?(mapping) do
    if mapping != nil and mapping != "" and mapping != [] do
      String.match?(
        mapping.endpoint,
        mapping_regex()
      ) and mapping.value_type != nil and is_atom(mapping.value_type)
    else
      false
    end
  end

  def mapping_regex do
    ~r/^((\/%{[a-zA-Z]+[a-zA-Z0-9]*})*(\/[a-zA-Z]+[a-zA-Z0-9]*)*)+$/
  end

  @doc """
  Removes all placeholders from an endpoint.
  """
  @spec normalize_endpoint(String.t()) :: String.t()
  def normalize_endpoint(endpoint) when is_binary(endpoint) do
    String.replace(endpoint, ~r/%{[a-zA-Z0-9]*}/, "")
  end

  @doc """
  Deserializes a `%Mapping{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `%Mapping{}` on success,
  raises on failure
  """
  def from_db_result!(db_result) when not is_map(db_result) do
    db_result
    |> Enum.into(%{})
    |> from_db_result!()
  end

  def from_db_result!(db_result) do
    %{
      endpoint: endpoint,
      value_type: value_type,
      reliabilty: reliability,
      retention: retention,
      expiry: expiry,
      allow_unset: allow_unset,
      endpoint_id: endpoint_id,
      interface_id: interface_id
    } = db_result

    %Mapping{
      endpoint: endpoint,
      value_type: ValueType.from_int(value_type),
      reliability: Reliability.from_int(reliability),
      retention: Retention.from_int(retention),
      expiry: expiry,
      allow_unset: allow_unset,
      endpoint_id: endpoint_id,
      interface_id: interface_id
    }
  end
end
