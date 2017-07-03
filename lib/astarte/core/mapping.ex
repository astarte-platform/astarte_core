defmodule Astarte.Core.Mapping do
  defstruct endpoint: "",
    value_type: nil,
    reliability: nil,
    retention: nil,
    expiry: 0,
    allow_unset: false

  def is_valid?(mapping) do
    if ((mapping != nil) and (mapping != "") and (mapping != [])) do
      String.match?(mapping.endpoint, ~r/^((\/%{[a-zA-Z]+[a-zA-Z0-9]*})*(\/[a-zA-Z]+[a-zA-Z0-9]*)*)+$/)
        and (mapping.value_type != nil)
        and is_atom(mapping.value_type)
    else
      false
    end
  end
end
