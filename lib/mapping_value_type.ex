defmodule AstarteCore.Mapping.ValueType do

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
      :binaryblob-> @mapping_value_type_binaryblob
      :datetime ->@mapping_value_type_datetime
      :doublearray -> @mapping_value_type_doublearray
      :integerarray -> @mapping_value_type_integerarray
      :booleanarray -> @mapping_value_type_booleanarray
      :longintegerarray -> @mapping_value_type_longintegerarray
      :stringarray -> @mapping_value_type_stringarray
      :binaryblobarray -> @mapping_value_type_binaryblobarray
      :datetimearray ->@mapping_value_type_datetimearray
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
