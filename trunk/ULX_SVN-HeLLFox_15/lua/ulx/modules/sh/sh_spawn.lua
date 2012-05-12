-- ULX spawn for ULX SVN/ULib SVN by HeLLFox_15
function ulx.spawn( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
			
		if v:Alive() then v:KillSilent() else v:Spawn() end
		v:Spawn()

	end

	ulx.fancyLogAdmin( calling_ply, "#A respawned #T", target_plys )
end
local spawn = ulx.command( CATEGORY_NAME, "ulx spawn", ulx.spawn, "!spawn" )
spawn:addParam{ type=ULib.cmds.PlayersArg }
spawn:defaultAccess( ULib.ACCESS_ADMIN )
spawn:help( "respawn a target(s)." )