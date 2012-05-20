-- Realistic Water --
local eff = 0
local effc = 1024

timer.Create( "WaterAir", 5.5, 0, function()
    for k, ply in pairs(player.GetAll()) do
        if ( ply:IsValid() and ply:WaterLevel() >= 3 ) then
            if ( ply:Health() >= 2 ) then
                ply:SetHealth(ply:Health() - math.random(10,20))
            else
                if ( ply:IsValid() and ply:Alive() ) then ply:Kill() end
            end
            
            ply:ViewPunch( Angle( -5, 0, 0 ) )
            
            local eff = eff + 1
            local effc = effc - 1
            ply:ConCommand("pp_toytown 1")
            if ( eff <= 10 ) then ply:ConCommand("pp_toytown_passes "..eff) end
            ply:ConCommand("pp_toytown_size 0.4")
            ply:ConCommand("pp_dof 1")
            ply:ConCommand("pp_dof_initlength "..effc)
            ply:ConCommand("pp_dof_spacing "..effc)
        else
            local eff = 0
            local effc = 1024
            ply:ConCommand("pp_toytown 0")
            if ( eff <= 10 ) then ply:ConCommand("pp_toytown_passes "..eff) end
            ply:ConCommand("pp_toytown_size 0.4")
            ply:ConCommand("pp_dof 0")
            ply:ConCommand("pp_dof_initlength "..effc)
            ply:ConCommand("pp_dof_spacing "..effc)
        end
    end
end)

timer.Create( "WaterExtinguish", 0.5, 0, function() 
    for _, ent in ipairs( ents.GetAll() ) do
        if ( ent:IsValid() and ent:IsOnFire() and ent:WaterLevel() > 0 ) then
            ent:Extinguish()
        end
    end
end)