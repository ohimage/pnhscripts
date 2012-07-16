
if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Pulse Rifle"			
	SWEP.Slot = 2
	SWEP.SlotPos = 7
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.IconLetter = "2"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_pulserifle", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Instructions = "High-power energy based weapon. Consumes suit power!" 

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_IRifle.mdl"
SWEP.WorldModel			= "models/weapons/w_IRifle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_AR2.Single")
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Unrecoil		= 8
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ConeMoving		= 0.1
SWEP.Primary.ConeCrouching	= 0.03

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.MuzzleEffect			= "rg_muzzle_rifle"

--SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
--SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

SWEP.Drain = 3

function SWEP:PrimaryAttack()

	local ply = self.Owner

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if not self:CanPrimaryAttack() then return end

	self.Weapon:EmitSound(self.Primary.Sound)
	
	self:FireIWBullet()
	
	if SERVER then
		ply:SetSuitPower(ply:SuitPower()-self.Drain)
	end
	
	ply:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))

	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

SWEP.fired = false

function SWEP:Think()
	
	local ply = self.Owner

	-- Show reload animation when player stops firing. Looks cool.
	if ply:KeyDown(IN_ATTACK) then	
		self.fired = true
	elseif self.fired then 
		self.fired = false
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	end
end

function SWEP:CanPrimaryAttack()

	local ply = self.Owner
	if ply:SuitPower() <= self.Drain then
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end
	return true
end


