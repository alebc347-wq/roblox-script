local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ///////////////////////////////////////////////////////////
-- //                 UI 核心與主題設定                     //
-- ///////////////////////////////////////////////////////////

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HamsterHub_V43_Final"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local ToggleKey = Enum.KeyCode.K
local selectedPlayer = nil
local tpSpeed = 120 -- 初始傳送速度

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
-- //                 UI 組件工具                           //
-- ///////////////////////////////////////////////////////////

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", Sidebar)
TitleLabel.Text = "Hamster V43"
TitleLabel.Size = UDim2.new(1, 0, 0, 60)
TitleLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 22
TitleLabel.BackgroundTransparency = 1

local TabContainer = Instance.new("ScrollingFrame", Sidebar)
TabContainer.Position = UDim2.new(0, 0, 0, 70)
TabContainer.Size = UDim2.new(1, 0, 1, -70)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 0
TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 190, 0, 60)
ContentArea.Size = UDim2.new(1, -200, 1, -70)
ContentArea.BackgroundTransparency = 1

local function createTab(name)
    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundTransparency = 1
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextSize = 14
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        Page.Visible = true; Btn.TextColor3 = Color3.fromRGB(255, 180, 50)
    end)
    return Page
end

local function createButton(page, text, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,45); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Btn = Instance.new("TextButton", Frame); Btn.Size=UDim2.new(1,0,1,0); Btn.BackgroundTransparency=1; Btn.Text=text; Btn.TextColor3=Color3.fromRGB(0,255,255); Btn.Font=Enum.Font.GothamBold; Btn.TextSize=15
    Btn.MouseButton1Click:Connect(callback)
end

local function createToggle(page, name, default, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,45); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel", Frame); Label.Text=name; Label.Size=UDim2.new(0.7,0,1,0); Label.Position=UDim2.new(0,15,0,0); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Btn = Instance.new("TextButton", Frame); Btn.Size=UDim2.new(0,40,0,25); Btn.Position=UDim2.new(1,-50,0.5,-12.5); Btn.BackgroundColor3=default and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); Btn.Text=""; Instance.new("UICorner",Btn).CornerRadius=UDim.new(1,0)
    local isOn = default
    Btn.MouseButton1Click:Connect(function() isOn=not isOn; Btn.BackgroundColor3=isOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); callback(isOn) end)
end

local function createSlider(page, name, min, max, default, callback)
    local Frame = Instance.new("Frame", page); Frame.Size=UDim2.new(1,-5,0,60); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel", Frame); Label.Text=name..": "..default; Label.Size=UDim2.new(1,-20,0,25); Label.Position=UDim2.new(0,15,0,5); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Bar = Instance.new("Frame", Frame); Bar.Size=UDim2.new(1,-30,0,8); Bar.Position=UDim2.new(0,15,0,40); Bar.BackgroundColor3=Color3.fromRGB(60,60,60); Instance.new("UICorner",Bar).CornerRadius=UDim.new(1,0)
    local Fill = Instance.new("Frame", Bar); Fill.Size=UDim2.new((default-min)/(max-min),0,1,0); Fill.BackgroundColor3=Color3.fromRGB(255, 180, 50); Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
    local Trigger = Instance.new("TextButton", Bar); Trigger.Size=UDim2.new(1,0,1,0); Trigger.BackgroundTransparency=1; Trigger.Text=""
    local dragging=false
    local function update(input)
        local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        local v = math.floor(min + (max - min) * p)
        Label.Text = name .. ": " .. v; callback(v)
    end
    Trigger.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i) end end)
end

local function createLabel(page, text)
    local L = Instance.new("TextLabel", page); L.Size=UDim2.new(1,-10,0,30); L.BackgroundTransparency=1; L.Text=text; L.TextColor3=Color3.fromRGB(200,200,200); L.Font=Enum.Font.Gotham; L.TextSize=14
    return L
end

-- ///////////////////////////////////////////////////////////
-- //                 分頁初始化                            //
-- ///////////////////////////////////////////////////////////

local PageBedwars = createTab("🛌 床戰 (Bedwars)")
local PageBF = createTab("🍎 海賊王 (Blox Fruits)")
local PageVehicles = createTab("⛵ 船隻/載具 (Vehicles)")
local PageRage = createTab("⚡ 暴力引擎 (Rage)")
local PageStats = createTab("🔢 數值修改 (Stats)")
local PageRivals = createTab("🔫 競爭者 (Rivals)")
local PageVisual = createTab("👁️ 視覺透視 (Visual)")
local PagePlayers = createTab("👥 玩家管理")

-- ///////////////////////////////////////////////////////////
-- //              ⛵ 船隻/載具加速功能 (New)              //
-- ///////////////////////////////////////////////////////////

