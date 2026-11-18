-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V15 HYBRID ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualUser = game:GetService("VirtualUser")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V15",
   LoadingTitle = "Loading V15 Hybrid...",
   LoadingSubtitle = "Hub Ken Logic + Smooth Flight",
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
   CurrentValue = 35,
   Flag = "FlyHeight",
   Callback = function(Value)
       getgenv().FlyHeight = Value
   end,
})

-- Accurate Dodge Counter
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
    if count == 0 then
        for _, child in ipairs(char:GetChildren()) do
            if child.Name == "Dodge" then count = count + 1 end
        end
    end
    return count
end

-- Hub's specific NPC locations as fallback
local function getHubNPC()
    local PlaceId = game.PlaceId
    if PlaceId == 2753915549 then -- Sea 1
        return Vector3.new(-5478.39209, 15.9775667, -5246.9126) -- Lava Pirate
    elseif PlaceId == 4442272183 then -- Sea 2
        return Vector3.new(5533.29785, 88.1079102, 4852.3916) -- Galley Captain
    elseif PlaceId == 7449423635 then -- Sea 3
        return Vector3.new(4530.3540039063, 656.75695800781, -131.60952758789) -- Giant Islander
    end
    return nil
end

-- Find Nearest NPC dynamically
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
        local targetPos = nil
        
        if npc then
            targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
        else
            -- Fallback to Hub's hardcoded locations if no NPC is found nearby
            local hubPos = getHubNPC()
            if hubPos then targetPos = hubPos end
        end

        if not targetPos then
            StatusLabel:Set("Status: No NPCs found.")
            clearMovement()
            task.wait(1)
            continue
        end

        StatusLabel:Set("Status: Flying to NPC...")
        startFlight()
        local timePassed = 0
        
        while timePassed < 2.5 and getgenv().AutoKen do
            local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
            if dist < 5 then break end
            hrp.FlyBV.Velocity = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit * 50
            task.wait(0.1)
            timePassed = timePassed + 0.1
        end
        clearMovement() -- Stop flying so you stand perfectly still
        
        -- 2. ACTIVATE KEN (Using Hub's exact logic)
        StatusLabel:Set("Status: Activating Ken...")
        
        -- Hub uses VirtualUser and checks ScreenGui
        if not game:GetService('Players').LocalPlayer.PlayerGui.ScreenGui:FindFirstChild('ImageLabel') then
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown('0x65')
            task.wait(0.5)
            VirtualUser:SetKeyUp('0x65')
        end
        
        -- 3. WAIT FOR DODGES TO HIT 0
        local kenWait = 0
        while getDodgeCount() > 0 and kenWait < 15 and getgenv().AutoKen do
            task.wait(0.2)
            kenWait = kenWait + 0.2
        end
        
        -- 4. FLY UP
        StatusLabel:Set("Status: Dodges empty. Flying UP!")
        startFlight()
        local targetY = hrp.Position.Y + flyHeight
        timePassed = 0
        
        while hrp.Position.Y < targetY and timePassed < 2 and getgenv().AutoKen do
            hrp.FlyBV.Velocity = Vector3.new(0, 40, 0)
            task.wait(0.1)
            timePassed = timePassed + 0.1
        end
        
        -- 5. LOCK IN THE SKY
        clearMovement()
        local bp = Instance.new("BodyPosition")
        bp.Name = "HoverBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Position = hrp.Position
        bp.Parent = hrp
        
        -- 6. HOVER AND WAIT FOR THRESHOLD
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