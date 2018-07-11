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

defmodule Astarte.Core.Interface do
  use Ecto.Schema
  import Ecto.Changeset

  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Interface.Aggregation
  alias Astarte.Core.Interface.Ownership
  alias Astarte.Core.Interface.Type
  alias Astarte.Core.Interface
  alias Astarte.Core.Mapping

  @required_fields [
    :interface_name,
    :version_major,
    :version_minor,
    :type,
    :ownership,
  ]

  @permitted_fields [
    :aggregation,
    :explicit_timestamp,
    :has_metadata,
    :quality,
    :aggregate
    | @required_fields
  ]

  @primary_key false
  embedded_schema do
    field :interface_id, :binary
    field :name
    field :major_version, :integer
    field :minor_version, :integer
    field :type, Type
    field :ownership, Ownership
    field :aggregation, Aggregation, default: :individual
    field :explicit_timestamp, :boolean, default: false
    field :has_metadata, :boolean, default: false
    embeds_many :mappings, Mapping
    # Legacy
    field :quality, Ownership, virtual: true
    field :aggregate, :boolean, virtual: true
    # Different input naming
    field :interface_name, :string, virtual: true
    field :version_major, :integer, virtual: true
    field :version_minor, :integer, virtual: true
  end

  def changeset(%Interface{} = interface, params \\ %{}) do
    changeset =
      interface
      |> cast(params, @permitted_fields)
      |> handle_legacy_ownership()
      |> handle_legacy_aggregation()
      |> validate_required(@required_fields)
      |> validate_length(:interface_name, max: 128)
      |> validate_format(:interface_name, interface_name_regex())
      |> validate_number(:version_major, greater_than_or_equal_to: 0)
      |> validate_number(:version_minor, greater_than_or_equal_to: 0)
      |> validate_non_null_version()
      |> validate_explicit_timestamp()
      |> validate_has_metadata()
      |> put_interface_id()
      |> normalize_fields()

    # We break the pipe because we need the changeset as argument to mapping_changeset
    changeset
    |> cast_embed(:mappings, required: true, with: mapping_changeset(changeset))
    |> validate_mapping_uniqueness()
  end

  def interface_name_regex do
    ~r/^[a-zA-Z]+(\.[a-zA-Z0-9]+)*$/
  end

  defp handle_legacy_ownership(changeset) do
    if get_field(changeset, :ownership) do
      delete_change(changeset, :quality)
    else
      quality = get_change(changeset, :quality)

      changeset
      |> delete_change(:quality)
      |> put_change(:ownership, quality)
    end
  end

  defp handle_legacy_aggregation(changeset) do
    cond do
      get_change(changeset, :aggregation) ->
        delete_change(changeset, :aggregate)

      get_field(changeset, :aggregate) ->
        changeset
        |> delete_change(:aggregate)
        |> put_change(:aggregation, :object)

      true ->
        changeset
    end
  end

  defp mapping_changeset(%Ecto.Changeset{} = changeset) do
    name = get_field(changeset, :name)
    major = get_field(changeset, :major_version)
    minor = get_field(changeset, :minor_version)
    interface_id = get_field(changeset, :interface_id)
    opts = [interface_name: name, interface_major: major, interface_minor: minor, interface_id: interface_id]

    fn type, params ->
      Mapping.changeset(type, params, opts)
    end
  end

  # Map the input fields to the expected internal fields
  defp normalize_fields(changeset) do
    name = get_field(changeset, :interface_name)
    major = get_field(changeset, :version_major)
    minor = get_field(changeset, :version_minor)

    changeset
    |> delete_change(:interface_name)
    |> delete_change(:version_major)
    |> delete_change(:version_minor)
    |> put_change(:name, name)
    |> put_change(:major_version, major)
    |> put_change(:minor_version, minor)
  end

  defp put_interface_id(changeset) do
    with {_, name} when is_binary(name) <- fetch_field(changeset, :interface_name),
         {_, major} when is_integer(major) <- fetch_field(changeset, :version_major) do
      interface_id = CQLUtils.interface_id(name, major)

      changeset
      |> put_change(:interface_id, interface_id)
    else
      _ ->
        changeset
    end
  end

  defp validate_non_null_version(changeset) do
    if get_field(changeset, :version_major) == 0 and get_field(changeset, :version_minor) == 0 do
      add_error(changeset, :version_minor, "must be > 0 if major_version is 0")
    else
      changeset
    end
  end

  defp validate_explicit_timestamp(changeset) do
    if get_field(changeset, :explicit_timestamp) do
      validate_change(changeset, :type, fn
        :type, :datastream ->
          []

        :type, _ ->
          [explicit_timestamp: "is allowed only in datastream interfaces"]
      end)
    else
      changeset
    end
  end

  defp validate_has_metadata(changeset) do
    if get_field(changeset, :has_metadata) do
      changeset
      |> validate_change(:type, fn
        :type, :datastream ->
          []

        :type, _ ->
          [has_metadata: "is allowed only in datastream interfaces"]
      end)
      |> validate_change(:aggregation, fn
        :aggregation, :individual ->
          []

        :aggregation, _ ->
          [has_metadata: "is allowed only in individual interfaces"]
      end)
    else
      changeset
    end
  end

  defp validate_mapping_uniqueness(changeset) do
    mappings = get_field(changeset, :mappings, [])
    unique_count =
      Enum.uniq_by(mappings, fn mapping ->
        Mapping.normalize_endpoint(mapping.endpoint)
        |> String.downcase()
      end)
      |> Enum.count()

    if Enum.count(mappings) != unique_count do
      add_error(changeset, :mappings, "contain conflicting endpoints")
    else
      changeset
    end
  end
end
