--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
if not game.IsLoaded then
    game.Loaded:Wait()
end

-- Configuration
local CONFIG = {
    useShortestWords = false; -- "false" if you want longest words or "true" if you want shortest words
    notificationLibrary = "Akali"; -- "BocusLuke" or "Akali" both credits go to them
    typingSpeed = 0.07; -- Typing speed (seconds between each letter)
    typeEnterSpeed = 0.02; -- typing enter speed
    randomTypeEnterSpeed = true; -- Randomized typing enter speed
    randomTypeEnterSpeedMinimum = 20; -- ms (0.02 in task.wait and wait) 
    randomTypeEnterSpeedMaximum = 40; -- ms (0.04 in task.wait and wait) 
    reactionSpeed = 0.02; -- reaction speed
    randomReactionSpeed = true; -- Randomized typing enter speed
    randomReactionSpeedMinimum = 20; -- ms (0.02 in task.wait and wait) 
    randomReactionSpeedMaximum = 40; -- ms (0.04 in task.wait and wait) 
    idealLength = 6; -- Ideal length
    wordsPerPage = 10; -- Words per page
    randomTypingSpeed = true; -- Randomized typing speed
    randomTypingSpeedMinimum = 70; -- ms (0.07 in task.wait and wait) 
    randomTypingSpeedMaximum = 200; -- ms (0.2 in task.wait and wait) 
}

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Active = false
local CoreGui = game:GetService("CoreGui")
local env = getgenv() or _G

if env and env.GuiName then
    local foundGui = gethui():FindFirstChild(env.GuiName) or CoreGui:FindFirstChild(env.GuiName)

    if foundGui and foundGui:IsA("ScreenGui") then
        foundGui:Destroy()
    end
end

local GUI = game:GetService("CoreGui"):FindFirstChild("STX_Nofitication")
if not GUI then
    local STX_Nofitication = Instance.new("ScreenGui")
    local STX_NofiticationUIListLayout = Instance.new("UIListLayout")
    STX_Nofitication.Name = "STX_Nofitication"
    STX_Nofitication.Parent = game.CoreGui
    STX_Nofitication.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    STX_Nofitication.ResetOnSpawn = false
    
    STX_NofiticationUIListLayout.Name = "STX_NofiticationUIListLayout"
    STX_NofiticationUIListLayout.Parent = STX_Nofitication
    STX_NofiticationUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    STX_NofiticationUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    STX_NofiticationUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local AkaliNotif = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/NotificationLibs/refs/heads/main/AkaliNotif/AkaliNotifSource.lua"))()

local BocusLukeNotification = loadstring(game:HttpGet("https://raw.githubusercontent.com/DozeIsOkLol/NotificationLibs/refs/heads/main/BocusLukeNotif/ClientSource.lua"))()

local TypingWord = false

-- functions --

