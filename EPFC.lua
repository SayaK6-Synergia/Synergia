-- // CARGAR FATALITY
local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))();
local Notification = Fatality:CreateNotifier();

Fatality:Loader({
    Name = "Synergia",
    Duration = 4
});

Notification:Notify({
    Title = "Synergia",
    Content = "Hello, "..game.Players.LocalPlayer.DisplayName..' Welcome back!',
    Icon = "clipboard"
})

local Window = Fatality.new({
    Name = "Synergia",
    Expire = "never",
});

-- Tab VISUAL (ESP)
local Visual = Window:AddMenu({
    Name = "VISUAL",
    Icon = "eye"
})

-- Tab README (info personalizada)
local Readme = Window:AddMenu({
    Name = "README",
    Icon = "info"
})

---------------------------------------------------------------------
-- ========================= ESP LOGIC =============================
---------------------------------------------------------------------
-- CONFIG
local LEVEL = workspace:WaitForChild("Level")

-- IDs numéricos de camisas especiales
local GUARD_SHIRT_ID_NUM    = "4626167333"  -- guardia normal (azul)
local RYAN_SHIRT_ID_NUM     = "4012473058"  -- Ryan blanco
local GUARD2_SHIRT_ID_NUM   = "12069799"    -- Guard2 café
local SWAT_SHIRT_ID_NUM     = "4622401121"  -- SWAT gris
local MANAGER3_SHIRT_ID_NUM = "5499076"     -- Manager3 morado

-- ID numérico del mesh de pelo de Manager3
local MANAGER3_HAIR_MESH_ID_NUM = "85783762802903"

local ROLES = {
    Manager = {
        ItemName   = "ManagerOfficeKey",
        ExtraItems = {},
        Label      = "MANAGER",
        Color      = Color3.fromRGB(0, 255, 0)
    },
    Guard = {
        ItemName   = "SecurityKeycard",
        ExtraItems = { "BasicKeycard" },
        Label      = "GUARD",
        Color      = Color3.fromRGB(0, 170, 255)
    },
    GuardMaster = {
        ItemName   = "MasterKey",
        ExtraItems = {},
        Label      = "GUARD MASTER",
        Color      = Color3.fromRGB(255, 170, 0)
    }
}

local CIVILIAN_ROLE = {
    Name  = "Civilian",
    Label = "CIVILIAN",
    Color = Color3.fromRGB(255, 255, 255)
}

local ID_ATTRIBUTE_NAME = "v824"

-- obtener InstanceX
local function getCurrentInstanceFolder()
    for _, child in ipairs(LEVEL:GetChildren()) do
        if child:IsA("Folder") and string.sub(child.Name, 1, 8) == "Instance" then
            return child
        end
    end
    return nil
end

local INSTANCE = getCurrentInstanceFolder()
while not INSTANCE do
    task.wait(0.1)
    INSTANCE = getCurrentInstanceFolder()
end

local BOT_MODEL = INSTANCE:WaitForChild("BotModel")
local BOT_DATA  = INSTANCE:WaitForChild("BotData")

-- TOGGLES STATE
local ESP_ENABLED = true
local ROLE_TOGGLES = {
    Manager    = true,
    Guard      = true,
    Guard2     = true,
    GuardMaster= true,
    Ryan       = true,
    SWAT       = true,
    Manager3   = true,
    Civilian   = true
}

-- VISUAL ELEMENTS
local function createBillboard(part, text, color, roleName)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RoleESP_"..roleName
    billboard.Size = UDim2.new(0, 130, 0, 22)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.MaxDistance = 500

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    billboard.Parent = part
end

local function createHighlight(model, color, roleName)
    local old = model:FindFirstChild("RoleHighlight_"..roleName)
    if old then old:Destroy() end

    local highlight = Instance.new("Highlight")
    highlight.Name = "RoleHighlight_"..roleName
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.FillTransparency = 0.75
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
end

