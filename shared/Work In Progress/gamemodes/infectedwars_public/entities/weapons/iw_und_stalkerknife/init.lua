AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Think()
	if self.Owner:IsValid() then
		local div = 3
		if (self.Owner.EquipedSuit == "stalkerghostsuit") then
			div = 4
			if self.Owner:Crouching() then
				div = 20
			end
		end
		self.Owner:SetColor(200, 200, 200, math.Clamp(self.Owner:GetVelocity():Length()/div, 5, 60))
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CurTime() < self.Weapon:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end
	self.Owner:LagCompensation(true)

	local trace = self.Owner:TraceLine(70)
	local ent = nil

	if trace.HitNonWorld then
		ent = trace.Entity
	end

	if trace.Hit then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			self.Owner:EmitSound("weapons/knife/knife_hit"..math.random(1,4)..".wav")
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			self.Owner:EmitSound("weapons/knife/knife_hitwall1.wav")
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	end

	if ent and ent:IsValid() then
	    ent:TakeDamage(self.Primary.Damage, self.Owner)
	end

	if self.Alternate then
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	end
	self.Alternate = not self.Alternate

	self.Owner:EmitSound("weapons/knife/knife_slash"..math.random(1,2)..".wav")
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	
	if ( !self:CanSecondaryAttack() ) then return end
	self.screamTimer = CurTime()+2.5
	
	local amplify = self.Owner:HasBought("chaosamplifier")
	
	local dis
	local fuckedlvl
	local reach = 350
	local power = 300
	if amplify then
		reach = 450
		power = 400
	end
	-- Find all players within the radius and fuck em up!
	local fucked_ones = ents.FindInSphere( self.Owner:GetPos(), reach ) or {}
	for k, pl in pairs(fucked_ones) do
		if (pl:IsPlayer()) then
			if (pl:Team() == TEAM_HUMAN) then
				dis = pl:GetPos():Distance(self.Owner:GetPos())
				fuckedlvl = math.Clamp(power/dis,0.5,6)
				if fuckedlvl >= 1.2 then 
					self.Owner:AddScore("screensfucked",1)
					self.Owner.ScreensFucked = self.Owner.ScreensFucked+1
					
					-- Achievement stuff
					if not table.HasValue(self.Owner.Screamlist,pl) then
						table.insert(self.Owner.Screamlist,pl)
						if #self.Owner.Screamlist == 10 then
							self.Owner:UnlockAchievement("thebooman")
						end
					end
					
					if self.Owner:GetScore("screensfucked") >= 300 then
						self.Owner:UnlockAchievement("japanesehorror")
					end
				end
				pl:SendLua("StalkerFuck("..fuckedlvl..")")
			end
		end
	end
	self.Owner:SendLua("StalkerScream()")
	
	self.Weapon:EmitSound(self.ScreamSound)
	
end

