/*------------
Infected Wars
cl_hud.lua
Clientside
------------*/

local textureBullet = surface.GetTextureID("infectedwars/bullet")
local turretTexture = surface.GetTextureID("killicon/infectedwars/turret")
local timeblock = surface.GetTextureID( "infectedwars/timeblock" )
local timeborder = surface.GetTextureID( "infectedwars/HUD/HUDtimer_rev2" )
local undlogo = surface.GetTextureID( "infectedwars/undeadlegion" )
local humlogo = surface.GetTextureID( "infectedwars/specialforces" )

/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
---------------------------------------------------------*/
local undwin = UNDEADWINLIST[math.random(#UNDEADWINLIST)]
local humwin = HUMANWINLIST[math.random(#HUMANWINLIST)]
DrawCrHair = true

function GM:HUDPaint()
	
	if not HUD_ON then return end
	
	local MySelf = LocalPlayer()
	
	/*--------------------------------------------------
				Draw teammate/identified locations
	---------------------------------------------------*/

	local idList = {}
	for k, v in pairs(player.GetAll()) do
		if (ValidEntity(v) and (v:Team() == TEAM_HUMAN or v.Detectable) and v:IsValid() and v:Alive() and v ~= LocalPlayer()) then
			idList[#idList+1] = { Obj = v, ID = v:Name() }
		end
	end
	
	if (MySelf:Team() == TEAM_HUMAN and MySelf:IsValid() and MySelf:Alive() and not ENDROUND) then
	
		local target
		local pos
		local pl
		local dis
		local disToMiddle
		local alpha
		local mypos = MySelf:GetPos()
		local hp
		local maxhp
		local col = COLOR_GREEN
		local ratio = 1
		local enemy
		
		function ScaleAlpha( color, amount )
			return Color(color.r, color.g, color.b, amount)
		end
		
		
		for k=1, #idList do
			target = idList[k].Obj:GetPos()+Vector(0,0,50)
			pl = idList[k].Obj
			hp = pl:Health()
			maxhp = pl:GetMaximumHealth()
			enemy = (idList[k].Obj:Team() ~= MySelf:Team())

			pos = target:ToScreen()
			dis = math.floor(target:Distance(mypos))
			disToMiddle = Vector(pos.x-w/2,pos.y-h/2,0):Length()
			alpha = math.min(255,math.max(0,255*50/disToMiddle))
			if (dis < 1500) then
				SCALEBLACK = ScaleAlpha(COLOR_BLACK,alpha)
				surface.SetDrawColor( SCALEBLACK )
				surface.DrawLine( pos.x - 16, pos.y - 16, pos.x - 16, pos.y + 16 ) -- left
				surface.DrawLine( pos.x + 16, pos.y - 16, pos.x + 16, pos.y + 16 ) -- right
				surface.DrawLine( pos.x - 23, pos.y - 16, pos.x + 23, pos.y - 16 ) -- top
				surface.DrawLine( pos.x - 23, pos.y + 16, pos.x + 23, pos.y + 16 ) -- bottom
				surface.DrawLine( pos.x - 23, pos.y - 16, pos.x - 23, pos.y + 16 ) -- more left
				surface.DrawLine( pos.x + 23, pos.y - 16, pos.x + 23, pos.y + 16 ) -- more right
				
				if enemy then
					col = COLOR_UNDEAD
					draw.SimpleTextOutlined("UNDEAD TARGET","InfoMedium",pos.x,pos.y+17,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, SCALEBLACK)
					draw.SimpleTextOutlined("X","InfoSmall",pos.x,pos.y,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, SCALEBLACK)
					surface.SetDrawColor( Color(200,20,20,100) )
					surface.DrawRect( pos.x - 20,  pos.y - 14, 3, 28 )
					surface.DrawRect( pos.x + 18,  pos.y - 14, 3, 28 )
				else
					col = ScaleAlpha(COLOR_HURT1,alpha)
					if (hp <= 0.25*maxhp) then col = ScaleAlpha(COLOR_HURT4,alpha)
					elseif (hp <= 0.5*maxhp) then col = ScaleAlpha(COLOR_HURT3,alpha)
					elseif (hp <= 0.75*maxhp) then col = ScaleAlpha(COLOR_HURT2,alpha)
					end
					surface.SetDrawColor( col )
					ratio = math.Clamp(hp/maxhp,0,1)
					surface.DrawRect( pos.x - 20,  pos.y + 14-math.Round((28*ratio)), 3, math.Round(28*ratio) )
					surface.DrawRect( pos.x + 18,  pos.y + 14-math.Round((28*ratio)), 3, math.Round(28*ratio) )
					col = ScaleAlpha(COLOR_HUMAN,alpha)
					draw.SimpleTextOutlined(idList[k].ID,"InfoMedium",pos.x,pos.y+17,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, SCALEBLACK)
					draw.SimpleTextOutlined(tostring(hp),"InfoSmall",pos.x,pos.y,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, SCALEBLACK)
				end
				draw.SimpleTextOutlined("Distance: "..dis,"InfoSmall",pos.x,pos.y+40,col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, SCALEBLACK)
				
			end
		end

	end
	
	/*--------------- Draw endround -----------*/
	if ENDROUND then 
	
		GAMEMODE:DrawDeathNotice( 0.82, 0.04 )
		
		local toDraw = ""
		local displayCol = team.GetColor( self.TeamThatWon )
		
		local tab = {}
		tab[1] = { StatsUndKiller, "Most undead killed by ", "No undead were harmed this round" }
		tab[2] = { StatsHumKiller, "Most humans killed by ", "No humans died this round (wtf O_o)" }
		tab[3] = { StatsUndDmg, "Most damage done to undead by ", "Pussy humans failed to damage the undead" }
		tab[4] = { StatsHumDmg, "Most damage done to humans by ", "Undead couldn't even scratch the humans" }
		tab[5] = { StatsMostSocial, "Most social player was ", "No social player, you're all egocentric dicks" }
		tab[6] = { StatsMostScary, "Most scary player was ", "There were no scary players, you're all pussies" }
		tab[7] = { StatsMostUnlucky, "Most unlucky player was ", "You were all lucky" }
		
		local adv = stattimer-CurTime()
		if (statsreceived) then
			for k=1, #tab do
				if adv < (#tab)-k then
					local str = tab[k][2]..tab[k][1]
					if tab[k][1] == "-" then
						str = tab[k][3]
					end
					draw.SimpleTextOutlined(str, "EndRoundStats", w/2, h/2-270+k*30, displayCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
				end
			end
		end
		
		local tab = {}
		tab[1] = { StatsRoundKills, "Total kills this round: " }
		tab[2] = { StatsRoundDamage, "Total damage this round: " }
		
		if (statsreceived) then
			for k=1, #tab do
				if adv < (#tab)-k then
					draw.SimpleTextOutlined(tab[k][2]..tab[k][1], "DoomMedium", w/2, h/2+12+k*30, displayCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
				end
			end
		end
		
		if (self.TeamThatWon == TEAM_UNDEAD) then
			toDraw = undwin
		else
			toDraw = humwin
		end
		
		draw.SimpleTextOutlined(toDraw, "DoomLarge", w/2, h/2, displayCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
		
		// Show voting thingies
		if not self.ShowVoting then return end
		
		local m_x, m_y = gui.MouseX(), gui.MouseY()
		local mousepressed = input.IsMouseDown(MOUSE_LEFT)
		local hasvoted = (MySelf.Voted > 0)
		
		local initBox = false
		if not VoteBox then
			initBox = true
			VoteBox = {}
		end
		
		local drawCol = COLOR_GRAY
		
		local str = "VOTE (click one)"
		if hasvoted then
			str = "NOW WAIT"
		end
		draw.SimpleTextOutlined(str, "DoomSmall", w/2, h/2+90, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		
		local y = 0
		local vx, vy
		if self.CanRestart then
			str = "Restart round"
			if MySelf.Voted == 1 then
				str = "-> "..str.." <-"
			end
			if initBox then
				vx, vy = surface.GetTextSize( str )
				table.insert(VoteBox,{ x = (w/2-vx/2), y = (h/2+115+y*40), w = vx, h = vy }) 
			end
			if (VoteBox[1].x < m_x and VoteBox[1].x+VoteBox[1].w > m_x and VoteBox[1].y < m_y and VoteBox[1].y+VoteBox[1].h > m_y) then
				drawCol = COLOR_WHITE
				if mousepressed and not hasvoted then
					print("Voting for restart round")
					MySelf.Voted = 1
					RunConsoleCommand("vote_map_choice",1)
				end
			end
			draw.SimpleTextOutlined(str, "InfoSmall", w/2, h/2+115+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
			draw.SimpleTextOutlined(string.rep("X",MapVotes.curMap), "InfoSmall", w/2, h/2+134+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
			y = y+1
			drawCol = COLOR_GRAY
		else
			// quick hacky solution so it doesn't complain about indices further on
			if initBox then
				table.insert(VoteBox,{})
			end
		end
		
		str = "Map "..self.NextMap
		if MySelf.Voted == 2 then
			str = "-> "..str.." <-"
		end
		if initBox then
			vx, vy = surface.GetTextSize( str )
			table.insert(VoteBox,{ x = (w/2-vx/2), y = (h/2+115+y*40), w = vx, h = vy }) 
		end
		if (VoteBox[2].x < m_x and VoteBox[2].x+VoteBox[2].w > m_x and VoteBox[2].y < m_y and VoteBox[2].y+VoteBox[2].h > m_y) then
			drawCol = COLOR_WHITE
			if mousepressed and not hasvoted then
				//print("Voting for next map")
				MySelf.Voted = 2
				RunConsoleCommand("vote_map_choice",2)
			end
		end
		draw.SimpleTextOutlined(str, "InfoSmall", w/2, h/2+115+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		draw.SimpleTextOutlined(string.rep("X",MapVotes.nextMap), "InfoSmall", w/2, h/2+134+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		y = y+1
		drawCol = COLOR_GRAY
		
		str = "Map "..self.SecondNextMap
		if MySelf.Voted == 3 then
			str = "-> "..str.." <-"
		end
		if initBox then
			vx, vy = surface.GetTextSize( str )
			table.insert(VoteBox,{ x = (w/2-vx/2), y = (h/2+115+y*40), w = vx, h = vy }) 
		end
		if (VoteBox[3].x < m_x and VoteBox[3].x+VoteBox[3].w > m_x and VoteBox[3].y < m_y and VoteBox[3].y+VoteBox[3].h > m_y) then
			drawCol = COLOR_WHITE
			if mousepressed and not hasvoted then
				//print("Voting for second next map")
				MySelf.Voted = 3
				RunConsoleCommand("vote_map_choice",3)
			end
		end
		draw.SimpleTextOutlined(str, "InfoSmall", w/2, h/2+115+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		draw.SimpleTextOutlined(string.rep("X",MapVotes.secondNextMap), "InfoSmall", w/2, h/2+134+y*40, drawCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		y = y+1
		drawCol = COLOR_GRAY
		
		// Show what is winning the vote
		local winner = "Restarting round"
		if (MapVotes.nextMap > MapVotes.curMap or not self.CanRestart) and MapVotes.nextMap >= MapVotes.secondNextMap then
			winner = "Changing to "..self.NextMap
		elseif MapVotes.secondNextMap > MapVotes.curMap then
			winner = "Changing to "..self.SecondNextMap
		end
		draw.SimpleTextOutlined(winner.." in "..math.floor(self:RoundTimeLeft()).." seconds", "DoomSmall", w/2, h/2+115+y*40, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		
		return 
	end
	
	/*---------- Draw logos and counter stuff -------*/
	
	surface.SetTexture( undlogo )
	surface.SetDrawColor( 180, 20, 20, 240 )
	surface.DrawTexturedRect( 100, -2, 153, 75 )

	surface.SetTexture( humlogo )
	surface.SetDrawColor( 20, 20, 180, 240 )
	surface.DrawTexturedRect( 100, 52, 153, 75 )
	
	local undeads = self.Reinforcements
	draw.SimpleTextOutlined("Undead Legion: "..undeads, "DoomSmall", 120, 40, COLOR_UNDEAD, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
	
	local humans = team.NumPlayers(TEAM_HUMAN)
	draw.SimpleTextOutlined("Special Forces: "..humans, "DoomSmall", 120, 77, COLOR_HUMAN, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
	
	
	/*--------------- Draw round timer -----------------*/
	
	local vertextable = {{}}
	local tim = GAMEMODE:RoundTimeLeft()
	local steps = 36-math.Round((tim/ROUNDLENGTH)*36)
	local clockx = 51
	local clocky = 66
	local clocklength = 35
	
	local function lengthdirx(length, dir)
		return length*math.cos(math.rad(dir))
	end -- Muahahahaha, I'm a mathematical genius! :D
	local function lengthdiry(length, dir)
		return length*math.sin(math.rad(dir))
	end
	
	-- Draw clock background
	surface.SetTexture( timeblock )
	surface.SetDrawColor( 30, 30, 30, 200 )	
	for k=1, 36 do		
		vertextable = {}
		vertextable[1] = {}
		vertextable[2] = {}
		vertextable[3] = {}
		vertextable[1]["x"] = clockx
		vertextable[1]["y"] = clocky
		vertextable[1]["u"] = 0
		vertextable[1]["v"] = 0
		vertextable[2]["x"] = clockx+lengthdirx(clocklength,(k-1)*10-90)
		vertextable[2]["y"] = clocky+lengthdiry(clocklength,(k-1)*10-90)
		vertextable[2]["u"] = 1
		vertextable[2]["v"] = 0
		vertextable[3]["x"] = clockx+lengthdirx(clocklength,k*10-90)
		vertextable[3]["y"] = clocky+lengthdiry(clocklength,k*10-90)
		vertextable[3]["u"] = 0
		vertextable[3]["v"] = 1
		surface.DrawPoly( vertextable )
	end
		
	-- Draw clock itself
	surface.SetTexture( timeblock )	
	surface.SetDrawColor( team.GetColor(MySelf:Team()) )
	
	if steps > 0 then 
		for k=1, steps do		
			vertextable = {}
			vertextable[1] = {}
			vertextable[2] = {}
			vertextable[3] = {}
			vertextable[1]["x"] = clockx
			vertextable[1]["y"] = clocky
			vertextable[1]["u"] = 0
			vertextable[1]["v"] = 0
			vertextable[2]["x"] = clockx+lengthdirx(clocklength,(k-1)*10-90)
			vertextable[2]["y"] = clocky+lengthdiry(clocklength,(k-1)*10-90)
			vertextable[2]["u"] = 1
			vertextable[2]["v"] = 0
			vertextable[3]["x"] = clockx+lengthdirx(clocklength,k*10-90)
			vertextable[3]["y"] = clocky+lengthdiry(clocklength,k*10-90)
			vertextable[3]["u"] = 0
			vertextable[3]["v"] = 1
			surface.DrawPoly( vertextable )			
		end
	end
	-- Draw pointer line(s)
	surface.SetDrawColor( team.GetColor(MySelf:Team()) )
	surface.SetTexture( timeblock )
	surface.DrawTexturedRectRotated( clockx+lengthdirx(clocklength/2,steps*10-90), clocky+lengthdiry(clocklength/2,steps*10-90), clocklength, 3, (36-steps)*10-90 )
	
	surface.SetTexture( timeborder )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0,0, 128, 128 )//clockx-clocklength-1,clocky-clocklength-1,clocklength*2+2,clocklength*2+2 )
	
	draw.SimpleTextOutlined(string.ToMinutesSeconds(tim), "DoomSmall", clockx, clocky+10, COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
	
	-- Rest isn't drawn if player is not alive
	if (MySelf:IsValid() and MySelf:Alive() and MySelf.Class and MySelf.Class ~= 0) then
		
		/*--------------- HUD info --------------------*/
		
		draw.SimpleTextOutlined("F1: Help  F2: Classes  F3: Options  F4: Score", "InfoSmall", 6, 2, COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, COLOR_BLACK)
		
		/*------- Turret info for experimental -----------*/
		
		if MySelf:GetPlayerClass() == 5 and MySelf:Team() == TEAM_HUMAN then
		
			self.TurTabTargetW = self.TurTabTargetW or 78
			self.TurTabCurrentW = self.TurTabCurrentW or 78
		
			-- nice transition effect
			if (self.TurTabTargetW != self.TurTabCurrentW) then
				self.TurTabCurrentW = math.Approach(self.TurTabCurrentW,self.TurTabTargetW,math.abs(self.TurTabCurrentW-self.TurTabTargetW)*2*FrameTime())
			end
		
			draw.RoundedBox(16, 4, 146, self.TurTabCurrentW, 60, Color(0,0,0,180))
			
			local turcol = COLOR_HUMAN
			
			if MySelf.TurretStatus == TurretStatus.active then
				if ValidEntity(MySelf.Turret.Entity) then
					self.TurTabTargetW = 190
					local turhp = MySelf.Turret:GetTable():GetHealth()
					local turmaxhp = MySelf.Turret:GetTable():GetMaxHealth()
					local mode = MySelf.Turret:GetTable():GetMode()
					local st = { FOLLOWING = 1, TRACKING = 2, LOST = 3, DEFEND = 4, SHUTDOWN = 5 }
					local kills = 0
					
					kills = MySelf.Turret:GetTable():Kills()
					draw.SimpleText("Kills: "..kills, "InfoSmall", 82, 150, COLOR_HUMAN_LIGHT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					
					local modestr = "* Following owner"
					local modestr2 = ""
					if (mode == st.TRACKING) then
						modestr = "* Lost owner!"
						modestr2 = "* Tracking..."
					elseif (mode == st.LOST) then
						modestr = "* Lost track"
						modestr2 = "* Waiting for owner"
					elseif (mode == st.DEFEND) then
						modestr = "* Defending point"
						modestr2 = ""
					end
					draw.SimpleText(modestr, "InfoSmall", 82, 170, COLOR_HUMAN_LIGHT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					draw.SimpleText(modestr2, "InfoSmall", 82, 186, COLOR_HUMAN_LIGHT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					
					surface.SetDrawColor( COLOR_DARKGRAY )
					surface.DrawRect(10,186,70,10)
					
					local col = COLOR_HURT1
					if (turhp <= 0.25*turmaxhp) then col = COLOR_HURT4
					elseif (turhp <= 0.5*turmaxhp) then col = COLOR_HURT3
					elseif (turhp <= 0.75*turmaxhp) then col = COLOR_HURT2
					end
					surface.SetDrawColor( col )
					surface.DrawRect(10,186,70*turhp/turmaxhp,10)
					
					surface.SetDrawColor( 0,0,0,255 )
					surface.DrawOutlinedRect(10,186,70,10)
				end
			elseif MySelf.TurretStatus == TurretStatus.inactive then
				self.TurTabTargetW = 78
				draw.SimpleText("UNDEPLOYED", "InfoSmaller", 42, 186, COLOR_HUMAN_LIGHT, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			elseif MySelf.TurretStatus == TurretStatus.destroyed then
				self.TurTabTargetW = 78
				turcol = COLOR_GRAY
				draw.SimpleText("DESTROYED", "InfoSmaller", 42, 186, COLOR_HUMAN_LIGHT, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			
			surface.SetTexture(turretTexture)
			surface.SetDrawColor(turcol.r, turcol.g, turcol.b, 255)
			surface.DrawTexturedRect( 10,130, 64, 64 )

		end
		
		// stuff
		
		local classname = ""
		if (MySelf:Team() == TEAM_HUMAN) then
			classname = HumanClass[MySelf.Class].Name
		elseif (MySelf:Team() == TEAM_UNDEAD) then
			classname = UndeadClass[MySelf.Class].Name
		end
		local powername = HumanPowers[(MySelf:GetPower() or 0)].Name

		/* ------------ Weapon info drawing ---------------*/
		local clip_left = 0
		local clip_reserve = 0
		if (MySelf:GetActiveWeapon():IsValid()) then
			-- Amount of ammo in clip
			clip_left = MySelf:GetActiveWeapon():Clip1() or 0
			-- Amount of ammunition left
			clip_reserve = MySelf:GetAmmoCount(MySelf:GetActiveWeapon():GetPrimaryAmmoType()) or 0
		end
		
		if (clip_left ~= -1) then  -- mostly meaning user is holding knife or something
		
			clip_type = "none"
			if MySelf:GetActiveWeapon().Primary then
				clip_type = MySelf:GetActiveWeapon().Primary.Ammo
			end
			local clipline = "Clip: "..clip_left.."/"..clip_reserve
			
			-- Draw bullets
			local function DrawBullet(x,y)
				surface.SetDrawColor(255,255,255,255)
				surface.SetTexture( textureBullet )	
				surface.DrawTexturedRect( x,y, 4,10 )
			end
			
			local drawx = w - 10
			local drawy = h - 4
			local linemax = 50 -- Amount of bullets on one line
			if (clip_left > 0 and clip_type ~= "grenade" and clip_type ~= "none") then
				drawy = drawy-11
				for k = 1, clip_left, 1 do
					DrawBullet(drawx,drawy)
					if (math.fmod(k,linemax)==0 and k ~= clip_left) then -- split up bullet alignment
						drawy = drawy-11
						drawx = w - 10
					else
						drawx = drawx-5
					end
				end
			end
			
			if (clip_type == "none" or clip_type == "grenade" or clip_type == "slam") then
				clipline = "Amount: "..math.max(clip_left,clip_reserve)
			end
			
			draw.SimpleTextOutlined(clipline, "DoomSmall", w - 16, drawy-20, COLOR_GRAY, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
		end
		
		-- Draw team specific HUD elements	
		if MySelf:Team() == TEAM_UNDEAD then
			self:UndeadHUD()
		elseif MySelf:Team() == TEAM_HUMAN then
			self:HumanHUD()
		end

		/*------------ Draw class picture ---------------*/
		
		surface.SetDrawColor(MySelf:GetColor())
		if MySelf:Team() == TEAM_UNDEAD then
			surface.SetTexture( surface.GetTextureID(UndeadClass[MySelf.Class].HUDfile) )	
		elseif MySelf:Team() == TEAM_HUMAN then
			surface.SetTexture( surface.GetTextureID(HumanClass[MySelf.Class].HUDfile) )		
		end
		surface.DrawTexturedRect( 0,h-160, 180,160 )
		
		local col = COLOR_GRAY
		if MySelf:Team() == TEAM_UNDEAD then
			col = COLOR_RED
		end
		draw.SimpleTextOutlined(classname, "DoomSmall", 75, h - 20, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		
		
	end
	
	-- Draw target ID
	GAMEMODE:HUDDrawTargetID()
	-- Draw pickup history
	GAMEMODE:HUDDrawPickupHistory()
	-- Draw death notice
	GAMEMODE:DrawDeathNotice( 0.82, 0.04 )
	
	-- Draw crosshair
	if MySelf and MySelf:IsValid() and MySelf:Alive() and MySelf:Team() ~= TEAM_UNASSIGNED and DrawCrHair then
		GAMEMODE:DrawCrosshair()
	end
	
end

local showsuitpower = 0
local showhealth = 0

local zhud = surface.GetTextureID( "infectedwars/HUD/ZHUD" )
	
function GM:UndeadHUD()

	local MySelf = LocalPlayer()
	local myhealth = 0
	local mymaxhealth = MySelf:GetMaximumHealth() or 100
	if (MySelf:IsValid() and MySelf:Alive()) then
		myhealth = math.max(MySelf:Health(), 0)	
	end
	
	/*-------- Warghoul smell ----------*/
	for v, ply in pairs(player.GetAll()) do
		if ply:Team() == TEAM_HUMAN and ply:Alive() and (ply.Detectable or MySelf:GetPlayerClass() == 5)then
			local pos = ply:GetPos() + Vector(0,0,50)
			if pos:Distance(pos) < 2000 then
				local vel = ply:GetVelocity() * 0.6
				local emitter = ParticleEmitter(pos)
				for i=1, math.random(2,3) do
					local par = emitter:Add("Sprites/light_glow02_add_noz.vmt", pos)
					par:SetVelocity(vel + Vector(math.random(-25, 25),math.random(-25, 25), math.Rand(-20, 20)))
					par:SetDieTime(0.5)
					par:SetStartAlpha(4)
					par:SetEndAlpha(2)
					par:SetStartSize(math.random(1, 9))
					par:SetEndSize(math.random(1,4))
					if ply.Detectable then
						par:SetColor(250, math.random(220,240), 0)
					else
						par:SetColor(220, math.random(10,50), 10)
					end
				end
				emitter:Finish()
			end
		end
	end
	
	/*--------------- Draw healthbar ----------------*/
	
	local barcolor = Color(255,66,66,255)
	
	-- Make the health flash when low on HP
	if myhealth > 25 then
		surface.SetDrawColor( barcolor )
	else
		surface.SetDrawColor(barcolor.r, barcolor.g, barcolor.b, (math.sin(RealTime() * 6) * 100) + 155)
	end
	
	-- Draw bars for below healthbar
	surface.SetDrawColor( COLOR_BLACK )
	surface.DrawRect(160, h - 48, 202, 26)	
	surface.SetDrawColor( Color(255,90,90) )
	
	local targethealth = math.min(myhealth / mymaxhealth,1) * 202
	showhealth = math.Approach(showhealth, targethealth, FrameTime()*202)
	surface.DrawRect(160, h - 48, showhealth, 26)

	surface.SetTexture( zhud )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, h-200, 400, 200 )
		
	draw.SimpleTextOutlined(myhealth.."/"..mymaxhealth, "DoomSmall", 360, h - 48, Color(255,0,0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(75,0,0))
		
end

local hhud = surface.GetTextureID( "infectedwars/HUD/HHUD" )

function GM:HumanHUD()
	/*--------------- Draw suit power ----------------*/
	local MySelf = LocalPlayer()
	local barcolor = Color (0, 255, 255, 200)
	local suitpower = MySelf:SuitPower()
	local maxsuitpower = MySelf:GetMaxSuitPower()
	local powername = HumanPowers[MySelf:GetPower()].Name
	local myhealth = 0
	local mymaxhealth = MySelf:GetMaximumHealth() or 100
	if (MySelf:IsValid() and MySelf:Alive()) then
		myhealth = math.max(MySelf:Health(), 0)	
	end
	
	-- Draw bars for below healthbar
	surface.SetDrawColor( COLOR_BLACK )
	surface.DrawRect(170, h - 31, 190, 22)	
	
	surface.SetDrawColor( barcolor )
	local targetsuitpower = math.min(suitpower / maxsuitpower,1) * 190
	showsuitpower = math.Approach(showsuitpower, targetsuitpower, FrameTime()*190)
	surface.DrawRect(170, h - 31, showsuitpower, 22)
			
	
	/*--------------- Draw healthbar ----------------*/
	
	local barcolor
	
	-- Determine health color
	barcolor = COLOR_HURT1
	if (myhealth <= 0.25*mymaxhealth) then barcolor = COLOR_HURT4
	elseif (myhealth <= 0.5*mymaxhealth) then barcolor = COLOR_HURT3
	elseif (myhealth <= 0.75*mymaxhealth) then barcolor = COLOR_HURT2
	end
	
	-- Draw bars for below healthbar
	surface.SetDrawColor( COLOR_BLACK )
	surface.DrawRect(170, h - 68, 190, 22)	
	
	-- Make the health flash when low on HP
	if myhealth > 25 then
		surface.SetDrawColor( barcolor )
	else
		surface.SetDrawColor(barcolor.r, barcolor.g, barcolor.b, (math.sin(RealTime() * 6) * 100) + 155)
	end
	
	local targethealth = math.min(myhealth / mymaxhealth,1) * 190
	showhealth = math.Approach(showhealth, targethealth, FrameTime()*190)
	surface.DrawRect(170, h - 68, showhealth, 22)
	
	surface.SetTexture( hhud )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, h-200, 400, 200 )
	
	draw.SimpleTextOutlined(suitpower.."/"..maxsuitpower, "DoomSmall", 355, h - 10, Color(0,140,200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,25,45))
	draw.SimpleTextOutlined(myhealth.."/"..mymaxhealth, "DoomSmall", 355, h - 68, Color(0,140,200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, Color(0,25,45))
	
	-- draw power logo
	local powlogo = surface.GetTextureID( HumanPowers[MySelf:GetPower()].HUDfile )
	
	surface.SetTexture( powlogo )
	surface.SetDrawColor( COLOR_HUMAN )
	surface.DrawTexturedRect( w-100, 10, 100, 100 )
	draw.SimpleTextOutlined(powername, "DoomSmall", w-50, 60, COLOR_HUMAN, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
	
end

function GM:DrawCrosshair()
	surface.SetTexture( surface.GetTextureID(CROSSHAIR[CurCrosshair]) )
	local col = CROSSHAIRCOLORS[CurCrosshairColor] or Color(255,255,255,255)
	local alph = GetConVarNumber("_iw_crosshairalpha")
	surface.SetDrawColor( col.r, col.g, col.b, alph )	
	surface.DrawTexturedRect( w/2-32, h/2-32, 64, 64 )
end

local lastStandTex = surface.GetTextureID("infectedwars/laststand")
local lastStandAlph = 255
function LastHumanPaint()

	local sizex = 512
	local sizey = 256
	
	if GAMEMODE.LastHumanStart+8 > CurTime() then
		lastStandAlph = 255
	else
		lastStandAlph = math.max(0,lastStandAlph-255*FrameTime()/2)
	end
	
	surface.SetTexture( lastStandTex )
	surface.SetDrawColor( 255,255,255,lastStandAlph )	
	surface.DrawTexturedRect( w/2-sizex/2, h/2-sizey/2+h/4, sizex, sizey )
	surface.SetDrawColor( 100,100,100, lastStandAlph/4 )	
	surface.DrawTexturedRect( w/2-sizex*4, h/2-sizey/2+h/4, sizex*8, sizey )
	
	local col = COLOR_RED
	col.a = lastStandAlph
	if LocalPlayer():Team() == TEAM_HUMAN then
		draw.SimpleTextOutlined("Survive!", "DoomSmall", w/2, h*3/4+sizey/4, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
	else
		draw.SimpleTextOutlined("Kill the last human!", "DoomSmall", w/2, h*3/4+sizey/4, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, COLOR_BLACK)
	end
	
	if GAMEMODE.LastHumanStart != 0 and GAMEMODE.LastHumanStart+10 < CurTime() then
		hook.Remove("HUDPaint","LastHumanP")
	end
end


function ToggleHUD( pl,commandName,args )
	local MySelf = LocalPlayer()
	HUD_ON = util.tobool(args[1])
	if HUD_ON then 
		MySelf:PrintMessage( HUD_PRINTTALK, "HUD activated")
		RunConsoleCommand("r_viewmodel","1")
	else 
		MySelf:PrintMessage( HUD_PRINTTALK, "HUD deactivated")
		RunConsoleCommand("r_viewmodel","0")
	end
end
concommand.Add("iw_enablehud",ToggleHUD) 

/*---------------------------------------------------------
   Name: gamemode:HUDPaintBackground( )
   Desc: Same as HUDPaint except drawn before
---------------------------------------------------------*/
local armorHitOverlay = surface.GetTextureID("infectedwars/HUD/armorhit")
local armorHitAlpha = 0
function GM:HUDPaintBackground()

	if not HUD_ON then return end
	
	local MySelf = LocalPlayer()
	
	-- Call scope drawing before all the other HUD code
	if MySelf:GetActiveWeapon() and MySelf:GetActiveWeapon().DrawScope then
		MySelf:GetActiveWeapon():DrawScope()
	end
	
	if (armorHitAlpha <= 0) then return end
	
	armorHitAlpha = math.max(0,armorHitAlpha-FrameTime()*400)
	surface.SetTexture( armorHitOverlay )
	surface.SetDrawColor( 255,255,255,armorHitAlpha )	
	surface.DrawTexturedRect( 0, 0, w, h )
end

local hitSounds = { Sound("weapons/crossbow/hitbod1.wav"), Sound("weapons/crossbow/hitbod2.wav") }
function ShowArmorHit()
	surface.PlaySound(table.Random(hitSounds))
	armorHitAlpha = 200
end
usermessage.Hook("HUDArmorHit",ShowArmorHit)

/*---------------------------------------------------------
   Draw coin receival effect
---------------------------------------------------------*/
local amountAdded = 0
local yAddAdd = 40
local yAdd = 0
local cdrawx = 0
local cdrawstr = ""
function PaintCoinEffect()
	yAdd = yAdd + FrameTime()*yAddAdd
	yAddAdd = math.max(0,yAddAdd - FrameTime()*35)

	draw.DrawText(cdrawstr, "InfoSmall", 10+cdrawx, 124-yAdd, Color(115,160,150,255), TEXT_ALIGN_LEFT) 
end

function KillCoinPaint()
	amountAdded = 0
	cdrawstr = ""
	hook.Remove("HUDPaint","PaintCoinEffect")
end

local function CoinEffect(um)
	yAdd = 0
	yAddAdd = 40

	local add = um:ReadShort()
	if add then
		amountAdded = amountAdded + add
		hook.Add("HUDPaint","PaintCoinEffect",PaintCoinEffect)
		timer.Remove("CoinKillTimer")
		timer.Create("CoinKillTimer",2,1,KillCoinPaint)
		
		local MySelf = LocalPlayer()
		local coins = MySelf:Money()
		
		cdrawstr = "+"..amountAdded
		if amountAdded < 0 then
			cdrawstr = ""..amountAdded
		end
		
		surface.SetFont("InfoSmall")
		wi, he = surface.GetTextSize("$$$ "..coins)
		wi2, he2 = surface.GetTextSize(cdrawstr)
		
		cdrawx = wi-wi2
	
	end
end
usermessage.Hook("CoinEffect", CoinEffect)

function DrawMoney()
	local MySelf = LocalPlayer()
	if not (MySelf:IsValid() and MySelf.Class and MySelf.Class ~= 0) then return end
	if ENDROUND then return end
	local coins = MySelf:Money()
	draw.RoundedBox(5, 3, 120, 200, 24, Color(0, 0, 0, 180))
	local drawcol = Color(115,160,150,185)
	draw.DrawText("$$$ "..coins, "InfoSmall", 10, 124, drawcol, TEXT_ALIGN_LEFT)
	draw.DrawText("$$$ "..coins, "InfoSmall", 10, 124, drawcol, TEXT_ALIGN_LEFT)
end
hook.Add("HUDPaint","DrawMoney",DrawMoney)


/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
---------------------------------------------------------*/
local NotToDraw = { "CHudHealth", "CHudSecondaryAmmo","CHudAmmo","CHudBattery" }
function GM:HUDShouldDraw( name )

	if not HUD_ON then 
		return false
	end

	if(name == "CHudDamageIndicator" and not LocalPlayer():Alive()) then
		return false
	end
	for k,v in pairs(NotToDraw) do
		if (v == name) then 
			return false
		end
	end
	return true
end