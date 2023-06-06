---@class Injector : ToolClass
Injector = class()

dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

local fileExists = sm.json.fileExists
addedCommands = {}
local function GetCommandSets()
    for uuid, desc in pairs(ModDatabase.databases.descriptions) do
        if desc.type == "Blocks and Parts" then
            local key = "$CONTENT_"..uuid
            local success, exists = pcall(fileExists, key)
            if success == true and exists == true then
                local commands = key.."/commands.json"
                if fileExists(commands) then
                    addedCommands[#addedCommands+1] = sm.json.open(commands)
                    print("[Command Injector] Found commands in "..desc.name.."!")
                end
            end
        end
    end
end



local commandFunction = nil
local oldBind = sm.game.bindChatCommand
function bindHook(name, params, func, help)
    if commandFunction == nil and func ~= nil then
        commandFunction = func
    end

    return oldBind(name, params, func, help)
end
sm.game.bindChatCommand = bindHook

local gameHooked = false
local oldTime = sm.game.setTimeOfDay
function timeHook(time)
    if not gameHooked and commandFunction and ModDatabase.databases.descriptions == nil then
        print("[Command Injector] Loading commands!")
        ModDatabase.loadDescriptions()

        GetCommandSets()
        for k, set in pairs(addedCommands) do
            for _k, command in pairs(set) do
                sm.game.bindChatCommand( command.name, command.params, commandFunction, command.help or "" )
            end
        end

        ModDatabase.unloadDescriptions()
        gameHooked = true
        print("[Command Injector] Finished loading commands!")
    end

    return oldTime(time)
end
sm.game.setTimeOfDay = timeHook