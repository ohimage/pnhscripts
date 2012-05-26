--if not file.Exists( "lua_temp/ups/cl_init.lua", true ) then return end -- If this file doesn't exist then the server isn't running UPS.
module( "UPS", package.seeall )

-- ULX UPS_Menu for ULX SVN/ULib SVN by HeLLFox_15

function upsMenuOpen()

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( ScrW() / 2, ScrH() / 2 )
	DermaPanel:SetSize( 500, 500 )
	DermaPanel:SetTitle( "UPS Menu" )
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()

	locatex = 20
	
	local myLabelTwo = vgui.Create("DLabel", DermaPanel)
	myLabelTwo:SetPos( locatex,40 )
	myLabelTwo:SetColor(Color(255,255,255,255)) // Color
	myLabelTwo:SetFont("default")
	myLabelTwo:SetText("Time until props are put up for grabs after player leaves:") // Text
	myLabelTwo:SizeToContents() // make the control the same size as the text.
	
	local NumSliderOne = vgui.Create( "DNumSlider", DermaPanel )
	NumSliderOne:SizeToContents()
	NumSliderOne:SetPos( locatex,60 )
	NumSliderOne:SetText( "Set to -1 to disable" )
	NumSliderOne:SetWide( 150 )
	NumSliderOne:SetMin( -1 ) -- Minimum number of the slider
	NumSliderOne:SetMax( 1200 ) -- Maximum number of the slider
	NumSliderOne:SetDecimals( 0 ) -- Sets a decimal. Zero means it's a whole number
	NumSliderOne:SetConVar( "ups_cl_cleartime" ) -- Set the convar

	
	local myLabelFour = vgui.Create("DLabel", DermaPanel)
	myLabelFour:SetColor(Color(255,255,255,255)) // Color
	myLabelFour:SetPos( locatex,120 )
	myLabelFour:SetFont("default")
	myLabelFour:SetText("Time until deletion after player leaves:") // Text
	myLabelFour:SizeToContents() // make the control the same size as the text.
	
	local NumSliderTwo = vgui.Create( "DNumSlider", DermaPanel )
	NumSliderTwo:SizeToContents()
	NumSliderTwo:SetPos( locatex,140 )
	NumSliderTwo:SetText( "Set to -1 to disable" )
	NumSliderTwo:SetWide( 150 )
	NumSliderTwo:SetMin( -1 ) -- Minimum number of the slider
	NumSliderTwo:SetMax( 1200 ) -- Maximum number of the slider
	NumSliderTwo:SetDecimals( 0 ) -- Sets a decimal. Zero means it's a whole number
	NumSliderTwo:SetConVar( "ups_cl_deletetime" ) -- Set the convar
	
	local CheckBoxOne = vgui.Create( "DCheckBoxLabel", DermaPanel )
	CheckBoxOne:SetPos( locatex,190 )
    CheckBoxOne:SetText( "Delete admin props on leave" )
    CheckBoxOne:SetConVar( "ups_cl_deleteadmin" )
    CheckBoxOne:GetValue()
    CheckBoxOne:SizeToContents()
	
	local CheckBoxTwo = vgui.Create( "DCheckBoxLabel", DermaPanel )
	CheckBoxTwo:SetPos( locatex,210 )
    CheckBoxTwo:SetText( "Admins affected by restrictions" )
    CheckBoxTwo:SetConVar( "ups_cl_affectadmins" )
    CheckBoxTwo:GetValue()
    CheckBoxTwo:SizeToContents()
	
	local CheckBoxThree = vgui.Create( "DCheckBoxLabel", DermaPanel )
	CheckBoxThree:SetPos( locatex,230 )
    CheckBoxThree:SetText( "Enable world protection" )
    CheckBoxThree:SetConVar( "ups_cl_worldprotection" )
    CheckBoxThree:GetValue()
    CheckBoxThree:SizeToContents()
	
	
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
	
	EntTable = {} 
	
	for _, aenty in pairs( ents.GetAll() ) do
		if aenty:IsValid() then
			if not table.HasValue( ignoreList, aenty:GetClass() ) then
				if not aenty:IsWorld() and not aenty:IsWeapon() then
					table.insert(EntTable,aenty)
				end
			end
		end
	end

	------------------------------------------------------------------------------------------------------------------|
