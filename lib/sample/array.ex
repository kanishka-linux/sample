defmodule SM.Array do
  @type_list [
    %{"type" => "integer"},
    %{"type" => "number"},
    %{"type" => "boolean"},
    %{"type" => "string"},
    %{"type" => "null"},
    nil
  ]

  def gen_array(map, type), do: arraytype(map, map["enum"], map["items"])

  def arraytype(map, enum, items) when enum != nil, do: SM.gen_enum(enum, "array")

  def arraytype(map, enum, items) when is_map(items) do
    item = SM.gen_init(items)
    decide_min_max(map, item, map["minItems"], map["maxItems"])
  end

  def arraytype(map, enum, items) when is_list(items) do
    list = for n <- items, is_map(n), do: SM.gen_init(n)

    case map["additionalItems"] do
      x when (is_boolean(x) and x) or is_nil(x) ->
        add_additional_items(list, true, map["maxItems"], map["minItems"])

      x when is_map(x) ->
        add_additional_items(list, x, map["maxItems"], map["minItems"])

      _ ->
        add_additional_items(list, false, map["maxItems"], map["minItems"])
    end
  end

  def arraytype(map, enum, items) when is_nil(items) and is_nil(enum) do
    item = get_one_of()
    decide_min_max(map, item, map["minItems"], map["maxItems"])
  end

  def decide_min_max(map, item, min, max)
      when is_integer(min) and is_integer(max) and min < max do
    if map["uniqueItems"] do
      StreamData.uniq_list_of(item, min_length: min, max_length: max)
    else
      StreamData.list_of(item, min_length: min, max_length: max)
    end
  end

  def decide_min_max(map, item, min, max) when is_integer(min) and is_nil(max) do
    if map["uniqueItems"] do
      StreamData.uniq_list_of(item, min_length: min)
    else
      StreamData.list_of(item, min_length: min)
    end
  end

  def decide_min_max(map, item, min, max) when is_nil(min) and is_integer(max) do
    if map["uniqueItems"] do
      StreamData.uniq_list_of(item, max_length: max)
    else
      StreamData.list_of(item, max_length: max)
    end
  end

  def decide_min_max(map, item, min, max) when is_nil(min) and is_nil(max) do
    if map["uniqueItems"] do
      StreamData.uniq_list_of(item)
    else
      StreamData.list_of(item)
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
    nlist = list ++ [get_one_of()]
    generate_list(list, nlist, max, min)
  end

  def add_additional_items(list, bool, max, min) when is_boolean(bool) and not bool do
    if check_bounds(list, max, min) do
      StreamData.fixed_list(list)
    end
  end

  def add_additional_items(list, map, max, min) when is_map(map) do
    nlist = list ++ [map |> SM.gen_init()]
    generate_list(list, nlist, max, min)
  end

  def generate_list(list, nlist, max, min) do
    cond do
      check_bounds(nlist, max, min) ->
        StreamData.fixed_list(nlist)

      not check_bounds(nlist, max, min) ->
        if check_bounds(list, max, min) do
          StreamData.fixed_list(list)
        end
    end
  end
end
