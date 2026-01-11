local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Synergia - RGD",
    Icon = 0,
    LoadingTitle = "Loading Synergia...",
    LoadingSubtitle = "by SayaK6",
    Theme = "Dark",

    DisableRayfieldPrompts = false,
    DisableMobileWindowMovable = false,
    Size = UDim2.new(0, 580, 0, 520),
    Transparency = 0.25,
    BlacklistedFrameNames = {"TopbarContainer"},
    BlacklistedGroupNames = {}
})

local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

-- ===== Principal =====
local autoKillEnabled   = false
local autoClickEnabled  = false
local autoShopEnabled   = false
local autoMysteryEnabled= false
local autoWinEnabled    = false
local autoArenaEnabled  = false

local lastKillTime   = 0
local lastClickTime  = 0
local lastShopTime   = 0
local lastMysteryTime= 0
local lastWinTime    = 0
local lastArenaTime  = 0

local killInterval   = 1
local clickInterval  = 2
local shopInterval   = 2
local mysteryInterval= 2
local winInterval    = 1
local arenaInterval  = 1

local mainHeartbeat  = nil

-- ===== Loops (getgenv) =====
getgenv().RGD_BringCircuits   = false
getgenv().RGD_AnchorDroids    = false
getgenv().RGD_UnAnchorDroids  = false
getgenv().RGD_BringOrnaments  = false

local function getCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char
end

