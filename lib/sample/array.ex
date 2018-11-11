defmodule SM.Array do
  @type_list [
    %{"type" => "integer"},
    %{"type" => "number"},
    %{"type" => "boolean"},
    %{"type" => "string"},
    %{"type" => "null"},
    nil
  ]

  @min_items 0

  @max_items 1000

  def gen_array(map, type), do: arraytype(map, map["enum"], map["items"])

  def arraytype(map, enum, items) when enum != nil, do: SM.gen_enum(enum, "array")

  def arraytype(map, enum, items) when is_list(items) or is_map(items) do
    list =
      if is_list(items) do
        for n <- items, is_map(n), do: SM.gen_init(n)
      else
        [SM.gen_init(items)]
      end

    {min, max} = get_min_max(map)

    case map["additionalItems"] do
      x when (is_boolean(x) and x) or is_nil(x) ->
        add_additional_items(list, true, max, min)

      x when is_map(x) ->
        add_additional_items(list, x, max, min)

      _ ->
        add_additional_items(list, false, max, min)
    end
  end

  def get_min_max(map) do
    min =
      if map["minItems"] do
        min = map["minItems"]
      else
        min = @min_items
      end

    max =
      if map["maxItems"] do
        max = map["maxItems"]
      else
        max = @max_items
      end

    {min, max}
  end

  def arraytype(map, enum, items) when is_nil(items) and is_nil(enum) do
    item = get_one_of()
    {min, max} = get_min_max(map)
    decide_min_max(map, item, min, max)
  end

  def decide_min_max(map, item, min, max)
      when is_integer(min) and is_integer(max) and min < max do
    if map["uniqueItems"] do
      StreamData.uniq_list_of(item, min_length: min, max_length: max)
    else
      StreamData.list_of(item, min_length: min, max_length: max)
    end
  end

  def check_bounds(list, max, min) do
    case {min, max} do
      {x, y} when is_nil(x) and is_nil(y) ->
        true

      {x, y} when is_nil(x) and is_integer(y) and length(list) <= y ->
        true

      {x, y} when is_integer(x) and is_nil(y) and length(list) >= x ->
        true

      {x, y} when is_integer(x) and is_integer(y) and length(list) >= x and length(list) <= y ->
        true

      _ ->
        false
    end
  end

  def get_one_of() do
    for(n <- @type_list, is_map(n), do: SM.gen_init(n)) |> StreamData.one_of()
  end

  def add_additional_items(list, bool, max, min) when is_boolean(bool) and bool do
    generate_list(list, get_one_of(), max, min)
  end

  def add_additional_items(list, bool, max, min) when is_boolean(bool) and not bool do
    if check_bounds(list, max, min) do
      StreamData.fixed_list(list)
    end
  end

  def add_additional_items(list, map, max, min) when is_map(map) do
    generate_list(list, SM.gen_init(map), max, min)
  end

  def generate_list(olist, additional, max, min) do
    StreamData.bind(StreamData.fixed_list(olist), fn list ->
      StreamData.bind_filter(
        StreamData.list_of(additional),
        fn
          nlist
          when (length(list) + length(nlist)) in min..max ->
            {:cont, StreamData.constant(list ++ nlist)}

          nlist
          when length(list) in min..max ->
            {:cont, StreamData.constant(list)}

          nlist when true ->
            :skip
        end
      )
    end)
  end
end
