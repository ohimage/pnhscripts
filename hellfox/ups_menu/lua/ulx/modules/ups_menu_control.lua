-- ULX UPS_Menu for ULX SVN/ULib SVN by HeLLFox_15

-- CreateClientConVar("ups_clnstr_string", "*", false, false) -- not needed.

function UpsClnStr( player,command,args )

	strArgs = args[1]
    strArg2 = args[2]
    strArgValid = false
	
	if( strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  " ) then
		strArgs = "*"		
	end
	
	if not ( player:IsValid() ) then return false end 
	
	if(player:IsAdmin() or player:IsSuperAdmin()) then
		
		if(strArgs == "*") then 
			game.CleanUpMap()
            strArgValid = true
		end
        
        if(strArgs == "p") then
            if( strArg2 == "" or strArg2 == nil or strArg2 == " " or strArg2 == "  " ) then
                print("Error: Player Not Specified!")
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
            umsg.Start( "[clnup] Cleanup Help All" )
                    umsg.String( "[clnup] Input a model string or an entity class.\n [clnup] Input * to cleanup every thing.\n [clnup] Input p then a players name to cleanup a player.\n", player )
            umsg.End()
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
        
        if( string.find(strArgs,"*") >= 1 and string.len(strArgs) > 1 ) then
            fStrArgs = string.Explode(strArgs,"*")
            for _, ent in ipairs( ents.GetAll() ) do
                if(ent:IsValid() and not ent:IsWorld()) then
                    if not (table.HasValue( ignoreList, ent:GetClass() )) then
                        for _, sa in ipairs( fStrArgs ) then
                            if( string.find(ent:GetClass(),sa) > 0 ) then ent:Remove() end
                            strArgValid = true
                        end
                    end
                end
            end    
        end
	
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
            umsg.Start( "[clnup] Cleanup Confirmed 01" )
                if( strArgs == "*" ) then
                    umsg.String( "[clnup] "..player:GetName().." has reset the map." )
                else
                    umsg.String( "[clnup] "..player:GetName().." has removed "..strArgs )
                end
            umsg.End()
            strArgValid = false
        end
			
	elseif not (strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  ") then	
        umsg.Start( "[clnup] Cleanup Error 01" )
                umsg.String( "[clnup] You are not allowed to do that "..player:GetName(), player )
        umsg.End()
        strArgValid = false
	end
end
	
concommand.Add( "ups_clnstr", UpsClnStr )