defmodule C3 do
  def list_len(list) do
    list_len(0, list)
  end

  defp list_len(cur, []) do
    cur
  end

  defp list_len(cur, [_head | tail]) do
    new_len = cur + 1
    list_len(new_len, tail)
  end

  def list_len_reduce(list) do
    Enum.reduce(list, 0, fn _elem, len -> len + 1 end)
  end

  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.filter(&(String.length(&1) > 200))
  end

  def lines_length!(path) do
    list = []

    File.stream!(path)
    |> Stream.map(&count(&1, list))
    |> Enum.take(10)
    |> Enum.with_index()
    |> List.flatten()
  end

  defp count(line, list) do
    [String.length(line) | list]
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.length(&1))
    |> Enum.to_list()
    |> Enum.sort(&>/2)
    |> Enum.fetch(0)
  end

  def longest_line_length_optimized!(path) do
    File.open!(path)
    |> IO.read(:all)
    |> String.split("\n")
    |> Enum.map(&String.length(&1))
    |> Enum.max()
  end

  def longest_line!(path) do
    File.open!(path)
    |> IO.read(:all)
    |> String.split("\n")
    |> Enum.map(&{String.length(&1), &1})
    |> Enum.max_by(&elem(&1, 0))
  end

  def words_per_line!(path) do
    File.open!(path, [:utf8])
    |> IO.read(:all)
    |> String.split("\n")
    |> Enum.map(&length(String.split(&1)))
  end
end
