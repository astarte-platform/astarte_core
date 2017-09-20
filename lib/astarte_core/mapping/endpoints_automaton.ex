defmodule Astarte.Core.Mapping.EndpointsAutomaton do

  @doc """
  returns ``:ok`` and an endpoint for a given ``path`` using a previously built automata (``{transitions, accepting_states}``).
  path must be a likely valid path, (e.g. no trailing slashes).
  if path is not complete one or more endpoints will be gussed and ``:gussed`` followed by a list of endpoints is returned.
  """
  def resolve_endpoint(path, {transitions, accepting_states}) do
    ["" | path_tokens] = String.split(path, "/")

    states = do_transitions(path_tokens, [0], transitions)
    [state|_] = states

    cond do
      states == [] ->
        :not_found
      length(states) == 1 and accepting_states[state] != nil ->
        {:ok, accepting_states[state]}

      true ->
        states = force_transitions(states, transitions, accepting_states)
        guessed_endpoints = for state <- states do
          accepting_states[state]
        end

        {:guessed, guessed_endpoints}
    end
  end

  defp do_transitions([], current_states, _transitions) do
    current_states
  end

  defp do_transitions(_tokens, [], _transitions) do
    []
  end

  defp do_transitions([token | tail_tokens], current_states, transitions) do
    next_states = for state <- current_states do
      [transitions[{state, token}] || [], transitions[{state, ""}] || []]
    end

    do_transitions(tail_tokens, List.flatten(next_states), transitions)
  end

  defp force_transitions(current_states, transitions, accepting_states) do
    next_states = for state <- current_states do
      if accepting_states[state] == nil do
        for found <- (Enum.filter(transitions, fn(transition) -> match?({{^state, _}, _}, transition) end) || []) do
          {_, next_state} = found

          next_state
        end
      else
        state
      end
    end

    flat_next = List.flatten(next_states)

    finished = Enum.reduce(flat_next, true, fn(state, finished) ->
      finished and (accepting_states[state] != nil)
    end)

    if finished do
      flat_next
    else
      force_transitions(flat_next, transitions, accepting_states)
    end
  end

end
