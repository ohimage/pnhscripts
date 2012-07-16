include("shared.lua")

SWEP.PrintName = "Shape Shifter's Knife"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.CSMuzzleFlashes = false

SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.IconLetter = "j"
killicon.Add( "iw_und_shapeshiftersknife", "killicon/infectedwars/stalkerknife", Color(255, 80, 0, 255 ) )
--killicon.AddFont("iw_und_shapeshiftersknife", "CSKillIcons", SWEP.IconLetter, Color(255, 80, 0, 255))

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CurTime() < self.Weapon:GetNetworkedFloat("LastShootTime", -100) + self.Primary.Delay then return end

	local trace = self.Owner:TraceLine(62)

	if trace.Hit then
		if trace.MatType == MAT_FLESH or trace.MatType == MAT_BLOODYFLESH or trace.MatType == MAT_ANTLION or trace.MatType == MAT_ALIENFLESH then
			util.Decal("Blood", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		else
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal * 8, trace.HitPos - trace.HitNormal * 8)
		end
	end

	self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	// Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:SetWorldModel(str)
	self.WorldModel = str
end
