local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ///////////////////////////////////////////////////////////
-- //                 UI 核心設定 (Hamster V61)            //
-- ///////////////////////////////////////////////////////////

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HamsterHub_V61_Final"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleKey = Enum.KeyCode.K
local selectedPlayer = nil
local islandFlightSpeed = 80 
local boatSpeedMul = 2
local inputJobId = ""
local LocalIsland = nil
local currentCar = nil

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 180, 50)
UIStroke.Thickness = 2

-- ///////////////////////////////////////////////////////////
-- //                 UI 組件函數 (修復滑桿)                //
-- ///////////////////////////////////////////////////////////

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", Sidebar)
TitleLabel.Text = "Hamster V61"
TitleLabel.Size = UDim2.new(1, 0, 0, 60)
TitleLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 22; TitleLabel.BackgroundTransparency = 1

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Position = UDim2.new(0, 0, 0, 70); TabContainer.Size = UDim2.new(1, 0, 1, -70); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 190, 0, 60); ContentArea.Size = UDim2.new(1, -200, 1, -70); ContentArea.BackgroundTransparency = 1

local function createTab(name)
    local Page = Instance.new("ScrollingFrame", ContentArea); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 3; Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    local Btn = Instance.new("TextButton", TabContainer); Btn.Size = UDim2.new(1, -10, 0, 35); Btn.BackgroundTransparency = 1; Btn.Text = "  " .. name; Btn.TextColor3 = Color3.fromRGB(150, 150, 150); Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.TextSize = 13
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        Page.Visible = true; Btn.TextColor3 = Color3.fromRGB(255, 180, 50)
    end)
    return Page
end

local function createButton(page, text, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,40); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Btn = Instance.new("TextButton", Frame); Btn.Size=UDim2.new(1,0,1,0); Btn.BackgroundTransparency=1; Btn.Text=text; Btn.TextColor3=Color3.fromRGB(0,255,255); Btn.Font=Enum.Font.GothamBold; Btn.TextSize=14
    Btn.MouseButton1Click:Connect(callback)
end

local function createToggle(page, name, default, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,40); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel", Frame); Label.Text=name; Label.Size=UDim2.new(0.7,0,1,0); Label.Position=UDim2.new(0,15,0,0); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=13
    local Btn = Instance.new("TextButton", Frame); Btn.Size=UDim2.new(0,35,0,22); Btn.Position=UDim2.new(1,-45,0.5,-11); Btn.BackgroundColor3=default and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); Btn.Text=""; Instance.new("UICorner",Btn).CornerRadius=UDim.new(1,0)
    local isOn = default; Btn.MouseButton1Click:Connect(function() isOn=not isOn; Btn.BackgroundColor3=isOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); callback(isOn) end)
end

-- // [核心回歸] 舊版穩定滑桿邏輯 //
local function createSlider(page, name, min, max, default, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,55); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel", Frame); Label.Text=name..": "..default; Label.Size=UDim2.new(1,-20,0,20); Label.Position=UDim2.new(0,15,0,5); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=13
    local Bar = Instance.new("Frame", Frame); Bar.Size=UDim2.new(1,-30,0,6); Bar.Position=UDim2.new(0,15,0,35); Bar.BackgroundColor3=Color3.fromRGB(60,60,60); Instance.new("UICorner",Bar).CornerRadius=UDim.new(1,0)
    local Fill = Instance.new("Frame", Bar); Fill.Size=UDim2.new((default-min)/(max-min),0,1,0); Fill.BackgroundColor3=Color3.fromRGB(255, 180, 50); Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
    local Trigger = Instance.new("TextButton", Bar); Trigger.Size=UDim2.new(1,0,1,0); Trigger.BackgroundTransparency=1; Trigger.Text=""
    
    local dragging = false
    local function update()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            local p = math.clamp((mousePos - barPos) / barSize, 0, 1)
            Fill.Size = UDim2.new(p, 0, 1, 0)
            local value = math.floor(min + (max - min) * p)
            Label.Text = name .. ": " .. value
            callback(value)
        end
    end
    Trigger.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(update)
end

local function createLabel(page, text)
    local L = Instance.new("TextLabel", page); L.Size=UDim2.new(1,-10,0,25); L.BackgroundTransparency=1; L.Text=text; L.TextColor3=Color3.fromRGB(200,200,200); L.Font=Enum.Font.Gotham; L.TextSize=13; return L
end

