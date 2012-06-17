-- ULX Cleanup By HeLLFox for ULX SVN/ULib.
function ulx.clnup( calling_ply, string_arg )
		calling_ply:ConCommand("hf_clnstr "..string_arg)

--  ulx.fancyLogAdmin( calling_ply, "#A cleaned up ".. string_arg, command, target_plys )
	
	return true
end
local clnup= ulx.command( "Utility", "ulx clnup", ulx.clnup, "!clnup" )
clnup:addParam{ type=ULib.cmds.StringArg, default="*", hint="Input a model string or an entity class.", error="Invalid input \"%s\" specified" }
clnup:defaultAccess( ULib.ACCESS_ADMIN )
clnup:help( "Cleans up the map." )

function ulx.clnup2( calling_ply )
	
	local aimTrace = calling_ply:GetEyeTrace()
	local aimEnt = aimTrace.Entity
	
	if (!aimEnt or !aimEnt:IsValid()) then return end
	
	local aimString = aimEnt:GetModel()

	calling_ply:ConCommand("hf_clnstr "..aimString)

end
local clnup2= ulx.command( "Utility", "ulx clnup2", ulx.clnup2, "!clnup2" )
clnup2:defaultAccess( ULib.ACCESS_ADMIN )
clnup2:help( "Get the entity your looking at and clean every thing that has the same model." )