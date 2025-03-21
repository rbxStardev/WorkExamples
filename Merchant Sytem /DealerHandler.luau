local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dealersLibrary = ReplicatedStorage.DealersLibrary
local dealerEvent = ReplicatedStorage.Events.DealerEvent

dealerEvent.OnServerEvent:Connect(function(player, selectedItem)
	local success, item, playerData = pcall(function()
		return dealersLibrary[selectedItem], player:FindFirstChild("Data")
	end)
	if success ~= true then return end
	
	local playerMoney = playerData:FindFirstChild("Economy"):FindFirstChild("Money")
	
	if playerMoney.Value >= item:FindFirstChild("Price").Value then
		
		playerMoney.Value -= item:FindFirstChild("Price").Value
		
		local tool = item:FindFirstChild(item.Name):Clone()
		tool.Parent = player.Backpack
		
		dealerEvent:FireClient(player, true)
		
	else
		dealerEvent:FireClient(player, false)
	end
	
end)
