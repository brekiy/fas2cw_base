function SWEP:getBaseViewModelPos()
    if GetConVar("cw_alternative_vm_pos"):GetBool() and !self:GetOwner():IsSprinting() and self.AlternativePos then
        if self:GetOwner():Crouching() and self.AlternativeCrouchPos then
            return self.AlternativeCrouchPos, self.AlternativeCrouchAng
        end
        return self.AlternativePos, self.AlternativeAng
    end

    return Vector(0, 0, 0), Vector(0, 0, 0)
end

-- Override to fix a bug where it assumes that the second attachment is the ejector port
-- This is strictly for shell ejection from firing
function SWEP:CreateShell(sh)
    if self:GetOwner():ShouldDrawLocalPlayer() or self.NoShells then
        return
    end

    -- doesnt actually seem to be used in the original fxn...
    -- local ejectsh = self.Shell or sh
    local ejectAtt = self.CW_VM:LookupAttachment(self.EjectorAttachmentName)
    if ejectAtt <= 0 then
        error("Invalid ejector port attachment " .. self.EjectorAttachmentName)
        return
    end
    local att = self.CW_VM:GetAttachment(ejectAtt)

    if self.ShellDelay then
        CustomizableWeaponry.actionSequence.new(self, self.ShellDelay, nil, function()
            if self.InvertShellEjectAngle then
                dir = -att.Ang:Forward()
            else
                dir = att.Ang:Forward()
            end

            if self.ShellPosOffset then
                att.Pos = att.Pos + self.ShellPosOffset.x * att.Ang:Right()
                att.Pos = att.Pos + self.ShellPosOffset.y * att.Ang:Forward()
                att.Pos = att.Pos + self.ShellPosOffset.z * att.Ang:Up()
            end

            CustomizableWeaponry.shells.make(self, att.Pos + dir * self.ShellOffsetMul, EyeAngles(), dir * 200, 0.6, 10)
        end)
    else
        if self.InvertShellEjectAngle then
            dir = -att.Ang:Forward()
        else
            dir = att.Ang:Forward()
        end

        if self.ShellPosOffset then
            att.Pos = att.Pos + self.ShellPosOffset.x * att.Ang:Right()
            att.Pos = att.Pos + self.ShellPosOffset.y * att.Ang:Forward()
            att.Pos = att.Pos + self.ShellPosOffset.z * att.Ang:Up()
        end

        CustomizableWeaponry.shells.make(self, att.Pos + dir * self.ShellOffsetMul, EyeAngles(), dir * 200, 0.6, 10)
    end
end

--[[
    Spawns a number of shells
    shell: shell name in cw shells arr e.g. 9x19, 10x25
    everything else is self-explanatory
]]--
-- function SWEP:FAS2_MakeFakeShell(shell, num, pos, ang, vel, removetime, shellscale)
--     if !shell or !pos then
--         return
--     end

--     ang = ang or AngleRand()
--     vel = vel or Vector(0, 0, -100)
--     vel = vel + VectorRand() * 5
--     num = num or 1
--     removetime = removetime or 5
--     shellscale = shellscale or 1
--     local shellTable = CustomizableWeaponry.shells:getShell(shell)

--     for i = 1, num do
--         local shellEnt = ClientsideModel(shellTable.m, RENDERGROUP_BOTH)
--         shellEnt:SetPos(pos)
--         shellEnt:PhysicsInitBox(self.shellBoundBox[1], self.shellBoundBox[2])
--         shellEnt:SetAngles(ang)
--         shellEnt:SetModelScale(shellscale, 0)
--         shellEnt:SetMoveType(MOVETYPE_VPHYSICS)
--         shellEnt:SetSolid(SOLID_VPHYSICS)
--         shellEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

--         local phys = shellEnt:GetPhysicsObject()
--         phys:SetMaterial("gmod_silent")
--         phys:SetMass(10)
--         phys:SetVelocity(vel)
--         if shellTable.s then
--             shellEnt:EmitSound(shellTable.s, 35, 100)
--         end

--         SafeRemoveEntityDelayed(shellEnt, removetime)
--     end
-- end

--[[
    Spawns a number of shells at an attachment
    shell: shell name in cw shells arr e.g. 9x19, 10x25
    everything else is self-explanatory
]]--
function SWEP:FAS2_MakeFakeShell(shell, num, attachmentName, vel, removetime, shellscale)
    if !shell or !attachmentName then
        return
    end
    local pos, ang
    if self.FakeShellOffsetCalcs and self.FakeShellOffsetCalcs[attachmentName] then
        pos, ang, vel = self.FakeShellOffsetCalcs[attachmentName](self)
    else
        local attTable = self:GetAttachment(self:LookupAttachment(attachmentName))
        pos, ang = attTable.Pos, attTable.Ang
    end
    vel = vel or Vector(0, 0, -100)
    vel = vel + VectorRand() * 5 + self:GetOwner():GetVelocity()
    num = num or 1
    removetime = removetime or 5
    shellscale = shellscale or 1
    local shellTable = CustomizableWeaponry.shells:getShell(shell)

    for i = 1, num do
        local shellEnt = ClientsideModel(shellTable.m, RENDERGROUP_BOTH)
        shellEnt:SetPos(pos + i * 0.5 * VectorRand())
        shellEnt:PhysicsInitBox(self.shellBoundBox[1], self.shellBoundBox[2])
        shellEnt:SetAngles(ang)
        shellEnt:SetModelScale(shellscale, 0)
        shellEnt:SetMoveType(MOVETYPE_VPHYSICS)
        shellEnt:SetSolid(SOLID_VPHYSICS)
        shellEnt:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        local phys = shellEnt:GetPhysicsObject()
        phys:SetMaterial("gmod_silent")
        phys:SetMass(10)
        phys:SetVelocity(vel)
        if shellTable.s then
            shellEnt:EmitSound(shellTable.s, 35, 100)
        end

        SafeRemoveEntityDelayed(shellEnt, removetime)
    end
