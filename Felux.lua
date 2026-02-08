-- Fishing System Main Script
-- By: [FeluxHub]
-- Version: 1.0

local FishingSystem = {}
FishingSystem.__index = FishingSystem

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

-- Module setup
if not ReplicatedStorage:FindFirstChild("FishingEvents") then
	local fishingEvents = Instance.new("Folder")
	fishingEvents.Name = "FishingEvents"
	fishingEvents.Parent = ReplicatedStorage
	
	local startFishing = Instance.new("RemoteEvent")
	startFishing.Name = "StartFishing"
	startFishing.Parent = fishingEvents
	
	local reelFish = Instance.new("RemoteEvent")
	reelFish.Name = "ReelFish"
	reelFish.Parent = fishingEvents
end

-- Fish data
local fishData = {
	{
		name = "Guppy",
		rarity = "Common",
		minWeight = 0.1,
		maxWeight = 0.5,
		minValue = 5,
		maxValue = 15,
		image = "rbxassetid://1234567890" -- Replace with actual image ID
	},
	{
		name = "Catfish",
		rarity = "Uncommon",
		minWeight = 1.0,
		maxWeight = 5.0,
		minValue = 25,
		maxValue = 50,
		image = "rbxassetid://1234567891"
	},
	{
		name = "Bass",
		rarity = "Rare",
		minWeight = 2.0,
		maxWeight = 8.0,
		minValue = 50,
		maxValue = 100,
		image = "rbxassetid://1234567892"
	},
	{
		name = "Shark",
		rarity = "Legendary",
		minWeight = 50.0,
		maxWeight = 200.0,
		minValue = 500,
		maxValue = 2000,
		image = "rbxassetid://1234567893"
	}
}

-- Fishing spots data
local fishingSpots = {
	{
		name = "Pond",
		position = Vector3.new(0, 0, 0),
		radius = 20,
		fishAvailable = {"Guppy", "Catfish"},
		difficulty = 1
	},
	{
		name = "Lake",
		position = Vector3.new(50, 0, 50),
		radius = 30,
		fishAvailable = {"Guppy", "Catfish", "Bass"},
		difficulty = 2
	},
	{
		name = "Ocean",
		position = Vector3.new(100, 0, 100),
		radius = 50,
		fishAvailable = {"Catfish", "Bass", "Shark"},
		difficulty = 3
	}
}

-- Fishing rods data
local fishingRods = {
	{
		name = "Basic Rod",
		catchRate = 1.0,
		durability = 100,
		value = 0
	},
	{
		name = "Advanced Rod",
		catchRate = 1.5,
		durability = 200,
		value = 1000
	},
	{
		name = "Pro Rod",
		catchRate = 2.0,
		durability = 500,
		value = 5000
	}
}

-- Player data management
local playerData = {}

function FishingSystem:InitializePlayer(player)
	if not playerData[player.UserId] then
		playerData[player.UserId] = {
			currentRod = 1,
			fishCaught = {},
			totalValue = 0,
			isFishing = false,
			currentSpot = nil
		}
		
		-- Create leaderstats
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		local fishCaughtStat = Instance.new("IntValue")
		fishCaughtStat.Name = "Fish Caught"
		fishCaughtStat.Value = 0
		fishCaughtStat.Parent = leaderstats
		
		local totalValueStat = Instance.new("IntValue")
		totalValueStat.Name = "Total Value"
		totalValueStat.Value = 0
		totalValueStat.Parent = leaderstats
		
		local bestFishStat = Instance.new("StringValue")
		bestFishStat.Name = "Best Fish"
		bestFishStat.Value = "None"
		bestFishStat.Parent = leaderstats
	end
end

function FishingSystem:GetFishData(fishName)
	for _, fish in ipairs(fishData) do
		if fish.name == fishName then
			return fish
		end
	end
	return nil
end

