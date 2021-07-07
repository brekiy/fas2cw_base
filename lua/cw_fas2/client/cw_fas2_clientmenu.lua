-- Setup stuff for the config menu
local function CW2_FAS2_ClientsidePanel(panel)
    panel:ClearControls()

    panel:AddControl("Label", {Text = "Visual effects control"})

    panel:AddControl("CheckBox", {Label = "Camera shake on recoil?", Command = "cw_fas2_recoil_shake"})

end

local function CW2_FAS2_AdminPanel(panel)
    if not LocalPlayer():IsAdmin() then
        panel:AddControl("Label", {Text = "Not an admin - don't look here."})
        return
    end

    -- panel:AddControl("Button", {Label = "Apply Changes", Command = "cw_applychanges"})
    panel:AddControl("Label", {Text = "Booleans"})

    panel:AddControl("CheckBox", {Label = "Enable physical bullets?", Command = "cw_fas2_physical_bullets"})
    panel:AddControl("CheckBox", {Label = "Draw non-tracers?", Command = "cw_fas2_physical_bullet_nontracer_trails"})

    panel:AddControl("Label", {Text = "Multipliers"})
    -- autocenter time slider
    local slider = vgui.Create("DNumSlider", panel)
    slider:SetDecimals(2)
    slider:SetMin(0.1)
    slider:SetMax(2)
    slider:SetConVar("cw_fas2_effrange_mult")
    slider:SetValue(GetConVar("cw_fas2_effrange_mult"):GetFloat())
    slider:SetText("Effective Range")
    slider:SetDark(true)
    panel:AddItem(slider)

    -- autocenter time slider
    local slider = vgui.Create("DNumSlider", panel)
    slider:SetDecimals(2)
    slider:SetMin(0.1)
    slider:SetMax(2)
    slider:SetConVar("cw_fas2_physical_bullet_muzzle_velocity_mult")
    slider:SetValue(GetConVar("cw_fas2_physical_bullet_muzzle_velocity_mult"):GetFloat())
    slider:SetText("Phys. Bullet Speed")
    slider:SetDark(true)
    panel:AddItem(slider)

end

local function CW2_FAS2_PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Utilities", "CW 2.0 SWEPs", "CW 2.0 FAS2 Client", "FAS2 Exp. Client", "", "", CW2_FAS2_ClientsidePanel)
    spawnmenu.AddToolMenuOption("Utilities", "CW 2.0 SWEPs", "CW 2.0 FAS2 Admin", "FAS2 Exp. Admin", "", "", CW2_FAS2_AdminPanel)
end

hook.Add("PopulateToolMenu", "CW2_FAS2_PopulateToolMenu", CW2_FAS2_PopulateToolMenu)