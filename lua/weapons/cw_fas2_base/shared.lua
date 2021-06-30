SWEP.Base = "cw_base"

AddCSLuaFile()
AddCSLuaFile("cl_fas2_hud.lua")
AddCSLuaFile("cl_fas2_model.lua")
AddCSLuaFile("cl_fas2_calcview.lua")
AddCSLuaFile("cl_fas2_cvars.lua")
AddCSLuaFile("sh_fas2_model.lua")
AddCSLuaFile("sh_fas2_reload.lua")
AddCSLuaFile("sh_fas2_firing.lua")
AddCSLuaFile("sh_fas2_stats.lua")
AddCSLuaFile("sh_fas2_think.lua")

include("sh_fas2_model.lua")
include("sh_fas2_reload.lua")
include("sh_fas2_firing.lua")
include("sh_fas2_stats.lua")
include("sh_fas2_think.lua")

CustomizableWeaponry:registerAmmo(".380 ACP", ".380 ACP Rounds", 9, 17.3)
CustomizableWeaponry:registerAmmo("10mm Auto", "10mm Auto Rounds", 10, 25.2)
-- this is an abstraction for how much powder is in the shotty shell
CustomizableWeaponry:registerAmmo("23x75MMR", "23x75MMR Shells", 9.1, 10)
CustomizableWeaponry:registerAmmo(".50 Beowulf", ".50 Beowulf Rounds", 12.7, 42)
CustomizableWeaponry:registerAmmo(".300 Blackout", ".300 Blackout Rounds", 7.8, 34.7)
CustomizableWeaponry:registerAmmo(".357 SIG", ".357 SIG Rounds", 9.02, 21.97)
CustomizableWeaponry:registerAmmo("9x18MM", "9x18MM Rounds", 9, 18)
CustomizableWeaponry:registerAmmo("6.8x43MM", "6.8x43MM SPC Rounds", 7, 42.3)
CustomizableWeaponry:registerAmmo(".300 Win Mag", ".300 Win Mag Rounds", 7.8, 67)
CustomizableWeaponry:registerAmmo(".357 Magnum", ".357 Magnum Rounds", 9.1, 33)
CustomizableWeaponry:registerAmmo(".454 Casull", ".454 Casull Rounds", 11.5, 35.1)
CustomizableWeaponry:registerAmmo(".50 BMG", ".50 BMG Rounds", 13, 99)
CustomizableWeaponry:registerAmmo(".45 Colt", ".45 Long Colt Rounds", 11.5, 32.6)
CustomizableWeaponry:registerAmmo("6x35MM", "6x35MM KAC Rounds", 6, 35)
CustomizableWeaponry:registerAmmo("9.3x64MM", "9.3x64MM Brenneke Rounds", 9.3, 64)
CustomizableWeaponry:registerAmmo(".40 S&W", ".40 S&W Rounds", 10.2, 21.6)

-- Guesstimating case length until i find a spec sheet
CustomizableWeaponry:registerAmmo(".429 DE", ".429 DE Rounds", 10.9, 32.6)
CustomizableWeaponry:registerAmmo(".50 GI", ".50 GI Rounds", 12.7, 22.8)

if CLIENT then
    include("cl_fas2_cvars.lua")
    include("cl_fas2_hud.lua")
    include("cl_fas2_model.lua")
    include("cl_fas2_calcview.lua")

    SWEP.Author			= "brekiy"
    SWEP.Contact		= ""
    SWEP.Purpose		= ""
    SWEP.Instructions	= ""
    SWEP.Category = "CW 2.0 FA:S 2 Weapons"
    SWEP.HipFireFOVIncrease = false

    SWEP.ViewModelFlip	= false
    SWEP.HUD_3D2DScale = 0.0105
    SWEP.ReloadViewBobEnabled = false
    SWEP.RVBPitchMod = 0.4
    SWEP.RVBYawMod = 0.4
    SWEP.RVBRollMod = 0.4
    SWEP.PosBasedMuz = false
    -- Recoil shake factor
    SWEP.CameraShakeFactor = 0

    -- This offset is added to all aimpositions
    -- SWEP.BipodAimOffsetPos = Vector()
    -- SWEP.BipodAimOffsetAng = Vector()

    SWEP.MuzzleEffect = "muzzleflash_6"
    SWEP.Shell = "fas2_7.62x39"

    SWEP.AlternativePos = Vector(-1, 0, 0)
    SWEP.AlternativeAng = Vector(0, 0, -8)
    -- Custom crouching origin
    SWEP.AlternativeCrouchPos = Vector(-4, -2, 0)
    SWEP.AlternativeCrouchAng = Vector(0, 0, -25)

    -- Function table for adjusting shell ejects in FAS2_MakeFakeShell()
    -- <attachmentName> = callback function(self)
    SWEP.FakeShellOffsetCalcs = {
        -- ejector3 = SKS_Ejector3Offsetter,
    }
    -- Dunno why, but we can't have an empty table in here. Must be set to an empty table at least in each weapon that uses a bodygroup optic.
    -- Otherwise the code will just skip over setting aim positions for bodygroup optics. :)
    -- What a nice gap in logic that i cant be assed to override right now
    -- SWEP.AttachmentModelsVM = {}
    SWEP.CArmsVM = true
    SWEP.CArmsModel = "models/weapons/c_arms.mdl"