function FishingSystem:GetRandomFish(spotDifficulty)
	local availableFish = {}
	
	for _, spot in ipairs(fishingSpots) do
		if spot.difficulty <= spotDifficulty then
			for _, fishName in ipairs(spot.fishAvailable) do
				table.insert(availableFish, fishName)
			end
		end
	end
	
	if #availableFish == 0 then
		return fishData[1].name
	end
	
	local randomIndex = math.random(1, #availableFish)
	return availableFish[randomIndex]
end

function FishingSystem:CalculateCatchTime(fishName, rodIndex, spotDifficulty)
	local fish = self:GetFishData(fishName)
	local rod = fishingRods[rodIndex]
	
	if not fish or not rod then
		return 5
	end
	
	local baseTime = 3
	local difficultyMultiplier = spotDifficulty
	local rarityMultiplier = 1
	
	if fish.rarity == "Uncommon" then
		rarityMultiplier = 1.5
	elseif fish.rarity == "Rare" then
		rarityMultiplier = 2
	elseif fish.rarity == "Legendary" then
		rarityMultiplier = 3
	end
	
	local catchTime = baseTime * difficultyMultiplier * rarityMultiplier / rod.catchRate
	return math.clamp(catchTime, 2, 10)
end

function FishingSystem:StartFishing(player, spotName)
	local userId = player.UserId
	local data = playerData[userId]
	
	if data.isFishing then
		return false, "Already fishing!"
	end
	
	-- Find fishing spot
	local spot = nil
	for _, s in ipairs(fishingSpots) do
		if s.name == spotName then
			spot = s
			break
		end
	end
	
	if not spot then
		return false, "Fishing spot not found!"
	end
	
	-- Check if player is near the spot
	local character = player.Character
	if not character then
		return false, "Character not found!"
	end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false, "HumanoidRootPart not found!"
	end
	
	local distance = (humanoidRootPart.Position - spot.position).Magnitude
	if distance > spot.radius then
		return false, "Too far from fishing spot!"
	end
	
	-- Start fishing
	data.isFishing = true
	data.currentSpot = spotName
	
	-- Get random fish
	local fishName = self:GetRandomFish(spot.difficulty)
	local catchTime = self:CalculateCatchTime(fishName, data.currentRod, spot.difficulty)
	
	-- Notify client
	ReplicatedStorage.FishingEvents.StartFishing:FireClient(player, fishName, catchTime)
	
	-- Create fishing session
	local fishingSession = {
		player = player,
		fishName = fishName,
		startTime = tick(),
		catchTime = catchTime,
		spot = spot
	}
	
	-- Schedule fish catch
	delay(catchTime, function()
		if data.isFishing and playerData[userId] then
			self:CompleteFishing(player, fishingSession)
		end
	end)
	
	return true, "Started fishing!"
end

function FishingSystem:CompleteFishing(player, session)
	local userId = player.UserId
	local data = playerData[userId]
	
	if not data or not data.isFishing then
		return
	end
	
	-- Reset fishing state
	data.isFishing = false
	data.currentSpot = nil
	
	-- Get fish data
	local fish = self:GetFishData(session.fishName)
	if not fish then
		return
	end
	
	-- Calculate fish weight and value
	local weight = math.random(fish.minWeight * 100, fish.maxWeight * 100) / 100
	local value = math.random(fish.minValue, fish.maxValue)
	
	-- Apply rod bonus
	local rod = fishingRods[data.currentRod]
	if rod then
		value = math.floor(value * rod.catchRate)
	end
	
	-- Update player data
	table.insert(data.fishCaught, {
		name = fish.name,
		weight = weight,
		value = value,
		time = os.time(),
		spot = session.spot.name
	})
	
	data.totalValue = data.totalValue + value
	
	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local fishCaughtStat = leaderstats:FindFirstChild("Fish Caught")
		local totalValueStat = leaderstats:FindFirstChild("Total Value")
		local bestFishStat = leaderstats:FindFirstChild("Best Fish")
		
		if fishCaughtStat then
			fishCaughtStat.Value = #data.fishCaught
		end
		
		if totalValueStat then
			totalValueStat.Value = data.totalValue
		end
		
		if bestFishStat then
			-- Find best fish by value
			local bestValue = 0
			local bestFishName = "None"
			
			for _, caughtFish in ipairs(data.fishCaught) do
				if caughtFish.value > bestValue then
					bestValue = caughtFish.value
					bestFishName = caughtFish.name
				end
			end
			
			if bestValue > 0 then
				bestFishStat.Value = bestFishName .. " (" .. bestValue .. ")"
			end
		end
	end
	
	-- Notify player
	ReplicatedStorage.FishingEvents.ReelFish:FireClient(player, {
		success = true,
		fishName = fish.name,
		weight = weight,
		value = value,
		rarity = fish.rarity
	})
	
	-- Update rod durability
	if rod then
		rod.durability = rod.durability - 1
		if rod.durability <= 0 then
			-- Rod broke
			data.currentRod = 1 -- Default to basic rod
			ReplicatedStorage.FishingEvents.RodBroke:FireClient(player, rod.name)
		end
	end
end

function FishingSystem:CancelFishing(player)
	local userId = player.UserId
	local data = playerData[userId]
	
	if data and data.isFishing then
		data.isFishing = false
		data.currentSpot = nil
		
		ReplicatedStorage.FishingEvents.ReelFish:FireClient(player, {
			success = false,
			message = "Fishing cancelled!"
		})
		
		return true
	end
	
	return false
end

function FishingSystem:GetPlayerData(player)
	return playerData[player.UserId]
end

function FishingSystem:GetFishingSpots()
	return fishingSpots
end

function FishingSystem:GetFishingRods()
	return fishingRods
end

function FishingSystem:UpgradeRod(player)
	local userId = player.UserId
	local data = playerData[userId]
	
	if not data then
		return false, "Player data not found!"
	end
	
	local currentRodIndex = data.currentRod
	local nextRodIndex = currentRodIndex + 1
	
	if nextRodIndex > #fishingRods then
		return false, "Already have the best rod!"
	end
	
	local nextRod = fishingRods[nextRodIndex]
	
	-- Check if player has enough money (using leaderstats)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return false, "Leaderstats not found!"
	end
	
	local totalValueStat = leaderstats:FindFirstChild("Total Value")
	if not totalValueStat then
		return false, "Total Value stat not found!"
	end
	
	if totalValueStat.Value < nextRod.value then
		return false, "Not enough money! Need " .. nextRod.value
	end
	
	-- Deduct money and upgrade rod
	totalValueStat.Value = totalValueStat.Value - nextRod.value
	data.currentRod = nextRodIndex
	
	return true, "Upgraded to " .. nextRod.name .. "!"
end

-- Remote event handlers
ReplicatedStorage.FishingEvents.StartFishing.OnServerEvent:Connect(function(player, spotName)
	local success, message = FishingSystem:StartFishing(player, spotName)
	if not success then
		ReplicatedStorage.FishingEvents.ReelFish:FireClient(player, {
			success = false,
			message = message
		})
	end
end)

ReplicatedStorage.FishingEvents.ReelFish.OnServerEvent:Connect(function(player)
	FishingSystem:CancelFishing(player)
end)

-- Player connection handling
Players.PlayerAdded:Connect(function(player)
	FishingSystem:InitializePlayer(player)
	
	-- Clean up on leave
	player.CharacterRemoving:Connect(function()
		FishingSystem:CancelFishing(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	FishingSystem:CancelFishing(player)
	playerData[player.UserId] = nil
end)

return FishingSystem

-- Fishing Client Script
-- Controls UI and client-side fishing mechanics

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Fishing events
local fishingEvents = ReplicatedStorage:WaitForChild("FishingEvents")
local startFishingEvent = fishingEvents:WaitForChild("StartFishing")
local reelFishEvent = fishingEvents:WaitForChild("ReelFish")

-- Create fishing GUI
local fishingGUI = Instance.new("ScreenGui")
fishingGUI.Name = "FishingGUI"
fishingGUI.Parent = playerGui

-- Main fishing frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.7, -100)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = fishingGUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Fishing"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Status text
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -20, 0, 40)
statusText.Position = UDim2.new(0, 10, 0, 50)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Text = "Ready to fish!"
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 16
statusText.Parent = mainFrame

-- Progress bar
local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(1, -20, 0, 20)
progressBar.Position = UDim2.new(0, 10, 0, 100)
progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
progressBar.BorderSizePixel = 0
progressBar.Parent = mainFrame

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(0, 4)
progressBarCorner.Parent = progressBar

local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBar

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(0, 4)
progressFillCorner.Parent = progressFill

-- Fish info
local fishInfo = Instance.new("TextLabel")
fishInfo.Name = "FishInfo"
fishInfo.Size = UDim2.new(1, -20, 0, 40)
fishInfo.Position = UDim2.new(0, 10, 0, 130)
fishInfo.BackgroundTransparency = 1
fishInfo.TextColor3 = Color3.fromRGB(255, 255, 200)
fishInfo.Text = ""
fishInfo.Font = Enum.Font.Gotham
fishInfo.TextSize = 14
fishInfo.Parent = mainFrame

-- Action button
local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.new(0, 120, 0, 40)
actionButton.Position = UDim2.new(0.5, -60, 1, -50)
actionButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
actionButton.Text = "Start Fishing"
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 16
actionButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 4)
buttonCorner.Parent = actionButton

