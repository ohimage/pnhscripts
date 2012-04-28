--[[
	Title: Server initialization
	
	Server-side initialization. In here we include all the necessary files and make sure the clients receive the proper files as well.
]]
if SERVER then
	module( "UPS", package.seeall )
	include( "ulx/modules/ups_menu_control.lua" )
	AddCSLuaFile( "upsmenu/ups_menu.lua" )
	AddCSLuaFile( "init.lua" )
else
	print("Ups Menu Initialized Clientside")
	include( "upsmenu/ups_menu.lua" )
end