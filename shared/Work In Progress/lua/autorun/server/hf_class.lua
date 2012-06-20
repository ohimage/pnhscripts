-- RP Class Control --

// This is mostly made to be used with the class below.

//[ TEAM_PET = AddExtraTeam("Pet", Color(72, 255, 0, 255), "models/renamon/renamon2009.mdl", [[ You are a pet, do pet things. ]], {"weapon_Pounce", "weapon_Bite"}, "pet", 5, 0, 0, false)
// models/combine_soldier/combinesoldiersheet
// TEAM_CPPET = AddExtraTeam("Police Pet", Color(0, 255, 180, 255), "models/renamon/renamon2009.mdl", [[ You work for the police, your helping! ]], {"weapon_Pounce", "weapon_Bite", "weaponchecker"}, "cppet", 6, 0, 0, false)

timer.Create( "PetProperties", 1.5, 0, function()
    for _, ply in pairs( player.GetAll() ) do
        if ( ( ply:Team() == TEAM_PET or ply:Team() == TEAM_CPPET ) and ply:Health() < 150 ) then
            ply:SetHealth(ply:Health() + 1)
        end
        if ( ply:Team() == TEAM_CPPET ) then
            ply:SetMaterial("models/combine_soldier/combinesoldiersheet")
        else
            ply:SetMaterial("")
        end
    end
end)

function petClassControl( ply ) 

    defaultTools = { "keys", "weapon_physgun", "gmod_camera", "gmod_tool", "pocket", "weapon_physcannon"  }

    if ( ply:IsValid() and ply:Alive() ) then
        if ( ply:Team() == TEAM_PET or ply:Team() == TEAM_CPPET ) then
            -- ply:StripWeapons()
            ply:Give("weapon_Pounce")
            ply:Give("weapon_Bite")
            print( "Class Set!" )
        end     
    end
    
end

-- hook.Add("OnPlayerChangedTeam", "petClassControlNoRespawn", petClassControl())

hook.Add("PlayerSpawn", "petClassControlRespawn", petClassControl())