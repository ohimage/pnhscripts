if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "FAMAS"
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 9
	SWEP.IconLetter = "t"
	killicon.AddFont("iw_famas", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"
SWEP.ViewModelFlip		= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_famas.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_FAMAS.Single")
SWEP.Primary.Recoil			= 1.1
SWEP.Primary.Unrecoil		= 11
SWEP.Primary.Damage			= 14
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.11
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.06
SWEP.Primary.ConeMoving		= 0.11
SWEP.Primary.ConeCrouching	= 0.045

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(-4,-3,1)
--SWEP.IronSightsAng = Vector(3,.5,4)