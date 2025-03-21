local QuestR = {}

local function newQuest(questFolder)
	local quest = {}
	quest.__index = quest
	quest.Folder = questFolder

	local completeEvent = Instance.new("BindableEvent")
	local cancelEvent = Instance.new("BindableEvent")

	local watchValue = questFolder["WatchValue"]
	local value = questFolder["Value"]

	function quest.Complete()
		completeEvent:Fire()
		questFolder:Destroy()
	end

	function quest.Cancel()
		cancelEvent:Fire()
		questFolder:Destroy()
	end

	watchValue.Changed:Connect(function()
		print("Quest Progress")
		if watchValue.Value >= value.Value then
			quest.Complete()
		end
	end)

	quest.Completed = completeEvent.Event
	quest.Canceled = cancelEvent.Event

	local self = setmetatable({}, quest)

	return self
end

function QuestR.create(player, questName, Value)
	local questFolder = Instance.new("Folder")
	questFolder.Name = questName

	-- Garante que a pasta "Quests" exista no jogador
	local playerQuests = player:FindFirstChild("Quests")
	if not playerQuests then
		playerQuests = Instance.new("Folder")
		playerQuests.Name = "Quests"
		playerQuests.Parent = player
	end

	-- Define o pai da pasta da quest como a pasta "Quests" do jogador
	questFolder.Parent = playerQuests

	-- Adiciona o valor da quest à pasta
	local questWatchValue = Instance.new("IntValue")
	questWatchValue.Name = "WatchValue"
	questWatchValue.Value = 0
	questWatchValue.Parent = questFolder
	
	local questValue = Instance.new("IntValue")
	questValue.Name = "Value"
	questValue.Value = Value
	questValue.Parent = questFolder
	
	return newQuest(questFolder)
end

return QuestR
