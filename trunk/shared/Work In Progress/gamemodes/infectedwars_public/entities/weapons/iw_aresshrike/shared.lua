if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "smg"

if CLIENT then
	SWEP.PrintName = "Ares Shrike"			
	SWEP.Slot = 2
	SWEP.SlotPos = 8
	SWEP.IconLetter = "z"
	SWEP.ViewModelFlip = false
	killicon.Add( "iw_aresshrike", "killicon/infectedwars/aresshrike", Color(255, 80, 0, 255 ) )
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_ares_shrikesb.mdl"
SWEP.WorldModel			= "models/weapons/infectedwars/w_ares_shrikesb.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/m249/ares_shrike-2.wav")
SWEP.Primary.Recoil			= 3.2
SWEP.Primary.Unrecoil		= 9
SWEP.Primary.Damage			= 17
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 100
SWEP.Primary.Delay			= 0.09
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.05
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.035

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 

--SWEP.IronSightsPos = Vector(-4.49,-2,2.15)
--SWEP.IronSightsAng = Vector(.00001,-.06,.00001)