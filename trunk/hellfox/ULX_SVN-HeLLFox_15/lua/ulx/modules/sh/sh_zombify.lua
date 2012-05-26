-- ULX Zombify for ULX SVN/ULib SVN by HeLLFox_15 with assistance from MrPresident, Megiddo, and JamminR
-- Organized by MrPresident
function Spawnzomb( pl, pos, ang, ztime )	
	R = { "npc_fastzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "npc_fastzombie_torso" }

	pl.zomb = ents.Create( R[math.random(1,5)] )
	pl.zomb:SetAngles( ang )
	pl.zomb:SetPos( pos )
	pl.zomb:Spawn()
	pl.zomb:Activate()
	pl.zomb:SetNPCState(3)
	pl:Spectate( OBS_MODE_DEATHCAM )
	pl:SpectateEntity( pl.zomb )
	if not ( pl.zomb ) then DespawnZomb( pl, pl.zomb, pos ) end
	if ( pl.zomb ) then
		timer.Create( "zombRemove_"..CurTime(), ztime, 1, DespawnZomb, pl, pl.zomb, pos )
	end

end

function DespawnZomb( pl, zomb, pos )
	
	if ( zomb and zomb:IsValid() ) then
		pl:UnSpectate()
		zomb:Remove()
	end  
	pl:Spawn()
	pl:SetPos( pos )
	
end

function ulx.zombify( calling_ply, target_ply, ztime )
	
for _,pl in pairs( target_ply ) do
	local pos = pl:GetPos()
	local ang = pl:GetAngles()
	local Effect = EffectData()
	Effect:SetOrigin(pos)
	Effect:SetStart(pos)
	Effect:SetMagnitude(512)
	Effect:SetScale(128)
	util.Effect("cball_explode", Effect)

	pl:EmitSound( "ambient/creatures/town_zombie_call1.wav", 100, 100 )	
	pl:StripWeapons()
	
	Spawnzomb( pl, pos, ang, ztime )
end
	ulx.fancyLogAdmin( calling_ply, "#A zombified #T for #s seconds", target_ply, ztime )
end
local zombify = ulx.command( "Fun", "ulx zombify", ulx.zombify, "!zombify" )
zombify:addParam{ type=ULib.cmds.PlayersArg }
zombify:addParam{ type=ULib.cmds.NumArg, hint="ztime", min=10, max=60, default=10, ULib.cmds.optional }
zombify:defaultAccess( ULib.ACCESS_SUPERADMIN )
zombify:help( "Turn a players into zombies." )