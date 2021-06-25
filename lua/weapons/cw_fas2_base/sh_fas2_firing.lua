-- Special functions for FAS2 behavior and to expand functionality
local SP = game.SinglePlayer()

--[[
    Override to:
    1. Adjust viewpunch
    2. Add camera shake factor tracking
]]-- 
function SWEP:MakeRecoil(mod)
    local finalMod = self:GetRecoilModifier(mod)
    local IFTP = IsFirstTimePredicted()
    local freeAimOn = self:isFreeAimOn()
    local yawRecoil = math.Rand(-1, 1)
    local yawSpread = self.AddSpread * 10 * yawRecoil
    yawRecoil = yawRecoil + yawSpread
    if (SP and SERVER) or (!SP and CLIENT and IFTP) then
        ang = self:GetOwner():EyeAngles()
        ang.p = ang.p - self.Recoil * 0.5 * finalMod
        ang.y = ang.y + yawRecoil * self.RecoilSide * 0.5 * finalMod
        self:GetOwner():SetEyeAngles(ang)
    end

    if !freeAimOn or (freeAimOn and self.dt.BipodDeployed) then
        local viewPunchAngle = Angle()
        viewPunchAngle.p = -self.Recoil * finalMod
        viewPunchAngle.y = yawRecoil * self.RecoilSide * finalMod
        -- viewPunchAngle.r = yawRecoil * self.Recoil * 0.125 * finalMod
        self:GetOwner():ViewPunch(viewPunchAngle)
        self.CameraShakeFactor = GetConVar("cw_fas2_recoil_shake"):GetBool() and (self.Recoil / 2 + self.RecoilSide / 2) * 0.011 * finalMod or 0
    end

    if CLIENT and IFTP and self.AimBreathingEnabled then
        if self.holdingBreath then
            self:reduceBreathAmount(mod)
        else
            self:reduceBreathAmount(0)
        end
    end
end

-- Create a burst-fire tracking full-auto mode for use with hyperburst functionality
CustomizableWeaponry.firemodes:registerFiremode("hyperburst_auto", "FULL-AUTO", true, 9999, 5)

--[[
    Hijack the vanilla animation behavior to support extra animations
]]--
function SWEP:fireAnimFunc()
    local remainingAmmo = self:Clip1() - self.AmmoPerShot
    local animString = "fire"
    if remainingAmmo <= 0 and self.fire_dry then
        animString = animString .. "_dry"
    else
        if self.dt.BipodDeployed and !self.BipodFireAnim then
            animString = animString .. "_bipod"
        end

        -- Play special animations if we don't just use the regular hipfire animation for these special states
        if self.dt.State == CW_AIMING and !self.ADSFireAnim then
            animString = animString .. "_aim"
        end

        if self.dt.State != CW_AIMING and (!self.LuaViewmodelRecoilOverride and self.LuaViewmodelRecoil) then
            return
        end

        if remainingAmmo <= 0 then
            animString = animString .. "_last"
        end
    end

    self:sendWeaponAnim(animString, self.FireAnimSpeed)
end

-- Override to play the bipod animation, hope this shit works
function SWEP:performBipodDelay(time)
    time = time or self.BipodDeployTime
    local CT = CurTime()

    self.BipodDelay = CT + time
    self:SetNextPrimaryFire(CT + time)
    self:SetNextSecondaryFire(CT + time)
    self.ReloadWait = CT + time

    self:deployBipodAnim()
end

-- Prefixed with an underscore because its meant to be internal only
function SWEP:_manualActionHelp()
    local cycleDelay, shellDelay
    local animString = "cycle_gun"
    local cycleDelayStr = "CycleDelay"
    local shellDelayStr = "ManualShellDelay"
    self.Cycling = true
    if self.dt.BipodDeployed and self.Animations.cycle_gun_bipod then
        animString = animString .. "_bipod"
        cycleDelayStr = cycleDelayStr .. "Bipod"
        shellDelayStr = shellDelayStr .. "Bipod"
    end
    if self:IsNonVanillaFastReload() then
        animString = animString .. "_fast"
        cycleDelayStr = cycleDelayStr .. "Fast"
        shellDelayStr = shellDelayStr .. "Fast"
    end
    if self.dt.State == CW_AIMING and self.Animations.cycle_gun_aim then
        animString = animString .. "_aim"
        cycleDelayStr = cycleDelayStr .. "Aim"
        shellDelayStr = shellDelayStr .. "Aim"
    end
    cycleDelay = self[cycleDelayStr]
    shellDelay = self[shellDelayStr]
    self:sendWeaponAnim(animString)
    -- print(animString)
    timer.Simple(cycleDelay, function()
        self.Cocked = true
        self.Cycling = false
    end)
    if CLIENT then
        self.NoShells = false
        timer.Simple(shellDelay, function()
            self:CreateShell()
            self.NoShells = true
        end)
    end

