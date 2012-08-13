-- UPS_Menu by HeLLFox

function UpsClnMsg( ply, msg, wasValid )
    
    if not ( ply == nil or ( ply:IsPlayer() and ply:IsValid() ) ) then return end
    if( ply and ply:IsValid() ) then wasValid = true else wasValid = false end
    if( msg == nil ) then return end
    
	if SERVER and ply and not ply:IsValid() then -- Server console
		if wasValid then -- This means we had a valid player that left, so do nothing
			return
		end
		Msg( msg .. "\n" )
		return
	end

	if CLIENT then
		LocalPlayer():ChatPrint( msg )
		return
	end

	if ply then
		ply:ChatPrint( msg )
	else
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			player:ChatPrint( msg )
		end
	end
end

-- Thanks to who ever made the above script for ulib.tsay

function clnupAllTable( splyname, delList )
    local entModel = ""
    UpsClnMsg( nil, "[clnup] " .. splyname .. " has removed ")
    for _,ent in pairs(delList) do
        if(ent and ent:IsValid() and not ent:IsWorld()) then
            if( ent:GetModel() ) then entModel = ent:GetModel() end
            UpsClnMsg( nil, ent:GetClass() .. "(" .. entModel .. ")" )
            ent:Remove()
        end
    end
    if( delList or table.getn(delList) > 0 ) then
        table.Empty(delList)
    end
end

function UpsClnStr( player,command,args )

	strArgs = string.lower(args[1])
    strArg2 = args[2]
    strArgValid = false
	
	if( strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  " ) then
		strArgs = "s*"		
	end
	
    if ( player:IsValid() ) then
        splyname = player:GetName()
        if not ( player:IsAdmin() or player:IsSuperAdmin() ) then
            if not (strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  ") then	
                UpsClnMsg( player, "[clnup] You are not allowed to do that, "..splyname )
                strArgValid = false
            end
            return
        end
    else
        splyname = "Console"
    end
	
	if(strArgs == "f*") then 
		game.CleanUpMap()
        UpsClnMsg( nil, "[clnup] "..splyname.." has reset the map." )
        return
	end

    if(strArgs == "*") then
        if( player:IsValid() ) then player:ConCommand( "gmod_admin_cleanup" ) else RunConsoleCommand( "gmod_admin_cleanup" ) end
        UpsClnMsg( nil, "[clnup] "..splyname.." has cleaned up the map." )
        return
    end
        
    -- if(strArgs == "p") then
        -- if( strArg2 == "" or strArg2 == nil or strArg2 == " " or strArg2 == "  " ) then
            -- UpsClnMsg( player, "Error: Player Not Specified!")
        -- else
            -- for k,v in pairs(player.GetAll())do
                -- if( v:IsValid() and v:IsPlayer() and string.find(v:Name(),strArg2) ) then
                    -- v:ConCommand("gmod_cleanup")
                    -- strArgValid = true
                -- end
            -- end
        -- end
    -- end
	
	if(strArgs == "help") then
        UpsClnMsg( player, "[clnup] Input a model string or an entity class.\n [clnup] Input s* cleans up every thing safely, input * resets the map.\n [clnup] Input p then a players name to cleanup a player.\n" )
        return
    end
    
    local WildCard = false
    local killScript = false
    local cs = string.find(strArgs,"*")
    local entClassS = 0
    local entModelS = 0
    local delList = {}
	local ignoreList =
	{
        "player",
        "worldspawn",
        "gmod_anchor",    
        "npc_grenade_frag", 
        "prop_combine_ball", 
        "npc_satchel",
        "class C_PlayerResource",
        "C_PlayerResource",
        "viewmodel",
        "beam",
        "physgun_beam",
        "class C_FogController",
        "C_FogController",
        "class C_Sun",
        "C_Sun",
        "class C_EnvTonemapController",
        "C_EnvTonemapController",
        "class C_WaterLODControl",
        "C_WaterLODControl",
        "class C_SpotlightEnd",
        "C_SpotlightEnd"
	}
        
    -- ScanReturn = {}
    -- indxd = 0
        
    -- if(strArgs == "scan") then
        -- for _, ent in ipairs( ents.GetAll() ) do
            -- if not (table.HasValue( ignoreList, ent:GetClass() )) then
                -- indxd = indxd + 1
                -- table.insert(ScanReturn,ent:GetClass())
            -- end
        -- end
        -- UpsClnMsg( player, "[clnup] Scan Results_\n"..table.concat(ScanReturn,"\n").."[clnup] "..indxd.." objects have been found." )
        -- indxd = 0
        -- ScanReturn = {}
    -- end
    
    for _, ent in ipairs( ents.GetAll() ) do
        if(ent and ent:IsValid() and ent:GetModel() == strArgs) then
            if not (ent:IsWorld()) then
                if not table.HasValue( ignoreList, ent:GetClass() ) then
                    ent:Remove()
                    strArgValid = true
                end
            end
            
        elseif(ent and ent:IsValid() and ent:GetClass() == strArgs) then
            if not table.HasValue( ignoreList, ent:GetClass() ) then
            
                if not ( ent:IsWorld() ) then
                    ent:Remove()
                    strArgValid = true
                end
                
            end
            
        elseif(ent and ent:IsValid() and strArgs and string.find(strArgs, "*") and not (ent:IsWorld() and strArgValid)) then
            if(ent:GetClass() and ent:GetModel() and not (ent:GetModel() == nil or ent:GetModel() == "") ) then
                if not table.HasValue( ignoreList, ent:GetClass() ) then
                    if( ent:GetClass() ) then
                        entClassS = string.find(ent:GetClass(), string.Trim(strArgs,"*"))
                    else
                        killScript = true
                        break
                    end
                    
                    if not( entClassS == nil ) then
                        if ( entClassS <= cs ) then
                            table.insert(delList,ent)
                        end
                        WildCard = true
                    end
                end
            else
                WildCard = false
            end
            
        end
    end
    
    if( killScript ) then 
        UpsClnMsg( player, "[clnup] Error. No valid ents." )
        return 
    end
    
    if( WildCard ) then
        if( string.find(strArgs,"*") > 0 ) then
            clnupAllTable(splyname, delList)
            if( delList or table.getn(delList) > 0 ) then
                table.Empty(delList)
            end
        end
    end
        
    if( strArgValid ) then
        UpsClnMsg( nil, "[clnup] "..splyname.." has removed "..strArgs )
        strArgValid = false
    end
end

concommand.Add( "hf_clnstr", UpsClnStr, function() return {"hf_clnstr help","hf_clnstr *","hf_clnstr f*","hf_clnstr prop_physics","hf_clnstr prop_ragdoll","hf_clnstr npc_*"} end )