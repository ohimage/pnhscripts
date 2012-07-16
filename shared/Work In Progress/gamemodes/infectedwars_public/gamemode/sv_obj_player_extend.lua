/*------------
Infected Wars
sv_obj_player_extend.lua
Serverside
------------*/

local meta = FindMetaTable( "Player" )
if (!meta) then return end

function meta:GiveMoney( amount )
	if self:IsBot() then return end
	self.DataTable["money"] = self.DataTable["money"] + amount
	GAMEMODE:SendCoins(self, amount)
end

function meta:TakeMoney( amount, hash )
	if self:IsBot() then return end
	self.DataTable["money"] = self.DataTable["money"] - amount
	GAMEMODE:SendCoins(self)
end

function meta:AddScore( stat, amount )
	if not PLAYER_STATS then return end
	self.DataTable[stat] = self.DataTable[stat] + amount
end

function meta:UnlockAchievement( stat )
	if not PLAYER_STATS then return end
	if self.DataTable["achievements"][stat] == true then return end
	self.DataTable["achievements"][stat] = true
	self.DataTable["progress"] = math.floor(self:GetAchvProgress())
	self:SendLua('UnlockEffect("'..stat..'")')
	PrintMessageAll(HUD_PRINTTALK,"Player "..self:Name().." got the achievement: "..achievementDesc[stat].Name.."!")
	
	local hasAll = true
	for k, v in pairs(self.DataTable["achievements"]) do
		if not v and k ~= "masterofiw" then
			hasAll = false
		end
	end
	if hasAll then
		self:UnlockAchievement("masterofiw")
	else
		self.DataTable["achievements"]["masterofiw"] = false
	end
end

function meta:SetPlayerClass( i )

	self.Class = i
	umsg.Start( "SetClass" )
		umsg.Entity( self )
		umsg.Short( i )
	umsg.End()
end

-- using my own max-health system
function meta:SetMaximumHealth(hp)
	hp = math.max(1,hp)
	self.MaxHP = hp
	umsg.Start( "SetMaxHP" )
		umsg.Entity( self )
		umsg.Short( hp )
	umsg.End()
end

function meta:SetDetectable( detect )
	if self.Detectable == detect then return end
	self.Detectable = detect
	umsg.Start( "SetDetectable" )
		umsg.Entity( self )
		umsg.Bool( detect )
	umsg.End()
end

-- suit power system
function meta:SetMaxSuitPower(pow)
	pow = math.max(pow,0)
	if (self.MaxSP ~= pow) then
		self.MaxSP = pow
		umsg.Start( "SetMaxSP" , self)
			umsg.Short( pow )
		umsg.End()
	end
end

function meta:SetTitle( text )
	self.TitleText = text
	-- Send new title to everyone
	umsg.Start( "SetTitle" )
		umsg.Entity( self )
		umsg.String( text )
	umsg.End()
end

function meta:SetSuit( item )

	local suitdata = suitsData[item]

	if !suitdata or self:GetPlayerClass() != suitdata.class or self:Team() != suitdata.team then return end
	
	local cursuit = self:GetSuit()
	if ValidEntity(cursuit) then
		if item != self.lastSuit then
			cursuit:Remove()
			self.lastSuit = nil
		else
			return
		end
	end

	self.EquipedSuit = item
	
	local ent = ents.Create("suit")
	if ent then
		ent:SetOwner(self)
		ent:SetParent(self)
		ent:SetPos(self:GetPos())
		ent:Spawn()
		ent:CreateSuit( suitdata.suit, item )
		self:SetNWEntity("suit", ent)
		self.lastSuit = item
	end
end

function meta:CheckSuit()
	local cursuit = self:GetSuit()
	if ValidEntity(cursuit) then
		local suitdata = suitsData[self.lastSuit]

		if !suitdata or self:GetPlayerClass() != suitdata.class or self:Team() != suitdata.team then
			cursuit:Remove()
			self.lastSuit = nil
			self.EquipedSuit = nil
		end
	else
		self.EquipedSuit = nil
	end
end

// GetImpulse is used for walljumping. To help make it easier, GetImpulse is a sort of velocity history
function meta:GetImpulse()
	return ImpulseList[self].speed or 0
end

function meta:GetImpulseDir()
	return ImpulseList[self].dir or Vector(0,0,0)
end
