if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:CopyHandler"
end

local isstring      = isstring
local tonumber      = tonumber
local type          = type
local createTimer	= timer.Create
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
end

function hook.Add (hookName, hookSub, hookFunc)
	if not self.HookManager then
		self:Constructor ()
	end
	
	hookName = tostring (hookName)
	
    if self.HookManager.ManagingList [hookName] then
        addHook ("Minuit:HookingManager", hookSub, hookFunc)
    else
        addHook (hookName, hookSub, hookFunc)
    end
end

function hook.Remove (hookName, hookSub)
	if not self.HookManager then
		self:Constructor ()
	end
	
	hookName = tostring (hookName)
	
    if self.HookManager.ManagingList [hookName] then
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