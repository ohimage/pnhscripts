/*------------
Infected Wars
cl_screeneffects.lua
Clientside
------------*/

/* -------------------------
	Post processing effects
---------------------------*/
BlurTimer = 0
BlurOn = false

-- Remove sandbox colormodification
hook.Remove("RenderScreenspaceEffects", "RenderColorModify")

CreateClientConVar("_iw_enablepp", 1, true, false)
CreateClientConVar("_iw_enablemotionblur", 1, true, false)
CreateClientConVar("_iw_enablecolormod", 1, true, false)
CreateClientConVar("_iw_enablebloom", 1, true, false)
CreateClientConVar("_iw_enablesharpen", 1, true, false)
CreateClientConVar("_iw_enableshellfx", 1, true, false)
CreateClientConVar("_iw_enablemuzzlefx", 1, true, false)
CreateClientConVar("_iw_enablegore", 1, true, false)

PP_ON = util.tobool(GetConVarNumber("_iw_enablepp"))
PP_MOTIONBLUR = util.tobool(GetConVarNumber("_iw_enablemotionblur"))
PP_COLOR = util.tobool(GetConVarNumber("_iw_enablecolormod"))
PP_BLOOM = util.tobool(GetConVarNumber("_iw_enablebloom"))
PP_SHARPEN = util.tobool(GetConVarNumber("_iw_enablesharpen"))
EFFECT_MUZZLE = util.tobool(GetConVarNumber("_iw_enablemuzzlefx"))
EFFECT_SHELL = util.tobool(GetConVarNumber("_iw_enableshellfx"))
EFFECT_UBERGORE = util.tobool(GetConVarNumber("_iw_enablegore"))

-- Weapon effect toggle commands
function ToggleShell( pl,commandName,args )
	local MySelf = LocalPlayer()
	EFFECT_SHELL = util.tobool(args[1])
	if EFFECT_SHELL then 
		RunConsoleCommand("_iw_enableshellfx","1")
		RunConsoleCommand("_shellfx","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Shell fx on")
	else 
		RunConsoleCommand("_iw_enableshellfx","0")
		RunConsoleCommand("_shellfx","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Shell fx off")
	end
end
concommand.Add("iw_enableshellfx",ToggleShell) 

function ToggleMuzzle( pl,commandName,args )
	local MySelf = LocalPlayer()
	EFFECT_MUZZLE = util.tobool(args[1])
	if EFFECT_MUZZLE then 
		RunConsoleCommand("_iw_enablemuzzlefx","1")
		RunConsoleCommand("_muzzlefx","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Additional muzzle fx on")
	else 
		RunConsoleCommand("_iw_enablemuzzlefx","0")
		RunConsoleCommand("_muzzlefx","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Additional muzzle fx off")
	end
end
concommand.Add("iw_enablemuzzlefx",ToggleMuzzle) 

function ToggleGore( pl,commandName,args )
	local MySelf = LocalPlayer()
	EFFECT_UBERGORE = util.tobool(args[1])
	if EFFECT_UBERGORE then 
		RunConsoleCommand("_iw_enablegore","1")
		RunConsoleCommand("_muzzlefx","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Over-the-top gore turned on")
	else 
		RunConsoleCommand("_iw_enablegore","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Over-the-top gore turned off")
	end
end
concommand.Add("iw_enablegore",ToggleGore) 

function InitShellMuzzleFX()
	RunConsoleCommand("_muzzlefx",EFFECT_MUZZLE)
	RunConsoleCommand("_shellfx",EFFECT_SHELL)	
end
hook.Add("Initialize", "MuzzleShellFX", InitShellMuzzleFX)

-- Add PP colormod toggle commands
function TogglePP( pl,commandName,args )
	local MySelf = LocalPlayer()
	PP_ON = util.tobool(args[1])
	if PP_ON then 
		RunConsoleCommand("_iw_enablepp","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Screeneffects on")
	else 
		RunConsoleCommand("_iw_enablepp","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Screeneffects off")
	end
