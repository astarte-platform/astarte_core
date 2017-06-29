defmodule Astarte.Core.Mapping do
  defstruct endpoint: "",
    value_type: nil,
    reliability: nil,
    retention: nil,
    expiry: 0,
    allow_unset: false
end
