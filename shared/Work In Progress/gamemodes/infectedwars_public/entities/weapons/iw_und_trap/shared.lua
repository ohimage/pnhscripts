if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "grenade"

if CLIENT then
	SWEP.PrintName = "Energy Trap"			
	SWEP.Author	= "" -- ClavusElite
	SWEP.DrawCrosshair = false
	SWEP.Slot = 2
	SWEP.SlotPos = 2
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60
end

SWEP.Instructions = "Explodes in a cloud of black smoke on impact. Blinds nearby enemies for a few seconds." 

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("weapons/slam/throw.wav")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Unrecoil		= 1
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize		= 3
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 3
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
	
	if (!SERVER) then return end
	
	self:TakePrimaryAmmo(1)
	
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 84
	trace.mask = MASK_NPCWORLDSTATIC
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	
	if ( tr.Hit ) then
		
		local ent = ents.Create ("trap")
		if ( ValidEntity(ent) ) then
			ent:SetPos(tr.HitPos)
			ent:SetAngles(tr.HitNormal:Angle())
			ent:SetOwner(self.Owner)
			ent:Spawn()
			ent:Activate()
		end	
		
	end
		
	if CLIENT then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end

end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(false)
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
		draw.SimpleText( "8", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end

