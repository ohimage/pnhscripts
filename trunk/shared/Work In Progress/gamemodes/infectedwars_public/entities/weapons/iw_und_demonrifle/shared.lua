if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Demon Rifle"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = true
	
	SWEP.IconLetter = "b"
	killicon.AddFont("iw_und_demonrifle", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("npc/ichthyosaur/snap.wav")
SWEP.Primary.Recoil			= 2
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.2
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ConeMoving		= 0.1
SWEP.Primary.ConeCrouching	= 0.02

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect 			= "none"

--SWEP.IronSightsPos = Vector(6.02,-3,2.3)
--SWEP.IronSightsAng = Vector(2.5,-.21,0)