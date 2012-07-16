/*-------------------------------
Infected Wars
Version 1.2
Made by ClavusElite (a.k.a. Joerdgs)
www.clavusstudios.nl
options_shared.lua
Shared
--------------------------------*/

-- Subversion of the gamemode. Give your edit a suiting name!
GM.Version = "Public 1.2"


/*--------------
SERVER SETTINGS
--------------*/

-- Disable or enable the build-in admin addon. You might want to turn it off if
-- you're running your own admin mod, like ULX.
ADMIN_ADDON = true

-- Allow your admins to use noclip.
ALLOW_ADMIN_NOCLIP = true

-- Allow the admins to have gravity gun and physgun
ALLOW_ADMIN_TOOLS = true

-- Allow the players to suicide? (by typing kill in console for example)
ALLOW_SUICIDE = true

-- Disable or enable the players stats system. If you turn it off, the server will not
-- keep track of player status across map changes.
-- It will probably save server processing time and server space if you turn it off,
-- but it will also lower the replay value of your server.
PLAYER_STATS = true

-- Allow soft collisions with teammates, instead of the standard collisions
SOFT_COLLISIONS = true

if CLIENT then

-- Radio music
-- Format { file path, duration (in secs) }
Radio = {}
Radio[1] = {"music/VLVX_song22.mp3", 195}-- from "episode two content.gcf"
Radio[2] = {"music/VLVX_song23.mp3", 167}
Radio[3] = {"music/VLVX_song24.mp3", 127}
Radio[4] = {"music/VLVX_song25.mp3", 167}
Radio[5] = {"music/HL2_song14.mp3", 159}-- from "source sounds.gcf"
Radio[6] = {"music/HL2_song15.mp3", 69}
Radio[7] = {"music/HL2_song16.mp3", 170}
Radio[8] = {"music/HL2_song20_submix0.mp3", 103}
Radio[9] = {"music/HL1_song10.mp3", 105}
Radio[10] = {"music/HL1_song15.mp3", 121}
Radio[11] = {"music/HL2_song12_long.mp3", 73}

if CLIENT then
	for k, v in pairs(Radio) do
		v[2] = v[2] or SoundDuration(v[1]) -- only use sound duration if no time was specified
		// SoundDuration returns exactly 60 if file ain't found
		if (v[2] == 60) then
			v[2] = 0.1
		end
	end
end

LASTSTANDMUSIC = "infectedwars/iw_lasthuman.mp3"
UNDEADWINMUSIC = "music/Ravenholm_1.mp3"
HUMANWINMUSIC = "music/HL2_song32.mp3"

-- Text displayed at round end (be sure not to mess up the comma placement)
UNDEADWINLIST = {
	"The Undead smashed all humans",
	"The Undead rule the world",
	"The Undead legion wins"
}
HUMANWINLIST = {
	"The Special Forces are victorious",
	"The Special Forces win the round",
	"The Special Forces pwned them bitches"
}

-- List of crosshairs (image size should be 64x64 with the crosshair centered)
CrossInit = function() -- we need to initialize this later
	CROSSHAIR = {}
	CROSSHAIR[1] = "infectedwars/HUD/crosshair1"
	CROSSHAIR[2] = "infectedwars/HUD/crosshair2"
	CROSSHAIR[3] = "infectedwars/HUD/crosshair3"
	CROSSHAIR[4] = "infectedwars/HUD/crosshair4"
	CROSSHAIR[5] = "infectedwars/HUD/crosshair5"

	CROSSHAIRCOLORS = { 
		["Default"] = Color(255,255,255,255), -- NEVER remove the default one
		["Red"] = Color(255,0,0,255), 
		["Blue"] = Color(0,0,255,255), 
		["Green"] = Color(0,220,0,255), 
		["Yellow"] = Color(255,240,0,255), 
		["Aqua"] = Color(0,225,225,255), 
		["Orange"] = Color(255,100,0,255), 
		["Gray"] = Color(160,160,160,255), 
		["Black"] = Color(0,0,0,255)
	}
end

-- Text displayed at when someone joins
WELCOME_TEXT =
[[
IS THIS YOUR FIRST TIME IN THIS GAMEMODE?
Please press F1 as soon as you spawned and read the help topics for more information!

Report any problems/Lua errors in the official thread/topic on either Facepunch or 
www.left4green.com! Please be aware that you won't see the custom font the first time 
you play! You need to restart Garry's Mod before the font loads into the engine.		
]]		
		
