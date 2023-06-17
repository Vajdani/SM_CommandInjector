---@class Injector : ToolClass
Injector = class()

local commands = {
    ["/test"] = {
        callback = "cl_cmd_test",
        help = "Test command"
    },
    ["/togglefly"] = {
        callback = "cl_cmd_togglefly",
        help = "Toggle fly mode"
    },
    ["/explode"] = {
        callback = "cl_cmd_explode",
        help = "Create explosion at aim position"
    }
}



local gameHooked = false
local oldTime = sm.game.setTimeOfDay
function timeHook(time)
    if not gameHooked then
        print("[Command Injector] Loading commands!")
        dofile "$CONTENT_9bc6c720-b6b2-4883-9251-571de93b9e7a/Scripts/vanilla_override.lua"

        for name, data in pairs(commands) do
            sm.game.bindChatCommand( name, data.params or {}, data.callback, data.help or "" )
        end

        gameHooked = true
        print("[Command Injector] Finished loading commands!")
    end

    return oldTime(time)
end
sm.game.setTimeOfDay = timeHook