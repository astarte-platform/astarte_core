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

defmodule Astarte.Core.Mapping do
  @moduledoc """
  This module handles Interface Mappings using Ecto Changesets
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Mapping
  alias Astarte.Core.Mapping.ValueType
  alias Astarte.Core.Mapping.Reliability
  alias Astarte.Core.Mapping.Retention

  @placeholder_regex ~r/%{[a-zA-Z]+[a-zA-Z0-9_]*}/

  @required_fields [
    :endpoint,
    :type
  ]
  @permitted_fields [
    :reliability,
    :retention,
    :expiry,
    :allow_unset,
    :explicit_timestamp,
    :description,
    :doc,
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
    field :explicit_timestamp, :boolean, default: false
    field :description
    field :doc
    field :endpoint_id, :binary
    field :interface_id, :binary
    # Legacy support
    field :path, :string, virtual: true
    # Different input naming
    field :type, ValueType, virtual: true
  end

  def changeset(%Mapping{} = mapping, %{} = params, opts) do
    # We need those, so we raise if they're not there
    # Note that they can be there but be nil,
    # but this would be handled from the parent changeset
    interface_name = Keyword.fetch!(opts, :interface_name)
    interface_major = Keyword.fetch!(opts, :interface_major)
    interface_id = Keyword.fetch!(opts, :interface_id)
    interface_type = Keyword.get(opts, :interface_type)

    mapping
    |> cast(params, @permitted_fields)
    |> handle_legacy_endpoint()
    |> validate_required(@required_fields)
    |> validate_length(:endpoint, min: 2, max: 256)
    |> validate_format(:endpoint, mapping_regex())
    |> validate_number(:expiry, greater_than_or_equal_to: 0)
    |> validate_not_set_unless(:allow_unset, interface_type, [:properties, nil])
    |> validate_not_set_unless(:expiry, interface_type, [:datastream, nil])
    |> validate_not_set_unless(:retention, interface_type, [:datastream, nil])
    |> validate_not_set_unless(:reliability, interface_type, [:datastream, nil])
    |> validate_not_set_unless(:explicit_timestamp, interface_type, [:datastream, nil])
    |> validate_length(:description, max: 1000)
    |> validate_length(:doc, max: 100_000)
    |> normalize_fields()
    |> put_change(:interface_id, interface_id)
    |> put_endpoint_id(interface_name, interface_major)
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

  defp put_endpoint_id(changeset, interface_name, interface_major)
       when is_binary(interface_name) and is_integer(interface_major) do
    if endpoint_name = get_field(changeset, :endpoint) do
      endpoint_id = CQLUtils.endpoint_id(interface_name, interface_major, endpoint_name)
      put_change(changeset, :endpoint_id, endpoint_id)
    else
      changeset
    end
  end

  # Interface errors will be handled by the parent changeset, just force it to invalid
  defp put_endpoint_id(changeset, _interface_name, _interface_major) do
    %{changeset | valid?: false}
  end

  def mapping_regex do
    ~r/^(\/(%{([a-zA-Z]+[a-zA-Z0-9_]*)}|[a-zA-Z]+[a-zA-Z0-9_]*)){1,64}$/
  end

  @doc """
  Removes all placeholders from an endpoint.
  """
  @spec normalize_endpoint(String.t()) :: String.t()
  def normalize_endpoint(endpoint) when is_binary(endpoint) do
    String.replace(endpoint, @placeholder_regex, "")
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
      reliability: reliability,
      retention: retention,
      expiry: expiry,
      allow_unset: allow_unset,
      explicit_timestamp: explicit_timestamp,
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
      explicit_timestamp: explicit_timestamp,
      endpoint_id: endpoint_id,
      interface_id: interface_id
    }
  end

  defp validate_not_set_unless(changeset, field, param, values) do
    unless Enum.member?(values, param) do
      validate_change(changeset, field, fn field, value ->
        if value != nil do
          [{field, "must be blank"}]
        else
          []
        end
      end)
    else
      changeset
    end
  end

  defimpl Poison.Encoder, for: Mapping do
    def encode(%Mapping{} = mapping, options) do
      %Mapping{
        endpoint: endpoint,
        value_type: value_type,
        reliability: reliability,
        retention: retention,
        expiry: expiry,
        allow_unset: allow_unset,
        explicit_timestamp: explicit_timestamp,
        description: description,
        doc: doc
      } = mapping

      %{
        endpoint: endpoint,
        type: value_type
      }
      |> add_key_if_not_default(:reliability, reliability, :unreliable)
      |> add_key_if_not_default(:retention, retention, :discard)
      |> add_key_if_not_default(:expiry, expiry, 0)
      |> add_key_if_not_default(:allow_unset, allow_unset, false)
      |> add_key_if_not_default(:explicit_timestamp, explicit_timestamp, false)
      |> add_key_if_not_nil(:description, description)
      |> add_key_if_not_nil(:doc, doc)
      |> Poison.Encoder.Map.encode(options)
    end

    defp add_key_if_not_default(encode_map, _key, default, default), do: encode_map

    defp add_key_if_not_default(encode_map, key, value, _default) do
      Map.put(encode_map, key, value)
    end

    defp add_key_if_not_nil(encode_map, _key, nil), do: encode_map

    defp add_key_if_not_nil(encode_map, key, value) do
      Map.put(encode_map, key, value)
    end
  end
end
