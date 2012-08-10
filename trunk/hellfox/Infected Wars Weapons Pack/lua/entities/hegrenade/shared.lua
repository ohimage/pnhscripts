
ENT.Type = "anim"

ENT.PrintName		= "High-Explosive Grenade"
ENT.Author			= "Night-Eagle"
ENT.Contact			= ""
ENT.Purpose			= nil
ENT.Instructions	= nil


/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self.Entity:EmitSound(Sound("HEGrenade.Bounce"))
	end
	
	local impulse = -data.Speed * data.HitNormal * .3 + (data.OurOldVelocity * -.3)
	phys:ApplyForceCenter(impulse)
end
