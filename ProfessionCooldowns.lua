local frame, events = CreateFrame("FRAME", "ProfessionCooldownEvents"), {};

local ARCANITE_SPELL_ID = 17187
local MOONCLOTH_SPELL_ID = 18563 -- 18560
local SALT_SHAKER_ID = 15846
local HEARTHSTONE_ID = 6948

function updateCooldowns()

    local playerName = UnitName("player")

    ProfessionCooldowns[playerName] = {}

    for i = 1, GetNumSkillLines() do
        local skillName, _, _, skillRank = GetSkillLineInfo(i)

        if skillName == "Alchemy" and skillRank >= 275 then
            -- Arcanite
            local start, duration, enabled = GetSpellCooldown(ARCANITE_SPELL_ID)
            ProfessionCooldowns[playerName].arcanite = {
                cooldownStart = start,
                cooldownDuration = duration,
                readyAt = start + duration,
            }
        end

        if skillName == "Tailoring" and skillRank >= 250 then
            -- Mooncloth
            local start, duration, enabled = GetSpellCooldown(MOONCLOTH_SPELL_ID)
            ProfessionCooldowns[playerName].mooncloth = {
                cooldownStart = start,
                cooldownDuration = duration,
                readyAt = start + duration,
            }
        end
    end

end

function printCooldowns()
    local currentTime = GetTime()
    for characterName, CooldownInfo in pairs(ProfessionCooldowns) do
        for cooldownName, cooldownState in pairs(CooldownInfo) do
            if currentTime > cooldownState.readyAt then
                print("|cff00FF00 + " .. characterName .. " " .. cooldownName .. " is ready|r")
            else
                print("|cffFF0000 - " .. characterName .. " " .. cooldownName .. " on cooldown|r")
            end
        end
    end
end

function events:ADDON_LOADED(...)
    local playerName = UnitName("player")
    if ProfessionCooldowns == nil then ProfessionCooldowns = {} end
    ProfessionCooldowns[playerName] = {}
end

function events:PLAYER_LOGIN(...)
    updateCooldowns()
    printCooldowns()
end

function events:PLAYER_LOGOUT(...)
    updateCooldowns()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end);

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

SLASH_COOLDOWNS1 = "/cd"
function SlashCmdList.COOLDOWNS(msg, editbox)
    printCooldowns()
end