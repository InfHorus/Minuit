if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:CVMonitoring"
end

function self:Constructor ()
	if not self.ConVarPlanning then
		self.ConVarPlanning = Minuit ["Minuit:Source"]:WeakKeys ()
	end
	
	self.ConVarPlanning ["Burst"] = {
		["gmod_mcore_test"] 					= { GetConVar ("gmod_mcore_test"):GetInt (), 1, false },
		
		["map_bumpmap"] 						= { GetConVar ("map_bumpmap") and GetConVar ("map_bumpmap"):GetInt (), 0, false },
		["mat_picmip"] 							= { GetConVar ("mat_picmip")  and GetConVar ("mat_picmip"):GetInt (), 2, false },
		
		["mat_queue_mode"] 						= { GetConVar ("mat_queue_mode"):GetInt (), 2, false },
		["cl_threaded_bone_setup"] 				= { GetConVar ("cl_threaded_bone_setup"):GetInt (), 1, false },
		["cl_threaded_client_leaf_system"] 		= { GetConVar ("cl_threaded_client_leaf_system"):GetInt (), 1, false },
		["r_threaded_client_shadow_manager"] 	= { GetConVar ("r_threaded_client_shadow_manager"):GetInt (), 1, false },
		["r_threaded_particles"] 				= { GetConVar ("r_threaded_particles"):GetInt (), 1, false },
		["r_threaded_renderables"] 				= { GetConVar ("r_threaded_renderables"):GetInt (), 1, false },
		["r_queued_ropes"] 						= { GetConVar ("r_queued_ropes"):GetInt (), 1, false },
		["studio_queue_mode"] 					= { GetConVar ("studio_queue_mode"):GetInt (), 1, false },
		["mat_specular"] 						= { GetConVar ("mat_specular"):GetInt (), 1, false },
		["fps_max"] 							= { GetConVar ("fps_max"):GetInt (), Minuit ["Minuit:PlayerHandler"]:GetRefreshRate () or 165, false },
		["M9KGasEffect"]						= { GetConVar ("M9KGasEffect") and GetConVar ("M9KGasEffect"):GetInt () or 0, 0, false },
	}
end

function self:ApplyConvars ()
	if self.ConVarPlanning and self.ConVarPlanning.Burst then
		local changeAmount = 0
		for convar, array in pairs (self.ConVarPlanning.Burst) do
			if not ConVarExists (convar) then
				goto ignore
			end
		
			if tonumber (array [1]) ~= tonumber (array [2]) then
				RunConsoleCommand (tostring (convar), tonumber (array [2]))
				Minuit ["Minuit:Initializer"]:MiniLogger ("Switched ConVar " .. convar .. " from " .. array [1] .. " to " .. array [2])
				changeAmount = changeAmount + 1
			end
				
			::ignore::
		end
		
		--RunConsoleCommand ("menu_cleanupgmas")
		if changeAmount > 0 then
			Minuit ["Minuit:Initializer"]:MiniLogger ("Saved Minuit Change.")
			self:Constructor ()
		end
	end
end

function self:WidgetDestroyer (entity)
	if not entity or entity == NULL then return end
	
	if entity:IsWidget () then
		hook.Add ("PlayerTick", "Minuit:WidgetManager", 
			function (ply, move) 
				widgets.PlayerTick (ply, move) 
			end 
		)
		
		hook.Remove ("OnEntityCreated", "Minuit:WidgetInitializer")
	end
end

hook.Add("OnEntityCreated", "Minuit:WidgetInitializer", self.WidgetDestroyer)

Minuit.MakeGateAway (self, Minuit, self:InternalId ())