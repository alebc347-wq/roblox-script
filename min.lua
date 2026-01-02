local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ///////////////////////////////////////////////////////////
-- //                 UI 基礎設定 (hamster V9)              //
-- ///////////////////////////////////////////////////////////

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "hamsterHub_V9_UI"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 主視窗
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

-- 圓角與裝飾
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(255, 180, 50) -- 琥珀金
UIStroke.Thickness = 2
UIStroke.Transparency = 0.2

-- ///////////////////////////////////////////////////////////
-- //                 確認視窗 & 通知提示 (新功能)          //
-- ///////////////////////////////////////////////////////////

-- 1. 退出確認視窗 (Confirm Dialog)
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Parent = ScreenGui
ConfirmFrame.Size = UDim2.new(0, 300, 0, 150)
ConfirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 10
Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConfirmFrame).Color = Color3.fromRGB(255, 50, 50)

local ConfirmTitle = Instance.new("TextLabel", ConfirmFrame)
ConfirmTitle.Size = UDim2.new(1, 0, 0.5, 0)
ConfirmTitle.Text = "確定要退出嗎？"
ConfirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextSize = 18
ConfirmTitle.ZIndex = 10

local YesBtn = Instance.new("TextButton", ConfirmFrame)
YesBtn.Size = UDim2.new(0, 100, 0, 35)
YesBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
YesBtn.Text = "退出 (Yes)"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.ZIndex = 10
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton", ConfirmFrame)
NoBtn.Size = UDim2.new(0, 100, 0, 35)
NoBtn.Position = UDim2.new(0.6, -10, 0.6, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NoBtn.Text = "取消 (No)"
NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoBtn.Font = Enum.Font.GothamBold
NoBtn.ZIndex = 10
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

-- 2. 右下角縮小提示 (Notification)
local NotifyLabel = Instance.new("TextLabel")
NotifyLabel.Parent = ScreenGui
NotifyLabel.Size = UDim2.new(0, 200, 0, 40)
NotifyLabel.Position = UDim2.new(1, -220, 1, -60) -- 右下角
NotifyLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotifyLabel.BackgroundTransparency = 0.2
NotifyLabel.Text = "按 [K] 重新開啟介面"
NotifyLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
NotifyLabel.Font = Enum.Font.GothamBold
NotifyLabel.TextSize = 14
NotifyLabel.Visible = false
Instance.new("UICorner", NotifyLabel).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", NotifyLabel).Color = Color3.fromRGB(0, 255, 255)

-- ///////////////////////////////////////////////////////////
-- //                 側邊欄與佈局                          //
-- ///////////////////////////////////////////////////////////

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = Sidebar
Title.Text = "hamster V9"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 180, 50)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.BackgroundTransparency = 1

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Parent = Sidebar
TabContainer.Position = UDim2.new(0, 0, 0, 60)
TabContainer.Size = UDim2.new(1, 0, 1, -60)
TabContainer.BackgroundTransparency = 1
TabContainer.ScrollBarThickness = 2

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 160, 0, 10)
ContentArea.Size = UDim2.new(1, -170, 1, -20)
ContentArea.BackgroundTransparency = 1

-- ///////////////////////////////////////////////////////////
-- //                 右上角控制鍵 (Min, Max, Close)        //
-- ///////////////////////////////////////////////////////////

local function createTopBtn(text, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0, 30, 0, 30)
    -- 計算位置：最右邊是 Close, 往左推
    btn.Position = UDim2.new(1, -35 * order - 5, 0, 5) 
    btn.Text = text
    btn.TextColor3 = color
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 18
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. 關閉鍵 (X) - 顯示確認視窗
createTopBtn("X", Color3.fromRGB(255, 80, 80), 0, function()
    ConfirmFrame.Visible = true
end)

-- 2. 放大/還原鍵 (□) - 切換大小
local isMaximized = false
createTopBtn("□", Color3.fromRGB(80, 255, 150), 1, function()
    isMaximized = not isMaximized
    if isMaximized then
        MainFrame:TweenSize(UDim2.new(0, 700, 0, 450), "Out", "Quad", 0.3, true)
        ContentArea.Size = UDim2.new(1, -170, 1, -20)
    else
        MainFrame:TweenSize(UDim2.new(0, 560, 0, 360), "Out", "Quad", 0.3, true)
        ContentArea.Size = UDim2.new(1, -170, 1, -20)
    end
end)

