if(CLIENT)then
	print([[
	ERROR: ANTI PK SERVER RUNNING ON CLIENT.
	I have no clue why this file ended up running clientside
	but the owner of the server is probably a dumass with no
	clue what hes doing... and should give up on his dreams
	of learning to program.]])
	return
end

local pk = PAntiPropKill

local function PK_Notify( ply, victim )
	umsg.Start("PK_Tried")
		umsg.Entity( ply )
		umsg.Entity( victim )
	umsg.End()
end

hook.Add("EntityTakeDamage","PK_EntTakeDmg",function( ent,  inflictor,  attacker,  amount,  dmginfo )
	if(ValidEntity( ent ) )then
		if(ent:GetClass() == "player" and attacker:GetClass() == "prop_physics"
			or dmginfo:GetDamageType() == DMG_CRUSH)then
			dmginfo:ScaleDamage( 0 )
			if(attacker.PK_NotifySent == nil)then
				if(ValidEntity( attacker ))then
					print("Sending notice.")
					PK_Notify( attacker.lastTouchedBy, ent)
					attacker.PK_NotifySent = true
				end
			end
		end
	end
end)

hook.Add("PhysgunDrop","SVGuard_PhysDrop",function( ply, ent )
	if(ent:GetClass() == "prop_physics")then
        ent:SetCollisionGroup( ply.lp_antipk.OldCollision )
        ent:SetColor( ply.lp_antipk.OldColor )
		ent:SetMaterial( ply.lp_antipk.OldMaterial )
		ent.heldByPlayer = false
	end
end)

hook.Add("PhysgunPickup","SVGuard_PhysPickup",function( ply, ent )
	if(ply.lp_antipk == nil)then ply.lp_antipk = {} end
	if(ent:GetClass() == "prop_physics")then
		ent.heldByPlayer = true
		ply.lp_antipk.OldColor = Color(ent:GetColor())
		ply.lp_antipk.OldMaterial = ent:GetMaterial()
        ply.lp_antipk.OldCollision = ent:GetCollisionGroup()
		ent:SetColor(0,0,255,255)
		ent:SetMaterial( "models/wireframe" )
        if( ent:GetCollisionGroup() != COLLISION_GROUP_WORLD ) then
            ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        end
		ply:ResetHull() -- this is to prevent potential glitches that could allow prop surfing though it would
		-- be very hard.
	end
end)

