require("forceconvar")
require("console")

concommand.Add("convar_force", function(a, b, args)
	if (#args >= 2) then
		console.Print(Color(0,255,255),"LPScript: Forcing convar "..args[1].." to value "..args[2])
		ForceConVar(CreateConVar(args[1], ""), args[2])
	else
		console.Print(Color(255,0,0),"LPScript: Forcing convar "..args[1].." to value "..args[2])
	end
end )
