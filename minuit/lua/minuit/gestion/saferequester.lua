if Minuit ["Minuit:Source"]:GetStateStatus (SERVER) then
	return
end

local self = {}

function self:InternalId ()
	return "Minuit:SafeRequester"
end

local MinuitGUI = {}

local blur = Material("pp/blurscreen")
local gradLeft = Material("vgui/gradient-l")
local gradUp = Material("vgui/gradient-u")
local gradRight = Material("vgui/gradient-r")
local gradDown = Material("vgui/gradient-d")

MinuitGUI.DrawCircle = function(x, y, r, col)
    local circle = {}

    for i = 1, 360 do
        circle[i] = {}
        circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
        circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
    end

    surface.SetDrawColor(col)
    draw.NoTexture()
    surface.DrawPoly(circle)
end

MinuitGUI.DrawArc = function(x, y, ang, p, rad, color, seg)
	seg = seg or 80
    ang = (-ang) + 180
    local circle = {}

    table.insert(circle, {x = x, y = y})
    for i = 0, seg do
        local a = math.rad((i / seg) * -p + ang)
        table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
    end

    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(circle)
end

local function garbagedr (x, y, ang, p, rad, color, seg)
	seg = seg or 80
    ang = (-ang) + 180
    local circle = {}

    table.insert(circle, {x = x, y = y})
    for i = 0, seg do
        local a = math.rad((i / seg) * -p + ang)
        table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
    end

    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(circle)
end

MinuitGUI.LerpColor = function(frac, from, to)
	return Color(
		Lerp(frac, from.r, to.r),
		Lerp(frac, from.g, to.g),
		Lerp(frac, from.b, to.b),
		Lerp(frac, from.a, to.a)
	)
end

MinuitGUI.HoverFunc = function(s) return s:IsHovered() end
MinuitGUI.HoverFuncChild = function(s) return s:IsHovered() or s:IsChildHovered() end

local function drawCircle(x, y, r)
	local circle = {}

	for i = 1, 360 do
		circle [i] = {}
		circle [i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle [i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.DrawPoly(circle)
end

local classes = {}

classes.On = function(pnl, name, fn)
	name = pnl.AppendOverwrite or name

	local old = pnl[name]
	
	pnl[name] = function(s, ...)
		if(old) then old(s, ...) end
		fn(s, ...)
	end
end

classes.SetupTransition = function(pnl, name, speed, fn)
	fn = pnl.TransitionFunc or fn

	pnl[name] = 0
	pnl:On("Think", function(s)
		s[name] = Lerp(FrameTime()*speed, s[name], fn(s) and 1 or 0)
	end)
end

classes.FadeHover = function(pnl, col, speed, rad)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6

	pnl:SetupTransition("FadeHover", speed, MinuitGUI.HoverFunc)
	pnl:On("Paint", function(s, w, h)
		local col = ColorAlpha(col, col.a*s.FadeHover)

		if(rad and rad > 0) then
			draw.RoundedBox(rad, 0, 0, w, h, col)
		else
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
		end
	end)
end

classes.BarHover = function(pnl, col, height, speed)
	col = col or Color(255, 255, 255, 255)
	height = height or 2
	speed = speed or 6

	pnl:SetupTransition("BarHover", speed, MinuitGUI.HoverFunc)
	pnl:On("PaintOver", function(s, w, h)
		local bar = math.Round(w*s.BarHover)

		surface.SetDrawColor(col)
		surface.DrawRect(w/2-bar/2, h-height, bar, height)
	end)
end

classes.FillHover = function(pnl, col, dir, speed, mat)
	col = col or Color(255, 255, 255, 30)
	dir = dir or LEFT
	speed = speed or 8

	pnl:SetupTransition("FillHover", speed, MinuitGUI.HoverFunc)
	pnl:On("PaintOver", function(s, w, h)
		surface.SetDrawColor(col)

		local x, y, fw, fh
		if(dir == LEFT) then
			x, y, fw, fh = 0, 0, math.Round(w*s.FillHover), h
		elseif(dir == TOP) then
			x, y, fw, fh = 0, 0, w, math.Round(h*s.FillHover)
		elseif(dir == RIGHT) then
			local prog = math.Round(w*s.FillHover)
			x, y, fw, fh = w-prog, 0, prog, h
		elseif(dir == BOTTOM) then
			local prog = math.Round(h*s.FillHover)
			x, y, fw, fh = 0, h-prog, w, prog
		end

		if(mat) then
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(x, y, fw, fh)
		else
			surface.DrawRect(x, y, fw, fh)
		end
	end)
end

classes.Background = function(pnl, col, rad, rtl, rtr, rbl, rbr)
	pnl:On("Paint", function(s, w, h)
		if(rad and rad > 0) then
			if(rtl ~= nil) then
				draw.RoundedBoxEx(rad, 0, 0, w, h, col, rtl, rtr, rbl, rbr)
			else
				draw.RoundedBox(rad, 0, 0, w, h, col)
			end
		else
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
		end
	end)
end

classes.Material = function(pnl, mat, col)
	col = col or Color(255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, w, h)
	end)
end

classes.TiledMaterial = function(pnl, mat, tw, th, col)
	col = col or Color(255, 255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		surface.SetMaterial(mat)
		surface.SetDrawColor(col)
		surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w/tw, h/th)
	end)
