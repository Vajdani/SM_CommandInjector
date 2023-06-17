dofile '$CONTENT_5a081817-b141-4439-987f-a25162d125fd/Scripts/scrapvm.lua'

local gameClasses = {
    SurvivalGame,
    CreativeGame,
    Game
}

for k, gclass in pairs(gameClasses) do
    if gclass then
        gclass["cl_cmd_test"] = function(self)
            print("BALLS!!!")
        end

        gclass["cl_cmd_togglefly"] = function(self)
            self.network:sendToServer("sv_cmd_togglefly")
        end

        gclass["sv_cmd_togglefly"] = function(self, args, player)
            local char = player.character
            char:setSwimming(not char:isSwimming())
        end

        gclass["cl_cmd_explode"] = function(self)
            self.network:sendToServer("sv_cmd_explode")
        end

        gclass["sv_cmd_explode"] = function(self, args, player)
            local char = player.character
            local pos = char.worldPosition
            local hit, result = sm.physics.raycast(pos, pos + char.direction * 1000)
            if hit then
                sm.physics.explode(result.pointWorld, 10, 10, 10, 10, 'PropaneTank - ExplosionBig')
            end
        end

        break
    end
end
