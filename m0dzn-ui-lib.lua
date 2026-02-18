--[[ 
███╗   ███╗ ██████╗ ██████╗ ███████╗███╗   ██╗
████╗ ████║██╔═████╗██╔══██╗╚══███╔╝████╗  ██║
██╔████╔██║██║██╔██║██║  ██║  ███╔╝ ██╔██╗ ██║
██║╚██╔╝██║████╔╝██║██║  ██║ ███╔╝  ██║╚██╗██║
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║ ╚████║
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝
           M0DZN LIBRARY V1.0
          (CONFIG TAB NOT WORK)
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
              (CONFIG TAB NOT WORK)
]])

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- CONFIGURABLE SETTINGS
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local GuiTransparency = 0.1 
local BlurStrength = 20     

local Registry = {} 
local ConfigObjects = {} 
local BlurInstance = nil
local MainStroke = nil
local Gradient = nil

-- ICONS
local ResetIconID = "rbxassetid://7185430959"

-- CREATE BLUR
task.spawn(function()
    local existing = Lighting:FindFirstChild("M0dznBlur")
    if existing then existing:Destroy() end
    BlurInstance = Instance.new("BlurEffect")
    BlurInstance.Name = "M0dznBlur"
    BlurInstance.Size = 0 
    BlurInstance.Enabled = false
    BlurInstance.Parent = Lighting
end)

-- SFX SYSTEM
local Sounds = {
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
    ToggleOff = "rbxassetid://4510087425",
    Slide = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Tab = "rbxassetid://4510087056" 
}

local function PlaySound(id)
    if not SFXEnabled then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 1
        s.Parent = SoundService
        s:Play()
        game.Debris:AddItem(s, 2)
    end)
end

-- THEMES
local Themes = {
    Dark   = {Main = Color3.fromRGB(20, 20, 20), Top = Color3.fromRGB(30, 30, 30), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(114, 137, 218), Stroke = Color3.fromRGB(60, 60, 60)},
    White  = {Main = Color3.fromRGB(240, 240, 240), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(0, 120, 215), Stroke = Color3.fromRGB(200, 200, 200)},
    Purple = {Main = Color3.fromRGB(30, 25, 35), Top = Color3.fromRGB(40, 30, 45), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(170, 0, 255), Stroke = Color3.fromRGB(80, 40, 80)},
    Blue   = {Main = Color3.fromRGB(20, 25, 40), Top = Color3.fromRGB(30, 35, 50), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 100, 255), Stroke = Color3.fromRGB(40, 50, 80)},
    Red    = {Main = Color3.fromRGB(35, 20, 20), Top = Color3.fromRGB(45, 25, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 50, 50), Stroke = Color3.fromRGB(80, 40, 40)},
    Yellow = {Main = Color3.fromRGB(35, 35, 20), Top = Color3.fromRGB(45, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 200, 50), Stroke = Color3.fromRGB(80, 80, 40)},
    Green  = {Main = Color3.fromRGB(20, 35, 20), Top = Color3.fromRGB(25, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 200, 100), Stroke = Color3.fromRGB(40, 80, 40)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeIndex, extraTransparency)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex, ExtraTrans = extraTransparency or 0})
    obj[prop] = CurrentTheme[themeIndex]
    if prop == "BackgroundColor3" and obj.Name ~= "Stroke" then
        obj.BackgroundTransparency = GuiTransparency + (extraTransparency or 0)
    end
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:UpdateTransparency(val)
    GuiTransparency = val
    for _, reg in pairs(Registry) do
        if reg.Object and reg.Property == "BackgroundColor3" then
            reg.Object.BackgroundTransparency = GuiTransparency + (reg.ExtraTrans or 0)
        end
    end
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, reg in pairs(Registry) do
            if reg.Object then
                Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
            end
        end
        if not RainbowEnabled and MainStroke then
            MainStroke.Color = CurrentTheme.Stroke
        end
    end
end

-- RAINBOW
function Library:ToggleRainbow(bool) 
    RainbowEnabled = bool 
    if not bool and MainStroke then
        MainStroke.Color = CurrentTheme.Stroke
        if Gradient then Gradient.Enabled = false end
    end
