if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "melee"

if( CLIENT ) then
	SWEP.PrintName = "Proximity Mine"
	SWEP.Slot = 3
	SWEP.SlotPos = 1
	SWEP.DrawCrosshair = false
end
------------------------------------------------------------------------------------------------------
SWEP.Author			= "" -- Original code by Amps, edited by ClavusElite for the IW gamemode
SWEP.Instructions	= "Stand close to a wall to plant the mine. Detonates when enemy is within visible range." 
SWEP.NextPlant = 0
------------------------------------------------------------------------------------------------------
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= true
------------------------------------------------------------------------------------------------------
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
------------------------------------------------------------------------------------------------------
SWEP.ViewModel      = "models/weapons/v_c4.mdl"
SWEP.WorldModel   = "models/weapons/w_c4.mdl"
------------------------------------------------------------------------------------------------------
SWEP.Primary.Delay			= 0.9 	
SWEP.Primary.Recoil			= 0		
SWEP.Primary.Damage			= 7	
SWEP.Primary.NumShots		= 1		
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 5	
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "slam"	
------------------------------------------------------------------------------------------------------
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 6
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"
------------------------------------------------------------------------------------------------------
//Preload
util.PrecacheSound("weapons/c4/c4_beep1.wav")
util.PrecacheSound("weapons/c4/c4_plant.wav")

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
end

function SWEP:Deploy()
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextPlant ) or not self:CanPrimaryAttack() or not SERVER then return end
	self.NextPlant = ( CurTime() + self.Primary.Delay )
	//
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64
	trace.mask = MASK_NPCWORLDSTATIC
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	//

	if ( tr.Hit ) then
		local ent = ents.Create ("proxbomb")
		if ( ent ~= nil and ent:IsValid() ) then
			ent:SetPos(tr.HitPos)		
			ent:SetOwner(self.Owner)
			ent:Spawn()
			ent:Activate()
			self.Owner:EmitSound( "weapons/c4/c4_plant.wav" )
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			ent:WallPlant( tr.HitPos + tr.HitNormal, tr.HitNormal )
			ent:SetCloak( self.Owner:HasBought("opticalobliteration") )
			
			self:TakePrimaryAmmo( 1 )
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) <= 0 then
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.NextPlant = ( CurTime() + self.Primary.Delay )
		return false
	end
	return true
end

function SWEP:Reload() 
	return false
end  

function SWEP:SecondaryAttack()
end 

if CLIENT then
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "*", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end
