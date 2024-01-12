local self  = {}
local pairs = pairs

function self:InternalId ()
	return "Minuit:NewLibrary"
end

function self:Constructor ()
	self.SwitchNetworkedLibrary = function ()
		local ENTITY 			= FindMetaTable ("Entity")
		
		ENTITY.SetNWAngle 			= ENTITY.SetNW2Angle
		ENTITY.SetNWBool 			= ENTITY.SetNW2Bool
		ENTITY.SetNWVector 			= ENTITY.SetNW2Vector
		ENTITY.SetNWString 			= ENTITY.SetNW2String
		ENTITY.GetNWAngle 			= ENTITY.GetNW2Angle
		ENTITY.GetNWBool 			= ENTITY.GetNW2Bool
		ENTITY.GetNWVector 			= ENTITY.GetNW2Vector
		ENTITY.GetNWString 			= ENTITY.GetNW2String
		--ENTITY.SetNWEntity 		= ENTITY.SetNW2Entity
		--ENTITY.SetNWFloat 		= ENTITY.SetNW2Float
		--ENTITY.SetNWInt 			= ENTITY.SetNW2Int
		--ENTITY.GetNWEntity 		= ENTITY.GetNW2Entity
		--ENTITY.GetNWFloat 		= ENTITY.GetNW2Float
		--ENTITY.GetNWInt 			= ENTITY.GetNW2Int

		ENTITY.SetNetworkedNumber 	= ENTITY.SetNW2Int
		ENTITY.SetNetworkedEntity 	= ENTITY.SetNW2Entity
		ENTITY.GetNetworkedString 	= ENTITY.GetNW2String
		ENTITY.SetNetworkedInt 		= ENTITY.SetNW2Int
		ENTITY.SetNetworkedBool 	= ENTITY.SetNW2Bool
		ENTITY.SetNetworkedVector 	= ENTITY.SetNW2Vector
		ENTITY.SetNetworkedVar 		= ENTITY.SetNW2Var
		ENTITY.SetNetworkedFloat 	= ENTITY.SetNW2Float
		ENTITY.SetNetworkedString 	= ENTITY.SetNW2String
		ENTITY.GetNetworkedEntity 	= ENTITY.GetNW2Entity
		ENTITY.GetNetworkedBool 	= ENTITY.GetNW2Bool
		ENTITY.GetNetworkedVector 	= ENTITY.GetNW2Vector
		ENTITY.GetNetworkedInt 		= ENTITY.GetNW2Int
		ENTITY.GetNetworkedFloat 	= ENTITY.GetNW2Float
		ENTITY.GetNetworkedVar 		= ENTITY.GetNW2Var
		ENTITY.SetNetworkedAngle 	= ENTITY.SetNW2Angle
		ENTITY.GetNetworkedAngle 	= ENTITY.GetNW2Angle
	end
	
	self.Initiate = function (inBuffer)
		if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
			return
		end
		
		if inBuffer > 35 then -- Gmod being shit.
			-- render.SuppressEngineLighting (true)
		else
			-- render.SuppressEngineLighting (false)
		end
	end
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())