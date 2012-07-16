include("shared.lua")

function ENT:Initialize()
end

local Games = {}
function LPRP_RegisterGame( name, tbl )
	Games[ name ] = tbl
end

function ENT:Draw()
	self.Entity:DrawModel()
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	Ang:RotateAroundAxis(Ang:Right(), 180)
	
	cam.Start3D2D(Pos + Ang:Up() * 200, Ang, 0.1)
		draw.WordBox(2, 200, "test", "ChatFont", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
end

function ENT:Think()
	
end