-- 3. 縮小鍵 (-) - 隱藏並顯示提示
createTopBtn("-", Color3.fromRGB(255, 200, 80), 2, function()
    MainFrame.Visible = false
    NotifyLabel.Visible = true
    -- 提示框顯示 3 秒後淡出
    wait(3)
    if NotifyLabel.Visible then
        NotifyLabel.Visible = false
    end
end)

-- 確認視窗邏輯
YesBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
NoBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = false
end)


-- ///////////////////////////////////////////////////////////
-- //                 功能組件函數                        //
-- ///////////////////////////////////////////////////////////

local function createTab(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Parent = ContentArea
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Page
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    local Btn = Instance.new("TextButton")
    Btn.Parent = TabContainer
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundTransparency = 1
    Btn.Text = "  " .. name
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextSize = 14
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
        Page.Visible = true
        Btn.TextColor3 = Color3.fromRGB(255, 180, 50)
    end)
    return Page
end

local function createToggle(page, name, default, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,40); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel"); Label.Parent=Frame; Label.Text=name; Label.Size=UDim2.new(0.7,0,1,0); Label.Position=UDim2.new(0,10,0,0); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Btn = Instance.new("TextButton"); Btn.Parent=Frame; Btn.Size=UDim2.new(0,40,0,20); Btn.Position=UDim2.new(1,-50,0.5,-10); Btn.BackgroundColor3=default and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); Btn.Text=""; Instance.new("UICorner",Btn).CornerRadius=UDim.new(1,0)
    local isOn = default
    Btn.MouseButton1Click:Connect(function() isOn=not isOn; Btn.BackgroundColor3=isOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(60,60,60); callback(isOn) end)
end

local function createSlider(page, name, min, max, default, callback)
    local Frame = Instance.new("Frame"); Frame.Parent=page; Frame.Size=UDim2.new(1,-5,0,50); Frame.BackgroundColor3=Color3.fromRGB(35,35,40); Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,6)
    local Label = Instance.new("TextLabel"); Label.Parent=Frame; Label.Text=name..": "..default; Label.Size=UDim2.new(1,-20,0,20); Label.Position=UDim2.new(0,10,0,5); Label.BackgroundTransparency=1; Label.TextColor3=Color3.fromRGB(255,255,255); Label.Font=Enum.Font.GothamSemibold; Label.TextXAlignment=Enum.TextXAlignment.Left; Label.TextSize=14
    local Bar = Instance.new("Frame"); Bar.Parent=Frame; Bar.Size=UDim2.new(1,-20,0,6); Bar.Position=UDim2.new(0,10,0,30); Bar.BackgroundColor3=Color3.fromRGB(60,60,60); Instance.new("UICorner",Bar).CornerRadius=UDim.new(1,0)
    local Fill = Instance.new("Frame"); Fill.Parent=Bar; Fill.Size=UDim2.new((default-min)/(max-min),0,1,0); Fill.BackgroundColor3=Color3.fromRGB(255, 180, 50); Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0)
    local Trigger = Instance.new("TextButton"); Trigger.Parent=Bar; Trigger.Size=UDim2.new(1,0,1,0); Trigger.BackgroundTransparency=1; Trigger.Text=""
    local dragging=false
    local function update(input)
        local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        local v = math.floor(min + (max - min) * p)
        Label.Text = name .. ": " .. v
        callback(v)
    end
    Trigger.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i) end end)
end

-- ///////////////////////////////////////////////////////////
-- //                 V9 功能核心                           //
-- ///////////////////////////////////////////////////////////

local PageStats = createTab("數值修改 (Stats)")
local PageRage = createTab("暴力破解 (Rage)")
local PageCombat = createTab("戰鬥輔助 (Combat)")
local PageVisual = createTab("視覺透視 (Visual)")

-- GOD Mode
local godMode = false
RunService.Stepped:Connect(function()
    if godMode and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = math.huge; hum.Health = math.huge
            if not LocalPlayer.Character:FindFirstChildOfClass("ForceField") then
                local ff = Instance.new("ForceField")
                ff.Parent = LocalPlayer.Character; ff.Visible = true
            end
        end
    end
end)
createToggle(PageStats, "👑 GOD Mode (無敵+防護罩)", false, function(state)
    godMode = state
    if not state and LocalPlayer.Character then
        for _,o in pairs(LocalPlayer.Character:GetChildren()) do if o:IsA("ForceField") then o:Destroy() end end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum.MaxHealth=100 end
    end
end)

