--[[ 
███╗   ███╗ ██████╗ ██████╗ ███████╗███╗   ██╗
████╗ ████║██╔═████╗██╔══██╗╚══███╔╝████╗  ██║
██╔████╔██║██║██╔██║██║  ██║  ███╔╝ ██╔██╗ ██║
██║╚██╔╝██║████╔╝██║██║  ██║ ███╔╝  ██║╚██╗██║
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║ ╚████║
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝
               M0DZN LIBRARY V1.0
]]

print([[
script loaded
 ███╗   ███╗  ██████╗  ██████╗  ███████╗ ███╗   ██╗
 ████╗ ████║ ██╔═████╗ ██╔══██╗ ╚══███╔╝ ████╗  ██║
 ██╔████╔██║ ██║██╔██║ ██║  ██║   ███╔╝  ██╔██╗ ██║
 ██║╚██╔╝██║ ████╔╝██║ ██║  ██║  ███╔╝   ██║╚██╗██║
 ██║ ╚═╝ ██║ ╚██████╔╝ ██████╔╝ ███████╗ ██║ ╚████║
 ╚═╝     ╚═╝  ╚═════╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═══╝
               M0DZN LIBRARY V1.0
]])

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- ============================================================
-- ORION-STYLE FLAGS SYSTEM (CONFIG FIX)
-- ============================================================
Library.Flags = {}  -- All interactive element values live here

-- ============================================================
-- REST OF ORIGINAL GLOBALS (UNCHANGED)
-- ============================================================
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {}  -- kept for Set() references internally

-- SFX (UNCHANGED)
local Sounds = {
    Hover = "rbxassetid://4510086912",
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
    ToggleOff = "rbxassetid://4510087425",
    Slide = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Back = "rbxassetid://4510087236",
    Error = "rbxassetid://4510087545",
    Tab = "rbxassetid://4510087056" 
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

-- ============================================================
-- THEMES — Dark Futuristic / Obsidian Black + Crimson Red
-- ============================================================
local Themes = {
    -- DEFAULT is now Dark Futuristic
    Dark   = {Main = Color3.fromRGB(8, 8, 10),    Top = Color3.fromRGB(16, 16, 20),   Text = Color3.fromRGB(220, 220, 230), Accent = Color3.fromRGB(210, 30, 45),   Stroke = Color3.fromRGB(40, 15, 18)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20),   Accent = Color3.fromRGB(0, 100, 210),   Stroke = Color3.fromRGB(220, 220, 225)},
    Purple = {Main = Color3.fromRGB(18, 15, 22),   Top = Color3.fromRGB(30, 25, 35),   Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255),  Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28),   Top = Color3.fromRGB(25, 32, 45),   Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255),  Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(8, 8, 10),     Top = Color3.fromRGB(16, 16, 20),   Text = Color3.fromRGB(220, 220, 230), Accent = Color3.fromRGB(210, 30, 45),   Stroke = Color3.fromRGB(40, 15, 18)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12),   Top = Color3.fromRGB(35, 35, 20),   Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80),  Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15),   Top = Color3.fromRGB(20, 35, 25),   Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130),  Stroke = Color3.fromRGB(40, 60, 50)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeIndex)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex})
    obj[prop] = CurrentTheme[themeIndex]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, reg in pairs(Registry) do
            if reg.Object then
                Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
            end
        end
    end
end

function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end

-- ============================================================
-- ORION-STYLE CONFIG SYSTEM FUNCTIONS
-- ============================================================
local ActiveWindow = nil  -- set when window is created

function Library:SaveConfig(configName, configFolder)
    if not isfolder(configFolder) then makefolder(configFolder) end
    local SaveData = {}
    for flag, val in pairs(self.Flags) do
        SaveData[flag] = val
    end
    writefile(configFolder .. "/" .. configName .. ".json", HttpService:JSONEncode(SaveData))
end

