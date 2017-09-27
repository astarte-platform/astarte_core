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

defmodule Astarte.Core.Interface.Type do

  @interface_type_properties 1
  @interface_type_datastream 2

  def to_int(type) do
    case type do
      :properties -> @interface_type_properties
      :datastream -> @interface_type_datastream
    end
  end

  def from_int(type_int) do
    case type_int do
      @interface_type_properties -> :properties
      @interface_type_datastream -> :datastream
    end
  end

  def from_string(type) do
    case type do
      "properties" -> :properties
      "datastream" -> :datastream
    end
  end

end