createSlider(PageStats, "🏃 走路速度", 16, 1000, 16, function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed=val end end)
createSlider(PageStats, "⬆️ 跳躍高度", 50, 500, 50, function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower=true; LocalPlayer.Character.Humanoid.JumpPower=val end end)

local infJump=false
UserInputService.JumpRequest:Connect(function() if infJump and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end end)
createToggle(PageStats, "☁️ 無限跳 (Infinite Jump)", false, function(state) infJump=state end)

local antiAFK=true
LocalPlayer.Idled:Connect(function() if antiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end)
createToggle(PageStats, "🛡️ 防掛機 (Anti-AFK)", true, function(state) antiAFK=state end)

local cfSpeed=false; local cfVal=1
RunService.Stepped:Connect(function()
    if cfSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid; local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum.MoveDirection.Magnitude > 0 and root then root.CFrame = root.CFrame + (hum.MoveDirection * cfVal) end
    end
end)
createToggle(PageRage, "⏩ 暴力加速 (CFrame)", false, function(state) cfSpeed=state end)
createSlider(PageRage, "⚡ 強度設定", 1, 10, 2, function(val) cfVal=val/2 end)

local flyOn, flySpd=false, 50
local function flyUpdate()
    if not flyOn or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand=true
    local cam=workspace.CurrentCamera; local dir=Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
    if dir.Magnitude>0 then root.CFrame=root.CFrame+(dir.Unit*(flySpd/10)); root.Velocity=Vector3.new(0,0,0) end
end
createToggle(PageRage, "🚀 暴力飛行 (Fly)", false, function(state) flyOn=state; if state then RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, flyUpdate) else RunService:UnbindFromRenderStep("Fly"); if LocalPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand=false end end end)
createSlider(PageRage, "✈️ 飛行速度", 10, 300, 50, function(val) flySpd=val end)

local noclip=false
RunService.Stepped:Connect(function() if noclip and LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide=false end end end end)
createToggle(PageRage, "👻 穿牆 (Noclip)", false, function(state) noclip=state end)

local kAura, kDist = false, 25
RunService.Heartbeat:Connect(function()
    if not kAura or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local eRoot = p.Character.HumanoidRootPart
            if (eRoot.Position - root.Position).Magnitude < kDist and p.Character.Humanoid.Health>0 then
                root.CFrame = CFrame.new(root.Position, Vector3.new(eRoot.Position.X, root.Position.Y, eRoot.Position.Z))
                local t = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if t then t:Activate() else VirtualUser:ClickButton1(Vector2.new()) end
            end
        end
    end
end)
createToggle(PageCombat, "⚔️ 狂暴普攻 (Kill Aura)", false, function(state) kAura=state end)
createSlider(PageCombat, "📏 攻擊範圍", 10, 50, 25, function(val) kDist=val end)

local aimOn, aimFov = false, 300
RunService.RenderStepped:Connect(function()
    if aimOn then
        local t, dist = nil, aimFov; local m = UserInputService:GetMouseLocation()
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local d = (Vector2.new(pos.X,pos.Y)-m).Magnitude
                    if d<dist then dist=d; t=p.Character.Head end
                end
            end
        end
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), 0.2) end
    end
end)
createToggle(PageCombat, "🎯 自瞄 (Aimbot)", false, function(state) aimOn=state end)
createSlider(PageCombat, "⭕ 鎖定範圍", 50, 800, 300, function(val) aimFov=val end)

local espOn=false; local espFolder=Instance.new("Folder", CoreGui)
local function updESP()
    espFolder:ClearAllChildren()
    if not espOn then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local h = Instance.new("Highlight", espFolder); h.Adornee=p.Character; h.FillColor=Color3.fromRGB(255,0,0); h.FillTransparency=0.5; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end
createToggle(PageVisual, "👁️ 玩家透視 (ESP)", false, function(state) espOn=state; updESP(); if state then spawn(function() while espOn do wait(3) updESP() end end) end end)

UserInputService.InputBegan:Connect(function(i) 
    if i.KeyCode==Enum.KeyCode.K then -- 按 K 顯示/隱藏
        MainFrame.Visible = not MainFrame.Visible
        NotifyLabel.Visible = false -- 既然已經開了，就隱藏提示
    end 
end)

PageStats.Visible = true
local firstBtn = TabContainer:FindFirstChildOfClass("TextButton")
if firstBtn then firstBtn.TextColor3 = Color3.fromRGB(255, 180, 50) end

print("hamsterHub_V9_UI Loaded")
