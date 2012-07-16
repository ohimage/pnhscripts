AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:UpdateHealScore( target, prevhp )

	ply = self.Owner
	// Give Green-Coins for healing
	self.healstack = self.healstack + math.max(0, target:Health() - prevhp)
	if self.healstack > 30 then
		self.healstack = 0
		ply:GiveMoney( 1 )
	end	

	ply:AddScore("humanshealed",2)
	ply.AmountHealed = ply.AmountHealed+2
	
	if ply.AmountHealed >= 200 then
		ply:UnlockAchievement("bloodbuddy")
	end
	if ply:GetScore("humanshealed") > 10000 then
		ply:UnlockAchievement("motherteresa")
	end

end