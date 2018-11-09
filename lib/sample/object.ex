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

  def objectype(map, enum, properties) when is_map(properties) do
    new_prop = for {k, v} <- properties, into: %{}, do: {k, SM.gen_init(v)}

    req =
      if map["required"] do
        for n <- map["required"], into: %{}, do: {n, Map.get(new_prop, n)}
      end

    if Map.size(req) == 0 do
      check_additional_properties(map, 0, req, new_prop)
    else
      check_additional_properties(map, Map.size(req), req, new_prop)
    end
  end

  def check_additional_properties(map, req_size, req, new_prop) when req_size == 0 do
    case map["additionalProperties"] do
      x when is_nil(x) or (is_boolean(x) and x) ->
        additional = objectype(map, nil, nil)
        StreamData.one_of([StreamData.optional_map(new_prop), additional])

      x when is_boolean(x) and not x ->
        StreamData.optional_map(new_prop)

      x when is_map(x) ->
        obj = SM.gen_init(x)
        StreamData.one_of([StreamData.optional_map(new_prop), obj])
    end
  end

  def check_additional_properties(map, req_size, req, new_prop) when req_size > 0 do
    case map["additionalProperties"] do
      x when is_nil(x) or (is_boolean(x) and x) ->
        additional = objectype(map, nil, nil)
        add_dict = Map.merge(new_prop, %{"additionalProperties" => additional})

        StreamData.one_of([
          StreamData.fixed_map(req),
          StreamData.fixed_map(new_prop),
          StreamData.fixed_map(add_dict)
        ])

      x when is_boolean(x) and not x ->
        StreamData.one_of([StreamData.fixed_map(req), StreamData.fixed_map(new_prop)])

      x when is_map(x) ->
        obj = SM.gen_init(x)
        add_dict = Map.merge(new_prop, %{"additionalProperties" => obj})
        StreamData.one_of([StreamData.fixed_map(req), StreamData.fixed_map(new_prop), add_dict])
    end
  end

  def decide_min_max(map, key, value, min, max)
      when is_integer(min) and is_integer(max) and min < max do
    StreamData.map_of(key, value, min_length: min, max_length: max)
  end

  def decide_min_max(map, key, value, min, max) when is_integer(min) and is_nil(max) do
    StreamData.map_of(key, value, min_length: min)
  end

  def decide_min_max(map, key, value, min, max) when is_nil(min) and is_integer(max) do
    StreamData.map_of(key, value, max_length: max)
  end

  def decide_min_max(map, key, value, min, max) when is_nil(min) and is_nil(max) do
    StreamData.map_of(key, value)
  end
end
