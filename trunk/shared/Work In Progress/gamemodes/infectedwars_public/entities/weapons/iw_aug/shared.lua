if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Steyer AUG"			
	SWEP.Slot = 2
	SWEP.SlotPos = 9
	SWEP.IconLetter = "e"
	killicon.AddFont("iw_aug", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_aug.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_AUG.Single")
SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Unrecoil		= 8
SWEP.Primary.Damage			= 19
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.11
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.06
SWEP.Primary.ConeMoving		= 0.13
SWEP.Primary.ConeCrouching	= 0.04

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(5.1, -4, 1.5)
--SWEP.IronSightsAng = Vector(0,0,0)