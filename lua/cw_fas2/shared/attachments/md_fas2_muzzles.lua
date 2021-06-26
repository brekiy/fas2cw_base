local att = {}
att.name = "md_fas2_compensator"
att.displayName = "Compensator"
att.displayNameShort = "Comp."

att.statModifiers = {
    RecoilMult = -0.45,
    RecoilSideMult = -0.65,
    MaxSpreadIncMult = 0.25,
    SpreadPerShotMult = 0.2,
}

if CLIENT then
    att.displayIcon = surface.GetTextureID("atts/saker")
    -- att.description = {
    --     [1] = {t = "Decreases firing noise.", c = CustomizableWeaponry.textColors.POSITIVE}
    -- }
end

CustomizableWeaponry:registerAttachment(att)

att = {}
att.name = "md_fas2_muzzlebrake"
att.displayName = "Muzzle Brake"
att.displayNameShort = "Muz. Brake"

att.statModifiers = {
    RecoilMult = -0.3,
    RecoilSideMult = -0.55,
    MaxSpreadIncMult = 0.15,
    SpreadPerShotMult = 0.1,
}

if CLIENT then
    att.displayIcon = surface.GetTextureID("atts/saker")
    -- att.description = {[1] = {t = "Decreases firing noise.", c = CustomizableWeaponry.textColors.POSITIVE}}
end


CustomizableWeaponry:registerAttachment(att)

att = {}
att.name = "md_fas2_suppressor"
att.displayName = "Suppressor"
att.displayNameShort = "Supp."
att.isSuppressor = true
att.NearWallDistance = 3

att.statModifiers = {
    RecoilMult = -0.15,
    RecoilSideMult = -0.05,
    SpreadPerShotMult = -0.15,
}

if CLIENT then
    att.displayIcon = surface.GetTextureID("atts/saker")
    att.description = {[1] = {t = "Decreases firing noise.", c = CustomizableWeaponry.textColors.POSITIVE}}
end

function att:attachFunc()
    self.dt.Suppressed = true
end

function att:detachFunc()
    self:resetSuppressorStatus()
end

CustomizableWeaponry:registerAttachment(att)