-- ===== Loop principal =====
local function startMainLoop()
    if mainHeartbeat then
        mainHeartbeat:Disconnect()
    end

    mainHeartbeat = RunService.Heartbeat:Connect(function()
        local now         = tick()
        local currentRoom = workspace:FindFirstChild("Room")

        -- Auto Kill
        if autoKillEnabled and now - lastKillTime >= killInterval then
            lastKillTime = now
            if currentRoom then
                for _, obj in ipairs(currentRoom:GetDescendants()) do
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        hum.Health = 0
                    end
                end
            end
        end

        -- Auto Click
        if autoClickEnabled and now - lastClickTime >= clickInterval then
            lastClickTime = now
            if currentRoom then
                local enemies = currentRoom:FindFirstChild("Enemies")
                if enemies then
                    for _, button in ipairs(enemies:GetDescendants()) do
                        if button.Name == "Button" and button:IsA("BasePart") then
                            local cd = button:FindFirstChildOfClass("ClickDetector")
                            if cd then
                                cd.MaxActivationDistance = 999999
                                pcall(function() fireclickdetector(cd) end)
                            end
                            for _, d in ipairs(button:GetDescendants()) do
                                if d:IsA("ClickDetector") then
                                    if d:FindFirstChild("RemoteEvent") then
                                        pcall(function() d.RemoteEvent:FireServer() end)
                                    end
                                    pcall(function() fireclickdetector(d) end)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Auto Shop
        if autoShopEnabled and now - lastShopTime >= shopInterval then
            lastShopTime = now
            if currentRoom then
                for _, part in ipairs(currentRoom:GetDescendants()) do
                    if part.Name == "ShopButton" and part:IsA("BasePart") then
                        local cd = part:FindFirstChildOfClass("ClickDetector")
                        if cd then
                            cd.MaxActivationDistance = 999999
                            pcall(function() fireclickdetector(cd) end)
                        end
                        for _, d in ipairs(part:GetDescendants()) do
                            if d:IsA("ClickDetector") then
                                pcall(function() fireclickdetector(d) end)
                            end
                        end
                    end
                end
            end
        end

        -- Auto Mystery
        if autoMysteryEnabled and now - lastMysteryTime >= mysteryInterval then
            lastMysteryTime = now
            if currentRoom then
                for _, part in ipairs(currentRoom:GetDescendants()) do
                    if part.Name == "MysteryButton" and part:IsA("BasePart") then
                        local cd = part:FindFirstChildOfClass("ClickDetector")
                        if cd then
                            cd.MaxActivationDistance = 999999
                            pcall(function() fireclickdetector(cd) end)
                        end
                        for _, d in ipairs(part:GetDescendants()) do
                            if d:IsA("ClickDetector") then
                                pcall(function() fireclickdetector(d) end)
                            end
                        end
                    end
                end
            end
        end

        -- Auto Win
        if autoWinEnabled and now - lastWinTime >= winInterval then
            lastWinTime = now
            if currentRoom then
                for _, part in ipairs(currentRoom:GetDescendants()) do
                    if part.Name == "WinButton" and part:IsA("BasePart") then
                        local cd = part:FindFirstChildOfClass("ClickDetector")
                        if cd then
                            cd.MaxActivationDistance = 999999
                            pcall(function() fireclickdetector(cd) end)
                        end
                        for _, d in ipairs(part:GetDescendants()) do
                            if d:IsA("ClickDetector") then
                                d.MaxActivationDistance = 999999
                                pcall(function() fireclickdetector(d) end)
                            end
                        end
                    end
                end
            end
        end

        -- Auto Arena
        if autoArenaEnabled and now - lastArenaTime >= arenaInterval then
            lastArenaTime = now
            if currentRoom then
                for _, part in ipairs(currentRoom:GetDescendants()) do
                    if part.Name == "ArenaButton" and part:IsA("BasePart") then
                        local cd = part:FindFirstChildOfClass("ClickDetector")
                        if cd then
                            cd.MaxActivationDistance = 999999
                            pcall(function() fireclickdetector(cd) end)
                        end
                        for _, d in ipairs(part:GetDescendants()) do
                            if d:IsA("ClickDetector") then
                                d.MaxActivationDistance = 999999
                                pcall(function() fireclickdetector(d) end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===== Tab Principal =====
local MainTab = Window:CreateTab("🏠 Main", 4483362458)

MainTab:CreateLabel("Auto", {TextSize = 16})
MainTab:CreateDivider()

MainTab:CreateLabel("Script 1: Auto Kill (1s)")
local AutoKillToggle = MainTab:CreateToggle({
    Name = "AutoKillAura",
    CurrentValue = false,
    Flag = "AutoKill",
    Callback = function(v) autoKillEnabled = v if v then startMainLoop() end end,
})

MainTab:CreateDivider()
MainTab:CreateLabel("Script 2: Auto Click (2s)")
local AutoClickToggle = MainTab:CreateToggle({
    Name = "Auto Buttons",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(v) autoClickEnabled = v if v then startMainLoop() end end,
})

MainTab:CreateDivider()
MainTab:CreateLabel("Script 3: Auto Shop (2s)")
local AutoShopToggle = MainTab:CreateToggle({
    Name = "Auto Skip Shop",
    CurrentValue = false,
    Flag = "AutoShop",
    Callback = function(v) autoShopEnabled = v if v then startMainLoop() end end,
})

MainTab:CreateDivider()
MainTab:CreateLabel("Script 4: Auto Mystery (2s)")
local AutoMysteryToggle = MainTab:CreateToggle({
    Name = "auto Mystery Button",
    CurrentValue = false,
    Flag = "AutoMystery",
    Callback = function(v) autoMysteryEnabled = v if v then startMainLoop() end end,
})

MainTab:CreateDivider()
MainTab:CreateLabel("Script 5: Auto Win Button (1s)")
local AutoWinToggle = MainTab:CreateToggle({
    Name = "AutoFinalWin (boss button)",
    CurrentValue = false,
    Flag = "AutoFinalWin (boss button)",
    Callback = function(v) autoWinEnabled = v if v then startMainLoop() end end,
})

MainTab:CreateDivider()
MainTab:CreateLabel("Script 6: Auto Arena Button (1s)")
local AutoArenaToggle = MainTab:CreateToggle({
    Name = "AutoBoss",
    CurrentValue = false,
    Flag = "AutoBoss",
    Callback = function(v) autoArenaEnabled = v if v then startMainLoop() end end,
})

-- ===== Tab Config (simple) =====
local ConfigTab = Window:CreateTab("⚙️ Settings", 4483362458)

ConfigTab:CreateLabel("Turn Off all", {TextSize = 14})
ConfigTab:CreateButton({
    Name = "OFF all scripts",
    Callback = function()
        autoKillEnabled    = false
        autoClickEnabled   = false
        autoShopEnabled    = false
        autoMysteryEnabled = false
        autoWinEnabled     = false
        autoArenaEnabled   = false

        AutoKillToggle:Set(false)
        AutoClickToggle:Set(false)
        AutoShopToggle:Set(false)
        AutoMysteryToggle:Set(false)
        AutoWinToggle:Set(false)
        AutoArenaToggle:Set(false)

        if mainHeartbeat then
            mainHeartbeat:Disconnect()
            mainHeartbeat = nil
        end

        Rayfield:Notify({
            Title = "✓ Éxito",
            Content = "Todos los scripts han sido desactivados",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- ===== Tab Loops =====
local LoopsTab = Window:CreateTab("🔁 Loops", 4483362458)

LoopsTab:CreateLabel("Loops Circuits / Droids / Ornaments", {TextSize = 14})

LoopsTab:CreateToggle({
    Name = "Bring Circuits",
    CurrentValue = false,
    Flag = "RGD_BringCircuits",
    Callback = function(v) getgenv().RGD_BringCircuits = v end,
})

LoopsTab:CreateToggle({
    Name = "Anchor Droids",
    CurrentValue = false,
    Flag = "RGD_AnchorDroids",
    Callback = function(v) getgenv().RGD_AnchorDroids = v end,
})

LoopsTab:CreateToggle({
    Name = "Unanchor Droids",
    CurrentValue = false,
    Flag = "RGD_UnAnchorDroids",
    Callback = function(v) getgenv().RGD_UnAnchorDroids = v end,
})

LoopsTab:CreateToggle({
    Name = "Bring Ornaments (event)",
    CurrentValue = false,
    Flag = "RGD_BringOrnaments",
    Callback = function(v) getgenv().RGD_BringOrnaments = v end,
})

-- ===== Tab TPs =====
local TPTab = Window:CreateTab("📍 TPs", 4483362458)

TPTab:CreateLabel("Teleports", {TextSize = 14})

TPTab:CreateButton({
    Name = "TP NexusCrystal (chritsmas event final room)",
    Callback = function()
        task.spawn(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp  = char:WaitForChild("HumanoidRootPart")

            local room  = workspace:WaitForChild("Room")
            local nexus = room:WaitForChild("NexusCrystal")

            local offset = Vector3.new(0, 5, 0)
            hrp.CFrame = nexus.CFrame + offset
        end)
    end,
})

-- ===== Loops de getgenv =====
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_BringCircuits then
            local char = getCharacter()
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("UnionOperation") and v.Name == "Circuit" then
                        v.CFrame = hrp.CFrame
                        v.CanCollide = false
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_AnchorDroids then
            local room    = workspace:FindFirstChild("Room")
            local enemies = room and room:FindFirstChild("Enemies")
            if enemies then
                for _, v in pairs(enemies:GetDescendants()) do
                    if v:IsA("Part") and v.Name == "Head" then
                        v.Anchored = true
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_UnAnchorDroids then
            local room    = workspace:FindFirstChild("Room")
            local enemies = room and room:FindFirstChild("Enemies")
            if enemies then
                for _, v in pairs(enemies:GetDescendants()) do
                    if v:IsA("Part") and v.Name == "Head" then
                        v.Anchored = false
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_BringOrnaments then
            local char = getCharacter()
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, orn in ipairs(workspace:GetChildren()) do
                    if orn:IsA("Model") and orn.Name == "Ornament" then
                        local handle = orn:FindFirstChild("Handle")
                        if handle and handle:IsA("BasePart") then
                            handle.CFrame = hrp.CFrame
                            handle.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({
    Title = "✓ Cargado",
    Content = "Hub iniciado con Principal + Config + Loops + TPs.",
    Duration = 300,
    Image = 4483362458,
})
