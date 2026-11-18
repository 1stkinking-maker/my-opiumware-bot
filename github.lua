-- Wait for the game to detect a refill event
game:GetService("RunService").Heartbeat:Connect(function()
        -- Check if Observation is off
        if not game.Players.LocalPlayer.Character:FindFirstChild("Observation") or game.Players.LocalPlayer.Character:FindFirstChild("Observation"):GetAttribute("Active") == false then
                -- Check if at least 1 dodge is refilled
                local dodgeRefilled = false
                for _, fruit in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if fruit.Name == "Dodge" and fruit:GetAttribute("Refilled") then
                                dodgeRefilled = true
                                break
                        end
                end
                
                if dodgeRefilled then