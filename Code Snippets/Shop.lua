--// Scripted By Skyler \\--

local Module = {}

--// Variables \\--

local Variables = require(script.Parent.Variables)
local Prefabs = script.Parent.Parent.Prefabs

--// Main \\--

local function SortByName(A, B)
	local AString = string.lower(A.ItemData.ItemID ~= nil and A.ItemData.ItemID) or string.lower("Nil")
	local BString = string.lower(B.ItemData.ItemID ~= nil and B.ItemData.ItemID) or string.lower("Nil")
	local ABytes = {}
	local BBytes = {}
	local AIsLess = false

	for i = 1, string.len(AString) do
		table.insert(ABytes, string.byte(AString, i, i))
	end

	for i = 1, string.len(BString) do
		table.insert(BBytes, string.byte(BString, i, i))
	end

	for i = 1, #BBytes do
		if #ABytes < i then
			AIsLess = true
			break
		end

		if ABytes[i] < BBytes[i] then
			AIsLess = true
			break
		elseif ABytes[i] > BBytes[i] then
			break
		end
	end

	return AIsLess
end

local function SortByPriceAndName(A, B)
	local APriceCoins = (A.ItemData.Prices ~= nil and A.ItemData.Prices.VibeBucks ~= nil and A.ItemData.Prices.VibeBucks) or 0
	local BPriceCoins = (B.ItemData.Prices ~= nil and B.ItemData.Prices.VibeBucks ~= nil and B.ItemData.Prices.VibeBucks) or 0

	if APriceCoins == BPriceCoins then
		return SortByName(A, B)
	end

	return APriceCoins < BPriceCoins
end

local function SortShopItems()	
	for _, Class in pairs(Variables.Misc.Stuff) do
		local Data = Variables.Misc.Database[Class]
		local Sorted = {}
		
		for ItemID, ItemData in pairs(Data) do
			table.insert(Sorted, {ItemID = ItemData.ItemID, ItemData = ItemData})
		end
		
		table.sort(Sorted, SortByPriceAndName)
		Variables.Misc.Database[Class] = {Sorted = Sorted, Original = Data}
	end
end

local function Navigate(FrameName)
	Variables.UIs.ShopUI.Main.Container.Main.FrontPage.Visible = false
	Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay.Visible = false
	
	if FrameName == "FrontPage" then
		if not Variables.Misc.Tweening then
			for _, Frame in pairs(Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay:GetChildren()) do
				if Frame:IsA("Frame") then
					Frame.Visible = false
				end
			end
			
			Variables.Misc.Tweening = true
			Variables.Misc.CurrentFrame = FrameName
			
			for _, NavButton in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Container:GetChildren()) do
				if NavButton:IsA("Frame") and NavButton.Name ~= FrameName then
					NavButton.Label.Text = NavButton.Name
				end
			end
			
			Variables.UIs.ShopUI.Main.Container.Main.FrontPage.Visible = true
			Variables.Misc.Tweening = false
		end
		
		return
	end
	
	if not Variables.Misc.Tweening then
		if FrameName ~= "Passes" and FrameName ~= "Products" then
			for _, Frame in pairs(Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay:GetChildren()) do
				if Frame:IsA("Frame") then
					Frame.Visible = false
				end
			end

			for _, NavButton in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Container:GetChildren()) do
				if NavButton:IsA("Frame") and NavButton.Name ~= FrameName then
					NavButton.Label.Text = NavButton.Name
				end
			end

			Variables.Misc.Tweening = true
			Variables.Misc.CurrentFrame = FrameName
			Variables.UIs.ShopUI.Main.Container.Main.FrontPage.Visible = false

			for _, NavButton in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Container:GetChildren()) do
				if NavButton:IsA("Frame") and NavButton.Name == FrameName then
					NavButton.Label.Text = "Back"
				end
			end

			Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay.Visible = true
			Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay[FrameName].Visible = true
			Variables.Misc.Tweening = false
		end
	end
end

local function UpdateCurrency(Data)
	if Data ~= nil then
		Variables.UIs.ShopUI.Currency.VibeBucks.Amount.Text = Variables.Modules.Tasks.Commas(Data.Stats["Vibe Bucks"])
	end
