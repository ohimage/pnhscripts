if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "melee"

if( CLIENT ) then
	SWEP.PrintName = "Tripmine"
	SWEP.DrawCrosshair = false
	SWEP.Slot = 4
	SWEP.SlotPos = 2
end
------------------------------------------------------------------------------------------------------
SWEP.Author			= "" -- Original code by Amps, edited by ClavusElite for the IW gamemode
SWEP.Instructions	= "Stand close to a wall to plant the device. Every enemy that passes the beam will be marked." 
SWEP.NextPlant = 0
------------------------------------------------------------------------------------------------------
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= true
------------------------------------------------------------------------------------------------------
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
------------------------------------------------------------------------------------------------------
SWEP.ViewModel			= "models/weapons/v_eq_smokegrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_smokegrenade.mdl"
------------------------------------------------------------------------------------------------------
SWEP.Primary.Delay			= 1.5 	
SWEP.Primary.Recoil			= 0		
SWEP.Primary.Damage			= 7	
SWEP.Primary.NumShots		= 1		
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 2	
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none"	
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
util.PrecacheSound("weapons/slam/mine_mode.wav")

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
end

SWEP.AddedUpgradeAmmo = false
function SWEP:Deploy()
	if SERVER then
		if self.Owner:HasBought("detecttodestroy") and not self.AddedUpgradeAmmo then
			self.AddedUpgradeAmmo = true
			self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )
		end
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextPlant ) or not self:CanPrimaryAttack() then return end
		self.NextPlant = ( CurTime() + .8 );
	//
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 64
	trace.mask = MASK_NPCWORLDSTATIC
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	//

	if ( tr.Hit ) then
		local ent = ents.Create ("tripmine")
		if ( ent ~= nil and ent:IsValid() ) then
			ent:SetPos(tr.HitPos)
			ent:SetOwner(self.Owner)
			ent:Spawn()
			ent:Activate()
			self.Owner:EmitSound( "weapons/slam/mine_mode.wav" )
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			timer.Create("trippulltimer",0.8,1,function()
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			end,self)
			ent:GetTable():StartTripmineMode( tr.HitPos + tr.HitNormal, tr.HitNormal )
			
			self:TakePrimaryAmmo( 1 )
		end
	end
end

 function SWEP:Reload() 
	return false
 end  

function SWEP:SecondaryAttack()
end 

if CLIENT then
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "4", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end
