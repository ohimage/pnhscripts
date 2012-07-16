/*Note to coders:
Frequently accessed values should be written in SQLite
Large amounts of data and stuff thats not frequently accessed
should go in the text files.
*/

local sql = sql
local file = file
local DATA = {}
LPRP.DATA = DATA


local lastErrorShown = sql.LastError()
concommand.Add("SQLite_LastError",function(ply)
	if(ply:IsListenServerHost())then
		if(lastErrorShown == sql.LastError())then
			print("Last SQL Error was:")
			print("No new errors.")
		else
			print("Last SQL Error was: ")
			print(sql.LastError())
			lastErrorShown = sql.LastError()
		end
	end
end)

// Configuration.
local config = {}

DATA.MakeDirIfNotExists = function( dir )
	if(!file.IsDir(dir))then
		file.CreateDir(dir)
	end
end


// Initalise stuff
DATA.Init = function()
	// Data Directories:
	DATA.MakeDirIfNotExists("LPRP")
	DATA.MakeDirIfNotExists("LPRP/UserData")
	
	// SQL Tables
	print("Checking that SQLite database tables exist.")
	sql.Begin()
		sql.Query( "CREATE TABLE IF NOT EXISTS LPRP_money (id BIGINT, amount BIGINT)" )
		sql.Query( "CREATE TABLE IF NOT EXISTS LPRP_variables (name VARCHAR( 50 ), value VARCHAR(50))" )
	sql.Commit()
end
// we call it right after.
DATA.Init()

-- checks that the player's data entry exists in the sql table given.
function LPRP:inSQLTable( ply, name )
	local query = "SELECT * FROM "..name.." WHERE id = "..sql.SQLStr( ply:LPRP_ID() )..";"
	local result = sql.QueryValue( query )
	if( result == nil)then
		print("Player doesnt have this table" )
		return false
	end
	return true
end

-- checks that entrys for the player exist in all needed plaeyr data tables
function LPRP:SettupSQLUserData( ply )
	if( not LPRP:inSQLTable( ply, "LPRP_money") )then
		print("Making money table for "..ply:Nick() )
		local query = string.format(
		"REPLACE INTO LPRP_money (ID, amount) VALUES ( %s, %s);"
		,sql.SQLStr(ply:LPRP_ID()),sql.SQLStr(LPRP:GetUser( ply ).money or 1000))
		sql.Query( query )
	end
end

-- stores the player's money.
DATA.StoreMoney = function( ply )
	if(ply )then
		print("Updated player "..ply:Nick().."s wallet to "..LPRP:GetUser( ply ).money )
		sql.Query( "UPDATE LPRP_money SET amount = "..math.floor(LPRP:GetUser( ply ).money) .. " WHERE ID = "..sql.SQLStr( ply:LPRP_ID() )..";")
	end
end

-- stores the player's money.
DATA.LoadMoney = function( ply )
	if( ply )then
		local result = sql.QueryValue( "SELECT amount FROM LPRP_money WHERE id='"..ply:LPRP_ID().."'")
		if( result == nil) then
			print("Player not in SQL database. Defaulting money to 1000" )
			ply:SetMoney( 1000 )
			return 1000
		else
			result = tonumber( result )
			ply:SetMoney( result )
			return result
		end
	end
end

timer.Create("ComitMoney",60,0,function()
	for k,v in pairs( player.GetAll())do
		if(v.MoneyHasChanged)then
			v.MoneyHasChanged = false
			DATA.StoreMoney( v )
		end
	end
end)

// this is used for genaric properties that shouldnt be accessed extreamly frequently.
local properties = {}
function LPRP:RegisterPlayerProperty( name, value )
	properties[ name ] = value
end
function LPRP:SetPlayerProperty( ply, name, value )
	ply:LPRP().properties[ name ] = value
	-- changed is reserved for the gamemode.
	ply:LPRP().properties[ "changed" ] = true
end

function LPRP:GetPlayerProperty( ply, name )
	return ply:LPRP().properties[ name ]
end

function LPRP:LoadPlayerProperties( ply )
	local data = file.Read("LPRP/UserData/"..ply:LPRP_ID()..".txt" )
	if( data != nil and data != '' )then
		ply:LPRP().properties = glon.decode( data )
	else
		ply:LPRP().properties = table.Copy( properties )
		print(string.format( "Creating data file for player %s", ply:Nick() ))
		file.Write( "LPRP/UserData/"..ply:LPRP_ID()..".txt", glon.encode( properties ))
	end
end

timer.Create("LPRP_CPD",10, 0 , function( )
	for k,v in pairs(player.GetAll())do
		if( LPRP:GetPlayerProperty(v,"changed") == true )then
			v:LPRP().properties[ "changed" ] = false
			file.Write( "LPRP/UserData/"..v:LPRP_ID()..".txt", glon.encode( v:LPRP().properties ))
		end
	end
end)