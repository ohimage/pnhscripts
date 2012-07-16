require("datastream")

// The Class Picker when player first spawns
local function makeClassPicker()
	local width = ScrW() / 2
	local height = ScrH() * 0.8
		
	local classes = LPRP.Class:GetAll()
	local CP_Frame = vgui.Create( "DFrame" )
	CP_Frame:SetPos( width / 2, height * 0.1 )
	CP_Frame:SetSize( width, height )
	CP_Frame:SetTitle( "Select Your Class" ) 
	CP_Frame:SetVisible( true )
	CP_Frame:SetDraggable( true )
	CP_Frame:ShowCloseButton( true )
	CP_Frame:MakePopup()
	CP_Frame:SetSkin( "LPRP_LightSkin" )
	
	// Name and other information input box:
	local lbl1 = vgui.Create("DLabel", CP_Frame)
	lbl1:SetPos(25,32) // Position
	lbl1:SetColor(Color(255,255,255,255)) // Color
	lbl1:SetFont("Trebuchet18")
	lbl1:SetText("Role Play Name:") // Text
	lbl1:SizeToContents()
	
	local nameEntry = vgui.Create("DTextEntry", CP_Frame)
	nameEntry:SetPos( 130, 30 );
	nameEntry:SetWidth( 100 );
	nameEntry:SelectAllOnFocus( true );
	nameEntry:SetText("<name>")
	nameEntry:SetEnterAllowed(false)
	nameEntry.OnLoseFocus = function( self )
		chat.AddText("Checking name is free.")
	end
	// E-Mail ( if users want out of game contact. )
	local lbl2 = vgui.Create("DLabel", CP_Frame)
	lbl2:SetPos(25,62) // Position
	lbl2:SetColor(Color(255,255,255,255)) // Color
	lbl2:SetFont("Trebuchet18")
	lbl2:SetText("E-Mail:") // Text
	lbl2:SizeToContents()
	
	local emailEntry = vgui.Create("DTextEntry", CP_Frame)
	emailEntry:SetPos( 130, 60 );
	emailEntry:SetWidth( 100 );
	emailEntry:SelectAllOnFocus( true );
	emailEntry:SetText("<optional>")
	emailEntry:SetEnterAllowed(false)
	emailEntry.OnLoseFocus = function( self )
		chat.AddText("Thanks for your email")
	end
	// The Class picker List
	ClassList = vgui.Create( "DPanelList", CP_Frame )
	ClassList:SetPos( 25, height * 0.75 )
	ClassList:SetSize( width - 50, height * 0.25 - 25 )
	ClassList:SetSpacing( 5 ) 
	ClassList:EnableHorizontal( true )
	ClassList:EnableVerticalScrollbar( true ) 
	
	local selectedIcon = nil
	local selectedClass = nil
	
	for k,v in pairs(classes)do
		local mdls = v:GetModels();
		if( mdls[1] ~= nil)then
			local Icon = vgui.Create( "LPRP_SpawnIcon")
			Icon:SetPos( 20, 20 )
			Icon:SetModel( mdls[1] )
			Icon:SetIconSize( 100 )
			Icon.label = k
			Icon.OnCursorExited = nil
			Icon.OnCursorEntered = nil
			function Icon:DoClick()
				if ( selectedIcon and selectedIcon.PaintOver == selectedIcon.PaintOverHovered ) then
					selectedIcon.PaintOver = selectedIcon.PaintOverOld
				end
				selectedIcon = self
				selectedClass = self.label
				self.PaintOverOld = self.PaintOver
				self.PaintOver = self.PaintOverHovered
			end
			ClassList:AddItem( Icon )
		end
	end
	
	local function checkName()
		
	end
	
	local function submitData()
		local data = {}
		local name = nameEntry:GetValue()
		if( name and name != "" and validName( name ) )then
			checkName()
		else
			Derma_Message( "Name must be a-z,A-Z or 0-9.","Invalid Name","Ok" )
		end
	end
end

concommand.Add("LPRP_ShowClassPicker",function()
	makeClassPicker()
end)