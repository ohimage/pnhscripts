function ulx.ups( calling_ply )
	calling_ply:ConCommand("ups_menu")
end
local ups= ulx.command( "Utility", "ulx ups", ulx.ups, "!ups" )
ups:defaultAccess( ULib.ACCESS_ADMIN )
ups:help( "Open the UPS Menu." )