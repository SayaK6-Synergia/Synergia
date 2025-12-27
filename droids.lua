pcall(function()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--================ FATALITY / SYNERGIA ================

local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
local Notification = Fatality:CreateNotifier()

Fatality:Loader({
    Name = "Synergia - RGD",
    Duration = 3
})

local Window = Fatality.new({
    Name = "Synergia - RGD",
    Expire = "never",
})

local MainMenu = Window:AddMenu({
    Name = "RGD",
    Icon = "settings"
})

--================= FLAGS (TOGGLES) =================

getgenv().RGD_KillAllDroids     = false
getgenv().RGD_BringCircuits     = false
getgenv().RGD_AnchorDroids      = false
getgenv().RGD_UnAnchorDroids    = false
getgenv().RGD_LavaImmunity      = false
getgenv().RGD_WaterQuicksandImm = false
getgenv().RGD_AcidImmunity      = false
getgenv().RGD_SolidWater        = false
getgenv().RGD_SolidLava         = false
getgenv().RGD_PressButtons      = false
getgenv().RGD_BringGroundItems  = false
getgenv().RGD_AutoRoom          = false

-- flags hitbox enemigos
getgenv().HK6_Enabled = false
getgenv().HK6_Size    = 10
getgenv().HK6_Transp  = 0.4

local originalEnemyData = {}

--================= LOOPS =================

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_KillAllDroids then
            for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
                if v:IsA("Humanoid") and v.Parent.Name ~= LocalPlayer.Name then
                    v.Health = 0
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_BringCircuits then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
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
            for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
                if v:IsA("Part") and v.Name == "Head" then
                    v.Anchored = true
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().RGD_UnAnchorDroids then
            for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
                if v:IsA("Part") and v.Name == "Head" then
                    v.Anchored = false
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_LavaImmunity then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Lava" and v:FindFirstChild("TouchInterest") then
                    v.TouchInterest:Destroy()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_WaterQuicksandImm then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Killer" and v:FindFirstChild("TouchInterest") then
                    v.TouchInterest:Destroy()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_AcidImmunity then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Acid" and v:FindFirstChild("TouchInterest") then
                    v.TouchInterest:Destroy()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_SolidWater then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Water" then
                    v.CanCollide = true
                    v.Transparency = 0
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_SolidLava then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Lava" then
                    v.CanCollide = true
                    v.BrickColor = BrickColor.new("Cocoa")
                    v.Transparency = 0
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_PressButtons then
            for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
                if v.Name == "Button" and v:FindFirstChild("ClickDetector") then
                    fireclickdetector(v.ClickDetector)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().RGD_BringGroundItems then
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        v.Handle.CFrame = hrp.CFrame
                        v.Handle.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- loop hitbox enemigos
local function getEnemiesFolder()
    local room = workspace:FindFirstChild("Room")
    if not room then return nil end
    return room:FindFirstChild("Enemies")
end

local function applyEnemyHitbox(sizeVal, transparency)
    local enemiesFolder = getEnemiesFolder()
    if not enemiesFolder then return end

    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy:IsA("Model") then
            local root = enemy:FindFirstChild("HumanoidRootPart")
                       or enemy:FindFirstChild("Head")
                       or enemy.PrimaryPart
                       or enemy:FindFirstChildWhichIsA("BasePart", true)
            if root and root:IsA("BasePart") then
                if not originalEnemyData[root] then
                    originalEnemyData[root] = {
                        Size         = root.Size,
                        Transparency = root.Transparency,
                        CanCollide   = root.CanCollide,
                        Massless     = root.Massless
                    }
                end

                root.CanCollide = false
                root.Massless   = true

                if not sizeVal or sizeVal == 1 then
                    root.Size = Vector3.new(2, 1, 1)
                else
                    root.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
                end

                root.Transparency = transparency
            end
        end
    end
end

local function restoreEnemyHitbox()
    for part, data in pairs(originalEnemyData) do
        if part and part.Parent then
            part.Size         = data.Size
            part.Transparency = data.Transparency
            part.CanCollide   = data.CanCollide
            part.Massless     = data.Massless
        end
    end
    originalEnemyData = {}
end

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().HK6_Enabled then
            applyEnemyHitbox(getgenv().HK6_Size, getgenv().HK6_Transp)
        end
    end
end)

--================= SECCIONES UI =================

local DroidMenu = MainMenu:AddSection({
    Position = "left",
    Name = "Droids / Circuits"
})

local PuzzleMenu = MainMenu:AddSection({
    Position = "right",
    Name = "Puzzle Boxes"
})

local MapMenu = MainMenu:AddSection({
    Position = "left",
    Name = "Map"
})

local PlayerMenu = MainMenu:AddSection({
    Position = "right",
    Name = "Player"
})

--========== DROID / CIRCUITS (incluye hitbox) ==========

DroidMenu:AddToggle({
    Name = "Kill all Droids",
    Default = false,
    Callback = function(v)
        getgenv().RGD_KillAllDroids = v
    end
})

DroidMenu:AddToggle({
    Name = "Bring all Circuits",
    Default = false,
    Callback = function(v)
        getgenv().RGD_BringCircuits = v
    end
})

