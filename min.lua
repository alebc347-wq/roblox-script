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

-- ///////////////////////////////////////////////////////////
-- //                 UI 基礎設定 (Hamster V40 Stable)      //
-- ///////////////////////////////////////////////////////////

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HamsterHub_V40_Stable"
-- 優先嘗試掛載到 CoreGui (防偵測)，失敗則掛載到 PlayerGui
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 全局變數
local ToggleKey = Enum.KeyCode.K
local ToggleKeyName = "K"
local selectedPlayer = nil

-- 主視窗
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(255, 180, 50)
UIStroke.Thickness = 2

-- ///////////////////////////////////////////////////////////
-- //                 確認退出視窗 (Safe Exit)              //
-- ///////////////////////////////////////////////////////////

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Parent = ScreenGui
ConfirmFrame.Size = UDim2.new(0, 320, 0, 160)
ConfirmFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 100
Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", ConfirmFrame).Color = Color3.fromRGB(255, 50, 50)
Instance.new("UIStroke", ConfirmFrame).Thickness = 2

local ConfirmTitle = Instance.new("TextLabel", ConfirmFrame)
ConfirmTitle.Size = UDim2.new(1, 0, 0.4, 0)
ConfirmTitle.Text = "確定要退出嗎？(將重生)"
ConfirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Font = Enum.Font.GothamBlack
ConfirmTitle.TextSize = 18

local YesBtn = Instance.new("TextButton", ConfirmFrame)
YesBtn.Size = UDim2.new(0, 120, 0, 40)
YesBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
YesBtn.Text = "是 (退出)"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 8)

-- 這裡處理退出邏輯：刪除 FOV 圈、刪除 UI、重生
local FOVCircle -- 先宣告變數以供刪除
YesBtn.MouseButton1Click:Connect(function()
    if FOVCircle and FOVCircle.Remove then FOVCircle:Remove() end
    ScreenGui:Destroy()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

local NoBtn = Instance.new("TextButton", ConfirmFrame)
NoBtn.Size = UDim2.new(0, 120, 0, 40)
NoBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
NoBtn.Text = "取消"
NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 8)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)

-- ///////////////////////////////////////////////////////////
-- //                 側邊欄與佈局                          //
-- ///////////////////////////////////////////////////////////

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.Text = "Hamster V40"
Title.Size = UDim2.new(1, 0, 0, 60)
Title.TextColor3 = Color3.fromRGB(255, 180, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.BackgroundTransparency = 1

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Parent = Sidebar
TabContainer.Position = UDim2.new(0, 0, 0, 70)
TabContainer.Size = UDim2.new(1, 0, 1, -70)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 2
TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 190, 0, 60)
ContentArea.Size = UDim2.new(1, -200, 1, -70)
ContentArea.BackgroundTransparency = 1

-- ///////////////////////////////////////////////////////////
-- //                 UI 生成函數                           //
-- ///////////////////////////////////////////////////////////

local function createTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Parent = ContentArea
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Page
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Btn = Instance.new("TextButton")
    Btn.Parent = TabContainer
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundTransparency = 1
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextSize = 14
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        Page.Visible = true; Btn.TextColor3 = Color3.fromRGB(255, 180, 50)
    end)
    return Page
end

local function createButton(page, text, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,45); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Btn = Instance.new("TextButton"); Btn.Parent=Frame; Btn.Size=UDim2.new(1,0,1,0); Btn.BackgroundTransparency=1; Btn.Text=text; Btn.TextColor3=Color3.fromRGB(0,255,255); Btn.Font=Enum.Font.GothamBold; Btn.TextSize=15
    Btn.MouseButton1Click:Connect(callback)
end

local function createToggle(page, name, default, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,45); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel"); Label.Parent=Frame; Label.Text=name; Label.Size=UDim2.new(0.7,0,1,0); Label.Position=UDim2.new(0,15,0,0); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Btn = Instance.new("TextButton"); Btn.Parent=Frame; Btn.Size=UDim2.new(0,40,0,25); Btn.Position=UDim2.new(1,-50,0.5,-12.5); Btn.BackgroundColor3=default and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); Btn.Text=""; Instance.new("UICorner",Btn).CornerRadius=UDim.new(1,0)
    local isOn = default
    Btn.MouseButton1Click:Connect(function() isOn=not isOn; Btn.BackgroundColor3=isOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); callback(isOn) end)
end

