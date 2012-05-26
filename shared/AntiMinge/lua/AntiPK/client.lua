if(SERVER)then
	print([[
	ERROR: ANTI PK SERVER RUNNING ON CLIENT.
	I have no clue why this file ended up running clientside
	but the owner of the server is probably a dumass with no
	clue what hes doing... and should give up on his dreams
	of learning to program.]])
	return
end
print([[
########################################
# Loaded TheLastPenguin's AntiPropkill #
# This server is protected by Penguin's#
# AntiPropKill version 0.0.1           #
# Type AntiMinge_Info in console for more #
# information.                         #
########################################
]])

usermessage.Hook("PK_Tried",function( data )
	local attacker = data:ReadEntity()
	local victim = data:ReadEntity()
	if(ValidEntity( attacker ) and ValidEntity( victim ))then
		chat.AddText( attacker,Color(0,255,255),
			" (",attacker:SteamID(),")",
			" tried to prop kill ", victim,
			". please report his SteamID to an admin if none are on.")
	end
end)

concommand.Add("AntiMinge_Info",function( ply, cmd, args)
	print([["
This server is protected by TheLastPenguin's
AntiMinge mod version 0.0.1.
Base code by TheLastPenguin.
AntiPropSerf addition by ULX hellfox.]])
end