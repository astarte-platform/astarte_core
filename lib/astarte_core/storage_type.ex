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

defmodule Astarte.Core.StorageType do
  @multi_interface_individual_properties_dbtable 1
  @multi_interface_individual_datastream_dbtable 2
  @one_individual_properties_dbtable 3
  @one_individual_datastream_dbtable 4
  @one_object_datastream_dbtable 5

  @doc """
  returns storage_type associated int value.
  """
  def to_int(storage_type) do
    case storage_type do
      :multi_interface_individual_properties_dbtable ->
        @multi_interface_individual_properties_dbtable

      :multi_interface_individual_datastream_dbtable ->
        @multi_interface_individual_datastream_dbtable

      :one_individual_properties_dbtable ->
        @one_individual_properties_dbtable

      :one_individual_datastream_dbtable ->
        @one_individual_datastream_dbtable

      :one_object_datastream_dbtable ->
        @one_object_datastream_dbtable
    end
  end

  @doc """
  returns storage_type atom from a valid storage type int value.
  """
  def from_int(storage_type_int) do
    case storage_type_int do
      @multi_interface_individual_properties_dbtable ->
        :multi_interface_individual_properties_dbtable

      @multi_interface_individual_datastream_dbtable ->
        :multi_interface_individual_datastream_dbtable

      @one_individual_properties_dbtable ->
        :one_individual_properties_dbtable

      @one_individual_datastream_dbtable ->
        :one_individual_datastream_dbtable

      @one_object_datastream_dbtable ->
        :one_object_datastream_dbtable
    end
  end
end
