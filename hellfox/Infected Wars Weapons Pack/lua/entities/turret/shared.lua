ENT.Type = "anim"
ENT.PrintName = ""
ENT.Author = "ClavusElite"
ENT.Purpose	= ""

st = { FOLLOWING = 1, TRACKING = 2, LOST = 3, DEFEND = 4, SHUTDOWN = 5 }
ENT.status = st.FOLLOWING

ENT.SoundPing = Sound("npc/turret_floor/ping.wav")
ENT.SoundAlarm = Sound("npc/turret_floor/active.wav")
ENT.ExplodeSound = Sound("npc/scanner/scanner_explode_crash2.wav")
ENT.ActivateSound = Sound("weapons/tripwire/mine_activate.wav")
ENT.LostSound = Sound("npc/scanner/cbot_servoscared.wav")
ENT.HappySound = Sound("npc/roller/mine/rmine_blip1.wav")
ENT.PainSounds = { Sound("npc/scanner/scanner_pain1.wav"), Sound("npc/scanner/scanner_pain2.wav") }
ENT.ConfirmSound = Sound("npc/scanner/scanner_scan4.wav")
ENT.ShootSound = {}
for k=1,3 do
	ENT.ShootSound[k] = Sound("npc/turret_floor/shoot"..k..".wav")
end
