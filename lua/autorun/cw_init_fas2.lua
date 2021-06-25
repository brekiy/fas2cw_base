AddCSLuaFile()
--inconsistent name to get it to load after vanilla cw2
if SERVER then
    include("cw_fas2/server/cw_fas2_netstring.lua")
end

include("cw_fas2/shared/cw_fas2_cvars.lua")
include("cw_fas2/shared/cw_fas2_stats.lua")
include("cw_fas2/shared/cw_fas2_attachments.lua")
include("cw_fas2/shared/cw_physical_bullets.lua")
AddCSLuaFile("autorun/client/cw_cl_init_fas2.lua")

