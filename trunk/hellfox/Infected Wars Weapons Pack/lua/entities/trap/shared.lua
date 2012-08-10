ENT.Type = "anim"
ENT.PrintName = ""
ENT.Author = "ClavusElite"
ENT.Purpose	= ""

util.PrecacheModel("models/Gibs/HGIBS.mdl")

ENT.PlaceSound = Sound("npc/headcrab_poison/ph_talk1.wav")
ENT.SoundDeath = Sound("npc/headcrab_poison/ph_rattle1.wav")

function ENT:Team()
	return TEAM_UNDEAD
end