end
concommand.Add("iw_enablepp",TogglePP) 

function ToggleColor( pl,commandName,args )
	local MySelf = LocalPlayer()
	PP_COLOR = util.tobool(args[1])
	if PP_COLOR then 
		RunConsoleCommand("_iw_enablecolormod","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Colormod on")
	else 
		RunConsoleCommand("_iw_enablecolormod","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Colormod off")
	end
end
concommand.Add("iw_enablecolormod",ToggleColor) 

function ToggleMotionBlur( pl,commandName,args )
	local MySelf = LocalPlayer()
	PP_MOTIONBLUR = util.tobool(args[1])
	if PP_MOTIONBLUR then 
		RunConsoleCommand("_iw_enablemotionblur","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Motionblur on")
	else 
		RunConsoleCommand("_iw_enablemotionblur","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Motionblur off")
	end
end
concommand.Add("iw_enablemotionblur",ToggleMotionBlur) 

function ToggleBloom( pl,commandName,args )
	local MySelf = LocalPlayer()
	PP_BLOOM = util.tobool(args[1])
	if PP_BLOOM then 
		RunConsoleCommand("_iw_enablebloom","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Bloom on")
	else 
		RunConsoleCommand("_iw_enablebloom","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Bloom off")
	end
end
concommand.Add("iw_enablebloom",ToggleBloom) 

function ToggleSharpen( pl,commandName,args )
	local MySelf = LocalPlayer()
	PP_SHARPEN = util.tobool(args[1])
	if PP_SHARPEN then 
		RunConsoleCommand("_iw_enablesharpen","1")
		MySelf:PrintMessage( HUD_PRINTTALK, "Sharpen on")
	else 
		RunConsoleCommand("_iw_enablesharpen","0")
		MySelf:PrintMessage( HUD_PRINTTALK, "Sharpen off")
	end
end
concommand.Add("iw_enablesharpen",ToggleSharpen) 

--[[ Blur and HUD color effects ]]--

local UndeadColTab = 
{
	[ "$pp_colour_addr" ] 		= 18/255,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = -0.04,
	[ "$pp_colour_contrast" ] 	= 1.15,
	[ "$pp_colour_colour" ] 	= 0.6,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}
local HumanColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 20/255,
	[ "$pp_colour_addb" ] 		= 24/255,
	[ "$pp_colour_brightness" ] = -0.08,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

// No longer used this one
/*local function DrawSpeedBlur()
	if not PP_ON or not PP_MOTIONBLUR then return end
	DrawMotionBlur( 0.8, 0.8, 0.03)
end*/

local function DrawUndeadHUDColor()
	if DoXRay then return end -- Don't mess with Xray mode
	if not PP_ON or not PP_COLOR then return end	
	DrawColorModify( UndeadColTab )
end

local function DrawHumanHUDColor()
	if DoXRay then return end -- Don't mess with Xray mode
	if not PP_ON or not PP_COLOR then return end
	DrawColorModify( HumanColTab )
end

--[[ Power selection 'flash' effect ]]--

local FlashTime = 0
local FlashColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

local flash = { red = 0, green = 0, blue = 0 }

local function DrawPowerFlash()
	DrawColorModify( FlashColTab )
	
	FlashColTab[ "$pp_colour_addr" ] 		= math.Approach( FlashColTab[ "$pp_colour_addr" ], 0, flash.red*FrameTime())
	FlashColTab[ "$pp_colour_addg" ] 		= math.Approach( FlashColTab[ "$pp_colour_addg" ], 0, flash.green*FrameTime())
	FlashColTab[ "$pp_colour_addb" ] 		= math.Approach( FlashColTab[ "$pp_colour_addb" ], 0, flash.blue*FrameTime())
	FlashColTab[ "$pp_colour_brightness" ] 	= math.Approach( FlashColTab[ "$pp_colour_brightness" ], 0, 0.03*FrameTime())

	if (CurTime() > FlashTime) then
		hook.Remove("RenderScreenspaceEffects", "DrawPowerFlash")
	end
