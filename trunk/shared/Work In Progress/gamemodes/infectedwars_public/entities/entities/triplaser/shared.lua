ENT.Type = "anim"
ENT.PrintName = ""
ENT.Author = "ClavusElite" -- Code based on trip mine from The Stalker made by Rambo_6 (aka Sechs)
ENT.Purpose	= ""

function ENT:Initialize()
	if SERVER then
		self.Entity:DrawShadow( false )
		self.Entity:SetSolid( SOLID_BBOX )
		self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.Entity:SetTrigger( true )
	end
	self.at = CurTime() + 2
end


/*---------------------------------------------------------
---------------------------------------------------------*/
function ENT:SetEndPos( endpos )
	self.Entity:SetNetworkedVector( "endpos", endpos )	
	self.Entity:SetCollisionBoundsWS( self.Entity:GetPos(), endpos, Vector() * 0.25 )
end


/*---------------------------------------------------------
---------------------------------------------------------*/
function ENT:GetEndPos()
	return self.Entity:GetNetworkedVector( "endpos" )
end


/*---------------------------------------------------------
---------------------------------------------------------*/
function ENT:GetActiveTime()
	--return self.Entity:GetNetworkedFloat( "at" )
	return self.at
end
