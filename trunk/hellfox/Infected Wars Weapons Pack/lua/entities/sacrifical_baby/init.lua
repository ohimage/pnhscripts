
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetNetworkedBool( "active", false )
	self.Entity:SetNetworkedBool( "drawstuff", true )
	local hp = 20
	if (self:GetOwner():HasBought("infantechantment")) then
		hp = hp * 3
	end
	self.Entity:SetNetworkedFloat( "health", hp )
	self.Entity:SetNetworkedVector( "drawpos", nil )
	
	self.Dead = false
	self.fade = false
	self.alpha = 255
	
	timer.Simple(2,function(me) 
		if ValidEntity(me) and not self.Dead then 
			me.Entity:SetNetworkedBool( "active", true )
		end
	end,self)
	
	self.spawnEnt = ents.Create("info_player_start")
	self.spawnEnt:SetPos(self.Entity:GetPos()+Vector(0,0,28))
	self.spawnEnt:SetAngles(self.Entity:GetAngles())
	self.spawnEnt:Spawn()
	self.spawnEnt:Activate()
	
	self.StartPos = self.Entity:GetPos()
	self.LockPos = self.StartPos + Vector(0,0,20)

	self.Entity:DrawShadow( false )
	self.Entity:SetColor(255,150,150,255)
	self.Entity:SetModel( "models/props_c17/doll01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	
	self.PhysObj = self.Entity:GetPhysicsObject()
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableDrag( true )
	self.PhysObj:SetDamping( 0, 200000 )
	self.PhysObj:SetAngleDragCoefficient( 200 )
	self.PhysObj:Wake()

end

function ENT:Alive()
	return not self.Dead
end

function ENT:Name()
	return "< Sacrifical Baby >"
end

function ENT:Team()
	return TEAM_UNDEAD
end

function ENT:SetDrawPos( pos )
	self.Entity:SetNetworkedVector( "drawpos", pos )
end

function ENT:GetSpawn()
	return self.spawnEnt
end

function ENT:Eliminate( attacker )

	self.Dead = true
	self.Entity:SetNetworkedBool( "active", false )
	self.Entity:SetNetworkedBool( "drawstuff", false )
	self.Entity:EmitSound(self.SoundDeath)
	
	self.PhysObj:EnableGravity( true )
	
	local vPoint = self.Entity:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint ) 
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 2 )
	util.Effect( "BloodImpact", effectdata ) 
	
	if self.spawnEnt:IsValid() then
		self.spawnEnt:Remove()
	end
	
	timer.Simple(5,self.StartFade,self)
	timer.Simple(10,function(me) 
		if not ValidEntity(me.Entity) then return end
		me.Entity:Remove() end,
		self)
	
	if attacker and attacker:IsPlayer() then
		
		local inflictor = attacker:GetActiveWeapon()
		if not inflictor then inflictor = attacker end
		
		attacker.BabiesKilled = attacker.BabiesKilled+1
		attacker:AddScore("babieskilled",1)
		
		local babkills = attacker:GetScore("babieskilled")
		if babkills >= 150 then
			attacker:UnlockAchievement("politicalincorrectness")
			if babkills >= 500 then
				attacker:UnlockAchievement("infantfobia")
			end
		end
		
		if attacker.BabiesKilled >= 10 then
			attacker:UnlockAchievement("cribdeath")
		end
		
		umsg.Start( "PlayerKilled" )
		
			umsg.Entity( self )
			umsg.String( inflictor:GetClass() )
			umsg.Entity( attacker )

		umsg.End()
		
		self:GetOwner():ChatPrint("Your sacrifical baby has been destroyed by "..attacker:Name().."!")
	end	
end

function ENT:StartFade()
	self.fade = true
end

function ENT:Think()

	local active = self.Entity:GetNetworkedBool( "active" )

	if (not self:GetOwner() or not self:GetOwner():IsValid()) and not self.Dead then
		self:Eliminate()
	end
	
	if self.fade then
		self.Entity:SetColor(255,150,150,self.alpha)
		self.alpha = math.max(0,self.alpha - (255/40))
		self.Entity:NextThink(CurTime()+0.1)
	end

	self.PhysObj:Wake()
	
	self.Entity:NextThink(CurTime()+0.05)
	return true
	
end

function ENT:PhysicsUpdate( phys )

	local active = self.Entity:GetNetworkedBool( "active" )
	
	if not self.Dead then
		if active then
			local ang = self.PhysObj:GetAngle()
			ang.p = 0
			ang.r = 0
			self:AlignToAngle( ang+Angle(0,10,0) )
		end
		
		local dis = self.Entity:GetPos():Distance(self.LockPos)
		if dis > 1 and not self.lock then
			self.Entity:SetPos(self.Entity:GetPos()+(self.LockPos-self.Entity:GetPos())/2*FrameTime())
		else
			self.Entity:SetPos(self.LockPos)
			self.lock = true
		end
	end
end

function ENT:AlignToAngle( angle )
	self.PhysObj:SetAngle(self:ApproachAngle( self.PhysObj:GetAngle(), angle, FrameTime()*40 ))
	self.Entity:SetAngles(self.PhysObj:GetAngle())
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

function ENT:OnTakeDamage( dmginfo )
	if dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() ~= self:Team() and not self.Dead then

		self.Entity:SetNetworkedFloat( "health", math.max(0,self.Entity:GetNetworkedFloat("health") - dmginfo:GetDamage()) )
		if self.Entity:GetNetworkedFloat("health") <= 0 then 
			self.Dead = true
			
			local retries = self:GetOwner().BabySpawnRetries
			if retries > 0 then
				self:GetOwner().BabySpawnRetries = retries - 1
				local wep = self:GetOwner():GetWeapon( "iw_und_sacrificer" )
				if ValidEntity(wep) then
					wep:SetClip1(1)
				end
			end
			
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

