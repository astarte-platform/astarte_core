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

defmodule Astarte.Core.Interface.Aggregation do

  @interface_aggregation_individual 1
  @interface_aggregation_object 2

  def to_int(aggregation) do
    case aggregation do
      :individual -> @interface_aggregation_individual
      :object -> @interface_aggregation_object
    end
  end

  def from_int(aggregation_int) do
    case aggregation_int do
      @interface_aggregation_individual -> :individual
      @interface_aggregation_object -> :object
    end
  end

  def from_string(aggregation) do
    case aggregation do
      "individual" -> :individual
      "object" -> :object
    end
  end

end
