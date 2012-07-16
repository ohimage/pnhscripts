/*------------
Infected Wars
init.lua
Serverside
------------*/

TESTMODE = false

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_hudpickup.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("cl_scoreboard.lua" )
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("obj_player_extend.lua")
AddCSLuaFile("options_shared.lua")
AddCSLuaFile("xrayvision.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_radialmenu.lua")
AddCSLuaFile("cl_screeneffects.lua")
AddCSLuaFile("cl_hud.lua")

AddCSLuaFile("debug/cl_debug.lua")

include( 'shared.lua' )
include( 'sv_obj_player_extend.lua' )
include( 'commands.lua' )
include( 'options_server.lua' )
include( 'anti_map_exploit.lua' )
include( 'savedata.lua' )

include( 'debug/sv_debug.lua' )

if SINGLEPLAYER then
	PLAYER_STATS = false
end

ROUND_NUMBER = 1

ROUNDSTATE_IDLE = 1
ROUNDSTATE_PLAY = 2
ROUNDSTATE_END = 3

GM.PlayerSpawnTime = {}

ENDROUND = false
ROUNDWINNER = 0

-- List of dead people's Steam ID's, in order to prevent rejoiners
-- from joining the human team.
DeadPeople = {}

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

	/*-------- Include files the client must download ---------*/
	
	local listOfResourceMaps = { 
	"sound/infectedwars", -- Just add map paths from which you want to include all files
	"sound/weapons/turboscout",
	"sound/weapons/Kriss",
	"sound/weapons/m249",
	"sound/weapons/sg550",
	"sound/weapons/m16a4",
	"sound/weapons/bizon",
	"sound/weapons/m3",
	"materials/xray",
	"materials/infectedwars",
	"materials/infectedwars/HUD",
	"materials/egon",
	"materials/decals",
	"materials/killicon/infectedwars",
	"materials/effects/infectedwars",
	"materials/models/weapons/v_models/tactical_m24",
	"materials/models/weapons/w_models/tactical_m24",
	"materials/models/weapons/v_models/shrike",
	"materials/models/weapons/w_models/shrike",
	"materials/models/weapons/v_models/darkeh.twinke.g36.550",
	"materials/models/weapons/v_models/darkeh.twinke.g36.550/sproily",
	"materials/models/weapons/w_models/darkeh.twinke.g36",
	"materials/models/weapons/v_models/Kriss",
	"materials/models/weapons/w_models/Kriss",
	"materials/models/weapons/v_models/snark.spas",
	"materials/models/weapons/v_models/shot_m3super90",
	"materials/models/weapons/w_models/shot_m3super90",
	"materials/models/weapons/v_models/smg_bizon",
	"materials/models/weapons/w_models/smg_bizon",
	"materials/models/weapons/v_models/twinke.m16",
	"materials/models/weapons/w_models/twinke.m16"}

	for _, filemap in pairs( listOfResourceMaps ) do
		for _, filename in pairs(file.Find("../"..filemap.."/*.*")) do
			resource.AddFile(filemap.."/"..filename)
		end
	end

	local listOfWeaponModels = {
	"_lazr_scout", "_ares_shrikesb", "_g36c_snipe","_rif_g36", "_smg_kriss", "_shot_shotteh01", "_shot_m3tactica", "_m16_a4mm", "_olbizon"
	}
	for k, wildcard in pairs(listOfWeaponModels) do
		for _, filename in pairs(file.Find("../models/weapons/*"..wildcard..".*")) do
			resource.AddFile("models/weapons/"..filename)
		end
		for _, filename in pairs(file.Find("../models/weapons/infectedwars/*"..wildcard..".*")) do
			resource.AddFile("models/weapons/infectedwars/"..filename)
		end
	end

	resource.AddFile("resource/fonts/doom.ttf")
	resource.AddFile("materials/refract_ring.vtf")
	resource.AddFile("materials/refract_ring.vmt")
	resource.AddFile("scripts/decals/iwegonswep.txt")
	resource.AddFile("scripts/sounds/infectedwars_sweps.txt")
	
	-- creates the infected wars directory in the garrysmod/data folder
	-- if it doesn't exist yet
	if (not file.IsDir("infectedwars")) then
		file.CreateDir("infectedwars")
	end 
	if (not file.IsDir("infectedwars/maps")) then
		file.CreateDir("infectedwars/maps")
	end
	
	-- Write file with next map for dynamic server restore (Mr. Green only :P)
	file.Write( "nextmap.txt", GetNextMap() )
	
	self:InitializeVars()
end

function GM:InitializeVars()
	LASTHUMAN = false
	ROUNDTIME = ROUNDLENGTH+CurTime()
	self.Reinforcements = UNDEAD_REINFORCEMENTS
	self.GameState = ROUNDSTATE_IDLE
	
	self.DamageThisRound = 0
	self.KillsThisRound = 0

	-- Reset everything for multiple rounds
	ENDROUND = false
	ROUNDWINNER = 0

	DeadPeople = {}
	
	Stats = { WeaponKills = {}, TotalDeaths = 0, TotalKills = 0 }
	
	VotingStarted = false
	NumberOfVoters = 0
	MapVotes = { curMap = 0, nextMap = 0, secondNextMap = 0 }
	
	timer.Destroy("FirstSlay")
	timer.Destroy("FirstSlayBackup")
	timer.Create("FirstSlay",60+math.random(10),1,self.StartGameKill,self)
	timer.Create("FirstSlayBackup",200,1,self.StartGameKill,self) -- second one in case there are still no undead
	
end


/*----------------------
	Restart the round
*/----------------------
function GM:RestartRound()

	ROUND_NUMBER = ROUND_NUMBER+1
	game.CleanUpMap()
	self:InitializeVars()
	self:InitPostEntity()
	
	umsg.Start("RestartRound")
	umsg.End()
	
	for k, v in pairs(player.GetAll()) do
		v.Validated = false
		self:PlayerInitialSpawn(v)
		v:Spawn()
	end
	
end


-- Timer function
function GM:RoundTimeLeft()
	if (self.GameState ~= ROUNDSTATE_IDLE) then
		return( math.Clamp( ROUNDTIME - CurTime() , 0, ROUNDLENGTH) )
	else
		return ROUNDLENGTH
	end
end

function SendAdminStats( ply )
	-- send admin status
	umsg.Start("SetAdmin", ply)
		umsg.Bool( ply:IsAdmin() )
	umsg.End()
end

/*------------------------------
	Kills first human for zombs
-------------------------------*/

