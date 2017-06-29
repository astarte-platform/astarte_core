defmodule Astarte.Core.Interface.Ownership do

  @interface_ownership_thing 1
  @interface_ownership_server 2

  def to_int(ownership) do
    case ownership do
      :thing -> @interface_ownership_thing
      :server -> @interface_ownership_server
    end
  end

  def from_string(ownership) do
    case ownership do
      "thing" -> :thing
      "server" -> :server
        # deprecated names
      "producer" -> :thing
      "consumer" -> :server
    end
  end

end