local function clearESPForAllRoles(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BillboardGui") and string.find(v.Name, "RoleESP_") then
            v:Destroy()
        end
    end
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") and string.find(child.Name, "RoleHighlight_") then
            child:Destroy()
        end
    end
end

local function clearESPByRole(roleName)
    for _, bot in ipairs(BOT_MODEL:GetChildren()) do
        if bot:IsA("Model") then
            local head = bot:FindFirstChild("Head") or bot:FindFirstChild("HumanoidRootPart")
            if head then
                local gui = head:FindFirstChild("RoleESP_"..roleName)
                if gui then gui:Destroy() end
            end
            local h = bot:FindFirstChild("RoleHighlight_"..roleName)
            if h then h:Destroy() end
        end
    end
end

-- clothing helpers
local function getClothingId(botModel)
    local shirt = botModel:FindFirstChildOfClass("Shirt")
        or botModel:FindFirstChildOfClass("ShirtGraphic")
        or botModel:FindFirstChildOfClass("Pants")

    if not shirt then return nil end

    local template = shirt.ShirtTemplate or shirt.Graphic or shirt.PantsTemplate
    if not template then return nil end

    return template:match("%d+")
end

local function hasGuardShirt(botModel)
    return getClothingId(botModel) == GUARD_SHIRT_ID_NUM
end

local function hasRyanShirt(botModel)
    return getClothingId(botModel) == RYAN_SHIRT_ID_NUM
end

local function hasGuard2Shirt(botModel)
    return getClothingId(botModel) == GUARD2_SHIRT_ID_NUM
end

local function hasSwatShirt(botModel)
    return getClothingId(botModel) == SWAT_SHIRT_ID_NUM
end

local function hasManager3Shirt(botModel)
    return getClothingId(botModel) == MANAGER3_SHIRT_ID_NUM
end

-- hair check
local function hasManager3Hair(botModel)
    local accessoriesFolder = botModel:FindFirstChild("Accessories")
    if not accessoriesFolder then return false end

    for _, desc in ipairs(accessoriesFolder:GetDescendants()) do
        if desc:IsA("SpecialMesh") or desc:IsA("MeshPart") then
            local meshId = desc.MeshId or desc.MeshID or ""
            local num = meshId:match("%d+")
            if num == MANAGER3_HAIR_MESH_ID_NUM then
                return true
            end
        end
    end
    return false
end

-- role logic
local function getRole(botModel)
    -- PRIORIDAD 1: ropa / pelo
    if hasSwatShirt(botModel) then
        return "SWAT", "SWAT", Color3.fromRGB(150,150,150)
    end

    if hasManager3Shirt(botModel) and hasManager3Hair(botModel) then
        return "Manager3", "MANAGER3", Color3.fromRGB(170,0,255)
    end

    if hasRyanShirt(botModel) then
        return "Ryan", "RYAN", Color3.fromRGB(255,255,255)
    end

    if hasGuard2Shirt(botModel) then
        return "Guard2", "GUARD2", Color3.fromRGB(181,140,90)
    end

    -- PRIORIDAD 2: items
    local idAttr = botModel:GetAttribute(ID_ATTRIBUTE_NAME)
    local dataFolder, inv
    if idAttr then
        dataFolder = BOT_DATA:FindFirstChild(tostring(idAttr))
        if dataFolder then
            inv = dataFolder:FindFirstChild("Inv")
        end
    end

    local order = {"GuardMaster","Guard","Manager"}
    for _, roleName in ipairs(order) do
        local def = ROLES[roleName]
        if def then
            local hasItem = false
            if inv then
                if inv:FindFirstChild(def.ItemName) then
                    hasItem = true
                else
                    for _, extra in ipairs(def.ExtraItems or {}) do
                        if inv:FindFirstChild(extra) then
                            hasItem = true
                            break
                        end
                    end
                end
            end
            if roleName == "Guard" and not hasItem and hasGuardShirt(botModel) then
                hasItem = true
            end
            if hasItem then
                return roleName, def.Label, def.Color
            end
        end
    end

    return "Civilian", CIVILIAN_ROLE.Label, CIVILIAN_ROLE.Color
end

local function applyESPToBot(botModel)
    clearESPForAllRoles(botModel)
    if not ESP_ENABLED then return end

    local roleKey, label, color = getRole(botModel)
    if not roleKey then return end
    if ROLE_TOGGLES[roleKey] == false then return end

    local head = botModel:FindFirstChild("Head") or botModel:FindFirstChild("HumanoidRootPart")
    if head and head:IsA("BasePart") then
        createBillboard(head, label, color, roleKey)
        createHighlight(botModel, color, roleKey)
    end
end

-- inicial
for _, bot in ipairs(BOT_MODEL:GetChildren()) do
    if bot:IsA("Model") then
        applyESPToBot(bot)
    end
end

BOT_MODEL.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        task.wait(0.1)
        applyESPToBot(child)
    end
end)

---------------------------------------------------------------------
-- ======================== GUI: VISUAL =============================
---------------------------------------------------------------------
do
    local MiscV = Visual:AddSection({
        Name = "ESP",
        Position = "left"
    })

    -- toggle global
    MiscV:AddToggle({
        Name = "ESP Enabled",
        Default = true,
        Callback = function(val)
            ESP_ENABLED = val
            for _, bot in ipairs(BOT_MODEL:GetChildren()) do
                if bot:IsA("Model") then
                    if not val then
                        clearESPForAllRoles(bot)
                    else
                        applyESPToBot(bot)
                    end
                end
            end
        end
    })

    local function makeRoleToggle(name, key)
        MiscV:AddToggle({
            Name = name,
            Default = true,
            Callback = function(val)
                ROLE_TOGGLES[key] = val
                clearESPByRole(key)
                if val and ESP_ENABLED then
                    for _, bot in ipairs(BOT_MODEL:GetChildren()) do
                        if bot:IsA("Model") then
                            applyESPToBot(bot)
                        end
                    end
                end
            end
        })
    end

    makeRoleToggle("Manager ESP",     "Manager")
    makeRoleToggle("Guard ESP",       "Guard")
    makeRoleToggle("Guard2 ESP",      "Guard2")
    makeRoleToggle("Guard Master ESP","GuardMaster")
    makeRoleToggle("Ryan ESP",        "Ryan")
    makeRoleToggle("SWAT ESP",        "SWAT")
    makeRoleToggle("Manager3 ESP",    "Manager3")
    makeRoleToggle("Civilian ESP",    "Civilian")
end

---------------------------------------------------------------------
-- ======================== GUI: README =============================
---------------------------------------------------------------------
---------------------------------------------------------------------
-- ======================== GUI: README =============================
---------------------------------------------------------------------
do
    local InfoSec = Readme:AddSection({
        Name = "README",
        Position = "left"
    })

    -- “Label” simulado como botón sin acción
    InfoSec:AddButton({
        Name = "INFO",
        Callback = function() end
    })

    InfoSec:AddButton({
        Name = "GUARD2s are civilians (Deposit/Withdraw)",
        Callback = function() end
    })

    InfoSec:AddButton({
        Name = "Re-execute Synergy if you retry level.",
        Callback = function() end
    })

    InfoSec:AddButton({
        Name = "Manager: Top is real, Basement is fake.",
        Callback = function() end
    })
end
