defmodule Astarte.Core.InterfaceDescriptor do
  alias Astarte.Core.InterfaceDescriptor

  defstruct name: "",
    major_version: 0,
    minor_version: 0,
    type: nil,
    ownership: nil,
    aggregation: nil,
    explicit_timestamp: false,
    has_metadata: false

  def validate(interface_descriptor) do
    cond do
      interface_descriptor == nil ->
        {:error, :null_interface_descriptor}

      interface_descriptor == "" ->
        {:error, :not_an_interface_descriptor}

      interface_descriptor == [] ->
        {:error, :not_an_interface_descriptor}

      String.length(interface_descriptor.name <> "_v" <> Integer.to_string(interface_descriptor.major_version)) >= 48 ->
        {:error, :too_long_interface_name}

      String.match?(interface_descriptor.name, ~r/^[a-zA-Z]+(\.[a-zA-Z0-9]+)*$/) == false ->
        {:error, :invalid_interface_name}

      interface_descriptor.major_version < 0 ->
        {:error, :invalid_major_version}

      interface_descriptor.major_version < 0 ->
        {:error, :invalid_minor_version}

      (interface_descriptor.major_version == 0) and (interface_descriptor.minor_version == 0) ->
        {:error, :invalid_minor_version}

      ((interface_descriptor.type == :properties) or (interface_descriptor.type == :datastream)) == false ->
        {:error, :invalid_interface_type}

      ((interface_descriptor.ownership == :thing) or (interface_descriptor.ownership == :server)) == false ->
        {:error, :invalid_interface_ownership}

      ((interface_descriptor.aggregation == :individual) or (interface_descriptor.aggregation == :object)) == false ->
        {:error, :invalid_interface_aggregation}

      (interface_descriptor.type != :datastream) and interface_descriptor.explicit_timestamp ->
        {:error, :explicit_timestamp_not_allowed}

      ((interface_descriptor.aggregation != :individual) or (interface_descriptor.type != :datastream)) and interface_descriptor.has_metadata ->
        {:error, :metadata_not_allowed}

      true ->
        :ok
    end
  end

  def is_valid?(interface_descriptor) do
    validate(interface_descriptor) == :ok
  end

  @doc """
  Deserializes an `%InterfaceDescriptor{}` from `db_result`.
  `db_result` can be a keyword list or a map.

  Returns the `%InterfaceDescriptor{}` on success,
  raises on failure
  """
  def from_db_result!(db_result) when not is_map(db_result) do
    db_result
    |> Enum.into(%{})
    |> from_db_result!()
  end

  def from_db_result!(db_result) do
    %{name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: type,
      ownership: ownership,
      aggregation: aggregation,
    } = db_result

    %InterfaceDescriptor{
      name: name,
      major_version: major_version,
      minor_version: minor_version,
      type: Astarte.Core.Interface.Type.from_int(type),
      ownership: Astarte.Core.Interface.Ownership.from_int(ownership),
      aggregation: Astarte.Core.Interface.Aggregation.from_int(aggregation),
    }
  end
end
