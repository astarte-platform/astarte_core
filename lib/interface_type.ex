defmodule AstarteCore.Interface.Type do

  @interface_type_properties 1
  @interface_type_datastream 2

  def to_int(type) do
    case type do
      :properties -> @interface_type_properties
      :datastream -> @interface_type_datastream
    end
  end

  def from_string(type) do
    case type do
      "properties" -> :properties
      "datastream" -> :datastream
    end
  end

end
