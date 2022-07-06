if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:PlayerHandler"
end

function self:Constructor ()
	self.Integration = Minuit ["Minuit:Source"]:WeakKeys ()
end

function self:GetResolution ()
	return { Width = ScrW (), Height = ScrH () }
end

function self:GetRefreshRate ()
	local importedResolution = self:GetResolution ()
	
	local width  = importedResolution.Width
	local height = importedResolution.Height
	
	if not width 
	or not height then
		return 0, "Missing resolution."
	end
	
	if type (width)  ~= "number"
	or type (height) ~= "number" then
		width  = tonumber (width)
		height = tonumber (height)
	end
	
	if width <= 1980 and height <= 1080 then
		return 165
	end
	
	if width > 1980 and width <= 2600 and height > 1080 and height <= 1440 then
		return 300
	end
	
	if width > 2500 and height > 1500 then
		return 75
	end
	
	return 165
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())