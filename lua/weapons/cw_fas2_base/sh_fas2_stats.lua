
function SWEP:recalculateMuzzleVelocity()
    self.MuzzleVelocity = self.MuzzleVelocity_Orig * self.MuzzleVelocityMult
    self.MuzzleVelocityConverted = self.MuzzleVelocity * 39.37
end

function SWEP:recalculateRecoilSide()
    self.RecoilSide = self.RecoilSide_Orig * self.RecoilSideMult
end

-- was missing from vanilla base
function SWEP:recalculateSpreadPerShot()
    self.SpreadPerShot = self.SpreadPerShot_Orig * self.SpreadPerShotMult
end

-- fix bug where this was based off of damagemult lmao
function SWEP:recalculateClumpSpread()
    if !self.ClumpSpread then
        return
    end

    self.ClumpSpread = self.ClumpSpread_Orig * self.ClumpSpreadMult
end

-- Override to factor in muzzle velocity
function SWEP:CalculateEffectiveRange()
    self.EffectiveRange = self.CaseLength * 10 - self.BulletDiameter * 5 -- setup realistic base effective range
    -- some arbitrary factor lol
    -- for shotguns we divide by number of pellets?
    local muzzleMult = math.Clamp(
        self.MuzzleVelocity / self.EffectiveRange / 2 / math.max(math.floor(self.Shots / 4), 1),
        0.5,
        1.5
    )
    self.EffectiveRange = self.EffectiveRange * muzzleMult * GetConVar("cw_fas2_effrange_mult"):GetFloat() * 39.37 -- convert meters to units
    self.DamageFallOff = (100 - (self.CaseLength - self.BulletDiameter)) * (1 + (-1 * (muzzleMult - 1))) / 200
    self.PenStr = (self.BulletDiameter * 0.5 + self.CaseLength * 0.35) * (self.PenAdd and self.PenAdd or 1) * muzzleMult
    self.PenetrativeRange = self.EffectiveRange * 0.5

    -- we need to save it once
    if !self.EffectiveRange_Orig then
        self.EffectiveRange_Orig = self.EffectiveRange
        self.DamageFallOff_Orig = self.DamageFallOff
        self.PenetrativeRange_Orig = self.PenetrativeRange
    end
end

function SWEP:getEffectiveRange()
    local EffectiveRange = self.CaseLength * 10 - self.BulletDiameter * 5
    local muzzleMult = math.Clamp(
        self.MuzzleVelocity / EffectiveRange / 2 / math.max(math.floor(self.Shots / 4), 1),
        0.5,
        1.5
    )
    EffectiveRange = EffectiveRange * muzzleMult * GetConVar("cw_fas2_effrange_mult"):GetFloat() * 39.37 -- convert meters to units
    local DamageFallOff = (100 - (self.CaseLength - self.BulletDiameter)) * (1 + (-1 * (muzzleMult - 1))) / 200
    local PenStr = (self.BulletDiameter * 0.5 + self.CaseLength * 0.35) * (self.PenAdd and self.PenAdd or 1) * muzzleMult
    local PenetrativeRange = EffectiveRange * 0.5

    return EffectiveRange, DamageFallOff, PenStr, PenetrativeRange
end



-- Override to force a recalc of effective range and muzzle velocity
function SWEP:recalculateStats()
    -- recalculates all stats
    self:recalculateDamage()
    self:recalculateRecoil()
    self:recalculateRecoilSide()
    self:recalculateFirerate()
    self:recalculateVelocitySensitivity()
    self:recalculateAimSpread()
    self:recalculateHipSpread()
    self:recalculateDeployTime()
    self:recalculateReloadSpeed()
    self:recalculateClumpSpread()
    self:recalculateSpreadPerShot()

    if CLIENT then
        self:recalculateMouseSens()
    end
    self:setupBallisticsInformation()
    self:recalculateMaxSpreadInc()
    self:recalculateMuzzleVelocity()
    self:CalculateEffectiveRange()
end