local function IsMyTurn()
    local frame = playerGui:FindFirstChild("InGame")
        and playerGui.InGame:FindFirstChild("Frame")

    if not frame then return false end

    local label = frame:FindFirstChild("Archivable")
    if not label or not label:IsA("TextLabel") then return false end

    local text = (label.Text or ""):lower()
    local name = player.Name:lower()

    text = text:match("^%s*(.-)$")

    return text:sub(1, #name) == name
end

local HardLetterScores = {
    x = 10, z = 9, q = 9, j = 8, v = 6, k = 5, b = 4, f = 3, w = 3,
    y = 2, g = 2, p = 2
}

local function GetKillerScore(word)
    local lastChar = word:sub(-1)
    return HardLetterScores[lastChar] or 0
end

local function GetCurrentGameWord2()
    local player = Players.LocalPlayer
    local gui = player and player:FindFirstChild("PlayerGui")
    local inGame = gui and gui:FindFirstChild("InGame")
    local frame = inGame and inGame:FindFirstChild("Frame")

    local container = frame and frame:FindFirstChild("CurrentWord")
    if not container then return "" end

    local detected = ""

    for _, c in ipairs(container:GetChildren()) do
        if c:IsA("GuiObject") and c.Visible then
            local txt = c:FindFirstChild("Letter")
            if txt and txt:IsA("TextLabel") and txt.TextTransparency < 1 then
                detected = detected .. txt.Text
            end
        end
    end

    return detected
end

-- end --

-- Common words to ignore
local commonWords = {
    -- ["the"] = true, ["and"] = true, ["a"] = true, ["an"] = true,
    -- ["is"] = true, ["it"] = true, ["to"] = true, ["of"] = true,
    -- ["in"] = true, ["for"] = true, ["on"] = true, ["with"] = true,
    -- ["as"] = true, ["at"] = true, ["by"] = true, ["or"] = true,
}

-- Dictionary URLs
local DICTIONARY_URLS = {
    "https://raw.githubusercontent.com/QuavixAlt/-Q7-Zx-N-3L-8mT2P-EwHkA9cFrXyS/refs/heads/main/words.txt", -- credits to QuavixAlt
    "https://raw.githubusercontent.com/dwyl/english-words/refs/heads/master/words_dictionary.json", -- credits to dwyl
    "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa-no-swears.txt", -- credits to first20hours
    "https://raw.githubusercontent.com/skrylor/english-words/refs/heads/main/merged_english.txt", -- credits to skrylor
}

-- if you want to add some here, suggest it to me on scriptblox https://scriptblox.com/script/Last-Letter-auto-type-requires-human-asistance-113188
local CUSTOM_DICTIONARY = {
    "gealousies";
    "gealousy";
    "gealous";
    "gealing";
    "gealed";
    "geals";
    "yoyoyoyoyo";
    "yoyodyne";
    "yoyogi";
    "yoyomf";
    "yoyoda";
    "yoyos";
    "yoyow";
    "ippons";
    "ippoo";
    "ippon";
    "elloughton";
    "ellomenos";
    "ellobius";
    "ellora";
    "ellore";
    "elloes";
}

local allWords = {}
local collectedLetters = {}
local usedWords = {}
local lastWordTime = 0
local topWords = {}
local selectedIndex = 1
local currentPage = 1

local screenGui = Instance.new("ScreenGui")
screenGui.Name = tostring(math.random(0, 999999999))
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui and gethui() or CoreGui
env.GuiName = screenGui.Name

local scaleFactor = 0.75
local marginX, marginY = 20, 20

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0, 540 * scaleFactor, 0, 90 * scaleFactor)
searchBox.Position = UDim2.new(1, -540*scaleFactor - marginX, 1, -90*scaleFactor - marginY)
searchBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
searchBox.BorderColor3 = Color3.fromRGB(0, 255, 255)
searchBox.BorderSizePixel = 4
searchBox.TextColor3 = Color3.fromRGB(0, 255, 255)
searchBox.PlaceholderText = "loading dictionary..."
searchBox.Font = Enum.Font.GothamBold
searchBox.TextSize = 36 * scaleFactor
searchBox.ClearTextOnFocus = false
searchBox.TextEditable = true
searchBox.PlaceholderText = "Type a word"
searchBox.Parent = screenGui

local resultsFrame = Instance.new("Frame")
resultsFrame.Size = UDim2.new(0, 540 * scaleFactor, 0, 400 * scaleFactor)
resultsFrame.Position = UDim2.new(1, -540*scaleFactor - marginX, 1, -490*scaleFactor - marginY)
resultsFrame.BackgroundTransparency = 1
resultsFrame.Parent = screenGui

local selectionBox = Instance.new("Frame")
selectionBox.BackgroundTransparency = 0.5
selectionBox.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
selectionBox.BorderSizePixel = 2
selectionBox.Visible = false
selectionBox.Parent = resultsFrame

local arrowMargin = 5

task.wait()
RunService.RenderStepped:Wait()

local leftArrow = Instance.new("TextButton")
leftArrow.Size = UDim2.new(0, 40*scaleFactor, 0, 40*scaleFactor)
leftArrow.Text = "<"
leftArrow.Font = Enum.Font.GothamBold
leftArrow.TextSize = 32*scaleFactor
leftArrow.BackgroundColor3 = Color3.fromRGB(15,15,15)
leftArrow.TextColor3 = Color3.fromRGB(0,255,150)
leftArrow.Parent = screenGui
leftArrow.Position = UDim2.new(0, searchBox.AbsolutePosition.X, 0, searchBox.AbsolutePosition.Y - 40*scaleFactor - arrowMargin)

