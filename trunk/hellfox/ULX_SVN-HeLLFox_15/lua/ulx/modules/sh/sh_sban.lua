-- ULX sban for ULX SVN/ULib SVN by HeLLFox_15
function ulx.sban( calling_ply, target_plys, time, reason )
	
	if target_ply:IsBot() then
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		return
	end
	
	local minutes = ULib.stringTimeToSeconds( time )
	if not minutes then
		ULib.tsayError( calling_ply, "Invalid time format." )
		return
	end
	
	ULib.kickban( target_plys, time, reason, calling_ply )
	sourcebans.BanPlayer( target_plys, time, reason, calling_ply )
	
	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A source banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local sban = ulx.command( "Utility", "ulx sban", ulx.sban, "!sban" )
sban:addParam{ type=ULib.cmds.PlayerArg }
sban:addParam{ type=ULib.cmds.StringArg, hint="minutes, 0 for perma. 'h' for hours, 'd' for days, 'w' for weeks. EG, '2w5d' for 2 weeks 5 days", ULib.cmds.optional }
sban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
sban:defaultAccess( ULib.ACCESS_SUPERADMIN )
sban:help( "Bans a target and adds them to the source bans list." )