defmodule SM.Number do
  @num_min 0

  @num_max 100_000

  def gen_number(map, type) do
    gen_number_init(map, map["enum"], type)
  end

  def gen_number_init(map, enum, type) when is_list(enum), do: SM.gen_enum(enum, type)

  def gen_number_init(map, enum, type) when type == "integer" or type == "number" do
    min = findmin(map, @num_min)
    max = findmax(map, @num_max)
    random_number_gen(map["multipleOf"], type, min, max)
  end

  def random_number_gen(mult, type, min, max) when type == "integer" do
    new_min =
      case min do
        x when is_float(x) ->
          new_min = trunc(min) + 1

        x when is_integer(x) ->
          new_min = min
      end

    new_max =
      case max do
        x when is_float(x) ->
          new_max = trunc(x)

        x when is_integer(x) ->
          new_max = max
      end

    random_number_int(mult, new_min, new_max)
  end

  def random_number_gen(mult, type, min, max) when type == "number" do
    case {mult, min, max} do
      {m, x, y} when is_integer(x) and is_integer(y) ->
        random_number_int(m, x, y)

      {m, x, y} when is_number(m) ->
        random_number_float(m * 1.0, x, y)

      _ ->
        random_number_float(mult, min, max)
    end
  end

  def random_number_int(mult, min, max) when is_number(mult) and round(mult) == mult do
    getmultipleof(round(mult), min, max)
  end

  def random_number_int(mult, min, max) when is_number(mult) and round(mult) != mult do
    getmultipleof(mult, min, max)
  end

  def random_number_int(mult, min, max) when is_nil(mult) do
    Enum.random(min..max)
  end

  def random_number_float(mult, min, max) when is_float(mult) do
    getmultipleof(mult, min, max)
  end

  def random_number_float(mult, min, max) when mult == nil do
    get_float_number(min, max)
  end

  def findmax(map, max) do
    case {map["maximum"], map["exclusiveMaximum"]} do
      {x, y} when x != nil and y and is_integer(x) -> x - 1
      {x, y} when x != nil and y and is_float(x) -> x - 0.1
      {x, _} when x != nil -> x
      _ -> max
    end
  end

  def findmin(map, min) do
    case {map["minimum"], map["exclusiveMinimum"]} do
      {x, y} when x != nil and y -> x + 1
      {x, y} when x != nil and y and is_float(x) -> x + 0.1
      {x, _} when x != nil -> x
      _ -> min
    end
  end

  def getmultipleof(mult, min, max) when is_integer(mult) do
    fn_mod = fn x -> rem(x, mult) == 0 end
    for(n <- min..max, fn_mod.(n), do: n) |> Enum.random()
  end

  def getmultipleof(mult, min, max) when is_float(mult) do
    fn_check = fn x, y -> x * y >= min and x * y <= max end

    for(n <- trunc(min / mult)..trunc(max / mult), fn_check.(n, mult), do: n * mult)
    |> Enum.random()
  end

  def get_float_number(min, max) do
    interval = :rand.uniform(1000)
    fraction = (max - min) / interval
    for(n <- 1..interval, do: min + n * fraction) |> Enum.random()
  end
end
