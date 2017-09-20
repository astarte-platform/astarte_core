defmodule Astarte.Core.Mapping.EndpointsAutomatonTest do
  use ExUnit.Case
  alias Astarte.Core.Mapping.EndpointsAutomaton

@valid_interface """
{
   "interface_name": "com.ispirata.Hemera.DeviceLog",
   "version_major": 1,
   "version_minor": 0,
   "type": "datastream",
   "quality": "producer",
   "aggregate": true,
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
           "type": "string",
           "allow_unset": true
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
   "aggregate": true,
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
           "type": "string",
           "allow_unset": true
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

  test "build endpoints automaton and resolve some endpoints" do
    {:ok, document} = Astarte.Core.InterfaceDocument.from_json(@valid_interface)

    assert {:ok, automaton} = EndpointsAutomaton.build(document.mappings)
    assert EndpointsAutomaton.is_valid?(automaton, document.mappings) == true

    # Exact match
    assert EndpointsAutomaton.resolve_endpoint("/filterRules/hello/world/value", automaton) == {:ok, "/filterRules/%{ruleId}/%{filterKey}/value"}
    assert EndpointsAutomaton.resolve_endpoint("/test/0/v", automaton) == {:ok, "/test/%{ind}/v"}

    # Guessed match
    assert EndpointsAutomaton.resolve_endpoint("/filterRules/hello/world", automaton) == {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}
    assert EndpointsAutomaton.resolve_endpoint("/filterRules/hello", automaton) == {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}
    assert EndpointsAutomaton.resolve_endpoint("/filterRules", automaton) == {:guessed, ["/filterRules/%{ruleId}/%{filterKey}/value"]}
    assert EndpointsAutomaton.resolve_endpoint("/test/0", automaton) == {:guessed, ["/test/%{ind}/v"]}
    assert EndpointsAutomaton.resolve_endpoint("/test", automaton) == {:guessed, ["/test/%{ind}/v"]}
    assert {:guessed, all_endpoints} = EndpointsAutomaton.resolve_endpoint("", automaton)
    assert Enum.sort(all_endpoints) ==  ["/applicationId", "/cmdLine", "/filterRules/%{ruleId}/%{filterKey}/value", "/message", "/monotonicTimestamp", "/pid", "/test/%{ind}/v", "/test2/pluto/v", "/timestamp"]
  end

  test "build endpoints automaton and test resolve failure" do
    {:ok, document} = Astarte.Core.InterfaceDocument.from_json(@valid_interface)

    assert {:ok, automaton} = EndpointsAutomaton.build(document.mappings)

    assert EndpointsAutomaton.resolve_endpoint("/notFound/hello/world/value", automaton) == {:error, :not_found}
    assert EndpointsAutomaton.resolve_endpoint("/filterRules/hello/world/value/too/long", automaton) == {:error, :not_found}
    assert EndpointsAutomaton.resolve_endpoint("/filterRules/hello/value/other/things", automaton) == {:error, :not_found}
  end

  test "build endpoints automaton and fail due to invalid interface" do
    {:ok, document} = Astarte.Core.InterfaceDocument.from_json(@invalid_interface)

    assert {:error, :overlapping_mappings} = EndpointsAutomaton.build(document.mappings)
    assert ["/test/pluto/v"] = EndpointsAutomaton.lint(document.mappings)
  end
end
