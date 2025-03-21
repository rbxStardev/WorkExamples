local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local database = DataStoreService:GetDataStore("TestData")
local sessionData = {}

local function playerJoined(player)
	local dataFolder = Instance.new("Folder")
	dataFolder.Name = "Data"

	local currency = Instance.new("NumberValue")
	currency.Name = "Currency"
	currency.Value = 10
	currency.Parent = dataFolder
	
	local playerLoaded = Instance.new("BoolValue")
	playerLoaded.Name = "PlayerLoaded"
	playerLoaded.Value = false
	playerLoaded.Parent = player

	local success = nil
	local playerData = nil
	local attempt = 1

	repeat
		success, playerData = pcall(function()
			return database:GetAsync(player.UserId)
		end)

		attempt += 1
		if not success then
			warn(playerData)
			task.wait(2.5)
		end
	until success or attempt == 5

	if success then
		print("Connected to database")
		playerData = playerData or {
			Data = {
				Currency = 10
			}
		}
		sessionData[player.UserId] = playerData

		sessionData[player.UserId].Data = sessionData[player.UserId].Data or {}
		local data = sessionData[player.UserId].Data
		
		data.Currency = data.Currency or 10
	else
		warn("Unable to get data for: "..player.Name)
		player:Kick("Unable to load your data, rejoin please.")
		return
	end

	currency.Value = sessionData[player.UserId].Data.Currency

	currency.Changed:Connect(function()
		sessionData[player.UserId].Data.Currency = currency.Value
	end)

	dataFolder.Parent = player
	playerLoaded.Value = true
	
end

Players.PlayerAdded:Connect(playerJoined)

local function playerLeaving(player)
	if sessionData[player.UserId] then
		local success = nil
		local errorMsg = nil
		local attempt = 1

		repeat
			success, errorMsg = pcall(function()
				database:SetAsync(player.UserId, sessionData[player.UserId])
			end)

			attempt += 1
			if not success then
				warn(errorMsg)
				task.wait(2.5)
			end
		until success or attempt == 5

		if success then
			print("Data Saved for player: "..player.Name)
		else
			warn("Couldn't save data for player: "..player.Name)
		end
	end
end

Players.PlayerRemoving:Connect(playerLeaving)

local function serverShutdown()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			playerLeaving(player)
		end)
	end
end

game:BindToClose(serverShutdown)
