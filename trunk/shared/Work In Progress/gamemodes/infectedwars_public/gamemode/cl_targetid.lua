

/*---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
   Desc: Draw the target id (the name of the player you're currently looking at)
---------------------------------------------------------*/
function GM:HUDDrawTargetID()

	local tr = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local MySelf = LocalPlayer()
	
	local text = "ERROR"
	local subtext = ""
	local font = "TargetID"
	local subfont = "InfoSmall"
	
	local isTurret = false
	
	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
		if (MySelf:Team() == TEAM_HUMAN and trace.Entity:Team() == TEAM_HUMAN) then return end
	else
		if trace.Entity:GetClass() == "turret" then
			isTurret = true
			if trace.Entity:GetOwner():IsPlayer() then
				text = trace.Entity:GetTable():NickName()
				subtext = trace.Entity:GetOwner():Nick().."'s turret"
			else
				text = "Unowned turret"
			end
		else
			return
		end
	end
	
	surface.SetFont( subfont )
	local subw, subh = surface.GetTextSize( subtext )
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	local alpha = 255
	local col = Color(0, 0, 255)
	if not isTurret then
		col = self:GetTeamColor( trace.Entity )
	end
	
	if not isTurret and trace.Entity:GetPlayerClass() == 3 and LocalPlayer():Team() == TEAM_HUMAN and 
		trace.Entity:Team() == TEAM_UNDEAD then -- Stalker class
		if trace.Entity:GetVelocity():Length() > 10 then
			alpha = 40
		else
			alpha = 0	
		end
	end
	col.a = alpha
	
	x = x - w / 2
	y = y + 30
	
	if isTurret then
		col = team.GetColor(TEAM_HUMAN)
	end
	
	// The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,alpha/2) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,alpha/4) )
	draw.SimpleText( text, font, x, y, col )
	
	if isTurret then
		x = MouseX - subw / 2
		draw.SimpleText( subtext, subfont, x+1, y+22, Color(0,0,0,alpha/2) )
		draw.SimpleText( subtext, subfont, x+2, y+23, Color(0,0,0,alpha/4) )
		draw.SimpleText( subtext, subfont, x, y+21, col )
	end
	
	y = y + h + 5
	
	if not isTurret and MySelf:Team() == trace.Entity:Team() then
		local text = trace.Entity:Health() .. "%"
		local font = "TargetIDSmall"
		
		surface.SetFont( font )
		local w, h = surface.GetTextSize( text )
		local x =  MouseX  - w / 2
		
		draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,alpha/2) )
		draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,alpha/4) )
		draw.SimpleText( text, font, x, y, col )
	end
	
	col.a = 255 -- for some reason, it changed the alpha of the names in the chatmenu, so change it back
end

