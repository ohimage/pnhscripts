/*------------
Infected Wars
shared.lua
Serverside
------------*/

TEAM_UNDEAD = 3
TEAM_HUMAN = 4

include( 'obj_player_extend.lua' )
include( 'options_shared.lua' )

-- Don't change any of these GM.* variables
GM.Name 	= "Infected Wars "..GM.Version
GM.Author 	= "ClavusElite" 
GM.Email 	= "joerivdvelden@gmail.com"
GM.Website 	= "www.clavusstudios.com"

COLOR_UNDEAD = Color(200,40,40,255)
COLOR_HUMAN = Color(0,90,200,255)

team.SetUp(TEAM_UNDEAD, "Undead Legion", COLOR_UNDEAD)
team.SetUp(TEAM_HUMAN, "Special Forces", COLOR_HUMAN)

for k=1,#HumanClass do
	util.PrecacheModel(HumanClass[k].Model)
end
for k=1,#UndeadClass do
	util.PrecacheModel(UndeadClass[k].Model)
end

util.PrecacheSound("npc/strider/fire.wav")
util.PrecacheSound("weapons/physcannon/superphys_launch2.wav")
for k=1, 4 do
	util.PrecacheSound("physics/body/body_medium_impact_soft"..k..".wav")
end

HumanGibs = {"models/gibs/antlion_gib_medium_2.mdl", 
"models/gibs/Antlion_gib_Large_1.mdl", 
"models/gibs/Strider_Gib4.mdl",
"models/gibs/HGIBS.mdl",
"models/gibs/HGIBS_rib.mdl",
"models/gibs/HGIBS_scapula.mdl",
"models/gibs/HGIBS_spine.mdl" }

for k, v in pairs( HumanGibs ) do
	util.PrecacheModel( v )
end

for k, v in pairs( suitsData ) do
	for j, prop in pairs(v.suit) do
		util.PrecacheModel( prop.model )
	end
end

TurretStatus = { inactive = 1, active = 2, destroyed = 3 }

/*---------------------------------------------------------
   Name: gamemode:PropBreak( )
   Desc: Prop has been broken
---------------------------------------------------------*/
function GM:PropBreak( attacker, prop )
end


/*---------------------------------------------------------
   Name: gamemode:PhysgunPickup( )
   Desc: Return true if player can pickup entity
---------------------------------------------------------*/
function GM:PhysgunPickup( ply, ent )

	// Don't pick up players
	--what if we do?
	--if ( ent:GetClass() == "player" ) then return false end

	return true
end


/*---------------------------------------------------------
   Name: gamemode:GravGunPunt( )
   Desc: We're about to punt an entity (primary fire).
		 Return true if we're allowed to.
---------------------------------------------------------*/
function GM:GravGunPunt( ply, ent )
	return true	
end

/* Checks if it's a valid title */
local validchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789><:;[]/()!?.,@#$%^&*-_=+ "
local forbiddenwords = { "admin", "moderator", "host", "server" }
function ValidTitle( pl, str )
	// 24 character limit
	if not str then return false end
	if (string.len(str) > 24) then return false end
	
	for i = 1, string.len( str ) do
		local char = string.sub( str, i, i )
		if not string.find(validchars,char) then
			return false
		end
	end 

	if not ((CLIENT and PlayerIsAdmin) or (SERVER and pl:IsAdmin())) then
		for k, word in pairs(forbiddenwords) do
			if string.find(string.lower(str),word) then return false end
		end
	end
	
	return true
end

/* Thank you Garry for this great function in GMod update 65 */
function GM:ShouldCollide( ent1, ent2 )
	
	if ent1:IsPlayer() and ent2:IsPlayer() and SOFT_COLLISIONS then
		local collide = ent1:Team() != ent2:Team()
		if SERVER and !collide then
			local pl, other_pl = ent1, ent2
			if not pl.LastMove then pl.LastMove = 0 end
			if not other_pl.LastMove then other_pl.LastMove = 0 end
			
			if pl:GetVelocity():Length() > 1 then
				pl.LastMove = CurTime()
			end
			if other_pl:GetVelocity():Length() > 1 then
				other_pl.LastMove = CurTime()
			end
			
			local dis = pl:GetPos():Distance(other_pl:GetPos())
			if dis < 20 then
				local pushVec
				local force = 70 - (70*0.3) * dis/20
				if pl.LastMove < other_pl.LastMove then

					pushVec = other_pl:GetPos()-pl:GetPos()
					pushVec.z = 0
					pushVec = pushVec:GetNormal() * force
					
					other_pl:SetVelocity(pushVec)
					
				elseif pl.LastMove > other_pl.LastMove then

					pushVec = pl:GetPos()-other_pl:GetPos()
					pushVec.z = 0
					pushVec = pushVec:GetNormal() * force
					
					pl:SetVelocity(pushVec)
					
				else
					
					pushVec = other_pl:GetPos()-pl:GetPos()
					if pushVec == Vector(0,0,0) then
						pushVec = Vector(1,0,0)
					end
					pushVec.z = 0
					pushVec = pushVec:GetNormal() * force
				
					other_pl:SetVelocity(pushVec)
					pl:SetVelocity(pushVec*(-1))
					
				end
			end
		end
		return collide
	end
	
	return true	
	
end

if (SERVER) then


	/*---------------------------------------------------------
	   Name: gamemode:GravGunPickupAllowed( )
	   Desc: Return true if we're allowed to pickup entity
	---------------------------------------------------------*/
	function GM:GravGunPickupAllowed( ply, ent )
		return true	
	end

	
	/*---------------------------------------------------------
	   Name: gamemode:GravGunOnPickedUp( )
	   Desc: The entity has been picked up
	---------------------------------------------------------*/
	function GM:GravGunOnPickedUp( ply, ent )
	end

	
	/*---------------------------------------------------------
	   Name: gamemode:GravGunOnDropped( )
	   Desc: The entity has been dropped
	---------------------------------------------------------*/
	function GM:GravGunOnDropped( ply, ent )
	end
	
end

