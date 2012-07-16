/*------------
Infected Wars
init.lua
Clientside
------------*/
 
/*-----------------
	Make derma skin
-------------------*/
local SKIN = {}
	SKIN.bg_color 					= Color( 0,0,0,250 )

	SKIN.control_color 				= Color( 30, 30, 30, 255 ) 
	SKIN.control_color_highlight	= Color( 50, 50, 50, 255 ) 
	SKIN.control_color_active 		= Color( 50, 50, 120, 255 ) 
	SKIN.control_color_bright 		= Color( 150, 100, 50, 255 ) 
	SKIN.control_color_dark 		= Color( 30, 30, 30, 255 ) 
	
	function SKIN:DrawGenericBackground( x, y, w, h, color )
		
		surface.SetDrawColor( color )
		surface.DrawRect( x, y, w, h )
		
		surface.SetDrawColor( 50, 50, 50, 200 )
		surface.DrawOutlinedRect( x, y, w, h )
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( x+1, y+1, w-2, h-2 )

	end

	 function SKIN:PaintFrame( panel ) 
	   
	 	local color = self.bg_color  
		
	 	self:DrawGenericBackground( 0, 0, panel:GetWide(), panel:GetTall(), color ) 
	 	 
	 	surface.SetDrawColor( 50, 50, 50, 255 ) 
	 	surface.DrawRect( 1, 21, panel:GetWide()-2, 1 ) 
	   
	 end 
	 
	function SKIN:PaintTextEntry( panel ) 

		if ( panel.m_bBackground ) then 

			surface.SetDrawColor( 60, 60, 60, 240 ) 
			surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() ) 

		end 

		panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor ) 

		if ( panel.m_bBorder ) then 

			surface.SetDrawColor( 50, 50, 50, 255 ) 
			surface.DrawOutlinedRect( 0, 0, panel:GetWide(), panel:GetTall() ) 
			
			surface.SetDrawColor( 10, 10, 10, 200 ) 
			surface.DrawOutlinedRect( 1, 1, panel:GetWide()-2, panel:GetTall()-2 ) 
		end 


	end 
	 
	function SKIN:SchemeTextEntry( panel ) 

		panel:SetTextColor( Color( 200, 200, 200, 255 ) ) 
		panel:SetHighlightColor( Color( 20, 200, 250, 255 ) ) 
		panel:SetCursorColor( Color( 0, 0, 100, 255 ) ) 

	end
 
derma.DefineSkin( "iw_skin", "Infected Wars Derma Skin", SKIN )

local DESC_CLASS = 1
local DESC_WEAPON = 2

local startPanelOpen = false

local MENU_framewidth = 600
local MENU_subframeheigth = 400

local firstSpawn = false
local roundStart = true

function GM:InitializeMenuVars()
	CloseFrames()
	DESC_CLASS = 1
	DESC_WEAPON = 2
	startPanelOpen = false
	firstSpawn = false
	roundStart = true
end

/*---------- MUSIC ----------*/
CreateClientConVar("_iw_enablemusic", 1, true, false)
MUSIC_ENABLED = util.tobool(GetConVarNumber("_iw_enablemusic"))
function ToggleMusic( pl,commandName,args )
	local MySelf = LocalPlayer()
	MUSIC_ENABLED = util.tobool(args[1])
	if MUSIC_ENABLED then 
		RunConsoleCommand("_iw_enablemusic","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Music on")
	else 
		RunConsoleCommand("_iw_enablemusic","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Music off")
	end
end
concommand.Add("iw_enablemusic",ToggleMusic) 

Options = {}
Options[1] = { Value = PP_ON, Desc = "Toggle all screeneffects", Cmd = "iw_enablepp" }
Options[2] = { Value = PP_COLOR, Desc = "^ Toggle colormod", Cmd = "iw_enablecolormod" }
Options[3] = { Value = PP_MOTIONBLUR, Desc = "^ Toggle motionblur", Cmd = "iw_enablemotionblur" }
Options[4] = { Value = PP_BLOOM, Desc = "^ Toggle bloom", Cmd = "iw_enablebloom" }
Options[5] = { Value = PP_SHARPEN, Desc = "^ Toggle sharpen", Cmd = "iw_enablesharpen" }
Options[6] = { Value = HUD_ON, Desc = "Toggle HUD", Cmd = "iw_enablehud" }
Options[7] = { Value = EFFECT_MUZZLE, Desc = "Toggle additional muzzle effect", Cmd = "iw_enablemuzzlefx" }
Options[8] = { Value = EFFECT_SHELL, Desc = "Toggle shell ejection effect", Cmd = "iw_enableshellfx" }
Options[9] = { Value = EFFECT_UBERGORE, Desc = "Toggle gore", Cmd = "iw_enablegore" }
Options[10] = { Value = MUSIC_ENABLED, Desc = "Toggle game music", Cmd = "iw_enablemusic" }

function amountOfPlayerInClass( class, team )
	local count = 0
	for k, v in pairs(player.GetAll()) do
		if v:GetPlayerClass() == class and v:Team() == team then
			count = count+1
		end
	end
	return count
end

/*-----------------------------------------------
	Translate weapon names (for descriptions)
------------------------------------------------*/
	
