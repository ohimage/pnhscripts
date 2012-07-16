local Class = {}
local Class_MT = {}
LPRP.Class = Class
local classTable = {}
// makes a new class.
function Class:new( name )
	local newTbl = {}
	classTable[ name ] = newTbl
	newTbl.id = #classTable
	newTbl.name = name
	newTbl._weapons = {}
	newTbl._models = {}
	return setmetatable(newTbl, Class)
end
function Class:GetAll()
	return classTable
end

// Class Meta Table
function Class_MT:print()
	print( self.name )
end
function Class_MT:ID()
	local tbl = self.id 
end
function Class_MT:RegisterModel( model )
	table.insert( self._models , model )
end
function Class_MT:GetModels(  )
	return self._models or {}
end
function Class_MT:GetName()
	return self.name
end
function Class_MT:ValidModel( mdl )
	return table.HasValue( self._models, mdl )
end
function Class_MT:RegisterWeapon( class )
	table.insert( self._weapons, class )
end
function Class_MT:GetWeapons( )
	return self._weapons or {}
end
function Class_MT:SetHelpURL( url )
	self._helpUrl = url
end
function Class_MT:GetHelpURL( )
	return self._helpUrl;
end

local accessLevels = {}
accessLevels[ 's' ] = function( ply ) return ply:IsSuperAdmin() end
accessLevels[ 'a' ] = function( ply ) return ply:IsAdmin() end
function Class_MT:PlayerHasAccess( ply )
	if( self._accessRequired != nil)then
		return accessLevels[ self._accessRequired ]( ply )
	else
		return true
	end
end
function Class_MT:SetRequiredRank( rank )
	self._accessRequired = rank
end
Class.__index = Class_MT -- redirect queries to the String table

local default = LPRP.Class:new("Citizen")
default:RegisterModel( "models/Humans/Group01/Male_04.mdl" )
default:RegisterWeapon( "weapon_physgun" )
default:RegisterWeapon( "gmod_tool" )
default:RegisterWeapon( "gmod_tool" )

local default = LPRP.Class:new("Combine")
default:RegisterModel( "models/Combine_Soldier.mdl" )
default:RegisterWeapon( "weapon_physgun" )
default:RegisterWeapon( "gmod_tool" )
default:RegisterWeapon( "gmod_tool" )