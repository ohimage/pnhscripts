if(SERVER)then return end
local PA = PAntiCheet

// This loads the black list tables to local variables
local bl = PA.blacklist
// BlackList tables
local b_hooks = bl.hooks
local b_concmd = bl.concmd
local b_global = bl.global

// Flagged items.
local flags = {}
flags.hooks = {}
flags.concmds = {}
flags.globals = {}

local fh = flags.hooks
local fcon = flags.concmds
local fg = flags.globals

local function flagHook( hooktype, name )
	table.insert( fh, { hooktype, name } )
end

local function scanHook( hooktype, name )
	for k,v in pairs( b_hooks )do
		if(string.match( name, v ))then
			print("Possible hack detected")
			flagHook( hooktype, name )
		end
	end
end)

// This copys all hooks into a new table that we can scan without copying HUGE levels of data.
// this just copys their names over and looks into tables at their first level.
for k,v in pairs( _G )do
	if( type( v ) == "table")then
		for i,j in pairs( v )do
			table.insert( globalCopy, i )
		end
	end
	table.insert( globalCopy, k )
end