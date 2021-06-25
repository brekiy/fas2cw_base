AddCSLuaFile()
local path = "cw_fas2/shared/attachments/"

-- load attachment files
for k, v in pairs(file.Find(path .. "*", "LUA")) do
	loadFile(path .. v)
end

path = "cw_fas2/shared/ammotypes/"

-- load ammo type files (they're the same as attachments, really, but this way it's very easy to integrate it with the weapon customization menu)
for k, v in pairs(file.Find(path .. "*", "LUA")) do
	loadFile(path .. v)
end