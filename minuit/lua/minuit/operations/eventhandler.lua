if Minuit ["Minuit:Source"]:GetStateStatus (CLIENT) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:EventHandler"
end

local isstring      = isstring
local tonumber      = tonumber
local tostring		= tostring
local type          = type
local strfinder		= string.find
local debug_info	= debug.getinfo
local createTimer	= timer.Create
local callHook		= hook.Call
local addHook  	 	= addHook 	 or hook.Add
local removeHook 	= removeHook or hook.Remove
local equation		= 0.01 * (player.GetCount () + 1)

function self:Constructor ()
	self.HookManager = Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.HookManager.RefreshRate  = 0.05
	self.HookManager.ManagingList = {
		["Think"] = true,
		["Tick"]  = true,
	}
	
	self.HookManager.IgnoreList   = { 
		["VC_Load_SV_PSync"] = true,
		["VC_Think"]		 = true,
	}
end

function hook.Add (hookName, hookSub, hookFunc, ...)
	hookName = tostring (hookName)
	
	if not hookFunc or type (hookFunc) ~= "function" then
		ErrorNoHaltWithStack ("Minuit:EventHandler : Provided function from " .. debug_info (2).source .. ":" .. debug_info (2).currentline .. " is invalid.")
	end
	
    if self.HookManager.ManagingList [hookName] and not self.HookManager.IgnoreList [hookSub] and not strfinder (tostring (hookSub), "VC_") then
        addHook ("Minuit:HookingManager", hookSub, hookFunc)
    else
        addHook (hookName, hookSub, hookFunc, ...)
    end
end

function hook.Remove (hookName, hookSub)
	hookName = tostring (hookName)
	
    if self.HookManager.ManagingList [hookName] and not self.HookManager.IgnoreList [hookSub] and not strfinder (tostring (hookSub), "VC_") then
        removeHook ("Minuit:HookingManager", hookSub)
    else
        removeHook (hookName, hookSub)
    end
end

function self:StartupHook ()
	timer.Simple (0, 
		function ()
			createTimer ("Minuit:HandleWorldEvents", self.HookManager.RefreshRate, 0,
				function () 
					callHook ("Minuit:HookingManager")
				end 
			)
		end
	)
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())