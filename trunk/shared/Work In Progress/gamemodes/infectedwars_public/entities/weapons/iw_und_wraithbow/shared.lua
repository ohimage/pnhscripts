if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"

if CLIENT then
	SWEP.PrintName = "Wraith Bow"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	SWEP.IconLetter = "1"
	SWEP.SelectFont = "HL2MPTypeDeath"
	killicon.AddFont("iw_und_wraithbow", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.Base				= "iw_base"

SWEP.Instructions	= "A long range weapon that's more lethal if fired from a longer distance!" 

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = "models/weapons/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/crossbow/fire1.wav")
SWEP.Primary.Recoil			= 14
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.Damage			= 25 // minimum damage, maximum damage is three times as much
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ConeMoving		= 0.1
SWEP.Primary.ConeCrouching	= 0.012
SWEP.Primary.ZoomedCone		= 0.02
SWEP.Primary.ZoomedConeMoving = 0.05
SWEP.Primary.ZoomedConeCrouching = 0.005

SWEP.Secondary.Delay = 0.5

SWEP.ShellEffect 			= "none"

--SWEP.IronSightsPos = Vector(6.02,-3,2.3)
--SWEP.IronSightsAng = Vector(2.5,-.21,0)

function SWEP:SecondaryAttack()
	self.Weapon.NextZoom = self.Weapon.NextZoom or CurTime()
	if CurTime() < self.Weapon.NextZoom then return end
	self.Weapon.NextZoom = CurTime() + self.Secondary.Delay

	local zoomed = !(self.Weapon:GetNetworkedBool("Zoomed", false))
	
	self:SetZoom(zoomed)
end

function SWEP:SetZoom( b )

	if ( self.Weapon:GetNetworkedBool( "Zoomed" ) == b ) then return end
	
	if (b == false) then
		if SERVER then
			self.Owner:SetFOV(70, 0.5)
		end
		self.Primary.Cone			= 0.04
		self.Primary.ConeMoving		= 0.1
		self.Primary.ConeCrouching	= 0.024
	else
		if SERVER then
			self.Owner:SetFOV(30, 0.5)
		end
		self.Primary.Cone			= self.Primary.ZoomedCone
		self.Primary.ConeMoving		= self.Primary.ZoomedConeMoving
		self.Primary.ConeCrouching	= self.Primary.ZoomedConeCrouching
	end
	
	self.Weapon:SetNetworkedBool("Zoomed", b)
end

function SWEP:Reload()
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self:SetZoom(false)	
end

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
	
	-- Increase damage at range
	bullet.Callback = function ( attacker, tr, dmginfo )  
		local ent = tr.Entity
		if ent:IsValid() and ent:IsPlayer() and ent:Team() ~= attacker:Team() then
			local dis = attacker:GetPos():Distance(ent:GetPos())
			dmginfo:SetDamage(math.Clamp(dis/(1200/dmg*3),dmg,dmg*3))
		end
	end
	
	self.Owner:FireBullets(bullet)
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	self:SetZoom(false)
end