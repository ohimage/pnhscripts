-- ULX UPS_Menu for ULX SVN/ULib SVN by HeLLFox_15

-- CreateClientConVar("ups_clnstr_string", "*", false, false) -- not needed.

function UpsClnStr( player,command,args )

	strArgs = args[1]
    strArg2 = args[2]
	
	if( strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  " ) then
		strArgs = "*"		
	end
	
	if not ( player:IsValid() ) then return false end 
	
	if(player:IsAdmin() or player:IsSuperAdmin()) then
		
		if(strArgs == "*") then 
			game.CleanUpMap()
		end
        
        if(strArgs == "p") then
            if( strArg2 == "" or strArg2 == nil or strArg2 == " " or strArg2 == "  " ) then
                print("Error: Player Not Specified!")
            else
                for k,v in pairs(player.GetAll())do
                    if( v:Name() == strArg2 ) then
                        v:ConCommand("gmod_cleanup")
                    end
                end
            end
        end
	
		if(strArgs == "help") then ULib.tsay( player,"Input a model string or an entity class." ) end

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
					end
				end
				
			elseif(ent:IsValid() and ent:GetClass() == strArgs) then
			
				if not table.HasValue( ignoreList, ent:GetClass() ) then
					
					if( ent:IsValid() and ent:GetClass() == strArgs ) then
						
						if not ( ent:IsWorld() ) then
							
							ent:Remove()
						
						end
					end
				end
			end
		end
			
		ULib.tsay( nil, player:GetName().." has removed "..strArgs )
			
	elseif not (strArgs == "" or strArgs == nil or strArgs == " " or strArgs == "  ") then	
		ULib.tsay(	player, "You are not allowed to do that." )	
	end
end
	
concommand.Add( "ups_clnstr", UpsClnStr )