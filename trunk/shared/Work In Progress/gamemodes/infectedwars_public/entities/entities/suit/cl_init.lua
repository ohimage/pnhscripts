include("shared.lua")

function ENT:Draw()  
	return false	
end  

function ENT:Think()
	if ValidEntity(self:GetOwner()) then
		self:GetOwner().EquipedSuit = self:GetNWString("suitname")
	end
end
function ENT:OnRemove()
	if ValidEntity(self:GetOwner()) then
		self:GetOwner().EquipedSuit = nil
	end
end