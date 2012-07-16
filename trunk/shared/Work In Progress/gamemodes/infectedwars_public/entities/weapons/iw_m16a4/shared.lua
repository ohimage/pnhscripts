if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "M16A4"			
	SWEP.Slot = 2
	SWEP.SlotPos = 4
	SWEP.IconLetter = "w"
	killicon.AddFont("iw_m16a4", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_m16_a4mm.mdl"
SWEP.WorldModel			= "models/weapons/infectedwars/w_m16_a4mm.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/m16a4/m16a4-1.wav")
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Unrecoil		= 11
SWEP.Primary.Damage			= 19
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.045
SWEP.Primary.ConeMoving		= 0.1
SWEP.Primary.ConeCrouching	= 0.024

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(5.1, -4, 1.5)
--SWEP.IronSightsAng = Vector(0,0,0)