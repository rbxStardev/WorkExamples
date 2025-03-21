local IgnispythonVolcanis = {}
IgnispythonVolcanis.__index = IgnispythonVolcanis

local plantSet = script:FindFirstChild("IgnispythonVolcanisSet")

local stages = {
	plantSet:FindFirstChild("IgnispythonVolcanisSeed"),
	plantSet:FindFirstChild("IgnispythonVolcanis1"),
	plantSet:FindFirstChild("IgnispythonVolcanis2"),
	plantSet:FindFirstChild("IgnispythonVolcanis3")
}

function IgnispythonVolcanis.new(yard, quantity)
	local self = setmetatable({}, IgnispythonVolcanis)
	self.yard = yard
	self.quantity = quantity
	self.currentStage = 0
	self.isGrowing = false
	self.growthInProgress = false
	self.growthLocked = false

	yard:SetAttribute("CurrentPlant", "IgnispythonVolcanis")
	yard:SetAttribute("CurrentStage", self.currentStage)
	yard:SetAttribute("Occupied", true)
	yard:SetAttribute("PlantStorage", self.quantity)

	self:UpdatePlantStage()
	self:StartGrowthCycle()

	print("New plant created: IgnispythonVolcanis")
	return self
end

function IgnispythonVolcanis:UpdatePlantStage()
	if not self.yard or not self.yard:IsDescendantOf(game) then
		self:StopGrowthCycle()
		return
	end

	if self.plantModel then
		self.plantModel:Destroy()
	end

	local stageModel = stages[self.currentStage + 1]
	if stageModel then
		self.plantModel = stageModel:Clone()
		self.plantModel:PivotTo(self.yard:GetPivot())
		self.plantModel.Parent = self.yard
		print("Updated to stage:", self.currentStage + 1)
	end
end

function IgnispythonVolcanis:StartGrowthCycle()
	if self.growthInProgress then
		print("Growth cycle is already in progress for yard:", self.yard.Name)
		return
	end

	self.growthInProgress = true
	self.isGrowing = true
	self.growthLocked = true

	task.spawn(function()
		while self.isGrowing and self.currentStage < #stages - 1 do
			task.wait(2.5)
			if not self.yard or not self.yard:IsDescendantOf(game) or self.yard:GetAttribute("CurrentPlant") ~= "IgnispythonVolcanis" then
				self:StopGrowthCycle()
				break
			end
			self.currentStage += 1
			self.yard:SetAttribute("CurrentStage", self.currentStage)
			self:UpdatePlantStage()
			if self.currentStage == #stages - 1 then
				self:StopGrowthCycle()
			end
		end
	end)
end

function IgnispythonVolcanis:StopGrowthCycle()
	self.isGrowing = false
	self.growthInProgress = false
	self.growthLocked = false
	print("Growth cycle stopped for yard:", self.yard.Name)
end

return IgnispythonVolcanis
