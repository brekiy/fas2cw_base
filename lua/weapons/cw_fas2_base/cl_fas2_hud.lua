function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
    if self.SelectIcon then
        -- Original weapon_base code
        -- cw 2.0 decides to call it SelectIcon instead of WepSelectIcon. ok then we'll adhere to the base's custom
        -- i disabled the bouncing by default in the base because it looks dumb, but if someone wants it for some reason it's still here

        -- Set us up the texture
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetTexture(self.SelectIcon)

        -- Lets get a sin wave to make it bounce
        local fsin = 0

        if ( self.BounceWeaponIcon == true ) then
            fsin = math.sin( CurTime() * 10 ) * 5
        end

        -- Borders
        y = y + 10
        x = x + 10
        wide = wide - 20

        -- Draw that mother
        surface.DrawTexturedRect(x + fsin, y - fsin,  wide - fsin * 2 , wide / 2 + fsin)

        -- Draw weapon info box
        self:PrintWeaponInfo(x + wide + 20, y + tall * 0.95, alpha)
    else
        draw.SimpleText(self.IconLetter, self.SelectFont, x + wide / 2, y + tall * 0.2, Color(255, 210, 0, alpha), TEXT_ALIGN_CENTER)
    end
end

CustomizableWeaponry.callbacks:addNew("initialize", "FAS2_autoIcon", function(self)
    -- will look for a select icon texture under /materials/vgui/inventory/<weapon classname>
    local weaponClass = self:GetClass()
    local defaultPath = "vgui/inventory/" .. weaponClass
    local iconMaterial = Material(defaultPath)

    if iconMaterial:IsError() then return end
    local iconTexture = iconMaterial:GetTexture("$basetexture")
    if iconTexture:IsError() then return end
    local iconTextureName = iconTexture:GetName()
    killicon.Add(weaponClass, iconTextureName, Color(255, 255, 255))
    self.SelectIcon = surface.GetTextureID(iconTextureName)
end)
