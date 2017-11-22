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

defmodule Astarte.Core.Triggers.SimpleTriggersProtobuf do
  @external_resource Path.expand("simple_triggers_protobuf", __DIR__)

  use Protobuf, from: Path.wildcard(Path.expand("simple_triggers_protobuf/*.proto", __DIR__))

  @doc """
  Utility macro, `use Astarte.Core.Triggers.SimpleTriggersProtobuf` injects aliases
  for all the structs defined in the `Astarte.Core.Triggers.SimpleTriggersProtobuf`
  namespace
  """
  defmacro __using__(_opts) do
    for {{:msg, msg_module}, _} <- __MODULE__.defs() do
      quote do
        alias unquote(msg_module)
      end
    end
  end
end
