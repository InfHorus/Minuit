local self = {}

local pGetCount = player.GetCount

function self:InternalId ()
	return "Minuit:TimerEntry"
end

function self:Constructor ()
	self.TimerHandler = Minuit ["Minuit:Source"]:WeakKeys ()
	
	self.TimerHandler.Create = {}
	
	self.TimerHandler.FormatTime = function (duration)
		if duration > 60 then
			local minutes = duration / 60

			return string.format ("%.3g minute%s", minutes, minutes == 1 and "" or "s")
		else
			local seconds = duration

			return string.format ("%.3g second%s", seconds, seconds == 1 and "" or "s")
		end
	end
end

function self:CreateTimer (id, delay, callback)
	if not self.TimerHandler.Create then
		return
	end
	
	if not self.TimerHandler.Create [id] then
		self.TimerHandler.Create [id] = {delay, callback, delay}
	end
end

function self:RemoveTimer (id)
	if self and self.TimerHandler and self.TimerHandler.Create then
		if self.TimerHandler.Create [id] then
			self.TimerHandler.Create [id] = nil
		end
	end
end

function self:GetTimeLeft (id)
	if self and self.TimerHandler and self.TimerHandler.Create then
		if self.TimerHandler.Create [id] then
			return tonumber (math.abs (CurTime () - self.TimerHandler.Create [id] [1]))
		end
	end
end

function self:GetFormattedTimeLeft (id)
	if self and self.TimerHandler and self.TimerHandler.Create then
		if self.TimerHandler.Create [id] then
			return self.TimerHandler.FormatTime (tonumber (math.abs (CurTime () - self.TimerHandler.Create [id] [1])))
		end
	end
end

function self:ExecuteTimers ()
	if self.TimerHandler.Create then
		for id, array in pairs (self.TimerHandler.Create) do
			if self.TimerHandler.Create [id] [1] < CurTime () then
				if self.TimerHandler.Create [id] [2] and type (self.TimerHandler.Create [id] [2]) == "function" then
					self.TimerHandler.Create [id] [2] ()
				end
			
				self.TimerHandler.Create [id] [1] = CurTime () + self.TimerHandler.Create [id] [3]
			end
		end
	end
	
	if Minuit ["Minuit:EventHandler"] and Minuit ["Minuit:EventHandler"].HookManager.RefreshRate then
		if pGetCount () > 50 and pGetCount () < 65 then
			Minuit ["Minuit:EventHandler"].HookManager.RefreshRate = 0.1
			
			timer.Adjust ("Minuit:HandleWorldEvents", Minuit ["Minuit:EventHandler"].HookManager.RefreshRate)
		elseif pGetCount () >= 65 and pGetCount () < 90 then
			Minuit ["Minuit:EventHandler"].HookManager.RefreshRate = 0.35
			
			timer.Adjust ("Minuit:HandleWorldEvents", Minuit ["Minuit:EventHandler"].HookManager.RefreshRate)
		elseif pGetCount () >= 90 then
			Minuit ["Minuit:EventHandler"].HookManager.RefreshRate = 0.65
			
			timer.Adjust ("Minuit:HandleWorldEvents", Minuit ["Minuit:EventHandler"].HookManager.RefreshRate)
		end
	end
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())