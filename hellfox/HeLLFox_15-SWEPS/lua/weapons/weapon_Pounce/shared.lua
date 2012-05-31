if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "Pounce";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15"
SWEP.Contact = "youremail@gmail.com"
SWEP.Purpose = "Pounce"
SWEP.Instructions = "Primary Scratch, Secondary jump at a player."
SWEP.Category = "HeLLFox_15-SWEPS"

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
 
function SWEP:Initialize()
	self:SetWeaponHoldType("physgun")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawViewModel(false)
		self.Owner:DrawWorldModel(false)
	end
end
 
function SWEP:Think()
end
  
function SWEP:SecondaryAttack() // when secondary attack happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
 
	self.Weapon:EmitSound ( "npc/fast_zombie/leap1.wav" )
    
    self.Owner:SetVelocity((self.Owner:GetForward() * 320) + Vector(0,0,150))
 
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
	self.Weapon:SetNextSecondaryFire( CurTime() + 3 )
	//this sets the delay for the next primary and secondary fires.
end //telling Gmod that it's the end of the function
 
function SWEP:PrimaryAttack() //when +attack1 happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
    if ( SERVER ) then
        local eyetrace = self.Owner:GetEyeTrace()
        local phys = eyetrace.Entity:GetPhysicsObject()
       
        if ( eyetrace.HitPos:Distance(self.Owner:GetPos()) < 100 ) then
            self.Weapon:EmitSound ( "npc/fast_zombie/claw_strike"..math.random(1,3)..".wav" )
            if ( eyetrace.Entity:IsValid() and eyetrace.Entity:IsPlayer() or eyetrace.Entity:IsNPC() ) then 
                eyetrace.Entity:TakeDamage( math.random(15,100), self.Owner, self.Owner )
                eyetrace.Entity:SetVelocity((eyetrace.Entity:GetForward() * -64) + Vector(0,0,32))
            elseif ( phys and phys:IsValid() and phys:IsMoveable() ) then
                phys:Wake()
                phys:SetVelocity((eyetrace.Entity:GetForward() * -640) + Vector(0,0,74))
            end
        else
            self.Weapon:EmitSound ( "npc/vort/claw_swing"..math.random(1,2)..".wav" )
        end
    end
    self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
end //end our function
 
function SWEP:Reload()
    return true
end