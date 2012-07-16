local chatText = {}

local function recieveMessageStream( handler, id, encoded, message )
	local prefix = message[1]
	local prefixColor = message[2]
	local ply = message[3]
	local msg = message[4]
	chat.AddText(Color( 200, 200, 200 ), '<',prefixColor, prefix, ply,Color( 200, 200, 200 ),'>',Color( 255, 255, 255 ),unpack( msg ) )
end
datastream.Hook("LPRP_Chat",recieveMessageStream )

surface.CreateFont( "LPRP_Hand", 25, 300, true, false, "LPRP_HandWriting", false, false )
local boxOpen = {}
hook.Add("HUDPaint","LPRP_ChatBox",function()
	surface.SetFont("Trebuchet24")
	for i = 1, 9 do
		if( chatText[ i ] != nil)then
			local curMsg = chatText[ i ]
			local lenSum = 10
			local curCol = Color( 255, 255, 255 )
			for k,v in pairs( curMsg )do
				if( type( v ) == "table")then
					curCol = Color( v.r, v.g, v.b, 255 )
				else
					draw.SimpleText(  v,  "LPRP_Hand",  lenSum,  ScrW() / 2 - i * 20, curCol,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
					lenSum = lenSum + surface.GetTextSize( v )
				end
			end
		end
	end
end)