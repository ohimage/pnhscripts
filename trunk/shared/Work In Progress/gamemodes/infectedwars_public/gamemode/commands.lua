/*------------
Infected Wars
commands.lua
Serverside
------------*/

function SendMapList(pl,commandName,args)

	local daList = file.Find( "/../maps/*.bsp" )
	
	local x = 1
	for k, v in pairs(daList) do	
		umsg.Start("RcMapList", pl)
			umsg.Short(x)
			umsg.String(v)
		umsg.End()
		x = x+1
	end
	
end
concommand.Add("get_maplist",SendMapList) 

function VoteMapChoice(pl,commandName,args)

	if pl.Voted then return end
	pl.Voted = true
	if(tonumber(args[1]) == 3) then
		MapVotes.secondNextMap = MapVotes.secondNextMap+1
	elseif (tonumber(args[1]) == 2) then
		MapVotes.nextMap = MapVotes.nextMap+1
	else
		MapVotes.curMap = MapVotes.curMap+1
	end
	
	umsg.Start("SynchronizeVotes")
		umsg.Short(MapVotes.curMap)
		umsg.Short(MapVotes.nextMap)
		umsg.Short(MapVotes.secondNextMap)
	umsg.End()
	
end
concommand.Add("vote_map_choice",VoteMapChoice) 

function SendScoreData(pl,commandName,args)

	if not args[1] then return end

	local function findID( id ) -- player.GetByID requires entity indexes... I have user IDs.
		for k, v in pairs(player.GetAll()) do
			if id == v:UserID() then 
				return v
			end
		end
	end
	
	local from = findID(tonumber(args[1]))
	if from and from:IsValid() then
		SendPlayerData( from, pl )
	end
	
end
concommand.Add("get_playerstats",SendScoreData) 

function BuyItem(pl,commandName,args)
	if not pl:IsValid() then return end
		
	local item = args[1]
	if not shopData[item] then return end
	
	local gc = pl:Money()
	
	-- voornamelijk protectie tegen mensen die direct via console items pogen aan te schaffen
	if gc < shopData[item].Cost then
		pl:ChatPrint("You're too poor you lazy bastard.")
		return
	end
	if shopData[item].AdminOnly and not pl:IsAdmin() then
		pl:ChatPrint("Server-side validation bitch!")
		return
	end
	if pl.DataTable["shopitems"][item] then
		pl:ChatPrint("You already have this item!")
		SendShopData(pl) -- update just in case
		return
	end
	if (shopData[item].Requires and not pl:HasBought(shopData[item].Requires)) then
		pl:ChatPrint ("You need to buy "..shopData[shopData[item].Requires].Name.." before you can buy this item!")		
		return
	end
	
	// buy the thing
	pl:TakeMoney(shopData[item].Cost)
	pl.DataTable["shopitems"][item] = true

	SendShopData(pl)
	
	umsg.Start("CoinEffect",pl)
		umsg.Short(-shopData[item].Cost)
	umsg.End()
	
end
concommand.Add("iw_buyitem",BuyItem) 

-- Set title
function SetPlayerTitle(pl,commandName,args)
	local title = args[1]
	
	if not pl:HasBought("titleeditor") then
		pl:ChatPrint("You do not have the title editor!")
		return
	end
	
	if not ValidTitle(pl, title) then
		pl:ChatPrint("Invalid title!")
		return
	end
	
	if pl.LastTChange and pl.LastTChange > CurTime()-5 then
		pl:ChatPrint("Please wait 5 seconds before setting a new title")
		return
	end
	
	pl.LastTChange = CurTime()
	
	pl:SetTitle( title )
end
concommand.Add("iw_settitle",SetPlayerTitle)

function PrintMapCycle(pl,commandName,args)

	for k, v in pairs(MAPCYCLE) do
		pl:PrintMessage(HUD_PRINTCONSOLE,k..": "..v.map)
	end
	pl:PrintMessage(HUD_PRINTTALK,"The mapcycle has been printed in console")
	
end
concommand.Add("print_mapcycle",PrintMapCycle) 

// for Death Pursuit shop item
function ForceBoost(pl,commandName,args)

	if not args[1] then return end
	local other = player.GetByID( tonumber(args[1]) )
	pl.nextjump = pl.nextjump or 0
	
	if (ValidEntity(other) and other:IsPlayer() and pl:Alive() and not pl:IsOnGround() and pl:Team() == TEAM_UNDEAD and pl:GetPlayerClass() == 4 
		 and pl:HasBought("deathpursuit") and pl.nextjump < CurTime()) then
		
		local force = 1000
		local vec = (other:GetPos()-pl:GetPos()):GetNormal()
		
		pl:EmitSound("physics/body/body_medium_impact_soft"..math.random(1,3)..".wav")
		pl:SetVelocity( vec * force )
		pl.nextjump = CurTime()+2
		
	end
	
