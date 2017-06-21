defmodule AstarteCore.Mapping.ValueType do

  @mapping_value_type_integer 1
  @mapping_value_type_integer64 2
  @mapping_value_type_string 3
  @mapping_value_type_boolean 4
  @mapping_value_type_datetime 5

  def to_int(value_type) do
    case value_type do
      :integer -> @mapping_value_type_integer
      :integer64 -> @mapping_value_type_integer64
      :string -> @mapping_value_type_string
      :boolean -> @mapping_value_type_boolean
      :datetime -> @mapping_value_type_datetime
    end
  end

  def from_string(value_type) do
    case value_type do
      "integer" -> :integer
      "integer64" -> :integer64
      "string" -> :string
      "boolean" -> :boolean
      "datetime" -> :datetime
    end
  end

end
