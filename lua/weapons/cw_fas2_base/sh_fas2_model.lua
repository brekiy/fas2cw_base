local SP = game.SinglePlayer()

-- damn thats a lotta shells
CustomizableWeaponry.shells:addNew("fas2_50bmg", "models/shells/50bmg.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_50beowulf", "models/shells/50beowulf.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x39", "models/shells/7_62x39mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x39_t", "models/shells/7_62x39mm_tracer.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x39_live", "models/shells/7_62x39mm_live.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_5.56x45", "models/shells/5_56x45mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x51", "models/shells/7_62x51mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_5.45x39", "models/shells/5_45x39mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_5.45x39_t", "models/shells/5_45x39mm_tracer.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_10x25", "models/shells/10x25mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_357sig", "models/shells/357sig.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_357mag", "models/shells/357mag.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_380acp", "models/shells/380acp.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_45acp", "models/shells/45acp.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_454casull", "models/shells/454casull.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_9x18", "models/shells/9x18mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_50ae", "models/shells/50ae.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_44mag", "models/shells/44mag.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_9x19", "models/shells/9x19mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_4.6x30", "models/shells/4_6x30mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_stripper", "models/shells/sks_clip.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_5.45x18", "models/shells/5_45x18mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_5.7x28", "models/shells/5_7x28mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_5.45x18", "models/shells/5_45x18mm.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_6.8x43", "models/shells/6_8x43mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x54", "models/shells/7_62x54mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_7.62x54_t", "models/shells/7_62x54mm_tracer.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_9.3x64", "models/shells/9_3x64mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_9x39", "models/shells/9x39mm.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_22lr", "models/shells/22lr.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_30-06", "models/shells/30-06.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_40sw", "models/shells/40sw.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_300wm", "models/shells/300win.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_338lm", "models/shells/338lapua.mdl", "CW_SHELL_MAIN")
CustomizableWeaponry.shells:addNew("fas2_408ct", "models/shells/408cheytac.mdl", "CW_SHELL_SMALL")
CustomizableWeaponry.shells:addNew("fas2_23x75", "models/shells/23mm.mdl", "CW_SHELL_SHOT")
CustomizableWeaponry.shells:addNew("fas2_12g_buck", "models/shells/12g_buck.mdl", "CW_SHELL_SHOT")
-- CustomizableWeaponry.shells:addNew("fas2_12g_slug", "models/shells/12g_slug.mdl", "CW_SHELL_SHOT")

-- Special CW_VM has its separate bodygroup...
function SWEP:getCWBodygroup(main)
    if SERVER then
        return
    end

    if self.CW_VM then
        return self.CW_VM:GetBodygroup(main)
    end
end

-- Preps a net message to tell a client to eject a bunch of shells.
-- Really just meant to be used in singleplayer, and has a hard cap on number of shells to eject via the bit limit
function SWEP:SendFakeShellToClient(targetPly, shell, num, delay, attachmentName, vel, removetime, shellscale)
    if SERVER and SP then
        vel = vel or Vector(0, 0, -100)
        removetime = removetime or 5
        shellscale = shellscale or 1
        net.Start("CW_FAS2_FAKESHELL")
        net.WriteString(shell)
        net.WriteUInt(num, 8)
        net.WriteFloat(delay)
        net.WriteString(attachmentName)
        net.WriteVector(vel)
        net.WriteFloat(removetime)
        net.WriteFloat(shellscale)
        net.Send(targetPly)
    end
end