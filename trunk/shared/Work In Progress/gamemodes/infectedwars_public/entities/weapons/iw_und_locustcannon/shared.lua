if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "Locust Cannon"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false
	
	SWEP.IconLetter = "0"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_und_locustcannon", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/Weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/Weapons/w_shotgun.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("npc/antlion/land1.wav")
SWEP.Primary.Recoil			= 8
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 2
SWEP.Primary.NumShots		= 8
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 0.4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.12
SWEP.Primary.ConeMoving		= 0.19
SWEP.Primary.ConeCrouching	= 0.08

SWEP.MuzzleEffect			= "rg_muzzle_rifle"

--SWEP.IronSightsPos = Vector(-5.6, -6, 3.6)
--SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.NextReload = 0


function SWEP:Reload()
	--self:SetIronsights(false)
	
	if CurTime() < self.NextReload then return end
	self.NextReload = CurTime() + self.Primary.Delay * 2
	
	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:DefaultReload( ACT_VM_RELOAD )
		timer.Simple(0.4, self.Weapon.SendWeaponAnim, self.Weapon, ACT_SHOTGUN_RELOAD_FINISH)
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	end
end
