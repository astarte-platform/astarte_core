defmodule Astarte.Core.InterfaceDescriptor do
  defstruct name: "",
    major_version: 0,
    minor_version: 0,
    type: nil,
    ownership: nil,
    aggregation: nil,
    has_metadata: false

  def is_valid?(interface_descriptor) do
    if ((interface_descriptor != nil) and (interface_descriptor != "") and (interface_descriptor != [])) do
      (String.length(interface_descriptor.name <> "_v" <> Integer.to_string(interface_descriptor.major_version)) < 48)
        and String.match?(interface_descriptor.name, ~r/^[a-zA-Z]+(\.[a-zA-Z0-9]+)*$/)
        and (interface_descriptor.major_version >= 0)
        and (interface_descriptor.minor_version >= 0)
        and ((interface_descriptor.major_version > 0) or (interface_descriptor.minor_version > 0))
        and ((interface_descriptor.type == :properties) or (interface_descriptor.type == :datastream))
        and ((interface_descriptor.ownership == :thing) or (interface_descriptor.ownership == :server))
        and ((interface_descriptor.aggregation == :individual) or (interface_descriptor.aggregation == :object))
    else
     false
    end
  end

end
