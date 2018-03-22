defmodule Astarte.Core.InterfaceDocumentTest do
  use ExUnit.Case

  @aggregated_datastream_interface_json """
  {
   "interface_name": "com.ispirata.Hemera.DeviceLog",
   "version_major": 1,
   "version_minor": 2,
   "type": "datastream",
   "quality": "producer",
   "aggregate": true,
   "mappings": [
       {
           "path": "/message",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/timestamp",
           "type": "datetime",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/monotonicTimestamp",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/applicationId",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/pid",
           "type": "integer",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/cmdLine",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/category",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/severity",
           "type": "integer",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/bootId",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       }
   ]
  }
  """

  @individual_property_server_owned_interface """
  {
     "interface_name": "com.ispirata.Hemera.DeviceLog.Configuration",
     "version_major": 1,
     "version_minor": 0,
     "type": "properties",
     "quality": "consumer",
     "mappings": [
         {
             "path": "/filterRules/%{ruleId}/%{filterKey}/value",
             "type": "string",
             "allow_unset": true
         }
     ]
  }
  """

  @individual_property_device_owned_interface """
  {
       "interface_name": "com.ispirata.Hemera.DeviceLog.Status",
       "version_major": 2,
       "version_minor": 1,
       "type": "properties",
       "quality": "producer",
       "mappings": [
           {
               "path": "/filterRules/%{ruleId}/%{filterKey}/value",
               "type": "string",
               "allow_unset": true
           }
       ]
  }
  """

  @invalid_mapping_document """
  {
       "interface_name": "com.ispirata.Hemera.DeviceLog.Status",
       "version_major": 2,
       "version_minor": 1,
       "type": "properties",
       "quality": "producer",
       "mappings": [
           {
               "path": "/filterRules/%{ruleId}/; DROP TABLE endpoints; //",
               "type": "string",
               "allow_unset": true
           }
       ]
  }
  """

  test "aggregated datastream interface deserialization" do
    {:ok, interface_document} =
      Astarte.Core.InterfaceDocument.from_json(@aggregated_datastream_interface_json)

    descriptor = interface_document.descriptor
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog"
    assert descriptor.major_version == 1
    assert descriptor.minor_version == 2
    assert descriptor.type == :datastream
    assert descriptor.ownership == :device
    assert descriptor.aggregation == :object

    last_mapping = List.last(interface_document.mappings)
    assert last_mapping.endpoint == "/bootId"
    assert last_mapping.value_type == :string
    assert last_mapping.reliability == :guaranteed
    assert last_mapping.retention == :stored

    pid_mapping = Enum.at(interface_document.mappings, 4)
    assert pid_mapping.endpoint == "/pid"
    assert pid_mapping.value_type == :integer
    assert pid_mapping.reliability == :guaranteed
    assert pid_mapping.retention == :stored

    assert Kernel.length(interface_document.mappings) == 9

    assert interface_document.source == @aggregated_datastream_interface_json
  end

  test "individual property server owned interface deserialization" do
    {:ok, interface_document} =
      Astarte.Core.InterfaceDocument.from_json(@individual_property_server_owned_interface)

    descriptor = interface_document.descriptor
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog.Configuration"
    assert descriptor.major_version == 1
    assert descriptor.minor_version == 0
    assert descriptor.type == :properties
    assert descriptor.ownership == :server
    assert descriptor.aggregation == :individual

    last_mapping = List.last(interface_document.mappings)
    assert last_mapping.endpoint == "/filterRules/%{ruleId}/%{filterKey}/value"
    assert last_mapping.value_type == :string
    assert last_mapping.allow_unset == true

    # TODO: choose a reasonable default for property interface mappings reliability and retention and test it

    assert Kernel.length(interface_document.mappings) == 1

    assert interface_document.source == @individual_property_server_owned_interface
  end

  test "individual property device owned interface deserialization" do
    {:ok, interface_document} =
      Astarte.Core.InterfaceDocument.from_json(@individual_property_device_owned_interface)

    descriptor = interface_document.descriptor
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog.Status"
    assert descriptor.major_version == 2
    assert descriptor.minor_version == 1
    assert descriptor.type == :properties
    assert descriptor.ownership == :device
    assert descriptor.aggregation == :individual

    last_mapping = List.last(interface_document.mappings)
    assert last_mapping.endpoint == "/filterRules/%{ruleId}/%{filterKey}/value"
    assert last_mapping.value_type == :string
    assert last_mapping.allow_unset == true

    # TODO: choose a reasonable default for property interface mappings reliability and retention and test it

    assert Kernel.length(interface_document.mappings) == 1

    assert interface_document.source == @individual_property_device_owned_interface
  end

  test "invalid mapping document" do
    assert Astarte.Core.InterfaceDocument.from_json(@invalid_mapping_document) == :error
  end

  test "invalid mappings" do
    mapping = %Astarte.Core.Mapping{
      endpoint: "/this/is/almost/%{ok}",
      value_type: nil
    }

    assert Astarte.Core.Mapping.is_valid?(mapping) == false

    mapping = %Astarte.Core.Mapping{
      endpoint: "//this/is/almost/%{ok}",
      value_type: :integer
    }

    assert Astarte.Core.Mapping.is_valid?(mapping) == false

    mapping = %Astarte.Core.Mapping{
      endpoint: "/this/is/%{ok}",
      value_type: :integer
    }

    assert Astarte.Core.Mapping.is_valid?(mapping) == true
  end

  test "invalid document descriptor" do
    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "notok; DROP KEYSPACE astarte;//",
      major_version: 1,
      minor_version: 0,
      type: :properties,
      ownership: :device,
      aggregation: :individual
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) ==
             {:error, :invalid_interface_name}

    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == false

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "notok",
      major_version: 1,
      minor_version: 0,
      type: :a_typo_here,
      ownership: :device,
      aggregation: :individual
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) ==
             {:error, :invalid_interface_type}

    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == false

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "nowok",
      major_version: 1,
      minor_version: 0,
      type: :datastream,
      ownership: :device,
      aggregation: :object,
      has_metadata: true
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) ==
             {:error, :metadata_not_allowed}

    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == false

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "nowok",
      major_version: 1,
      minor_version: 0,
      type: :properties,
      ownership: :device,
      aggregation: :object,
      explicit_timestamp: true
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) ==
             {:error, :explicit_timestamp_not_allowed}

    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == false

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "longlonglonglonglonglonglonglonglonglong.v1",
      major_version: 1,
      minor_version: 0,
      type: :properties,
      ownership: :device,
      aggregation: :individual
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) == :ok
    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == true

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "nowok",
      major_version: 1,
      minor_version: 0,
      type: :properties,
      ownership: :device,
      aggregation: :individual
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) == :ok
    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == true

    descriptor = %Astarte.Core.InterfaceDescriptor{
      name: "nowok",
      major_version: 1,
      minor_version: 0,
      type: :datastream,
      ownership: :device,
      aggregation: :individual,
      has_metadata: true,
      explicit_timestamp: true
    }

    assert Astarte.Core.InterfaceDescriptor.validate(descriptor) == :ok
    assert Astarte.Core.InterfaceDescriptor.is_valid?(descriptor) == true
  end

  test "document members" do
    {:ok,
     %Astarte.Core.InterfaceDocument{
       descriptor: %Astarte.Core.InterfaceDescriptor{
         name: "com.ispirata.Hemera.DeviceLog",
         major_version: 1,
         minor_version: 2,
         type: :datastream,
         ownership: :device,
         aggregation: :object
       },
       mappings: [_ | _],
       source: @aggregated_datastream_interface_json
     }} = Astarte.Core.InterfaceDocument.from_json(@aggregated_datastream_interface_json)
  end
end
