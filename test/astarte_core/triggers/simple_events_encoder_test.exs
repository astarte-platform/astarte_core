defmodule Astarte.Core.SimpleEventsEncoderTest do
  use ExUnit.Case

  describe "simple events JSON encoding" do
    test "works for DeviceConnectedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.DeviceConnectedEvent

      ip = "123.1.2.3"

      event = %DeviceConnectedEvent{
        device_ip_address: ip
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{"type" => "device_connected", "device_ip_address" => ip}
    end

    test "works for DeviceErrorEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.DeviceErrorEvent

      error_name = "invalid_introspection"
      metadata_map = %{"base64_payload" => Base.encode64("notanintrospection")}
      metadata = Enum.into(metadata_map, [])

      event = %DeviceErrorEvent{
        error_name: error_name,
        metadata: metadata
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "device_error",
               "error_name" => error_name,
               "metadata" => metadata_map
             }
    end

    test "works for DeviceDisconnectedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.DeviceDisconnectedEvent

      event = %DeviceDisconnectedEvent{}

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{"type" => "device_disconnected"}
    end

    test "works for IncomingDataEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.IncomingDataEvent

      interface = "com.example.Interface"
      path = "/a/path"
      value = 42
      bson_value = Cyanide.encode!(%{v: value})

      event = %IncomingDataEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "incoming_data",
               "interface" => interface,
               "path" => path,
               "value" => value
             }
    end

    test "works for IncomingDataEvent with empty bson_value (e.g. unset)" do
      alias Astarte.Core.Triggers.SimpleEvents.IncomingDataEvent

      interface = "com.example.Interface"
      path = "/another/path"
      value = nil
      bson_value = <<>>

      event = %IncomingDataEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "incoming_data",
               "interface" => interface,
               "path" => path,
               "value" => value
             }
    end

    test "works for IncomingDataEvent with nil bson_value (e.g. unset)" do
      alias Astarte.Core.Triggers.SimpleEvents.IncomingDataEvent

      interface = "com.example.Interface"
      path = "/another/path"
      value = nil
      bson_value = nil

      event = %IncomingDataEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "incoming_data",
               "interface" => interface,
               "path" => path,
               "value" => value
             }
    end

    test "works for IncomingIntrospectionEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.IncomingIntrospectionEvent

      introspection = "com.example.Interface:0:2;com.example.AnotherInterface:1:1"

      event = %IncomingIntrospectionEvent{
        introspection: introspection
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "incoming_introspection",
               "introspection" => introspection
             }
    end

    test "works for InterfaceAddedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.InterfaceAddedEvent

      interface = "com.example.Interface"
      major_version = 1
      minor_version = 2

      event = %InterfaceAddedEvent{
        interface: interface,
        major_version: major_version,
        minor_version: minor_version
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "interface_added",
               "interface" => interface,
               "major_version" => major_version,
               "minor_version" => minor_version
             }
    end

    test "works for InterfaceMinorUpdatedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.InterfaceMinorUpdatedEvent

      interface = "com.example.Interface"
      major_version = 1
      old_minor_version = 2
      new_minor_version = 3

      event = %InterfaceMinorUpdatedEvent{
        interface: interface,
        major_version: major_version,
        old_minor_version: old_minor_version,
        new_minor_version: new_minor_version
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "interface_minor_updated",
               "interface" => interface,
               "major_version" => major_version,
               "old_minor_version" => old_minor_version,
               "new_minor_version" => new_minor_version
             }
    end

    test "works for InterfaceRemovedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.InterfaceRemovedEvent

      interface = "com.example.Interface"
      major_version = 1

      event = %InterfaceRemovedEvent{
        interface: interface,
        major_version: major_version
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "interface_removed",
               "interface" => interface,
               "major_version" => major_version
             }
    end

    test "works for PathCreatedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.PathCreatedEvent

      interface = "com.example.Interface"
      path = "/some/path"
      value = "a string value"
      bson_value = Cyanide.encode!(%{v: value})

      event = %PathCreatedEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "path_created",
               "interface" => interface,
               "path" => path,
               "value" => value
             }
    end

    test "works for PathRemovedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.PathRemovedEvent

      interface = "com.example.Interface"
      path = "/some/path"

      event = %PathRemovedEvent{
        interface: interface,
        path: path
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "path_removed",
               "interface" => interface,
               "path" => path
             }
    end

    test "works for ValueChangeAppliedEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.ValueChangeAppliedEvent

      interface = "com.example.Interface"
      path = "/some/value"
      old_value = 2.1
      new_value = 4.1
      old_bson_value = Cyanide.encode!(%{v: old_value})
      new_bson_value = Cyanide.encode!(%{v: new_value})

      event = %ValueChangeAppliedEvent{
        interface: interface,
        path: path,
        old_bson_value: old_bson_value,
        new_bson_value: new_bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "value_change_applied",
               "interface" => interface,
               "path" => path,
               "old_value" => old_value,
               "new_value" => new_value
             }
    end

    test "works for ValueChangeEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.ValueChangeEvent

      interface = "com.example.Interface"
      path = "/some/value"
      old_value = 2.1
      new_value = 4.1
      old_bson_value = Cyanide.encode!(%{v: old_value})
      new_bson_value = Cyanide.encode!(%{v: new_value})

      event = %ValueChangeEvent{
        interface: interface,
        path: path,
        old_bson_value: old_bson_value,
        new_bson_value: new_bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "value_change",
               "interface" => interface,
               "path" => path,
               "old_value" => old_value,
               "new_value" => new_value
             }
    end

    test "works for ValueStoredEvent" do
      alias Astarte.Core.Triggers.SimpleEvents.ValueStoredEvent

      interface = "com.example.Interface"
      path = "/some/value"
      value = "test"
      bson_value = Cyanide.encode!(%{v: value})

      event = %ValueStoredEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "value_stored",
               "interface" => interface,
               "path" => path,
               "value" => value
             }
    end

    test "works for ValueStoredEvent with old-format aggregate bson value" do
      alias Astarte.Core.Triggers.SimpleEvents.ValueStoredEvent

      interface = "com.example.Interface"
      path = "/some/value"
      old_format_value = %{"some" => "aggregate", "old" => "format", "version" => 42}
      bson_value = Cyanide.encode!(old_format_value)

      event = %ValueStoredEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      }

      roundtrip =
        Jason.encode!(event)
        |> Jason.decode!()

      assert roundtrip == %{
               "type" => "value_stored",
               "interface" => interface,
               "path" => path,
               "value" => old_format_value
             }
    end
  end
end
