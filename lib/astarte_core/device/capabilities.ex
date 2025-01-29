#
# This file is part of Astarte.
#
# Copyright 2025 SECO Mind Srl
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
# SPDX-License-Identifier: Apache-2.0
#

defmodule Astarte.Core.Device.Capabilities do
  use Ecto.Schema
  import Ecto.Changeset

  alias Astarte.Core.Device.Capabilities

  @required_fields []

  @permitted_fields [:purge_properties_compression_format] ++ @required_fields

  @primary_key false
  embedded_schema do
    field :purge_properties_compression_format, Ecto.Enum,
      values: [zlib: 0, plaintext: 1],
      default: :zlib
  end

  def changeset(%Capabilities{} = capabilities, params \\ %{}) do
    capabilities
    |> cast(params, @permitted_fields)
    |> validate_required(@required_fields)
  end
end
