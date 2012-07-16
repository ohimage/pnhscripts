if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "smg"

if CLIENT then
	SWEP.PrintName = "P90"			
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.IconLetter = "m"
	killicon.AddFont("iw_p90", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_P90.Single")
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 9
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.06
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.06
SWEP.Primary.ConeMoving		= 0.16
SWEP.Primary.ConeCrouching	= 0.05

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject" 

--SWEP.IronSightsPos = Vector(3.7, -5.4, 2.8)
--SWEP.IronSightsAng = Vector(0.6, -1.4, -1.5)