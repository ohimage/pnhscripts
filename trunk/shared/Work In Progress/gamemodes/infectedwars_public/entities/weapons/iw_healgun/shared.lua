
SWEP.HoldType = "pistol"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("items/medshot4.wav")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Unrecoil		= 1
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0
SWEP.Primary.ConeMoving		= 0
SWEP.Primary.ConeCrouching	= 0

--SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
--SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

SWEP.Drain = 2

SWEP.HealDistance = 80

local restoretimer = 0

function SWEP:Initialize()
	self.HealTime = 0
	self.HealSound = CreateSound(self.Weapon,"items/medcharge4.wav")
	self.EmptySound = Sound("items/medshotno1.wav")
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:FindPlayer( dis )
	local trace = self.Owner:TraceLine(dis)
	if trace.HitNonWorld then
		local target = trace.Entity
		if target:IsPlayer() then
			return target
		end
	end
	return
end

function SWEP:HealStart()
	self.Primary.Automatic = true
	self.Weapon:EmitSound(self.Primary.Sound)
	if SERVER then
		self.HealSound:Play()
	end			
end

function SWEP:HealStop()
	self.HealTime = CurTime()+self.Primary.Delay*2 -- prohibits heal button smashing
	self.Primary.Automatic = false
	self.Weapon:EmitSound(self.EmptySound)
	if SERVER then
		self.HealSound:Stop()
	end		
end

SWEP.target = nil
SWEP.healstack = 0

function SWEP:PrimaryAttack()

	local ply = self.Owner
	if (ply.EquipedSuit == "suppliesboosterpack") then
		self.Weapon:SetNextPrimaryFire(CurTime() + (self.Primary.Delay*0.666))
	else
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	end
	if not self:CanPrimaryAttack() then return end

	self.target = self.target or self:FindPlayer(self.HealDistance)
	
	if self.target ~= nil and self.target:IsValid() and self.target:Team() == self.Owner:Team()
		and self.target:GetPos():Distance(self.Owner:GetShootPos()) < self.HealDistance*1.5 and self.target:Alive() then
		if self.target:Health() < self.target:GetMaximumHealth() then -- and if it doesn't have full hp
			local prevhp = self.target:Health()
			self.target:SetHealth(math.min(self.target:Health()+2,self.target:GetMaximumHealth()))
			local drain = self.Drain
			if ply:HasBought("efficientexchange") then
				drain = drain * 0.7
			end
			ply:SetSuitPower(ply:SuitPower()-drain)
			if CLIENT then -- Emit some nice looking particles...
				local pos = self.target:GetPos()+Vector(0,0,50)
				self:EmitHealParticles( pos )
			end				
			if SERVER then
				self:UpdateHealScore( self.target, prevhp )
			end
		elseif self.Primary.Automatic then
			if CLIENT then
				self.Owner:PrintMessage(HUD_PRINTTALK,"Target player is full")
			end
			self:HealStop()
		end
	else
		self.target = nil
		self:HealStop()
	end
	
	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

local fired = false

function SWEP:Think()
 
	local ply = self.Owner
	   
	if ply:KeyPressed(IN_ATTACK) and self:CanPrimaryAttack() then
		local target = self:FindPlayer(self.HealDistance)
		if target ~= nil then
			if target:Health() < target:GetMaximumHealth() then
				self:HealStart()
			elseif self.Primary.Automatic then
				if CLIENT then
					self.Owner:PrintMessage(HUD_PRINTTALK,"Target player is full")
				end
				self:HealStop()
			end			
		else
			self:HealStop()
		end
	end
	
	if ply:KeyReleased(IN_ATTACK) and SERVER then
		self.Primary.Automatic = true
		self.HealSound:Stop()
	end

end 

function SWEP:CanPrimaryAttack()
	local ply = self.Owner
	if ply:SuitPower() <= self.Drain and self.HealTime < CurTime() then
		self.Weapon:EmitSound(self.EmptySound)
		return false
	end
	return true
end

function SWEP:SecondaryAttack()

end
