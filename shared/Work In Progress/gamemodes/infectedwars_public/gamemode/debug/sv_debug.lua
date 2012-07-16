
function DebugVector( start, vector, color )

	umsg.Start("Debug_Vector")
		umsg.Vector( start )
		umsg.Vector( vector )
		umsg.Vector( Vector( color.r, color.g, color.b ) )
	umsg.End()

end