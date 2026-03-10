-- m0dzn ui library v1.0
-- dark futuristic style, obsidian black + crimson red
-- config system works like orion (flags table, auto save/load)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- every interactive element registers its value here automatically
-- this is what the config system reads when saving
Library.Flags = {}

local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow"
local SFXEnabled = true
local Registry = {}
local ConfigObjects = {}

local Sounds = {
    Hover        = "rbxassetid://4510086912",
    Click        = "rbxassetid://4510086561",
    ToggleOn     = "rbxassetid://4510087425",
    ToggleOff    = "rbxassetid://4510087425",
    Slide        = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Back         = "rbxassetid://4510087236",
    Error        = "rbxassetid://4510087545",
    Tab          = "rbxassetid://4510087056"
}

local function PlaySound(id)
    if not SFXEnabled then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 0.5
        s.Parent = SoundService
        s:Play()
        game.Debris:AddItem(s, 2)
    end)
end

-- dark is the default theme, obsidian black + crimson red
local Themes = {
    Dark   = {Main = Color3.fromRGB(6, 6, 8),      Top = Color3.fromRGB(14, 14, 18),   Text = Color3.fromRGB(220, 220, 230), Accent = Color3.fromRGB(210, 30, 45),  Stroke = Color3.fromRGB(35, 12, 15)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20),   Accent = Color3.fromRGB(0, 100, 210),  Stroke = Color3.fromRGB(220, 220, 225)},
    Purple = {Main = Color3.fromRGB(18, 15, 22),    Top = Color3.fromRGB(30, 25, 35),   Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255), Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28),    Top = Color3.fromRGB(25, 32, 45),   Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255), Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(6, 6, 8),       Top = Color3.fromRGB(14, 14, 18),   Text = Color3.fromRGB(220, 220, 230), Accent = Color3.fromRGB(210, 30, 45),  Stroke = Color3.fromRGB(35, 12, 15)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12),    Top = Color3.fromRGB(35, 35, 20),   Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80), Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15),    Top = Color3.fromRGB(20, 35, 25),   Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130), Stroke = Color3.fromRGB(40, 60, 50)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeKey)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeKey})
    obj[prop] = CurrentTheme[themeKey]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function Library:SetTheme(name)
    if Themes[name] then
        CurrentTheme = Themes[name]
        for _, r in pairs(Registry) do
            if r.Object then
                Tween(r.Object, {[r.Property] = CurrentTheme[r.Type]})
            end
        end
    end
end

function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end

-- saves all flag values to a json file
function Library:SaveConfig(configName, configFolder)
    if not isfolder(configFolder) then makefolder(configFolder) end
    local data = {}
    for flag, val in pairs(self.Flags) do
        data[flag] = val
    end
    writefile(configFolder .. "/" .. configName .. ".json", HttpService:JSONEncode(data))
end

-- reads a config file and updates all ui elements to match what was saved
function Library:LoadConfig(path)
    if not isfile(path) then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end
    for flag, val in pairs(data) do
        self.Flags[flag] = val
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            ConfigObjects[flag].Set(val)
        end
    end
    return true
