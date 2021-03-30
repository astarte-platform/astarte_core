defmodule Astarte.Core.Triggers.PolicyTest do
  use Astarte.Core.Triggers.PolicyProtobuf

  use ExUnit.Case
  alias Astarte.Core.Triggers.Policy
  alias Astarte.Core.Triggers.Policy.Handler
  alias Astarte.Core.Triggers.Policy.KeywordError
  alias Astarte.Core.Triggers.Policy.RangeError
  alias Astarte.Core.Triggers.PolicyProtobuf.Policy, as: PolicyProto
  alias Astarte.Core.Triggers.PolicyProtobuf.Handler, as: HandlerProto
  alias Astarte.Core.Triggers.PolicyProtobuf.KeywordError, as: KeywordErrorProto
  alias Astarte.Core.Triggers.PolicyProtobuf.RangeError, as: RangeErrorProto

  @a_policy """
    {
      "name": "somename",
      "error_handlers": [
        {
          "on" : "any_error",
          "strategy": "retry"
        }
      ],
      "maximum_capacity": 300,
      "retry_times": 10,
      "event_ttl": 10
    }
  """

  test "valid policy" do
    params = %{
      name: "pippo",
      maximum_capacity: 100,
      error_handlers: [
        %{on: "any_error", strategy: "discard"}
      ]
    }

    assert %Ecto.Changeset{valid?: true} = Policy.changeset(%Policy{}, params)
  end

  describe "policy name validation" do
    test "valid policy_name with punctuation" do
      params = %{
        name: "org.astarte-platform.PolicyName",
        error_handlers: [
          %{on: "any_error", strategy: "discard"}
        ],
        maximum_capacity: 300
      }

      assert %Ecto.Changeset{valid?: true} = Policy.changeset(%Policy{}, params)
    end

    test "invalid policy name starting with @" do
      params = %{
        name: "@org.astarte-platform.PolicyName",
        error_handlers: [
          %{on: "any_error", strategy: "discard"}
        ],
        maximum_capacity: 300
      }

      assert %Ecto.Changeset{valid?: false, errors: [name: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "long policy name fails" do
      params = %{
        name: Stream.cycle(["a"]) |> Enum.take(129),
        error_handlers: [
          %{on: "any_error", strategy: "discard"}
        ],
        maximum_capacity: 300
      }

      assert %Ecto.Changeset{valid?: false, errors: [name: _]} =
               Policy.changeset(%Policy{}, params)
    end
  end

  describe "policy attributes combination" do
    test "invalid policy no handler" do
      params = %{
        name: "pippo",
        maximum_capacity: 100
      }

      assert %Ecto.Changeset{valid?: false, errors: [error_handlers: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "invalid policy retry and no retry_times " do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: "any_error", strategy: "retry"}
        ]
      }

      assert %Ecto.Changeset{valid?: false, errors: [retry_times: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "invalid policy overlapping keyword handlers" do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: "any_error", strategy: "discard"},
          %{on: "server_error", strategy: "discard"}
        ]
      }

      assert %Ecto.Changeset{valid?: false, errors: [error_handlers: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "invalid policy overlapping range handlers" do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: [401, 402, 403, 404], strategy: "discard"},
          %{on: [404, 500], strategy: "discard"}
        ]
      }

      assert %Ecto.Changeset{valid?: false, errors: [error_handlers: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "invalid policy overlapping keyword and range handlers" do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: "client_error", strategy: "discard"},
          %{on: [404, 500], strategy: "discard"}
        ]
      }

      assert %Ecto.Changeset{valid?: false, errors: [error_handlers: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "invalid policy discards with retry_times" do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: "any_error", strategy: "discard"}
        ],
        retry_times: 10
      }

      assert %Ecto.Changeset{valid?: false, errors: [retry_times: _]} =
               Policy.changeset(%Policy{}, params)
    end

    test "valid policy discard and retry" do
      params = %{
        name: "pippo",
        maximum_capacity: 100,
        error_handlers: [
          %{on: "client_error", strategy: "retry"},
          %{on: "server_error", strategy: "discard"}
        ],
        retry_times: 10
      }

      assert %Ecto.Changeset{valid?: true} = Policy.changeset(%Policy{}, params)
    end
  end

  test "Policy roundtrip" do
    policy = %Policy{
      name: "pippo",
      maximum_capacity: 100,
      error_handlers: [
        %Handler{on: %KeywordError{keyword: "client_error"}, strategy: "retry"},
        %Handler{on: %RangeError{error_codes: [500, 501, 503]}, strategy: "discard"}
      ],
      retry_times: 10
    }

    policy_proto = Policy.to_policy_proto(policy)

    assert %PolicyProto{
             name: "pippo",
             maximum_capacity: 100,
             retry_times: 10,
             event_ttl: 0,
             error_handlers: error_handlers
           } = policy_proto

    assert [
             %HandlerProto{
               strategy: :RETRY,
               on: tagged_keyword_error
             },
             %HandlerProto{
               strategy: :DISCARD,
               on: tagged_range_error
             }
           ] = error_handlers

    assert {:keyword_error, %KeywordErrorProto{keyword: :CLIENT_ERROR}} = tagged_keyword_error

    assert {:range_error, %RangeErrorProto{error_codes: [500, 501, 503]}} = tagged_range_error

    assert policy == Policy.from_policy_proto!(policy_proto)
  end

  test "JSON encode" do
    policy = %Policy{
      name: "somename",
      error_handlers: [
        %Handler{
          on: %KeywordError{keyword: "any_error"},
          strategy: "retry"
        }
      ],
      maximum_capacity: 300,
      retry_times: 10
    }

    assert Jason.encode(policy) ==
             Jason.encode(%{
               "name" => "somename",
               "error_handlers" => [
                 %{
                   "on" => %{"keyword" => "any_error"},
                   "strategy" => "retry"
                 }
               ],
               "maximum_capacity" => 300,
               "retry_times" => 10,
               "event_ttl" => nil
             })
  end

  test "JSON decode" do
    {:ok, params} = Jason.decode(@a_policy)

    {:ok, _policy} =
      Policy.changeset(%Policy{}, params)
      |> Ecto.Changeset.apply_action(:insert)
  end
end
