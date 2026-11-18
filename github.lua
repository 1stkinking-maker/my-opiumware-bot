-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Blox Fruits Auto Ken",
   LoadingTitle = "Loading Auto Ken...",
   LoadingSubtitle = "by Professional Scripter",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458) 
local Toggle = MainTab:CreateToggle({
   Name = "Auto Observation Grind",
   CurrentValue = false,
   Flag = "AutoKenToggle", 
   Callback = function(Value)
       getgenv().AutoKen = Value
   end,
})

-- MAIN LOGIC LOOP
task.spawn(function()
    while task.wait() do
        if getgenv().AutoKen then
            local player = game.Players.LocalPlayer
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char.HumanoidRootPart
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                -- 1. Activate Observation (Press E)
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, "E", false, game)
                task.wait(0.5) -- Wait a moment for it to activate
                
                -- 2. Spam Dodges
                local dodgesEmpty = false
                while not dodgesEmpty and getgenv().AutoKen do
                    -- Check for Dodge refill (Using your logic)
                    local anyRefilled = false
                    for _, child in ipairs(char:GetChildren()) do
                        if child.Name == "Dodge" and child:GetAttribute("Refilled") then
                            anyRefilled = true
                            break
                        end
                    end
                    
                    if anyRefilled then
                        -- Press Space to dodge
                        vim:SendKeyEvent(true, "Space", false, game)
                        task.wait(0.05)
                        vim:SendKeyEvent(false, "Space", false, game)
                        task.wait(0.1)
                    else
                        dodgesEmpty = true
                    end
                end
                
                -- 3. Fly Up (Y Axis)
                if getgenv().AutoKen then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, 100, 0) -- Fly straight up
                    bv.Parent = hrp
                    
                    task.wait(1.5) -- Fly up for 1.5 seconds (Adjust if you need to go higher)
                    bv:Destroy()
                    
                    -- 4. Wait for Dodges to Refill
                    local isRefilled = false
                    while not isRefilled and getgenv().AutoKen do
                        task.wait(0.5)
                        for _, child in ipairs(char:GetChildren()) do
                            if child.Name == "Dodge" and child:GetAttribute("Refilled") then
                                isRefilled = true
                                break
                            end
                        end
                    end
                    
                    -- 5. Fall back down (Optional, but needed to be near enemies again)
                    if getgenv().AutoKen then
                        local fallVel = Instance.new("BodyVelocity")
                        fallVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        fallVel.Velocity = Vector3.new(0, -150, 0) -- Fly straight down
                        fallVel.Parent = hrp
                        task.wait(1) -- Fall down
                        fallVel:Destroy()
                        task.wait(1) -- Pause before repeating
                    end
                end
            end
        end
    end
end)