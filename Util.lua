local waitTable = {}
local waitFrame = nil

function ProfessionCooldowns_wait(delay, func, ...)
    if(type(delay) ~= "number" or type(func) ~= "function") then
        return false
    end
    if not waitFrame then
        waitFrame = CreateFrame("Frame", nil, UIParent)
        waitFrame:SetScript("OnUpdate", function (self, elapse)
            for i = 1, #waitTable do
                local waitRecord = tremove(waitTable, i)
                if waitRecord ~= nil then
                    local d = tremove(waitRecord, 1)
                    local f = tremove(waitRecord, 1)
                    local p = tremove(waitRecord, 1)
                    if d > elapse then
                        tinsert(waitTable, i, {d - elapse, f, p})
                        i = i + 1
                    else
                        f(unpack(p))
                    end
                end
            end
        end)
    end
    tinsert(waitTable, {delay, func, {...}})
    return true
end

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