end

function CreatePowerFlash( r, g, b ) -- Used in cl_radialmenu.lua
	if not PP_ON or not PP_COLOR then return end
	hook.Remove("RenderScreenspaceEffects", "DrawPowerFlash")
	FlashColTab[ "$pp_colour_addr" ] 		= r/255
	FlashColTab[ "$pp_colour_addg" ] 		= g/255
	FlashColTab[ "$pp_colour_addb" ] 		= b/255
	FlashColTab[ "$pp_colour_brightness" ] 	= 0.03
	flash.red = r/255
	flash.green = g/255
	flash.blue = b/255
	FlashTime = CurTime()+1.2
	hook.Add("RenderScreenspaceEffects", "DrawPowerFlash", DrawPowerFlash) 
end

--[[ Stalker Screen Fuck effect ]]--

local FuckedTime = 0
local FuckedLength = 0
local FuckColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 0.5,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

local function DrawStalkerFuck()
	DrawColorModify( FuckColTab )
	DrawMotionBlur( 0.2, math.Clamp(FuckedTime-CurTime(),0,1), 0)
	FuckColTab[ "$pp_colour_colour" ] = math.Approach( FuckColTab[ "$pp_colour_colour" ], 1, FuckedLength*FrameTime())
	local sev = math.Clamp(FuckedTime-CurTime(),0,5)/25
	FuckColTab[ "$pp_colour_brightness" ] = math.Rand(-sev*2,sev*2)
	
	local MySelf = LocalPlayer()
	MySelf:SetEyeAngles((MySelf:GetAimVector()+Vector(math.Rand(-sev,sev),math.Rand(-sev,sev),math.Rand(-sev,sev))):Angle())
	
	if FuckedTime < CurTime() then
		FuckColTab[ "$pp_colour_brightness" ] = 0
		hook.Remove("RenderScreenspaceEffects", "DrawStalkerFuck")
	end
end

function StalkerFuck(length)
	if not length then length = 3 end
	hook.Remove("RenderScreenspaceEffects", "DrawStalkerFuck")
	FuckColTab[ "$pp_colour_colour" ] = 0.5
	FuckedTime = CurTime()+length
	FuckedLength = length
	hook.Add("RenderScreenspaceEffects", "DrawStalkerFuck", DrawStalkerFuck)
end

--[[ Stalker Scream effect ]]--

local DrawTime = 0

local function DrawStalkerScream()
	DrawSharpen( (DrawTime-CurTime())/2 ,DrawTime-CurTime() )
	local MySelf = LocalPlayer()
	local sev = 0.01
	MySelf:SetEyeAngles((MySelf:GetAimVector()+Vector(math.Rand(-sev,sev),math.Rand(-sev,sev),math.Rand(-sev,sev))):Angle())	
	if DrawTime < CurTime() then
		hook.Remove("RenderScreenspaceEffects", "DrawStalkerScream")
	end
end

function StalkerScream()
	hook.Remove("RenderScreenspaceEffects", "DrawStalkerScream")
	DrawTime = CurTime()+2
	hook.Add("RenderScreenspaceEffects", "DrawStalkerScream", DrawStalkerScream)
end

--[[ Contamination effect ]]--

local ConColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}
local DrawCont = 0
local step = 5

