-- [[ PROFESSIONAL BLOX FRUITS OBSERVATION MACRO - V6 CUSTOM THRESHOLD ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "Auto Ken V6",
   LoadingTitle = "Loading V6 Custom Threshold...",
   LoadingSubtitle = "Perfect Loop",
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
           if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("HoverBP") then
               char.HumanoidRootPart.HoverBP:Destroy()
           end
       end
   end,
})

-- Slider now goes from 1 to 12, letting you choose exactly how many dodges to wait for
local DodgeThresholdSlider = MainTab:CreateSlider({
   Name = "Dodges Needed to Dive",
   Range = { 1, 12 },
   Increment = 1,
   Suffix = "Dodges",
   CurrentValue = 3, -- Default to 3 (which is 50% of 6)
   Flag = "DodgeThreshold",
   Callback = function(Value)
       getgenv().DodgeThreshold = Value
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

-- Accurately count physical dodge instances
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

-- Anti-Gravity Hover Anchor
local function hoverAt(pos)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    local bp = hrp:FindFirstChild("HoverBP")
    
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "HoverBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Parent = hrp
    end
    bp.Position = pos
end

local function stopHovering()
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("HoverBP") then
        hrp.HoverBP:Destroy()
    end
end

-- Smooth Glide
local function glideTo(targetPos, duration)
    local char = game.Players.LocalPlayer.Character
    local hrp = char.HumanoidRootPart
    stopHovering()
    
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
end

-- STATE MACHINE
task.spawn(function()
    local state = "FIND_NPC"
    local hoverPos = nil
    
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
                StatusLabel:Set("Status: Gliding to NPC...")
                local targetPos = npc.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
                glideTo(targetPos, 0.3)
                state = "FIGHT"
            else
                StatusLabel:Set("Status: No NPCs found nearby.")
                task.wait(1)
            end
            
        elseif state == "FIGHT" then
            if dodges > 0 then
                StatusLabel:Set("Status: Dodging! ("..dodges.." left)")
                vim:SendKeyEvent(true, "E", false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, "E", false, game)
                task.wait(0.2)
                
                vim:SendKeyEvent(true, "Space", false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, "Space", false, game)
                task.wait(0.1)
            else
                StatusLabel:Set("Status: Out of dodges. Flying to Safe Zone!")
                hoverPos = hrp.Position + Vector3.new(0, flyHeight, 0)
                stopHovering()
                
                -- Quickly fly straight up
                local tween = TweenService:Create(hrp, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {CFrame = CFrame.new(hoverPos)})
                tween:Play()
                tween.Completed:Wait()
                
                state = "HOVER"
            end
            
        elseif state == "HOVER" then
            -- Lock in place in the sky
            if hoverPos then
                hoverAt(hoverPos) 
            end
            
            StatusLabel:Set("Status: Safe in sky. Waiting for "..waitThreshold.." dodges. (Current: "..dodges..")")
            
            if dodges >= waitThreshold then
                StatusLabel:Set("Status: Dodges ready! Diving back in...")
                stopHovering()
                state = "FIND_NPC"
            end
        end
    end
end)