end

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "m0dzn ui"
    local Keybind = Config.Keybind

    Window.RootFolder = Title
    Window.ConfigFolder = Title .. "/Config"
    Window.CurrentConfig = ""

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif gethui then
        ScreenGui.Parent = gethui()
    end

    -- main window, starts invisible and tweens open
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    -- outer border, crimson by default
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.15
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Accent")

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    -- soft red glow behind the content area for depth
    local GlowBlob = Instance.new("ImageLabel")
    GlowBlob.Size = UDim2.new(0, 380, 0, 280)
    GlowBlob.Position = UDim2.new(0.5, -190, 0, -90)
    GlowBlob.BackgroundTransparency = 1
    GlowBlob.Image = "rbxassetid://5028857472"
    GlowBlob.ImageColor3 = Color3.fromRGB(160, 15, 25)
    GlowBlob.ImageTransparency = 0.78
    GlowBlob.ZIndex = 0
    GlowBlob.ScaleType = Enum.ScaleType.Fit
    GlowBlob.Parent = MainFrame

    -- thin crimson line at the top of the window
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 0)
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 6
    TopLine.Parent = MainFrame
    Instance.new("UICorner", TopLine).CornerRadius = UDim.new(0, 10)
    AddToRegistry(TopLine, "BackgroundColor3", "Accent")

    -- gradient overlay on the topbar to fade from dark into the window
    local TopGrad = Instance.new("Frame")
    TopGrad.Size = UDim2.new(1, 0, 0, 60)
    TopGrad.Position = UDim2.new(0, 0, 0, 0)
    TopGrad.BackgroundTransparency = 0
    TopGrad.BorderSizePixel = 0
    TopGrad.ZIndex = 1
    TopGrad.Parent = MainFrame
    AddToRegistry(TopGrad, "BackgroundColor3", "Top")
    local TGCorner = Instance.new("UICorner", TopGrad)
    TGCorner.CornerRadius = UDim.new(0, 10)
    local TGGrad = Instance.new("UIGradient", TopGrad)
    TGGrad.Rotation = 90
    TGGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
    })
    TGGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    -- rainbow border loop
    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick()
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Gradient.Enabled = true; Gradient.Rotation = 0
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,255))
                    })
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Gradient.Enabled = false
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.8, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 1.5; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0))
                    })
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Gradient.Enabled = false
                    local step = math.floor((t % 2) * 4) / 4
                    Stroke.Color = Color3.fromHSV(step, 0.8, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Gradient.Enabled = false
                    local pulse = (math.sin(t * 2) + 1) / 2
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,255))
                    })
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Gradient.Enabled = false
                    Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.6, 1)
                elseif RainbowType == "Pastel Rainbow" then
                    Gradient.Enabled = false
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.3, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Gradient.Enabled = true; Gradient.Rotation = 90
                    local c  = Color3.fromHSV(t % 5 / 5, 0.8, 1)
                    local c2 = Color3.fromHSV((t + 1) % 5 / 5, 0.8, 1)
                    Gradient.Color = ColorSequence.new(c, c2)
                    Stroke.Color = Color3.new(1,1,1)
                end
            else
                Gradient.Enabled = false
                Stroke.Color = CurrentTheme.Accent
            end
            RunService.RenderStepped:Wait()
        end
    end)

    -- topbar is invisible, just used for dragging
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 52)
    Topbar.BackgroundTransparency = 1
    Topbar.ZIndex = 4
    Topbar.Parent = MainFrame

    -- small red square icon before the title
    local TitleIcon = Instance.new("Frame")
    TitleIcon.Size = UDim2.new(0, 8, 0, 8)
    TitleIcon.Position = UDim2.new(0, 18, 0.5, -4)
    TitleIcon.BorderSizePixel = 0
    TitleIcon.ZIndex = 5
    TitleIcon.Parent = Topbar
    Instance.new("UICorner", TitleIcon).CornerRadius = UDim.new(0, 2)
    AddToRegistry(TitleIcon, "BackgroundColor3", "Accent")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(0.7, 0, 0, 28)
    TitleLabel.Position = UDim2.new(0, 34, 0.5, -14)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 5
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    -- subtle status pill on the right side of the topbar
    local StatusPill = Instance.new("Frame")
    StatusPill.Size = UDim2.new(0, 68, 0, 20)
    StatusPill.Position = UDim2.new(1, -84, 0.5, -10)
    StatusPill.ZIndex = 5
    StatusPill.BackgroundTransparency = 0.1
    StatusPill.Parent = Topbar
    Instance.new("UICorner", StatusPill).CornerRadius = UDim.new(1, 0)
    AddToRegistry(StatusPill, "BackgroundColor3", "Top")

    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.new(0, 6, 0, 6)
    StatusDot.Position = UDim2.new(0, 8, 0.5, -3)
    StatusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
    StatusDot.ZIndex = 6
    StatusDot.Parent = StatusPill
    Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "online"
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 18, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextSize = 10
    StatusText.ZIndex = 6
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = StatusPill
    AddToRegistry(StatusText, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -68)
    Content.Position = UDim2.new(0, 10, 0, 58)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 138, 0.84, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    -- player info card pinned to the bottom of the sidebar
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 138, 0, 44)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -44)
    ProfileFrame.BackgroundTransparency = 0.04
    ProfileFrame.Parent = Content
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")

    -- left accent bar on the profile card
    local ProfileAccent = Instance.new("Frame")
    ProfileAccent.Size = UDim2.new(0, 3, 0.6, 0)
    ProfileAccent.Position = UDim2.new(0, 0, 0.2, 0)
    ProfileAccent.BorderSizePixel = 0
    ProfileAccent.Parent = ProfileFrame
    Instance.new("UICorner", ProfileAccent).CornerRadius = UDim.new(1, 0)
    AddToRegistry(ProfileAccent, "BackgroundColor3", "Accent")

    local PStroke = Instance.new("UIStroke")
    PStroke.Thickness = 1
    PStroke.Transparency = 0.75
    PStroke.Parent = ProfileFrame
    AddToRegistry(PStroke, "Color", "Accent")

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 28, 0, 28)
    Avatar.Position = UDim2.new(0, 11, 0.5, -14)
    Avatar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local DispName = Instance.new("TextLabel")
    DispName.Text = LocalPlayer.DisplayName
    DispName.Size = UDim2.new(1, -48, 0, 15)
    DispName.Position = UDim2.new(0, 46, 0, 7)
    DispName.BackgroundTransparency = 1
    DispName.Font = Enum.Font.GothamBold
    DispName.TextSize = 11
    DispName.TextXAlignment = Enum.TextXAlignment.Left
    DispName.Parent = ProfileFrame
    AddToRegistry(DispName, "TextColor3", "Text")

    local UsrName = Instance.new("TextLabel")
    UsrName.Text = "@" .. LocalPlayer.Name
    UsrName.Size = UDim2.new(1, -48, 0, 15)
    UsrName.Position = UDim2.new(0, 46, 0, 22)
    UsrName.BackgroundTransparency = 1
    UsrName.Font = Enum.Font.Gotham
    UsrName.TextSize = 10
    UsrName.TextTransparency = 0.5
    UsrName.TextXAlignment = Enum.TextXAlignment.Left
    UsrName.Parent = ProfileFrame
    AddToRegistry(UsrName, "TextColor3", "Text")

    -- thin vertical line between the sidebar and the page content
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 1, 1, 0)
    Divider.Position = UDim2.new(0, 148, 0, 0)
    Divider.BackgroundTransparency = 0.7
    Divider.Parent = Content
    AddToRegistry(Divider, "BackgroundColor3", "Accent")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -162, 1, 0)
    PageContainer.Position = UDim2.new(0, 162, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    -- open animation
    Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 430)}, 0.65)

    -- drag logic
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.2)
        end
    end)

    -- keybind to show or hide the window
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
            if MainFrame.Visible then
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 430)}, 0.5)
            end
        end
    end)

    -- notification toast that slides in from the bottom right
    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame")
            Notif.ZIndex = 100
            Notif.Size = UDim2.new(0, 268, 0, 48)
            Notif.Position = UDim2.new(1, 20, 1, -68)
            Notif.Parent = ScreenGui
            Notif.BackgroundTransparency = 0.04
            Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
            AddToRegistry(Notif, "BackgroundColor3", "Top")

            local NAccentBar = Instance.new("Frame")
            NAccentBar.Size = UDim2.new(0, 3, 0.6, 0)
            NAccentBar.Position = UDim2.new(0, 0, 0.2, 0)
            NAccentBar.BackgroundTransparency = 0
            NAccentBar.ZIndex = 101
            NAccentBar.Parent = Notif
            Instance.new("UICorner", NAccentBar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(NAccentBar, "BackgroundColor3", "Accent")

            local NStroke = Instance.new("UIStroke")
            NStroke.Thickness = 1
            NStroke.Parent = Notif
            NStroke.Transparency = 0.4
            AddToRegistry(NStroke, "Color", "Accent")

            -- small icon dot inside notification
            local NIcon = Instance.new("Frame")
            NIcon.Size = UDim2.new(0, 6, 0, 6)
            NIcon.Position = UDim2.new(0, 14, 0.5, -3)
            NIcon.ZIndex = 102
            NIcon.BorderSizePixel = 0
            NIcon.Parent = Notif
            Instance.new("UICorner", NIcon).CornerRadius = UDim.new(1, 0)
            AddToRegistry(NIcon, "BackgroundColor3", "Accent")

            local NText = Instance.new("TextLabel")
            NText.ZIndex = 101
            NText.Text = text
            NText.Size = UDim2.new(1, -30, 1, 0)
            NText.Position = UDim2.new(0, 26, 0, 0)
            NText.BackgroundTransparency = 1
            NText.Parent = Notif
            NText.Font = Enum.Font.GothamMedium
            NText.TextSize = 12
            NText.TextXAlignment = Enum.TextXAlignment.Left
            AddToRegistry(NText, "TextColor3", "Text")

            -- progress bar that drains while the notification is visible
            local NBar = Instance.new("Frame")
            NBar.Size = UDim2.new(1, 0, 0, 2)
            NBar.Position = UDim2.new(0, 0, 1, -2)
            NBar.ZIndex = 101
            NBar.BorderSizePixel = 0
            NBar.Parent = Notif
            Instance.new("UICorner", NBar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(NBar, "BackgroundColor3", "Accent")
            Tween(NBar, {Size = UDim2.new(0, 0, 0, 2)}, 3)

            Tween(Notif, {Position = UDim2.new(1, -288, 1, -68)}, 0.5)
            task.wait(3)
            Tween(Notif, {Position = UDim2.new(1, 20, 1, -68)}, 0.5)
            task.wait(0.55)
            Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end

    local firstTab = true

    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "    " .. name
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = Color3.fromRGB(85, 85, 92)
        TabBtn.TextSize = 12
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7)

        -- red indicator bar that appears on the active tab
        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0.65, 0)
        TabBar.Position = UDim2.new(0, 0, 0.175, 0)
        TabBar.BackgroundTransparency = 1
        TabBar.BorderSizePixel = 0
        TabBar.Parent = TabBtn
        Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
        AddToRegistry(TabBar, "BackgroundColor3", "Accent")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(210, 30, 45)
        Page.Visible = false
        Page.Parent = PageContainer

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 16)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab)
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(85, 85, 92)})
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then Tween(bar, {BackgroundTransparency = 1}) end
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.06, TextColor3 = CurrentTheme.Text, BackgroundColor3 = CurrentTheme.Top})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        -- hover effect on inactive tabs
        TabBtn.MouseEnter:Connect(function()
            if TabBar.BackgroundTransparency ~= 0 then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(140, 140, 148)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBar.BackgroundTransparency ~= 0 then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(85, 85, 92)}, 0.15)
            end
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.TextColor3 = CurrentTheme.Text
            TabBtn.BackgroundTransparency = 0.06
            TabBtn.BackgroundColor3 = CurrentTheme.Top
            TabBar.BackgroundTransparency = 0
        end

        if name == "Config"   then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}

        -- section label above a group of elements
        function Elements:Section(text)
            local S = Instance.new("TextLabel")
            S.Text = string.upper(text)
            S.Size = UDim2.new(1, 0, 0, 22)
            S.BackgroundTransparency = 1
            S.Font = Enum.Font.GothamBold
            S.TextSize = 10
            S.TextXAlignment = Enum.TextXAlignment.Left
            S.Parent = Page
            S.TextTransparency = 0.35
            AddToRegistry(S, "TextColor3", "Accent")
        end

        -- shared helper that builds a styled dark tile for each element
        local function MakeTile(h)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, h)
            F.Parent = Page
            F.BackgroundTransparency = 0.04
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
            AddToRegistry(F, "BackgroundColor3", "Top")

            local A = Instance.new("Frame")
            A.Size = UDim2.new(0, 3, 0.55, 0)
            A.Position = UDim2.new(0, 0, 0.225, 0)
            A.BorderSizePixel = 0
            A.Parent = F
            Instance.new("UICorner", A).CornerRadius = UDim.new(1, 0)
            AddToRegistry(A, "BackgroundColor3", "Accent")

            local St = Instance.new("UIStroke")
            St.Thickness = 1
            St.Transparency = 0.82
            St.Parent = F
            AddToRegistry(St, "Color", "Stroke")

            return F
        end

        function Elements:Value(text, default, callback)
            local ValFrame = MakeTile(44)

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = text
            NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
            NameLbl.Position = UDim2.new(0, 16, 0, 0)
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Font = Enum.Font.GothamMedium
            NameLbl.TextSize = 13
            NameLbl.BackgroundTransparency = 1
            NameLbl.Parent = ValFrame
            AddToRegistry(NameLbl, "TextColor3", "Text")

            local ValBox = Instance.new("TextBox")
            ValBox.Text = tostring(default)
            ValBox.Size = UDim2.new(0.28, 0, 0, 28)
            ValBox.Position = UDim2.new(0.72, -14, 0.5, -14)
            ValBox.Font = Enum.Font.GothamMedium
            ValBox.TextSize = 12
            ValBox.TextXAlignment = Enum.TextXAlignment.Center
            ValBox.Parent = ValFrame
            ValBox.BackgroundTransparency = 0.1
            Instance.new("UICorner", ValBox).CornerRadius = UDim.new(0, 6)
            AddToRegistry(ValBox, "BackgroundColor3", "Main")
            AddToRegistry(ValBox, "TextColor3", "Accent")

            Library.Flags[text] = default

            ValBox.FocusLost:Connect(function()
                PlaySound(Sounds.Click)
                Library.Flags[text] = ValBox.Text
                ConfigObjects[text].Value = ValBox.Text
                if callback then callback(ValBox.Text) end
                Window:Notification(text .. " set to " .. ValBox.Text)
            end)

            ConfigObjects[text] = {Type = "Value", Value = default, Set = function(val)
                ValBox.Text = tostring(val)
                Library.Flags[text] = val
            end}
        end

        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Tile = MakeTile(44)
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = text
            TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = Key.Name
            KeyLabel.Size = UDim2.new(0, 86, 0, 28)
            KeyLabel.Position = UDim2.new(1, -100, 0.5, -14)
            KeyLabel.Font = Enum.Font.GothamMedium
            KeyLabel.TextSize = 11
            KeyLabel.Parent = Tile
            KeyLabel.BackgroundTransparency = 0.1
            Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 6)
            AddToRegistry(KeyLabel, "BackgroundColor3", "Main")
            AddToRegistry(KeyLabel, "TextColor3", "Accent")

            Library.Flags[text] = Key.Name

            ClickBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                KeyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    Key = input.KeyCode
                    KeyLabel.Text = Key.Name
                    Library.Flags[text] = Key.Name
                    ConfigObjects[text].Value = Key.Name
                    callback(Key)
                    Window:Notification("keybind changed to " .. Key.Name)
                else
                    KeyLabel.Text = Key.Name
                end
            end)

            ConfigObjects[text] = {Type = "Keybind", Value = Key.Name, Set = function(val)
                Key = Enum.KeyCode[val] or Key
                KeyLabel.Text = Key.Name
                Library.Flags[text] = Key.Name
                callback(Key)
            end}
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 44)
            Btn.Text = "    " .. text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            Btn.BackgroundTransparency = 0.04
            AddToRegistry(Btn, "BackgroundColor3", "Top")
            AddToRegistry(Btn, "TextColor3", "Text")

            local St = Instance.new("UIStroke")
            St.Thickness = 1
            St.Transparency = 0.82
            St.Parent = Btn
            AddToRegistry(St, "Color", "Stroke")

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0, 3, 0.55, 0)
            Bar.Position = UDim2.new(0, 0, 0.225, 0)
            Bar.BorderSizePixel = 0
            Bar.Parent = Btn
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Bar, "BackgroundColor3", "Accent")

            Btn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                Tween(Btn, {Size = UDim2.new(0.97, 0, 0, 40)}, 0.1)
                task.wait(0.1)
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 44)}, 0.15)
                callback()
            end)

            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.0}, 0.18) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0.04}, 0.18) end)
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Tile = MakeTile(44)
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = text
            TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -56, 0.5, -11)
            Switch.Parent = Tile
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
            Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(26, 26, 32)

            -- switch track stroke
            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1
            SwStroke.Transparency = 0.6
            SwStroke.Parent = Switch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Dot.Parent = Switch
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            Library.Flags[text] = Enabled

            local function Update()
                if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(26, 26, 32)})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                Library.Flags[text] = Enabled
                ConfigObjects[text].Value = Enabled
                callback(Enabled)
                Window:Notification(text .. " is now " .. tostring(Enabled))
            end

            ClickBtn.MouseButton1Click:Connect(function() Enabled = not Enabled; Update() end)

            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(val)
                Enabled = val
                Library.Flags[text] = val
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(26, 26, 32)})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                callback(Enabled)
            end}
        end

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Frame = MakeTile(64)

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, -30, 0, 20)
            Lbl.Position = UDim2.new(0, 16, 0, 10)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Frame
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Num = Instance.new("TextLabel")
            Num.Text = tostring(Val)
            Num.Size = UDim2.new(0, 44, 0, 20)
            Num.Position = UDim2.new(1, -56, 0, 10)
            Num.BackgroundTransparency = 1
            Num.TextColor3 = Color3.fromRGB(210, 30, 45)
            Num.Font = Enum.Font.GothamBold
            Num.TextSize = 12
            Num.TextXAlignment = Enum.TextXAlignment.Right
            Num.Parent = Frame

            -- track background
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -30, 0, 5)
            Track.Position = UDim2.new(0, 16, 0, 46)
            Track.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
            Track.BorderSizePixel = 0
            Track.Parent = Frame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Val - min) / (max - min), 0, 1, 0)
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Fill, "BackgroundColor3", "Accent")

            -- small draggable knob at the end of the fill
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new((Val - min) / (max - min), 0, 0.5, 0)
            Knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Knob.ZIndex = 2
            Knob.Parent = Track
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            -- invisible click target over the whole track
            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, 0, 0, 18)
            Bar.Position = UDim2.new(0, 0, 0.5, -9)
            Bar.BackgroundTransparency = 1
            Bar.Text = ""
            Bar.ZIndex = 3
            Bar.Parent = Track

            Library.Flags[text] = Val

            local function Update(newVal)
                Val = newVal
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.16)
                Tween(Knob, {Position = UDim2.new(p, 0, 0.5, 0)}, 0.16)
                Num.Text = tostring(Val)
                Library.Flags[text] = Val
                ConfigObjects[text].Value = Val
                callback(Val)
            end

            local function Drag(input)
                local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Update(math.floor(min + (max - min) * p))
            end

            local sliding = false
            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true; PlaySound(Sounds.Slide); Drag(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then Drag(i) end
            end)

            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(val) Update(val) end}
        end

        function Elements:Textbox(text, placeholder, callback)
            local Frame = MakeTile(74)

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, 0, 0, 20)
            Lbl.Position = UDim2.new(0, 16, 0, 10)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Frame
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -32, 0, 28)
            Box.Position = UDim2.new(0, 16, 0, 36)
            Box.Text = ""
            Box.PlaceholderText = placeholder
            Box.Font = Enum.Font.GothamMedium
            Box.TextSize = 12
            Box.Parent = Frame
            Box.BackgroundTransparency = 0.08
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Box, "BackgroundColor3", "Main")
            AddToRegistry(Box, "TextColor3", "Text")

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Thickness = 1
            BoxStroke.Transparency = 0.75
            BoxStroke.Parent = Box
            AddToRegistry(BoxStroke, "Color", "Accent")

            Library.Flags[text] = ""

            Box.Focused:Connect(function()
                Tween(BoxStroke, {Transparency = 0.2}, 0.2)
            end)
            Box.FocusLost:Connect(function()
                Tween(BoxStroke, {Transparency = 0.75}, 0.2)
                Library.Flags[text] = Box.Text
                ConfigObjects[text].Value = Box.Text
                callback(Box.Text)
            end)

            ConfigObjects[text] = {Type = "Textbox", Value = "", Set = function(val)
                Box.Text = val
                Library.Flags[text] = val
                callback(val)
            end}
        end

        function Elements:Dropdown(text, options, callback)
            local Dropped = false
            local Selected = options[1] or ""

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 44)
            Btn.Text = ""
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            Btn.BackgroundTransparency = 0.04
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local St = Instance.new("UIStroke")
            St.Thickness = 1
            St.Transparency = 0.82
            St.Parent = Btn
            AddToRegistry(St, "Color", "Stroke")

            local AccBar = Instance.new("Frame")
            AccBar.Size = UDim2.new(0, 3, 0.55, 0)
            AccBar.Position = UDim2.new(0, 0, 0.225, 0)
            AccBar.BorderSizePixel = 0
            AccBar.Parent = Btn
            Instance.new("UICorner", AccBar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(AccBar, "BackgroundColor3", "Accent")

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, -32, 1, 0)
            Lbl.Position = UDim2.new(0, 16, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Btn
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Image = "rbxassetid://6031091004"
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -28, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Parent = Btn
            Icon.ImageColor3 = Color3.fromRGB(210, 30, 45)

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Visible = false
            Container.ClipsDescendants = true
            Container.Parent = Page
            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
            Container.BackgroundTransparency = 0.04
            AddToRegistry(Container, "BackgroundColor3", "Top")

            local CSt = Instance.new("UIStroke")
            CSt.Thickness = 1
            CSt.Transparency = 0.55
            CSt.Parent = Container
            AddToRegistry(CSt, "Color", "Accent")

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container

            Library.Flags[text] = Selected

            local function Select(opt)
                Dropped = false
                Selected = opt
                Lbl.Text = text .. "   —   " .. opt
                Library.Flags[text] = opt
                ConfigObjects[text].Value = opt
                callback(opt)
                Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                Tween(Icon, {Rotation = 0}, 0.28)
                task.wait(0.3)
                Container.Visible = false
            end

            local function RefreshOptions(newOpts)
                for _, v in pairs(Container:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 34)
                    O.Text = "   " .. opt
                    O.TextXAlignment = Enum.TextXAlignment.Left
                    O.TextColor3 = Color3.fromRGB(145, 145, 152)
                    O.Font = Enum.Font.GothamMedium
                    O.TextSize = 12
                    O.BackgroundTransparency = 1
                    O.Parent = Container
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                    O.MouseEnter:Connect(function() Tween(O, {TextColor3 = CurrentTheme.Accent}, 0.15) end)
                    O.MouseLeave:Connect(function() Tween(O, {TextColor3 = Color3.fromRGB(145, 145, 152)}, 0.15) end)
                end
            end
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                PlaySound(Sounds.Click)
                if Dropped then
                    Container.Visible = true
                    Tween(Container, {Size = UDim2.new(1, 0, 0, #Container:GetChildren() * 34)}, 0.32)
                    Tween(Icon, {Rotation = 180}, 0.32)
                else
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    Tween(Icon, {Rotation = 0}, 0.28)
                    task.wait(0.3)
                    Container.Visible = false
                end
            end)

            ConfigObjects[text] = {Type = "Dropdown", Value = Selected, Set = function(val) Select(val) end, Refresh = RefreshOptions}
            return {Refresh = RefreshOptions}
        end

        return Elements
    end

    -- config tab
    local ConfigTab = Window:Tab("Config")
    ConfigTab:Section("manage configs")

    local ConfigName = ""
    ConfigTab:Textbox("Config Name", "enter a name here", function(val) ConfigName = val end)

    local ConfigList = {}
    local Dropdown = ConfigTab:Dropdown("Select Config", {"None"}, function(val) Window.CurrentConfig = val end)

    local function RefreshConfigs()
        if not isfolder(Window.RootFolder) then makefolder(Window.RootFolder) end
        if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end
        ConfigList = {"None"}
        for _, file in pairs(listfiles(Window.ConfigFolder)) do
            local name = file:gsub(Window.ConfigFolder .. "\\", ""):gsub(Window.ConfigFolder .. "/", ""):gsub(".json", "")
            if name ~= "" then table.insert(ConfigList, name) end
        end
        Dropdown.Refresh(ConfigList)
    end

    ConfigTab:Button("Refresh List", function() RefreshConfigs() end)

    ConfigTab:Button("Save Config", function()
        if ConfigName == "" then Window:Notification("enter a name first"); return end
        Library:SaveConfig(ConfigName, Window.ConfigFolder)
        Window:Notification("saved " .. ConfigName)
        RefreshConfigs()
    end)

    ConfigTab:Button("Load Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then
            Window:Notification("select a config first"); return
        end
        local path = Window.ConfigFolder .. "/" .. Window.CurrentConfig .. ".json"
        local ok = Library:LoadConfig(path)
        if ok then
            Window:Notification("loaded " .. Window.CurrentConfig)
        else
            Window:Notification("config file not found")
        end
    end)

    ConfigTab:Button("Delete Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then
            Window:Notification("select a config first"); return
        end
        local path = Window.ConfigFolder .. "/" .. Window.CurrentConfig .. ".json"
        if isfile(path) then
            delfile(path)
            Window:Notification("deleted " .. Window.CurrentConfig)
            Window.CurrentConfig = ""
            RefreshConfigs()
        else
            Window:Notification("config file not found")
        end
    end)

    -- settings tab, always pinned at the bottom of the tab list
    local Settings = Window:Tab("Settings")
    Settings:Section("appearance")
    Settings:Toggle("Rainbow Edge", false, function(v) Library:ToggleRainbow(v) end)
    Settings:Dropdown("Rainbow Type", {"Linear Gradient (Solid Rainbow)", "Animated/Cycling Rainbow", "Smooth Fading Gradient", "Step/Band Rainbow", "Rainbow Pulse", "Radial Rainbow", "Neon/Glowing Rainbow", "Pastel Rainbow", "Vertical/Horizontal Fade"}, function(val) Library:SetRainbowType(val) end)
    Settings:Dropdown("Theme", {"Dark", "White", "Purple", "Blue", "Red", "Yellow", "Green"}, function(v) Library:SetTheme(v) end)
    Settings:Keybind("Menu Keybind", Keybind or Enum.KeyCode.M, function(v) Window:SetKeybind(v) end)
    Settings:Toggle("UI SFX", true, function(v) SFXEnabled = v end)
    Settings:Button("Destroy UI", function() Window:Destroy() end)

    RefreshConfigs()
    return Window
end

return Library
