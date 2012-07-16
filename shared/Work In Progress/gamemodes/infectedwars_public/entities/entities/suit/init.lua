
include("shared.lua")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()   
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetNotSolid(true)
	self:DrawShadow(false)

	self.Props = {}
end 

function ENT:Think()
	local pl = self:GetOwner():GetRagdollEntity() or self:GetOwner()
	self:SetColor(pl:GetColor())
	if not ValidEntity(pl) then self:Remove() end
	self.Entity:SetPos(pl:GetPos())
	for k, v in pairs(self.Props) do
		if pl.Disguised then
			v:SetColor(Color(255,255,255,0))
		else
			v:SetColor(self:GetColor())
		end
		v:SetPos(pl:GetPos())
	end
end

function ENT:CreateSuit( suittable, item )
	
	for k, prop in pairs( suittable ) do
		local ent = ents.Create("suit_prop")
		if ent then
			ent:SetPos(self.Entity:GetPos())
			ent:SetOwner(self:GetOwner())
			ent:SetParent(self:GetOwner())
			ent:Spawn()
			ent:CreateFromTable( prop )
			table.insert(self.Props, ent)
		end
	end
	
	self:SetNWString("suitname", item)
end

function ENT:OnRemove()
	for k, ent in pairs(self.Props) do
		ent:Remove()
	end
end