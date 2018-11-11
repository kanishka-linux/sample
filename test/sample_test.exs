defmodule SMTest do
  use ExUnit.Case
  doctest SM

  def test_generator(jschema) do
    gen = SM.generator(jschema)
    schema = Poison.decode!(jschema)
    #IO.inspect(Enum.take(gen, 3))

    Enum.take(gen, 100)
    |> Enum.each(fn val -> ExJsonSchema.Validator.valid?(schema, val) end)
  end

  test "test anyOf" do
    jschema = ~s({"anyOf": [{"type": "object"}, {"type": "array"}]})
    assert test_generator(jschema)
  end

  test "test object with no properties" do
    jschema = ~s({"type": "object"})
    assert test_generator(jschema)
  end

  test "test object with properties" do
    jschema =
      ~s({"type": "object", "properties": {"name":{"type":"string", "maxLength": 10}, "age":{"type": "integer", "minimum": 1, "maximum": 125}}, "required":["name", "age"]})

    assert test_generator(jschema)
  end

  test "test object with properties minmax" do
    jschema =
      ~s({"type": "object", "properties": {"name":{"type":"string", "maxLength": 10}, "age":{"type": "integer", "minimum": 1, "maximum": 125}}, "additionalProperties": {"type": "integer"}, "minProperties":1, "maxProperties": 50})

    assert test_generator(jschema)
  end

  test "test object with properties required" do
    jschema =
      ~s({"type": "object", "properties": {"name":{"type":"string", "maxLength": 10}, "age":{"type": "integer", "minimum": 1, "maximum": 125}}, "additionalProperties": false, "minProperties":1, "maxProperties": 5, "required": ["age", "name"]})

    assert test_generator(jschema)
  end

  test "test object with additional properties and required" do
    jschema =
      ~s({"type": "object", "properties": {"name":{"type":"string", "maxLength": 10}, "age":{"type": "integer", "minimum": 1, "maximum": 125}}, "additionalProperties": {"type": "integer"}, "minProperties":2, "maxProperties": 5, "required": ["age"]})

    assert test_generator(jschema)
  end

  test "test array items" do
    jschema =
      ~s({"type": "array", "items" : [{"type": "integer"}, {"type": "string", "maxLength": 10}, {"type": "boolean"}], "additionalItems": {"type": "boolean"} })

    assert test_generator(jschema)
  end

  test "test array item with bounds" do
    jschema =
      ~s({"type": "array", "items" : {"type": "string", "maxLength": 10, "minLength":5}, "minItems": 1, "maxItems": 100 })

    assert test_generator(jschema)
  end

  test "test array single item" do
    jschema =
      ~s({"type": "array", "items" : {"type": "string", "maxLength": 10}, "additionalItems":true})

    assert test_generator(jschema)
  end

  test "test string" do
    jschema = ~s({"type": "string", "maxLength": 5, "minLength": 1})
    assert test_generator(jschema)
  end

  test "test string regex" do
    jschema = ~s({"type": "string", "pattern": "[a-zA-Z0-9_]{5,10}@abc[.]\(org|com|in\)"})
    assert test_generator(jschema)
  end

  test "test integer" do
    jschema = ~s({"type": "integer", "maximum": 111, "minimum": -87, "multipleOf": 9})
    assert test_generator(jschema)
  end

  test "test integer excl" do
    jschema =
      ~s({"type": "integer", "maximum": 120, "minimum": -87, "multipleOf": 6, "exclusiveMaximum": true})

    assert test_generator(jschema)
  end

  test "test number" do
    jschema = ~s({"type": "number", "maximum": 7.5, "minimum": 3.6})
    assert test_generator(jschema)
  end

  test "test number multiple" do
    jschema = ~s({"type": "number", "maximum": 9.7, "minimum": 3.2, "multipleOf": 1.5})
    assert test_generator(jschema)
  end

  test "test number multiple again" do
    jschema = ~s({"type": "number", "maximum": 9.8, "minimum": -3.6, "multipleOf": 2})
    assert test_generator(jschema)
  end

  test "test fraction" do
    jschema = ~s({"type": "number", "maximum": 9.7, "minimum": 9.65, "multipleOf": 0.04})
    assert test_generator(jschema)
  end

  test "test fraction excl" do
    jschema =
      ~s({"type": "number", "maximum": 8.1, "minimum": 7.79, "multipleOf": 0.3, "exclusiveMaximum": true, "exclusiveMinimum": true})

    assert test_generator(jschema)
  end

  test "test number negative" do
    jschema = ~s({"type": "number", "maximum": -3, "minimum": -9})
    assert test_generator(jschema)
  end

  test "test integer enum" do
    jschema = ~s({"type": "integer", "enum": [30, -11, 18, 75, 99, -65, null, "abc"]})
    assert test_generator(jschema)
  end

  test "test only enum" do
    jschema = ~s({"enum": [1, 2, "hello", -3, "world"]})
    assert test_generator(jschema)
  end

  test "test boolean" do
    jschema = ~s({"type": "boolean"})
    assert test_generator(jschema)
  end

  test "test null" do
    jschema = ~s({"type": "null"})
    assert test_generator(jschema)
  end

  test "test notype" do
    jschema = ~s({"maxLength": 20, "minLength": 10, "minItems": 3})
    assert test_generator(jschema)
  end

  test "test type both integer string" do
    jschema = ~s({"type": ["string", "integer"], "maxLength": 5, "minLength": 1, "maximum": 29})
    assert test_generator(jschema)
  end
end
