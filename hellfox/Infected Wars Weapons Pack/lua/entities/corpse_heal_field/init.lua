include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetNotSolid(true)	
	self.Entity:DrawShadow( false )
	
	self.nextheal = 0
	
	timer.Simple(5,function(ent)
		if ValidEntity(ent) then
			ent:Remove()
		end
	end,self.Entity)
end	

function ENT:Think()
	if self.nextheal < CurTime() then

		local players = ents.FindInSphere(self.Entity:GetPos(), 150)
		for k, pl in pairs(players) do
			if pl:IsPlayer() and pl:Team() == TEAM_UNDEAD and pl:Alive() then
				local hpplus = 0
				if pl:HasBought("maliceabsorption2") then
					hpplus = 20
				elseif pl:HasBought("maliceabsorption1") then
					hpplus = 10
				end
				
				if hpplus > 0 then
					pl:SetHealth(math.min(pl:GetMaximumHealth(),pl:Health()+hpplus))
					
					local eff = EffectData()
						eff:SetOrigin(pl:GetPos())
					util.Effect( "demon_heal", eff )
				end
			end
		end
		self.nextheal = CurTime() + 2
	end
end

function ENT:OnRemove()
end
