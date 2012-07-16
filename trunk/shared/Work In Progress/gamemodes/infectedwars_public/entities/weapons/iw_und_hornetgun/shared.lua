if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "pistol"

if CLIENT then
	SWEP.PrintName = "Hornet Gun"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	
	SWEP.IconLetter = "-"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_und_hornetgun", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("infectedwars/hornetgun.wav")
SWEP.Primary.Recoil			= 2
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 8
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone			= 0.03
SWEP.Primary.ConeMoving		= 0.11
SWEP.Primary.ConeCrouching	= 0.02

SWEP.MuzzleEffect			= "rg_muzzle_pistol"

--SWEP.IronSightsPos = Vector(-5.5, -8.2, 3.9)
--SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:ShootBullet(dmg, numbul, cone)
	local bullet = {}
	bullet.Num = numbul
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.Force = dmg * 0.5
	bullet.Damage = dmg
	bullet.TracerName = "black_tracer"
	-- Leech HP
	bullet.Callback = function ( attacker, tr, dmginfo )  
		local ent = tr.Entity
		if ent:IsValid() and ent:IsPlayer() then
			if ent:Team() ~= attacker:Team() then
				local multiplier = 1
				if attacker:HasBought("leech") then multiplier = 1.25 end
				attacker:SetHealth( math.min(attacker:Health()+dmginfo:GetDamage()*multiplier,attacker:GetMaximumHealth()) )
			end
		end
	end
	
	self.Owner:FireBullets(bullet)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end
