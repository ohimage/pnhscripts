if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "Pulse";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15"
SWEP.Contact = "youremail@gmail.com"
SWEP.Purpose = "Vaporize!"
SWEP.Instructions = "Primary to fire a bullet, Secondary to use the guns real power."
SWEP.Category = "HeLLFox_15-SWEPS"
 
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;
 
SWEP.ViewModel = "models/weapons/v_physcannon.mdl";
SWEP.WorldModel = "models/weapons/w_physcannon.mdl";

SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
 
SWEP.Primary.ClipSize = 8;
SWEP.Primary.DefaultClip = 20;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "357";
 
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";
 
SWEP.Sound = Sound ("weapon_357.Single")
SWEP.Damage = 50
SWEP.Spread = 0.02
SWEP.NumBul = 1
SWEP.Delay = 0.6
SWEP.Force = 3
 
function SWEP:Deploy()
return true
end
 
function SWEP:Holster()
return true
end
 
function SWEP:Think()
end
  
function SWEP:SecondaryAttack() // when secondary attack happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
 
	local eyetrace = self.Owner:GetEyeTrace();
	// this gets where you are looking. The SWep is making an explosion where you are LOOKING, right?
 
	self.Weapon:EmitSound ( self.Sound )
	// this makes the sound, which I specified earlier in the code
 
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	//this makes the shooting animation for the 357
 
	local explode = ents.Create( "point_hurt" ) //creates the explosion
	explode:SetPos( eyetrace.HitPos ) //this creates the explosion where you were looking
	explode:SetOwner( self.Owner ) // this sets you as the person who made the explosion
	explode:Spawn() //this actually spawns the explosion
	explode:SetKeyValue( "DamageRadius", "300" ) //the magnitude
	explode:SetKeyValue( "Damage", "99999" ) //the Damage
	explode:SetKeyValue( "DamageType", "256" ) //the Damage Type
	explode:Fire( "Hurt", 0, 0 )
	explode:EmitSound( "weapon_AWP.Single", 50, 50 ) //the sound for the explosion, and how far away it can be heard
	
	local explode = ents.Create("env_ar2explosion") 
	explode:SetPos( eyetrace.HitPos ) 
	explode:SetOwner( self.Owner ) 
	explode:Spawn() 
	explode:SetKeyValue("iMagnitude","575") 
	explode:Fire("Explode", 0, 0 ) 
	explode:EmitSound("weapon_AWP.Single", 50, 50 )
 
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
	//this sets the delay for the next primary and secondary fires.
 
	self:TakePrimaryAmmo(1) //removes 1 ammo from our clip
 
end //telling Gmod that it's the end of the function
 
function SWEP:PrimaryAttack() //when +attack1 happens
 
	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end
 
	local bullet = {} //creates a table for the properties of the bullet
	bullet.Num 		= self.NumBul //number of bullets you are shooting
	bullet.Src 		= self.Owner:GetShootPos() // Source, where you are standing
	bullet.Dir 		= self.Owner:GetAimVector() // direction of bullet, where you are looking
	bullet.Spread 	= Vector( self.Spread, self.Spread, 0 ) // spread of bullet, how accurate it is
	bullet.Tracer	= 0	// this is the beam behind the bullet.
	bullet.Force	= 99999999 // how powerful it is
	bullet.Damage	= 99999999 //how much damage it does to people
	bullet.AmmoType = self.Primary.Ammo //what type of ammo you are using
 
	self.Owner:FireBullets( bullet ) //actually shoots the bullet.
 
	self.Weapon:EmitSound ( self.Sound )
	// this makes the sound, which I specified earlier in the code
 
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	//this makes the shooting animation for the 357
 
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
	//this sets the delay for the next primary and secondary fires.
 
	self:TakePrimaryAmmo(1) //removes 1 ammo from our clip
end //end our function
 
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD ) //animation for reloading
end