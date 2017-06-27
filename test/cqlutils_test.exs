defmodule CQLUtilsTest do
  use ExUnit.Case
  doctest AstarteCore.CQLUtils

  test "interface name to table name" do
    assert AstarteCore.CQLUtils.interface_name_to_table_name("com.ispirata.Hemera.DeviceLog", 1) == "com_ispirata_hemera_devicelog_v1"
    assert AstarteCore.CQLUtils.interface_name_to_table_name("test", 0) == "test_v0"
  end

  test "endpoint name to object interface column name" do
    assert AstarteCore.CQLUtils.endpoint_to_db_column_name("/testEndpoint") == "testendpoint"
    assert AstarteCore.CQLUtils.endpoint_to_db_column_name("%{p0}/%{p1}/testEndpoint2") == "testendpoint2"
  end

  test "mapping value type to db column type" do
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:double) == "double"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:integer) == "int"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:boolean) == "boolean"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:longinteger) == "bigint"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:string) == "varchar"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:binaryblob) == "blob"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:datetime) == "timestamp"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:doublearray) == "list<double>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:integerarray) == "list<int>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:booleanarray) == "list<boolean>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:longintegerarray) == "list<bigint>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:stringarray) == "list<varchar>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:binaryblobarray) == "list<blob>"
    assert AstarteCore.CQLUtils.mapping_value_type_to_db_type(:datetimearray) == "list<timestamp>"

    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type("integer") end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type(:date) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type(:time) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type(:int64) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type(:timestamp) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.mapping_value_type_to_db_type(:float) end
  end

  test "mapping value type to individual interface column name" do
    assert AstarteCore.CQLUtils.type_to_db_column_name(:double) == "double_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:integer) == "integer_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:boolean) == "boolean_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:longinteger) == "longinteger_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:string) == "string_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:binaryblob) == "binaryblob_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:datetime) == "datetime_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:doublearray) == "doublearray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:integerarray) == "integerarray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:booleanarray) == "booleanarray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:longintegerarray) == "longintegerarray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:stringarray) == "stringarray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:binaryblobarray) == "binaryblobarray_value"
    assert AstarteCore.CQLUtils.type_to_db_column_name(:datetimearray) == "datetimearray_value"

    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name("integer") end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name(:date) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name(:time) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name(:int64) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name(:timestamp) end
    assert_raise CaseClauseError, fn -> AstarteCore.CQLUtils.type_to_db_column_name(:float) end
  end

end
