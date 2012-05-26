local pairs = pairs
local Error = Error
local ErrorNoHalt = ErrorNoHalt
local pcall = pcall
local tostring = tostring
local concommand = concommand
local PrintTable = PrintTable
local CLIENT = CLIENT
local Msg = Msg
local type = type
local unpack = unpack

/*---------------------------------------------------------
   Name: hook
   Desc: For scripts to hook onto Gamemode events
---------------------------------------------------------*/
module("hook")


// Local variables
local Hooks = {}


// Exposed Functions

/*---------------------------------------------------------
   Name: Hooks( )
   Desc: Returns the hook table
---------------------------------------------------------*/
function GetTable()

    return Hooks
    
end

/*---------------------------------------------------------
   Name: Add( event_name, name, function )
   Desc: Adds a hook
   Usage: hook.Add( "Think", "MyHookName", MyThinkFunction )
---------------------------------------------------------*/
function Add( event_name, name, func )

    if (Hooks[ event_name ] == nil) then
        Hooks[ event_name ] = {}
    end

    Hooks[ event_name ][ name ] = func
end

/*---------------------------------------------------------
   Name: Remove( name )
   Desc: Removes a hook
   Usage: Remove( "Think", "MyHookName" )
---------------------------------------------------------*/
function Remove( event_name, name )

    Hooks[ event_name ][ name ] = nil

end

/*---------------------------------------------------------
   Name: Call( name, args )
   Desc: Called by the engine to call a gamemode hook
---------------------------------------------------------*/
function Call( name, gm, ... )

    local ret
    local HookTable = Hooks[ name ]
    

    if ( HookTable != nil ) then
    
        for k, v in pairs( HookTable ) do 
            
            if ( v == nil ) then
            
                ErrorNoHalt("Hook '"..tostring(k).."' tried to call a nil function!\n")
                HookTable[ k ] = nil // remove this hook
                break;
            
            else                
                ret = { pcall( v, ... ) }
                
                if ( !ret[1] ) then
                    ErrorNoHalt( "Hook '" .. tostring( k ) .. "' Failed: " .. tostring( ret[2] ) .. "\n" )
                    HookTable[ k ] = nil
                else
                    if ( ret[2] != nil ) then
                        return unpack( ret, 2 )
                    end
                end
            end
            
        end
    end
    
    if ( gm ) then
    
        local GamemodeFunction = gm[ name ]
        if ( GamemodeFunction == nil ) then return nil end
        
        if ( type( GamemodeFunction ) != "function" ) then
            Msg( "Calling Non Function!? ", GamemodeFunction, "\n" )
        end
        
        // This calls the actual gamemode function - after all the hooks have had chance to override
        ret = { pcall( GamemodeFunction, gm, ... ) }
        
        if ( !ret[1] ) then
        
            gm[ name .. "_ERRORCOUNT" ] = gm[ name .. "_ERRORCOUNT" ] or 0
            gm[ name .. "_ERRORCOUNT" ] = gm[ name .. "_ERRORCOUNT" ] + 1
            ErrorNoHalt( tostring(ret[2]) .. "(Hook: "..tostring(name)..")\n" )
            return nil
            
        end
        
        return unpack( ret, 2 )
        
    end
    
    
end