DroidMenu:AddToggle({
    Name = "Anchor all Droids",
    Default = false,
    Callback = function(v)
        getgenv().RGD_AnchorDroids = v
        if v then
            getgenv().RGD_UnAnchorDroids = false
        end
    end
})

DroidMenu:AddToggle({
    Name = "Un-Anchor all Droids",
    Default = false,
    Callback = function(v)
        getgenv().RGD_UnAnchorDroids = v
        if v then
            getgenv().RGD_AnchorDroids = false
        end
    end
})

DroidMenu:AddToggle({
    Name = "Auto Room (flag)",
    Default = false,
    Callback = function(v)
        getgenv().RGD_AutoRoom = v
    end
})

-- HITBOX ENEMIES

DroidMenu:AddToggle({
    Name = "Enemy HitboxK6",
    Default = false,
    Callback = function(v)
        getgenv().HK6_Enabled = v
        if not v then
            restoreEnemyHitbox()
        end
    end
})

DroidMenu:AddSlider({
    Name = "Hitbox Size",
    Min = 1,
    Max = 30,
    Default = 10,
    Callback = function(val)
        getgenv().HK6_Size = val
    end
})

DroidMenu:AddSlider({
    Name = "Hitbox Transparency",
    Min = 0,
    Max = 1,
    Default = 0.4,
    Callback = function(val)
        getgenv().HK6_Transp = val
    end
})

--================= PUZZLE BOXES =================

PuzzleMenu:AddButton({
    Name = "Solve Puzzles Red",
    Callback = function()
        for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
            if v.Name == "PuzzleBox 1" then
                v.Box.CFrame = workspace.Room.Enemies["PressurePlate 1"].Activator.CFrame
            end
        end
    end
})

PuzzleMenu:AddButton({
    Name = "Solve Puzzles Blue",
    Callback = function()
        for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
            if v.Name == "PuzzleBox 2" then
                v.Box.CFrame = workspace.Room.Enemies["PressurePlate 2"].Activator.CFrame
            end
        end
    end
})

PuzzleMenu:AddButton({
    Name = "Solve Puzzles Green",
    Callback = function()
        for _, v in pairs(workspace.Room.Enemies:GetDescendants()) do
            if v.Name == "PuzzleBox 3" then
                v.Box.CFrame = workspace.Room.Enemies["PressurePlate 3"].Activator.CFrame
            end
        end
    end
})

--================= MAP =================

MapMenu:AddToggle({
    Name = "Lava Immunity",
    Default = false,
    Callback = function(v)
        getgenv().RGD_LavaImmunity = v
    end
})

MapMenu:AddToggle({
    Name = "Water+QuickSand Immunity",
    Default = false,
    Callback = function(v)
        getgenv().RGD_WaterQuicksandImm = v
    end
})

MapMenu:AddToggle({
    Name = "Acid Immunity",
    Default = false,
    Callback = function(v)
        getgenv().RGD_AcidImmunity = v
    end
})

MapMenu:AddToggle({
    Name = "Solidify Water",
    Default = false,
    Callback = function(v)
        getgenv().RGD_SolidWater = v
    end
})

MapMenu:AddToggle({
    Name = "Solidify Lava",
    Default = false,
    Callback = function(v)
        getgenv().RGD_SolidLava = v
    end
})

MapMenu:AddToggle({
    Name = "Press all Buttons",
    Default = false,
    Callback = function(v)
        getgenv().RGD_PressButtons = v
    end
})

MapMenu:AddToggle({
    Name = "Bring all Items on Ground",
    Default = false,
    Callback = function(v)
        getgenv().RGD_BringGroundItems = v
    end
})

--================= PLAYER =================

PlayerMenu:AddSlider({
    Name = "WalkSpeed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(t)
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = t end
    end
})

PlayerMenu:AddSlider({
    Name = "JumpPower",
    Min = 0,
    Max = 300,
    Default = 50,
    Callback = function(t)
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = t end
    end
})

PlayerMenu:AddTextbox({
    Name = "Manual WalkSpeed",
    Default = "",
    PlaceholderText = "Type here!",
    Numeric = true,
    Callback = function(t)
        local val = tonumber(t)
        if not val then return end
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})

PlayerMenu:AddTextbox({
    Name = "Manual JumpPower",
    Default = "",
    PlaceholderText = "Type here!",
    Numeric = true,
    Callback = function(t)
        local val = tonumber(t)
        if not val then return end
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
})

PlayerMenu:AddButton({
    Name = "HitBox+ (Laggy)",
    Callback = function()
        local lp = Players.LocalPlayer
        local bp = lp and lp.Backpack
        if not bp then return end

        -- primer tool con Handle en la backpack
        local tool
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                tool = v
                break
            end
        end

        if tool then
            tool.Handle.Size = Vector3.new(60, 60, 60)
        end
    end
})

PlayerMenu:AddButton({
    Name = "Undo HitBox+",
    Callback = function()
        local lp = Players.LocalPlayer
        local bp = lp and lp.Backpack
        if not bp then return end

        local tool
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                tool = v
                break
            end
        end

        if tool then
            tool.Handle.Size = Vector3.new(1, 0.8, 5)
        end
    end
})


PlayerMenu:AddLabel({
    Text = "You must have the Copper Sword unequipped."
})

end)