/*-----------------------------
	CREATE MAIN FRAME PANEL
-------------------------------*/
function createMainFrame()
	
	frame = vgui.Create("DFrame")
	frame:SetPos(w/2-MENU_framewidth/2,h/2-(MENU_subframeheigth)/2-45) 
	frame:SetSize(MENU_framewidth, 90) 
    frame:SetTitle( "Infected Wars" ) 
    frame:SetVisible( true ) 
	frame:SetSizable(false)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
    frame:MakePopup() 

	-- Create close button
	local buttonClose = vgui.Create("DButton",frame)
	buttonClose:SetText( "CLOSE MENU")
	buttonClose:SetPos(5,60)
	buttonClose:SetSize(MENU_framewidth-10,25)
	buttonClose.DoClick = function( ) 
		if subframe and subframe:IsValid() then
			subframe:Close()
		end
		if frame and frame:IsValid() then
			frame:Close()
		end
	end	

	-- Create help button
	local buttonHelp = vgui.Create("DButton",frame)
	buttonHelp:SetText( "Help")
	buttonHelp:SetPos(6,30)
	buttonHelp:SetSize(60,20)
	buttonHelp.DoClick = function( btn) RunConsoleCommand("iw_menu_help") end
	
	-- Create class button
	local buttonClass = vgui.Create("DButton",frame)
	buttonClass:SetText( "Classes")
	buttonClass:SetPos(72,30)
	buttonClass:SetSize(60,20)
	buttonClass.DoClick = function( btn ) RunConsoleCommand("iw_menu_class") end
	
	-- Create options button
	local buttonOptions = vgui.Create("DButton",frame)
	buttonOptions:SetPos(138,30)
	buttonOptions:SetSize(60,20)
	buttonOptions:SetText( "Options")
	buttonOptions.DoClick = function( btn ) RunConsoleCommand("iw_menu_options") end
	
	-- Create achievements button
	local buttonAchiev = vgui.Create("DButton",frame)
	buttonAchiev:SetText( "Score")
	buttonAchiev:SetPos(204,30)
	buttonAchiev:SetSize(60,20)
	buttonAchiev.DoClick = function( btn ) RunConsoleCommand("iw_menu_score") end
	
	-- Create about button
	local buttonAbout = vgui.Create("DButton",frame)
	buttonAbout:SetText( "About")
	buttonAbout:SetPos(270,30)
	buttonAbout:SetSize(60,20)
	buttonAbout.DoClick = function( btn ) RunConsoleCommand("iw_menu_about") end

	-- Create shop button
	local buttonShop = vgui.Create("DButton",frame)
	buttonShop:SetText( "Shop")
	buttonShop:SetPos(336,30)
	buttonShop:SetSize(60,20)
	buttonShop.DoClick = function( btn ) RunConsoleCommand("iw_menu_shop") end
	
	if (PlayerIsAdmin == true and ADMIN_ADDON) then
		local buttonAdmin = vgui.Create("DButton",frame)
		buttonAdmin:SetPos(402,30)
		buttonAdmin:SetSize(60,20)
		buttonAdmin:SetText( "Admin")
		buttonAdmin.DoClick = function( btn ) RunConsoleCommand("iw_menu_admin") end
	end
	
	-- Make sure the maplist has arrived for the admin panel
	if #MapList == 0 and PlayerIsAdmin then 
		RunConsoleCommand("get_maplist")
	end
	
end

function createSubFrame()
	subframe = vgui.Create("DFrame")
	subframe:SetPos(w/2-MENU_framewidth/2,h/2-(MENU_subframeheigth)/2+50) 
	subframe:SetSize(MENU_framewidth, MENU_subframeheigth) 
    subframe:SetTitle( "Empty frame. Go fix your code! :D" ) 
    subframe:SetVisible( true ) 
	subframe:SetSizable(false)
	subframe:SetDraggable(false)
	subframe:ShowCloseButton(false)
    subframe:MakePopup() 
end

/*-----------------------------
	CREATE HELP PANEL
-------------------------------*/
function createHelpPanel()
	subframe:SetTitle( "Help menu" )
	local descbox = vgui.Create("DTextEntry",subframe)
	descbox:SetPos( 5, 30 ) 
    descbox:SetSize( MENU_framewidth-110, MENU_subframeheigth-35 ) 
	descbox:SetEditable( false )
	descbox:SetValue(HELP_TEXT[1].Text)
	descbox:SetMultiline( true )
	
	local button = {}
	for k = 1, #HELP_TEXT do
		-- Create text-switch buttons
		button[k]= vgui.Create("DButton",subframe)
		button[k]:SetText( HELP_TEXT[k].Button )
		button[k]:SetPos(MENU_framewidth-100,5+(25*k))
		button[k]:SetSize(90,20)
		button[k].DoClick = function( btn ) 
			descbox:SetValue(HELP_TEXT[k].Text)
		end
	end
end 

/*-----------------------------
	CREATE ABOUT PANEL
-------------------------------*/
function createAboutPanel()
	subframe:SetTitle( "Dev info and special thanks" )
	local descbox = vgui.Create("DTextEntry",subframe)
	descbox:SetPos( 5, 30 ) 
    descbox:SetSize( MENU_framewidth-10, MENU_subframeheigth-35 ) 
	descbox:SetEditable( false )
	descbox:SetValue(ABOUT_TEXT)
	descbox:SetMultiline( true )
end 

