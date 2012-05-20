-- RP Player Damage --

if( CLIENT ) then
    function HurtEff( hp )
        local tab = {}
            tab[ "$pp_colour_addr" ] = 5
            tab[ "$pp_colour_addg" ] = 0
            tab[ "$pp_colour_addb" ] = 0
            tab[ "$pp_colour_brightness" ] = 0
            tab[ "$pp_colour_contrast" ] = 1
            tab[ "$pp_colour_colour" ] = 1
            tab[ "$pp_colour_mulr" ] = hp * 2
            tab[ "$pp_colour_mulg" ] = 1
            tab[ "$pp_colour_mulb" ] = 1 

        DrawColorModify( tab )
	
        DrawMotionBlur( 0.5, 0.5, 0.1 )
        DrawBloom( 1, Hp/100, 3, 9, 9, 1, 255, 0, 0 )
    end
else
    return end
end

function GM:EntityTakeDamage( ent, inflictor, attacker, amount )
    if( ent:IsPlayer() ) then 
        hurtEff( ent:Health() )        
    end
end

local BestScore = 0 
local BestPlayer

function BestPlayer()
    // Looping trough a table of all players where v is an individual player.
    for k,v in pairs( player.GetAll() ) do  
        local Frags = v:Frags()       // Getting a player's frags
        if Frags > BestScore then     // If it's higher then the current BestScore then
            BestScore = Frags     // Make it the new BestScore
            BestPlayer = v // And make the player the new BestPlayer
        end
    end
    
    return BestPlayer
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

    if( attacker:IsPlayer() ) then
        attacker:AddMoney(50)
    end

    if( BestPlayer():Alive() == false ) then // If anyone had a score higher then 0 then print the results.
        if( attacker:IsValid() and attacker:IsPlayer() ) then attacker:AddMoney(20) end
    end

end

timer.Create( "PlyHealthC", 2, 0, PlyHealthRegVar = 0)
timer.Create( "PlyHealth", 4, 0, PlyHealthRegVar = 1)

function regenHealth()
    if( PlyHealthRegVar ) then
        for _, ply in pairs( player.GetAll() ) do
            if ( ply:Health() < 100 ) then
                ply:SetHealth(ply:Health() + 1)
            end
        end
    end
end
hook.Add( "Think", "PlayerHealthRegen", regenHealth )