require("datastream")
resource.AddSingleFile( "resource/fonts/LPRP_Hand.ttf")

local colors = {}
colors['r'] = Color( 255, 0, 0 )
colors['w'] = Color( 255, 255, 255 )
colors['g'] = Color( 0, 255, 0 )
colors['b'] = Color( 0, 0, 255 )
colors['f'] = colors['w'] -- f is an alias for white
colors['0'] = Color( 0, 0, 0 )
colors['c'] = Color( 0, 255, 255)
colors['y'] = Color( 255, 255, 0)
colors['o'] = Color( 255, 127, 0)
colors['p'] = Color( 255, 0, 255)

function GM:PlayerSay(  ply,  text,  team_only,  dead )
	local exp = string.Explode( ' ', text )
	local colorsUsed = 0
	local prefix = ''
	local prefixColor =  Color( 100, 100, 100 )
	local message = {}
	local final = {}
	local occ = false
	if( not dead )then
		if( exp[1] == '//')then
			occ = true
			table.remove( exp, 1 )
		end
		for k,v in ipairs( exp )do
			if( v[1] == '&' and v[2] != nil )then
				if( colors[ v[2] ] != nil)then
					table.insert( message , colors[ v[ 2] ] )
					colorsUsed = colorsUsed + 1;
				end
			else
				table.insert( message, v..' ')
			end
		end
	else
		message[1] = Color( 255, 100, 100 )
		message[2] = text
		prefixColor =  Color( 255, 100, 100 )
		prefix = '*dead*'
	end
	if( ply:CanAfford( colorsUsed * 10 ) )then
		ply:GiveMoney( colorsUsed * (-10), false )
		if( colorsUsed != 0 )then
			LPRP:Notify( ply, Color( 0, 200, 0, 255 ), string.format( "Spent $%.2s on message color codes.", colorsUsed * 10 ) )
		end
		final[1] = prefix
		final[2] = prefixColor
		final[3] = ply
		final[4] = message
		datastream.StreamToClients( player.GetAll(), "LPRP_Chat", final );
	else
		LPRP:Notify( ply,Color( 255, 0, 0, 255 ),"You cant afford the color codes in your message.")
	end
	return ""
end
