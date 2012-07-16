if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "smg"

if CLIENT then
	SWEP.PrintName = "MP5"			
	SWEP.Slot = 2
	SWEP.SlotPos = 5
	SWEP.IconLetter = "x"
	killicon.AddFont("iw_mp5", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mp5.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Recoil			= 2.2
SWEP.Primary.Damage			= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.07
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.05

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject" 