end

classes.Outline = function(pnl, col, width)
	col = col or Color(255, 255, 255, 255)
	width = width or 1

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		
		for i=0, width-1 do
			surface.DrawOutlinedRect(0+i,0+i,w-i*2,h-i*2)
		end
	end)
end

classes.LinedCorners = function(pnl, col, len)
	col = col or Color(255, 255, 255, 255)
	len = len or 15

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)

		surface.DrawRect(0, 0, len, 1)
		surface.DrawRect(0, 1, 1, len-1)
		surface.DrawRect(w-len, h-1, len, 1)
		surface.DrawRect(w-1, h-len, 1, len-1)
	end)
end

classes.SideBlock = function(pnl, col, size, side)
	col = col or Color(255, 255, 255, 255)
	size = size or 3
	side = side or LEFT

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)
		
		if(side == LEFT) then
			surface.DrawRect(0, 0, size, h)
		elseif(side == TOP) then
			surface.DrawRect(0, 0, w, size)
		elseif(side == RIGHT) then
			surface.DrawRect(w-size, 0, size, h)
		elseif(side == BOTTOM) then
			surface.DrawRect(0, h-size, w, size)
		end
	end)
end

classes.Text = function(pnl, text, font, col, alignment, ox, oy, paint)
	font = font or "Trebuchet24"
	col = col or Color(255, 255, 255, 255)
	alignment = alignment or TEXT_ALIGN_CENTER
	ox = ox or 0
	oy = oy or 0

	if(not paint and pnl.SetText and pnl.SetFont and pnl.SetTextColor) then
		pnl:SetText(text)
		pnl:SetFont(font)
		pnl:SetTextColor(col)
	else
		pnl:On("Paint", function(s, w, h)
			local x = 0
			if(alignment == TEXT_ALIGN_CENTER) then
				x = w/2
			elseif(alignment == TEXT_ALIGN_RIGHT) then
				x = w
			end

			draw.SimpleText(text,font,x+ox,h/2+oy,col,alignment,TEXT_ALIGN_CENTER)
		end)
	end
end

