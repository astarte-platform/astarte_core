defmodule Astarte.Core.Mapping.EndpointsAutomaton do

  @doc """
  returns `:ok` and an endpoint for a given `path` using a previously built automata (`{transitions, accepting_states}`).
  if path is not complete one or more endpoints will be guessed and `:guessed` followed by a list of endpoints is returned.
  """
  def resolve_path(path, {transitions, accepting_states}) do
    path_tokens = String.split(path, "/", trim: true)

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
  builds the automaton for given `mappings`, returns `:ok` followed by the automaton tuple if build succeeded, otherwise `:error` and the reason.
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
  returns true if `nfa` is valid for given `mappings`
  """
  def is_valid?(nfa, mappings) do
    Enum.all?(mappings, fn(mapping) ->
      resolve_path(mapping.endpoint, nfa) == {:ok, mapping.endpoint}
    end)
  end

  @doc """
  returns a list of likely invalid endpoints for a certain list of `mappings`.
  """
  def lint(mappings) do
    nfa = do_build(mappings)

    errors_list = for mapping <- mappings do
      if (resolve_path(mapping.endpoint, nfa) == {:ok, mapping.endpoint}) do
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
    next_states = List.foldl(current_states, [], fn(state, acc) ->
      transition = Map.get(transitions, {state, token})
      epsi_transition = Map.get(transitions, {state, ""})

      transition_list = if transition do
        [transition]
      else
        []
      end
      epsi_transition_list = if epsi_transition do
        [epsi_transition]
      else
        []
      end

      transition_list ++ epsi_transition_list ++ acc
    end)

    do_transitions(tail_tokens, next_states, transitions)
  end

  defp force_transitions(current_states, transitions, accepting_states) do
    next_states = List.foldl(current_states, [], fn(state, acc) ->
      good_state = if accepting_states[state] == nil do
        Enum.reduce(transitions, [], fn(transition, acc) ->
          if match?({{^state, _}, _}, transition) do
            {_, next_state} = transition
            [next_state] ++ acc
          else
            acc
          end
        end)
      else
        [state]
      end

      good_state ++ acc
    end)

    finished = Enum.all?(next_states, fn(state) ->
      accepting_states[state]
    end)

    if finished do
      next_states
    else
      force_transitions(next_states, transitions, accepting_states)
    end
  end

  defp do_build(mappings) do
    {transitions, _, accepting_states} = Enum.reduce(mappings, {%{}, [], %{}}, &parse_endpoint/2)

    {transitions, accepting_states}
  end

  def parse_endpoint(mapping, {transitions, states, accepting_states}) do
    ["" | path_tokens] =
      mapping.endpoint
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
  end

end
