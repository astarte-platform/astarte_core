defmodule AstarteCore.CQLUtils do

  def interface_name_to_table_name(interface_name, major_version) do
    String.replace(interface_name, ".", "_") <> "_v" <> Integer.to_string(major_version)
  end

  def endpoint_to_db_column_name(endpoint_name) do
    List.last(String.split(endpoint_name, "/"))
  end

  def mapping_value_type_to_db_type(value_type) do
    case value_type do
      :double -> "double"
      :integer -> "int"
      :boolean -> "boolean"
      :longinteger -> "bigint"
      :string -> "varchar"
      :binaryblob-> "blob"
      :datetime -> "timestamp"
      :doublearray -> "list<double>"
      :integerarray -> "list<int>"
      :booleanarray -> "list<boolean>"
      :longintegerarray -> "list<bigint>"
      :stringarray -> "list<varchar>"
      :binaryblobarray -> "list<blob>"
      :datetimearray -> "list<timestamp>"
    end
  end

  def type_to_db_column_name(column_type) do
    case column_type do
      :double -> "double_value"
      :integer -> "integer_value"
      :boolean -> "boolean_value"
      :longinteger -> "longinteger_value"
      :string -> "string_value"
      :binaryblob-> "binaryblob_value"
      :datetime -> "datetime_value"
      :doublearray -> "doublearray_value"
      :integerarray -> "integerarray_value"
      :booleanarray -> "booleanarray_value"
      :longintegerarray -> "longintegerarray_value"
      :stringarray -> "stringarray_value"
      :binaryblobarray -> "binaryblobarray_value"
      :datetimearray -> "datetimearray_value"
    end
  end

end
