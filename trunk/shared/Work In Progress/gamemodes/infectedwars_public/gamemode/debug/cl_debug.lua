
DEBUG_DRAWVECS = true
local debugvecs = {}

local function DebugPaint()

	if (DEBUG_DRAWVECS) then
		for k, v in pairs(debugvecs) do
			local cross = v.vector:GetNormal():Cross(Vector(0,0,1))
			local arr1 = (v.start + (v.vector - (v.vector:GetNormal()*2) + (cross*2))):ToScreen()
			local arr2 = (v.start + (v.vector - (v.vector:GetNormal()*2) - (cross*2))):ToScreen()
			
			local stpos = v.start:ToScreen()
			local endpos = (v.start+v.vector):ToScreen()
			
			surface.SetDrawColor( v.color )
			surface.DrawLine( stpos.x, stpos.y, endpos.x, endpos.y )
			
			if (v.vector:Length() > 3) then
				surface.DrawLine( arr1.x, arr1.y, endpos.x, endpos.y )
				surface.DrawLine( arr2.x, arr2.y, endpos.x, endpos.y )
			end
		end
	end

end
hook.Add("HUDPaint","DrawDebug",DebugPaint)

local function DebugVecs(um)
	local start = um:ReadVector()
	local vec = um:ReadVector()
	local col = um:ReadVector()
	
	table.insert( debugvecs, { start = start, vector = vec, color = Color(col.x, col.y, col.z, 255) } )

end
usermessage.Hook("Debug_Vector", DebugVecs)