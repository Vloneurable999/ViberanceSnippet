local Module = {}

--// Variables \\--

local Variables = require(script.Parent.Variables)

--// Main \\--

local function ChangeProgress()	
	local CurrentPage = Variables.UIs.TutorialUI.Pages.PageLayout.CurrentPage
	
	for _, Frame in pairs(Variables.UIs.TutorialUI.Progress:GetChildren()) do
		if Frame:IsA("Frame") then
			if Frame.Name == CurrentPage.Name then
				Frame.Background.Stroke.Color = Color3.fromRGB(0, 255, 0)
			else
				Frame.Background.Stroke.Color = Color3.fromRGB(255, 0, 255)
			end
		end
	end
end

function Module.Handler()
	repeat task.wait() until _G.PlayerData.Loaded == true

	Variables.UIs.TutorialUI.Visible = true

	Variables.UIs.TutorialUI.Pages.PageLayout.Changed:Connect(function()
		ChangeProgress()
	end)

	Variables.UIs.TutorialUI.Pages.Step4.AgreeArea.Agree.Button.MouseButton1Click:Connect(function()
		Variables.UIs.TutorialUI.Pages.Step4.AgreeArea.Agree.Check.Visible = true
		task.wait(0.5)
		Variables.Modules.UI.ToggleFrame(Variables.UIs.TutorialUI, false)
		Variables.Misc.Remotes.Tutorial.Agree:FireServer()
	end)
end

return Module
