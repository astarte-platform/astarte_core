defmodule Astarte.Core.GroupTest do
  use ExUnit.Case

  alias Astarte.Core.Group

  test "empty group name fails" do
    assert Group.valid_name?("") == false
  end

  test "group name with reserved prefixes fail" do
    assert Group.valid_name?("astarte:other") == false
    assert Group.valid_name?("interfaces-other") == false
    assert Group.valid_name?("interface$other") == false
    assert Group.valid_name?("devices/other") == false
    assert Group.valid_name?("query_other") == false
    assert Group.valid_name?("realm.other") == false
    assert Group.valid_name?("triggers@other") == false
  end

  test "valid group names are accepted" do
    assert Group.valid_name?("plainname") == true
    assert Group.valid_name?("a/name-with@many*strange§characters") == true
    assert Group.valid_name?("🤔") == true
  end
end
