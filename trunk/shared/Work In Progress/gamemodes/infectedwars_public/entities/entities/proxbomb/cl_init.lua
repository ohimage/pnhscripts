include('shared.lua')

killicon.Add( "proxbomb", "killicon/infectedwars/proxbomb", Color(255, 80, 0, 255 ) )
util.PrecacheSound("npc/scanner/combat_scan2.wav")

function ENT:Initialize()

	local tab = { ">:3", ">:O", "SHI-", "WTF", "EPIC", "X.X", "0.o", "FFF-", "NOES", "D:>", "O_O" }
	self.DispText = tab[math.random(1,#tab)]
	
	self.DrawText = false
	
	timer.Simple(4,function(ent)
		if ValidEntity( ent ) then
			ent.DrawText = true
			ent:EmitSound("npc/scanner/combat_scan2.wav")
		end
	end, self)
end

function ENT:Draw()
	self.Entity:DrawModel()
	local FixAngles = self.Entity:GetAngles()
	local FixRotation = Vector(0, 270, 0)

	FixAngles:RotateAroundAxis(FixAngles:Right(), 	FixRotation.x)
	FixAngles:RotateAroundAxis(FixAngles:Up(), 		FixRotation.y)
	FixAngles:RotateAroundAxis(FixAngles:Forward(), FixRotation.z)
	local TargetPos = self.Entity:GetPos() + (self.Entity:GetUp() * 9)
	local _,_,_,a = self:GetColor()
	
	if self.DrawText then
		cam.Start3D2D(TargetPos, FixAngles, 0.15)
		draw.SimpleText(self.DispText, "InfoSmall", 25, -18, Color(255,0,0,a),1,1)
		cam.End3D2D() 
	end
end

function ENT:Think()

end
