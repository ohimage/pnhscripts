if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "melee"

if CLIENT then
	SWEP.PrintName = "Ammo Supply"			
	SWEP.Author	= "ClavusElite"
	SWEP.Slot = 3
	SWEP.SlotPos = 2
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
	SWEP.DrawCrosshair = false
end

SWEP.Instructions	= "Drop ammunition for your team."

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/slam/throw.wav")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Unrecoil		= 1
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 5
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0
SWEP.Primary.ConeMoving		= 0
SWEP.Primary.ConeCrouching	= 0

--SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
--SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

local restoretimer = 0

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()

	local ply = self.Owner

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if not self:CanPrimaryAttack() then return end
	
	self:TakePrimaryAmmo(1)
	self.Weapon:EmitSound(self.Weapon.Primary.Sound)
	
	if (!SERVER) then return end
	
	local Box = ents.Create("ammobox")
	local Force = 200
	
	local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * 4
		v = v + self.Owner:GetRight() * 8
		v = v + self.Owner:GetUp() * -3
	Box:SetPos(v)
	Box:SetAngles( self.Owner:GetAimVector():Angle() )
	Box:SetOwner(self.Owner)
	Box:Spawn()
	
	Box:Activate()
	
	local Phys = Box:GetPhysicsObject()
	Phys:SetVelocity((self.Owner:GetAimVector()+Vector(0,0,0.5)) * Force)
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW) 
	if SERVER then
		self.Owner:DrawWorldModel(false)
		self.Owner:DrawViewModel(false)
	end
	self:SetColor(255, 255, 255, 255)
	self.Owner:SetColor(255, 255, 255, 255)
	return true
end

function SWEP:Think()
 
end 

function SWEP:SecondaryAttack()

end

if CLIENT then
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "9", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end