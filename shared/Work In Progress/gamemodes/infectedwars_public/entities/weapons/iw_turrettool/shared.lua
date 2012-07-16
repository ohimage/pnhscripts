if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "pistol"

if( CLIENT ) then
	SWEP.PrintName = "Turret Tool"
	SWEP.DrawCrosshair = false
	SWEP.Slot = 3
	SWEP.SlotPos = 1
end
------------------------------------------------------------------------------------------------------
SWEP.Author			= "" -- ClavusElite
SWEP.Instructions	= "Right click to toggle through commands. Left click to execute." 
SWEP.NextPlant = 0
------------------------------------------------------------------------------------------------------
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
------------------------------------------------------------------------------------------------------
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
------------------------------------------------------------------------------------------------------
SWEP.ViewModel			= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
------------------------------------------------------------------------------------------------------
SWEP.Primary.Delay			= 1.5 	
SWEP.Primary.Recoil			= 0		
SWEP.Primary.Damage			= 0	
SWEP.Primary.NumShots		= 0		
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "none"	
------------------------------------------------------------------------------------------------------
SWEP.Secondary.Delay		= 0.2
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 6
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"
------------------------------------------------------------------------------------------------------
SWEP.Commands = { { cur = 1, name = {"Command: Defend"}, cmd = {"defend"}, desc = {{"Turret will remain stationary and","guard the spot you're pointing at"}} }, 
					{ cur = 1, name = {"Command: Follow"}, cmd = {"follow"}, desc = {{"Turret will start following you"}} },
					{ cur = 1, name = {"Command: Free Fire", "Command: Seize Fire"}, cmd = {"fire","fire2"}, 
						desc = {{"Turret will fire at the spot","you're looking at"}, {"Make the turret stop firing"}} }}
SWEP.SelectedCommand = 1

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	if SERVER then
		self.dt.toofar = false
		self.dt.cur = Vector(1,1,0)
	else
		self.stophighlight = 0
	end
end

function SWEP:SetupDataTables()
	// Prediction goodness! Thanks Garry :D
	// For future reference: http://www.garry.tv/?p=1198
	self:DTVar( "Bool", 0, "toofar" )
	self:DTVar( "Vector", 0, "cur" )
	self:DTVar( "Int", 0, "selcommand" )
	self:DTVar( "Entity", 0, "turret" )
end

function SWEP:Precache()
	util.PrecacheSound("weapons/c4/c4_plant.wav")
	util.PrecacheSound("npc/scanner/scanner_scan4.wav")
end

function SWEP:Deploy()
	self.SelectedCommand = 1
	self.dt.selcommand = self.SelectedCommand
	self.dt.cur = Vector(self.SelectedCommand,1,0)
	self.dt.turret = self.Owner.Turret

	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:Holster()
	self:ResetToggles()
	return true
end

function SWEP:ResetToggles()
	// Reset toggles
	local tur = self.Owner.Turret
	if ValidEntity(tur) and SERVER then
		tur:GetTable():CommandFire(false)
	end
	for k, v in pairs(self.Commands) do
		v.cur = 1
	end	
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local tur = self.Owner.Turret
	if ValidEntity(tur) then
		if self.Owner:GetPos():Distance(tur:GetPos()) <= 200 then
			local command = self.Commands[self.SelectedCommand]
			if SERVER then
				self:ExecuteCommand( command.cmd[command.cur] )
			else
				self.stophighlight = CurTime()+0.4
			end
			// toggles commands
			command.cur = command.cur+1
			if command.cur > #command.name then
				command.cur = 1
			end
			self.Commands[self.SelectedCommand].cur = command.cur
			if SERVER then
				self.dt.cur = Vector(self.SelectedCommand,self.Commands[self.SelectedCommand].cur,0)
			end
		end
	
	end
end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
	
	self.SelectedCommand = self.SelectedCommand+1
	if (self.SelectedCommand > #self.Commands) then
		self.SelectedCommand = 1
	end
	if SERVER then
		self.dt.selcommand = self.SelectedCommand
		self.dt.cur = Vector(self.SelectedCommand,self.Commands[self.SelectedCommand].cur,0)
	end
end 

function SWEP:ExecuteCommand( cmd )
	if cmd == "defend" then
		self.Owner.Turret:CommandDefend()
	elseif cmd == "follow" then
		self.Owner.Turret:CommandFollow()
	elseif cmd == "fire" then
		self.Owner.Turret:CommandFire(true)
	elseif cmd == "fire2" then
		self.Owner.Turret:CommandFire(false)
	end
end

function SWEP:Reload() 
	return false
end  

function SWEP:Think()
	local tur = self.Owner.Turret
	if ValidEntity(tur) then
		local prevtoofar = self.dt.toofar
		local toofar = (self.Owner:GetPos():Distance(tur:GetPos()) > 200)
		if (toofar != prevtoofar) then
			self.dt.toofar = toofar
			if toofar then
				self:ResetToggles()
			end
		end
	end
end
	
if CLIENT then

	function SWEP:DrawHUD()
		if LocalPlayer().TurretStatus == TurretStatus.destroyed then
			draw.SimpleTextOutlined("Turret destroyed!","InfoSmall",w/2+30,h/2,COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
			return 
		end
	
		if self.dt.toofar then
			draw.SimpleTextOutlined("Turret too far away to issue commands!","InfoSmall",w/2+30,h/2,COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
			return 
		end

		local function NextCmd( nr )
			if nr+1 > #self.Commands then
				return 1
			end
			return nr+1
		end
		self.SelectedCommand = self.dt.selcommand
		local curtoggle = self.Commands[self.SelectedCommand].cur
		
		// some hacky shit to sync the toggled commands
		local cursyncvector = self.dt.cur
		if cursyncvector.x == self.SelectedCommand then
			curtoggle = cursyncvector.y
		end
			
		local curcmd = self.Commands[self.SelectedCommand].name[curtoggle]
			
		draw.RoundedBox(4, w/2+30, h/2-40, 103, 20, Color(0,0,0,180))
		draw.SimpleTextOutlined("COMMANDLIST","InfoSmall",w/2+34,h/2-30,COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
		
		local col = COLOR_HUMAN
		if (self.stophighlight < CurTime()) then
			col = COLOR_GRAY
		end
		draw.SimpleTextOutlined(">> "..curcmd,"InfoMedium",w/2+30,h/2,col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, COLOR_BLACK)
		
		local previd = self.SelectedCommand
		for i = 1, (#self.Commands-1) do
			previd = NextCmd( previd )
			local tog = self.Commands[previd].cur
			local nm = self.Commands[previd].name[tog]
			draw.SimpleTextOutlined(nm,"InfoSmall",w/2+30,h/2+30+(i-1)*20,COLOR_GRAY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, COLOR_BLACK)
		end
		
		local desc = self.Commands[self.SelectedCommand].desc[curtoggle]
		draw.RoundedBox(6, w/2-222, h/2-10, 200, #desc*16+15, Color(0,0,0,110))
		for k, v in pairs(desc) do
			draw.SimpleText(v,"InfoSmall",w/2-30,h/2+(k-1)*20,COLOR_GRAY, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

	end

	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText( "9", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
		// Draw weapon info box
		self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	end
end