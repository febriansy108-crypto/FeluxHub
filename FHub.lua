-- =====================================================
-- CLEAN UP SYSTEM
-- =====================================================

if getgenv().fishingStart then
    getgenv().fishingStart = false
    task.wait(0.5)
end

local CoreGui = game:GetService("CoreGui")
local GUI_NAMES = {
    Main = "Felux_Fishing_UI",
    Mobile = "Felux_Mobile_Button",
    Coords = "Felux_Coords_HUD"
}

for _, v in pairs(CoreGui:GetChildren()) do
    for _, name in pairs(GUI_NAMES) do
        if v.Name == name then v:Destroy() end
    end
end

for _, v in pairs(CoreGui:GetDescendants()) do
    if v:IsA("FeluxHub | Free") and v.Text == "Felux" then
        
        local container = v
        
        for i = 1, 10 do
            -- Cegah nil edge cases
            if typeof(container) ~= "Instance" then 
                break 
            end

            local parent = container.Parent
            if not parent then 
                break 
            end

            container = parent

            if typeof(container) == "Instance" and container:IsA("ScreenGui") then
                container:Destroy()
                break
            end
        end
    end
end

-- =====================================================
-- VARIABLE + REMOTE
-- =====================================================

getgenv().fishingStart = false
local legit = false
local instant = false
local superInstant = true 
local blatant = true 

local args = {-1.230, 1, workspace:GetServerTimeNow()}
local delayTime = 0.54  
local delayCharge = 1.14 
local delayReset = 0.19

local rs = game:GetService("ReplicatedStorage")
local net = rs.Packages["_Index"]["sleitnick_net@0.2.0"].net

-- Remote Definitions
local ChargeRod    = net["RF/ChargeFishingRod"]
local RequestGame  = net["RF/RequestFishingMinigameStarted"]
local CompleteGame = net["RF/CatchFishCompleted"]
local CancelInput  = net["RF/CancelFishingInputs"]
local SellAll      = net["RF/SellAllItems"] 
local EquipTank    = net["RF/EquipOxygenTank"]
local UpdateRadar  = net["RF/UpdateFishingRadar"]

local SettingsState = { 
    FPSBoost = { Active = false, BackupLighting = {} }, 
    VFXRemoved = false,
    DestroyerActive = false,
    PopupDestroyed = false,
    AutoSell = {
        TimeActive = false,
        TimeInterval = 60,
        IsSelling = false
    },
    AutoWeather = {
        Active = false,
        Targets = {} 
    },
    PosWatcher = { Active = false, Connection = nil },
    WaterWalk = { Active = false, Part = nil, Connection = nil },
    AnimsDisabled = { Active = false, Connections = {} },
    AutoEventDisco = { Active = false },
    AutoFavorite = {
        Active = false,
        Rarities = {}
    },
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local WindUI

-- =====================================================
-- AUTO SELL FEATURE
-- =====================================================

local function StartAutoSellLoop()
    task.spawn(function()
        print("💰 Auto Sell: BACKGROUND MODE STARTED")
        while SettingsState.AutoSell.TimeActive do
            for i = 1, SettingsState.AutoSell.TimeInterval do
                if not SettingsState.AutoSell.TimeActive then return end
                task.wait(1)
            end
            task.spawn(function()
                pcall(function() SellAll:InvokeServer() end)
            end)
        end
    end)
end

-- =====================================================
-- ⚙️ BAGIAN 6: FITUR LAIN
-- =====================================================

local function ToggleFPSBoost(state)
    if state then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
        end)
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.Plastic; v.CastShadow = false end
        end
    end
end

-- local function ExecuteRemoveVFX()
--     local function KillVFX(obj)
--         if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
--             obj.Enabled = false
--             obj.Transparency = NumberSequence.new(1)
--         elseif obj:IsA("Explosion") then obj.Visible = false end
--     end
--     for _, v in pairs(game:GetDescendants()) do pcall(function() KillVFX(v) end) end
--     workspace.DescendantAdded:Connect(function(child)
--         task.wait()
--         pcall(function() 
--             KillVFX(child) 
--             for _, gc in pairs(child:GetDescendants()) do KillVFX(gc) end 
--         end)
--     end)
-- end

-- =====================================================
-- DISABLE DIVE & THROW VFX (FINAL FIX)
-- Reason: VFX depth is NOT flat → must scan ancestors
-- =====================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXFolder = ReplicatedStorage:FindFirstChild("VFX")

local DiveThrowVFX = {
    Active = false,
    Connections = {}
}

