# The default sorting algorithm on enum is merge sort.
# In our use case, the data will almost always be nearly sorted.
# Insertion sort preforms better on sets of data that are nearly sorted
# compared to merge sort.
defmodule Pageviews.Insertion do
  def sort(list, comparer) do
    do_sort([], list, comparer)
  end

  def sort(list) do
    do_sort([], list, &<=/2)
  end

  def sort(list) when not is_list(list) do
    {:error, "bad argument, should be list"}
  end

  defp do_sort(_sorted_list = [], _unsorted_list = [head | tail], comparer) do
    do_sort([head], tail, comparer)
  end

  defp do_sort(sorted_list, _unsorted_list = [head | tail], comparer) do
    insert(head, sorted_list, comparer) |> do_sort(tail, comparer)
  end

  defp do_sort(sorted_list, _unsorted_list = [], _comparer) do
    sorted_list
  end

  defp insert(elem, _sorted_list = [], _comparer) do
    [elem]
  end

  defp insert(elem, sorted_list, comparer) do
    [min | rest] = sorted_list

    if comparer.(min, elem) do
      [min | insert(elem, rest, comparer)]
    else
      [elem | [min | rest]]
    end
  end
end
