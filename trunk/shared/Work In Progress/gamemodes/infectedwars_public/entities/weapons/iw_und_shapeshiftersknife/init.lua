AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Think()
	if self.Owner:IsValid() and not self.Owner.Disguised then
		local div = 2
		if (self.Owner.EquipedSuit == "stalkerghostsuit") then
			div = 3
			if self.Owner:Crouching() then
				div = 20
			end
		end
		self.Owner:SetColor(200, 200, 200, math.Clamp(self.Owner:GetVelocity():Length()/div, 10, 100))
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CurTime() < self.Weapon:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end
	self.Owner:LagCompensation(true)

	self:DeShift()
	
	local trace = self.Owner:TraceLine(70)
	local ent = nil

	if trace.HitNonWorld then
		ent = trace.Entity
	end

	if trace.Hit then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			self.Owner:EmitSound("weapons/knife/knife_hit"..math.random(1,4)..".wav")
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			self.Owner:EmitSound("weapons/knife/knife_hitwall1.wav")
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	end

	if ent and ent:IsValid() then
	    ent:TakeDamage(self.Primary.Damage, self.Owner)
	end

	if self.Alternate then
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	else
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	end
	self.Alternate = not self.Alternate

	self.Owner:EmitSound("weapons/knife/knife_slash"..math.random(1,2)..".wav")
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:LagCompensation(false)
end

SWEP.TargetEnt = nil

function SWEP:SecondaryAttack()
	
	if ( !self:CanSecondaryAttack() ) then return end
	self.screamTimer = CurTime()+5
	
	self.TargetEnt = self:TraceTarget()
	if self.TargetEnt ~= nil and self.TargetEnt:IsPlayer() then
		timer.Simple(2,self.ShapeShift,self)
		self.Owner:ChatPrint("(SHAPESHIFT) Acquired victim, focussing...")
		self.Owner:Freeze(true)
		return
	end
	
	self.Owner:ChatPrint("(SHAPESHIFT) No victim in range")
	
end

function SWEP:ShapeShift()
	if not self.Owner then return end
	if not self.Owner:IsValid() then return end
	if not self.Owner:Alive() or self.Owner:GetActiveWeapon() ~= self.Weapon then return end
	
	local ent = self:TraceTarget()
	if not ValidEntity( self.TargetEnt ) or self.TargetEnt ~= ent or not self.TargetEnt:Alive() then
		self.Owner:ChatPrint("(SHAPESHIFT) Failure! Victim no longer within focus")
		self.Owner:Freeze(false)
		return
	end
	
	local holdtype = "ar2"
	local model = ent:GetModel()
	local worldmodel = "models/weapons/w_rif_m4a1.mdl"
	
	local wep = ent:GetActiveWeapon()
	if ValidEntity( wep ) then
		if wep.HoldType then
			holdtype = wep.HoldType
		end
		if wep.WorldModel then
			worldmodel = wep.WorldModel
		end
	end
	
	self:SetWeaponHoldType(holdtype)
	self.Owner:SetModel(model)
	self.WorldModel = worldmodel
	self:CallOnClient("SetWorldModel",worldmodel)
	
	self.Owner:Freeze(false)
	self.Owner:SetColor(255,255,255,255)
	
	self.Owner:DrawWorldModel(true)
	
	local revpos = self.Owner:GetPos()
	local revangle = self.Owner:GetAimVector():Angle()
	self.Owner:SetPos(ent:GetPos())
	self.Owner:SetEyeAngles(ent:GetAimVector():Angle())
	ent:SetPos(revpos)
	ent:SetEyeAngles(revangle)
	
	self.Owner.Disguised = true
	self.Owner:ChatPrint("(SHAPESHIFT) Succes!")
	
	self.Owner:SelectWeapon(self.Weapon:GetClass())
end

function SWEP:DeShift()
	if self.Owner.Disguised then
		self.Owner:DrawWorldModel(false)
		self.Owner.Disguised = false
		self.Owner:SetModel(UndeadClass[3].Model)
		self:SetWeaponHoldType(self.HoldType)
		self.WorldModel = "models/weapons/w_knife_t.mdl"
		self:CallOnClient("SetWorldModel","models/weapons/w_knife_t.mdl")
		self.Owner:ChatPrint("(SHAPESHIFT) Disguise dropped!")
	end
end

function SWEP:TraceTarget()
	
	local trace = self.Owner:TraceLine(2048)
	
	if trace.Hit and trace.HitNonWorld then
		return trace.Entity
	end
	
	return nil

end