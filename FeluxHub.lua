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
-- CLEANUP SYSTEM
-- =====================================================

