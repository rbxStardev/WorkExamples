local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local shopLibrary = ReplicatedStorage:FindFirstChild("GameLibrary"):FindFirstChild("ShopItems")
local shopRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Shop")

shopRemote.OnServerEvent:Connect(function(player, itemId)
	local item = shopLibrary:FindFirstChild(itemId)
	if item then
		local itemType = item:FindFirstChild("Type").Value
		if itemType == "Item" then
			
			local itemTool = item:FindFirstChild(item.Name)
			local price = item:FindFirstChild("Price")
			local playerNormals = player:FindFirstChild("leaderstats"):FindFirstChild("Normals")
			
			if playerNormals.Value >= price.Value then
				playerNormals.Value -= price.Value
				itemTool:Clone().Parent = player.Backpack
			end
			
		elseif itemType == "Cosmetic" then
			
			local cosmetic = item:FindFirstChild(item.Name)
			local price = item:FindFirstChild("Price")
			local playerNormals = player:FindFirstChild("leaderstats"):FindFirstChild("Normals")
			local playerCosmetics = player:FindFirstChild("Data"):FindFirstChild("Cosmetics")

			if playerNormals.Value >= price.Value then
				playerNormals.Value -= price.Value
				cosmetic:Clone().Parent = playerCosmetics
			end

		elseif itemType == "Gamepass" then
			local itemGamepassId = item:FindFirstChild("GamepassId")
			MarketplaceService:PromptGamePassPurchase(player, itemGamepassId.Value)
		elseif itemType == "DevProduct" then
			local itemProduct = item:FindFirstChild("ProductId")
			MarketplaceService:PromptProductPurchase(player, itemProduct.Value)
		end
	end
end)
