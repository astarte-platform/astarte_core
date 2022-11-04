#
# This file is part of Astarte.
#
# Copyright 2022 SECO Mind srl
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

defmodule Astarte.Core.Triggers.Policy.ErrorKeyword do
  use Ecto.Schema
  import Ecto.Changeset

  @on_constants [
    "client_error",
    "server_error",
    "any_error"
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :keyword, :string
  end

  def validate(changeset) do
    validate_inclusion(changeset, :keyword, @on_constants)
  end
end