local function createTextBox(page, placeholder, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,45); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Box = Instance.new("TextBox", Frame); Box.Size=UDim2.new(0.9,0,0.8,0); Box.Position=UDim2.new(0.05,0,0.1,0); Box.BackgroundTransparency=1; Box.Text=""; Box.PlaceholderText=placeholder; Box.TextColor3=Color3.fromRGB(255,255,255); Box.Font=Enum.Font.Gotham; Box.TextSize=15; Box.FocusLost:Connect(function() callback(Box.Text) end); return Box
end

-- ///////////////////////////////////////////////////////////
-- //                 分頁對齊                              //
-- ///////////////////////////////////////////////////////////

local PageStats = createTab("🔢 修改器")
local PageBF = createTab("🍎 海賊王 (BF)")
local PageVehicles = createTab("⛵ 載具/島嶼")
local PageVisual = createTab("👁️ 視覺管理")
local PageBedwars = createTab("🛌 床戰 (Bed)")
local PageRivals = createTab("🔫 競爭者 (Rivals)")
local PagePlayers = createTab("👥 玩家管理")

-- ///////////////////////////////////////////////////////////
-- //              🔢 修改器 (全數找回)                     //
-- ///////////////////////////////////////////////////////////

createLabel(PageStats, "== 基礎屬性調整 ==")
createSlider(PageStats, "🏃 走路速度", 16, 500, 16, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
createSlider(PageStats, "⬆️ 跳躍高度", 50, 500, 50, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = v end end)

local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
createToggle(PageStats, "☁️ 無限跳躍", false, function(s) infJumpEnabled = s end)

-- ///////////////////////////////////////////////////////////
-- //              👁️ 視覺管理 (ESP 恢復)                    //
-- ///////////////////////////////////////////////////////////

createLabel(PageVisual, "== 玩家 ESP 與環境 ==")
local espOn = false
local function handleESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart; local gui = hrp:FindFirstChild("HamsterESP")
            if not gui then
                gui = Instance.new("BillboardGui", hrp); gui.Name = "HamsterESP"; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0, 100, 0, 40); gui.StudsOffset = Vector3.new(0, 3, 0)
                local t = Instance.new("TextLabel", gui); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.Name = "L"
            end
            gui.Enabled = espOn; local d = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
            gui.L.Text = p.DisplayName .. "\n[" .. d .. "m]"; gui.L.TextColor3 = p.TeamColor.Color
        end
    end
end
createToggle(PageVisual, "👁️ 啟動玩家透視 (ESP)", false, function(s) espOn = s; if s then RunService:BindToRenderStep("ESP_Final", 1, handleESP) else RunService:UnbindFromRenderStep("ESP_Final") end end)

createToggle(PageVisual, "☀️ 移除黑暗 (Fullbright)", false, function(s) if s then Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.Brightness = 2; Lighting.FogEnd = 9e9; end end)
createToggle(PageVisual, "🌟 全島極限發光", false, function(s) if s then Lighting.ExposureCompensation = 3 else Lighting.ExposureCompensation = 0 end end)

-- ///////////////////////////////////////////////////////////
-- //              🍎 海賊王 (BF) 功能                      //
-- ///////////////////////////////////////////////////////////

createLabel(PageBF, "== 海市蜃樓與齒輪 ==")
createButton(PageBF, "⚙️ 齒輪強傳 (Gear Auto-TP)", function()
    local gear = nil; for _, v in pairs(Workspace:GetDescendants()) do if v.Name == "Gear" or v.Name == "BlueGear" then gear = v break end end
    if gear then LocalPlayer.Character:PivotTo(gear.CFrame * CFrame.new(0,5,0)) else createLabel(PageBF, "❌ 未發現齒輪粒子").TextColor3 = Color3.fromRGB(255,0,0) end
end)
createButton(PageBF, "🏝️ 深度搜索幻影島", function()
    local t = nil; for _, v in pairs(Workspace:GetDescendants()) do if string.find(v.Name, "Mirage") then t = v break end end
    if t then LocalPlayer.Character:PivotTo(t:GetModelCFrame() * CFrame.new(0,150,0)) end
end)

