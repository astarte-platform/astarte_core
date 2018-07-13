defmodule Astarte.Core.MappingTest do
  use ExUnit.Case

  alias Astarte.Core.CQLUtils
  alias Astarte.Core.Mapping

  test "mapping with no type fails" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/valid"
    }

    assert %Ecto.Changeset{valid?: false, errors: [type: _]} =
             Mapping.changeset(%Mapping{}, params, opts)
  end

  test "mapping with invalid type fails" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/valid",
      "type" => "invalid"
    }

    assert %Ecto.Changeset{valid?: false, errors: [type: _]} =
             Mapping.changeset(%Mapping{}, params, opts)
  end

  test "mapping with invalid endpoint fails" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "//this/is/almost/%{ok}",
      "type" => "string"
    }

    assert %Ecto.Changeset{valid?: false, errors: [endpoint: _]} =
             Mapping.changeset(%Mapping{}, params, opts)
  end

  test "mapping with invalid retention fails" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/valid",
      "type" => "string",
      "retention" => "invalid"
    }

    assert %Ecto.Changeset{valid?: false, errors: [retention: _]} =
             Mapping.changeset(%Mapping{}, params, opts)
  end

  test "mapping with invalid reliability fails" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/valid",
      "type" => "string",
      "reliability" => "invalid"
    }

    assert %Ecto.Changeset{valid?: false, errors: [reliability: _]} =
             Mapping.changeset(%Mapping{}, params, opts)
  end

  test "valid mapping" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/this/is/%{ok}",
      "type" => "integer",
      "retention" => "stored",
      "reliability" => "guaranteed",
      "expiry" => 60
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Mapping.changeset(%Mapping{}, params, opts)
    assert {:ok, mapping} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Mapping{
             endpoint: "/this/is/%{ok}",
             value_type: :integer,
             retention: :stored,
             reliability: :guaranteed,
             expiry: 60
           } = mapping
  end

  test "legacy naming" do
    opts = opts_fixture()

    params = %{
      "path" => "/this/is/%{ok}",
      "type" => "double"
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Mapping.changeset(%Mapping{}, params, opts)
    assert {:ok, mapping} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Mapping{
             endpoint: "/this/is/%{ok}",
             value_type: :double
           } = mapping
  end

  test "defaults" do
    opts = opts_fixture()

    params = %{
      "endpoint" => "/this/is/%{ok}",
      "type" => "datetime"
    }

    assert %Ecto.Changeset{valid?: true} = changeset = Mapping.changeset(%Mapping{}, params, opts)
    assert {:ok, mapping} = Ecto.Changeset.apply_action(changeset, :insert)

    assert %Mapping{
             endpoint: "/this/is/%{ok}",
             value_type: :datetime,
             retention: :discard,
             reliability: :unreliable,
             expiry: 0,
             allow_unset: false
           } = mapping
  end

  defp opts_fixture do
    interface_name = "com.Name"
    interface_major = 1
    interface_id = CQLUtils.interface_id(interface_name, interface_major)

    [interface_name: interface_name, interface_major: interface_major, interface_id: interface_id]
  end
end