end

SWEP.UseHands = true

-- render target shit on the base FAS2 weapons
SWEP.PSO1Glass = Material("models/weapons/view/accessories/Lens_EnvSolid")

-- these suck
SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.MuzzleVelocity = 300 -- m/s, required value
SWEP.ManualCycling = false -- bolt/pump, if true then uncocks the gun every shot
SWEP.CycleDelay = 0.8 -- standard cycle
SWEP.CycleDelayAim = 0.83 -- ditto ads
SWEP.CycleDelayFast = 0.67 -- fast cycling with SWEP.FastReload, if you have an animation for it
SWEP.CycleDelayFastAim = 0.62 -- ditto ads
SWEP.Cocked = true -- needs to be cocked to fire
SWEP.ShotgunReloadEmptyInsert = false -- whether the empty reload start animation inserts a shell or not
SWEP.ShotgunReloadEmptyInsertCount = 1

SWEP.MuzzleAttachment = 1
SWEP.MuzzleAttachmentName = "muzzle"
SWEP.EjectorAttachmentName = "ejector"

SWEP.SpeedDec = 20 -- source units

SWEP.Recoil = 1.1 -- vertical
SWEP.RecoilSide = 0.55 -- horizontal

-- Explanations of various tabular props
--[[

-- Example attachments
-- This MUST have a key of 1, otherwise some shit breaks regarding selecting custom laser colors etc.
SWEP.Attachments = {
    [1] = {header = "Sight", offset = {400, -250},  atts = {"bg_fas2_eotech", "bg_fas2_compm4", "bg_fas2_elcan"}},
    [2] = {header = "Muzzle", offset = {-200, -250}, atts = {"bg_fas2_suppressor"}},
    [3] = {header = "Caliber", offset = {-200, 250}, atts = {"am_fas2_300ar", "am_fas2_68ar", "am_fas2_50ar"}},
    ["+use"] = {header = "Perk", offset = {1200, 50}, atts = {"pk_fas2_fast_reload"}},
    ["+reload"] = {header = "Ammo", offset = {600, 250}, atts = {"am_magnum", "am_matchgrade"}}
}

-- Example animations
SWEP.Animations = {
    fire = {"fire1", "fire2", "fire3"}, --shooting
    fire_last = "fire_last", --last round in the mag
    fire_aim = "fire2", --shooting ads
    fire_aim_last = "fire_last", --last round in the mag ads
    fire_bipod = {"bipod_fire1", "bipod_fire2", "bipod_fire3"}, --you can figure these out right
    fire_bipod_last = "bipod_fire_last",
    fire_bipod_aim = "bipod_fire3_scoped",
    fire_bipod_aim_last = "bipod_fire_last_scoped",
    reload = "reload",
    reload_bipod = "bipod_reload",
    reload_empty = "reload_empty",
    reload_fast = "reload_nomen", --only read when SWEP.FastReloadVanilla is not true
    reload_fast_bipod = "bipod_reload_nomen",
    reload_fast_empty = "reload_empty_nomen",
    reload_fast_bipod_empty = "bipod_reload_empty_nomen",
    idle = "idle",
    draw = "deploy",
    holster = "holster",
    bipod_down = "bipod_down",
    bipod_up = "bipod_up",
}

-- Sounds table, recommended to define this in a separate file and get it included to improve readability
-- <animation> = <table array of sounds and times>
SWEP.Sounds = {
    deploy = {{time = 0, sound = "CW_FOLEY_MEDIUM"}},
}
]]--

SWEP.ADSSpeed = 1 -- multiplier for how quickly this weapon goes into irons


-- Time of wet reload sequence
SWEP.ReloadTime = 2
-- Time of dry reload sequence
SWEP.ReloadTime_Empty = 2
-- Blocking time of wet reload (no shooting, make it about 0.1-0.15s longer than ReloadTime)
SWEP.ReloadHalt = 2.1
-- Blocking time of dry reload
SWEP.ReloadHalt_Empty = 2.1

-- Same deal but for the fast reload perk (think sleight of hand from COD)
-- SWEP.ReloadFastTime = 1
-- SWEP.ReloadFastTime_Empty = 1
-- SWEP.ReloadFastHalt = 1.1
-- SWEP.ReloadFastHalt_Empty = 1.1

--[[
    If set to true, functions will look for special animations for reloading:
    reload_start_fast
    reload_fast
    reload_fast_empty
    insert_fast
    If set to false, it will ignore the above fastreload times and just speed up the animation a bit
]]--
SWEP.FastReloadVanilla = false

-- individual round loading props
SWEP.ShotgunReload = false -- if false the following arent used
--[[
SWEP.ReloadStartTime = 0.4
SWEP.ReloadStartFastTime = 0.3
SWEP.ReloadStartTime_Empty = 2.1
SWEP.ReloadStartFastTime_Empty = 2.1
SWEP.InsertShellTime = 1
SWEP.InsertShellFastTime = 0.75
SWEP.ReloadFinishWait = 1.5
SWEP.ReloadFinishFastWait = 1
SWEP.PumpMidReloadWait = 0.7
]]--

SWEP.Chamberable = true
