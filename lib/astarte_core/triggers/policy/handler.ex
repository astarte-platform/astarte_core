#
# This file is part of Astarte.
#
# Copyright 2021 Ispirata Srl
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

defmodule Astarte.Core.Triggers.Policy.Handler do
  use Ecto.Schema
  import Ecto.Changeset
  alias Astarte.Core.Triggers.Policy
  alias Astarte.Core.Triggers.Policy.Handler
  alias Astarte.Core.Triggers.PolicyProtobuf.KeywordError, as: KeywordErrorProto
  alias Astarte.Core.Triggers.PolicyProtobuf.RangeError, as: RangeErrorProto
  alias Astarte.Core.Triggers.PolicyProtobuf.Handler, as: HandlerProto

  @required_fields [
    :on,
    :strategy
  ]

  @keyword_error_string_to_atom %{
    "any_error" => :ANY_ERROR,
    "client_error" => :CLIENT_ERROR,
    "server_error" => :SERVER_ERROR
  }
  @keyword_error_atom_to_string %{
    :ANY_ERROR => "any_error",
    :CLIENT_ERROR => "client_error",
    :SERVER_ERROR => "server_error"
  }

  @strategy_string_to_atom %{
    "discard" => :DISCARD,
    "retry" => :RETRY
  }

  @strategy_atom_to_string %{
    :DISCARD => "discard",
    :RETRY => "retry"
  }

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :on, Policy.ErrorType
    field :strategy, :string, default: "discard"
  end

  def changeset(%Handler{} = handler, params \\ %{}) do
    handler
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:strategy, Map.keys(@strategy_string_to_atom))
  end

  def error_list(%Handler{on: error_type}) do
    values =
      case error_type do
        %Policy.KeywordError{keyword: "any_error"} -> 400..599
        %Policy.KeywordError{keyword: "client_error"} -> 400..499
        %Policy.KeywordError{keyword: "server_error"} -> 500..599
        %Policy.RangeError{error_codes: errs} -> errs
        _ -> []
      end

    Enum.into(values, [])
  end

  def includes_any?(%Handler{on: error_type}, error_list) do
    Enum.any?(error_list, fn e -> includes?(error_type, e) end)
  end

  def includes?(%Handler{on: error_type}, error) do
    case {error_type, error} do
      {%Policy.KeywordError{keyword: "any_error"}, e} when e >= 400 and e <= 599 ->
        true

      {%Policy.KeywordError{keyword: "client_error"}, e} when e >= 400 and e <= 499 ->
        true

      {%Policy.KeywordError{keyword: "server_error"}, e} when e >= 500 and e <= 599 ->
        true

      {%Policy.RangeError{error_codes: codes}, e} when e >= 400 and e <= 599 ->
        Enum.member?(codes, error)

      _ ->
        false
    end
  end

  def discards?(%Handler{strategy: "discard"}) do
    true
  end

  def discards?(%Handler{}) do
    false
  end

  def to_handler_proto(%Handler{} = handler) do
    %Handler{
      on: error_type,
      strategy: strategy
    } = handler

    HandlerProto.new(
      strategy: Map.get(@strategy_string_to_atom, strategy),
      on: error_type_to_tagged_error_tuple(error_type)
    )
  end

  def from_handler_proto(%HandlerProto{} = handler_proto) do
    %HandlerProto{
      on: tagged_error_tuple,
      strategy: strategy
    } = handler_proto

    %Handler{
      on: tagged_error_tuple_to_error_type(tagged_error_tuple),
      strategy: Map.get(@strategy_atom_to_string, strategy)
    }
  end

  defp error_type_to_tagged_error_tuple(%Policy.KeywordError{keyword: keyword}) do
    {:keyword_error,
     KeywordErrorProto.new(keyword: Map.get(@keyword_error_string_to_atom, keyword))}
  end

  defp error_type_to_tagged_error_tuple(%Policy.RangeError{error_codes: codes}) do
    {:range_error, RangeErrorProto.new(error_codes: codes)}
  end

  defp tagged_error_tuple_to_error_type({_, %KeywordErrorProto{keyword: keyword}}) do
    keyword_string = Map.get(@keyword_error_atom_to_string, keyword)
    %Policy.KeywordError{keyword: keyword_string}
  end

  defp tagged_error_tuple_to_error_type({_, %RangeErrorProto{error_codes: error_codes}}) do
    %Policy.RangeError{error_codes: error_codes}
  end
end
