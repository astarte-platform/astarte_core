defmodule Astarte.Core.CQLUtilsTest do
  use ExUnit.Case

  test "interface name to table name" do
    assert Astarte.Core.CQLUtils.interface_name_to_table_name("com.ispirata.Hemera.DeviceLog", 1) == "com_ispirata_hemera_devicelog_v1"
    assert Astarte.Core.CQLUtils.interface_name_to_table_name("test", 0) == "test_v0"
  end

  test "endpoint name to object interface column name" do
    assert Astarte.Core.CQLUtils.endpoint_to_db_column_name("/testEndpoint") == "testendpoint"
    assert Astarte.Core.CQLUtils.endpoint_to_db_column_name("%{p0}/%{p1}/testEndpoint2") == "testendpoint2"
  end

  test "mapping value type to db column type" do
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:double) == "double"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:integer) == "int"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:boolean) == "boolean"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:longinteger) == "bigint"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:string) == "varchar"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:binaryblob) == "blob"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:datetime) == "timestamp"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:doublearray) == "list<double>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:integerarray) == "list<int>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:booleanarray) == "list<boolean>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:longintegerarray) == "list<bigint>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:stringarray) == "list<varchar>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:binaryblobarray) == "list<blob>"
    assert Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:datetimearray) == "list<timestamp>"

    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type("integer") end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:date) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:time) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:int64) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:timestamp) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.mapping_value_type_to_db_type(:float) end
  end

  test "mapping value type to individual interface column name" do
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:double) == "double_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:integer) == "integer_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:boolean) == "boolean_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:longinteger) == "longinteger_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:string) == "string_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:binaryblob) == "binaryblob_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:datetime) == "datetime_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:doublearray) == "doublearray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:integerarray) == "integerarray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:booleanarray) == "booleanarray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:longintegerarray) == "longintegerarray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:stringarray) == "stringarray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:binaryblobarray) == "binaryblobarray_value"
    assert Astarte.Core.CQLUtils.type_to_db_column_name(:datetimearray) == "datetimearray_value"

    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name("integer") end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name(:date) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name(:time) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name(:int64) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name(:timestamp) end
    assert_raise CaseClauseError, fn -> Astarte.Core.CQLUtils.type_to_db_column_name(:float) end
  end

  test "interface id generation" do
    assert Astarte.Core.CQLUtils.interface_id("com.foo", 2) == Astarte.Core.CQLUtils.interface_id("com.foo", 2)
    assert Astarte.Core.CQLUtils.interface_id("com.test", 0) != Astarte.Core.CQLUtils.interface_id("com.test", 1)
    assert Astarte.Core.CQLUtils.interface_id("com.test1", 0) != Astarte.Core.CQLUtils.interface_id("com.test", 10)
    assert Astarte.Core.CQLUtils.interface_id("a", 1) != Astarte.Core.CQLUtils.interface_id("b", 1)
    assert Astarte.Core.CQLUtils.interface_id("astarte.is.cool", 10) == <<130, 183, 0, 172, 236, 95, 170, 50, 48, 172, 31, 81, 226, 57, 154, 178>>
  end

  test "endpoint id generation" do
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo", :float) == Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo", :float)
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo", :float) != Astarte.Core.CQLUtils.endpoint_id("com.foo", 3, "/test/foo", :float)
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo", :float) != Astarte.Core.CQLUtils.endpoint_id("com.foo", 2, "/test/foo", :integer)
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 1, "/test/foo", :float) != Astarte.Core.CQLUtils.endpoint_id("com.bar", 2, "/test/foo", :float)
    assert Astarte.Core.CQLUtils.endpoint_id("com.foo", 1, "/test/foo", :string) == <<219, 3, 255, 18, 65, 224, 57, 99, 144, 43, 234, 154, 231, 108, 196, 204>>
  end

end