createLabel(PageVehicles, "== 載具增強 ==")
local boatSpeedActive = false
local boatSpeedMul = 2
RunService.Stepped:Connect(function()
    if boatSpeedActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local seat = LocalPlayer.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            -- 獲取前進方向並給予速度
            if seat.Throttle ~= 0 then
                seat.Velocity = seat.CFrame.LookVector * (seat.Throttle * boatSpeedMul * 60)
            end
        end
    end
end)

createToggle(PageVehicles, "⛵ 暴力開船/載具加速", false, function(s) boatSpeedActive = s end)
createSlider(PageVehicles, "⚡ 船隻速度倍率", 1, 100, 2, function(v) boatSpeedMul = v end)
createLabel(PageVehicles, "說明：坐在船上駕駛座前進時生效")

-- ///////////////////////////////////////////////////////////
-- //              🛌 床戰與防拉回系統                      //
-- ///////////////////////////////////////////////////////////

createLabel(PageBedwars, "== 移動與防禦 ==")
local antiRubber = false
createToggle(PageBedwars, "🛡️ 防拉回系統 (Anti-Rubber)", false, function(s)
    antiRubber = s
    if s then
        RunService:BindToRenderStep("AntiBack", 1, function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local state = LocalPlayer.Character.Humanoid:GetState()
                if state == Enum.HumanoidStateType.Jumping then return end
                if hrp.Velocity.Magnitude > 75 then hrp.Velocity = hrp.Velocity.Unit * 25 end
            end
        end)
    else
        RunService:UnbindFromRenderStep("AntiBack")
    end
end)

local flyActive = false
local flySpeedVal = 60
createButton(PageBedwars, "📍 點擊飛行 (點擊地面移動)", function()
    flyActive = true
    createLabel(PageBedwars, "系統：請在地圖點擊目標...").TextColor3 = Color3.fromRGB(0, 255, 100)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 and flyActive then
            flyActive = false; conn:Disconnect()
            local targetPos = Mouse.Hit.p + Vector3.new(0, 5, 0)
            if LocalPlayer.Character then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local hum = LocalPlayer.Character.Humanoid
                hum.PlatformStand = true
                local dist = (hrp.Position - targetPos).Magnitude
                local tween = TweenService:Create(hrp, TweenInfo.new(dist/flySpeedVal, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                tween:Play()
                tween.Completed:Connect(function() hum.PlatformStand = false; hrp.Velocity = Vector3.new(0,0,0) end)
            end
        end
    end)
end)

-- ///////////////////////////////////////////////////////////
-- //              🍎 Blox Fruits 功能                      //
-- ///////////////////////////////////////////////////////////

createLabel(PageBF, "== 自動功能 ==")
local autoAtk = false
createToggle(PageBF, "⚡ 自動攻擊", false, function(s)
    autoAtk = s
    spawn(function()
        while autoAtk do
            VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0,0))
            if LocalPlayer.Character then local t = LocalPlayer.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
            task.wait(0.1)
        end
    end)
end)
createButton(PageBF, "🍎 隨機買果實", function()
    pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy") end)
end)

-- ///////////////////////////////////////////////////////////
-- //              ⚡ 暴力引擎 (Rage)                       //
-- ///////////////////////////////////////////////////////////

createLabel(PageRage, "== 暴力移動 ==")
local rageOn = false; local rageSpeedMul = 1
RunService.Stepped:Connect(function()
    if rageOn and LocalPlayer.Character then
        local hum = LocalPlayer.Character.Humanoid; local hrp = LocalPlayer.Character.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * rageSpeedMul); hrp.Velocity = Vector3.new(0,0,0) end
    end
end)
createToggle(PageRage, "⏩ 暴力加速 (CFrame)", false, function(s) rageOn = s end)
createSlider(PageRage, "⚡ 加速強度", 1, 10, 2, function(v) rageSpeedMul = v/2 end)
local noclip = false
RunService.Stepped:Connect(function() if noclip and LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)
createToggle(PageRage, "👻 穿牆", false, function(s) noclip = s end)

-- ///////////////////////////////////////////////////////////
-- //              🔢 數值修改 (Stats)                      //
-- ///////////////////////////////////////////////////////////

