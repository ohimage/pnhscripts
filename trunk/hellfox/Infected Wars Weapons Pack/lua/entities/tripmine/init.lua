
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	
	self.Entity:DrawShadow( false )
	self.Entity:SetModel( "models/weapons/w_eq_smokegrenade.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetTrigger( true )
	
end

function ENT:Think()
	
	if self.LockPos then
		self.Entity:SetPos(self.LockPos)
		self.Entity:SetAngles(self.LockAngle)
	end
	
	if ( self.AlarmTimer && self.AlarmTimer < CurTime() ) then
		self.AlarmTimer = nil
	end

	if ( self.NotifyTimer && self.NotifyTimer < CurTime() ) then
		self.NotifyTimer = nil
	end

	
end


function ENT:StartTripmineMode( hitpos, forward )
	
	if (hitpos) then self.Entity:SetPos( hitpos ) end
	self.Entity:SetAngles( forward:Angle() + Angle( 90, 0, 0 ) )

	self.LockPos = self.Entity:GetPos()
	self.LockAngle = self.Entity:GetAngles()
	
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + (forward * 4096)
	trace.filter = self.Entity
	trace.mask = MASK_NPCWORLDSTATIC
	local tr = util.TraceLine( trace )

	local ent = ents.Create( "triplaser" )
	ent:SetAngles(self.Entity:GetAngles())
	ent:SetPos( self.Entity:LocalToWorld( Vector( 0, 0, 1) ) )
	ent:Spawn()
	ent:Activate()
	ent:GetTable():SetEndPos( tr.HitPos )	
	ent:SetParent( self.Entity )
	ent:SetOwner( self.Entity )
		
	self.Laser = ent
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetNormal( forward )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 1 )
	util.Effect( "Sparks", effectdata )

end

function ENT:Alarm()

	if ( self.AlarmTimer ) then return end
	
	self.AlarmTimer = CurTime() +  0.90

	self.Entity:EmitSound( Sound("npc/attack_helicopter/aheli_damaged_alarm1.wav", 100, 400) )

end

function ENT:Notify()

	if ( self.NotifyTimer ) then return end
	
	self.NotifyTimer = CurTime() +  0.90

	self.Entity:EmitSound( Sound("npc/scanner/combat_scan2.wav", 200, 120) )

end


/*---------------------------------------------------------
   Name: UpdateTransmitState
   Desc: Set the transmit state
---------------------------------------------------------*/
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

