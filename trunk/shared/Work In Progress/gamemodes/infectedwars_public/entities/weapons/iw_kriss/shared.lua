if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "smg"

if CLIENT then
	SWEP.PrintName = "Kriss"			
	SWEP.Slot = 2
	SWEP.SlotPos = 5
	SWEP.IconLetter = "x"
	killicon.Add( "iw_kriss", "killicon/infectedwars/kriss", Color(255, 80, 0, 255 ) )
	--killicon.AddFont("iw_kriss", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_kriss.mdl"
SWEP.WorldModel			= "models/weapons/infectedwars/w_smg_kriss.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/Kriss/kriss-2.wav")
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 28
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.065
SWEP.Primary.ConeMoving		= 0.14
SWEP.Primary.ConeCrouching	= 0.045

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject" 

--SWEP.IronSightsPos = Vector(4.72,-2,1.86)
--SWEP.IronSightsAng = Vector(1.2,-.15,0)