if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "pistol"

if CLIENT then
	SWEP.PrintName = "Dual Elites"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 1
	SWEP.SlotPos = 6
	SWEP.IconLetter = "s"
	killicon.AddFont("iw_elites", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_elite.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_ELITE.Single")
SWEP.Primary.Recoil			= 2.5
SWEP.Primary.Damage			= 14
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.12
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone			= 0.06
SWEP.ConeMoving				= 0.1
SWEP.ConeCrouching			= 0.045

SWEP.MuzzleEffect			= "rg_muzzle_pistol"
SWEP.ShellEffect			= "rg_shelleject" 

--SWEP.IronSightsPos = Vector(0,0,0)
--SWEP.IronSightsAng = Vector(0,0,0)