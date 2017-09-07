defmodule Astarte.Core.Interface.Aggregation do

  @interface_aggregation_individual 1
  @interface_aggregation_object 2

  def to_int(aggregation) do
    case aggregation do
      :individual -> @interface_aggregation_individual
      :object -> @interface_aggregation_object
    end
  end

  def from_int(aggregation_int) do
    case aggregation_int do
      @interface_aggregation_individual -> :individual
      @interface_aggregation_object -> :object
    end
  end

  def from_string(aggregation) do
    case aggregation do
      "individual" -> :individual
      "object" -> :object
    end
  end

end
