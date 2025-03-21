--// Services

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Vars

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local appButtonsUi = script.Parent:WaitForChild("Screen"):WaitForChild("Apps")
local appsUi = script.Parent:WaitForChild("Screen"):WaitForChild("AppFrames")
local middleFrames = script.Parent.Parent:WaitForChild("MiddleFrames")

local tabletHomeButton = script.Parent:WaitForChild("Buttons"):WaitForChild("Home")

local openApp = nil

--// Tablet

tabletHomeButton.MouseButton1Click:Connect(function()
	script.Parent.Buttons.Click:Play()
	if openApp ~= nil then
		openApp.Visible = false
		openApp = nil
	end
end)

for i, app in pairs(appButtonsUi:GetChildren()) do
	if app:IsA("Frame") then
		if app:FindFirstChildWhichIsA("TextButton") then
			local success, appFrame, appMiddleFrame = pcall(function()
				return appsUi[app.Name], middleFrames[app.Name]
			end)
			if not appFrame and not appMiddleFrame then
				print("no app found for: "..app.Name)
				return
			end
			
			local button = app:FindFirstChildWhichIsA("TextButton")
			
			button.MouseButton1Click:Connect(function()
				if appFrame then
					script.Parent.Buttons.Click:Play()
					appFrame.Visible = true
					openApp = appFrame
				elseif appMiddleFrame then
					script.Parent.Buttons.Click:Play()
					appMiddleFrame.Visible = true
					openApp = appFrame
				end
			end)
			
		end
	end
end

appButtonsUi.ChildAdded:Connect(function(app)
	if app:IsA("Frame") then
		if app:FindFirstChildWhichIsA("TextButton") then
			local appFrame = appsUi[app.Name]
			if not appFrame then
				print("no app found for: "..app.Name)
				return
			end

			local button = app:FindFirstChildWhichIsA("TextButton")

			button.MouseButton1Click:Connect(function()
				script.Parent.Buttons.Click:Play()
				appFrame.Visible = true
				openApp = appFrame
			end)

		end
	end
end)

--// Coordinates

local coordinatesApp = appsUi:WaitForChild("Coordinates")

local cordsX = coordinatesApp:WaitForChild("App"):WaitForChild("PosX")
local cordsY = coordinatesApp:WaitForChild("App"):WaitForChild("PosY")
local cordsZ = coordinatesApp:WaitForChild("App"):WaitForChild("PosZ")

local coordinatesUpdate = coroutine.create(function()
	local posx = tostring(math.round(root.Position.X))
	local posy = tostring(math.round(root.Position.Y))
	local posz = tostring(math.round(root.Position.Z))

	cordsX.Text = "X: "..posx
	cordsY.Text = "Y: "..posy
	cordsZ.Text = "Z: "..posz
	task.wait(0.1)
end)

coordinatesApp.Changed:Connect(function(property)
	if property == "Visible" then
		if property == true then
			coroutine.resume(coordinatesUpdate)
		else
			coroutine.yield(coordinatesUpdate)
		end
	end
end)

--// Hints  

local hintsApp = appsUi:WaitForChild("Hints")

local hintLabel = hintsApp:WaitForChild("App"):WaitForChild("Hint")

game.Workspace:GetAttributeChangedSignal("Hint"):Connect(function()
	local hint = game.Workspace:GetAttribute("Hint")
	hintLabel.Text = tostring(hint)
end)

--// Shop

local shopApp = middleFrames:WaitForChild("Shop")

local shopEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
local shopItems = shopApp:WaitForChild("ScrollingFrame"):GetChildren()
local closeButton = shopApp:WaitForChild("TopBar"):WaitForChild("Close")

closeButton.MouseButton1Click:Connect(function()
	shopApp.Visible = false
end)

for i, item in pairs(shopItems) do
	if item:IsA("TextButton") then
		if item:FindFirstChild("ItemId") then
			item.MouseButton1Click:Connect(function()
				shopEvent:FireServer(item:FindFirstChild("ItemId").Value)
			end)
		end
	end
end