-- The code below is glitched in a strange way	
	-- local UpsMenuCC = vgui.Create("DCollapsibleCategory", DermaPanel)
	-- UpsMenuCC:SetPos( 5,290 )
	-- UpsMenuCC:SetSize( 200, 50 ) -- Keep the second number at 50
	-- UpsMenuCC:SetExpanded(  ) -- Expanded when popped up
	-- UpsMenuCC:SetLabel( "Cleanup Controlls" )
 
	-- CategoryList = vgui.Create( "DPanelList" )
	-- CategoryList:SetAutoSize( true )
	-- CategoryList:SetSpacing( 5 )
	-- CategoryList:EnableHorizontal( false )
	-- CategoryList:EnableVerticalScrollbar( true )
 
	-- UpsMenuCC:SetContents( CategoryList ) -- Add our list above us as the contents of the collapsible category
-- The code above glitched in a strange way.                                                                      
------------------------------------------------------------------------------------------------------------------|
	
----Yes Another Thing That Does Not Work, hopefully I can bang my head against the keyboard and figure some thing out, textbox:GetValue() returns " "...----	
	-- local textbox = vgui.Create("TextEntry", DermaPanel)
	-- textbox:SetPos( locatex,290 )
	-- textbox:SetTall( 20 )
	-- textbox:SetWide( 150 )
	-- textbox:SelectAllOnFocus( true )
	-- textbox:SizeToContents()
	-- textbox:GetValue()
----Atleast the Cleanup Button Works----

	local button = vgui.Create( "DButton", DermaPanel )
	button:SizeToContents()
	button:SetPos( locatex,290 )
	button:SetSize( 200, 50 )
	button:SetText( "Cleanup!" )
    button:SetConsoleCommand( "ups_clnstr", textboxval )
	
	local button3 = vgui.Create( "DButton", DermaPanel )
	button3:SizeToContents()
	button3:SetPos( locatex+200,290 )
	button3:SetSize( 200, 50 )
	button3:SetText( "Freeze All Props!" )
	button3:SetConsoleCommand( "ulx", "nolag" )

	
