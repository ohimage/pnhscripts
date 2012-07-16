if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "M249 SAW"			
	SWEP.Slot = 2
	SWEP.SlotPos = 8
	SWEP.IconLetter = "z"
	SWEP.ViewModelFlip = false
	killicon.AddFont("iw_m249", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_M249.Single")
SWEP.Primary.Recoil			= 4
SWEP.Primary.Unrecoil		= 9
SWEP.Primary.Damage			= 14
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.06
SWEP.Primary.ConeMoving		= 0.17
SWEP.Primary.ConeCrouching	= 0.04

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(-4.49,-2,2.15)
--SWEP.IronSightsAng = Vector(.00001,-.06,.00001)