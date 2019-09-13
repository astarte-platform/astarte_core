#
# This file is part of Astarte.
#
# Copyright 2019 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Core.Group do
  @moduledoc """
  Functions that deal with Astarte groups
  """

  @group_name_regex ~r<^(astarte|interface|interfaces|devices|query|realm|triggers)[-:/_.@$]>

  @doc """
  Returns true if `group_name` is a valid group name, false otherwise.

  Valid group names _do not_ match this regular expression: `#{inspect(@group_name_regex)}`
  """
  def valid_name?("") do
    false
  end

  def valid_name?(group_name) do
    not String.match?(group_name, @group_name_regex)
  end
end