end

net.Receive("CW_FAS2_FAKESHELL", function(len, ply)
    local wep = LocalPlayer():GetActiveWeapon()
    if !IsValid(wep) or !wep.CW20Weapon then return end
    local shell = net.ReadString()
    local num = net.ReadUInt(8)
    local delay = net.ReadFloat()
    local attachmentName = net.ReadString()
    local vel = net.ReadVector()
    local removetime = net.ReadFloat()
    local shellscale = net.ReadFloat()
    timer.Simple(delay, function()
        wep:FAS2_MakeFakeShell(shell, num, attachmentName, vel, removetime, shellscale)
    end)
end)

-- Overriden from base to allow bipod offsetting
function SWEP:getDifferenceToAimPos(targetPos, targetAng, vertDependance, horDependance, dependMod)
    dependMod = dependMod or 1
    vertDependance = vertDependance or 1
    horDependance = horDependance or 1

    local sway = (self.AngleDelta.p * 0.65 * vertDependance + self.AngleDelta.y * 0.75 * horDependance) * 0.05 * dependMod
    if self.dt.State == CW_AIMING and self.dt.BipodDeployed then
        targetPos, targetAng = self:_CalcBipodAimOffsets(targetPos, targetAng)
    end
    local pos = self.BlendPos - targetPos
    local ang = self.BlendAng - targetAng
    ang.z = 0

    pos = pos:Length()
    ang = ang:Length() - sway

    local dependance = pos + ang

    return 1 - dependance
end

function SWEP:_CalcBipodAimOffsets(targetPos, targetAng)
    if self.BipodAimOffsetPos then
        targetPos = self.AimPos + self.BipodAimOffsetPos
        targetAng = self.AimAng + self.BipodAimOffsetAng
    end
    return targetPos, targetAng
end

-- Adds an offset to bipod ADS position for weapons that need it
CustomizableWeaponry.callbacks:addNew("adjustViewmodelPosition", "FAS2_BIPOD_AIM_OFFSET", function(self, targetPos, targetAng)
    local newTargetPos, newTargetAng = targetPos, targetAng
    if self.dt.State == CW_AIMING and self.dt.BipodDeployed then
        newTargetPos, newTargetAng = self:_CalcBipodAimOffsets(newTargetPos, newTargetAng)
    end
    return newTargetPos, newTargetAng
end)

function SWEP:createCustomVM(mdl)
    self.CW_VM = self:createManagedCModel(mdl, RENDERGROUP_BOTH)
    self.CW_VM:SetNoDraw(true)
    self.CW_VM:SetupBones()

    if self.CArmsVM then
        self.CW_C_HANDS = self:createManagedCModel(self.CArmsModel, RENDERGROUP_BOTH)

        self.CW_C_HANDS:SetNoDraw(true)
        self.CW_C_HANDS:SetupBones()
        self.CW_C_HANDS:SetParent(self.CW_VM)
        self.CW_C_HANDS:AddEffects(EF_BONEMERGE)
        self.CW_C_HANDS:AddEffects(EF_BONEMERGE_FASTCULL)
    end

    if self.ViewModelFlip then
        local mtr = Matrix()
        mtr:Scale(Vector(1, -1, 1))

        self.CW_VM:EnableMatrix("RenderMultiply", mtr)
    end
end

function SWEP:_drawViewModel()
    -- draw the viewmodel

    if self.ViewModelFlip then
        render.CullMode(MATERIAL_CULLMODE_CW)
    end

    -- local POS = EyePos() - self.CW_VM:GetPos()

    self.CW_VM:FrameAdvance(FrameTime())
    self.CW_VM:SetupBones()
    if !self.CW_VM.hideModel then
        self.CW_VM:DrawModel()
    end

    if self.ViewModelFlip then
        render.CullMode(MATERIAL_CULLMODE_CCW)
    end

    local hands = self:GetOwner():GetHands()

    if self.CArmsVM then
        if hands:GetParent() != self.CW_C_HANDS then
            hands:SetParent(self.CW_C_HANDS)
            hands:AddEffects(EF_BONEMERGE)
            hands:AddEffects(EF_BONEMERGE_FASTCULL)
        end
        hands:DrawModel()
    end

    -- draw the attachments
    self:drawAttachments()

    -- draw the customization menu
    self:drawInteractionMenu()

    -- draw the unique scope behavior if it is defined
    if self.reticleFunc then
        self.reticleFunc(self)
    end

    -- and lastly, draw the custom hud if the player has it enabled
    if GetConVar("cw_customhud_ammo"):GetBool() then
        self:draw3D2DHUD()
    end
end