end
concommand.Add("_iw_forceboost",ForceBoost)

-- Toggle shell effect
function ShellFX(pl,commandName,args)
	if not args[1] then return end
	pl.EFFECT_SHELL = util.tobool(args[1])
end
concommand.Add("_shellfx",ShellFX) 

-- Toggle additional muzzle flash effect serverside
function MuzzleFX(pl,commandName,args)

	if not args[1] then return end
	pl.EFFECT_MUZZLE = util.tobool(args[1])
	
end
concommand.Add("_muzzlefx",MuzzleFX) 

-- Ban player
function BanPlayer(pl,commandName,args)

	if !(pl:IsAdmin()) then return end
	
	for k=1, 3 do -- spam the command
		pl:ConCommand("banid2 "..tonumber(args[1]).." "..tonumber(args[2]).."\n") 
	end
	
end
concommand.Add("ban_player",BanPlayer) 

-- Kick player
function KickPlayer(pl,commandName,args)

	if !(pl:IsAdmin()) then return end
	if !(args[2]) then args[2] = "" end
	args[2] = string.Replace(args[2]," ","_")
	for k=1, 3 do -- spam the command
		pl:ConCommand("kickid2 "..tonumber(args[1]).." "..args[2].."\n")
	end
	
end
concommand.Add("kick_player",KickPlayer) 

-- Bring player
function BringPlayer(pl,commandName,args)

	if !(pl:IsAdmin()) then return end
	local target = GetPlayerByName(args[1])
	local des = pl
	
	if target == -1 or target == -2 then
		pl:PrintMessage(HUD_PRINTTALK, "Multiple or no players specified!")
		return
	end
	
	if !(des:Alive()) then
		pl:PrintMessage(HUD_PRINTTALK, "You're dead dumbass!")
		return
	end
	
	if !(target:Alive()) then
		pl:PrintMessage(HUD_PRINTTALK, "Specified player is not alive!")
		return
	end
	
	if (target == des) then
		pl:PrintMessage(HUD_PRINTTALK, "You can't bring yourself!")
		return			
	end
	
	local newpos = playerSend( target, des, target:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		pl:PrintMessage( HUD_PRINTTALK, "Can't find a place to put them!")
		return
	end

	local newang = (des:GetPos() - newpos):Angle()

	target:SetPos( newpos )
	if ValidEntity(target.Turret) then
		target.Turret:SetPos(newpos+Vector(0,30,30))
	end
	target:SetEyeAngles( newang )
	target:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!
	
	target:PrintMessage( HUD_PRINTTALK, "You were brought to (ADMIN) "..pl:Name())
	des:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." teleported to you")
	
end
concommand.Add("bring_player",BringPlayer) 

-- Goto player
function GotoPlayer(pl,commandName,args)

	if !(pl:IsAdmin()) then return end
	local target = pl
	local des = GetPlayerByName(args[1])
	
	if des == -1 or des == -2 then
		pl:PrintMessage(HUD_PRINTTALK, "Multiple or no players specified!")
		return
	end
	
	if !(des:Alive()) then
		pl:PrintMessage(HUD_PRINTTALK, "Specified player is not alive!")
		return
	end
	
	if !(target:Alive()) then
		pl:PrintMessage(HUD_PRINTTALK, "You're dead dumbass!")
		return
	end
	
	if (target == des) then
		pl:PrintMessage(HUD_PRINTTALK, "You can't goto yourself!")
		return			
	end
	
	local newpos = playerSend( target, des, target:GetMoveType() == MOVETYPE_NOCLIP )
	if not newpos then
		pl:PrintMessage( HUD_PRINTTALK, "Can't find a place to put you! Use noclip to force a goto.")
		return
	end

	local newang = (des:GetPos() - newpos):Angle()

	target:SetPos( newpos )
	if ValidEntity(target.Turret) then
		target.Turret:SetPos(newpos+Vector(0,30,30))
	end
	target:SetEyeAngles( newang )
	target:SetLocalVelocity( Vector( 0, 0, 0 ) ) -- Stop!
	
	target:PrintMessage( HUD_PRINTTALK, "Teleported to player "..target:Name())
	
end
concommand.Add("goto_player",GotoPlayer) 

