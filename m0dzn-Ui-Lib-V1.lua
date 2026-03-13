--[[ 
 ███╗   ███╗   ██████╗   ██████╗   ███████╗  ███╗   ██╗
 ████╗ ████║  ██╔═████╗  ██╔══██╗  ╚══███╔╝  ████╗  ██║
 ██╔████╔██║  ██║██╔██║  ██║  ██║    ███╔╝   ██╔██╗ ██║
 ██║╚██╔╝██║  ████╔╝██║  ██║  ██║   ███╔╝    ██║╚██╗██║
 ██║ ╚═╝ ██║  ╚██████╔╝  ██████╔╝  ███████╗  ██║ ╚████║
 ╚═╝     ╚═╝   ╚═════╝   ╚═════╝   ╚══════╝  ╚═╝  ╚═══╝
               M0DZN LIBRARY V1.0
]]

print([[
script loaded
 ███╗   ███╗   ██████╗   ██████╗   ███████╗  ███╗   ██╗
 ████╗ ████║  ██╔═████╗  ██╔══██╗  ╚══███╔╝  ████╗  ██║
 ██╔████╔██║  ██║██╔██║  ██║  ██║    ███╔╝   ██╔██╗ ██║
 ██║╚██╔╝██║  ████╔╝██║  ██║  ██║   ███╔╝    ██║╚██╗██║
 ██║ ╚═╝ ██║  ╚██████╔╝  ██████╔╝  ███████╗  ██║ ╚████║
 ╚═╝     ╚═╝   ╚═════╝   ╚═════╝   ╚══════╝  ╚═╝  ╚═══╝
               M0DZN LIBRARY V1.0
]])

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Library = {}

Library.Flags = {}

local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow"
local RainbowSpeed = 1.0
local Registry = {}
local ConfigObjects = {}
local ThemeListeners = {}

local Themes = {
    Dark   = {Main = Color3.fromRGB(28, 28, 30),      Top = Color3.fromRGB(38, 38, 40),     Text = Color3.fromRGB(220, 220, 225), Accent = Color3.fromRGB(160, 160, 168), Stroke = Color3.fromRGB(55, 55, 60)},
    Light  = {Main = Color3.fromRGB(235, 235, 238),   Top = Color3.fromRGB(245, 245, 248),  Text = Color3.fromRGB(30, 30, 35),    Accent = Color3.fromRGB(110, 110, 120), Stroke = Color3.fromRGB(200, 200, 205)},
    Purple = {Main = Color3.fromRGB(18, 15, 22),      Top = Color3.fromRGB(30, 25, 35),     Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255),  Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28),      Top = Color3.fromRGB(25, 32, 45),     Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255),  Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(22, 10, 10),      Top = Color3.fromRGB(35, 18, 18),     Text = Color3.fromRGB(255, 235, 235), Accent = Color3.fromRGB(210, 50, 50),   Stroke = Color3.fromRGB(60, 30, 30)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12),      Top = Color3.fromRGB(35, 35, 20),     Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80),  Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15),      Top = Color3.fromRGB(20, 35, 25),     Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130),  Stroke = Color3.fromRGB(40, 60, 50)},
}

local CurrentTheme = Themes.Yellow

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
        for _, fn in pairs(ThemeListeners) do
            pcall(fn)
        end
    end
end

function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end
function Library:SetRainbowSpeed(val) RainbowSpeed = math.clamp(tonumber(val) or 1, 0.1, 10) end

function Library:SaveConfig(configName, configFolder)
    if not isfolder(configFolder) then makefolder(configFolder) end
    local data = {}
    for flag, val in pairs(self.Flags) do
        data[flag] = val
    end
    writefile(configFolder .. "/" .. configName .. ".json", HttpService:JSONEncode(data))
end

function Library:LoadConfig(path)
    if not isfile(path) then return false, "file_missing" end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false, "bad_data" end

    local totalFlags = 0
    local loadedFlags = 0
    for flag, _ in pairs(self.Flags) do
        totalFlags = totalFlags + 1
    end

    for flag, val in pairs(data) do
        self.Flags[flag] = val
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            local setOk = pcall(function()
                ConfigObjects[flag].Set(val)
            end)
            if setOk then
                loadedFlags = loadedFlags + 1
            end
        else
            loadedFlags = loadedFlags + 1
        end
    end

    if totalFlags > 0 and loadedFlags < math.floor(totalFlags * 0.5) then
        return false, "partial_load"
    end

    return true, "ok"
end

