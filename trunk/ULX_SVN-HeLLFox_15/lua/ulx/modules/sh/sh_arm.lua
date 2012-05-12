-- ULX arm for ULX SVN/ULib SVN by HeLLFox_15
function ulx.arm( calling_ply, target_plys, command )
	for _, v in ipairs( target_plys ) do
		if( v:IsAdmin() or v:IsSuperAdmin() ) then
			GAMEMODE:PlayerLoadout( v )
			v:Give("weapon_crowbar");
			v:Give("weapon_stunstick");
			v:Give("weapon_physcannon");
			v:Give("weapon_physgun");
			v:Give("weapon_pistol");
			v:Give("weapon_357");
			v:Give("weapon_smg1");
			v:Give("weapon_ar2");
			v:Give("weapon_shotgun");
			v:Give("weapon_crossbow");
			v:Give("weapon_frag");
			v:Give("weapon_rpg");
			v:Give("weapon_slam");
			v:Give("weapon_bugbait");
			v:Give("gmod_camera");
			v:Give("gmod_tool");
			v:GiveAmmo(100,"SMG1_Grenade");
			v:GiveAmmo(100,"AR2AltFire");
			v:GiveAmmo(50,"RPG_Round");
			v:GiveAmmo(50,"Grenade")
			v:GiveAmmo(50,"slam");
		else
			GAMEMODE:PlayerLoadout( v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A armed #T", target_plys )
end
local arm = ulx.command( "Utility", "ulx arm", ulx.arm, "!arm" )
arm:addParam{ type=ULib.cmds.PlayersArg, default="^", ULib.cmds.optional }
arm:defaultAccess( ULib.ACCESS_SUPERADMIN )
arm:help( "arm a target(s)." )