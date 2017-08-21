defmodule ExFormat.Unit.IndentationTest do
  import Test.Support.Unit
  use ExUnit.Case

  describe "pipeline indentation" do
    test "do not split if pipeline has no line break" do
      assert_format_string("1 |> 2 |> 3 |> 4\n")
    end

    test "split every pipe if pipeline is too long even though it has no line break" do
      bad = "input |> Some.verylongcall() |> Again.verylonglongcall() |> AgainAgain.verylonglongcall() |> AgainAgainAgain.verylonglongcall"
      good = """
      input
      |> Some.verylongcall()
      |> Again.verylonglongcall()
      |> AgainAgain.verylonglongcall()
      |> AgainAgainAgain.verylonglongcall()
      """
      assert_format_string(bad, good)
    end

    test "split every pipe if there's intended line break in pipeline" do
      good = """
      input
      |> pipe1()
      |> pipe2()
      |> pipe3()
      |> pipe4()
      """
      assert_format_string(good)

      bad = """
      input |> pipe1()
      |> pipe2() |> pipe3() |> pipe4()
      """
      assert_format_string(bad, good)

      bad = """
      input |> pipe1() |> pipe2() |> pipe3()
      |> pipe4()
      """
      assert_format_string(bad, good)

      bad = """
      input |> pipe1() |> pipe2()
      |> pipe3() |> pipe4()
      """
      assert_format_string(bad, good)
    end
  end

  describe "binary op indentation" do
    test "do not split if binary op has no line break" do
      assert_format_string """
      "The Bronze Age trumpet's" <> "tone of exile" <> "hovers over bottomlessness."
      """

      assert_format_string("[1, 2] ++ [3, 4]\n")
    end

    test "split if binary op is too long even though it has no line break" do
      bad = """
      "In the first hours of day"<>"consciousness can embrace the world" <> "just as the hand grasps a sun-warm stone."
      """
      good = """
      "In the first hours of day" <>
        "consciousness can embrace the world" <>
        "just as the hand grasps a sun-warm stone."
      """
      assert_format_string(bad, good)
    end

    test "split if binary op has intended line break" do
      bad = """
      "The traveler stands under the tree. After"
      <> "the plunge through"<> # death's whirling vortex, will
      "a great light" # unfurl over his head?
      """
      good = """
      "The traveler stands under the tree. After" <>
        "the plunge through" <> # death's whirling vortex, will
        "a great light" # unfurl over his head?
      """
      assert_format_string(bad, good)

      bad = """
      [{:prev, prev_lineno}] ++
      [{:prefix_comments, get_prefix_comments()}] ++
      [{:prefix_newline, get_prefix_newline()}] ++ curr_ctx
      """
      good = """
      [{:prev, prev_lineno}] ++
        [{:prefix_comments, get_prefix_comments()}] ++
        [{:prefix_newline, get_prefix_newline()}] ++
        curr_ctx
      """
      assert_format_string(bad, good)
    end

    test "correct indentation of multiline binary op" do
      bad = """
      "No matching message.\\n" <>
      "Process mailbox:\\n" <>
      mailbox
      """
      good = """
      "No matching message.\\n" <>
        "Process mailbox:\\n" <>
        mailbox
      """
      assert_format_string(bad, good)

      assert_format_string """

      "No matching message.\\n" <>
        "Process mailbox:\\n" <>
        mailbox
      """
    end

    test "correct indentation of binary op when assigning" do
      bad = """
      message =
        "No matching message.\\n" <>
          "Process mailbox:\\n" <>
          mailbox
      """
      good = """
      message =
        "No matching message.\\n" <>
        "Process mailbox:\\n" <>
        mailbox
      """
      assert_format_string(bad, good)
    end

    test "split every <> operator if there's line break in the operation" do
      good = """
      "test1" <>
        "test2" <>
        "test3" <>
        "test4"
      """

      bad = """
      "test1" <> "test2" <> "test3" <>
      "test4"
      """
      assert_format_string(bad, good)

      bad = """
      "test1" <> "test2" <>
      "test3" <> "test4"
      """
      assert_format_string(bad, good)

      bad = """
      "test1" <>
      "test2" <> "test3" <> "test4"
      """
      assert_format_string(bad, good)
    end

    test "split every ++ operator if there's line break in the operation" do
      good = """
      test1 ++
        test2 ++
        test3 ++
        test4
      """

      bad = """
      test1 ++ test2 ++ test3 ++
      test4
      """
      assert_format_string(bad, good)

      bad = """
      test1 ++ test2 ++
      test3 ++ test4
      """
      assert_format_string(bad, good)

      bad = """
      test1 ++
      test2 ++ test3 ++ test4
      """
      assert_format_string(bad, good)
    end

    test "split every 'and'/'or' operator if there's line break in the operation" do
      good = """
      test1 and
        test2 and
        test3 or
        test4 or
        test5
      """

      bad = """
      test1 and test2 and test3 or test4 or
      test5
      """
      assert_format_string(bad, good)

      bad = """
      test1 and test2 and
      test3 or test4 or test5
      """
      assert_format_string(bad, good)

      bad = """
      test1 and
      test2 and test3 or test4 or test5
      """
      assert_format_string(bad, good)
    end

    test "split every arithmetic operator if there's line break in the operation" do
      assert_format_string """
      Integer.floor_div(previous_year, 4) -
        Integer.floor_div(previous_year, 100) +
        Integer.floor_div(previous_year, 400) +
        previous_year *
        @days_per_nonleap_year /
        @days_per_leap_year
      """
    end
  end

  describe "'with' special form indentation" do
    test "with multiple calls" do
      bad = """
      with {:ok, date} <- Calendar.ISO.date(year, month, day),
           {:ok, time} <- Time.new(hour, minute, second, microsecond),
           do: new(date, time)
      """
      good = """
      with {:ok, date} <- Calendar.ISO.date(year, month, day),
           {:ok, time} <- Time.new(hour, minute, second, microsecond) do
        new(date, time)
      end
      """
      assert_format_string(bad, good)

      assert_format_string """
      with {year, ""} <- Integer.parse(year),
           {month, ""} <- Integer.parse(month),
           {day, ""} <- Integer.parse(day) do
        new(year, month, day)
      else
        _ ->
          {:error, :invalid_format}
      end
      """
    end

    test "with one call" do
      assert_format_string("with {:ok, date} <- Calendar.ISO.date(year, month, day), do: new(date, time)\n")

      bad = """
      with {:ok, date} <- Calendar.ISO.date(year, month, day),
      do: new(date, time)
      """
      good = """
      with {:ok, date} <- Calendar.ISO.date(year, month, day) do
        new(date, time)
      end
      """
      assert_format_string(bad, good)
    end

    test "with messy input" do
      bad = """
      with {year, ""} <- Integer.parse(year), {month, ""} <- Integer.parse(month),
      {day, ""} <- Integer.parse(day) do
        new(year, month, day)
      end
      """
      good = """
      with {year, ""} <- Integer.parse(year),
           {month, ""} <- Integer.parse(month),
           {day, ""} <- Integer.parse(day) do
        new(year, month, day)
      end
      """
      assert_format_string(bad, good)
    end
  end

  describe "'for' special form indentation" do
    test "with kw list" do
      bad = """
      for app <- apps,
        do: {app, path},
        into: %{}
      """
      good = """
      for app <- apps,
          do: {app, path},
          into: %{}
      """
      assert_format_string(bad, good)

      assert_format_string """
      for partition <- 0..partitions - 1,
          pair <- safe_lookup(registry, partition, key),
          into: [],
          do: pair
      """
    end

    test "with kw block" do
      bad = """
      for {alias, _module} <- aliases_from_env(server),
          [name] = Module.split(alias),
          starts_with?(name, hint),
          into: [] do
        %{kind: :module, type: :alias, name: name}
      end
      """
      good = """
      for {alias, _module} <- aliases_from_env(server),
          [name] = Module.split(alias),
          starts_with?(name, hint), into: [] do
        %{kind: :module, type: :alias, name: name}
      end
      """
      assert_format_string(bad, good)
    end
  end
end