local function DrawContamination()
	
	ConColTab[ "$pp_colour_addr" ] 		= math.Approach( ConColTab[ "$pp_colour_addr" ], 0, 150/255*FrameTime())
	ConColTab[ "$pp_colour_addg" ] 		= math.Approach( ConColTab[ "$pp_colour_addg" ], 0, 195/255*FrameTime())
	ConColTab[ "$pp_colour_addb" ] 		= math.Approach( ConColTab[ "$pp_colour_addb" ], 0, 80/255*FrameTime())
	ConColTab[ "$pp_colour_brightness" ] = math.Rand(-0.02,0.02)
	ConColTab[ "$pp_colour_colour" ] = math.Rand(0.5,1.5)
	
	DrawColorModify( ConColTab )
	
	local sev = math.max((DrawCont-CurTime())/250,0)
	local MySelf = LocalPlayer()
	MySelf:SetEyeAngles((MySelf:GetAimVector()+Vector(math.Rand(-sev,sev),math.Rand(-sev,sev),math.Rand(-sev,sev))):Angle())
	
	if step > math.max((DrawCont-CurTime())*2,0) then
		step = step-1
		RunConsoleCommand("decrement_suit",10)
	end
	
	if DrawCont < CurTime() then
		hook.Remove("RenderScreenspaceEffects", "DrawContamination")
	end
end

function Contaminate()
	hook.Remove("RenderScreenspaceEffects", "DrawContamination")
	ConColTab[ "$pp_colour_addr" ] 	= 150/255
	ConColTab[ "$pp_colour_addg" ] 	= 195/255
	ConColTab[ "$pp_colour_addb" ] 	= 80/255
	ConColTab[ "$pp_colour_brightness" ] = 0
	ConColTab[ "$pp_colour_colour" ] = 1
	step = 10
	DrawCont = CurTime()+5
	hook.Add("RenderScreenspaceEffects", "DrawContamination", DrawContamination)
end

--[[ Drain effect ]]--

local DrainColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}
local DrawDrn = 0
local DrainSev = 0

local function DrawDrain()
	
	DrainColTab[ "$pp_colour_addr" ] 		= math.Approach( DrainColTab[ "$pp_colour_addr" ], 0, 60/255*FrameTime())
	DrainColTab[ "$pp_colour_addg" ] 		= math.Approach( DrainColTab[ "$pp_colour_addg" ], 0, 10/255*FrameTime())
	DrainColTab[ "$pp_colour_addb" ] 		= math.Approach( DrainColTab[ "$pp_colour_addb" ], 0, 10/255*FrameTime())
	DrainColTab[ "$pp_colour_brightness" ] = math.Rand(-0.01,0.01)
	DrainColTab[ "$pp_colour_colour" ] = math.Rand(0.9,1.1)
	
	DrawColorModify( DrainColTab )
	
	local sev = math.Clamp((DrawDrn-CurTime())*DrainSev/200, 0, 0.05)
	local MySelf = LocalPlayer()
	MySelf:SetEyeAngles((MySelf:GetAimVector()+Vector(math.Rand(-sev,sev),math.Rand(-sev,sev),math.Rand(-sev,sev))):Angle())
	
	if DrawDrn < CurTime() then
		hook.Remove("RenderScreenspaceEffects", "DrawDrain")
	end
end

function DrainEffect( amount )

	hook.Remove("RenderScreenspaceEffects", "DrawDrain")
	DrainColTab[ "$pp_colour_addr" ] 	= 60/255
	DrainColTab[ "$pp_colour_addg" ] 	= 10/255
	DrainColTab[ "$pp_colour_addb" ] 	= 10/255
	DrainColTab[ "$pp_colour_brightness" ] = 0
	DrainColTab[ "$pp_colour_colour" ] = 1
	DrawDrn = CurTime()+1
	DrainSev = amount
	hook.Add("RenderScreenspaceEffects", "DrawDrain", DrawDrain)
end

--[[ Blind effect ]]--

local BlindColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}
local DrawBl = 0
local BLength = 0

local function DrawBlind()

	local nr = -BlindColTab[ "$pp_colour_brightness" ]
	if (DrawBl - CurTime()) > (2/3*BLength) then
		nr = math.Approach( nr, 0.8, 2/3*BLength*FrameTime() )
	elseif (DrawBl - CurTime()) < (1/3*BLength) then
		nr = math.Approach( nr, 0, 1/3*BLength*FrameTime() )
	end
	
	BlindColTab[ "$pp_colour_brightness" ] = -nr
	BlindColTab[ "$pp_colour_colour" ] = 1-nr
	
	DrawColorModify( BlindColTab )
	
	if DrawBl < CurTime() then
		hook.Remove("RenderScreenspaceEffects", "DrawBlind")
	end
