
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local sndOnline = Sound( "weapons/tripwire/mine_activate.wav" )

function ENT:Think()

	if ( self:GetActiveTime() == 0 || self:GetActiveTime() > CurTime() ) then return end
	if ( self.Activated ) then return end
	
	self.Activated = true
	self.Entity:GetOwner():EmitSound( sndOnline )

end


function ENT:StartTouch( ent )

	if ( self:GetActiveTime() == 0 || self:GetActiveTime() > CurTime() ) then return end

	if ent:IsPlayer() then	
		if ent:Team() == TEAM_UNDEAD then
			ent:SetDetectable(true)
			self.Entity:GetOwner():GetTable():Alarm()
		else
			self.Entity:GetOwner():GetTable():Notify()
		end		
	end

end


