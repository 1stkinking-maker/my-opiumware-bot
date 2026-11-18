-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V12 FIXED STATE MACHINE ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V12",
   LoadingTitle = "Loading V12...",
   LoadingSubtitle = "Fixed Loops & Anti-Freeze",
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
   Name = "Hover Height (Y-Axis)",
   Range = { 30, 150 },
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = 60,
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
            count = count + 1
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

-- Clean up all movement
local function clearMovement()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("HoverBP") then hrp.HoverBP:Destroy() end
        if hrp:FindFirstChild("FlyAlign") then hrp.FlyAlign:Destroy() end
    end
end

-- Smooth Flight Engine
local function startFlight()
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    clearMovement()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    -- AlignOrientation prevents flipping perfectly
    local align = Instance.new("AlignOrientation")
    align.Name = "FlyAlign"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.MaxTorque = math.huge
    align.Responsiveness = 200
    local att = Instance.new("Attachment", hrp)
    align.Attachment0 = att
    align.Parent = hrp
    att.Name = "FlyAtt"
end

-- STATE MACHINE
task.spawn(function()
    local state = "FIND_NPC"
    local dodgeTimer = 0
    
    while task.wait(0.1) do
        if not getgenv().AutoKen then
            state = "FIND_NPC"
            continue
        end
        
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
        local hrp = char.HumanoidRootPart
        
        local dodges = getDodgeCount()
        local waitThreshold = getgenv().DodgeThreshold or 3
        local flyHeight = getgenv().FlyHeight or 60
        
        if state == "FIND_NPC" then
            local npc = getNearestNPC()
            if npc then
                StatusLabel:Set("Status: Flying to NPC...")
                startFlight()
                local targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
                
                -- Fly for a maximum of 2 seconds to prevent getting stuck
                local timePassed = 0
                while timePassed < 2 do
                    local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
                    if dist < 5 then break end
                    hrp.FlyBV.Velocity = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit * 50
                    task.wait(0.1)
                    timePassed = timePassed + 0.1
                end
                
                clearMovement() -- Stop flying so you can get hit
                state = "FIGHT"
                dodgeTimer = 0
            else
                StatusLabel:Set("Status: No NPCs found.")
                clearMovement()
                task.wait(1)
            end
            
        elseif state == "FIGHT" then
            if dodges > 0 then
                StatusLabel:Set("Status: Dodging! ("..dodges.." left)")
                
                -- Press E to activate Ken
                vim:SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, "E", false, game)
                
                -- Press Space to dodge (slower so the game registers it)
                task.wait(0.2)
                vim:SendKeyEvent(true, "Space", false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, "Space", false, game)
                
                task.wait(0.3) -- Wait before the next loop tick
            else
                -- Dodges are 0, go up immediately
                state = "FLY_UP"
            end
            
        elseif state == "FLY_UP" then
            StatusLabel:Set("Status: Out of dodges! Flying UP!")
            startFlight()
            local targetY = hrp.Position.Y + flyHeight
            
            local timePassed = 0
            while hrp.Position.Y < targetY and timePassed < 3 do
                hrp.FlyBV.Velocity = Vector3.new(0, 60, 0)
                task.wait(0.1)
                timePassed = timePassed + 0.1
            end
            
            -- Lock in place in the sky
            clearMovement()
            local bp = Instance.new("BodyPosition")
            bp.Name = "HoverBP"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.Position = hrp.Position
            bp.Parent = hrp
            
            state = "HOVER"
            
        elseif state == "HOVER" then
            StatusLabel:Set("Status: Hovering. Dodges: "..dodges.."/"..waitThreshold)
            
            local bp = hrp:FindFirstChild("HoverBP")
            if bp then
                bp.Position = Vector3.new(hrp.Position.X, bp.Position.Y, hrp.Position.Z)
            end
            
            if dodges >= waitThreshold then
                StatusLabel:Set("Status: Dodges ready! Diving...")
                clearMovement()
                state = "FIND_NPC"
            end
        end
    end
end)