if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "grenade"

if CLIENT then
	SWEP.PrintName = "Infection Ball"			
	SWEP.Author	= "" -- ClavusElite
	SWEP.Slot = 3
	SWEP.SlotPos = 3
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
end

SWEP.Instructions = "Throw at enemies. Heavily drains enemy suit power on impact. Will also mark players so other undead can track them." 

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = "models/weapons/V_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/slam/throw.wav")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Unrecoil		= 1
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 1.5
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Cone			= 0
SWEP.Primary.ConeMoving		= 0
SWEP.Primary.ConeCrouching	= 0

--SWEP.IronSightsPos = Vector(-4.5, -9.6, 3.1)
--SWEP.IronSightsAng = Vector(1.1, 0.6, -3.3)

util.PrecacheSound("infectedwars/roar1.wav")
util.PrecacheSound("infectedwars/roar2.wav")

local restoretimer = 0

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()

	local ply = self.Owner

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if not self:CanPrimaryAttack() then return end
	
	self:TakePrimaryAmmo(1)
	
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	timer.Create("balldraw",0.5,1,function()
		if self.Weapon and self.Weapon:IsValid() then
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	end,self)
	self.Weapon:EmitSound(self.Weapon.Primary.Sound)
	
	if (!SERVER) then return end
	
	local rep = 1
	if self.Owner:HasBought("spreadtheplague") then
		rep = 3
	end
	
	for k = 1, rep do
		local Ball = ents.Create("infectionball")
		local Force = 800
		
		local v = self.Owner:GetShootPos()
			v = v + self.Owner:GetForward() * 4
			v = v + self.Owner:GetRight() * 3
			v = v + self.Owner:GetUp() * -3
		Ball:SetPos(v)
		Ball:SetAngles( self.Owner:GetAimVector():Angle() )
		Ball:SetOwner(self.Owner)
		Ball:Spawn()
		
		Ball:Activate()
		Ball:SetMaterial("models/flesh")
		
		local addvector = Vector(0,0,0)
		if k == 2 then
			addvector = self.Owner:GetRight()*0.1
		elseif k == 3 then
			addvector = self.Owner:GetRight()*-0.1
		end
		
		local Phys = Ball:GetPhysicsObject()
		Phys:SetVelocity((self.Owner:GetAimVector()+Vector(0,0,0.1)+addvector):GetNormal() * Force)
	end
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(true)
		self.Owner:DrawViewModel(true)
	end
	local vm = self.Owner:GetViewModel()
	if vm and vm:IsValid() then
		vm:SetColor(255, 255, 255, 255)
		vm:SetMaterial("models/flesh")
	end
	if self and self:IsValid() then
		self:SetColor(255, 255, 255, 255)
		self.Owner:SetColor(255, 255, 255, 255)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	timer.Destroy("balldraw")
	return true
end

function SWEP:Think()
 
end 

local screamtimer = 0

function SWEP:SecondaryAttack()
	if screamtimer < CurTime() then
		screamtimer = CurTime()+2
		self.Owner:EmitSound("infectedwars/roar"..math.random(1,2)..".wav")
	end
end

if CLIENT then
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "5", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end