----Every Thing Under This Does Not Work!!!----
	
	
	-- local ClassCleanupMenu = vgui.Create("DCollapsibleCategory", DermaPanel)
	-- ClassCleanupMenu:SetPos( locatex,350 )
	-- ClassCleanupMenu:SetSize( 200, 50 ) -- Keep the second number at 50
	-- ClassCleanupMenu:SetExpanded( 0 ) -- Expanded when popped up
	-- ClassCleanupMenu:SetLabel( "Cleanup all props of a selected class:" )
 
	-- local ClassCleanupList = vgui.Create( "DPanelList", DermaPanel )
	-- ClassCleanupList:SetAutoSize( true )
	-- ClassCleanupList:SetPos( locatex,350 )
	-- ClassCleanupList:SetSpacing( 5 )
	-- ClassCleanupList:EnableHorizontal( false )
	-- ClassCleanupList:EnableVerticalScrollbar( true )
 
	-- ClassCleanupMenu:SetContents( ClassCleanupList, DermaPanel ) -- Add our list above us as the contents of the collapsible category
	
	-- local entClassTable = {}
	
	-- for _, ent in pairs( ents.GetAll() ) do
		-- if( ent:IsValid() ) then
			-- if not ( ent:IsWorld() ) then
				-- if not table.HasValue( ignoreList, ent:GetClass() ) then
					-- table.insert( entClassTable, ent:GetClass() )
				
					-- if table.HasValue( entClassTable, ent:GetClass() ) then
						-- local clnbutton = vgui.Create( "DButton" )
						-- clnbutton:SizeToContents()
						-- clnbutton:SetText( ent:GetClass() )
						-- clnbutton:SetConsoleCommand("ups_clnstr", ent:GetClass())
					-- end
				
					-- ClassCleanupList:AddItem( clnbutton ) -- Add lines
				-- end
			-- end
		-- end
	-- end
	
	-- CategoryList:AddItem( ClassCleanupMenu, DermaPanel  ) -- Add the above item to our list
	
	-- local PlayerCleanupMenu = vgui.Create("DCollapsibleCategory")
	-- PlayerCleanupMenu:SetSize( 200, 50 ) -- Keep the second number at 50
	-- PlayerCleanupMenu:SetExpanded( 0 ) -- Expanded when popped up
	-- PlayerCleanupMenu:SetLabel( "Delete all of a player's props:" )
 
	-- PlayerCleanupList = vgui.Create( "DPanelList" )
	-- PlayerCleanupList:SetAutoSize( true )
	-- PlayerCleanupList:SetSpacing( 5 )
	-- PlayerCleanupList:EnableHorizontal( false )
	-- PlayerCleanupList:EnableVerticalScrollbar( true )
 
	-- PlayerCleanupMenu:SetContents( PlayerCleanupList, DermaPanel ) -- Add our list above us as the contents of the collapsible category
	
	-- for uid, nick in pairs( playerTable ) do
		-- local plybutton = vgui.Create( "DButton" )
		-- plybutton:SizeToContents()
		-- plybutton:SetText( nick )
		-- plybutton:SetConsoleCommand("ups_remove " .. uid)
	-- end
	
	-- PlayerCleanupList:AddItem( PlayerCleanupMenu, DermaPanel ) -- Add the above item to our list
	
----Except the stuff here :P----
	
	local delbutton = vgui.Create( "DButton", DermaPanel )
	delbutton:SizeToContents()
	delbutton:SetPos( locatex+250,340 )
	delbutton:SetSize( 150, 20 )
	delbutton:SetText( "Find Entities!" )
	delbutton.DoClick = function ()
	ULib.tsay(	LocalPlayer(), "There are " .. tostring( table.getn( EntTable ) ) .. " entities found on the map!" )
	end
	
	local helpbutton = vgui.Create( "DButton", DermaPanel )
	helpbutton:SizeToContents()
	helpbutton:SetPos( locatex,340 )
	helpbutton:SetSize( 150, 20 )
	helpbutton:SetText( "Console Commands" )
	helpbutton.DoClick = function()
		ULib.tsay(	LocalPlayer(), "The UPS console commands have been printed to console.")
		Msg("\n")
		Msg("---\n")
        Msg("The console commands are as follows!\n")
		Msg("---\n")
		Msg("ups_cl_cleartime # [Time until props are put up for grabs after player leaves]\n")
		Msg("---\n")
		Msg("ups_cl_deletetime # [Time until deletion after player leaves]\n")
		Msg("---\n")
		Msg("ups_cl_deleteadmin # [Delete admin props on leave]\n")
		Msg("---\n")
		Msg("ups_cl_affectadmins # [Admins affected by restrictions]\n")
		Msg("---\n")
		Msg("ups_cl_worldprotection # [Enable world protection]\n")
		Msg("---\n")
		Msg("ups_clnstr [Cleanup the entities selected by arguments]\n")
		Msg("---\n")
		Msg("\n")
		Msg("Bellow are the chat commands!\n")
		Msg("---\n")
		Msg("!nolag [Freeze all props on the server!]\n")
		Msg("---\n")
		Msg("!clnup [Cleanup the entities selected by arguments]\n")
		Msg("---\n")
		Msg("!clnup2 [Get the entity your looking at and clean every thing that has the same model.]\n")
		Msg("---\n")
		Msg("\n")
    end
	
end

concommand.Add( "ups_menu", upsMenuOpen )