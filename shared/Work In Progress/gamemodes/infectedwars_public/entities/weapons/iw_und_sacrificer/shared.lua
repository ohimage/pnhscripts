if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "melee"

if( CLIENT ) then
	SWEP.PrintName = "Baby Sacrificer"
	SWEP.DrawCrosshair = false
	SWEP.Slot = 4
	SWEP.SlotPos = 1
end
------------------------------------------------------------------------------------------------------
SWEP.Author			= "" -- ClavusElite
SWEP.Instructions	= "Left click to place sacrifical baby. This will become your spawnpoint. Right click to kill your baby, in exchange for full health!" 
SWEP.NextPlant = 0
------------------------------------------------------------------------------------------------------
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= true
------------------------------------------------------------------------------------------------------
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
------------------------------------------------------------------------------------------------------
SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
------------------------------------------------------------------------------------------------------
SWEP.Primary.Delay			= 1.5 	
SWEP.Primary.Recoil			= 0		
SWEP.Primary.Damage			= 7	
SWEP.Primary.NumShots		= 1		
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= 1 -- You can't have more than 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none"	
------------------------------------------------------------------------------------------------------
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 6
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"
------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetNetworkedEntity("baby",nil)
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Precache()
	util.PrecacheSound("npc/fast_zombie/fz_alert_close1.wav")
	util.PrecacheModel("props_c17/doll01.mdl")
end

function SWEP:Deploy()
	self:SetWeaponHoldType(self.HoldType)
	return true
end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextPlant ) or not self:CanPrimaryAttack() then return end
	self.NextPlant = ( CurTime() + 0.1 )
	
	if not SERVER then return end
	
	local tur = self:GetNetworkedEntity("baby")
	if tur and tur:IsValid() and tur:Alive() then
		tur:GetTable():Eliminate()
	end
	
	self:SetNetworkedEntity("baby",nil)
	
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 84
	trace.mask = MASK_NPCWORLDSTATIC
	trace.filter = self.Owner
	local tr = util.TraceLine( trace )
	
	if ( tr.Hit ) then
		
		local isFree = CheckCollisionBox(tr.HitPos+Vector(0,0,75), self.Owner:GetAimVector(),30,30,100,self.Owner)
		-- Check if there are no other babies near
		for k, v in pairs( ents.FindInSphere( tr.HitPos+Vector(0,0,20), 48 ) ) do
			if (v:GetClass() == "sacrifical_baby") then
				isFree = false
				break
			end
		end
		
		if not isFree then
			self.Owner:PrintMessage(HUD_PRINTTALK,"Not enough free space to place sacrifical baby!")
		elseif self.Owner:WaterLevel() > 1 then
			self.Owner:PrintMessage(HUD_PRINTTALK,"You'll drown the baby smartass!")
		else
			local ent = ents.Create ("sacrifical_baby")
			if ( ent ~= nil and ent:IsValid() ) then
				ent:SetPos(tr.HitPos+Vector(0,0,20))
				ent:SetAngles(Angle(0,self.Owner:GetAimVector():Angle().y,0)) -- ?? Angle( roll, pitch, yaw) or Angle( pitch, yaw, roll) ??
				ent:SetOwner(self.Owner)
				ent:Spawn()
				ent:Activate()
				
				ent:GetTable():SetDrawPos(tr.HitPos)
				
				self.Owner.BabySpawn = ent
				
				self.Owner:EmitSound( "npc/fast_zombie/fz_alert_close1.wav" )
				
				self:TakePrimaryAmmo( 1 )
				
				self:SetNetworkedEntity("baby",ent)
			end
		end
	end
end

 function SWEP:Reload() 
	return false
 end  

function SWEP:SecondaryAttack()
	if ENDROUND then return end -- some kind of spamming exploit
	local baby = self:GetNetworkedEntity("baby")
	if baby and baby:IsValid() and SERVER and baby:GetTable():Alive() and baby:GetNetworkedBool( "active", false ) then
		baby:GetTable():Eliminate()
		self.Owner:ChatPrint("Baby sacrificed, health regained!")
		self.Owner:SetHealth(self.Owner:GetMaximumHealth())
	end
end 

if CLIENT then

	function SWEP:DrawHUD()

		local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 84
		trace.mask = MASK_NPCWORLDSTATIC
		trace.filter = self.Owner
		local tr = util.TraceLine( trace )
		
		if not tr.Hit then return end
		
		local aimv = self.Owner:GetAimVector()
		local startv = tr.HitPos+Vector(0,0,10)
		local forv = Vector(aimv.x,aimv.y,0):Normalize()*20
		local rotv = aimv -- rotating modifies the vector its applied to
		rotv:Rotate(Angle(0,270,0))
		local rightv = Vector(rotv.x,rotv.y,0):Normalize()*20
		for k, v in pairs( { {(forv-rightv),(-1*forv-rightv)},{(-1*forv+rightv),(forv+rightv)}, 
			{(forv+rightv),(forv-rightv)},{(-1*forv-rightv),(-1*forv+rightv)}} ) do
			local pos1 = (startv+v[1]):ToScreen()
			local pos2 = (startv+v[2]):ToScreen()
			surface.SetDrawColor( COLOR_RED )
			surface.DrawLine( pos1.x, pos1.y, pos2.x, pos2.y )
			draw.SimpleTextOutlined("o","InfoSmall",pos2.x,pos2.y,COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		end
		/*local hitscreen = tr.HitPos:ToScreen()
		draw.SimpleTextOutlined("0.0","InfoSmall",hitscreen.x,hitscreen.y,COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		
		local center = tr.HitPos+Vector(0,0,70)
		local width = 30
		local length = 30
		local height = 110
		local dir = self.Owner:GetAimVector()
		
		local points = {}
		local aimv = dir:Normalize()
		local startv = center-Vector(0,0,height/2)
		local forv = Vector(aimv.x,aimv.y,0):Normalize()*(length/2)
		local rotv = aimv -- rotating modifies the vector its applied to
		rotv:Rotate(Angle(0,270,0))
		local rightv = Vector(rotv.x,rotv.y,0):Normalize()*(width/2)
		local upv = Vector(0,0,height)
		
		for k, v in pairs( {(forv-rightv), (-1*forv-rightv), (forv+rightv), (-1*forv+rightv)} ) do
			table.insert(points, startv+v+upv)
			table.insert(points, startv+v)
		end

		local ignorePoints = {}
		
		for k, v in pairs(points) do
			table.insert(ignorePoints,v) -- avoid double tracing
			for i, j in pairs(points) do
				if not table.HasValue(ignorePoints,j) then
					local pos1 = v:ToScreen()
					local pos2 = j:ToScreen()
					surface.SetDrawColor( Color(255,0,0) )
					surface.DrawLine( pos1.x, pos1.y, pos2.x, pos2.y )
					draw.SimpleTextOutlined("o","InfoSmall",pos2.x,pos2.y,COLOR_GRAY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
				end
			end
		end
		*/
	end

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "BABY", "DoomSmaller", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end