-- Results frame
local resultsFrame = Instance.new("Frame")
resultsFrame.Name = "ResultsFrame"
resultsFrame.Size = UDim2.new(0, 250, 0, 150)
resultsFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
resultsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
resultsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
resultsFrame.BorderSizePixel = 0
resultsFrame.Visible = false
resultsFrame.Parent = fishingGUI

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 8)
resultsCorner.Parent = resultsFrame

local resultsTitle = Instance.new("TextLabel")
resultsTitle.Name = "ResultsTitle"
resultsTitle.Size = UDim2.new(1, 0, 0, 40)
resultsTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
resultsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
resultsTitle.Text = "Fishing Results"
resultsTitle.Font = Enum.Font.GothamBold
resultsTitle.TextSize = 18
resultsTitle.Parent = resultsFrame

local resultsText = Instance.new("TextLabel")
resultsText.Name = "ResultsText"
resultsText.Size = UDim2.new(1, -20, 0, 80)
resultsText.Position = UDim2.new(0, 10, 0, 50)
resultsText.BackgroundTransparency = 1
resultsText.TextColor3 = Color3.fromRGB(255, 255, 255)
resultsText.Text = ""
resultsText.Font = Enum.Font.Gotham
resultsText.TextSize = 16
resultsText.TextWrapped = true
resultsText.Parent = resultsFrame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, -50, 1, -40)
closeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "Close"
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 14
closeButton.Parent = resultsFrame

