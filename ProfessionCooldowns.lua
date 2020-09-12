local frame, events = CreateFrame("FRAME"), {};

local ARCANITE_SPELL_ID = 17187
local WATER_TO_AIR = 17562
local MOONCLOTH_SPELL_ID = 18560 -- 18563
local SALT_SHAKER_ID = 15846
local HEARTHSTONE_ID = 6948

function SecondsToClock(seconds)

    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "0h 0m"
    else
        h = string.format("%01.f", math.floor(seconds / 3600));
        m = string.format("%01.f", math.floor(seconds / 60 - (h * 60)));
        s = string.format("%02.f", math.floor(seconds - h * 3600 - m * 60));
        return h .. "h " .. m .. "m"
    end

end

function updateCooldowns()

    local playerName = UnitName("player")

    ProfessionCooldownsDB[playerName] = {}

    -- Hearthstone
    local start, duration, enabled = GetItemCooldown(HEARTHSTONE_ID)
    ProfessionCooldownsDB[playerName].Hearthstone = {
        cooldownStart = start,
        cooldownDuration = duration,
        readyAt = start + duration,
    }

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
            -- Water to Air
            local start, duration, enabled = GetSpellCooldown(WATER_TO_AIR)
            ProfessionCooldownsDB[playerName].WaterToAir = {
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
    for characterName, CooldownInfo in pairs(ProfessionCooldownsDB) do
        for cooldownName, cooldownState in pairs(CooldownInfo) do
            if currentTime > cooldownState.readyAt then
                print("|cffFFFF00[Cooldowns]|r <" .. characterName .. "> |cff00FF7F" .. cooldownName .. " ready|r")
            else
                local timeLeft = SecondsToClock(cooldownState.readyAt - currentTime)
                print("|cffFFFF00[Cooldowns]|r <" .. characterName .. "> |cffFF4500" .. cooldownName .. " on cooldown|r " .. "|cffff6060" .. timeLeft .. "|r")
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

function events:CHAT_MSG_LOOT(text, _, _, _, playerName2)
    local playerName = UnitName("player")
    if playerName == playerName2 then
        updateCooldowns()
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end);

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

SLASH_COOLDOWNS1 = "/cd"
function SlashCmdList.COOLDOWNS(msg, editbox)
    if msg == "reset" then
        ProfessionCooldownsDB = {}
        updateCooldowns()
    else
        updateCooldowns()
        printCooldowns()
    end
end