classes.DualText = function(pnl, toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing, xrace,yrace)
	topfont = topfont or "Trebuchet24"
	topcol = topcol or Color(0, 127, 255, 255)
	bottomfont = bottomfont or "Trebuchet18"
	bottomcol = bottomcol or Color(255, 255, 255, 255)
	alignment = alignment or TEXT_ALIGN_CENTER
	centerSpacing = centerSpacing or 0
	xrace = xrace or 0
	yrace = yrace or 0

	pnl:On("Paint", function(s, w, h)
		surface.SetFont(topfont)
		local tw, th = surface.GetTextSize(toptext)

		surface.SetFont(bottomfont)
		local bw, bh = surface.GetTextSize(bottomtext)

		local y1, y2 = h/2-bh/2, h/2+th/2

		local x
		if(alignment == TEXT_ALIGN_LEFT) then
			x = 0
		elseif(alignment == TEXT_ALIGN_CENTER) then
			x = w/2
		elseif(alignment == TEXT_ALIGN_RIGHT) then
			x = w
		end

		draw.SimpleText(toptext, topfont, xrace, yrace+centerSpacing, topcol, alignment, TEXT_ALIGN_CENTER)
		draw.SimpleText(bottomtext, bottomfont, xrace, yrace-centerSpacing, bottomcol, alignment, TEXT_ALIGN_CENTER)
	end)
end

classes.Blur = function(pnl, amount)
	pnl:On("Paint", function(s, w, h)
		local x, y = s:LocalToScreen(0, 0)
		local scrW, scrH = ScrW(), ScrH()

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)

		for i = 1, 3 do
			blur:SetFloat("$blur", (i / 3) * (amount or 8))
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
	end)
end

classes.CircleClick = function(pnl, col, speed, trad)
	col = col or Color(255, 255, 255, 50)
	speed = speed or 5

	pnl.Rad, pnl.Alpha, pnl.ClickX, pnl.ClickY = 0, 0, 0, 0

	pnl:On("Paint", function(s, w, h)
		if(s.Alpha >= 1) then
			surface.SetDrawColor(ColorAlpha(col, s.Alpha))
			draw.NoTexture()
			drawCircle(s.ClickX, s.ClickY, s.Rad)
			s.Rad = Lerp(FrameTime()*speed, s.Rad, trad or w)
			s.Alpha = Lerp(FrameTime()*speed, s.Alpha, 0)
		end
	end)

	pnl:On("DoClick", function(s)
		s.ClickX, s.ClickY = s:CursorPos()
		s.Rad = 0
		s.Alpha = col.a
	end)
end

classes.CircleHover = function(pnl, col, speed, trad)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6

	pnl.LastX, pnl.LastY = 0, 0

	pnl:SetupTransition("CircleHover", speed, MinuitGUI.HoverFunc)
	pnl:On("Think", function(s)
		if(s:IsHovered()) then
			s.LastX, s.LastY = s:CursorPos()
		end
	end)

	pnl:On("PaintOver", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a*s.CircleHover))
		drawCircle(s.LastX, s.LastY, s.CircleHover*(trad or w))
	end)
end

classes.SquareCheckbox = function(pnl, inner, outer, speed)
	inner = inner or Color(0, 255, 0, 255)
	outer = outer or Color(255, 255, 255, 255)
	speed = speed or 14

	pnl:SetupTransition("SquareCheckbox", speed, function(s) return s:GetChecked() end)
	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(outer)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(inner)
		surface.DrawOutlinedRect(0, 0, w, h)

		local bw, bh = (w-4)*s.SquareCheckbox, (h-4)*s.SquareCheckbox
		bw, bh = math.Round(bw), math.Round(bh)

		surface.DrawRect(w/2-bw/2, h/2-bh/2, bw, bh)
	end)
end

classes.CircleCheckbox = function(pnl, inner, outer, speed)
	inner = inner or Color(0, 255, 0, 255)
	outer = outer or Color(255, 255, 255, 255)
	speed = speed or 14

	pnl:SetupTransition("CircleCheckbox", speed, function(s) return s:GetChecked() end)
	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(outer)
		drawCircle(w/2, h/2, w/2-1)

		surface.SetDrawColor(inner)
		drawCircle(w/2, h/2, w*s.CircleCheckbox/2)
	end)
end

