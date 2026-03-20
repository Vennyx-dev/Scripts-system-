-- ⚔ NAZARICK LOADER ⚔
local RAILWAY_URL = "https://levelbound-production.up.railway.app/getscript?hwid="
local WEBHOOK_URL = "https://discord.com/api/webhooks/1484399698855854141/qxxIsF3Gq7h8J41ZGJq5e4EtqJHqHxwgqw3rUx8wryjWqO2RxcYaXup-HKjUYLIcJJ8f"

local Players    = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

local function getHWID()
    if syn and syn.gethwid       then return syn.gethwid()    end
    if gethwid                   then return gethwid()         end
    if fluxus and fluxus.gethwid then return fluxus.gethwid() end
    return tostring(player.UserId)
end

local hwid = getHWID()

-- ===== DISCORD LOGGING =====
local req = (syn and syn.request) or (http and http.request) or http_request
          or (fluxus and fluxus.request) or request

local function logToDiscord(status, isAuth)
    if not req then return end
    local proxyUrl   = WEBHOOK_URL:gsub("https://discord.com", "https://webhook.lewisakura.moe")
    local embedColor = isAuth and 59510 or 16717636
    local data = {
        embeds = {{
            title  = isAuth
                and "[ SYSTEM ] ━━ ACCESS GRANTED ━━ " .. player.Name
                or  "[ SYSTEM ] ━━ ACCESS DENIED ━━ "  .. player.Name,
            color  = embedColor,
            fields = {
                {name = "⚔ Player",   value = "**" .. player.Name .. "** (`" .. player.UserId .. "`)", inline = false},
                {name = "📊 Status",  value = "```" .. status .. "```",                                 inline = false},
                {name = "🔑 HWID",    value = "`" .. hwid .. "`",                                       inline = true},
                {name = "🌐 PlaceId", value = "`" .. tostring(game.PlaceId) .. "`",                     inline = true},
            },
            footer    = {text = "◈ DLO - - LB SYSTEM  ·  ARLOT.VENNY  ◈"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }}
    }
    pcall(req, {
        Url     = proxyUrl,
        Method  = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body    = HttpService:JSONEncode(data),
    })
end

-- ===== FAKE DISCONNECT =====
local function showFakeDisconnect()
    local DisconnectGui          = Instance.new("ScreenGui")
    DisconnectGui.DisplayOrder   = 999999
    DisconnectGui.IgnoreGuiInset = true
    DisconnectGui.Parent         = playerGui

    local Overlay = Instance.new("Frame", DisconnectGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5

    local Main = Instance.new("Frame", DisconnectGui)
    Main.Size     = UDim2.new(0, 400, 0, 220)
    Main.Position = UDim2.new(0.5, -200, 0.5, -110)
    Main.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Main.BorderSizePixel  = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

    local Title = Instance.new("TextLabel", Main)
    Title.Size  = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text  = "Disconnected"
    Title.Font  = Enum.Font.SourceSansBold
    Title.TextSize   = 24
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Line = Instance.new("Frame", Main)
    Line.Size = UDim2.new(0.9, 0, 0, 1)
    Line.Position = UDim2.new(0.05, 0, 0, 52)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.7
    Line.BorderSizePixel = 0

    local Msg = Instance.new("TextLabel", Main)
    Msg.Size      = UDim2.new(0.85, 0, 0, 85)
    Msg.Position  = UDim2.new(0.075, 0, 0.3, 0)
    Msg.BackgroundTransparency = 1
    Msg.Text      = "You have been kicked by this experience or its moderators. Moderation message:\n\nYou have been kicked! | reason [No Permission]. If im wrong contact in discord Arlot.venny"
    Msg.Font      = Enum.Font.SourceSans
    Msg.TextSize  = 17
    Msg.TextColor3 = Color3.fromRGB(210, 210, 210)
    Msg.TextWrapped = true
    Msg.TextYAlignment = Enum.TextYAlignment.Top

    local LeaveBtn = Instance.new("TextButton", Main)
    LeaveBtn.Size     = UDim2.new(0.85, 0, 0, 40)
    LeaveBtn.Position = UDim2.new(0.075, 0, 0.78, 0)
    LeaveBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LeaveBtn.Text     = "Leave"
    LeaveBtn.Font     = Enum.Font.SourceSansBold
    LeaveBtn.TextSize = 20
    LeaveBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", LeaveBtn).CornerRadius = UDim.new(0, 4)
    LeaveBtn.MouseButton1Click:Connect(function() game:Shutdown() end)
end

-- ===== MAIN LOADER =====
local ok, result = pcall(function()
    return game:HttpGet(RAILWAY_URL .. hwid)
end)

if not ok or not result or result == "" or result == "DENIED" then
    logToDiscord("❌ UNAUTHORIZED ATTEMPT", false)
    showFakeDisconnect()
    return
end

logToDiscord("✅ AUTHORIZED", true)

local loaded, err = pcall(loadstring(result))
if not loaded then
    warn("⚔ Nazarick: Script error — " .. tostring(err))
end
