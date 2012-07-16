include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetNotSolid(true)	
	self.Entity:DrawShadow( false )
	
	self.nextheal = 0
end	

function ENT:Think()
	if !ValidEntity(self:GetOwner()) or !self:GetOwner():Alive() then
		self:Remove()
		return
	end
	self.Entity:SetPos(self:GetOwner():GetPos())
	if self.nextheal < CurTime() then

		local players = ents.FindInSphere(self.Entity:GetPos(), 150)
		for k, pl in pairs(players) do
			if pl:IsPlayer() and pl != self:GetOwner() and pl:Team() == TEAM_UNDEAD and pl:Alive() then
				local hpplus = 5

				pl:SetHealth(math.min(pl:GetMaximumHealth(),pl:Health()+hpplus))
				
				local eff = EffectData()
					eff:SetOrigin(pl:GetPos())
				util.Effect( "demon_heal", eff )
			end
		end
		self.nextheal = CurTime() + 2
	end
end

function ENT:OnRemove()
end
