-- ULX Clear Decals for ULX SVN/ULib SVN by .:RynO-SauruS:.
function ulx.dcals( calling_ply )
	for k, v in pairs(player.GetAll()) do 
		v:ConCommand("r_cleardecals")
	end

	ulx.fancyLogAdmin( calling_ply, "#A cleared all decals", command, target_plys )
	
	return true
end
local dcals= ulx.command( "Utility", "ulx dcals", ulx.dcals, "!dcals" )
dcals:defaultAccess( ULib.ACCESS_ADMIN )
dcals:help( "Clears all decals." )