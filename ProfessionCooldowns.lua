local frame, events = CreateFrame("FRAME"), {};

local cooldownSpells = {
    -- Classic Era
	{
        spellName = "Transmute: Arcanite",
        spellID = 17187,
    },
    {
        spellName = "Transmute: Water to Air",
        spellID = 17562,
    },
    {
        spellName = "Transmute: Mooncloth",
        spellID = 18560,
    },
    {
        spellName = "Salt Shaker",
        spellID = 19566,
    },
    -- Classic: The Burning Crusade
    {
        spellName = "Transmute: Primal Might",
        spellID = 29688,
    },
    {
        spellName = "Primal Mooncloth",
        spellID = 26751,
    },
    {
        spellName = "Shadowcloth",
        spellID = 36686,
    },
    {
        spellName = "Spellcloth",
        spellID = 31373,
    },
}

function printCooldowns()
    local currentTime = GetServerTime()
    for characterName, CooldownInfo in pairs(ProfessionCooldownsDB) do
        for cooldownName, cooldownState in pairs(CooldownInfo) do
            if currentTime > cooldownState.readyAt then
                print("|cffFFFF00[Cooldowns]|r " .. characterName .. " |cff00FF7F" .. cooldownName .. " ready|r")
            else
                local timeLeft = SecondsToClock(cooldownState.readyAt - currentTime)
                print("|cffFFFF00[Cooldowns]|r " .. characterName .. " |cffFF4500" .. cooldownName .. " on cooldown|r " .. "|cffff6060" .. timeLeft .. "|r")
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
    ProfessionCooldowns_wait(5, printCooldowns)
end

function events:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
    local playerName = UnitName("player")
    local spellCooldown = GetSpellBaseCooldown(spellID) / 1000 -- seconds
    for i, spellInfo in ipairs(cooldownSpells) do
        if spellID == spellInfo.spellID then
            local startCooldown = GetServerTime()
            ProfessionCooldownsDB[playerName][spellInfo.spellName] = {
                cooldownStart = startCooldown,
                cooldownDuration = spellCooldown,
                readyAt = startCooldown + spellCooldown,
            }
        end
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
        local playerName = UnitName("player")
        ProfessionCooldownsDB = {}
        ProfessionCooldownsDB[playerName] = {}
    else
        printCooldowns()
    end
end