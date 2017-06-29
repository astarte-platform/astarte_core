defmodule Astarte.Core.Mapping.Reliability do

  @mapping_reliability_unreliable 1
  @mapping_reliability_guaranteed 2
  @mapping_reliability_unique 3

  def to_int(reliability) do
    case reliability do
      :unreliable -> @mapping_reliability_unreliable
      :guaranteed -> @mapping_reliability_guaranteed
      :unique -> @mapping_reliability_unique
    end
  end

  def from_string(reliability) do
    case reliability do
      "unreliable" -> :unreliable
      "guaranteed" -> :guaranteed
      "unique" -> :unique
    end
  end

end
