#
# This file is part of Astarte.
#
# Copyright 2017-2018 Ispirata Srl
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

defmodule Astarte.Core.Mapping.ValueType do
  use Ecto.Type

  @mapping_value_type_double 1
  @mapping_value_type_doublearray 2
  @mapping_value_type_integer 3
  @mapping_value_type_integerarray 4
  @mapping_value_type_longinteger 5
  @mapping_value_type_longintegerarray 6
  @mapping_value_type_string 7
  @mapping_value_type_stringarray 8
  @mapping_value_type_boolean 9
  @mapping_value_type_booleanarray 10
  @mapping_value_type_binaryblob 11
  @mapping_value_type_binaryblobarray 12
  @mapping_value_type_datetime 13
  @mapping_value_type_datetimearray 14
  @valid_atoms [
    :double,
    :integer,
    :boolean,
    :longinteger,
    :string,
    :binaryblob,
    :datetime,
    :doublearray,
    :integerarray,
    :booleanarray,
    :longintegerarray,
    :stringarray,
    :binaryblobarray,
    :datetimearray
  ]

  # The following limits are really conservative,
  # it is always easier to increase them in future releases
  @blob_size 65536
  @list_len 1024
  @string_size 65536

  @impl true
  def type, do: :integer

  @impl true
  def cast(nil), do: {:ok, nil}

  def cast(atom) when is_atom(atom) do
    if Enum.member?(@valid_atoms, atom) do
      {:ok, atom}
    else
      :error
    end
  end

  def cast(string) when is_binary(string) do
    case string do
      "double" -> {:ok, :double}
      "integer" -> {:ok, :integer}
      "boolean" -> {:ok, :boolean}
      "longinteger" -> {:ok, :longinteger}
      "string" -> {:ok, :string}
      "binaryblob" -> {:ok, :binaryblob}
      "datetime" -> {:ok, :datetime}
      "doublearray" -> {:ok, :doublearray}
      "integerarray" -> {:ok, :integerarray}
      "booleanarray" -> {:ok, :booleanarray}
      "longintegerarray" -> {:ok, :longintegerarray}
      "stringarray" -> {:ok, :stringarray}
      "binaryblobarray" -> {:ok, :binaryblobarray}
      "datetimearray" -> {:ok, :datetimearray}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @impl true
  def dump(value_type) when is_atom(value_type) do
    case value_type do
      :double -> {:ok, @mapping_value_type_double}
      :integer -> {:ok, @mapping_value_type_integer}
      :boolean -> {:ok, @mapping_value_type_boolean}
      :longinteger -> {:ok, @mapping_value_type_longinteger}
      :string -> {:ok, @mapping_value_type_string}
      :binaryblob -> {:ok, @mapping_value_type_binaryblob}
      :datetime -> {:ok, @mapping_value_type_datetime}
      :doublearray -> {:ok, @mapping_value_type_doublearray}
      :integerarray -> {:ok, @mapping_value_type_integerarray}
      :booleanarray -> {:ok, @mapping_value_type_booleanarray}
      :longintegerarray -> {:ok, @mapping_value_type_longintegerarray}
      :stringarray -> {:ok, @mapping_value_type_stringarray}
      :binaryblobarray -> {:ok, @mapping_value_type_binaryblobarray}
      :datetimearray -> {:ok, @mapping_value_type_datetimearray}
      _ -> :error
    end
  end

  def to_int(value_type) when is_atom(value_type) do
    case dump(value_type) do
      {:ok, int} -> int
      :error -> raise ArgumentError, message: "#{inspect(value_type)} is not a valid value type"
    end
  end

  @impl true
  def load(value_type_int) when is_integer(value_type_int) do
    case value_type_int do
      @mapping_value_type_double -> {:ok, :double}
      @mapping_value_type_integer -> {:ok, :integer}
      @mapping_value_type_boolean -> {:ok, :boolean}
      @mapping_value_type_longinteger -> {:ok, :longinteger}
      @mapping_value_type_string -> {:ok, :string}
      @mapping_value_type_binaryblob -> {:ok, :binaryblob}
      @mapping_value_type_datetime -> {:ok, :datetime}
      @mapping_value_type_doublearray -> {:ok, :doublearray}
      @mapping_value_type_integerarray -> {:ok, :integerarray}
      @mapping_value_type_booleanarray -> {:ok, :booleanarray}
      @mapping_value_type_longintegerarray -> {:ok, :longintegerarray}
      @mapping_value_type_stringarray -> {:ok, :stringarray}
      @mapping_value_type_binaryblobarray -> {:ok, :binaryblobarray}
      @mapping_value_type_datetimearray -> {:ok, :datetimearray}
      _ -> :error
    end
  end

  def from_int(value_type_int) when is_integer(value_type_int) do
    case load(value_type_int) do
      {:ok, value_type} ->
        value_type

      :error ->
        raise ArgumentError,
          message: "#{value_type_int} is not a valid value type int representation"
    end
  end

  def validate_value(expected_type, value) do
    case {value, expected_type} do
      {v, :double} when is_number(v) ->
        :ok

      {v, :integer} when is_integer(v) and abs(v) <= 0x7FFFFFFF ->
        :ok

      {v, :boolean} when is_boolean(v) ->
        :ok

      {v, :longinteger} when is_integer(v) and abs(v) <= 0x7FFFFFFFFFFFFFFF ->
        :ok

      {v, :string} when is_binary(v) ->
        cond do
          String.valid?(v) == false ->
            {:error, :unexpected_value_type}

          byte_size(v) > @string_size ->
            {:error, :value_size_exceeded}

          true ->
            :ok
        end

      {v, :binaryblob} when is_binary(v) ->
        if byte_size(v) > @blob_size do
          {:error, :value_size_exceeded}
        else
          :ok
        end

      {{_subtype, bin}, :binaryblob} when is_binary(bin) ->
        if byte_size(bin) > @blob_size do
          {:error, :value_size_exceeded}
        else
          :ok
        end

      {%DateTime{} = _v, :datetime} ->
        :ok

      {v, :datetime} when is_integer(v) ->
        :ok

      {v, :doublearray} when is_list(v) ->
        validate_array_value(:double, v)

      {v, :integerarray} when is_list(v) ->
        validate_array_value(:integer, v)

      {v, :booleanarray} when is_list(v) ->
        validate_array_value(:boolean, v)

      {v, :longintegerarray} when is_list(v) ->
        validate_array_value(:longinteger, v)

      {v, :stringarray} when is_list(v) ->
        validate_array_value(:string, v)

      {v, :binaryblobarray} when is_list(v) ->
        validate_array_value(:binaryblob, v)

      {v, :datetimearray} when is_list(v) ->
        validate_array_value(:datetime, v)

      _ ->
        {:error, :unexpected_value_type}
    end
  end

  defp validate_array_value(type, values) do
    cond do
      length(values) > @list_len ->
        {:error, :value_size_exceeded}

      Enum.all?(values, fn item -> validate_value(type, item) == :ok end) == false ->
        {:error, :unexpected_value_type}

      true ->
        :ok
    end
  end
end
