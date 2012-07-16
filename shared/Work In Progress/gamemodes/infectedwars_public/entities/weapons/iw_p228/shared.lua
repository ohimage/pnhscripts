if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "pistol"

if CLIENT then
	SWEP.PrintName = "P228"
	SWEP.Slot = 1
	SWEP.SlotPos = 2
	SWEP.IconLetter = "a"
	killicon.AddFont("iw_p228", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_p228.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_P228.Single")
SWEP.Primary.Recoil			= 2.25
SWEP.Primary.Damage			= 11
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 22
SWEP.Primary.Delay			= 0.15
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone			= 0.065
SWEP.Primary.ConeMoving		= 0.11
SWEP.Primary.ConeCrouching  = 0.038

SWEP.MuzzleEffect			= "rg_muzzle_pistol"
SWEP.ShellEffect			= "rg_shelleject" 

--SWEP.IronSightsPos = Vector(4.76,-2,2.955)
--SWEP.IronSightsAng = Vector(-.6,0,0)