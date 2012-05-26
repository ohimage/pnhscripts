-- RP Class Control --

timer.Create( "PetHealth", 1.5, 0, function()
    for _, ply in pairs( player.GetAll() ) do
        if ( ( ply:Team() == TEAM_PET or ply:Team() == TEAM_CPPET ) and ply:Health() < 150 ) then
            ply:SetHealth(ply:Health() + 1)
        end
    end
end)

function classControl() 

    defaultTools = { "keys", "weapon_physcannon", "gmod_camera", "gmod_tool", "pocket", "weapon_physgun"  }

    for k, ply in pairs(player.GetAll()) do
        if ( ply:IsSuperAdmin() == false ) then
            if ( ply:Team() == TEAM_PET or ply:Team() == TEAM_CPPET ) then
                if ( ply:GetActiveWeapon():GetClass() != "weapon_pounce" and ply:GetActiveWeapon():GetClass() != "weapon_bite" ) then
                    if ( table.HasValue( defaultTools, ply:GetActiveWeapon():GetClass() ) ) then ply:GetActiveWeapon():Remove() else ply:DropWeapon( ply:GetActiveWeapon():GetClass() ) end
                end
            end     
        end
    
        if ( ply:Team() == TEAM_CPPET ) then
            ply:SetMaterial("models/combine_soldier/combinesoldiersheet")
        else
            ply:SetMaterial("")
        end
    end
    
end

hook.Add( "Think", "PlayerClassControl", classControl )