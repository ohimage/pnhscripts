/*------------
Infected Wars
cl_init.lua
Clientside
------------*/

h = ScrH()
w = ScrW()

PlayerIsAdmin = false

HUD_ON = true

COLOR_RED = Color(180, 0, 0, 255)
COLOR_BLUE = Color(0, 0, 180, 255)
COLOR_GREEN = Color(0, 180, 0, 255)
COLOR_LIMEGREEN = Color(30, 180, 30, 255)
COLOR_YELLOW = Color(180, 180, 0, 255)
COLOR_WHITE = Color(255, 255, 255, 255)
COLOR_BLACK = Color(0, 0, 0, 255)
COLOR_ARMOR = Color(0,0,200,165)
COLOR_DARKBLUE = Color(10, 80, 180, 255)
COLOR_DARKGREEN = Color(0, 190, 0, 255)
COLOR_GRAY = Color(170, 170, 170, 255)
COLOR_DARKGRAY = Color(40, 40, 40, 255)
COLOR_HURT1 = Color( 0, 255, 255, 255 )
COLOR_HURT2 = Color( 128, 255, 142, 255 )
COLOR_HURT3 = Color( 255, 233, 127, 255 )
COLOR_HURT4 = Color( 255, 127, 127, 255 )
COLOR_HUMAN_LIGHT = Color( 85, 150, 200, 255 )

SOUND_POWERACTIVATE = Sound("items/battery_pickup.wav")
SOUND_WARNING = Sound("common/warning.wav")

surface.CreateFont("Tahoma", 16, 1000, true, false, "ScoreboardText" )
surface.CreateFont("DooM", 14, 500, true, false, "DoomSmaller")
surface.CreateFont("DooM", 18, 500, true, false, "DoomSmall")
surface.CreateFont("DooM", 24, 500, true, false, "DoomMedium")
surface.CreateFont("DooM", 40, 500, true, false, "DoomLarge")
surface.CreateFont("Arial", 14, 500, true, false, "InfoSmaller")
surface.CreateFont("Arial", 16, 500, true, false, "InfoSmall")
surface.CreateFont("Arial", 26, 500, true, false, "InfoMedium")
surface.CreateFont("Courier New", 20, 500, true, false, "EndRoundStats")

include( 'shared.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_targetid.lua' )
include( 'cl_hudpickup.lua' )
include( 'cl_deathnotice.lua' )
include( 'xrayvision.lua' )
include( 'cl_screeneffects.lua' )
include( 'cl_menu.lua' )
include( 'cl_radialmenu.lua' )
include( 'cl_hud.lua' )

include( 'debug/cl_debug.lua' )

CreateClientConVar("_iw_crosshair", 1, true, false)
CreateClientConVar("_iw_crosshaircolor", "Default", true, false)
CreateClientConVar("_iw_crosshairalpha", 200, true, false)

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

	timer.Create("adjusthud",1,0,function()
		h = ScrH()
		w = ScrW()
	end) -- adjust HUD screen dimensions in case the user changes them

	CrossInit()
	CurCrosshair = GetConVarNumber("_iw_crosshair")
	if not CROSSHAIR[CurCrosshair] then
		CurCrosshair = 1
	end
	CurCrosshairColor = GetConVarString("_iw_crosshaircolor")
	if not CROSSHAIRCOLORS[CurCrosshairColor] then
		CurCrosshairColor = "Default"
	end
	RunConsoleCommand("_iw_crosshair",CurCrosshair)
	RunConsoleCommand("_iw_crosshaircolor",CurCrosshairColor)

	// Get changelog info
	http.Get(CHANGELOG_HTTP,"",HTTPChangelog)
	
	self:InitializeVars()
end