end

local function CreateFrame(Index, ItemTable, Container)
	local NewFrame = Prefabs.ContentTemplate:Clone()
	local ItemID = ItemTable.ItemID
	local ItemData = ItemTable.ItemData
	
	NewFrame.Parent = Container
	Variables.Modules.UI.ButtonAnimations(NewFrame)
	
	print(ItemData.ItemID)
	
	NewFrame.Container.Icon.Image = Variables.Modules.ItemInfo.GetAttribute(ItemData.ItemID, "Icon")
	NewFrame.Container.Title.Label.Text = Variables.Modules.ItemInfo.GetAttribute(ItemData.ItemID, "ActualName")
	NewFrame.Container.Prices.VibeBucks.Visible = (ItemData.Prices.VibeBucks ~= nil and true) or false
	NewFrame.Container.Prices.Robux.Visible = (ItemData.Prices.Robux ~= nil and true) or false
	
	if NewFrame.Container.Prices.VibeBucks.Visible then
		NewFrame.Container.Prices.VibeBucks.Amount.Text = Variables.Modules.Tasks.Commas(ItemData.Prices.VibeBucks)
	end
end

function Module.Handler()
	SortShopItems()
	
	if game.UserInputService.KeyboardEnabled and not game.UserInputService.TouchEnabled then
		Variables.UIs.ShopUI.Size = UDim2.new(0.48, 0, 0.5, 0)
	end
	
	for DataName, DataTable in pairs(Variables.Misc.Database) do
		local Data = DataTable.Sorted
		local ScrollFrame = Variables.UIs.ShopUI.Main.Container.Main.ItemDisplay[DataName].Items.Container
	
		Variables.Modules.Tasks.ClearFrame(ScrollFrame, "Frame")
		
		for ItemName, ItemDataTable in pairs(Data) do
			if ItemDataTable.ItemData.Prices ~= nil then
				if ItemDataTable.ItemData.Prices.NotForSale == nil then
					CreateFrame(ItemName, ItemDataTable, ScrollFrame)
				end
			end
		end
	end
	
	for _, NavButton in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Container:GetChildren()) do
		if NavButton:IsA("Frame") then
			NavButton.Button.MouseButton1Click:Connect(function()
				if NavButton.Label.Text ~= "Back" then
					Navigate(NavButton.Name)
				else
					Navigate("FrontPage")
				end
			end)
		end
	end
	
	for _, Object in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Container:GetChildren()) do
		if Object:IsA("Frame") then
			Variables.Modules.UI.ButtonAnimations(Object)
		end
	end
	
	for _, Object in pairs(Variables.UIs.ShopUI.Main.Container.TopBar.Arrows:GetChildren()) do
		if Object:IsA("Frame") then
			Variables.Modules.UI.ButtonAnimations(Object)
		end
	end
	
	for _, Object in pairs(Variables.UIs.ShopUI.Main.Container.Main.FrontPage.Bottom.ItemBundle.Main.Container.Contents:GetChildren()) do
		if Object:IsA("Frame") then
			Variables.Modules.UI.ButtonAnimations(Object)
		end
	end
	
	if game.Players.LocalPlayer.Name == ("Takeables" or "ViberanceHolder") then
		Variables.UIs.ShopUI.WIP.Visible = false
	else
		Variables.UIs.ShopUI.WIP.Visible = true
	end
	
	Variables.UIs.ShopUI.Close.Button.MouseButton1Click:Connect(function()
		Variables.Modules.UI.ToggleFrame(Variables.UIs.ShopUI, false)
	end)
	
	Variables.Modules.UI.ButtonAnimations(Variables.UIs.ShopUI.Main.Container.Main.FrontPage.Bottom.ItemBundle.Main.Container.Bottom.Buy)
	Variables.Modules.UI.ButtonAnimations(Variables.UIs.ShopUI.Currency.VibeBucks.More)
	Variables.Modules.UI.ButtonAnimations(Variables.UIs.ShopUI.Close)
	
	UpdateCurrency(_G.PlayerData)
end

game.ReplicatedStorage.Remotes.Data.UpdateData.OnClientEvent:Connect(function(Data)
	UpdateCurrency(Data)
end)

return Module