createLabel(PageStats, "== 屬性修改 ==")
createSlider(PageStats, "🏃 走路速度", 16, 500, 16, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
createSlider(PageStats, "⬆️ 跳躍高度", 50, 500, 50, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = v end end)
local infJump = false
UserInputService.JumpRequest:Connect(function() if infJump and LocalPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand = false; LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
createToggle(PageStats, "☁️ 無限跳", false, function(s) infJump = s end)

-- ///////////////////////////////////////////////////////////
-- //              🔫 競爭者 (Rivals)                       //
-- ///////////////////////////////////////////////////////////

createLabel(PageRivals, "== 自瞄系統 ==")
local aimEnabled = false; local aimFOVSize = 100; local aimHolding = false; local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.Radius = aimFOVSize; FOVCircle.Color = Color3.fromRGB(255, 180, 50); FOVCircle.Visible = false; FOVCircle.Filled = false
end
local function getClosestPlayer()
    local target = nil; local dist = aimFOVSize
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if vis then local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude; if mag < dist then dist = mag; target = v end end
        end
    end
    return target
end
RunService.RenderStepped:Connect(function()
    if FOVCircle then FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y); FOVCircle.Radius = aimFOVSize; FOVCircle.Visible = aimEnabled end
    if aimEnabled and aimHolding then
        local t = getClosestPlayer(); if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position) end
    end
end)
createToggle(PageRivals, "🎯 啟用自瞄 (右鍵)", false, function(s) aimEnabled = s end)
createSlider(PageRivals, "⭕ FOV 大小", 30, 800, 100, function(v) aimFOVSize = v end)
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHolding = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then aimHolding = false end end)
createToggle(PageRivals, "📦 擴大頭部 (Hitbox)", false, function(s) spawn(function() while s do for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then p.Character.Head.Size = Vector3.new(5,5,5); p.Character.Head.Transparency = 0.5; p.Character.Head.CanCollide = false end end task.wait(1) end end) end)

-- ///////////////////////////////////////////////////////////
-- //              👁️ 視覺透視 (Visual)                     //
-- ///////////////////////////////////////////////////////////

createLabel(PageVisual, "== 玩家 ESP ==")
local espOn = false
local function handleESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart; local gui = hrp:FindFirstChild("HamsterESP")
            if not gui then
                gui = Instance.new("BillboardGui", hrp); gui.Name = "HamsterESP"; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0,100,0,40); gui.StudsOffset = Vector3.new(0,3,0)
                local t = Instance.new("TextLabel", gui); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamBold; t.TextSize = 12
            end
            gui.Enabled = espOn; gui.TextLabel.Text = p.DisplayName .. "\n" .. math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m"; gui.TextLabel.TextColor3 = p.TeamColor.Color
        end
    end
end
createToggle(PageVisual, "👁️ 啟動透視", false, function(s) espOn = s; if s then RunService:BindToRenderStep("ESP", 1, handleESP) else RunService:UnbindFromRenderStep("ESP") end end)

-- ///////////////////////////////////////////////////////////
-- //              👥 玩家管理 (動態追蹤 TP)                //
-- ///////////////////////////////////////////////////////////

createLabel(PagePlayers, "== 選取對象 ==")
local targetInfo = createLabel(PagePlayers, "目前選擇: 無")
local pScroll = Instance.new("ScrollingFrame", PagePlayers); pScroll.Size = UDim2.new(1,-5,0,120); pScroll.BackgroundColor3 = Color3.fromRGB(25,25,30); Instance.new("UIListLayout", pScroll)
local function updateList()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", pScroll); b.Size = UDim2.new(1,0,0,30); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(40,40,45); b.TextColor3 = Color3.fromRGB(255,255,255)
            b.MouseButton1Click:Connect(function() selectedPlayer = p; targetInfo.Text = "目前選擇: " .. p.DisplayName end)
        end
    end
end
createButton(PagePlayers, "🔄 刷新列表", updateList); updateList()

local isTeleporting = false
createButton(PagePlayers, "🚀 動態追蹤傳送 (防拉回+高度修正)", function()
    if selectedPlayer and selectedPlayer.Character and LocalPlayer.Character and not isTeleporting then
        isTeleporting = true; local hrp = LocalPlayer.Character.HumanoidRootPart; local hum = LocalPlayer.Character.Humanoid
        hum.PlatformStand = true
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") or not isTeleporting then
                isTeleporting = false; hum.PlatformStand = false; connection:Disconnect(); return
            end
            local targetHrp = selectedPlayer.Character.HumanoidRootPart; local targetPos = targetHrp.Position + Vector3.new(0, 5, 0)
            local currentPos = hrp.Position; local direction = (targetPos - currentPos).Unit; local distance = (targetPos - currentPos).Magnitude
            if distance < 5 then isTeleporting = false; hum.PlatformStand = false; hrp.Velocity = Vector3.new(0,0,0); connection:Disconnect()
            else hrp.CFrame = CFrame.new(currentPos + direction * (tpSpeed / 60), targetPos); hrp.Velocity = Vector3.new(0,0,0) end
        end)
    end
end)
createSlider(PagePlayers, "🚄 傳送速度", 50, 400, 120, function(v) tpSpeed = v end)

-- ///////////////////////////////////////////////////////////
-- //                 熱鍵與結束                            //
-- ///////////////////////////////////////////////////////////

UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == ToggleKey then MainFrame.Visible = not MainFrame.Visible end end)
createButton(PagePlayers, "❌ 關閉 UI", function() if FOVCircle then FOVCircle:Remove() end; ScreenGui:Destroy() end)

PageVehicles.Visible = true
print("HamsterHub V43 Ultimate: Boat Speed Edition Loaded!")
