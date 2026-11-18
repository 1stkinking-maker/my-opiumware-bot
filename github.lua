-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V3 FLIGHT ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Blox Fruits Auto Ken V3",
   LoadingTitle = "Loading Auto Ken V3...",
   LoadingSubtitle = "True Flight & Dodge Logic",
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
       local char = game.Players.LocalPlayer.Character
       if not Value and char and char:FindFirstChild("MacroBV") then
           char.MacroBV:Destroy() -- Clean up flight when turned off
       end
   end,
})

local MaxDodgesSlider = MainTab:CreateSlider({
   Name = "Max Dodges (For 50% Calc)",
   Range = { 2, 10 },
   Increment = 1,
   Suffix = "Dodges",
   CurrentValue = 6, -- Default Blox Fruits max dodges
   Flag = "MaxDodges",
   Callback = function(Value)
       getgenv().MaxDodges = Value
   end,
})

local HeightSlider = MainTab:CreateSlider({
   Name = "Fly Height",
   Range = { 20, 150 },
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = 60,
   Flag = "FlyHeight",
   Callback = function(Value)
       getgenv().FlyHeight = Value
   end,
})

-- Helper function to count current refilled dodges
local function getDodgeCount()
    local char = game.Players.LocalPlayer.Character
    if not char then return 0 end
    local count = 0
    for _, child in ipairs(char:GetChildren()) do
        if child.Name == "Dodge" and child:GetAttribute("Refilled") == true then
            count = count + 1
        end
    end
    return count
end

-- Helper function to find nearest NPC
local function getNearestNPC()
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local shortestDist = math.huge
    
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            -- Make sure it's an NPC and not another player
            if not game.Players:GetPlayerFromCharacter(v) then
                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist and dist < 1000 then
                    shortestDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- MAIN LOGIC LOOP
task.spawn(function()
    local vim = game:GetService("VirtualInputManager")
    
    while task.wait(0.1) do
        if getgenv().AutoKen then
            local player = game.Players.LocalPlayer
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char.HumanoidRootPart
                
                -- Ensure BodyVelocity exists for flight
                if not char:FindFirstChild("MacroBV") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "MacroBV"
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Parent = hrp
                end
                local bv = char.MacroBV
                
                local currentDodges = getDodgeCount()
                local maxDodges = getgenv().MaxDodges or 6
                local halfDodges = math.floor(maxDodges / 2)
                if halfDodges < 1 then halfDodges = 1 end
                local flyHeight = getgenv().FlyHeight or 60

                if currentDodges == 0 then
                    -- === STATE 1: OUT OF DODGES, FLY UP AND HOVER ===
                    bv.Velocity = Vector3.new(0, 50, 0) -- Fly up
                    task.wait(1) 
                    bv.Velocity = Vector3.new(0, 0, 0) -- Hover in place (negates gravity)
                    
                    -- Wait until we get 50% of our dodges back
                    while getDodgeCount() < halfDodges and getgenv().AutoKen do
                        task.wait(0.5)
                        -- Keep hovering to prevent falling
                        bv.Velocity = Vector3.new(0, 0, 0) 
                    end
                    
                else
                    -- === STATE 2: HAVE DODGES, FLY TO NPC ===
                    local npc = getNearestNPC()
                    if npc then
                        -- Fly to NPC while maintaining current Y height
                        local targetPos = Vector3.new(npc.HumanoidRootPart.Position.X, hrp.Position.Y, npc.HumanoidRootPart.Position.Z)
                        local dir = (targetPos - hrp.Position).Unit
                        
                        -- Fly at the NPC
                        bv.Velocity = dir * 100 
                        
                        -- Wait until we are close to the NPC horizontally
                        while (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude > 5 and getgenv().AutoKen do
                            task.wait(0.1)
                        end
                        
                        -- Stop moving once there
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    -- === STATE 3: ACTIVATE KEN & SPAM DODGES ===
                    -- Only press E if we actually have a dodge ready
                    if getDodgeCount() >= 1 then
                        vim:SendKeyEvent(true, "E", false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, "E", false, game)
                        task.wait(0.3) -- Let Ken activate
                        
                        -- Spam spacebar until dodges hit 0
                        while getDodgeCount() > 0 and getgenv().AutoKen do
                            vim:SendKeyEvent(true, "Space", false, game)
                            task.wait(0.05)
                            vim:SendKeyEvent(false, "Space", false, game)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)