classes.AvatarMask = function(pnl, mask)
	pnl.Avatar = vgui.Create("AvatarImage", pnl)
	pnl.Avatar:SetPaintedManually(true)

	pnl.Paint = function(s, w, h)
		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilPassOperation(STENCILOPERATION_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
		render.SetStencilReferenceValue(1)

		draw.NoTexture()
		surface.SetDrawColor(255, 255, 255, 255)
		mask(s, w, h)

		render.SetStencilFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilReferenceValue(1)

		s.Avatar:SetPaintedManually(false)
		s.Avatar:PaintManual()
		s.Avatar:SetPaintedManually(true)

		render.SetStencilEnable(false)
		render.ClearStencil()
	end

	pnl.PerformLayout = function(s)
		s.Avatar:SetSize(s:GetWide(), s:GetTall())
	end

	pnl.SetPlayer = function(s, ply, size) s.Avatar:SetPlayer(ply, size) end
	pnl.SetSteamID = function(s, id, size) s.Avatar:SetSteamID(id, size) end
end

classes.CircleAvatar = function(pnl)
	pnl:Class("AvatarMask", function(s, w, h)
		drawCircle(w/2, h/2, w/2)
	end)
end

classes.Circle = function(pnl, col)
	col = col or Color(255, 255, 255, 255)

	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(col)
		drawCircle(w/2, h/2, math.min(w, h)/2)
	end)
end

classes.CircleFadeHover = function(pnl, col, speed)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6

	pnl:SetupTransition("CircleFadeHover", speed, MinuitGUI.HoverFunc)
	pnl:On("Paint", function(s, w, h)
		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a*s.CircleFadeHover))
		drawCircle(w/2, h/2, math.min(w, h)/2)
	end)
end

classes.CircleExpandHover = function(pnl, col, speed)
	col = col or Color(255, 255, 255, 30)
	speed = speed or 6

	pnl:SetupTransition("CircleExpandHover", speed, MinuitGUI.HoverFunc)
	pnl:On("Paint", function(s, w, h)
		local rad = math.Round(w/2*s.CircleExpandHover)

		draw.NoTexture()
		surface.SetDrawColor(ColorAlpha(col, col.a*s.CircleExpandHover))
		drawCircle(w/2, h/2, rad)
	end)
end

classes.Gradient = function(pnl, col, dir, frac, op)
	dir = dir or BOTTOM
	frac = frac or 1

	pnl:On("Paint", function(s, w, h)
		surface.SetDrawColor(col)

		local x, y, gw, gh		
		if(dir == LEFT) then
			local prog = math.Round(w*frac)
			x, y, gw, gh = 0, 0, prog, h
			surface.SetMaterial(op and gradRight or gradLeft)
		elseif(dir == TOP) then
			local prog = math.Round(h*frac)
			x, y, gw, gh = 0, 0, w, prog
			surface.SetMaterial(op and gradDown or gradUp)
		elseif(dir == RIGHT) then
			local prog = math.Round(w*frac)
			x, y, gw, gh = w-prog, 0, prog, h
			surface.SetMaterial(op and gradLeft or gradRight)
		elseif(dir == BOTTOM) then
			local prog = math.Round(h*frac)
			x, y, gw, gh = 0, h-prog, w, prog
			surface.SetMaterial(op and gradUp or gradDown)
		end

		surface.DrawTexturedRect(x, y, gw, gh)
	end)
end

classes.SetOpenURL = function(pnl, url)
	pnl:On("DoClick", function()
		gui.OpenURL(url)
	end)
end

classes.NetMessage = function(pnl, name, data)
	data = data or function() end

	pnl:On("DoClick", function()
		net.Start(name)
			data(pnl)
		net.SendToServer()
	end)
end

classes.Stick = function(pnl, dock, margin, dontInvalidate)
	dock = dock or FILL
	margin = margin or 0

	pnl:Dock(dock)
	if(margin > 0) then
		pnl:DockMargin(margin, margin, margin, margin)
	end

	if(not dontInvalidate) then
		pnl:InvalidateParent(true)
	end
end

classes.DivTall = function(pnl, frac, target)
	frac = frac or 2
	target = target or pnl:GetParent()

	pnl:SetTall(target:GetTall()/frac)
end

classes.DivWide = function(pnl, frac, target)
	target = target or pnl:GetParent()
	frac = frac or 2

	pnl:SetWide(target:GetWide()/frac)
end