local function createSlider(page, name, min, max, default, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,60); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel"); Label.Parent=Frame; Label.Text=name..": "..default; Label.Size=UDim2.new(1,-20,0,25); Label.Position=UDim2.new(0,15,0,5); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Bar = Instance.new("Frame"); Bar.Parent=Frame; Bar.Size=UDim2.new(1,-30,0,8); Bar.Position=UDim2.new(0,15,0,40); Bar.BackgroundColor3=Color3.fromRGB(60,60,60); Instance.new("UICorner",Bar).CornerRadius=UDim.new(1,0)
    local Fill = Instance.new("Frame"); Fill.Parent=Bar; Fill.Size=UDim2.new((default-min)/(max-min),0,1,0); Fill.BackgroundColor3=Color3.fromRGB(255, 180, 50); Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
    local Trigger = Instance.new("TextButton"); Trigger.Parent=Bar; Trigger.Size=UDim2.new(1,0,1,0); Trigger.BackgroundTransparency=1; Trigger.Text=""
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
    local L = Instance.new("TextLabel"); L.Parent=page; L.Size=UDim2.new(1,-10,0,30); L.BackgroundTransparency=1; L.Text=text; L.TextColor3=Color3.fromRGB(200,200,200); L.Font=Enum.Font.Gotham; L.TextSize=14
    return L
end

local function createTextBox(page, placeholder, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,50); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Box = Instance.new("TextBox"); Box.Parent=Frame; Box.Size=UDim2.new(0.9,0,0.8,0); Box.Position=UDim2.new(0.05,0,0.1,0); Box.BackgroundTransparency=1; Box.Text=""; Box.PlaceholderText=placeholder; Box.TextColor3=Color3.fromRGB(255,255,255); Box.Font=Enum.Font.Gotham; Box.TextSize=16
    Box.FocusLost:Connect(function() callback(Box.Text) end)
    return Box
end

-- 頂部按鈕
local function createBigTopBtn(text, color, order, callback)
    local btn = Instance.new("TextButton"); btn.Parent = MainFrame; btn.Size = UDim2.new(0, 40, 0, 40); btn.AnchorPoint = Vector2.new(1, 0); local rightPadding = 10 + (order * 50); btn.Position = UDim2.new(1, -rightPadding, 0, 10); btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.BackgroundColor3 = color; btn.BackgroundTransparency = 0.2; btn.Font = Enum.Font.GothamBlack; btn.TextSize = 20; btn.ZIndex = 30; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); btn.MouseButton1Click:Connect(callback); return btn
end

createBigTopBtn("X", Color3.fromRGB(200, 50, 50), 0, function() ConfirmFrame.Visible = true end)
local isMaximized = false
createBigTopBtn("□", Color3.fromRGB(50, 180, 100), 1, function()
    isMaximized = not isMaximized
    if isMaximized then MainFrame:TweenSize(UDim2.new(0, 900, 0, 600), "Out", "Quad", 0.3, true)
    else MainFrame:TweenSize(UDim2.new(0, 650, 0, 450), "Out", "Quad", 0.3, true) end
end)
createBigTopBtn("-", Color3.fromRGB(200, 160, 50), 2, function() MainFrame.Visible = false end)

-- ///////////////////////////////////////////////////////////
-- //                 功能核心 (Tabs)                       //
-- ///////////////////////////////////////////////////////////

local PagePlayers = createTab("👥 玩家/聊天")
local PageBF = createTab("🍎 海賊王 (Blox Fruits)")
local PageRage = createTab("⚡ 暴力引擎 (Rage)")
local PageStats = createTab("🔢 數值修改 (Stats)")
local PageRivals = createTab("🔫 競爭者 (Rivals)")
local PageVisual = createTab("👁️ 視覺透視 (Visual)")
local PageSettings = createTab("⚙️ 設定 (Settings)")

-- ///////////////////////////////////////////////////////////
-- //              👁️ 視覺透視 (Visual) [修復版 - 不消失]   //
-- ///////////////////////////////////////////////////////////

createLabel(PageVisual, "== 進階透視 (ESP) ==")

-- 使用一個 Table 來管理已經存在的 ESP 物件，而不是每次都刪除
local ESP_Holder = {}
local espEnabled = false
local espConnection = nil

local function UpdateESP()
    if not espEnabled then 
        for i, v in pairs(ESP_Holder) do v:Destroy() end
        ESP_Holder = {}
        return 
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            -- 如果這個玩家還沒有 ESP，就創建一個
            if not ESP_Holder[player] then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ESP"
                bb.Size = UDim2.new(0, 200, 0, 50)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel", bb)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.TextStrokeTransparency = 0
                txt.TextColor3 = Color3.fromRGB(0, 255, 0)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 14
                
                bb.Parent = CoreGui -- 掛載到 CoreGui 防止被遊戲刪除
                ESP_Holder[player] = {gui = bb, label = txt}
            end
            
            -- 更新位置和文字
            local esp = ESP_Holder[player]
            esp.gui.Adornee = player.Character.Head
            
            -- 計算距離
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                esp.label.Text = player.DisplayName .. "\n[" .. math.floor(dist) .. "m]"
                
                -- 距離越遠顏色越紅
                if dist < 100 then esp.label.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif dist < 500 then esp.label.TextColor3 = Color3.fromRGB(255, 255, 0)
                else esp.label.TextColor3 = Color3.fromRGB(255, 0, 0) end
            end
        else
            -- 如果玩家離開或死亡，清除 ESP
            if ESP_Holder[player] then
                ESP_Holder[player].gui:Destroy()
                ESP_Holder[player] = nil
            end
        end
    end
    
    -- 清理已離開的玩家
    for p, data in pairs(ESP_Holder) do
        if not p.Parent then
            data.gui:Destroy()
            ESP_Holder[p] = nil
        end
    end
