/*
THINGS TO TAKE NOTE OF:
The menu is recreated every time it is opened, so make sure to save settings.
This could / probably should be rewritten later to only generate the menue once, 
but for now this system will be used.

notes on reformatting for fix:
	Rather than caching settings, vgui objects for the settings should be cached.
	when things are updated, simply forcing an open / close wont fix it. You will have
	to actually set values that were changed or force a recreation of the menu which could
	break other scripts

*/

if(CLIENT)then
	// creating variables used by this hack.
	// OH MY FUCKING GOD A SE BIPASS: http://dl.dropbox.com/u/39666519/gmcl_sdef2.zip
	// lua goes in menu_plugins and dll in modules/includes
	MsgN("####################")
	MsgN("# Loading PHack    #")
	MsgN("####################")
	
	
	PHack = {}
	PHack.plugins = {}
	PHack.lib = {}
	PHack.cfg = {}
	PHack.cfg.debugmode = true
	
	PHack.lib.debugmsg = function( str )
		if(PHack.cfg.debugmode == true)then
			print( str )
		end
	end
	
	PHack.lib.registerPlugin = function(hack)
		PHack.lib.debugmsg("Registering hack "..hack.name)
		PHack.plugins[hack.name] = hack
		// adding data to the hack that may not have been added
		if(hack.enabled == nil)then
			hack.enabled = false
		end
	end
	
	PHack.lib.debugmsg("Loading hacks from PHack/plugins/ directory")
	local hacksDir = "PHack/plugins/"
	local hackFiles = file.FindInLua(hacksDir.."*.lua")
	//local hacksCrypted = file.FindInLua("LPHack/hacks/*.lpc") -- work in progress.
	PHack.lib.debugmsg("found "..#hackFiles.." hacks")
	
	
	for k,v in pairs(hackFiles)do
		MsgN("Loading PHack Plugin: "..v)
		include(hacksDir..v)
	end
	
	CreateClientConVar( "LP_name_enabled", 0, true, false )
	CreateClientConVar( "LP_name_useunichars", 0, true, false )
	
	local lpmenu = nil;
	
	// THE CODE TO SHOW THE MENU
	
	local function lp_menu()
		// if the menu has allready been created just show it
		// rather than remaking it and waisting time.
		if(lpmenu != nil)then
			lpmenu:SetVisible( true )
			return
			PHack.lib.debugmsg("Reusing the old menu")
		end
		
		// variables
		local framew, frameh = ScrW()*0.75,ScrH()*0.75
		
		// #############################################
		// THE MENU FRAME ITS SELF
		// #############################################
		lpmenu = vgui.Create( "DFrame" )
		lpmenu:SetPos( 50, 50 ) -- Position on the players screen
		lpmenu:SetSize( framew, frameh ) -- Size of the frame
		lpmenu:SetTitle( "TheLastPenguin's Name Changer Hack" ) -- Title of the frame
		lpmenu:SetVisible( true )
		lpmenu:SetDraggable( true ) -- Draggable by mouse?
		lpmenu:ShowCloseButton( true ) -- Show the close button?
		lpmenu:SetDeleteOnClose( false )
		lpmenu:MakePopup() -- Show the frame
		
		
		// #############################################
		// THE PROPERTY SHEET
		// #############################################
		local PSheet = vgui.Create( "DPropertySheet" )
		PSheet:SetParent( lpmenu )
		PSheet:SetPos( 10, 30 )
		PSheet:SetSize( framew - 20, frameh - 40 )
		
		// #############################################
		// THE HOME PAGE  - Shows a list of loaded hacks.
		// #############################################
		local MainPage = vgui.Create( "DPanel" )
		MainPage:SetParent( PSheet )
		MainPage:SetPos( 0, 0 )
		MainPage:SetSize( framew - 20, frameh - 20 )
		
		local backgroundimg = vgui.Create("DImage", MainPage)
		backgroundimg:SetPos(0,0)
		backgroundimg:SetSize(framew - 20, frameh - 20)
		backgroundimg:SetMaterial("LPHack/GUI/Backgrounds/StripedDark.vmt")
		
		// an awesome looking penguin immage
		local HackIconImg = vgui.Create( "DImageButton", MainPage )
		local imgwidth = math.min((framew - 20)*0.75,(frameh - 20)*0.75)
		HackIconImg:SetPos(framew / 2 - imgwidth/2 , 20 )
		HackIconImg:SetImage( "LPHack/GUI/Penguin.vmt" )
		HackIconImg:SetSize(imgwidth , imgwidth )
		HackIconImg.DoClick = function()
			chat.AddText(Color(0,255,0),"Name Changer hack by TheLastPenguin")
		end
		PSheet:AddSheet( "Main", MainPage, "gui/silkicons/world", false, false, "Main Page" )
		
		// Making pages for hacks.
		for k,v in pairs(PHack.plugins) do
			PHack.lib.debugmsg("Creating tab for plugin "..v.name)
			local pluginPage = vgui.Create( "DPropertySheet" )
			pluginPage:SetParent(PSheet)
			pluginPage:SetPos( 0, 0 )
			pluginPage:SetSize( framew - 20, frameh - 20 )
			
			// stick on our background immage.
			local backgroundimg = vgui.Create("DImage", pluginPage)
			backgroundimg:SetPos(0,0)
			backgroundimg:SetSize(pluginPage:GetSize())
			backgroundimg:SetMaterial("LPHack/GUI/Backgrounds/StripedDark.vmt")
			
			
			v.menuload(pluginPage)
			v.pluginPage = pluginPage -- not actually used, but we will keep it just incase
			PSheet:AddSheet( v.name , pluginPage, v.menuicon or "gui/silkicons/page" )
			
			// this makes a checkbox to set if the hack is enabled or not.
			local EnabledCheckbox = vgui.Create( "DCheckBoxLabel" , pluginPage)
			EnabledCheckbox:SetPos(5,5)
			EnabledCheckbox:SetText( "Name Changer Hack Enabled" )
			EnabledCheckbox:SetValue( 1 )
			EnabledCheckbox:SizeToContents()
			EnabledCheckbox.OnChange = function()
				if(EnabledCheckbox:GetChecked())then
					PHack.lib.debugmsg("Name changer is now enabled")
					v.enabled = true
					if(v.onEnabled != nil) then
						v.onEnabled()
					end
				else
					PHack.lib.debugmsg("Name changer is now disabled")
					v.enabled = false
					if(v.onDisabled != nil) then
						v.onDisabled()
					end
				end
			end
		end
	end
	PHack.lib.debugmsg("Adding the command LP_menu to open the hack menu")
	concommand.Add("LP_hackmenu", lp_menu)
	lp_menu()
end