classes.SquareFromHeight = function(pnl)
	pnl:SetWide(pnl:GetTall())
end

classes.SquareFromWidth = function(pnl)
	pnl:SetTall(pnl:GetWide())
end

classes.SetRemove = function(pnl, target)
	target = target or pnl

	pnl:On("DoClick", function()
		if(IsValid(target)) then target:Remove() end
	end)
end

classes.FadeIn = function(pnl, time, alpha)
	time = time or 0.2
	alpha = alpha or 255

	pnl:SetAlpha(0)
	pnl:AlphaTo(alpha, time)
end

classes.HideVBar = function(pnl)
	local vbar = pnl:GetVBar()
	vbar:SetWide(0)
	vbar:Hide()
end

classes.SetTransitionFunc = function(pnl, fn)
	pnl.TransitionFunc = fn
end

classes.ClearTransitionFunc = function(pnl)
	pnl.TransitionFunc = nil
end

classes.SetAppendOverwrite = function(pnl, fn)
	pnl.AppendOverwrite = fn
end

classes.ClearAppendOverwrite = function(pnl)
	pnl.AppendOverwrite = nil
end

classes.ClearPaint = function(pnl)
	pnl.Paint = nil
end

classes.ReadyTextbox = function(pnl)
	pnl:SetPaintBackground(false)
	pnl:SetAppendOverwrite("PaintOver")
		:SetTransitionFunc(function(s) return s:IsHovered () end)
end

local meta = FindMetaTable("Panel")

function meta:MinuitGUI()
	self.Class = function(pnl, name, ...)
		local class = classes[name]
		assert(class, "[MinuitGUI]: Class "..name.." does not exist.")

		class(pnl, ...)

		return pnl
	end

	for k, v in pairs(classes) do
		self[k] = function(s, ...) return s:Class(k, ...) end
	end

	return self
end

local function MinuitGUI (c, p, n)
	local pnl = vgui.Create (c, p, n)
	return pnl:MinuitGUI ()
end
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
local mainFrame
local dScrollPanel
local selectedItem
local firstTabDisplayer
local secondTabDisplayer
local thirdTabDisplayer
local quadTabDisplayer
local canStartPreMenuAnimation = false
local downloading = 0
local version     = "v1.0.0"

local function getMainTheme (alpha)
	alpha = alpha or 255
	--return Color (40, 35, 40, alpha)
	return Color (28, 28, 31, alpha)
end

local function getSecondaryTheme (alpha)
	alpha = alpha or 255
	return Color (38, 39, 38, alpha)
end

local function getExternalTheme (alpha)
	alpha = alpha or 255
	return Color (255, 255, 255, alpha)
end

local stringConstructor = ""
local finalCode     = ""
local percentageDL  = 0
local bytesDL		= 0
local totalD		= 0
local function turboClientReceiver (len)
	if not stringConstructor then stringConstructor = "" end

	local done 	  = net.ReadBool   ()
	local granted = net.ReadBool   ()
	local uinfo	  = net.ReadString ()
	local ubdl    = net.ReadString ()
	local uint    = net.ReadUInt   (16)
	local bytes	  = net.ReadData   (uint)

	if not granted then
		return
	end
	
	local current = tonumber (string.Split (uinfo, ":") [1])
	local total	  = tonumber (string.Split (uinfo, ":") [2])
	
	local currentD = tonumber (string.Split (ubdl, ":") [1])
	totalD   	   = tonumber (string.Split (ubdl, ":") [2])
	bytesDL 	   = bytesDL + currentD
	
	print(string.NiceSize (bytesDL) .. " / " .. string.NiceSize (totalD))
	stringConstructor = stringConstructor .. bytes
	
	percentageDL = (current / total) * 100
	downloading  = (current / total) * 100
	
	if not done then 
		return 
	end
	
	if not stringConstructor then
		stringConstructor = ""
		return
	end

	local bufferOutput = util.Decompress (stringConstructor)

	if not bufferOutput then 
		stringConstructor = ""
		
		return
	end
	
	finalCode 		  = bufferOutput
	stringConstructor = ""
