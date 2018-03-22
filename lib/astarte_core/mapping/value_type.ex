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

defmodule Astarte.Core.Mapping.ValueType do
  @mapping_value_type_double 1
  @mapping_value_type_doublearray 2
  @mapping_value_type_integer 3
  @mapping_value_type_integerarray 4
  @mapping_value_type_longinteger 5
  @mapping_value_type_longintegerarray 6
  @mapping_value_type_string 7
  @mapping_value_type_stringarray 8
  @mapping_value_type_boolean 9
  @mapping_value_type_booleanarray 10
  @mapping_value_type_binaryblob 11
  @mapping_value_type_binaryblobarray 12
  @mapping_value_type_datetime 13
  @mapping_value_type_datetimearray 14

  def to_int(value_type) do
    case value_type do
      :double -> @mapping_value_type_double
      :integer -> @mapping_value_type_integer
      :boolean -> @mapping_value_type_boolean
      :longinteger -> @mapping_value_type_longinteger
      :string -> @mapping_value_type_string
      :binaryblob -> @mapping_value_type_binaryblob
      :datetime -> @mapping_value_type_datetime
      :doublearray -> @mapping_value_type_doublearray
      :integerarray -> @mapping_value_type_integerarray
      :booleanarray -> @mapping_value_type_booleanarray
      :longintegerarray -> @mapping_value_type_longintegerarray
      :stringarray -> @mapping_value_type_stringarray
      :binaryblobarray -> @mapping_value_type_binaryblobarray
      :datetimearray -> @mapping_value_type_datetimearray
    end
  end

  def from_int(value_type_int) do
    case value_type_int do
      @mapping_value_type_double -> :double
      @mapping_value_type_integer -> :integer
      @mapping_value_type_boolean -> :boolean
      @mapping_value_type_longinteger -> :longinteger
      @mapping_value_type_string -> :string
      @mapping_value_type_binaryblob -> :binaryblob
      @mapping_value_type_datetime -> :datetime
      @mapping_value_type_doublearray -> :doublearray
      @mapping_value_type_integerarray -> :integerarray
      @mapping_value_type_booleanarray -> :booleanarray
      @mapping_value_type_longintegerarray -> :longintegerarray
      @mapping_value_type_stringarray -> :stringarray
      @mapping_value_type_binaryblobarray -> :binaryblobarray
      @mapping_value_type_datetimearray -> :datetimearray
    end
  end

  def from_string(value_type) do
    case value_type do
      "double" -> :double
      "integer" -> :integer
      "boolean" -> :boolean
      "longinteger" -> :longinteger
      "string" -> :string
      "binaryblob" -> :binaryblob
      "datetime" -> :datetime
      "doublearray" -> :doublearray
      "integerarray" -> :integerarray
      "booleanarray" -> :booleanarray
      "longintegerarray" -> :longintegerarray
      "stringarray" -> :stringarray
      "binaryblobarray" -> :binaryblobarray
      "datetimearray" -> :datetimearray
    end
  end
end
