GM.Name 	= "LPRP"
GM.Author 	= "TheLastPenguin"
GM.Email 	= "thelastpenguin@comcast.net"
GM.Website 	= "lastpenguin.com"

include( "plugins/loader.lua" )
// Core stuff:
local Users = {}
function LPRP:GetUser( arg )
	if(type( arg ) == "Player")then
		arg = arg:LPRP_ID()
	end
	if( Users[arg] == nil)then
		Users[arg] = {}
	end
	return Users[arg]
end

hook.Add("LPRP_CleanupUserTables","RemoveDataTable",function( ply )
	table.remove( Users, ply:LPRP_ID() )
end)

local plymeta = FindMetaTable( "Player" )
function plymeta:LPRP()
	return LPRP:GetUser( self:LPRP_ID() )
end

hook.Add("LPRP_GarbageCollect","SH_GarbageCollect",function()
	for k,v in pairs(Users)do
		if not ValidEntity( v.entity ) then
			print("Cleaned old user data for player "..k)
			table.remove( Users, k )
		end
	end
end)