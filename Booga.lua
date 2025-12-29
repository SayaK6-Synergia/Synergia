--[[ ==================== CORE ORIGINAL ==================== ]]

pcall(function()
--==================== SERVICES ====================

local rs              = game:GetService("ReplicatedStorage")
local Modules         = rs:WaitForChild("Modules")
local Packets         = require(Modules:WaitForChild("Packets"))
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player          = Players.LocalPlayer

--==================== CAMERA ZOOM UNLOCK (ALWAYS ON) ====================

player.CameraMaxZoomDistance = 1000
player.CameraMinZoomDistance = 0.5

task.spawn(function()
    while true do
        player.CameraMaxZoomDistance = 1000
        player.CameraMinZoomDistance = 0.5
        task.wait(1)
    end
end)

--==================== CONSTANTS & GLOBAL STATE ====================

local ITEMS_FOLDER     = workspace:WaitForChild("Items")
local PICKUP_DISTANCE  = 25

-- PlaceIds
local MAIN_PLACE_ID      = 11729688377
local DIMENSION_PLACE_ID = 11879754496
local STORY_PLACE_ID     = 18596007812
local TRADE_PLACE_ID     = 71090798546210
local BOSS_PLACE_ID      = 114178392375273

-- Auto heal + trader ESP
local HEAL_LOOPS     = 5
local HEAL_THRESHOLD = 0.9       -- 90% HP
local HEAL_COOLDOWN  = 0.016     -- ~1 frame
local BF_STRING      = "+\1\0"   -- bloodfruit buffer (ajustado)

local ByteNetReliable = rs:WaitForChild("ByteNetReliable")

local autoHealEnabled   = false
local traderESPEnabled  = false
local traderHighlight   = nil

-- States
local pickupActive        = false
local pickupLoop          = nil

local deleteItemsActive   = false
local deleteItemsLoop     = nil

local espActive           = false
local espLoop             = nil

local godEspActive        = false
local godEspLoop          = nil

local itemsEspActive      = false
local itemsEspLoop        = nil

local meteorEspActive     = false
local meteorEspLoop       = nil

local doorNoclipActive    = false
local doorNoclipLoop      = nil

local speedCFrameActive   = false
local speedValue          = 0.2030
local baseSpeedFactor     = 0.2030

local mapGodsEspActive    = false
local mapGodsEspLoop      = nil

local playersWithESP      = {}
local playersWithGodESP   = {}

local hitboxExpanderActive = false
local hitboxSizeValue      = 14
local hitboxTransparency   = 0.2

local cameraInvisicamActive = false

--==================== ITEM FILTERS ====================

local itemFilters = {
    ["Emerald"]       = true,
    ["Coal"]          = true,
    ["Crystal Chunk"] = true,
    ["Pink Diamond"]  = true,
    ["Raw Gold"]      = true,
    ["Adurite"]       = true,
    ["Gold"]          = true,
    ["Iron"]          = true,
    ["Spirit Key"]    = true,
    ["Steel"]         = true,
    ["Magnetite"]     = true,
    ["Essence"]       = true,
    ["Bloodfruit"]    = true,
    ["Coin2"]         = true,
    ["Void Shard"]    = true,
}

local autopickItemList = {
    "Gold",
    "Crystal Chunk",
    "Emerald",
    "Bloodfruit",
    "Void Shard",
    "Coal",
    "Iron",
    "Adurite",
    "Magnetite",
    "Essence",
    "Coin2",
    "Pink Diamond",
    "Raw Gold",
    "Steel",
    "Spirit Key",
}


-- Important items for ESP
local importantItemNames = {
    ["Gold"]          = true,
    ["Crystal Chunk"] = true,
}

-- Map gods names (workspace.Resources)
local mapGodNames = {
    ["Ancient God"]   = true,
    ["Furious God"]   = true,
    ["Hateful God"]   = true,
    ["Lonely God"]    = true,
    ["Miserable God"] = true,
    ["Old God"]       = true,
    ["Sleeping God"]  = true,
    ["Wealthy God"]   = true,
    ["Dark God"]      = true,
    ["Infinity God"]  = true,
    ["Magical God"]   = true,
    ["Odd God"]       = true,
    ["Strange God"]   = true,
}

local autopickFilters = {
    ["Gold"]          = true,
    ["Crystal Chunk"] = true,
    ["Emerald"]       = true,
    ["Bloodfruit"]    = false,
    ["Void Shard"]    = false,
}

local function getDistance(a, b)
    return (a.Position - b.Position).Magnitude
end

local function getTeamColor(otherPlayer)
    if otherPlayer.Team then
        return otherPlayer.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

--==================== HITBOX EXPANDER ====================

local originalHitboxData = {}

local function applyHitboxToPlayer(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    if not originalHitboxData[hrp] then
        originalHitboxData[hrp] = {
            Size         = hrp.Size,
            Transparency = hrp.Transparency,
            CanCollide   = hrp.CanCollide
        }
    end

    hrp.CanCollide   = false
    hrp.Size         = Vector3.new(hitboxSizeValue, hitboxSizeValue, hitboxSizeValue)
    hrp.Transparency = hitboxTransparency
end

local function restoreHitbox(plr)
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local data = originalHitboxData[hrp]
    if data then
        hrp.Size         = data.Size
        hrp.Transparency = data.Transparency
        hrp.CanCollide   = data.CanCollide
        originalHitboxData[hrp] = nil
    end
end

local function startHitboxLoop()
    task.spawn(function()
        while hitboxExpanderActive do
            task.wait(0.1)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    applyHitboxToPlayer(plr)
                end
            end
        end
    end)
end

local function stopHitbox()
    hitboxExpanderActive = false

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            restoreHitbox(plr)
        end
    end

    for hrp, data in pairs(originalHitboxData) do
        if hrp and hrp.Parent then
            hrp.Size         = data.Size
            hrp.Transparency = data.Transparency
            hrp.CanCollide   = data.CanCollide
        end
    end
    originalHitboxData = {}
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterRemoving:Connect(function()
        restoreHitbox(plr)
    end)
end)

--==================== PLAYER ESP ====================

local function startPlayerESP()
    if espLoop then task.cancel(espLoop) end
    playersWithESP = {}

    espLoop = task.spawn(function()
        while espActive do
            task.wait(0.1)

            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    local character = otherPlayer.Character
                    if character then
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        local hum = character:FindFirstChild("Humanoid")

                        if hrp and hum then
                            local teamColor = getTeamColor(otherPlayer)

                            local highlight = character:FindFirstChild("ESP_Highlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name                = "ESP_Highlight"
                                highlight.Adornee             = character
                                highlight.FillColor           = teamColor
                                highlight.OutlineColor        = teamColor
                                highlight.FillTransparency    = 0.7
                                highlight.OutlineTransparency = 0.3
                                highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent              = character
                            else
                                highlight.FillColor    = teamColor
                                highlight.OutlineColor = teamColor
                            end

                            local billboardGui = character:FindFirstChild("ESP_Label")
                            if not billboardGui then
                                billboardGui = Instance.new("BillboardGui")
                                billboardGui.Name         = "ESP_Label"
                                billboardGui.Adornee      = hrp
                                billboardGui.Size         = UDim2.new(0, 120, 0, 40)
                                billboardGui.StudsOffset  = Vector3.new(0, 3, 0)
                                billboardGui.MaxDistance  = math.huge
                                billboardGui.AlwaysOnTop  = true

                                local textLabel           = Instance.new("TextLabel")
                                textLabel.Name            = "PlayerInfo"
                                textLabel.Size            = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3      = teamColor
                                textLabel.TextSize        = 12
                                textLabel.Font            = Enum.Font.GothamBold
                                textLabel.TextStrokeTransparency = 0.3
                                textLabel.TextScaled      = false
                                textLabel.Parent          = billboardGui

                                billboardGui.Parent       = character
                            end

                            local label = billboardGui:FindFirstChild("PlayerInfo")
                            if label then
                                label.Text      = otherPlayer.Name .. " - " .. math.floor(hum.Health) .. " HP"
                                label.TextColor3 = teamColor
                            end

                            playersWithESP[otherPlayer.UserId] = true
                        end
                    end
                end
            end
        end
    end)
end

local function stopPlayerESP()
    if espLoop then task.cancel(espLoop) end

    task.wait(0.1)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "ESP_Highlight" or obj.Name == "ESP_Label" then
            pcall(function() obj:Destroy() end)
        end
    end

    playersWithESP = {}
end

--==================== GOD GEAR ESP ====================

local function playerHasGodGear(plr)
    local wsPlayers = workspace:FindFirstChild("Players")
    if not wsPlayers then return false end

    local charFolder = wsPlayers:FindFirstChild(plr.Name)
    if not charFolder then return false end

    local hasLegs  = charFolder:FindFirstChild("God Legs")
    local hasChest = charFolder:FindFirstChild("God Chestplate")
    local hasHalo  = charFolder:FindFirstChild("God Halo")

    return (hasLegs ~= nil) or (hasChest ~= nil) or (hasHalo ~= nil)
end

local function startGodGearESP()
    if godEspLoop then task.cancel(godEspLoop) end
    playersWithGodESP = {}

    godEspLoop = task.spawn(function()
        while godEspActive do
            task.wait(0.15)

            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player then
                    local character = otherPlayer.Character
                    if character and playerHasGodGear(otherPlayer) then
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        local hum = character:FindFirstChild("Humanoid")

                        if hrp and hum then
                            local teamColor = Color3.fromRGB(255, 215, 0)

                            local highlight = character:FindFirstChild("GOD_ESP_Highlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name                = "GOD_ESP_Highlight"
                                highlight.Adornee             = character
                                highlight.FillColor           = teamColor
                                highlight.OutlineColor        = teamColor
                                highlight.FillTransparency    = 0.5
                                highlight.OutlineTransparency = 0.1
                                highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent              = character
                            else
                                highlight.FillColor    = teamColor
                                highlight.OutlineColor = teamColor
                            end

                            local billboardGui = character:FindFirstChild("GOD_ESP_Label")
                            if not billboardGui then
                                billboardGui = Instance.new("BillboardGui")
                                billboardGui.Name        = "GOD_ESP_Label"
                                billboardGui.Adornee     = hrp
                                billboardGui.Size        = UDim2.new(0, 150, 0, 45)
                                billboardGui.StudsOffset = Vector3.new(0, 4, 0)
                                billboardGui.MaxDistance = math.huge
                                billboardGui.AlwaysOnTop = true

                                local textLabel           = Instance.new("TextLabel")
                                textLabel.Name            = "GodPlayerInfo"
                                textLabel.Size            = UDim2.new(1, 0, 1, 0)
                                textLabel.BackgroundTransparency = 1
                                textLabel.TextColor3      = teamColor
                                textLabel.TextSize        = 13
                                textLabel.Font            = Enum.Font.GothamBold
                                textLabel.TextStrokeTransparency = 0.2
                                textLabel.TextScaled      = false
                                textLabel.Parent          = billboardGui

                                billboardGui.Parent = character
                            end

                            local label = billboardGui:FindFirstChild("GodPlayerInfo")
                            if label then
                                label.Text       = "[GOD] " .. otherPlayer.Name .. " - " .. math.floor(hum.Health) .. " HP"
                                label.TextColor3 = teamColor
                            end

                            playersWithGodESP[otherPlayer.UserId] = true
                        end
                    end
                end
            end
        end
    end)
end

local function stopGodGearESP()
    if godEspLoop then task.cancel(godEspLoop) end
    task.wait(0.1)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GOD_ESP_Highlight" or obj.Name == "GOD_ESP_Label" then
            pcall(function() obj:Destroy() end)
        end
    end

    playersWithGodESP = {}
end

--==================== IMPORTANT ITEMS ESP ====================

local function getItemHighlightColor(name)
    if name == "Gold" then
        return Color3.fromRGB(255, 215, 0)
    elseif name == "Crystal Chunk" then
        return Color3.fromRGB(0, 255, 255)
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

local function startImportantItemsESP()
    if itemsEspLoop then task.cancel(itemsEspLoop) end

    itemsEspLoop = task.spawn(function()
        while itemsEspActive do
            task.wait(0.15)

            for _, item in ipairs(ITEMS_FOLDER:GetChildren()) do
                if importantItemNames[item.Name] then
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local highlight = part:FindFirstChild("ITEM_ESP_Highlight")
                        local color     = getItemHighlightColor(item.Name)

                        if not highlight then
                            highlight                     = Instance.new("Highlight")
                            highlight.Name                = "ITEM_ESP_Highlight"
                            highlight.Adornee             = part
                            highlight.FillColor           = color
                            highlight.OutlineColor        = color
                            highlight.FillTransparency    = 0.6
                            highlight.OutlineTransparency = 0.1
                            highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent              = part
                        else
                            highlight.FillColor    = color
                            highlight.OutlineColor = color
                        end

                        local billboardGui = part:FindFirstChild("ITEM_ESP_Label")
                        if not billboardGui then
                            billboardGui = Instance.new("BillboardGui")
                            billboardGui.Name        = "ITEM_ESP_Label"
                            billboardGui.Adornee     = part
                            billboardGui.Size        = UDim2.new(0, 120, 0, 30)
                            billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
                            billboardGui.MaxDistance = math.huge
                            billboardGui.AlwaysOnTop = true

                            local textLabel           = Instance.new("TextLabel")
                            textLabel.Name            = "ItemInfo"
                            textLabel.Size            = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextColor3      = color
                            textLabel.TextSize        = 12
                            textLabel.Font            = Enum.Font.GothamBold
                            textLabel.TextStrokeTransparency = 0.3
                            textLabel.TextScaled      = false
                            textLabel.Parent          = billboardGui

                            billboardGui.Parent = part
                        end

                        local label = billboardGui:FindFirstChild("ItemInfo")
                        if label then
                            label.Text       = item.Name
                            label.TextColor3 = color
                        end
                    end
                end
            end
        end
    end)
end

local function stopImportantItemsESP()
    if itemsEspLoop then task.cancel(itemsEspLoop) end

    task.wait(0.1)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "ITEM_ESP_Highlight" or obj.Name == "ITEM_ESP_Label" then
            pcall(function() obj:Destroy() end)
        end
    end
end

--==================== METEOR CORE ESP ====================

local function startMeteorESP()
    if meteorEspLoop then task.cancel(meteorEspLoop) end

    meteorEspLoop = task.spawn(function()
        while meteorEspActive do
            task.wait(0.2)

            local function handleMeteor(obj)
                if not obj then return end
                if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end

                local adornee = obj
                if obj:IsA("Model") then
                    adornee = obj:FindFirstChildWhichIsA("BasePart", true) or obj
                end
                if not adornee then return end

                local highlight = adornee:FindFirstChild("METEOR_ESP_Highlight")
                if not highlight then
                    highlight                     = Instance.new("Highlight")
                    highlight.Name                = "METEOR_ESP_Highlight"
                    highlight.Adornee             = adornee
                    highlight.FillColor           = Color3.fromRGB(255, 100, 100)
                    highlight.OutlineColor        = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency    = 0.5
                    highlight.OutlineTransparency = 0.1
                    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent              = adornee
                end

                local billboardGui = adornee:FindFirstChild("METEOR_ESP_Label")
                if not billboardGui then
                    billboardGui = Instance.new("BillboardGui")
                    billboardGui.Name        = "METEOR_ESP_Label"
                    billboardGui.Adornee     = adornee
                    billboardGui.Size        = UDim2.new(0, 140, 0, 35)
                    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
                    billboardGui.MaxDistance = math.huge
                    billboardGui.AlwaysOnTop = true

                    local textLabel           = Instance.new("TextLabel")
                    textLabel.Name            = "MeteorInfo"
                    textLabel.Size            = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3      = Color3.fromRGB(255, 80, 80)
                    textLabel.TextSize        = 13
                    textLabel.Font            = Enum.Font.GothamBold
                    textLabel.TextStrokeTransparency = 0.2
                    textLabel.TextScaled      = false
                    textLabel.Text            = obj.Name
                    textLabel.Parent          = billboardGui

                    billboardGui.Parent = adornee
                else
                    local lbl = billboardGui:FindFirstChild("MeteorInfo")
                    if lbl then
                        lbl.Text = obj.Name
                    end
                end
            end

            handleMeteor(workspace:FindFirstChild("Meteor Core"))
            handleMeteor(workspace:FindFirstChild("Crystal Meteor Core"))
        end
    end)
end

local function stopMeteorESP()
    if meteorEspLoop then task.cancel(meteorEspLoop) end

    task.wait(0.1)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "METEOR_ESP_Highlight" or obj.Name == "METEOR_ESP_Label" then
            pcall(function() obj:Destroy() end)
        end
    end
end

--==================== MAP GODS ESP ====================

local function startMapGodsESP()
    if mapGodsEspLoop then task.cancel(mapGodsEspLoop) end

    mapGodsEspLoop = task.spawn(function()
        while mapGodsEspActive do
            task.wait(0.3)

            local resources = workspace:FindFirstChild("Resources")
            if not resources then continue end

            for _, inst in ipairs(resources:GetChildren()) do
                if mapGodNames[inst.Name] then
                    local adornee = inst
                    if inst:IsA("Model") then
                        adornee = inst:FindFirstChildWhichIsA("BasePart", true) or inst
                    end
                    if not adornee then continue end

                    local highlight = adornee:FindFirstChild("MAP_GOD_ESP_Highlight")
                    if not highlight then
                        highlight                     = Instance.new("Highlight")
                        highlight.Name                = "MAP_GOD_ESP_Highlight"
                        highlight.Adornee             = adornee
                        highlight.FillColor           = Color3.fromRGB(150, 0, 255)
                        highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency    = 0.5
                        highlight.OutlineTransparency = 0.1
                        highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent              = adornee
                    end

                    local billboardGui = adornee:FindFirstChild("MAP_GOD_ESP_Label")
                    if not billboardGui then
                        billboardGui = Instance.new("BillboardGui")
                        billboardGui.Name        = "MAP_GOD_ESP_Label"
                        billboardGui.Adornee     = adornee
                        billboardGui.Size        = UDim2.new(0, 160, 0, 35)
                        billboardGui.StudsOffset = Vector3.new(0, 5, 0)
                        billboardGui.MaxDistance = math.huge
                        billboardGui.AlwaysOnTop = true

                        local textLabel           = Instance.new("TextLabel")
                        textLabel.Name            = "MapGodInfo"
                        textLabel.Size            = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3      = Color3.fromRGB(200, 150, 255)
                        textLabel.TextSize        = 13
                        textLabel.Font            = Enum.Font.GothamBold
                        textLabel.TextStrokeTransparency = 0.2
                        textLabel.TextScaled      = false
                        textLabel.Text            = inst.Name
                        textLabel.Parent          = billboardGui

                        billboardGui.Parent = adornee
                    else
                        local lbl = billboardGui:FindFirstChild("MapGodInfo")
                        if lbl then
                            lbl.Text = inst.Name
                        end
                    end
                end
            end
        end
    end)
end

local function stopMapGodsESP()
    if mapGodsEspLoop then task.cancel(mapGodsEspLoop) end
    mapGodsEspLoop = nil

    task.wait(0.1)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MAP_GOD_ESP_Highlight" or obj.Name == "MAP_GOD_ESP_Label" then
            pcall(function() obj:Destroy() end)
        end
    end
end

--==================== AUTOPICKUP VACUUM ====================

local function startPickupLoop()
    if pickupLoop then
        task.cancel(pickupLoop)
    end

    pickupLoop = task.spawn(function()
        while pickupActive do
            task.wait(0.1)

            local char = player.Character
            if not char then
                continue
            end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                continue
            end

            for _, item in ipairs(ITEMS_FOLDER:GetChildren()) do
                local itemName = item.Name
                if autopickFilters[itemName] then
                    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= PICKUP_DISTANCE then
                            local entityId = item:GetAttribute("EntityID")
                            if entityId then
                                pcall(function()
                                    Packets.Pickup.send(entityId)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopPickupLoop()
    pickupActive = false
    if pickupLoop then
        task.cancel(pickupLoop)
        pickupLoop = nil
    end
end

--==================== WANDERING TRADER ESP ====================

local function getWanderingTrader()
    local ok, npc = pcall(function()
        return workspace.DialogNPCs.Normal["Wandering Trader"]
    end)
    if ok and npc and npc:IsA("Model") then
        return npc
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not traderESPEnabled then
        if traderHighlight then
            traderHighlight:Destroy()
            traderHighlight = nil
        end
        return
    end

    local trader = getWanderingTrader()
    if not trader then
        if traderHighlight then
            traderHighlight:Destroy()
            traderHighlight = nil
        end
        return
    end

    if not traderHighlight then
        traderHighlight                      = Instance.new("Highlight")
        traderHighlight.FillColor            = Color3.fromRGB(255, 0, 255)
        traderHighlight.OutlineColor         = Color3.fromRGB(255, 255, 255)
        traderHighlight.FillTransparency     = 0.5
        traderHighlight.OutlineTransparency  = 0
        traderHighlight.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop
        traderHighlight.Parent               = trader
    end

    traderHighlight.Adornee = trader
end)

--==================== DOOR NOCLIP (OPTIMIZED) ====================

local function applyDoorNoclipOnce()
    local deployables = workspace:FindFirstChild("Deployables")
    if not deployables then return end

    for _, dep in ipairs(deployables:GetChildren()) do
        for _, obj in ipairs(dep:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Door" then
                if obj:GetAttribute("OriginalDoorCollide") == nil then
                    obj:SetAttribute("OriginalDoorCollide", obj.CanCollide)
                end
                if obj:GetAttribute("OriginalDoorTransparency") == nil then
                    obj:SetAttribute("OriginalDoorTransparency", obj.Transparency)
                end
                obj.CanCollide   = false
                obj.Transparency = 0.8
            end
        end

        for _, obj in ipairs(dep:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Door" then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part:GetAttribute("OriginalDoorCollide") == nil then
                            part:SetAttribute("OriginalDoorCollide", part.CanCollide)
                        end
                        if part:GetAttribute("OriginalDoorTransparency") == nil then
                            part:SetAttribute("OriginalDoorTransparency", part.Transparency)
                        end
                        part.CanCollide   = false
                        part.Transparency = 0.8
                    end
                end
            end
        end
    end
end

local function restoreDoors()
    local deployables = workspace:FindFirstChild("Deployables")
    if not deployables then return end

    local restored = 0

    for _, dep in ipairs(deployables:GetChildren()) do
        for _, obj in ipairs(dep:GetDescendants()) do
            if obj:IsA("BasePart") then
                local oc = obj:GetAttribute("OriginalDoorCollide")
                local ot = obj:GetAttribute("OriginalDoorTransparency")
                if oc ~= nil or ot ~= nil then
                    if oc ~= nil then
                        obj.CanCollide = oc
                        obj:SetAttribute("OriginalDoorCollide", nil)
                    end
                    if ot ~= nil then
                        obj.Transparency = ot
                        obj:SetAttribute("OriginalDoorTransparency", nil)
                    end
                    restored += 1
                end
            end
        end
    end
end

local function setDoorNoclipOptimized(enabled)
    doorNoclipActive = enabled

    if enabled then
        if doorNoclipLoop then
            task.cancel(doorNoclipLoop)
            doorNoclipLoop = nil
        end

        doorNoclipLoop = task.spawn(function()
            while doorNoclipActive do
                applyDoorNoclipOnce()
                task.wait(0.5)
            end
        end)
    else
        if doorNoclipLoop then
            task.cancel(doorNoclipLoop)
            doorNoclipLoop = nil
        end
        restoreDoors()
    end
end

--==================== SPEED CFRAME ====================

RunService.RenderStepped:Connect(function(dt)
    if not speedCFrameActive then return end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude > 0 then
        local delta = moveDir.Unit * speedValue * baseSpeedFactor
        hrp.CFrame = hrp.CFrame + Vector3.new(delta.X, 0, delta.Z)
    end
end)

--==================== CAMERA INVISICAM ====================

local localPlayer           = Players.LocalPlayer
local originalOcclusionMode = localPlayer.DevCameraOcclusionMode

local function startCameraInvisicam()
    cameraInvisicamActive   = true
    originalOcclusionMode   = localPlayer.DevCameraOcclusionMode
    localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
end

local function stopCameraInvisicam()
    cameraInvisicamActive   = false
    localPlayer.DevCameraOcclusionMode = originalOcclusionMode
end

--==================== FORCE CHARACTER CLIP ====================

local function forceCharacterClip()
    local char = player.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
            if part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0
            end
        end
    end
end

--==================== AUTO HEAL BLOODFRUIT x5 ====================

local function startHealLoop(id)
    task.spawn(function()
        local lastHeal = 0
        while true do
            task.wait()

            if not autoHealEnabled then
                continue
            end

            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                continue
            end

            local hp    = hum.Health
            local maxhp = hum.MaxHealth
            if maxhp <= 0 then
                continue
            end

            local ratio = hp / maxhp
            if ratio <= HEAL_THRESHOLD and (tick() - lastHeal) >= HEAL_COOLDOWN then
                lastHeal = tick()
                pcall(function()
                    ByteNetReliable:FireServer(buffer.fromstring(BF_STRING))
                end)
            end
        end
    end)
end

for i = 1, HEAL_LOOPS do
    startHealLoop(i)
end

--==================== DELETE ALL ITEMS ====================

local function startDeleteItemsLoop()
    if deleteItemsLoop then task.cancel(deleteItemsLoop) end

    deleteItemsLoop = task.spawn(function()
        while deleteItemsActive do
            task.wait(0.2)

            for _, item in ipairs(ITEMS_FOLDER:GetChildren()) do
                pcall(function()
                    item:Destroy()
                end)
            end
        end
    end)
end

local function stopDeleteItemsLoop()
    deleteItemsActive = false
    if deleteItemsLoop then
        task.cancel(deleteItemsLoop)
        deleteItemsLoop = nil
    end
end

--[[ ==================== UI FATALITY SYNERGIA ==================== ]]

local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
local Notification = Fatality:CreateNotifier()

Fatality:Loader({
    Name = "Synergia",
    Duration = 3
})

local Window = Fatality.new({
    Name = "Synergia",
    Expire = "02/10/####",
})

local Farm = Window:AddMenu({
    Name = "FARM",
    Icon = "leaf"
})

local Misc = Window:AddMenu({
    Name = "MISC",
    Icon = "settings"
})

local Visual = Window:AddMenu({
    Name = "VISUAL",
    Icon = "eye"
})

-- VOID TELEPORT
local Void = Window:AddMenu({
    Name = "Void",
    Icon = "🌌"
})

local VoidSection = Void:AddSection({
    Position = "left",
    Name = "TELEPORTS"
})

VoidSection:AddButton({
    Name = "🚀 Tp Void (11879754496)",
    Callback = function()
        Notification:Notify({
            Title = "Teleporting...",
            Content = "Loading Void Dimension...",
            Duration = 3,
            Icon = "zap"
        })
        TeleportService:Teleport(11879754496)
    end
})


-- FARM: AUTOPICKUP + HEAL + SPEED

do
    local FarmSection = Farm:AddSection({
        Position = "left",
        Name = "AUTOFARM"
    })

    FarmSection:AddToggle({
        Name = "🧲 Autopickup Vacuum",
        Default = false,
        Callback = function(value)
            pickupActive = value
            if value then
                startPickupLoop()
                Notification:Notify({
                    Title = "Autopickup ON",
                    Content = "Vacuum enabled.",
                    Duration = 3,
                    Icon = "magnet"
                })
            else
                stopPickupLoop()
                Notification:Notify({
                    Title = "Autopickup OFF",
                    Content = "Vacuum disabled.",
                    Duration = 2,
                    Icon = "magnet"
                })
            end
        end
    })

    local HealSection = Farm:AddSection({
        Position = "center",
        Name = "SURVIVAL"
    })

    HealSection:AddToggle({
        Name = "💉 AutoHeal (Bloodfruit x5)",
        Default = false,
        Callback = function(value)
            autoHealEnabled = value
            Notification:Notify({
                Title = value and "AutoHeal ON" or "AutoHeal OFF",
                Content = value and "Healing below threshold with Bloodfruit." or "Auto heal disabled.",
                Duration = 3,
                Icon = "activity"
            })
        end
    })

    HealSection:AddSlider({
        Name = "HP threshold (%)",
        Default = 90,
        Min = 10,
        Max = 100,
        Callback = function(val)
            HEAL_THRESHOLD = val / 100
        end
    })

    HealSection:AddSlider({
        Name = "Cooldown (s)",
        Default = 0.02,
        Min = 0.01,
        Max = 1,
        Callback = function(val)
            HEAL_COOLDOWN = val
        end
    })

    local MoveSection = Farm:AddSection({
        Position = "right",
        Name = "MOVEMENT"
    })

    MoveSection:AddToggle({
        Name = "⚡ Speed CFrame",
        Default = false,
        Callback = function(value)
            speedCFrameActive = value
            Notification:Notify({
                Title = value and "Speed ON" or "Speed OFF",
                Content = value and "CFrame speed enabled." or "CFrame speed disabled.",
                Duration = 3,
                Icon = value and "zap" or "zap-off"
            })
        end
    })

    MoveSection:AddSlider({
        Name = "Speed multiplier (raw)",
        Default = 0.2030,
        Min = 0.0,
        Max = 0.4000,
        Callback = function(val)
            speedValue = val
            baseSpeedFactor = val
        end
    })
end

    -- Autopick item filters
    local ItemsSection = Farm:AddSection({
        Position = "left",
        Name = "AUTOPICK ITEMS"
    })

    for _, itemName in ipairs(autopickItemList) do
        -- valor inicial desde autopickFilters (default false si nil)
        local defaultState = autopickFilters[itemName] == true

        ItemsSection:AddToggle({
            Name = itemName,
            Default = defaultState,
            Callback = function(state)
                autopickFilters[itemName] = state and true or false
            end
        })
    end


-- MISC: WORLD + CAMERA

do
    local WorldSection = Misc:AddSection({
        Position = "left",
        Name = "WORLD"
    })

    WorldSection:AddToggle({
        Name = "🚪 Door Noclip",
        Default = false,
        Callback = function(value)
            setDoorNoclipOptimized(value)
            Notification:Notify({
                Title = value and "Door Noclip ON" or "Door Noclip OFF",
                Content = value and "Doors have no collision." or "Doors restored.",
                Duration = 3,
                Icon = value and "door-open" or "door-closed"
            })
        end
    })

    WorldSection:AddToggle({
        Name = "🗑️ Delete Items",
        Default = false,
        Callback = function(value)
            deleteItemsActive = value
            if value then
                startDeleteItemsLoop()
            else
                stopDeleteItemsLoop()
            end
            Notification:Notify({
                Title = value and "Delete Items ON" or "Delete Items OFF",
                Content = value and "Deleting ground items." or "Stopped deleting items.",
                Duration = 3,
                Icon = "trash"
            })
        end
    })

    local CamSection = Misc:AddSection({
        Position = "right",
        Name = "CAMERA"
    })

    CamSection:AddToggle({
        Name = "👁️ Invisicam (No-clip cam)",
        Default = false,
        Callback = function(value)
            if value then
                startCameraInvisicam()
            else
                stopCameraInvisicam()
            end
            Notification:Notify({
                Title = value and "Invisicam ON" or "Invisicam OFF",
                Content = value and "Camera can clip through objects." or "Camera restored.",
                Duration = 3,
                Icon = value and "camera" or "camera-off"
            })
        end
    })

    CamSection:AddButton({
        Name = "Fix Character Clip",
        Callback = function()
            forceCharacterClip()
        end
    })
end

-- VISUAL: ALL ESP + HITBOX

do
    local EspSection = Visual:AddSection({
        Position = "left",
        Name = "ESP"
    })

    EspSection:AddToggle({
        Name = "👥 Player ESP",
        Default = false,
        Callback = function(value)
            espActive = value
            if value then
                startPlayerESP()
            else
                stopPlayerESP()
            end
            Notification:Notify({
                Title = "Player ESP",
                Content = value and "Players highlighted." or "Player ESP disabled.",
                Duration = 3,
                Icon = "users"
            })
        end
    })

    EspSection:AddToggle({
        Name = "👑 God Gear ESP",
        Default = false,
        Callback = function(value)
            godEspActive = value
            if value then
                startGodGearESP()
            else
                stopGodGearESP()
            end
            Notification:Notify({
                Title = "God Gear ESP",
                Content = value and "Players with God Gear highlighted." or "God Gear ESP disabled.",
                Duration = 3,
                Icon = "star"
            })
        end
    })

    EspSection:AddToggle({
        Name = "📦 Important Items ESP",
        Default = false,
        Callback = function(value)
            itemsEspActive = value
            if value then
                startImportantItemsESP()
            else
                stopImportantItemsESP()
            end
            Notification:Notify({
                Title = "Items ESP",
                Content = value and "Important items highlighted." or "Items ESP disabled.",
                Duration = 3,
                Icon = "package"
            })
        end
    })

    EspSection:AddToggle({
        Name = "☄️ Meteor Core ESP",
        Default = false,
        Callback = function(value)
            meteorEspActive = value
            if value then
                startMeteorESP()
            else
                stopMeteorESP()
            end
            Notification:Notify({
                Title = "Meteor ESP",
                Content = value and "Meteor cores highlighted." or "Meteor ESP disabled.",
                Duration = 3,
                Icon = "target"
            })
        end
    })

    EspSection:AddToggle({
        Name = "👼 Map Gods ESP",
        Default = false,
        Callback = function(value)
            mapGodsEspActive = value
            if value then
                startMapGodsESP()
            else
                stopMapGodsESP()
            end
            Notification:Notify({
                Title = "Map Gods ESP",
                Content = value and "Map gods highlighted." or "Map Gods ESP disabled.",
                Duration = 3,
                Icon = "crosshair"
            })
        end
    })

    EspSection:AddToggle({
        Name = "🧑‍🌾 Trader ESP",
        Default = false,
        Callback = function(value)
            traderESPEnabled = value
            Notification:Notify({
                Title = "Trader ESP",
                Content = value and "Wandering Trader highlighted." or "Trader ESP disabled.",
                Duration = 3,
                Icon = "eye"
            })
        end
    })

    EspSection:AddToggle({
        Name = "📏 Hitbox Expander",
        Default = false,
        Callback = function(value)
            hitboxExpanderActive = value
            if value then
                startHitboxLoop()
            else
                stopHitbox()
            end
            Notification:Notify({
                Title = "Hitbox Expander",
                Content = value and "Enemy hitboxes expanded." or "Hitboxes restored.",
                Duration = 3,
                Icon = "square"
            })
        end
    })
end

end)


