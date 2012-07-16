include("shared.lua")

SWEP.PrintName = "Heal Gun"
SWEP.Instructions = "Aim at team mate to start healing, stay close to keep healing. Consumes suit power!" 
	
SWEP.Author	= "" -- ClavusElite
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60
SWEP.DrawCrosshair = false

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "!", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	// Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:EmitHealParticles( pos )

	local em = ParticleEmitter(pos)
	for i=1, 8 do
		local part = em:Add("sprites/light_glow02_add",pos)
		if part then
			part:SetColor(200,200,255,math.random(255))
			part:SetVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),0):GetNormal() * (30+math.random(10)))
			part:SetDieTime(1)
			part:SetLifeTime(0)
			part:SetStartSize(10)
			part:SetEndSize(0)
		end
	end
	em:Finish()
	
end