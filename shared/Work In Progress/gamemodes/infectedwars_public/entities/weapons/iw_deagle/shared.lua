if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "pistol"

if CLIENT then
	SWEP.PrintName = "Desert Eagle"			
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.IconLetter = "f"
	killicon.AddFont("iw_deagle", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_Deagle.Single")
SWEP.Primary.Recoil			= 3.25
SWEP.Primary.Damage			= 28
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 7
SWEP.Primary.Delay			= 0.3
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone			= 0.08
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.04

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject" 

--SWEP.IronSightsPos = Vector(5.15,-2,2.65)
--SWEP.IronSightsAng = Vector(.3,0,0)