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
    list = Enum.slice(@type_list, 0, length(@type_list) - 1)
    item = SM.gen_init(choose_item(list))
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

  def add_additional_items(list, bool, max, min) when is_boolean(bool) and bool do
    add_item = choose_item([true, false])

    nlist =
      if add_item do
        list ++ [select_one_item()]
      else
        list
      end

    generate_list(list, nlist, max, min, add_item)
  end

  def add_additional_items(list, bool, max, min) when is_boolean(bool) and not bool do
    if check_bounds(list, max, min) do
      StreamData.fixed_list(list)
    end
  end

  def add_additional_items(list, map, max, min) when is_map(map) do
    add_item = choose_item([true, false])

    nlist =
      if add_item do
        list ++ [SM.gen_init(map)]
      else
        list
      end

    generate_list(list, nlist, max, min, add_item)
  end

  def generate_list(list, nlist, max, min, add_item) do
    cond do
      add_item and check_bounds(nlist, max, min) ->
        StreamData.fixed_list(nlist)

      add_item and not check_bounds(nlist, max, min) ->
        if check_bounds(list, max, min) do
          StreamData.fixed_list(list)
        end

      not add_item and check_bounds(list, max, min) ->
        StreamData.fixed_list(list)
    end
  end

  def choose_item(list) do
    choice = :rand.uniform(length(list))
    Enum.fetch!(list, choice - 1)
  end

  def select_one_item() do
    item = choose_item(@type_list)

    if is_map(item) do
      SM.gen_init(item)
    else
      []
    end
  end
end
