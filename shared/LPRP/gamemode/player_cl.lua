local plymeta = FindMetaTable("Player")

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

if(plymeta.OldName == nil)then
	plymeta.OldName = plymeta.Name
	function plymeta:Name()
		local n = self:GetNWString("name")
		if( n == nil or n == "" )then
			return self:OldName()
		else
			return n
		end
	end
	function plymeta:Nick()
		return self:Name()
	end
	function plymeta:GetName()
		return self:Name()
	end
end

local money = 0
function LPRP:GetMoney()
	return money
end
function LPRP:SetMoney(amount)
	money = amount
end

usermessage.Hook("LPRP_UpdateCLWallet",function( data )
	money = data:ReadLong()
	print("Money updated client side to "..money )
end)