-- Slay player
function SlayPlayer(pl,commandName,args)

	if !(pl:IsAdmin()) then return end

	local des = GetPlayerByName(args[1])
	
	if des == -1 or des == -2 then
		pl:PrintMessage(HUD_PRINTTALK, "Multiple or no players specified!")
		return
	end
	
	if not des:Alive() then
		pl:PrintMessage( HUD_PRINTTALK, "Target player is not alive!")
	end
	
	des:Kill()
	pl:PrintMessage( HUD_PRINTTALK, "Player "..des:Name().." was killed")
	des:PrintMessage( HUD_PRINTTALK, "Admin "..pl:Name().." killed you")	
	
end
concommand.Add("slay_player",SlayPlayer)

-- Change map
function ChangeMap(pl,commandName,args)

	if !(pl:IsAdmin()) then return end
	for k=1, 3 do
		game.ConsoleCommand("changelevel "..args[1].."\n")
	end
	
end
concommand.Add("change_map",ChangeMap) 

-- Whether the player wants to be Behemoth (probably to compensate for something)
function BehemothPreference(pl,commandName,args)

	if !(args[1]) then return end
	pl.PreferBehemoth = util.tobool(args[1])
	
end
concommand.Add("prefer_behemoth",BehemothPreference) 

function DecrementSuitPower(pl,commandName,args)
	if not ValidEntity(pl) then return end
	
	local amount = tonumber(args[1]) or 1
	if (amount < 0) then -- Prevent command abuse
		amount = 0 
	end
	pl:SetSuitPower(pl:SuitPower()-amount)
	
end
concommand.Add("decrement_suit",DecrementSuitPower) 

function DrownMe(pl,commandName,args)

	local amount = tonumber(args[1]) or 1
	if (amount < 0) then -- Prevent command abuse
		amount = 0 
	end
	pl:TakeDamage( amount, "water", "water" )
	
end
concommand.Add("drown_me",DrownMe) 

function PlayerPowerActivate(pl,commandName,args)

	if not (args[1]) then return end
	if (pl:Team() ~= TEAM_HUMAN) then return end
	
	local pow = tonumber(args[1]) or 0
	pl:SetPower(pow)
	
end
concommand.Add("set_power",PlayerPowerActivate) 

function ClassSpawn(ply,commandName,args)

	if !(args[1]) or ENDROUND then return end
	if (ply:Team() == TEAM_UNDEAD and tonumber(args[1]) == 1) then return end -- block manual spawning as Behemoth
	if (ply.StartTeam == TEAM_UNDEAD and ply.FirstSpawn and tonumber(args[1]) == 1) then return end
	
	ply.SpawnAsClass = tonumber(args[1])
	local load = tonumber(args[2]) or 1
	-- double check the loadout unlocks
	if (ply:ValidateLoadout(ply:Team(), ply.SpawnAsClass, load) ~= load) then
		load = 1
		ply:ChatPrint("Don't try to cheat >:O")
	end
	
	ply.NextLoadout = load
	ply:PrintMessage(HUD_PRINTTALK,"You will spawn as "..UndeadClass[ply.SpawnAsClass].Name.." with loadout "..ply.NextLoadout.."!")
	
end
concommand.Add("class_spawn",ClassSpawn)

function SetViewModelVis(player,commandName,args)

	if !(args[1]) then return end
	player:DrawViewModel(util.tobool(args[1]))
	
end
concommand.Add("r_viewmodel",SetViewModelVis) 

function SetTurretName(pl, command, args)
	if not args[1] then return end
	if string.len(tostring(args[1])) > 15 then 
		pl:ChatPrint("Maximum nickname length is 15 characters!")
		return 
	end
	if ValidEntity(pl.Turret) then
		pl.Turret:GetTable():SetNickName(tostring(args[1]))
	end
end
concommand.Add("turret_nickname",SetTurretName)

/*------------------------------------------
			Some extra functions
------------------------------------------*/

-- Returns player entity (returns -1 if not found, returns -2 if multiple found)
function GetPlayerByName( name )

	local found = nil
	local multiple = false
	local foundString = nil
	for k,v in pairs(player.GetAll()) do
		foundString = string.find(string.lower(v:GetName()), string.lower(name))
		if (foundString ~= nil and multiple == false) then
			if (found == nil) then
				found = v
			else
				multiple = true
			end
		end	
	end

	if (multiple == true) then return -2 end
	if (found == nil or not found:IsValid()) then return -1 end
	
	return found	
end

