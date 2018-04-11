defmodule Astarte.Core.Triggers.SimpleTriggerConfig do
  @moduledoc """
  This module handles the functions for creating a SimpleTriggerConfig (and its relative struct).

  The struct contains the `simple_trigger_container` wrapping the simple trigger and the `object_id` and `object_type`
  on which the trigger is or will be installed
  """
  # TODO: clarify/refactor the naming around SimpleTrigger{,Config,Container}

  defstruct [
    :object_type,
    :object_id,
    :simple_trigger_container
  ]

  use Astarte.Core.Triggers.SimpleTriggersProtobuf

  import Ecto.Changeset
  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Device
  alias Astarte.Core.Triggers.SimpleTriggerConfig

  @data_trigger_types %{
    interface_name: :string,
    interface_major: :integer,
    on: :string,
    value_match_operator: :string,
    match_path: :string,
    known_value: :any
  }
  @data_trigger_required_keys [
    :interface_name,
    :interface_major,
    :on,
    :value_match_operator
  ]
  @data_trigger_condition_to_atom %{
    "incoming_data" => :INCOMING_DATA,
    "value_change" => :VALUE_CHANGE,
    "value_change_applied" => :VALUE_CHANGE_APPLIED,
    "path_created" => :PATH_CREATED,
    "path_removed" => :PATH_REMOVED,
    "value_stored" => :VALUE_STORED
  }
  @data_trigger_operator_to_atom %{
    "*" => :ANY,
    "==" => :EQUAL_TO,
    "!=" => :NOT_EQUAL_TO,
    ">" => :GREATER_THAN,
    ">=" => :GREATER_OR_EQUAL_TO,
    "<" => :LESS_THAN,
    "<=" => :LESS_OR_EQUAL_TO,
    "contains" => :CONTAINS,
    "not_contains" => :NOT_CONTAINS
  }
  @data_trigger_any_match_operator "*"

  @device_trigger_types %{
    on: :string,
    device_id: :string
  }
  @device_trigger_condition_to_atom %{
    "device_connected" => :DEVICE_CONNECTED,
    "device_disconnected" => :DEVICE_DISCONNECTED,
    "device_empty_cache_received" => :DEVICE_EMPTY_CACHE_RECEIVED,
    "device_error" => :DEVICE_ERROR
  }

  @allowed_trigger_types [
    "data_trigger",
    "device_trigger"
  ]

  @doc """
  Creates a `SimpleTriggerConfig` from a params map.

  The map for a data trigger must include:
  - `"type"`: `"data_trigger"`
  - `"interface_name"`: the interface name (string)
  - `"interface_major"`: the interface major (integer)
  - `"on"`: one of `"incoming_data"`, `"value_change"`, `"value_change_applied"`, `"path_created"`, `"path_removed"`, `"value_stored"` (string)
  - `"value_match_operator"`: one of `"*"`, `"=="`, `"!="`, `">"`, `">="`, `"<"`, `"<="`, `"contains"`, `"not contains"`  (string)
  If `"value_match_operator"` is not `"*"`, then the map must also include:
  - `"match_path"`: the interface path to take the trigger value from (string)
  - `"known_value"`: the known value which the trigger value will be matched against with `"value_match_operator"` (any)

  The map for a device trigger must include:
  - `"type"`: `"device_trigger"`
  - `"device_id"`: the 128 bits base64 url encoded device id
  - `"on"`: one of `"device_connected"`, `"device_disconnected"`, `"device_empty_cache_received"`, `"device_error"`

  Returns `{:ok, %SimpleTriggerConfig{}}` or `{:error, %Ecto.Changeset{}}`
  """
  def from_map(%{"type" => "data_trigger"} = params) do
    changeset =
      {%{}, @data_trigger_types}
      |> cast(params, Map.keys(@data_trigger_types))
      |> validate_required(@data_trigger_required_keys)
      |> validate_inclusion(:on, Map.keys(@data_trigger_condition_to_atom))
      |> validate_inclusion(:value_match_operator, Map.keys(@data_trigger_operator_to_atom))
      |> validate_match_parameters()

    # TODO: add further validation (e.g. interface name and mapping regex validation)

    with {:ok, validated_params} <- apply_action(changeset, :insert) do
      data_trigger_config =
        validated_params
        |> put_data_trigger_atoms()
        |> create_data_trigger_config()

      {:ok, data_trigger_config}
    end
  end

  def from_map(%{"type" => "device_trigger"} = params) do
    changeset =
      {%{}, @device_trigger_types}
      |> cast(params, Map.keys(@device_trigger_types))
      |> validate_required(Map.keys(@device_trigger_types))
      |> validate_inclusion(:on, Map.keys(@device_trigger_condition_to_atom))
      |> validate_and_decode_device_id(:device_id)

    with {:ok, validated_params} <- apply_action(changeset, :insert) do
      device_trigger_config =
        validated_params
        |> put_device_trigger_atoms()
        |> create_device_trigger_config()

      {:ok, device_trigger_config}
    end
  end

  def from_map(params) when is_map(params) do
    # If we're here, "type" is either missing or invalid
    # This will return an error changeset with the appropriate message
    {%{}, %{type: :string}}
    |> cast(params, [:type])
    |> validate_required([:type])
    |> validate_inclusion(:type, @allowed_trigger_types)
    |> apply_action(:insert)
  end

  defp validate_match_parameters(%Ecto.Changeset{} = changeset) do
    if get_field(changeset, :value_match_operator) == @data_trigger_any_match_operator do
      changeset
      |> delete_change(:match_path)
      |> delete_change(:known_value)
    else
      changeset
      |> validate_required([:match_path, :known_value])
    end
  end

  defp validate_and_decode_device_id(%Ecto.Changeset{} = changeset, field) do
    with {:ok, encoded_id} <- fetch_change(changeset, field),
         {:ok, decoded_id} <- Device.decode_device_id(encoded_id) do
      put_change(changeset, field, decoded_id)
    else
      :error ->
        # fetch_change failes, so the changeset is already invalid
        changeset

      {:error, :invalid_device_id} ->
        # decode_device_id failed
        add_error(changeset, field, "is not a valid device id")

      {:error, :extended_id_not_allowed} ->
        # extended id
        add_error(changeset, field, "is too long, device id must be 128 bits")
    end
  end

  defp put_data_trigger_atoms(%{on: condition, value_match_operator: operator} = params) do
    condition_atom = Map.get(@data_trigger_condition_to_atom, condition)
    operator_atom = Map.get(@data_trigger_operator_to_atom, operator)
    %{params | on: condition_atom, value_match_operator: operator_atom}
  end

  defp put_device_trigger_atoms(%{on: condition} = params) do
    condition_atom = Map.get(@device_trigger_condition_to_atom, condition)
    %{params | on: condition_atom}
  end

  defp create_data_trigger_config(params) do
    interface_id = CQLUtils.interface_id(params[:interface_name], params[:interface_major])

    data_trigger = %DataTrigger{
      interface_id: interface_id,
      known_value: params[:known_value] && Bson.encode(%{v: params[:known_value]}),
      match_path: params[:match_path],
      data_trigger_type: params[:on],
      value_match_operator: params[:value_match_operator]
    }

    %SimpleTriggerConfig{
      # TODO: object_type 2 is interface, it should be a constant
      object_type: 2,
      object_id: interface_id,
      simple_trigger_container: %SimpleTriggerContainer{
        simple_trigger: {:data_trigger, data_trigger}
      }
    }
  end

  defp create_device_trigger_config(params) do
    device_trigger = %DeviceTrigger{
      device_event_type: params[:on]
    }

    %SimpleTriggerConfig{
      # TODO: object_type 1 is device, it should be a constant
      object_type: 1,
      object_id: params[:device_id],
      simple_trigger_container: %SimpleTriggerContainer{
        simple_trigger: {:device_trigger, device_trigger}
      }
    }
  end
end
