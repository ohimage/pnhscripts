if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "Bite";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15";
SWEP.Contact = "youremail@gmail.com";
SWEP.Purpose = "Bite";
SWEP.Instructions = "Bite some one take their health!";
SWEP.Category = "Pet-SWEPS";

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
   
function SWEP:PrimaryAttack() //when +attack1 happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
        
        local eyetrace = self.Owner:GetEyeTrace()
        
        if ( eyetrace.HitPos:Distance(self.Owner:GetPos()) < 100 ) then
            self.Weapon:EmitSound ( "npc/headcrab/headbite.wav" )
            
            local dmg = math.random(40,55)
            local hp = self.Owner:Health()
            
            if ( eyetrace.Entity:IsValid() and eyetrace.Entity:IsPlayer() ) then
                
                if ( self.Owner:Health() < hp ) then 
                    self.Owner:SetHealth((self.Owner:Health() - dmg) + eyetrace.Entity:Health())
                end
                
                if ( self.Owner:Health() > hp ) then self.Owner:SetHealth( hp ) end
                
                eyetrace.Entity:TakeDamage( dmg, self.Owner, self.Owner:GetActiveWeapon() )
                eyetrace.Entity:SetVelocity(((self.Owner:GetPos() - eyetrace.Entity:GetPos()) * 32) + Vector(0,0,32))
            end
            self.Weapon:EmitSound ( "npc/fast_zombie/fz_frenzy1.wav")
        else
            self.Weapon:EmitSound ( "npc/headcrab/headbite.wav" )
        end
    
    self.Weapon:SetNextPrimaryFire( CurTime() + 5 )
end //end our function

function SWEP:SecondaryAttack() // when secondary attack happens
    // if ( self.Owner:Team() == TEAM_pet ) then end
    return
end //telling Gmod that it's the end of the function
 
function SWEP:Reload()
    return true
end