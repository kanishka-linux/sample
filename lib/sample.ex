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
  
  def generator(jschema) do
    IO.puts jschema
    jschema |> Poison.decode!() |> gen_init()
  end
  
  def gen_init(map) do
    gen_all(map, map["enum"], map["type"])
  end
  
  def gen_all(map, enum, type) when enum != nil, do: gen_enum(enum, type)
  
  def gen_all(map, enum, type) when is_list(type) do
    ntype = Enum.random(type)
    Map.put(map, "type", ntype)
    gen_type(ntype, map)
  end
  
  def gen_all(map, enum, type) when type in @types, do: gen_type(type, map)
  
  def gen_type(type, map) when type == "string" do
    SM.String.gen_string(map)
  end
  
  def gen_type(type, map) when type == "integer" do 
    SM.Number.gen_number(map, "integer")
  end
    
  def gen_type(type, map) when type == "number" do 
    SM.Number.gen_number(map, "number")
  end
    
  def gen_type(type, map) when type == "boolean" do 
    Enum.random([true, false])
  end
  
  def gen_type(type, map) when type == "null" do 
    "null"
  end
    
  def gen_enum(list, type) do
    nlist =
    case type do
      x when x == "integer" ->
        for n <- list, is_integer(n), do: n
      x when x == "number" ->
        for n <- list, is_number(n), do: n
      x when x == "string" ->
        for n <- list, is_binary(n), do: n
      _ -> list
    end
    Enum.random(nlist)
  end
  
end
