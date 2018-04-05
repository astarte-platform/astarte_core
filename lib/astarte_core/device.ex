defmodule Astarte.Core.Device do
  @moduledoc """
  Utility functions to deal with Astarte devices
  """

  @doc """
  Decodes a Base64 url encoded device id and returns it as a 128-bit binary (usable as uuid).

  By default, it will fail with `{:error, :extended_id_not_allowed}` if the size of the encoded device_id is > 128 bit.
  You can pass `allow_extended_id: true` as second argument to allow longer device ids (the returned binary will still be 128 bit long, but the function will not return an error and will instead drop the extended id).

  Returns `{:ok, device_id}` or `{:error, reason}`.
  """
  def decode_device_id(encoded_device_id, opts \\ []) when is_binary(encoded_device_id) and is_list(opts) do
    allow_extended = Keyword.get(opts, :allow_extended_id, false)
    with {:ok, device_id, extended_id} <- decode_extended_device_id(encoded_device_id) do
      if not allow_extended and byte_size(extended_id) > 0 do
        {:error, :extended_id_not_allowed}
      else
        {:ok, device_id}
      end
    end
  end

  @doc """
  Decodes an extended Base64 url encoded device id.

  Returns `{:ok, device_id, extended_id}` (where `device_id` is a binary with the first 128 bits of the decoded id and `extended_id` the rest of the decoded binary) or `{:error, reason}`.
  """
  def decode_extended_device_id(encoded_device_id) when is_binary(encoded_device_id) do
    with {:ok, decoded} <- Base.url_decode64(encoded_device_id, padding: false),
         <<device_id::binary-size(16), extended_id::binary>> <- decoded do
      {:ok, device_id, extended_id}
    else
      _ ->
        {:error, :invalid_device_id}
    end
  end
end
