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

defmodule Astarte.Core.Interface.Ownership do

  @interface_ownership_thing 1
  @interface_ownership_server 2

  def to_int(ownership) do
    case ownership do
      :thing -> @interface_ownership_thing
      :server -> @interface_ownership_server
    end
  end

  def from_int(ownership_int) do
    case ownership_int do
      @interface_ownership_thing -> :thing
      @interface_ownership_server -> :server
    end
  end

  def from_string(ownership) do
    case ownership do
      "thing" -> :thing
      "server" -> :server
        # deprecated names
      "producer" -> :thing
      "consumer" -> :server
    end
  end

end
