defmodule Astarte.Core.InterfaceDescriptorTest do
  use ExUnit.Case

  alias Astarte.Core.InterfaceDescriptor
  alias Astarte.Core.Interface.Type
  alias Astarte.Core.Interface.Ownership
  alias Astarte.Core.Interface.Aggregation

  @interface_fixture_name "com.ispirata.Hemera.Test"
  @interface_fixture_maj 1
  @interface_fixture_min 2
  @interface_fixture_type :properties
  @interface_fixture_type_as_int Type.to_int(@interface_fixture_type)
  @interface_fixture_ownership :server
  @interface_fixture_ownership_as_int Ownership.to_int(@interface_fixture_ownership)
  @interface_fixture_aggregation :individual
  @interface_fixture_aggregation_as_int Aggregation.to_int(@interface_fixture_aggregation)

  @interface_descriptor_fixture %InterfaceDescriptor{
    name: @interface_fixture_name,
    major_version: @interface_fixture_maj,
    minor_version: @interface_fixture_min,
    type: @interface_fixture_type,
    ownership: @interface_fixture_ownership,
    aggregation: @interface_fixture_aggregation
  }

  test "keyword list result deserialization" do
    descriptor_as_keyword_list = [
      name: @interface_fixture_name,
      major_version: @interface_fixture_maj,
      minor_version: @interface_fixture_min,
      type: @interface_fixture_type_as_int,
      ownership: @interface_fixture_ownership_as_int,
      aggregation: @interface_fixture_aggregation_as_int
    ]

    assert InterfaceDescriptor.from_db_result!(descriptor_as_keyword_list) == @interface_descriptor_fixture
  end

  test "keyword list deserialization fails if keys are missing" do
    descriptor_as_keyword_list_no_aggr = [
      name: @interface_fixture_name,
      major_version: @interface_fixture_maj,
      minor_version: @interface_fixture_min,
      type: @interface_fixture_type_as_int,
      ownership: @interface_fixture_ownership_as_int
      # Missing aggregation
    ]

    assert_raise MatchError, fn ->
      InterfaceDescriptor.from_db_result!(descriptor_as_keyword_list_no_aggr)
    end
  end

  test "map result deserialization" do
    descriptor_as_map = %{
      name: @interface_fixture_name,
      major_version: @interface_fixture_maj,
      minor_version: @interface_fixture_min,
      type: @interface_fixture_type_as_int,
      ownership: @interface_fixture_ownership_as_int,
      aggregation: @interface_fixture_aggregation_as_int
    }

    assert InterfaceDescriptor.from_db_result!(descriptor_as_map) == @interface_descriptor_fixture
  end

  test "map deserialization fails if keys are missing" do
    descriptor_as_map_no_name = %{
      #Missing name
      major_version: @interface_fixture_maj,
      minor_version: @interface_fixture_min,
      type: @interface_fixture_type_as_int,
      ownership: @interface_fixture_ownership_as_int,
      aggregation: @interface_fixture_aggregation_as_int
    }

    assert_raise MatchError, fn ->
      InterfaceDescriptor.from_db_result!(descriptor_as_map_no_name)
    end
  end
end