/*-----------------------------
	CREATE SCORE PANEL
-------------------------------*/
function createScorePanel()
	subframe:SetTitle( "Achievements and score" )
	
	-- create player list
	local playerlist = vgui.Create("DComboBox",subframe) 
    playerlist:SetPos( 5, 60 ) 
    playerlist:SetSize( 150, MENU_subframeheigth-65 ) 	
	-- update player list button
	local buttonUpdate = vgui.Create("DButton",subframe)
	buttonUpdate:SetText( "Update Player List")
	buttonUpdate:SetPos(5,30)
	buttonUpdate:SetSize(150,25)
	
	-- Top label
	local toplabel = vgui.Create("DLabel",subframe)
	toplabel:SetText( "Select a player" )
	toplabel:SetPos( 170, 30 ) 
    toplabel:SetSize( MENU_framewidth-180, 25 ) 
	
	-- List view
	local list = vgui.Create("DListView",subframe)
	list:SetPos(160,60)
	list:SetSize(MENU_framewidth-165,MENU_subframeheigth-170)
	
	list.SortByColumn = function() end
	
	local c0 = list:AddColumn( "Score/Achievement" ) 
	local c1 = list:AddColumn( "Progress" ) 

	c0:SetMinWidth( math.floor((MENU_framewidth-165)/2+10) )
	c0:SetMaxWidth( math.floor((MENU_framewidth-165)/2+10) )
	c1:SetMinWidth( math.floor((MENU_framewidth-165)/2-10) )
	c1:SetMaxWidth( math.floor((MENU_framewidth-165)/2-10) )
	
	-- image
	local achvimage = vgui.Create("DImage", subframe)
	achvimage:SetPos(160,MENU_subframeheigth-105)
	achvimage:SetSize(100,100)
	achvimage:SetImage( "infectedwars/achv_blank" )
	achvimage:SetImageColor( Color(255,255,255,255) )
	
	-- description box
	local reasonbox = vgui.Create("DTextEntry",subframe)
	reasonbox:SetPos( 265, MENU_subframeheigth-105 ) 
    reasonbox:SetSize( MENU_framewidth-270, 50 ) 
	reasonbox:SetEditable( false )
	reasonbox:SetMultiline( true )
	reasonbox:SetValue("<< Select something to view the description! >>")
	
	-- unlockinfo box
	local unlockbox = vgui.Create("DTextEntry",subframe)
	unlockbox:SetPos( 265, MENU_subframeheigth-55 ) 
    unlockbox:SetSize( MENU_framewidth-270, 50 ) 
	unlockbox:SetEditable( false )
	unlockbox:SetMultiline( true )
	unlockbox:SetValue("")
	
	/*-------------------------------
				Functions
	-------------------------------*/
		
	function updatePlayerList()
		playerlist:Clear()
		for k, v in pairs(player.GetAll()) do
			v.Item = playerlist:AddItem( v:Name() )
		end	
		updateDoClicks()
		if LocalPlayer().Item then
			LocalPlayer().Item:Select() -- Calls DoClick
			playerlist:SelectItem(LocalPlayer().Item)
		end
	end
	
	function updateScorelist( pl )

		list:Clear()	

		toplabel:SetText( "Fetching stats of player "..pl:Name().."..." )
		if not pl.DataTable then return end
		toplabel:SetText( "Stats of player "..pl:Name().." ("..pl:Title()..") " )
		
		list:AddLine( "--------------- SCORE ------------------------------- ","-------------------------------------------" )
		
		local id
		for k, v in pairs( recordData ) do
			local str = tostring(pl.DataTable[k])
			local secs, mins, hours
			if k == "timeplayed" then
				secs = tonumber(str)
				mins = (secs-(secs%60))/60
				hours = (secs-(secs%(3600)))/3600
				mins = mins-(hours*60)
				str = tostring(hours).." hours, "..tostring(mins).." minutes"
			end
			if k == "progress" then
				str = str.."%"
			end
			id = list:AddLine( v.Name, str )
			id.Image = v.Image
			id.Desc = v.Desc
			id.UnlockInfo = ""
		end	

		list:AddLine( "--------------- UNLOCKABLES ---------------------- ","-------------------------------------------" )
		
		for k, v in ipairs( unlockTable ) do
			local str
			local unl = true
			for i, j in pairs( unlockData[v.UnlockCode] ) do
				if not pl.DataTable["achievements"][j] then
					unl = false
				end
			end
			if unl then
				str = "<< UNLOCKED >>"
			else
				str = "LOCKED"
			end
			
			id = list:AddLine( v.Name, str )
			id.Image = "infectedwars/achv_blank"
			id.Desc = v.LoadoutInfo
			id.UnlockInfo = v.UnlockInfo
		end
		
		list:AddLine( "--------------- ACHIEVEMENTS -------------------- ","-------------------------------------------" )
		
		for k, v in ipairs( achievementSorted ) do
			local str
			if pl.DataTable["achievements"][v] == true then
				str = "<< ACHIEVED! >>"
			else
				str = "Unattained"
			end
			id = list:AddLine( achievementDesc[v].Name, str )
			id.Image = achievementDesc[v].Image
			id.Desc = achievementDesc[v].Desc
			id.UnlockInfo = achievementDesc[v].UnlockInfo
		end
	end
	
	/*--------------------------------
		DoClick functions and others
	--------------------------------*/
	
	function updateDoClicks()
		for k, pl in pairs(player.GetAll()) do
			if (pl.Item) then
				pl.Item.DoClick = function( btn )
					-- It's getting quite messy around here...
					pl.StatsReceived = false
					updateScorelist( pl )
					RunConsoleCommand("get_playerstats",pl:UserID())
					-- Update score list with delay so server can send data
					timer.Create(pl:UserID().."statreceive",0.5,0,function( ply, dalist ) 
						if dalist:IsValid() then
							if ply:IsValid() and ply.StatsReceived then
								updateScorelist(ply)
								timer.Destroy(ply:UserID().."statreceive")
							end
						else
							timer.Destroy(ply:UserID().."statreceive")
						end
					end,pl,list)
				end
			end
		end
	end
	
	list.OnRowSelected = function(lineID,line) 
		local theline = list:GetSelected()[1] -- those fucking function arguments do not contain the real line entity
		if (theline.Image and theline.Desc) then
			reasonbox:SetValue(theline.Desc)
			unlockbox:SetValue(theline.UnlockInfo)
			achvimage:SetImage(theline.Image)
		else
			reasonbox:SetValue("<< Select something to view the description! >>")
			achvimage:SetImage("infectedwars/achv_blank")
		end
	end
		
	buttonUpdate.DoClick = function( btn ) 
		updatePlayerList()
	end -- update playerlist	
	
	updatePlayerList()
end 

