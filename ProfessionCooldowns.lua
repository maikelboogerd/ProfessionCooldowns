local frame, events = CreateFrame("FRAME"), {};

local ARCANITE_SPELL_ID = 17187
local MOONCLOTH_SPELL_ID = 18560 -- 18563
local SALT_SHAKER_ID = 15846
local HEARTHSTONE_ID = 6948

function updateCooldowns()

    local playerName = UnitName("player")

    ProfessionCooldownsDB[playerName] = {}

    -- -- Arcanite
    -- local start, duration, enabled = GetSpellCooldown(ARCANITE_SPELL_ID)
    -- ProfessionCooldownsDB[playerName].Arcanite = {
    --     cooldownStart = start,
    --     cooldownDuration = duration,
    --     readyAt = start + duration,
    -- }

    for i = 1, GetNumSkillLines() do
        local skillName, _, _, skillRank = GetSkillLineInfo(i)

        if skillName == "Alchemy" and skillRank >= 275 then
            -- Arcanite
            local start, duration, enabled = GetSpellCooldown(ARCANITE_SPELL_ID)
            ProfessionCooldownsDB[playerName].Arcanite = {
                cooldownStart = start,
                cooldownDuration = duration,
                readyAt = start + duration,
            }
        end

        if skillName == "Tailoring" and skillRank >= 250 then
            -- Mooncloth
            local start, duration, enabled = GetSpellCooldown(MOONCLOTH_SPELL_ID)
            ProfessionCooldownsDB[playerName].Mooncloth = {
                cooldownStart = start,
                cooldownDuration = duration,
                readyAt = start + duration,
            }
        end

        if skillName == "Leatherworking" and skillRank >= 250 then
            -- Salt Shaker
            local start, duration, enabled = GetItemCooldown(SALT_SHAKER_ID)
            ProfessionCooldownsDB[playerName].SaltShaker = {
                cooldownStart = start,
                cooldownDuration = duration,
                readyAt = start + duration,
            }
        end

    end

end

function printCooldowns()
    local currentTime = GetTime()
    print("ProfessionCooldowns:")
    for characterName, CooldownInfo in pairs(ProfessionCooldownsDB) do
        print(characterName)
        for cooldownName, cooldownState in pairs(CooldownInfo) do
            if currentTime > cooldownState.readyAt then
                print("|cff00FF00 + " .. characterName .. " " .. cooldownName .. " is ready|r")
            else
                print("|cffFF0000 - " .. characterName .. " " .. cooldownName .. " on cooldown|r")
            end
        end
    end
end

function events:ADDON_LOADED(addonName)
    if addonName == "ProfessionCooldowns" then
        local playerName = UnitName("player")
        if ProfessionCooldownsDB == nil then ProfessionCooldownsDB = {} end
        if ProfessionCooldownsDB[playerName] == nil then ProfessionCooldownsDB[playerName] = {} end
    end
end

function events:PLAYER_LOGIN(...)
    updateCooldowns()
    printCooldowns()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end);

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

SLASH_COOLDOWNS1 = "/cd"
function SlashCmdList.COOLDOWNS(msg, editbox)
    updateCooldowns()
    printCooldowns()
end