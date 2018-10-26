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
  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Mapping
  alias Astarte.Core.Triggers.DataTrigger

  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.DataTrigger,
    as: SimpleTriggersProtobufDataTrigger

  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.TriggerTargetContainer
  alias Astarte.Core.Triggers.SimpleTriggersProtobuf.SimpleTriggerContainer

  @any_device_object_id <<140, 77, 4, 17, 75, 202, 11, 92, 131, 72, 15, 167, 65, 149, 191, 244>>
  @any_interface_object_id <<247, 238, 60, 243, 184, 175, 236, 43, 25, 242, 126, 91, 253, 141, 17,
                             119>>
  @device_object_type_int 1
  @interface_object_type_int 2
  @any_interface_object_type_int 3
  @any_device_object_type_int 4

  def any_interface_object_id do
    @any_interface_object_id
  end

  def any_device_object_id do
    @any_device_object_id
  end

  def object_type_to_int!(:device), do: @device_object_type_int
  def object_type_to_int!(:interface), do: @interface_object_type_int
  def object_type_to_int!(:any_device), do: @any_device_object_type_int
  def object_type_to_int!(:any_interface), do: @any_interface_object_type_int

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

  def get_interface_id_or_any(interface_name, interface_major) do
    if interface_name == "*" do
      :any_interface
    else
      CQLUtils.interface_id(interface_name, interface_major)
    end
  end

  def simple_trigger_to_data_trigger(protobuf_data_trigger) do
    %SimpleTriggersProtobufDataTrigger{
      interface_name: interface_name,
      interface_major: interface_major,
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
      if match_path == "/*" do
        :any_endpoint
      else
        match_path
        |> Mapping.normalize_endpoint()
        |> String.split("/")
        |> tl()
      end

    interface_id_or_any = get_interface_id_or_any(interface_name, interface_major)

    %DataTrigger{
      interface_id: interface_id_or_any,
      path_match_tokens: path_match_tokens,
      value_match_operator: value_match_operator,
      known_value: plain_value,
      trigger_targets: nil
    }
  end
end
