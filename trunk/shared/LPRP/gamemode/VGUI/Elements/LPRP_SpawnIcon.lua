local matHover = Material( "vgui/spawnmenu/hover" )

local PANEL = {}

AccessorFunc( PANEL, "m_iIconSize",         "IconSize" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

    self.Icon = vgui.Create( "ModelImage", self )
    self.Icon:SetMouseInputEnabled( false )
    self.Icon:SetKeyboardInputEnabled( false )
    
    self.animPress = Derma_Anim( "Press", self, self.PressedAnim )
    
    self:SetIconSize( 64 ) // Todo: Cookie!
	self.label = ""
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

    if ( mcode == MOUSE_LEFT ) then
        self:DoClick()
        self.animPress:Start( 0.2 )
    end
    
    if ( mcode == MOUSE_RIGHT ) then
        self:OpenMenu()
    end

end

function PANEL:OnMouseReleased()

    

end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()
end

/*---------------------------------------------------------
   Name: OpenMenu
---------------------------------------------------------*/
function PANEL:OpenMenu()
end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnCursorEntered()

    self.PaintOverOld = self.PaintOver
    self.PaintOver = self.PaintOverHovered

end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnCursorExited()

    if ( self.PaintOver == self.PaintOverHovered ) then
        self.PaintOver = self.PaintOverOld
    end

end

/*---------------------------------------------------------
   Name: PaintOverHovered
---------------------------------------------------------*/
function PANEL:PaintOverHovered()

    if ( self.animPress:Active() ) then return end

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( matHover )
    self:DrawTexturedRect()
	
	local sizex, sizey = self:GetSize()
	surface.SetDrawColor(  0,  0,  0,  200 )
	surface.DrawRect(  0,  sizey - sizey / 4,  sizex,  sizey / 4 )
	draw.DrawText(  self.label,  "Trebuchet18",  sizex / 2,  sizey - sizey / 4,  Color( 255, 255, 255, 255 ),  TEXT_ALIGN_CENTER )
end

/*---------------------------------------------------------
   Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:PerformLayout()

    self:SetSize( self.m_iIconSize, self.m_iIconSize )    
    self.Icon:StretchToParent( 0, 0, 0, 0 )

end

/*---------------------------------------------------------
   Name: PressedAnim
---------------------------------------------------------*/
function PANEL:SetModel( mdl, iSkin )

    if (!mdl) then debug.Trace() return end

    self.Icon:SetModel( mdl, iSkin )
end


/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

    self.animPress:Run()

end

/*---------------------------------------------------------
   Name: PressedAnim
---------------------------------------------------------*/
function PANEL:PressedAnim( anim, delta, data )

    if ( anim.Started ) then
    end
    
    if ( anim.Finished ) then
        self.Icon:StretchToParent( 0, 0, 0, 0 )
    return end

    local border = math.sin( delta * math.pi ) * ( self.m_iIconSize * 0.1 )
    self.Icon:StretchToParent( border, border, border, border )
end

/*---------------------------------------------------------
   Name: RebuildSpawnIcon
---------------------------------------------------------*/
function PANEL:RebuildSpawnIcon()

    self.Icon:RebuildSpawnIcon()

end

function PANEL:PaintOver()
	
	local sizex, sizey = self:GetSize()
	surface.SetDrawColor(  0,  0,  0,  200 )
	surface.DrawRect(  0,  sizey - sizey / 4,  sizex,  sizey / 4 )
	
	draw.DrawText( self.label,  "Trebuchet18",  sizex / 2,  sizey - sizey / 4,  Color( 255, 255, 255, 255 ),  TEXT_ALIGN_CENTER )
end


vgui.Register( "LPRP_SpawnIcon", PANEL, "Panel" )