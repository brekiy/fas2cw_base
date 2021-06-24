CreateConVar("cw_fas2_effrange_mult", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Multiplier for effective range. May need to refresh your weapon after changing this", 0.1, 2)
if SERVER then
    util.AddNetworkString("CW_FAS2_FAKESHELL")
end