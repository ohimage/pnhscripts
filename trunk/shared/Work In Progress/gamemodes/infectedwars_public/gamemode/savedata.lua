/*------------
Infected Wars
savedata.lua
Serverside
------------*/

/*-------------------------
Write and read player data
--------------------------*/
function GM:WritePlayerData( pl )
	
	if not PLAYER_STATS then return end
	
	-- Register player play data
	pl.DataTable["timeplayed"] = math.max(0,math.floor(pl.DataTable["timeplayed"]+CurTime()-(pl.StartTime or CurTime())))
	
	local path = "infectedwars/data_"..string.Replace( string.sub(pl:SteamID(), 9), ":", "-" )..".txt"
	-- util.TableToKeyValues won't work since I write down the last used name plus the
	-- player's Steam ID too. That way it's easier for readers to identify whom's data it contains.
	pl.DataTable["name"] = pl:Name()
	pl.DataTable["id"] = pl:SteamID()
	pl.DataTable["money"] = pl:Money()
	pl.DataTable["title"] = pl.TitleText or "Guest"
	
	-- wait, doesn't util.TableToKeyValues convert booleans already? LIES I TELL YOU!
	for k, v in pairs(achievementDesc) do
		pl.DataTable["achievements"][k] = tostring(pl.DataTable["achievements"][k])
	end	
	
	for k, v in pairs(shopData) do
		pl.DataTable["shopitems"][k] = tostring(pl.DataTable["shopitems"][k])
	end
	
	local data = util.TableToKeyValues(pl.DataTable)
	
	-- and convert them back, we might be needing them later
	for k, v in pairs(achievementDesc) do
		pl.DataTable["achievements"][k] = util.tobool(pl.DataTable["achievements"][k])
	end	
	
	file.Write( path, data )
end

function GM:GetBlankStats( pl )
	local data =
	[["0"
	{
		"name" "]]..pl:Name()..[["
		"id" "]]..pl:SteamID()..[["
		"money" "0"
		"title" "Guest"
]]
	for k, v in pairs(recordData) do
		data = data..'		"'..k..'" "0"\n'
	end
	data = data..[[
		
		"achievements"
		{
]]
	for k, v in pairs(achievementDesc) do
		data = data..'			"'..k..'" "false"\n'
	end
	data = data..[[
		}
		
		"shopitems"
		{
]]
	for k, v in pairs(shopData) do
		data = data..'			"'..k..'" "false"\n'
	end
		data = data..[[
		}
		
	}]]
	
	return data
end

function GM:WriteBlankData( pl )

	if not PLAYER_STATS then return end
	
	local path = "infectedwars/data_"..string.Replace( string.sub(pl:SteamID(), 9), ":", "-" )..".txt"
	local data = self:GetBlankStats(pl)
	
	file.Write( path, data )
end

-- read file, if it doesnt exists, create a blank first
function GM:ReadData( pl )
	
	if not PLAYER_STATS then return end
	
	pl.DataTable = {}
	
	local path = "infectedwars/data_"..string.Replace( string.sub(pl:SteamID(), 9), ":", "-" )..".txt"
	if not file.Exists( path ) then
		GAMEMODE:WriteBlankData( pl )
	end
	
	local contents = file.Read( path )
	pl.DataTable = util.KeyValuesToTable(self:GetBlankStats(pl))
	local tab = util.KeyValuesToTable(contents)
	-- Merge with default table new updates can be added to the achievements
	-- list without having to totally erase all player data to avoid errors.
	table.Merge( pl.DataTable, tab ) 
	
	-- Convert the achievements to boolean values. No, util.KeyValuesToTable does NOT do this for you
	-- like it says on the wiki!
	for k, v in pairs(achievementDesc) do
		if achievementDesc[k] ~= nil then
			pl.DataTable["achievements"][k] = util.tobool(pl.DataTable["achievements"][k])
		else
			pl.DataTable["achievements"][k] = nil
		end
	end	
	
	for k, v in pairs(pl.DataTable["shopitems"]) do
		if shopData[k] ~= nil then
			pl.DataTable["shopitems"][k] = util.tobool(pl.DataTable["shopitems"][k])
		else
			pl.DataTable["shopitems"][k] = nil
		end
	end	
	
	local title = pl.DataTable["title"] or "Guest"
	pl:SetTitle(title)
	
end

function SendShopData( to )
	if not to:IsValid() then return end
	
	umsg.Start( "SetShopData", to )
		for k, v in pairs(shopData) do
			umsg.Bool( to.DataTable["shopitems"][k] )
		end
	umsg.End()

end