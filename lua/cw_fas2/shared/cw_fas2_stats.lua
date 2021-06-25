AddCSLuaFile()
--stuff it in here to load stat updates before the attachments
CustomizableWeaponry.originalValue:add("NearWallDistance", false)
CustomizableWeaponry.originalValue:add("MuzzleVelocity", true)
CustomizableWeaponry.originalValue:add("RecoilSide", true)
-- kinda broken originally
CustomizableWeaponry.originalValue:add("ClumpSpread", true)

CustomizableWeaponry:registerRecognizedVariable(
    "NearWallDistance",
    "Decreases weapon length by ",
    "Increases weapon length by ",
    CustomizableWeaponry.textColors.POSITIVE,
    CustomizableWeaponry.textColors.NEGATIVE,

    function(weapon, attachmentData)
        weapon.NearWallDistance = (weapon.NearWallDistance or 0) + attachmentData.NearWallDistance
    end,

    function(weapon, attachmentData)
        weapon.NearWallDistance = (weapon.NearWallDistance or 0) - attachmentData.NearWallDistance
    end,

    function(attachmentData, value, varData)
        if value > 0 then
            return varData.greater .. math.abs(math.Round(value / 39.37, 2)) .. "M", varData.greaterColor
        end

        return varData.lesser .. math.abs(math.Round(value / 39.37, 2)) .. "M", varData.lesserColor
    end
)

CustomizableWeaponry:registerRecognizedStat(
    "MuzzleVelocityMult",
    "Decreases muzzle velocity",
    "Increases muzzle velocity",
    CustomizableWeaponry.textColors.NEGATIVE,
    CustomizableWeaponry.textColors.POSITIVE
)

CustomizableWeaponry:registerRecognizedStat(
    "RecoilSideMult",
    "Decreases horizontal recoil",
    "Increases horizontal recoil",
    CustomizableWeaponry.textColors.POSITIVE,
    CustomizableWeaponry.textColors.NEGATIVE
)
-- overwrite the original one
CustomizableWeaponry:registerRecognizedStat(
    "RecoilMult",
    "Decreases vertical recoil",
    "Increases vertical recoil",
    CustomizableWeaponry.textColors.POSITIVE,
    CustomizableWeaponry.textColors.NEGATIVE
)

print("registering fas2 cw stats")