/*-------------------------------------------------------------------------------------------------------------------------
	Fuck a player with a train
-------------------------------------------------------------------------------------------------------------------------*/

function SpawnTrain( Pos, Direction )
	local train = ents.Create( "prop_physics" )
	train:SetModel("models/props_vehicles/train_boxcar.mdl")
	train:SetAngles( Direction:Angle() )
	train:SetPos( Pos )
	train:Spawn()
	train:Activate()
	train:EmitSound( "ambient/alarms/train_horn2.wav", 100, 100 )
	train:GetPhysicsObject():SetVelocity( Direction * 100000 )
	
	timer.Create( "TrainRemove_"..CurTime(), 5, 1, function( train ) train:Remove() end, train )
end

function ulx.trainfuck( calling_ply, target_plys )
	for _, pl in ipairs( target_plys, calling_ply ) do
		
		local Hp = pl:Health()
		local Dif = Hp - 20
		local HpOut = Hp - Dif
		local HpSur = Hp + Dif
		
		pl:SetMoveType( MOVETYPE_WALK )
		pl:GodDisable()
		pl:SetHealth(HpOut)
		SpawnTrain( pl:GetPos() + pl:GetForward() * 1000 + Vector(0,0,50), pl:GetForward() * -1 )
		pl:GodDisable()
		pl:SetMoveType( MOVETYPE_WALK )
		
		timer.Create( "trainKillNot_", 6.5, 1, function( target_plys )
			if pl:Alive() then pl:SetHealth(HpSur) else end
		end )
		
	end

	ulx.fancyLogAdmin( calling_ply, "#A trainfucked #T", target_plys )
end

local trainfuck = ulx.command( "Fun", "ulx trainfuck", ulx.trainfuck, "!trainfuck" )
trainfuck:addParam{ type=ULib.cmds.PlayersArg }
trainfuck:defaultAccess( ULib.ACCESS_ADMIN )
trainfuck:help( "Fuck a player with a train." )
