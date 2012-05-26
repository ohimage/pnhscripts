local directions = {"up", "down", "left", "right", "forward", "back", "u", "d", "l", "r", "f", "b"}

function ulx.rocket( calling_ply, target_plys, string_arg )
	
	for _, v in ipairs( target_plys ) do
		if not v:Alive() then
			ULib.tsay( calling_ply, v:Nick() .. " is dead!", true )
			return
		end
		if v.jail then
			ULib.tsay( calling_ply, v:Nick() .. " is in jail", true )
			return
		end
		if v.ragdoll then
			ULib.tsay( calling_ply, v:Nick() .. " is a ragdoll", true )
			return
		end	

		if v:InVehicle() then
			local vehicle = v:GetParent()
			v:ExitVehicle()
		end
		v:SetMoveType(MOVETYPE_WALK)
		tcolor = team.GetColor( v:Team()  )
		local trail = util.SpriteTrail(v, 0, Color(tcolor.r,tcolor.g,tcolor.b), false, 60, 20, 4, 1/(60+20)*0.5, "trails/smoke.vmt")  				
		
		if( string_arg == "up" or string_arg == "u" ) then
			v:SetVelocity(Vector(0, 0, 2048))
		elseif ( string_arg == "down" or string_arg == "d" ) then
			v:SetVelocity(Vector(0, 0, -2048))
		elseif ( string_arg == "left" or string_arg == "l" ) then
			v:SetVelocity(v:GetLeft() * 2048)
		elseif ( string_arg == "right" or string_arg == "r" ) then
			v:SetVelocity(v:GetRight() * 2048)
		elseif ( string_arg == "forward" or string_arg == "f" ) then
			v:SetVelocity(v:GetForward() * 2048)
		elseif ( string_arg == "back" or string_arg == "b" ) then
			v:SetVelocity(v:GetForward() * -2048)
		end
			
		
		timer.Simple(2.5, function()
			local Position = v:GetPos()		
			local Effect = EffectData()
			Effect:SetOrigin(Position)
			Effect:SetStart(Position)
			Effect:SetMagnitude(512)
			Effect:SetScale(128)
			util.Effect("Explosion", Effect)
			timer.Simple(0.1, function()
				v:KillSilent()
				trail:Remove()
			end)
		end)
	end
	ulx.fancyLogAdmin( calling_ply, "#A turned #T into a rocket!", target_plys )
end

local rocket = ulx.command( "Fun", "ulx rocket", ulx.rocket, "!rocket" )
rocket:addParam{ type=ULib.cmds.PlayersArg }
rocket:addParam{ type=ULib.cmds.StringArg, completes=directions, default="up", hint="direction", error="invalid direction \"%s\" specified", ULib.cmds.restrictToCompletes }
rocket:defaultAccess( ULib.ACCESS_ADMIN )
rocket:help( "Rocket players into the air" )

