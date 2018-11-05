defmodule SMTest do
  use ExUnit.Case
  doctest SM

  test "test string" do
    x = ~s({"type": "string", "maxLength": 5, "minLength": 1})
    val = SM.generator(x)
    schema = Poison.decode!(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test string regex" do
    x = ~s({"type": "string", "pattern": "[a-zA-Z0-9_]{5,10}@abc[.]\(org|com|in\)"})
    val = SM.generator(x)
    schema = Poison.decode!(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test integer" do
    x = ~s({"type": "integer", "maximum": 111, "minimum": -87, "multipleOf": 9})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test integer excl" do
    x =
      ~s({"type": "integer", "maximum": 120, "minimum": -87, "multipleOf": 6, "exclusiveMaximum": true})

    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test number" do
    x = ~s({"type": "number", "maximum": 7.5, "minimum": 3.6})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test number multiple" do
    x = ~s({"type": "number", "maximum": 9.7, "minimum": 3.2, "multipleOf": 1.5})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test number multiple again" do
    x = ~s({"type": "number", "maximum": 9.8, "minimum": -3.6, "multipleOf": 2})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test fraction" do
    x = ~s({"type": "number", "maximum": 9.7, "minimum": 9.65, "multipleOf": 0.04})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test fraction excl" do
    x =
      ~s({"type": "number", "maximum": 8.1, "minimum": 7.79, "multipleOf": 0.3, "exclusiveMaximum": true, "exclusiveMinimum": true})

    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test number negative" do
    x = ~s({"type": "number", "maximum": -3, "minimum": -9})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test integer enum" do
    x = ~s({"type": "integer", "enum": [30, -11, 18, 75, 99, -65, null, "abc"]})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test only enum" do
    x = ~s({"enum": [1, 2, "hello", -3, "world"]})
    val = SM.generator(x)
    schema = Poison.decode!(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test boolean" do
    x = ~s({"type": "boolean"})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test null" do
    x = ~s({"type": "null"})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end

  test "test type both integer string" do
    x = ~s({"type": ["string", "integer"], "maxLength": 5, "minLength": 1, "maximum": 29})
    schema = Poison.decode!(x)
    val = SM.generator(x)
    IO.puts(val)
    assert ExJsonSchema.Validator.valid?(schema, val)
  end
end
