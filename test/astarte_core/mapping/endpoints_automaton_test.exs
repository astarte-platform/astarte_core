defmodule Astarte.Core.Mapping.EndpointsAutomatonTest do
  use ExUnit.Case
  alias Astarte.Core.Mapping.EndpointsAutomaton
  alias Astarte.Core.Interface

  @valid_interface """
  {
   "interface_name": "com.ispirata.Hemera.DeviceLog",
   "version_major": 1,
   "version_minor": 0,
   "type": "datastream",
   "quality": "producer",
   "mappings": [
       {
           "path": "/message",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/timestamp",
           "type": "datetime",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/monotonicTimestamp",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/applicationId",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/pid",
           "type": "integer",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/cmdLine",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/filterRules/%{ruleId}/%{filterKey}/value",
           "type": "string"
       },
       {
           "path": "/test/%{ind}/v",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/test2/pluto/v",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       }
   ]
  }
  """

  @invalid_interface """
  {
   "interface_name": "com.ispirata.Hemera.DeviceLog",
   "version_major": 1,
   "version_minor": 0,
   "type": "datastream",
   "quality": "producer",
   "mappings": [
       {
           "path": "/message",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/timestamp",
           "type": "datetime",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/monotonicTimestamp",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/applicationId",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/pid",
           "type": "integer",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/cmdLine",
           "type": "string",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/filterRules/%{ruleId}/%{filterKey}/value",
           "type": "string"
       },
       {
           "path": "/test/%{ind}/v",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       },
       {
           "path": "/test/pluto/v",
           "type": "longinteger",
           "reliability": "guaranteed",
           "retention": "stored"
       }
   ]
  }
  """

  @test_draft_interface_a_0 """
    {
      "interface_name": "com.ispirata.Draft",
      "version_major": 0,
      "version_minor": 2,
      "type": "properties",
      "quality": "consumer",
      "mappings": [
        {
          "path": "/filterRules/%{ruleId}/%{filterKey}/value",
          "type": "string",
          "allow_unset": true
        },
        {
          "path": "/filterRules/%{ruleId}/%{filterKey}/foo",
          "type": "boolean",
          "allow_unset": false
        }
      ]
    }
  """

  test "build endpoints automaton" do
    {:ok, params} = Poison.decode(@test_draft_interface_a_0)

    {:ok, document} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    assert {status, automaton} = EndpointsAutomaton.build(document.mappings)
    assert EndpointsAutomaton.lint(document.mappings) == []
    assert EndpointsAutomaton.is_valid?(automaton, document.mappings) == true
    assert status == :ok

    assert Enum.count(elem(automaton, 0)) == 5
    assert Enum.count(elem(automaton, 1)) == 2
  end

  test "build endpoints automaton and resolve some endpoints" do
    {:ok, params} = Poison.decode(@valid_interface)

    {:ok, document} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    assert {:ok, automaton} = EndpointsAutomaton.build(document.mappings)
    assert EndpointsAutomaton.is_valid?(automaton, document.mappings) == true

    assert Enum.count(elem(automaton, 1)) == length(document.mappings)

    # Exact match
    assert EndpointsAutomaton.resolve_path("/filterRules/hello/world/value", automaton) ==
             {:ok, "/filterRules/%{ruleId}/%{filterKey}/value"}

    assert EndpointsAutomaton.resolve_path("/test/0/v", automaton) == {:ok, "/test/%{ind}/v"}

    # Guessed match
    assert EndpointsAutomaton.resolve_path("/filterRules/hello/world", automaton) ==
             {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}

    assert EndpointsAutomaton.resolve_path("/filterRules/hello/world/", automaton) ==
             {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}

    assert EndpointsAutomaton.resolve_path("/filterRules/hello", automaton) ==
             {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}

    assert EndpointsAutomaton.resolve_path("/filterRules", automaton) ==
             {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}

    assert EndpointsAutomaton.resolve_path("/test/0", automaton) == {:guessed, ["/test/%{ind}/v"]}
    assert EndpointsAutomaton.resolve_path("/test", automaton) == {:guessed, ["/test/%{ind}/v"]}
    assert {:guessed, all_endpoints} = EndpointsAutomaton.resolve_path("", automaton)

    assert Enum.sort(all_endpoints) == [
             "/applicationId",
             "/cmdLine",
             "/filterRules/%{ruleId}/%{filterKey}/value",
             "/message",
             "/monotonicTimestamp",
             "/pid",
             "/test/%{ind}/v",
             "/test2/pluto/v",
             "/timestamp"
           ]

    assert {:guessed, all_endpoints} = EndpointsAutomaton.resolve_path("/", automaton)

    assert Enum.sort(all_endpoints) == [
             "/applicationId",
             "/cmdLine",
             "/filterRules/%{ruleId}/%{filterKey}/value",
             "/message",
             "/monotonicTimestamp",
             "/pid",
             "/test/%{ind}/v",
             "/test2/pluto/v",
             "/timestamp"
           ]
  end

  test "build endpoints automaton and test resolve failure" do
    {:ok, params} = Poison.decode(@valid_interface)

    {:ok, document} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)


    assert {:ok, automaton} = EndpointsAutomaton.build(document.mappings)

    assert EndpointsAutomaton.resolve_path("/notFound/hello/world/value", automaton) ==
             {:error, :not_found}

    assert EndpointsAutomaton.resolve_path("/filterRules/hello/world/value/too/long", automaton) ==
             {:error, :not_found}

    assert EndpointsAutomaton.resolve_path("/filterRules/hello/value/other/things", automaton) ==
             {:error, :not_found}
  end

  test "build endpoints automaton and fail due to invalid interface" do
    {:ok, params} = Poison.decode(@invalid_interface)

    {:ok, document} =
      Interface.changeset(%Interface{}, params)
      |> Ecto.Changeset.apply_action(:insert)

    assert {:error, :overlapping_mappings} = EndpointsAutomaton.build(document.mappings)
    assert ["/test/pluto/v"] = EndpointsAutomaton.lint(document.mappings)
  end
end
