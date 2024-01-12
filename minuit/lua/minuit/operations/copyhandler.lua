if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:CopyHandler"
end

local isstring      = isstring
local tonumber      = tonumber
local tostring		= tostring
local type          = type
local strfinder		= string.find
local createTimer	= timer.Create
local debug_info	= debug.getinfo
local callHook		= hook.Call
local addHook  	 	= addHook 	 or hook.Add
local removeHook 	= removeHook or hook.Remove
local equation		= 0.01 * (player.GetCount () + 1)

function self:Constructor ()
	self.HookManager = Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.HookManager.RefreshRate  = 0.00001
	self.HookManager.ManagingList = {
		["Think"] = true,
		["Tick"]  = true,
	}
	
	self.HookManager.IgnoreList   = { 
		["FSpectate"] 		 = true,
		["VC_Load_SV_PSync"] = true,
		["VC_Think"]		 = true,
		["Cardinal.Register.PreviousAngles"] = true,
		["Cardinal.Register.RegisteredAAG_E_50"] = true,
	}
end

function hook.Add (hookName, hookSub, hookFunc, ...)
	if not self.HookManager then
		self:Constructor ()
	end
	
	if not hookFunc or type (hookFunc) ~= "function" then
		ErrorNoHaltWithStack ("Minuit:CopyHandler : Provided function from " .. debug_info (2).source .. ":" .. debug_info (2).currentline .. " is invalid.")
	end
	
	hookName = tostring (hookName)
	
    if self.HookManager.ManagingList [hookName] then
		if self.HookManager.IgnoreList [hookSub] or strfinder (tostring (hookSub), "VC_") then
			addHook (hookName, hookSub, hookFunc, ...)
		else
			addHook ("Minuit:HookingManager", hookSub, hookFunc)
		end
    else
        addHook (hookName, hookSub, hookFunc, ...)
    end
end

function hook.Remove (hookName, hookSub)
	if not self.HookManager then
		self:Constructor ()
	end

	hookName = tostring (hookName)
	
    if self.HookManager.ManagingList [hookName] then
		if self.HookManager.IgnoreList [hookSub] or strfinder (tostring (hookSub), "VC_") then
			removeHook (hookName, hookSub)
		else
			removeHook ("Minuit:HookingManager", hookSub)
		end
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