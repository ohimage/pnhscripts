require( "datastream" )
DeriveGamemode( "sandbox" );

LPRP = {}

include("VGUI/include_cl.lua")
include( "shared.lua" )
include( "hud_cl.lua" )
include( "plugins/loader.lua" )
include( "classes_sh.lua" )
include( "classes_cl.lua" )
include( "player_cl.lua" )
include( "chat_cl.lua" )

local damagePoints = {}

usermessage.Hook( "LPRP_ShowHitPoint",function( data )
	local pos = data:ReadVector()
	local dmg = data:ReadShort()
	table.insert( damagePoints, {dmg = dmg,p = pos, vel = Vector( math.random(-2,2), math.random(-2,2),math.random(0,5)) } )
end)

local function hitsWorld( P1, P2 , filter)
	local trace = {}
	trace.start = P1
	trace.endpos = P2
	trace.filter = filter or {}
	local res = util.TraceLine( trace )
	return res.HitWorld
end

hook.Add("HUDPaint","LPRP_DamageThingy",function()
	for k,v in pairs(damagePoints)do
		local vel = v.vel
		local p = v.p
		local scrp = p:ToScreen()
		draw.DrawText( v.dmg,  "Trebuchet18", scrp.x,  scrp.y , Color( 255,0,0,255), TEXT_ALIGN_CENTER )
		p = p + vel
		vel.z = vel.z - 0.1
		v.vel = vel
		v.p = p
		if(hitsWorld( v.p, v.p + v.vel ))then
			print("Its hitting something! Removing it.")
			table.remove( damagePoints, k)
		end
	end
end)