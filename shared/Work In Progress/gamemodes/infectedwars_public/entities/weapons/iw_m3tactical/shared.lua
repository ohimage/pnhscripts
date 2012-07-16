if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "M3 Tactical"
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.IconLetter = "k"
	killicon.AddFont("iw_m3tactical", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

-- Derive from super90 shotgun
SWEP.Base				= "iw_m3super90"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shot_m3tactica.mdl"
SWEP.WorldModel			= "models/weapons/infectedwars/w_shot_m3tactica.mdl"

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/m3/m3tact-1.wav")
SWEP.Primary.Recoil			= 25
SWEP.Primary.Damage			= 12
SWEP.Primary.NumShots		= 10
SWEP.Primary.ClipSize		= 7
SWEP.Primary.Delay			= 0.95
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize*7
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Cone			= 0.1
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.075

SWEP.MuzzleEffect			= "rg_muzzle_hmg"
SWEP.ShellEffect			= "rg_shelleject_shotgun" 

SWEP.Tracer 				= ""

--SWEP.IronSightsPos = Vector(5.73,-2,3.375)
--SWEP.IronSightsAng = Vector(0.001,.05,0.001)