function GM:InitializeVars()
	
	self:InitializeMenuVars()
	
	self.Reinforcements = 0
	self.Voted = false
	self.EquipedSuit = nil
	
	ROUNDTIME = 0
	ROUNDLENGTH = 0
	ENDROUND = false
	LASTHUMAN = false
	
	// resync between server and client
	if ValidEntity(MySelf) then
		MySelf.Class, MySelf.MaxHP, MySelf.SP, MySelf.MaxSP, MySelf.CurPower = nil
	end
	
	GAMEMODE.LastHumanStart = 0
	
	GAMEMODE.ShowScoreboard = false
	
	statsreceived = false
	stattimer = 0
	
	
	MapList = {}
	
	MapVotes = { curMap = 0, nextMap = 0, secondNextMap = 0 }
	gui.EnableScreenClicker(false)
	
	-- call PlayerEntitityStart when LocalPlayer is valid
	timer.Create("playervalid",0.01,0,function()
		if (LocalPlayer():IsValid()) then
			GAMEMODE:PlayerEntityStart()
			timer.Destroy("playervalid")
		end
	end)
end

function HTTPChangelog(contents, size)
	HELP_TEXT[7].Text = contents
end

function RestartRound()
	if DoXRay then
		XRayToggle()
	end
	hook.Remove("RenderScreenspaceEffects", "DrawEnding")
	GAMEMODE:InitializeVars()
end
usermessage.Hook("RestartRound", RestartRound)

function LastHuman()
	if LASTHUMAN then return end
	LASTHUMAN = true
	GAMEMODE.LastHumanStart = CurTime()
	
	-- deactivate radio
	RunConsoleCommand("stopsounds")
	timer.Destroy("playtimer")
	timer.Destroy("nextplaytimer")
	
	if MUSIC_ENABLED then
		timer.Simple(0.1,function() surface.PlaySound(LASTSTANDMUSIC) end)
	end
	
	hook.Add("HUDPaint","LastHumanP",LastHumanPaint)
end
usermessage.Hook("lasthuman", LastHuman)

function ReceiveMoney( um )
	LocalPlayer().DataTable["money"] = um:ReadLong()
end
usermessage.Hook("SendMoney",ReceiveMoney)

/*--------------------------------------------------
--	This function is called when localplayer() is valid
--------------------------------------------------*/
MySelf = nil

