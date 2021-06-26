
--[[
    Override this to:
    1. Clean it up a little bit, seriously
    2. Tweak the recoil viewpunch/camerashake
]]--

-- Bunch of global locals, presumably to cache references
local FT, CT, cos1, cos2, ws, vel, att
local Ang0, curang, curviewbob = Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0)
local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
local Right = reg.Angle.Right
local Up = reg.Angle.Up
local Forward = reg.Angle.Forward
local RotateAroundAxis = reg.Angle.RotateAroundAxis

function SWEP:CalcView(ply, pos, ang, fov)
    self.freeAimOn = self:isFreeAimOn()
    self.autoCenterFreeAim = GetConVar("cw_freeaim_autocenter"):GetBool()

    if self.dt.BipodDeployed then
        if !self.forceFreeAimOffTime then
            self.forceFreeAimOffTime = CurTime() + 0.5
        end
    else
        self.forceFreeAimOffTime = false
    end

    if self.freeAimOn then
        fov = 90 -- force FOV to 90 when in free aim mode, unfortunately, due to angles getting fucked up when FOV is !90
        RunConsoleCommand("fov_desired", 90)
    end

    -- if we have free aim on, and we are !using a bipod, or we're using a bipod and we have !run out of "free aim time", then we should simulate free aim
    if self.freeAimOn and (!self.forceFreeAimOffTime or CurTime() < self.forceFreeAimOffTime) then
        local aiming = self.dt.State == CW_AIMING

        if self.shouldUpdateAngles then
            self.lastEyeAngle = self:GetOwner():EyeAngles()
            self.shouldUpdateAngles = false
        else
            local dot = math.Clamp(math.abs(self:getFreeAimDotToCenter()) + 0.3, 0.3, 1)

            local lazyAim = GetConVar("cw_freeaim_lazyaim"):GetFloat()
            self.lastEyeAngle.y = math.NormalizeAngle(self.lastEyeAngle.y - self.mouseX * lazyAim * dot)

            if !aiming and CurTime() > self.lastShotTime then -- we only want to modify pitch if we haven't shot lately
                self.lastEyeAngle.p = math.Clamp(self.lastEyeAngle.p + self.mouseY * lazyAim * dot, -89, 89)
            end
        end

        if self.autoCenterFreeAim then
            if self.mouseActive then
                self.lastMouseActivity = CurTime() + GetConVar("cw_freeaim_autocenter_time"):GetFloat()
            end

            local canAutoCenter = CurTime() > self.lastMouseActivity
            local shouldAutoCenter = false
            -- !even used...
            -- local aimAutoCenter = GetConVar("cw_freeaim_autocenter_aim"):GetBool()

            if aiming then
                canAutoCenter = true
                shouldAutoCenter = true
            end

            if self.autoCenterExclusions[self.dt.State] then
                canAutoCenter = true
                shouldAutoCenter = true
            end

            if self.forceFreeAimOffTime then -- if we're being forced to turn free-aim off, do so
                canAutoCenter = true
                shouldAutoCenter = true
            end

            if canAutoCenter then
                local frameTime = FrameTime()

                self.freeAimAutoCenterSpeed = frameTime * 16

                if aiming then
                    self.freeAimAutoCenterSpeed = frameTime * 25 --math.Approach(self.freeAimAutoCenterSpeed, frameTime * 40, frameTime * 6)
                end

                if self.autoCenterExclusions[self.dt.State] then
                    shouldAutoCenter = true
                else
                    if CurTime() > self.lastMouseActivity then
                        shouldAutoCenter = true
                        self.freeAimAutoCenterSpeed = frameTime * 6 --math.Approach(self.freeAimAutoCenterSpeed, frameTime * 6, frameTime * 6)
                    end
                end

                self.freeAimAutoCenterSpeed = math.Clamp(self.freeAimAutoCenterSpeed, 0, 1)

                if shouldAutoCenter then
                    self.lastEyeAngle = LerpAngle(self.freeAimAutoCenterSpeed, self.lastEyeAngle, self:GetOwner():EyeAngles())
                end
            end
        end

        local yawDiff = math.AngleDifference(self.lastEyeAngle.y, ang.y)
        local pitchDiff = math.AngleDifference(self.lastEyeAngle.p, ang.p)

        local yawLimit = GetConVar("cw_freeaim_yawlimit"):GetFloat()
        local pitchLimit = GetConVar("cw_freeaim_pitchlimit"):GetFloat()

        if yawDiff >= yawLimit then
            self.lastEyeAngle.y = math.NormalizeAngle(ang.y + yawLimit)
        elseif yawDiff <= -yawLimit then
            self.lastEyeAngle.y = math.NormalizeAngle(ang.y - yawLimit)
        end

        if pitchDiff >= pitchLimit then
            self.lastEyeAngle.p = math.NormalizeAngle(ang.p + pitchLimit)
        elseif pitchDiff <= -pitchLimit then
            self.lastEyeAngle.p = math.NormalizeAngle(ang.p - pitchLimit)
        end

        ang.y = self.lastEyeAngle.y
        ang.p = self.lastEyeAngle.p

        ang = ang
    else
        self.shouldUpdateAngles = true
    end

    FT, CT = FrameTime(), CurTime()

    local resetM203Angles = false

    self.M203CameraActive = false

    if self.AttachmentModelsVM then
        local m203 = self.AttachmentModelsVM.md_m203

        if m203 and self.dt.State != CW_CUSTOMIZE then
            local CAMERA = m203.ent:GetAttachment(m203.ent:LookupAttachment("Camera")).Ang
            local modelAng = m203.ent:GetAngles()

            RotateAroundAxis(CAMERA, Right(CAMERA), self.M203CameraRotation.p)
            RotateAroundAxis(CAMERA, Up(CAMERA), self.M203CameraRotation.y)
            RotateAroundAxis(CAMERA, Forward(CAMERA), self.M203CameraRotation.r)

            local factor = math.abs(ang.p)
            local intensity = 1

            if factor >= 60 then
                factor = factor - 60
                intensity = math.Clamp(1 - math.abs(factor / 15), 0, 1)
            end

            self.M203AngDiff = math.NormalizeAngles(modelAng - CAMERA) * 0.5 * intensity
        end
    end

    ang = ang - self.M203AngDiff
    ang = ang - self.CurM203Angles * 0.5
    ang.r = ang.r + self.lastViewRoll

    if UnPredictedCurTime() > self.lastViewRollTime then
        self.lastViewRoll = LerpCW20(FrameTime() * 10, self.lastViewRoll, 0)
    end

    if UnPredictedCurTime() > self.FOVHoldTime or self.freeAimOn then
        self.FOVTarget = LerpCW20(FT * 10, self.FOVTarget, 0)
    end

    if self.ReloadViewBobEnabled then
        if self.IsReloading and self.Cycle <= 0.9 then
            att = self:GetOwner():GetAttachment(1)

            if att then
                ang = ang * 1

                self.LerpBackSpeed = 1
                curang = LerpAngle(FT * 10, curang, (ang - att.Ang) * 0.1)
            else
                self.LerpBackSpeed = math.Approach(self.LerpBackSpeed, 10, FT * 50)
                curang = LerpAngle(FT * self.LerpBackSpeed, curang, Ang0)
            end
        else
            self.LerpBackSpeed = math.Approach(self.LerpBackSpeed, 10, FT * 50)
            curang = LerpAngle(FT * self.LerpBackSpeed, curang, Ang0)
        end

        RotateAroundAxis(ang, Right(ang), curang.p * self.RVBPitchMod)
        RotateAroundAxis(ang, Up(ang), curang.r * self.RVBYawMod)
        RotateAroundAxis(ang, Forward(ang), (curang.p + curang.r) * 0.15 * self.RVBRollMod)
    end

    local fovOverride = false

    if self.dt.State == CW_AIMING then
        if self.dt.M203Active and self.M203Chamber and !CustomizableWeaponry.grenadeTypes:canUseProperSights(self.Grenade40MM) then
            self.CurFOVMod = LerpCW20(FT * 10, self.CurFOVMod, 5)
        else
            local zoomAmount = self.ZoomAmount
            local simpleTelescopics = !self:canUseComplexTelescopics()
            local shouldDelay = false

            if simpleTelescopics and self.SimpleTelescopicsFOV then
                zoomAmount = self.SimpleTelescopicsFOV
                shouldDelay = true
            end

            if self.DelayedZoom or shouldDelay then
                if CT > self.AimTime then
                    if self.SnapZoom or (self.SimpleTelescopicsFOV and simpleTelescopics) then
                        self.CurFOVMod = zoomAmount

                        -- back-compat with old attachments
                        -- new telescopics FOV sets the FOV instead of deducing it from the current FOV
                        fovOverride = self.newTelescopicsFOV
                    else
                        self.CurFOVMod = LerpCW20(FT * 10, self.CurFOVMod, zoomAmount)
                    end
                else
                    self.CurFOVMod = LerpCW20(FT * 10, self.CurFOVMod, 0)
                end
            else
                if self.SnapZoom or (self.SimpleTelescopicsFOV and simpleTelescopics) then
                    self.CurFOVMod = zoomAmount
                else
                    self.CurFOVMod = LerpCW20(FT * 10, self.CurFOVMod, zoomAmount)
                end
            end
        end
    else
        self.CurFOVMod = LerpCW20(FT * 10, self.CurFOVMod, 0)
    end

    if self.holdingBreath then
        self.BreathFOVModifier = math.Approach(self.BreathFOVModifier, 7, FT * 12)
    else
        self.BreathFOVModifier = math.Approach(self.BreathFOVModifier, 0, FT * 10)
    end

    if self.SimpleTelescopicsFOV and fovOverride then
        fov = self.SimpleTelescopicsFOV
    else
        fov = math.max(5, fov - self.CurFOVMod - self.BreathFOVModifier)
    end

    if self:GetOwner() and self.ViewbobEnabled then
        ws = self:GetOwner():GetWalkSpeed()
        vel = Length(GetVelocity(self:GetOwner()))

        local intensity = 1

        if self:isPlayerProne() and vel >= self.BusyProneVelocity then
            intensity = 7
            cos1 = math.cos(CT * 6)
            cos2 = math.cos(CT * 7)
            curviewbob.p = cos1 * 0.1 * intensity
            curviewbob.y = cos2 * 0.2 * intensity
        else
            if self:GetOwner():OnGround() and vel > ws * 0.3 then
                if vel < ws * 1.2 then
                    cos1 = math.cos(CT * 15)
                    cos2 = math.cos(CT * 12)
                    curviewbob.p = cos1 * 0.15 * intensity
                    curviewbob.y = cos2 * 0.1 * intensity
                else
                    cos1 = math.cos(CT * 20)
                    cos2 = math.cos(CT * 15)
                    curviewbob.p = cos1 * 0.25 * intensity
                    curviewbob.y = cos2 * 0.15 * intensity
                end
            else
                curviewbob = LerpAngle(FT * 10, curviewbob, Ang0)
            end
        end
    end

    fov = fov - self.FOVTarget
    self.curFOV = fov
    self.curViewBob = curviewbob * self.ViewbobIntensity
    ang = ang + curviewbob * self.ViewbobIntensity
    if GetConVar("cw_fas2_recoil_shake"):GetBool() then
        local shakeAngle = AngleRand()
        shakeAngle.p = shakeAngle.p * 0.2
        shakeAngle.y = shakeAngle.y * 0.2
        shakeAngle.r = shakeAngle.y * -2
        -- self.LastShakeAngle = shakeAngle * self.CameraShakeFactor
        ang = ang + shakeAngle * self.CameraShakeFactor
    end
    local cooldownRate = 20 - math.Clamp(self.FireDelay, 0.05, 0.1) * (1 / self.SpreadCooldown)
    self.CameraShakeFactor = Lerp(cooldownRate * FrameTime(), self.CameraShakeFactor, 0)
    return pos, ang, fov
end

-- Override to provide more natural looking reticle movement
function SWEP:getReticleAngles()
    if self.freeAimOn then
        local ang = self.CW_VM:GetAngles()
        ang.p = ang.p + self.AimAng.x
        ang.y = ang.y - self.AimAng.y
        ang.r = ang.r - self.AimAng.z

        return ang
    end
    return self:GetOwner():EyeAngles() + self:GetOwner():GetViewPunchAngles() * 1.075
end