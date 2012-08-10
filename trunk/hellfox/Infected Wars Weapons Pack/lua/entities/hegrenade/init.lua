
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:DrawShadow( false )
	
	// Don't collide with the player
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.timer = CurTime() + 2
end

function ENT:Think()

	// Proximity grenade upgrade
	if ValidEntity(self:GetOwner()) and self:GetOwner():Team() == TEAM_HUMAN then
		if (self:GetOwner():HasBought("proxgrenades")) then
			local found = ents.FindInSphere( self.Entity:GetPos(), 150 )
			for k, pl in pairs(found) do
				if pl:IsPlayer() and pl:Team() == TEAM_UNDEAD 
					and (pl:GetPos()+Vector(0,0,40)):Distance(self.Entity:GetPos()) < 50 then
					self:Explode()
				end
			end
		end
	end

	if self.timer < CurTime() then	
		self:Explode()
	end
end

function ENT:Explode()
	local Ent = ents.Create("env_explosion")
	Ent:EmitSound( "explode_4" )		
	Ent:SetPos(self.Entity:GetPos())
	Ent:Spawn()
	-- Prevent teamdamage when dieing before the grenade goes off
	if not ValidEntity(self:GetOwner()) or self:GetOwner():Team() ~= TEAM_HUMAN then
		Ent:SetOwner(Entity())
	else
		Ent:SetOwner(self:GetOwner())
	end
	Ent.Team = function() 
		return TEAM_HUMAN 
	end
	Ent.GetName = function() 
		return "< Grenade >" 
	end
	Ent:Activate()
	Ent:SetKeyValue("iMagnitude", 200)
	Ent:SetKeyValue("iRadiusOverride", 150)
	Ent.Inflictor = self.Entity:GetClass()
	Ent:Fire("explode", "", 0)
	
	timer.Simple(0,function (me) me:Remove() end,self)
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
end


/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end


/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end


/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end
