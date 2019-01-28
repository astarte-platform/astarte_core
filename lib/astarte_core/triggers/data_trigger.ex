#
# This file is part of Astarte.
#
# Copyright 2017 Ispirata Srl
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

defmodule Astarte.Core.Triggers.DataTrigger do
  @enforce_keys [:trigger_targets]
  defstruct [
    :interface_id,
    :path_match_tokens,
    :value_match_operator,
    :known_value,
    :trigger_targets
  ]

  def are_congruent?(trigger_a, trigger_b) do
    trigger_a.interface_id == trigger_b.interface_id and
      trigger_a.path_match_tokens == trigger_b.path_match_tokens and
      trigger_a.value_match_operator == trigger_b.value_match_operator and
      trigger_a.known_value == trigger_b.known_value
  end
end
