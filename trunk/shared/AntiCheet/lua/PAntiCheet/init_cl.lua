if(SERVER)then return end
local PA = PAntiCheet

// This loads the black list tables to local variables
local bl = PA.blacklist
// BlackList tables
local b_hooks = bl.hooks
local b_concmd = bl.concmd
local b_global = bl.global

local function scanHook( hooktype, name )
	for k,v in pairs( b_hooks )do
		if(string.match( name, v ))then
		
		end
	end
end)