-- Fishing variables
local isFishing = false
local currentCatchTime = 0
local catchStartTime = 0
local currentFish = ""

-- Function to show fishing GUI
local function showFishingGUI(show)
	mainFrame.Visible = show
end

-- Function to update progress bar
local function updateProgressBar(progress)
	progressFill.Size = UDim2.new(progress, 0, 1, 0)
end

-- Function to show results
local function showResults(success, data)
	if success then
		resultsText.Text = string.format("You caught a %s!\nWeight: %.2f kg\nValue: %d coins\nRarity: %s",
			data.fishName, data.weight, data.value, data.rarity)
		
		-- Color based on rarity
		if data.rarity == "Common" then
			resultsText.TextColor3 = Color3.fromRGB(200, 200, 200)
		elseif data.rarity == "Uncommon" then
			resultsText.TextColor3 = Color3.fromRGB(0, 200, 0)
		elseif data.rarity == "Rare" then
			resultsText.TextColor3 = Color3.fromRGB(0, 150, 255)
		elseif data.rarity == "Legendary" then
			resultsText.TextColor3 = Color3.fromRGB(255, 100, 0)
		end
	else
		resultsText.Text = data.message or "Failed to catch fish!"
		resultsText.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
	
	resultsFrame.Visible = true
end

-- Action button click
actionButton.MouseButton1Click:Connect(function()
	if isFishing then
		-- Cancel fishing
		reelFishEvent:FireServer()
	else
		-- Start fishing (automatically detects nearest spot)
		startFishingEvent:FireServer("Pond") -- Default to Pond, you can implement spot detection
	end
end)

-- Close results button
closeButton.MouseButton1Click:Connect(function()
	resultsFrame.Visible = false
end)

-- Remote event listeners
startFishingEvent.OnClientEvent:Connect(function(fishName, catchTime)
	isFishing = true
	currentFish = fishName
	currentCatchTime = catchTime
	catchStartTime = tick()
	
	statusText.Text = "Fishing..."
	fishInfo.Text = string.format("Fish detected: %s", fishName)
	actionButton.Text = "Cancel"
	actionButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	
	showFishingGUI(true)
end)

reelFishEvent.OnClientEvent:Connect(function(data)
	isFishing = false
	
	if data.success then
		statusText.Text = "Fish caught!"
		showResults(true, data)
	else
		statusText.Text = "Ready to fish!"
		if data.message then
			showResults(false, data)
		end
	end
	
	fishInfo.Text = "start"
	actionButton.Text = "Start Fishing"
	actionButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	updateProgressBar(0)
	
	-- Hide main frame after delay if not showing results
	if not data.success or not resultsFrame.Visible then
		delay(2, function()
			if not isFishing then
				showFishingGUI(false)
			end
		end)
	end
end)

