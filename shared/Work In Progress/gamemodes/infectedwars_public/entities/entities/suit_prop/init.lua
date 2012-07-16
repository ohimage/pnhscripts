
include("shared.lua")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()   
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetNotSolid(true)
	self:DrawShadow(false)
end 

function ENT:Think()
	// Use own colors, but owner's alpha
	local pl = self:GetOwner():GetRagdollEntity() or self:GetOwner()
	local r,g,b,_ = self:GetColor()
	local _,_,_,a = pl:GetColor()
	
	// apparently it doesn't do this itself
	if (pl == self:GetOwner():GetRagdollEntity()) then
		a = 255
	end
	
	if (self:GetOwner().Dissolving or self:GetOwner().Gibbed) then
		a = 0
	end
	
	self:SetColor(r,g,b,a)
end

function ENT:CreateFromTable( suittable )
	
	self:SetModel(suittable.model)
	self:SetNWString("bone", suittable.bone)
	self:SetNWVector("position", suittable.pos)
	self:SetNWAngle("angles", suittable.ang)
	self:SetNWInt("scale", suittable.scale)
	
	if suittable.color then
		self:SetColor( suittable.color.r, suittable.color.g, suittable.color.b, 255 )
	end
end