-- ============================================
-- Untitled Boxing Game | Auto Dodge + Anti-AFK
-- Auto Dodge by CDHW/Kohrynth
-- Anti-AFK integrated
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local RS = RunService

-- ============================================
-- AUTO ANTI-AFK (ALWAYS ON)
-- ============================================
player.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ============================================
-- AUTO DODGE (CDHW/Kohrynth)
-- ============================================
local lastPerfect

-- Clean up previous connections
if getgenv().dodge then
    getgenv().dodge:Disconnect()
end

if getgenv().dodgeChar then
    getgenv().dodgeChar:Disconnect()
end

local function getState()
    local states = game.Workspace:FindFirstChild("States")

    if states then
        return states:FindFirstChild(player.Name)
    end
end

local function dodge()
    local character = player.Character

    if not character then
        return
    end

    local perfect = character:GetAttribute("Perfect")

    if perfect == nil or perfect == lastPerfect then
        return
    end

    local direction = character:GetAttribute("NeededDirection")

    if direction ~= "Left" and direction ~= "Right" and direction ~= "Backward" and direction ~= "Forward" then
        return
    end

    local state = getState()

    if not state then
        return
    end

    local occupied = state:FindFirstChild("Occupied")

    if not occupied then
        return
    end

    local locked = occupied:FindFirstChild("LockedOn")
    local dashing = occupied:FindFirstChild("Dashing")

    if not locked or not locked.Value then
        return
    end

    if dashing and dashing.Value then
        return
    end

    local enemy = locked.Value

    if enemy:GetAttribute("IsFeinting") == true or enemy:GetAttribute("LocalIsFeinting") == true then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local eroot = enemy:FindFirstChild("HumanoidRootPart")

    if root and eroot and (root.Position - eroot.Position).Magnitude > 7 then
        return
    end

    local events = game.ReplicatedStorage:FindFirstChild("Events")
    local dash = events and events:FindFirstChild("ForceDash")

    if not dash then
        return
    end

    lastPerfect = perfect

    dash:Fire({Direction = direction})

    RS.Heartbeat:Once(function()
        local state = getState()
        local occupied = state and state:FindFirstChild("Occupied")
        local dashing = occupied and occupied:FindFirstChild("Dashing")

        if player.Character == character and character:GetAttribute("Perfect") == perfect and (not dashing or dashing.Value == false) then
            dash:Fire({Direction = direction})
        end
    end)

    RS.Heartbeat:Once(function()
        local state = getState()
        local occupied = state and state:FindFirstChild("Occupied")
        local dashing = occupied and occupied:FindFirstChild("Dashing")

        if player.Character == character and character:GetAttribute("Perfect") == perfect and (not dashing or dashing.Value == false) then
            dash:Fire({Direction = direction})
        end
    end)
end

-- Start Auto Dodge
getgenv().dodge = RS.Heartbeat:Connect(function()
    if player.Character then
        dodge()
    end
end)

-- Reset on respawn
getgenv().dodgeChar = player.CharacterAdded:Connect(function()
    lastPerfect = nil
end)

print("✅ Auto Dodge + Anti-AFK Loaded!")
print("   🥊 Auto Dodge: ACTIVE (CDHW/Kohrynth)")
print("   🤖 Anti-AFK: ACTIVE (always on)")
