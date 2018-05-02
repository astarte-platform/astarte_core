#
# Copyright (C) 2018 Ispirata Srl
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

defmodule Astarte.Core.Triggers.SimpleEvents.Encoder do
  alias Astarte.Core.Triggers.SimpleEvents
  alias Astarte.Core.Triggers.SimpleEvents.Encoder

  defimpl Poison.Encoder, for: SimpleEvents.DeviceConnectedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.DeviceConnectedEvent

    def encode(%DeviceConnectedEvent{} = event, opts) do
      %DeviceConnectedEvent{
        device_ip_address: device_ip_address
      } = event

      %{
        "type" => "device_connected",
        "device_ip_address" => device_ip_address
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.DeviceDisconnectedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.DeviceDisconnectedEvent

    def encode(%DeviceDisconnectedEvent{}, opts) do
      %{
        "type" => "device_disconnected",
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.IncomingDataEvent do
    alias Astarte.Core.Triggers.SimpleEvents.IncomingDataEvent

    def encode(%IncomingDataEvent{} = event, opts) do
      %IncomingDataEvent{
        interface: interface,
        path: path,
        bson_value: bson_value
      } = event

      %{
        "type" => "incoming_data",
        "interface" => interface,
        "path" => path,
        "value" => Encoder.extract_bson_value(bson_value)
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.IncomingIntrospectionEvent do
    alias Astarte.Core.Triggers.SimpleEvents.IncomingIntrospectionEvent

    def encode(%IncomingIntrospectionEvent{} = event, opts) do
      %IncomingIntrospectionEvent{
        introspection: introspection,
      } = event

      %{
        "type" => "incoming_introspection",
        "introspection" => introspection
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.InterfaceAddedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.InterfaceAddedEvent

    def encode(%InterfaceAddedEvent{} = event, opts) do
      %InterfaceAddedEvent{
        interface: interface,
        major_version: major_version,
        minor_version: minor_version
      } = event

      %{
        "type" => "interface_added",
        "interface" => interface,
        "major_version" => major_version,
        "minor_version" => minor_version
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.InterfaceMinorUpdatedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.InterfaceMinorUpdatedEvent

    def encode(%InterfaceMinorUpdatedEvent{} = event, opts) do
      %InterfaceMinorUpdatedEvent{
        interface: interface,
        major_version: major_version,
        old_minor_version: old_minor_version,
        new_minor_version: new_minor_version
      } = event

      %{
        "type" => "interface_minor_updated",
        "interface" => interface,
        "major_version" => major_version,
        "old_minor_version" => old_minor_version,
        "new_minor_version" => new_minor_version
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.InterfaceRemovedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.InterfaceRemovedEvent

    def encode(%InterfaceRemovedEvent{} = event, opts) do
      %InterfaceRemovedEvent{
        interface: interface,
        major_version: major_version,
      } = event

      %{
        "type" => "interface_removed",
        "interface" => interface,
        "major_version" => major_version
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.PathCreatedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.PathCreatedEvent

    def encode(%PathCreatedEvent{} = event, opts) do
      %PathCreatedEvent{
        interface: interface,
        path: path,
        bson_value: bson_value,
      } = event

      %{
        "type" => "path_created",
        "interface" => interface,
        "path" => path,
        "value" => Encoder.extract_bson_value(bson_value)
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.PathRemovedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.PathRemovedEvent

    def encode(%PathRemovedEvent{} = event, opts) do
      %PathRemovedEvent{
        interface: interface,
        path: path
      } = event

      %{
        "type" => "path_removed",
        "interface" => interface,
        "path" => path
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.ValueChangeAppliedEvent do
    alias Astarte.Core.Triggers.SimpleEvents.ValueChangeAppliedEvent

    def encode(%ValueChangeAppliedEvent{} = event, opts) do
      %ValueChangeAppliedEvent{
        interface: interface,
        path: path,
        old_bson_value: old_bson_value,
        new_bson_value: new_bson_value,
      } = event

      %{
        "type" => "value_change_applied",
        "interface" => interface,
        "path" => path,
        "old_value" => Encoder.extract_bson_value(old_bson_value),
        "new_value" => Encoder.extract_bson_value(new_bson_value)
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.ValueChangeEvent do
    alias Astarte.Core.Triggers.SimpleEvents.ValueChangeEvent

    def encode(%ValueChangeEvent{} = event, opts) do
      %ValueChangeEvent{
        interface: interface,
        path: path,
        old_bson_value: old_bson_value,
        new_bson_value: new_bson_value,
      } = event

      %{
        "type" => "value_change",
        "interface" => interface,
        "path" => path,
        "old_value" => Encoder.extract_bson_value(old_bson_value),
        "new_value" => Encoder.extract_bson_value(new_bson_value)
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  defimpl Poison.Encoder, for: SimpleEvents.ValueStoredEvent do
    alias Astarte.Core.Triggers.SimpleEvents.ValueStoredEvent

    def encode(%ValueStoredEvent{} = event, opts) do
      %ValueStoredEvent{
        interface: interface,
        path: path,
        bson_value: bson_value,
      } = event

      %{
        "type" => "value_stored",
        "interface" => interface,
        "path" => path,
        "value" => Encoder.extract_bson_value(bson_value)
      }
      |> Poison.Encoder.encode(opts)
    end
  end

  def extract_bson_value(bson_value) do
    case Bson.decode(bson_value) do
      %{v: value} ->
        value

      other ->
        other
    end
  end
end