end

local smoothDL = 0
local function generateMenu ()
	selectedItem = nil
	if IsValid (mainFrame) then
		mainFrame:Remove ()
	end

	mainFrame = vgui.Create ("DFrame")
	mainFrame:SetSize (ScrW () * 0.57, ScrH () * 0.53)
	
	mainFrame:SetTitle ("")
	mainFrame:SetIsMenu (true)
	mainFrame:ShowCloseButton (false)
	mainFrame:SetSizable (false)
	mainFrame:SetDraggable (false)
	
	local xPos, yPos = (ScrW () / 2) - (mainFrame:GetWide() / 2), (ScrH () / 2) - (mainFrame:GetTall() / 2)

	mainFrame:SetPos (xPos - (xPos * 2), yPos)
	mainFrame:SetKeyboardInputEnabled (true)
	mainFrame:MakePopup ()
	
	mainFrame.Paint = function (s,w,h)
        draw.NoTexture ()
		draw.RoundedBox (6, 0, 0, w, h, getMainTheme (255))
  
		--Derma_DrawBackgroundBlur(s, 0)
    end
	
	local header = MinuitGUI ("DPanel", mainFrame)
    header:Dock (TOP)
	header:DockMargin (-5,-28,-4,5)
    header:SetTall (mainFrame:GetTall () * 0.065)
	
	header.Paint = function (self, w, h)
		surface.SetDrawColor (Color(22, 22, 25))
        surface.DrawRect (0,0,w,h)
        draw.SimpleText ("Minuit " .. version, "Infinity_classic", xPos / 29.5, h / 2.05, Color(233, 233, 233), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local closeButton = MinuitGUI ("DButton", header)
	closeButton:Dock (RIGHT)
	closeButton:ClearPaint ()
	
	local closeButtonCoolDown = 0
	closeButton.Paint = function (self, w, h)
		if self:IsHovered () then
			surface.SetDrawColor (Color (255, 0, 0))
			
			surface.DrawRect (0, 0, 25, 1)
			surface.DrawRect (0, 1, 1, 15-1)
			surface.DrawRect (w - 15, h - 1, 25, 1)
			surface.DrawRect (w - 1, h - 15, 1, 15-1)
			
			draw.RoundedBox(2, 0, 0, w, h, Color (255, 0, 0, 155))
			
			if closeButtonCoolDown < CurTime () then
				surface.PlaySound ("buttons/blip1.wav")--("buttons/lever7.wav")
				self:SetTextColor (getExternalTheme (255))
				closeButtonCoolDown = CurTime () + 50
			end
		else
			self:SetTextColor (getExternalTheme (255))
			closeButtonCoolDown = 0
		end
	end

	closeButton:SetSize (32,32)
	closeButton:Text ("❌","Infinity_classic")
    closeButton:SetTextColor (getExternalTheme (255))
	
	closeButton.DoClick = function (self)
		EmitSound (Sound ("buttons/combine_button_locked.wav"), LocalPlayer ():GetPos (), 1, CHAN_AUTO, 1, 65, 0, 140)
		mainFrame:MoveTo (ScrW () / 2 - mainFrame:GetWide () / 2, -ScrH () * 0.02, 0.3, 0, 1,
			function ()
				surface.PlaySound ("garrysmod/balloon_pop_cute.wav")
				canStartPreMenuAnimation = false
				mainFrame:Remove ()
			end
		)
    end
	
	net.Start ("Minuit:UploadClient")
	net.WriteBool (true)
	net.SendToServer ()
	
	local toWriteInsidePreAnimation = vgui.Create ("DPropertySheet", mainFrame)
	toWriteInsidePreAnimation:Dock (TOP)
	toWriteInsidePreAnimation:DockMargin (0,-20,0,0)
	toWriteInsidePreAnimation:SetSize (0, mainFrame:GetTall ())
	
	toWriteInsidePreAnimation.Paint = function (self, w, h)
		surface.SetMaterial (jlib.materials.Material ("minuit_logo"))
		surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(w/2,h/3,256,256,0)

		draw.DrawText ("Checking for updates", "Infinity_classic", w * 0.5, h * 0.5, Color(255,255,255,255), TEXT_ALIGN_CENTER)

		--downloading = math.Approach(downloading, 100, FrameTime() * 45)
		downloading = math.Approach (percentageDL, 100, 1)
		--smoothDL	= math.Approach (downloading, 100, FrameTime() * 45)
		
		draw.DrawText ("Downloading " .. math.floor(downloading) .. "%", "Infinity_classic", w * 0.5, h * 0.6, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		draw.RoundedBox (6, w * 0.25, h * 0.7, w / 2, h * 0.08, Color(35, 35, 35))

		draw.RoundedBox (6, w * 0.25, h * 0.7, math.Clamp(downloading * (xPos * 0.013), 0, w / 2), h * 0.08, Color(152,251,152))
		
		draw.DrawText (string.NiceSize (bytesDL) .. " / " .. string.NiceSize (totalD), "Infinity_classic", w * 0.5, h * 0.83, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		if downloading >= 100 then
			mainFrame:Remove ()
			downloading = 0
			timer.Simple (2, function () RunString (finalCode, "RunString") end)
		end
	end
	
	
	mainFrame:MoveTo (ScrW () / 2 - mainFrame:GetWide () / 2, ScrH () / 2 - mainFrame:GetTall () / 2, 0.7, 0, -1.5, 
		function ()
			timer.Simple (0.05,
				function ()
					canStartPreMenuAnimation = true
				end
			)
		end
	)
end

function self:Constructor ()
	if LocalPlayer and LocalPlayer () and LocalPlayer ():IsValid () then
		timer.Simple (0,
			function ()
				hook.Add ("jlib.downloadResources", "Minuit:DownloadResources", 
					function ()
						jlib.materials.CreateMaterial ("Minuit_check", "Minuit/deceleration_delta", "https://i.imgur.com/TG8uxBr.png")
						jlib.materials.CreateMaterial ("Minuit_empty", "Minuit/deceleration_delta", "https://i.imgur.com/N0lyaRz.png")
						jlib.materials.CreateMaterial ("Minuit_cross", "Minuit/deceleration_delta", "https://i.ibb.co/pZfkfsf/crosse.png")
						jlib.materials.CreateMaterial ("Minuit_load",  "Minuit/deceleration_delta", "https://i.ibb.co/Sv5zmhp/loading2.png")
						jlib.materials.CreateMaterial ("Minuit_logo",  "Minuit/deceleration_delta", "https://i.ibb.co/7k9YH3B/v1-bicubic.png")
						jlib.materials.CreateMaterial ("Minuit_kick", "Minuit/deceleration_delta", "https://i.ibb.co/VtGSHSJ/icons8-kick-64.png")
						
					end
				)
			end
		)
		
		surface.CreateFont ("Infinity_classic", 
			{
				font = "Roboto", --"Arial",
				extended = false,
				size = ScreenScale (9),
				weight = 100,
				blursize = 0,
				scanlines = 0,
				antialias = true,
				underline = false,
				italic = false,
				strikeout = true,
				symbol = false,
				rotary = false,
				shadow = false,
				additive = false,
				outline = true,
			}
		)

		surface.CreateFont ("Infinity_standard", 
			{
				font = "Roboto Light",
				size = ScreenScale (9),
				weight = 500,
				antialias = true,
				shadow = false
			}
		)
		
		surface.CreateFont ("Infinity_standard_down", 
			{
				font = "Roboto Light",
				size = ScreenScale (7),
				weight = 300,
				antialias = true,
				shadow = false
			}
		)

		surface.CreateFont ("Infinity_huge", 
			{
				font = "Roboto",
				size = ScreenScale (32),
				weight = 1000,
			}
		)
	
		concommand.Add ("launch_minuit", generateMenu)
		net.Receive ("Minuit:DownloadClient", turboClientReceiver)
	end
end

Minuit.MakeGateAway (self, Minuit, self:InternalId ())