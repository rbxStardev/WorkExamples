local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local ZoneModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zone"))

local dealerZones = CollectionService:GetTagged("DealerZone")

local dealersLibrary = ReplicatedStorage:WaitForChild("DealersLibrary")
local dealerEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("DealerEvent")

local mainFrame = script.Parent
local closeButton = mainFrame:WaitForChild("Close"):WaitForChild("Button")
local dealerFrame = mainFrame:WaitForChild("Main")

local itemInfoUi = dealerFrame:WaitForChild("ItemInfo")
local blocker = itemInfoUi:WaitForChild("Blocker")
local itemsUi = dealerFrame:WaitForChild("Items"):WaitForChild("ScrollingFrame")
local itemTemplate = script:WaitForChild("ItemTemplate")
local successLabel = mainFrame:WaitForChild("success")

local selectedItem = script:WaitForChild("SelectedItem")

local buyButton = itemInfoUi:WaitForChild("Buttons"):WaitForChild("Buy")

--// Ui Management

local function displayItemInfo(itemName, itemIcon, itemDescription, itemPrice)
	itemInfoUi.Blocker.Visible = false
	
	itemInfoUi.ItemView.Icon.Image = itemIcon
	itemInfoUi.ItemName.Text = itemName
	itemInfoUi.ItemDescription.Text = itemDescription
	itemInfoUi.Buttons.Buy.Price.Text = itemPrice
	
end

for index, item in pairs(itemsUi:GetChildren()) do
	if item:IsA("TextButton") then
		local success, itemLibrary = pcall(function()
			return dealersLibrary[item.Name]
		end)
		
		if not success then
			print("no item library found for item: "..item.Name)
			return
		end
		
		item.MouseButton1Click:Connect(function()
			local itemIcon = item.ItemIcon.Image
			local itemDescription = itemLibrary:WaitForChild("Description").Value
			local itemPrice = itemLibrary:WaitForChild("Price").Value
			
			selectedItem.Value = item.Name
			
			displayItemInfo(item.Name, itemIcon, itemDescription, itemPrice)
			
		end)
		
	end
end

itemsUi.ChildAdded:Connect(function(item)
	if item:IsA("TextButton") then
		local success, itemLibrary = pcall(function()
			return dealersLibrary[item.Name]
		end)

		if not success then
			print("no item library found for item: "..item.Name)
			return
		end

		item.MouseButton1Click:Connect(function()
			local itemIcon = item.ItemIcon.Image
			local itemDescription = itemLibrary:WaitForChild("Description").Value
			local itemPrice = itemLibrary:WaitForChild("Price").Value

			selectedItem.Value = item.Name

			displayItemInfo(item.Name, itemIcon, itemDescription, itemPrice)

		end)

	end
end)

closeButton.MouseButton1Click:Connect(function()
	blocker.Visible = true
	mainFrame.Visible = false
end)

--// Zone Management

for i, zone in pairs(dealerZones) do
	local dealerZone = ZoneModule.new(zone)

	dealerZone.localPlayerEntered:Connect(function()
		blocker.Visible = true
		mainFrame.Visible = true
	end)
end

--// Dealer Event

buyButton.MouseButton1Click:Connect(function()
	if selectedItem.Value ~= nil or selectedItem.Value ~= "" then
		dealerEvent:FireServer(selectedItem.Value)
	else
		print("no selected item")
	end
end)

local successAppear = TweenService:Create(successLabel, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TextTransparency = 0})
local successHide = TweenService:Create(successLabel, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {TextTransparency = 1})

local successActing = false

dealerEvent.OnClientEvent:Connect(function(success)
	if success == true then
		task.spawn(function()
			if successActing == false then
				successLabel.Text = "Purchase successful!"
				successLabel.TextColor3 = Color3.fromRGB(85, 255, 0)
				successActing = true
				successAppear:Play()
				successAppear.Completed:Wait()
				task.wait(2)
				successHide:Play()
				successHide.Completed:Wait()
				successActing = false
			end
		end)
	else
		task.spawn(function()
			if successActing == false then
				successLabel.Text = "Purchase failed."
				successLabel.TextColor3 = Color3.fromRGB(255, 85, 0)
				successActing = true
				successAppear:Play()
				successAppear.Completed:Wait()
				task.wait(2)
				successHide:Play()
				successHide.Completed:Wait()
				successActing = false
			end
		end)
	end
end)
