SWEP.Author = "" -- ClavusElite
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Give a deadly stab to your enemies. Alternate fire lets you switch places with an enemy and take his appearance."

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Spawnable = true
SWEP.AdminSpawnable	= true

SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 25
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Reload()
	return false
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
	util.PrecacheSound("weapons/knife/knife_hit1.wav")
	util.PrecacheSound("weapons/knife/knife_hit2.wav")
	util.PrecacheSound("weapons/knife/knife_hit3.wav")
	util.PrecacheSound("weapons/knife/knife_hit4.wav")
	util.PrecacheSound("weapons/knife/knife_slash1.wav")
	util.PrecacheSound("weapons/knife/knife_slash2.wav")
	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(false)
		self.Owner:DrawViewModel(true)
	end
	local vm = self.Owner:GetViewModel()
	if vm and vm:IsValid() then
		vm:SetColor(255, 255, 255, 255)
		vm:SetMaterial("")
	end
	if self and self:IsValid() then
		self:SetColor(255, 255, 255, 255)
		self.Owner:SetColor(255, 255, 255, 255)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end 

function SWEP:Think()
	if (self.Owner:IsValid()) then
		local vm = self.Owner:GetViewModel()
		if vm and vm:IsValid() then
			local _,_,_,a = self.Owner:GetColor()
			vm:SetColor(20, 20, 20, a)
		end
	end
end

function SWEP:Holster()
	local vm = self.Owner:GetViewModel()
	if vm and vm:IsValid() then
		vm:SetColor(255, 255, 255, 255)
	end
	if SERVER then
		self:DeShift()
	end
	self:SetColor(255, 255, 255, 255)
	self.Owner:SetColor(255, 255, 255, 255)
	return true
end

SWEP.screamTimer = 0

function SWEP:SecondaryAttack()
	
	if ( !self:CanSecondaryAttack() ) then return end
	self.screamTimer = CurTime()+5
	
end

function SWEP:CanSecondaryAttack()
	
	return self.screamTimer < CurTime()
	
end
