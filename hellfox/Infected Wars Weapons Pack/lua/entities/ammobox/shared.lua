AddCSLuaFile("shared.lua")

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= "ClavusElite"
ENT.Purpose			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

util.PrecacheModel("models/Items/BoxMRounds.mdl")
util.PrecacheSound("items/ammo_pickup.wav")

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
		self.Entity:SetModel("models/Items/BoxMRounds.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)	
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.Entity:DrawShadow( true )
		self.active = false
		self:SetTrigger(true)
		timer.Simple(1,function(me) me.active = true end,self)
	end	
	
	function ENT:StartTouch( ent )
		if self.active and ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_HUMAN then
			local weps = ent:GetWeapons()
			local primtype = ""
			for k, v in pairs(weps) do
				if v:IsValid() and v.Primary ~= nil then
					if v.Primary.Ammo == "grenade" then
						ent:GiveAmmo(2, v:GetPrimaryAmmoType())
					elseif v.Primary.Ammo == "slam" then
						ent:GiveAmmo(1, v:GetPrimaryAmmoType())
					else
						local primtype = v:GetPrimaryAmmoType()
						local clips = 2
						if v.Primary.ClipSize <= 20 then
							clips = 4
						elseif v.Primary.ClipSize <= 50 then
							clips = 3
						end
						
						local stashmultiplier = 1
						if (ent:HasBought("ammostash3")) then
							stashmultiplier = 2
						elseif (ent:HasBought("ammostash2")) then
							stashmultiplier = 1.5
						elseif (ent:HasBought("ammostash1")) then
							stashmultiplier = 1.25
						end
						
						ent:GiveAmmo(math.ceil(v.Primary.ClipSize*clips*stashmultiplier), primtype)
					end
				end
			end
			if ent ~= self:GetOwner() and self:GetOwner():IsValid() then
				self:GetOwner():AddScore("ammosupplied",1)
				self:GetOwner().AmountSupplied = self:GetOwner().AmountSupplied+20
				
				if self:GetOwner():GetScore("ammosupplied") > 100 then
					self:GetOwner():UnlockAchievement("gunshop")
				end
			end
					
			timer.Simple(0,function (me) me:Remove() end,self)
			function self:StartTouch() end
		end
	end
	
	function ENT:OnRemove()
		active = false
	end

end
