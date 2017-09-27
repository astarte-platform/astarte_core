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

defmodule Astarte.Core.Mapping.Retention do

  @mapping_retention_discard 1
  @mapping_retention_volatile 2
  @mapping_retention_stored 3

  def to_int(retention) do
    case retention do
      :discard -> @mapping_retention_discard
      :volatile -> @mapping_retention_volatile
      :stored -> @mapping_retention_stored
    end
  end

  def from_int(retention_int) do
    case retention_int do
      @mapping_retention_discard -> :discard
      @mapping_retention_volatile -> :volatile
      @mapping_retention_stored -> :stored
    end
  end

  def from_string(retention) do
    case retention do
      "discard" -> :discard
      "volatile" -> :volatile
      "stored" -> :stored
    end
  end

end