-- ulx player teleportation code
function playerSend( from, to, force )

	if not to:IsInWorld() and not force then return false end -- No way we can do this one

	local yawForward = to:EyeAngles().yaw
	local directions = { -- Directions to try
		math.NormalizeAngle( yawForward - 180 ), -- Behind first
		math.NormalizeAngle( yawForward + 90 ), -- Right
		math.NormalizeAngle( yawForward - 90 ), -- Left
		yawForward
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 ) -- Move them up a bit so they can travel across the ground
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47 -- (33 is player width, this is sqrt( 33^2 * 2 ))
	local tr = util.TraceEntity( t, from )
    while tr.Hit do -- While it's hitting something, check other angles
    	i = i + 1
    	if i > #directions then  -- No place found
			if force then
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
    end

	return tr.HitPos
	
end

/*-----------------------------------------
				CHATCOMMANDS
-----------------------------------------*/

local function CommandSay( pl, text, teamonly )

	if (text == "!kill" and pl:Alive() and not ENDROUND and ALLOW_SUICIDE) then
		if (pl:Team() == TEAM_HUMAN and team.NumPlayers(TEAM_HUMAN) == 1 and not pl:IsAdmin()) then
			pl:PrintMessage(HUD_PRINTTALK,"You can't suicide now, wait till there are more humans")
			return ""
		else
			pl:Kill()
		end
		return text
	end
	
	if (text:sub(1,4) == "/me " or text:sub(1,4) == "\me " ) then
		PrintMessageAll(HUD_PRINTTALK,pl:Name().." "..text:sub(5,string.len(text)))
		return ""
	end
	
	if (text == "!nextmap") then
		if ENDROUND then
			PrintMessageAll(HUD_PRINTTALK,"Player "..pl:Name().." needs glasses")
		else
			PrintMessageAll(HUD_PRINTTALK,"The next map is "..GetNextMap()..". This might change during the round based on the amount of players!")
		end
		return text
	end
	
	if (text == "!mapcycle" or text == "!maplist") then
		pl:ConCommand("print_mapcycle")
		return text
	end
	
	if (text:sub(1,5) == "!ppon" or text:sub(1,6) == "!ppoff") then
		pl:ConCommand("iw_menu_options")
	end
	
end
hook.Add("PlayerSay", "ChatCommands1", CommandSay)

local weaponList = {} 
for k, v in pairs(swepDesc) do
	table.insert(weaponList,k)
end

