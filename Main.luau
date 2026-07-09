local cloneref = cloneref or function(x) return x end

local UserInputService = cloneref(game:GetService("UserInputService"))

local Library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/realheckersbrother/UnpackedHub/refs/heads/main/UI.luau", true))()

local MainWindow = Library:CreateWindow({
    Title = "Unpacked Hub",
    SubText = "Scripts",
})

local ScriptsTab = MainWindow:AddTab({
    Text = "Scripts",
    Icon = "rbxassetid://108020878442937"
})

local ScriptsSection = ScriptsTab:AddSection({
    Title = "Scripts",
    Side = "Left"
})

ScriptsSection:AddButton({
    Text = "Last Letter | Auto Typer",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/realheckersbrother/UnpackedHub/refs/heads/main/Scripts/LastLetterAutoTyper.luau", true))()
        end)

        if success then
            Library:Notify({
                Title = "Executed!",
                Lifetime = 5
            })
        else
            Library:Notify({
                Title = "Execution Failed",
                Lifetime = 5
            })

            warn(result)
        end
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if MainWindow then
            MainWindow.SetVisible(not MainWindow.Visible)
        end
    end
end)

Library:Notify({
    Title = "Unpacked Hub Loaded!",
    Lifetime = 5
})
