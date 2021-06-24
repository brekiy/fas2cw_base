local SP = game.SinglePlayer()
--[[
    Helper fxn to check if a weapon has special animations/setup for fast reloading.
    If this returns true the reload functions will look for additional '_fast_empty' and '_fast'
    type reload animations in the SWEP animation table.
    It does do a few safety checks, but still.
]]--
function SWEP:IsNonVanillaFastReload()
    return self.FastReload and !self.FastReloadVanilla
end

function SWEP:CalcReloadSpeed()
    local reloadSpeed = self.ReloadSpeed
    if self.FastReload then
        -- A modest buff
        reloadSpeed = reloadSpeed * 1.125
        if self.FastReloadVanilla then
            -- Another modest buff
            reloadSpeed = reloadSpeed * 1.2
        end
    end
    return reloadSpeed
end

--[[
    Override to allow:
    1. Starting a special empty reload for shotties
    2. Fast reload perk to play different set of animations
    3. Update reload time calc according to (2)
    TODO: maybe refactor the fastreload checks... idk
]]--
function SWEP:beginReload()
    local mag = self:Clip1()
    local CT = CurTime()
    local reloadSpeed = self:CalcReloadSpeed()
    if self.ShotgunReload then
        local time
        self.WasEmpty = mag == 0
        local animString = "reload_start"
        local reloadStartString = "ReloadStart"

        if self:IsNonVanillaFastReload() then
            reloadStartString = reloadStartString .. "Fast"
            animString = animString .. "_fast"
        end
        reloadStartString = reloadStartString .. "Time"

        if self.WasEmpty then
            if self.ReloadStartTime_Empty then
                reloadStartString = reloadStartString .. "_Empty"
                animString = animString .. "_empty"
            end
            if self.ShotgunReloadEmptyInsert then
                self:SetClip1(self.ShotgunReloadEmptyInsertCount)
                self.WasEmpty = false
                if self.ManualCycling then self.Cocked = true end
            end
        end

        time = CT + self[reloadStartString] / reloadSpeed

        self.ReloadDelay = time
        self:SetNextPrimaryFire(time)
        self:SetNextSecondaryFire(time)
        self.GlobalDelay = time
        self.ShotgunReloadState = 1
        self.ForcedReloadStop = false
        self:sendWeaponAnim(animString, reloadSpeed)
    else
        local reloadTime = nil
        local reloadHalt = nil

        if mag == 0 then
            if self.Chamberable then
                self.Primary.ClipSize = self.Primary.ClipSize_Orig
            end
            if self:IsNonVanillaFastReload() then
                reloadTime = self.ReloadFastTime_Empty
                reloadHalt = self.ReloadFastHalt_Empty
            else
                reloadTime = self.ReloadTime_Empty
                reloadHalt = self.ReloadHalt_Empty
            end
        else
            if self:IsNonVanillaFastReload() then
                reloadTime = self.ReloadFastTime
                reloadHalt = self.ReloadFastHalt
            else
                reloadTime = self.ReloadTime
                reloadHalt = self.ReloadHalt
            end

            if self.Chamberable then
                self.Primary.ClipSize = self.Primary.ClipSize_Orig + 1
            end
        end

        reloadTime = reloadTime / reloadSpeed
        reloadHalt = reloadHalt / reloadSpeed

        self.ReloadDelay = CT + reloadTime
        self:SetNextPrimaryFire(CT + reloadHalt)
        self:SetNextSecondaryFire(CT + reloadHalt)
        self.GlobalDelay = CT + reloadHalt

        if self.reloadAnimFunc then
            self:reloadAnimFunc(mag, reloadSpeed)
        else
            if self.FastReload then
                if mag == 0 then
                    if self.Animations.reload_fast_empty then
                        self:sendWeaponAnim("reload_fast_empty", reloadSpeed)
                    else
                        self:sendWeaponAnim("reload_empty", reloadSpeed)
                    end
                else
                    if self.Animations.reload_fast then
                        self:sendWeaponAnim("reload_fast", reloadSpeed)
                    else
                        self:sendWeaponAnim("reload", reloadSpeed)
                    end
                end
            else
                if self.Animations.reload_empty and mag == 0 then
                    self:sendWeaponAnim("reload_empty", reloadSpeed)
                else
                    self:sendWeaponAnim("reload", reloadSpeed)
                end
            end
        end
    end

    CustomizableWeaponry.callbacks.processCategory(self, "beginReload", mag == 0)

    self:GetOwner():SetAnimation(PLAYER_RELOAD)
