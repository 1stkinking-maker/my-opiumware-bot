-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V11 ROBUST FLIGHT ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V11",
   LoadingTitle = "Loading V11 Robust Flight...",
   LoadingSubtitle = "No Stuck, No Flips",
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
               if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
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
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    end
end

-- Robust Fly Function (with timeouts so you never get stuck)
local function flyTo(targetPos, speed, timeLimit)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    clearMovement()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = hrp
    
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "FlyGyro"
    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    gyro.P = 9e4
    gyro.D = 500
    gyro.CFrame = hrp.CFrame
    gyro.Parent = hrp
    
    local startTime = tick()
    
    while getgenv().AutoKen do
        if not hrp or not hrp.Parent then break end
        if tick() - startTime > timeLimit then break end -- Timeout to prevent freezing
        
        local dist = (targetPos - hrp.Position).Magnitude
        if dist < 5 then break end -- Reached destination
        
        bv.Velocity = (targetPos - hrp.Position).Unit * speed
        task.wait(0.1)
    end
end

-- STATE MACHINE
task.spawn(function()
    local state = "FIND_NPC"
    
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
                local targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
                flyTo(targetPos, 50, 2) -- Fly for max 2 seconds
                clearMovement() -- Hand control back to the game so you can get hit
                if getgenv().AutoKen then
                    state = "FIGHT"
                end
            else
                StatusLabel:Set("Status: No NPCs found nearby.")
                clearMovement()
                task.wait(1)
            end
            
        elseif state == "FIGHT" then
            if dodges > 0 then
                StatusLabel:Set("Status: Dodging! ("..dodges.." left)")
                vim:SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, "E", false, game)
                task.wait(0.3)
                
                while getDodgeCount() > 0 and getgenv().AutoKen do
                    vim:SendKeyEvent(true, "Space", false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, "Space", false, game)
                    task.wait(0.1)
                end
            end
            
            -- Immediately fly up when dodges hit 0
            if getDodgeCount() == 0 and getgenv().AutoKen then
                state = "FLY_UP"
            end
            
        elseif state == "FLY_UP" then
            StatusLabel:Set("Status: Out of dodges! Flying UP smoothly!")
            local targetPos = Vector3.new(hrp.Position.X, hrp.Position.Y + flyHeight, hrp.Position.Z)
            flyTo(targetPos, 60, 3) -- Fly up for max 3 seconds
            
            -- Lock in place in the sky
            clearMovement()
            local bp = Instance.new("BodyPosition")
            bp.Name = "HoverBP"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.Position = hrp.Position
            bp.Parent = hrp
            
            if getgenv().AutoKen then
                state = "HOVER"
            end
            
        elseif state == "HOVER" then
            StatusLabel:Set("Status: Hovering safely. Dodges: "..dodges.."/"..waitThreshold.." needed.")
            
            local bp = hrp:FindFirstChild("HoverBP")
            if bp then
                bp.Position = Vector3.new(hrp.Position.X, bp.Position.Y, hrp.Position.Z)
            end
            
            if dodges >= waitThreshold then
                StatusLabel:Set("Status: Dodges refilled! Diving back in...")
                clearMovement()
                state = "FIND_NPC"
            end
        end
    end
end)