local ActiveNotifs = {}

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "m0dzn ui"
    local Keybind = Config.Keybind or Enum.KeyCode.M

    if Config.Theme then
        if type(Config.Theme) == "string" then
            if Themes[Config.Theme] then
                CurrentTheme = Themes[Config.Theme]
            end
        elseif type(Config.Theme) == "table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v) == "table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v) == "userdata" then return v
                else return Color3.new(0,0,0) end
            end
            local customTheme = {
                Main   = t.Main   and toC3(t.Main)   or CurrentTheme.Main,
                Top    = t.Top    and toC3(t.Top)    or CurrentTheme.Top,
                Text   = t.Text   and toC3(t.Text)   or CurrentTheme.Text,
                Accent = t.Accent and toC3(t.Accent) or CurrentTheme.Accent,
                Stroke = t.Stroke and toC3(t.Stroke) or CurrentTheme.Stroke,
            }
            local customName = t.Name or "Custom"
            Themes[customName] = customTheme
            CurrentTheme = customTheme
        end
    end

    Window.RootFolder = Title
    Window.ConfigFolder = Title .. "/Config"
    Window.CurrentConfig = ""

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    -- FIX #4: Enable IgnoreGuiInset so GUI scales correctly on mobile same as PC
    ScreenGui.IgnoreGuiInset = true
    local ok, _ = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        elseif gethui then
            ScreenGui.Parent = gethui()
        end
    end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    -- FIX #2: Rainbow stroke thickness - default thin (1.5), only go thick when rainbow ON
    -- The bug was Stroke.Thickness was hardcoded to 0.1 initially but the rainbow loop
    -- always forced it to 6 whenever RainbowEnabled=true, ignoring user setting.
    -- Fix: use a separate RainbowThickness variable the scripter can control,
    -- and when rainbow is OFF restore to exactly 1.5 (thin border).
    local RainbowThickness = 2  -- thickness used only when rainbow is ON (reasonable default)

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5  -- start thin (non-rainbow state)
    Stroke.Transparency = 0
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    -- rainbow border loop
    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                -- FIX #2: Only set thickness to RainbowThickness (2), not hardcoded 6
                if Stroke.Thickness ~= RainbowThickness then
                    Stroke.Thickness = RainbowThickness
                    Stroke.Transparency = 0
                    Stroke.Color = Color3.new(1,1,1)
                end
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
                    Stroke.Color = Color3.fromHSV(t * RainbowSpeed % 5 / 5, 0.8, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 1.5 * RainbowSpeed; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0))
                    })
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Gradient.Enabled = false
                    local step = math.floor((t * RainbowSpeed % 2) * 4) / 4
                    Stroke.Color = Color3.fromHSV(step, 0.8, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Gradient.Enabled = false
                    local pulse = (math.sin(t * RainbowSpeed * 2) + 1) / 2
                    Stroke.Color = Color3.fromHSV(t * RainbowSpeed % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Gradient.Enabled = true; rot = rot + 2 * RainbowSpeed; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,255))
                    })
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Gradient.Enabled = false
                    Stroke.Color = Color3.fromHSV(t * RainbowSpeed % 2 / 2, 0.6, 1)
                elseif RainbowType == "Pastel Rainbow" then
                    Gradient.Enabled = false
                    Stroke.Color = Color3.fromHSV(t * RainbowSpeed % 5 / 5, 0.3, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Gradient.Enabled = true; Gradient.Rotation = 90
                    local c  = Color3.fromHSV(t * RainbowSpeed % 5 / 5, 0.8, 1)
                    local c2 = Color3.fromHSV((t * RainbowSpeed + 1) % 5 / 5, 0.8, 1)
                    Gradient.Color = ColorSequence.new(c, c2)
                    Stroke.Color = Color3.new(1,1,1)
                end
            else
                Gradient.Enabled = false
                -- FIX #2: Restore to thin 1.5 border when rainbow is off
                if Stroke.Thickness ~= 1.5 then
                    Stroke.Thickness = 1.5
                    Stroke.Transparency = 0
                    Stroke.Color = CurrentTheme.Stroke
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)

    -- ── Topbar ──────────────────────────────────────────────────────────────
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 52)
    Topbar.BackgroundTransparency = 1
    Topbar.ZIndex = 4
    Topbar.Parent = MainFrame

    local TitleIcon = Instance.new("Frame")
    TitleIcon.Size = UDim2.new(0, 8, 0, 8)
    TitleIcon.Position = UDim2.new(0, 18, 0.5, -4)
    TitleIcon.BorderSizePixel = 0; TitleIcon.ZIndex = 5; TitleIcon.Parent = Topbar
    Instance.new("UICorner", TitleIcon).CornerRadius = UDim.new(0, 2)
    AddToRegistry(TitleIcon, "BackgroundColor3", "Accent")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(0.55, 0, 0, 28)
    TitleLabel.Position = UDim2.new(0, 34, 0.5, -14)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 5; TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    -- FIX #6: Download SVG icon assets to local file system so no Roblox image IDs needed
    local IconCache = {}
    local function WriteIconIfNeeded(name, svgData)
        local path = "m0dzn_icons/" .. name .. ".svg"
        pcall(function()
            if not isfolder("m0dzn_icons") then makefolder("m0dzn_icons") end
            if not isfile(path) then writefile(path, svgData) end
        end)
        return path
    end

    local SVGIcons = {
        -- FIX #5 & #6: minus bar for minimize (hide content keep topbar)
        collapse_open  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><rect x="2" y="7" width="12" height="2" rx="1" fill="white"/></svg>',
        -- square for restore content
        collapse_close = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><rect x="2" y="2" width="12" height="12" rx="2" fill="none" stroke="white" stroke-width="1.8"/></svg>',
        -- FIX #5 & #6: X icon for hide/show button
        close_x        = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><line x1="3" y1="3" x2="13" y2="13" stroke="white" stroke-width="2" stroke-linecap="round"/><line x1="13" y1="3" x2="3" y2="13" stroke="white" stroke-width="2" stroke-linecap="round"/></svg>',
    }
    for name, svg in pairs(SVGIcons) do
        IconCache[name] = WriteIconIfNeeded(name, svg)
    end

    local function MakeIconBtn(iconName, fallbackText, xFromRight)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 28, 0, 28)
        Btn.Position = UDim2.new(1, xFromRight, 0.5, -14)
        Btn.BackgroundTransparency = 0.85
        Btn.Text = ""
        Btn.ZIndex = 6; Btn.Parent = Topbar
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        AddToRegistry(Btn, "BackgroundColor3", "Top")
        Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.5}, 0.12) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0.85}, 0.12) end)

        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(0, 16, 0, 16)
        Img.Position = UDim2.new(0.5, -8, 0.5, -8)
        Img.BackgroundTransparency = 1
        Img.ZIndex = 7; Img.Parent = Btn

        local loaded = false
        pcall(function()
            local path = IconCache[iconName]
            if path and isfile(path) then
                Img.Image = "file:///" .. path
                loaded = true
            end
        end)
        if not loaded then
            Img.Image = ""
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1,0,1,0); Lbl.BackgroundTransparency = 1
            Lbl.Text = fallbackText; Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Center; Lbl.ZIndex = 7; Lbl.Parent = Btn
            AddToRegistry(Lbl, "TextColor3", "Text")
        end

        local function setIcon(name2, fallback2)
            local ok2 = false
            pcall(function()
                local p2 = IconCache[name2]
                if p2 and isfile(p2) then Img.Image = "file:///" .. p2; ok2 = true end
            end)
            if not ok2 then
                Img.Image = ""
                for _, ch in pairs(Btn:GetChildren()) do
                    if ch:IsA("TextLabel") then ch.Text = fallback2 end
                end
            end
        end
        return {btn = Btn, setIcon = setIcon}
    end

    -- FIX #5: Button 1 = Minimize/Maximize (hides content, keeps topbar visible) using - icon
    local CollapseBtn = MakeIconBtn("collapse_open", "–", -36)

    -- FIX #5: Button 2 = Hide/Show (hides entire GUI like keybind) using X icon
    -- Removed the old MinBtn (minimize/maximize with arrows) - replaced with Hide/Show
    local HideShowBtn = MakeIconBtn("close_x", "✕", -70)

    -- FIX #3: Removed FloatBtn (the T pill button) entirely.
    -- The hide/show now only uses the keybind message approach.
    -- We still need a way to reopen - we'll use a small draggable label that appears
    -- at bottom right showing the keybind hint, no T logo.
    local HintLabel = Instance.new("TextButton")
    HintLabel.Size = UDim2.new(0, 0, 0, 0) -- invisible, zero size, no T logo
    HintLabel.BackgroundTransparency = 1
    HintLabel.Text = ""
    HintLabel.Visible = false
    HintLabel.ZIndex = 200
    HintLabel.Parent = ScreenGui

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

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 138, 0, 44)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -44)
    ProfileFrame.BackgroundTransparency = 0.04
    ProfileFrame.Parent = Content
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 12)
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")

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
    AddToRegistry(PStroke, "Color", "Stroke")

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 28, 0, 28)
    Avatar.Position = UDim2.new(0, 11, 0.5, -14)
    Avatar.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    pcall(function()
        Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
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
    UsrName.TextTransparency = 0.4
    UsrName.TextXAlignment = Enum.TextXAlignment.Left
    UsrName.Parent = ProfileFrame
    AddToRegistry(UsrName, "TextColor3", "Text")

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 1, 1, 0)
    Divider.Position = UDim2.new(0, 148, 0, 0)
    Divider.BackgroundTransparency = 0.75
    Divider.Parent = Content
    AddToRegistry(Divider, "BackgroundColor3", "Stroke")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -162, 1, 0)
    PageContainer.Position = UDim2.new(0, 162, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    local openSize  = UDim2.new(0, 650, 0, 430)
    local fullH     = 430
    local collapseH = 52

    -- spawn open: bounce scale from 0 up to full size
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 0
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = openSize}):Play()

    -- ── Drag (mouse + touch) ────────────────────────────────────────────────
    -- FIX #4: Drag works on both PC (mouse) and mobile (touch)
    local dragging, dragInput, dragStart, startPos
    local function isDragStart(t) return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch end
    local function isDragMove(t)  return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch end
    Topbar.InputBegan:Connect(function(input)
        if isDragStart(input.UserInputType) then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position; dragInput = input
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if isDragMove(input.UserInputType) then dragInput = input end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.25)
        end
    end)

    -- ── state vars ─────────────────────────────────────────────────────────
    local isOpen = true
    local isCollapsed = false

    -- FIX #5 Button 1: Minimize/Maximize - hides content area but keeps topbar visible
    -- Uses - icon (collapse_open svg) and □ icon (collapse_close svg)
    local function SetCollapsed(c)
        isCollapsed = c
        CollapseBtn.setIcon(c and "collapse_close" or "collapse_open", c and "□" or "–")
        -- When collapsed: shrink to just the topbar height (52px)
        -- When expanded: restore to full openSize
        local targetSize
        if c then
            -- hide content, keep topbar - set height to just topbar (52)
            targetSize = UDim2.new(0, openSize.X.Offset, 0, 52)
            Content.Visible = false
        else
            targetSize = openSize
            Content.Visible = true
        end
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = targetSize}):Play()
    end
    CollapseBtn.btn.MouseButton1Click:Connect(function() SetCollapsed(not isCollapsed) end)

    -- FIX #5 Button 2: Hide/Show - hides the entire GUI (same as keybind)
    -- Uses X icon, shows notification with keybind hint on hide
    local isOpen = true

    local function ShowGUI()
        isOpen = true
        MainFrame.Visible = true
        MainFrame.Active = true
        TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = openSize, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    end

    local function HideGUI()
        isOpen = false
        MainFrame.Active = false
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.38, function()
            if not isOpen then
                MainFrame.Visible = false
                -- FIX #5: Show keybind hint notification instead of T pill button
                local keyName = Keybind and Keybind.Name or "M"
                Window:Notification("UI Hidden", 'Press "' .. keyName .. '" to reopen', "warning")
            end
        end)
    end

    -- FIX #5: Hide/Show button uses X icon and hides entire GUI
    HideShowBtn.btn.MouseButton1Click:Connect(function() HideGUI() end)
    -- Tint the X icon red
    pcall(function()
        for _, ch in pairs(HideShowBtn.btn:GetChildren()) do
            if ch:IsA("ImageLabel") then ch.ImageColor3 = Color3.fromRGB(215,50,50) end
            if ch:IsA("TextLabel") then ch.TextColor3 = Color3.fromRGB(215,50,50) end
        end
    end)

    -- Position buttons: Collapse(-36) | HideShow(-70)
    CollapseBtn.btn.Position = UDim2.new(1, -36, 0.5, -14)
    HideShowBtn.btn.Position = UDim2.new(1, -70, 0.5, -14)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            if isOpen then HideGUI() else ShowGUI() end
        end
    end)

    -- FIX #1: Notification system - fixed out of bounds
    -- Use absolute pixel positions clamped inside viewport so they never go off screen
    local NotifTypes = {success=true, warning=true, error=true, info=true}
    function Window:Notification(title, body, notifType)
        task.spawn(function()
            if body and NotifTypes[body] and notifType == nil then
                notifType = body
                body = nil
            end

            local typeColor = Color3.fromRGB(185, 185, 190)
            if notifType == "success" then typeColor = Color3.fromRGB(45, 210, 90)
            elseif notifType == "warning" then typeColor = Color3.fromRGB(230, 190, 25)
            elseif notifType == "error"   then typeColor = Color3.fromRGB(215, 50, 50)
            elseif notifType == "info"    then typeColor = Color3.fromRGB(0, 210, 220)
            end

            local nW   = 300
            local nH   = body and body ~= "" and 76 or 54
            local padX = 16; local padY = 10
            local barH = 3

            -- FIX #1: Get viewport size and clamp notifications fully inside screen
            local vp2 = workspace.CurrentCamera.ViewportSize
            -- Right-align: leave 14px margin from right edge
            local nLandX = vp2.X - nW - 14
            -- Start off-screen to the right
            local nStartX = vp2.X + 20

            local Notif = Instance.new("Frame")
            Notif.ZIndex = 100
            Notif.Size = UDim2.new(0, nW, 0, nH)
            -- FIX #1: Use absolute position (Scale=0) so it never overflows
            Notif.Position = UDim2.new(0, nStartX, 0, 0) -- Y set by RepositionAll
            Notif.BackgroundTransparency = 1
            Notif.Parent = ScreenGui
            Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 12)
            Notif.ClipsDescendants = true
            AddToRegistry(Notif, "BackgroundColor3", "Top")

            local NBar = Instance.new("Frame")
            NBar.Size = UDim2.new(0, 4, 1, -12)
            NBar.Position = UDim2.new(0, 6, 0, 6)
            NBar.BackgroundColor3 = typeColor; NBar.BorderSizePixel = 0; NBar.ZIndex = 102; NBar.Parent = Notif
            Instance.new("UICorner", NBar).CornerRadius = UDim.new(0, 3)

            local NStroke = Instance.new("UIStroke")
            NStroke.Thickness = 1; NStroke.Transparency = 0.55; NStroke.Color = typeColor; NStroke.Parent = Notif

            local NTitle = Instance.new("TextLabel")
            NTitle.ZIndex = 101; NTitle.Text = title or ""
            NTitle.Size = UDim2.new(1, -68, 0, 18)
            NTitle.Position = UDim2.new(0, padX+8, 0, padY)
            NTitle.BackgroundTransparency = 1; NTitle.Parent = Notif
            NTitle.Font = Enum.Font.GothamBold
            NTitle.TextSize = 13
            NTitle.TextXAlignment = Enum.TextXAlignment.Left
            AddToRegistry(NTitle, "TextColor3", "Text")

            local NTimer = Instance.new("TextLabel")
            NTimer.ZIndex = 101; NTimer.Text = "3.0s"
            NTimer.Size = UDim2.new(0, 46, 0, 18)
            NTimer.Position = UDim2.new(1, -52, 0, padY)
            NTimer.BackgroundTransparency = 1; NTimer.Parent = Notif
            NTimer.Font = Enum.Font.GothamBold
            NTimer.TextSize = 11
            NTimer.TextXAlignment = Enum.TextXAlignment.Right
            NTimer.TextColor3 = typeColor

            local NText = Instance.new("TextLabel")
            NText.ZIndex = 101; NText.Text = body or ""
            NText.Size = UDim2.new(1, -40, 0, 18)
            NText.Position = UDim2.new(0, padX+8, 0, padY + 22)
            NText.BackgroundTransparency = 1; NText.Parent = Notif
            NText.Font = Enum.Font.GothamMedium
            NText.TextSize = 11
            NText.TextXAlignment = Enum.TextXAlignment.Left
            NText.TextTransparency = body and body ~= "" and 0.3 or 1
            AddToRegistry(NText, "TextColor3", "Text")

            local NBadge = Instance.new("TextLabel")
            NBadge.ZIndex = 102
            NBadge.Text = notifType and (notifType:sub(1,1):upper()..notifType:sub(2)) or "Notif"
            NBadge.Size = UDim2.new(0, 52, 0, 16)
            NBadge.Position = UDim2.new(1, -60, 0, padY + 22)
            NBadge.BackgroundColor3 = typeColor; NBadge.BackgroundTransparency = 0.75
            NBadge.Parent = Notif
            NBadge.Font = Enum.Font.GothamBold
            NBadge.TextSize = 9
            NBadge.TextColor3 = typeColor
            Instance.new("UICorner", NBadge).CornerRadius = UDim.new(1, 0)

            local NProgress = Instance.new("Frame")
            NProgress.Size = UDim2.new(1, 0, 0, barH)
            NProgress.Position = UDim2.new(0, 0, 1, -barH)
            NProgress.BorderSizePixel = 0; NProgress.BackgroundColor3 = typeColor
            NProgress.ZIndex = 101; NProgress.Parent = Notif
            Instance.new("UICorner", NProgress).CornerRadius = UDim.new(1, 0)

            NTitle.TextTransparency = 1
            NText.TextTransparency = 1
            NTimer.TextTransparency = 1
            NBar.BackgroundTransparency = 1
            NStroke.Transparency = 1

            table.insert(ActiveNotifs, Notif)

            -- FIX #1: RepositionAll uses absolute pixel Y so notifs stack upward from bottom
            -- and are always fully inside the screen (no out of bounds)
            local function RepositionAll()
                local vpr = workspace.CurrentCamera.ViewportSize
                local margin = 14
                -- FIX #1: bottom margin - start from bottom of screen minus margin
                local yBot = vpr.Y - margin
                for i = #ActiveNotifs, 1, -1 do
                    local n = ActiveNotifs[i]
                    local nh = nH -- use fixed nH, AbsoluteSize unreliable before first render
                    yBot = yBot - nh
                    -- FIX #1: clamp X so notification never goes off left or right edge
                    local nx = math.clamp(vpr.X - nW - margin, margin, vpr.X - nW - margin)
                    Tween(n, {Position = UDim2.new(0, nx, 0, yBot)}, 0.3)
                    yBot = yBot - 10
                end
            end
            RepositionAll()
            Tween(Notif, {BackgroundTransparency = 0.06}, 0.3)
            task.wait(0.2)
            Tween(NTitle, {TextTransparency = 0}, 0.2)
            Tween(NText, {TextTransparency = body and body ~= "" and 0.3 or 1}, 0.2)
            Tween(NTimer, {TextTransparency = 0}, 0.2)
            Tween(NBar, {BackgroundTransparency = 0}, 0.2)
            Tween(NStroke, {Transparency = 0.55}, 0.2)
            Tween(NProgress, {Size = UDim2.new(0, 0, 0, barH)}, 3)

            local timeLeft = 3.0
            local countConn
            countConn = RunService.Heartbeat:Connect(function(dt)
                timeLeft = timeLeft - dt
                if timeLeft <= 0 then
                    NTimer.Text = "0.0s"
                    countConn:Disconnect()
                else
                    NTimer.Text = string.format("%.1fs", timeLeft)
                end
            end)

            task.wait(3)
            countConn:Disconnect()
            for i, n in ipairs(ActiveNotifs) do
                if n == Notif then table.remove(ActiveNotifs, i); break end
            end
            -- reposition remaining after removal
            local vpr2 = workspace.CurrentCamera.ViewportSize
            local margin2 = 14
            local yBot2 = vpr2.Y - margin2
            for i = #ActiveNotifs, 1, -1 do
                local n = ActiveNotifs[i]
                yBot2 = yBot2 - nH
                local nx2 = vpr2.X - nW - margin2
                Tween(n, {Position = UDim2.new(0, nx2, 0, yBot2)}, 0.3)
                yBot2 = yBot2 - 10
            end
            Tween(NTitle, {TextTransparency = 1}, 0.15)
            Tween(NText, {TextTransparency = 1}, 0.15)
            Tween(NTimer, {TextTransparency = 1}, 0.15)
            Tween(NBadge, {TextTransparency = 1, BackgroundTransparency = 1}, 0.15)
            Tween(NBar, {BackgroundTransparency = 1}, 0.15)
            task.wait(0.1)
            local vpr3 = workspace.CurrentCamera.ViewportSize
            -- slide out to the right
            Tween(Notif, {Position = UDim2.new(0, vpr3.X + 20, 0, Notif.Position.Y.Offset), BackgroundTransparency = 1}, 0.25)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end

    function Window:Unload()
        MainFrame.Active = false
        Window:Notification("UI Unloaded", "Library has been destroyed", "error")
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(1.2)
        ScreenGui:Destroy()
    end

    function Window:Destroy()
        Window:Unload()
    end

    -- FIX #7: Track the first tab added by the scripter so it auto-selects on open
    -- firstTab flag ensures the FIRST tab Window:Tab() is called with gets selected
    local firstTab = true

    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "    " .. name
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 158)
        TabBtn.TextSize = 12
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

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
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = CurrentTheme.Accent
        Page.ScrollBarImageTransparency = 0.4
        Page.TopImage = ""
        Page.BottomImage = ""
        Page.MidImage = ""
        Page.Visible = false
        Page.Parent = PageContainer
        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingRight = UDim.new(0, 8)
        PagePad.PaddingLeft = UDim.new(0, 0)
        PagePad.Parent = Page

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 16)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 158)})
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then Tween(bar, {BackgroundTransparency = 1}) end
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.06, TextColor3 = CurrentTheme.Text, BackgroundColor3 = CurrentTheme.Top})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        TabBtn.MouseEnter:Connect(function()
            if TabBar.BackgroundTransparency ~= 0 then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(180, 180, 188)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBar.BackgroundTransparency ~= 0 then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(150, 150, 158)}, 0.15)
            end
        end)

        -- FIX #7: Only auto-select if this is NOT a Config or Settings tab
        -- Config and Settings are always added last by the library itself
        -- so the firstTab will correctly be the scripter's first tab (e.g. "TUNG")
        local isSystemTab = (name == "Config" or name == "Settings")
        if firstTab and not isSystemTab then
            firstTab = false
            Page.Visible = true
            TabBtn.TextColor3 = CurrentTheme.Text
            TabBtn.BackgroundTransparency = 0.06
            TabBtn.BackgroundColor3 = CurrentTheme.Top
            TabBar.BackgroundTransparency = 0
        end

        if name == "Config"   then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        table.insert(ThemeListeners, function()
            Page.ScrollBarImageColor3 = CurrentTheme.Accent
            Page.ScrollBarImageTransparency = 0.4
            if TabBar.BackgroundTransparency == 0 then
                TabBtn.TextColor3 = CurrentTheme.Text
                TabBtn.BackgroundColor3 = CurrentTheme.Top
            end
        end)

        local Elements = {}

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

        function Elements:Label(text)
            local L = Instance.new("TextLabel")
            L.Text = text
            L.Size = UDim2.new(1, 0, 0, 26)
            L.BackgroundTransparency = 1
            L.Font = Enum.Font.GothamMedium
            L.TextSize = 13
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Parent = Page
            L.TextTransparency = 0.2
            AddToRegistry(L, "TextColor3", "Text")
        end

        function Elements:Paragraph(title, body)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, 0)
            F.BackgroundTransparency = 0.04
            F.Parent = Page
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 12)
            AddToRegistry(F, "BackgroundColor3", "Top")

            local St = Instance.new("UIStroke")
            St.Thickness = 1; St.Transparency = 0.82; St.Parent = F
            AddToRegistry(St, "Color", "Stroke")

            local TLbl = Instance.new("TextLabel")
            TLbl.Text = title
            TLbl.Size = UDim2.new(1, -24, 0, 20)
            TLbl.Position = UDim2.new(0, 12, 0, 8)
            TLbl.BackgroundTransparency = 1
            TLbl.Font = Enum.Font.GothamBold
            TLbl.TextSize = 13
            TLbl.TextXAlignment = Enum.TextXAlignment.Left
            TLbl.Parent = F
            AddToRegistry(TLbl, "TextColor3", "Text")

            local BLbl = Instance.new("TextLabel")
            BLbl.Text = body
            BLbl.Size = UDim2.new(1, -24, 0, 0)
            BLbl.Position = UDim2.new(0, 12, 0, 30)
            BLbl.BackgroundTransparency = 1
            BLbl.Font = Enum.Font.Gotham
            BLbl.TextSize = 12
            BLbl.TextXAlignment = Enum.TextXAlignment.Left
            BLbl.TextWrapped = true
            BLbl.AutomaticSize = Enum.AutomaticSize.Y
            BLbl.Parent = F
            BLbl.TextTransparency = 0.25
            AddToRegistry(BLbl, "TextColor3", "Text")

            task.defer(function()
                local pad = 12
                F.Size = UDim2.new(1, 0, 0, 30 + BLbl.AbsoluteSize.Y + pad)
            end)
            BLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                F.Size = UDim2.new(1, 0, 0, 30 + BLbl.AbsoluteSize.Y + 12)
            end)
        end

        local function MakeTile(h)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(1, 0, 0, h)
            F.Parent = Page
            F.BackgroundTransparency = 0.04
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 12)
            AddToRegistry(F, "BackgroundColor3", "Top")

            local A = Instance.new("Frame")
            A.Size = UDim2.new(0, 3, 0.55, 0)
            A.Position = UDim2.new(0, 0, 0.225, 0)
            A.BorderSizePixel = 0
            A.Parent = F
            Instance.new("UICorner", A).CornerRadius = UDim.new(1, 0)
            AddToRegistry(A, "BackgroundColor3", "Accent")

            local St = Instance.new("UIStroke")
            St.Thickness = 1; St.Transparency = 0.82; St.Parent = F
            AddToRegistry(St, "Color", "Stroke")
            return F
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 44)
            Btn.Text = "    " .. text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
            Btn.BackgroundTransparency = 0.04
            AddToRegistry(Btn, "BackgroundColor3", "Top")
            AddToRegistry(Btn, "TextColor3", "Text")

            local St = Instance.new("UIStroke")
            St.Thickness = 1; St.Transparency = 0.82; St.Parent = Btn
            AddToRegistry(St, "Color", "Stroke")

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0, 3, 0.55, 0)
            Bar.Position = UDim2.new(0, 0, 0.225, 0)
            Bar.BorderSizePixel = 0; Bar.Parent = Btn
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Bar, "BackgroundColor3", "Accent")

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {Size = UDim2.new(0.97, 0, 0, 40)}, 0.1)
                task.wait(0.1)
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 44)}, 0.15)
                callback()
                Window:Notification(text, "Activated", "success")
            end)
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.0}, 0.18) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0.04}, 0.18) end)

            table.insert(ThemeListeners, function()
                Btn.BackgroundColor3 = CurrentTheme.Top
                Btn.TextColor3 = CurrentTheme.Text
                Bar.BackgroundColor3 = CurrentTheme.Accent
            end)
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Tile = MakeTile(44)
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""; ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = text; TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0); TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 42, 0, 22); Switch.Position = UDim2.new(1, -56, 0.5, -11)
            Switch.Parent = Tile; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
            Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke

            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1; SwStroke.Transparency = 0.6; SwStroke.Parent = Switch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1); Dot.Parent = Switch
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            Library.Flags[text] = Enabled

            local function Update()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                Library.Flags[text] = Enabled
                ConfigObjects[text].Value = Enabled
                callback(Enabled)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                Enabled = not Enabled; Update()
                Window:Notification(text, Enabled and "Enabled" or "Disabled", Enabled and "success" or "error")
            end)
            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(val)
                Enabled = val; Library.Flags[text] = val
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                callback(Enabled)
            end}

            table.insert(ThemeListeners, function()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
            end)
        end

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Frame = MakeTile(64)

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text; Lbl.Size = UDim2.new(1, -30, 0, 20)
            Lbl.Position = UDim2.new(0, 16, 0, 10); Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Num = Instance.new("TextBox")
            Num.Text = tostring(Val); Num.Size = UDim2.new(0, 52, 0, 22)
            Num.Position = UDim2.new(1, -62, 0, 9)
            Num.BackgroundTransparency = 0.08
            Num.Font = Enum.Font.GothamBold; Num.TextSize = 12
            Num.TextXAlignment = Enum.TextXAlignment.Center; Num.Parent = Frame
            Num.ClearTextOnFocus = false
            Instance.new("UICorner", Num).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Num, "BackgroundColor3", "Main")
            AddToRegistry(Num, "TextColor3", "Accent")
            local NumStroke = Instance.new("UIStroke")
            NumStroke.Thickness = 1; NumStroke.Transparency = 0.75; NumStroke.Parent = Num
            AddToRegistry(NumStroke, "Color", "Stroke")
            Num.Focused:Connect(function() Tween(NumStroke, {Transparency = 0.2}, 0.15) end)

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -30, 0, 5); Track.Position = UDim2.new(0, 16, 0, 46)
            Track.BorderSizePixel = 0; Track.Parent = Frame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Track, "BackgroundColor3", "Stroke")

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Val - min) / (max - min), 0, 1, 0); Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Fill, "BackgroundColor3", "Accent")

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12); Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new((Val - min) / (max - min), 0, 0.5, 0)
            Knob.BackgroundColor3 = Color3.new(1, 1, 1); Knob.ZIndex = 2; Knob.Parent = Track
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, 0, 0, 18); Bar.Position = UDim2.new(0, 0, 0.5, -9)
            Bar.BackgroundTransparency = 1; Bar.Text = ""; Bar.ZIndex = 3; Bar.Parent = Track

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

            Num.FocusLost:Connect(function()
                Tween(NumStroke, {Transparency = 0.75}, 0.15)
                local typed = tonumber(Num.Text)
                if typed then
                    Update(math.clamp(math.floor(typed), min, max))
                else
                    Num.Text = tostring(Val)
                end
            end)

            local sliding = false
            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; Drag(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if sliding then
                        sliding = false
                        Window:Notification(text, tostring(Val), "info")
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Drag(i) end
            end)
            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(val) Update(val) end}

            table.insert(ThemeListeners, function()
                Fill.BackgroundColor3 = CurrentTheme.Accent
                Track.BackgroundColor3 = CurrentTheme.Stroke
                Num.TextColor3 = CurrentTheme.Accent
            end)
        end

        function Elements:Dropdown(text, options, callback)
            local Dropped = false
            local Selected = options[1] or ""

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 44); Btn.Text = ""; Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
            Btn.BackgroundTransparency = 0.04
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local St = Instance.new("UIStroke")
            St.Thickness = 1; St.Transparency = 0.82; St.Parent = Btn
            AddToRegistry(St, "Color", "Stroke")

            local AccBar = Instance.new("Frame")
            AccBar.Size = UDim2.new(0, 3, 0.55, 0); AccBar.Position = UDim2.new(0, 0, 0.225, 0)
            AccBar.BorderSizePixel = 0; AccBar.Parent = Btn
            Instance.new("UICorner", AccBar).CornerRadius = UDim.new(1, 0)
            AddToRegistry(AccBar, "BackgroundColor3", "Accent")

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text; Lbl.Size = UDim2.new(1, -32, 1, 0)
            Lbl.Position = UDim2.new(0, 16, 0, 0); Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Btn
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Image = "rbxassetid://6031091004"; Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -28, 0.5, -8); Icon.BackgroundTransparency = 1; Icon.Parent = Btn
            AddToRegistry(Icon, "ImageColor3", "Accent")

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0); Container.Visible = false
            Container.ClipsDescendants = true; Container.Parent = Page
            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 12)
            Container.BackgroundTransparency = 0.04
            AddToRegistry(Container, "BackgroundColor3", "Top")

            local CSt = Instance.new("UIStroke")
            CSt.Thickness = 1; CSt.Transparency = 0.65; CSt.Parent = Container
            AddToRegistry(CSt, "Color", "Accent")

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder; List.Parent = Container

            Library.Flags[text] = Selected

            local function Select(opt)
                Dropped = false; Selected = opt
                Lbl.Text = text .. "   —   " .. opt
                Library.Flags[text] = opt; ConfigObjects[text].Value = opt
                callback(opt)
                Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                Tween(Icon, {Rotation = 0}, 0.28)
                task.wait(0.3); Container.Visible = false
                Window:Notification(text, opt, "info")
            end

            local OptionButtons = {}

            local function RefreshOptions(newOpts)
                for _, v in pairs(Container:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                OptionButtons = {}
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 34); O.Text = "   " .. opt
                    O.TextXAlignment = Enum.TextXAlignment.Left
                    O.Font = Enum.Font.GothamMedium; O.TextSize = 12
                    O.BackgroundTransparency = 1; O.Parent = Container
                    O.TextColor3 = CurrentTheme.Text
                    table.insert(OptionButtons, O)
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                    O.MouseEnter:Connect(function() Tween(O, {TextColor3 = CurrentTheme.Accent}, 0.15) end)
                    O.MouseLeave:Connect(function() Tween(O, {TextColor3 = CurrentTheme.Text}, 0.15) end)
                end
            end

            table.insert(ThemeListeners, function()
                for _, O in pairs(OptionButtons) do
                    if O and O.Parent then
                        O.TextColor3 = CurrentTheme.Text
                    end
                end
            end)
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped; if Dropped then
                    Container.Visible = true
                    Tween(Container, {Size = UDim2.new(1, 0, 0, #Container:GetChildren() * 34)}, 0.32)
                    Tween(Icon, {Rotation = 180}, 0.32)
                else
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    Tween(Icon, {Rotation = 0}, 0.28)
                    task.wait(0.3); Container.Visible = false
                end
            end)

            local function ResetDropdown()
                Dropped = false
                Selected = options[1] or ""
                Lbl.Text = text
                Library.Flags[text] = Selected
                Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(Icon, {Rotation = 0}, 0.2)
                task.delay(0.22, function() Container.Visible = false end)
            end

            ConfigObjects[text] = {Type = "Dropdown", Value = Selected, Set = function(val) Select(val) end, Refresh = RefreshOptions, Reset = ResetDropdown}
            return {Refresh = RefreshOptions, Reset = ResetDropdown}
        end

        function Elements:Textbox(text, placeholder, callback)
            local Frame = MakeTile(74)

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text; Lbl.Size = UDim2.new(1, 0, 0, 20)
            Lbl.Position = UDim2.new(0, 16, 0, 10); Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -32, 0, 28); Box.Position = UDim2.new(0, 16, 0, 36)
            Box.Text = ""; Box.PlaceholderText = placeholder
            Box.Font = Enum.Font.GothamMedium; Box.TextSize = 12; Box.Parent = Frame
            Box.BackgroundTransparency = 0.08
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
            AddToRegistry(Box, "BackgroundColor3", "Main"); AddToRegistry(Box, "TextColor3", "Text")

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Thickness = 1; BoxStroke.Transparency = 0.75; BoxStroke.Parent = Box
            AddToRegistry(BoxStroke, "Color", "Stroke")

            Library.Flags[text] = ""

            Box.Focused:Connect(function() Tween(BoxStroke, {Transparency = 0.2}, 0.2) end)
            Box.FocusLost:Connect(function()
                Tween(BoxStroke, {Transparency = 0.75}, 0.2)
                Library.Flags[text] = Box.Text
                if ConfigObjects[text] then ConfigObjects[text].Value = Box.Text end
                callback(Box.Text)
                if Box.Text ~= "" then
                    Window:Notification(text, Box.Text, "info")
                end
            end)
            ConfigObjects[text] = {Type = "Textbox", Value = "", Set = function(val)
                Box.Text = val; Library.Flags[text] = val; callback(val)
            end}
        end

        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Tile = MakeTile(44)
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""; ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = text; TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0); TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = Key.Name; KeyLabel.Size = UDim2.new(0, 86, 0, 28)
            KeyLabel.Position = UDim2.new(1, -100, 0.5, -14)
            KeyLabel.Font = Enum.Font.GothamMedium; KeyLabel.TextSize = 11; KeyLabel.Parent = Tile
            KeyLabel.BackgroundTransparency = 0.1
            Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 8)
            AddToRegistry(KeyLabel, "BackgroundColor3", "Main")
            AddToRegistry(KeyLabel, "TextColor3", "Accent")

            Library.Flags[text] = Key.Name

            ClickBtn.MouseButton1Click:Connect(function() KeyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    Key = input.KeyCode; KeyLabel.Text = Key.Name
                    Library.Flags[text] = Key.Name; ConfigObjects[text].Value = Key.Name
                    callback(Key)
                    Window:Notification("Keybind", "Changed to " .. Key.Name)
                else
                    KeyLabel.Text = Key.Name
                end
            end)
            ConfigObjects[text] = {Type = "Keybind", Value = Key.Name, Set = function(val)
                Key = Enum.KeyCode[val] or Key; KeyLabel.Text = Key.Name
                Library.Flags[text] = Key.Name; callback(Key)
            end}
        end

        function Elements:Value(text, default, callback)
            local ValFrame = MakeTile(44)

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = text; NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
            NameLbl.Position = UDim2.new(0, 16, 0, 0); NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 13
            NameLbl.BackgroundTransparency = 1; NameLbl.Parent = ValFrame
            AddToRegistry(NameLbl, "TextColor3", "Text")

            local ValBox = Instance.new("TextBox")
            ValBox.Text = tostring(default); ValBox.Size = UDim2.new(0.28, 0, 0, 28)
            ValBox.Position = UDim2.new(0.72, -14, 0.5, -14)
            ValBox.Font = Enum.Font.GothamMedium; ValBox.TextSize = 12
            ValBox.TextXAlignment = Enum.TextXAlignment.Center; ValBox.Parent = ValFrame
            ValBox.BackgroundTransparency = 0.1
            Instance.new("UICorner", ValBox).CornerRadius = UDim.new(0, 8)
            AddToRegistry(ValBox, "BackgroundColor3", "Main"); AddToRegistry(ValBox, "TextColor3", "Accent")

            Library.Flags[text] = default

            ValBox.FocusLost:Connect(function() Library.Flags[text] = ValBox.Text
                ConfigObjects[text].Value = ValBox.Text
                if callback then callback(ValBox.Text) end
            end)
            ConfigObjects[text] = {Type = "Value", Value = default, Set = function(val)
                ValBox.Text = tostring(val); Library.Flags[text] = val
            end}
        end

        function Elements:ColorPicker(text, default, callback)
            local Color = default or Color3.fromRGB(255, 255, 255)
            local h, s, v = Color3.toHSV(Color)

            local Tile = MakeTile(44)
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""; ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = text; TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 16, 0, 0); TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium; TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Swatch = Instance.new("Frame")
            Swatch.Size = UDim2.new(0, 32, 0, 22); Swatch.Position = UDim2.new(1, -46, 0.5, -11)
            Swatch.BackgroundColor3 = Color; Swatch.Parent = Tile
            Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 6)
            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1; SwStroke.Transparency = 0.6; SwStroke.Parent = Swatch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(1, 0, 0, 0); Panel.Visible = false
            Panel.ClipsDescendants = true; Panel.Parent = Page
            Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
            Panel.BackgroundTransparency = 0.04
            AddToRegistry(Panel, "BackgroundColor3", "Top")
            local PSt = Instance.new("UIStroke")
            PSt.Thickness = 1; PSt.Transparency = 0.65; PSt.Parent = Panel
            AddToRegistry(PSt, "Color", "Accent")

            local pickerOpen = false

            local SVBox = Instance.new("ImageLabel")
            SVBox.Size = UDim2.new(1, -52, 0, 110)
            SVBox.Position = UDim2.new(0, 10, 0, 10)
            SVBox.Image = "rbxassetid://4155801252"
            SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVBox.Parent = Panel
            Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 6)

            local SVDot = Instance.new("Frame")
            SVDot.Size = UDim2.new(0, 10, 0, 10)
            SVDot.AnchorPoint = Vector2.new(0.5, 0.5)
            SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
            SVDot.BackgroundColor3 = Color3.new(1, 1, 1)
            SVDot.ZIndex = 2; SVDot.Parent = SVBox
            Instance.new("UICorner", SVDot).CornerRadius = UDim.new(1, 0)
            local DotStroke = Instance.new("UIStroke")
            DotStroke.Thickness = 1.5
            DotStroke.Color = Color3.fromRGB(80, 80, 80)
            DotStroke.Parent = SVDot

            local HueBar = Instance.new("Frame")
            HueBar.Size = UDim2.new(0, 16, 0, 110)
            HueBar.Position = UDim2.new(1, -30, 0, 10)
            HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            HueBar.BorderSizePixel = 0
            HueBar.Parent = Panel
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 6)

            local HueGradient = Instance.new("UIGradient")
            HueGradient.Rotation = 90
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   0)),
            })
            HueGradient.Parent = HueBar

            local HueDot = Instance.new("Frame")
            HueDot.Size = UDim2.new(1, 6, 0, 4)
            HueDot.AnchorPoint = Vector2.new(0.5, 0.5)
            HueDot.Position = UDim2.new(0.5, 0, h, 0)
            HueDot.BackgroundColor3 = Color3.new(1, 1, 1)
            HueDot.ZIndex = 2; HueDot.Parent = HueBar
            Instance.new("UICorner", HueDot).CornerRadius = UDim.new(1, 0)

            local RGBRow = Instance.new("Frame")
            RGBRow.Size = UDim2.new(1, -20, 0, 28)
            RGBRow.Position = UDim2.new(0, 10, 0, 128)
            RGBRow.BackgroundTransparency = 1
            RGBRow.Parent = Panel

            local function MakeRGBBox(label, xPos)
                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(0.33, -4, 1, 0)
                Holder.Position = UDim2.new(xPos, 2, 0, 0)
                Holder.BackgroundTransparency = 0.08
                Holder.Parent = RGBRow
                Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Holder, "BackgroundColor3", "Main")

                local HolderStroke = Instance.new("UIStroke")
                HolderStroke.Thickness = 1; HolderStroke.Transparency = 0.75; HolderStroke.Parent = Holder
                AddToRegistry(HolderStroke, "Color", "Stroke")

                local Prefix = Instance.new("TextLabel")
                Prefix.Text = label .. ":"
                Prefix.Size = UDim2.new(0, 20, 1, 0)
                Prefix.Position = UDim2.new(0, 4, 0, 0)
                Prefix.BackgroundTransparency = 1
                Prefix.Font = Enum.Font.GothamBold
                Prefix.TextSize = 10
                Prefix.TextXAlignment = Enum.TextXAlignment.Left
                Prefix.Parent = Holder
                AddToRegistry(Prefix, "TextColor3", "Accent")

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1, -26, 1, 0)
                Box.Position = UDim2.new(0, 22, 0, 0)
                Box.Text = "0"
                Box.BackgroundTransparency = 1
                Box.Font = Enum.Font.GothamMedium
                Box.TextSize = 11
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.Parent = Holder
                AddToRegistry(Box, "TextColor3", "Text")

                Box.Focused:Connect(function()
                    Tween(HolderStroke, {Transparency = 0.15}, 0.15)
                end)
                Box.FocusLost:Connect(function()
                    Tween(HolderStroke, {Transparency = 0.75}, 0.15)
                end)

                return Box
            end

            local RBox = MakeRGBBox("R", 0)
            local GBox = MakeRGBBox("G", 0.33)
            local BBox = MakeRGBBox("B", 0.66)

            local function ApplyColor()
                Color = Color3.fromHSV(h, s, v)
                Swatch.BackgroundColor3 = Color
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                RBox.Text = tostring(math.floor(Color.R * 255))
                GBox.Text = tostring(math.floor(Color.G * 255))
                BBox.Text = tostring(math.floor(Color.B * 255))
                Library.Flags[text] = Color
                if ConfigObjects[text] then
                    ConfigObjects[text].Value = {R = Color.R, G = Color.G, B = Color.B}
                end
                callback(Color)
            end
            ApplyColor()

            local function OnRGBInput()
                local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
                local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
                local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
                Color = Color3.fromRGB(r, g, b)
                h, s, v = Color3.toHSV(Color)
                SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                HueDot.Position = UDim2.new(0.5, 0, h, 0)
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Swatch.BackgroundColor3 = Color
                Library.Flags[text] = Color
                if ConfigObjects[text] then
                    ConfigObjects[text].Value = {R = Color.R, G = Color.G, B = Color.B}
                end
                callback(Color)
            end

            RBox.FocusLost:Connect(OnRGBInput)
            GBox.FocusLost:Connect(OnRGBInput)
            BBox.FocusLost:Connect(OnRGBInput)

            local svDragging = false
            local SVBtn = Instance.new("TextButton")
            SVBtn.Size = UDim2.new(1, 0, 1, 0); SVBtn.BackgroundTransparency = 1
            SVBtn.Text = ""; SVBtn.ZIndex = 3; SVBtn.Parent = SVBox
            SVBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if svDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    s = math.clamp((i.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((i.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                    SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                    ApplyColor()
                end
            end)

            local hueDragging = false
            local HueBtn = Instance.new("TextButton")
            HueBtn.Size = UDim2.new(1, 0, 1, 0); HueBtn.BackgroundTransparency = 1
            HueBtn.Text = ""; HueBtn.ZIndex = 3; HueBtn.Parent = HueBar
            HueBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    h = math.clamp((i.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    HueDot.Position = UDim2.new(0.5, 0, h, 0)
                    ApplyColor()
                end
            end)

            ClickBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    Panel.Visible = true
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 166)}, 0.32)
                else
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    task.wait(0.3); Panel.Visible = false
                    local r = math.floor(Color.R * 255)
                    local g = math.floor(Color.G * 255)
                    local b = math.floor(Color.B * 255)
                    Window:Notification(text, r..", "..g..", "..b, "info")
                end
            end)

            Library.Flags[text] = Color
            ConfigObjects[text] = {Type = "ColorPicker", Value = {R = Color.R, G = Color.G, B = Color.B}, Set = function(val)
                if type(val) == "table" then
                    Color = Color3.new(val.R, val.G, val.B)
                    h, s, v = Color3.toHSV(Color)
                    SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueDot.Position = UDim2.new(0.5, 0, h, 0)
                    RBox.Text = tostring(math.floor(Color.R * 255))
                    GBox.Text = tostring(math.floor(Color.G * 255))
                    BBox.Text = tostring(math.floor(Color.B * 255))
                    ApplyColor()
                end
            end}
        end

        return Elements
    end

    local ConfigTab = Window:Tab("Config")
    ConfigTab:Section("manage configs")

    local ConfigName = ""
    ConfigTab:Textbox("Config Name", "enter a name here", function(val) ConfigName = val end)

    local ConfigList = {}
    local Dropdown = ConfigTab:Dropdown("Select Config", {"None"}, function(val) Window.CurrentConfig = val end)

    local ConfigPaths = {}

    local function RefreshConfigs()
        if not isfolder(Window.RootFolder) then makefolder(Window.RootFolder) end
        if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end
        ConfigList = {"None"}
        ConfigPaths = {}
        for _, file in pairs(listfiles(Window.ConfigFolder)) do
            local name = file
            name = name:gsub(".*[\/]", "")
            name = name:gsub("%.json$", "")
            if name ~= "" then
                table.insert(ConfigList, name)
                ConfigPaths[name] = file
            end
        end
        Dropdown.Refresh(ConfigList)
    end

    ConfigTab:Button("Refresh List", function() RefreshConfigs() end)
    ConfigTab:Button("Save Config", function()
        if ConfigName == "" then Window:Notification("Config", "Enter a name first", "warning"); return end
        Library:SaveConfig(ConfigName, Window.ConfigFolder)
        RefreshConfigs()
        Window:Notification("Config", ConfigName .. " Saved", "success")
    end)

    ConfigTab:Button("Load Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then
            Window:Notification("Config", "Select a config first", "warning"); return
        end

        local name = Window.CurrentConfig
        local path = ConfigPaths[name] or (Window.ConfigFolder .. "/" .. name .. ".json")

        Window:Notification("Config", "Loading " .. name .. " Config", "info")
        task.wait(0.1)

        local ok, reason = Library:LoadConfig(path)

        if ok then
            task.wait(2.8)
            Window:Notification("Config", name .. " Config Loaded", "success")
        elseif reason == "file_missing" then
            task.wait(2.8)
            Window:Notification("Config", "Error To Load " .. name .. " Config", "error")
        elseif reason == "bad_data" then
            task.wait(2.8)
            Window:Notification("Config", "Error To Load " .. name .. " Config", "error")
        elseif reason == "partial_load" then
            task.wait(2.8)
            Window:Notification("Config", "Error To Load " .. name .. " Config", "error")
        end
    end)

    ConfigTab:Button("Delete Config", function()
        if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then
            Window:Notification("Config", "Select a config first", "warning"); return
        end
        local name = Window.CurrentConfig
        local path = ConfigPaths[name] or (Window.ConfigFolder .. "/" .. name .. ".json")
        if isfile(path) then
            delfile(path)
            Window.CurrentConfig = ""
            RefreshConfigs()
            if ConfigObjects["Select Config"] and ConfigObjects["Select Config"].Reset then
                ConfigObjects["Select Config"].Reset()
            end
            Window:Notification("Config", name .. " Deleted", "info")
        else
            Window:Notification("Config", "Config file not found", "error")
        end
    end)

    local Settings = Window:Tab("Settings")
    Settings:Section("appearance")
    Settings:Toggle("Rainbow Edge", false, function(v) Library:ToggleRainbow(v) end)
    Settings:Slider("Rainbow Speed", 1, 100, 10, function(v)
        Library:SetRainbowSpeed(v / 10)
    end)
    Settings:Dropdown("Rainbow Type", {"Linear Gradient (Solid Rainbow)", "Animated/Cycling Rainbow", "Smooth Fading Gradient", "Step/Band Rainbow", "Rainbow Pulse", "Radial Rainbow", "Neon/Glowing Rainbow", "Pastel Rainbow", "Vertical/Horizontal Fade"}, function(val) Library:SetRainbowType(val) end)
    local builtinThemes = {"Red", "Dark", "Light", "Purple", "Blue", "Yellow", "Green"}
    local themeList = {}
    for _, n in ipairs(builtinThemes) do table.insert(themeList, n) end
    for name, _ in pairs(Themes) do
        local isBuiltin = false
        for _, b in ipairs(builtinThemes) do if b == name then isBuiltin = true; break end end
        if not isBuiltin then table.insert(themeList, name) end
    end
    local ThemeDropdown = Settings:Dropdown("Theme", themeList, function(v) Library:SetTheme(v) end)
    Settings:Keybind("Menu Keybind", Keybind or Enum.KeyCode.M, function(v) Window:SetKeybind(v) end)
    Settings:Button("Unload UI", function() Window:Unload() end)

    RefreshConfigs()

    do
        for _, r in pairs(Registry) do
            if r.Object and r.Object.Parent then
                pcall(function() r.Object[r.Property] = CurrentTheme[r.Type] end)
            end
        end
        for _, fn in pairs(ThemeListeners) do pcall(fn) end
    end

    return Window
end

return Library
