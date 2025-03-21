local LevelSystem = {}

LevelSystem.BaseExp = 120
LevelSystem.ExpMultiplier = 1.3

function LevelSystem.CalculateExpToNextLevel(level)
	return math.floor((LevelSystem.BaseExp * level) * LevelSystem.ExpMultiplier)
end

function LevelSystem.Initialize(player)
	local stats = player:WaitForChild("Data"):WaitForChild("Stats")
	local level = stats:WaitForChild("Level")
	local exp = stats:WaitForChild("Exp")
	local expNext = stats:WaitForChild("ExpNext")

	expNext.Value = LevelSystem.CalculateExpToNextLevel(level.Value)

	LevelSystem.CheckLevelUp(player)

	exp.Changed:Connect(function()
		LevelSystem.CheckLevelUp(player)
	end)
end

function LevelSystem.CheckLevelUp(player)
	local statsFolder = player:WaitForChild("Data"):WaitForChild("Stats")
	local level = statsFolder:WaitForChild("Level")
	local exp = statsFolder:WaitForChild("Exp")
	local expNext = statsFolder:WaitForChild("ExpNext")

	while exp.Value >= expNext.Value do
		exp.Value = exp.Value - expNext.Value
		level.Value += 1
		expNext.Value = LevelSystem.CalculateExpToNextLevel(level.Value)
	end
end

return LevelSystem
