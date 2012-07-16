local plymeta = FindMetaTable( "Player" )
local LPRPIDS = {}

function plymeta:LPRP_ID()
	if(LPRPIDS[ self:UniqueID() ] == nil)then
		local id = string.gsub( self:SteamID() , '[^%d]',"")
		id = tonumber( id )
		LPRPIDS[ self:UniqueID() ] = id
		return id
	else
		return LPRPIDS[ self:UniqueID() ]
	end
end

hook.Add("LPRP_CleanupUserTables","CleanupID",function( ply )
	table.remove( LPRPIDS, ply:UniqueID() )
end)

function plymeta:GiveMoney( a, notify )
	if( notify == nil and notify == false )then
		if( a > 0)then
			LPRP:Notify( self, Color(100,155,100,255),"You have recieved $"..a..".")
		else
			LPRP:Notify( self, Color(255,100,100,255),"Deducted $"..a..".")
		end
	end
	LPRP:GetUser( self ).money = (LPRP:GetUser( self ).money or 0) + a
	self.MoneyHasChanged = true
	umsg.Start("LPRP_UpdateCLWallet", self) -- still need to write the client handler.
		umsg.Long( LPRP:GetUser( self ).money  )
	umsg.End()
end

function plymeta:SetMoney( a, notify )
	if( a > 0 and ( notify == nil or not notify ) )then
		LPRP:Notify( self, Color(100,155,100,255),"Your money was set to $"..a..".")
	end
	LPRP:GetUser( self ).money = a
	self.MoneyHasChanged = true
	umsg.Start("LPRP_UpdateCLWallet", self) -- still need to write the client handler.
		umsg.Long( LPRP:GetUser( self ).money  )
	umsg.End()
end

function plymeta:GetMoney()
	return LPRP:GetUser( self ).money or 0
end

function plymeta:CanAfford( amount )
	return (LPRP:GetUser( self ).money or 0 )>= amount
end


function plymeta:SetName( name )
	self:SetNWString("name", name )
end

concommand.Add("LPRP_SetName",function( ply , cmd, args)
	ply:SetName( args[ 1] )
end)
