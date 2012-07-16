/*-------------------------------
Infected Wars
options_server.lua
Server
--------------------------------*/

/*------------------------------------
Server-only options, so you don't 
need to update your client cache constantly
------------------------------------*/

-- Round time in seconds (example: 15 x 60 makes 15 minutes)
ROUNDLENGTH = 15 * 60

-- Maximum rounds per map before next map is forced
MAX_ROUNDS_PER_MAP = 3

-- Between the end of the round and the next map
INTERMISSIONTIME = 30

-- How many seconds after round start can players still join human team when they join?
-- For obvious reasons, never make this larger than ROUNDTIME
HUMAN_JOINTIME = ROUNDLENGTH/3

-- Amount of reinforcements the undead have. Base number + increment per human player
-- If reinforcements reach 0, the humans win the round.
UNDEAD_REINFORCEMENTS = 30
UNDEAD_REINFORCEMENTS_INCREMENT_PER_PLAYER = 5

-- Amount of seconds players have spawn protection
SPAWN_PROTECTION = 5

-- Amount of seconds before a killed zombie player is allowed to respawn, 
-- always keep this more than 1
SPAWNTIME = 4

-- Amount of seconds before player can use roll the dice again
RTD_TIME = 180

-- Ammo droprate of zombies, the lower the number, the higher the chance 
-- (ex: 5 = random(1,5) chance, 1 = random(1,1) chance = always). USE ROUND NUMBERS.
AMMO_DROPRATE = 3

-- enable or disable gore on the entire server
GORE_MOD = true

-- Amount of times a behemoth player is allowed to die before being switched to another class
BEHEMOTH_DEATH_LIMIT = 10

-- Mapcycle. Goes from top to bottom. Chooses 1st map when the current map is not
-- in the list. It also checks if the minimum and maximum values match the current
-- amount of players.
-- Maps will be played in the order you add them!
-- You can NOT add maps twice or it'll mess up the system!
MAPCYCLE = {}
local function AddMap( name, minpl, maxpl )
	tab = { map = name, minplayers = minpl, maxplayers = maxpl }
	table.insert(MAPCYCLE,tab)
end


// Maplist, format ( map name, minimum required players, maximum amount of players )
AddMap( "cs_assault", 0, 99 )
AddMap( "de_port", 10, 99 )
AddMap( "de_piranesi", 0, 99 )
AddMap( "dm_steamlab", 0, 10 )
AddMap( "de_nuke", 0, 99 )
AddMap( "dm_powerhouse", 0, 99 )
AddMap( "de_prodigy", 0, 99 )
AddMap( "de_train", 0, 99 )
AddMap( "dm_runoff", 0, 99 )
AddMap( "dm_lockdown", 0, 99 )
AddMap( "cs_italy", 0, 99 )
AddMap( "de_chateau", 0, 99 )
AddMap( "de_aztec", 0, 99 )

-- Server news. Add whatever you like. Things like: "OMG YOU LIEK MUDKIPZ?"
NEWS = {}
NEWS[1] = "New to this gamemode? READ THE HELP FILE, you'll find it useful! (press F1)"
NEWS[2] = "The shop has opened! Access the menu (F1) and press the shop button!"
NEWS[3] = "Hold your Use key to select a power!"
NEWS[4] = "Press F1 for help topics and more detailed information!"
NEWS[5] = "Press F2 to change class!"
NEWS[6] = "Press F4 to view the stats and achievements of you and other players!"

NEWSTIMER = 45 -- amount of seconds between each news display, set to -1 if you don't want news being displayed
