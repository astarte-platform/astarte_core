defmodule Astarte.Core.CQLUtils do
  @moduledoc """
  This module contains a set of functions that should be used to map Astarte types and concepts to C*
  """

  @interface_descriptor_statement """
    SELECT name, major_version, minor_version, type, quality, flags
    FROM interfaces
    WHERE name=:name AND major_version=:major_version
  """

  @doc """
  Returns a generated table name that might be used during table creation."
  """
  def interface_name_to_table_name(interface_name, major_version) do
    String.replace(String.downcase(interface_name), ".", "_") <> "_v" <> Integer.to_string(major_version)
  end

  @doc """
  Returns the column name for a certain endpoint that will be used for object interface tables.
  """
  def endpoint_to_db_column_name(endpoint_name) do
    List.last(String.split(String.downcase(endpoint_name), "/"))
  end

  @doc """
  Returns the CQL query statement that should be used to retrieve interface descriptor from the database.
  """
  def interface_descriptor_statement() do
    @interface_descriptor_statement
  end

  @doc """
  Returns a CQL type for a given mapping value type atom
  """
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

  @doc """
  Returns table column name that stores a certain type.
  """
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

  @doc """
  Returns interface UUID for a certain `interface_name` with a certain `interface_major`
  """
  def interface_id(interface_name, interface_major) do
    :crypto.hash(:md5, "iid:#{interface_name}:#{Integer.to_string(interface_major)}")
  end

  @doc """
  returns an endpoint UUID for a certain `endpoint` on a certain `interface_name` with a certain `interface_major` and `endpoint_type`.
  """
  def endpoint_id(interface_name, interface_major, endpoint, endpoint_type) do
    stripped_endpoint =
      endpoint
      |> String.replace(~r/%{[a-zA-Z0-9]*}/, "")

    :crypto.hash(:md5, "eid:#{interface_name}:#{Integer.to_string(interface_major)}:#{stripped_endpoint}:#{to_string(endpoint_type)}:")
  end

end
