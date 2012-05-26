
if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
end

if (CLIENT) then
	SWEP.PrintName 		= "HF14-AR3"
	SWEP.Slot 			= 4
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= "x"
	SWEP.ViewModelFlip		= true

	killicon.AddFont("weapon_real_cs_mp5a4", "CSKillIcons", SWEP.IconLetter, Color( 10, 255, 0, 255 ))
end

SWEP.Instructions 		= "Damage: 9000% \nRecoil: 1% \nPrecision: 83% \nType: Automatic \nRate of Fire: 800 rounds per minute \n\nChange Mode: E + Right Click"

SWEP.Category = "HeLLFox_15-SWEPS"

SWEP.Base 				= "weapon_real_base_smg"
	
	SWEP.Spawnable			= false
	SWEP.AdminSpawnable		= true

	SWEP.Viewmodel			= "models/weapons/v_smg_mp5.mdl"
	SWEP.PlayerModel		= "models/weapons/w_smg_mp5.mdl"

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

	SWEP.Primary.Sound		= Sound("Weapon_AR2.Single")
	SWEP.Primary.Recoil		= 0.1
	SWEP.Primary.Damage		= 9000
	SWEP.Primary.NumShots		= 1
	SWEP.Primary.Cone		= 0.01
	SWEP.Primary.ClipSize		= 100
	SWEP.Primary.Delay		= 0
	SWEP.Primary.DefaultClip	= 100
	SWEP.Primary.Automatic		= true
	SWEP.Primary.Ammo		= "smg1"
	
	SWEP.Secondary.ClipSize 	= -1
	SWEP.Secondary.DefaultClip 	= -1
	SWEP.Secondary.Automatic 	= false
	SWEP.Secondary.Ammo 		= "none"

	SWEP.IronSightsPos 		= Vector (4.7494, -4.114, 1.9335)
	SWEP.IronSightsAng 		= Vector (1.018, -0.0187, 0)