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

-- 🔥 STAMINA 150 TOGGLE
do
    local PlayerSection = Misc:AddSection({
        Position = 'left',
        Name = "PLAYER"
    })
    
    local StaminaToggle = PlayerSection:AddToggle({
        Name = "🔒 INF Stamina",
        Default = false,
        Callback = function(value)
            if value then
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local playerName = LocalPlayer.Name
                
                local function setStamina()
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
                
                if not getgenv().StaminaHook then
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
                    getgenv().StaminaHook = true
                end
                
                local staminaConnection = game:GetService("RunService").Heartbeat:Connect(setStamina)
                local backupConnection = task.spawn(function()
                    while StaminaToggle.Value do
                        setStamina()
                        task.wait(0.05)
                    end
                end)
                
                StaminaToggle.Connections = {staminaConnection, backupConnection}
                
                Notification:Notify({
                    Title = "✅ Stamina ON",
                    Content = "🔒 Stamina 150 INFINITE",
                    Duration = 3,
                    Icon = "shield-check"
                })
            else
                if StaminaToggle.Connections then
                    for _, connection in pairs(StaminaToggle.Connections) do
                        if typeof(connection) == "RBXScriptConnection" then
                            connection:Disconnect()
                        elseif typeof(connection) == "thread" then
                            task.cancel(connection)
                        end
                    end
                    StaminaToggle.Connections = nil
                end
                Notification:Notify({
                    Title = "❌ Stamina OFF",
                    Content = "Stamina off",
                    Duration = 2,
                    Icon = "shield-off"
                })
            end
        end
    })
end

-- 🔥 ANTI ADMIN REAL (TE PROTEGE)
do
    local AntiAdminSection = Misc:AddSection({
        Position = 'right',
        Name = "PROTECCIÓN"
    })
    
    local AntiAdminToggle = AntiAdminSection:AddToggle({
        Name = "🛡️ Detectar Admins",
        Default = false,
        Callback = function(value)
            if value then
                local Players = game:GetService("Players")
                
                local function checkAdmin(player)
                    if table.find(AdminList, player.Name) then
                        Notification:Notify({
                            Title = "🚨 detected admin ",
                            Content = "👑 " .. player.Name .. " is on server",
                            Duration = 5,
                            Icon = "shield-alert"
                        })
                        
                        -- OPCIÓN: Auto-rejoin cuando detecta admin
                        task.spawn(function()
                            task.wait(2)
                            game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
                        end)
                    end
                end
                
                -- Check admins existentes
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer then
                        checkAdmin(player)
                    end
                end
                
                -- Detectar nuevos joins
                local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
                    if AntiAdminToggle.Value then
                        task.wait(2)
                        checkAdmin(player)
                    end
                end)
                
                AntiAdminToggle.Connections = {playerAddedConnection}
                
                Notification:Notify({
                    Title = "✅ Anti Admin ON",
                    Content = "🛡️ Detect 35+ admins",
                    Duration = 4,
                    Icon = "eye"
                })
                
            else
                if AntiAdminToggle.Connections then
                    for _, connection in pairs(AntiAdminToggle.Connections) do
                        if typeof(connection) == "RBXScriptConnection" then
                            connection:Disconnect()
                        end
                    end
                    AntiAdminToggle.Connections = nil
                end
                Notification:Notify({
                    Title = "❌ Anti Admin OFF",
                    Content = "no protection",
                    Duration = 2,
                    Icon = "eye-off"
                })
            end
        end
    })
end

print("🚀 Synergia LOAD - Stamina + Anti Admin!")
