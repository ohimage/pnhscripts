require("namechange") -- the module for the hack.

// stuff used in any hack
local thishack = {}
thishack.name = "Name Changer"
thishack.version = "1.0.0"
thishack.enabled = false
thishack.menuicon = "gui/silkicons/plugin"
thishack.data = {}
thishack.speed = 1
thishack.formatter = "[randomised] PHack Name Default"
thishack.namegenerators = {}
// TODO: The name changer menu needs ability to create random generators added.

thishack.menuload = function( PSheet ) -- allows for adding it's own special touch to the LP_hackmenu page.
	// Shows a combo box with list of name generators that can be used.
	local GensListLabel = vgui.Create("DLabel", PSheet)
	GensListLabel:SetPos(10,100)
	GensListLabel:SetText("Avaliable Name Generators")
	GensListLabel:SizeToContents()
	
	local NameGeneratorPicker = vgui.Create( "DComboBox", PSheet )
	NameGeneratorPicker:SetPos( 10, 120 )
	NameGeneratorPicker:SetSize( 100, 300 )
	NameGeneratorPicker:SetMultiple( false ) -- Don't use this unless you know extensive //knowledge about tables
	for k,v in pairs(thishack.namegenerators)do
		NameGeneratorPicker:AddItem(k)
	end
	
	// formatter string entry box
	local FormatStringLbl = vgui.Create("DLabel", PSheet)
	FormatStringLbl:SetPos(20,25)
	FormatStringLbl:SetText("Format String: ")
	FormatStringLbl:SizeToContents()
	
	local formatentry = vgui.Create( "DTextEntry", PSheet )
	formatentry:SetPos( 90,25 )
	formatentry:SetSize(200,20)
	formatentry:SetEnterAllowed( true )
	formatentry:SetValue("[randomised] PHack Name Default")
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( PSheet ) -- Set parent to our "DermaPanel"
	DermaButton:SetText( "Set" )
	DermaButton:SetPos( 305, 25 )
	DermaButton:SetSize(50,20)
	DermaButton.DoClick = function ()
		thishack.formatter = formatentry:GetValue()
	end
	
	// show the bar for setting the change rate:
	local NumSliderThingy = vgui.Create( "DNumSlider", PSheet )
	NumSliderThingy:SetPos( 25 , 60 )
	NumSliderThingy:SetSize( 200, 100 ) -- Keep the second number at 100
	NumSliderThingy:SetText( "Name Change Speed" )
	NumSliderThingy:SetMin( 0.05 ) -- Minimum number of the slider
	NumSliderThingy:SetMax( 60 ) -- Maximum number of the slider
	NumSliderThingy:SetDecimals( 4 ) -- Sets a decimal. Zero means it's a whole number
	NumSliderThingy.OnValueChanged = function( val )
		PHack.lib.debugmsg(" changed the speed to "..NumSliderThingy:GetValue())
		thishack.speed = NumSliderThingy:GetValue()
	end
end

// the code for the actual hack part
thishack.data.timername = "LP_ChangeName" //math.random(10000000,99999999) -- uses random number to get arround hook table blacklists.

thishack.onEnabled = function( )
	MsgN("Phack Name Changer enabled")
	timer.Simple(thishack.speed, thishack.run)
end
thishack.onDisabled = function()
	Msg("Phack Name changer disabled\n")
	thishack.enabled = false
end


thishack.namegenerators["players"] = function( length ) -- name generators are actually functions
	return player.GetAll()[math.random(1,#player.GetAll())]:Nick()..' ~'
end

thishack.namegenerators["randomised"] = function( length) -- name generators are actually functions
	local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ"
	local name = ""
	for i = 1, length do
		name = name..letters[math.random(1,string.len(letters))]
	end
	return name;
end

thishack.namegenerators["shapes"] = function( length ) -- name generators are actually functions
	local letters = file.Read("PHack/namechangerstrings.txt")
	local name = ""
	for i = 1, length do
		name = name..letters[math.random(1,string.len(letters))]
	end
	return name;
end
// set the default generator to be randomised.
// thishack.namegenerator = "randomised"

PHack.lib.registerPlugin( thishack ) -- register it with my hack.

// this code is quite inefficient. Increasing speed would be nice as long formatter strings would
// get laggy for other applications like the chat spammer.
local function createNameFromFormat( str )
	local cursegment = ""
	local count = 1
	local finalstr = ""
	for i = 1, string.len(str) do
		local curchar = str[i]
		if(curchar == '[' or curchar == ']')then
			if(count % 2 == 1)then
				PHack.lib.debugmsg(" found a string part. Adding it to the segments.")
				finalstr = finalstr..cursegment
				cursegment = ""
				count = count + 1
			else
				PHack.lib.debugmsg(" found function name "..cursegment..". Adding it into the segments")
				local exp = string.Explode( ' ' , cursegment )
				if(thishack.namegenerators[ exp[1] ] == nil) then
					chat.AddText(Color(255,0,0,255),"Name generator "..exp[1].." is invalid.")
				else
					if(exp[2] == nil)then
						exp[2] = 4
					else
						exp[2] = tonumber(exp[2])
					end
					PHack.lib.debugmsg("exp 1 is "..tostring(exp[1]))
					finalstr = finalstr..thishack.namegenerators[ exp[1] ]( exp[2] )
				end
				cursegment = ""
				count = count + 1
			end
		else
			cursegment = cursegment..curchar
		end
	end
	// lastly we add on the current segment to make sure nothing is left off.
	finalstr = finalstr .. cursegment
	PHack.lib.debugmsg("Got the final string "..finalstr)
	return finalstr
end

thishack.run = function() -- the code to load the hack. Hooks should be put here
	PHack.lib.debugmsg("useing format "..thishack.formatter)
	ChangeName(createNameFromFormat(thishack.formatter))
end