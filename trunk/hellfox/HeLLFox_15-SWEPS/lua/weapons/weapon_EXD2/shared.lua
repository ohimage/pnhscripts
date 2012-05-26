if (SERVER) then
AddCSLuaFile ("shared.lua");
end

if (CLIENT) then
SWEP.PrintName = "EXD2";
SWEP.Slot = 2;
SWEP.SlotPos = 4;
SWEP.DrawAmmo = true;
SWEP.DrawCrosshair = true;
end

SWEP.Author = "HeLLFox_15"
SWEP.Contact = "youremail@gmail.com"
SWEP.Purpose = "Blow peaple up."
SWEP.Instructions = "Primary to fire a bullet, Secondary to make an explosion where you are pointing"
SWEP.Category = "HeLLFox_15-SWEPS"
 
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;
 
SWEP.ViewModel = "models/weapons/v_357.mdl";
SWEP.WorldModel = "models/weapons/w_357.mdl";

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
	
	local stSteamID = string.Explode(":", self.Owner:SteamID())
	
	if(stSteamID[1] == "STEAM_0" and stSteamID[2] == "1" and stSteamID[3] == "20305110") then
	
	local explode = ents.Create( "env_explosion" )
	explode:SetPos( eyetrace.HitPos )
	explode:SetOwner( self.Owner )
	explode:Spawn()
	explode:SetKeyValue( "iMagnitude", "220" )
	explode:Fire( "Explode", 0, 0 )
	
	local EffectFire = EffectData()
	EffectFire:SetOrigin( eyetrace.HitPos )
	EffectFire:SetStart( eyetrace.HitPos )
	EffectFire:SetMagnitude(575)
	EffectFire:SetScale(256)
	util.Effect("Explosion", EffectFire)
	
	local EffectExplosion = EffectData()
	EffectExplosion:SetOrigin( eyetrace.HitPos )
	EffectExplosion:SetStart( eyetrace.HitPos )
	EffectExplosion:SetMagnitude(575)
	EffectExplosion:SetScale(575)
	util.Effect("balloon_pop", EffectExplosion)
	
	for _,trga in pairs( ents.FindInSphere(eyetrace.HitPos,258) ) do
		if( trga:IsValid() and not trga:IsNPC() and not trga:IsWorld() ) then
	
			if( trga:IsPlayer() and trga ~= self.Owner ) then
				if( ( trga:Health() - 50 ) <= 0 ) then
					trga:Kill()
					self.Owner:SetFrags( self.Owner:Frags() + 1 )
				else
					trga:SetHealth( trga:Health() - 50 )
					trga:SetVelocity( Vector(0,0,500) )
				end
			end
			
			if not ( trga:IsPlayer() ) then
			
				local stNameExp = string.Explode( "_", trga:GetClass() )
			
				if( trga:GetClass() == "prop_physics" or stNameExp[1] == "gmod" ) then
			
					trga:PhysWake()
			
					local phys = trga:GetPhysicsObject()
					local vecforceapl = ( trga:GetPos() - eyetrace.HitPos ) * ( 9000 * phys:GetMass() )
			
					if not ( trga:IsWorld() ) then
				
						if ( trga:GetParent():IsValid() ) then
							if not ( trga:IsPlayer() ) then
								local EffectParentRemove = EffectData()
								EffectParentRemove:SetOrigin( trga:GetPos() )
								EffectParentRemove:SetStart( trga:GetPos() )
								EffectParentRemove:SetMagnitude(575)
								EffectParentRemove:SetScale(256)
								util.Effect("StriderMuzzleFlash", EffectParentRemove)
						
								trga:Remove()
							end
						end
				
						if not ( trga:GetParent():IsValid() ) then
				
							if( constraint.HasConstraints( trga ) ) then
								constraint.RemoveAll( trga )
							end
					
							phys:EnableMotion(true)
							phys:ApplyForceCenter( vecforceapl )
							trga:SetVelocity( vecforceapl )
							phys:AddVelocity( vecforceapl )
							
						end
					end
				end
			end
		end
	end
	
	end
	
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