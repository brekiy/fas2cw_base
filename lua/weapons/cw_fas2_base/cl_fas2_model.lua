-- Functions that handle viewmodel related stuff

local reg = debug.getregistry()
-- since these are often-called functions (and somewhat expensive), we make local references to them to reduce the overhead as much as possible
local ManipulateBonePosition, ManipulateBoneAngles = reg.Entity.ManipulateBonePosition, reg.Entity.ManipulateBoneAngles
local Vec0, Ang0 = Vector(), Angle()

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

-- offsetBones helper because wow there are a ton of scopes
-- ugly af lol
function SWEP:canOffsetForegrip()
    local offsetName = "ForeGripOffsetCycle_Reload"
    if self.Sequence == self.Animations.reload or self.Sequence == self.Animations.reload_empty
        or self.Sequence == self.Animations.reload_fast or self.Sequence == self.Animations.reload_fast_empty then
            if self:IsNonVanillaFastReload() then
                offsetName = offsetName .. "_Fast"
            end
            if self.wasEmpty then
                offsetName = offsetName .. "_Empty"
            end
    elseif self.Sequence == self.Animations.reload_start then
        offsetName = offsetName .. "Start"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
        if self.wasEmpty then
            offsetName = offsetName .. "_Empty"
        end
    elseif self.Sequence == self.Animations.insert then
        offsetName = offsetName .. "Insert"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
    elseif self.Sequence == self.Animations.reload_end then
        offsetName = offsetName .. "End"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
    elseif self.Sequence == self.Animations.draw then
        offsetName = "ForeGripOffsetCycle_Draw"
    else
        return true
    end
    if !self[offsetName] then
        print("tried to use invalid offsetName", offsetName)
        return false
    else
        return self.Cycle >= self[offsetName]
    end
end

function SWEP:canOffsetM203()
    local offsetName = "M203OffsetCycle_Reload"
    if self.Sequence == self.Animations.reload or self.Sequence == self.Animations.reload_empty
        or self.Sequence == self.Animations.reload_fast or self.Sequence == self.Animations.reload_fast_empty then
            if self:IsNonVanillaFastReload() then
                offsetName = offsetName .. "_Fast"
            end
            if self.wasEmpty then
                offsetName = offsetName .. "_Empty"
            end
    elseif self.Sequence == self.Animations.reload_start then
        offsetName = offsetName .. "Start"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
        if self.wasEmpty then
            offsetName = offsetName .. "_Empty"
        end
    elseif self.Sequence == self.Animations.insert then
        offsetName = offsetName .. "Insert"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
    elseif self.Sequence == self.Animations.reload_end then
        offsetName = offsetName .. "End"
        if self:IsNonVanillaFastReload() then
            offsetName = offsetName .. "_Fast"
        end
    elseif self.Sequence == self.Animations.draw then
        offsetName = "M203OffsetCycle_Draw"
    else
        return true
    end

    return self.Cycle >= self[offsetName]
end

-- Overriden to allow fast reload bone offsetting
function SWEP:offsetBones()
    local vm = self.CW_VM

    -- if the animation cycle is past reload/draw no offset time of bones, then it falls within the bone offset timeline
    local FT = FrameTime()

    if self.AttachmentModelsVM then
        local can = false
        local canModifyBones = self.AttachmentModelsVM.md_foregrip or self.AttachmentModelsVM.md_m203 or self.ForegripOverride

        local foregrip = (self.AttachmentModelsVM.md_foregrip and self.AttachmentModelsVM.md_foregrip.active)
        local m203 = (self.AttachmentModelsVM.md_m203 and self.AttachmentModelsVM.md_m203.active)
        local otherOffsets = foregrip or m203

        if foregrip or self.ForegripOverride then
            can = self:canOffsetForegrip()
        end

        if m203 and !self.dt.M203Active then
            can = self:canOffsetM203()
        end

        local targetTbl = false

        -- select the desired offset table
        if can then
            local fallback = true

            if self.ForegripOverride and self.ForegripOverridePos then
                local desiredTarget = self.ForegripOverridePos[self.ForegripParent]

                if desiredTarget then
                    if !desiredTarget.weakOverride or (desiredTarget.weakOverride and !otherOffsets) then

                        targetTbl = desiredTarget
                        canModifyBones = true
                    else
                        fallback = true
                    end
                else
                    canModifyBones = false
                end
            end

            if fallback then
                if foregrip then
                    targetTbl = self.ForeGripHoldPos
                elseif m203 then
                    targetTbl = self.M203HoldPos
                end
            end
        end

        if !targetTbl then
            can = false
        end

        if m203 then
            if self.dt.M203Active or UnPredictedCurTime() < self.M203Time then
                self:offsetM203ArmBone(true)
                ManipulateBonePosition(vm, self.BaseArmBone, self.BaseArmBoneOffset)

                return
            else
                if self.curM203Anim != self.M203Anims.ready_to_idle then
                    self:resetM203Anim()
                end

                self:offsetM203ArmBone(false)
            end
        end

        if self.canOffsetMagBone then
            self:offsetMagBone(false)
        end

        if canModifyBones then
            for k, v in pairs(self.vmBones) do
                if can then
                    local index = targetTbl[v.boneName]

                    v.curPos = LerpVectorCW20(FT * 15, v.curPos, index and index.pos or Vec0)
                    v.curAng = LerpAngleCW20(FT * 15, v.curAng, index and index.angle or Ang0)
                else
                    v.curPos = LerpVectorCW20(FT * 15, v.curPos, Vec0)
                    v.curAng = LerpAngleCW20(FT * 15, v.curAng, Ang0)
                end

                ManipulateBonePosition(vm, v.bone, v.curPos)
                ManipulateBoneAngles(vm, v.bone, v.curAng)
            end
        end
    end

    if self.BoltBoneID then
        local can = true
        local recoverySpeed = self.BoltBonePositionRecoverySpeed

        if self.BoltShootOffset then
            if self.HoldBoltWhileEmpty and self:Clip1() == 0 and self.Sequence != self.EmptyBoltHoldAnimExclusion then
                if (self.IsReloading and self.Cycle > 0.98) or !self.IsReloading then
                    can = false
                    self.CurBoltBonePos = self.BoltShootOffset * 1
                end
            end

            ManipulateBonePosition(vm, self.BoltBoneID, self.CurBoltBonePos)
        end

        if self.OffsetBoltDuringNonEmptyReload then
            if self.IsReloading and self.Cycle <= self.StopReloadBoneOffset and self:Clip1() > 0 then
                self.CurBoltBonePos = math.ApproachVector(self.CurBoltBonePos, self.BoltReloadOffset, FT * self.ReloadBoltBonePositionMoveSpeed)
                can = false
            else
                if can then
                    recoverySpeed = self.ReloadBoltBonePositionRecoverySpeed
                end
            end

            ManipulateBonePosition(vm, self.BoltBoneID, self.CurBoltBonePos)
        end

        if can then
            self.CurBoltBonePos = math.ApproachVector(self.CurBoltBonePos, Vec0, FT * recoverySpeed)
        end
    end
end

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
    if self.dt.State == CW_AIMING and self.dt.BipodDeployed and self._CalcBipodAimOffsets then
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

-- Overriden to draw c-hands
function SWEP:_drawViewModel()
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