end

function Blind( length )
	hook.Remove("RenderScreenspaceEffects", "DrawBlind")
	BlindColTab[ "$pp_colour_brightness" ] = 0
	BlindColTab[ "$pp_colour_colour" ] = 1
	
	DrawBl = CurTime()+length
	BLength = length
	hook.Add("RenderScreenspaceEffects", "DrawBlind", DrawBlind)
end

--[[ Motion blur when running in speed mode ]]--

local motionBlur = 0
local function GetMotionBlurValues( x, y, fwd, spin )
	if not PP_MOTIONBLUR then
		return 0, 0, 0, 0
	end
	
	local MySelf = LocalPlayer()
	local blur = 0
	
	if (MySelf:Team() == TEAM_HUMAN and MySelf:GetPlayerClass() ~= 0) then
		local BlurSpeed = (HumanClass[MySelf:GetPlayerClass()].RunSpeed*SPEED_MULTIPLIER)-30
		local MySpeed = MySelf:GetVelocity():Length()
		if (MySelf:GetPower() == 1 and MySpeed > BlurSpeed) then
			blur = MySpeed / 1200
		end
	end
	
	motionBlur = math.Approach(motionBlur, blur, 2*FrameTime())
	
	return 0, 0, math.max(fwd, motionBlur), spin
end
hook.Add( "GetMotionBlurValues", "IWMotionBlur", GetMotionBlurValues )

// Replaced
/* local function BlurThink()
	local MySelf = LocalPlayer()
	if not MySelf:IsValid() then return end
	-- Show motionblur when running like.. real fast!
	if (BlurTimer < CurTime() and BlurOn and MySelf:IsOnGround()) then
		hook.Remove("RenderScreenspaceEffects", "DrawSpeedBlur")
		BlurOn = false
	elseif (MySelf:Team() == TEAM_HUMAN and MySelf:GetPlayerClass() ~= 0) then
		local BlurSpeed = (HumanClass[MySelf:GetPlayerClass()].RunSpeed*SPEED_MULTIPLIER)-30
		if (MySelf:GetPower() == 1 and MySelf:GetVelocity():Length() > BlurSpeed) then
			if not BlurOn then
				BlurOn = true
				hook.Add( "RenderScreenspaceEffects", "DrawSpeedBlur", DrawSpeedBlur )
			end
			BlurTimer = CurTime()+0.1
		end
		
	end
end
hook.Add("Think","MotionBlurThink",BlurThink) */

--[[ Draw ending color fade ]]--
local EndColTab = 
{
	[ "$pp_colour_addr" ] 		= 0,
	[ "$pp_colour_addg" ] 		= 0,
	[ "$pp_colour_addb" ] 		= 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] 	= 1,
	[ "$pp_colour_colour" ] 	= 1,
	[ "$pp_colour_mulr" ] 		= 0,
	[ "$pp_colour_mulg" ] 		= 0,
	[ "$pp_colour_mulb" ] 		= 0
}

function DrawEnding()
	BlindColTab[ "$pp_colour_colour" ] = math.Approach( BlindColTab[ "$pp_colour_colour" ], 0, (1/7)*FrameTime() )
	DrawColorModify( BlindColTab )
end

/*------------------------
	Called on player spawn
-------------------------*/
function OnPlayerSpawn( team )
	hook.Remove( "RenderScreenspaceEffects", "DrawColMod" )
	if (team == TEAM_UNDEAD) then
		hook.Add( "RenderScreenspaceEffects", "DrawColMod", DrawUndeadHUDColor )
	elseif (team == TEAM_HUMAN) then
		hook.Add( "RenderScreenspaceEffects", "DrawColMod", DrawHumanHUDColor )
	end
end
