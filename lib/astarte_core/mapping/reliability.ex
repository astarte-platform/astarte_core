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

defmodule Astarte.Core.Mapping.Reliability do

  @mapping_reliability_unreliable 1
  @mapping_reliability_guaranteed 2
  @mapping_reliability_unique 3

  def to_int(reliability) do
    case reliability do
      :unreliable -> @mapping_reliability_unreliable
      :guaranteed -> @mapping_reliability_guaranteed
      :unique -> @mapping_reliability_unique
    end
  end

  def from_int(reliability_int) do
    case reliability_int do
      @mapping_reliability_unreliable -> :unreliable
      @mapping_reliability_guaranteed -> :guaranteed
      @mapping_reliability_unique -> :unique
    end
  end

  def from_string(reliability) do
    case reliability do
      "unreliable" -> :unreliable
      "guaranteed" -> :guaranteed
      "unique" -> :unique
    end
  end

end
