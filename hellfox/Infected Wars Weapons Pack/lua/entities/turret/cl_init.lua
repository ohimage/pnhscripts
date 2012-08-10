include('shared.lua')

local matTripmineLaser 		= Material( "sprites/bluelaser1" )
local matLight 				= Material( "models/roller/rollermine_glow" )
local colBeam				= Color( 50, 100, 210, 30 )
local colLaser				= Color( 50, 100, 240, 30 )

killicon.Add( "turret", "killicon/infectedwars/turret", Color(255, 80, 0, 255 ) )

function ENT:Team()
	return TEAM_HUMAN
end

function ENT:GetName()
	return "< Turret >"
end

function ENT:NickName()
	return self.Entity:GetNetworkedString("nickname") or ""
end

function ENT:GetHealth()
	return self.Entity:GetNetworkedFloat( "health" ) or 0
end

function ENT:GetMaxHealth()
	return self.Entity:GetNetworkedFloat( "maxhealth" ) or 1
end

function ENT:Status()
	return self.Entity:GetNetworkedInt( "status" ) or TurretStatus.inactive
end

function ENT:GetMode()
	return self.Entity:GetNetworkedInt( "mode" ) or st.FOLLOWING
end

function ENT:Kills()
	return self.Entity:GetNetworkedInt( "kills" ) or 0
end

function ENT:OnRemove()
	LocalPlayer().TurretStatus = TurretStatus.destroyed
end

function ENT:Think()

	if not self.Entity:GetNetworkedBool( "active" ) then return end
	
	if self.Entity:GetOwner() == LocalPlayer() then
		LocalPlayer().Turret = self
		LocalPlayer().TurretStatus = self:Status()
		if (self:NickName() == "") then
			RunConsoleCommand("turret_nickname",TurretNickname)
		end
	end
	
	local t = {}
	t.start = self.Entity:GetPos() + self.Entity:GetAngles():Up()*2
	t.endpos = t.start + self.Entity:GetAngles():Forward() * 4096
	t.filter = {self.Entity, self.Entity:GetOwner()}
	t.mask = MASK_PLAYERSOLID
	local tr = util.TraceLine(t)
	self.endpos = tr.HitPos

	self.Entity:SetRenderBoundsWS( self.endpos, self.Entity:GetPos(), Vector()*8 )
	
	if self:GetHealth() < 50 then
		-- Smoke timer
		self.SmokeTimer = self.SmokeTimer or (CurTime()+0.02)
		if ( self.SmokeTimer <= CurTime() ) then 
			self.SmokeTimer = CurTime() + 0.02
			-- Smoke effects
			local spawnPos = self.Entity:GetPos()+Vector(math.random(0,8),math.random(0,8),math.random(0,8) )
			local emitter = ParticleEmitter( spawnPos )
			local particle = emitter:Add( "particles/smokey", spawnPos )
			particle:SetVelocity( Vector(math.Rand(0,1)/3,math.Rand(0,1)/3,1):Normalize()*math.Rand( 10, 20 ) )
			particle:SetDieTime( 0.7 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 5, 10 ) )
			particle:SetEndSize( math.Rand( 15, 30 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			local ran = math.random(0,30)
			particle:SetColor( 40+ran, 40+ran, 40+ran )
					
			emitter:Finish()
		end
	end
end

function ENT:Draw()

	self.Entity:DrawModel() 
	
	if not self.Entity:GetNetworkedBool( "active" ) or not self.endpos then return end

	render.SetMaterial( matTripmineLaser )
	
	// offset the texture coords so it looks like it is scrolling
	local TexOffset = CurTime() * 3
	
	// Make the texture coords relative to distance so they are always a nice size
	local Distance = self.endpos:Distance( self.Entity:GetPos() )
		
	// Draw the beam
	render.DrawBeam( self.endpos, self.Entity:GetPos(), 8, TexOffset, TexOffset+Distance/8, colBeam )
	render.DrawBeam( self.endpos, self.Entity:GetPos(), 4, TexOffset, TexOffset+Distance/8, colBeam )
	
	// Draw a quad at the hitpoint to fake the laser hitting it
	render.SetMaterial( matLight )
	local Size = math.Rand( 5, 8 )
	local Normal = (self.Entity:GetPos()-self.endpos):GetNormal() * 0.1
	render.DrawQuadEasy( self.endpos + Normal, Normal, Size, Size, colLaser, 0 )
	 
end

// Turret nickname setting
local randnames = { "R2D2", "C3P0", "Bender", "George", "Bob" }
CreateClientConVar("_iw_turretnickname", table.Random(randnames), true, false)
TurretNickname = GetConVarString("_iw_turretnickname")
function SetTurretNick( pl,commandName,args )
	if not args[1] then return end
	if string.len(tostring(args[1])) > 15 then 
		pl:ChatPrint("Maximum nickname length is 15 characters!")
		return 
	end
	TurretNickname = args[1]

	RunConsoleCommand("_iw_turretnickname",tostring(args[1]))
	RunConsoleCommand("turret_nickname",tostring(args[1]))
end
concommand.Add("iw_turretnickname",SetTurretNick) 