local function AdminSay( pl, text, teamonly )

	if not ADMIN_ADDON or not pl:IsAdmin() then 
		return text
	end

	local sep = string.Explode(" ",text)
	
	if (text:sub(1,3) == "@@@") then
		text = string.gsub(text,"@@@","")
		PrintMessageAll( HUD_PRINTCENTER, text )
		return ""
	elseif (text:sub(1,2) == "@@") then
		text = string.gsub(text,"@@","")
		PrintMessageAll( HUD_PRINTTALK, text )
		return ""
	elseif (text:sub(1,1) == "@") then
		text = string.gsub(text,"@","")
		PrintMessageAll( HUD_PRINTADMINCHAT, "(ADMINCHAT) "..pl:Name()..": "..text )
		return ""
	end
	
	if (text == "!printweapon") then
		pl:ChatPrint("Current weapon class: "..pl:GetActiveWeapon():GetClass())
		return text
	end
	
	if (text == "!printweapons") then
		pl:SendLua("PrintWeapons()")
		pl:PrintMessage(HUD_PRINTTALK, "Weaponlist printed in console")
		return text
	end
	
	if (text == "!sweplist") then   -- prints the list of available weapons
		pl:PrintMessage(HUD_PRINTCONSOLE, "\n\nList of weapons spawnable for the !swep command:\n")
		pl:PrintMessage(HUD_PRINTCONSOLE, "////////////////////////////////////////////////\n")
		for _, swep in pairs(weaponList) do		
			pl:PrintMessage(HUD_PRINTCONSOLE, swep.."\n")	 	 	
		end
		pl:PrintMessage(HUD_PRINTTALK, "List of weapons printed in console.")
		return ""	
	end
	
	if (pl:IsListenServerHost() and text == "!endround") then
		GAMEMODE:EndRound(TEAM_UNDEAD)
		return text
	end
		
	if (#sep > 1 and text:sub(1,1) == "!") then

		if(sep[1] == "!changemap" or sep[1] == "!changelevel") then
			pl:ConCommand("change_map "..sep[2])
			return ""		
		end
		
		/*------ Player targeted commands -------*/
		
		local target = GetPlayerByName(sep[2])
		if (target == -1) then
			pl:PrintMessage( HUD_PRINTTALK, "Target player was not found")
			return ""
		end
		if (target == -2) then
			pl:PrintMessage( HUD_PRINTTALK, "Multiple targets found, please refine your command")
			return ""
		end
		
		-- Kick command
		if(sep[1] == "!kick") then
			pl:ConCommand("kick_player "..target:UserID())
			pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." was kicked")
			return ""
		end

		if not target:Alive() or not target:IsValid() then
			pl:PrintMessage( HUD_PRINTTALK, "Target player is not alive!")
			return ""
		end
		
		if (sep[1] == "!ip") then
			pl:PrintMessage(HUD_PRINTTALK, "Player "..target:Nick().." IP adress is "..target:IPAddress())
			return ""
		end
		
		if(sep[1] == "!slay") then
			target:Kill()
			pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." was killed")
			target:PrintMessage( HUD_PRINTTALK, "Admin "..pl:Name().." killed you")
			return ""		
		end
		
		if(sep[1] == "!slap") then
			local slapdam = 10
			if sep[3] then
				slapdam = tonumber(sep[3])
			end
			target:TakeDamage(slapdam)
			target:EmitSound("ambient/voices/citizen_punches2.wav")
			target:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),math.random(0,10)):Normalize()*math.random(300,500))
			pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." was slapped with "..slapdam.." damage")
			target:PrintMessage( HUD_PRINTTALK, "Admin "..pl:Name().." slapped you with "..slapdam.." damage")
			return ""		
		end
		
		if (sep[1] == "!bring") then
			pl:ConCommand("bring_player "..sep[2])
			return ""
		end
			
		if (sep[1] == "!goto") then
			pl:ConCommand("goto_player "..sep[2])
			return ""
		end
		
		if (sep[1] == "!god") then
			if target.God then
				target.God = false
				target:GodDisable()
				pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." is now out of godmode")
				target:PrintMessage( HUD_PRINTTALK, "Admin "..pl:Name().." disabled godmode on you")
			else
				target.God = true
				target:GodEnable()
				pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." is now in godmode")
				target:PrintMessage( HUD_PRINTTALK, "Admin "..pl:Name().." enabled godmode on you")
			end
			
			return ""
		end	
		
		-- Give ammo command
		if (sep[1] == "!ammo+") then
			pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." was give 100 ammo for his current weapon")
			if (target ~= pl) then
				target:PrintMessage( HUD_PRINTTALK, "(ADMIN) "..pl:Name().." gave you 100 ammo for your current weapon")
			end
			local ammotype = target:GetActiveWeapon():GetPrimaryAmmoType()
			if ammotype == "none" then 
				ammotype = "pistol" 
			end
			target:GiveAmmo(100,ammotype)
			return ""
		end
		
		-- Give hp command
		if (sep[1] == "!hp+") then
			pl:PrintMessage( HUD_PRINTTALK, "Player "..target:Name().." restored 25 health")
			if (target ~= pl) then
				target:PrintMessage( HUD_PRINTTALK, "(ADMIN) "..pl:Name().." gave you 25 health")
			end
			target:SetHealth(math.min(target:Health()+25,target:GetMaximumHealth()))
			return ""
		end	
		
		if (sep[1] == "!swep") then -- gives the admin the ability to appoint a swep to a player     
			local weaponToGive = nil
			
			if sep[3] then
				for k, v in pairs(weaponList) do
					if (string.find(string.lower(v),string.lower(sep[3]))) then
						if weaponToGive ~= nil then 
							weaponToGive = nil
							break
						end
						weaponToGive = v
					end
				end
			end
			
			if (weaponToGive ~= nil) then
				target:Give(weaponToGive)
				target:SelectWeapon(weaponToGive)
				pl:ChatPrint(target:GetName().." was given "..weaponToGive)
				target:ChatPrint("You received "..weaponToGive.." from (ADMIN) "..pl:GetName())
			else
				pl:ChatPrint("No valid weapon or multiple weapons specified")
			end
			return ""
		end
		
	end
	
end
hook.Add("PlayerSay", "ChatCommands2", AdminSay)

local function FixSay( pl, text, teamonly )

	if (text == "!fix") then
		pl:PrintMessage( HUD_PRINTTALK, "Chatcommands rehooked.")
		hook.Add("PlayerSay", "ChatCommands1", CommandSay)
		hook.Add("PlayerSay", "ChatCommands2", AdminSay)
	end
	
end
hook.Add("PlayerSay", "ChatCommands3", FixSay)