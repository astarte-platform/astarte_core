#
# Copyright (C) 2017 Ispirata Srl
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

defmodule Astarte.Core.Triggers.SimpleTriggersProtobuf.Utils do
  alias Astarte.Core.Triggers.DataTrigger

  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DataTrigger,
    as: SimpleTriggersProtobufDataTrigger

  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.TriggerTargetContainer
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.SimpleTriggerContainer

  @any_device_object_id <<140, 77, 4, 17, 75, 202, 11, 92, 131, 72, 15, 167, 65, 149, 191, 244>>
  @any_interface_object_id <<247, 238, 60, 243, 184, 175, 236, 43, 25, 242, 126, 91, 253, 141, 17,
                             119>>

  def any_interface_object_id do
    @any_interface_object_id
  end

  def any_device_object_id do
    @any_device_object_id
  end

  def deserialize_trigger_target(payload) do
    %TriggerTargetContainer{
      version: 1,
      trigger_target: {_target_type, target}
    } = TriggerTargetContainer.decode(payload)

    target
  end

  def deserialize_simple_trigger(payload) do
    %SimpleTriggerContainer{
      version: 1,
      simple_trigger: {simple_trigger_type, simple_trigger}
    } = SimpleTriggerContainer.decode(payload)

    {simple_trigger_type, simple_trigger}
  end

  def simple_trigger_to_data_trigger(protobuf_data_trigger) do
    %SimpleTriggersProtobufDataTrigger{
      interface_id: interface_id,
      match_path: match_path,
      value_match_operator: value_match_operator,
      known_value: encoded_known_value
    } = protobuf_data_trigger

    %{v: plain_value} =
      if encoded_known_value do
        Bson.decode(encoded_known_value)
      else
        %{v: nil}
      end

    path_match_tokens =
      if match_path do
        match_path
        |> String.replace(~r/%{[a-zA-Z0-9]*}/, "")
        |> String.split("/")
      else
        :any_endpoint
      end

    # TODO: it doesn't seem a good idea to accept both @any_interface_object_id and nil
    # FIXME: chose just one of them
    interface_id_or_any =
      if interface_id == @any_interface_object_id || interface_id == nil do
        :any_interface
      else
        interface_id
      end

    %DataTrigger{
      interface_id: interface_id_or_any,
      path_match_tokens: path_match_tokens,
      value_match_operator: value_match_operator,
      known_value: plain_value,
      trigger_targets: nil
    }
  end
end