/*-----------------------------
	CREATE OPTIONS PANEL
-------------------------------*/
function createOptionsPanel()
	subframe:SetTitle( "Options and settings" )
	
	local selectedSong = CurPlaying
	
	-- 'Radio' label
	local radlabel = vgui.Create("DLabel",subframe)
	radlabel:SetText( "Radio" )
	radlabel:SetPos( 5, 30 ) 
    radlabel:SetSize( 100, 25 ) 
	
	-- List with available songs
	local songlist = vgui.Create("DMultiChoice",subframe)
	songlist:SetPos( 5, 50 ) 
    songlist:SetSize( 80, 20 ) 
	songlist:SetEditable( false )
	songlist:Clear()	
	local list = {} 
	for k = 1, #Radio do
		list[k] = songlist:AddChoice("Song "..k)
	end
	songlist:ChooseOption("Song "..selectedSong)
	songlist.OnSelect = function( index, value, data )
		for k = 1, #list do
			-- find what choice was selected
			if (value == list[k]) then
				selectedSong = k
			end
		end
	end
	
	-- Create play song button
	local buttonPlay = vgui.Create("DButton",subframe)
	buttonPlay:SetText( "Play song")
	buttonPlay:SetPos(90,50)
	buttonPlay:SetSize(70,20)
	buttonPlay.DoClick = function( btn ) 
		RunConsoleCommand("iw_enableradio","1",tostring(selectedSong))
	end
	
	-- Create stop radio button
	local buttonStop = vgui.Create("DButton",subframe)
	buttonStop:SetText( "Stop radio")
	buttonStop:SetPos(165,50)
	buttonStop:SetSize(70,20)
	buttonStop.DoClick = function( btn ) 
		RunConsoleCommand("iw_enableradio","0")
	end	

	-- Update option values
	Options[1].Value = PP_ON
	Options[2].Value = PP_COLOR
	Options[3].Value = PP_MOTIONBLUR
	Options[4].Value = PP_BLOOM
	Options[5].Value = PP_SHARPEN
	Options[6].Value = HUD_ON
	Options[7].Value = EFFECT_MUZZLE
	Options[8].Value = EFFECT_SHELL
	Options[9].Value = EFFECT_UBERGORE

	local boxY = 75
	for k, v in pairs(Options) do
		-- Create checkboxes
		local box = vgui.Create("DCheckBox",subframe)
		box:SetValue( v.Value )
		box:SetPos(5,boxY+2)
		box:SetSize(15,15)
		box.DoClick = function( btn ) 
			-- Update value in case player used console to switch
			v.Value = util.tobool((GetConVarNumber( "_"..v.Cmd ))) or v.Value
			if (v.Value == box:GetChecked()) then
				box:Toggle()
			end
			if (v.Value ~= box:GetChecked()) then
				v.Value = box:GetChecked()
				RunConsoleCommand(v.Cmd,tostring(box:GetChecked()))
			end
		end
		
		-- Create Labels
		local lab = vgui.Create("DLabel",subframe)
		lab:SetText( v.Desc )
		lab:SetPos(22,boxY+1)
		lab:SetSize(0,20)
		lab:SizeToContents()
		
		boxY = boxY + 20
	end
	
	-- 'Crosshair' label
	local crlabel = vgui.Create("DLabel",subframe)
	crlabel:SetText( "Crosshair" )
	crlabel:SetPos( MENU_framewidth - 105, 30 ) 
    crlabel:SetSize( 100, 25 ) 
	-- Crosshair stuff
	local crosslist = vgui.Create("DMultiChoice",subframe)
	crosslist:SetPos( MENU_framewidth - 105, 50 ) 
    crosslist:SetSize( 100, 20 ) 
	crosslist:SetEditable( false )
	crosslist:Clear()	
	local clist = {}
	for k, v in ipairs(CROSSHAIR) do
		clist[k] = crosslist:AddChoice("Crosshair "..k)
	end
	crosslist:ChooseOption("Crosshair "..CurCrosshair)

	-- 'Color' label
	local cllabel = vgui.Create("DLabel",subframe)
	cllabel:SetText( "Color" )
	cllabel:SetPos( MENU_framewidth - 105, 80 ) 
    cllabel:SetSize( 100, 25 ) 
	
	-- Color list
	local collist = vgui.Create("DMultiChoice",subframe)
	collist:SetPos( MENU_framewidth - 105, 100 ) 
    collist:SetSize( 100, 20 ) 
	collist:SetEditable( false )
	collist:Clear()	
	for k, v in pairs(CROSSHAIRCOLORS) do
		collist:AddChoice(k)
	end
	collist:ChooseOption(CurCrosshairColor)

	local cross = vgui.Create("DImage", subframe)
	cross:SetPos(MENU_framewidth - 180,45)
	cross:SetSize(64,64)
	cross:SetImage( CROSSHAIR[CurCrosshair] )
	cross:SetImageColor( CROSSHAIRCOLORS[CurCrosshairColor] )
	cross:SizeToContents()
	
	local alphaSlider = vgui.Create( "DNumSlider", subframe )
	alphaSlider:SetPos( MENU_framewidth - 180,140 )
	alphaSlider:SetSize( 175, 100 ) // Keep the second number at 100
	alphaSlider:SetText( "Alpha channel" )
	alphaSlider:SetMin( 0 )
	alphaSlider:SetMax( 255 )
	alphaSlider:SetDecimals( 0 )
	alphaSlider:SetConVar( "_iw_crosshairalpha" ) // Set the convar 

	-- 'Turret nickname' label
	local tnlabel = vgui.Create("DLabel",subframe)
	tnlabel:SetText( "Turret nickname" )
	tnlabel:SetPos( MENU_framewidth - 180, 194 ) 
    tnlabel:SetSize( 100, 25 ) 
	
	-- Turret nickname text entry
	local turretnickbox = vgui.Create("DTextEntry",subframe)
	turretnickbox:SetPos( MENU_framewidth - 180, 220 ) 
    turretnickbox:SetSize( 100, 20 ) 
	turretnickbox:SetEditable( true )
	turretnickbox:SetMultiline( false )
	turretnickbox:SetValue(TurretNickname or "")
	
	-- Turret nickname set box
	local buttonSetTurNick = vgui.Create("DButton",subframe)
	buttonSetTurNick:SetText( "Submit")
	buttonSetTurNick:SetPos( MENU_framewidth - 70, 220 )
	buttonSetTurNick:SetSize(50,20)
	buttonSetTurNick.DoClick = function( btn ) 
		RunConsoleCommand("iw_turretnickname",turretnickbox:GetValue())
	end	
	
	if (MySelf:HasBought("titleeditor")) then
		local titleeditlabel = vgui.Create("DLabel",subframe)
		titleeditlabel:SetText( "Title Editor" )
		titleeditlabel:SetPos( MENU_framewidth - 180, 260 )
		titleeditlabel:SetSize( 100, 25 )

		local titlefield = vgui.Create("DTextEntry",subframe)
		titlefield:SetText( MySelf:Title() )
		titlefield:SetPos( MENU_framewidth - 180, 286 ) 
		titlefield:SetSize( 100, 20 )
		titlefield:SetEditable( true )
		titlefield:SetMultiline( false )
		
		local submitbutton = vgui.Create("DButton", subframe)
		submitbutton:SetPos(MENU_framewidth - 70, 286)
		submitbutton:SetSize(50, 20)
		submitbutton:SetText("Submit")
		submitbutton.DoClick = function(btn) 
			// ValidTitle can be found in shared.lua
			if ValidTitle(MySelf, titlefield:GetValue()) then
				RunConsoleCommand("iw_settitle",titlefield:GetValue())
				titlefield:SetText("< updating... >")
				titlefield:SetEditable( false )
				timer.Simple(0.5,function()
					if titlefield then
						titlefield:SetText(MySelf:Title())
						titlefield:SetEditable( true )
					end
				end)
			else
				titlefield:SetText("< INVALID TITLE >")
				titlefield:SetEditable( false )
				timer.Simple(1,function()
					if titlefield then
						titlefield:SetText(MySelf:Title())
						titlefield:SetEditable( true )
					end
				end)
			end
		end
		
		local infolabel = vgui.Create("DLabel",subframe)
		infolabel:SetText( "Max title length is 24 characters. \nSome characters and words are\ndisallowed." )
		infolabel:SetPos( MENU_framewidth - 180, 305 )
		infolabel:SetSize( 160, 60 )
	end
		
	/*-------- Functions ------------*/
	local function UpdateCrosshair()
		cross:SetImage( CROSSHAIR[CurCrosshair] )
		local colc = CROSSHAIRCOLORS[CurCrosshairColor]
		local alph = GetConVarNumber("_iw_crosshairalpha")
		cross:SetImageColor( Color(colc.r, colc.g, colc.b, alph) )
		RunConsoleCommand("_iw_crosshair",CurCrosshair)
		RunConsoleCommand("_iw_crosshaircolor",CurCrosshairColor)
	end
	
	/*---------- Select functions -----------*/
	alphaSlider.OnValueChanged = function( val ) 
		UpdateCrosshair()
	end

	collist.OnSelect = function( index, value, data )
		CurCrosshairColor = collist:GetOptionText(value)
		UpdateCrosshair()
	end	
	
	crosslist.OnSelect = function( index, value, data )
		for k = 1, #clist do
			-- find what choice was selected
			if (value == clist[k]) then
				CurCrosshair = k
				UpdateCrosshair()
			end
		end
	end
	