local rightArrow = leftArrow:Clone()
rightArrow.Text = ">"
rightArrow.Parent = screenGui
rightArrow.Position = UDim2.new(0, searchBox.AbsolutePosition.X + 50*scaleFactor, 0, searchBox.AbsolutePosition.Y - 40*scaleFactor - arrowMargin)

local lib = string.lower(CONFIG.notificationLibrary)

local function Notification(title, description, duration)
    pcall(function()
        if lib == "akali" then
            AkaliNotif.Notify({
                Title = title,
                Description = description,
                Duration = duration,
            })
        elseif lib == "bocusluke" then
            BocusLukeNotification:Notify({
                Title = title,
                Description = description
            }, {
                OutlineColor = Color3.fromRGB(80, 80, 80),
                Time = duration,
                Type = 'default'
            })
        else
            warn("Invalid notification library:", lib)
        end
    end)
end

local function GetCurrentGameWord(frame)
    frame = frame
        or (player and player:FindFirstChild("PlayerGui")
        and player.PlayerGui:FindFirstChild("InGame")
        and player.PlayerGui.InGame:FindFirstChild("Frame"))

    local container = frame and frame:FindFirstChild("CurrentWord")
    if not container then
        return "", false
    end

    local letters = {}
    local censored = false

    for _, c in ipairs(container:GetChildren()) do
        if c:IsA("GuiObject") and c.Visible then
            local txt = c:FindFirstChild("Letter")
            if txt and txt:IsA("TextLabel") and txt.TextTransparency < 1 then
                local t = txt.Text or ""

                if t:find("#") or t:find("%*") then
                    censored = true
                end

                letters[#letters + 1] = {
                    text = t,
                    x = c.AbsolutePosition.X,
                    id = tonumber(c.Name) or 0
                }
            end
        end
    end

    -- sort once (still needed for correct order)
    table.sort(letters, function(a, b)
        return (a.x == b.x) and (a.id < b.id) or (a.x < b.x)
    end)

    local result = table.create(#letters)

    for i = 1, #letters do
        result[i] = letters[i].text
    end

    return table.concat(result):lower():gsub(" ", ""), censored
end

-- Clears the current letters by backspacing them out
local function retypeWord(letters)
    for i = 1, #letters do
        local delay = CONFIG.typingSpeed
        if CONFIG.randomTypingSpeed then
            delay = math.random(CONFIG.randomTypingSpeedMinimum, CONFIG.randomTypingSpeedMaximum) / 1000
        end
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(delay)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
    end
end

local lastRoundWord = ""
local currentLetters = nil

local function autoTypeWord(word, currentInput)
    if not currentInput or not word then return end
    if not Active or not IsMyTurn() then return end
    if word == lastRoundWord then return end

    lastRoundWord = word
    TypingWord = true

    task.spawn(function()
        local reactionDelay = CONFIG.reactionSpeed
        if CONFIG.randomReactionSpeed then
            reactionDelay = math.random(CONFIG.randomReactionSpeedMinimum, CONFIG.randomReactionSpeedMaximum) / 1000
        end
        task.wait(reactionDelay)

        local remaining = word:sub(#currentInput + 1)
        for c in remaining:upper():gmatch(".") do
            local key = Enum.KeyCode[c]
            if key then
                local delay = CONFIG.typingSpeed
                if CONFIG.randomTypingSpeed then
                    delay = math.random(CONFIG.randomTypingSpeedMinimum, CONFIG.randomTypingSpeedMaximum) / 1000
                end
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(delay)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end

        task.wait(0.1)

        local letters = GetCurrentGameWord2() or GetCurrentGameWord()
        if letters ~= "" and string.lower(letters) ~= string.lower(word) then
            retypeWord(letters)
            if Active and IsMyTurn() then
                autoTypeWord(word, "")
            end
            TypingWord = false
            return
        end

        local delay = CONFIG.typeEnterSpeed
        if CONFIG.randomTypeEnterSpeed then
            delay = math.random(CONFIG.randomTypeEnterSpeedMinimum, CONFIG.randomTypeEnterSpeedMaximum) / 1000
        end
        task.wait(delay)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

        currentLetters = nil
        lastRoundWord = ""
        TypingWord = false
    end)
end

local lastWord = ""

local function handleWord(letters)
    if not letters or letters == "" then return end

    lastWordTime = tick()
    table.insert(collectedLetters, letters)

    if Active and IsMyTurn() then
        TypingWord = true
        local input = letters:lower()
        local trollWord = nil
        local startTime = tick()

        while not trollWord and (tick() - startTime) < 10 do
            local candidates = {}

            if CONFIG.useShortestWords == false then
                for _, w in ipairs(allWords) do
                    if w:sub(1, #input) == input and #w >= 7 and not usedWords[w] then
                        table.insert(candidates, w)
                    end
                end
                if #candidates == 0 then
                    for _, w in ipairs(allWords) do
                        if w:sub(1, #input) == input and not usedWords[w] then
                            table.insert(candidates, w)
                        end
                    end
                end
            else
                for _, w in ipairs(allWords) do
                    if w:sub(1, #input) == input and not usedWords[w] then
                        table.insert(candidates, w)
                    end
                end
            end

            table.sort(candidates, function(a, b)
                return GetKillerScore(a) > GetKillerScore(b)
            end)

            if #candidates > 0 then
                trollWord = candidates[1]
            else
                task.wait(0.1)
            end
        end

        if not trollWord then
            TypingWord = false
            return
        end

        usedWords[trollWord] = true
        TypingWord = false
        autoTypeWord(trollWord, letters)
    else
        searchBox.Text = letters
    end
end

local function loadFromJSON(content)
    local success, wordsJson = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    
    if not success then return false end
    
    for word, _ in pairs(wordsJson) do
        if not commonWords[word:lower()] then
            table.insert(allWords, word:lower())
        end
    end
    return true
end

local function loadFromText(content)
    for word in content:gmatch("[^\r\n]+") do
        if not commonWords[word:lower()] then
            table.insert(allWords, word:lower())
        end
    end
    return #allWords > 0
end

local FILE_NAME = "RHBWordList.txt"

local function loadDictionary()
    Notification("RHB's Auto Typer", "Loading dictionary...", 5)

    allWords = {}

    local wordsSet = {}

    local function extractWords(text)
        for word in text:gmatch("%a+") do
            word = word:lower()
            if not wordsSet[word] then
                wordsSet[word] = true
                table.insert(allWords, word)
            end
        end
    end

    if isfile(FILE_NAME) then
        local data = readfile(FILE_NAME)
        extractWords(data)
    else
        for _, url in ipairs(DICTIONARY_URLS) do
            local ok, content = pcall(function()
                return game:HttpGet(url)
            end)

            if ok and content then
                if url:find("%.json") then
                    local decoded
                    pcall(function()
                        decoded = game:GetService("HttpService"):JSONDecode(content)
                    end)

                    if decoded then
                        for key, _ in pairs(decoded) do
                            if typeof(key) == "string" then
                                extractWords(key)
                            end
                        end
                    else
                        extractWords(content)
                    end
                else
                    extractWords(content)
                end
            else
                Notification("RHB's Auto Typer", "Failed to fetch:", url, 5)
            end
        end

        local combined = table.concat(allWords, "\n")
        writefile(FILE_NAME, combined)

        Notification("RHB's Auto Typer", "Dictionary built & saved! (" .. #allWords .. " words)", 5)
    end

    for _, customWord in ipairs(CUSTOM_DICTIONARY) do
        local lower = customWord:lower()

        if not wordsSet[lower] then
            wordsSet[lower] = true
            table.insert(allWords, lower)
        end
    end

    Notification("RHB's Auto Typer", "Dictionary ready! (" .. #allWords .. " words)", 5)
    return true
end

local function createWordLabel(parent, text, size, offsetY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, size + 5)
    lbl.Position = UDim2.new(0, 0, 0, offsetY)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
    lbl.Font = Enum.Font.Arcade
    lbl.TextSize = size
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

local function displayPage()
    for _, c in ipairs(resultsFrame:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    local startIdx = (currentPage-1)*CONFIG.wordsPerPage + 1
    local endIdx = math.min(currentPage*CONFIG.wordsPerPage, #topWords)
    
    for i = startIdx, endIdx do
        local size = (i == startIdx) and 68*scaleFactor or 33*scaleFactor
        local offsetY = (i == startIdx) and 0 or 68*scaleFactor + (i-startIdx-1)*33*scaleFactor
        local lbl = createWordLabel(resultsFrame, topWords[i]:upper(), size, offsetY)

        lbl.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local word = topWords[i]
                if word then
                    usedWords[word] = true
                    Notification("RHB's Auto Typer", "selected: " .. word, 5)
                    autoTypeWord(word, searchBox.Text)
                    searchBox.Text = ""
                    selectionBox.Visible = false
                end
            end
        end)
    end

    if endIdx-startIdx+1 > 0 then
        local firstLabel = resultsFrame:GetChildren()[1]
        if firstLabel and firstLabel:IsA("TextLabel") then
            selectionBox.Position = firstLabel.Position
            selectionBox.Size = firstLabel.Size
            selectionBox.Visible = true
        end
    else
        selectionBox.Visible = false
    end
end

local function updateTopWords(input)
    topWords = {}
    input = input:lower()
    
    if input == "" then
        selectionBox.Visible = false
        for _, c in ipairs(resultsFrame:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        return
    end

    for _, w in ipairs(allWords) do
        if w:sub(1, #input) == input and w ~= input and not usedWords[w] then
            table.insert(topWords, w)
        end
    end

    currentPage = 1
    displayPage()
end

leftArrow.MouseButton1Click:Connect(function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        displayPage()
    end
end)

rightArrow.MouseButton1Click:Connect(function()
    if currentPage < math.ceil(#topWords/CONFIG.wordsPerPage) then
        currentPage = currentPage + 1
        displayPage()
    end
end)

searchBox.Focused:Connect(function()
    searchBox.Text = ""
    selectionBox.Visible = false
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateTopWords(searchBox.Text)
end)

task.spawn(function()
    if loadDictionary() then
        task.wait(0.5)

        local InGame = playerGui:FindFirstChild("InGame")
        local InGameFrame = InGame and InGame:FindFirstChild("Frame")

        if InGameFrame.Visible == true then
            Active = true
            Notification("RHB's Auto Typer", "Auto typer enabled", 5)
        else
            Active = false
            Notification("RHB's Auto Typer", "Auto typer disabled", 5)
            usedWords = {}
            lastWordTime = 0
        end

        if InGame and InGameFrame then
            InGameFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if InGameFrame.Visible == true then
                    Active = true
                    Notification("RHB's Auto Typer", "Auto typer enabled", 5)
                else
                    Active = false
                    Notification("RHB's Auto Typer", "Auto typer disabled", 5)
                    usedWords = {}
                    lastWordTime = 0
                end
            end)
        else
            Notification("RHB's Auto Typer", "Game event join error", 5)
            Notification("RHB's Auto Typer", "Game event exit error", 5)
        end
local currentWord = game:GetService("Players").LocalPlayer.PlayerGui
    .InGame.Frame:FindFirstChild("CurrentWord")

if currentWord then
    currentWord.ChildAdded:Connect(function(child)

        task.delay(0.05, function()
            local letters = GetCurrentGameWord2() or GetCurrentGameWord()
            if not IsMyTurn() and TypingWord then
                TypingWord = false
            end
            if letters ~= "" and Active and IsMyTurn() and not TypingWord then
                handleWord(letters)
            else
            end
        end)
    end)

    local initialLetters = GetCurrentGameWord2() or GetCurrentGameWord()
            if not IsMyTurn() and TypingWord then
                TypingWord = false
            end
    if initialLetters ~= "" and Active and IsMyTurn() and not TypingWord then
        handleWord(initialLetters)
    else
    end
end

while true do
    local initialLetters = GetCurrentGameWord2() or GetCurrentGameWord()
            if not IsMyTurn() and TypingWord then
                TypingWord = false
            end
    if initialLetters ~= "" and Active and IsMyTurn() and not TypingWord then
        handleWord(initialLetters)
    else
    end
task.wait(1)
end

    end
end)
