Helper = {}


--- Recursively serialize a table to string
--- @param value any
--- @param indent number? Indentation level
--- @return string
function Helper.Serialize(value, indent)
     indent = indent or 0
       local t = type(value)
       if t ~= "table" then return tostring(value) end
       if next(value) == nil then return "{EMPTY TABLE}" end

       local lines = { "{" }
       for k, v in pairs(value) do
           local key = tostring(k)
           local val = Helper.Serialize
           table.insert(lines, string.rep(" ", indent + 2) .. key .. " = " .. val .. ",")
       end
       table.insert(lines, string.rep(" ", indent) .. "}")
       return table.concat(lines, "\n")
end

--- Format final message with prefixes / resoruce / time
--- @param level string
--- @param message string
--- @param cfg table
--- @param lSettings table
--- @return string
function Helper.FormatMessage(level, message, cfg, lSettings)
	local style = Logger.styles[level] or Logger.styles.info
	local ts = cfg.showTime and "" or ""
	if cfg.showTime then
		ts = lib.callback.await("mate-logger:GetTime", false)
	end
	local resName = GetCurrentResourceName()

	local allPrefixes = {resName}

	for _,p in ipairs(cfg.prefixes or {}) do table.insert(allPrefixes, p) end
	if lSettings then
     	for _,p in ipairs(lSettings.prefixes or {}) do table.insert(allPrefixes, p) end
     	if lSettings.subPrefix then table.insert(allPrefixes, lSettings.subPrefix) end
	end

	local prefix = "[" .. table.concat(allPrefixes, "] [") .. "] "

	return string.format("%s%s[%s] %s%s", ts, style.color, style.label, prefix, message)
end

return Helper
