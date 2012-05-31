MsgN([[
=======================
= LOADED PANTICHEET   =
= Server is Protected =
=======================
]])
PAntiCheet = {}
if(SERVER)then
	// ClientSide Files
	AddCSLuaFile("autorun/panticheet_init.lua")
	AddCSLuaFile("PAntiCheet/init_cl.lua")
	// Include server side scripts
	include("PAntiCheet/init_sv.lua")
elseif(CLIENT)then
	// include the client side scripts
	include("PAntiCheet/init_cl.lua")
end