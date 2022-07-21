local self   = {}
local pairs	 = pairs
local ipairs = ipairs

function self:InternalId ()
	return "Minuit:TurboPhysics"
end

function self:Constructor ()
	util.AddNetworkString ("Minuit:LatencyScore")
	util.AddNetworkString ("Minuit:StressScore")
	util.AddNetworkString ("Minuit:Ascending")
	
	self.Penetrating 	= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Degrees 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Entities 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Stress 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Meshes			= Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.Scores 		= Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.Delay 		 	= function (tick, cid)
		local cooperativeThread = coroutine.running ()
		
		timer.Create (self:InternalId () .. "internal_" .. cid, tick, 0,
			function ()
				coroutine.resume (cooperativeThread)
			end
		)
		
		coroutine.yield ()
	end
	
	self.FreezeStack 	= function (amount)
		local activeCoroutine = coroutine.running ()

		timer.Simple (amount, 
			function ()
				coroutine.resume (activeCoroutine)
			end
		)

		return coroutine.yield ()
	end
	
	self.SessionHash 	= function ()
		math.randomseed (os.clock () ^ 5)
		
		return tostring (math.random (-9999999999, 9999999999))
	end
	
	self.getPlayerFromId = function (id)
		for _, ply in ipairs (player.GetAll ()) do
			if ply:SteamID () == id then
				return ply
			end
		end
		
		return false
	end
	
end

local function latenceManager (tick, cid)
	local cooperativeThread = coroutine.running ()
		
	timer.Create (self:InternalId () .. "internal_" .. cid, tick, 0,
		function ()
			coroutine.resume (cooperativeThread)
		end
	)
		
	coroutine.yield ()
end

local function deliverUpdatedPacket (garbagedBase, ply, channel)
	local ATS = 0
	local sessionHash = self.SessionHash ()
	
	print(timer.Exists (self:InternalId () .. "internal_" .. sessionHash))
	for key, value in pairs (garbagedBase) do
		if not key or type (key) ~= "Player" then 
			goto skipped
		end
		
		garbagedBase [key:SteamID ()] = value
		garbagedBase [key] = nil
		
		::skipped::
	end
	
	local loadPacket = util.Compress (util.TableToJSON (garbagedBase))
	if not loadPacket or loadPacket == NULL or loadPacket == "" then return end
	
	local length  = string.len (loadPacket)
	local packets = 50
	local parts   = math.ceil (length / packets)
	local start   = 0
	
	local bool 	  = true
	if not ply:IsAdmin () then
		bool = false
	end
	
	for i = 1, parts do
		local endbyte = math.min (start + packets, length)
		local size    = endbyte - start
		net.Start (channel)
		net.WriteBool (i == parts)
		net.WriteBool (bool)
		net.WriteUInt (size, 16)
		net.WriteData (loadPacket:sub (start + 1, endbyte + 1), size)
		net.Send (ply)
		start = endbyte
		
		latenceManager (0.02, channel .. sessionHash)
		
		if i == parts and ATS < CurTime () then
			ATS = CurTime () + 3
		end
	end
end

function self:LaunchTurboPhysics ()
	self.Penetrating 	= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Degrees 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Entities 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Stress 		= Minuit ["Minuit:Source"]:WeakKeys ()
	self.Meshes			= Minuit ["Minuit:Source"]:WeakKeys ()
			
	self.Scores 		= Minuit ["Minuit:Source"]:WeakKeys ()
			
	for _, ply in ipairs (player.GetAll ()) do
		self.Scores [ply] = 0
	end

	for _, ent in ipairs (ents.GetAll ()) do
		if IsValid (ent) and ent.CPPIGetOwner then
			local owner 	= ent:CPPIGetOwner()
			local physObj 	= ent:GetPhysicsObject()
			
			if IsValid (owner) and IsValid (physObj) and not IsValid (ent:GetParent ()) then
				local stressScore = physObj:GetStress () / physObj:GetMass ()
						
				if (physObj:IsMotionEnabled () and not physObj:IsAsleep ()) or stressScore > 1 then
					local welds  = constraint.FindConstraints (ent, "Weld")
					local ropes  = constraint.FindConstraints (ent, "Rope")
					local degree = 0
							
					for _ in pairs (welds) do
						degree = degree + 1
					end
					
					for _ in pairs (ropes) do
						degree = degree + 1
					end
							
					if degree > 0 or stressScore > 0 then
						self.Entities [owner] = (self.Entities [owner] or 0) + 1
						self.Degrees  [owner] = (self.Degrees  [owner] or 0) + degree
						self.Stress   [owner] = (self.Stress   [owner] or 0) + stressScore
						self.Meshes   [owner] = (self.Meshes   [owner] or 0) + math.Max (1, #(physObj:GetMeshConvexes () or {}))
					end
				end
				
				if physObj:IsPenetrating () then
					self.Penetrating  [owner] = (self.Penetrating [owner] or 0) + 1
				end
			end
		end
	end
			
	for ply, count in pairs (self.Entities) do
		self.Scores [ply] = (self.Meshes [ply] or 1) * (self.Degrees [ply] or 1) * (self.Stress [ply] or 1) / count
		
		ply:SetNWFloat ("Minuit:Sorting", tonumber (self.Scores [ply]) * (1 + tonumber (self.Stress [ply])))
	end
	
	for _, broadCast in ipairs (player.GetAll ()) do
		coroutine.wrap (deliverUpdatedPacket) (self.Scores, broadCast, "Minuit:LatencyScore")
		
		coroutine.wrap (deliverUpdatedPacket) (self.Penetrating, broadCast, "Minuit:StressScore")
	end
end

function self:Ejection (len, ply)
	local bool  = net.ReadBool   ()
	local reID  = net.ReadString ()
	
	if reID == "none" then
		Minuit ["Minuit:Initializer"]:MiniLogger ("Warning: Transmitted ID for punishment is not valid.")
		return
	end
	
	local victim = self.getPlayerFromId (reID) or nil
	
	if not IsValid (victim) then
		Minuit ["Minuit:Initializer"]:MiniLogger ("Warning: " .. ply:Nick () .. " attempted to kick a non-valid player")
		return
	end
	
	if not bool or not ply:IsAdmin () then
		Minuit ["Minuit:Initializer"]:MiniLogger ("Warning: " .. ply:Nick ()  .. " attempted to kick " .. victim:Nick () .. " without admin privileges.")
		return
	end
	
	Minuit ["Minuit:PFactory"]:HandlePunishment (victim, "Kicked by " .. ply:Nick () .. " through Minuit Stress Panel", -1)
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())