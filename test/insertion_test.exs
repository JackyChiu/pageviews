defmodule PageviewsInsertionTest do
  use ExUnit.Case
  alias Pageviews.Insertion

  test "insertion sort with unsorted list" do
    list = [1, 2, 100, 3, 4, 1, 200, 45, 6, 10]
    expected = [1, 1, 2, 3, 4, 6, 10, 45, 100, 200]
    assert(expected == Insertion.sort(list))
  end

  test "insertion sort with sorted list" do
    list = [1, 1, 2, 3, 4, 6, 10, 45, 100, 200]
    expected = [1, 1, 2, 3, 4, 6, 10, 45, 100, 200]
    assert(expected == Insertion.sort(list))
  end

  test "insertion sort with comparer" do
    list = [1, 2, 100, 3, 4, 1, 200, 45, 6, 10]
    expected = [200, 100, 45, 10, 6, 4, 3, 2, 1, 1]
    assert(expected == Insertion.sort(list, &>/2))
  end
end
