-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V7 TRUE FLIGHT ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V7",
   LoadingTitle = "Loading V7 True Flight...",
   LoadingSubtitle = "No Jumping, Pure Flight",
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
               if char.HumanoidRootPart:FindFirstChild("FlyBV") then char.HumanoidRootPart.FlyBV:Destroy() end
               if char.HumanoidRootPart:FindFirstChild("HoverBP") then char.HumanoidRootPart.HoverBP:Destroy() end
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

-- Clean up movement functions
local function clearMovement()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("HoverBP") then hrp.HoverBP:Destroy() end
    end
end

-- Fly horizontally to the NPC (1 stud above ground)
local function flyToNPC(targetPos)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    clearMovement()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = hrp
    
    -- Fly loop
    while getgenv().AutoKen do
        if not hrp or not hrp.Parent then break end
        local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
        if dist < 5 then break end -- Stop when close
        
        -- Calculate direction to fly
        local dir = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit
        bv.Velocity = dir * 50 -- Fly speed
        
        task.wait(0.1)
    end
    bv:Destroy()
end

-- Fly straight UP into the sky
local function flyUp(targetY)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    clearMovement()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 100, 0) -- Fast upward velocity
    bv.Parent = hrp
    
    -- Wait until we reach the target height
    while getgenv().AutoKen and hrp.Position.Y < targetY do
        task.wait(0.1)
    end
    bv:Destroy()
    
    -- Lock in place using BodyPosition
    local bp = Instance.new("BodyPosition")
    bp.Name = "HoverBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.Position = Vector3.new(hrp.Position.X, targetY, hrp.Position.Z)
    bp.Parent = hrp
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
        
        -- If we are on the ground and have 0 dodges, force fly up immediately
        if state == "FIGHT" and dodges == 0 then
            state = "FLY_UP"
        end
        
        if state == "FIND_NPC" then
            local npc = getNearestNPC()
            if npc then
                StatusLabel:Set("Status: Flying to NPC...")
                -- Fly to the NPC, staying exactly 1 stud above their root part
                local targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
                flyToNPC(targetPos)
                
                if getgenv().AutoKen then
                    state = "FIGHT"
                end
            else
                StatusLabel:Set("Status: No NPCs found nearby.")
                task.wait(1)
            end
            
        elseif state == "FIGHT" then
            StatusLabel:Set("Status: Dodging! ("..dodges.." left)")
            
            -- 1. Activate Ken (Press E)
            vim:SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, "E", false, game)
            task.wait(0.3) -- Wait for Ken to activate
            
            -- 2. Spam Space to Dodge ONLY while we still have dodges
            while getDodgeCount() > 0 and getgenv().AutoKen do
                vim:SendKeyEvent(true, "Space", false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, "Space", false, game)
                task.wait(0.1)
            end
            
            if getgenv().AutoKen then
                state = "FLY_UP"
            end
            
        elseif state == "FLY_UP" then
            StatusLabel:Set("Status: Dodges empty. Flying UP!")
            local targetY = hrp.Position.Y + flyHeight
            flyUp(targetY)
            if getgenv().AutoKen then
                state = "HOVER"
            end
            
        elseif state == "HOVER" then
            StatusLabel:Set("Status: Safe in sky. Waiting for "..waitThreshold.." dodges. (Current: "..dodges..")")
            
            -- Keep locking position in case of lag
            local bp = hrp:FindFirstChild("HoverBP")
            if bp then
                bp.Position = Vector3.new(hrp.Position.X, bp.Position.Y, hrp.Position.Z)
            end
            
            if dodges >= waitThreshold then
                StatusLabel:Set("Status: Dodges ready! Diving back in...")
                clearMovement()
                state = "FIND_NPC"
            end
        end
    end
end)