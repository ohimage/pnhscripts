AddCSLuaFile("shared.lua")

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= "ClavusElite"
ENT.Purpose			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

util.PrecacheModel("models/weapons/w_bugbait.mdl")
util.PrecacheSound("weapons/bugbait/bugbait_impact1.wav")
util.PrecacheSound("weapons/bugbait/bugbait_impact3.wav")

if CLIENT then

	function ENT:Draw()
		self.BaseClass.Draw(self)
	end

	function ENT:OnRemove()
	end

	function ENT:Think()	
	end
end

if SERVER then

	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_bugbait.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)	
	end	
	
	function ENT:Think()
		if self.Entity:WaterLevel() > 0 then
			if math.random(1,2) == 1 then
				self:EmitSound("weapons/bugbait/bugbait_impact1.wav")
			else
				self:EmitSound("weapons/bugbait/bugbait_impact3.wav")
			end
			timer.Simple(0,function (me) me:Remove() end,self)	
			function self.Think() end
		end
	end
	
	function ENT:GetName()
		return "< Infection Ball >"
	end
	
	function ENT:PhysicsCollide( data, physobj )
		local decal = "Antlion.Splat"
		
		-- Create splatter decal
		local Pos1 = data.HitPos + data.HitNormal
		local Pos2 = data.HitPos - data.HitNormal
		util.Decal(decal, Pos1, Pos2) 
			
		if data.HitEntity and data.HitEntity:IsValid() then
			if data.HitEntity:IsPlayer() then
				local ply = data.HitEntity
				if ply:Team() == TEAM_HUMAN then
					ply:SendLua("Contaminate()")
					if ply.Detectable == false then
						ply:SetDetectable(true)
						if self:GetOwner():IsValid() then
							self:GetOwner().Marked = self:GetOwner().Marked+1
							table.insert(self:GetOwner().MarkedThisLife, ply)
							if self:GetOwner().Marked >= 5 then
								self:GetOwner():UnlockAchievement("icanseeyou")
							end
						end
					end
				end
			end
			
			if SERVER and not data.HitEntity:IsWorld() 
				and data.HitEntity:GetClass() ~= "prop_ragdoll" then
	   
				local decal =  
				{  
					decal,  
					data.HitEntity:WorldToLocal(Pos1),  
					data.HitEntity:WorldToLocal(Pos2)  
				} 
				
				if not data.HitEntity:GetTable().decals then data.HitEntity:GetTable().decals = {} end 
	   
				table.insert( data.HitEntity:GetTable().decals, 1, decal ) 
	   
			 	//Trim decal table so only 20 decals are saved 
			 	if #data.HitEntity:GetTable().decals > 20 then 
			 		data.HitEntity:GetTable().decals[21] = nil 
			 	end
			end
		end
		
		if math.random(1,2) == 1 then
			self:EmitSound("weapons/bugbait/bugbait_impact1.wav")
		else
			self:EmitSound("weapons/bugbait/bugbait_impact3.wav")
		end
		timer.Simple(0,function (me) me:Remove() end,self)
	end
	
	function ENT:OnRemove()
	end

end
