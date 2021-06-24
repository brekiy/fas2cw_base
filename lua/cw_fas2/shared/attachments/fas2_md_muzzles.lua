local att = {}
att.name = "md_fas2_compensator"
att.displayName = "Compensator"
att.displayNameShort = "Compensator"

att.statModifiers = {
    RecoilMult = -0.35,
    RecoilSideMult = -0.1,
    SpreadPerShotMult = -0.15
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
att.displayNameShort = "Muzzle Brake"

att.statModifiers = {
    RecoilMult = -0.2,
    RecoilSideMult = -0.25,
    SpreadPerShotMult = -0.05
}

if CLIENT then
    att.displayIcon = surface.GetTextureID("atts/saker")
    -- att.description = {[1] = {t = "Decreases firing noise.", c = CustomizableWeaponry.textColors.POSITIVE}}
end


CustomizableWeaponry:registerAttachment(att)

att = {}
att.name = "md_fas2_suppressor"
att.displayName = "Suppressor"
att.displayNameShort = "Suppressor"
att.isSuppressor = true
att.NearWallDistance = 3

att.statModifiers = {
    RecoilMult = -0.1,
    RecoilSideMult = -0.05,
    SpreadPerShotMult = -0.1,
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
