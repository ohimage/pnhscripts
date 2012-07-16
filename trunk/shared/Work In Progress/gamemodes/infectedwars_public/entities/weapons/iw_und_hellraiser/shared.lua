if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Hellraiser"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false
	
	SWEP.IconLetter = "v"
	killicon.AddFont("iw_und_hellraiser", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("npc/antlion/foot1.wav")
SWEP.Primary.Recoil			= 4
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 3
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 20
SWEP.Primary.Delay			= 0.11
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone			= 0.06
SWEP.Primary.ConeMoving		= 0.15
SWEP.Primary.ConeCrouching	= 0.04

SWEP.MuzzleEffect			= "rg_muzzle_rifle"
SWEP.ShellEffect 			= "none"

--SWEP.IronSightsPos = Vector(6.02,-3,2.3)
--SWEP.IronSightsAng = Vector(2.5,-.21,0)

function SWEP:ShootBullet(dmg, numbul, cone)
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.Force = dmg * 0.5
	bullet.Damage = dmg
	bullet.TracerName = "AR2Tracer"
	-- Drain suit power
	bullet.Callback = function ( attacker, tr, dmginfo )  
		if CLIENT then return end
		local ent = tr.Entity
		if ent:IsValid() and ent:IsPlayer() then
			if ent:Team() == TEAM_HUMAN then
				ent:SetSuitPower( ent:SuitPower() - 15 )
			end
		end
	end
	
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end