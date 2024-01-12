Minuit  		   = Minuit or {}
local self 		   = {}
local include 	   = include
local AddCSLuaFile = AddCSLuaFile
local type		   = type
local setmetatable = setmetatable
local MinuitStart  = SysTime ()

function Minuit.MakeGateAway (SignalAccelerator, SignalFilter, ISaveMap)
    SignalFilter [ISaveMap] = SignalAccelerator
end

function self:WeakKeys ()
    local weakTable = {}
	
    setmetatable (weakTable, 
		{
			__mode = "k" 
		}
	)
	
    return weakTable
end

function self:TimeTracker ()
	local startupTime = SysTime () 
	startupTime 	  = startupTime - MinuitStart
	return string.format ("%02d:%02d", math.floor (startupTime / 60), math.floor (startupTime % 60), math.floor (startupTime * 1000 % 1000))
end

function self:InternalId ()
	return "Minuit:Source"
end

function self:Constructor ()
	self.LoadFile = self:WeakKeys ()
	
	self.LoadFile [#self.LoadFile + 1] = "minuit/data/minuitinitializer.lua"
	self.LoadFile [#self.LoadFile + 1] = "SERVER|minuit/management/governance.lua"
	self.LoadFile [#self.LoadFile + 1] = "SERVER|minuit/management/dispatcher.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/management/timerentry.lua"
	self.LoadFile [#self.LoadFile + 1] = "SERVER|minuit/core/punishmentfactory.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/plugins/surface.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/plugins/color.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/plugins/usermessage.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/collection/playerhandler.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/operations/eventhandler.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/operations/copyhandler.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/operations/rendercross.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/collection/cvmonitoring.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/controllers/imagesynthesiscontroller.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/switcher/newlibrary.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/supervisors/corerendering.lua"
	self.LoadFile [#self.LoadFile + 1] = "SERVER|minuit/supervisors/turbophysics.lua"
	self.LoadFile [#self.LoadFile + 1] = "SERVER|minuit/supervisors/layoutcontrol.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/gestion/saferequester.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/data/classesmegastructure.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/switcher/animations.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/fingerprint.lua"
	self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/switcher/drawlibrary.lua"
	--self.LoadFile [#self.LoadFile + 1] = "CLIENT|minuit/plugins/hooksystem.lua"
end

function self:ParseCorrectFiles (_)
	if string.sub (self, 1, 6) == "SERVER" then
		return true
	else
		return false
	end
end

function self:DispatchFiles (file, server)
	if type (self) ~= "table" and not file then
		file = tostring (self)
	end
	if file ~= nil then
		AddCSLuaFile (file)
		include (file)

		return "> Dispatched > " .. file .. "."
	else
		if type (self) == "table" then
			return self:InternalId () .. ".DispatchFiles : Empty allocation provided."
		else
			return self:InternalId () .. ".DispatchFiles : Empty allocation provided."
		end
	end
end

function self:GetStateStatus (status)
	if status then
		return true
	end
end

self:Constructor ()
Minuit.MakeGateAway (self, Minuit, self:InternalId ())
self:DispatchFiles (self.LoadFile [1])