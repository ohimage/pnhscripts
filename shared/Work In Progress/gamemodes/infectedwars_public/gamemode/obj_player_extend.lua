/*------------
Infected Wars
obj_player_extend.lua
Shared
------------*/

local meta = FindMetaTable( "Player" )
if (!meta) then return end

function meta:Money()
	if not self.DataTable then return 0 end
	return self.DataTable["money"] or 0
end

function meta:HasBought( str )
	if not self.DataTable or (SERVER and self:IsBot()) then return false end
	if not self.DataTable["shopitems"] then return false end
	return self.DataTable["shopitems"][str]
end

function meta:GetScore( stat, amount )
	if not PLAYER_STATS then return 0 end
	return self.DataTable[stat]
end

function meta:PlayDeathSound()
	local cls = self:GetPlayerClass()
	local nr = 0
	if self:Team() == TEAM_UNDEAD then
		nr = #UndeadClass[cls].DeathSounds
		if nr > 0 then
			self:EmitSound(UndeadClass[cls].DeathSounds[math.random(1,nr)])
		end
	elseif self:Team() == TEAM_HUMAN then
		nr = #HumanClass[cls].DeathSounds
		if nr > 0 then
			self:EmitSound(HumanClass[cls].DeathSounds[math.random(1,nr)])
		end	
	end
end

function meta:PlayPainSound()
	local cls = self:GetPlayerClass()
	local nr = 0
	if self:Team() == TEAM_UNDEAD then
		nr = #UndeadClass[cls].PainSounds
		if nr > 0 then
			self:EmitSound(UndeadClass[cls].PainSounds[math.random(1,nr)])
		end
	elseif self:Team() == TEAM_HUMAN then
		nr = #HumanClass[cls].PainSounds
		if nr > 0 then
			self:EmitSound(HumanClass[cls].PainSounds[math.random(1,nr)])
		end	
	end
end

function meta:GetAchvProgress()
	local subnumber = 0
	local totnumber = 0
	for k, v in pairs(self.DataTable["achievements"]) do
		totnumber = totnumber + 1
		if v == true then
			subnumber = subnumber + 1
		end
	end
	return subnumber/totnumber*100
end

function meta:HasUnlocked( code )
	for k, v in pairs(unlockData[code]) do
		if not self.DataTable["achievements"][v] then
			return false
		end
	end
	return true
end

-- Serverside validation of unlocked loadout
function meta:ValidateLoadout( plteam, class, nr )
	if plteam and class and nr then
		if plteam == TEAM_UNDEAD then
			if (self:HasUnlocked(UndeadClass[class].SwepLoadout[nr].UnlockCode)) then
				return nr
			else
				return 1
			end
		elseif plteam == TEAM_HUMAN then
			if (self:HasUnlocked(HumanClass[class].SwepLoadout[nr].UnlockCode)) then
				return nr
			else
				return 1
			end	
		end
	end
	return nil
end

function meta:GetPlayerClass()
	return self.Class or 0
end

function meta:TraceLine( distance, direction )
	local dir
	if direction then
		dir = direction:GetNormal()
	else
		dir = self:GetAimVector()
	end
	local start = self:GetShootPos()
	local trace = {}
	trace.start = start
	trace.endpos = start + dir * distance
	trace.filter = self
	return util.TraceLine(trace)
end

function meta:EyeTraceLine( distance )
	local start = self:EyePos()
	local trace = {}
	trace.start = start
	trace.endpos = start + self:GetAimVector() * distance
	trace.filter = self
	return util.TraceLine(trace)
end

function meta:Gib( dmginfo )

	if not GORE_MOD then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		if dmginfo:IsBulletDamage() then
			effectdata:SetNormal( (self:GetPos()-dmginfo:GetInflictor():GetPos()):GetNormal() )
		else
			effectdata:SetNormal( dmginfo:GetDamageForce() )
		end
	util.Effect( "gib_player", effectdata )

end

function meta:SetPower( pow )

	if CLIENT then
		RunConsoleCommand("set_power",tostring(pow))
		return
	end

	if ((pow > (#HumanPowers)) or self.CurPower == pow or pow < 0) then return end
	
	self.CurPower = pow or 0
	umsg.Start( "SetPower" , self)
		umsg.Short( self.CurPower ) -- Vision gets activated client side
	umsg.End()
	
	if (self:Team() ~= TEAM_HUMAN) then return end
	
	-- Activate player speed when Speed power is activated
	if (pow == 1) then
		local runmultiplier = 1
		if (self.EquipedSuit == "scoutsspeedpack") then
			runmultiplier = 1.2
		end
		GAMEMODE:SetPlayerSpeed( self, HumanClass[self:GetPlayerClass()].WalkSpeed*SPEED_MULTIPLIER , HumanClass[self:GetPlayerClass()].RunSpeed*SPEED_MULTIPLIER*runmultiplier )
	else
		GAMEMODE:SetPlayerSpeed( self, HumanClass[self:GetPlayerClass()].WalkSpeed, HumanClass[self:GetPlayerClass()].RunSpeed)
	end
	self:PrintMessage(HUD_PRINTCONSOLE,"Power set to "..HumanPowers[pow].Name..".")
end

function meta:GetPower( pow )
	return self.CurPower
end

function meta:GetMaximumHealth()
	if SERVER then
		return self.MaxHP or 100
	else
		if self:GetPlayerClass() == 0 then
			return 0
		else
			if self.MaxHP then
				return self.MaxHP
			elseif self:Team() == TEAM_HUMAN then
				return HumanClass[self:GetPlayerClass()].Health
			elseif self:Team() == TEAM_UNDEAD then
				return UndeadClass[self:GetPlayerClass()].Health
			end
		end
	end
	return 100
end

function meta:GetMaxSuitPower()
	return self.MaxSP	
end

function meta:SetSuitPower(pow)
	if CLIENT then return end
	pow = math.Clamp(pow,0,self:GetMaxSuitPower())
	if (self.SP ~= pow) then
		self.SP = pow
		umsg.Start( "SetSP" , self)
			umsg.Short( pow )
		umsg.End()
	end
end

function meta:SuitPower()
	return self.SP	
end

function meta:Title()
	return self.TitleText or "Guest"
end

function meta:GetSuit()
	return self:GetNWEntity("suit")
end

function meta:DistanceToGround()
	local start = self:GetPos()
	local trace = {}
	trace.start = start
	trace.endpos = start + Vector(0,0,-1) * 999999
	trace.filter = self
	trace.mask = MASK_SOLID_BRUSHONLY
	
	local result = util.TraceLine(trace)
	if (result.Hit) then
		return (result.HitPos-start):Length()
	else
		return 999999
	end
end
