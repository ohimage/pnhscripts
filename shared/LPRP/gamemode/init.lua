DeriveGamemode( "sandbox" );
require( "datastream" );
LPRP = {}
include( "shared.lua" )

local plymeta = FindMetaTable( "Player" )

function GM:Initialize()
	self.BaseClass:Initialize();
	MsgN("Initalizing LPRP")
end

function LPRP:Notify( ply , ... )
	local message = arg
	local targs = nil
	if( ply != nil and type( ply ) == "Player")then
		targs = ply
	else
		table.insert( message, 1, ply)
		targs = player.GetAll()
	end
	datastream.StreamToClients( targs, "LPRP_Notify", message );
end

// Add CSLuaFiles
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "hud_cl.lua" );
AddCSLuaFile( "classes_cl.lua" );
AddCSLuaFile( "classes_sh.lua" );
AddCSLuaFile( "player_cl.lua" );
AddCSLuaFile( "plugins/loader.lua" );
AddCSLuaFile( "chat_cl.lua");
// Includes:
include( "VGUI/include_sv.lua" );
include( "data_sv.lua" );
include( "player_sv.lua" ); -- money systems ect.
include( "plugins/loader.lua" );
include( "classes_sh.lua" );
include( "classes_sv.lua" );
include( "chat_sv.lua" )

// gammemode functions should come after this line.
function GM:Initialize( )
	hook.Call("LPRP_RegisterPlayerProperties",GM )
end

function GM:PlayerInitialSpawn( ply )
    // This is truely quite ugly and could use some improvements later.
	MsgN("Welcome "..ply:Nick().." to the server.")
	LPRP:Notify(ply, Color(0,255,255),"Welcome to ",Color(0,0,255),GetHostName(),Color(0,255,255)," we are running LPRP. Enjoy your stay")
	LPRP:SettupSQLUserData( ply )
	hook.Call("LPRP_GarbageCollect",GM)
	LPRP.DATA.LoadMoney( ply )
	ply:LPRP().money = ply:GetMoney()
	ply:LPRP().entity = ply
	LPRP:LoadPlayerProperties( ply )
end

local function saveWeapons( ply )
	local weps = ply:GetWeapons()
	for k,v in pairs(weps)do
		weps[ k ] = v:GetClass()
	end
	LPRP:SetPlayerProperty( ply, "weapons", weps )
	LPRP:SetPlayerProperty( ply, "activeWeapon", ply:GetActiveWeapon():GetClass() )
end

LPRP:RegisterPlayerProperty( "weapons", {} )
function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	
	local weps = LPRP:GetPlayerProperty( ply, "weapons" )
	if( weps != nil)then
		for k,v in pairs(weps)do
			ply:Give( v )
		end
	end
end

function GM:PlayerDeath( ply )
	LPRP:SetPlayerProperty( "weapons", {} )
end

function GM:EntityTakeDamage(  ent,  inflictor,  attacker,  amount,  dmginfo )
	if( attacker != nil and ent != nil and inflictor != nil and dmginfo != nil)then
		if( ent:IsNPC() or ent:IsPlayer())then
			if( attacker:IsPlayer() )then
				print("Player "..attacker:Nick().." attacked something.")
				umsg.Start("LPRP_ShowHitPoint", attacker)
					umsg.Vector( dmginfo:GetDamagePosition( ) )
					umsg.Short( amount )
				umsg.End()
			end
		end
	end
end

function GM:PlayerDisconnected( ply )
	hook.Call("LPRP_CleanupUserTables",GM, ply )
end

function GM:GravGunPunt(  ply,  ent )
	return ply:IsAdmin()
end

function GM:PlayerCanPickupWeapon( ply,  wep )
	timer.Simple( 1, saveWeapons, ply )
	return true
end

function GM:PlayerGiveSWEP(  ply,  class,  weapon )
	timer.Simple( 1, saveWeapons, ply )
	return ply:IsSuperAdmin()
end