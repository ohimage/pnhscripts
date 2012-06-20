if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "Whistle";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15";
SWEP.Contact = "youremail@gmail.com";
SWEP.Purpose = "Make pets a little easier to kill.";
SWEP.Instructions = "Blowing the whistle makes a special sound that stops the pets health regen.";
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