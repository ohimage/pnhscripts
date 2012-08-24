//steamworks.lua
 
require("steamworks2")
 
steamClient007 = steamworks.ISteamClient(7)
 
if (!steamClient007) then return end
 
hSteamPipe = steamClient007:CreateSteamPipe()
 
if (!hSteamPipe) then return end
 
hSteamUser = steamClient007:ConnectToGlobalUser(hSteamPipe)
 
if (!hSteamUser) then return end
 
steamUser012 = steamClient007:GetISteamUser(hSteamUser, hSteamPipe, 12)
 
if (!steamUser012) then return end
 
if (!steamUser012:LoggedOn()) then return end
 
steamFriends005 = steamClient007:GetISteamFriends(hSteamUser, hSteamPipe, 5)
 
if (!steamFriends005) then return end
 
steamFriends002 = steamClient007:GetISteamFriends(hSteamUser, hSteamPipe, 2)
 
if (!steamFriends002) then return end
 
hook.Add("Think", "Steam_BGetCallback", function()
    callbackMsg = steamworks.Steam_BGetCallback(hSteamPipe)
     
    if (!callbackMsg) then return end
     
    if (callbackMsg:GetCallback() == (300 + 31)) then
        local gameOverlay = callbackMsg:GetPubParam():To(FindMetaTable("GameOverlayActivated_t").MetaID)
             
        hook.Call("GameOverlayActivated", nil, gameOverlay:IsActive())
    elseif (callbackMsg:GetCallback() == (300 + 4)) then
        local personaChange = callbackMsg:GetPubParam():To(FindMetaTable("PersonaStateChange_t").MetaID)
         
        local personaSID = personaChange:GetSteamID()
         
        if (personaSID) then
            local personaCSID = steamworks.CSteamID()
             
            personaCSID:Set(personaSID, 1, 1)
     
            if (personaChange:GetFlags() == 0x001) then
                hook.Call("EPersonaChangeName", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x002) then
                hook.Call("EPersonaChangeStatus", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x004) then
                hook.Call("EPersonaChangeComeOnline", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x008) then
                hook.Call("EPersonaChangeGoneOffline", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x010) then
                hook.Call("EPersonaChangeGamePlayed", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x020) then
                hook.Call("EPersonaChangeGameServer", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x040) then
                hook.Call("EPersonaChangeAvatar", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x080) then
                hook.Call("EPersonaChangeJoinedSource", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x100) then
                hook.Call("EPersonaChangeLeftSource", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x200) then
                hook.Call("EPersonaChangeRelationshipChanged", nil, personaCSID)
            elseif (personaChange:GetFlags() == 0x400) then
                hook.Call("EPersonaChangeNameFirstSet", nil, personaCSID)
            end
        end
    end
     
    steamworks.Steam_FreeLastCallback(hSteamPipe)
end )