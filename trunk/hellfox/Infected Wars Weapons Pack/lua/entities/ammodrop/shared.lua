AddCSLuaFile("shared.lua")

ENT.Type 			= "anim"
ENT.PrintName		= ""
ENT.Author			= "ClavusElite"
ENT.Purpose			= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

util.PrecacheModel("models/Items/BoxSRounds.mdl")
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
		self.Entity:SetModel("models/Items/BoxSRounds.mdl")
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
			local atype = ""
			for k, v in pairs(weps) do				
				if v:IsValid() and v.Primary ~= nil then
					if v.Primary.Ammo == "grenade" then
						ent:GiveAmmo(1, v:GetPrimaryAmmoType())
					else
						local clips = 1
						if v.Primary.ClipSize <= 20 then
							clips = 3
						elseif v.Primary.ClipSize <= 50 then
							clips = 2
						elseif v.Primary.ClipSize <= 100 then
							clips = 1
						end
						
						local stashmultiplier = 1
						if (ent:HasBought("ammostash3")) then
							stashmultiplier = 2
						elseif (ent:HasBought("ammostash2")) then
							stashmultiplier = 1.5
						elseif (ent:HasBought("ammostash1")) then
							stashmultiplier = 1.25
						end
						
						ent:GiveAmmo(math.ceil(v.Primary.ClipSize*clips*stashmultiplier), v:GetPrimaryAmmoType())
					end
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