end

createToggle(PageVisual, "👁️ 啟用透視 (Render Update)", false, function(state)
    espEnabled = state
    if state then
        -- 使用 BindToRenderStep 確保每一幀都更新，絕不閃爍
        RunService:BindToRenderStep("ESP_Update", Enum.RenderPriority.Camera.Value, UpdateESP)
    else
        RunService:UnbindFromRenderStep("ESP_Update")
        UpdateESP() -- 清除
    end
end)

createLabel(PageVisual, "提示: 透視使用即時渲染，不會消失")

-- ///////////////////////////////////////////////////////////
-- //              🔫 競爭者 (RIVALS) [Tween 自瞄]          //
-- ///////////////////////////////////////////////////////////

createLabel(PageRivals, "== 自動瞄準 (Aimbot) ==")

local AimEnabled = false
local AimHolding = false
local AimSensitivity = 0
local TeamCheck = false
local FOVRadius = 80
local FOVVisible = true

-- 建立 FOV 圓圈 (安全檢查)
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOVRadius
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Transparency = 0.7
    FOVCircle.NumSides = 64
    FOVCircle.Thickness = 1
end

local function GetClosestPlayer()
    local MaximumDistance = FOVRadius
    local Target = nil
    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if TeamCheck and v.Team == LocalPlayer.Team then continue end
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local ScreenPoint, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                if VectorDistance < MaximumDistance and OnScreen then Target = v; MaximumDistance = VectorDistance end
            end
        end
    end
    return Target
end

UserInputService.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton2 then AimHolding = true end end)
UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton2 then AimHolding = false end end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        FOVCircle.Radius = FOVRadius
        FOVCircle.Visible = FOVVisible and AimEnabled
    end
    if AimHolding and AimEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            TweenService:Create(Camera, TweenInfo.new(AimSensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)}):Play()
        end
    end
end)

createToggle(PageRivals, "🎯 啟用自瞄 (Hold Right Click)", false, function(s) AimEnabled = s end)
createToggle(PageRivals, "⭕ 顯示 FOV 圈", true, function(s) FOVVisible = s end)
createSlider(PageRivals, "📏 FOV 大小", 10, 500, 80, function(v) FOVRadius = v end)
createSlider(PageRivals, "🐢 平滑度 (0=強)", 0, 10, 0, function(v) AimSensitivity = v/10 end)
createToggle(PageRivals, "🛡️ 隊伍檢查", false, function(s) TeamCheck = s end)

createLabel(PageRivals, "== 其他 ==")
createToggle(PageRivals, "📦 擴大頭部 (Hitbox)", false, function(state) spawn(function() while state do for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then p.Character.Head.Size = Vector3.new(5,5,5); p.Character.Head.Transparency = 0.5; p.Character.Head.CanCollide = false end end wait(1) end end) end)

-- ///////////////////////////////////////////////////////////
-- //              👥 玩家管理 (Players)                    //
-- ///////////////////////////////////////////////////////////

createLabel(PagePlayers, "== 玩家操作 ==")
local SelectedLabel = createLabel(PagePlayers, "當前選擇: 無")
SelectedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Parent = PagePlayers; ListFrame.Size = UDim2.new(1, -5, 0, 150); ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0); ListFrame.ScrollBarThickness = 3
local ListLayout = Instance.new("UIListLayout"); ListLayout.Parent = ListFrame; ListLayout.Padding = UDim.new(0, 2)

local function refreshPlayerList()
    for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local contentSize = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton"); btn.Parent = ListFrame; btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); btn.Text = "  " .. p.DisplayName; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Gotham; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.TextSize = 14
            btn.MouseButton1Click:Connect(function() selectedPlayer = p; SelectedLabel.Text = "當前選擇: " .. p.DisplayName; end)
            contentSize = contentSize + 32
        end
    end
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize)
end
createButton(PagePlayers, "🔄 刷新列表", refreshPlayerList); refreshPlayerList()

createButton(PagePlayers, "🚀 傳送至玩家", function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
        local root = LocalPlayer.Character.HumanoidRootPart
        for i = 1, 10 do root.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3); root.Velocity = Vector3.new(0,0,0); RunService.RenderStepped:Wait() end
    end
