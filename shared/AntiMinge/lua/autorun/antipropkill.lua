PAntiPropKill = {}
print([[
########################################
# Loaded TheLastPenguin's AntiPropkill #
# This server is protected by Penguin's#
# AntiPropKill version 0.0.1           #
# Type AntiPK_Info in console for more #
# information.                         #
########################################
]])
local pk = PAntiPropKill

if(SERVER)then
	AddCSLuaFile("AntiPK/client.lua")
	AddCSLuaFile("autorun/antipropkill.lua")
	include("AntiPK/server.lua")
elseif(CLIENT)then
	include("AntiPK/client.lua")
end