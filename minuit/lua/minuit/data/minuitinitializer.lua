-- Forensics.Theme = Green
-- Cardinal.Theme  = Blue
-- Bastion.Theme   = Red
-- Minuit.Theme    = Black

local self 			= {}
local MsgC 			= MsgC

function self:InternalId ()
	return "Minuit:Initializer"
end

function self:MiniLogger (appender, _)
	if not appender and type (self) ~= "table" then
		appender = self
	end

	Msg ("\n")
	MsgC (Color (255,255,255), "(", Color (255,0,0), "[!] Minuit | " .. tostring (Minuit ["Minuit:Source"].TimeTracker ()) .. " [!]", Color (255,255,255),"): ", appender)
	Msg ("\n")
end

function self:LoadSubPath ()
	if Minuit ["Minuit:Source"].LoadFile and type (Minuit ["Minuit:Source"].LoadFile) == "table" then
		for incremental = 1, #Minuit ["Minuit:Source"].LoadFile do
			if not Minuit ["Minuit:Source"].LoadFile [incremental] or incremental == 1 then
				goto iterationIsNotValid
			end

			local isServer 	  = Minuit ["Minuit:Source"].ParseCorrectFiles (Minuit ["Minuit:Source"].LoadFile [incremental])
			local correctPath = string.gsub (Minuit ["Minuit:Source"].LoadFile [incremental], "SERVER|", "")
			correctPath		  = string.gsub (correctPath, "CLIENT|", "")
			
			if isServer and SERVER then
				local output = Minuit ["Minuit:Source"].DispatchFiles (correctPath)
				self:MiniLogger (output)
			elseif not isServer then
				local output = Minuit ["Minuit:Source"].DispatchFiles (correctPath)
				self:MiniLogger (output)
			end

			::iterationIsNotValid::
		end
	else
		self:MiniLogger ('!!Could not retrieve element {Minuit ["Minuit:Source"].LoadFile}.')
	end
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())
self:LoadSubPath ()