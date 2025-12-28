local Fatality = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
local Notification = Fatality:CreateNotifier()

Fatality:Loader({
    Name = "Synergia",
    Duration = 3
})

Notification:Notify({
    Title = "Synergia",
    Content = "¡Stamina + Anti Admin ready!",
    Icon = "shield"
})

local Window = Fatality.new({
    Name = "Synergia",
    Expire = "some day",
})

local Misc = Window:AddMenu({
    Name = "MISC",
    Icon = "settings"
})

-- 🔥 SERVICIOS Y VARIABLES GLOBALES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerName = LocalPlayer.Name
local RunService = game:GetService("RunService")

-- 🔥 ADMINS LIST
local AdminList = {
    "uffuez", "Dexne5t", "Duckie_Zinc2", "Leeoyoo", "lzwans", "Gemononis",
    "samplayz28", "O_CJs", "Akira_Blade", "ElSpeakerCuh", "benjaminskylark",
    "Vol3an", "iamproTOHok", "1SyNet", "Floriyia", "iqmazlz", "Johzensei",
    "mar_xzy", "terrarian_25", "BruhThis_weird", "Senzastu", "Zandcheese",
    "Luesity", "math128q", "CodenameKuwo", "Lilly_theSiIly", "nullisite",
    "YT_Gamersilverboy", "TakanashiHoshinoSan", "Minecraft_Dude360",
    "MilkingSylph", "Kathexy", "Delta_X295", "endlessdock", "meliodas3524"
}

-- 🔥 ESTADOS DE TOGGLES
local stamina150Active = false
local legitStaminaActive = false
local antiAdminActive = false
local staminaHookActive = false

-- 🔥 FUNCIÓN HOOK STAMINA (UNA SOLA VEZ)
local function createStaminaHook()
    if staminaHookActive then return end
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self):find("Stamina") then
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
        staminaHookActive = true
    end)
end

-- 🔥 FUNCIÓN STAMINA 150
local function setStamina150()
    pcall(function()
        local playerFolder = workspace.Players:FindFirstChild(playerName)
        if playerFolder then
            local info = playerFolder:FindFirstChild("Info")
            if info then
                local stamina = info:FindFirstChild("Stamina")
                if stamina and stamina:IsA("NumberValue") then
                    stamina.Value = 150
                end
            end
        end
    end)
end

-- 🔥 FUNCIÓN LEGIT STAMINA (MÍNIMO 5) - MEJORADA
local function checkLegitStamina()
    pcall(function()
        local playerFolder = workspace.Players:FindFirstChild(playerName)
        if playerFolder then
            local info = playerFolder:FindFirstChild("Info")
            if info then
                local stamina = info:FindFirstChild("Stamina")
                if stamina and stamina:IsA("NumberValue") then
                    -- MÁS AGRESIVO: Siempre mantiene >= 2
                    if stamina.Value < 2 then
                        stamina.Value = 2
                    end
                end
            end
        end
    end)
end

-- 🔥 LOOP PRINCIPAL LEGIT STAMINA (MÁS RÁPIDO)
local legitStaminaConnection = nil
local function startLegitStaminaLoop()
    if legitStaminaConnection then return end
    
    legitStaminaConnection = RunService.Heartbeat:Connect(function()
        if legitStaminaActive then
            checkLegitStamina()
        end
    end)
end

-- 🔥 PLAYER SECTION
do
    local PlayerSection = Misc:AddSection({
        Position = 'left',
        Name = "PLAYER"
    })
    
    -- TOGGLE 1: INF Stamina 150
    PlayerSection:AddToggle({
        Name = "🔒 INF Stamina 150",
        Default = false,
        Callback = function(value)
            stamina150Active = value
            if value then
                createStaminaHook()
                task.spawn(function()
                    while stamina150Active do
                        setStamina150()
                        task.wait()
                    end
                end)
                Notification:Notify({
                    Title = "✅ Stamina 150 ON",
                    Content = "🔒 Stamina 150 INFINITE",
                    Duration = 3,
                    Icon = "shield-check"
                })
            else
                Notification:Notify({
                    Title = "❌ Stamina 150 OFF",
                    Content = "Stamina 150 off",
                    Duration = 2,
                    Icon = "shield-off"
                })
            end
        end
    })
    
    -- TOGGLE 2: LEGIT INF Stamina - ARREGLADO
    PlayerSection:AddToggle({
        Name = "🟢 Legit Inf Stamina",
        Default = false,
        Callback = function(value)
            legitStaminaActive = value
            if value then
                createStaminaHook()
                startLegitStaminaLoop()
                Notification:Notify({
                    Title = "✅ Legit Stamina ON",
                    Content = "🟢 Min 2 - Heartbeat on",
                    Duration = 3,
                    Icon = "shield-check"
                })
            else
                Notification:Notify({
                    Title = "❌ Legit Stamina OFF",
                    Content = "Stamina legit off",
                    Duration = 2,
                    Icon = "shield-off"
                })
            end
        end
    })
end

-- 🔥 ANTI ADMIN
do
    local AntiAdminSection = Misc:AddSection({
        Position = 'right',
        Name = "PROTECCIÓN"
    })
    
    local function checkAdmin(player)
        if table.find(AdminList, player.Name) then
            Notification:Notify({
                Title = "🚨 Admin detected",
                Content = "👑 " .. player.Name .. " is on your server",
                Duration = 5,
                Icon = "shield-alert"
            })
            task.spawn(function()
                task.wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end
    
    AntiAdminSection:AddToggle({
        Name = "🛡️ Detect Admins",
        Default = false,
        Callback = function(value)
            antiAdminActive = value
            if value then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        checkAdmin(player)
                    end
                end
                
                getgenv().antiAdminConnection = Players.PlayerAdded:Connect(function(player)
                    if antiAdminActive then
                        task.wait(2)
                        checkAdmin(player)
                    end
                end)
                
                Notification:Notify({
                    Title = "✅ Anti Admin ON",
                    Content = "🛡️ Detect 35+ admins",
                    Duration = 4,
                    Icon = "eye"
                })
            else
                if getgenv().antiAdminConnection then
                    getgenv().antiAdminConnection:Disconnect()
                    getgenv().antiAdminConnection = nil
                end
                Notification:Notify({
                    Title = "❌ Anti Admin OFF",
                    Content = "protection off",
                    Duration = 2,
                    Icon = "eye-off"
                })
            end
        end
    })
end

print("🚀 Synergia LEGIT FIXED!")
