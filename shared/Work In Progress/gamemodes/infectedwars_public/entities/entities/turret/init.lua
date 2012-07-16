
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*
BEHAVIOUR DESCRIPTION

* Turret always engages enemies in sight
* Turret tries to stick to owner
* If he can't find a clear path to the owner, it tries to follow the owners path
* The turret can be instructed to defend a point
* If owner gets killed, the turret shuts down and selfdestructs

*/

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetNetworkedBool( "active", true )

	// These are placeholder values, actual health is set later
	self.Entity:SetNetworkedFloat( "health", 100 )
	self.Entity:SetNetworkedFloat( "maxhealth", 100 )
	
	self.Entity:SetNetworkedInt( "status", TurretStatus.active )
	
	self.kills = 0
	self.Entity:SetNetworkedInt( "kills", self.kills )
	
	self.Entity:SetPos(self.Entity:GetPos()+Vector(0,0,30))
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:DrawShadow( false )
	self.Entity:SetColor(5,100,255,255)
	self.Entity:SetModel( "models/Combine_Scanner.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:EmitSound(self.ActivateSound)
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	self.OwnerLocs = {}
	self.LocRecordDelay = 0.2
	self.NextLocRecord = CurTime()+self.LocRecordDelay
	
	self.TimeTillItScreamsForHisMommy = 20
	
	self:SetMode( st.FOLLOWING )
	self.attacking = false
	self.fireat = false
	self.lastownertracevec = Vector(0,0,0)
	self.targetpos = self.Entity:GetPos()
	self.targetangle = self.Entity:GetAngles()
	self.disToTarget = 0
	self.disToOwner = 0
	self.vecToTarget = Vector(0,0,0)
	self.vecToOwner = Vector(0,0,0)
	self.owneraim = Vector(0,0,0)
	self.nextownerpulse = 0
	self.lastownercontact = CurTime()
	
	self.enemytarget = nil
	self.vecToEnemy = Vector(0,0,0)
	self.shootdamage = 4
	self.shoottimer = 0
	self.shootdelay = 0.08
	self.Dead = false
	self.lasttargetcontact = 0
	self.nextlostsignal = 0

	self.loseengagedistance = 1400
	self.engagedistance = 800
	self.engagedistanceboosted = 1100 // After buying "searchengine" item
	
	self.turnspeed = 75
	
	self.lastdamage = 0
	self.lastrestore = 0
	
	self.vecToTargetDefend = Vector(0,0,0)
	self.defendpos = Vector(0,0,0)
	self.nextdefendswitch = 0
	self.targetspottodefend = Vector(0,0,0)
	self.targetrollswitch = 0
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableDrag( true )
	self.PhysObj:SetDamping( 0, 200000 )
	self.PhysObj:SetAngleDragCoefficient( 200 )
	self.PhysObj:Wake()

end

function ENT:SetHealthDefault( hp )
	self.Entity:SetNetworkedFloat( "health", hp )
	self.Entity:SetNetworkedFloat( "maxhealth", hp )
	--print("Turret health set to "..hp)
end

function ENT:FireBullet()
	if self.shoottimer > CurTime() then return end
	self.shoottimer = CurTime()+self.shootdelay
	bullet = {}
	bullet.Num		= 1
	if self.Owner:IsPlayer() then
		bullet.Attacker = self.Owner
	end
	bullet.Inflictor = self.Entity
	bullet.Src		= self.Entity:GetPos()
	bullet.Dir		= self.Entity:GetAngles():Forward()
	bullet.Spread	= Vector(0.04,0.04,0)
	bullet.Tracer	= 1
	bullet.Force	= 2
	bullet.Damage	= self.shootdamage
	bullet.TracerName = "AR2Tracer"
	self.Entity:FireBullets(bullet) 
	self.Entity:EmitSound(self.ShootSound[math.random(1,3)])
	local ed = EffectData()
	ed:SetOrigin(self.Entity:GetAttachment(1).Pos)
	ed:SetAngle(self.Entity:GetAngles())
	ed:SetScale(0.5)
	util.Effect("MuzzleEffect", ed)
end

function ENT:Team()
	return TEAM_HUMAN
end

function ENT:AdjustGuardAngle( angle )
	self.LockAngle = angle
end

function ENT:GetName()
	return "< Turret >"
end

function ENT:CommandDefend()
	self:SetMode(st.DEFEND)
	local trace = self.Owner:GetEyeTrace()
	self.targetspottodefend = trace.HitPos
	self.defendpos = self.Entity:GetPos()
	self.vecToTargetDefend = (self.targetspottodefend-self.Entity:GetPos()):GetNormal()
	self.nextdefendswitch = CurTime()+3
	self.Entity:EmitSound(self.ConfirmSound)
end

function ENT:CommandFollow()
	self:SetMode(st.TRACKING)
	self.Entity:EmitSound(self.ConfirmSound)
end

function ENT:CommandFire( set )
	self.fireat = set
end

function ENT:Think()

	self.Owner = self:GetOwner()
	// Die is owner is no longer alive
	if (not ValidEntity(self.Owner) or (self.Owner:IsPlayer() and not self.Owner:Alive())) and not self.Dead then
		self:SetOwner(Entity())
		self:SetMode(st.SHUTDOWN)
		self.Dead = true
		self.Entity:SetNetworkedBool( "active", false )
		self.attacking = false
		self.fireat = false
		self.PhysObj:EnableGravity(true)
		timer.Simple(4,function(self) 
			self:Explode()
			timer.Simple(0.01,function (me) 
				if me:IsValid() then
					me:Remove() 
				end
			end,self) -- some delay
		end,self)
	end
	
	// Shop upgrade
	if ValidEntity(self.Owner) and self.Owner:HasBought("searchengine") then
		self.engagedistance = self.engagedistanceboosted
	end
	
	// no going underwater with this thing
	if self.Entity:WaterLevel() >= 2 then
		self:Damage(1,nil)
	end
	
	// DEBUG
	/*if not self.Dead then
		if (self.Owner:KeyDown(IN_ATTACK2) and not self.defend) then
			self.defend = true
			self:CommandDefend()
		elseif self.defend and not self.Owner:KeyDown(IN_ATTACK2) then
			self:CommandFollow()
			self.defend = false
		end
	end
	if (self.Owner:KeyDown(IN_ATTACK2)) then
		self:Damage(3, nil)
	end*/
	
	// Record owner positions
	if( self.NextLocRecord < CurTime() and !(self:GetMode() == st.SHUTDOWN)) then
		self.NextLocRecord = CurTime()+self.LocRecordDelay
		// only record positions if player is moving
		local ownpos = self.Owner:GetPos()+Vector(0,0,20)
		if not self.Owner:Crouching() then
			ownpos = ownpos+Vector(0,0,40)
		end
		
		if (#self.OwnerLocs < 1 or ownpos:Distance(self.OwnerLocs[#self.OwnerLocs]) > 30) then
			table.insert(self.OwnerLocs, ownpos)
			if (#self.OwnerLocs > 60) then
				table.remove(self.OwnerLocs,1)
			end
		end
	end
	
	// target player lookat position
	if self.fireat then
		local trace = self.Owner:TraceLine(9999)
		local pos = trace.HitPos
		self.lastownertracevec = (pos-self.Entity:GetPos()):Normalize()
		if self.lastownertracevec:DotProduct(self.Entity:GetAngles():Forward()) > 0.9 then
			self:FireBullet()
		end
	// if attacking
	elseif self.attacking then
		// check if enemy is still valid and in sight
		local distoen = 0
		if ValidEntity(self.enemytarget) then
			distoen = self.enemytarget:GetPos():Distance(self.Entity:GetPos())
		end
		
		if !ValidEntity(self.enemytarget) or !self.enemytarget:Alive() or self.lasttargetcontact+1.5 < CurTime() or distoen > self.loseengagedistance or 
			(self.enemytarget:GetPlayerClass() == 3 and distoen > 393 and self.enemytarget:HasBought("machineillusion")) then
			self.attacking = false
			self.enemytarget = nil
		else
			// attack enemy
			local upv = Vector(0,0,50)
			if self.enemytarget:Crouching() then
				upv = Vector(0,0,30)
			end
			self.vecToEnemy = ((self.enemytarget:GetPos()+upv)-self.Entity:GetPos()):GetNormal()
			if (self.enemytarget:GetPos()-self.Entity:GetPos()):Normalize():DotProduct(self.Entity:GetAngles():Forward()) > 0.9 then
				self:FireBullet()
			end
			
			if self:ClearTrace(self.enemytarget) then
				self.lasttargetcontact = CurTime()
			end
		end
	elseif !(self:GetMode() == st.SHUTDOWN) then
		// check if you're seeing an enemy
		for k, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
			local distoen = pl:GetPos():Distance(self.Entity:GetPos())
			if pl:IsValid() and pl:Alive()
				and (pl:GetPos()-self.Entity:GetPos()):Normalize():DotProduct(self.Entity:GetAngles():Forward()) > 0.6
				and distoen < self.engagedistance and (pl:GetPlayerClass() ~= 3 or pl:GetVelocity():Length() > 180) and not pl.Disguised and self:ClearTrace(pl) and
				!(pl:GetPlayerClass() == 3 and distoen > 393 and pl:HasBought("machineillusion")) then
				self.enemytarget = pl
				self.lasttargetcontact = CurTime()
				self.vecToEnemy = (pl:GetPos()-self.Entity:GetPos()):GetNormal()
				self.shoottimer = CurTime()+0.5
				self.Entity:EmitSound(self.SoundAlarm)
				self.attacking = true
				break
			end	
		end
	
	end
	
	// Orientation stuff goes below
	if (self.status != st.SHUTDOWN) then
	
		// check if player is still visible
		if self.nextownerpulse < CurTime() then
			self.nextownerpulse = CurTime()+0.33
			if (self:ClearTrace(self.Owner)) then
				self.lastownercontact = CurTime()
			end
		end
	
		// check when you last saw the player and start tracking if it was too long ago
		if self.lastownercontact+0.5 < CurTime() then
			if self:GetMode() == st.FOLLOWING then
				self:SetMode(st.TRACKING)
				if (!self:LockNearestOwnerPathNode()) then
					self:SetMode(st.LOST)
				end
			end
		else
			if self:GetMode() == st.TRACKING or self:GetMode() == st.LOST then
				self:SetMode(st.FOLLOWING)
				if (self:GetMode() == st.LOST) then
					self.Entity:EmitSound(self.HappySound,500,100)
				end
			end
		end
		
		self.owneraim = self.Owner:GetAimVector()
		self.targetpos = self.Owner:GetPos()+Vector(0,0,80)+(self.owneraim:Angle()+Angle(0,-40,0)):Forward()*40
		// Useful for vent orientation:
		// check if target area is clear, if not, use old owner position, 
		// if that don't work, stick to current owner pos
		if not self:IsClear(self.Entity:GetPos(),self.targetpos) then
			local vec = self.OwnerLocs[#self.OwnerLocs-1]
			if vec then
				self.targetpos = vec
			else
				self.targetpos = self.Owner:GetPos()+Vector(0,0,30)
			end
		end
		self.disToOwner = self.Entity:GetPos():Distance(self.Owner:GetPos())
		self.vecToOwner = (self.Owner:GetPos()-self.Entity:GetPos()):GetNormal()
		
		if self:GetMode() == st.FOLLOWING then
			self.disToTarget = self.Entity:GetPos():Distance(self.targetpos)
			self.vecToTarget = (self.targetpos-self.Entity:GetPos()):GetNormal()
		elseif self:GetMode() == st.TRACKING then
			local tar = self.OwnerLocs[1]
			if tar then
				self.disToTarget = self.Entity:GetPos():Distance(tar)
				self.vecToTarget = (tar-self.Entity:GetPos()):GetNormal()
				
				if (self.disToTarget < 10) then
					table.remove(self.OwnerLocs,1) // now it should target the next
					
					if (self.lastownercontact+self.TimeTillItScreamsForHisMommy < CurTime()) then
						self:SetMode(st.LOST)
					end
				end
			end
		elseif self:GetMode() == st.LOST then
			if self.nextlostsignal < CurTime() then
				self.Entity:EmitSound(self.LostSound,500,100)
				self.nextlostsignal = CurTime()+4
				self.vecToTarget = (self.vecToTarget:Angle()+Angle(0,math.random(0,359),0)):Forward()
			end
		elseif self:GetMode() == st.DEFEND then
			self.disToTarget = self.Entity:GetPos():Distance(self.defendpos)
			self.vecToTarget = (self.defendpos-self.Entity:GetPos()):GetNormal()
			if self.nextdefendswitch < CurTime() and not self.attacking and not self.fireat then
				self.nextdefendswitch = CurTime()+2.5

				local ang = (self.targetspottodefend-self.Entity:GetPos()):Angle()
				local left = (ang+Angle(0,45,0)):Forward()
				local right = (ang+Angle(0,-45,0)):Forward()
				if self.targetrollswitch == 0 then
					self.vecToTargetDefend = left
					self.targetrollswitch = 1
				else
					self.vecToTargetDefend = right
					self.targetrollswitch = 0
				end
				self.Entity:EmitSound(self.SoundPing)
			end
		end
		
		if (self.lastdamage < CurTime() - 3 and self.lastrestore < CurTime() - 1) then
			self:RestoreHealth(0.5)
		end
	
	end
	
	self.PhysObj:Wake() // it seems to fall asleep now and then. Lazy physobjects
	
	self.Entity:NextThink(CurTime()+0.01)
	return true
end

function ENT:PhysicsUpdate( phys )
	if (self:GetMode() == st.SHUTDOWN) then return end

	self.PhysObj = phys
	local dis = self.disToTarget
	
	if (phys:GetAngleVelocity():Length() > 0) then
		// nullify angle velocity
		phys:AddAngleVelocity(phys:GetAngleVelocity( )*-1)
	end
	
	if (dis > 5) then
		if (self:GetMode() == st.FOLLOWING or self:GetMode() == st.DEFEND) then
			self:SetSpeed(self.vecToTarget*math.min(200000,3000*dis)*FrameTime())
		elseif (self:GetMode() == st.TRACKING) then
			self:SetSpeed(self.vecToTarget*140000*FrameTime())
		end
	end
	
	if self.fireat then
		self.targetangle = self.lastownertracevec:Angle()
	elseif self.attacking then
		self.targetangle = self.vecToEnemy:Angle()
	else
		if (self:GetMode() == st.FOLLOWING and dis < 150) then
			self.targetangle = self.owneraim:Angle()
		elseif (self:GetMode() == st.DEFEND) then
			self.targetangle = self.vecToTargetDefend:Angle()
		else
			self.targetangle = self.vecToTarget:Angle()
		end
	end
	
	self:AlignToAngle( self.targetangle )
end

function ENT:OnTakeDamage( dmginfo )
	if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() ~= self:Team() and not self.Dead then
		self.enemytarget = dmginfo:GetAttacker()
		self.lasttargetcontact = CurTime()
		self.vecToEnemy = (self.enemytarget:GetPos()-self.Entity:GetPos()):GetNormal()
		if not self.attacking then
			self.attacking = true
			self.Entity:EmitSound(self.SoundAlarm)
		end

		if (dmginfo:GetAttacker():HasBought("machinedestruction")) then
			dmginfo:SetDamage(dmginfo:GetDamage()*1.2)
		end
		
		self:Damage(dmginfo:GetDamage(), dmginfo:GetAttacker())
	end
end


function ENT:Damage( amount, attacker )

	self.Entity:SetNetworkedFloat( "health", math.max(0,self.Entity:GetNetworkedFloat("health") - amount) )
	if self.lastdamage+1 < CurTime() then
		self.Entity:EmitSound(self.PainSounds[math.random(1,#self.PainSounds)])
	end
	
	self.lastdamage = CurTime()
	
	if self.Entity:GetNetworkedFloat("health") <= 0 and not self.Dead then 
	
		self.Dead = true
		self.Entity:SetNetworkedBool( "active", false )
		
		local inflictor
		if ValidEntity(attacker) and attacker:IsPlayer() then
			inflictor = attacker:GetActiveWeapon()
			if not ValidEntity(inflictor) then inflictor = attacker end
		end
		
		umsg.Start( "PlayerKilled" )
		
			umsg.Entity( self )
			if ValidEntity(inflictor) then
				umsg.String( inflictor:GetClass() )
			else
				umsg.String("")
			end
			umsg.Entity( attacker )

		umsg.End()
	
		if ValidEntity(attacker) and attacker:IsPlayer() then
			attacker.TurretsDestroyed = attacker.TurretsDestroyed+1
			if attacker.TurretsDestroyed >= 4 then
				attacker:UnlockAchievement("rageagainstmachine")
			end
		end
		
		timer.Simple(0,self.Explode,self)
		timer.Simple(0.01,function (me) 
			if me:IsValid() then
				me:Remove() 
			end
		end,self) -- some delay
	end

end

function ENT:Restore( amount )


end

function ENT:LockNearestOwnerPathNode()
	local dis = 10000
	local vecdis = 0
	local index = 0
	for k, v in pairs(self.OwnerLocs) do
		vecdis = v:Distance(self.Entity:GetPos()) - k*20 // this way we make sure to grab the closest / latest path node
		if (vecdis <= dis and self:IsClear(self.Entity:GetPos(),v)) then
			dis = vecdis
			index = k
		end
	end
	
	if (index > 1) then
		for i=1, index-1 do
			table.remove(self.OwnerLocs,1)
		end
	end
	
	return index
	// Closest node should now be on self.OwnerLocs[1]
end

function ENT:Explode()
	
	-- BOOM!
	local Ent = ents.Create("env_explosion")
	Ent:EmitSound( self.ExplodeSound )
	Ent:SetPos(self.Entity:GetPos())
	Ent:Spawn()
	Ent:SetOwner(self:GetOwner())
	Ent.Team = function()
		return TEAM_HUMAN
	end
	Ent.GetName = function()
		return "< Turret Kamikazi >"
	end
	Ent:Activate()
	Ent:SetKeyValue("iMagnitude", 50)
	Ent:SetKeyValue("iRadiusOverride", 100)
	Ent:Fire("explode", "", 0)
	
	//self.Entity:Fire("kill", "", "0")
end

function ENT:ApproachAngle( cur_angle, target_angle, amount )

	local angle_diff = target_angle - cur_angle

	// express the angle difference between 0 and 360 degrees
	while (angle_diff.p >=360) do angle_diff.p = angle_diff.p-360 end
	while (angle_diff.p < 0) do angle_diff.p = angle_diff.p+360 end
	while (angle_diff.y >=360) do angle_diff.y = angle_diff.y-360 end
	while (angle_diff.y < 0) do angle_diff.y = angle_diff.y+360 end
	while (angle_diff.r >=360) do angle_diff.r = angle_diff.r-360 end
	while (angle_diff.r < 0) do angle_diff.r = angle_diff.r+360 end
	
	// if you're within range, follow normally.
	if (angle_diff.p < amount or angle_diff.p > 360-amount) then
		cur_angle.p = target_angle.p
	elseif (angle_diff.p < 180) then
		cur_angle.p = cur_angle.p+amount
	else
		cur_angle.p = cur_angle.p-amount
	end
	
	if (angle_diff.y < amount or angle_diff.y > 360-amount) then
		cur_angle.y = target_angle.y
	elseif (angle_diff.y < 180) then
		cur_angle.y = cur_angle.y+amount
	else
		cur_angle.y = cur_angle.y-amount
	end

	if (angle_diff.r < amount*2 or angle_diff.r > 360-amount*2) then
		cur_angle.r = target_angle.r
	elseif (angle_diff.r < 180) then
		cur_angle.r = cur_angle.r+amount*2
	else
		cur_angle.r = cur_angle.r-amount*2
	end
	
	return cur_angle
end

function ENT:SetMode( mode )
	self.status = mode
	self.Entity:SetNetworkedInt( "mode", self.status )
end

function ENT:GetMode()
	return self.status
end

function ENT:SetSpeed( vector )
	self.PhysObj:ApplyForceCenter(vector)
end

function ENT:AlignToAngle( angle )
	self.PhysObj:SetAngle(self:ApproachAngle( self.PhysObj:GetAngle(), angle, FrameTime()*self.turnspeed ))
	self.Entity:SetAngles(self.PhysObj:GetAngle())
end

function ENT:IsClear(pos1, pos2)
	local pos = pos1
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos2
	tracedata.filter = self.Owner
	tracedata.mask = MASK_PLAYERSOLID_BRUSHONLY
	local trace = util.TraceLine(tracedata)
	return !(trace.Hit and not trace.HitNonWorld)
end

function ENT:ClearTrace( ply )
	local clear = true
	
	local start = self.Entity:GetPos()
	local endpos = ply:GetPos()+Vector(0,0,35) -- aim for torso area
	local trace = {}
	trace.start = start
	trace.endpos = endpos
	trace.mask = MASK_PLAYERSOLID_BRUSHONLY
	trace.filter = self
	local tr = util.TraceLine(trace)
	if not tr.Hit then 
		clear = true 
	else
		clear = tr.HitNonWorld
	end

	start = self.Entity:GetPos()
	endpos = ply:GetPos()+Vector(0,0,58) -- aim for head area
	trace = {}
	trace.start = start
	trace.endpos = endpos
	trace.mask = MASK_PLAYERSOLID_BRUSHONLY
	trace.filter = self
	tr = util.TraceLine(trace)
	if (!tr.Hit or tr.HitNonWorld) and not clear then
		clear = tr.HitNonWorld
	end
	
	return clear
end

function ENT:RestoreHealth( amount )
	if (self:GetMode() == st.SHUTDOWN) then return end
	self.Entity:SetNetworkedFloat( "health", math.min(self.Entity:GetNetworkedFloat("maxhealth"),self.Entity:GetNetworkedFloat("health") + amount) )
	self.lastrestore = CurTime()
end

function ENT:AddKill()
	self.kills = self.kills+1
	self.Entity:SetNetworkedInt( "kills", self.kills )
end

function ENT:OnRemove()
	self.Entity:SetNetworkedBool( "active", false )
	self.Entity:SetNetworkedInt( "status", TurretStatus.destroyed )
end

function ENT:NickName()
	return self.NickName
end

function ENT:SetNickName( nm )
	self.NickName = nm
	self.Entity:SetNetworkedString("nickname",nm)
end

/*---------------------------------------------------------
   Name: UpdateTransmitState
   Desc: Set the transmit state
---------------------------------------------------------*/
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