---------------------------------------------------------------------
-- Apply handler to matching VFX only
---------------------------------------------------------------------
local function Apply(handler)
    for _, obj in ipairs(VFXFolder:GetDescendants()) do
        if HasDiveOrThrowAncestor(obj) then
            handler(obj)
        end
    end
end

---------------------------------------------------------------------
-- ENABLE
---------------------------------------------------------------------
function EnableDiveThrowVFX()
    if DiveThrowVFX.Active or not VFXFolder then return end
    DiveThrowVFX.Active = true

    -- Existing
    Apply(DisableVisual)

    -- Future spawned
    DiveThrowVFX.Connections[#DiveThrowVFX.Connections + 1] =
        VFXFolder.DescendantAdded:Connect(function(child)
            task.wait()
            if DiveThrowVFX.Active and HasDiveOrThrowAncestor(child) then
                DisableVisual(child)
            end
        end)
end

---------------------------------------------------------------------
-- DISABLE / RESTORE
---------------------------------------------------------------------
function DisableDiveThrowVFX()
    if not DiveThrowVFX.Active or not VFXFolder then return end
    DiveThrowVFX.Active = false

    Apply(RestoreVisual)

    for _, conn in ipairs(DiveThrowVFX.Connections) do
        conn:Disconnect()
    end
    table.clear(DiveThrowVFX.Connections)
end



local function ExecuteDestroyPopup()
    local target = PlayerGui:FindFirstChild("Small Notification")
    if target then target:Destroy() end
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "Small Notification" then
            task.wait() 
            child:Destroy()
        end
    end)
end

local function StartAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    if getconnections then
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then conn:Disable() elseif conn.Disconnect then conn:Disconnect() end
        end
    end
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ============================================
-- WALK ON WATER (STABLE / NO RAYCAST)
-- ============================================

local WATER_Y_LEVEL = nil
local WATER_OFFSET = 0.1 -- tinggi berdiri di atas air

local function DetectWaterLevel(hrp)
    -- asumsi: player mengaktifkan saat dekat / di atas air
    return hrp.Position.Y - 2
end

local function ToggleWaterWalk(state)
    SettingsState.WaterWalk.Active = state

    if state then
        if SettingsState.WaterWalk.Part then return end

        local char = Players.LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- DETECT WATER LEVEL ONCE
        WATER_Y_LEVEL = DetectWaterLevel(hrp)

        local platform = Instance.new("Part")
        platform.Name = "UQiLL_WaterPlatform"
        platform.Size = Vector3.new(18, 1, 18)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.Material = Enum.Material.SmoothPlastic
        platform.Parent = Workspace

        SettingsState.WaterWalk.Part = platform

        SettingsState.WaterWalk.Connection = RunService.Heartbeat:Connect(function()
            local charNow = Players.LocalPlayer.Character
            if not charNow then return end

            local hrpNow = charNow:FindFirstChild("HumanoidRootPart")
            if not hrpNow then return end

            -- Y DIKUNCI, X/Z IKUT PLAYER
            platform.CFrame = CFrame.new(
                hrpNow.Position.X,
                WATER_Y_LEVEL + WATER_OFFSET,
                hrpNow.Position.Z
            )
        end)

    else
        if SettingsState.WaterWalk.Connection then
            SettingsState.WaterWalk.Connection:Disconnect()
            SettingsState.WaterWalk.Connection = nil
        end

        if SettingsState.WaterWalk.Part then
            SettingsState.WaterWalk.Part:Destroy()
            SettingsState.WaterWalk.Part = nil
        end

        WATER_Y_LEVEL = nil
    end
end


local function ToggleAnims(state)
    SettingsState.AnimsDisabled.Active = state
    
    local function StopAll()
        local Char = Players.LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            local Hum = Char.Humanoid
            local Animator = Hum:FindFirstChild("Animator")
            if Animator then
                for _, track in pairs(Animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
    end

    if state then
        StopAll()
        local function HookChar(char)
            local hum = char:WaitForChild("Humanoid")
            local animator = hum:WaitForChild("Animator")
            local conn = animator.AnimationPlayed:Connect(function(track)
                if SettingsState.AnimsDisabled.Active then track:Stop() end
            end)
            table.insert(SettingsState.AnimsDisabled.Connections, conn)
        end

        if Players.LocalPlayer.Character then HookChar(Players.LocalPlayer.Character) end
        local conn2 = Players.LocalPlayer.CharacterAdded:Connect(HookChar)
        table.insert(SettingsState.AnimsDisabled.Connections, conn2)
    else
        for _, conn in pairs(SettingsState.AnimsDisabled.Connections) do
            conn:Disconnect()
        end
        SettingsState.AnimsDisabled.Connections = {}
    end
end
