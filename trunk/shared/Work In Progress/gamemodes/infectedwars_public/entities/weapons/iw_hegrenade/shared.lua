
if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight	= 5
end

SWEP.HoldType = "grenade"

if (CLIENT) then
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 80
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false
	
	SWEP.PrintName			= "High-Explosive Grenade"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "O"
	
	killicon.AddFont("iw_hegrenade","CSKillIcons",SWEP.IconLetter,Color(255,80,0,255))
end

SWEP.Author	= "" -- original code by Night-Eagle, edited by ClavusElite for IW
SWEP.Instructions = "Pull pin. Toss away. In that order." 

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Primary.Sound			= Sound("Default.PullPin_Grenade")
SWEP.Primary.Recoil			= 0
SWEP.Primary.Unrecoil		= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 1

SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "grenade"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Next = CurTime()
SWEP.Primed = 0
SWEP.ThrowCharge = 0
SWEP.ChargeStart = 0
SWEP.MaxCharge = 2

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Reload()
	return false
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW) 
	self:SetColor(255, 255, 255, 255)
	self.Owner:SetColor(255, 255, 255, 255)
	return true
end

function SWEP:Holster()
	self.Next = CurTime()
	self.Primed = 0
	return true
end

function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim( ACT_VM_THROW ) 		// View model animation
	//self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
end

function SWEP:PrimaryAttack()
	if self.Next < CurTime() and self.Primed == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Next = CurTime() + self.Primary.Delay
		
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Primed = 1
		self.ChargeStart = CurTime()
		self.ThrowCharge = 0
		//self.Weapon:EmitSound(self.Primary.Sound)
	end
end

function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK) and self.Primed == 1 then
		self.ThrowCharge = math.min(CurTime()-self.ChargeStart,self.MaxCharge)
	end
	if self.Next < CurTime() then
		if self.Primed == 1 and not self.Owner:KeyDown(IN_ATTACK) then
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
			self.Primed = 2
			self.Next = CurTime() + .3
		elseif self.Primed == 2 then
			self.Primed = 0
			self.Next = CurTime() + self.Primary.Delay
			
			if SERVER then
				local ent = ents.Create("hegrenade")
				
				local v = self.Owner:GetShootPos()
					v = v + self.Owner:GetForward() * 4
					v = v + self.Owner:GetRight() * 3
					v = v + self.Owner:GetUp() * -3
		
				ent:SetPos(v)
				ent:SetAngles(Vector(1,0,0):Angle())
				ent:Spawn()
				ent:SetOwner(self.Owner)
				
				local phys = ent:GetPhysicsObject()
				phys:SetVelocity((self.Owner:GetAimVector()+Vector(0,0,0.1)) * (400+800*self.ThrowCharge/self.MaxCharge))
				phys:AddAngleVelocity(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
				
				self.Owner:RemoveAmmo(1,self.Primary.Ammo)
				
				if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
					self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
				end
			end
		end
	end
end

if CLIENT then
	
	function SWEP:DrawHUD()
		if self.Primed > 0 then
			local x = w-240
			local y = h-80
			local wi = 130
			local he = 25
		
			surface.SetDrawColor( 0, 0, 0, 80 )
			surface.DrawRect(x,y,wi,he)
			
			surface.SetDrawColor( 0, 100, 220, 255 )
			surface.DrawRect(x,y,wi*self.ThrowCharge/self.MaxCharge,he)
			
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetFont("InfoSmall")
			surface.SetTextPos(x+5,y+4)
			surface.DrawText("FORCE")
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect(x,y,wi,he)
			surface.DrawOutlinedRect(x-1,y-1,wi+2,he+2)
		end
	end

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "h", "CSSelectIcons", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end
