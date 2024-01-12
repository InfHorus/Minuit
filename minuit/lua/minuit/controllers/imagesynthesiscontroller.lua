if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:ImageSynthesisC"
end

function self:Constructor ()
	self.OptimalDistance = 2500 * 1.4
	self.EntityTable	 = ents.GetAll
	self.Identifier		 = self:InternalId ()
	
	self.IsPlayerInFOV   = function (ply, endVector)
		local diff = endVector - ply:GetShootPos ()
		return ply:GetAimVector ():Dot (diff) / diff:Length () >= 0.925
	end
end

function self:PlayerIsInBound (ply, target, distance)
	local distSqr = distance * distance
	
	return ply:GetPos ():DistToSqr (target:GetPos ()) < distSqr
end

local _LocalPlayer_ = LocalPlayer or NULL
function self:ImageSynthetizer (ply, numberflag)
	if _LocalPlayer_ == NULL then
		_LocalPlayer_ = LocalPlayer
	end
	
	if ply ~= _LocalPlayer_ () then 
		if not self:PlayerIsInBound (_LocalPlayer_ (), ply, self.OptimalDistance) and not self.IsPlayerInFOV (_LocalPlayer_ (), ply:GetPos ()) then
			ply:AddEFlags  (EFL_DORMANT)
			ply:SetNoDraw  (true)
			ply:DrawShadow (false)
			
			return true
		else
			ply:AddEFlags  (EFL_IN_SKYBOX)
			ply:SetNoDraw  (false)
			ply:DrawShadow (true)
		end
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