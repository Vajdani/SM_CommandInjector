---@class Injector : ToolClass
Injector = class()

dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

local fileExists = sm.json.fileExists
local function GetCommandSets()
    local addedCommands = {}
    for uuid, desc in pairs(ModDatabase.databases.descriptions) do
        if desc.type == "Blocks and Parts" then
            local key = "$CONTENT_"..uuid
            local success, exists = pcall(fileExists, key)
            if success == true and exists == true then
                local commands = key.."/commands.json"
                if fileExists(commands) then
                    for k, data in pairs(sm.json.open(commands)) do
                        addedCommands[#addedCommands+1] = data
                    end
                    print("[Command Injector] Found commands in "..desc.name.."!")
                end
            end
        end
    end

    return addedCommands
end



local gameHooked = false
local oldTime = sm.game.setTimeOfDay
function timeHook(time)
    if not gameHooked and ModDatabase.databases.descriptions == nil then
        print("[Command Injector] Loading commands!")
        dofile "$CONTENT_9bc6c720-b6b2-4883-9251-571de93b9e7a/Scripts/vanilla_override.lua"
        ModDatabase.loadDescriptions()

        local commands = GetCommandSets()
        sm.event.sendToGame("cl_setCommandData", commands)
        for k, command in pairs(commands) do
            sm.game.bindChatCommand( command.name, command.params or {}, "cl_onCustomCommand", command.help or "" )
        end

        ModDatabase.unloadDescriptions()
        gameHooked = true
        print("[Command Injector] Finished loading commands!")
    end

    return oldTime(time)
end
sm.game.setTimeOfDay = timeHook