--- @class LoggerLSettings
--- @field prefixes string[]? Optional prefixes for this log
--- @field subPrefix string[]? Optional sub-prefixes for this log
--- @field id string? Optional custom log ID for suppression

--- @class LoggerResourceConfig
--- @field enabled boolean Whether logging is enabled for this resource
--- @field showTime boolean Where to include time prefix in logs
--- @field prefixes string[]? Optional Resource-level default prefixies

--- @alias logLevel "info"|"error"|"success"|"warn"|"debug"

--- @class Logger
--- @field resources table<string, table>
--- @field suppressedIds table<string, boolean>
--- @field defaultConfig table
--- @field styles table<string, table>
--- @field _log function
Logger = {}
Logger.__index = Logger

Logger.resources = {}
Logger.suppressedIds = {}
Logger.defaultConfig = {
     enabled   = true,
     showTime  = true,
     prefixes  = {}
}

Logger.styles = {
     info    = { label = "INFO", color = "^3" },
     error   = { label = "ERROR", color = "^1" },
     success = { label = "SUCCESS", color = "^2" },
     warn    = { label = "WARN", color = "^3" },
     debug   = { label = "DEBUG", color = "^5" },
}

--- Internal Logger function
--- @param level logLevel
--- @param ... any
function Logger:_log(level, ...)
	local resName = GetCurrentResourceName()
	--- @type LoggerResourceConfig
	local cfg = self.resources[resName] or self.defaultConfig
	if not cfg.enabled then return end

	local args = {...}
	--- @type LoggerLSettings
	local lSettings = {}

	if type(args[#args]) == "table" and args[#args].lSettings then
		lSettings = args[#args].lSettings
		table.remove(args, #args)
	end

	if lSettings and lSettings.id and Logger.suppressedIds[lSettings.id] then
		return
	end

	local parts = {}
	for i=1,#args do
	     local arg = args[i]
		if type(arg) =="table" then
			table.insert(parts, Helper.Serialize(arg))
		else
			table.insert(parts, tostring(arg))
		end
	end

	local msg = table.concat(parts, " ")

	print(Helper.FormatMessage(level, msg, cfg, lSettings))
end

--
-- API
--

-- LOG LEVELS

--- @param ... any
--- @return Logger
function Logger:Info(...)
	self:_log("info", ...)
	return self
end

--- @param ... any
--- @return Logger
function Logger:Error(...)
	self:_log("error", ...)
	return self
end

--- @param ... any
--- @return Logger
function Logger:Success(...)
	self:_log("success", ...)
	return self
end

--- @param ... any
--- @return Logger
function Logger:Warn(...)
	self:_log("warn", ...)
	return self
end
--- @param ... any
--- @return Logger
function Logger:Warning(...)
	self:_log("warn", ...)
	return self
end

--- @param ... any
--- @return Logger
function Logger:Debug(...)
	self:_log("debug", ...)
	return self
end

--- Enable logging for a resource
--- @param resName string
function Logger:EnableResource(resName)
	local cfg = self.resources[resName] or {}
	cfg.enabled = true
	self.resources[resName] = cfg
end

--- Disable logging for a resource
--- @param resName string
function Logger:DisableResource(resName)
	local cfg = self.resources[resName] or {}
	cfg.enabled = false
	self.resources[resName] = cfg
end


function Logger:SetConfig(resName, cfg)
	self.resources[resName] = cfg
end

function Logger:GetConfig(resName)
     return self.resources[resName] or self.defaultConfig
end

--- Suppress logging for a resource
--- @param id string
function Logger:SuppressLog(id)
     if id then
          Logger.suppressedIds[id] = true
     end
end

--- Unsuppress logs by ID
--- @param id string
function Logger:UnSuppressLog(id)
     if id then
          Logger.suppressedIds[id] = nil
          collectgarbage("collect")
     end
end

function Logger:UnSuppressAll()
     Logger.suppressedIds = nil
end

-- Chaining  support (Debug():Error(), OR Debug():Success())
setmetatable(Logger, {
	__index = function (t, k)
		if rawget(t, k) then return rawget(t, k) end
		if Logger.styles[k] then
			return function(_, ...)
				Logger:_log(k, ...)
				return Logger
			end
		end
	end
})

RegisterCommand("log_suppress", function (source, args, raw)
     local id = args[1]
     if not id then
          return Logger:Error("Invalid argument")
     end

     Logger:SuppressLog(id)

end, false)


RegisterCommand("log_unsuppress", function (source, args, raw)
     local id = args[1]
     if not id then
          return Logger:Error("Invalid argument")
     end

     Logger:UnSuppressLog(id)
end, false)
RegisterCommand("log_unsuppressall", function (source, args, raw)
     Logger:UnSuppressAll()
end, false)

RegisterCommand("log_enable", function (source, args, raw)
     local res = args[1]
     if not res then
          return Logger:Error("Invalid argument")
     end

     Logger:EnableResource(res)
end, false)

RegisterCommand("log_disable", function (source, args, raw)
     local res = args[1]
     if not res then
          return Logger:Error("Invalid argument")
     end

     Logger:DisableResource(res)
end, false)


RegisterCommand("log_config", function (source, args, raw)
	local resName = args[1]
	local key = args[2]
	local value = args[3]

	if not resName or not key or value == nil then
		return Logger:Error("Invalid argument")
	end

	local cfg = Logger:GetConfig(resName)

	if (value):lower() == "true" then
		value = true
	elseif (value):lower() == "false" then
	     value = false
	else
		return Logger:Error("Invalid argument[3] true or false")
	end

	cfg[key] = value
	Logger:SetConfig(resName, cfg)
end, false)


_G.Logger = Logger
_ENV.Logger = Logger