-- Text displayed in the help menu
HELP_TEXT = {}
HELP_TEXT[1] = { Button = "Objective", Text =
[[
-- OBJECTIVE --

Long after the start of the Zombie Apocalypse mankind is still fighting its war against the undead. 
But unlike the first days, the demons that walk the earth now are faster, stronger, and smarter. 
Join the war!


Special Forces: 

Either survive the round, or deplete the enemy reinforcements!


Undead Legion:

Slay all humans!

]]
}
HELP_TEXT[2] = { Button = "Controls", Text =
[[
-- CONTROLS --

ALL HUMANS:
Hold Use (default E) key to display the Power selection menu. Click on a power to select it.

Additionally you can bind these console commands for quick selection:
activate_armor, activate_vision, activate_regen, activate_speed
]]
}
HELP_TEXT[3] = { Button = "Powers", Text = 
[[
-- POWERS --

The Special Forces carry a technologically advanced suit that lets them enhance specific abilities. 
Here's a small explanation of every ability:

Armor: 
Nullifies most of the incoming damage. Drains suit power with every hit.
	   
Speed: 
Doubles your speed and increases jump height. Drains power while moving.
	   
Vision: 
Allows you to look though walls. Drains power while used.
		
Regen: 
Regenerates suit power and health.
]]
}
HELP_TEXT[4] = { Button = "Tactics", Text =
[[
-- TACTICS --

Survival of the human team has proven to be somewhat difficult. This is caused by a few 'strategies' 
people constantly apply:

* They scatter all over the map
* They try to spawnkill (wears them down faster)
* They camp a spot (alone or as a group)

Camping doesn't work, because it'll just lure all the undead towards you. The best way to survive 
is to form a stable group with diverse classes. Next is to KEEP MOVING, that'll make sure not all 
the undead players are aware of your position, making it easier to pick them off one by one.
  
]]
}
HELP_TEXT[5] = { Button = "Game facts", Text =
[[
-- GAME FACTS --

* Only ONE undead player can play the Behemoth at the same time. If you want to be able to be 
   selected as the Behemoth, you need to check the "Apply for Behemoth" box in the Class menu.
  
* Read the class info and weapon info while you're at it.

* The Behemoth's meatrocket power is scaled to the amount of human players! 
   SPAWNKILLING = (eventually) SUICIDE.
  
]]
}
HELP_TEXT[6] = { Button = "Debug", Text =
[[
-- DEBUG --

Please email any bugs to clavus@clavusstudios.nl or post them in the Infected Wars 
development topic! I will regularly update the server, so keep playing! 

- ClavusElite
]]
}
-- You can put the changelog of your own edit here. You can use HTTP.Get information too
CHANGELOG_HTTP = "http://www.mr-green.nl/portal/serverinfo/iw_changelog.html"
HELP_TEXT[7] = { Button = "Changelog", Text =
[[
-- CHANGELOG --

Nothing to report!
]]
}
HELP_TEXT[8] = { Button = "Credits", Text =
[[
- ClavusElite (about everything that's not named below)
- Tetabonita (xray vision, realistic swep base code, and helping out a lot on the forum)
- croxmeister (radial menu)
- Sechs (tripmine code and other stuff)
- jaanus (some materials)
- L337N008 (swep model hexing)
- The Darker One (swep model bone translations)
- Garry (egon swep code, and gmdm gibbing)
- Dark Moule (egon swep fixing and custom materials)
- Sgt. Kanonenfutter (for a few killicons and for being a great admin)
- All the modellers that made the custom models
- Zircon (music used for Last Stand mode)
]]
}

-- Text displayed in the about menu
-- DON'T CHANGE THE CREDITS, ONLY ADD INFORMATION IF YOU MUST
ABOUT_TEXT = 
[[
Infected Wars ]]..GM.Version..[[ 
Created by ClavusElite
www.clavusstudios.nl
www.left4green.com
www.facepunchstudios.com

-- SPECIAL THANKS --

Ywa (Server hosting and support)
The Mr.Green Community (For support)
Facepunch Studios (for Lua help and achievement suggestions)
Garry Newman (for Garry's Mod, of course)
All the people whom helped out with coding
You (for playing my gamemode!)
]]

end -- end of "if CLIENT" from line 37

/*------------
CLASSES
-------------*/

-- Don't touch these
UndeadClass = {} 
HumanClass = {}

-- Undead classes
UndeadClass[1] =
{
	Choosable = false, -- whether you can spawn as this class (via menu)
	Name = "Behemoth", -- set class name
	Model = "models/player/zombie_soldier.mdl", -- zombine model
	HUDfile = "infectedwars/HUD/HUD_behemoth", -- HUD image location in the materials folder
	Health = 240, -- set amount of health
	WalkSpeed = 170, -- set walking speed
	RunSpeed = 240, -- set running speed
	DeathSounds = { "npc/strider/striderx_die1.wav" },
	PainSounds = { "npc/strider/striderx_pain2.wav", "npc/strider/striderx_pain5.wav", "npc/strider/striderx_pain7.wav" , "npc/strider/striderx_pain8.wav" },
	SwepLoadout = {
	{Name = "Behemoth apocalypse", UnlockCode = "NONE", Sweps = {"iw_und_crowbar","iw_und_launcher"}}
	}, -- swep loadout (every Undead gets the sacrificer swep automatically)
	Info = [[]], -- class description (Behemoth doesn't have one since you can't spawn as this class manually)
}
CLASS_Z_BEHEMOTH = 1

UndeadClass[2] =
{
	Choosable = true,
	Name = "Zombie",
	Model = "models/player/classic.mdl", -- classic zombie model
	HUDfile = "infectedwars/HUD/HUD_zombie",
	Health = 120,
	WalkSpeed = 190,
	RunSpeed = 270,
	DeathSounds = { "npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav" },
	PainSounds = { "npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav" },
	SwepLoadout = { -- ALWAYS make the unlockcode of the first loadout "NONE"
	{ Name = "Zombie standard", UnlockCode = "NONE", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_demonrifle"}},
	{ Name = "Zombie alternate", UnlockCode = "NONE", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_swarmblaster"}},
	{ Name = "Zombie overdrive", UnlockCode = "ZOHELL", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_hellraiser"}},
	{ Name = "Zombie master", UnlockCode = "ZOBOW", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_wraithbow"}}
	}, -- alternate loadout
	Info = [[
	The backbone of every undead army. Its hunger for human brains will never 
	be satisfied.
	
	Health: 120
	
	Tips:
		* The Demon Rifle is very effective at distances!
	]]
}
CLASS_Z_ZOMBIE = 2

UndeadClass[3] =
{
	Choosable = true,
	Name = "Stalker",
	Model = "models/player/charple01.mdl", -- burned body model
	HUDfile = "infectedwars/HUD/HUD_stalker",
	Health = 90,
	WalkSpeed = 230,
	RunSpeed = 320,
	DeathSounds = { "npc/headcrab_poison/ph_rattle1.wav", "npc/headcrab_poison/ph_rattle2.wav", "npc/headcrab_poison/ph_rattle3.wav"  },
	PainSounds = { "npc/headcrab_poison/ph_pain1.wav", "npc/headcrab_poison/ph_pain2.wav", "npc/headcrab_poison/ph_pain3.wav" },
	SwepLoadout = {
	{ Name = "Stalker standard", UnlockCode = "NONE", Sweps = {"iw_und_stalkerknife"}},
	{ Name = "Stalker master", UnlockCode = "STSHAPE", Sweps = {"iw_und_shapeshiftersknife"}}
	},
	Info = [[
	Demon adapted to killing its prey using stealth tactics. Uses screams to 
	disorient them before attacking.
	
	Health: 90
	Ability: invisibility
	
	Tips:
		* Use the scream of disorientation before stabbing, it'll soften up 
		  your target!
		* Its all about stealth! If players expect you they can easily track you 
		  down using Vision power!
	]]
}
CLASS_Z_STALKER = 3

UndeadClass[4] =
{
	Choosable = true,
	Name = "Bones",
	Model = "models/player/Zombiefast.mdl", -- fast zombie model
	HUDfile = "infectedwars/HUD/HUD_bones",
	Health = 60,
	WalkSpeed = 290,
	RunSpeed = 390,
	DeathSounds = { "npc/fast_zombie/fz_alert_close1.wav" },
	PainSounds = { "npc/fast_zombie/leap1.wav", "npc/fast_zombie/wake1.wav" },
	SwepLoadout = {
	{Name = "Bones standard", UnlockCode = "NONE", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_swarmblaster"}},
	{Name = "Bones overdrive", UnlockCode = "BOLOCUST", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_locustcannon"}},
	{Name = "Bones master", UnlockCode = "BOBULL", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_bullshot"}}
	},
	Info = [[
	Due to the ever lasting decay, this zombie's flesh has rotten off, making it
	very agile.
	
	Health: 60
	Ability: high jumps
	
	Tips:
		* Speed is your game! Try to dodge bullets by using your rapid movement!
	]]
}
CLASS_Z_BONES = 4

UndeadClass[5] =
{
	Choosable = true,
	Name = "Warghoul",
	Model = "models/player/corpse1.mdl", -- burned corpse model
	HUDfile = "infectedwars/HUD/HUD_warghoul",
	Health = 100,
	WalkSpeed = 190,
	RunSpeed = 270,
	DeathSounds = { "npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav" },
	PainSounds = { "npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav" },
	SwepLoadout = {
	{Name = "Warghoul standard", UnlockCode = "NONE", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_shadeball","iw_und_infectionball"}},
	{Name = "Warghoul master", UnlockCode = "WATRAP", Sweps = {"iw_und_undeadknife","iw_und_hornetgun","iw_und_trap","iw_und_infectionball"}}
	},
	Info = [[
	A damned creature that won't rest till its prey has been decapitated. 
	Can smell enemies through walls and can also drain their suit power.
	
	Health: 100
	
	Tips:
		* You don't have much power of your own, stick to your team!
		* Every player that you hit with the infection ball will attract your teammates!
	]]
}
CLASS_Z_WARGHOUL = 5

-- Humans classes
HumanClass[1] =
{
	Choosable = true,
	Name = "Assault",
	Model = "models/player/combine_soldier.mdl", -- combine soldier model
	HUDfile = "infectedwars/HUD/HUD_assault",
	Health = 100,
	SuitPower = 100, -- amount of suit power
	WalkSpeed = 170,
	RunSpeed = 260,
	ArmorDrainMultiplier = 1,
	DeathSounds = { "npc/metropolice/die1.wav", "npc/metropolice/die2.wav", "npc/metropolice/die3.wav", "npc/metropolice/die4.wav" },
	PainSounds = { "npc/metropolice/pain1.wav", "npc/metropolice/pain2.wav", "npc/metropolice/pain3.wav", "npc/metropolice/pain4.wav" },
	SwepLoadout = {
	{Name = "Assault standard", UnlockCode = "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_p228","iw_m3super90","iw_m4a1"}},
	{Name = "Assault alternate", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_deagle","iw_m3super90","iw_aug"}},
	{Name = "Assault overdrive", UnlockCode =  "ASG36", Sweps = {"iw_knife","iw_hegrenade","iw_p228","iw_m3super90","iw_g36"}},
	{Name = "Assault master", UnlockCode = "ASM16", Sweps = {"iw_knife","iw_hegrenade","iw_p228","iw_semispas","iw_m16a4"}}
	},
	Info = [[
	Trained commando who's used to working under extreme pressure. Uses an assault 
	rifle to engage its targets for distance, and a shotgun to handle things close 
	and personal.
	
	Health: 100
	SuitPower: 100
	
	Tips:
		* Switch between weapons to increase your effectivity and spread your 
		  ammo usage!		  
	]]
}
CLASS_H_ASSAULT = 1

HumanClass[2] =
{
	Choosable = true,
	Name = "Support",
	Model = "models/player/combine_soldier_prisonguard.mdl", -- combine prisonguard model
	HUDfile = "infectedwars/HUD/HUD_support",
	Health = 120,
	SuitPower = 100,
	WalkSpeed = 170,
	RunSpeed = 260,
	ArmorDrainMultiplier = 1,
	DeathSounds = { "npc/metropolice/die1.wav", "npc/metropolice/die2.wav", "npc/metropolice/die3.wav", "npc/metropolice/die4.wav" },
	PainSounds = { "npc/metropolice/pain1.wav", "npc/metropolice/pain2.wav", "npc/metropolice/pain3.wav", "npc/metropolice/pain4.wav" },
	SwepLoadout = {
	{Name = "Support standard", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_mine","iw_deagle","iw_m249"}},
	{Name = "Support alternate", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_mine","iw_deagle","iw_m1014"}},
	{Name = "Support overdrive", UnlockCode =  "SUSHRIKE", Sweps = {"iw_knife","iw_hegrenade","iw_mine","iw_deagle","iw_aresshrike"}},
	{Name = "Support master", UnlockCode =  "SUM3", Sweps = {"iw_knife","iw_hegrenade","iw_mine","iw_deagle","iw_m3tactical"}}
	},
	Info = [[
	Supports the squad by providing heavy fire. Carries around mines to lay traps for 
	the undead.
	
	Health: 120
	SuitPower: 100
	
	Tips:
		* Don't waste your ammo too quickly!
		* Place proximity mines on places where undead are sure to pass by!
	]]
}
CLASS_H_SUPPORT = 2

HumanClass[3] =
{
	Choosable = true,
	Name = "Scout",
	Model = "models/player/police.mdl", -- metrocop model
	HUDfile = "infectedwars/HUD/HUD_scout",
	Health = 100,
	SuitPower = 80,
	WalkSpeed = 190,
	RunSpeed = 280,
	ArmorDrainMultiplier = 1,
	DeathSounds = { "npc/metropolice/die1.wav", "npc/metropolice/die2.wav", "npc/metropolice/die3.wav", "npc/metropolice/die4.wav" },
	PainSounds = { "npc/metropolice/pain1.wav", "npc/metropolice/pain2.wav", "npc/metropolice/pain3.wav", "npc/metropolice/pain4.wav" },
	SwepLoadout = {
	{Name = "Scout standard", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_tripmine","iw_deagle","iw_scout","iw_p90"}},
	{Name = "Scout alternate", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_tripmine","iw_elites","iw_scout","iw_mp5"}},
	{Name = "Scout overdrive", UnlockCode =  "SCM24", Sweps = {"iw_knife","iw_hegrenade","iw_tripmine","iw_elites","iw_m24_snip","iw_p90"}},
	{Name = "Scout master", UnlockCode =  "SCAWP", Sweps = {"iw_knife","iw_hegrenade","iw_tripmine","iw_deagle","iw_awp","iw_mp5"}}
	},
	Info = [[
	Light traveling soldiers, capable of quick maneuvering and providing sniper support
	where needed. Can place tripmines to mark enemies.
	
	Health: 100
	SuitPower: 80
	
	Tips:
		* Make good use of the tripmines, you only have a couple of them!
	]]
}
CLASS_H_SCOUT = 3

HumanClass[4] =
{
	Choosable = true,
	Name = "Supplies",
	Model = "models/player/combine_super_soldier.mdl", -- combine elite model
	HUDfile = "infectedwars/HUD/HUD_supplies",
	Health = 150,
	SuitPower = 100,
	WalkSpeed = 170,
	RunSpeed = 230,
	ArmorDrainMultiplier = 1,
	DeathSounds = { "npc/metropolice/die1.wav", "npc/metropolice/die2.wav", "npc/metropolice/die3.wav", "npc/metropolice/die4.wav" },
	PainSounds = { "npc/metropolice/pain1.wav", "npc/metropolice/pain2.wav", "npc/metropolice/pain3.wav", "npc/metropolice/pain4.wav" },
	SwepLoadout = {
	{Name = "Supplies standard", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_healgun","iw_ammosupply","iw_elites","iw_mp5"}},
	{Name = "Supplies alternate", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_hegrenade","iw_healgun","iw_ammosupply","iw_p228","iw_famas"}},
	{Name = "Supplies overdrive", UnlockCode =  "SUKRISS", Sweps = {"iw_knife","iw_hegrenade","iw_healgun","iw_ammosupply","iw_p228","iw_kriss"}},
	{Name = "Supplies master", UnlockCode =  "SUUMP", Sweps = {"iw_knife","iw_hegrenade","iw_healgun","iw_ammosupply","iw_p228","iw_ump"}}
	},
	Info = [[
	No team can survive without one. Is capable of quickly healing and 
	resupplying teammates.
	
	Health: 150
	SuitPower: 100
	
	Tips:
		* Resupply and heal teammates to keep your team alive and breathing!
		* Make sure you're covered when healing!
	]]
}
CLASS_H_SUPPLIES = 4

HumanClass[5] =
{
	Choosable = true,
	SpawnTurret = true,
	Name = "Experimental",
	Model = "models/player/soldier_stripped.mdl", -- stripped soldier model
	HUDfile = "infectedwars/HUD/HUD_experimental",
	Health = 75,
	SuitPower = 150,
	WalkSpeed = 160,
	RunSpeed = 220,
	ArmorDrainMultiplier = 1.5, -- Drain additional energy when being hit in armor mode
	DeathSounds = { "vo/npc/male01/pain06.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain08.wav" },
	PainSounds = { "vo/npc/male01/pain01.wav", "vo/npc/male01/pain02.wav", "vo/npc/male01/pain03.wav", "vo/npc/male01/pain04.wav" },
	SwepLoadout = {
	{Name = "Experimental standard", UnlockCode =  "NONE", Sweps = {"iw_knife","iw_turrettool","iw_p228","iw_pulserifle"}},
	{Name = "Experimental overdrive", UnlockCode =  "EXEGON", Sweps = {"iw_knife","iw_turrettool","iw_p228","iw_egon"}},
	{Name = "Experimental master", UnlockCode =  "EXVAPOR", Sweps = {"iw_knife","iw_turrettool","iw_p228","iw_vaporizer"}}
	},
	Info = [[
	An recently developed experimental unit capable of handling the newest 
	weaponry. Most of its weapons are energy based and require suit power 
	instead of ammunition! This class is accompanied by a deadly turret.
	
	Health: 75
	SuitPower: 150
	
	Tips:
		* Keep track of your suit power! Be sure to keep some for emergencies!
		* Your turret can be instructed to defend specific spots.
	]]
}
CLASS_H_EXPERIMENTAL = 5

/*----------------------------------------
				Powers
----------------------------------------*/
HumanPowers = {} -- Don't mess with these.
HumanPowers[0] = { Name = "Armor", HUDfile = "infectedwars/armor", Cost = 1 }
HumanPowers[1] = { Name = "Speed", HUDfile = "infectedwars/speed", Cost = 2 }
HumanPowers[2] = { Name = "Vision", HUDfile = "infectedwars/vision", Cost = 2 }
HumanPowers[3] = { Name = "Regen", HUDfile = "infectedwars/regen", Cost = 5 }
-- How cost works depends per power. Armor decreases  every time you get hit by its 
-- cost*amount of damage*class specific armor drain multiplier,
-- speed and vision decrease with each step of their respective timers (XRAY_TIMER and SPEED_TIMER) (see below).
-- With Regen it's exactly the opposite: there the cost is the amount added per step of REGEN_TIMER
-- to the suit power.
POWER_ARMOR = 0
POWER_SPEED = 1
POWER_VISION = 2
POWER_REGEN = 3

-- Amount of seconds before XRay vision subtracts the Vision power cost from the suit power
XRAY_TIMER = 0.5

-- Amount of velocity added to the player's jump speed when using the Speed power
JUMP_VELOCITY = 150

-- Speed multiplier for player's run and sprints speeds when using the Speed power
SPEED_MULTIPLIER = 2

-- Amount of seconds before the Speed power cost is subtracted from the suit power
SPEED_TIMER = 0.5

-- Amount of seconds before the Regen power 'cost' is added to the suit power
REGEN_TIMER = 1

/*----------------------------------------
		Mr. Green shopdata
----------------------------------------*/
shopData = {
	["titleeditor"] = { Name = "Title Editor", Cost = 3500, Desc = "Ability to change your scoreboard title in the Options menu." },
	["ammostash1"] = { Name = "Ammo Stash lvl. 1", Cost = 2000, Desc = "[Humans - All classes] Receive 1.25x the amount of ammo from ammo drops (grenades excluded)." },
	["ammostash2"] = { Name = "Ammo Stash lvl. 2", Cost = 2000, Desc = "[Humans - All classes] Receive 1.5x the amount of ammo from ammo drops (grenades excluded).", Requires = "ammostash1" },
	["ammostash3"] = { Name = "Ammo Stash lvl. 3", Cost = 2000, Desc = "[Humans - All classes] Receive 2x the amount of ammo from ammo drops (grenades excluded).", Requires = "ammostash2" },
	["proxgrenades"] = { Name = "Proximity Grenades", Cost = 5400, Desc = "[Humans - All classes] Your grenades will detonate directly when near the undead." },
	["finalshowdown"] = { Name = "Final Showdown", Cost = 6200, Desc = "[Humans - All classes] Get 5 seconds of invincibility and extra ammo when you're last human." },
	["shockdampers"] =  { Name = "Shock Dampers", Cost = 3000, Desc = "[Humans - All classes] Halves fall damage." },
	["opticalobliteration"] =  { Name = "Optical Obliteration", Cost = 4500, Desc = "[Humans - Support] Makes your proximity mines almost invisible after placement." },
	["touchdown"] =  { Name = "Touchdown", Cost = 4000, Desc = "[Humans - All classes] When landing at great speed you will create a small airblast around you." },
	["deadeffort"] =  { Name = "Dead Effort", Cost = 4200, Desc = "[Undead - Behemoth] You explode, doing damage to your direct surroundings." },
	["ladyluck"] = { Name = "Lady Luck", Cost = 3800, Desc = "The chance of a good outcome with roll-the-dice is increased." },
	["duracell"] = { Name = "Duracell", Cost = 3500, Desc = "[Humans - All classes] The Vision power will drain 25% less energy." },
	["duracell2"] = { Name = "Duracell Extra", Cost = 3500, Desc = "[Humans - All classes] The Speed power will drain 25% less energy.", Requires = "duracell" },
	["duracell3"] = { Name = "Duracell Super", Cost = 3500, Desc = "[Humans - All classes] The Armor power will drain 25% less energy.", Requires = "duracell2" },
	["duracell4"] = { Name = "Duracell X", Cost = 3500, Desc = "[Humans - All classes] The Regen power will restore energy 25% faster!", Requires = "duracell3" },
	["smokescreen"] = { Name = "Smokescreen", Cost = 3500, Desc = "[Undead - Warghoul] You drop several shadeballs when killed." },
	["organicharvest1"] = { Name = "Organic Harvest lvl. 1", Cost = 3500, Desc = "[Humans - Experimental] Your turret restores a little health when killing an undead." },
	["organicharvest2"] = { Name = "Organic Harvest lvl. 2", Cost = 3500, Desc = "[Humans - Experimental] Your turret restores even more health when killing an undead.", Requires = "organicharvest1" },
	["detecttodestroy"] = { Name = "Detect to Destroy", Cost = 2000, Desc = "[Humans - Scout] Receive an additional tripmine at the start of the round." },
	["chaosamplifier"] = { Name = "Chaos Amplifier", Cost = 3000, Desc = "[Undead - Stalker] Increases the reach and strength of your scream." },
	["efficientexchange"] = { Name = "Efficient Exchange", Cost = 3500, Desc = "[Humans - Supplies] Decrease healgun drain by 30%." },
	["infantechantment"] = { Name = "Infant Echantment", Cost = 4000, Desc = "[Undead - All classes] Triples the health of your sacrifical baby." },
	["fragilewarden"] = { Name = "Fragile Warden", Cost = 4000, Desc = "[Undead - All classes] Nullifies the first shot you get from long distance (like sniper shots) after spawning." },
	["leech"] = { Name = "Leech", Cost = 2700, Desc = "[Undead - Zombie/Bones/Warghoul] The swarmblaster and hornet gun will leech a little more health with every hit." },
	["deathpursuit"] = { Name = "Death Pursuit", Cost = 4200, Desc = "[Undead - Bones] When in mid-air, aim directly towards a nearby human and press the Use key. You'll launch towards him!" },
	["maliceabsorption1"] = { Name = "Malice Absorption lvl. 1", Cost = 3500, Desc = "[Undead - All classes] Regenerate a little health around fresh human or undead corpses." },
	["maliceabsorption2"] = { Name = "Malice Absorption lvl. 2", Cost = 3500, Desc = "[Undead - All classes] Regenerate more health around fresh human or undead corpses.", Requires = "maliceabsorption1" },
	["abortiondenial"] = { Name = "Abortion Denial", Cost = 4500, Desc = "[Undead - All classes] If your sacrifical baby is killed before you could sacrifice it, you can place it again. Only one retry!" },
	["spreadtheplague"] = { Name = "Spread the Plague", Cost = 4800, Desc = "[Undead - Warghoul] You throw three infection balls at once, while wasting just one." },
	["machineillusion"] = { Name = "Machine Illusion", Cost = 3700, Desc = "[Undead - Stalker] Turrets will no longer target you if you're more than 10 meters away." },
	["machinedestruction"] = { Name = "Machine Destruction", Cost = 3500, Desc = "[Undead - All classes] Do 20% more damage to turrets." },
	["walljump"] = { Name = "Wall jump", Cost = 5000, Desc = "[Humans - All classes] Allows you to wall jump when in Speed mode! (controls: hit your jump key once you hit a wall)" },
	["searchengine"] = { Name = "Search Engine", Cost = 4000, Desc = "[Humans - Experimental] Your turret will engage enemies at a longer distance." },
	
	["behemothdemonsuit"] = { Name = "Suit: Demon Totem", Cost = 7500, Desc = "Outfit for Behemoth. Increases health by 100. All undead in a small range around you will regenerate health slowly." },
	["zombiecorpsemastersuit"] = { Name = "Suit: Corpse Master", Cost = 7500, Desc = "Outfit for Zombie. After killing a human, you fully restore health. Default health increased by 40 points." },
	["bonesgalesuit"] = { Name = "Suit: Gale Beast", Cost = 7500, Desc = "Outfit for Bones. Increases run speed by 30%. Gives a slight chance of completely ignoring bullet damage. Gives the ability to walljump." },
	["warghoultoxicsuit"] = { Name = "Suit: Toxic Creature", Cost = 7500, Desc = "Outfit for Warghoul. You mark anyone you damage with your weapons." },
	["stalkerghostsuit"] = { Name = "Suit: Ghost", Cost = 7500, Desc = "Outfit for Stalker. You're less visible when moving and you'll remain completely invisible when crouching." },
	["suppliesboosterpack"] = { Name = "Suit: Booster Pack", Cost = 7500, Desc = "Outfit for Supplies. Increases Healgun healing speed by 50%. Increases suit power by 25%." },
	["experimentalupgradepack"] = { Name = "Suit: Upgrade Pack", Cost = 7500, Desc = "Outfit for Experimental. Increases suit power by 1/3 of the original amount. Also increases the turret's max health." },
	["scoutsspeedpack"] = { Name = "Suit: Speed Pack", Cost = 7500, Desc = "Outfit for Scout. Increases run speed in Speed mode by 30%. Speed mode suit power drain is reduced by 50%." },
	["assaultshieldpack"] = { Name = "Suit: Shield Pack", Cost = 7500, Desc = "Outfit for Assault. Decreases armor mode suit power drain by 30%. Buffs health with 30 points." },
	["supportammopack"] = { Name = "Suit: Ammo Pack", Cost = 7500, Desc = "Outfit for Support. Doubles standard weapon ammo. Gives one additional mine and two additional grenades." }
}

suitsData = {
	["behemothdemonsuit"] = { 
		team = TEAM_UNDEAD,
		class = 1,
		suit = {
			{ model = "models//gibs/hgibs.mdl", scale = 1, bone = "ValveBiped.Bip01_Head1", pos = Vector(1.4327403306961, -1.2675623893738, -1.1292405128479), ang = Angle(8.7871751785278, -126.49304962158, -109.47680664063) },
			{ model = "models//gibs/hgibs_spine.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(13.743143081665, 1.2496782541275, -5.5966320037842), ang = Angle(66.460571289063, 167.65664672852, -135.94622802734) },
			{ model = "models//gibs/hgibs_spine.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(13.596088409424, 2.2983810901642, 6.3195624351501), ang = Angle(64.269882202148, -14.101877212524, 35.259143829346) }
		}
	},
	["zombiecorpsemastersuit"] = { 
		team = TEAM_UNDEAD,
		class = 2,
		suit = {
			{ model = "models//gibs/antlion_gib_large_3.mdl", scale = 0.7, bone = "ValveBiped.Bip01_Spine2", pos = Vector(-1.2499768733978, -2.6541941165924, -0.15171729028225), ang = Angle(-1.3941439390182, -6.196168422699, 85.076599121094) },
			{ model = "models//gibs/hgibs_rib.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(8.5820789337158, 2.0459978580475, -10.655274391174), ang = Angle(1.1656086444855, 25.352821350098, 76.163185119629) },
			{ model = "models//gibs/hgibs_rib.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(5.7287373542786, -1.564227104187, 9.0457372665405), ang = Angle(-17.561738967896, -68.426277160645, 161.46885681152) },
			{ model = "models//gibs/antlion_gib_large_2.mdl", scale = 0.5, bone = "ValveBiped.Bip01_L_Thigh", pos = Vector(7.1347646713257, -4.0487656593323, 0.84789746999741), ang = Angle(-18.03857421875, -16.981311798096, 61.191638946533) },
			{ model = "models//gibs/antlion_gib_large_2.mdl", scale = 0.55, bone = "ValveBiped.Bip01_R_Thigh", pos = Vector(8.0506010055542, -4.4165859222412, 0.25122186541557), ang = Angle(-0.27120584249496, -25.118692398071, 90.420753479004) }
		}
	},
	["bonesgalesuit"] = { 
		team = TEAM_UNDEAD,
		class = 4,
		suit = {
			{ model = "models//gibs/antlion_gib_small_1.mdl", scale = 0.85, bone = "ValveBiped.Bip01_Head1", pos = Vector(3.7095222473145, 4.4393701553345, 0.080810397863388), ang = Angle(1.4880415201187, 47.686431884766, 88.523559570313) },
			{ model = "models//gibs/antlion_gib_small_1.mdl", scale = 0.85, bone = "ValveBiped.Bip01_Head1", pos = Vector(-0.63822662830353, 5.3056688308716, 0.34944403171539), ang = Angle(-2.5412516593933, 105.49115753174, 101.55364227295) },
			{ model = "models//gibs/hgibs.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(4.3274455070496, 4.9422917366028, 0.2432965785265), ang = Angle(-4.7533483505249, 98.725730895996, 90.630355834961) },
			{ model = "models//gibs/antlion_gib_small_2.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(4.5000076293945, -2.6276860237122, 0.29245662689209), ang = Angle(2.4557552337646, 25.013784408569, 93.718078613281) }
		}
	},
	["warghoultoxicsuit"] = { 
		team = TEAM_UNDEAD,
		class = 5,
		suit = {
			{ model = "models//gibs/gunship_gibs_eye.mdl", scale = 0.5, bone = "ValveBiped.Bip01_Spine2", pos = Vector(2.0665833950043, -3.8896129131317, -0.29518872499466), ang = Angle(-32.63745880127, -173.78834533691, 2.150173664093) },
			{ model = "models//gibs/shield_scanner_gib6.mdl", scale = 0.75, bone = "ValveBiped.Bip01_R_Forearm", pos = Vector(6.5496783256531, 0.58329981565475, -1.1495870351791), ang = Angle(17.339664459229, 79.093200683594, -86.614929199219) },
			{ model = "models//gibs/strider_gib2.mdl", scale = 0.35, bone = "ValveBiped.Bip01_Head1", pos = Vector(9.2699728012085, -8.3622856140137, -0.69111865758896), ang = Angle(3.0479559898376, -15.591602325439, -83.820991516113) }
		}
	},
	["stalkerghostsuit"] = { 
		team = TEAM_UNDEAD,
		class = 3,
		suit = {
			{ model = "models//gibs/shield_scanner_gib5.mdl", scale = 0.6, bone = "ValveBiped.Bip01_Head1", pos = Vector(0.72819995880127, -1.3877241611481, 1.4546996355057), ang = Angle(12.131274223328, -100.20729827881, -100.4158782959) },
			{ model = "models//gibs/shield_scanner_gib4.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(3.4411573410034, -5.460385799408, -1.2568247318268), ang = Angle(-1.7010117769241, 152.4010925293, 93.411247253418) }
		}
	},
	["suppliesboosterpack"] = {
		team = TEAM_HUMAN,
		class = 4,
		suit = {
			{ model = "models//gibs/shield_scanner_gib1.mdl", scale = 1, bone = "ValveBiped.Bip01_Head1", pos = Vector(5.1830825805664, -4.0161843299866, 0.39721876382828), ang = Angle(29.346021652222, 176.59098815918, -99.914283752441) },
			{ model = "models//gibs/scanner_gib02.mdl", scale = 1, bone = "ValveBiped.Bip01_L_UpperArm", pos = Vector(5.3622288703918, -0.22343842685223, 2.7896068096161), ang = Angle(-49.232322692871, 171.21894836426, 48.978149414063) },
			{ model = "models//gibs/scanner_gib02.mdl", scale = 1, bone = "ValveBiped.Bip01_R_UpperArm", pos = Vector(4.2643294334412, -1.4303684234619, -2.261864900589), ang = Angle(45.503536224365, -158.00933837891, -100.02246856689) },
			{ model = "models//gibs/gunship_gibs_sensorarray.mdl", scale = 0.6, bone = "ValveBiped.Bip01_Spine2", pos = Vector(8.6497287750244, -3.5460500717163, -0.11184871196747), ang = Angle(-1.4765989780426, -103.57688903809, -91.565498352051) },
			{ model = "models//items/battery.mdl", scale = 0.3, bone = "ValveBiped.Bip01_R_Hand", pos = Vector(1.6776658296585, 0.57706487178802, -0.12026292085648), ang = Angle(0.99250650405884, 75.861869812012, 93.910125732422) }
		}
	},
	["experimentalupgradepack"] = {
		team = TEAM_HUMAN,
		class = 5,
		suit = {
			{ model = "models/items/combine_rifle_cartridge01.mdl", scale = 1, bone = "ValveBiped.Bip01_Head1", pos = Vector(1.8311771154404, -0.17054943740368, -0.90054947137833), ang = Angle(64.686553955078, -84.389167785645, -3.2020144462585) },
			{ model = "models/items/combine_rifle_ammo01.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(3.4938471317291, -0.98498487472534, -0.23404963314533), ang = Angle(2.7308826446533, 161.93771362305, 87.480819702148) },
			{ model = "models/items/battery.mdl", scale = 1, bone = "ValveBiped.Bip01_R_Thigh", pos = Vector(13.813385009766, -1.7309963703156, -3.2058463096619), ang = Angle(54.786354064941, -87.938293457031, 88.364753723145) },
			{ model = "models/items/battery.mdl", scale = 1, bone = "ValveBiped.Bip01_L_Thigh", pos = Vector(14.833634376526, -1.4039047956467, 3.2033789157867), ang = Angle(-68.770347595215, -84.935073852539, 80.946914672852) }
		}
	},
	["scoutsspeedpack"] = {
		team = TEAM_HUMAN,
		class = 3,
		suit = {
			{ model = "models//gibs/helicopter_brokenpiece_03.mdl", scale = 0.25, bone = "ValveBiped.Bip01_Spine2", pos = Vector(2.274120092392, 8.7328720092773, -0.0078107994049788), ang = Angle(2.0792920589447, -9.4065847396851, 40.874393463135) },
			{ model = "models//gibs/scanner_gib01.mdl", scale = 0.8, bone = "ValveBiped.Bip01_Head1", pos = Vector(5.8143081665039, 1.9418733119965, 0.20156456530094), ang = Angle(0.55033403635025, -107.37648010254, -89.643928527832) },
			{ model = "models//gibs/shield_scanner_gib2.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(6.8622660636902, -4.2071146965027, 0.063722357153893), ang = Angle(2.7039425373077, -161.9363861084, 80.617668151855) },
			{ model = "models//props_junk/popcan01a.mdl", scale = 1, bone = "ValveBiped.Bip01_Pelvis", pos = Vector(-7.4896521568298, 3.8911969661713, -2.1400356292725), ang = Angle(-84.054145812988, -80.231010437012, -17.382932662964) }
		}
	},
	["assaultshieldpack"] = {
		team = TEAM_HUMAN,
		class = 1,
		suit = {
			{ model = "models//props_combine/combine_light002a.mdl", scale = 0.5, bone = "ValveBiped.Bip01_Spine2", pos = Vector(-8.4397354125977, -4.2856278419495, -4.8038859367371), ang = Angle(-20.218063354492, 89.163124084473, 92.542297363281) },
			{ model = "models//props_combine/tprotato2.mdl", scale = 0.15, bone = "ValveBiped.Bip01_Spine2", pos = Vector(2.9495055675507, 11.850051879883, 0.18194548785686), ang = Angle(1.8538411855698, 73.883186340332, -92.593276977539) },
			{ model = "models//weapons/w_alyx_gun.mdl", scale = 1, bone = "ValveBiped.Bip01_R_UpperArm", pos = Vector(5.7516212463379, -1.9248474836349, -4.1494512557983), ang = Angle(-5.7085776329041, -170.07400512695, -165.52563476563) },
			{ model = "models//props_combine/combine_intwallunit.mdl", scale = 0.25, bone = "ValveBiped.Bip01_Spine2", pos = Vector(7.4525828361511, -5.0034132003784, 0.57272636890411), ang = Angle(-3.9635679721832, -86.458190917969, 176.28259277344) },
			{ model = "models//gibs/manhack_gib02.mdl", scale = 0.8, bone = "ValveBiped.Bip01_Head1", pos = Vector(2.4370293617249, -2.6262662410736, -3.7462885379791), ang = Angle(-2.652161359787, -73.73762512207, 90.886138916016) }
		}
	},
	["supportammopack"] = {
		team = TEAM_HUMAN,
		class = 2,
		suit = {
			{ model = "models/weapons/w_eq_fraggrenade.mdl", scale = 1, bone = "ValveBiped.Bip01_Pelvis", pos = Vector(-6.8909358978271, 1.7911233901978, 0.28397363424301), ang = Angle(-16.114158630371, -25.425861358643, -88.245964050293) },
			{ model = "models/weapons/w_eq_fraggrenade.mdl", scale = 1, bone = "ValveBiped.Bip01_Pelvis", pos = Vector(-6.8930072784424, 2.1905839443207, -4.2527604103088), ang = Angle(-44.773292541504, -35.220443725586, -62.458473205566) },
			{ model = "models/weapons/w_defuser.mdl", scale = 1, bone = "ValveBiped.Bip01_Pelvis", pos = Vector(7.0554299354553, -0.038317274302244, 0.7411248087883), ang = Angle(21.182584762573, -174.45013427734, 87.262550354004) },
			{ model = "models/items/boxsrounds.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(4.8357734680176, -5.6739935874939, -6.0353970527649), ang = Angle(2.2185914516449, -88.034332275391, -0.77987444400787) },
			{ model = "models/weapons/w_shot_xm1014.mdl", scale = 1, bone = "ValveBiped.Bip01_Spine2", pos = Vector(-7.9856958389282, -3.3115284442902, 9.6557598114014), ang = Angle(4.9797701835632, 3.6224992275238, 135.02363586426) },
			{ model = "models//weapons/w_slam.mdl", scale = 0.5, bone = "ValveBiped.Bip01_Head1", pos = Vector(3.9873898029327, -2.1861128807068, -4.2874884605408), ang = Angle(-1.4684052467346, -168.82461547852, 173.162109375) }
		}
	}
}
	
/*----------------------------------------
		Weapon descriptions and so on...
----------------------------------------*/

swepDesc = {
	-- Human weaponry
	["iw_knife"] = { Weapon = "Military knife", Clip = "---", Special = "", Type = "melee" },
	["iw_deagle"] = { Weapon = "Desert Eagle handgun", Clip = "7", Special = "", Type = "pistol" },
	["iw_p228"] = { Weapon = "P228 handgun", Clip = "18", Special = "", Type = "pistol" },
	["iw_elites"] = { Weapon = "Dual Elites", Clip = "16x2", Special = "", Type = "pistol" },
	["iw_mp5"] = { Weapon = "MP5 Navy submachinegun", Clip = "30", Special = "", Type = "smg" },
	["iw_ump"] = { Weapon = "UMP-45 submachinegun", Clip = "25", Special = "", Type = "smg" },
	["iw_kriss"] = { Weapon = "Kriss submachinegun", Clip = "28", Special = "", Type = "smg" },
	["iw_p90"] = { Weapon = "P90 submachinegun", Clip = "50", Special = "", Type = "smg" },
	["iw_m249"] = { Weapon = "M249 Squad Automatic weapon", Clip = "100", Special = "", Type = "machinegun" },
	["iw_m4a1"] = { Weapon = "M4A1 assault rifle", Clip = "30", Special = "", Type = "assault" },
	["iw_m16a4"] = { Weapon = "M16A4 assault rifle", Clip = "30", Special = "", Type = "assault" },
	["iw_famas"] = { Weapon = "FAMAS assault rifle", Clip = "30", Special = "", Type = "assault" },
	["iw_g36"] = { Weapon = "G36 full-auto sniper", Clip = "30", Special = "", Type = "assault" },
	["iw_aresshrike"] = { Weapon = "Ares Shrike machinegun", Clip = "100", Special = "", Type = "machinegun" },
	["iw_aug"] = { Weapon = "Steyer AUG assault rifle", Clip = "30", Special = "", Type = "assault" },
	["iw_m3super90"] = { Weapon = "M3 Super 90 shotgun", Clip = "5", Special = "", Type = "shotgun" },
	["iw_m3tactical"] = { Weapon = "M3 Tactical", Clip = "7", Special = "", Type = "shotgun" },
	["iw_semispas"] = { Weapon = "Semi-automatic Spas-12", Clip = "6", Special = "", Type = "shotgun" },
	["iw_m1014"] = { Weapon = "M1014 automatic shotgun", Clip = "8", Special = "", Type = "shotgun" },
	["iw_scout"] = { Weapon = "Scout sniper rifle", Clip = "6", Special = "", Type = "sniper" },
	["iw_m24_snip"] = { Weapon = "M24 sniper rifle", Clip = "5", Special = "", Type = "sniper" },
	["iw_awp"] = { Weapon = "AWP sniper rifle", Clip = "4", Special = "", Type = "sniper" },
	["iw_pulserifle"] = { Weapon = "Pulse rifle", Clip = "---", Special = "uses suit power", Type = "experimental" },
	["iw_egon"] = { Weapon = "Egon beamcannon", Clip = "---", Special = "uses suit power", Type = "experimental" },
	["iw_vaporizer"] = { Weapon = "Vaporizer Rifle", Clip = "---", Special = "uses suit power", Type = "experimental" },
	["iw_healgun"] = { Weapon = "Health regeneration gun", Clip = "---", Special = "uses suit power", Type = "support" },
	["iw_ammosupply"] = { Weapon = "Box of ammunition", Clip = "5", Special = "", Type = "support" },
	["iw_hegrenade"] = { Weapon = "High-explosive grenade", Clip = "3", Special = "", Type = "explosive" },
	["iw_mine"] = { Weapon = "Proximity mine", Clip = "5", Special = "", Type = "explosive" },
	["iw_tripmine"] = { Weapon = "Tripmine", Clip = "2", Special = "", Type = "support" },
	["iw_turrettool"] = { Weapon = "Turret", Clip = "---", Special = "", Type = "support" },
	
	-- Undead weaponry
	["iw_und_undeadknife"] = { Weapon = "Undead knife", Clip = "---", Special = "", Type = "melee" },
	["iw_und_stalkerknife"] = { Weapon = "Stalker knife", Clip = "---", Special = "scream of disorientation", Type = "melee" },
	["iw_und_shapeshiftersknife"] = { Weapon = "Shape Shifter's knife", Clip = "---", Special = "relocative shapeshift", Type = "melee" },
	["iw_und_demonrifle"] = { Weapon = "Demon Rifle", Clip = "16", Special = "", Type = "sniper" },
	["iw_und_wraithbow"] = { Weapon = "Wraith Bow", Clip = "1", Special = "deadlier when fired from far", Type = "sniper" },
	["iw_und_hellraiser"] = { Weapon = "Hellraiser", Clip = "20", Special = "drains suit power like a bitch", Type = "assault" },
	["iw_und_swarmblaster"] = { Weapon = "Swarm Blaster", Clip = "50", Special = "leeches health", Type = "smg" },
	["iw_und_bullshot"] = { Weapon = "Bullshot", Clip = "10", Special = "pushes away targets", Type = "shotgun" },
	["iw_und_locustcannon"] = { Weapon = "Locust Cannon", Clip = "10", Special = "", Type = "shotgun" },
	["iw_und_hornetgun"] = { Weapon = "Hornet Gun", Clip = "12", Special = "leeches health", Type = "pistol" },
	["iw_und_infectionball"] = { Weapon = "Infection Ball", Clip = "10", Special = "drains suit power and marks enemies", Type = "support" },
	["iw_und_shadeball"] = { Weapon = "Shade Ball", Clip = "10", Special = "blinds enemies", Type = "support" },
	["iw_und_sacrificer"] = { Weapon = "Baby Sacrificer", Clip = "1", Special = "place your own spawns!", Type = "support" },
	["iw_und_launcher"] = { Weapon = "", Clip = "", Special = "", Type = "explosive" },
	["iw_und_crowbar"] = { Weapon = "", Clip = "", Special = "", Type = "melee" },
	["iw_und_trap"] = { Weapon = "Energy Trap", Clip = "3", Special = "absorbs suit power from enemies", Type = "support" },
	
	-- Admin tools
	["admin_exploitblocker"] = { Weapon = "", Clip = "", Special = "", Type = "admin" }
}
/*--------------------------------------------
		Achievement descriptions
--------------------------------------------*/

achievementDesc = {
	["perfectrun"] = { Nr = 1, Name = "Perfect Run", Desc = "Kill 15 undead in one round!", Image = "infectedwars/achv_perfectrun" },
	["rambo"] = { Nr = 2, Name = "Rambo", Desc = "Kill 25 undead in one round!", Image = "infectedwars/achv_rambo" },
	["divinewarrior"] = { Nr = 3, Name = "Divine Warrior", Desc = "Kill 35 undead in one round!", Image = "infectedwars/achv_divinewarrior" },
	["slacker"] = { Nr = 4, Name = "Slacker", Desc = "Kill absolutely NOTHING in one round and survive as human! (requires at least 8 players ingame)", Image = "infectedwars/achv_slacker" },
	["deusexmachina"] = { Nr = 5, Name = "Deus Ex Machina", Desc = "Survive the round without getting damaged once! Armor absorbed damage won't count! (requires at least 8 players ingame)", Image = "infectedwars/achv_deusexmachina" },
	["crazybastard"] = { Nr = 6, Name = "Crazy Bastard", Desc = "Completely kill a Behemoth with only a knife", Image = "infectedwars/achv_crazybastard" },
	["wrathofthedead"] = { Nr = 7, Name = "Wrath of the Dead", Desc = "Kill 5 humans in one round!", Image = "infectedwars/achv_wrathofthedead" },
	["baneofhumanity"] = { Nr = 8, Name = "Bane of Humanity", Desc = "Kill 10 humans in one round!", Image = "infectedwars/achv_baneofhumanity" },
	["blackops"] = { Nr = 9, Name = "Black Ops", Desc = "Kill 500 undead in total! (on this server)", Image = "infectedwars/achv_blackops" },
	["superhuman"] = { Nr = 10, Name = "Super Human", Desc = "Kill a total of 1500 undead! (on this server)", Image = "infectedwars/achv_superhuman" },
	["warofluck"] = { Nr = 11, Name = "War of Luck", Desc = "Kill a total of 7777 undead! (on this server)", Image = "infectedwars/achv_warofluck" },
	["blackwidow"] = { Nr = 12, Name = "Black Widow", Desc = "Kill a total of 100 humans! (on this server)", Image = "infectedwars/achv_blackwidow" },
	["lichking"] = { Nr = 13, Name = "Lich King", Desc = "Kill 250 humans in total! (on this server)", Image = "infectedwars/achv_lichking" },
	["antichrist"] = { Nr = 14, Name = "Antichrist", Desc = "Kill 750 humans in total! (on this server)", Image = "infectedwars/achv_antichrist" },
	["luckyluke"] = { Nr = 15, Name = "Lucky Luke", Desc = "Kill 5 enemies within 5 seconds!", Image = "infectedwars/achv_luckyluke" },
	["bulletstorm"] = { Nr = 16, Name = "Bullet Storm", Desc = "Kill 10 enemies within 15 seconds!", Image = "infectedwars/achv_bulletstorm" },
	["myfriendpain"] = { Nr = 17, Name = "My Friend PAIN", Desc = "Deal 10.000 damage to the humans in total! (on this server)", Image = "infectedwars/achv_myfriendpain" },
	["myfriendagony"] = { Nr = 18, Name = "My Friend AGONY", Desc = "Deal 50.000 damage to the humans in total! (on this server)", Image = "infectedwars/achv_myfriendagony" },
	["angelofremorse"] = { Nr = 19, Name = "Angel of Remorse", Desc = "Deal 100.000 damage to the undead in total! (on this server)", Image = "infectedwars/achv_angelofremorse" },
	["angelofdisaster"] = { Nr = 20, Name = "Angel of Disaster", Desc = "Deal a staggering 1.000.000 damage to the undead in total! (on this server)", Image = "infectedwars/achv_angelofdisaster" },
	["onemanarmy"] = { Nr = 21, Name = "One Man Army", Desc = "Survive 3 minutes as last human (requires at least 8 players ingame)", Image = "infectedwars/achv_onemanarmy" },
	["bloodbuddy"] = { Nr = 22, Name = "Blood Buddy", Desc = "Heal 200 health in one round as Supplies", Image = "infectedwars/achv_bloodbuddy" },
	["motherteresa"] = { Nr = 23, Name = "Mother Teresa", Desc = "Heal a total of 10.000 health as Supplies! (on this server)", Image = "infectedwars/achv_motherteresa" },
	["gunshop"] = { Nr = 24, Name = "Gun Shop", Desc = "Provide a total of 100 ammo packages as Supplies! (on this server)", Image = "infectedwars/achv_gunshop" },
	["rachet&clank"] = { Nr = 25, Name = "Rachet and Clank", Desc = "Get 7 turret kills in one round", Image = "infectedwars/achv_rachet&clank" },
	["spraymoregetmore"] = { Nr = 26, Name = "Spray More Get More", Desc = "Get a total of 100 turret kills! (on this server)", Image = "infectedwars/achv_spraymoregetmore" },
	["thebooman"] = { Nr = 27, Name = "The Booman", Desc = "Scare 10 different players with Stalker screams in one round", Image = "infectedwars/achv_thebooman" },
	["japanesehorror"] = { Nr = 28, Name = "Japanese Horror", Desc = "Scare players a total of 300 times! (on this server)", Image = "infectedwars/achv_japanesehorror" },
	["worldwar666"] = { Nr = 29, Name = "World War 666", Desc = "Get a round damage score (the sum of the damage score of all players) of over 12.000!", Image = "infectedwars/achv_worldwar666" },
	["worldwarzero"] = { Nr = 30, Name = "World War Zero", Desc = "Get a round damage score (the sum of the damage score of all players) of over 18.000!", Image = "infectedwars/achv_worldwarzero" },
	["icanseeyou"] = { Nr = 31, Name = "I Can See You", Desc = "Mark 5 players in one round with the Warghoul's infection ball!", Image = "infectedwars/achv_icanseeyou" },
	["youcantseeme"] = { Nr = 32, Name = "You Can't See Me", Desc = "Blind 10 different players in one round with the Warghoul's shade ball!", Image = "infectedwars/achv_youcantseeme" },
	["wraithofevil"] = { Nr = 33, Name = "Wraith of Evil", Desc = "Kill a human with a backstab as Stalker", Image = "infectedwars/achv_wraithofevil" },
	["boomhemoth"] = { Nr = 34, Name = "BOOMhemoth", Desc = "Kill three humans with a single meatrocket!", Image = "infectedwars/achv_boomhemoth" },
	["daredevil"] = { Nr = 35, Name = "Daredevil", Desc = "Make a kill as Bones while running at full speed!", Image = "infectedwars/achv_daredevil" },
	["rageagainstmachine"] = { Nr = 36, Name = "Rage Against The Machine", Desc = "Destroy four turrets in one round!", Image = "infectedwars/achv_rageagainstmachine" },
	["cribdeath"] = { Nr = 37, Name = "Crib Death", Desc = "Kill 10 babies in one round", Image = "infectedwars/achv_cribdeath" },
	["politicalincorrectness"] = { Nr = 38, Name = "Political Incorrectness", Desc = "Kill 150 sacrifical babies in total on this server!", Image = "infectedwars/achv_political" },
	["infantfobia"] = { Nr = 39, Name = "Infantfobia", Desc = "Kill 500 sacrifical babies in total on this server!", Image = "infectedwars/achv_infantfobia" },
	["revengeinblood"] = { Nr = 40, Name = "Revenge in Blood", Desc = "When Undead, kill the human that killed you last", Image = "infectedwars/achv_revengeinblood" },
	["closecall"] = { Nr = 41, Name = "Close Call", Desc = "Kill an undead within 10 meters from you with sub-10 health", Image = "infectedwars/achv_closecall" },
	["airassault"] = { Nr = 42, Name = "Air Assault", Desc = "Kill a human while in mid-air", Image = "infectedwars/achv_airassault" },
	["poormanssniper"] = { Nr = 43, Name = "Poor Man's Sniper", Desc = "Kill an undead with a pistol from over 50 meters", Image = "infectedwars/achv_poormanssniper" },
	["crazymanssniper"] = { Nr = 44, Name = "Crazy Man's Sniper", Desc = "Kill an undead with a shotgun from over 50 meters", Image = "infectedwars/achv_crazymanssniper" },
	["truemanssniper"] = { Nr = 45, Name = "True Man's Sniper", Desc = "Kill an undead with a sniper headshot from over 120 meters", Image = "infectedwars/achv_truemanssniper" },
	["meatshower"] = { Nr = 46, Name = "Meatshower", Desc = "Kill an undead with a shotgun from within 2 meters", Image = "infectedwars/achv_meatshower" },
	["mankindwillhold"] = { Nr = 47, Name = "Mankind Will Hold", Desc = "Win the round as human by depleting the enemy reinforcements!", Image = "infectedwars/achv_mankindwillhold" },
	["steamroller"] = { Nr = 48, Name = "Steamroller", Desc = "Undead must win the round before half-time! (requires at least 10 players ingame)", Image = "infectedwars/achv_steamroller" },
	["hellflood"] = { Nr = 49, Name = "Hell Flood", Desc = "Undead must win the round before 1/4 of the round time! (requires at least 10 players ingame)", Image = "infectedwars/achv_hellflood" },
	["zombieninja"] = { Nr = 50, Name = "Zombie Ninja", Desc = "Kill a player after hitting him with an infection ball as Warghoul, in the same life", Image = "infectedwars/achv_zombieninja" },
	["masterofiw"] = { Nr = 51, Name = "Master of IW", Desc = "Get every other achievement", Image = "infectedwars/achv_masterofiw" }
}	


-- Fucking unsorted non-numerical tables...
achievementSorted = {}
for k, v in pairs(achievementDesc) do
	achievementSorted[v.Nr] = k
end


-- Unlock codes, couple the weapon unlock code to the required achievements
unlockData = {
	["NONE"] = {}, -- for loadouts that are always available
	["ASG36"] = { "superhuman" },
	["ASM16"] = { "worldwarzero", "rambo", "cribdeath" },
	["SCM24"] = { "deusexmachina", "rambo" },
	["SCAWP"] = { "truemanssniper", "mankindwillhold", "angelofdisaster"},
	["SUKRISS"] = { "divinewarrior" },
	["SUUMP"] = { "worldwarzero", "gunshop", "motherteresa" },
	["ZOHELL"] = { "blackwidow", "wrathofthedead" },
	["ZOBOW"] = { "myfriendagony", "revengeinblood" },
	["BOLOCUST"] = { "steamroller", "lichking" },
	["BOBULL"] = { "hellflood", "antichrist", "daredevil" },
	["STSHAPE"] = { "japanesehorror", "thebooman", "hellflood" },
	["EXEGON"] = { "spraymoregetmore", "worldwar666" },
	["EXVAPOR"] = { "worldwarzero", "rachet&clank", "infantfobia" },
	["SUSHRIKE"] = { "onemanarmy", "meatshower" },
	["SUM3"] = { "luckyluke", "divinewarrior", "politicalincorrectness" },
	["WATRAP"] = { "youcantseeme", "icanseeyou", "zombieninja" }
}

/*-----------------------------------
		Some other player data
------------------------------------*/

recordData = {
	["undeadkilled"] = { Name = "Undead killed", Desc = "Amount of undead this person killed", Image = "infectedwars/achv_blank" },	
	["humanskilled"] = { Name = "Humans killed", Desc = "Amount of humans this person killed", Image = "infectedwars/achv_blank" },
	["undeaddamaged"] = { Name = "Undead damaged", Desc = "Amount of damage this person inflicted to the undead legion", Image = "infectedwars/achv_blank" },	
	["humansdamaged"] = { Name = "Humans damaged", Desc = "Amount of damage this person inflicted to the human race", Image = "infectedwars/achv_blank" },	
	["humanshealed"] = { Name = "Humans healed", Desc = "Amount of health this user healed as Supplies", Image = "infectedwars/achv_blank" },	
	["screensfucked"] = { Name = "Screens fucked", Desc = "Amount of effective Stalker screams this person emitted", Image = "infectedwars/achv_blank" },	
	["ammosupplied"] = { Name = "Ammo supplied", Desc = "Amount of ammo this person supplied as Supplies", Image = "infectedwars/achv_blank" },
	["turretkills"] = { Name = "Turret kills", Desc = "Amount kills this person made using the Experimental class' turret", Image = "infectedwars/achv_blank" },
	["babieskilled"] = { Name = "Babies killed", Desc = "Amount of sacrifical babies destroyed", Image = "infectedwars/achv_blank" },
	["progress"] = { Name = "Overall Progress", Desc = "How much percent of the total amount of achievements this person has", Image = "infectedwars/achv_blank" },
	["timeplayed"] = { Name = "Time played", Desc = "Time this player spend on this server (measured from last round)", Image = "infectedwars/achv_blank" }	
}


if CLIENT then -- only for client

	-- Build up unlockable tables
	unlockTable = {}
	local checktab = {}
	table.Add(checktab,HumanClass)
	table.Add(checktab,UndeadClass)
	local smallTab = {}
	local addString = ""
	
	for k, v in pairs(checktab) do
		for i, j in pairs(v.SwepLoadout) do
			smallTab = {}
			addString = "Contains: "
			if j.UnlockCode ~= "NONE" then
				smallTab.UnlockCode = j.UnlockCode
				smallTab.Name = j.Name
				
				for g, h in ipairs(j.Sweps) do
					if g > 1 then
						addString = addString..", "
					end
					addString = addString..swepDesc[h].Weapon
				end
				smallTab.LoadoutInfo = addString
				
				addString = "Requires achievements: "
				for g, h in pairs(unlockData[j.UnlockCode]) do
					if g > 1 then
						addString = addString..", "
					end
					addString = addString..achievementDesc[h].Name
				end
				
				smallTab.UnlockInfo = addString
				table.insert(unlockTable,smallTab)
			end
		end
	
	end

	-- Build up weapon achievement info out of the data tables
	checktab = {}
	table.Add(checktab,HumanClass)
	table.Add(checktab,UndeadClass)
	addString = ""
	smallTab = {}
	
	for k, v in pairs(achievementDesc) do
		v.HasUnlockInfo = false
		v.UnlockInfo = "Unlocks nothing (yet). Do it for the bragging rights."
		for i, j in pairs(unlockData) do
			if table.HasValue(j,k) then -- I'm running out of letters :/
				for poop, shit in pairs(checktab) do
					for foo, bar in pairs(shit.SwepLoadout) do
						if bar.UnlockCode == i then 
							addString = ""
							smallTab = {}
							if #j > 1 then
								for e, r in pairs(j) do
									if r ~= k then
										table.insert(smallTab,r)
									end
								end
							end -- You're not honestly trying to understand what's going on here do you?
							if #smallTab > 0 then
								addString = " (Also requires "
								for c=1, #smallTab do
									addString = addString..achievementDesc[smallTab[c]].Name
									if #smallTab > c then
										addString = addString.." and "
									else
										addString = addString..")"
									end
								end
							end
							if not v.HasUnlockInfo then
								v.UnlockInfo = "Unlocks loadout(s): "..bar.Name..addString
								v.HasUnlockInfo = true
							else
								v.UnlockInfo = v.UnlockInfo..", "..bar.Name..addString
							end
						end
					end
				end
			end
		end -- It worked. So I'm not complaining :P
	end
end

