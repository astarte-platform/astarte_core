#
# Copyright (C) 2017 Ispirata Srl
#
# This file is part of Astarte.
# Astarte is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Astarte is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Astarte.  If not, see <http://www.gnu.org/licenses/>.
#

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
