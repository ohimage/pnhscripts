if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "M24 Sniper"
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 3
	SWEP.SlotPos = 4
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = true
	
	SWEP.IconLetter = "n"
	killicon.AddFont("iw_m24_snip", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_scout" -- Based on scout sniper code

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel				= "models/weapons/v_lazr_scout.mdl"
SWEP.WorldModel				= "models/weapons/infectedwars/w_lazr_scout.mdl"

SWEP.Weight				= 6
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/turboscout/m24_fire.wav")
SWEP.Primary.Recoil			= 4.0
SWEP.Primary.Damage			= 50
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 1.8
SWEP.Primary.DefaultClip	= 22
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.ReloadDelay	= 1.5
SWEP.Primary.Cone			= 0.1
SWEP.Primary.ConeMoving		= 0.18
SWEP.Primary.ConeCrouching	= 0.07
SWEP.Primary.OrigCone		= SWEP.Primary.Cone
SWEP.Primary.OrigConeMoving	= SWEP.Primary.ConeMoving
SWEP.Primary.OrigConeCrouching	= SWEP.Primary.ConeCrouching
SWEP.Primary.ZoomedCone		= 0.01
SWEP.Primary.ZoomedConeMoving = 0.055
SWEP.Primary.ZoomedConeCrouching = 0

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 
SWEP.ZoomFOV				= 20

SWEP.IronSightsPos = Vector (3.3529, -3.4659, 1.9723)
SWEP.IronSightsAng = Vector (0, 0, 0)
