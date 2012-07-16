-- Draw code is based on that of the tripmine laser in The Stalker gamemode
-- Credit to Sechs for that!

include('shared.lua')

local matTripmineLaser 		= Material( "sprites/bluelaser1" )
local matLight 				= Material( "models/roller/rollermine_glow" )
local colBeam				= Color( 100, 100, 210, 30 )
local colLaser				= Color( 100, 100, 240, 30 )

function ENT:Think()

	if ( self:GetActiveTime() == 0 || self:GetActiveTime() > CurTime() ) then return end

	if not self.endpos then
		local t = {}
		t.start = self.Entity:GetPos()
		t.endpos = t.start + self.Entity:GetUp() * 4096
		t.filter = {self.Entity, self.Entity:GetOwner()}
		t.mask = MASK_SOLID_BRUSHONLY
		local tr = util.TraceLine(t)
		self.endpos = tr.HitPos
	end

	self.Entity:SetRenderBoundsWS( self.endpos, self.Entity:GetPos(), Vector()*8 )
	
end

function ENT:Draw()

	if ( self:GetActiveTime() == 0 || self:GetActiveTime() > CurTime() ) then
		return
	end
	if not self.endpos then
		return
	end

	render.SetMaterial( matTripmineLaser )
	
	// offset the texture coords so it looks like it is scrolling
	local TexOffset = CurTime() * 3
	
	// Make the texture coords relative to distance so they are always a nice size
	local Distance = self.endpos:Distance( self.Entity:GetPos() )
		
	// Draw the beam
	render.DrawBeam( self.endpos, self.Entity:GetPos(), 6, TexOffset, TexOffset+Distance/8, colBeam )
	render.DrawBeam( self.endpos, self.Entity:GetPos(), 3, TexOffset, TexOffset+Distance/8, colBeam )
	
	// Draw a quad at the hitpoint to fake the laser hitting it
	render.SetMaterial( matLight )
	local Size = math.Rand( 3, 5 )
	local Normal = (self.Entity:GetPos()-self.endpos):GetNormal() * 0.1
	render.DrawQuadEasy( self.endpos + Normal, Normal, Size, Size, colLaser, 0 )
	 
end

function ENT:IsTranslucent()
	return true
end
