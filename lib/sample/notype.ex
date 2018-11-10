defmodule SM.Notype do
  @prop %{
    "minLength" => "string",
    "maxLength" => "string",
    "pattern" => "string",
    "multipleOf" => "number",
    "minimum" => "number",
    "maximum" => "number",
    "exclusiveMinimum" => "number",
    "exclusiveMaximum" => "number",
    "items" => "array",
    "additionalItems" => "array",
    "minItems" => "array",
    "maxItems" => "array",
    "uniqueItems" => "array",
    "properties" => "object",
    "additionalProperties" => "object",
    "required" => "object",
    "minProperties" => "object",
    "maxProperties" => "object"
  }

  def gen_notype(map, type) do
    nmap = for {k, v} <- map, into: %{}, do: {k, v}
    nlist = for {k, v} <- map, into: [], do: @prop[k]

    types =
      Enum.reduce(nlist, nil, fn
        x, acc when not is_nil(x) -> x
        x, acc when is_nil(x) -> acc
      end)

    nmap = if not is_nil(types), do: Map.put(nmap, "type", types), else: nmap
    if nmap["type"], do: SM.gen_init(nmap)
  end
end
