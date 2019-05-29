defmodule Astarte.Core.InterfaceTest do
  use ExUnit.Case

  alias Astarte.Core.Interface
  alias Astarte.Core.InterfaceDescriptor
  alias Astarte.Core.Mapping

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
    {:ok, params} = Jason.decode(@aggregated_datastream_interface_json)

    {:ok, interface} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    descriptor = InterfaceDescriptor.from_interface(interface)
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog"
    assert descriptor.major_version == 1
    assert descriptor.minor_version == 2
    assert descriptor.type == :datastream
    assert descriptor.ownership == :device
    assert descriptor.aggregation == :object

    last_mapping = List.last(interface.mappings)
    assert last_mapping.endpoint == "/bootId"
    assert last_mapping.value_type == :string
    assert last_mapping.reliability == :guaranteed
    assert last_mapping.retention == :stored

    pid_mapping = Enum.at(interface.mappings, 4)
    assert pid_mapping.endpoint == "/pid"
    assert pid_mapping.value_type == :integer
    assert pid_mapping.reliability == :guaranteed
    assert pid_mapping.retention == :stored

    assert Kernel.length(interface.mappings) == 9
  end

  test "individual property server owned interface deserialization" do
    {:ok, params} = Jason.decode(@individual_property_server_owned_interface)

    {:ok, interface} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    descriptor = InterfaceDescriptor.from_interface(interface)
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog.Configuration"
    assert descriptor.major_version == 1
    assert descriptor.minor_version == 0
    assert descriptor.type == :properties
    assert descriptor.ownership == :server
    assert descriptor.aggregation == :individual

    last_mapping = List.last(interface.mappings)
    assert last_mapping.endpoint == "/filterRules/%{ruleId}/%{filterKey}/value"
    assert last_mapping.value_type == :string
    assert last_mapping.allow_unset == true

    # TODO: choose a reasonable default for property interface mappings reliability and retention and test it

    assert Kernel.length(interface.mappings) == 1
  end

  test "individual property device owned interface deserialization" do
    {:ok, params} = Jason.decode(@individual_property_device_owned_interface)

    {:ok, interface} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    descriptor = InterfaceDescriptor.from_interface(interface)
    assert descriptor.name == "com.ispirata.Hemera.DeviceLog.Status"
    assert descriptor.major_version == 2
    assert descriptor.minor_version == 1
    assert descriptor.type == :properties
    assert descriptor.ownership == :device
    assert descriptor.aggregation == :individual

    last_mapping = List.last(interface.mappings)
    assert last_mapping.endpoint == "/filterRules/%{ruleId}/%{filterKey}/value"
    assert last_mapping.value_type == :string
    assert last_mapping.allow_unset == true

    # TODO: choose a reasonable default for property interface mappings reliability and retention and test it

    assert Kernel.length(interface.mappings) == 1
  end

  test "invalid mapping document" do
    {:ok, params} = Jason.decode(@invalid_mapping_document)

    assert %Ecto.Changeset{valid?: false, changes: %{mappings: [mapping_changeset]}} =
             Interface.changeset(%Interface{}, params)

    assert %Ecto.Changeset{valid?: false, errors: [endpoint: _]} = mapping_changeset
  end

  test "invalid interface name" do
    params = %{
      "interface_name" => "notok; DROP KEYSPACE astarte;//",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [interface_name: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "invalid interface type" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "a_typo_here",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [type: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "long interface_name fails" do
    params = %{
      # aaaaa...
      "interface_name" => Stream.cycle(["a"]) |> Enum.take(129),
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [interface_name: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "major 0 and minor 0 fails" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 0,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [version_minor: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "interface with conflicting mappings fail" do
    mappings = [
      %{
        "endpoint" => "/%{pretty}/endpoint",
        "type" => "integer"
      },
      %{
        "endpoint" => "/%{UGLY}/endpOiNt",
        "type" => "integer"
      }
    ]

    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings
    }

    assert %Ecto.Changeset{valid?: false, errors: [mappings: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "valid properties interface" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Interface.changeset(%Interface{}, params)
    assert {:ok, interface} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Interface{
             name: "valid",
             major_version: 1,
             minor_version: 0,
             type: :properties,
             ownership: :device,
             aggregation: :individual,
             mappings: [%Mapping{}]
           } = interface
  end

  test "object aggregated properties interface is not valid" do
    params = %{
      "interface_name" => "bad",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "properties",
      "ownership" => "device",
      "aggregation" => "object",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [aggregation: _]} =
             Interface.changeset(%Interface{}, params)
  end

  # TODO: add support to server owned object aggregated in future releases
  test "object aggregated server owned interface is not yet valid" do
    params = %{
      "interface_name" => "bad",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "datastream",
      "ownership" => "server",
      "aggregation" => "object",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: false, errors: [ownership: _]} =
             Interface.changeset(%Interface{}, params)
  end

  test "valid datastream interface" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "datastream",
      "ownership" => "device",
      "aggregation" => "individual",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Interface.changeset(%Interface{}, params)
    assert {:ok, interface} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Interface{
             name: "valid",
             major_version: 1,
             minor_version: 0,
             type: :datastream,
             ownership: :device,
             aggregation: :individual,
             mappings: [%Mapping{}]
           } = interface
  end

  test "legacy interface" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "datastream",
      "quality" => "producer",
      "aggregate" => "true",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Interface.changeset(%Interface{}, params)
    assert {:ok, interface} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Interface{
             name: "valid",
             major_version: 1,
             minor_version: 0,
             type: :datastream,
             ownership: :device,
             aggregation: :object,
             mappings: [%Mapping{}]
           } = interface
  end

  test "interface JSON serialization/deserialization" do
    params = %{
      "interface_name" => "valid",
      "version_major" => 1,
      "version_minor" => 0,
      "type" => "datastream",
      "ownership" => "device",
      "mappings" => mappings_fixture()
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Interface.changeset(%Interface{}, params)
    assert {:ok, %Interface{} = interface} = Ecto.Changeset.apply_action(changeset, :insert)

    roundtrip =
      Jason.encode!(interface)
      |> Jason.decode!()

    assert roundtrip == params
  end

  defp mappings_fixture do
    [
      %{
        "endpoint" => "/something",
        "type" => "string"
      }
    ]
  end
end