end 

/*-----------------------------
	CREATE SHOP PANEL
-------------------------------*/
function createShopPanel()
	subframe:SetTitle( "Green-Coins shop!" )

	local curItemSelected = ""
	
	local shoplabel = vgui.Create("DLabel",subframe)
	shoplabel:SetText( [[HOW TO GET GREEN-COINS:
	
	- Kill an undead (as human): 1 GC
	- Every 30 health you heal (as human): 1 GC
	- Kill a human (as undead): 3 GC
	
	]] )
	shoplabel:SetPos( 350, 150 ) 
	shoplabel:SetSize( 240, 200 )
	
	// SHOP
	
	local itemlistlabel = vgui.Create("DLabel",subframe)
	itemlistlabel:SetText( "Shop Items" )
	itemlistlabel:SetPos( 16, 30 ) 
	itemlistlabel:SetSize( 180, 25 )
		
	local itemlist = vgui.Create("DComboBox",subframe) 
	itemlist:SetPos( 16, 60 ) 
	itemlist:SetSize( 180, 320 )

	local itemnamelabel = vgui.Create("DLabel",subframe)
	itemnamelabel:SetText( "ITEM:" )
	itemnamelabel:SetPos( 220, 60 ) 
	itemnamelabel:SetSize( 180, 22 )
	
	local itemcostlabel = vgui.Create("DLabel",subframe)
	itemcostlabel:SetText( "COST:" )
	itemcostlabel:SetPos( 220, 80 ) 
	itemcostlabel:SetSize( 180, 22 )
	
	local itemreqlabel = vgui.Create("DLabel",subframe)
	itemreqlabel:SetText( "REQUIRES:" )
	itemreqlabel:SetPos( 220, 100 ) 
	itemreqlabel:SetSize( 180, 22 )
	
	local itemdesclabel = vgui.Create("DLabel",subframe)
	itemdesclabel:SetText( "DESCRIPTION:" )
	itemdesclabel:SetPos( 220, 120 ) 
	itemdesclabel:SetSize( 180, 22 )
	
	local itemdescfield = vgui.Create("DTextEntry",subframe)
	itemdescfield:SetText( "< none >" )
	itemdescfield:SetPos( 220, 140 ) 
	itemdescfield:SetSize( 360, 50 )
	itemdescfield:SetEditable( false )
	itemdescfield:SetMultiline( true )
	
	local buybutton = vgui.Create("DButton", subframe)
	buybutton:SetPos(400, 70)
	buybutton:SetSize(180, 50)
	buybutton:SetText("")
	buybutton.DoClick = function(btn) 
		if curItemSelected == "" then return end
		RunConsoleCommand("iw_buyitem",curItemSelected)
		timer.Simple(0.7,function()
			updateItemList()
		end)
	end
	
	--[[-------------------------------
				Functions
	-------------------------------]]
	
	function updateItemList()
		itemlist:Clear()
		local item
		local item_sorted = {}
		
		for k, v in pairs(shopData) do
			if not shopData[k].AdminOnly or PlayerIsAdmin then
				if MySelf.DataTable["shopitems"][k] then
					table.insert(item_sorted, { key = k, postfix = " (BOUGHT)", name = v.Name })
				else
					table.insert(item_sorted, { key = k, postfix = "", name = v.Name })
				end
			end
		end
		
		// can't sort associative tables, had to hack my way around it.
		table.sort(item_sorted, function(a, b) return a.name < b.name end)
		for k, v in pairs(item_sorted) do
			item = itemlist:AddItem( v.name..v.postfix )
			item.ItemType = v.key
			item.DoClick = itemDoClick
			shopData[v.key].Item = item
		end
		
		-- Select a item if not already selected
		if not shopData[curItemSelected] then
			shopData["ammostash1"].Item:Select() -- Calls DoClick
			itemlist:SelectItem(shopData["ammostash1"].Item)
		else
			shopData[curItemSelected].Item:Select() -- Calls DoClick
			itemlist:SelectItem(shopData[curItemSelected].Item)	
		end
		
		
	end
	
	--[[--------------------------------
		DoClick functions and others
	--------------------------------]]
	
	function itemDoClick(btn)
		local item = btn.ItemType
		
		curItemSelected = item
		if (shopData[item].Cost == -1) then
			itemcostlabel:SetText("COST: -")
		else
			itemcostlabel:SetText("COST: $$$ "..shopData[item].Cost)
		end
		itemnamelabel:SetText("ITEM: "..shopData[item].Name)
		if shopData[item].Requires then
			itemreqlabel:SetText( "REQUIRES: "..shopData[shopData[item].Requires].Name )
		else
			itemreqlabel:SetText( "REQUIRES: n/a" )
		end
		itemdescfield:SetText(shopData[item].Desc)
		
		if (MySelf.DataTable["shopitems"][item]) then
			buybutton:SetDisabled(true)
			buybutton:SetText("You got this already!")
		elseif (shopData[item].Requires != nil and not MySelf:HasBought(shopData[item].Requires)) then
			buybutton:SetDisabled(true)
			buybutton:SetText("You do not have the required item!")
		elseif (MySelf:Money() < shopData[item].Cost) then
			buybutton:SetDisabled(true) -- disable button if you can't buy it
			buybutton:SetText("You're too poor")
		else
			buybutton:SetDisabled(false)
			buybutton:SetText("BUY THAT SHIT")
		end
		
	end
	
	updateItemList()
end 

