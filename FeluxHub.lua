-- =====================================================
-- CLEANUP SYSTEM
-- =====================================================
if getgenv().fishingStart false
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
    for _, name in pairs(FELUX_HUB) do
        if v.Name == name then v:Destroy() end
    end
end

for _, v in pairs(CoreGui:GetDescendants()) do
    if v:IsA("TextLabel") and v.Text == "Felux" then
        
        local container = v
        
        for i = 0.8, 8 do
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
-- VARIABEL & REMOTE
-- =====================================================
getgenv().fishingStart = false
local legit = false
local instant = false
local superInstant = true 
local blatant = true

local args = {-1.233, 1, workspace:GetServerTimeNow()}
local delayTime = 0.56   
local delayCharge = 1.15 
local delayReset = 0.2 

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
    VFXRemoved = { Active = false, Backuplighting = {} },
    DestroyerActive = { Active = false, Backiplighting = {} },
    PopupDestroyed = false,
    AutoSell = { Active = false, Backuplighting = {} },
        TimeActive = false,
        TimeInterval = 50,
        IsSelling = false
    },
    local args = {"Wind,Cloudy,Storm"}
game:GetService("ReplicatedStorage").RF/PurchaseWeatherEvent:InvokeServer(unpack(args))
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

local WindUI = -
-- =====================================================
-- UTILTY TELEPORT MENU
-- =====================================================
local Waypoints = {
    ["Fisherman Island"]    = Vector3.new(-33, 10, 2770),
    ["Traveling Merchant"]  = Vector3.new(-135, 2, 2764),
    ["Kohana"]              = CFrame.new(-604, 2, 546) * CFrame.Angles(0, math.rad(90), 0),
    ["Kohana Lava"]         = CFrame.new(-592, 59, 127) * CFrame.Angles(0, math.rad(75), 0),
    ["Esoteric Island"]     = Vector3.new(1991, 6, 1390),
    ["Esoteric Depths"]     = CFrame.new(3243, -1302, 1404) * CFrame.Angles(0, math.rad(160), 0),
    ["Tropical Grove"]      = CFrame.new(-2136, 53, 3631) * CFrame.Angles(0, math.rad(120), 0),
    ["Coral Reef"]          = Vector3.new(-3138, 4, 2132),
    ["Weather Machine"]     = Vector3.new(-1517, 3, 1910),
    ["Sisyphus Statue"]     = CFrame.new(-3657, -134, -963) * CFrame.Angles(0, math.rad(100), 0),
    ["Treasure Room"]       = Vector3.new(-3599, -276, -1641),
    ["Ancient Jungle"]      = CFrame.new(1483, 11, -302) * CFrame.Angles(0, math.rad(0), 0),
    ["Ancient Ruin"]        = Vector3.new(6067, -586, 4714),
    ["Sacred Temple"]       = Vector3.new(1498, -22, -640),
    ["Crater Island"]       = CFrame.new(1015, 15, 5097) * CFrame.Angles(0, math.rad(140), 0),
    ["Underground Cellar"]     = Vector3.new(2135, -91, -700),
}

