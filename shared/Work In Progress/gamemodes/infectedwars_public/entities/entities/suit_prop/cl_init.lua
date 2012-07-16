include("shared.lua")

ENT.scale = 1

function ENT:SetScale()

	if self.scale != self:GetNWInt("scale") then
		self.scale = self:GetNWInt("scale")
		self:SetModelScale(Vector(self.scale,self.scale,self.scale))
	end
end

function ENT:Draw()  
	if (!ValidEntity(self:GetOwner())) then return end
	local dead = !self:GetOwner():Alive()
	local isself = (LocalPlayer() == self:GetOwner())
	if (isself and !dead) then return end

	self:SetScale()
	
	local bonename = self:GetNWString("bone")
	if (bonename == "ValveBiped.Bip01_Head1" and isself) then return end 
	local ply = self:GetOwner():GetRagdollEntity() or self:GetOwner()
	local bone = ply:LookupBone(bonename)  
	if bone then  
		local position, angles = ply:GetBonePosition(bone)
		
		local localpos = self:GetNWVector("position")
		local localang = self:GetNWAngle("angles")

		local newpos, newang = LocalToWorld( localpos, localang, position, angles ) 

		self:SetPos(newpos)  
		self:SetAngles(newang)  

		self:DrawModel()
	end 
	
end  

/*
for k, v in pairs(ents.FindByModel("models//gibs/hgibs.mdl")) do v:SetNWAngle("angles", Angle(0,0,0)) end
*/
