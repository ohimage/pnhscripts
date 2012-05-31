if not CLIENT then return end

local sndOn = Sound( "common/bugreporter_succeeded.wav" )
local sndOff = Sound( "common/bugreporter_succeeded.wav" )

local Dowall = false

local DefMats = {}
local DefClrs = {}

local pairs = pairs
local string = string
local render = render
local surface = surface

local ColorTab = 
{
	[ "$pp_colour_addr" ] 		= -0.1,
	[ "$pp_colour_addg" ] 		= -0.1,
	[ "$pp_colour_addb" ] 		= -0.1,
	[ "$pp_colour_brightness" ] 	= 0.1,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= -0.1,
	[ "$pp_colour_mulg" ] 		= -0.1,
	[ "$pp_colour_mulb" ] 		= -0.1
}

local function processEntity( v )
	if string.sub( (v:GetModel() or "" ), -3) == "mdl" then 
		local r,g,b,a = v:GetColor()
		local entmat = v:GetMaterial()
		// weapon block
		if not v:IsWeapon() then
			-- is player or alive
			if v:IsNPC() or v:IsPlayer() then 

				if not (r == 255 and g == 255 and b == 255 and a == 255) then -- Has our color been changed?
					DefClrs[ v ] = Color( r, g, b, a )  -- Store it so we can change it back later
					v:SetColor( 255, 255, 255, 255 ) -- Set it back to what it should be now
				end

				if entmat ~= "wall/living" then -- Has our material been changed?
					DefMats[ v ] = entmat -- Store it so we can change it back later
					v:SetMaterial( "wall/living" ) -- The wall matierals are designed to show through walls
				end

				else -- else part of is player or npc

				if not (r == 255 and g == 255 and b == 255 and a == 70) then
					DefClrs[ v ] = Color( r, g, b, a )
					v:SetColor( 255, 255, 255, 70 )
				end

				if entmat ~= "wall/prop" then
					DefMats[ v ] = entmat
					v:SetMaterial( "wall/prop" )
				end

			end -- end of player or npc
		else -- end of the is weapon block
			v:SetMaterial("Arealmouse/greenglass")
		end
	end
end

local function wallMat()
	local etbl = ents.GetAll()
	if( true)then
		lastCount = #etbl
		local lpos = LocalPlayer():GetPos() + Vector( 0, 0, 50 )
		for k,v in pairs( etbl ) do	
			if( lpos:Distance( v:GetPos() ) > 6000 )then
			
			else
				local trace = {}
				trace.start = v:GetPos()
				trace.endpos = lpos
				trace.filter = {LocalPlayer(), v}
				local res = util.TraceLine( trace )
				if( res.Hit )then
					processEntity( v )
				else
					if(v:IsPlayer() or v:IsNPC())then
						v:SetColor( 255, 255, 0,255)
					else
						v:SetColor( 0, 255, 255,255)
					end
					v:SetMaterial( "models/wireframe" )
				end
			end
		end
	end
		
end



local function wallFX() 

	-- Colormod
	DrawColorModify( ColorTab )
	
	-- Bloom
	DrawBloom(		0,  			-- Darken
 				0,				-- Multiply
 				0, 			-- Horizontal Blur
 				0, 			-- Vertical Blur
 				1, 				-- Passes
 				1, 			-- Color Multiplier
 				-0.1, 				-- Red 0.1
 				-0.1, 				-- Green 0.1
 				-0.1 ) 			-- Blue 0.1
	
end 


local function wallToggle()
 
	if Dowall then
	
		hook.Remove( "RenderScene", "wall_ApplyMats" )
		hook.Remove( "RenderScreenspaceEffects", "wall_RenderModify" )

		Dowall = false
		surface.PlaySound( sndOff )
		
		-- Set colors and materials back to normal
		for ent,mat in pairs( DefMats ) do
			if ent:IsValid() then
				ent:SetMaterial( mat )
			end
		end
		
		for ent,clr in pairs( DefClrs ) do
			if ent:IsValid() then
				ent:SetColor( clr.r, clr.g, clr.b, clr.a )
			end
		end
		
		DefMats = {}
		DefClrs = {}
		
	else
	
		hook.Add( "RenderScene", "wall_ApplyMats", wallMat ) 
		hook.Add( "RenderScreenspaceEffects", "wall_RenderModify", wallFX )

		Dowall = true
		surface.PlaySound( sndOn )
	end
 
end
concommand.Add( "PHack_togglewalls", wallToggle )
