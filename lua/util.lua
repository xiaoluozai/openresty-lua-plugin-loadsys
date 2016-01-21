local json = require "cjson"

local _M = {}

local function _M.err(code, message)
  -- resp
  local res = {
    err_code = code,
    err_msg = message
  }

  ngx.status = ngx.HTTP_OK
  ngx.header["Content-Type"] = 'application/json'
  ngx.say(json.encode(res))
end

-- https://github.com/daurnimator/lua-http/blob/master/http/util.lua
local function _M.char_to_pchar(c)
	return string.format("%%%02X", c:byte(1,1))
end
-- https://github.com/daurnimator/lua-http/blob/master/http/util.lua
local function _M.encodeURIComponent(str)
	return (str:gsub("[^%w%-_%.%!%~%*%'%(%)]", char_to_pchar))
end

local function _M.split (str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	       table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local function _M.ispassaway (rules, path)
  for _, epatt in ipairs(rules) do
    -- 开启 pattern 缓存
    local m, err = ngx.re.match(path, epatt, 'o')
    if m then
      return true
    end
  end
end

local function _M.ipmatch (cfg, ip)
  -- body...
  local matched
  local tokens = split(ip, '%.')
  for rule, cfg in pairs(ip_cfg) do
    for i, patt in ipairs(split(rule, '%.')) do
      if patt ~= '*' and tokens[i] ~= patt then
        matched = false
        break
      end
      matched = true
    end
    if matched then
      return cfg
    end
  end
end

return _M