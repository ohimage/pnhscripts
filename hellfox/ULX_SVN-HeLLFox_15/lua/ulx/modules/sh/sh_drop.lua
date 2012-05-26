-- ULX Drop for ULX SVN/ULib SVN by HeLLFox_15
function ulx.drop( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		v:DropNamedWeapon( command )
	end

	ulx.fancyLogAdmin( calling_ply, "#A droped #s from #T", command, target_plys )
end
local drop = ulx.command( "Utility", "ulx drop", ulx.drop, "!drop" )
drop:addParam{ type=ULib.cmds.PlayersArg }
drop:addParam{ type=ULib.cmds.StringArg, hint="command", ULib.cmds.takeRestOfLine }
drop:defaultAccess( ULib.ACCESS_SUPERADMIN )
drop:help( "Drop a target(s) weapon." )