/*-----------------------------
	CREATE ADMIN PANEL
-------------------------------*/
function createAdminPanel()
	if !(PlayerIsAdmin) then
		subframe:SetTitle( "Admin suite (RESTRICTED)" )
	else
	
	-- frame settings
	subframe:SetTitle( "Admin suite (welcome "..LocalPlayer():Name().."!)" )
	
	-- create player list
	local playerlist = vgui.Create("DComboBox",subframe) 
    playerlist:SetPos( 6, 50 ) 
    playerlist:SetSize( 120, MENU_subframeheigth-60 ) 	
	-- update player list button
	local buttonUpdate = vgui.Create("DButton",subframe)
	buttonUpdate:SetText( "Update Player List")
	buttonUpdate:SetPos(6,28)
	buttonUpdate:SetSize(120,20)
	
	-- create map list
	local maplist = vgui.Create("DComboBox",subframe) 
    maplist:SetPos( 130, 170 ) 
    maplist:SetSize( 140, MENU_subframeheigth-180 ) 	
	-- change map button
	local buttonMapChange = vgui.Create("DButton",subframe)
	buttonMapChange:SetText( "Change map")
	buttonMapChange:SetPos(275,170)
	buttonMapChange:SetSize(70,20)
	
	-- kick button
	local buttonKick = vgui.Create("DButton",subframe)
	buttonKick:SetText( "Kick")
	buttonKick:SetPos(130,50)
	buttonKick:SetSize(65,20)	
	-- 'Kick reason' label
	local lolabel = vgui.Create("DLabel",subframe)
	lolabel:SetText( "Kick reason" )
	lolabel:SetPos( 200, 30 ) 
    lolabel:SetSize( 130, 25 ) 
	-- kick reason textbox
	local reasonbox = vgui.Create("DTextEntry",subframe)
	reasonbox:SetPos( 200, 50 ) 
    reasonbox:SetSize( 275, 20 ) 
	reasonbox:SetEditable( true )
	reasonbox:SetValue("Retard")
	
	/*------------ ADMIN BUTTONS --------------*/

	-- ban 5 minutes button
	local buttonBanFive = vgui.Create("DButton",subframe)
	buttonBanFive :SetText( "Ban 5 min")
	buttonBanFive :SetPos(130,75)
	buttonBanFive :SetSize(65,25)
	-- ban 60 minutes button
	local buttonBanSixty = vgui.Create("DButton",subframe)
	buttonBanSixty :SetText( "Ban 1 hour")
	buttonBanSixty :SetPos(200,75)
	buttonBanSixty :SetSize(65,25)	
	-- ban one day button
	local buttonBanDay = vgui.Create("DButton",subframe)
	buttonBanDay :SetText( "Ban 1 day")
	buttonBanDay :SetPos(270,75)
	buttonBanDay :SetSize(65,25)
	-- ban one week button
	local buttonBanWeek = vgui.Create("DButton",subframe)
	buttonBanWeek :SetText( "Ban 1 week")
	buttonBanWeek :SetPos(340,75)
	buttonBanWeek :SetSize(65,25)
	-- ban permanent button
	local buttonBanPerma = vgui.Create("DButton",subframe)
	buttonBanPerma :SetText( "Permaban")
	buttonBanPerma :SetPos(410,75)
	buttonBanPerma :SetSize(65,25)
	
	-- slay player
	local buttonSlay = vgui.Create("DButton",subframe)
	buttonSlay :SetText( "Slay")
	buttonSlay :SetPos(130,105)
	buttonSlay :SetSize(65,25)
	-- bring player
	local buttonBring = vgui.Create("DButton",subframe)
	buttonBring :SetText( "Bring")
	buttonBring :SetPos(200,105)
	buttonBring :SetSize(65,25)
	-- goto player
	local buttonGoto = vgui.Create("DButton",subframe)
	buttonGoto :SetText( "Goto")
	buttonGoto :SetPos(270,105)
	buttonGoto :SetSize(65,25)
	
	
	/*-------------------------
	TODO:
	- Slay
	- Ignite / Unignite
	- Health+, Ammo+
	- Execute console command on other persons console
	--------------------------*/
	
	
	/*------------------------
		ADMIN FUNCTIONS 
	-------------------------*/
	function getSelectedPlayer()
		local playerName = playerlist:GetSelected()
		if playerName and playerName:IsValid() then
			for k, v in pairs(player.GetAll()) do
				if (v:Name() == playerName:GetValue()) then
					if (v:IsValid()) then
						return v
					end
				end
			end
		end
		return nil
	end	
	
	function getSelectedMap()
		local mapName = maplist:GetSelected()
		if (mapName ~= nil) then
			return mapName:GetValue()
		else
			return ""
		end
	end	
	
	local function banSelectedPlayer( banTime )
		local pl = getSelectedPlayer()
		if (pl ~= nil) then
			RunConsoleCommand( "ban_player", ""..banTime, pl:UserID() )
			if (banTime == 0) then
				RunConsoleCommand( "kick_player", pl:UserID(), "Permanent ban." )
			else
				RunConsoleCommand( "kick_player", pl:UserID(), "Banned for "..banTime.." minutes." )
			end
		end
	end
	
	local function kickSelectedPlayer( reason )
		local pl = getSelectedPlayer()
		if (pl ~= nil) then
			RunConsoleCommand( "kick_player", pl:UserID(), reason )
		end
	end
	
	local function updatePlayerList()
		playerlist:Clear()
		for k, v in pairs(player.GetAll()) do
			playerlist:AddItem( v:Name() )
		end	
	end
	
	
	local function updateMapList()
		table.sort(MapList)
		maplist:Clear()
		for k, v in pairs(MapList) do
			maplist:AddItem( v )
		end	
	end
	
	/*--------------------------------
		DoClick functions and others
	--------------------------------*/
	
	buttonUpdate.DoClick = function( btn ) 
		updatePlayerList()
	end -- update playerlist	

	buttonKick.DoClick = function( btn ) 
		kickSelectedPlayer(reasonbox:GetValue())
	end -- kick selected player

	buttonBanWeek.DoClick = function( btn ) 
		banSelectedPlayer(60*24*7)
	end -- ban selected player for 1 week
	
	buttonBanDay.DoClick = function( btn ) 
		banSelectedPlayer(60*24)
	end -- ban selected player for 1 day

	buttonBanSixty.DoClick = function( btn ) 
		banSelectedPlayer(60)
	end -- ban selected player for 60 minutes

	buttonBanFive.DoClick = function( btn ) 
		banSelectedPlayer(5)
	end -- ban selected player for 5 minutes
	
	buttonBanPerma.DoClick = function( btn ) 
		banSelectedPlayer(0)
	end -- permanently ban selected player

	buttonSlay.DoClick = function( btn )
		local pl = getSelectedPlayer()
		if (pl ~= nil) then
			RunConsoleCommand("slay_player",pl:Name())
		end
	end -- slay player
	buttonBring.DoClick = function( btn )
		local pl = getSelectedPlayer()
		if (pl ~= nil) then
			RunConsoleCommand("bring_player",pl:Name())
		end
	end -- bring player
	buttonGoto.DoClick = function( btn )
		local pl = getSelectedPlayer()
		if (pl ~= nil) then
			RunConsoleCommand("goto_player",pl:Name())
		end
	end -- goto player
	
	buttonMapChange.DoClick = function( btn )
		 RunConsoleCommand("change_map",""..getSelectedMap())
	end -- change map
			
	updatePlayerList() -- update list at start of frame	
	updateMapList()
	
	end
end 

/*--------------------------------------
	CREATE CLASS PANEL
---------------------------------------*/