end
function Library:SetRainbowType(val) RainbowType = val end

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0dzn UI"
    local Keybind = Config.Keybind 
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V1.0"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 10000 
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true 
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    -- MAIN CONTAINER
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 400) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = false 
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16) 
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5 
    Stroke.Parent = MainFrame
    MainStroke = Stroke
    AddToRegistry(Stroke, "Color", "Stroke")

    local Grad = Instance.new("UIGradient")
    Grad.Parent = Stroke
    Grad.Enabled = false
    Gradient = Grad

    -- 9 RAINBOW MODES
    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick()
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Grad.Enabled = true; Grad.Rotation = 0
                    Grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Grad.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Grad.Enabled = true; rot = rot + 2; Grad.Rotation = rot
                    Grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Grad.Enabled = false; local h = math.floor((t % 5 / 5) * 6) / 6; Stroke.Color = Color3.fromHSV(h, 1, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Grad.Enabled = false; local h = t % 5 / 5; local v = (math.sin(t * 5) + 1) / 2; Stroke.Color = Color3.fromHSV(h, 1, v)
                elseif RainbowType == "Radial Rainbow" then
                    Grad.Enabled = true; rot = rot + 1; Grad.Rotation = rot; Grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(t % 3 / 3, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV((t + 0.5) % 3 / 3, 1, 1))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Grad.Enabled = false; Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.6, 1); 
                elseif RainbowType == "Pastel Rainbow" then
                     Grad.Enabled = false; Stroke.Color = Color3.fromHSV(t % 10 / 10, 0.4, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                     Grad.Enabled = true; Grad.Rotation = 90; Grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(t % 5 / 5, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV((t+0.5) % 5 / 5, 1, 1))}); Stroke.Color = Color3.new(1,1,1)
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 50) 
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 16)
    AddToRegistry(Topbar, "BackgroundColor3", "Top")

    local Fix = Instance.new("Frame")
    Fix.Size = UDim2.new(1, 0, 0, 20)
    Fix.Position = UDim2.new(0, 0, 1, -10)
    Fix.BorderSizePixel = 0
    Fix.Parent = Topbar
    AddToRegistry(Fix, "BackgroundColor3", "Top")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -65)
    Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 150, 0.82, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8) 
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 150, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -40)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Content
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 32, 0, 32)
    Avatar.Position = UDim2.new(0, 0, 0.5, -16)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
    
    local DispName = Instance.new("TextLabel"); DispName.Text = LocalPlayer.DisplayName; DispName.Size = UDim2.new(1, -40, 0, 15); DispName.Position = UDim2.new(0, 40, 0, 2); DispName.BackgroundTransparency = 1; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 13; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.Parent = ProfileFrame; AddToRegistry(DispName, "TextColor3", "Text")
    local UsrName = Instance.new("TextLabel"); UsrName.Text = "@"..LocalPlayer.Name; UsrName.Size = UDim2.new(1, -40, 0, 15); UsrName.Position = UDim2.new(0, 40, 0, 18); UsrName.BackgroundTransparency = 1; UsrName.Font = Enum.Font.GothamBold; UsrName.TextSize = 11; UsrName.TextTransparency = 0.4; UsrName.TextXAlignment = Enum.TextXAlignment.Left; UsrName.Parent = ProfileFrame; AddToRegistry(UsrName, "TextColor3", "Text")

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 2, 1, 0)
    Line.Position = UDim2.new(0, 160, 0, 0)
    Line.Parent = Content
    AddToRegistry(Line, "BackgroundColor3", "Stroke")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -175, 1, 0)
    PageContainer.Position = UDim2.new(0, 175, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    -- NOTIFICATION
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 250, 1, -20)
    NotifContainer.Position = UDim2.new(1, -270, 0, 0)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    local NotifList = Instance.new("UIListLayout")
    NotifList.Padding = UDim.new(0, 10)
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom 
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Parent = NotifContainer

    -- DRAGGING
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.25) 
        end
    end)

    -- ANIMATIONS: OPEN / HIDE / UNLOAD
    local function ToggleUI(bool)
        MainFrame.Visible = bool
        if bool then
            -- Show Animation: Pop in
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.BackgroundTransparency = 1
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 400), BackgroundTransparency = GuiTransparency}, 0.4)
            if BlurInstance then 
                BlurInstance.Enabled = true 
                Tween(BlurInstance, {Size = BlurStrength}, 0.5) 
            end
            UserInputService.MouseIconEnabled = true
        else
            -- Hide Animation: Fade out + Scale down slightly
            if BlurInstance then Tween(BlurInstance, {Size = 0}, 0.3) end
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
            t:Play()
            t.Completed:Wait()
            if BlurInstance then BlurInstance.Enabled = false end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            ToggleUI(not MainFrame.Visible)
        end
    end)
    ToggleUI(true)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame")
            Notif.Size = UDim2.new(1, 0, 0, 50)
            Notif.BackgroundTransparency = 1 
            Notif.Parent = NotifContainer
            Notif.LayoutOrder = 0 
            
            local Visual = Instance.new("Frame")
            Visual.Size = UDim2.new(1, 0, 1, 0)
            Visual.Position = UDim2.new(1, 0, 0, 0) 
            Visual.Parent = Notif
            Instance.new("UICorner", Visual).CornerRadius = UDim.new(0, 8)
            AddToRegistry(Visual, "BackgroundColor3", "Top")
            
            local S = Instance.new("UIStroke"); S.Parent = Visual; S.Thickness = 1.5; AddToRegistry(S, "Color", "Accent")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,0,1,0); Lbl.BackgroundTransparency = 1; Lbl.Parent = Visual; Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 14; AddToRegistry(Lbl, "TextColor3", "Text")
            
            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, 0, 0, 3)
            Bar.Position = UDim2.new(0, 0, 0, 0) 
            Bar.BorderSizePixel = 0
            Bar.BackgroundColor3 = Color3.new(1,1,1)
            Bar.Parent = Visual
            AddToRegistry(Bar, "BackgroundColor3", "Accent")

            Tween(Visual, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
            Tween(Bar, {Size = UDim2.new(0, 0, 0, 3)}, 3) 

            task.wait(3)
            Tween(Visual, {Position = UDim2.new(1, 20, 0, 0)}, 0.4)
            task.wait(0.4)
            Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    
    function Window:Destroy() 
        -- Unload Animation
        ToggleUI(false) 
        ScreenGui:Destroy()
        if BlurInstance then BlurInstance:Destroy() end 
    end

    local firstTab = true
    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold 
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 14
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 10) 
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 20) end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab) 
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150)}) end end
            Page.Visible = true; Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = CurrentTheme.Text}); Tween(TabBtn, {BackgroundColor3 = CurrentTheme.Accent})
        end)

        if firstTab then firstTab = false; Page.Visible = true; TabBtn.TextColor3 = CurrentTheme.Text; TabBtn.BackgroundTransparency = 0.8; TabBtn.BackgroundColor3 = CurrentTheme.Accent end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}

        local function CreateCard(height)
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -5, 0, height)
            Card.Parent = Page
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
            AddToRegistry(Card, "BackgroundColor3", "Top", 0.05) 
            local S = Instance.new("UIStroke")
            S.Parent = Card; S.Thickness = 1; S.Transparency = 0.8; AddToRegistry(S, "Color", "Stroke")
            return Card
        end
        
        local function AddReset(parent, callback, xOffset)
            local Reset = Instance.new("ImageButton")
            Reset.Name = "Reset"
            Reset.Size = UDim2.new(0, 20, 0, 20)
            Reset.Position = UDim2.new(1, xOffset or -60, 0.5, -10) 
            Reset.BackgroundTransparency = 1
            Reset.Image = ResetIconID
            Reset.ImageColor3 = Color3.fromRGB(150,150,150)
            Reset.Parent = parent
            Reset.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                Tween(Reset, {Rotation = 360}, 0.4)
                callback()
                task.wait(0.4)
                Reset.Rotation = 0
            end)
            return Reset
        end

        function Elements:Section(text)
            local S = Instance.new("TextLabel")
            S.Text = text:upper()
            S.Size = UDim2.new(1, 0, 0, 25)
            S.BackgroundTransparency = 1
            S.Font = Enum.Font.GothamBold 
            S.TextSize = 13
            S.TextXAlignment = Enum.TextXAlignment.Left
            S.Parent = Page
            AddToRegistry(S, "TextColor3", "Accent")
        end

        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Card = CreateCard(40)

            local Title = Instance.new("TextLabel")
            Title.Text = text
            Title.Size = UDim2.new(0.5, 0, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Card
            AddToRegistry(Title, "TextColor3", "Text")
            
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(1, -90, 1, 0)
            KeyBtn.BackgroundTransparency = 1
            KeyBtn.Text = ""
            KeyBtn.Parent = Card
            
            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = Key.Name
            KeyLabel.Size = UDim2.new(0, 80, 0, 24)
            KeyLabel.Position = UDim2.new(1, -90, 0.5, -12) 
            KeyLabel.Font = Enum.Font.GothamBold
            KeyLabel.TextSize = 13
            KeyLabel.Parent = Card
            Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 6)
            AddToRegistry(KeyLabel, "BackgroundColor3", "Main", 0.1)
            AddToRegistry(KeyLabel, "TextColor3", "Accent")

            local function Update(k)
                Key = k
                KeyLabel.Text = Key.Name
                ConfigObjects[text] = {Type = "Keybind", Value = Key.Name}
                callback(Key)
            end

            KeyBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                KeyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then Update(input.KeyCode) else KeyLabel.Text = Key.Name end
            end)
            
            AddReset(Card, function() Update(default) end, -120)

            ConfigObjects[text] = {Type = "Keybind", Value = Key.Name, Set = function(val) Update(Enum.KeyCode[val] or Key) end}
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -5, 0, 40)
            Btn.Text = text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 14
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            AddToRegistry(Btn, "BackgroundColor3", "Top", 0.05)
            AddToRegistry(Btn, "TextColor3", "Text")
            local S = Instance.new("UIStroke"); S.Parent = Btn; S.Thickness = 1; S.Transparency = 0.8; AddToRegistry(S, "Color", "Stroke")

            Btn.MouseButton1Click:Connect(function() 
                PlaySound(Sounds.Click)
                Tween(Btn, {Size = UDim2.new(0.96, -5, 0, 38)}, 0.05); task.wait(0.05); Tween(Btn, {Size = UDim2.new(1, -5, 0, 40)}, 0.05)
                callback() 
            end)
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Card = CreateCard(40)
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,1,0); Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.Parent = Card
            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.7,0,1,0); Title.Position = UDim2.new(0,12,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Card; AddToRegistry(Title, "TextColor3", "Text")
            local Switch = Instance.new("Frame"); Switch.Size = UDim2.new(0,44,0,22); Switch.Position = UDim2.new(1,-54,0.5,-11); Switch.Parent = Card; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0); Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)
            local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0,18,0,18); Dot.Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9); Dot.BackgroundColor3 = Color3.new(1,1,1); Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)
            local function Update(val) Enabled = val; if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end; Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)}); Tween(Dot, {Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}); ConfigObjects[text].Value = Enabled; callback(Enabled) end
            Btn.MouseButton1Click:Connect(function() Update(not Enabled) end)
            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(val) Update(val) end}
        end

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Card = CreateCard(55) 
            
            local Lbl = Instance.new("TextLabel")
            Lbl.Text = text
            Lbl.Size = UDim2.new(1,-20,0,20)
            Lbl.Position = UDim2.new(0,12,0,8)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Card
            AddToRegistry(Lbl, "TextColor3", "Text")
            
            -- SLIDER INPUT BOX
            local InputBox = Instance.new("TextBox")
            InputBox.Text = tostring(Val)
            InputBox.Size = UDim2.new(0,40,0,20)
            InputBox.Position = UDim2.new(1,-50,0,8) 
            InputBox.BackgroundTransparency = 1
            InputBox.TextColor3 = Color3.fromRGB(150,150,150)
            InputBox.Font = Enum.Font.GothamBold
            InputBox.TextSize = 12
            InputBox.Parent = Card
            
            local Bar = Instance.new("TextButton")
            Bar.Text = ""
            Bar.Size = UDim2.new(1,-24,0,6)
            Bar.Position = UDim2.new(0,12,0,38)
            Bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Bar.AutoButtonColor = false
            Bar.Parent = Card
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Val-min)/(max-min),0,1,0)
            Fill.Parent = Bar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
            AddToRegistry(Fill, "BackgroundColor3", "Accent")

            local function Update(val_new)
                Val = math.clamp(val_new, min, max)
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p,0,1,0)}, 0.1)
                InputBox.Text = tostring(Val)
                ConfigObjects[text].Value = Val
                callback(Val)
            end

            local function Drag(input)
                local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + ((max - min) * p))
                Update(newVal)
            end

            -- Input Logic
            InputBox.FocusLost:Connect(function()
                local num = tonumber(InputBox.Text)
                if num then Update(num) else InputBox.Text = tostring(Val) end
            end)

            local sliding
            Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; PlaySound(Sounds.Slide); Drag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then Drag(i) end end)
            
            AddReset(Card, function() Update(default) end, -90)
            
            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(val) Update(val) end}
        end

        function Elements:Textbox(text, placeholder, callback)
            local Card = CreateCard(65)
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,0,0,20); Lbl.Position = UDim2.new(0,12,0,8); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Card; AddToRegistry(Lbl, "TextColor3", "Text")
            local Box = Instance.new("TextBox"); Box.Size = UDim2.new(1,-60,0,28); Box.Position = UDim2.new(0,12,0,30); Box.Text = ""; Box.PlaceholderText = placeholder; Box.Font = Enum.Font.GothamBold; Box.TextSize = 13; Box.Parent = Card; Instance.new("UICorner", Box).CornerRadius = UDim.new(0,6); AddToRegistry(Box, "BackgroundColor3", "Main", 0.1); AddToRegistry(Box, "TextColor3", "Text")
            Box.FocusLost:Connect(function() ConfigObjects[text].Value = Box.Text; callback(Box.Text) end)
            AddReset(Card, function() Box.Text = ""; callback("") end, -30)
            ConfigObjects[text] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
        end

        function Elements:Dropdown(text, options, callback)
            local Dropped, Card = false, CreateCard(40)
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,1,0); Btn.Text = ""; Btn.BackgroundTransparency = 1; Btn.Parent = Card
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-30,1,0); Lbl.Position = UDim2.new(0,12,0,0); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamBold; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Card; AddToRegistry(Lbl, "TextColor3", "Text")
            local Icon = Instance.new("ImageLabel"); Icon.Image = "rbxassetid://6031091004"; Icon.Size = UDim2.new(0,20,0,20); Icon.Position = UDim2.new(1,-30,0.5,-10); Icon.BackgroundTransparency = 1; Icon.Parent = Card
            local Container = Instance.new("Frame"); Container.Size = UDim2.new(1,-5,0,0); Container.Visible = false; Container.ClipsDescendants = true; Container.Parent = Page; Instance.new("UICorner", Container).CornerRadius = UDim.new(0,8); AddToRegistry(Container, "BackgroundColor3", "Top", 0.05); local List = Instance.new("UIListLayout"); List.SortOrder = Enum.SortOrder.LayoutOrder; List.Parent = Container
            
            local function Select(opt) 
                Dropped = false
                Lbl.Text = text..": "..opt
                ConfigObjects[text].Value = opt
                callback(opt)
                Tween(Container, {Size = UDim2.new(1,-5,0,0)}, 0.2)
                Tween(Icon, {Rotation = 0}, 0.2)
                task.wait(0.2)
                Container.Visible = false 
            end
            
            local function Refresh(opts) 
                for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end 
                for _,o in pairs(opts) do 
                    local B=Instance.new("TextButton")
                    B.Size=UDim2.new(1,0,0,30)
                    B.Text=o
                    B.TextColor3=Color3.fromRGB(150,150,150)
                    B.BackgroundTransparency=1
                    B.Font = Enum.Font.GothamBold
                    B.TextSize = 15 -- Bigger Font
                    B.Parent=Container
                    B.MouseButton1Click:Connect(function() Select(o) end) 
                end 
            end
            Refresh(options)
            
            Btn.MouseButton1Click:Connect(function() 
                Dropped = not Dropped
                PlaySound(Sounds.Click)
                if Dropped then 
                    Container.Visible=true
                    Tween(Container, {Size=UDim2.new(1,-5,0,#Container:GetChildren()*30)}, 0.3)
                    Tween(Icon, {Rotation=180}, 0.3) 
                else 
                    Tween(Container, {Size=UDim2.new(1,-5,0,0)}, 0.2)
                    Tween(Icon, {Rotation=0}, 0.2)
                    task.wait(0.2)
                    Container.Visible=false 
                end 
            end)
            
            ConfigObjects[text] = {Type = "Dropdown", Value = options[1], Set = Select, Refresh = Refresh}
            return {Refresh = Refresh}
        end
        return Elements
    end

    local ConfigTab = Window:Tab("Config")
    ConfigTab:Section("Manage Configs")
    local ConfigName = ""
    ConfigTab:Textbox("Config Name", "Type name...", function(val) ConfigName = val end)
    local ConfigList = {}
    local Dropdown = ConfigTab:Dropdown("Select Config", {"None"}, function(val) Window.CurrentConfig = val end)

    local function RefreshConfigs()
        if not isfolder(Window.RootFolder) then makefolder(Window.RootFolder) end
        if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end
        ConfigList = {}
        for _, file in pairs(listfiles(Window.ConfigFolder)) do
            local name = file:gsub(Window.ConfigFolder.."\\", ""):gsub(Window.ConfigFolder.."/", ""):gsub(".json", "")
            table.insert(ConfigList, name)
        end
        Dropdown.Refresh(ConfigList)
    end
    ConfigTab:Button("Refresh List", function() RefreshConfigs() end)
    ConfigTab:Button("Save Config", function() if ConfigName == "" then Window:Notification("Enter a name!"); return end; if not isfolder(Window.RootFolder) then makefolder(Window.RootFolder) end; if not isfolder(Window.ConfigFolder) then makefolder(Window.ConfigFolder) end; local SaveData = {}; for name, data in pairs(ConfigObjects) do SaveData[name] = data.Value end; writefile(Window.ConfigFolder.."/"..ConfigName..".json", HttpService:JSONEncode(SaveData)); Window:Notification("Saved: "..ConfigName); RefreshConfigs() end)
    ConfigTab:Button("Load Config", function() if Window.CurrentConfig == "" or Window.CurrentConfig == "None" then Window:Notification("Select a config!"); return end; local path = Window.ConfigFolder.."/"..Window.CurrentConfig..".json"; if isfile(path) then local data = HttpService:JSONDecode(readfile(path)); for name, val in pairs(data) do if ConfigObjects[name] then ConfigObjects[name].Set(val) end end; Window:Notification("Loaded: "..Window.CurrentConfig) else Window:Notification("Config not found!") end end)

    local Settings = Window:Tab("Settings")
    Settings:Section("Visuals")
    Settings:Slider("Gui Transparency", 0, 100, 10, function(v) Library:UpdateTransparency(v / 100) end)
    Settings:Slider("Blur Strength", 0, 50, 20, function(v) BlurStrength = v; if BlurInstance then BlurInstance.Size = BlurStrength end end)

    Settings:Section("Rainbow & Theme")
    Settings:Toggle("Rainbow Edge", false, function(v) Library:ToggleRainbow(v) end)
    Settings:Dropdown("Rainbow Type", {"Linear Gradient (Solid Rainbow)", "Animated/Cycling Rainbow", "Smooth Fading Gradient", "Step/Band Rainbow", "Rainbow Pulse", "Radial Rainbow", "Neon/Glowing Rainbow", "Pastel Rainbow", "Vertical/Horizontal Fade"}, function(val) Library:SetRainbowType(val) end)
    Settings:Dropdown("Theme", {"Dark", "White", "Purple", "Blue", "Red", "Yellow", "Green"}, function(v) Library:SetTheme(v) end)
    
    Settings:Section("Keybinds")
    Settings:Keybind("Menu Keybind", Keybind or Enum.KeyCode.M, function(v) Window:SetKeybind(v) end)
    Settings:Toggle("UI SFX", true, function(v) SFXEnabled = v end)
    Settings:Button("Destroy UI", function() Window:Destroy() end)

    RefreshConfigs()
    Library:UpdateTransparency(0.1) 
    
    return Window
end
return Library
