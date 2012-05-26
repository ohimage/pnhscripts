/*-------------------------------------------------------------------------------------------------------------------------
	Freeze every prop/player on the server!
	Made By HeLLFox_15
-------------------------------------------------------------------------------------------------------------------------*/

function ulx.nolag( calling_ply )
	local Ent = ents.FindByClass("prop_physics")
		for _,Ent in pairs(Ent) do
			if Ent:IsValid() then
				local phys = Ent:GetPhysicsObject()
				phys:EnableMotion(false)
			end
		end
	ulx.fancyLogAdmin( calling_ply, "#A froze all of the props." )
end

local nolag = ulx.command( "Utility", "ulx nolag", ulx.nolag, "!nolag" )
nolag:defaultAccess( ULib.ACCESS_ADMIN )
nolag:help( "Freeze every prop on the server." )