createLabel(PageBF, "== 船隻防護 ==")
local boatGod = false
createToggle(PageBF, "🛡️ 船隻無限血量 (絕對無敵)", false, function(s)
    boatGod = s
    spawn(function()
        while boatGod do
            pcall(function()
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    local boat = hum.SeatPart.Parent
                    for _, v in pairs(boat:GetDescendants()) do if v.Name == "Health" or v.Name == "health" or v.Name == "HP" then v.Value = 1000000 end end
                end
            end)
            task.wait(0.1)
        end
    end)
end)
createButton(PageBF, "🎲 立即抽果實 (Gacha)", function() pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy") end) end)

createLabel(PageBF, "== 本地互動 (帶技能) ==")
local function giveLocal(name, color)
    local t = Instance.new("Tool", LocalPlayer.Backpack); t.Name = "[本地] "..name; local h = Instance.new("Part", t); h.Name = "Handle"; h.Size = Vector3.new(1,2,1); h.Color = color; h.Transparency = 0.5
    t.Activated:Connect(function() local ex = Instance.new("Explosion", Workspace); ex.Position = LocalPlayer.Character.HumanoidRootPart.Position + (LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 15); ex.BlastRadius = 12 end)
end
createButton(PageBF, "🦊 獲取狐狸果實", function() giveLocal("Kitsune", Color3.fromRGB(255, 100, 255)) end)
createButton(PageBF, "⚔️ 獲取三黑刀", function() giveLocal("Triple Blade", Color3.fromRGB(0, 255, 100)) end)
createToggle(PageBF, "🧬 虛假 V4 覺醒視覺", false, function(s) if s then local p = Instance.new("ParticleEmitter", LocalPlayer.Character.HumanoidRootPart); p.Name = "FakeV4"; p.Color = ColorSequence.new(Color3.fromRGB(0,255,255)); p.Rate = 150 else if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FakeV4") then LocalPlayer.Character.HumanoidRootPart.FakeV4:Destroy() end end end)

-- ///////////////////////////////////////////////////////////
-- //              ⛵ 載具與腳本島嶼 (島嶼飛行)             //
-- ///////////////////////////////////////////////////////////

createLabel(PageVehicles, "== 腳本島嶼與飛行速度 ==")
createSlider(PageVehicles, "🏝️ 島嶼飛行速度 (調低防拉回)", 20, 300, 80, function(v) islandFlightSpeed = v end)

createButton(PageVehicles, "🏝️ 召喚本地腳本島嶼", function()
    if LocalIsland then LocalIsland:Destroy() end
    LocalIsland = Instance.new("Part", Workspace); LocalIsland.Size = Vector3.new(300, 10, 300); LocalIsland.Position = Vector3.new(8000, 1000, 8000); LocalIsland.Anchored = true; LocalIsland.Color = Color3.fromRGB(40, 40, 40); LocalIsland.Material = Enum.Material.Neon
    createLabel(PageVehicles, "✅ 島嶼已在 (8000, 1000, 8000) 建立").TextColor3 = Color3.fromRGB(0, 255, 0)
end)

createButton(PageVehicles, "🚀 飛行前往腳本島嶼", function()
    if LocalIsland then
        local hrp = LocalPlayer.Character.HumanoidRootPart; LocalPlayer.Character.Humanoid.PlatformStand = true
        local dist = (hrp.Position - (LocalIsland.Position + Vector3.new(0,15,0))).Magnitude
        local duration = dist / islandFlightSpeed
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad), {CFrame = LocalIsland.CFrame * CFrame.new(0, 15, 0)})
        tween:Play(); tween.Completed:Connect(function() LocalPlayer.Character.Humanoid.PlatformStand = false; hrp.Velocity = Vector3.new(0,0,0) end)
    end
end)

createButton(PageVehicles, "🏎️ 召喚本地可駕駛跑車", function()
    if currentCar then currentCar:Destroy() end
    currentCar = Instance.new("Part", Workspace); currentCar.Size = Vector3.new(8, 2, 12); currentCar.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 5); currentCar.Color = Color3.fromRGB(30,30,30); currentCar.Material = Enum.Material.Metal
    local seat = Instance.new("VehicleSeat", currentCar); seat.Size = Vector3.new(6,1,6); seat.Position = currentCar.Position + Vector3.new(0,1,0)
    
    local driveCon; driveCon = RunService.Heartbeat:Connect(function()
        if not currentCar or not currentCar.Parent then driveCon:Disconnect(); return end
        if seat.Occupant and seat.Occupant == LocalPlayer.Character.Humanoid then
            currentCar.Velocity = currentCar.CFrame.LookVector * (seat.Throttle * 80)
            currentCar.RotVelocity = Vector3.new(0, -seat.Steer * 4, 0)
        end
    end)
    createLabel(PageVehicles, "🏎️ 車輛已召喚 (坐在駕駛座用 WASD)").TextColor3 = Color3.fromRGB(0, 255, 255)
end)

createSlider(PageVehicles, "⛵ 船隻速度倍率", 1, 10, 2, function(v) boatSpeedMul = v end)
RunService.Stepped:Connect(function() if LocalPlayer.Character and LocalPlayer.Character.Humanoid.SeatPart then local s = LocalPlayer.Character.Humanoid.SeatPart; if s:IsA("VehicleSeat") and s.Throttle ~= 0 then s.Velocity = s.CFrame.LookVector * (s.Throttle * boatSpeedMul * 60) end end end)

