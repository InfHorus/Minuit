do
	Minuit ["Minuit:TimerEntry"]:Constructor   ()
	Minuit ["Minuit:NewLibrary"]:Constructor   ()
	Minuit ["Minuit:RenderCross"]:Constructor  ()
	
	Minuit ["Minuit:NewLibrary"].SwitchNetworkedLibrary ()
	
	if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
		Minuit ["Minuit:Governance"]:Constructor   ()
		Minuit ["Minuit:EventHandler"]:Constructor ()
		Minuit ["Minuit:TurboPhysics"]:Constructor ()
		
		timer.Create ("Minuit:HandleTurboPhysic", 10, 0,
			function ()
				Minuit ["Minuit:TurboPhysics"]:LaunchTurboPhysics ()
			end
		)
		
		net.Receive ("Minuit:Ascending",
			function (len, ply)
				Minuit ["Minuit:TurboPhysics"]:Ejection (len, ply)
			end
		)
		
		net.Receive ("Minuit:UploadClient",
			function (len, ply)
				Minuit ["Minuit:LayoutControl"]:HandleRequest (len, ply)
			end
		)
		
		hook.Add ("InitPostEntity", "Minuit:InitEvent", 
			function () 
				Minuit ["Minuit:EventHandler"]:StartupHook ()
				
				Minuit ["Minuit:PFactory"]:PreConstructor ()
				Minuit ["Minuit:PFactory"]:Constructor ()
				
				Minuit ["Minuit:LayoutControl"]:Constructor ()
			end, HOOK_MONITOR_HIGH
		)
	end
	
	hook.Add ("Think", "Minuit:Timing", function () Minuit ["Minuit:TimerEntry"]:ExecuteTimers () end)
end

if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

do
	Minuit ["Minuit:ImageSynthesisC"]:Constructor   ()
	Minuit ["Minuit:CoreRendering"]:Constructor   	()
	Minuit ["Minuit:PlayerHandler"]:Constructor 	()
	Minuit ["Minuit:TimerEntry"]:Constructor		()
	Minuit ["Minuit:CVMonitoring"]:Constructor  	()
		
	hook.Add ("InitPostEntity", "Minuit:InitEvent", 
		function () 
			Minuit ["Minuit:CVMonitoring"]:ApplyConvars () 
			Minuit ["Minuit:CopyHandler"]:StartupHook   () 
			Minuit ["Minuit:SafeRequester"]:Constructor ()
		end
	)

	--hook.Add ("PreDrawViewModel", Minuit ["Minuit:ImageSynthesisC"].Identifier, 
		--function (ent, ply, numberflag) Minuit ["Minuit:ImageSynthesisC"]:ImageSynthetizer (ent, ply, numberflag) 
	--end)
	
	-- TODO: jit compile this part.
	--hook.Add ("Think", Minuit ["Minuit:CoreRendering"].Identifier,
		--function () Minuit ["Minuit:CoreRendering"]:RenderingInTime ()
	--end)
end

Minuit ["Minuit:TimerEntry"]:CreateTimer ("Minuit:HandleConVars", 120, 
	function ()	
		if Minuit ["Minuit:Source"]:GetStateStatus (CLIENT) then
			Minuit ["Minuit:NewLibrary"].Initiate  (player.GetCount () or 0)
		end
	end
)