function GM:StartGameKill()
	local pltab = team.GetPlayers(TEAM_HUMAN)
	if TESTMODE and #pltab == 1 then return end

	local humans = team.NumPlayers(TEAM_HUMAN)
	if humans <= 1 then
		timer.Destroy("FirstSlay")
		timer.Create("FirstSlay",15,1,self.StartGameKill,self)
		return
	end
	
	local required = 4-team.NumPlayers(TEAM_UNDEAD)+CountStartTeams(TEAM_UNDEAD)
	if humans <= 18 then
		required = required-1
		if humans <= 10 then
			required = required-1
			if humans <= 4 then
				required = required-1
			end
		end
	end
	
	if required <= 0 then return end
	
	for k=1, required do
		local nr = math.random(1,#pltab)
		local fucked = pltab[nr]
		table.remove(pltab,nr)
		if fucked:Team() == TEAM_UNASSIGNED then
			fucked:SendLua("CloseFrames()")
			fucked.StartTeam = TEAM_UNDEAD
			if not BehemothExists() then
				FirstSpawn(fucked,"first_spawn",{1,1})
				fucked:PrintMessage(HUD_PRINTTALK,"You've been chosen to become the Behemoth, leader of the undead army!")
				self.PreviousBehemoth = fucked
				fucked.BeheDeaths = 0
			else
				FirstSpawn(fucked,"first_spawn",{2,1})
				fucked:PrintMessage(HUD_PRINTTALK,"You've been chosen to join the undead army!")
			end
		else
			fucked:SetVelocity(Vector(0,0,3000))
			fucked:EmitSound("npc/strider/fire.wav")
			timer.Simple(0.1,function(pl) 
				if ValidEntity(pl) then 
					pl:Kill() 
				end 
			end,fucked)
			fucked:PrintMessage(HUD_PRINTTALK,"You've been chosen to join the undead army!")
		end
	end
	PrintMessageAll(HUD_PRINTTALK,"The Undead have arrived!")

end

-- counts amount of players that are already assigned to a team but haven't spawned yet
function CountStartTeams( theteam )
	local count = 0
	for k, v in pairs(player.GetAll()) do
		if (v.StartTeam == theteam and v.FirstSpawn == true) then
			count = count+1
		end
	end
	return count
end
	
/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	/*if pl:IsListenServerHost() then
		TESTMODE = true
	end*/
	
	pl.DataTable = {}

	-- read player data
	GAMEMODE:ReadData(pl)
	
	pl.FirstSpawn = true
	pl.PreferBehemoth = true
	
	pl.SpawnAsClass = 0
	pl.NextLoadout = 0
	pl.CurPower = 0
	pl.StartTeam = TEAM_HUMAN
	pl.Class = 0
	pl.Detectable = false
	pl.TitleText = pl.TitleText or "---"
	
	pl.BabySpawn = nil
	pl.Turret = nil
	
	-- Stats and achievement tracking stuff
	pl.HumansKilled = 0
	pl.UndeadKilled = 0
	pl.DamageToUndead = 0
	pl.DamageToHumans = 0
	pl.AmountHealed = 0
	pl.AmountSupplied = 0
	pl.ScreensFucked = 0
	pl.DamageBuild = 0
	pl.DamageTaken = 0
	pl.TurretKills = 0
	pl.Screamlist = {}
	pl.Fraglist = {}
	pl.Blindlist = {}
	pl.Marked = 0
	pl.MarkedThisLife = {}
	pl.BabiesKilled = 0
	pl.Blasted = {}
	pl.TurretsDestroyed = 0
	pl.LastKiller = nil
	pl.LastHeadShot = 0
	pl.LastHumanStartTime = nil
	pl.StartTime = nil
	
	pl:CrosshairDisable()
	
	-- Roll the dice
	pl.CanRTD = true
	
	pl.Voted = false
	
	pl:SetTeam(TEAM_UNASSIGNED)
	pl:SetFrags(0)
	pl:SetDeaths(0)
	
	pl:SetCanZoom( false )
	
	pl.MaxHP = 100 -- max health
	pl.SP = 100 -- suit power
	pl.MaxSP = 100 -- max suit power
	
	SendAdminStats(pl)
	
	GAMEMODE:SynchronizeTime(pl)

	-- determine what team to put in
	if DeadPeople[pl:SteamID()] or LASTHUMAN or (ROUNDLENGTH-GAMEMODE:RoundTimeLeft() > HUMAN_JOINTIME) then
		pl.StartTeam = TEAM_UNDEAD
		if not BehemothExists() then
			FirstSpawn(pl,"first_spawn",{1,1})
			pl:PrintMessage(HUD_PRINTTALK,"You've been chosen to become the Behemoth, leader of the undead army!")
			self.PreviousBehemoth = pl
			pl.BeheDeaths = 0
		end
	else
		self.Reinforcements = self.Reinforcements + UNDEAD_REINFORCEMENTS_INCREMENT_PER_PLAYER
		pl.StartTeam = TEAM_HUMAN
	end
	
	GAMEMODE:SynchronizeReinforcements()
end

-- Is called when player selects his class at start of the round
function FirstSpawn(ply,commandName,args)
	if !(args[1]) or not ply.FirstSpawn then return end
	ply.FirstSpawn = false
	ply:SetTeam(ply.StartTeam)
	ply.SpawnAsClass = tonumber(args[1])
	ply.NextLoadout = ply:ValidateLoadout(ply.StartTeam, ply.SpawnAsClass, tonumber(args[2]))	
	-- now SPAWN!!	
	ply:UnLock()
	ply:GodDisable()
	ply:SetColor(255,255,255,255)
	ply:Spawn()
	
	if LASTHUMAN then
		umsg.Start("lasthuman",ply)
		umsg.End()
	end
	
	-- Send over some final information
	SendAdminStats( ply )
	
	if (ply:Team() == TEAM_UNDEAD) then
		DeadPeople[ply:SteamID()] = true
	end
	
end
concommand.Add("first_spawn",FirstSpawn) 

-- Resends player data once the player is valid clientside
function ResendPlayerData(pl, commandName, args)

	if not ValidEntity(pl) then return end
	
	pl.Validated = true
	
	-- Data for others
	umsg.Start( "SetClass" )
		umsg.Entity( pl )
		umsg.Short( pl:GetPlayerClass() )
	umsg.End()
	umsg.Start( "SetTitle" )
		umsg.Entity( pl )
		umsg.String( pl:Title() )
	umsg.End()
	
	-- Data for target player
	
	SendPlayerData( pl, pl )
	SendAdminStats( pl )
	
	if pl:IsAdmin() then
		SendMapExploits( pl )
	end
	UpdateData( pl )
	SendShopData( pl )
	
	GAMEMODE:SynchronizeTime(pl)
	GAMEMODE:SynchronizeReinforcements(pl)
	
end
concommand.Add("data_synchronize",ResendPlayerData) 

-- Synchronize the time with the selected player
function GM:SynchronizeTime( pl )
	umsg.Start("SendTime", pl)
		umsg.Short(ROUNDLENGTH)
		umsg.Long(ROUNDTIME)
	umsg.End()
end

-- Synchronize undead reinforcements
function GM:SynchronizeReinforcements( pl )
	umsg.Start("SendReinforce", pl)
		umsg.Short(self.Reinforcements)
	umsg.End()
end

function UpdateData( pl )
	-- Send everyone's data to this player, split up in parts of 10 to avoid making the usermessages too long
	local players = player.GetAll()
	local taboftables = {{}}
	for k=1, math.ceil(#players/5) do -- apparently I must first initialize each subtable...
		taboftables[k] = {}
	end
	for k, ply in pairs(players) do
		for i=1, math.ceil(#players/5) do
			if table.Count(taboftables[i]) < 5 then
				table.insert(taboftables[i],ply)
				break
			end
		end
	end
	
	for k, tab in pairs(taboftables) do
		if #tab == 0 then break end -- end of line
		umsg.Start( "SetData", pl )
			umsg.Short( #tab )
			for k, v in pairs(tab) do
				umsg.Entity( v )
				umsg.String( v:Title() )
				umsg.Short( v:GetPlayerClass() )
				umsg.Bool( v.Detectable )
			end
		umsg.End()
	end
end

local news_nr = 1
--- set news timer
local function DisplayNews()
	for k, pl in pairs(player.GetAll()) do
		pl:PrintMessage(HUD_PRINTTALK,"[INFO] "..NEWS[news_nr])
	end
	
	news_nr = news_nr+1
	if (news_nr > #NEWS) then
		news_nr = 1
	end
	
end
if NEWSTIMER ~= -1 then
	timer.Create("newstimer", NEWSTIMER, 0, DisplayNews)
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	pl:StripWeapons()
	pl:ShouldDropWeapon( false )
	pl.Dissolving = false
	pl.Gibbed = false
	pl.AllowedSweps = {}
	
	if LASTHUMAN and pl:Team() != TEAM_UNDEAD then
		SwitchToUndead( pl )
		pl:Kill()
	end
	
	-- Prevent the player from actually spawning at first spawn
	if (pl.FirstSpawn and not ENROUND) then
	
		-- Bot testing
		if ( pl:SteamID() == "BOT" ) then
			local cls, load
			if pl.StartTeam == TEAM_UNDEAD then
				cls = math.random(1,#UndeadClass)
				load = math.random(1,#UndeadClass[cls].SwepLoadout)
			else
				cls = math.random(1,#HumanClass)
				load = math.random(1,#HumanClass[cls].SwepLoadout)
			end
			FirstSpawn(pl,"first_spawn",{cls,load})
			return
		end
		
		-- kill player (don't let him spawn just yet)
		pl:Spectate( OBS_MODE_FIXED ) 	-- set in spectate team
		pl:Lock()						-- lock movement
		pl:GodEnable()					-- make invincible
		pl:SetColor(255,255,255,0)		-- make invisible
		
		-- show class VGUI once validated
		local com
		if (pl.StartTeam == TEAM_HUMAN) then
			com = "iw_start_human"
		else
			com = "iw_start_undead"
		end
		
		timer.Create(pl:UniqueID().."menutimer",0.05,0,function( ply, cmd )
			if ply.Validated then
				ply:ConCommand(cmd)
				timer.Destroy(ply:UniqueID().."menutimer")
			end
		end,pl,com)
		
	else		
		-- Normal spawning
		pl:UnSpectate()
		pl:Freeze(false)
		pl:SendLua("OnPlayerSpawn("..pl:Team()..")")
		
		GAMEMODE:SendCoins(pl)
		
		GAMEMODE:SynchronizeTime(pl) -- sends over the current time to the player
		GAMEMODE:SynchronizeReinforcements(pl) 	
		
		if ENDROUND then 
			pl:Lock()
			pl:GodEnable()
			umsg.Start( "GameEndRound", pl )
				umsg.Short( ROUNDWINNER )
				umsg.Bool( false )
			umsg.End()
			return 
		end
		
		-- First player to join starts up the round
		self.GameState = ROUNDSTATE_PLAY
		
		pl:SetPlayerClass(pl.SpawnAsClass)
		pl.Loadout = pl.NextLoadout
		pl.StartTime = pl.StartTime or CurTime()
		pl:SetPower( 0 )
		pl:SetDetectable(false)
		
		// SUIT TESTING
		for k, v in pairs(suitsData) do
			if (pl:HasBought(k) or pl:IsBot()) and pl:Team() == v.team and pl:GetPlayerClass() == v.class then
				pl:SetSuit( k )
			end
		end
		pl:CheckSuit()
		
		local hp = 100
		local suitpow = 100
		if (pl:Team() == TEAM_UNDEAD) then	
			pl.AllowedSweps = { "iw_und_sacrificer" }
			pl.AllowedSweps = table.Add(pl.AllowedSweps,UndeadClass[pl:GetPlayerClass()].SwepLoadout[pl.Loadout].Sweps)
			GAMEMODE:SetPlayerSpeed( pl ,UndeadClass[pl.Class].WalkSpeed, UndeadClass[pl.Class].RunSpeed )
			hp = UndeadClass[pl.Class].Health
			suitpow = 0
			if (pl:HasBought("fragilewarden")) then
				pl.SniperWarden = true
			end
			pl.BabySpawnRetries = 0
			if (pl:HasBought("abortiondenial")) then
				pl.BabySpawnRetries = 1
			end
			
		elseif (pl:Team() == TEAM_HUMAN) then
			pl.AllowedSweps = HumanClass[pl:GetPlayerClass()].SwepLoadout[pl.Loadout].Sweps
			GAMEMODE:SetPlayerSpeed( pl, HumanClass[pl.Class].WalkSpeed, HumanClass[pl.Class].RunSpeed )
			hp = HumanClass[pl.Class].Health
			suitpow = HumanClass[pl.Class].SuitPower
			if (HumanClass[pl.Class].SpawnTurret) then // spawn turret for classes that have one
				local ent = ents.Create ("turret")
				if ValidEntity(ent) then
					ent:SetPos(pl:GetPos()+Vector(0,0,30)+pl:GetAimVector()*50)
					ent:SetAngles(Angle(0,pl:GetAimVector():Angle().y,0))
					ent:SetOwner(pl)
					ent:Spawn()
					pl.Turret = ent
					
					if (pl.EquipedSuit == "experimentalupgradepack") then
						ent:SetHealthDefault(180)
					else
						ent:SetHealthDefault(150)
					end
				end
			end
		else
			-- something probably went wrong
			pl:Kill()
			self:ClassSpawn(pl,"class_spawn",{2,1}) -- spawn as zombie
			return
		end
		
		local bonushp = 0
		if (pl.EquipedSuit == "behemothdemonsuit") then
			bonushp = 100
			local healfield = ents.Create("demon_heal_field")
			healfield:SetOwner(pl)
			healfield:SetPos(pl:GetPos())
			healfield:Spawn()
		elseif (pl.EquipedSuit == "zombiecorpsemastersuit") then
			bonushp = 40
		elseif (pl.EquipedSuit == "assaultshieldpack") then
			bonushp = 30
		end
		
		local bonussuitpow = 0
		if (pl.EquipedSuit == "suppliesboosterpack") then
			bonussuitpow = math.floor(suitpow*0.25)
		elseif (pl.EquipedSuit == "experimentalupgradepack") then
			bonussuitpow = math.floor(suitpow/3)
		end
		
		pl:SetMaximumHealth(hp+bonushp)
		pl:SetHealth(hp+bonushp)
		
		pl:SetMaxSuitPower(suitpow+bonussuitpow)
		pl:SetSuitPower(suitpow+bonussuitpow)
		
		if not pl.SpawnedAtBaby then
			pl:GodEnable()
			pl.God = true
			timer.Simple(SPAWN_PROTECTION,function(ply)
				if ValidEntity(ply) then
					ply:GodDisable()
					pl.God = false
				end
			end,pl)
			pl.SpawnedAtBaby = false
		end
		
		--// Call item loadout function
		hook.Call( "PlayerLoadout", GAMEMODE, pl )
		
		--// Set player model
		hook.Call( "PlayerSetModel", GAMEMODE, pl )
		
		pl:SetColor(255,255,255,255)
		timer.Simple(0.2,function( ply )
			if ValidEntity(ply) then
				ply:SetColor(255,255,255,255)
			end
		end,pl)
	end
end

/*--------------------
Set player speed stuff
---------------------*/
function GM:SetPlayerSpeed(pl, walk, run)
	if pl:IsValid() then
		if pl.EquipedSuit == "bonesgalesuit" then
			run = run * 1.2
		end
		
		-- We do it the other way around. So you won't have to hold shift all the fucking time
		pl:SetWalkSpeed(run)
		pl:SetRunSpeed(walk)
	end
end

// Player cannot enter vehicles
function GM:CanPlayerEnterVehicle( player, vehicle, role )
	return false
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSetModel( )
   Desc: Set the player's model
---------------------------------------------------------*/
function GM:PlayerSetModel( pl )

	local modelname
	
	if ( pl:Team() == TEAM_UNDEAD ) then
		modelname = UndeadClass[pl.Class].Model
	else
		modelname = HumanClass[pl.Class].Model
	end
	
	pl:SetModel( modelname )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )
	
	-- Just so the ammo doesn't increment per round
	pl:RemoveAllAmmo()
	
	local toChoose = nil
	
	-- Give the choosen loadout
	if (pl:Team() == TEAM_UNDEAD) then		
		for k,v in pairs(UndeadClass[pl.Class].SwepLoadout[pl.Loadout].Sweps) do
			toChoose = v
			pl:Give( v )
		end
	else
		for k,v in pairs(HumanClass[pl.Class].SwepLoadout[pl.Loadout].Sweps) do
			toChoose = v
			pl:Give( v )
		end	
	end
	
	if pl:Team() == TEAM_UNDEAD then
		pl:Give("iw_und_sacrificer")
	end

	pl:SelectWeapon( toChoose )
	-- The first time the player chooses his weapon, only the server calls the deploy function
	-- So we'll have to call it clientside a bit later
	pl:SendLua("CallLateDeploy()") 
	
	if (pl.EquipedSuit == "supportammopack") then
		local weps = pl:GetWeapons()
		local primtype = ""
		for k, v in pairs(weps) do
			if v:IsValid() and v.Primary ~= nil then
				if v.Primary.Ammo == "grenade" then
					pl:GiveAmmo(2, v:GetPrimaryAmmoType())
				elseif v.Primary.Ammo == "slam" then
					pl:GiveAmmo(1, v:GetPrimaryAmmoType())
				else
					primtype = v:GetPrimaryAmmoType()
					pl:GiveAmmo(pl:GetAmmoCount(primtype), primtype)
				end
			end
		end
	end
end

function SendPlayerData( from, to )
	if not PLAYER_STATS then return end
	if not to:IsValid() or not from:IsValid() then end

	umsg.Start( "SetRecordData", to )
		umsg.Entity( from )
		for k, v in pairs(recordData) do
			umsg.String( tostring(math.floor(tonumber(from.DataTable[k]))) )
		end
		for k, v in pairs(achievementDesc) do
			umsg.Bool( from.DataTable["achievements"][k] )
		end
	umsg.End()
	
end

/*--- Whether player can pickup weapon ------------*/
function GM:PlayerCanPickupWeapon(ply, entity)
	local entname = entity:GetClass()
	if (entname == "weapon_physgun" or entname == "weapon_physcannon") then 
		return ply:IsAdmin()
	end
	if ply:IsAdmin() then return true end

	local tab = { "weapon_crowbar", "weapon_stunstick", "weapon_pistol", "weapon_smg1", "weapon_ar2", "weapon_crossbow",
	"weapon_shotgun", "weapon_rpg", "weapon_slam", "weapon_frag" }
	if (table.HasValue(tab,entname)) then
		entity:Remove()
	end

	return table.HasValue(ply.AllowedSweps,entname)
end


/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	

	-- Destroy all unnecessary entities
	local toDestroy = ents.FindByClass("prop_ragdoll")
	toDestroy = table.Add(toDestroy, ents.FindByClass("npc_zombie"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("npc_maker"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("npc_template_maker"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("npc_maker_template"))	
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_physicscannon"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_crowbar"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_stunstick"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_357"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_pistol"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_smg1"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_ar2"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_crossbow"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_shotgun"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_rpg"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_slam"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_pumpshotgun"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_ak47"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_deagle"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_fiveseven"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_glock"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_m4"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_mac10"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_mp5"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_para"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_tmp"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("weapon_frag"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_357"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_357_large"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_pistol"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_pistol_large"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_box_buckshot"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_ar2"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_ar2_large"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_ar2_altfire"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_dynamic_resupply"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_rpg_round"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_item_crate"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_crate"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_crossbow"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_smg1"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_smg1_large"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_ammo_smg1_grenade"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_box_buckshot"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("func_healthcharger"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("func_recharge"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_healthcharger"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_battery"))
	toDestroy = table.Add(toDestroy, ents.FindByClass("item_suitcharger"))
    toDestroy = table.Add(toDestroy, ents.FindByClass("item_healthkit"))
    toDestroy = table.Add(toDestroy, ents.FindByClass("item_healthvial"))
	for _, ent in pairs(toDestroy) do
		ent:Remove()
	end
	
	-- Sort out spawnpoints
	self.UndeadSpawnPoints = {}
	self.UndeadSpawnPoints = ents.FindByClass("info_player_undead") -- Zombie Survival spawnpoints
	self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_zombie"))
	self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_rebel")) -- HL2 DM spawns
	self.UndeadSpawnPoints = table.Add( self.UndeadSpawnPoints, ents.FindByClass( "info_player_axis" ) ) -- DoD spawns
	
	self.HumanSpawnPoints = {}
	self.HumanSpawnPoints = ents.FindByClass("info_player_human") -- Zombie Survival spawnpoints
	self.HumanSpawnPoints = table.Add( self.HumanSpawnPoints, ents.FindByClass("info_player_combine")) -- HL2 DM spawns
	self.HumanSpawnPoints = table.Add( self.HumanSpawnPoints, ents.FindByClass( "info_player_allies" ) ) -- DoD spawns
	
	local mapname = game.GetMap()
	-- Counter-Strike: Source spawnpoints
	-- In cs_ and zs_ maps, terrorist spawns are usually at the most defendable place, place humans there
	if string.find(mapname, "cs_") or string.find(mapname, "zs_") then
		self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_counterterrorist"))
		self.HumanSpawnPoints = table.Add( self.HumanSpawnPoints, ents.FindByClass("info_player_terrorist"))
	else -- In other counter-strike maps, it's the other way around most of the time
		self.UndeadSpawnPoints = table.Add(self.UndeadSpawnPoints, ents.FindByClass("info_player_terrorist"))
		self.HumanSpawnPoints = table.Add(self.HumanSpawnPoints, ents.FindByClass("info_player_counterterrorist"))
	end	
	-- Old GMod spawns
	for _, oldspawn in pairs(ents.FindByClass("gmod_player_start")) do
		if oldspawn.BlueTeam then
			table.insert(self.HumanSpawnPoints, oldspawn)
		else
			table.insert(self.UndeadSpawnPoints, oldspawn)
		end
	end	
	-- TF2 spawns
	for _, tf2spawn in pairs(ents.FindByClass("info_player_teamspawn")) do
		if tf2spawn:GetKeyValues().TeamNum == 3  then -- Red TF2 spawn
			table.insert(self.HumanSpawnPoints, tf2spawn)
		else -- Blue TF2 spawns and the rest with the undead
			table.insert(self.UndeadSpawnPoints, tf2spawn)
		end
	end	
	-- If no team spawn have been found, it's probably a deathmatch map.
	if #self.HumanSpawnPoints <= 0 then
		self.DeathMatchMap = true
		self.HumanSpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("info_player_start"))
		self.HumanSpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("info_player_deathmatch" ))
	end
	if #self.UndeadSpawnPoints <= 0 then
		self.DeathMatchMap = true
		self.UndeadSpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("info_player_start"))
		self.UndeadSpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass("info_player_deathmatch"))
	end
	
end

/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
local SPregen = 0
ImpulseList = {}

function GM:Think( )

	-- Round time handling
	if (self.GameState == ROUNDSTATE_PLAY and not ENDROUND) then
		if (team.NumPlayers(TEAM_HUMAN) <= 0 and not TESTMODE) then
			if self:RoundTimeLeft() > ROUNDTIME/2 and #player.GetAll() >= 10 then
				for k, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
					pl:UnlockAchievement("steamroller")
				end
				if self:RoundTimeLeft() > ROUNDTIME*0.75 then
					for k, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
						pl:UnlockAchievement("hellflood")
					end				
				end
			end
			self:EndRound( TEAM_UNDEAD, "humans_killed" ) --End the game (in favor of undead)
		end
		if (self:RoundTimeLeft() <= 0) then
			self:EndRound( TEAM_HUMAN, "roundtime_ended" ) --End the game (in favor of humans)
		end
	elseif (self.GameState == ROUNDSTATE_END) then
		if (self:RoundTimeLeft() <= 0) then
			if (MapVotes.curMap >= MapVotes.nextMap and MapVotes.curMap >= MapVotes.secondNextMap and self.CanRestart) then
				print("VOTE END; Restarting round")
				self:RestartRound()
			elseif (MapVotes.nextMap >= MapVotes.secondNextMap) then
				print("VOTE END; Loading next map")
				self:LoadNextMap(self.NextMap)
			else	
				print("VOTE END; Loading second next map")
				self:LoadNextMap(self.SecondNextMap)
			end
		end
	end
	
	-- Suit regen power (when in Regen mode)
	SPregen = SPregen or 0
	local powTab = {}
	if (SPregen < CurTime()) then
		for k,v in pairs(player.GetAll()) do
			if (v:IsValid()) then
				if (v:Team() == TEAM_HUMAN and v:GetPower() == 3 and v:WaterLevel() < 2) then
					local add = HumanPowers[3].Cost
					if v:GetPlayerClass() == CLASS_H_EXPERIMENTAL then
						add = add * 1.3
					end
					if v:HasBought("duracell4") then
						add = add * 1.25
					end
					v:SetSuitPower(v:SuitPower()+add)
					v:SetHealth(math.min(v:Health()+1,v:GetMaximumHealth()))
				end
			end
		end
		SPregen = CurTime()+REGEN_TIMER
	end
	
	// Update impulse list
	for k, pl in pairs( player.GetAll() ) do
		local speed = pl:GetVelocity():Length()
		if not ImpulseList[pl] then
			ImpulseList[pl] = { speed = 0, dir = Vector(0,0,0), time = CurTime() }
		end
		
		if ImpulseList[pl].speed < speed then
			ImpulseList[pl].speed = speed
		else
			local diff = math.min(1, (CurTime() - ImpulseList[pl].time) * 2)
			ImpulseList[pl].speed = speed * diff + ImpulseList[pl].speed * (1-diff)
		end
		ImpulseList[pl].dir = (ImpulseList[pl].dir*0.8+pl:GetVelocity():GetNormal()*0.2):GetNormal()
		ImpulseList[pl].time = CurTime()
	end
	
end

/*------------------------------------
	Print message to all players
------------------------------------*/

HUD_PRINTADMINCHAT = 77 -- custom printtype
function PrintMessageAll( printtype, text )

	if (printtype == HUD_PRINTADMINCHAT) then
		for k,v in pairs(player.GetAll()) do
			if (v:IsAdmin()) then
				v:PrintMessage(HUD_PRINTTALK,text)
			end
		end	
	else
		for k,v in pairs(player.GetAll()) do
			v:PrintMessage(printtype,text)
		end
	end
	
end

/*---------------------------------------------------------
   End the round (show scoreboard etc.)
---------------------------------------------------------*/
function GM:EndRound( winner, reason )

	if ENDROUND then return end
	ENDROUND = true	
	
	for k, pl in pairs(player.GetAll()) do
		if not pl.FirstSpawn then
			-- three minute survival as last human
			if (LASTHUMAN and pl.LastHumanStartTime and CurTime()-pl.LastHumanStartTime >= 3*60 and #player.GetAll() >= 8) then
				pl:UnlockAchievement("onemanarmy")
			end
		
			-- shared damage of over 12000
			if self.DamageThisRound >= 12000 then
				pl:UnlockAchievement("worldwar666")
				if self.DamageThisRound >= 18000 then
					pl:UnlockAchievement("worldwarzero")
				end
			end
		
			-- Check for the slacker achievement
			if (CurTime() - pl.StartTime > ROUNDLENGTH*0.75 and pl:Team() == TEAM_HUMAN and #player.GetAll() >= 8) then
				if pl:Frags() == 0 then
					pl:UnlockAchievement("slacker")
				end
				if pl.DamageTaken == 0 then
					pl:UnlockAchievement("deusexmachina")
				end
			end
		end
	end
	
	-- First undead kill timers
	timer.Destroy("FirstSlay")
	timer.Destroy("FirstSlayBackup")
	
	-- Reset round timer for intermission
	ROUNDTIME = CurTime() + INTERMISSIONTIME
	ROUNDWINNER = winner
	
	self.GameState = ROUNDSTATE_END

	/*--- Send round stats (I know players love these) --- */
	local UndKiller = {}
	local HumKiller = {}
	local UndDmg = {}
	local HumDmg = {}
	local MostSocial = {}
	local MostScary = {}
	local MostUnlucky = {}
	for k, pl in pairs(player.GetAll()) do
		if pl:IsValid() and pl.UndeadKilled != nil then
			if pl.UndeadKilled > 0 then
				table.insert(UndKiller, pl)
			end
			if pl.HumansKilled > 0 then
				table.insert(HumKiller, pl)
			end
			if pl.DamageToUndead > 0 then
				table.insert(UndDmg, pl)
			end
			if pl.DamageToHumans > 0 then
				table.insert(HumDmg, pl)
			end
			if pl.AmountHealed > 0 or pl.AmountSupplied > 0 then
				table.insert(MostSocial, pl)
			end
			if pl.ScreensFucked > 0 then
				table.insert(MostScary, pl)
			end
			if pl:Deaths() > 0 then
				table.insert(MostUnlucky, pl)
			end
		end
	end
	table.sort(UndKiller,function(a, b) return a.UndeadKilled > b.UndeadKilled end)
	table.sort(HumKiller,function(a, b) return a.HumansKilled > b.HumansKilled end)
	table.sort(UndDmg,function(a, b) return a.DamageToUndead > b.DamageToUndead end)
	table.sort(HumDmg,function(a, b) return a.DamageToHumans > b.DamageToHumans end)
	table.sort(MostSocial,function(a, b) return a.AmountHealed+a.AmountSupplied > b.AmountHealed+b.AmountSupplied end)
	table.sort(MostScary,function(a, b) return a.ScreensFucked > b.ScreensFucked end)
	table.sort(MostUnlucky,function(a, b) return a:Deaths() > b:Deaths() end)
	
	umsg.Start( "SendTopStats" ) -- Keeping stuff compact....
		if UndKiller[1] then umsg.String( UndKiller[1]:Name() )
		else umsg.String( "-" ) end
		if HumKiller[1] then umsg.String( HumKiller[1]:Name() )
		else umsg.String( "-" ) end
		if UndDmg[1] then umsg.String( UndDmg[1]:Name() )
		else umsg.String( "-" ) end
		if HumDmg[1] then umsg.String( HumDmg[1]:Name() )
		else umsg.String( "-" ) end
		if MostSocial[1] then umsg.String( MostSocial[1]:Name() )
		else umsg.String( "-" ) end
		if MostScary[1] then umsg.String( MostScary[1]:Name() )
		else umsg.String( "-" ) end
		if MostUnlucky[1] then umsg.String( MostUnlucky[1]:Name() )
		else umsg.String( "-" ) end
		umsg.String( tostring(self.KillsThisRound) )
		umsg.String( tostring(math.floor(self.DamageThisRound)) )
	umsg.End()
	
	/*------- Next map options ---------*/
	self.CurMap = game.GetMap()
	self.CanRestart = true
	if ROUND_NUMBER >= MAX_ROUNDS_PER_MAP then
		self.CanRestart = false
	end
	
	self.NextMap = GetNextMap()
	self.SecondNextMap = GetNextMap(self.NextMap)
	
	MapVotes = { curMap = 0, nextMap = 0, secondNextMap = 0 }
	------- Send End Round status -------
	
	umsg.Start( "GameEndRound" )
		umsg.Short( winner )
		umsg.Bool( true ) -- show voting. New joiners can't vote
		umsg.Bool( self.CanRestart )
		umsg.String( self.CurMap)
		umsg.String( self.NextMap)
		umsg.String( self.SecondNextMap )
	umsg.End()

	umsg.Start("SynchronizeVotes")
		umsg.Short(MapVotes.curMap)
		umsg.Short(MapVotes.nextMap)
		umsg.Short(MapVotes.secondNextMap)
	umsg.End()
	
	VotingStarted = true
	NumberOfVoters = table.Count(player.GetAll())
	
	
	GAMEMODE:SynchronizeTime()
	GAMEMODE:SynchronizeReinforcements() 
	
	for k, pl in pairs(player.GetAll()) do
		pl:Lock()
		pl:GodEnable()	
		self:WritePlayerData( pl ) -- write player data
	end	

	-- Writes away stored map exploit blockers
	MapExploitWrite()

end

/*---------------------------------------------------------
	After round ended, load map
---------------------------------------------------------*/
function GM:LoadNextMap( nextmap )

	// failsafe?
	if not nextmap then 
		nextmap = GetNextMap()
	end

	-- Load the next map (spam commands to ensure it works)
	for k=1, 3 do
		game.ConsoleCommand( "changelevel " .. nextmap .. "\n" )
	end
	
	timer.Simple(3,function() -- If loading the next map fails, restart this one
		local curmap = game.GetMap()
		for k=1, 3 do
			game.ConsoleCommand( "changelevel " .. curmap .. "\n" )
		end
	end)
	
end

function GetNextMap( map )
	if map == nil then
		map = game.GetMap()
	end

	local curmap = map
	for k=1, (#MAPCYCLE-1) do
		if (curmap == MAPCYCLE[k].map) then
			for i=k, (#MAPCYCLE-1) do
				local check = i+1
				if (check > #MAPCYCLE) then
					check = i-#MAPCYCLE
				end
				if (MAPCYCLE[check].minplayers <= #player.GetAll() and MAPCYCLE[check].maxplayers >= #player.GetAll() ) then
					return MAPCYCLE[check].map
				end
			end
		end
	end
	return MAPCYCLE[1].map -- it's either last map in the list, or a unlisted one
end

function GM:ShowHelp(pl) -- Called when user presses the F1 key
	pl:ConCommand("iw_menu_help")
end
function GM:ShowTeam(pl) -- Called when user presses the F2 key
	pl:ConCommand("iw_menu_class")
end
function GM:ShowSpare1(pl) -- Called when user presses the F3 key
	pl:ConCommand("iw_menu_options")
end
function GM:ShowSpare2(pl) -- Called when user presses the F4 key
	pl:ConCommand("iw_menu_score")
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )

end

/*---------------------------------------------------------------------------
	Checks if the specified box hits anything that blocks player movement
---------------------------------------------------------------------------*/
function CheckCollisionBox( center, dir, width, length, height, ignore )
	local points = {}
	local aimv = dir:Normalize()
	local startv = center-Vector(0,0,height/2)
	local forv = Vector(aimv.x,aimv.y,0):Normalize()*(length/2)
	local rotv = aimv -- rotating modifies the vector its applied to
	rotv:Rotate(Angle(0,270,0))
	local rightv = Vector(rotv.x,rotv.y,0):Normalize()*(width/2)
	local upv = Vector(0,0,height)
	
	for k, v in pairs( {(forv-rightv), (-1*forv-rightv), (forv+rightv), (-1*forv+rightv)} ) do
		table.insert(points, startv+v+upv)
		table.insert(points, startv+v)
	end

	local ignorePoints = {}
	
	for k, v in ipairs(points) do
		table.insert(ignorePoints,v) -- avoid double tracing
		for i, j in ipairs(points) do
			if not table.HasValue(ignorePoints,j) then
				local trace = {}
				trace.start = v
				trace.endpos = j
				trace.mask = MASK_PLAYERSOLID
				trace.filter = ignore
				local tr = util.TraceLine( trace )
				if ( tr.Hit ) then
					return false
				end
			end
		end
	end
	
	return true

end

/*---------------------------------------------------------
   Name: gamemode:KeyPress( )
   Desc: Player pressed a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyPress( pl, key )

	-- Extra jump power
	if( key == IN_JUMP ) then 
		
		pl.LastWallJump = pl.LastWallJump or 0
		
		if ( pl:IsOnGround() ) then
		
			local jumpPow = 0
			if (pl:GetPower() == POWER_SPEED and pl:Team() == TEAM_HUMAN) then
				jumpPow = 200
			elseif (pl:Team() == TEAM_UNDEAD and pl:GetPlayerClass() == CLASS_Z_BONES) then
				jumpPow = 200
			end
			if jumpPow > 0 then
				if (pl:KeyDown(IN_SPEED)) then -- Jump height increases while sprinting
					jumpPow = jumpPow*2
				end
				pl:SetVelocity( Vector(0,0,jumpPow) )
			end
		
		elseif ( ((pl:HasBought("walljump") and pl:Team() == TEAM_HUMAN and pl:GetPower() == POWER_SPEED) 
			or pl.EquipedSuit == "bonesgalesuit") and pl.LastWallJump < CurTime()-1 ) then
			
			// Wall jumping!
			//print("Player "..pl:Name().." not on ground; pressed jump; Velocity "..pl:GetVelocity():Length().."; Impulse "..pl:GetImpulse())

			local speed = pl:GetImpulse()
			local dir = pl:GetImpulseDir()
			dir.z = 0
			local start = pl:GetPos()
			local trace = {}
			trace.start = start
			trace.endpos = start + dir * 120
			trace.filter = self
			trace.mask = MASK_SOLID
			
			local result = util.TraceLine(trace)
			
			local hitdis = (result.HitPos - pl:GetPos()):Length()
			local dot = math.abs(dir:GetNormal():Dot(result.HitNormal))
			local wallsurfacecheck = math.abs(result.HitNormal:Dot(Vector(0,0,1)))
			local distoground = pl:DistanceToGround()
			
			//print("Hit/HitWorld/HitNonWorld: "..tostring(result.Hit).."/"..tostring(result.HitWorld).."/"..tostring(result.HitNonWorld).."; HitNormal: "..tostring(result.HitNormal))
			//print("hitdis = "..hitdis.."; dot = "..dot.."; calc = "..(hitdis + dot*30))
			//print("distance to ground: "..distoground)
			//print("wallsurfacecheck: "..tostring(wallsurfacecheck))
			
			if (result.Hit and hitdis + dot*30  < 100 and wallsurfacecheck < 0.5 and distoground > 16 ) then
			
				pl.LastWallJump = CurTime()
			
				local veldir = pl:GetImpulse() * pl:GetImpulseDir()
				local reflectvec = veldir - ( 2 * veldir:Dot(result.HitNormal) ) * result.HitNormal
				reflectvec.z = math.max(120, reflectvec.z)
				
				//print("Player "..pl:Name().." walljumped!")
				
				pl:SetVelocity( reflectvec:GetNormal()*speed*1.1 + Vector(0,0,50) )//pl:GetVelocity()*-1 + Vector(0,0,speed*2/3) + result.HitNormal * (speed*1/3) )
				pl:EmitSound( "physics/body/body_medium_impact_soft"..math.random(1,4)..".wav" )
				
				//DebugVector( pl:GetPos(), result.HitPos-pl:GetPos(), Color(255, 0, 0) )
				//DebugVector( result.HitPos, result.HitNormal*4, Color(0, 0, 255) )
				//DebugVector( result.HitPos, reflectvec:GetNormal()*48, Color(0, 255, 0) )
			end
			
		end

	end
	
end


/*---------------------------------------------------------
   Name: gamemode:KeyRelease( )
   Desc: Player released a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyRelease( pl, key )

end
   
/*---------------------------------------------------------
   Name: gamemode:PlayerHurt( )
   Desc: Called when a player is hurt.
---------------------------------------------------------*/
function GM:PlayerHurt( ply, attacker, healthleft, healthtaken )
end

/*---------------------------------------------------------
   Name: gamemode:DoPlayerDeath( )
   Desc: Carries out actions when the player dies 		 
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	if ply.Disguised then -- disguised Stalker
		ply:SetModel(UndeadClass[3].Model)
		ply.Disguised = false
	end
	
	ply.MarkedThisLife = {}
	
	local deadeffort = (ply:GetPlayerClass() == CLASS_Z_BEHEMOTH and ply:Team() == TEAM_UNDEAD and ply:HasBought("deadeffort") and attacker:IsValid() and ply != attacker)
	
	if (( dmginfo:GetDamage() > 50 or deadeffort ) and not ply.Dissolving ) then
		ply:Gib( dmginfo )
		ply.Gibbed = true
		
		// BOOM
		if deadeffort then
			local ent = ents.Create("env_explosion")
			if ValidEntity(ent) then
				ent:EmitSound( "explode_4" )		
				ent:SetPos(ply:GetPos()+Vector(0,0,30))
				ent:Spawn()
				ent:SetOwner(ply)
				ent.Team = function() return TEAM_UNDEAD end
				ent.GetName = function() return "< Behemoth Kamikazi >" end
				ent:Activate()
				ent:SetKeyValue("iMagnitude", 120)
				ent:SetKeyValue("iRadiusOverride", 120)
				ent:Fire("explode", "", 0)
			end
		end
	else
		ply:CreateRagdoll()
		ply:PlayDeathSound()
		if ply.Dissolving then
			Dissolve( ply:GetRagdollEntity() )
		end
	end
	
	ply:DrawWorldModel(true) // fix up Stalker effects
	
	ply:Freeze( false )
	ply:AddDeaths( 1 )

	local inf = dmginfo:GetInflictor():GetClass()
	if inf == "player" and ply != attacker and dmginfo:GetInflictor():GetActiveWeapon() then
		inf = dmginfo:GetInflictor():GetActiveWeapon():GetClass()
	end
	
	// Update weapon kill statistics
	if ply != attacker then
		Stats.WeaponKills[inf] = Stats.WeaponKills[inf] or 0
		Stats.WeaponKills[inf] = Stats.WeaponKills[inf] + 1
		//print(table.ToString(Stats))
	end
	
	Stats.TotalDeaths = Stats.TotalDeaths + 1
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
		ply.LastKiller = attacker
	
		if ( attacker:Team() ~= ply:Team()) then
			
			Stats.TotalKills = Stats.TotalKills + 1
			
			local headshot = false
			local attach = ply:GetAttachment(1)
			if attach then
				headshot = dmginfo:IsBulletDamage() and dmginfo:GetDamagePosition():Distance(attach.Pos) < 15
			end
			
			if (table.HasValue(attacker.MarkedThisLife, ply) and attacker:GetPlayerClass() == CLASS_Z_WARGHOUL) then
				attacker:UnlockAchievement("zombieninja")
			end
			
			if (inf == "iw_knife" and ply:Team() == TEAM_UNDEAD and
				ply:GetPlayerClass() == CLASS_Z_BEHEMOTH and attacker.BehemothKnifing and (attacker.BhPos:Distance(ply:GetPos()) > 40 
				or attacker.BhAngle:Forward():Dot(ply:EyeAngles():Forward()) < 0.9) ) then -- Behemoth killed with knife <:O
				attacker:UnlockAchievement("crazybastard")
			end
			
			if (dmginfo:GetInflictor():GetClass() == "turret") then -- turret be killing mah enemies!
				dmginfo:GetInflictor():GetTable():AddKill()
			
				if attacker:HasBought("organicharvest2") then
					dmginfo:GetInflictor():GetTable():RestoreHealth( 5 )
				elseif attacker:HasBought("organicharvest1") then
					dmginfo:GetInflictor():GetTable():RestoreHealth( 3 )
				end			
			
				attacker:AddScore("turretkills",1)
				attacker.TurretKills = attacker.TurretKills+1
				
				if attacker.TurretKills >= 7 then
					attacker:UnlockAchievement("rachet&clank")
				end
				if attacker:GetScore("turretkills") >= 100 then
					attacker:UnlockAchievement("spraymoregetmore")
				end
			end
			
			local amount = 0
			
			if (attacker:Team() == TEAM_UNDEAD) then
				attacker:AddScore("humanskilled",1)
				attacker.HumansKilled = attacker.HumansKilled+1
				attacker:GiveMoney( 3 )
				
				if (attacker.EquipedSuit == "zombiecorpsemastersuit") then
					attacker:SetHealth(attacker:GetMaximumHealth())
					local eff = EffectData()
						eff:SetOrigin(attacker:GetPos())
					util.Effect( "demon_heal", eff )
				end
				
				if attacker.LastKiller and attacker.LastKiller == ply then
					attacker:UnlockAchievement("revengeinblood")
				end
				
				if not attacker:TraceLine(100, Vector(0,0,-1)).Hit then
					attacker:UnlockAchievement("airassault")
				end
				
				local humkilled = attacker.HumansKilled
				-- Achievement checking
				if humkilled >= 5 then
					attacker:UnlockAchievement("wrathofthedead")
					if humkilled >= 10 then
						attacker:UnlockAchievement("baneofhumanity")
					end
				end
				
				humkilled = attacker:GetScore("humanskilled")
				if humkilled >= 100 then
					attacker:UnlockAchievement("blackwidow")
					if humkilled >= 250 then
						attacker:UnlockAchievement("lichking")
						if humkilled >= 750 then
							attacker:UnlockAchievement("antichrist")
						end
					end
				end
				
				if attacker:GetPlayerClass() == CLASS_Z_BEHEMOTH then -- Behemoth
					table.insert(attacker.Blasted,CurTime())
					if #attacker.Blasted > 3 then
						table.remove(attacker.Blasted,1)
					end
					if #attacker.Blasted > 2 and attacker.Blasted[3]-attacker.Blasted[1] < 0.5 then
						attacker:UnlockAchievement("boomhemoth")
					end
				elseif attacker:GetPlayerClass() == CLASS_Z_STALKER then -- Stalker 
					if attacker:EyeAngles():Forward():Dot(ply:GetAngles():Forward()) > 0.7 then
						attacker:UnlockAchievement("wraithofevil")
					end				
				elseif attacker:GetPlayerClass() == CLASS_Z_BONES then -- Bones
					if attacker:GetVelocity():Length() > UndeadClass[4].RunSpeed-10 then
						attacker:UnlockAchievement("daredevil")
					end
				end
				
			elseif (attacker:Team() == TEAM_HUMAN) then
				attacker:AddScore("undeadkilled",1)
				attacker.UndeadKilled = attacker.UndeadKilled+1
				attacker:GiveMoney( 1 )
				
				weptype = "nothing"
				
				if swepDesc[inf] then
					weptype = swepDesc[inf].Type
				end
				local dis = attacker:GetPos():Distance(ply:GetPos())
				if dis >= 1970 then -- about 50 meters
					if weptype == "pistol" then
						attacker:UnlockAchievement("poormanssniper")
					elseif weptype  == "shotgun" then
						attacker:UnlockAchievement("crazymanssniper")
					end
					if headshot and weptype  == "sniper" and dis >= 4720 then -- about 120 meters
						attacker:UnlockAchievement("truemanssniper")
					end
				elseif dis <= 78 and weptype  == "shotgun" then -- about 2 meters
					attacker:UnlockAchievement("meatshower")
				elseif dis <= 394 and attacker:Health() < 10 then -- about 10 meters
					attacker:UnlockAchievement("closecall")
				end
				
				-- Achievement checking
				local undkilled = attacker.UndeadKilled
				if undkilled >= 15 then
					attacker:UnlockAchievement("perfectrun")
					if undkilled >= 25 then
						attacker:UnlockAchievement("rambo")
						if undkilled >= 35 then
							attacker:UnlockAchievement("divinewarrior")
						end
					end
				end
				undkilled = attacker:GetScore("undeadkilled")
				if undkilled >= 500 then
					attacker:UnlockAchievement("blackops")
					if undkilled >= 1500 then
						attacker:UnlockAchievement("superhuman")
						if undkilled >= 7777 then
							attacker:UnlockAchievement("warofluck")
						end
					end
				end
				
				// Drop shadeballs when warghoul and you have the required shopitem
				if ply:GetPlayerClass() == CLASS_Z_WARGHOUL and ply:HasBought("smokescreen") then
					for i = 1, 3 do
						local ball = ents.Create("shadeball")
						if ValidEntity(ball) then
							local force = 200
							local v = ply:GetPos()+Vector(0,0,40)
							ball:SetPos(v)
							ball:SetOwner(ply)
							ball:Spawn()
							ball:Activate()
							ball:SetMaterial("models/shadertest/shader4")
							
							local phys = ball:GetPhysicsObject()
							phys:SetVelocity((Vector(0,0,4)+Vector(math.Rand(0,1),math.Rand(0,1),math.Rand(0,1))):GetNormal()*force)
						end
					end
				end
			end
					
			attacker:AddFrags( 1 )
			self.KillsThisRound = self.KillsThisRound + 1
			
			-- Achievement check: if players get 5 kills within 5 seconds or 10 within 15 secs
			table.insert(attacker.Fraglist,CurTime())
			if (#attacker.Fraglist > 10) then
				table.remove(attacker.Fraglist,1)
			end
			
			if #attacker.Fraglist >= 5 and attacker.Fraglist[5]-attacker.Fraglist[1] <= 5 then
				attacker:UnlockAchievement("luckyluke")
			end	
			if #attacker.Fraglist >= 10 and attacker.Fraglist[10]-attacker.Fraglist[1] <= 15 then
				attacker:UnlockAchievement("bulletstorm")
			end			
		end
		
		-- check health to prevent suicide whores from draining the reinforcements
		if (ply:Team() == TEAM_UNDEAD and ply:Health() < 30 ) then 
			GAMEMODE:DecreaseReinforcements( 1 )
		end
		
	end
	
	// create corpse healing field (for undead that bought upgrades)
	if ply:IsOnGround() then
		local ent = ents.Create("corpse_heal_field")
		ent:SetPos(ply:GetPos())
		ent:Spawn()
	end
	
	
	if (ply:Team() ~= TEAM_UNDEAD) then
		SwitchToUndead( ply )
		
		if team.NumPlayers(TEAM_HUMAN) == 1 and (self:RoundTimeLeft() < ROUNDLENGTH*0.75 or team.NumPlayers(TEAM_UNDEAD) > 3) and not LASTHUMAN then
			LastHuman()
		end
	else
		if (math.random(1,math.max(1,math.floor(AMMO_DROPRATE))) == 1) then
			SpawnAmmo(ply:GetPos()+Vector(0,0,50))
		end
		
		if (ply:GetPlayerClass() == CLASS_Z_BEHEMOTH or ply.SpawnAsClass == CLASS_Z_BEHEMOTH) then
			ply.BeheDeaths = ply.BeheDeaths + 1
		end
	end
	
	if ply.PreferBehemoth and not BehemothExists() and (self.PreviousBehemoth != ply or team.NumPlayers(TEAM_UNDEAD) < 2) then
		ply.SpawnAsClass = CLASS_Z_BEHEMOTH
		ply.NextLoadout = 1
		ply:PrintMessage(HUD_PRINTTALK,"You have been chosen to become the Behemoth, the leader of the undead army!")		
		self.PreviousBehemoth = ply
		ply.BeheDeaths = 0
	end

end

function SwitchToUndead( ply )
	-- Set to zombie class
	ply:SetFrags(0)
	local newclass = 2
	if ply:IsBot() then
		newclass = math.random(2,5)
	end
	ply.SpawnAsClass = newclass
	ply:SetPlayerClass( newclass )
	ply.NextLoadout = 1
	ply:SetTeam(TEAM_UNDEAD)
	ply:SetPower( 0 )
	DeadPeople[ply:SteamID()] = true
	timer.Simple(0.5,function(pl) -- send with delay (gives client time to apply teamswitch)
		if ENDROUND or not ValidEntity(pl) then return end
		pl:ConCommand("iw_menu_class")
	end,ply)
end

function LastHuman()
	LASTHUMAN = true
	umsg.Start("lasthuman")
	umsg.End()
	local last = team.GetPlayers(TEAM_HUMAN)[1]
	last.LastHumanStartTime = CurTime()
	
	// Final Showdown: 5 seconds of godmode and extra ammo
	if last:HasBought("finalshowdown") then
		last:GodEnable()
		last:ChatPrint("UPGRADE ACTIVATED: Final Showdown!")
		timer.Simple(5, function( pl )
			if ValidEntity(pl) then
				pl:GodDisable()
			end
		end,last)
		local weps = last:GetWeapons()
		local primtype = ""
		for k, v in pairs(weps) do
			if v:IsValid() and v.Primary ~= nil then
				if v.Primary.Ammo != "grenade" and v.Primary.Ammo != "slam" then
					local primtype = v:GetPrimaryAmmoType()
					local clips = 2
					if v.Primary.ClipSize <= 20 then
						clips = 4
					elseif v.Primary.ClipSize <= 50 then
						clips = 3
					end
					
					last:GiveAmmo(math.ceil(v.Primary.ClipSize*clips), primtype)
				end
			end
		end
	end
	
	
	for k, v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTCONSOLE,"LAST HUMAN started! "..last:Name().." is the only one left!")
	end
end

/*--------- Spawns ammo -------------*/
function SpawnAmmo( pos )
	local Box = ents.Create("ammodrop")
	local Force = 200+math.random(0,50)
	
	Box:SetPos(pos)
	Box:SetAngles( Vector(math.random(-1,1),math.random(-1,1),math.random(-1,1)):GetNormal():Angle() )
	Box:Spawn()
	
	Box:Activate()
	
	local Phys = Box:GetPhysicsObject()
	Phys:SetVelocity(Vector(0,0,1) * Force)
end

/*-------- Teamkilling OFF ---------*/
function GM:PlayerShouldTakeDamage(pl, attacker)
	if ( attacker.Team ) then
		if( pl:Team() == attacker:Team() ) then
			return false
		end 
	end
	return true
end

/*---------------------------
Decrease undead reinforcments
---------------------------*/
function GM:DecreaseReinforcements( amount )

	GAMEMODE.Reinforcements = GAMEMODE.Reinforcements - amount

	if (GAMEMODE.Reinforcements <= 0) then
		for k, pl in pairs(team.GetPlayers( TEAM_HUMAN )) do
			pl:UnlockAchievement("mankindwillhold")
		end
		GAMEMODE:EndRound(TEAM_HUMAN, "undead_depleted")
		GAMEMODE.Reinforcements = 0
	end
	
	GAMEMODE:SynchronizeReinforcements() 
end


/*---------------------------------------------------------
   Name: gamemode:EntityTakeDamage( entity, inflictor, attacker, amount, dmginfo )
   Desc: The entity has received damage	 
---------------------------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	if ent:IsPlayer() then
		local ply = ent
		
		//print("Player "..ply:Name().." taking "..amount.." damage from "..attacker:GetClass().." using "..inflictor:GetClass() )
		
		if attacker:IsPlayer() then
			if attacker:Team() == ply:Team() then
				dmginfo:SetDamage(0)
				return
			end
			// disable spawn protection if you attack others
			if attacker.God then
				attacker:GodDisable()
				attacker.God = false
			end
		end
		
		if (string.find(attacker:GetClass(),"prop_physics")) then
			dmginfo:SetDamage(math.min(20,dmginfo:GetDamage()))
		end
		
		if (attacker:GetClass() == "meatrocket" or inflictor:GetClass() == "meatrocket") then
			// nullfies meatrocket physics damage
			dmginfo:SetDamage(0)
			return
		end
		
		// Silly bug
		if (ply:Team() == TEAM_UNDEAD and inflictor:GetClass() == "infectionball") then
			dmginfo:SetDamage(0)
		end
		
		// small chance of ignoring bullet damage when wearing this suit
		if ply.EquipedSuit == "bonesgalesuit" and dmginfo:IsBulletDamage() and math.random(1,10) == 1 then
			dmginfo:SetDamage(0)
		end
		
		if (ent:Team() == TEAM_UNDEAD and ent:GetPlayerClass() == CLASS_Z_BEHEMOTH) then
			if inflictor:GetClass() == "iw_knife" then
				if ent:Health() >= UndeadClass[1].Health then
					attacker.BehemothKnifing = true
					attacker.BhPos = ent:GetPos() -- make sure the guy ain't afk. That would be too easy...
					attacker.BhAngle = ent:EyeAngles()
				end
			else 
				attacker.BehemothKnifing = false
			end
		end
			
		-- Dynamic fall damage
		if dmginfo:IsFallDamage() then
			dmginfo:SetDamage( 0 )
			-- Undead are immune to fall damage
			if (ply:Team() ~= TEAM_UNDEAD) then
				local speed = math.abs(ply:GetVelocity().z)
				
				-- touchdown!
				if ply:HasBought("touchdown") and speed > 800 then
					StompShockWave( ply )
				end
				
				-- falldamage calculations
				local div_factor = 25
				if (ent:GetPower() == 1) then -- Jump power decreases damage
					div_factor = 60
				end
				local dmg = math.Clamp(speed/div_factor,5,50)
				
				if ply:HasBought("shockdampers") then
					dmg = dmg/2
				end				
				
				dmginfo:AddDamage( dmg )
			end
		else
			-- Armor hit
			if (ply:GetPower() == 0 and ply:SuitPower() > 0 and ply:Team() == TEAM_HUMAN) then
				if attacker:IsPlayer() or attacker:IsNPC() then	
					local multiplier = HumanClass[ply:GetPlayerClass()].ArmorDrainMultiplier
					local cost = HumanPowers[0].Cost
					if ply:HasBought("duracell3") then
						cost = cost * 0.75
					end
					if ply.EquipedSuit == "assaultshieldpack" then
						cost = cost * 0.7
					end
					ply:SetSuitPower( ply:SuitPower()-(dmginfo:GetDamage()*cost*multiplier) )
					dmginfo:SetDamage(0)
					umsg.Start("HUDArmorHit",ply)
					umsg.End()
				end
			end		
		end
		
		ply.DamageTaken = ply.DamageTaken + dmginfo:GetDamage()
		
		if dmginfo:GetDamage() ~= 0 then

			local headshot = false
			local attach = ply:GetAttachment(1)
			if attach then
				headshot = dmginfo:IsBulletDamage() and dmginfo:GetDamagePosition():Distance(attach.Pos) < 15
				if headshot and ply.LastHeadShot < CurTime()-1 and GORE_MOD then
					ply.LastHeadShot = CurTime() -- prevents blood spam
					for i= 0, 3 do -- Blood! :O
						ply:EmitSound("player/headshot"..math.random(1,2)..".wav")
						local effectdata = EffectData()
							effectdata:SetOrigin( attach.Pos )
							effectdata:SetNormal( (VectorRand() + Vector(0,0,math.random(0,1))):GetNormal() )
						util.Effect( "gore_bloodprop", effectdata )
					end
				end
			end
			
			if (attacker:IsValid() and attacker:IsPlayer()) then
				
				ply.PainSTimer = ply.PainSTimer or 0
				if ply.PainSTimer < CurTime() and math.random(1,3) == 1 then
					ply:PlayPainSound()
					ply.PainSTimer = CurTime()+2
				end
		
				self.DamageThisRound = self.DamageThisRound + dmginfo:GetDamage()
				
				if (ply:Team() == TEAM_UNDEAD) then
			
					if dmginfo:IsBulletDamage() and attacker:GetPos():Distance(ply:GetPos()) > 1500 and ply.SniperWarden then
						dmginfo:SetDamage(0)
						ply.SniperWarden = false
					end

					attacker:AddScore("undeaddamaged",dmginfo:GetDamage())
					attacker.DamageToUndead = attacker.DamageToUndead+dmginfo:GetDamage()
					
					-- Achievement checking
					if attacker:GetScore("undeaddamaged") >= 100000 then
						attacker:UnlockAchievement("angelofremorse")
						if attacker:GetScore("undeaddamaged") >= 1000000 then
							attacker:UnlockAchievement("angelofdisaster")
						end
					end
					
				elseif (ply:Team() == TEAM_HUMAN) then
					attacker:AddScore("humansdamaged",dmginfo:GetDamage())
					attacker.DamageToHumans = attacker.DamageToHumans+dmginfo:GetDamage()
					
					if (attacker.EquipedSuit == "warghoultoxicsuit" and ply.Detectable == false) then
						ply:SetDetectable(true)
						if math.random(1,2) == 1 then
							ply:EmitSound("weapons/bugbait/bugbait_impact1.wav")
						else
							ply:EmitSound("weapons/bugbait/bugbait_impact3.wav")
						end
					end
					
					-- Achievement checking
					if attacker:GetScore("humansdamaged") >= 10000 then
						attacker:UnlockAchievement("myfriendpain")
						if attacker:GetScore("humansdamaged") >= 50000 then
							attacker:UnlockAchievement("myfriendagony")
						end
					end
					
				end
			end
		end
	end 

end

/* ---- Check if a player is already using the Behemoth class ------*/
function BehemothExists()
	for k,v in pairs(player.GetAll()) do
		if (v:Team() == TEAM_UNDEAD and (v:GetPlayerClass() == CLASS_Z_BEHEMOTH or v.SpawnAsClass == CLASS_Z_BEHEMOTH)) then
			return true
		end
	end	
	return false
end

function StompShockWave( ply )
	local pos = ply:GetPos()
	WorldSound( "weapons/physcannon/superphys_launch2.wav", pos, 75, 100 )
	local effectdata = EffectData()
		effectdata:SetOrigin( pos )
	util.Effect( "stomp_shockwave", effectdata )
	
	// blast away all nearby players
	for k, ent in pairs(ents.FindInSphere(pos,250)) do
		if ent != ply then
			local phys = ent:GetPhysicsObject()
			if (ent:IsPlayer() and ent:Team() != ply:Team()) or ValidEntity(phys) then
				local origin = ent:GetPos()
				if ent:IsPlayer() then
					origin = origin + Vector(0,0,30)
				end
				local vec = origin-pos
				local dis = vec:Length()
				
				ent:TakeDamage(200/dis,ply,Entity())
				
				if ent:IsPlayer() then
					ent:SetVelocity( vec/dis*60000/dis )
				else
					phys:ApplyForceCenter( vec/dis*60000/dis )
				end
			end
		end
	end	
end


/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
		 Return true to not take damage
---------------------------------------------------------*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	
	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( math.sqrt(1.5) )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( math.sqrt(0.5) )
	 
	 end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDisconnected( )
   Desc: Player has disconnected from the server.
---------------------------------------------------------*/
function GM:PlayerDisconnected( pl )
	if ENDROUND then return end
	
	if pl.FirstSpawn == false then
		self:WritePlayerData(pl)
		DeadPeople[pl:SteamID()] = true
	end

	-- Sometimes this is exploited... (undead player rejoins just to make the game kill other players)
	if (team.NumPlayers(TEAM_UNDEAD) == 1 and pl:Team() == TEAM_UNDEAD and #player.GetAll() > 1) then
		timer.Simple(5,self.StartGameKill,self)
	end
	
	-- Prevents the round from ending too soon when the first human player disconnects
	if (table.Count(player.GetAll()) == 1 and team.NumPlayers(TEAM_HUMAN) == 1 and pl:Team() == TEAM_HUMAN and self:RoundTimeLeft() < 0.9*ROUNDTIME) then
		self.GameState = ROUNDSTATE_IDLE
	end
	
	-- Activate last human
	SwitchToUndead( pl )
	ImpulseList[pl] = nil
	
	if team.NumPlayers(TEAM_HUMAN) == 1 and (self:RoundTimeLeft() < ROUNDLENGTH*0.75 or team.NumPlayers(TEAM_UNDEAD) > 3) and not LASTHUMAN then
		LastHuman()
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSay( )
   Desc: A player (or server) has used say. Return a string
		 for the player to say. Return an empty string if the
		 player should say nothing.
---------------------------------------------------------*/
function GM:PlayerSay( player, text, teamonly )
	return text
end

-- Hooks on PlayerSay can be found in commands.lua

/*---------------------------------------------------------
   Name: gamemode:PlayerDeathThink( player )
   Desc: Called when the player is waiting to respawn
---------------------------------------------------------*/
function GM:PlayerDeathThink( pl )

	-- wait till the player's spawntime is over
	if (  pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then 
		return 
	end

	-- revoke their Behemoth power if they're afk for longer than a minute
	if pl:Team() == TEAM_UNDEAD and (pl:GetPlayerClass() == CLASS_Z_BEHEMOTH or pl.SpawnAsClass == CLASS_Z_BEHEMOTH) 
		and (CurTime()-pl.BehemothTimeout > 60 or pl.BeheDeaths >= BEHEMOTH_DEATH_LIMIT) then
		pl.SpawnAsClass = CLASS_Z_ZOMBIE
		pl:SetPlayerClass( CLASS_Z_ZOMBIE )
		pl.NextLoadout = 1
		pl:ChatPrint("You are no longer the Behemoth")
	end
	
	-- spawn if you're undead and the there are still reinforcements
	if (pl:Team() == TEAM_UNDEAD and UNDEAD_REINFORCEMENTS > 0) then
		if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) || pl:IsBot() ) then
			pl:Spawn()	
		end
	end	
	
end

/*---------------------------------------------------------
	Name: gamemode:PlayerUse( player, entity )
	Desc: A player has attempted to use a specific entity
		Return true if the player can use it
//--------------------------------------------------------*/
function GM:PlayerUse( pl, entity )
	// door exploit prevention
	pl.LastDoorUse = pl.LastDoorUse or 0
	local doors = { "func_door", "prop_door_rotating", "func_door_rotating" }
	if table.HasValue(doors,entity:GetClass()) then
		if pl.LastDoorUse+2 > CurTime() then
			return false
		end
		pl.LastDoorUse = CurTime()
	end
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function GM:PlayerDeath( Victim, Inflictor, Attacker )

	// Don't spawn for at least 2 seconds
	Victim.NextSpawnTime = CurTime() + SPAWNTIME
	Victim.BehemothTimeout = CurTime()
	
	// Convert the inflictor to the weapon that they're holding if we can.
	// This can be right or wrong with NPCs since combine can be holding a 
	// pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then

		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = Attacker end
	
	end
	
	local inflictorClass = ""
	if ( Inflictor and Inflictor:GetClass() == "env_explosion" and Inflictor.Inflictor ) then
		inflictorClass = Inflictor.Inflictor // makes sense, no? Is to redirect inflictor for grenades and meatrocket
	else
		inflictorClass = Inflictor:GetClass()
	end
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( inflictorClass )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. inflictorClass .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( inflictorClass )
		umsg.Entity( Attacker )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
end

function Dissolve( ent )
	if ( ValidEntity( ent ) && !ent.Dissolving ) then            
		local dissolve = ents.Create( "env_entity_dissolver" )
		dissolve:SetPos( ent:GetPos() )

		local targname = "dis"..ent:EntIndex()
		ent:SetName(targname)
		dissolve:SetKeyValue( "target", targname )
		dissolve:SetKeyValue( "dissolvetype", 0 )
		dissolve:SetKeyValue( "magnitude", 0 )
		dissolve:Spawn()
		dissolve:Fire( "Dissolve", targname, 0 )
		dissolve:Fire( "kill", "", 1 )

		dissolve:EmitSound( Sound( "NPC_CombineBall.KillImpact" ) )

		ent.Dissolving = true
	end
end

  
/*---------------------------------------------------------
   Name: gamemode:PlayerSelectSpawn( player )
   Desc: Find a spawn point entity for this player
---------------------------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	-- Based off the spawn selection in Zombie Survival
	-- So credit to JetBoom for this
	if pl:Team() == TEAM_UNDEAD then
	
		if pl.BabySpawn and pl.BabySpawn:IsValid() and pl.BabySpawn:GetTable():Alive() then
			timer.Simple(0.5,function ( ply ) -- destroy sacrifical baby spawn
				if ValidEntity(ply) and ply.BabySpawn:IsValid() and ply.BabySpawn:Alive() then
					ply.BabySpawn:GetTable():Eliminate()
				end
			end,pl)
			pl.SpawnedAtBaby = true
			local spawnpoint = pl.BabySpawn:GetTable():GetSpawn()
			// push away everything that stands in the way
			for _, ent in pairs(ents.FindInBox(spawnpoint:GetPos() + Vector(-48, -48, 0), spawnpoint:GetPos() + Vector(48, 48, 60))) do
				if ValidEntity(ent) then
					local force = (ent:GetPos()-spawnpoint:GetPos()):GetNormal()*500
					ent:SetVelocity(force)
					local phys = ent:GetPhysicsObject()
					if ValidEntity(phys) then
						phys:ApplyForceCenter(force)
					end
				end
			end
			return spawnpoint
		end
	
		local Count = #self.UndeadSpawnPoints
		if Count == 0 then return pl end
		if !self.DeathMatchMap then
			for i=0, 20 do
				local ChosenSpawnPoint = self.UndeadSpawnPoints[math.random(1, Count)]
				if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() and ChosenSpawnPoint ~= LastZombieSpawnPoint then
					local blocked = false
					for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, 0), ChosenSpawnPoint:GetPos() + Vector(48, 48, 60))) do
						if ent and ent:IsPlayer() then
							blocked = true
						end
					end
					if not blocked then
						LastZombieSpawnPoint = ChosenSpawnPoint
						return ChosenSpawnPoint
					end
				end
			end
		else
			LastZombieSpawnPoint = self:ChooseMostFarSpawn(pl)
		end
		return LastZombieSpawnPoint
	else
		local Count = #self.HumanSpawnPoints
		if Count == 0 then return pl end
		for i=0, 20 do
			local ChosenSpawnPoint = self.HumanSpawnPoints[math.random(1, Count)]
			if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() and ChosenSpawnPoint ~= LastHumanSpawnPoint then
				local blocked = false
				for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, 0), ChosenSpawnPoint:GetPos() + Vector(48, 48, 60))) do
					if ent and ent:IsPlayer() then
						blocked = true
					end
				end
				if not blocked then
					LastHumanSpawnPoint = ChosenSpawnPoint
					return ChosenSpawnPoint
				end
			end
		end
		return LastHumanSpawnPoint
	end
	return pl
	
end

function GM:ChooseMostFarSpawn(pl)
	local c = 0
	local vec = Vector(0,0,0)
	for k, v in pairs(team.GetPlayers(TEAM_HUMAN)) do
		c = c+1
		vec = vec+v:GetPos()
	end

	local averageteampos = vec/c
	local chosenpoint = self.UndeadSpawnPoints[1]
	local dis = chosenpoint:GetPos():Distance(averageteampos)
	local blocked = false
	
	for k, v in pairs(self.UndeadSpawnPoints) do
		if (dis < v:GetPos():Distance( averageteampos ) and v != LastZombieSpawnPoint) then
			blocked = false
			for _, ent in pairs(ents.FindInBox(v:GetPos() + Vector(-48, -48, 0), v:GetPos() + Vector(48, 48, 60))) do
				if ent and ent:IsPlayer() then
					blocked = true
				end
			end
			if not blocked then
				chosenpoint = v
				dis = v:GetPos():Distance( averageteampos )
			end			
		end
	end
	
	return chosenpoint
end

/*---------------------------------------------------------
   Name: gamemode:WeaponEquip( weapon )
   Desc: Player just picked up (or was given) weapon
---------------------------------------------------------*/
function GM:WeaponEquip( weapon )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeathSound()
   Desc: Return true to not play the default sounds
---------------------------------------------------------*/
function GM:PlayerDeathSound()
	return false
end

/*---------------------------------------------------------
   Name: gamemode:SetupPlayerVisibility()
   Desc: Add extra positions to the player's PVS
---------------------------------------------------------*/
function GM:SetupPlayerVisibility()
	
	//AddOriginToPVS( vector_position_here )
	
end

/*---------------------------------------------------------
   Name: gamemode:CanPlayerSuicide( ply )
   Desc: Player typed KILL in the console. Can they kill themselves?
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )
	
	return ALLOW_SUICIDE and (!(ply:Team() == TEAM_HUMAN and team.NumPlayers(TEAM_HUMAN) == 1) or ply:IsAdmin())
	
end

/*---------------------------------------------------------
   Name: gamemode:CreateEntityRagdoll( entity, ragdoll )
   Desc: A ragdoll of an entity has been created
---------------------------------------------------------*/
function GM:CreateEntityRagdoll( entity, ragdoll )
end


/*---------------------------------------------------------
--  Name: gamemode:PlayerNoClip( player, bool )
--  Desc: Player pressed the noclip key, return true if
--		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	
	--// Allow noclip if we're in single player or player is admin
	if ( SinglePlayer() or (pl:IsAdmin() and ALLOW_ADMIN_NOCLIP) ) then 
		return true
	end
	
	--// Don't if it's not.
	return false
	
end

function GM:SendCoins(pl, amount)
	if not pl.DataTable then return end
	umsg.Start("SendMoney",pl)
		umsg.Long(pl.DataTable["money"])
	umsg.End()	
	
	// coin effect
	if amount then
		umsg.Start("CoinEffect",pl)
			umsg.Short(amount)
		umsg.End()
	end
end


