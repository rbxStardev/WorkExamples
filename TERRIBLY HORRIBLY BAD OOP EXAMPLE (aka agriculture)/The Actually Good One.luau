local ServerStorage = game:GetService("ServerStorage")

-- Folder where all tree models are stored
local treesFolder = ServerStorage.Trees

local Tree = {}
Tree.__index = Tree

-- Finds the tree model set based on its name
local function findTreeSet(treeName)
	local success, treeFolder = pcall(function()
		return treesFolder:FindFirstChild(treeName)
	end)
	if success then
		return treeFolder
	else
		return nil
	end
end

-- Creates a new tree instance
function Tree.new(yard, treeName)
	local self = setmetatable({}, Tree)
	self.treeSet = findTreeSet(treeName)
	if not self.treeSet then
		return nil
	end

	-- Stores all growth stages of the tree
	self.stages = {}
	for _, stage in pairs(self.treeSet.Stages:GetChildren()) do
		table.insert(self.stages, stage)
	end

	self.treeName = treeName
	self.yard = yard
	self.stage = 0
	self.isGrowing = false
	
	self.fullyGrown = false
	self.growthCoroutine = nil

	-- Create individual events for this tree instance
	self.GrowthStarted = Instance.new("BindableEvent")
	self.FullyGrown = Instance.new("BindableEvent")
	self.GrowthStopped = Instance.new("BindableEvent")
	self.StageChanged = Instance.new("BindableEvent")

	return self
end

-- Updates the tree's visual model to match its current stage
function Tree:UpdatePlantStage()
	if not self.yard or not self.yard:IsDescendantOf(game) then
		self:StopGrowthCycle()
		return
	end

	if self.plantModel then
		self.plantModel:Destroy()
	end

	local stageModel = self.stages[self.stage + 1]
	if stageModel then
		self.plantModel = stageModel:Clone()
		self.plantModel:PivotTo(self.yard:GetPivot())
		self.plantModel.Parent = self.yard
	end
end

-- Starts the growth cycle
function Tree:StartGrowthCycle()
	if self.isGrowing or self.fullyGrown then
		return
	end

	self.isGrowing = true
	
	self.GrowthStarted:Fire()  

	self.growthCoroutine = coroutine.create(function()
		while self.isGrowing and self.stage < #self.stages - 1 do
			coroutine.yield()
			task.wait(2.5)

			if not self.yard or not self.yard:IsDescendantOf(game) or self.yard:GetAttribute("CurrentPlant") ~= self.treeName then
				self:StopGrowthCycle()
				break
			end

			-- Increment stage and update visual model
			self.stage = self.stage + 1
			self.yard:SetAttribute("CurrentStage", self.stage)
			self.StageChanged:Fire(self.stage)  -- Fire StageChanged event for this specific tree
			self:UpdatePlantStage()

			-- If the tree reaches the final stage, fire FullyGrown event
			if self.stage == #self.stages - 1 and not self.fullyGrown then
				self.fullyGrown = true
				self.FullyGrown:Fire()
				self:StopGrowthCycle()
			end
		end
	end)

	coroutine.resume(self.growthCoroutine)
end

-- Pauses the growth cycle
function Tree:PauseGrowthCycle()
	if self.growthCoroutine and coroutine.status(self.growthCoroutine) == "running" then
		coroutine.yield(self.growthCoroutine)
	end
end

-- Resumes the growth cycle
function Tree:ResumeGrowthCycle()
	if self.growthCoroutine and coroutine.status(self.growthCoroutine) == "suspended" then
		coroutine.resume(self.growthCoroutine)
	end
end

-- Stops the growth cycle
function Tree:StopGrowthCycle()
	if not self.isGrowing then
		return
	end
	self.isGrowing = false
	
	self.GrowthStopped:Fire()  -- Fire GrowthStopped event for this specific tree

	if self.growthCoroutine and coroutine.status(self.growthCoroutine) ~= "dead" then
		self.growthCoroutine = nil
	end
end

return Tree