-- Update progress bar while fishing
RunService.RenderStepped:Connect(function()
	if isFishing then
		local elapsed = tick() - catchStartTime
		local progress = math.min(elapsed / currentCatchTime, 1)
		updateProgressBar(progress)
		
		-- Update status text
		local timeLeft = math.max(0, currentCatchTime - elapsed)
		statusText.Text = string.format("Fishing... %.1fs", timeLeft)
		
		-- Visual effect when almost done
		if progress > 0.9 then
			progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		elseif progress > 0.7 then
			progressFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
		else
			progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		end
		
		-- Fish icon animation
		if math.random(1, 20) == 1 then
			fishInfo.Text = string.format("Fish detected: %s (Biting!)", currentFish)
			delay(0.5, function()
				if isFishing then
					fishInfo.Text = string.format("Fish detected: %s", currentFish)
				end
			end)
		end
	end
end)

-- Keybind for fishing (F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		actionButton:Activate()
	end
end)

-- Initialize
showFishingGUI(false)

-- Fishing Map Setup Script
-- Creates fishing spots and visual indicators in the game world

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Check if fishing system exists
if not ReplicatedStorage:FindFirstChild("FishingEvents") then
	warn("FishingSystem not found! Make sure to run FishingSystem.lua first.")
	return
end

-- Fishing spots configuration (same as in main system)
local fishingSpots = {
	{
		name = "Pond",
		position = Vector3.new(0, 0, 0),
		radius = 20,
		fishAvailable = {"Guppy", "Catfish"},
		difficulty = 1,
		color = Color3.fromRGB(0, 100, 200)
	},
	{
		name = "Lake",
		position = Vector3.new(50, 0, 50),
		radius = 30,
		fishAvailable = {"Guppy", "Catfish", "Bass"},
		difficulty = 2,
		color = Color3.fromRGB(0, 150, 255)
	},
	{
		name = "Ocean",
		position = Vector3.new(100, 0, 100),
		radius = 50,
		fishAvailable = {"Catfish", "Bass", "Shark"},
		difficulty = 3,
		color = Color3.fromRGB(0, 50, 150)
	}
}

-- Create fishing spots in the workspace
local function createFishingSpots()
	local fishingSpotsFolder = Instance.new("Folder")
	fishingSpotsFolder.Name = "FishingSpots"
	fishingSpotsFolder.Parent = workspace
	
	for _, spot in ipairs(fishingSpots) do
		-- Create a part to mark the fishing spot
		local spotPart = Instance.new("Part")
		spotPart.Name = spot.name .. "Spot"
		spotPart.Size = Vector3.new(spot.radius * 2, 5, spot.radius * 2)
		spotPart.Position = spot.position + Vector3.new(0, 2.5, 0)
		spotPart.Anchored = true
		spotPart.CanCollide = false
		spotPart.Transparency = 0.7
		spotPart.Color = spot.color
		spotPart.Material = Enum.Material.Neon
		spotPart.Parent = fishingSpotsFolder
		
		-- Add a billboard GUI for the name
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "SpotBillboard"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 10, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = spotPart
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = spot.name .. " (Fishing Spot)"
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = billboard
		
		-- Add a proximity prompt for fishing
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "FishingPrompt"
		prompt.ActionText = "Fish Here"
		prompt.ObjectText = spot.name
		prompt.KeyboardKeyCode = Enum.KeyCode.F
		prompt.MaxActivationDistance = spot.radius
		prompt.HoldDuration = 0
		prompt.Parent = spotPart
		
		-- Prompt trigger
		prompt.Triggered:Connect(function(player)
			local fishingEvents = ReplicatedStorage:FindFirstChild("FishingEvents")
			if fishingEvents then
				local startFishing = fishingEvents:FindFirstChild("StartFishing")
				if startFishing then
					startFishing:FireServer(player, spot.name)
				end
			end
		end)
		
		-- Create water effect
		local water = Instance.new("Part")
		water.Name = "Water"
		water.Size = Vector3.new(spot.radius * 2, 1, spot.radius * 2)
		water.Position = spot.position
		water.Anchored = true
		water.CanCollide = false
		water.Transparency = 0.3
		water.Color = Color3.fromRGB(0, 100, 255)
		water.Material = Enum.Material.Water
		water.Parent = spotPart
		
		print("Created fishing spot: " .. spot.name)
	end
	
	print("Fishing map setup complete!")
end

-- Initialize fishing map
createFishingSpots()

-- Optional: Add decorative elements
local function addDecorations()
	local decorations = ServerStorage:FindFirstChild("FishingDecorations")
	if decorations then
		decorations:Clone().Parent = workspace
	end
end

-- Run decorations if available
addDecorations()