if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "Claws";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15";
SWEP.Contact = "youremail@gmail.com";
SWEP.Purpose = "Pounce";
SWEP.Instructions = "Primary Scratch, Secondary jump at a player.";
SWEP.Category = "Pet-SWEPS";

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;

SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
 
SWEP.Primary.ClipSize = 100;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";
 
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "";

SWEP.MinDamage = 5
SWEP.MaxDamage = 35

function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
		self.Owner:DrawWorldModel(false)
	end
end

function SWEP:OnDrop()
    self.Weapon:Remove()
end 

function SWEP:Think()
    if not( self.Owner:IsAdmin() or self.Owner:IsSuperAdmin() ) then
        self.Weapon:Remove()
    end
end
  
function SWEP:SecondaryAttack() // when secondary attack happens
 
	// Make sure we can shoot first
	if not( self:CanPrimaryAttack() ) then return end  
    
    self.Owner:SetGravity(1)
	self.Weapon:EmitSound ( "npc/fast_zombie/leap1.wav" )
    self.Owner:SetVelocity((self.Owner:GetForward() * 320) + Vector(0,0,150))
 
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )
	//this sets the delay for the next primary and secondary fires.
end //telling Gmod that it's the end of the function
 
function SWEP:PrimaryAttack() //when +attack1 happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
    
    local dmg = math.random(self.MinDamage,self.MaxDamage)
    
    local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 70 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)

	if ( trace.Hit ) then
        local ent = trace.Entity
		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 999999
			bullet.Damage = dmg + 15
            if( SERVER ) then trace.Entity:Ignite(15,0) end
			self.Owner:FireBullets(bullet)
			self.Weapon:EmitSound ( "npc/fast_zombie/claw_strike"..math.random(1,3)..".wav" )
		else
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 999999
			bullet.Damage = dmg + 15
			self.Owner:FireBullets(bullet)
            self.Weapon:EmitSound ( "npc/fast_zombie/claw_strike"..math.random(1,3)..".wav" )
		end
    else
        self.Weapon:EmitSound ( "npc/vort/claw_swing"..math.random(1,2)..".wav" )
    end
    
end //end our function
 
function SWEP:Reload()
    return false
end