end

function SWEP:ManualAction()
    if !self.ManualCycling or self.Cocked or self.WasEmpty then
        return false
    end

    if self.Cycling then
        -- exit early if we're already trying to do this
        return true
    end

    if self:Clip1() > 0 and !self:GetOwner():KeyDown(IN_ATTACK) and self:GetNextPrimaryFire() < CurTime() and !self.Cycling then
        self:_manualActionHelp()
    end
    return true
end

function SWEP:uncycle()
    if self.ManualCycling then self.Cocked = false end
end

function SWEP:checkManualCycling()
    -- callback condition checks that the callback returns FALSE before it lets you shoot
    if self.ManualCycling then return !self.Cocked end
end

function SWEP:deployBipodAnim()
    if self.Animations.bipod_down and self.Animations.bipod_up then
        if self.dt.BipodDeployed then
            self:sendWeaponAnim("bipod_down")
        else
            self:sendWeaponAnim("bipod_up")
        end
    end
end

--[[
    postFire callback
    In a SWEP with a burst firemode, you can have an optional table:
    The numeric key assigns it to that shot in the burst or auto spray.
    The value is another table with 3 optional values:
    1. FireDelay => Set the next shot to occur with this delay.
    2. Recoil => Set the next shot to occur with this recoil.
    3. SpreadPerShot => Set the next shot to occur with this spread increase.
]]--
function SWEP:specialBurst()
    if self.SpecialBurstTable and self.BurstAmount > 0 then
        local shots = self.dt.Shots
        local mods = self.SpecialBurstTable[shots]
        if !mods then
            self.FireDelay = self.NonBurstFireDelay
            self.Recoil = self.NonBurstRecoil
            self.RecoilSide = self.NonBurstRecoilSide
            self.SpreadPerShot = self.NonBurstSpreadPerShot
        else
            self.FireDelay = self.NonBurstFireDelay * (mods.fireDelayMult or 1)
            self.Recoil = self.NonBurstRecoil * (mods.recoilMult or 1)
            self.RecoilSide = self.NonBurstRecoilSide * (mods.recoilSideMult or 1)
            self.SpreadPerShot = self.NonBurstSpreadPerShot * (mods.spreadPerShotMult or 1)
        end
    end
end

function SWEP:saveNonBurstValues()
    self.NonBurstFireDelay = self.FireDelay
    self.NonBurstRecoil = self.Recoil
    self.NonBurstRecoilSide = self.RecoilSide
    self.NonBurstSpreadPerShot = self.SpreadPerShot
end

if SERVER then
    CustomizableWeaponry.callbacks:addNew("postFire", "FAS2_uncycle", function(self)
        if self.uncycle then self:uncycle() end
    end)
    CustomizableWeaponry.callbacks:addNew("preFire", "FAS2_checkManualCycling", function(self)
        if self.checkManualCycling then return self:checkManualCycling() else return false end
    end)
    CustomizableWeaponry.callbacks:addNew("preFire", "FAS2_specialBurst", function(self)
        if self.specialBurst and self.BurstAmount and self.BurstAmount > 0 then self:specialBurst() end
        return false
    end)
    CustomizableWeaponry.callbacks:addNew("initialize", "FAS2_specialBurstInit", function(self)
        if self.SpecialBurstTable then self:saveNonBurstValues() end
    end)
    CustomizableWeaponry.callbacks:addNew("postAttachAttachment", "FAS2_resetNonBurstValues", function(self)
        if self.SpecialBurstTable then self:saveNonBurstValues() end
    end)
    CustomizableWeaponry.callbacks:addNew("postDetachAttachment", "FAS2_resetNonBurstValues", function(self)
        if self.SpecialBurstTable then self:saveNonBurstValues() end
    end)
end
