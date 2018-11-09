defmodule SM.Object do
  @type_list [
    %{"type" => "integer"},
    %{"type" => "number"},
    %{"type" => "boolean"},
    %{"type" => "string"},
    %{"type" => "null"},
    nil
  ]

  def gen_object(map, type), do: objectype(map, map["enum"], map["properties"])

  def objectype(map, enum, properties) when enum != nil, do: SM.gen_enum(enum, "object")

  def objectype(map, enum, properties) when is_nil(properties) and is_nil(enum) do
    list = for n <- @type_list, is_map(n), do: SM.gen_init(n)
    key = SM.gen_init(%{"type" => "string", "maxLength" => 10, "minLength" => 4})
    decide_min_max(map, key, StreamData.one_of(list), map["minProperties"], map["maxProperties"])
  end

  def decide_min_max(map, key, value, min, max)
      when is_integer(min) and is_integer(max) and min < max do
    StreamData.map_of(key, value, min_length: min, max_length: max)
  end

  def decide_min_max(map, key, value, min, max) when is_integer(min) and is_nil(max) do
    StreamData.list_of(key, value, min_length: min)
  end

  def decide_min_max(map, key, value, min, max) when is_nil(min) and is_integer(max) do
    StreamData.list_of(key, value, max_length: max)
  end

  def decide_min_max(map, key, value, min, max) when is_nil(min) and is_nil(max) do
    StreamData.map_of(key, value)
  end
end
