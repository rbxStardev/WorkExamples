local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local gameSettings = ServerStorage.GameConfiguration

local intermissionTime = gameSettings.IntermissionTime
local roundTime = gameSettings.RoundTime
local minPlayers = gameSettings.MinimumPlayers
local scoreMultiplier = gameSettings.ScoreMultiplier

local maps = ReplicatedStorage.Maps:GetChildren()

local currentTarget = nil
local roundInProgress = false
local currentMap = nil
local votingInProgress = false
local votes = {}

local remotes = ReplicatedStorage:FindFirstChild("Remotes")

local mapVoteRemote = remotes:FindFirstChild("MapVote")

local hintModule = require(script.HintModule)

local possibleHints = {"Outline", "Fill", "Particle"}

local function hint()
	if currentTarget == nil then return end
	local chosenHint = possibleHints[math.random(1, #possibleHints)]
	if chosenHint == "Outline" then
		hintModule.Outline(currentTarget)
		game.Workspace:SetAttribute("Hint", "The suspect is outlined!")
	elseif chosenHint == "Fill" then
		hintModule.Fill(currentTarget)
		game.Workspace:SetAttribute("Hint", "The suspect has a slightly transparent fill color of red!")
	elseif chosenHint == "Particle" then
		hintModule.Particle(currentTarget)
		game.Workspace:SetAttribute("Hint", "There are particles coming out of the suspect!")
	end
end

local function playerWin(player, target)
	local leaderstats = player:FindFirstChild("leaderstats")
	local score = leaderstats:FindFirstChild("Score")
	local wins = leaderstats:FindFirstChild("Wins")
	
	score.Value += (10 * scoreMultiplier.Value)
	wins.Value += 1
	
	game.Workspace:SetAttribute("Status", player.Name.." found the suspect: "..target.Name)
	game.Workspace:SetAttribute("Hint", "There are no hints yet.")
end

local function gameTarget(map)
	local playersFolder = map:FindFirstChild("Players")
	if not playersFolder then return end
	local players = playersFolder:GetChildren()
	local randomPlayer = players[math.random(1, #players)]
	
	currentTarget = randomPlayer
	currentTarget:SetAttribute("Found", false)
	hint()
	
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Name = "ClickDetector"
	clickDetector.Parent = randomPlayer
	
	print(randomPlayer.HumanoidRootPart.Position)
	
	clickDetector.MouseClick:Connect(function(winner)
		if roundInProgress == false then return end
		
		playerWin(winner, currentTarget)
		
		local success, high = pcall(function()
			 return currentTarget:FindFirstChildWhichIsA("Highlight")
		end)
		
		if high then high:Destroy() end
		
		local highlight = Instance.new("Highlight")
		highlight.Parent = currentTarget
		currentTarget:SetAttribute("Found", true)
		
		roundInProgress = false
	end)
end

local function getRandomMap()
	return maps[math.random(1, #maps)]
end

local function teleportPlayersToMap(map)
	local spawnsFolder = map:FindFirstChild("Spawns")
	if not spawnsFolder then return end
	local spawns = spawnsFolder:GetChildren()
	local players = Players:GetPlayers()
	for i, player in players do
		if not player.Character or player.PlayerLoaded.Value == false then return end
		
		local randomSpawn = spawns[math.random(1, #spawns)]
		
		player.Character:PivotTo(randomSpawn.CFrame)
	end
end

local function teleportPlayersToLobby()
	local lobby = game.Workspace:FindFirstChild("Lobby")
	local players = Players:GetPlayers()
	for i, player in players do
		if not player.Character then return end

		player.Character:PivotTo(lobby.Spawn.CFrame * CFrame.new(0,2,0))
	end
end

local function countdown(duration)
	for i=duration, 1, -1 do
		game.Workspace:SetAttribute("Clock", i)
		task.wait(1)
	end
	game.Workspace:SetAttribute("Clock", 0)
end

local function gameCountdown(duration)
	for i=duration, 1, -1 do
		if roundInProgress == false then
			break
		end
		game.Workspace:SetAttribute("Clock", i)
		task.wait(1)
	end
	game.Workspace:SetAttribute("Clock", 0)
end

local function intermission()
	game.Workspace:SetAttribute("Status", "Intermission")
	teleportPlayersToLobby()
	task.wait(5)
	countdown(intermissionTime.Value)
end

local function runGame(map)
	roundInProgress = true
	currentMap = map
	teleportPlayersToMap(map)

	game.Workspace:SetAttribute("Status", "Prepare...")
	gameTarget(map)
	countdown(15)
	game.Workspace:SetAttribute("Status", "Find it!")
	
	gameCountdown(roundTime.Value)
	if currentTarget:GetAttribute("Found") ~= true then
		game.Workspace:SetAttribute("Status", "No one found the suspect.")
	end
	currentTarget = nil
	game.Workspace:SetAttribute("Hint", "There are no hints yet.")
	task.wait(5)
	map:Destroy()
	roundInProgress = false
	currentMap = nil
end

game.Workspace:SetAttribute("Clock", 0)

while true do
	if #Players:GetPlayers() >= minPlayers.Value then
		intermission()
		game.Workspace:SetAttribute("Clock", 0)
		
		workspace:SetAttribute("Status", "Loading Map...")
		
		local randomMap = getRandomMap()
		local newMap = randomMap:Clone()
		newMap.Parent = game.Workspace
		
		task.wait(5)
		
		runGame(newMap)
		game.Workspace:SetAttribute("Clock", 0)
	else
		game.Workspace:SetAttribute("Status", "Waiting for Players...")
		print("no enough players to start game")
		task.wait(5)
	end
end
