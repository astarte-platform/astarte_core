defmodule Astarte.Core.Triggers.Policy.HandlerTest do
  use ExUnit.Case
  alias Astarte.Core.Triggers.Policy.Handler

  test "valid keyword handler" do
    params = %{
      "on" => "any_error",
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: true} = Handler.changeset(%Handler{}, params)
  end

  test "valid Http error codes handler" do
    params = %{
      "on" => [400, 401, 502],
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: true} = Handler.changeset(%Handler{}, params)
  end

  test "invalid keyword handler" do
    params = %{
      "on" => "invalid_error",
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: false, errors: [on: _]} = Handler.changeset(%Handler{}, params)
  end

  test "empty http error codes handler" do
    params = %{
      "on" => [],
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: false, errors: [on: _]} = Handler.changeset(%Handler{}, params)
  end

  test "invalid (< 400) http error codes handler" do
    params = %{
      "on" => [399],
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: false, errors: [on: _]} = Handler.changeset(%Handler{}, params)
  end

  test "invalid (> 599) http error codes handler" do
    params = %{
      "on" => [600],
      "strategy" => "discard"
    }

    assert %Ecto.Changeset{valid?: false, errors: [on: _]} = Handler.changeset(%Handler{}, params)
  end

  test "invalid strategy handler" do
    params = %{
      "on" => "any_error",
      "strategy" => "none"
    }

    assert %Ecto.Changeset{valid?: false, errors: [strategy: _]} =
             Handler.changeset(%Handler{}, params)
  end
end
