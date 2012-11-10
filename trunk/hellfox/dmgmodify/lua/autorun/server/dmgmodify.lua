function sel( ply, cmd, args )
    local val = string.Explode( ",", string.Replace(args[1], " ", "") )
    if not ( type( tonumber(val[1]) ) == nil or type( tonumber(val[2]) ) == nil or type( tonumber(val[3]) ) == nil ) then
        local focus = tonumber(val[1]) or 0
        local act = tonumber(val[2]) or 0
        local mult = tonumber(val[3]) or 0
        if( focus >= 1) then focus = 1 end
        local tb = { focus, act, mult }
        return tb
    else
        if( ply and IsValid( ply ) ) then
            ply:ChatPrint("Error: One or more arguments are not a number!")
        else
            print("Error: One or more arguments are not a number!")
        end
    end
end

concommand.Add( "dmgmodify_set", sel( ply, cmd, args ), function() return autocompletesel = { "1,0,0", "1,2,0", "1,3,0", "1,4,0", "1,5,2", "1,6,0" }, 
[[Run dmgmodify_help for help with this command.]] )

concommand.Add( "dmgmodify_help", function( ply, cmd, args ) 
    if( ply and IsValid( ply ) ) then
        ply:ChatPrint([[dmgmodify_set has 3 variables that are entered like so #,#,#]]) 
        ply:ChatPrint([[The first variable is the overide variable if set to one it will apply the settings to every thing not just players.]])
        ply:ChatPrint([[The second variable selects the damage type. (0 or 1 (prop dmg), 2 (vehicle dmg), 3 (explosion dmg), 4 (bullet dmg), 5 (fall damage), and 6 (ALL dmg)).]])
        ply:ChatPrint([[The third variable is the damage multiplier set to 0 to turn off the given damage type.]])
    else
        print([[dmgmodify_set has 3 variables that are entered like so #,#,#]]) 
        print([[The first variable is the overide variable if set to one it will apply the settings to every thing not just players.]])
        print([[The second variable selects the damage type. (0 or 1 (prop dmg), 2 (vehicle dmg), 3 (explosion dmg), 4 (bullet dmg), 5 (fall damage), and 6 (ALL dmg)).]])
        print([[The third variable is the damage multiplier set to 0 to turn off the given damage type.]])
    end
end )

function dmgmodify( ent, inf, atk, amount, dmginfo )
    if( IsValid( ent ) ) then
        if( sel()[2] == 0 or sel()[2] == 1 ) then
            if( ( ent:GetClass() == "player" or sel()[1] ) and ( atk:GetClass() == "prop_physics" or dmginfo:GetDamageType() == DMG_CRUSH ) ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        elseif( sel()[2] == 2 ) then
            if( ( ent:GetClass() == "player" or sel()[1] ) and ( dmginfo:GetDamageType() == DMG_VEHICLE ) ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        elseif( sel()[2] == 3 ) then
            if( ( ent:GetClass() == "player" or sel()[1] ) and ( dmginfo:GetDamageType() == DMG_BLAST or dmginfo:GetDamageType() == DMG_BLAST_SURFACE) ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        elseif( sel[2] == 4 ) then
            if( ( ent:GetClass() == "player" or sel()[1] ) and dmginfo:GetDamageType() == DMG_BULLET ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        elseif( sel[2] == 5 ) then
            if( ( ent:GetClass() == "player" or sel()[1] ) and ( dmginfo:GetDamageType() == DMG_FALL or dmginfo:IsFallDamage() ) ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        else
            if( ( ent:GetClass() == "player" or sel()[1] ) ) then
                dmginfo:ScaleDamage( sel()[3] )
            end
        end
    end
end

function hooka()
    hook.Remove( "EntityTakeDamage", "dmgmodify" )
    hook.Add( "EntityTakeDamage", "dmgmodify", dmgmodify( ent, inf, atk, amount, dmginfo ) )
end

concommand.Add( "dmgmodify_rehook", hooka(), nil, "This will remove the dmgmodify hook and readd it. (Use at your own risk.)" )

hook.Add( "EntityTakeDamage", "dmgmodify", dmgmodify( ent, inf, atk, amount, dmginfo ) )