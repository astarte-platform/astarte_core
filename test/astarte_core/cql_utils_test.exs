defmodule CQLUtilsTest do
  use ExUnit.Case
  alias Astarte.Core.CQLUtils

  test "interface name to table name" do
    assert CQLUtils.interface_name_to_table_name("com.ispirata.Hemera.DeviceLog", 1) == "com_ispirata_hemera_devicelog_v1"
    assert CQLUtils.interface_name_to_table_name("test", 0) == "test_v0"
  end

  test "endpoint name to object interface column name" do
    assert CQLUtils.endpoint_to_db_column_name("/testEndpoint") == "testendpoint"
    assert CQLUtils.endpoint_to_db_column_name("%{p0}/%{p1}/testEndpoint2") == "testendpoint2"
  end

  test "mapping value type to db column type" do
    assert CQLUtils.mapping_value_type_to_db_type(:double) == "double"
    assert CQLUtils.mapping_value_type_to_db_type(:integer) == "int"
    assert CQLUtils.mapping_value_type_to_db_type(:boolean) == "boolean"
    assert CQLUtils.mapping_value_type_to_db_type(:longinteger) == "bigint"
    assert CQLUtils.mapping_value_type_to_db_type(:string) == "varchar"
    assert CQLUtils.mapping_value_type_to_db_type(:binaryblob) == "blob"
    assert CQLUtils.mapping_value_type_to_db_type(:datetime) == "timestamp"
    assert CQLUtils.mapping_value_type_to_db_type(:doublearray) == "list<double>"
    assert CQLUtils.mapping_value_type_to_db_type(:integerarray) == "list<int>"
    assert CQLUtils.mapping_value_type_to_db_type(:booleanarray) == "list<boolean>"
    assert CQLUtils.mapping_value_type_to_db_type(:longintegerarray) == "list<bigint>"
    assert CQLUtils.mapping_value_type_to_db_type(:stringarray) == "list<varchar>"
    assert CQLUtils.mapping_value_type_to_db_type(:binaryblobarray) == "list<blob>"
    assert CQLUtils.mapping_value_type_to_db_type(:datetimearray) == "list<timestamp>"

    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type("integer") end
    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type(:date) end
    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type(:time) end
    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type(:int64) end
    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type(:timestamp) end
    assert_raise CaseClauseError, fn -> CQLUtils.mapping_value_type_to_db_type(:float) end
  end

  test "mapping value type to individual interface column name" do
    assert CQLUtils.type_to_db_column_name(:double) == "double_value"
    assert CQLUtils.type_to_db_column_name(:integer) == "integer_value"
    assert CQLUtils.type_to_db_column_name(:boolean) == "boolean_value"
    assert CQLUtils.type_to_db_column_name(:longinteger) == "longinteger_value"
    assert CQLUtils.type_to_db_column_name(:string) == "string_value"
    assert CQLUtils.type_to_db_column_name(:binaryblob) == "binaryblob_value"
    assert CQLUtils.type_to_db_column_name(:datetime) == "datetime_value"
    assert CQLUtils.type_to_db_column_name(:doublearray) == "doublearray_value"
    assert CQLUtils.type_to_db_column_name(:integerarray) == "integerarray_value"
    assert CQLUtils.type_to_db_column_name(:booleanarray) == "booleanarray_value"
    assert CQLUtils.type_to_db_column_name(:longintegerarray) == "longintegerarray_value"
    assert CQLUtils.type_to_db_column_name(:stringarray) == "stringarray_value"
    assert CQLUtils.type_to_db_column_name(:binaryblobarray) == "binaryblobarray_value"
    assert CQLUtils.type_to_db_column_name(:datetimearray) == "datetimearray_value"

    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name("integer") end
    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name(:date) end
    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name(:time) end
    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name(:int64) end
    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name(:timestamp) end
    assert_raise CaseClauseError, fn -> CQLUtils.type_to_db_column_name(:float) end
  end

  test "interface id generation" do
    assert CQLUtils.interface_id("com.foo", 2) == CQLUtils.interface_id("com.foo", 2)
    assert CQLUtils.interface_id("com.test", 0) != CQLUtils.interface_id("com.test", 1)
    assert CQLUtils.interface_id("com.test1", 0) != CQLUtils.interface_id("com.test", 10)
    assert CQLUtils.interface_id("a", 1) != CQLUtils.interface_id("b", 1)
    assert CQLUtils.interface_id("astarte.is.cool", 10) == <<130, 183, 0, 172, 236, 95, 170, 50, 48, 172, 31, 81, 226, 57, 154, 178>>
  end

  test "endpoint id generation" do
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo") == Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo")
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo") != Astarte.Core.CQLUtils.endpoint_id("com.foo", 3, "/test/foo")
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 1, "/test/foo") != Astarte.Core.CQLUtils.endpoint_id("com.bar", 1, "/test/foo")
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 1, "/test/foo") == <<70, 183, 225, 18, 23, 42, 133, 243, 125, 50, 212, 187, 67, 186, 155, 223>>
  end

end
