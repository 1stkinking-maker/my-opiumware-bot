-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V4 TWEEN GLIDE ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Blox Fruits Auto Ken V4",
   LoadingTitle = "Loading Auto Ken V4...",
   LoadingSubtitle = "Tween Glide & Dodge Tracking",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458) 

local StatusLabel = MainTab:CreateLabel("Status: Idle")

local Toggle = MainTab:CreateToggle({
   Name = "Auto Observation Grind",
   CurrentValue = false,
   Flag = "AutoKenToggle", 
   Callback = function(Value)
       getgenv().AutoKen = Value
       if not Value then StatusLabel:Set("Status: Idle") end
   end,
})

local MaxDodgesSlider = MainTab:CreateSlider({
   Name = "Max Dodges (For 50% Calc)",
   Range = { 2, 10 },
   Increment = 1,
   Suffix = "Dodges",
   CurrentValue = 6,
   Flag = "MaxDodges",
   Callback = function(Value)
       getgenv().MaxDodges = Value
   end,
})

local HeightSlider = MainTab:CreateSlider({
   Name = "Fly Height (Safe Zone)",
   Range = { 30, 150 },
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

-- Helper function to find nearest NPC (Works in Blox Fruits)
local function getNearestNPC()
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local shortestDist = math.huge
    
    -- Search common Blox Fruits folders for enemies
    local foldersToSearch = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs"), workspace}
    
    for _, folder in pairs(foldersToSearch) do
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if not game.Players:GetPlayerFromCharacter(v) then
                        local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                        if dist < shortestDist and dist < 1000 then
                            shortestDist = dist
                            nearest = v
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Smooth Glide function using TweenService
local function glideTo(targetCFrame, duration)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait() -- Wait until we arrive
    end
end

-- MAIN LOGIC LOOP
task.spawn(function()
    local isHovering = false
    
    while task.wait(0.1) do
        if getgenv().AutoKen then
            local player = game.Players.LocalPlayer
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char.HumanoidRootPart
                local currentDodges = getDodgeCount()
                local maxDodges = getgenv().MaxDodges or 6
                local halfDodges = math.max(1, math.floor(maxDodges / 2))
                local flyHeight = getgenv().FlyHeight or 60
                local npc = getNearestNPC()

                -- === LOGIC: OUT OF DODGES ===
                if currentDodges == 0 and not isHovering then
                    StatusLabel:Set("Status: Flying Up to Safe Zone...")
                    isHovering = true
                    
                    -- Fly up straight into the sky
                    local skyCFrame = hrp.CFrame + Vector3.new(0, flyHeight, 0)
                    glideTo(skyCFrame, 0.5) 
                end
                
                if isHovering then
                    StatusLabel:Set("Status: Hovering. Waiting for " .. halfDodges .. " dodges...")
                    -- Keep hovering until we reach half dodges
                    if currentDodges >= halfDodges then
                        isHovering = false
                    else
                        -- Make sure we don't fall
                        hrp.CFrame = hrp.CFrame 
                        continue
                    end
                end

                -- === LOGIC: HAVE DODGES, FLY TO NPC AND FIGHT ===
                if not isHovering and npc then
                    StatusLabel:Set("Status: Gliding to NPC...")
                    
                    -- Fly slightly above the NPC so you don't clip
                    local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    
                    -- Only glide if we are more than 10 studs away
                    if (hrp.Position - targetCFrame.Position).Magnitude > 10 then
                        glideTo(targetCFrame, 0.3)
                    end
                    
                    -- Once at the NPC, Activate Ken
                    if currentDodges >= 1 then
                        StatusLabel:Set("Status: Spamming Dodges (Ken Active)")
                        
                        -- Press E
                        vim:SendKeyEvent(true, "E", false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, "E", false, game)
                        task.wait(0.2)
                        
                        -- Spam Space until dodges hit 0
                        while getDodgeCount() > 0 and getgenv().AutoKen do
                            vim:SendKeyEvent(true, "Space", false, game)
                            task.wait(0.05)
                            vim:SendKeyEvent(false, "Space", false, game)
                            task.wait(0.1)
                            
                            -- Reset hovering flag since we are about to fly up
                            if getDodgeCount() == 0 then
                                isHovering = false 
                            end
                        end
                    end
                elseif not isHovering and not npc then
                    StatusLabel:Set("Status: No NPCs found nearby. Searching...")
                end
            end
        else
            isHovering = false
        end
    end
end)