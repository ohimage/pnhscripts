if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "shotgun"

if CLIENT then
	SWEP.PrintName = "Semi Spas-12"
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 3
	SWEP.SlotPos = 3
	
	SWEP.IconLetter = "0"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_semispas", SWEP.SelectFont, SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

-- Derive from super90 shotgun
SWEP.Base				= "iw_m3super90"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_shot_shotteh01.mdl"
SWEP.WorldModel			= "models/weapons/infectedwars/w_shot_shotteh01.mdl"

SWEP.Weight				= 10
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/m3/shotteh-1.wav")
SWEP.Primary.Recoil			= 11
SWEP.Primary.Damage			= 13
SWEP.Primary.NumShots		= 10
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 0.95
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize*5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Cone			= 0.15
SWEP.Primary.ConeMoving		= 0.21
SWEP.Primary.ConeCrouching	= 0.12

SWEP.MuzzleEffect			= "rg_muzzle_hmg"
SWEP.ShellEffect			= "rg_shelleject_shotgun" 

SWEP.Tracer 				= ""

--SWEP.IronSightsPos = Vector(5.73,-2,3.375)
--SWEP.IronSightsAng = Vector(0.001,.05,0.001)
