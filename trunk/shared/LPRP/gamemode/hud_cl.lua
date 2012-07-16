// Clientside HUD thingy.
local surface = surface
local draw = draw
require( "datastream" )

// ConVariable
CreateClientConVar("LPRP_HUD_TextSpeed", "1", true, false)

local w = ScrW()
local h = ScrH()
local hx, hy = 0, h - 70
local lply = LocalPlayer
local noticesFont = "Trebuchet22"

trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
--First Vertex
trianglevertex[1]["x"] = 0
trianglevertex[1]["y"] = hy
trianglevertex[1]["u"] = 0 //Top Left
trianglevertex[1]["v"] = 0

trianglevertex[2]["x"] = hx + 200
trianglevertex[2]["y"] = hy
trianglevertex[2]["u"] = 0 //Top Left
trianglevertex[2]["v"] = 0

--Second Vertex
trianglevertex[3]["x"] = hx + 230
trianglevertex[3]["y"] = hy + 30
trianglevertex[3]["u"] = 1 //Top Right
trianglevertex[3]["v"] = 0

--Third Vertex
trianglevertex[4]["x"] = 0
trianglevertex[4]["y"] = hy + 30
trianglevertex[4]["u"] = 0 //Bottom Left
trianglevertex[4]["v"] = 1

local messages = {}
/*
message data structure:
m = {}
m.c = Color()
m.p = Position
m.txt = "string of text"
m.len = "the size in pixels of that text"
*/
local function _drawNotices(x,y,font)
	local remove = nil
	for k,v in ipairs( messages )do
		draw.DrawText( v.txt,  font,  x + v.p,  y , v.c, TEXT_ALIGN_LEFT )
	end
end

hook.Add("Think","LPRP_HUD_Scroll",function()
	
end)

LPRP._addNotice = function(text, col, padding)
	local msg = {}
	msg.c = col
	msg.txt = text
	surface.SetFont( noticesFont )
	msg.len = surface.GetTextSize( text ) + padding
	local lensum = 0
	for k,v in pairs(messages)do
		lensum = lensum + v.len
	end
	msg.p = w + lensum 
	table.insert(messages, msg)
end

LPRP.addNotice = function(tbl)
	LPRP._addNotice( "",Color(0,0,0),50)
	local col = Color(155,155,155,255)
	for k,v in ipairs(tbl)do
		if(type(v) == "table")then
			col = v
		elseif(type(v) == "Player")then
			LPRP._addNotice( v:Nick(), team.GetColor( v:Team() ),0)
		elseif(type(v) == "Entity")then
			LPRP._addNotice( v:GetClass(), Color(200,0,0),0)
		elseif(type(v) == "string")then
			LPRP._addNotice( v , col,0)
		end
	end
	LPRP._addNotice( "",Color(0,0,0),50)
end

local function PHUDNoticeHandler( a3, a2, a1, tbl)
	if(tbl != nil and type(tbl) == "table")then
		LPRP.addNotice( tbl )
	end
end
datastream.Hook( "LPRP_Notify", PHUDNoticeHandler)

concommand.Add("HudNoticeTest",function( ply, cmd, args)
	LPRP._addNotice( args[1], Color( math.random(1, 255),math.random(1, 255),math.random(1, 255),255),50) 
end)
local function drawBarMesure(Val, MaxVal,x,y, Width, Height, colfor, colback)
	local DrawVal = math.Min(Val / MaxVal, 1)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawVal)))
	draw.RoundedBox(Border, x , y , Width , Height, colback)
	draw.RoundedBox(Border, x + 1, y + 1, Width * DrawVal - 2, Height - 2, colfor)
end
local lastMoney = 0
local function drawInfo()
	// Name
	draw.DrawText(  "Name: "..lply():Nick(),  "Trebuchet18",  hx + 15,  hy + 5,  Color(255,255,255,255), TEXT_ALIGN_LEFT )
	
	// Health Bar
	drawBarMesure( lply():Health(), 100, hx + 200, hy + 37, 200, 25, Color(255,0,0,255),Color(0,0,0,255))
	// Ammo
	local gun = lply():GetActiveWeapon( )
	if(ValidEntity( gun ))then
		local ammo1 = gun:Clip1()
		local ammo2 = gun:Clip2()
	end
	// Money
	local dispMon = ( lastMoney * 9  + LPRP:GetMoney() )/ 10
	draw.DrawText(  "Money: $"..tostring( math.Round(dispMon) ),  "Trebuchet24",  hx + 20,  hy + 40,  Color(255,255,255,255), TEXT_ALIGN_LEFT )
	lastMoney = dispMon
end
local lastNoticeBarPos = 0

local hudPlugins = {}
function GM:HUDPaint()
	local goal = nil
	if(#messages == 0)then
		goal = 100
	else
		goal = 1
	end
	
	local noticeBarPos = (lastNoticeBarPos*19 + goal) / 20
	// compleatly black area for scrolling text later.
	surface.SetDrawColor(  0,  0,  0,  175 )
	surface.DrawRect( hx + 200, hy + noticeBarPos,  w - 200,  30 )
	lastNoticeBarPos = noticeBarPos
	
	// The gray bar at the very bottom.
	surface.SetDrawColor(  50,  50,  50,  255 )
	surface.DrawRect(  hx, hy + 30,  w,  40 )
	
	// drawing in the text.
	_drawNotices(200,h - 67,noticesFont)
	// Draw the name spot thingy.
	draw.NoTexture()
	surface.SetDrawColor( 70, 70, 70, 255)
	surface.DrawPoly( trianglevertex )
	
	drawInfo()
	
	// Move the ScrollText
	local speed = GetConVarString( "LPRP_HUD_TextSpeed" )
	local remove = nil
	for k,v in ipairs(messages)do
		v.p = v.p - speed
		if(v.p < -v.len)then
			remove = k
		end
	end
	if( remove != nil)then
		table.remove(messages, remove)
	end
	for k,v in pairs( hudPlugins )do
		pcall( v )
	end
	//self.BaseClass:HUDPaint()
end
function LPRP:RegisterHudPlugin( name, func )
	hudPlugins[ name ] = func
end
local tohide = { -- This is a table where the keys are the HUD items to hide
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudChat"] = false
}
function GM:HUDShouldDraw(name)
	if(tohide[name] == nil)then
		return true
	elseif(tohide[name]==true)then
		return false
	end
	return true
end

function GM:HUDAmmoPickedUp( itemname, amount )
	LPRP.addNotice( {Color(200,200,200,255),"You picked up "..amount.." ammo for "..itemname } )
end

