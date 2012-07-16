AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


local function chooseModel(ent)
	local amount = ent:GetNWInt("value")
	if(amount <= 50)then -- setting models for money
		ent:SetModel("models/money/broncoin.mdl")
	elseif(amount <= 125)then
		ent:SetModel("models/money/silvcoin.mdl")
	elseif(amount <= 1500)then
		ent:SetModel("models/money/note.mdl")
	else
		ent:SetModel("models/money/goldbar.mdl" )
	end
end

function ENT:Initialize()
	chooseModel(self.Entity)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	
	local phys = self.Entity:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true

	if phys and phys:IsValid() then phys:Wake() end
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) 
end


function ENT:Use(activator,caller)
	local amount = self:GetNWInt("value")
	activator:GiveMoney(amount or 0)
	self:Remove()
end

function LPRP:CreateMoneyBag(pos, amount)
	local moneybag = ents.Create("money")
	moneybag:SetPos(pos)
	moneybag:SetNWInt("value",amount)
	moneybag:Spawn()
	moneybag:Activate()
end