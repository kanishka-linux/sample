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

    non_req =
      if is_map(req) and map_size(req) > 0 do
        for {k, v} <- new_prop, req[k] == nil, into: %{}, do: {k, v}
      end

    if is_nil(req) or map_size(req) == 0 do
      check_additional_properties(map, 0, req, non_req, new_prop)
    else
      check_additional_properties(map, Map.size(req), req, non_req, new_prop)
    end
  end

  def bind_function(new_prop, additional, y, z) do
    StreamData.bind(StreamData.optional_map(new_prop), fn mapn ->
      StreamData.bind(
        additional,
        fn
          nmap
          when (not is_nil(y) and map_size(mapn) + map_size(nmap) < y) or
                 (not is_nil(z) and map_size(mapn) + map_size(nmap) > z) ->
            StreamData.constant(%{})

          nmap when is_map(nmap) ->
            StreamData.constant(Map.merge(mapn, nmap))
        end
      )
    end)
  end

  def bind_function_req(req, non_req, y, z) when is_map(non_req) or is_nil(non_req) do
    StreamData.bind(
      StreamData.fixed_map(req),
      fn
        mapn when is_map(non_req) ->
          StreamData.bind(StreamData.optional_map(non_req), fn
            nmap
            when not is_nil(y) and map_size(mapn) + map_size(nmap) >= y and
                   (not is_nil(z) and map_size(mapn) + map_size(nmap) <= z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when is_nil(y) and (not is_nil(z) and map_size(mapn) + map_size(nmap) <= z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when not is_nil(y) and map_size(mapn) + map_size(nmap) >= y and is_nil(z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when is_nil(y) and is_nil(z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap when true ->
              StreamData.constant(%{})
          end)

        mapn
        when is_nil(non_req) and
               ((not is_nil(y) and map_size(mapn) < y) or (not is_nil(z) and map_size(mapn) > z)) ->
          StreamData.constant(%{})

        mapn when is_nil(non_req) ->
          StreamData.constant(mapn)
      end
    )
  end

  def bind_function_req(req, non_req, y, z, add) when not is_nil(non_req) do
    StreamData.bind(
      StreamData.fixed_map(req),
      fn
        mapn when is_map(non_req) ->
          StreamData.bind(non_req, fn
            nmap
            when not is_nil(y) and map_size(mapn) + map_size(nmap) >= y and
                   (not is_nil(z) and map_size(mapn) + map_size(nmap) <= z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when is_nil(y) and (not is_nil(z) and map_size(mapn) + map_size(nmap) <= z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when not is_nil(y) and map_size(mapn) + map_size(nmap) >= y and is_nil(z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap
            when is_nil(y) and is_nil(z) ->
              StreamData.constant(Map.merge(mapn, nmap))

            nmap when true ->
              StreamData.constant(%{})
          end)
      end
    )
  end

  def check_additional_properties(map, req_size, req, non_req, new_prop)
      when is_nil(req) or req_size == 0 do
    case {map["additionalProperties"], map["minProperties"], map["maxProperties"]} do
      {x, y, z} when is_nil(x) or (is_boolean(x) and x) ->
        additional = objectype(map, nil, nil)
        bind_function(new_prop, additional, y, z)

      {x, y, z} when is_boolean(x) and not x ->
        StreamData.bind(
          StreamData.optional_map(new_prop),
          fn
            map
            when (not is_nil(y) and map_size(map) < y) or (not is_nil(z) and map_size(map) > z) ->
              StreamData.constant(%{})

            map when true ->
              StreamData.constant(map)
          end
        )

      {x, y, z} when is_map(x) ->
        obj = SM.gen_init(x)
        key = SM.gen_init(%{"type" => "string", "maxLength" => 10, "minLength" => 4})
        bind_function(new_prop, StreamData.map_of(key, obj), y, z)
    end
  end

  def check_additional_properties(map, req_size, req, non_req, new_prop) when req_size > 0 do
    case {map["additionalProperties"], map["minProperties"], map["maxProperties"]} do
      {x, y, z} when is_nil(x) or (is_boolean(x) and x) ->
        additional = objectype(map, nil, nil)
        val2 = bind_function(non_req, additional, y, z)
        bind_function_req(req, val2, y, z, "additional")

      {x, y, z} when is_boolean(x) and not x ->
        bind_function_req(req, non_req, y, z)

      {x, y, z} when is_map(x) ->
        obj = SM.gen_init(x)
        key = SM.gen_init(%{"type" => "string", "maxLength" => 10, "minLength" => 4})
        val1 = decide_min_max(map, key, obj, y, z)
        val2 = bind_function(non_req, val1, y, z)
        bind_function_req(req, val2, y, z, "additional")
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
