-- UPS_Menu by HeLLFox

function UpsClnMsg( ply, msg, wasValid )
    
    if not ( ply == nil or ( ply:IsPlayer() and ply:IsValid() ) ) then return end
    if( ply and ply:IsValid() ) then wasValid = true end
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

function UpsClnStr( player,command,args )

	strArgs = args[1]
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
	
	if(strArgs == "*") then 
		game.CleanUpMap()
        game.ConsoleCommand("gmod_admin_cleanup")
        strArgValid = true
	end
    
    if(strArgs == "s*") then
        game.ConsoleCommand("gmod_admin_cleanup")
        strArgValid = true
    end
        
    if(strArgs == "p") then
        if( strArg2 == "" or strArg2 == nil or strArg2 == " " or strArg2 == "  " ) then
            UpsClnMsg( player, "Error: Player Not Specified!")
        else
            for k,v in pairs(player.GetAll())do
                if( v:IsValid() and v:IsPlayer() and string.find(v:Name(),strArg2) ) then
                    v:ConCommand("gmod_cleanup")
                    strArgValid = true
                end
            end
        end
    end
	
	if(strArgs == "help") then
        UpsClnMsg( player, "[clnup] Input a model string or an entity class.\n [clnup] Input s* cleans up every thing safely, input * resets the map.\n [clnup] Input p then a players name to cleanup a player.\n" )
    end

	ignoreList =
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
		"class C_Sun",
		"class C_EnvTonemapController",
		"class C_WaterLODControl",
		"class C_SpotlightEnd"
	}
        
    ScanReturn = {}
    indxd = 0
        
    if(strArgs == "scan") then
        for _, ent in ipairs( ents.GetAll() ) do
            if not (table.HasValue( ignoreList, ent:GetClass() )) then
                indxd = indxd + 1
                table.insert(ScanReturn,ent:GetClass())
            end
        end
        UpsClnMsg( player, "[clnup] Scan Results_\n"..table.concat(ScanReturn,"\n").."[clnup] "..indxd.." objects have been found." )
        indxd = 0
        ScanReturn = {}
    end
    
--[[if( string.find(strArgs,"*") >= 1 and string.len(strArgs) > 1 ) then
        fStrArgs = string.Explode(strArgs,"*")
        for _, ent in ipairs( ents.GetAll() ) do
            if(ent:IsValid() and not ent:IsWorld()) then
                if not (table.HasValue( ignoreList, ent:GetClass() )) then
                    for _, sa in ipairs( fStrArgs ) do
                        if( string.find(ent:GetClass(),sa) > 0 ) then ent:Remove() end
                        strArgValid = true
                    end
                end
            end
        end    
    end ]]

    for _, ent in ipairs( ents.GetAll() ) do
        if(ent:IsValid() and ent:GetModel() == strArgs) then
        
            if not (ent:IsWorld()) then
                if not table.HasValue( ignoreList, ent:GetClass() ) then
                    ent:Remove()
                    strArgValid = true
                end
            end
            
        elseif(ent:IsValid() and ent:GetClass() == strArgs) then
        
            if not table.HasValue( ignoreList, ent:GetClass() ) then
                
                if( ent:IsValid() and ent:GetClass() == strArgs ) then
                    
                    if not ( ent:IsWorld() ) then
                        
                        ent:Remove()
                        strArgValid = true
                    
                    end
                end
            end
        end
    end
        
    if( strArgValid ) then
        if( strArgs == "*" ) then
            UpsClnMsg( nil, "[clnup] "..splyname.." has reset the map." )
        elseif( strArgs == "s*" ) then
            UpsClnMsg( nil, "[clnup] "..splyname.." has cleaned up the map." )
        else
            UpsClnMsg( nil, "[clnup] "..splyname.." has removed "..strArgs )
        end
        strArgValid = false
    end
end
	
concommand.Add( "hf_clnstr", UpsClnStr, {"help","s*","*","prop_physics","prop_ragdoll","npc_*"} )