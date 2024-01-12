if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self  = {}
local pairs = pairs

function self:InternalId ()
	return "Minuit:CoreRendering"
end

function self:Constructor ()
	self.OptimalDistance = 2500 * 1.4
	self.EntityTable	 = ents.GetAll
	self.Identifier		 = self:InternalId ()
	
	self.WeakCache		 = Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.IsObjectInFOV   = function (ply, endVector)
		local diff = endVector - ply:GetShootPos ()
		return ply:GetAimVector ():Dot (diff) / diff:Length () >= 0.93
	end
end

function self:PlayerIsInBound (ply, target, distance)
	local distSqr = distance * distance
	
	return ply:GetPos ():DistToSqr (target:GetPos ()) < distSqr
end

local function validateState (ent)
	if ent:IsWeapon () or ent:IsPlayer () or ent:IsNPC () or not IsEntity (ent) or not ent:IsSolid () then
		return false
	end
	
	return true
end

local function engineRendering (self, state)
	if not state then
		return
	end
	
	self:DrawModel ()
end

local _LocalPlayer_ = LocalPlayer or NULL
function self:RenderingInTime ()
	if _LocalPlayer_ == NULL then
		_LocalPlayer_ = LocalPlayer
	end
	
	for _, customEntity in pairs (self.EntityTable ()) do
		if not IsValid (customEntity) or not validateState (customEntity) or string.find (tostring (customEntity), "func_breakable") then
			goto ignoreIteration
		end

		if not self:PlayerIsInBound (_LocalPlayer_ (), customEntity, self.OptimalDistance) and not self.IsObjectInFOV (_LocalPlayer_ (), customEntity:GetPos ()) then
			if self.WeakCache [customEntity] then
				goto ignoreIteration
			end
			
			customEntity:SetNoDraw  (true)
			customEntity:DrawShadow (false)
			customEntity.RenderOverride   = engineRendering (customEntity, false)
			self.WeakCache [customEntity] = true
		else
			customEntity:SetNoDraw  (false)
			customEntity:DrawShadow (true)
			customEntity.RenderOverride   = engineRendering (customEntity, true)
			
			if self.WeakCache [customEntity] then
				self.WeakCache [customEntity] = nil
			end
		end
	
		::ignoreIteration::
	end
end

timer.Simple (0,
	function ()
		if IsValid (LocalPlayer ()) and _LocalPlayer_ == NULL then
			_LocalPlayer_ = LocalPlayer
		end
	end
)

Minuit.MakeGateAway (self, Minuit, self:InternalId ())