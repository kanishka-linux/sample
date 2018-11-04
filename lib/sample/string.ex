defmodule SM.String do

  @strlen_min 1
  
  @strlen_max 100

  def gen_string(map), do: stringer(map, map["enum"], map["pattern"])
  
  def stringer(map, enum, pattern) when is_nil(enum) and is_nil(pattern) do
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
  
  def stringer(map, enum, pattern) when is_list(enum) do
    SM.gen_enum(map["enum"], "string")
  end
  
  def stringer(map, enum, pattern) when is_binary(pattern) do
    Randex.stream(~r/#{pattern}/) |> Enum.at(0)
  end
  
end
