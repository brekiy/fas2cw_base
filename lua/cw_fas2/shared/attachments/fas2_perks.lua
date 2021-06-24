local att = {}
att.name = "pk_fas2_fast_reload"
att.displayName = "Fast Reload"
att.displayNameShort = "Fast Rel."
att.statModifiers = {
}

if CLIENT then
    att.displayIcon = surface.GetTextureID("vgui/fas2atts/fastreload")
    att.description = {
        {t = "Increased reload speed.", c = CustomizableWeaponry.textColors.POSITIVE},
        {t = "Very tactical. (Most of the time)", c = CustomizableWeaponry.textColors.VPOSITIVE},
    }
end

function att:attachFunc()
    self.FastReload = true
end

function att:detachFunc()
    self.FastReload = false
end

CustomizableWeaponry:registerAttachment(att)
