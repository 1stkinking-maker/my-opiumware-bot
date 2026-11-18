-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V14 TRUE AFK ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V14",
   LoadingTitle = "Loading V14...",
   LoadingSubtitle = "Perfect AFK Ken",
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
       if not Value then 
           StatusLabel:Set("Status: Idle") 
           local char = game.Players.LocalPlayer.Character
           if char and char:FindFirstChild("HumanoidRootPart") then
               local hrp = char.HumanoidRootPart
               if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
               if hrp:FindFirstChild("HoverBP") then hrp.HoverBP:Destroy() end
               if hrp:FindFirstChild("FlyAlign") then hrp.FlyAlign:Destroy() end
               if hrp:FindFirstChild("FlyAtt") then hrp.FlyAtt:Destroy() end
           end
       end
   end,
})

local DodgeThresholdSlider = MainTab:CreateSlider({
   Name = "Dodges Needed to Dive",
   Range = { 1, 12 },
   Increment = 1,
   Suffix = "Dodges",
   CurrentValue = 3,
   Flag = "DodgeThreshold",
   Callback = function(Value)
       getgenv().DodgeThreshold = Value
   end,
})

local HeightSlider = MainTab:CreateSlider({
   Name = "Hover Height (6 Players = 35)",
   Range = { 10, 100 },
   Increment = 5,
   Suffix = "Studs",
   CurrentValue = 35, -- 6 Roblox players roughly equals 35 studs
   Flag = "FlyHeight",
   Callback = function(Value)
       getgenv().FlyHeight = Value
   end,
})

-- Accurate Dodge Counter (Checks if the dodge is actually refilled)
local function getDodgeCount()
    local char = game.Players.LocalPlayer.Character
    if not char then return 0 end
    local count = 0
    for _, child in ipairs(char:GetChildren()) do
        if child.Name == "Dodge" then
            if child:GetAttribute("Refilled") == true then
                count = count + 1
            end
        end
    end
    -- Fallback just in case attributes are buggy
    if count == 0 then
        for _, child in ipairs(char:GetChildren()) do
            if child.Name == "Dodge" then
                count = count + 1
            end
        end
    end
    return count
end

-- Find Nearest NPC
local function getNearestNPC()
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local shortestDist = math.huge
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

-- Clean up movement
local function clearMovement()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("HoverBP") then hrp.HoverBP:Destroy() end
        if hrp:FindFirstChild("FlyAlign") then hrp.FlyAlign:Destroy() end
        if hrp:FindFirstChild("FlyAtt") then hrp.FlyAtt:Destroy() end
    end
end

-- Smooth Flight Engine (Prevents flipping and allows X/Y/Z movement)
local function startFlight()
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    clearMovement()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    local align = Instance.new("AlignOrientation")
    align.Name = "FlyAlign"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.MaxTorque = math.huge
    align.Responsiveness = 200
    local att = Instance.new("Attachment", hrp)
    att.Name = "FlyAtt"
    align.Attachment0 = att
    align.Parent = hrp
end

-- MAIN SEQUENCE
task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().AutoKen then continue end
        
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
        local hrp = char.HumanoidRootPart
        local waitThreshold = getgenv().DodgeThreshold or 3
        local flyHeight = getgenv().FlyHeight or 35
        
        -- 1. FIND AND FLY TO NPC
        local npc = getNearestNPC()
        if not npc then
            StatusLabel:Set("Status: No NPCs found.")
            clearMovement()
            task.wait(1)
            continue
        end

        StatusLabel:Set("Status: Flying to NPC...")
        startFlight()
        local targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
        local timePassed = 0
        
        while timePassed < 2 and getgenv().AutoKen do
            local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist < 5 then break end
            hrp.FlyBV.Velocity = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit * 50
            task.wait(0.1)
            timePassed = timePassed + 0.1
        end
        clearMovement() -- Stop flying so you stand perfectly still and get hit
        
        -- 2. ACTIVATE KEN & WAIT
        StatusLabel:Set("Status: Activating Ken (Standing Still)...")
        
        -- Press E ONCE
        vim:SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        vim:SendKeyEvent(false, "E", false, game)
        
        -- Wait for dodges to hit 0 (No jumping, just waiting for auto-dodge)
        local kenWait = 0
        while getDodgeCount() > 0 and kenWait < 10 and getgenv().AutoKen do
            -- If dodges aren't going down, it's because you aren't getting hit. Just wait.
            task.wait(0.2)
            kenWait = kenWait + 0.2
        end
        
        -- 3. FLY UP (Smoothly like the horizontal flight)
        StatusLabel:Set("Status: Dodges empty. Flying UP!")
        startFlight()
        local targetY = hrp.Position.Y + flyHeight
        timePassed = 0
        
        while hrp.Position.Y < targetY and timePassed < 2 and getgenv().AutoKen do
            hrp.FlyBV.Velocity = Vector3.new(0, 40, 0) -- Smooth upward velocity
            task.wait(0.1)
            timePassed = timePassed + 0.1
        end
        
        -- 4. LOCK IN THE SKY
        clearMovement()
        local bp = Instance.new("BodyPosition")
        bp.Name = "HoverBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Position = hrp.Position
        bp.Parent = hrp
        
        -- 5. HOVER AND WAIT FOR THRESHOLD
        while getgenv().AutoKen do
            local dodges = getDodgeCount()
            StatusLabel:Set("Status: Hovering. Dodges: "..dodges.."/"..waitThreshold)
            
            local bp2 = hrp:FindFirstChild("HoverBP")
            if bp2 then
                bp2.Position = Vector3.new(hrp.Position.X, bp2.Position.Y, hrp.Position.Z)
            end
            
            if dodges >= waitThreshold then
                StatusLabel:Set("Status: Dodges ready! Diving...")
                clearMovement()
                break
            end
            task.wait(0.2)
        end
    end
end)