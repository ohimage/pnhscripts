if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "M4A1"			
	SWEP.Slot = 2
	SWEP.SlotPos = 4
	SWEP.IconLetter = "w"
	killicon.AddFont("iw_m4a1", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_M4A1.Single")
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Unrecoil		= 8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ConeMoving		= 0.12
SWEP.Primary.ConeCrouching	= 0.03

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(5.1, -4, 1.5)
--SWEP.IronSightsAng = Vector(0,0,0)