hook.Add ("MouthMoveAnimation", "Minuit:UselessHook", 
	function () 
		return nil 
	end
)

hook.Add ("GrabEarAnimation", "Minuit:UselessHook", 
	function () 
		return nil 
	end
)

if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

hook.Add ("NeedsDepthPass", "Minuit:UselessHook", 
	function () 
		return false 
	end
)
