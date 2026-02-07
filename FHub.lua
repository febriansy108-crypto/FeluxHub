==============================
-- CLEAN UP SYSTEM
==============================
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
==============================
-- VARIABLE + REMOTE
==============================
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
==============================
-- AUTO SELL FEATURE
==============================
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
