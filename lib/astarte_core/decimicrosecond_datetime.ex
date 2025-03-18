defmodule Astarte.Core.DecimicrosecondDateTime do
  defstruct [:datetime, decimicrosecond: 0]

  @type decimicrosecond :: 0..9
  @type t :: %__MODULE__{datetime: DateTime.t(), decimicrosecond: decimicrosecond()}

  def from_unix!(timestamp, unit \\ :second)

  def from_unix!(timestamp, :decimicrosecond) do
    datetime =
      timestamp
      |> div(10)
      |> DateTime.from_unix!(:microsecond)

    decimicrosecond =
      timestamp
      |> rem(10)

    %__MODULE__{datetime: datetime, decimicrosecond: decimicrosecond}
  end

  def from_unix!(timestamp, unit),
    do: %__MODULE__{datetime: DateTime.from_unix!(timestamp, unit), decimicrosecond: 0}

  def to_unix(datetime, unit \\ :second)

  def to_unix(datetime, :decimicrosecond) do
    %__MODULE__{datetime: datetime, decimicrosecond: decimicrosecond} = datetime

    datetime
    |> DateTime.to_unix(:microsecond)
    |> Kernel.*(10)
    |> Kernel.+(decimicrosecond)
  end

  def to_unix(datetime, unit), do: DateTime.to_unix(datetime.datetime, unit)

  # TODO: use actual Duration type when we update to Elixir >= 1.17
  def shift(datetime, minute: minutes) do
    %__MODULE__{datetime: datetime, decimicrosecond: decimicrosecond} = datetime
    updated_datetime = datetime |> DateTime.add(minutes, :minute)

    %__MODULE__{datetime: updated_datetime, decimicrosecond: decimicrosecond}
  end

  def compare(dt1, dt2) do
    %__MODULE__{datetime: dt1, decimicrosecond: deciusec_1} = dt1
    %__MODULE__{datetime: dt2, decimicrosecond: deciusec_2} = dt2

    with :eq <- DateTime.compare(dt1, dt2) do
      cond do
        deciusec_1 == deciusec_2 -> :eq
        deciusec_1 < deciusec_2 -> :lt
        true -> :gt
      end
    end
  end

  def diff(dt1, dt2, unit \\ :second)

  def diff(dt1, dt2, :decimicrosecond) do
    %__MODULE__{datetime: dt1, decimicrosecond: deciusec_1} = dt1
    %__MODULE__{datetime: dt2, decimicrosecond: deciusec_2} = dt2

    DateTime.diff(dt1, dt2, :microsecond) * 10 + deciusec_1 - deciusec_2
  end

  def diff(dt1, dt2, unit) do
    DateTime.diff(dt1.datetime, dt2.datetime, unit)
  end

  def after?(dt1, dt2), do: compare(dt1, dt2) == :gt
end