// Tool / Material exploits:
local Exploit_Message = "Possible exploit detected."
local scan_interval = 30 --How quickly do you want this to scan. (
-- ^( 0.5 secounds is preffered because this way the exploit will be detected as soon as it is used. Rather then after it is used. [ Material Exploits ] )
local exploit = ""
// Exploit Logging
local e_log = false --Change to true if you want to enable logging.
local e_filename = "AntiPK_ae_log.txt"
function LogExploit(pl, expl, cla)
    if e_log then
        local NAM = ""
        local SID = ""
        
        if pl == nil then
            NAM = "Unknown name"
            SID = "Unknown steamid"
        else
            NAM = pl:Nick( )
            SID = pl:SteamID()
        end
        if file.Exists( e_filename ) then
            file.Write( e_filename, file.Read( e_filename ) .. "\n" .. tostring( os.date() ) .. " || " .. NAM .. " || " .. SID .. " || " .. expl .. " || " .. cla )
        else
            file.Write( e_filename, tostring( os.date() ) .. " || " .. NAM .. " || " .. SID .. " || " .. expl .. " || " .. cla)
        end
    end
end
// Tool gun shit.
function UseTool( pl, tr, toolmode )
    if CLIENT then return true end
    
    if toolmode == "material" then
        exploit = "Material Exploit (Material tool)"
        if string.find( string.lower( pl:GetInfo( "material_override" ) ), "ar2_altfire1" ) then
            LogExploit(pl, exploit, pl:GetInfo( "material_override" ))
            pl:Ban(0,Exploit_Message)
            pl:Kick(Exploit_Message)
            return false
        end
    end
    if toolmode == "door" or toolmode == "wired_door" then
        exploit = "Door Exploit"
        if pl:GetInfo( "door_class" ) == "prop_dynamic" or pl:GetInfo( "door_class" ) == "prop_door_rotating"  then else
            LogExploit(pl, exploit, pl:GetInfo( "door_class" ))
            pl:Kick(Exploit_Message)
            return false
        end
    end
    if toolmode == "trails" then
        exploit = "Material Exploit (Trails tool)"
        if string.find( string.lower( pl:GetInfo( "trails_material" ) ), "ar2_altfire1" ) then
            LogExploit(pl, exploit, pl:GetInfo( "trails_material" ))
            //pl:Ban(0,"Exploiting. Nice Try")
            pl:Kick(Exploit_Message)
            return false
        end
    end
    
    if toolmode == "turret" then
        exploit = "dof_node or smoke Exploit (Turrets tool)"
        if string.find( string.lower( pl:GetInfo( "turret_tracer" ) ), "dof_node" ) or string.find( string.lower( pl:GetInfo( "turret_tracer" ) ), "smoke" ) then
            LogExploit(pl, exploit, pl:GetInfo( "turret_tracer" ))
            pl:Kick(Exploit_Message)
            return false
        end
    end
	
    if toolmode == "rope" then
        exploit = "Rope Graphics Exploit (Rope Tool)"
        if string.find( string.lower( pl:GetInfo( "rope_material" ) ), "effects/bonk" ) then
            LogExploit(pl, exploit, pl:GetInfo( "rope_material" ))
            pl:Kick(Exploit_Message)
            return false
        end
    end
    
    if toolmode == "thruster" then
        exploit = "Thruster Exploit (Thruster Tool)"
        if string.find( string.lower( pl:GetInfo( "thruster_soundname" ) ), "?thruster" ) then
            LogExploit(pl, exploit, pl:GetInfo( "thruster_soundname" ))
            pl:Kick(Exploit_Message)
            return false
        end
    end
    
	if toolmode == "parent" then -- Theres a few different parent tools, we've got to find out the toolmode for them. Later
		exploit = "Parent on vechicle exploit"
		if( tr.Entity:IsVehicle() ) then
			LogExploit( pl, exploit, pl:GetInfo( "parent_vehicle" ) )
			pl:ChatPrint( "You cannot use parrent tool on Vehicles!" )
            //pl:ConCommand( "say", "H3y guyz i just tr1ed to p4r3nt 4 c4r..." ) 
			return false
		end
    end
    return true
end
hook.Add( "CanTool", "UseTool", UseTool )

// Material exploits:
BlockedMaterials = 
{
    "skybox/sky_day02_02_hdrft",
    "skybox/sky_day02_02_hdrup",
    "skybox/sky_day02_02_hdrbk",
    "skybox/sky_day02_02_hdrlf",
    "skybox/sky_day02_02_hdrrt",
    "ar2_altfire1"
}

timer.Create( "scan_exploit", scan_interval, 0, --This timer checks for materials add it here
function()
    exploit = "Material Exploit (Other)"
    for _, ent in pairs( ents.GetAll() ) do
        if ( table.HasValue( BlockedMaterials, string.lower( ent:GetMaterial() ) ) or string.find(ent:GetMaterial(),"skybox"))then
            if ent:IsPlayer() then
                LogExploit(ent, exploit, ent:GetMaterial() .. " (Player)")
                //ent:Ban(0,"Exploiting. Nice Try")
                ent:Kick(Exploit_Message)
            elseif ValidEntity( ent:GetOwner() ) then
                LogExploit(ent:GetOwner(), exploit, ent:GetMaterial() .. " (Entity ".. ent:GetClass() ..")")
                //ent:GetOwner():Ban(0,"Exploiting. Nice Try")
                ent:CPPIGetOwner():Kick(Exploit_Message)
                ent:Remove()
            elseif SPropProtection then
                LogExploit(ent:CPPIGetOwner(), exploit, ent:GetMaterial() .. " (Entity ".. ent:GetClass() ..")")
                //ent:CPPIGetOwner():Ban(0,"Exploiting. Nice Try")
                ent:CPPIGetOwner():Kick(Exploit_Message)
                ent:Remove()
            else
                LogExploit(nil, exploit, ent:GetMaterial() .. " (Entity ".. ent:GetClass() ..")")
                ent:Remove()
            end
        end
    end
end)