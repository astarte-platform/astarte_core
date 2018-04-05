defmodule Astarte.Core.Triggers.SimpleTriggerConfig do
  @moduledoc """
  This module handles the functions for creating a SimpleTriggerConfig (and its relative struct).

  The struct contains the `simple_trigger_container` wrapping the simple trigger and the `object_id` and `object_type`
  on which the trigger is or will be installed
  """
  # TODO: clarify/refactor the naming around SimpleTrigger{,Config,Container}

  defstruct [
    :object_type,
    :object_id,
    :simple_trigger_container
  ]
end
