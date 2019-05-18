# TODO: finish module sort that accepts a compare func
# The default sorting algorithm on enum is merge sort.
# In our use case, the data will almost always be nearly sorted.
# Insertion sort preforms better on sets of data that are nearly sorted
# compared to merge sort.
defmodule Pageviews.Insertion do
  def sort(list, comparer) when is_list(list) do
    do_sort([], list)
  end

  defp do_sort(_sorted_list = [], _unsorted_list = [head | tail], comparer) do
    do_sort([head], tail)
  end

  defp do_sort(sorted_list, _unsorted_list = [head | tail], comparer) do
    insert(head, sorted_list) |> do_sort(tail)
  end

  defp do_sort(sorted_list, _unsorted_list = [], _comparer) do
    sorted_list
  end

  defp insert(elem, _sorted_list = [], _comparer) do
    [elem]
  end

  defp insert(elem, sorted_list) do
    [min | rest] = sorted_list

    if min >= elem do
      [elem | [min | rest]]
    else
      [min | insert(elem, rest)]
    end
  end
end