function createClassPanel( start, team )
	
	local numLoadouts = 0
	local class = {}
	local load = {}
	local currentSelectedLoad = 1
	
	-- On start, create a slightly different frame than the normal one
	if start then
		
		frame = vgui.Create("DFrame")
		frame:SetTitle( "Welcome to this Infected Wars server!" )
		frame:SetPos(w/2-(MENU_framewidth)/2,h/2-MENU_subframeheigth/2-55) 
		frame:SetSize(MENU_framewidth, 150) 
	    frame:SetVisible( true ) 
		frame:SetSizable(false)
		frame:SetDraggable(false)
		frame:ShowCloseButton(false)
	    frame:MakePopup() 
		local welcomebox = vgui.Create("DTextEntry",frame)
		welcomebox:SetPos( 5, 25 ) 
		welcomebox:SetSize( MENU_framewidth-10, 120 ) 
		welcomebox:SetEditable( false )
		welcomebox:SetValue(WELCOME_TEXT)
		welcomebox:SetMultiline( true )
	
		subframe = vgui.Create("DFrame")
		subframe:SetPos(w/2-MENU_framewidth/2,h/2-MENU_subframeheigth/2+100) 
		subframe:SetSize(MENU_framewidth, MENU_subframeheigth) 
		if (team == TEAM_HUMAN) then
			subframe:SetTitle( "You joined the Special Forces - Choose your class!" ) 
		else
			subframe:SetTitle( "You joined the Undead Legion - Choose your class!" ) 
		end
	    subframe:SetVisible( true ) 
		subframe:SetSizable(false)
		subframe:SetDraggable(false)
		subframe:ShowCloseButton(false)
	    subframe:MakePopup() 
	else
	-- Else, just use the normal one (subframe has already been made with the createSubFrame function)
		if (team == TEAM_HUMAN) then
			subframe:SetTitle( "Human class menu" ) 
		else
			subframe:SetTitle( "Undead class menu" ) 
		end		
	end
	
	-- 'Class' label
	local cllabel = vgui.Create("DLabel",subframe)
	cllabel:SetText( "Select class" )
	cllabel:SetPos( 5, 30 ) 
	cllabel:SetSize( 60, 25 ) 
	-- List of choosable classes
	local classlist = vgui.Create("DComboBox",subframe) 
	classlist:SetPos( 5, 50 ) 
	classlist:SetSize( 165, 165 ) 
	-- Insert all the class options
	if (team == TEAM_HUMAN) then
		for k = 1, #HumanClass do
			if (HumanClass[k].Choosable) then
				class[k] = classlist:AddItem( HumanClass[k].Name.." ("..amountOfPlayerInClass(k,TEAM_HUMAN).." players)" )
			else
				class[k] = nil
			end
		end
	else
		for k = 1, #UndeadClass do
			if (UndeadClass[k].Choosable) then
				class[k] = classlist:AddItem( UndeadClass[k].Name.." ("..amountOfPlayerInClass(k,TEAM_UNDEAD).." players)" )
			else
				class[k] = nil
			end
		end
	end
	
	-- Update the list every second
	timer.Create("updatetimer",1,0,function( dalist, team ) 
		if not dalist[2]:IsValid() then
			timer.Destroy("updatetimer")
			return
		end
		for k = 1, #dalist do
			if dalist[k] ~= nil then
				if team == TEAM_HUMAN then
					dalist[k]:SetText(HumanClass[k].Name.." ("..amountOfPlayerInClass(k,TEAM_HUMAN).." players)")
				else
					dalist[k]:SetText(UndeadClass[k].Name.." ("..amountOfPlayerInClass(k,TEAM_UNDEAD).." players)")
				end
			end
		end
	end,class,team)
	
	-- 'Select loadout' label
	local lolabel = vgui.Create("DLabel",subframe)
	lolabel:SetText( "Select loadout" )
	lolabel:SetPos( 5, 215 ) 
    lolabel:SetSize( 90, 25 ) 
	-- List with possible loadout choices
	local loadoutlist = vgui.Create("DMultiChoice",subframe)
	loadoutlist:SetPos( 5, 235 ) 
    loadoutlist:SetSize( 165, 20 ) 
	loadoutlist:SetEditable( false )
	loadoutlist:Clear()
	
	-- 'Apply for Behemoth' checkbox
	local box = vgui.Create("DCheckBox",subframe)
	if start then
		box:SetValue( true )
	else
		box:SetValue( LocalPlayer().PreferBehemoth )
	end
	box:SetPos(5,MENU_subframeheigth-60)
	box:SetSize(15,15)
	box.DoClick = function( btn ) 
		box:Toggle()
		LocalPlayer().PreferBehemoth = box:GetChecked()
		RunConsoleCommand("prefer_behemoth",tostring(box:GetChecked()))
	end
	-- Create Label
	local lab = vgui.Create("DLabel",subframe)
	lab:SetText( "Apply for Behemoth" )
	lab:SetPos(24,MENU_subframeheigth-62)
	lab:SetSize(200,20)
	
	
	-- Class name label
	local cllabel = vgui.Create("DLabel",subframe)
	cllabel:SetText( "Description class" )
	cllabel:SetPos( 175, 30 ) 
    cllabel:SetSize( 200, 25 ) 	
	-- Description textbox
	local descbox = vgui.Create("DTextEntry",subframe)
	descbox:SetPos( 175, 50 ) 
    descbox:SetSize( 420, 170 ) 
	descbox:SetEditable( false )
	descbox:SetValue("")
	descbox:SetMultiline( true )

	-- Add loadout listing
	local list = vgui.Create("DListView",subframe)
	list:SetPos(175,220)
	list:SetSize(420,140)
	
	list.SortByColumn = function() end
	list.OnRowSelected = function(lineID,line) end
	
	local c0 = list:AddColumn( "Weapon" ) 
	local c1 = list:AddColumn( "Clip or amount" ) 
	local c2 = list:AddColumn( "Special" ) 

	c0:SetMinWidth( 160 )
	c0:SetMaxWidth( 160 )
	c1:SetMinWidth( 80 )
	c1:SetMaxWidth( 80 )
	c2:SetMinWidth( 180 )
	c2:SetMaxWidth( 180 )
	
	-- 'SPAWN' or 'CHOOSE' button
	local buttonSpawn = vgui.Create("DButton",subframe)
	buttonSpawn:SetText( "SPAWN")
	if not start and team == TEAM_UNDEAD then
		buttonSpawn:SetText( "CHOOSE FOR NEXT SPAWN")		
	end
	buttonSpawn:SetPos(5,MENU_subframeheigth-35)
	buttonSpawn:SetSize(MENU_framewidth-10,30)
	
	-- Can't press the button when you're human
	if not start and team == TEAM_HUMAN then
		buttonSpawn:SetText( "CAN'T RESPAWN WHEN HUMAN")
		buttonSpawn:SetDisabled(true)
	end

	
	/*----------------------------------------------
		Specific data retrieving functions :O
	-----------------------------------------------*/
	
	-- Get the selected class
	function getSelectedClass()
		local className = classlist:GetSelected()
		if (className == nil) then return 0 end
		for k = 1, #class do
			if (class[k] ~= nil) then
				if (className == class[k]) then
					return k
				end
			end
		end
		return 0
	end
	
	-- Get the selected loadout
	function getSelectedLoadout()
		if (currentSelectedLoad == nil) then return 1 end
		return currentSelectedLoad
	end
	
	-- Update the loadout list with the number of available loadouts
	function updateLoadoutList()
		
		load = {}
		loadoutlist:Clear()
		local loadname = ""
		local slect = nil
		local code = ""
		local selClass = getSelectedClass()

		for k = 1, numLoadouts  do
			if (team == TEAM_HUMAN) then
				code = HumanClass[selClass].SwepLoadout[k].UnlockCode
				loadname = HumanClass[selClass].SwepLoadout[k].Name
			else
				code = UndeadClass[selClass].SwepLoadout[k].UnlockCode
				loadname = UndeadClass[selClass].SwepLoadout[k].Name
			end
			
			if LocalPlayer():HasUnlocked( code ) then	
				load[k] = loadoutlist:AddChoice(loadname, k) -- load k fetches index
				if not slect then
					slect = load[k]
				end
			end
		end
		
		currentSelectedLoad = 1
		loadoutlist:ChooseOptionID(slect)
	end	
	
	-- Update loadout description
	function updateDescription()
		
		local text = ""
		local selClass = getSelectedClass()
		local selLoadout = getSelectedLoadout()
		
		if (team == TEAM_HUMAN) then
			text = HumanClass[selClass].Info
			cllabel:SetText( "Description "..HumanClass[selClass].Name.." class" )
		else
			text = UndeadClass[selClass].Info	
			cllabel:SetText( "Description "..UndeadClass[selClass].Name.." class" )
		end
		
		-- update description textbox
		descbox:SetValue( text )
		
		list:Clear()

		local tab = {}
		if (team == TEAM_HUMAN) then
			tab = HumanClass[selClass].SwepLoadout[selLoadout].Sweps
		else
			tab = UndeadClass[selClass].SwepLoadout[selLoadout].Sweps
		end
		for k, swep in pairs( tab ) do
			local r = swepDesc[swep] or { Weapon = "No description for "..swep, Clip = "", Special = "" }
			list:AddLine( r.Weapon, r.Clip, r.Special )
		end

	end
	
	/*--------- End of the messy data retrieving functions --------- */
	
	/*-----------------------------------------
	DoClick functions
	Called when player presses on of the items
	-----------------------------------------*/
	
	-- every option in the combobox needs to update the loadout list
	for k = 1, #class do
		if (class[k] ~= nil) then
			class[k].DoClick = function( btn )
				local selectedClass = getSelectedClass()
				if (team == TEAM_HUMAN) then
					numLoadouts = (#HumanClass[selectedClass].SwepLoadout)
				elseif (team == TEAM_UNDEAD) then
					numLoadouts = (#UndeadClass[selectedClass].SwepLoadout)
				end
				updateLoadoutList()
			end
		end
	end
	
	buttonSpawn.DoClick = function( btn ) 
		-- run server command that spawns player
		local newClass = getSelectedClass()
		local newLoadout = getSelectedLoadout()
		if start then
			if (newClass ~= 0) then
				startPanelOpen = false
				RunConsoleCommand("first_spawn",""..newClass,""..newLoadout)
				frame:Close()
				subframe:Close()
			end
		else
			if (newClass ~= 0) then
				RunConsoleCommand("class_spawn",""..newClass,""..newLoadout)
				if frame and frame:IsValid() then
					frame:Close()
				end
				subframe:Close()
			end
		end
	end 
	
	-- update selected loadout
	loadoutlist.OnSelect = function( index, value, data )
		for k = 1, numLoadouts do
			-- find what choice was selected
			if (value == load[k]) then
				currentSelectedLoad = k
				break
			end
		end
		
		--currentSelectedLoad = value
		updateDescription()
	end
	
	-- At start, select the first class
	if (team == TEAM_HUMAN) then
		classlist:SelectItem(class[1])
		class[1]:Select() -- calls DoClick() function
	else -- can't select behemoth class
		classlist:SelectItem(class[2])
		class[2]:Select()	
	end
	
	
end 

/*------------------------------------
	And now for the console commands
	that open these godforsaken menus
--------------------------------------*/

local function clearFrames()
	if subframe and subframe:IsValid() then
		subframe:Close()
	end
	if !(frame and frame:IsValid()) then
		createMainFrame()
	end
end

function CloseFrames()
	if subframe and subframe:IsValid() then
		subframe:Close()
	end
	if frame and frame:IsValid() then
		frame:Close()
	end
end

function openHelpMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createHelpPanel()
end
concommand.Add("iw_menu_help", openHelpMenu) 
concommand.Add("iw_menu", openHelpMenu) 

function openAboutMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createAboutPanel()
end
concommand.Add("iw_menu_about", openAboutMenu) 

function openClassMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	-- open class panel in normal mode
	createClassPanel( false , LocalPlayer():Team() ) 
end
concommand.Add("iw_menu_class", openClassMenu) 

function openOptionsMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createOptionsPanel() 
end
concommand.Add("iw_menu_options", openOptionsMenu) 

function openScoreMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createScorePanel() 
end
concommand.Add("iw_menu_score", openScoreMenu) 

function openShopMenu()
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createShopPanel()
end
concommand.Add("iw_menu_shop", openShopMenu) 

function openAdminMenu()
	if not ADMIN_ADDON then return end
	if startPanelOpen or firstSpawn then return end
	clearFrames()
	createSubFrame()
	createAdminPanel()
end
concommand.Add("iw_menu_admin", openAdminMenu) 

-- this function is called by the server in PlayerInitialSpawn
function openStartClassMenu( team )
	if not roundStart then return end
	roundStart = false
	firstSpawn = true
	timer.Create("delaytimer",0.1,0,function( myteam )
		if LocalPlayer().DataTable then  -- delay until player stats arrive
			CloseFrames()
			startPanelOpen = true
			firstSpawn = false
			-- open class panel in 'start of round' mode
			createClassPanel( true, myteam ) 
			timer.Destroy("delaytimer")
		end
	end, team)
end
function humanStart()
	openStartClassMenu( TEAM_HUMAN )
end
function undeadStart()
	openStartClassMenu( TEAM_UNDEAD )
end
concommand.Add("iw_start_human", humanStart)
concommand.Add("iw_start_undead", undeadStart)