end

-- pretty much the shotgun reload logic from the base, but customized to allow
-- special animations to be played and to tie into the fastreload stuff
function SWEP:FAS2ShotgunReload()
    local CT = CurTime()
    local reloadSpeed = self:CalcReloadSpeed()
    if self.ShotgunReloadState == 1 then
        -- continuing to reload
        if self:GetOwner():KeyPressed(IN_ATTACK) and self:Clip1() != 0 then
            self.ShotgunReloadState = 2
            self.ForcedReloadStop = true
        end

        if CT > self.ReloadDelay then
            local insertTime
            local animString = "insert"
            if self:IsNonVanillaFastReload() and self.Animations.insert_fast then
                animString = "insert_fast"
                insertTime = self.InsertShellFastTime
            else
                animString = "insert"
                insertTime = self.InsertShellTime
            end

            self:sendWeaponAnim(animString, reloadSpeed)

            -- if SP isn't defined or whatever it bugs out and plays the hl2 shotgun cock sound every insert. happens even if i override the whole think()
            if SERVER and !SP then
                self:GetOwner():SetAnimation(PLAYER_RELOAD)
            end

            local mag, ammo = self:Clip1(), self:GetOwner():GetAmmoCount(self.Primary.Ammo)

            if SERVER then
                self:SetClip1(mag + 1)
                self:GetOwner():SetAmmo(ammo - 1, self.Primary.Ammo)
            end

            self.ReloadDelay = CT + insertTime / reloadSpeed

            local maxReloadAmount = self.Primary.ClipSize

            if self.Chamberable and !self.WasEmpty then  -- if the weapon is chamberable + we've cocked it - we can add another shell in there
                maxReloadAmount = self.Primary.ClipSize + 1
            end

            -- if we've filled up the weapon (or we have no ammo left), we go to the "end reload" state
            if mag + 1 == maxReloadAmount or ammo - 1 == 0 then
                self.ShotgunReloadState = 2
            end
        end
    elseif self.ShotgunReloadState == 2 then
        -- ending reload
        -- this section has no issues.
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self.ShotgunReloadState = 2
            self.ForcedReloadStop = true
        end

        if CT > self.ReloadDelay then
            self.ShotgunReloadState = 0
            --[[
                select the animation to use
                ideally you have the animations set up like this:
                1. reload_end = finish reloading, whatever it is
                2. reload_end_fast = optional special anim
                3. idle = fallback
            ]]--
            local animString = self.Animations.reload_end and "reload_end" or "idle"
            if self:IsNonVanillaFastReload() and self.Animations.reload_end_fast and animString != "idle" then
                animString = animString .. "_fast"
            end

            if !self.WasEmpty then
                local time = 0.25 / reloadSpeed
                self:SetNextPrimaryFire(time)
                self:SetNextSecondaryFire(time)
                self.ReloadWait = time
                self.ReloadDelay = nil
            else
                local canInsertMore = false
                local waitTime = self.ReloadFinishWait

                if !self.ForcedReloadStop and self.Chamberable and self:Clip1() < self.Primary.ClipSize + 1 and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
                    waitTime = self.PumpMidReloadWait or waitTime
                    canInsertMore = true
                end

                local time = CT + waitTime / reloadSpeed
                self:SetNextPrimaryFire(time)
                self:SetNextSecondaryFire(time)
                self.ReloadWait = time

                if !canInsertMore then
                    self.ReloadDelay = nil
                else
                    self.ReloadDelay = time
                end

                if canInsertMore then -- if we can chamber and we haven't chambered up fully + we have some ammo to spare
                    self.ShotgunReloadState = 1 -- we add another shell in there
                    self.WasEmpty = false
                end
            end
            self:sendWeaponAnim(animString, reloadSpeed)
        end
    end
end

-- Returns the number of rounds about to be loaded into the magazine
function SWEP:_getToLoad(mag)
    local toLoad
    local max = self:GetMaxClip1()

    if mag == 0 then
        toLoad = self:Ammo1() >= max and max or self:Ammo1()
    else
        toLoad = max - mag
    end
    if self.Chamberable then toLoad = toLoad + 1 end
    return toLoad
end

