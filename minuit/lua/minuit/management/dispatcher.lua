Minuit.iEventController = {}

local events 	   = {}
local pairs  	   = pairs
local type   	   = type
local error  	   = error
local ipairs 	   = ipairs
local setmetatable = setmetatable
local table_insert = table.insert

function Minuit.iEventController.Runner (eventname, ...)
	local eventlist = events [eventname] or {}
	
	for obj, callback in pairs (eventlist) do
		if type (obj) == "function" then
			obj (eventname, ...)
		elseif obj [eventname] then
			obj [eventname] (obj, eventname, ...)
		elseif obj.IEventController then
			obj:IEventController (eventname, ...)
		end
	end
end

function Minuit.iEventController.Register (obj, ...)
	if not obj then
		return error ("Minuit.iEventController.Register error: nil callback object", 2)
	end
	
	local eventnames = type (...) == "table" and ... or {...}
	
	if #eventnames == 0 then
		return error ("Minuit.iEventController.Register error: nil event name", 2)
	end
	
	for i, eventname in ipairs (eventnames) do
		if type (eventname) == "string" then
			local eventlist = events [eventname]
			
			if not eventlist then
				eventlist = {}
				setmetatable (eventlist, {__mode="k"}) -- weak keys so garbage collector can clean up properly
			end
			
			if type (obj) ~= "function" and type (obj) ~= "table" then
				return error ("Minuit.iEventController.Register error: callback object is not a table or function", 2)
			end
			
			eventlist [obj] = true
			events [eventname] = eventlist
		end
	end
	
	return obj
end

function Minuit.iEventController.Unregister (obj, ...)
	if not obj then
		return error ("Minuit.iEventController.Unregister error: nil callback object", 2)
	end
	
	local eventnames = type (...) == "table" and ... or {...}
	
	if #eventnames == 0 then
		return error ("Minuit.iEventController.Unregister error: nil event name", 2)
	end
	
	for i, eventname in ipairs (eventnames) do
		local eventlist = events [eventname]
		if eventlist and eventlist [obj] then
			eventlist [obj] = nil
		end
	end
end

function Minuit.iEventController.LookUp (obj)
	if type (obj) ~= "table" and type (obj) ~= "function" then
		return error ("Minuit.iEventController.LookUp error: callback object is not a table or function", 2)
	end
	
	local registeredevents = {}
	
	for eventname, eventlist in pairs (events) do
		for _obj, callback in pairs (eventlist) do
			if obj == _obj then
				table_insert (registeredevents, eventname)
				break
			end
		end
	end
	
	return registeredevents	
end