if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "M1014"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.IconLetter = "B"
	killicon.AddFont("iw_m1014", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_m3super90"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_XM1014.Single")
SWEP.Primary.Recoil			= 8
SWEP.Primary.Damage			= 9
SWEP.Primary.NumShots		= 8
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize*7
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.ReloadDelay	= 1
SWEP.Primary.Cone			= 0.13
SWEP.Primary.ConeMoving		= 0.19
SWEP.Primary.ConeCrouching	= 0.1

SWEP.Tracer 				= ""

SWEP.MuzzleEffect			= "rg_muzzle_hmg"
SWEP.ShellEffect			= "rg_shelleject_shotgun" 
SWEP.EjectDelay				= 0.1

--SWEP.IronSightsPos = Vector(5.16,-3.5,2.155)
--SWEP.IronSightsAng = Vector(0.001,.75,0.001)

SWEP.Reloadstopdelay = 0.3
