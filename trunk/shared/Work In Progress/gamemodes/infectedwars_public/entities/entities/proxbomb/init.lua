AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.StartupDelay = nil
function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_c4_planted.mdl") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetTrigger( true )
	self.StartupDelay = CurTime()+4
end

ENT.Cloak = false
function ENT:SetCloak( bool )
	self.Cloak = bool
end

function ENT:Think()
	if self.Cloak then
		local r, g, b, a = self:GetColor()
		if a > 50 then
			a = a - 1000 * FrameTime()
		end
		self:SetColor(r,g,b,a)
	end

	if self.StartupDelay and self.StartupDelay < CurTime() then
		local e = ents.FindInSphere( self.Entity:GetPos(), 130 )
		for a,pl in pairs(e) do
			-- Doesn't detonate for slow moving stalkers
			if (pl:IsPlayer() and pl:Team() == TEAM_UNDEAD and pl:Alive() and (pl:GetPlayerClass() ~= 3 or pl:GetVelocity():Length() > 180)) then
				local trace = {}
				trace.start = self.Entity:GetPos()
				trace.endpos = pl:GetPos()+Vector(0,0,30)
				trace.filter = self.Entity
				local tr = util.TraceLine( trace )
				-- Checks if there's a clear view of the player
				if tr.Entity:IsValid() and tr.Entity == pl then
					self.Entity:EmitSound(self.WarningSound)
					timer.Simple(0.5,self.Explode,self)
					function self.Think() end
				end
			end
		end
	end
	
	-- In case the owner dies
	if self:GetOwner():IsPlayer() and not self:GetOwner():Alive() then
		local ent = Entity()
		ent.Team = function() return TEAM_HUMAN end
		self:SetOwner(ent)
	end
end

function ENT:OnTakeDamage( dmginfo )
	if (dmginfo:IsExplosionDamage() and dmginfo:GetDamage() > 20) then
		timer.Simple(0,self.Explode,self)
		timer.Simple(0,function (me) 
			if ValidEntity(me) then me:Remove() end 
		end,self)	
	end
end

function ENT:Explode()
	-- BOOM!
	if not ValidEntity(self.Entity) then return end
	
	WorldSound( "explode_4", self.Entity:GetPos(), 130, 100 )
	
	local Ent = ents.Create("env_explosion")
	Ent:SetPos(self.Entity:GetPos())
	Ent:Spawn()
	Ent.Team = function() -- Correctly applies the whole 'no team damage' thing
		return TEAM_HUMAN
	end
	Ent.GetName = function()
		return "< Mine >"
	end
	Ent.Inflictor = self.Entity:GetClass()
	Ent:SetOwner(self:GetOwner())
	Ent:Activate()
	Ent:SetKeyValue("iMagnitude", 200)
	Ent:SetKeyValue("iRadiusOverride", 250)
	Ent:Fire("explode", "", 0)
	
	-- Shaken, not stirred
	local shake = ents.Create( "env_shake" )
	shake:SetPos( self.Entity:GetPos() )
	shake:SetKeyValue( "amplitude", "800" ) -- Power of the shake effect
	shake:SetKeyValue( "radius", "300" )	-- Radius of the shake effect
	shake:SetKeyValue( "duration", "3" )	-- Duration of shake
	shake:SetKeyValue( "frequency", "128" )	-- Screenshake frequency
	shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
	shake:Spawn()
	shake:SetOwner( self:GetOwner() )
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )
	
	timer.Simple(0,function (me)
		if not ValidEntity(self.Entity) then return end
		me:Remove() end,
		self)
end

function ENT:WallPlant(hitpos, forward)
	if (hitpos) then self.Entity:SetPos( hitpos ) end
    self.Entity:SetAngles( forward:Angle() + Angle( -90, 0, 180 ) )
end

function ENT:PhysicsCollide( data, phys ) 
	if ( !data.HitEntity:IsWorld() ) then return end
	phys:EnableMotion( false )
	phys:Sleep()
	self:WallPlant( nil, data.HitNormal:GetNormal() * -1 )
end
