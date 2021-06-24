function SWEP:IndividualThink()
    -- Automatically check that the trigger is released before bolting
    self:ManualAction()
    -- Handle shotgun anim stuff
    self:FAS2ShotgunReload()
end
