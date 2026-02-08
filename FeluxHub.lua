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