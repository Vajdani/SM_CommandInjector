dofile '$CONTENT_5a081817-b141-4439-987f-a25162d125fd/Scripts/scrapvm.lua'

local gameClasses = {
    SurvivalGame,
    CreativeGame,
    Game
}

addedFunctions = {}

for k, gclass in pairs(gameClasses) do
    if gclass then
        gclass["cl_setCommandData"] = function(self, data)
            addedCommands = data

            --[[for _k, command in pairs(data) do
                local functions = command.functions
                if functions then
                    for __k, _function in pairs(functions) do
                        gclass[_function.name] = function(self)
                            local func, err = sm.luavm.loadstring(_function.code)
                            if func then func() end
                        end
                    end
                end
            end]]
        end

        gclass["cl_onCustomCommand"] = function (self, params)
            local name = params[1]
            for _k, data in pairs(addedCommands) do
                if data.name == name then
                    print("[Command Injector] Executing command '"..name.."'...")
                    local sandbox = data.sandbox
                    if not sandbox or sandbox == "client" then
                        local func, err = sm.luavm.loadstring(data.code)
                        if func then func(params, sm.localPlayer.getPlayer()) end
                    else
                        params.player = sm.localPlayer.getPlayer()
                        self.network:sendToServer(
                            "sv_onCustomCommand",
                            {
                                command = data,
                                params = params
                            }
                        )
                    end

                    break
                end
            end
        end

        gclass["sv_onCustomCommand"] = function (self, args)
            local func, err = sm.luavm.loadstring(args.command.code)
            if func then
                func(args.params)
                print("[Command Injector] Command successfully executed!")
            else
                print("[Command Injector] Executing command failed! Please check your code for errors.")
            end
        end

        break
    end
end