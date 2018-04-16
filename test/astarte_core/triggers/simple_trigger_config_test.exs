defmodule Astarte.Core.SimpleTriggerConfigTest do
  use ExUnit.Case

  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Device
  alias Astarte.Core.Triggers.SimpleTriggerConfig
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DataTrigger
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DeviceTrigger
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.SimpleTriggerContainer
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.TaggedSimpleTrigger
  alias Ecto.Changeset

  @interface_name "com.Test.Interface"
  @interface_major 1
  @match_path "/some/path"
  @int_known_value 42
  @valid_data_trigger_map %{
    "type" => "data_trigger",
    "interface_name" => @interface_name,
    "interface_major" => @interface_major,
    "on" => "incoming_data",
    "value_match_operator" => ">",
    "match_path" => @match_path,
    "known_value" => @int_known_value
  }
  @valid_data_trigger_any_map %{
    "type" => "data_trigger",
    "interface_name" => @interface_name,
    "interface_major" => @interface_major,
    "on" => "value_change",
    "value_match_operator" => "*"
  }

  @device_id :crypto.strong_rand_bytes(16)
  @valid_device_trigger_map %{
    "type" => "device_trigger",
    "on" => "device_connected",
    "device_id" => Device.encode_device_id(@device_id)
  }

  test "changeset with invalid trigger_type returns an error changeset" do
    invalid_type = %{@valid_data_trigger_map | "type" => "invalid"}

    assert {:error, %Changeset{}} =
             SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, invalid_type)
             |> Ecto.Changeset.apply_action(:insert)
  end

  describe "data triggers" do
    test "changeset with invalid on returns an error changeset" do
      invalid_on = %{@valid_data_trigger_map | "on" => "invalid"}

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, invalid_on)
               |> Ecto.Changeset.apply_action(:insert)
    end

    test "changeset with invalid value_match_operator returns an error changeset" do
      invalid_operator = %{@valid_data_trigger_map | "value_match_operator" => "?"}

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, invalid_operator)
               |> Ecto.Changeset.apply_action(:insert)
    end

    test "changeset with value_match_operator != * and no match_path or known value returns an error changeset" do
      no_match_path = Map.delete(@valid_data_trigger_map, "match_path")

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, no_match_path)
               |> Ecto.Changeset.apply_action(:insert)

      no_known_value = Map.delete(@valid_data_trigger_map, "known_value")

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, no_known_value)
               |> Ecto.Changeset.apply_action(:insert)
    end

    test "changeset generates a SimpleTriggerConfig from a valid data trigger map to_tagged_simple_trigger converts it to a TaggedSimpleTrigger" do
      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)
      data_trigger_type = :INCOMING_DATA
      match_operator = :GREATER_THAN
      known_value = Bson.encode(%{v: @int_known_value})

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, @valid_data_trigger_map)
               |> Ecto.Changeset.apply_action(:insert)

      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)

      assert %TaggedSimpleTrigger{
               object_id: ^interface_id,
               object_type: 2,
               simple_trigger_container: simple_trigger_container
             } = SimpleTriggerConfig.to_tagged_simple_trigger(config)

      assert %SimpleTriggerContainer{simple_trigger: {:data_trigger, data_trigger}} =
               simple_trigger_container

      assert %DataTrigger{
               data_trigger_type: ^data_trigger_type,
               interface_id: ^interface_id,
               value_match_operator: ^match_operator,
               match_path: @match_path,
               known_value: ^known_value
             } = data_trigger
    end

    test "changeset generates a SimpleTriggerConfig from a valid data trigger map with any operator" do
      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)
      data_trigger_type = :VALUE_CHANGE
      match_operator = :ANY

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, @valid_data_trigger_any_map)
               |> Ecto.Changeset.apply_action(:insert)

      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)

      assert %TaggedSimpleTrigger{
               object_id: ^interface_id,
               object_type: 2,
               simple_trigger_container: simple_trigger_container
             } = SimpleTriggerConfig.to_tagged_simple_trigger(config)

      assert %SimpleTriggerContainer{simple_trigger: {:data_trigger, data_trigger}} =
               simple_trigger_container

      assert %DataTrigger{
               data_trigger_type: ^data_trigger_type,
               interface_id: ^interface_id,
               value_match_operator: ^match_operator,
               match_path: nil,
               known_value: nil
             } = data_trigger
    end
  end

  describe "device triggers" do
    test "changeset with invalid on returns an error changeset" do
      invalid_on = %{@valid_device_trigger_map | "on" => "invalid"}

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, invalid_on)
               |> Ecto.Changeset.apply_action(:insert)
    end

    test "changeset with invalid device id returns an error changeset" do
      invalid_operator = %{@valid_device_trigger_map | "device_id" => "invalidid"}

      assert {:error, %Changeset{}} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, invalid_operator)
               |> Ecto.Changeset.apply_action(:insert)
    end

    test "changeset generates a SimpleTriggerConfig from a valid device trigger map" do
      device_event_type = :DEVICE_CONNECTED

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.changeset(%SimpleTriggerConfig{}, @valid_device_trigger_map)
               |> Ecto.Changeset.apply_action(:insert)

      assert %TaggedSimpleTrigger{
               object_id: @device_id,
               object_type: 1,
               simple_trigger_container: simple_trigger_container
             } = SimpleTriggerConfig.to_tagged_simple_trigger(config)

      assert %SimpleTriggerContainer{simple_trigger: {:device_trigger, device_trigger}} =
               simple_trigger_container

      assert %DeviceTrigger{
               device_event_type: ^device_event_type
             } = device_trigger
    end
  end
end
