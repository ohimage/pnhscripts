/*------------
Infected Wars
xrayvision.lua
Clientside
------------*/

-- Clientside X-ray-Heat-Vision
-- Version 1.2
-- by Teta_Bonita

-- Edited by ClavusElite for the Infected Wars gamemode

-- console commands:
-- toggle_xrayvision			-toggles xrayvision on/off

if not CLIENT then return end -- Clientside only

local sndOn = Sound( "items/nvg_on.wav" )
local sndOff = Sound( "items/nvg_off.wav" )

DoXRay = false

local DefMats = {}
local DefClrs = {}

-- A most likely futile attempt to make things faster
local pairs = pairs
local string = string
local render = render

local ColorTab = 
{
	[ "$pp_colour_addr" ] 		= -1,
	[ "$pp_colour_addg" ] 		= -1,
	[ "$pp_colour_addb" ] 		= -0.1,
	[ "$pp_colour_brightness" ] = 0.3,
	[ "$pp_colour_contrast" ] 	= 0.7,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0.1
}

-- This is where we replace the entities' materials
-- This is so unoptimized it's almost painful : (
XRayTimer = 0

local function XRayMat()

	local function IsXrayFiltered( v )
		local mustfilter = v:IsWeapon() or v:IsNPC() or v:IsPlayer() 
			or v:GetClass() == "suit_prop" or v:GetClass() == "prop_ragdoll"
			or v:GetClass() == "class C_HL2MPRagdoll" or v:GetClass() == "viewmodel"
			or v:GetClass() == "turret"
		
		return mustfilter
	end

	if XRayTimer <= CurTime() then
		
		XRayTimer = CurTime()+0.2
		
		for k,v in pairs( ents.GetAll() ) do
		
			if ValidEntity(v) and string.sub( (v:GetModel() or "" ), -3) == "mdl" then -- only affect models
			
				-- Inefficient, but not TOO laggy I hope
				local r,g,b,a = v:GetColor()
				local entmat = v:GetMaterial()

				if IsXrayFiltered( v ) then -- It's alive!
				
					if not (r == 255 and g == 255 and b == 255 and a == 255) then -- Has our color been changed?
						DefClrs[ v ] = Color( r, g, b, a )  -- Store it so we can change it back later
						v:SetColor( 255, 255, 255, 255 ) -- Set it back to what it should be now
					end
					
					if entmat ~= "xray/living" then -- Has our material been changed?
						DefMats[ v ] = entmat -- Store it so we can change it back later
						v:SetMaterial( "xray/living" ) -- The xray materials are designed to show through walls
					end
					
				else -- It's a prop or something
				
					if not (r == 255 and g == 255 and b == 255 and a == 70) then
						DefClrs[ v ] = Color( r, g, b, a )
						v:SetColor( 255, 255, 255, 70 )
					end
				
					if entmat ~= "xray/prop" then
						DefMats[ v ] = entmat
						v:SetMaterial( "xray/prop" )
					end

				end
			
			end

		end
		
	end
	
	--if not SinglePlayer() then
	--	hook.Remove( "RenderScene", "XRay_ApplyMats" )
	--end
		
end


-- This is where we do the post-processing effects.
local function XRayFX() 

	if not PP_ON then return end
	
	-- Colormod
	if PP_COLOR then 
		DrawColorModify( ColorTab ) 
	end
	
	if PP_BLOOM then
		-- Bloom
		DrawBloom(	0,  			-- Darken
	 				7,				-- Multiply
	 				0.06, 			-- Horizontal Blur
	 				0.06, 			-- Vertical Blur
	 				0, 				-- Passes
	 				0.25, 			-- Color Multiplier
	 				0, 				-- Red
	 				0, 				-- Green
	 				1 ) 			-- Blue
	end
	
end 


function XRayToggle()
 
	if DoXRay then
	
		hook.Remove( "RenderScene", "XRay_ApplyMats" )
		hook.Remove( "RenderScreenspaceEffects", "XRay_RenderModify" )

		DoXRay = false
		surface.PlaySound( sndOff )
		
		-- Set colors and materials back to normal
		for ent,mat in pairs( DefMats ) do
			if ent:IsValid() then
				if ent.IsGib then
					ent:SetMaterial( "models/flesh" )
				else
					ent:SetMaterial( mat )
				end
			end
		end
		
		for ent,clr in pairs( DefClrs ) do
			if ent:IsValid() then
				ent:SetColor( clr.r, clr.g, clr.b, clr.a )
			end
		end
		
		-- Clean up our tables- we don't need them anymore.
		DefMats = {}
		DefClrs = {}
		
	else
		local MySelf = LocalPlayer()
		-- Exit if we are out of suit power or not using the vision power at all
		if (MySelf:GetPower() ~= 2) then return end
		if (MySelf:SuitPower() <= 0) then
			MySelf:SetPower( 0 )
			return
		end
		
		hook.Add( "RenderScene", "XRay_ApplyMats", XRayMat ) -- We need to call this every frame in singleplayer, otherwise the server would make the materials reset
		hook.Add( "RenderScreenspaceEffects", "XRay_RenderModify", XRayFX )

		DoXRay = true
		surface.PlaySound( sndOn )

	end
 
end
concommand.Add( "toggle_xrayvision", XRayToggle )

local Xtimer = 0
local Xstep = XRAY_TIMER

local function XRayThink()
	
	local MySelf = LocalPlayer()
	
	-- If your suit power is 0, turn of Xray
	if DoXRay then
		if (MySelf:SuitPower() <= 0) then
			MySelf:SetPower( 0 ) -- turn off the power
			surface.PlaySound(SOUND_WARNING)
			RunConsoleCommand("toggle_xrayvision")
		else
			-- Else, keep draining suit power
			if (Xtimer <= CurTime()) then
				Xtimer = CurTime()+Xstep
				local cost = HumanPowers[2].Cost
				if MySelf:HasBought("duracell") then 
					cost = cost * 0.75 
				end
				RunConsoleCommand("decrement_suit",tostring(cost))
			end
		end
	end
	
end
hook.Add("Think", "XRayCheck", XRayThink)