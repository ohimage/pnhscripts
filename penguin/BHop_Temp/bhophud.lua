// Please replace thease variables with the ones used by BHop. Since I dont have the full gamemode I used thease simple ones.
local time = 500
local money = 1000
local walkSpeed = 250
// Trapazoid Top Mid
// we be trapn a zoid from plannet hexa
trapazoid1 = {{ },{ },{ },{ }} --create the two dimensional table
trapazoid1[1]["x"] = ScrW() / 2 - 200
trapazoid1[1]["y"] = 0
trapazoid1[2]["x"] = ScrW() / 2 + 200
trapazoid1[2]["y"] = 0
trapazoid1[3]["x"] = ScrW() / 2 + 190
trapazoid1[3]["y"] = 40
trapazoid1[4]["x"] = ScrW() / 2 - 190
trapazoid1[4]["y"] = 40

// LeftCorner hud thingy.
hexagon = {{ },{ },{ },{ },{ },{ }} --create the two dimensional table
hexagon[1]["x"] = 0
hexagon[1]["y"] = ScrH() - 150
hexagon[2]["x"] = 300
hexagon[2]["y"] = ScrH() - 150
hexagon[3]["x"] = 330
hexagon[3]["y"] = ScrH() - 120
hexagon[4]["x"] = 330
hexagon[4]["y"] = ScrH()
hexagon[5]["x"] = 330
hexagon[5]["y"] = ScrH()
hexagon[6]["x"] = 0
hexagon[6]["y"] = ScrH()

local function timeToString(t)
	local minutes = math.floor( t / 60 )
	local seconds = t % 60
	if( seconds < 10 )then
		seconds = "0"..seconds
	end
	return string.format( "%2s:%s", minutes, seconds)
end
timer.Create("BHOP_CountDown",1,0,function()
	time = time - 1;
end)
surface.CreateFont( "Trebuchet20", 30, 400, true, false, "BHOP_TIMER_CDWN", false, false )
local pointer = {{},{},{}}

local function drawBarMesure(Val, MaxVal,x,y, Width, Height, colfor, colback)
	local DrawVal = math.Min(Val / MaxVal, 1)
	DrawVal = math.Max( DrawVal, 0)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawVal)))
	draw.RoundedBox(Border, x , y , Width , Height, colback)
	if( Val > (MaxVal / Width) * 2)then
		draw.RoundedBox(Border, x + 1, y + 1, Width * DrawVal - 2, Height - 2, colfor)
	end
end

hook.Add("HUDPaint","BHOP_HUD_19423",function()
	// Drawing the areas to show stuff on.
	// The timer.
	draw.NoTexture()
	surface.SetDrawColor( 0, 0, 0, 155)
	surface.DrawPoly( trapazoid1 )
	// Bottom left thingy
	surface.SetDrawColor( 0, 0, 0, 230)
	surface.DrawPoly( hexagon )
	
	// Drawing Timer Text
	draw.SimpleText( "Next Map: "..timeToString( time ), "BHOP_TIMER_CDWN",  ScrW() / 2,  0,  Color( 255, 255, 255 ),  TEXT_ALIGN_CENTER )
	// Drawing LocalPlayer's Name:
	draw.SimpleText( LocalPlayer():Name(), "Trebuchet22",  50,  ScrH() - 140,  Color( 255, 255, 255 ),  TEXT_ALIGN_LEFT )
	draw.SimpleText( "Money: "..money, "Trebuchet22",  50,  ScrH() - 100,  Color( 255, 255, 255 ),  TEXT_ALIGN_LEFT )
	local vel = LocalPlayer():GetVelocity()
	local velLen = Vector(0,0,0):Distance( LocalPlayer():GetVelocity() )
	// Drawing Speed:
	drawBarMesure( velLen, walkSpeed, 15, ScrH() - 70, 300, 30, Color(0,100,0,200),Color(0,0,0,255))
	drawBarMesure( velLen - walkSpeed, walkSpeed, 15, ScrH() - 70, 300, 30, Color(100,0,0,255),Color(0,0,0,0))
	draw.SimpleText( "Velocity: "..math.Round(velLen*10)/10, "Trebuchet22",  60,  ScrH() - 67,  Color( 255,255, 255 ),  TEXT_ALIGN_LEFT )
end)
// Profile Image:
HUD_av = vgui.Create("AvatarImage")
HUD_av:SetPos(5,ScrH() - 145)
HUD_av:SetSize(38, 32)
HUD_av:SetPlayer( LocalPlayer(), 32 )

// hide huds we dont want to see.
local tohide = { -- This is a table where the keys are the HUD items to hide
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}
hook.Add("HUDShouldDraw","BHOP_HideHuds",function( name )
	if(tohide[name] == nil or tohide[name] == false)then
		return true
	elseif(tohide[name]==true)then
		return false
	end
end)