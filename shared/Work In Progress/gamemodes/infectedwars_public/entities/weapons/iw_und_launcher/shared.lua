--SWEP by ClavusElite

if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "rpg"

if CLIENT then
	SWEP.PrintName		= "Meat Cannon"
	SWEP.Slot			= 2					
	SWEP.SlotPos		= 1	
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false
	SWEP.CSMuzzleFlashes = false
	
	SWEP.IconLetter = "3"
	killicon.AddFont("iw_und_launcher", "HL2MPTypeDeath", SWEP.IconLetter, Color(255, 80, 0, 255 ))
end

SWEP.ViewModel			= "models/weapons/v_RPG.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"
	
-- Other settings
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true
 
-- Primary fire settings
SWEP.Primary.Soundtab		= { Sound("infectedwars/meatrocket1.wav"), Sound("infectedwars/meatrocket2.wav") }

SWEP.Primary.Recoil			= 8
SWEP.Primary.Unrecoil		= 7
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 0
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3
SWEP.Primary.Cone = 0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"
SWEP.Secondary.Delay = 3

function SWEP:Initialize()
	self.NextPrimaryFire = 0
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end
	
	self.NextPrimaryFire = CurTime() + self.Primary.Delay
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:EmitSound(self.Weapon.Primary.Soundtab[math.random(1,2)])

	self:FireRocket( false, 600 )
	
	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))
end

function SWEP:SecondaryAttack()

	if not self:CanPrimaryAttack() then return end
	self.NextPrimaryFire = CurTime() + self.Primary.Delay
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Weapon:EmitSound(self.Weapon.Primary.Soundtab[math.random(1,2)])
	
	self:FireRocket( true, 800 )
	
	self.Owner:ViewPunch(Angle(math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0))
end

function SWEP:FireRocket( Grav, Force )

	if (!SERVER) then return end

	local Rocket = ents.Create("meatrocket")
	
	local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * 6
		v = v + self.Owner:GetRight() * 11
		v = v + self.Owner:GetUp() * 2
	Rocket:SetPos(v)
	Rocket:SetAngles( self.Owner:GetAimVector():Angle() )
	Rocket:SetOwner(self.Owner)
	Rocket:Spawn()
	
	Rocket:Activate()
	Rocket:GetTable():SetRocketGravity( Grav )
	Rocket:SetMaterial("models/flesh")
	
	local Phys = Rocket:GetPhysicsObject()
	
	-- FIRE ZHE ROCKET!
	Phys:SetVelocity(self.Owner:GetAimVector() * Force)
end

function SWEP:CanPrimaryAttack()
	if self.NextPrimaryFire < CurTime() then
		return true
	end
	return false
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(true)
	end
	self:SetColor(255, 255, 255, 255)
	self.Owner:SetColor(255, 255, 255, 255)
	local vm = self.Owner:GetViewModel()
	if vm and vm:IsValid() then
		vm:SetColor(255, 255, 255, 255)
		vm:SetMaterial("models/flesh")
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end 

 function SWEP:PrintWeaponInfo( x, y, alpha )
 end
 
 if CLIENT then
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "3", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	end
end