function GM:PlayerEntityStart( )

	-- recieve the maplist
	if (PlayerIsAdmin) then
		RunConsoleCommand("get_maplist")
	end
	
	-- set up defaults for current players
	for k, v in pairs(player.GetAll()) do
		v.TitleText = v.TitleText or "Guest"
		v.Class = v.Class or 0
		v.Detectable = v.Detectable or false
	end
	
	-- Since the player is now valid, receive data
	RunConsoleCommand("data_synchronize")
	timer.Create("datachecktimer",4,0,CheckData)
	
	MySelf = LocalPlayer()
	MySelf.Class = MySelf.Class or 0
	MySelf.MaxHP = MySelf.MaxHP or 100
	MySelf.SP = MySelf.SP or 100
	MySelf.MaxSP = MySelf.MaxSP or 100
	MySelf.CurPower = MySelf.CurPower or 0
	MySelf.TitleText = MySelf.TitleText or "Guest"
	MySelf.PreferBehemoth = true
	MySelf.TurretStatus = TurretStatus.inactive
	
	if RadioOn then
		RadioPlay(math.random(1,#Radio))
		MySelf:PrintMessage(HUD_PRINTTALK,"Radio can be turned off in the Options panel (F3)")
	end
end

function CheckData()
	-- Double check if all data has been received
	local check = false
	for k, pl in pairs(player.GetAll()) do
		if (pl.TitleText == nil or pl.Class == 0 or pl.Detectable == nil) and (pl:Team() == TEAM_HUMAN or pl:Team() == TEAM_UNDEAD) then
			check = true
		end
	end
	if check then
		RunConsoleCommand("data_synchronize")
	end
end


/*--- force my artistic derma skin. -----*/
function GM:ForceDermaSkin()
	return "iw_skin"
end 

/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	
end

/*---------------------
	Calling late deploy
----------------------*/
function CallLateDeploy()
	-- Call the deploy function (to apply the materials)
	-- Needed because deploy isn't called when player spawn for the first time
	timer.Simple(0.01,function() 
		if LocalPlayer():GetActiveWeapon().Deploy then
			LocalPlayer():GetActiveWeapon():Deploy() 
		end
	end)
end

/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
local WaterDraintimer = 0
function GM:Think( )
	if WaterDraintimer < CurTime() then
		WaterDraintimer = CurTime()+1
		local MySelf = LocalPlayer() -- Decrement suit power when under water
		if MySelf:WaterLevel() > 1 then
			RunConsoleCommand("decrement_suit",math.Clamp(math.ceil(MySelf:WaterLevel())*2,1,6))
			if MySelf:SuitPower() <= 0 and MySelf:Team() == TEAM_HUMAN then
				RunConsoleCommand("drown_me",3)
			end
		end
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies. If the attacker was
		  a player then attacker will become a Player instead
		  of an Entity. 		 
---------------------------------------------------------*/
function GM:PlayerDeath( ply, attacker )
end

/*--------- Radio functions -----------------*/
CreateClientConVar("_iw_enableradio", 1, true, false)
RadioOn = util.tobool(GetConVarNumber("_iw_enableradio"))

for k=1, #Radio do
	util.PrecacheSound(Radio[k][1])
end
CurPlaying = 1

function RadioPlay( nr )
	RunConsoleCommand("stopsounds")
	timer.Destroy("playtimer")
	timer.Destroy("nextplaytimer")
	if (nr >  #Radio) then
		nr = 1
	end
	print("Switching to song "..nr)
	RadioOn = true
	
	// seems the timers fail to create when they're also destroyed earlier in the same function :/
	timer.Simple(0.1,function()
		timer.Create("playtimer",0.1, 1, function( the_nr ) 
			print("Playing song "..the_nr)
			surface.PlaySound( the_nr ) end, 
		Radio[nr][1])
		
		timer.Create("nextplaytimer",tonumber(Radio[nr][2])+2, 1, function(nextnr) 
			if RadioOn then 
				RadioPlay( nextnr ) 
			end
		end, nr+1)
	end)
	
	CurPlaying = nr
end

function ToggleRadio( pl,commandName,args )
	local MySelf = LocalPlayer()
	local org = RadioOn
	RadioOn = util.tobool(args[1])
	RunConsoleCommand("stopsounds")
	if RadioOn then 
		RunConsoleCommand("_iw_enableradio","1")
		if not Org then
			MySelf:PrintMessage( HUD_PRINTTALK, "Radio on")
		end
		RadioPlay(tonumber(args[2]))
	else 
		RunConsoleCommand("_iw_enableradio","0")
		if Org then
			MySelf:PrintMessage( HUD_PRINTTALK, "Radio off")
		end
		timer.Destroy("playtimer")
		timer.Destroy("nextplaytimer")
	end
end
concommand.Add("iw_enableradio",ToggleRadio) 

/*---------------------------------------------------------
   Name: gamemode:KeyPress( )
   Desc: Player pressed a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyPress( player, key )

end

/*---- XRay timer works similiar, see xrayvision.lua ----- */
local Stimer = 0
local Sstep = SPEED_TIMER

local function SpeedThink()
	
	local MySelf = LocalPlayer()
	
	-- If your suit power is 0, turn of Xray
	if (MySelf:GetPower() == 1) then
		if (MySelf:SuitPower() <= 0) then
			surface.PlaySound( SOUND_WARNING )
			MySelf:SetPower( 0 ) -- turn off the power
		else
			-- Else, keep draining suit power (if we're truly running fast enough that is)
			if (Stimer <= CurTime()) then
				Stimer = CurTime()+Sstep
				if (MySelf:GetVelocity():Length() > 100) then
					local cost = HumanPowers[1].Cost
					if MySelf:HasBought("duracell2") then
						cost = cost * 0.75
					end
					if MySelf.EquipedSuit == "scoutsspeedpack" then
						cost = cost * 0.5
					end
					RunConsoleCommand("decrement_suit",tostring(cost))
				end
			end
		end
	end
	
end
hook.Add("Think", "SpeedCheck", SpeedThink)

/*---------------------------------------------------------
   Name: gamemode:KeyRelease( )
   Desc: Player released a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyRelease( player, key )

end

local nextjump = 0
function GM:PlayerBindPress( pl, bind, pressed )

	if (bind == "+use" and pl:Alive() and pl:Team() == TEAM_UNDEAD and not pl:IsOnGround() and pl:GetPlayerClass() == CLASS_Z_BONES 
		and pl:HasBought("deathpursuit") and nextjump < CurTime()) then
		
		local trace = pl:GetEyeTrace()
		if trace.Entity and trace.Entity:IsPlayer() and trace.Entity:Team() == TEAM_HUMAN then
			RunConsoleCommand("_iw_forceboost",trace.Entity:EntIndex())
			nextjump = CurTime()+2
		end
	end
	
	if string.find( bind, "zoom" ) then return true end
end

/*---------------------------------------------------------
					Unlock achievement
---------------------------------------------------------*/
local unlockSound = Sound("weapons/physcannon/energy_disintegrate5.wav")
local achvStack = 0
local achievTime = 0

function DrawAchievement()
	endX = w/2-200
	endY = h/2-150
	textEndX = w/2-90
	textEndY = h/2-150
	
	achievAlpha = achievAlpha or 255
	achievX = achievX or {}
	achievY = achievY or {}
	achievX[1] = achievX[1] or endX-w -- four text location
	achievY[1] = achievY[1] or endY
	achievX[2] = achievX[2] or endX+w
	achievY[2] = achievY[2] or endY
	achievX[3] = achievX[3] or endX
	achievY[3] = achievY[3] or endY-h
	achievX[4] = achievX[4] or endX
	achievY[4] = achievY[4] or endY+h
	achievX[5] = achievX[5] or endX-w -- image location
	achievY[5] = achievY[5] or endY	
	
	col = Color(255,255,255,achievAlpha)
	col2 = Color(0,0,0,achievAlpha)
	
	local rand = 0
	local rand2 = 0
	
	for k=1, 4 do
		rand = -2+math.Rand(0,4)
		rand2 = -2+math.Rand(0,4)
		if k == 4 then 
			rand = 0 
			rand2 = 0 
		end
		draw.SimpleTextOutlined("Achievement Unlocked!","DoomSmall",achievX[k]+rand,achievY[k]+rand2,col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col2)
		draw.SimpleTextOutlined(achievName,"DoomMedium",achievX[k]+rand,achievY[k]+20+rand2,col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col2)
		if achievLoadout ~= "" then
			draw.SimpleTextOutlined(achievLoadout,"DoomSmall",achievX[k]+rand,achievY[k]+50+rand2,col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col2)
		end
	end
	
	surface.SetTexture( achievImage )
	surface.SetDrawColor( col )
	surface.DrawTexturedRect( achievX[5], achievY[5],100,100 )
	
	for k=1,4 do
		achievX[k] = math.Approach(achievX[k], textEndX, w*3*FrameTime())
		achievY[k] = math.Approach(achievY[k], textEndY, h*3*FrameTime())
	end
	achievX[5] = math.Approach(achievX[5], endX, w*3*FrameTime())
	achievY[5] = math.Approach(achievY[5], endY, h*3*FrameTime())	
	
	if (achievTime < CurTime()+1) then
		achievAlpha = math.Approach(achievAlpha, 0, 255*FrameTime())
	end
	
	if (achievTime < CurTime()) then
		hook.Remove("HUDPaint","DrawAchievement")
		for k=1, 5 do
			achievX[k] = nil
			achievY[k] = nil
			achievAlpha = nil
		end
	end
end

function IdentifyUnlock( stat )
	local display = false
	local code = {}
	local disp = {}
	local retstr = ""
	for k, v in pairs(unlockData) do
		if table.HasValue(v,stat) then
			display = true
			for i, j in pairs(v) do
				if not LocalPlayer().DataTable["achievements"][j] then
					display = false
					break
				end
			end
			if display == true then
				table.insert(code,k)
				display = false
			end
		end
	end
	
	local tab = {}
	table.Add(tab,HumanClass)
	table.Add(tab,UndeadClass)	
	if #code > 0 then
		for k, v in pairs(tab) do
			for i, j in pairs(v.SwepLoadout) do
				if table.HasValue(code,j.UnlockCode) then
					table.insert(disp,j.Name)
				end
			end
		end
		retstr = "Unlocked loadout: "
		if #disp > 0 then
			for y=1, #disp do
				retstr = retstr..disp[y]
				if y < #disp then
					retstr = retstr..", "
				end
			end
		end
		return retstr
	end	
	return ""
end

function UnlockEffect( achv )
	achvStack = achvStack+1
	if achievTime < CurTime() then
		LocalPlayer().DataTable["achievements"][achv] = true
		achvStack = achvStack-1
		achievName = achievementDesc[achv].Name
		achievImage = surface.GetTextureID(achievementDesc[achv].Image)
		achievTime = CurTime()+5
		
		surface.PlaySound(unlockSound)
		
		achievLoadout = IdentifyUnlock( achv )
		
		hook.Add("HUDPaint","DrawAchievement",DrawAchievement)
	else
		timer.Simple((achievTime-CurTime()+0.2)+5*(achvStack-1),function( str ) 
			UnlockEffect(str) 
			achvStack = achvStack-1
		end,achv) -- Achievement display delays
	end
end

-- Receive max health status
local function SetMaxHealth(um)

	local ent = um:ReadEntity()
	ent.MaxHP = um:ReadShort()
	
end
usermessage.Hook("SetMaxHP", SetMaxHealth)

-- Receive suit power status
local function SetSuitPower(um)

	local MySelf = LocalPlayer()
	MySelf.SP = um:ReadShort()
	
end
usermessage.Hook("SetSP", SetSuitPower)

-- Receive max suit power status
local function SetMaxSuitPower(um)

	local MySelf = LocalPlayer()
	MySelf.MaxSP = um:ReadShort()
	
end
usermessage.Hook("SetMaxSP", SetMaxSuitPower)

-- Receive class status
local function RecClass(um)

	local ent = um:ReadEntity()
	if ent:IsValid() then
		ent.Class = um:ReadShort()
	end
	
end
usermessage.Hook("SetClass", RecClass)

-- Receive power status
local function RecPower(um)

	local MySelf = LocalPlayer()
	MySelf.CurPower = um:ReadShort()
	
	local pf = {
	[0] = { 0, 150, 150 },
	[1] = { 150, 0, 0 },
	[2] = { 0, 0, 150 },
	[3] = { 150, 150, 0 }
	}
	CreatePowerFlash( pf[MySelf.CurPower][1], pf[MySelf.CurPower][2], pf[MySelf.CurPower][3] )
	
	-- Toggle XRay (it will only activate if player has Vision power)
	RunConsoleCommand("toggle_xrayvision")
	
end
usermessage.Hook("SetPower", RecPower)

-- Receive detectability
local function RecDetect(um)

	local ent = um:ReadEntity()
	if ent:IsValid() then
		ent.Detectable = um:ReadBool()
	end
	
end
usermessage.Hook("SetDetectable", RecDetect)

-- Receive title
local function RecTitle(um)

	local ent = um:ReadEntity()
	if ent:IsValid() then
		ent.TitleText = um:ReadString()
	end
	
end
usermessage.Hook("SetTitle", RecTitle)

-- Receive player admin status locally
local function SetPlayerIsAdmin(um)

	PlayerIsAdmin = um:ReadBool()
	
end
usermessage.Hook("SetAdmin", SetPlayerIsAdmin)

-- receive data like title text, class, and max hp in one go
local function SetData(um)

	local amount = um:ReadShort()
	local ent
	local pl
	for k=1,amount do
		pl = um:ReadEntity()
		pl.TitleText = um:ReadString()
		pl.Class = um:ReadShort()
		pl.Detectable = um:ReadBool()
	end
	
end
usermessage.Hook("SetData", SetData)

-- receive all recorded data
local function SetRecordData(um)

	local pl = um:ReadEntity()
	if not pl.DataTable then
		pl.DataTable = {{}}
		pl.DataTable["achievements"] = {}
		pl.DataTable["shopitems"] = {}
	end
	for k, v in pairs(recordData) do
		pl.DataTable[k] = um:ReadString()
	end
	for k, v in pairs(achievementDesc) do
		pl.DataTable["achievements"][k] = um:ReadBool()
	end
	pl.StatsReceived = true
	
end
usermessage.Hook("SetRecordData", SetRecordData)

-- Receive map list
MapList = {}
local function ReceiveMapList(um)

	local index = um:ReadShort()
	local map = um:ReadString()
	map = string.gsub(map,".bsp","")
	MapList[index] = map
	
end
usermessage.Hook("RcMapList", ReceiveMapList)

-- Timer function
function GM:RoundTimeLeft()
	return( math.Clamp( ROUNDTIME - CurTime(), 0, ROUNDLENGTH) )
end

local function SynchronizeTime(um)
	ROUNDLENGTH = um:ReadShort()
	ROUNDTIME = um:ReadLong()
end
usermessage.Hook("SendTime", SynchronizeTime)

local function SynchronizeReinforcements(um)
	GAMEMODE.Reinforcements = um:ReadShort()
end
usermessage.Hook("SendReinforce", SynchronizeReinforcements)

statsreceived = false
stattimer = 0
local function SetStats(um)
	StatsUndKiller = um:ReadString()
	StatsHumKiller = um:ReadString()
	StatsUndDmg = um:ReadString()
	StatsHumDmg = um:ReadString()
	StatsMostSocial = um:ReadString()
	StatsMostScary = um:ReadString()
	StatsMostUnlucky = um:ReadString()
	StatsRoundKills = um:ReadString()
	StatsRoundDamage = um:ReadString()
	statsreceived = true
	stattimer = CurTime() + 7
end
usermessage.Hook("SendTopStats", SetStats)

function PrintWeapons()
	for k, v in pairs(LocalPlayer():GetWeapons()) do
		Msg(v:GetPrintName().."\n")
	end
end

/*--------------------------------------------------------
		Called when the round ends
--------------------------------------------------------*/
local function EndRound( um )
	
	GAMEMODE.TeamThatWon = um:ReadShort()
	GAMEMODE.ShowVoting = um:ReadBool()
	if GAMEMODE.ShowVoting then
		GAMEMODE.CanRestart = um:ReadBool()
		GAMEMODE.CurMap = um:ReadString()
		GAMEMODE.NextMap = um:ReadString()
		GAMEMODE.SecondNextMap = um:ReadString()
	end
	
	ENDROUND = true
	gui.EnableScreenClicker(true)
	LocalPlayer().Voted = 0
	VoteBox = nil
	
	RunConsoleCommand("stopsounds")
	if MUSIC_ENABLED then
		// stop radio
		timer.Destroy("playtimer")
		timer.Destroy("nextplaytimer")
		
		local song = HUMANWINMUSIC
		if GAMEMODE.TeamThatWon == TEAM_UNDEAD then
			song = UNDEADWINMUSIC
		end
		timer.Simple(0.1,function( ms ) surface.PlaySound(ms) end,song)
	end
	
	hook.Add("RenderScreenspaceEffects", "DrawEnding", DrawEnding)
	
	-- Close all derma frames
	CloseFrames()
end
usermessage.Hook("GameEndRound", EndRound)

function SyncVotes( um )
	if not GAMEMODE.ShowVoting then return end
	MapVotes = { curMap = 0, nextMap = 0, secondNextMap = 0 }
	
	MapVotes.curMap = um:ReadShort()
	MapVotes.nextMap = um:ReadShort()
	MapVotes.secondNextMap = um:ReadShort()
	
end
usermessage.Hook("SynchronizeVotes", SyncVotes)

GM.MapExploits = {}
-- receive map exploit locations
function RecMapExploits( um )
	local tab = {}
	local reset = um:ReadBool()
	if reset == true then
		GAMEMODE.MapExploits = {}
	end
	local number = um:ReadShort()
	local start = um:ReadShort()
	for k=1, number do
		tab = {}
		tab.origin = um:ReadVector()
		tab.bsize = um:ReadShort()
		tab.type = um:ReadString()
		GAMEMODE.MapExploits[start+k-1] = tab
		number = number + 1
	end

end
usermessage.Hook("mapexploits",RecMapExploits)

function RecMapExploitsSingle( um )
	local tab = {}
	tab.origin = um:ReadVector()
	tab.bsize = um:ReadShort()
	tab.type = um:ReadString()
	table.insert(GAMEMODE.MapExploits,tab)
end
usermessage.Hook("mapexploitssingle",RecMapExploitsSingle)

// Receive shop data
local function SetShopData(um)
	
	MySelf = LocalPlayer()
	if not MySelf.DataTable then
		MySelf.DataTable = {{}}
		MySelf.DataTable["achievements"] = {}
		MySelf.DataTable["shopitems"] = {}
	end
	for k, v in pairs(shopData) do
		MySelf.DataTable["shopitems"][k] = um:ReadBool()
	end
end
usermessage.Hook("SetShopData", SetShopData)

/*---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
---------------------------------------------------------*/
function GM:CreateMove( cmd )
end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse has been released on the game screen
---------------------------------------------------------*/
function GM:GUIMouseReleased( mousecode, AimVector )

	hook.Call( "CallScreenClickHook", GAMEMODE, false, mousecode, AimVector )

end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end


/*---------------------------------------------------------
   Name: gamemode:RenderScreenspaceEffects( )
   Desc: Bloom etc should be drawn here (or using this hook)
---------------------------------------------------------*/
function GM:RenderScreenspaceEffects()
end

/*---------------------------------------------------------
   Name: gamemode:GetTeamColor( ent )
   Desc: Return the color for this ent's team
		This is for chat and deathnotice text
---------------------------------------------------------*/
function GM:GetTeamColor( ent )

	local team = TEAM_UNASSIGNED
	if (ent.Team) then team = ent:Team() end
	return GAMEMODE:GetTeamNumColor( team )

end


/*---------------------------------------------------------
   Name: ChatText
   Allows override of the chat text
---------------------------------------------------------*/
function GM:ChatText( playerindex, playername, text, filter )

	if ( filter == "chat" ) then
		Msg( playername, ": ", text, "\n" )
	else
		Msg( text, "\n" )
	end
	
	return false

end

/*---------------------------------------------------------
   Name: gamemode:PostProcessPermitted( str )
   Desc: return true/false depending on whether this post process should be allowed
---------------------------------------------------------*/
function GM:PostProcessPermitted( str )

	return true

end


/*---------------------------------------------------------
   Name: gamemode:PostRenderVGUI( )
   Desc: Called after VGUI has been rendered
---------------------------------------------------------*/
function GM:PostRenderVGUI()
end


/*---------------------------------------------------------
   Name: gamemode:RenderScene( )
   Desc: Render the scene
---------------------------------------------------------*/
function GM:RenderScene()
end

/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angles, fov )
	
	local MySelf = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	
	-- Places eyes in ragdoll entity
	if MySelf:GetRagdollEntity() then
		local phys = MySelf:GetRagdollEntity():GetPhysicsObjectNum(12)
		local ragdoll = MySelf:GetRagdollEntity()
		if ragdoll then
			local lookup = MySelf:LookupAttachment("eyes")
			if lookup then
				local attach = ragdoll:GetAttachment(lookup)
				if attach then
					return {origin=attach.Pos, angles=attach.Ang}
				end
			end
		end
	end
	
	local view = {}
	view.origin 	= origin
	view.angles		= angles
	view.fov 		= fov
	
	// Give the active weapon a go at changing the viewmodel position
	
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin,  view.vm_angles = func( wep, origin*1, angles*1 ) // Note: *1 to copy the object so the child function can't edit it.
		end
		
		local func = wep.CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( wep, ply, origin*1, angles*1, fov ) // Note: *1 to copy the object so the child function can't edit it.
		end
	
	end
	
	return view
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawTranslucent( )
   Desc: Called before drawing translucent entities
---------------------------------------------------------*/
function GM:PreDrawTranslucent()
end

/*---------------------------------------------------------
   Name: gamemode:PostDrawTranslucent( )
   Desc: Called after drawing translucent entities
---------------------------------------------------------*/
function GM:PostDrawTranslucent()
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaque( )
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PreDrawOpaque()
end

/*---------------------------------------------------------
   Name: gamemode:PostDrawOpaque( )
   Desc: Called after drawing opaque entities
---------------------------------------------------------*/
function GM:PostDrawOpaque()
end

