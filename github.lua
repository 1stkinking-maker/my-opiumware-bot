-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V2 ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Blox Fruits Auto Ken",
   LoadingTitle = "Loading Auto Ken V2...",
   LoadingSubtitle = "by Professional Scripter",
   ConfigurationSaving = { Enabled = false },
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

local FlyHeight = MainTab:CreateSlider({
   Name = "Fly Height",
   Range = { 50, 300 },
   Increment = 10,
   Suffix = "Y-Axis",
   CurrentValue = 150,
   Flag = "FlyHeight",
   Callback = function(Value)
       getgenv().Height = Value
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
                
                -- 1. Find Nearest NPC and Teleport to it
                local nearestNPC = nil
                local shortestDistance = math.huge
                
                for _, v in pairs(game.Workspace:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
                        local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                        if dist < shortestDistance and dist < 500 then -- Only find NPCs within 500 studs
                            shortestDistance = dist
                            nearestNPC = v
                        end
                    end
                end
                
                if nearestNPC then
                    -- Teleport slightly above the NPC so you don't clip inside them
                    hrp.CFrame = nearestNPC.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.2)
                end
                
                -- 2. Activate Observation (Press E)
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, "E", false, game)
                task.wait(0.5) 
                
                -- 3. Spam Dodges for a few seconds
                local dodgeTimer = 0
                while dodgeTimer < 3 and getgenv().AutoKen do -- Spam for 3 seconds
                    vim:SendKeyEvent(true, "Space", false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, "Space", false, game)
                    task.wait(0.1)
                    dodgeTimer = dodgeTimer + 0.15
                end
                
                -- 4. Fly Up (Y Axis)
                if getgenv().AutoKen then
                    local flyHeight = getgenv().Height or 150
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, flyHeight, 0) 
                    bv.Parent = hrp
                    
                    task.wait(1) -- Fly up for 1 second
                    bv:Destroy()
                    
                    -- 5. Wait in the air for dodges to refill
                    task.wait(4) -- Wait 4 seconds in the air (dodges refill over time)
                    
                    -- 6. Fall back down
                    if getgenv().AutoKen then
                        local fallVel = Instance.new("BodyVelocity")
                        fallVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        fallVel.Velocity = Vector3.new(0, -200, 0) -- Fly straight down
                        fallVel.Parent = hrp
                        task.wait(0.8) 
                        fallVel:Destroy()
                        task.wait(0.5) 
                    end
                end
            end
        end
    end
end)