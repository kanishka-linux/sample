defmodule SMTest do
  use ExUnit.Case
  doctest SM

  test "test string" do
    x = ~s({"type": "string", "maxLength": 5, "minLength": 1})
    val = SM.generator(x)
    IO.puts val
    assert String.length(val) >=1 and String.length(val) <= 5
  end
  
  test "test string regex" do
    x = ~s({"type": "string", "pattern": "[a-zA-Z0-9_]{5,10}@abc[.]\(org|com|in\)"})
    val = SM.generator(x)
    IO.puts val
    assert Regex.match?(~r/[a-zA-Z0-9_]{5,10}@abc[.](org|com|in)/, val)
  end
  
  test "test integer" do
    x = ~s({"type": "integer", "maximum": 111, "minimum": -87, "multipleOf": 9})
    val = SM.generator(x)
    IO.puts val
    assert val >= -87 and val <= 111 and rem(val, 9) == 0
  end
  
  test "test integer excl" do
    x = ~s({"type": "integer", "maximum": 120, "minimum": -87, "multipleOf": 6, "exclusiveMaximum": true})
    val = SM.generator(x)
    IO.puts val
    assert val >= -87 and val < 120 and rem(val, 6) == 0
  end
  
  test "test number" do
    x = ~s({"type": "number", "maximum": 7.5, "minimum": 3.6})
    val = SM.generator(x)
    IO.puts val
    assert val >= 3.6 and val <=7.5
  end
  
  test "test number multiple" do
    x = ~s({"type": "number", "maximum": 9.7, "minimum": 3.2, "multipleOf": 1.5})
    val = SM.generator(x)
    IO.puts val
    assert val >= 3.2 and val <= 9.7
  end
  
  test "test number multiple again" do
    x = ~s({"type": "number", "maximum": 9, "minimum": -3, "multipleOf": 2})
    val = SM.generator(x)
    IO.puts val
    assert val >= -3 and val <= 9
  end
  
  test "test number negative" do
    x = ~s({"type": "number", "maximum": -3.2, "minimum": -9.7})
    val = SM.generator(x)
    IO.puts val
    assert val >= -9.7 and val <= -3.2
  end
  
  test "test integer enum" do
    x = ~s({"type": "integer", "enum": [30, -11, 18, 75, 99, -65, null, "abc"]})
    val = SM.generator(x)
    IO.puts val
    assert val in [30, -11, 18, 75, 99, -65]
  end
  
  test "test only enum" do
    x = ~s({"enum": [1, 2, "hello", -3, "world"]})
    val = SM.generator(x)
    IO.puts val
    assert val in [1, 2, "hello", -3, "world"]
  end
  
  test "test boolean" do
    x = ~s({"type": "boolean"})
    val = SM.generator(x)
    IO.puts val
    assert val in [true, false]
  end
  
  test "test null" do
    x = ~s({"type": "null"})
    val = SM.generator(x)
    IO.puts val
    assert val == "null"
  end
  
  test "test type both integer string" do
    x = ~s({"type": ["string", "integer"], "maxLength": 5, "minLength": 1})
    val = SM.generator(x)
    IO.puts val
    cond do
        is_binary(val) ->
            assert String.length(val) >=1 and String.length(val) <= 5
        is_integer(val) ->
            assert true
    end
  end
  
end
