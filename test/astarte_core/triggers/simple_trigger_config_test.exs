defmodule Astarte.Core.SimpleTriggerConfigTest do
  use ExUnit.Case

  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Device
  alias Astarte.Core.Triggers.SimpleTriggerConfig
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DataTrigger
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DeviceTrigger
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.SimpleTriggerContainer
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

  test "from_map/1 with invalid trigger_type returns an error changeset" do
    invalid_type = %{@valid_data_trigger_map | "type" => "invalid"}

    assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(invalid_type)
  end

  describe "data triggers" do
    test "from_map/1 with invalid on returns an error changeset" do
      invalid_on = %{@valid_data_trigger_map | "on" => "invalid"}

      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(invalid_on)
    end

    test "from_map/1 with invalid value_match_operator returns an error changeset" do
      invalid_operator = %{@valid_data_trigger_map | "value_match_operator" => "?"}

      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(invalid_operator)
    end

    test "from_map/1 with value_match_operator != * and no match_path or known value returns an error changeset" do
      no_match_path = Map.delete(@valid_data_trigger_map, "match_path")
      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(no_match_path)

      no_known_value = Map.delete(@valid_data_trigger_map, "known_value")
      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(no_known_value)
    end

    test "from_map/1 generates a SimpleTriggerConfig from a valid data trigger map" do
      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)
      data_trigger_type = :INCOMING_DATA
      match_operator = :GREATER_THAN
      known_value = Bson.encode(%{v: @int_known_value})

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.from_map(@valid_data_trigger_map)

      assert config.object_type == 2
      assert config.object_id == CQLUtils.interface_id(@interface_name, @interface_major)

      assert %SimpleTriggerContainer{simple_trigger: {:data_trigger, data_trigger}} =
               config.simple_trigger_container

      assert %DataTrigger{
               data_trigger_type: ^data_trigger_type,
               interface_id: ^interface_id,
               value_match_operator: ^match_operator,
               match_path: @match_path,
               known_value: ^known_value
             } = data_trigger
    end

    test "from_map/1 generates a SimpleTriggerConfig from a valid data trigger map with any operator" do
      interface_id = CQLUtils.interface_id(@interface_name, @interface_major)
      data_trigger_type = :VALUE_CHANGE
      match_operator = :ANY

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.from_map(@valid_data_trigger_any_map)

      assert config.object_type == 2
      assert config.object_id == CQLUtils.interface_id(@interface_name, @interface_major)

      assert %SimpleTriggerContainer{simple_trigger: {:data_trigger, data_trigger}} =
               config.simple_trigger_container

      assert %DataTrigger{
               data_trigger_type: ^data_trigger_type,
               interface_id: ^interface_id,
               value_match_operator: ^match_operator,
             } = data_trigger
    end
  end

  describe "device triggers" do
    test "from_map/1 with invalid on returns an error changeset" do
      invalid_on = %{@valid_device_trigger_map | "on" => "invalid"}

      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(invalid_on)
    end

    test "from_map/1 with invalid device id returns an error changeset" do
      invalid_operator = %{@valid_device_trigger_map | "device_id" => "invalidid"}

      assert {:error, %Changeset{}} = SimpleTriggerConfig.from_map(invalid_operator)
    end

    test "from_map/1 generates a SimpleTriggerConfig from a valid device trigger map" do
      device_event_type = :DEVICE_CONNECTED

      assert {:ok, %SimpleTriggerConfig{} = config} =
               SimpleTriggerConfig.from_map(@valid_device_trigger_map)

      assert config.object_type == 1
      assert config.object_id == @device_id

      assert %SimpleTriggerContainer{simple_trigger: {:device_trigger, device_trigger}} =
               config.simple_trigger_container

      assert %DeviceTrigger{
               device_event_type: ^device_event_type
             } = device_trigger
    end
  end
end
