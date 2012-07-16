if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "G36"			
	SWEP.Slot = 2
	SWEP.SlotPos = 4
	SWEP.ViewModelFOV = 70
	SWEP.IconLetter = "o"
	killicon.Add( "iw_g36", "killicon/infectedwars/g36", Color(255, 80, 0, 255 ) )
end

SWEP.Base				= "iw_scout" -- use zoom code from scout

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel				= "models/weapons/v_g36c_snipe.mdl"
SWEP.WorldModel				= "models/weapons/infectedwars/w_rif_g36.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_SG550.Single")
SWEP.Primary.Recoil			= 1.8
SWEP.Primary.Unrecoil		= 8
SWEP.Primary.Damage			= 22
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.13
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Cone			= 0.045
SWEP.Primary.ConeMoving		= 0.07
SWEP.Primary.ConeCrouching	= 0.02
SWEP.Primary.OrigCone		= SWEP.Primary.Cone
SWEP.Primary.OrigConeMoving	= SWEP.Primary.ConeMoving
SWEP.Primary.OrigConeCrouching	= SWEP.Primary.ConeCrouching
SWEP.Primary.ZoomedCone		= 0.02
SWEP.Primary.ZoomedConeMoving = 0.06
SWEP.Primary.ZoomedConeCrouching = 0.012

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect			= "rg_shelleject_rifle" 
SWEP.EjectDelay				= 0.1

SWEP.IronSightsPos = Vector (3.5978, -3.9252, 0.5547)
SWEP.IronSightsAng = Vector (0, 0, 0)