end)

createLabel(PagePlayers, "== 踢出功能 ==")
createButton(PagePlayers, "🌪️ 暴力甩飛 (Fling Kick)", function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bambam = Instance.new("BodyAngularVelocity"); bambam.Parent = LocalPlayer.Character.HumanoidRootPart; bambam.AngularVelocity = Vector3.new(0,99999,0); bambam.MaxTorque = Vector3.new(0,math.huge,0); bambam.P = math.huge
        local conn; conn = RunService.RenderStepped:Connect(function() if not selectedPlayer.Character then conn:Disconnect(); bambam:Destroy(); return end LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame; LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end)
        delay(3, function() if conn then conn:Disconnect() end if bambam then bambam:Destroy() end end)
    end
end)
createButton(PagePlayers, "💀 重置並關閉UI (Self Kick)", function() if FOVCircle and FOVCircle.Remove then FOVCircle:Remove() end ScreenGui:Destroy() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end)

-- ///////////////////////////////////////////////////////////
-- //              🍎 海賊王 & ⚡ 暴力 & 🔢 數值          //
-- ///////////////////////////////////////////////////////////

createLabel(PageBF, "== 攻擊與自動 ==")
local autoAtk = false; createToggle(PageBF, "⚡ 連續普攻 (Auto Attack)", false, function(s) autoAtk = s; if s then spawn(function() while autoAtk do VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0,0)); if LocalPlayer.Character then local t=LocalPlayer.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end task.wait(0.1) end end) end end)
createButton(PageBF, "🏃 戰術撤退", function() if LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5000, 0) end end)
createLabel(PageBF, "== 🍎 果實 ==")
createButton(PageBF, "🍎 100% 紅果連點", function() spawn(function() local args = {[1] = "Cousin", [2] = "Buy"}; for i = 1, 50 do if game.ReplicatedStorage:FindFirstChild("Remotes") and game.ReplicatedStorage.Remotes:FindFirstChild("CommF_") then game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args)) end wait(0.05) end end) end)

createLabel(PageRage, "== 暴力引擎 ==")
local cfSpeed=false; local cfVal=1; RunService.Stepped:Connect(function() if cfSpeed and LocalPlayer.Character then local h=LocalPlayer.Character.Humanoid; local r=LocalPlayer.Character.HumanoidRootPart; if h.MoveDirection.Magnitude>0 then r.CFrame=r.CFrame+(h.MoveDirection*cfVal) end end end)
createToggle(PageRage, "⏩ 暴力加速", false, function(s) cfSpeed=s end); createSlider(PageRage, "⚡ 強度", 1, 10, 2, function(v) cfVal=v/2 end)
local flyOn=false; local flySpd=50; createToggle(PageRage, "🚀 暴力飛行", false, function(s) flyOn=s; if s then RunService:BindToRenderStep("Fly",1,function() if LocalPlayer.Character then local r=LocalPlayer.Character.HumanoidRootPart; LocalPlayer.Character.Humanoid.PlatformStand=true; r.Velocity=Vector3.new(0,0,0); local c=workspace.CurrentCamera; local m=Vector3.new(); if UserInputService:IsKeyDown(Enum.KeyCode.W) then m=m+c.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then m=m-c.CFrame.LookVector end; r.CFrame=r.CFrame+m*(flySpd/20) end end) else RunService:UnbindFromRenderStep("Fly"); if LocalPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand=false end end end); createSlider(PageRage, "✈️ 速度", 10, 300, 50, function(v) flySpd=v end)
local noclip=false; RunService.Stepped:Connect(function() if noclip and LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end); createToggle(PageRage, "👻 穿牆", false, function(s) noclip=s end)

createLabel(PageStats, "== 數值 ==")
createSlider(PageStats, "🏃 走路速度", 16, 500, 16, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed=v end end)
createSlider(PageStats, "⬆️ 跳躍高度", 50, 400, 50, function(v) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.UseJumpPower=true; LocalPlayer.Character.Humanoid.JumpPower=v end end)
local infJump = false; UserInputService.JumpRequest:Connect(function() if infJump and LocalPlayer.Character then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
createToggle(PageStats, "☁️ 無限跳", false, function(s) infJump=s end)

-- Settings
createLabel(PageSettings, "== 設定 ==")
createTextBox(PageSettings, "按鍵綁定 (例: P)", function(t) if #t>0 then ToggleKey=Enum.KeyCode[string.upper(string.sub(t,1,1))] end end)
createToggle(PageSettings, "究極防踢", true, function() end)

UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
        if FOVCircle then FOVCircle.Visible = MainFrame.Visible and FOVVisible end
    end
end)

PagePlayers.Visible = true
print("HamsterHub_V40_Stable Loaded")
