local gui = script.Parent

local function updateStatus()
	local gameStatus = workspace:GetAttribute("Status")
	gui.Status.CurrentStatus.Text = gameStatus
end

local function updateClock()
	local clockTime = game.Workspace:GetAttribute("Clock")
	if clockTime <= 0 then
		gui.Time.Visible = false
	else
		gui.Time.Visible = true
		gui.Time.CurrentTime.Text = clockTime
	end
end

game.Workspace:GetAttributeChangedSignal("Clock"):Connect(updateClock)
game.Workspace:GetAttributeChangedSignal("Status"):Connect(updateStatus)
