
local Items = {}
local MenuIsOpen = false
local MenuJustClosed = false

local function PowerMenuCreate()

	for k = 0, #HumanPowers do
		PowerAdd( HumanPowers[k].Name, HumanPowers[k].HUDfile, k )
	end
	
end
hook.Add("Initialize","PowerMenuInit",PowerMenuCreate)

function PowerMenuOpen()
	gui.EnableScreenClicker(true) 
	gui.SetMousePos(ScrW()/2,ScrH()/2)
	MenuIsOpen = true
end

function PowerMenuClose()
	if not ENDROUND then
		gui.EnableScreenClicker(false) 
	end
	MenuIsOpen = false
	MenuJustClosed = true
end

function PowerExecute()
	if !PowerGetCurrent() or ENDROUND then return end
	if not MenuIsOpen then return end
	
	local dis = Vector((ScrW()/2),(ScrH()/2),0):Distance(Vector(gui.MouseX(),gui.MouseY(),0))
	if (dis < 10) then return end
	
	local nr = PowerGetCurrent()
	local newPow = Items[nr].Command
	
	PowerMenuClose()

	if newPow == 0 then
		RunConsoleCommand("activate_armor")
	elseif newPow == 1 then
		RunConsoleCommand("activate_speed")
	elseif newPow == 2 then
		RunConsoleCommand("activate_vision")
	elseif newPow == 3 then
		RunConsoleCommand("activate_regen")
	end
	
end

function ActivateArmor()
	local MySelf = LocalPlayer()
	if MySelf:GetPower() == 0 then return end
	MySelf:SetPower( 0 )
	surface.PlaySound(SOUND_POWERACTIVATE)
end
concommand.Add("activate_armor",ActivateArmor) 

function ActivateSpeed()
	local MySelf = LocalPlayer()
	if MySelf:GetPower() == 1 then return end
	if MySelf:SuitPower() <= 0 then return end
	MySelf:SetPower( 1 )
	surface.PlaySound(SOUND_POWERACTIVATE)
	
end
concommand.Add("activate_speed",ActivateSpeed) 

function ActivateVision()
	local MySelf = LocalPlayer()
	if MySelf:GetPower() == 2 then return end
	if MySelf:SuitPower() <= 0 then return end
	MySelf:SetPower( 2 )
	surface.PlaySound(SOUND_POWERACTIVATE)
end
concommand.Add("activate_vision",ActivateVision) 

function ActivateRegen()
	local MySelf = LocalPlayer()
	if MySelf:GetPower() == 3 then return end
	MySelf:SetPower( 3 )
	surface.PlaySound(SOUND_POWERACTIVATE)
end
concommand.Add("activate_regen",ActivateRegen) 

function PowerAdd( powername, file, cmd )
	local item = { Name = powername, File = file, Command = cmd }
	table.insert(Items, item)
end

function PowerGetCurrent()

	local MySelf = LocalPlayer()
	local dis = Vector((ScrW()/2),(ScrH()/2),0):Distance(Vector(gui.MouseX(),gui.MouseY(),0))
	if (dis < 10) then 
		return MySelf:GetPower()+1
	end
	
	local x = gui.MouseX() - ScrW()/2
	local y = gui.MouseY() - ScrH()/2
	
	local count = #Items
	local step = 360 / count
	
	local angle = math.deg(math.atan2(y,-x)) - 270
	if angle < 0 then angle = angle + 360 end
	if angle < 0 then angle = angle + 360 end
	
	local i = math.Round(angle/step) + 1
	if (i > #Items) then 
		i = 1	
	end
	
	return i
end

/*----------------------- needs fixing
CreateClientConVar("_iw_powermenukey", "+use", true, false)
OpenKey = GetConVarString("_iw_powermenukey")

function GM:PlayerBindPress( pl, bind, pressed )
	if (bind == OpenKey and pressed) then
		if #Items > 0 then
			PowerMenuOpen()
		end
	end
	if (bind == OpenKey and not pressed) then
		PowerMenuClose()
	end	
end
---------------------*/

function PowerMenuPaint()
	
	local MySelf = LocalPlayer()
	
	if (MySelf:Team() ~= TEAM_HUMAN) then return end
	if ENDROUND then
		PowerMenuClose()
		return
	end

	if (#Items > 0 and MySelf:KeyDown(IN_USE) and MenuJustClosed == false) then
		if not MenuIsOpen then
			PowerMenuOpen()
		end
	else
		if MenuIsOpen then
			PowerExecute()
			PowerMenuClose()
		end
		-- If we keep holding the menu open key, it would constantly pop up again
		-- So that's why I made the MenuJustClosed var
		if MenuJustClosed and not MySelf:KeyDown(IN_USE) then
			MenuJustClosed = false
		end
	end
	
	if #Items > 0 and MenuIsOpen then
		local count = #Items
		local step = 360 / count
		local current = PowerGetCurrent
		
		surface.SetDrawColor(100,100,255,255)
		if (gui.MouseX() ~= 0 and gui.MouseY() ~= 0) then
			surface.DrawLine((ScrW()/2),(ScrH()/2),gui.MouseX(),gui.MouseY())
		end
	
		local angle = 180
		for i,item in pairs(Items) do
				
			local x = (ScrW()/2) + (math.sin(math.rad(angle)) * 100)
			local y = (ScrH()/2) + (math.cos(math.rad(angle)) * 100)
			
			local color = COLOR_WHITE
			if (Items[PowerGetCurrent()] == item) then
				color = Color(0, 255, 255, 255)
			end
			if (Items[MySelf:GetPower()+1] == item) then
				color = COLOR_HUMAN
			end
			
			local powlogo = surface.GetTextureID( item.File )
	
			surface.SetTexture( powlogo )
			surface.SetDrawColor( color )
			surface.DrawTexturedRect( x-50,y-60,100,100 )
			
			draw.SimpleTextOutlined(item.Name ,"DoomSmall",x,y, color,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, COLOR_BLACK )
		
			angle = angle + step
		end
	end
end
hook.Add("HUDPaint","PowerMenuPaint",PowerMenuPaint)


function PowerMenuMousePress(mc)
	PowerExecute() 
end
hook.Add("GUIMousePressed","PowerMenuMousePress",PowerMenuMousePress)

-- Disable spawn menu
function GM:SpawnMenuEnabled()
	return false	
end

function GM:SpawnMenuOpen()
	return false	
end

function GM:ContextMenuOpen()
	return false	
end


