local self			  = {}
local entity 		  = FindMetaTable ("Entity")
local savedRenderMode = savedRenderMode or entity.SetRenderMode
local pairs 		  = pairs

local renderCrossKeyBlock = {
	[3] = true,
	[9] = true,
}
	
function self:Constructor ()
	self.Iterate = function (inBuffer, value)
		for k, v in pairs (inBuffer) do
			if v == value then return true end
		end
		
		return false
	end
end

function self:InternalId ()
	self:Constructor ()
	
	return "Minuit:RenderCross"
end

function entity:SetRenderMode (renderMode)	
	if renderCrossKeyBlock [renderMode] then 
		renderMode = 0 
	end
	
	savedRenderMode (self, renderMode)
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())