PHack = {}

--==============================================================
--                   CONFIGURATION
--==============================================================
local settings = {}
local varlist = {}
local optionlist = {}

function PHack:CfgListAdd( val , options )
	table.insert( varlist, val )
	optionlist[ val ] = options
end
function PHack:GetCfgVar( name, default)
	name = string.lower( name )
	if( settings[name] == nil)then
		settings[name] = default or 0
	end
	return settings[name]
end
if not file.IsDir("PHack")then
	file.CreateDir("PHack")
end
local dat = file.Read("PHack/config_save.txt")
settings = glon.decode( dat )
concommand.Add("PHack_SetVar",function( ply, cmd, arg)
	if(#arg == 2)then
		if arg[1] and arg[2] then
			local val = arg[2]
			if( string.match( arg[2] , "[%d]"))then
				val = tonumber( val )
			elseif( string.match( arg[2] , "true") )then
				val = true
			elseif( string.match( arg[2] , "false") )then
				val = false
			end
			settings[ string.lower( arg[1] ) ] = val
			chat.AddText(Color(0,0,255),"Set Value ",Color(0,255,255),arg[1],Color(0,0,255)," to ",Color(0,255,255),tostring(val),"[",type(val),"].")
			file.Write("PHack/config_save.txt",glon.encode( settings ) )
		else
			ErrorNoHalt("Expected 2 arguements. <property> <value> got none")
		end
	else
		ErrorNoHalt("Expected 2 arguements. <property> <value> got "..#arg)
	end
end, function( cmd, arg )
	arg = string.sub( arg, 2)
	local exp = string.Explode(" ",arg)
	local curword = exp[#exp]
	local count = #exp
	local partial = cmd
	for i = 1, #exp - 1 do
		partial = partial .. " " .. exp[i]
	end
	partial = string.Trim( partial )
	local final = {}
	local curlist = {}
	if( count == 1)then
		curlist = varlist
	elseif( count == 2)then
		if( optionlist[ exp[1]] != nil)then
			curlist = optionlist[ exp[1] ]
		end
	end
	for k,v in pairs( curlist) do
		if(string.find( string.lower( v ), string.lower( curword)))then
			table.insert( final, v )
		end
	end
	for k,v in pairs( final )do
		final[ k ]= partial.." "..v
	end
	if(#final == 0)then
		final = {"<No Options>"}
	end
	return final
end)

PHack:CfgListAdd( "PropCam_Enabled", {"true", "false"} )
PHack.tempShowPlayer = false

hook.Add("ShouldDrawLocalPlayer","LPHACK_DrawLocalPlayer",function()
	return PHack.tempShowPlayer
end)