
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