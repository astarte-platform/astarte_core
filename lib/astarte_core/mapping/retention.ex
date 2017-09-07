defmodule Astarte.Core.Mapping.Retention do

  @mapping_retention_discard 1
  @mapping_retention_volatile 2
  @mapping_retention_stored 3

  def to_int(retention) do
    case retention do
      :discard -> @mapping_retention_discard
      :volatile -> @mapping_retention_volatile
      :stored -> @mapping_retention_stored
    end
  end

  def from_int(retention_int) do
    case retention_int do
      @mapping_retention_discard -> :discard
      @mapping_retention_volatile -> :volatile
      @mapping_retention_stored -> :stored
    end
  end

  def from_string(retention) do
    case retention do
      "discard" -> :discard
      "volatile" -> :volatile
      "stored" -> :stored
    end
  end

end
