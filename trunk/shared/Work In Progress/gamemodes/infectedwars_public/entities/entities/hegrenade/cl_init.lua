
include('shared.lua')

killicon.AddFont( "hegrenade", 	"CSKillIcons", 	"h", Color( 255, 80, 0, 255 ) )

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()
	self.Entity:DrawModel()
end


/*---------------------------------------------------------
   Name: IsTranslucent
   Desc: Return whether object is translucent or opaque
---------------------------------------------------------*/
function ENT:IsTranslucent()
	return true
end


