// Invite loads of ppl to my group!!!

include("steamworks.lua")

local names = {}

local function addEmUP()
	local count = steamFriends005:GetClanCount()
	print("In "..count.." groups.")
	local LPS = nil
	for i = 1, count do
		local cur = steamFriends005:GetClanByIndex(i)
		if( steamFriends005:GetClanName(cur) == "LPS Servers")then
			print("Found LPS Servers.")
			LPS = cur
			break
		end
	end

	local friendFlag = 16 -- Cur Val is on game server -- All = 65535
	local num = steamFriends005:GetFriendCount(friendFlag)-1
	for i=0, num do
		local targetFriend = steamFriends005:GetFriendByIndex(i, friendFlag)
		local name = steamFriends005:GetFriendPersonaName(targetFriend)
		if( not table.HasValue( names, name ) )then
			steamFriends002:InviteFriendToClan(targetFriend, LPS )
			steamFriends002:AddFriend(targetFriend)
			print("Invited "..name)
			table.insert( names, name )
		end
	end
	print("Total of "..num )
end

concommand.Add("ADD_ALL",function() addEmUP() end )