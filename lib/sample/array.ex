defmodule SM.Array do
    
  def gen_array(map, type), do: arraytype(map, map["enum"], map["items"])
  
  def arraytype(map, enum, items) when enum != nil, do: SM.gen_enum(enum, "array")
  
  def arraytype(map, enum, items) when is_list(items) do
     list = (for n <- items, is_map(n), do: SM.gen_init(n))
     if length(list) > 1 do
        case map["additionalItems"] do
            x when is_boolean(x) and x -> add_additional_items(list, "bool")
            x when is_map(x) -> add_additional_items(list, "map") 
            _ -> StreamData.fixed_list(list)
        end
     end 
  end
  
  def add_additional_items(list, bool) when is_boolean(bool) and bool do
    ""
  end
  
  def add_additional_items(list, map) when is_map(map) do
    IO.puts "hello map"
  end
    
end
