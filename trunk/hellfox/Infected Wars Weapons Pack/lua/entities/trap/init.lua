
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	local hp = 10

	self.Entity:SetNetworkedFloat( "health", hp )

	self.Dead = false

	WorldSound( self.PlaceSound, self.Entity:GetPos()+self.Entity:GetAngles():Forward()*2 )

	self.Entity:DrawShadow( false )
	self.Entity:SetColor(255,150,150,255)
	self.Entity:SetModel( "models/Gibs/HGIBS.mdl" )
	self.Entity:PhysicsInitSphere( 12 )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetMoveType(MOVETYPE_NONE)
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.PhysObj:EnableGravity( false )
	self.PhysObj:Wake()

end

function ENT:Alive()
	return not self.Dead
end

function ENT:Eliminate( attacker )

	self.Dead = true
	WorldSound( self.SoundDeath, self.Entity:GetPos()+self.Entity:GetAngles():Forward()*2 )

	timer.Simple(0,function(me) 
		if not ValidEntity(me.Entity) then return end
		me.Entity:Remove() end,
		self)

end

function ENT:Think()

	if (not self:GetOwner() or not self:GetOwner():IsValid() or not self:GetOwner():Alive()) and not self.Dead then
		self:Eliminate()
	end

	self.PhysObj:Wake()
	
	self:DrainArea()
	
	self.Entity:NextThink(CurTime()+0.05)
	return true
	
end

function ENT:DrainArea()

	local entsindahood = ents.FindInSphere( self.Entity:GetPos(), 200 )

	for k, ent in pairs(entsindahood) do
		if (ent:IsPlayer() and ent:Team() == TEAM_HUMAN and 
			((ent:GetPos()+Vector(0,0,30))-self.Entity:GetPos()):GetNormal():Dot(self.Entity:GetAngles():Forward()) > 0.1) then
		
			local trace = {}
			trace.start = self.Entity:GetPos()+self.Entity:GetAngles():Forward()*2
			trace.endpos = ent:GetPos()+Vector(0,0,30)
			trace.mask = MASK_NPCWORLDSTATIC
			local tr = util.TraceLine( trace )
			
			local energy_loss = math.floor(ent:GetVelocity():Length()/150)
			
			if !( tr.Hit ) and energy_loss > 0 then
				ent:SetSuitPower(ent:SuitPower()-energy_loss)
			end
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() ~= self:Team() and not self.Dead then

		self.Entity:SetNetworkedFloat( "health", math.max(0,self.Entity:GetNetworkedFloat("health") - dmginfo:GetDamage()) )
		if self.Entity:GetNetworkedFloat("health") <= 0 then 
			self.Dead = true
			timer.Simple(0,self.Eliminate,self,dmginfo:GetAttacker())
		end
	end

end

	
/*---------------------------------------------------------
   Name: UpdateTransmitState
   Desc: Set the transmit state
---------------------------------------------------------*/
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