local function TeleportTo(targetPos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        HRP.AssemblyLinearVelocity = Vector3.new(0,0,0)
        
        -- Kita buat variable offset untuk tinggi (supaya tidak nyangkut di tanah)
        local heightOffset = Vector3.new(0, 3, 0)

        if typeof(targetPos) == "Vector3" then
            -- Jika data cuma Vector3, buat CFrame baru (rotasi default 0)
            HRP.CFrame = CFrame.new(targetPos + heightOffset)
        elseif typeof(targetPos) == "CFrame" then
            -- Jika data sudah CFrame (ada rotasinya), pakai langsung + tingginya
            HRP.CFrame = targetPos + heightOffset
        end
    end
end
-- ==========================================
-- AUTO WEATHER v4 — Ultra Light + Stable
-- ==========================================

local RS = game:GetService("ReplicatedStorage")
local Replion = require(RS.Packages.Replion)

local EventsReplion = Replion.Client:WaitReplion("Events")

local PurchaseWeather = RS
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")
	:WaitForChild("RF/PurchaseWeatherEvent")

-- cache connection
local WeatherConn

-- cek apakah weather masih aktif di WeatherMachine
local function IsWeatherActive(Wind,Cloudy,Storm)
	local list = EventsReplion:Get("WeatherMachine")
	if not list then return false end

	for _, v in ipairs(list) do
		if v == name then
			return true
		end
	end
	return false
end

-- beli ulang jika cuaca habis
local function WeatherUpdated()
	local selected = SettingsState.AutoWeather.SelectedList
	if not selected then return end

	local activeList = EventsReplion:Get("WeatherMachine") or {}

	for _, weather in ipairs(selected) do
		if not IsWeatherActive(weather) then
			warn("[AUTO WEATHER] Purchasing:", weather)
			pcall(function()
				PurchaseWeather:InvokeServer(weather)
			end)
			task.wait(0.2)
		end
	end
end

-- start mode
function StartAutoWeather()
	if not SettingsState.AutoWeather.Active then return end

	warn("===== WEATHER SNIFFER ARMED v4 =====")

	-- disconnect old
	if WeatherConn then
		WeatherConn:Disconnect()
	end

	-- listen perubahan state replion WeatherMachine
	WeatherConn = EventsReplion:OnChange("WeatherMachine", function(newValue)
		warn("[SNIFF] WeatherMachine Changed =", newValue)
		task.defer(WeatherUpdated)
	end)

	-- initial scan
	task.defer(WeatherUpdated)
end

-- stop mode
function StopAutoWeather()
	if WeatherConn then
		WeatherConn:Disconnect()
		WeatherConn = nil
	end

	warn("[AUTO WEATHER] Disabled")
end

-- =====================================================
-- AUTO SELL MODE
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

TabSell:Toggle({ Title = "Auto Sell (Time)", Desc = "Safe Pauses Fishing to Sell", Icon = "timer", Value = false, Callback = function(state) SettingsState.AutoSell.TimeActive = state; if state then StartAutoSellLoop(); WindUI:Notify({Title = "Auto Sell", Content = "Loop Started", Duration = 2}) else SettingsState.AutoSell.IsSelling = false; WindUI:Notify({Title = "Auto Sell", Content = "Loop Stopped", Duration = 2}) end end })
TabSell:Input({
    Title = "Sell Interval (Seconds)",
    Desc = "Time between sells",
    Value = "500",
    Callback = function(text)
        -- hanya angka bulat
        if not text:match("^%d+$") then
            SettingsState.AutoSell.TimeInterval = 500
            return "50"
        end

        local num = tonumber(text)
        if not num then
            SettingsState.AutoSell.TimeInterval = 500
            return "50"
        end

        num = math.clamp(math.floor(num), 10, 300)
        SettingsState.AutoSell.TimeInterval = num
        return tostring(num)
    end
})
TabSell:Button({ Title = "Sell Now", Desc = "Sell All Items Immediately", Icon = "trash-2", Callback = function() task.spawn(function() SettingsState.AutoSell.IsSelling = true; task.wait(0.2); pcall(function() SellAll:InvokeServer() end); WindUI:Notify({Title = "Sell All", Content = "Sold!", Duration = 2}); task.wait(0.5); SettingsState.AutoSell.IsSelling = false end) end })
-- =====================================================
-- FITUR FPS BOOST & DISABLE VFX
-- =====================================================
local function ToggleFPSBoost(state)
    if state then
        pcall(function()
            settings().Rendering.QualityLevel = 0.8
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
local WATER_OFFSET = 0.2 -- tinggi berdiri di atas air

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
-- =====================================================
-- BAGIAN 1: FPS
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
-- =====================================================
-- BAGIAN 2: FPS
-- =====================================================
local fps = 0
local frameCount = 0
local lastTick = os.clock()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()

    if now - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = now
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Config = {
    Position = UDim2.new(1, -130, 0, 80),
    Size = UDim2.new(0, 120, 0, 50),
    BackgroundColor = Color3.fromRGB(18, 18, 24),
    BackgroundTransparency = 0.15,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(160, 160, 175),
    BorderColor = Color3.fromRGB(55, 55, 70),

    DelayBeforeShow = 3.5, 

    Duration = 5,          

}

local Panel = {}
Panel.__index = Panel

local activeNotifications = {} 

local connection = nil
local updateConnection = nil

function Panel:Init(customConfig)
    if customConfig then
        for key, value in pairs(customConfig) do
            Config[key] = value
        end
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Notification_Panel"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 999
    self.ScreenGui.Parent = CoreGui

    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.AnchorPoint = Vector2.new(1, 0)
    self.Container.Position = Config.Position
    self.Container.Size = Config.Size
    self.Container.BackgroundColor3 = Config.BackgroundColor
    self.Container.BackgroundTransparency = Config.BackgroundTransparency
    self.Container.BorderSizePixel = 0
    self.Container.Parent = self.ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Container

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.BorderColor
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = self.Container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = self.Container

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = self.Container

    self:CreateRow("Notification", "", 1, true)

    self.CountLabel = self:CreateRow("Notification:", "0", 2)

    self:MakeDraggable()

    self:HookRemote()

    self:StartLoop()

    return self
end

function Panel:CreateRow(label, defaultValue, order, isTitle)
    local row = Instance.new("Frame")
    row.Name = label
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = self.Container

    if isTitle then
        local titleText = Instance.new("TextLabel")
        titleText.Name = "Title"
        titleText.Size = UDim2.new(1, 0, 1, 0)
        titleText.BackgroundTransparency = 1
        titleText.Font = Enum.Font.GothamBold
        titleText.Text = label
        titleText.TextColor3 = Config.TextColor
        titleText.TextSize = 12
        titleText.TextXAlignment = Enum.TextXAlignment.Center
        titleText.Parent = row
        return nil
    end

    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(0, 55, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Font = Enum.Font.GothamBold
    labelText.Text = label
    labelText.TextColor3 = Config.TextMuted
    labelText.TextSize = 11
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = row

    local valueText = Instance.new("TextLabel")
    valueText.Name = "Value"
    valueText.Size = UDim2.new(1, -55, 1, 0)
    valueText.Position = UDim2.new(0, 55, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Font = Enum.Font.GothamBold
    valueText.Text = defaultValue
    valueText.TextColor3 = Config.TextColor
    valueText.TextSize = 13
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = row

    return valueText
end

function Panel:AddNotification()
    local now = tick()
    local showTime = now + Config.DelayBeforeShow
    local hideTime = showTime + Config.Duration

    table.insert(activeNotifications, {
        showAt = showTime,
        hideAt = hideTime
    })
end

function Panel:StartLoop()
    if updateConnection then updateConnection:Disconnect() end

    updateConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        local count = 0
        local cleanList = {}

        for _, notif in ipairs(activeNotifications) do

            if now < notif.hideAt then
                table.insert(cleanList, notif)

                if now >= notif.showAt then
                    count = count + 1
                end
            end
        end

        activeNotifications = cleanList
        if self.CountLabel then
            self.CountLabel.Text = tostring(count)
        end
    end)
end

function Panel:HookRemote()
    local remote = nil
    local LocalPlayer = game:GetService("Players").LocalPlayer

    local function findRemote(parent, targetName)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("RemoteEvent") and string.find(child.Name, targetName) then
                return child
            end
        end
        return nil
    end

    local function isLocalPlayerEvent(...)
        local args = {...}
        for _, arg in pairs(args) do
            if typeof(arg) == "Instance" then
                if arg:IsA("Player") and arg ~= LocalPlayer then return false end
                if arg:IsA("Model") and arg ~= LocalPlayer.Character then
                    local player = game:GetService("Players"):GetPlayerFromCharacter(arg)
                    if player and player ~= LocalPlayer then return false end
                end
            end
        end
        return true
    end

    remote = findRemote(ReplicatedStorage, "CaughtFishVisual")

    if not remote then
         pcall(function()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            if packages then
                local idx = packages:FindFirstChild("_Index")
                if idx then
                    for _, folder in pairs(idx:GetChildren()) do
                        if string.find(folder.Name, "sleitnick_net") and folder:FindFirstChild("net") then
                            remote = folder.net:FindFirstChild("RE/CaughtFishVisual")
                            if remote then break end
                        end
                    end
                end
            end
        end)
    end

    if remote then
        connection = remote.OnClientEvent:Connect(function(...)
            if isLocalPlayerEvent(...) then
                self:AddNotification()
            end
        end)
        print("[Notification Panel] Hooked to " .. remote:GetFullName())
    else
        warn("[Notification Panel] Could not find CaughtFishVisual remote")
    end
end

function Panel:MakeDraggable()
    local dragging = false
    local dragStart, startPos
    self.Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Panel:Toggle()
    if self.Container then self.Container.Visible = not self.Container.Visible end
end

function Panel:Destroy()
    if connection then connection:Disconnect() end
    if updateConnection then updateConnection:Disconnect() end
    if self.ScreenGui then self.ScreenGui:Destroy() end
    activeNotifications = {}
end

Panel:Init()

return Panel

   
1
    
-- =====================================================
-- DISABLE 3D RENDRING
-- =====================================================
local RunService = game:GetService("RunService")

local NoRender3D = {
    Active = false,
    Supported = typeof(RunService.Set3dRenderingEnabled) == "function"
}

function NoRender3D:Enable()
    if self.Active or not self.Supported then return end
    pcall(function()
        RunService:Set3dRenderingEnabled(false)
    end)
    self.Active = true
end

function NoRender3D:Disable()
    if not self.Active or not self.Supported then return end
    pcall(function()
        RunService:Set3dRenderingEnabled(true)
    end)
    self.Active = false
end