function Library:LoadConfig(path)
    if not isfile(path) then return false end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end
    for flag, val in pairs(data) do
        self.Flags[flag] = val
        -- Update UI visuals via ConfigObjects Set()
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            ConfigObjects[flag].Set(val)
        end
    end
    return true
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0dzn UI"
    local Keybind = Config.Keybind 
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    ActiveWindow = Window

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V2.0"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    -- DARK FUTURISTIC: thinner, sharper corners, heavier stroke
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0.02
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)  -- sharper, futuristic
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5  -- slightly bolder stroke for futuristic feel
    Stroke.Transparency = 0.2 
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Accent")  -- crimson red stroke instead of grey

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    -- accent top bar line (futuristic HUD detail)
    local TopAccentLine = Instance.new("Frame")
    TopAccentLine.Size = UDim2.new(1, 0, 0, 2)
    TopAccentLine.Position = UDim2.new(0, 0, 0, 0)
    TopAccentLine.BorderSizePixel = 0
    TopAccentLine.ZIndex = 5
    TopAccentLine.Parent = MainFrame
    AddToRegistry(TopAccentLine, "BackgroundColor3", "Accent")

    -- rainbow loop (UNCHANGED logic)
    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick()
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Gradient.Enabled = true; Gradient.Rotation = 0
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.8, 1) 
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 1.5; Gradient.Rotation = rot 
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Gradient.Enabled = false; local step = math.floor((t % 2) * 4) / 4; Stroke.Color = Color3.fromHSV(step, 0.8, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Gradient.Enabled = false; local pulse = (math.sin(t * 2) + 1) / 2; Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.6, 1) 
                elseif RainbowType == "Pastel Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.3, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Gradient.Enabled = true; Gradient.Rotation = 90; local c = Color3.fromHSV(t % 5/5, 0.8, 1); local c2 = Color3.fromHSV((t+1) % 5/5, 0.8, 1); Gradient.Color = ColorSequence.new(c, c2); Stroke.Color = Color3.new(1,1,1)
                end
            else
                Gradient.Enabled = false
                Stroke.Color = CurrentTheme.Accent  -- crimson by default
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 50) 
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    -- DARK FUTURISTIC title styling: monospace-ish, uppercase feel via GothamBold
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "⬡  "..string.upper(Title)  -- hex icon + uppercase = futuristic
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 18, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold 
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Accent")  -- red title

    -- version tag (futuristic HUD label)
    local VerLabel = Instance.new("TextLabel")
    VerLabel.Text = "v2.0  //  SYSTEM ONLINE"
    VerLabel.Size = UDim2.new(1, -20, 0, 14)
    VerLabel.Position = UDim2.new(0, 18, 1, -16)
    VerLabel.BackgroundTransparency = 1
    VerLabel.Font = Enum.Font.Gotham
    VerLabel.TextSize = 10
    VerLabel.TextXAlignment = Enum.TextXAlignment.Left
    VerLabel.TextTransparency = 0.5
    VerLabel.Parent = Topbar
    AddToRegistry(VerLabel, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -65)
    Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 0.85, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -40)
    ProfileFrame.BackgroundTransparency = 0.05
    ProfileFrame.Parent = Content
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)  -- sharp futuristic
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")
    
    -- red left accent bar on profile tile
    local ProfileAccent = Instance.new("Frame")
    ProfileAccent.Size = UDim2.new(0, 2, 1, 0)
    ProfileAccent.Position = UDim2.new(0, 0, 0, 0)
    ProfileAccent.BorderSizePixel = 0
    ProfileAccent.Parent = ProfileFrame
    Instance.new("UICorner", ProfileAccent).CornerRadius = UDim.new(0, 6)
    AddToRegistry(ProfileAccent, "BackgroundColor3", "Accent")
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 26, 0, 26)
    Avatar.Position = UDim2.new(0, 10, 0.5, -13)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
    
    local DispName = Instance.new("TextLabel"); DispName.Text = LocalPlayer.DisplayName; DispName.Size = UDim2.new(1,-45,0,15); DispName.Position = UDim2.new(0,42,0,5); DispName.BackgroundTransparency = 1; DispName.Font = Enum.Font.GothamMedium; DispName.TextSize = 11; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.Parent = ProfileFrame; AddToRegistry(DispName, "TextColor3", "Text")
    local UsrName = Instance.new("TextLabel"); UsrName.Text = "@"..LocalPlayer.Name; UsrName.Size = UDim2.new(1,-45,0,15); UsrName.Position = UDim2.new(0,42,0,19); UsrName.BackgroundTransparency = 1; UsrName.Font = Enum.Font.Gotham; UsrName.TextSize = 10; UsrName.TextTransparency = 0.5; UsrName.TextXAlignment = Enum.TextXAlignment.Left; UsrName.Parent = ProfileFrame; AddToRegistry(UsrName, "TextColor3", "Text")

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 1, 1, 0)
    Line.Position = UDim2.new(0, 150, 0, 0)
    Line.BackgroundTransparency = 0.7
    Line.Parent = Content
    AddToRegistry(Line, "BackgroundColor3", "Accent")  -- crimson divider line

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -165, 1, 0)
    PageContainer.Position = UDim2.new(0, 160, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    Tween(MainFrame, {Size = UDim2.new(0, 640, 0, 420)}, 0.7)

    -- DRAG (UNCHANGED)
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.2) 
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
            if MainFrame.Visible then MainFrame.Size = UDim2.new(0,0,0,0); Tween(MainFrame, {Size = UDim2.new(0, 640, 0, 420)}, 0.5) end
        end
    end)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame"); Notif.ZIndex = 100; Notif.Size = UDim2.new(0, 260, 0, 45); Notif.Position = UDim2.new(1, 20, 1, -60); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 6); Notif.BackgroundTransparency = 0.05

            -- red left accent on notification
            local NAccent = Instance.new("Frame"); NAccent.Size = UDim2.new(0, 3, 1, 0); NAccent.BackgroundTransparency = 0; NAccent.ZIndex = 101; NAccent.Parent = Notif; Instance.new("UICorner", NAccent).CornerRadius = UDim.new(0,6); AddToRegistry(NAccent, "BackgroundColor3", "Accent")
            local NStroke = Instance.new("UIStroke"); NStroke.Thickness = 1; NStroke.Parent = Notif; AddToRegistry(NStroke, "Color", "Accent"); NStroke.Transparency = 0.4
            local NText = Instance.new("TextLabel"); NText.ZIndex = 101; NText.Text = text; NText.Size = UDim2.new(1,-10,1,0); NText.Position = UDim2.new(0,10,0,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamMedium; NText.TextSize = 12; AddToRegistry(NText, "TextColor3", "Text")
            Tween(Notif, {Position = UDim2.new(1, -280, 1, -60)}, 0.6); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -60)}, 0.6); task.wait(0.6); Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end

    local firstTab = true

    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundTransparency = 1
        -- FUTURISTIC: prefix with a bracket indicator
        TabBtn.Text = "  "..name
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = Color3.fromRGB(100, 100, 105)
        TabBtn.TextSize = 12
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

        -- left accent indicator bar (hidden by default, shows on active)
        local TabAccentBar = Instance.new("Frame")
        TabAccentBar.Size = UDim2.new(0, 2, 0.7, 0)
        TabAccentBar.Position = UDim2.new(0, 0, 0.15, 0)
        TabAccentBar.BackgroundTransparency = 1
        TabAccentBar.BorderSizePixel = 0
        TabAccentBar.Parent = TabBtn
        Instance.new("UICorner", TabAccentBar).CornerRadius = UDim.new(1, 0)
        AddToRegistry(TabAccentBar, "BackgroundColor3", "Accent")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2 
        Page.ScrollBarImageColor3 = Color3.fromRGB(210, 30, 45)  -- crimson scrollbar
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 15) end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab) 
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100,100,105)})
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then Tween(bar, {BackgroundTransparency = 1}) end
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.08, TextColor3 = CurrentTheme.Accent})
            Tween(TabBtn, {BackgroundColor3 = CurrentTheme.Top})
            Tween(TabAccentBar, {BackgroundTransparency = 0})
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.TextColor3 = CurrentTheme.Accent
            TabBtn.BackgroundTransparency = 0.08
            TabBtn.BackgroundColor3 = CurrentTheme.Top
            TabAccentBar.BackgroundTransparency = 0
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}

        function Elements:Section(text)
            local S = Instance.new("TextLabel")
            S.Text = "// "..string.upper(text)  -- futuristic section header style
            S.Size = UDim2.new(1, 0, 0, 24)
            S.BackgroundTransparency = 1
            S.Font = Enum.Font.GothamBold
            S.TextSize = 11
            S.TextXAlignment = Enum.TextXAlignment.Left
            S.Parent = Page
            AddToRegistry(S, "TextColor3", "Accent")  -- red section headers
        end

        -- helper: create a futuristic tile (shared by all elements)
        local function MakeTile(h)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, h)
            F.Parent = Page
            F.BackgroundTransparency = 0.04
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 5)  -- sharp
            AddToRegistry(F, "BackgroundColor3", "Top")
            -- left accent bar on each tile
            local Accent = Instance.new("Frame")
            Accent.Size = UDim2.new(0, 2, 0.6, 0)
            Accent.Position = UDim2.new(0, 0, 0.2, 0)
            Accent.BorderSizePixel = 0
            Accent.Parent = F
            Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Accent, "BackgroundColor3", "Accent")
            -- subtle stroke
            local St = Instance.new("UIStroke")
            St.Thickness = 1
            St.Transparency = 0.7
            St.Parent = F
            AddToRegistry(St, "Color", "Stroke")
            return F
        end

        -- =========================================================
        -- VALUE (UNCHANGED logic, new tile style + flag tracking)
        -- =========================================================
        function Elements:Value(text, default, callback)
            local ValFrame = MakeTile(42)
            
            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = text
            NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
            NameLbl.Position = UDim2.new(0, 15, 0, 0)
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Font = Enum.Font.GothamMedium
            NameLbl.TextSize = 13
            NameLbl.BackgroundTransparency = 1
            NameLbl.Parent = ValFrame
            AddToRegistry(NameLbl, "TextColor3", "Text")
            
            local ValBox = Instance.new("TextBox")
            ValBox.Text = tostring(default)
            ValBox.Size = UDim2.new(0.3, 0, 0, 28)
            ValBox.Position = UDim2.new(0.7, -15, 0.5, -14)
            ValBox.Font = Enum.Font.GothamMedium
            ValBox.TextSize = 12
            ValBox.TextXAlignment = Enum.TextXAlignment.Center
            ValBox.Parent = ValFrame
            ValBox.BackgroundTransparency = 0.1
            Instance.new("UICorner", ValBox).CornerRadius = UDim.new(0, 4)
            AddToRegistry(ValBox, "BackgroundColor3", "Main")
            AddToRegistry(ValBox, "TextColor3", "Accent")

            -- ORION FLAG
            Library.Flags[text] = default

            ValBox.FocusLost:Connect(function()
                PlaySound(Sounds.Click)
                Library.Flags[text] = ValBox.Text  -- update flag
                ConfigObjects[text] = {Type = "Value", Value = ValBox.Text}
                if callback then callback(ValBox.Text) end
                Window:Notification(text..": "..ValBox.Text)
            end)

            ConfigObjects[text] = {Type = "Value", Value = default, Set = function(val) ValBox.Text = tostring(val); Library.Flags[text] = val end}
        end

        -- =========================================================
        -- KEYBIND (UNCHANGED logic + flag tracking)
        -- =========================================================
        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Btn = MakeTile(42)
            Btn.BackgroundTransparency = 0.04  -- override since MakeTile returns Frame not TextButton
            -- We need a TextButton overlay for click
            local ClickBtn = Instance.new("TextButton"); ClickBtn.Size = UDim2.new(1,0,1,0); ClickBtn.BackgroundTransparency = 1; ClickBtn.Text = ""; ClickBtn.Parent = Btn
            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.6,0,1,0); Title.Position = UDim2.new(0,15,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamMedium; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local KeyLabel = Instance.new("TextLabel"); KeyLabel.Text = Key.Name; KeyLabel.Size = UDim2.new(0,80,0,26); KeyLabel.Position = UDim2.new(1,-95,0.5,-13); KeyLabel.Font = Enum.Font.GothamMedium; KeyLabel.TextSize = 11; KeyLabel.Parent = Btn; KeyLabel.BackgroundTransparency = 0.1; Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0,4); AddToRegistry(KeyLabel, "BackgroundColor3", "Main"); AddToRegistry(KeyLabel, "TextColor3", "Accent")

            -- ORION FLAG
            Library.Flags[text] = Key.Name

            ClickBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click); KeyLabel.Text = "[ .. ]"
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then 
                    Key = input.KeyCode
                    KeyLabel.Text = Key.Name
                    Library.Flags[text] = Key.Name  -- update flag
                    ConfigObjects[text].Value = Key.Name
                    callback(Key)
                    Window:Notification("Keybind: "..Key.Name) 
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

        -- =========================================================
        -- BUTTON (UNCHANGED logic, new tile)
        -- =========================================================
        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,42)
            Btn.Text = "  ›  "..text  -- futuristic arrow prefix
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,5)
            Btn.BackgroundTransparency = 0.04
            AddToRegistry(Btn, "BackgroundColor3", "Top")
            AddToRegistry(Btn, "TextColor3", "Text")
            -- accent stroke
            local St = Instance.new("UIStroke"); St.Thickness = 1; St.Transparency = 0.7; St.Parent = Btn; AddToRegistry(St, "Color", "Stroke")
            -- left bar
            local Bar = Instance.new("Frame"); Bar.Size = UDim2.new(0,2,0.6,0); Bar.Position = UDim2.new(0,0,0.2,0); Bar.BorderSizePixel = 0; Bar.Parent = Btn; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0); AddToRegistry(Bar, "BackgroundColor3", "Accent")

            Btn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                Tween(Btn, {Size = UDim2.new(0.97,0,0,38)}, 0.12)
                task.wait(0.12)
                Tween(Btn, {Size = UDim2.new(1,0,0,42)}, 0.15)
                callback()
            end)
        end

        -- =========================================================
        -- TOGGLE — Orion flag auto-save on change
        -- =========================================================
        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Btn = MakeTile(42)
            local ClickBtn = Instance.new("TextButton"); ClickBtn.Size = UDim2.new(1,0,1,0); ClickBtn.BackgroundTransparency = 1; ClickBtn.Text = ""; ClickBtn.Parent = Btn

            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.7,0,1,0); Title.Position = UDim2.new(0,15,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamMedium; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local Switch = Instance.new("Frame"); Switch.Size = UDim2.new(0,40,0,20); Switch.Position = UDim2.new(1,-55,0.5,-10); Switch.Parent = Btn; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0); Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(30,30,35)
            local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0,16,0,16); Dot.Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); Dot.BackgroundColor3 = Color3.new(1,1,1); Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            -- ORION FLAG
            Library.Flags[text] = Enabled

            local function Update()
                if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(30,30,35)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
                Library.Flags[text] = Enabled  -- update flag (auto-tracks, Orion style)
                ConfigObjects[text].Value = Enabled
                callback(Enabled)
                Window:Notification(text..": "..tostring(Enabled)) 
            end

            ClickBtn.MouseButton1Click:Connect(function() Enabled = not Enabled; Update() end)
            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(val)
                Enabled = val
                Library.Flags[text] = val
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(30,30,35)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
                callback(Enabled)
            end}
        end

        -- =========================================================
        -- SLIDER — Orion flag auto-save on change
        -- =========================================================
        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Frame = MakeTile(60)
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-30,0,20); Lbl.Position = UDim2.new(0,15,0,10); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            local Num = Instance.new("TextLabel"); Num.Text = tostring(Val); Num.Size = UDim2.new(0,40,0,20); Num.Position = UDim2.new(1,-55,0,10); Num.BackgroundTransparency = 1; Num.TextColor3 = Color3.fromRGB(210,30,45); Num.Font = Enum.Font.GothamBold; Num.TextSize = 12; Num.TextXAlignment = Enum.TextXAlignment.Right; Num.Parent = Frame
            local Bar = Instance.new("TextButton"); Bar.Text = ""; Bar.Size = UDim2.new(1,-30,0,4); Bar.Position = UDim2.new(0,15,0,43); Bar.BackgroundColor3 = Color3.fromRGB(30,30,35); Bar.AutoButtonColor = false; Bar.Parent = Frame; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
            local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Val-min)/(max-min),0,1,0); Fill.Parent = Bar; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0); AddToRegistry(Fill, "BackgroundColor3", "Accent")

            -- ORION FLAG
            Library.Flags[text] = Val

            local function Update(val_new)
                Val = val_new
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p,0,1,0)}, 0.2)
                Num.Text = tostring(Val)
                Library.Flags[text] = Val  -- update flag
                ConfigObjects[text].Value = Val
                callback(Val)
            end

            local function Drag(input)
                local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + ((max - min) * p))
                Update(newVal)
            end

            local sliding
            Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; PlaySound(Sounds.Slide); Drag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then Drag(i) end end)
            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(val) Update(val) end}
        end

        -- =========================================================
        -- TEXTBOX (UNCHANGED logic + flag)
        -- =========================================================
        function Elements:Textbox(text, placeholder, callback)
            local Frame = MakeTile(70)
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,0,0,20); Lbl.Position = UDim2.new(0,15,0,10); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            local Box = Instance.new("TextBox"); Box.Size = UDim2.new(1,-30,0,26); Box.Position = UDim2.new(0,15,0,34); Box.Text = ""; Box.PlaceholderText = placeholder; Box.Font = Enum.Font.GothamMedium; Box.TextSize = 12; Box.Parent = Frame; Box.BackgroundTransparency = 0.1; Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4); AddToRegistry(Box, "BackgroundColor3", "Main"); AddToRegistry(Box, "TextColor3", "Text")
            
            Library.Flags[text] = ""

            Box.FocusLost:Connect(function()
                Library.Flags[text] = Box.Text
                ConfigObjects[text] = ConfigObjects[text] or {}
                ConfigObjects[text].Value = Box.Text
                callback(Box.Text) 
            end)
            ConfigObjects[text] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; Library.Flags[text] = val; callback(val) end}
        end

        -- =========================================================
        -- DROPDOWN (UNCHANGED logic + flag)
        -- =========================================================
        function Elements:Dropdown(text, options, callback)
            local Dropped = false
            local Selected = options[1] or ""
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,42); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,5); Btn.BackgroundTransparency = 0.04; AddToRegistry(Btn, "BackgroundColor3", "Top")
            local St = Instance.new("UIStroke"); St.Thickness = 1; St.Transparency = 0.7; St.Parent = Btn; AddToRegistry(St, "Color", "Stroke")
            local Bar2 = Instance.new("Frame"); Bar2.Size = UDim2.new(0,2,0.6,0); Bar2.Position = UDim2.new(0,0,0.2,0); Bar2.BorderSizePixel = 0; Bar2.Parent = Btn; Instance.new("UICorner", Bar2).CornerRadius = UDim.new(1,0); AddToRegistry(Bar2, "BackgroundColor3", "Accent")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-30,1,0); Lbl.Position = UDim2.new(0,15,0,0); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Btn; AddToRegistry(Lbl, "TextColor3", "Text")
            local Icon = Instance.new("ImageLabel"); Icon.Image = "rbxassetid://6031091004"; Icon.Size = UDim2.new(0,16,0,16); Icon.Position = UDim2.new(1,-30,0.5,-8); Icon.BackgroundTransparency = 1; Icon.Parent = Btn; Icon.ImageColor3 = Color3.fromRGB(210,30,45)  -- crimson arrow
            
            local Container = Instance.new("Frame"); Container.Size = UDim2.new(1,0,0,0); Container.Visible = false; Container.ClipsDescendants = true; Container.Parent = Page; Instance.new("UICorner", Container).CornerRadius = UDim.new(0,5); Container.BackgroundTransparency = 0.04; AddToRegistry(Container, "BackgroundColor3", "Top")
            local CSt = Instance.new("UIStroke"); CSt.Thickness = 1; CSt.Transparency = 0.7; CSt.Parent = Container; AddToRegistry(CSt, "Color", "Accent")
            local List = Instance.new("UIListLayout"); List.SortOrder = Enum.SortOrder.LayoutOrder; List.Parent = Container

            Library.Flags[text] = Selected

            local function Select(opt)
                Dropped = false
                Selected = opt
                Lbl.Text = text..":  "..opt
                Library.Flags[text] = opt  -- update flag
                ConfigObjects[text].Value = opt
                callback(opt)
                Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.3); Tween(Icon, {Rotation = 0}, 0.3); task.wait(0.3); Container.Visible = false
            end
            
            local function RefreshOptions(newOpts)
                for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton"); O.Size = UDim2.new(1,0,0,34); O.Text = "  "..opt; O.TextXAlignment = Enum.TextXAlignment.Left; O.TextColor3 = Color3.fromRGB(160,160,165); O.Font = Enum.Font.GothamMedium; O.TextSize = 12; O.BackgroundTransparency = 1; O.Parent = Container
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                    -- hover effect
                    O.MouseEnter:Connect(function() Tween(O, {TextColor3 = CurrentTheme.Accent}, 0.2) end)
                    O.MouseLeave:Connect(function() Tween(O, {TextColor3 = Color3.fromRGB(160,160,165)}, 0.2) end)
                end
            end
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                PlaySound(Sounds.Click)
                if Dropped then Container.Visible = true; Tween(Container, {Size = UDim2.new(1,0,0, #Container:GetChildren()*34)}, 0.4); Tween(Icon, {Rotation = 180}, 0.4)
                else Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.3); Tween(Icon, {Rotation = 0}, 0.3); task.wait(0.3); Container.Visible = false end
            end)

            ConfigObjects[text] = {Type = "Dropdown", Value = Selected, Set = function(val) Select(val) end, Refresh = RefreshOptions}
            return {Refresh = RefreshOptions} 
        end

        return Elements
    end

    -- ============================================================
    -- CONFIG TAB — Orion-style backend
    -- ============================================================
    local ConfigTab = Window:Tab("Config")
    ConfigTab:Section("Manage Configs")

    local ConfigName = ""
    ConfigTab:Textbox("Config Name", "Enter name...", function(val) ConfigName = val end)
    
    local ConfigList = {}
    local Dropdown = ConfigTab:Dropdown("Select Config", {"None"}, function(val) Window.CurrentConfig = val end)

    local function RefreshConfigs()
        if not isfolder(Window.RootFolder) then makefolder(Window.RootFolder) end
        if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end
        ConfigList = {"None"}
        for _, file in pairs(listfiles(Window.ConfigFolder)) do
            local name = file:gsub(Window.ConfigFolder.."\\", ""):gsub(Window.ConfigFolder.."/", ""):gsub(".json", "")
            if name ~= "" then table.insert(ConfigList, name) end
        end
        Dropdown.Refresh(ConfigList)
    end

    ConfigTab:Button("Refresh List", function() RefreshConfigs() end)

    ConfigTab:Button("Save Config", function()
        if ConfigName == "" then Window:Notification("[ ERR ] Enter a name!"); return end
        Library:SaveConfig(ConfigName, Window.ConfigFolder)
        Window:Notification("[ OK ] Saved: "..ConfigName)
        RefreshConfigs()
    end)

    ConfigTab:Button("Load Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then Window:Notification("[ ERR ] Select a config!"); return end
        local path = Window.ConfigFolder.."/"..Window.CurrentConfig..".json"
        local ok = Library:LoadConfig(path)
        if ok then
            Window:Notification("[ OK ] Loaded: "..Window.CurrentConfig)
        else
            Window:Notification("[ ERR ] Config not found!")
        end
    end)

    ConfigTab:Button("Delete Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then Window:Notification("[ ERR ] Select a config!"); return end
        local path = Window.ConfigFolder.."/"..Window.CurrentConfig..".json"
        if isfile(path) then
            delfile(path)
            Window:Notification("[ OK ] Deleted: "..Window.CurrentConfig)
            Window.CurrentConfig = ""
            RefreshConfigs()
        else
            Window:Notification("[ ERR ] Config not found!")
        end
    end)

    -- SETTINGS TAB (UNCHANGED logic)
    local Settings = Window:Tab("Settings")
    Settings:Section("Customization")
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
