include('shared.lua')

local matPentagram 		= Material( "infectedwars/trappentagram" )
local matBeam		 	= Material( "egon/egon_middlebeam" )

function ENT:Initialize()
	self.emitter = ParticleEmitter( self.Entity:GetPos() )
	self.Entity:SetModelScale( Vector(0.3,0.3,0.3) )
	self.Entity:SetColor(200,200,200,250)
	
	self.suckers = {}
	
	self.Entity:SetRenderBoundsWS( self.Entity:GetPos()+Vector(0,0,20), self.Entity:GetPos()+self.Entity:GetAngles():Forward()*200-Vector(0,0,20) )
end

function ENT:Think()

	local entsindahood = ents.FindInSphere( self.Entity:GetPos(), 200 )
	self.suckers = {}
	
	if LocalPlayer():GetPos():Distance(self.Entity:GetPos()) < 200 then
		table.insert(entsindahood, LocalPlayer()) // somehow ents.FindInSphere ignores local player...
	end
	
	for k, ent in pairs(entsindahood) do
		if (ent:IsPlayer() and ent:Team() == TEAM_HUMAN and 
			((ent:GetPos()+Vector(0,0,30))-self.Entity:GetPos()):GetNormal():Dot(self.Entity:GetAngles():Forward()) > 0.1) then
		
			local trace = {}
			trace.start = self.Entity:GetPos()+self.Entity:GetAngles():Forward()*2
			trace.endpos = ent:GetPos()+Vector(0,0,30)
			trace.mask = MASK_NPCWORLDSTATIC
			local tr = util.TraceLine( trace )
			
			if !( tr.Hit ) then
				table.insert(self.suckers, ent)
				
				local energy_loss = ent:GetVelocity():Length()/150
				if ent == LocalPlayer() and energy_loss > 0 then
					DrainEffect( energy_loss )
				end
			end
		end
	end
	
	self.Entity:NextThink(CurTime()+0.05)
end

function ENT:OnRemove()
	if self.emitter then -- make sure that the emitter was created
		for k = 1, 20 do
			local particle = self.emitter:Add( "particle/fire", self.Entity:GetPos() )
			particle:SetVelocity( (self.Entity:GetAngles():Forward()*math.Rand(0,1)+self.Entity:GetAngles():Right()*-1+2*self.Entity:GetAngles():Right()*math.Rand(0,1)):GetNormal()*math.Rand(3,8) )
			particle:SetDieTime( 0.5 + math.Rand(0,0.5) )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 3, 6 ) )
			particle:SetEndSize( math.Rand( 3, 6 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			local ran = math.random(0,20)
			particle:SetColor( 255, 20+ran, 20+ran )
		end
	end
	self.emitter:Finish()
end

function ENT:Draw()

	render.SetMaterial( matPentagram )
	render.DrawQuadEasy( self.Entity:GetPos(), self.Entity:GetAngles():Forward(), 12, 12, Color(200,20,20,255), 0 )
	render.DrawQuadEasy( self.Entity:GetPos(), self.Entity:GetAngles():Forward(), 12+0.5*math.sin(CurTime()), 12+0.5*math.sin(CurTime()), Color(255,20,20,200), 0 )

	
	self.Entity:DrawModel() 
	
	render.SetMaterial( matBeam )
	for k, pl in pairs(self.suckers) do
	
		local alpha = math.Clamp(pl:GetVelocity():Length()/300, 0, 1) * 255
	
		local StartPos = self.Entity:GetPos()
		local EndPos = pl:GetPos()+Vector(0,0,50)
		
		local TexOffset = CurTime() * -3.0
		render.DrawBeam( StartPos, EndPos, 
						16, 
						TexOffset*-0.4, TexOffset*-0.4 + StartPos:Distance(EndPos) / 256, 
						Color(255, 20, 20, alpha) )
	end			

end