-- ///////////////////////////////////////////////////////////
-- //              🛌 床戰 & 🔫 競爭者                      //
-- ///////////////////////////////////////////////////////////

createLabel(PageBedwars, "== 移動對抗 ==")
createToggle(PageBedwars, "🛡️ 防拉回系統", false, function(s) if s then RunService:BindToRenderStep("AntiBack", 1, function() if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Velocity.Magnitude > 75 then LocalPlayer.Character.PrimaryPart.Velocity = LocalPlayer.Character.PrimaryPart.Velocity.Unit * 30 end end) else RunService:UnbindFromRenderStep("AntiBack") end end)
createButton(PageBedwars, "📍 平滑點擊飛行 (點擊地面)", function() local c; c = UserInputService.InputBegan:Connect(function(i, g) if not g and i.UserInputType == Enum.UserInputType.MouseButton1 then c:Disconnect(); local t = Mouse.Hit.p + Vector3.new(0, 5, 0); LocalPlayer.Character.Humanoid.PlatformStand = true; TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(t)}):Play(); task.wait(1.6); LocalPlayer.Character.Humanoid.PlatformStand = false end end) end)

createLabel(PageRivals, "== 自瞄系統 ==")
local aimEn = false; local aimF = 100; local aimH = false
RunService.RenderStepped:Connect(function() if aimEn and aimH then local t = nil; local d = aimF; for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then local p, vis = Camera:WorldToScreenPoint(v.Character.Head.Position); if vis then local m = (Vector2.new(Mouse.X, Mouse.Y)-Vector2.new(p.X, p.Y)).Magnitude; if m < d then d = m; t = v end end end end if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end end end)
createToggle(PageRivals, "🎯 啟用自瞄 (右鍵)", false, function(s) aimEn = s end); createSlider(PageRivals, "⭕ FOV 大小", 30, 500, 100, function(v) aimF = v end)
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then aimH = true end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then aimH = false end end)

-- ///////////////////////////////////////////////////////////
-- //              👥 玩家管理 (JobId 與 瞬間傳送)          //
-- ///////////////////////////////////////////////////////////

createLabel(PagePlayers, "== 伺服器 JobId 跳轉 ==")
createTextBox(PagePlayers, "貼上 JobId (支援 H2O2SERVER|)...", function(t) if string.find(t, "|") then inputJobId = string.split(t, "|")[2] else inputJobId = t end end)
createButton(PagePlayers, "🔗 加入指定伺服器", function() if inputJobId ~= "" then TeleportService:TeleportToPlaceInstance(game.PlaceId, inputJobId, LocalPlayer) end end)
createButton(PagePlayers, "🔄 一鍵 Server Hop", function() local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")); for _, v in pairs(s.data) do if v.playing < v.maxPlayers and v.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer) break end end end)

createLabel(PagePlayers, "== 玩家列表與傳送 ==")
local pScroll = Instance.new("ScrollingFrame", PagePlayers); pScroll.Size = UDim2.new(1,-5,0,100); pScroll.BackgroundColor3 = Color3.fromRGB(25,25,30); Instance.new("UIListLayout", pScroll)
local function refresh()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then
        local b = Instance.new("TextButton", pScroll); b.Size = UDim2.new(1,0,0,30); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(40,40,45); b.TextColor3 = Color3.fromRGB(255,255,255)
        b.MouseButton1Click:Connect(function() selectedPlayer = p; createLabel(PagePlayers, "選中: "..p.DisplayName).TextColor3 = Color3.fromRGB(255,255,0) end)
    end end
end
createButton(PagePlayers, "🔄 刷新名單", refresh); refresh()
createButton(PagePlayers, "🚀 瞬間傳送 (V61)", function() if selectedPlayer and selectedPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand = true; LocalPlayer.Character:PivotTo(selectedPlayer.Character:GetPivot() * CFrame.new(0, 10, 0)); task.wait(0.3); LocalPlayer.Character.Humanoid.PlatformStand = false end end)

-- ///////////////////////////////////////////////////////////
-- //                 熱鍵與結束                            //
-- ///////////////////////////////////////////////////////////

UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == ToggleKey then MainFrame.Visible = not MainFrame.Visible end end)
createButton(PagePlayers, "❌ 徹底關閉 UI", function() ScreenGui:Destroy() end)

PageStats.Visible = true
print("HamsterHub V61 Ultimate FINAL COMPLETE VERSION Loaded!")
