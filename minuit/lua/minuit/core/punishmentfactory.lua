if Minuit ["Minuit:Source"]:GetStateStatus (CLIENT) then
	return
end

local self   = {}
local ipairs = ipairs

function self:InternalId ()
	return "Minuit:PFactory"
end

function self:PreConstructor ()
	self.BestUsable = ""
	
	self.Channels   = Minuit ["Minuit:Source"]:WeakKeys ()
end

function self:Constructor ()
	if self.BestUsable ~= "" then -- Lua refresh compatibility.
		Minuit ["Minuit:Initializer"]:MiniLogger ("Already found Best Administration Mode (" .. self.BestUsable .. ").")
		return 
	end

	if ULib then
		self.Channels [#self.Channels + 1] = "ULX"
	elseif serverguard then
		self.Channels [#self.Channels + 1] = "ServerGuard"
	elseif maestro then
		self.Channels [#self.Channels + 1] = "Maestro"
	elseif sam then
		self.Channels [#self.Channels + 1] = "SAM"
	elseif D3A then
		self.Channels [#self.Channels + 1] = "D3A"
	else
		self.Channels [#self.Channels + 1] = "None"
	end
	
	if #self.Channels > 1 then
		Minuit ["Minuit:Initializer"]:MiniLogger ("Warning: Multiple Administration Mode has been detected, only one can run at a time.")
		
		for _, bestChannels in ipairs (self.Channels) do
			Minuit ["Minuit:Initializer"]:MiniLogger  ("Found : " .. bestChannels .. " as Best Administration Mode.")
		end
	end
	
	if #self.Channels == 1 then
		self.BestUsable = self.Channels [1]
	end
end

function self:HandlePunishment (ply, reason, duration)
	local banReason = "Minuit: " .. reason or "Minuit: No reason given."
	
	duration = duration or 0
	
	if not IsValid (ply) then
		Minuit ["Minuit:Initializer"]:MiniLogger ("Warning: Punishment attempt failed because of non-valid player.")
		return
	end
	
	local banId = ply:SteamID ()
	
	if duration == -1 then
		ply:Kick (banReason)
	end
	
	if self.Usable == "ULX" then
		RunConsoleCommand("ulx", "banid", banId, 0, banReason)
	elseif self.Usable == "ServerGuard" then
		serverguard:BanPlayer (nil, banId, 0, banReason, nil, nil, "Console")
	elseif self.Usable == "Maestro" then
		maestro.ban (banId, 0, banReason)
	elseif self.Usable == "SAM" then
		sam.player.ban_id (banId, 0, banReason, "Console")
	elseif self.Usable == "None" then
		ply:Kick (banReason)
	end
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())