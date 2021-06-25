CreateConVar("cw_fas2_effrange_mult", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Multiplier for effective range. May need to refresh your weapon after changing this", 0.1, 2)
CreateConVar("cw_fas2_physical_bullets", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables physical bullets")
CreateConVar("cw_fas2_physical_bullet_muzzle_velocity_mult", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Multiplier for physical bullet muzzle velocity simulation", 0.1, 2)

-- concommand.Add("cw_fas2_applychanges")