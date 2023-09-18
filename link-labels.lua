-- Transform output to use \label{}-based anchors in documents
-- See <https://tex.stackexchange.com/a/597744>
local domfilter = require "make4ht-domfilter"

-- Parse the aux file to get a mapping between labels and ID attributes
-- of the corresponding <a> element
local function parse_aux(aux_filename)
  local mapping = {}
  local f = io.open(aux_filename, "r")
  local content = f:read("*all")
  f:close()
  -- labels are stored in this form:
  -- \newlabel{sec:intro}{{\rEfLiNK{x1-10001}{1}}{\rEfLiNK{x1-10001}{1}}}
  for label, id in content:gmatch("newlabel{(.-)}{{.-{(.-)}") do
    mapping[id] = label
  end
  return mapping
end

-- Mapping between existing ids and labels
local aux

local process = domfilter {
  function(dom, properties)
    -- Reuse any existing mapping when we process subsequent files
    aux = aux or parse_aux(properties.input .. ".aux")

    for _, a in ipairs(dom:query_selector("a")) do
      -- Update IDs
      local id = a:get_attribute("id")
      if aux[id] then a:set_attribute("id", aux[id]) end

      -- Update links
      local href = a:get_attribute("href")
      if href then
        local url, id = href:match("(.*)#(.+)")
        if id and aux[id] then
          a:set_attribute("href", string.format("%s#%s", url or "", aux[id]))
        end
      end
    end
    return dom
  end
}

Make:match("html$", process)
