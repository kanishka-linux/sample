defmodule SM do

  @types [
    "array",
    "boolean",
    "integer",
    "null",
    "number",
    "object",
    "string"
  ]
  
  @num_min 0
  
  @num_max 100000
  
  @strlen_min 1
  
  @strlen_max 100
  
  def generator(x) do
    IO.puts x
    map = Poison.decode! x
    cond do
        map["enum"] ->
            gen_enum(map["enum"], map["type"])
        is_list(map["type"]) ->
            ntype = Enum.random(map["type"])
            Map.put(map, map["type"], ntype)
            gen_type(ntype, map)
        map["type"] in @types ->
            gen_type(map["type"], map)
    end
  end
  
  def gen_type(type, map) do
    case {type} do
        {"string"} ->
            gen_string(map)
        {"integer"} ->
            gen_number(map, "integer")
        {"number"} ->
            gen_number(map, "number")
        {"boolean"} ->
            Enum.random([true, false])
        {"null"} ->
            "null"
        {"array"} ->
            IO.puts "ARRAY"
        {"object"} ->
            IO.puts "DICT"
    end
  end
    
  def gen_enum(list, type) do
    Enum.random(list)
  end
  
  def gen_string(map) do
    cond do
        map["enum"] ->
            gen_enum(map["enum"], "string")
        map["pattern"] ->
            Randex.stream(~r/#{map["pattern"]}/) |> Enum.at(0)
        true ->
            min = 
            if map["minLength"] do
                min = map["minLength"]
            else
                min = @strlen_min
            end
            max = 
            if map["maxLength"] do
                max = map["maxLength"]
            else
                max = @strlen_max
            end
            if min <= max do
                Randex.stream(~r/[a-zA-Z0-9]{#{min},#{max}}/) |> Enum.at(0)
            end
    end
  end
  
  def findmax(map, max) do
    cond do
        map["maximum"] && map["exclusiveMaximum"] ->
            map["maximum"] - 1
        map["maximum"] ->
            map["maximum"]
        true ->
            max
    end
  end
  
  def findmin(map, min) do
    cond do
        map["minimum"] && map["exclusiveMinimum"] ->
            map["minimum"] - 1
        map["minimum"] ->
            map["minimum"]
        true ->
            min
    end
  end
  
  def getmultipleof(map, val, min) do
    if map["multipleOf"] do
        remainder = rem(val, map["multipleOf"])
        nval = val - remainder
        if nval >= min do
            nval
        end
    else
        val
    end
  end
  
  def random_number(map, min, max) do
    cond do
        is_integer(min) and is_integer(max) ->
            getmultipleof(map, Enum.random(min..max), min)
        is_integer(map["multipleOf"]) and is_float(min) and is_float(max) ->
            getmultipleof(map, Enum.random(Kernel.trunc(min)+1..Kernel.trunc(max)-1), min)
        is_integer(map["multipleOf"]) and is_integer(min) ->
            getmultipleof(map, Enum.random(min..Kernel.trunc(max)-1), min)
        is_integer(map["multipleOf"]) and is_integer(max) ->
            getmultipleof(map, Enum.random(Kernel.trunc(min)+1..max), min)
        (max - min) >= 1 ->
            min + :rand.uniform_real()
    end
  end
  
  def gen_number(map, type) do
    cond do
        map["enum"] ->
            gen_enum(map["enum"], type)
        type == "integer" || type == "number" ->
            min = findmin(map, @num_min)
            max = findmax(map, @num_max)
            random_number(map, min, max)
    end
  end
  
end
