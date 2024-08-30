local Module = {}

--// Variables \\--

local Variables = require(script.Parent.Variables)
local Prefabs = script.Parent.Parent.Prefabs

--// Main \\--

local function HandleEquip(Tool)
	if Tool.Parent ~= Variables.Misc.Character then
		Variables.Misc.Character.Humanoid:EquipTool(Tool)
	else
		Variables.Misc.Character.Humanoid:UnequipTools()
	end
end

local function CheckToolBar(RemoveIndex)
	if RemoveIndex then
		for _, Frame in pairs(Variables.UIs.ToolBarUI.Container:GetChildren()) do
			if Frame:IsA("GuiObject") then
				if tonumber(Frame.Name) >= RemoveIndex then
					local NewIndex = (tonumber(Frame.Name) == 11) and 0 or tonumber(Frame.Name) - 1
					local IsVisible = (Variables.Misc.MaxTools == 10) and (NewIndex <= 9 and true or false) or ((NewIndex ~= 0 and NewIndex <= Variables.Misc.MaxTools) and true or false)

					Frame.LayoutOrder -= 1
					Frame.Name -= 1
					Frame.Visible = IsVisible
					Frame.Index.Text = NewIndex
				end
			end
		end
	end
end

local function Create(Tool)
	local NextIndex = (#Variables.Misc.Items == 10) and 0 or #Variables.Misc.Items
	local IsVisible = (Variables.Misc.MaxTools == 10) and (NextIndex <= 9 and true or false) or ((NextIndex ~= 0 and NextIndex <= Variables.Misc.MaxTools) and true or false)
	local ToolTemplate = Prefabs.ToolTemplate:Clone()
	
	ToolTemplate.LayoutOrder = #Variables.Misc.Items
	ToolTemplate.Container.Number.Text = NextIndex
	ToolTemplate.Visible = IsVisible
	ToolTemplate.Container.Icon.Image = Variables.Modules.ItemInfo.GetAttribute(Tool.Name, "Icon")
	ToolTemplate.Parent = Variables.UIs.ToolBarUI.Container
	
	ToolTemplate.Button.MouseButton1Click:Connect(function()
		HandleEquip(Tool)
	end)
	
	CheckToolBar()
end

local function UpdateAdd(Tool)
	if not Tool:IsA("Tool") then
		return
	end

	CheckToolBar()

	if table.find(Variables.Misc.Items, Tool) then
		return
	end

	table.insert(Variables.Misc.Items, Tool)

	Create(Tool)
end

local function UpdateRemove(Tool)
	if not Tool:IsA("Tool") then
		return
	end

	if Tool.Parent == Variables.Misc.Character or Tool.Parent == Variables.Misc.Backpack then
		return
	end

	if table.find(Variables.Misc.Items, Tool) then
		local Index = table.find(Variables.Misc.Items, Tool)
		local Frame = Variables.UIs.ToolBarUI.Container:FindFirstChild(Index)

		if Frame then
			Frame:Destroy()
		end

		table.remove(Variables.Misc.Items, Index)
		CheckToolBar(Index)
	end
end

function Module.Handler()
	while true do
		local success, err = pcall(function()
			game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
		
		if success then
			break
		end
		
		wait()
	end
	
	if Variables.Misc.MaxTools > 10 then
		Variables.Misc.MaxTools = 10
	end
	
	for _, Tool in pairs(Variables.Misc.Backpack:GetChildren()) do
		UpdateAdd(Tool)
	end
	
	Variables.Misc.Backpack.ChildAdded:Connect(UpdateAdd)
	Variables.Misc.Backpack.ChildRemoved:Connect(UpdateRemove)
	Variables.Misc.Character.ChildAdded:Connect(UpdateAdd)
	Variables.Misc.Character.ChildRemoved:Connect(UpdateRemove)
	
	game:GetService("UserInputService").InputBegan:Connect(function(Input, GameProcessed)
		if GameProcessed then
			return
		end

		if Variables.Misc.KeyDictionary[Input.KeyCode.Name] then
			local Index = Variables.Misc.KeyDictionary[Input.KeyCode.Name]

			if Variables.Misc.Items[Index] then
				HandleEquip(Variables.Misc.Items[Index])
			end
		end
	end)
end

return Module
