local _, SM = ...

local scheduledTasks = {}
local debouncedTasks = {}

function SM.ScheduleTask(key, delay, callback)
    if not callback then return end
    key = key or callback
    if scheduledTasks[key] then return end
    scheduledTasks[key] = true
    C_Timer.After(delay or 0, function()
        scheduledTasks[key] = nil
        callback()
    end)
end

function SM.DebounceTask(key, delay, callback)
    if not key or not callback then return end
    local token = (debouncedTasks[key] or 0) + 1
    debouncedTasks[key] = token
    C_Timer.After(delay or 0, function()
        if debouncedTasks[key] ~= token then return end
        debouncedTasks[key] = nil
        callback()
    end)
end

function SM.ScheduleLayout(key, callback)
    if type(key) == "function" then
        callback = key
        key = "detail"
    end
    SM.ScheduleTask("layout:" .. tostring(key or "detail"), 0, callback or SM.LayoutDetailTab)
end
