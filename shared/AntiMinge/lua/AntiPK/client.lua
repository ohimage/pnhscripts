if(SERVER)then
	print([[
	ERROR: ANTI PK SERVER RUNNING ON CLIENT.
	I have no clue why this file ended up running clientside
	but the owner of the server is probably a dumbass with no
	clue what hes doing... and should give up on his dreams
	of learning to program.]])
	return
end
print([[
########################################
# Loaded TheLastPenguin's AntiPropkill #
# This server is protected by Penguin's#
# AntiPropKill version 0.0.1           #
# Type AntiMinge_Info in console for more #
# information.                         #
########################################
]])

usermessage.Hook("PK_Tried",function( data )
	local attacker = data:ReadEntity()
	local victim = data:ReadEntity()
	if(ValidEntity( attacker ) and ValidEntity( victim ))then
		chat.AddText( attacker,Color(0,255,255),
			" (",attacker:SteamID(),")",
			" tried to prop kill ", victim,
			". please report his SteamID to an admin if none are on.")
	end
end)

-- hook.Add("PhysgunDrop","SVGuard_PhysDrop_Client",function( ply, ent )
	-- if(ent:GetClass() == "prop_physics")then
        -- ent.activeHold = false
        -- ent.RgbCol = 0
		-- ent:SetColor( ent.oldColor )
        -- ent:SetMaterial( ent.oldMat )
        -- print("Dropped Object")
	-- end
-- end)

-- hook.Add("PhysgunPickup","SVGuard_PhysPickup_Client",function( ply, ent )
	-- if(ent:GetClass() == "prop_physics")then
        -- ent.activeHold = true
		-- ent.oldColor = Color(ent:GetColor())
        -- ent.oldMat = Material(ent:GetMaterial())
        -- ent:SetMaterial(Material("models/wireframe"))
        -- while(ent.activeHold) do
            -- if(ent.RgbCol == 360 or ent.RgbCol == nil) then
                -- ent.RgbCol = 0
            -- end
            -- ent:SetColor(HSVToColor(ent.RgbCol,1,1))
            -- ent.RgbCol = ent.RgbCol + 10
        -- end
	-- end
-- end)


concommand.Add("AntiMinge_Info",function( ply, cmd, args)
	print([["
This server is protected by TheLastPenguin's
AntiMinge mod version 0.0.1.
Created by TheLastPenguin.
Maintained by [ULX]HeLLFox and TheLastPenguin."]])
end