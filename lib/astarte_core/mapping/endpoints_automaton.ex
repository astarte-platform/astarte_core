defmodule Astarte.Core.Mapping.EndpointsAutomaton do

  @doc """
  returns ``:ok`` and an endpoint for a given ``path`` using a previously built automata (``{transitions, accepting_states}``).
  path must be a likely valid path, (e.g. no trailing slashes).
  if path is not complete one or more endpoints will be gussed and ``:gussed`` followed by a list of endpoints is returned.
  """
  def resolve_endpoint(path, {transitions, accepting_states}) do
    ["" | path_tokens] = String.split(path, "/")

    states = do_transitions(path_tokens, [0], transitions)

    cond do
      states == [] ->
        {:error, :not_found}
      length(states) == 1 and accepting_states[hd(states)] != nil ->
        {:ok, accepting_states[hd(states)]}

      true ->
        states = force_transitions(states, transitions, accepting_states)
        guessed_endpoints = for state <- states do
          accepting_states[state]
        end

        {:guessed, guessed_endpoints}
    end
  end

  @doc """
  builds the automaton for given `mappings`, returns ``:ok`` followed by the automaton tuple if build succeeded, otherwise ``:error`` and the reason.
  """
  def build(mappings) do
    nfa = do_build(mappings)

    if is_valid?(nfa, mappings) do
      {:ok, nfa}
    else
      {:error, :overlapping_mappings}
    end
  end

  @doc """
  returns true if ``nfa`` is valid for given ``mappings``
  """
  def is_valid?(nfa, mappings) do
    Enum.reduce(mappings, true, fn(mapping, valid) ->
      valid and (resolve_endpoint(mapping.endpoint, nfa) == {:ok, mapping.endpoint})
    end)
  end

  @doc """
  returns a list of likely invalid endpoints for a certain list of ``mappings``.
  """
  def lint(mappings) do
    nfa = do_build(mappings)

    errors_list = for mapping <- mappings do
      if (resolve_endpoint(mapping.endpoint, nfa) == {:ok, mapping.endpoint}) do
        []
      else
        mapping.endpoint
      end
    end

    List.flatten(errors_list)
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

  defp do_build(mappings) do
    {transitions, _, accepting_states} = Enum.reduce(mappings, {%{}, [], %{}}, fn(mapping, {transitions, states, accepting_states}) ->
      ["" | path_tokens] = mapping.endpoint
        |> String.replace(~r/%{[a-zA-Z0-9]*}/, "")
        |> String.split("/")

      {states, _, _, transitions} = Enum.reduce(path_tokens, {states, 0, "", transitions}, fn(token, {states, previous_state, partial_endpoint, transitions}) ->
        new_partial_endpoint = "#{partial_endpoint}/#{token}"
        candidate_previous = Enum.find_index(states, fn(state) -> state == new_partial_endpoint end)

        if candidate_previous != nil do
          {states, candidate_previous + 1, new_partial_endpoint, transitions}
        else
          states = states ++ [partial_endpoint]
          new_state = length(states)
          {states, new_state, new_partial_endpoint, Map.put(transitions, {previous_state, token}, new_state)}
        end
      end)

      accepting_states = Map.put(accepting_states, length(states), mapping.endpoint)

      {transitions, states, accepting_states}
    end)

    {transitions, accepting_states}
  end
end
