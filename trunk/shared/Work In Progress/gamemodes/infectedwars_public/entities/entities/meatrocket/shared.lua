AddCSLuaFile("shared.lua")

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= "ClavusElite"
ENT.Purpose			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

util.PrecacheModel("models/props_junk/watermelon01.mdl")

if CLIENT then

	killicon.AddFont("meatrocket", "HL2MPTypeDeath", "3", Color(255, 80, 0, 255 ))
	
	function ENT:Draw()
		self.BaseClass.Draw(self)
	end

	function ENT:OnRemove()
		function self:Think() end
	end

	function ENT:Think()
	
		local spawnPos = self.Entity:GetPos()-self.Entity:GetForward()
		
		-- Muzzleflash fire timer
		self.FireTimer = self.FireTimer or (CurTime()+0.005)
		if ( self.FireTimer <= CurTime() ) then
			self.FireTimer = CurTime() + 0.005
			-- Muzzleflash effect, cheap way to get a propelling fire
			
			local effectdata = EffectData() 
		 	effectdata:SetOrigin( spawnPos ) 
			effectdata:SetAngle( (self.Entity:GetVelocity():GetNormal()*-1):Angle() ) 
			effectdata:SetScale( 3 ) -- Let's size things up a bit
		 	util.Effect( "MuzzleEffect", effectdata ) 
		end
		
		-- Smoke timer
		self.SmokeTimer = self.SmokeTimer or (CurTime()+0.01)
		if ( self.SmokeTimer <= CurTime() ) then 
			self.SmokeTimer = CurTime() + 0.01
			-- Smoke effects
			local emitter = ParticleEmitter( spawnPos )
			local particle = emitter:Add( "particles/smokey", spawnPos )
			particle:SetVelocity( self.Entity:GetForward():GetNormalized()*math.Rand( 10, 20 ) )
			particle:SetDieTime( 0.5 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 10, 20 ) )
			particle:SetEndSize( math.Rand( 30, 70 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 160, 50, 50 )
					
			emitter:Finish()
		end
		
	end
end

if SERVER then

	ENT.Timer = 0

	function ENT:Initialize()
		self.Entity:SetModel("models/props_junk/watermelon01.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:SetMaterial("models/flesh")
		
		self.Timer = CurTime()+10
		
		self.Owner = self:GetOwner()
		
		self.PhysObj = self.Entity:GetPhysicsObject()
		if (self.PhysObj:IsValid()) then
			self.PhysObj:EnableGravity( false )
			self.PhysObj:EnableDrag( false ) 
			self.PhysObj:SetMass(1)
			self.PhysObj:SetMaterial("zombieflesh")
			self.PhysObj:Wake()
		end	
	end
	
	function ENT:SetRocketGravity( bool )
		if (self.PhysObj:IsValid()) then
			self.PhysObj:EnableGravity( bool )
		end	
	end
	
	function ENT:Think()
		if self.Entity:WaterLevel() > 0 or self.Timer < CurTime() then
			timer.Simple(0,self.Explode,self)	
			function self.Think() end
		end
	end
	
	-- Might be unnecessary, but might prevent the damn physics damage
	function ENT:Team()
		return TEAM_UNDEAD
	end
	
	function ENT:Explode()
		
		if not ValidEntity(self.Entity) then return end
		
		-- refraction ring
		local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:GetPos() )
			util.Effect( "refract_ring", effectdata ) 
		
		-- BOOM!
		local Ent = ents.Create("env_explosion")
		Ent:EmitSound( "explode_4" )		
		Ent:SetPos(self.Entity:GetPos())
		Ent:Spawn()
		Ent:SetOwner(self.Owner)
		Ent:Activate()
		Ent.Inflictor = self.Entity:GetClass()
		Ent:SetKeyValue("iMagnitude", math.max(8*(team.NumPlayers(TEAM_HUMAN)),40))
		Ent:SetKeyValue("iRadiusOverride", 120)
		Ent:Fire("explode", "", 0)
		
		-- Shaken, not stirred
		local shake = ents.Create( "env_shake" )
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "1000" ) -- Power of the shake effect
		shake:SetKeyValue( "radius", "300" )	-- Radius of the shake effect
		shake:SetKeyValue( "duration", "3" )	-- Duration of shake
		shake:SetKeyValue( "frequency", "128" )	-- Screenshake frequency
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:SetOwner( self.Owner )
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
			
		// Make blood spam effects
		if GORE_MOD then
			for i= 0, 10 do
			
				local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() )
					effectdata:SetNormal( (VectorRand() + Vector(0,0,math.random(0,1))):GetNormal() )
				util.Effect( "gore_bloodprop", effectdata )
				
			end
		end
	
		timer.Simple(0,function (me) 
			if me:IsValid() then
				me:Remove() 
			end
		end,self)
	end
	
	function ENT:PhysicsCollide( data, physobj )
		timer.Simple(0,self.Explode,self)
	end


end
