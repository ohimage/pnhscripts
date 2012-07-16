AddCSLuaFile("shared.lua")

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= "ClavusElite"
ENT.Purpose			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

util.PrecacheModel("models/Gibs/HGIBS.mdl")
util.PrecacheSound("npc/roller/mine/rmine_explode_shock1.wav")

if CLIENT then

	function ENT:Draw()
		self.BaseClass.Draw(self)
	end

	function ENT:OnRemove()
		local emitter = ParticleEmitter( self.Entity:GetPos() )
		for k=1, 20 do
			
			local particle = emitter:Add( "particles/smokey", self.Entity:GetPos() )
			particle:SetVelocity( Vector(-60+math.random(120),-60+math.random(120),math.random(60)) )
			particle:SetDieTime( 1+math.random(0,2) )
			particle:SetStartAlpha( math.Rand( 100, 220 ) )
			particle:SetStartSize( math.Rand( 40, 80 ) )
			particle:SetEndSize( math.Rand( 100, 160 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 20, 20, 20 )

		end
		emitter:Finish()
		function self:Think() end
	end

	function ENT:Think()	
		local spawnPos = self.Entity:GetPos()
		
		-- shadow trace effect
		self.SmokeTimer = self.SmokeTimer or (CurTime()+0.01)
		if ( self.SmokeTimer <= CurTime() ) then 
			self.SmokeTimer = CurTime() + 0.01
			local emitter = ParticleEmitter( spawnPos )
			local particle = emitter:Add( "particles/smokey", spawnPos )
			particle:SetVelocity( self.Entity:GetForward():GetNormalized()*math.Rand( 10, 20 ) )
			particle:SetDieTime( 0.5 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 10, 20 ) )
			particle:SetEndSize( math.Rand( 20, 40 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 20, 20, 20 )
					
			emitter:Finish()
		end
		
	end
end

if SERVER then

	function ENT:Initialize()
	
		self.Entity:SetModel("models/Gibs/HGIBS.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:SetMaterial("models/shadertest/shader4")
		
		self.PhysObj = self.Entity:GetPhysicsObject()
		if (self.PhysObj:IsValid()) then
			self.PhysObj:EnableDrag( false ) 
			self.PhysObj:SetMass(1)
			self.PhysObj:SetMaterial("zombieflesh")
			self.PhysObj:Wake()
		end	
	end
	
	function ENT:Think()
		if self.Entity:WaterLevel() > 0 then
			timer.Simple(0,function (me) me:Remove() end,self)		
			function self.Think() end
		end
	end
	
	function ENT:Explode()

		self.Entity:EmitSound( "npc/roller/mine/rmine_explode_shock1.wav" )
		
		local entlist = ents.FindInSphere( self.Entity:GetPos(), 150 )
		local dis
		for k, v in pairs(entlist) do
			if v:IsPlayer() and v:Team() == TEAM_HUMAN then
				dis = v:GetPos():Distance(self.Entity:GetPos())
				v:SendLua("Blind("..math.Clamp(250/dis,1,8)..")")
				if self:GetOwner():IsValid() then
					local own = self:GetOwner()
					if not table.HasValue(own.Blindlist,v) then
						table.insert(own.Blindlist,v)
						if #own.Blindlist >= 10 then
							own:UnlockAchievement("youcantseeme")
						end
					end
				end
			end
		end

		self.Entity:Fire("kill", "", "0")
	end
	
	function ENT:PhysicsCollide( data, physobj )
		timer.Simple(0,self.Explode,self)
		timer.Simple(0,function (me) me:Remove() end,self)
	end


end
