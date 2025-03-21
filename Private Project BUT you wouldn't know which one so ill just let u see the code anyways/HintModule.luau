local module = {}

local DEFAULT_SETTINGS = {
	OUTLINE = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		FillTransparency = 1,
		OutlineTransparency = 0.7
	},
	FILL = {
		DepthMode = Enum.HighlightDepthMode.Occluded,
		FillTransparency = 0.85,
		OutlineTransparency = 1
	},
	PARTICLE = {
		Size = Vector3.new(1, 1, 1),
		Anchored = true,
		Transparency = 1,
		CanCollide = false
	}
}

function module.Outline(target)
	if not target then return end

	local newOutline = Instance.new("Highlight")
	for property, value in pairs(DEFAULT_SETTINGS.OUTLINE) do
		newOutline[property] = value
	end
	newOutline.Parent = target

	return newOutline
end

function module.Fill(target)
	if not target then return end

	local newOutline = Instance.new("Highlight")
	for property, value in pairs(DEFAULT_SETTINGS.FILL) do
		newOutline[property] = value
	end
	newOutline.Parent = target

	return newOutline
end

function module.Particle(target)
	if not target then return end
	if not script:FindFirstChild("Particle") then return end

	local newPart = Instance.new("Part")
	for property, value in pairs(DEFAULT_SETTINGS.PARTICLE) do
		newPart[property] = value
	end

	if target:IsA("BasePart") or target:IsA("Model") then
		newPart.Position = target.WorldPivot.Position
	end

	newPart.Parent = target

	local newParticle = script.Particle:Clone()
	newParticle.Parent = newPart

	return newPart, newParticle
end

return module
