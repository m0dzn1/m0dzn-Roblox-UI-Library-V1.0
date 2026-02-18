--[[ 
███╗   ███╗ ██████╗ ██████╗ ███████╗███╗   ██╗
████╗ ████║██╔═████╗██╔══██╗╚══███╔╝████╗  ██║
██╔████╔██║██║██╔██║██║  ██║  ███╔╝ ██╔██╗ ██║
██║╚██╔╝██║████╔╝██║██║  ██║ ███╔╝  ██║╚██╗██║
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║ ╚████║
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝
           M0DZN LIBRARY V1.0 (CONFIG TAB NOT WORK)
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
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- [[ CONFIGURATION ]]
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local GuiTransparency = 0.1
local BlurStrength = 15     
local GlowScale = 20 -- 1 to 100
local MouseUnlocked = true

local Registry = {} 
local ConfigObjects = {} 
local BlurInstance = nil
local ShadowImage = nil 
local ScreenGui = nil
local MainFrame = nil
local NotifContainer = nil

-- ICONS
local ResetIconID = "rbxassetid://7185430959"

-- [[ SOUND SYSTEM ]]
local Sounds = {
    Hover = "rbxassetid://4510086912",
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
    ToggleOff = "rbxassetid://4510087425",
    Slide = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Back = "rbxassetid://4510087236",
    Tab = "rbxassetid://4510087056" 
}

local function PlaySound(id)
    if not SFXEnabled then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = id; s.Volume = 1; s.Parent = SoundService; s:Play(); game.Debris:AddItem(s, 2)
    end)
end

-- [[ THEME SYSTEM ]]
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

-- Helper to track objects for real-time theme changing
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

-- Refresh all colors (used when theme changes)
function Library:RefreshTheme()
    for _, reg in pairs(Registry) do
        if reg.Object then
            Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
            if reg.Property == "BackgroundColor3" and reg.Object.Name ~= "Stroke" then
                reg.Object.BackgroundTransparency = GuiTransparency + (reg.ExtraTrans or 0)
            end
        end
    end
    -- Update Rainbow if active
    if RainbowEnabled and ShadowImage then
        ShadowImage.ImageColor3 = CurrentTheme.Accent 
    end
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        Library:RefreshTheme()
    end
end

-- [[ GLOBAL UTILS ]]
function Library:UpdateTransparency(val)
    GuiTransparency = val
    Library:RefreshTheme()
end

function Library:UpdateGlow(val)
    GlowScale = val
    if ShadowImage then
        -- 1% = Tight, 100% = Large (approx 20% of frame)
        -- Base padding 10px, max additional 100px
        local p = 15 + (val * 0.85) 
        ShadowImage.Size = UDim2.new(1, p, 1, p)
    end
end

-- [[ RAINBOW LOGIC ]]
local function GetRainbowColor(t, type)
    if type == "Animated/Cycling Rainbow" then return Color3.fromHSV(t % 5 / 5, 1, 1) end
    if type == "Rainbow Pulse" then local h = (math.sin(t) + 1) / 2; return Color3.fromHSV(t % 5 / 5, 1, h) end
    if type == "Neon/Glowing Rainbow" then return Color3.fromHSV(t % 3 / 3, 1, 1) end
    if type == "Pastel Rainbow" then return Color3.fromHSV(t % 5 / 5, 0.5, 1) end
    return Color3.fromHSV(t % 5 / 5, 1, 1) -- Fallback
end

function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end

-- [[ MAIN WINDOW CREATION ]]
function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0DZN UI"
    local Keybind = Config.Keybind 

    -- ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V4"
    ScreenGui.DisplayOrder = 9999 -- Always on top
    ScreenGui.Parent = CoreGui
    ScreenGui.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    -- Blur Effect
    task.spawn(function()
        if Lighting:FindFirstChild("M0dznBlur") then Lighting.M0dznBlur:Destroy() end
        BlurInstance = Instance.new("BlurEffect")
        BlurInstance.Name = "M0dznBlur"
        BlurInstance.Size = 0
        BlurInstance.Enabled = false
        BlurInstance.Parent = Lighting
    end)

    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 420)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    -- Glow/Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Glow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5028857472" -- Smooth glow
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.2
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    Shadow.Parent = MainFrame
    ShadowImage = Shadow
    Library:UpdateGlow(GlowScale)

    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    -- Rainbow Loop
    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick()
                local color = GetRainbowColor(t, RainbowType)
                
                -- Handle Gradient Modes
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Gradient.Enabled = true; Gradient.Rotation = 0; Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))})
                    Stroke.Color = Color3.new(1,1,1)
                else
                    -- Solid color cycling modes
                    Gradient.Enabled = false
                    Stroke.Color = color
                    Shadow.ImageColor3 = color -- Glow matches rainbow
                end
            else
                Gradient.Enabled = false
                Stroke.Color = CurrentTheme.Stroke
                Shadow.ImageColor3 = Color3.new(0,0,0) -- Reset glow
            end
            RunService.RenderStepped:Wait()
        end
    end)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)
    AddToRegistry(Topbar, "BackgroundColor3", "Top")
    
    local Fix = Instance.new("Frame"); Fix.Size = UDim2.new(1,0,0,10); Fix.Position = UDim2.new(0,0,1,-5); Fix.BorderSizePixel=0; Fix.Parent = Topbar; AddToRegistry(Fix, "BackgroundColor3", "Top")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    -- Content Areas
    local TabArea = Instance.new("Frame"); TabArea.Size = UDim2.new(0, 150, 1, -45); TabArea.Position = UDim2.new(0,0,0,45); TabArea.BackgroundTransparency = 1; TabArea.Parent = MainFrame
    local PageArea = Instance.new("Frame"); PageArea.Size = UDim2.new(1, -150, 1, -45); PageArea.Position = UDim2.new(0,150,0,45); PageArea.BackgroundTransparency = 1; PageArea.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame"); TabContainer.Size = UDim2.new(1, -10, 1, -10); TabContainer.Position = UDim2.new(0,5,0,5); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = TabArea
    local TabList = Instance.new("UIListLayout"); TabList.Parent = TabContainer; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Padding = UDim.new(0, 5)

    -- Divider
    local Line = Instance.new("Frame"); Line.Size = UDim2.new(0,1,1,0); Line.Position = UDim2.new(0,150,0,45); Line.Parent = MainFrame; AddToRegistry(Line, "BackgroundColor3", "Stroke")

    -- [[ DRAG & ANIMATE ]]
    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local function ToggleUI(bool)
        MainFrame.Visible = bool
        if bool then
            MainFrame.Size = UDim2.new(0,0,0,0)
            MainFrame.BackgroundTransparency = 1
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 420), BackgroundTransparency = GuiTransparency}, 0.3)
            if BlurInstance then 
                BlurInstance.Enabled = true; Tween(BlurInstance, {Size = BlurStrength}, 0.5) 
            end
            if MouseUnlocked then UserInputService.MouseIconEnabled = true end
        else
            if BlurInstance then Tween(BlurInstance, {Size = 0}, 0.3) end
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
            t:Play(); t.Completed:Wait()
            if BlurInstance then BlurInstance.Enabled = false end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then ToggleUI(not MainFrame.Visible) end
    end)
    ToggleUI(true)

    -- [[ NOTIFICATION SYSTEM ]]
    NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 250, 1, 0)
    NotifContainer.Position = UDim2.new(1, -260, 0, 0) -- Right side
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    
    local NotifList = Instance.new("UIListLayout")
    NotifList.Padding = UDim.new(0, 10)
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom -- Stack from bottom up
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.Parent = NotifContainer

    function Window:Notification(text, duration)
        local dur = duration or 3
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(1, 0, 0, 50)
        Notif.BackgroundTransparency = 1 -- Animate in
        Notif.Parent = NotifContainer
        
        -- Card
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1,0,1,0)
        Card.Position = UDim2.new(1, 0, 0, 0) -- Slide in from right
        Card.Parent = Notif
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        AddToRegistry(Card, "BackgroundColor3", "Top")
        
        local Stroke = Instance.new("UIStroke"); Stroke.Parent = Card; Stroke.Thickness = 1.5; AddToRegistry(Stroke, "Color", "Accent")
        
        local Lbl = Instance.new("TextLabel")
        Lbl.Text = text
        Lbl.Size = UDim2.new(1,-10,1,-4)
        Lbl.Position = UDim2.new(0,5,0,4)
        Lbl.BackgroundTransparency = 1
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextColor3 = Color3.new(1,1,1)
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Card
        
        -- Time Bar
        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1,0,0,3)
        Bar.BackgroundColor3 = CurrentTheme.Accent -- Initial color
        Bar.BorderSizePixel = 0
        Bar.Parent = Card
        
        PlaySound(Sounds.Notification)
        Tween(Card, {Position = UDim2.new(0,0,0,0)}, 0.3)
        Tween(Bar, {Size = UDim2.new(0,0,0,3)}, dur) -- Shrink bar
        
        task.spawn(function()
            task.wait(dur)
            Tween(Card, {Position = UDim2.new(1.2,0,0,0)}, 0.3)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy(); if BlurInstance then BlurInstance:Destroy() end end

    -- [[ TAB & ELEMENTS ]]
    local firstTab = true
    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 14
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.new(0, 5, 0, 5)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageArea
        local PageList = Instance.new("UIListLayout"); PageList.Padding = UDim.new(0, 6); PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y+10) end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab)
            for _,v in pairs(PageArea:GetChildren()) do v.Visible = false end
            for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundTransparency=1, TextColor3=Color3.fromRGB(150,150,150)}) end end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency=0.8, TextColor3=CurrentTheme.Text, BackgroundColor3=CurrentTheme.Accent})
        end)

        if firstTab then firstTab=false; Page.Visible=true; TabBtn.TextColor3=CurrentTheme.Text; TabBtn.BackgroundTransparency=0.8; TabBtn.BackgroundColor3=CurrentTheme.Accent end

        local Elements = {}
        
        -- Helper: Create Reset Button
        local function AddReset(parent, callback)
            local Reset = Instance.new("ImageButton")
            Reset.Size = UDim2.new(0,18,0,18)
            Reset.Position = UDim2.new(1, -25, 0.5, -9)
            Reset.BackgroundTransparency = 1
            Reset.Image = ResetIconID
            Reset.ImageColor3 = Color3.fromRGB(180,180,180)
            Reset.Parent = parent
            
            Reset.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                Tween(Reset, {Rotation = 360}, 0.5)
                callback()
                task.wait(0.5)
                Reset.Rotation = 0
            end)
            return Reset
        end
        
        local function CreateCard(h)
            local C = Instance.new("Frame")
            C.Size = UDim2.new(1, 0, 0, h)
            C.Parent = Page
            Instance.new("UICorner", C).CornerRadius = UDim.new(0, 6)
            AddToRegistry(C, "BackgroundColor3", "Top", 0.05)
            local S = Instance.new("UIStroke"); S.Parent = C; S.Thickness=1; S.Transparency=0.8; AddToRegistry(S, "Color", "Stroke")
            return C
        end

        function Elements:Section(text)
            local L = Instance.new("TextLabel"); L.Text = text; L.Size = UDim2.new(1,0,0,25); L.BackgroundTransparency=1; L.Font=Enum.Font.GothamBlack; L.TextSize=12; L.TextColor3=CurrentTheme.Accent; L.Parent=Page; AddToRegistry(L,"TextColor3","Accent")
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Card = CreateCard(36)
            
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,-30,1,0); Btn.BackgroundTransparency=1; Btn.Text=""; Btn.Parent=Card
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size=UDim2.new(1,-50,1,0); Lbl.Position=UDim2.new(0,10,0,0); Lbl.BackgroundTransparency=1; Lbl.Font=Enum.Font.GothamBold; Lbl.TextSize=13; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Card; AddToRegistry(Lbl,"TextColor3","Text")
            
            local Switch = Instance.new("Frame"); Switch.Size=UDim2.new(0,36,0,18); Switch.Position=UDim2.new(1,-65,0.5,-9); Switch.Parent=Card; Instance.new("UICorner",Switch).CornerRadius=UDim.new(1,0)
            local Dot = Instance.new("Frame"); Dot.Size=UDim2.new(0,14,0,14); Dot.Position=UDim2.new(0,2,0.5,-7); Dot.BackgroundColor3=Color3.new(1,1,1); Dot.Parent=Switch; Instance.new("UICorner",Dot).CornerRadius=UDim.new(1,0)
            
            local function Update()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
                callback(Enabled)
            end
            Update()
            
            Btn.MouseButton1Click:Connect(function() Enabled=not Enabled; if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end; Update() end)
            AddReset(Card, function() Enabled=default; Update() end) -- Reset Logic
        end

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Card = CreateCard(50)
            
            local Lbl = Instance.new("TextLabel"); Lbl.Text=text; Lbl.Size=UDim2.new(1,0,0,20); Lbl.Position=UDim2.new(0,10,0,5); Lbl.BackgroundTransparency=1; Lbl.Font=Enum.Font.GothamBold; Lbl.TextSize=13; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Card; AddToRegistry(Lbl,"TextColor3","Text")
            local Num = Instance.new("TextLabel"); Num.Text=tostring(Val); Num.Size=UDim2.new(0,40,0,20); Num.Position=UDim2.new(1,-70,0,5); Num.BackgroundTransparency=1; Num.TextColor3=Color3.fromRGB(150,150,150); Num.Font=Enum.Font.Gotham; Num.TextSize=12; Num.Parent=Card
            
            local SlideBg = Instance.new("TextButton"); SlideBg.Text=""; SlideBg.Size=UDim2.new(1,-20,0,4); SlideBg.Position=UDim2.new(0,10,0,35); SlideBg.BackgroundColor3=Color3.fromRGB(40,40,40); SlideBg.AutoButtonColor=false; SlideBg.Parent=Card; Instance.new("UICorner",SlideBg).CornerRadius=UDim.new(1,0)
            local Fill = Instance.new("Frame"); Fill.Size=UDim2.new((Val-min)/(max-min),0,1,0); Fill.Parent=SlideBg; Instance.new("UICorner",Fill).CornerRadius=UDim.new(1,0); AddToRegistry(Fill,"BackgroundColor3","Accent")
            
            local function Set(v)
                Val = math.clamp(v, min, max)
                Num.Text = tostring(math.floor(Val))
                Tween(Fill, {Size = UDim2.new((Val-min)/(max-min), 0, 1, 0)}, 0.05)
                callback(Val)
            end
            
            local dragging = false
            SlideBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then 
                local p = math.clamp((i.Position.X - SlideBg.AbsolutePosition.X)/SlideBg.AbsoluteSize.X, 0, 1)
                Set(min + (max-min)*p)
            end end)
            
            AddReset(Card, function() Set(default) end) -- Reset Logic
        end
        
        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Card = CreateCard(36)
            
            local Lbl = Instance.new("TextLabel"); Lbl.Text=text; Lbl.Size=UDim2.new(0.6,0,1,0); Lbl.Position=UDim2.new(0,10,0,0); Lbl.BackgroundTransparency=1; Lbl.Font=Enum.Font.GothamBold; Lbl.TextSize=13; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Card; AddToRegistry(Lbl,"TextColor3","Text")
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Position = UDim2.new(1, -110, 0.5, -12) -- Space for reset
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 12
            BindBtn.Text = Key.Name
            BindBtn.Parent = Card
            Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
            AddToRegistry(BindBtn, "BackgroundColor3", "Main", 0.1)
            AddToRegistry(BindBtn, "TextColor3", "Accent")
            
            BindBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                BindBtn.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    Key = input.KeyCode
                    BindBtn.Text = Key.Name
                    callback(Key)
                else
                    BindBtn.Text = Key.Name
                end
            end)
            
            AddReset(Card, function() Key = default; BindBtn.Text = Key.Name; callback(Key) end)
        end
        
        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.Parent = Page
            Btn.Text = text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Btn, "BackgroundColor3", "Top", 0.05)
            AddToRegistry(Btn, "TextColor3", "Text")
            local S = Instance.new("UIStroke"); S.Parent = Btn; S.Thickness=1; S.Transparency=0.8; AddToRegistry(S, "Color", "Stroke")
            
            Btn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                Tween(Btn, {Size = UDim2.new(0.95,0,0,30)}, 0.05)
                task.wait(0.05)
                Tween(Btn, {Size = UDim2.new(1,0,0,32)}, 0.05)
                callback()
            end)
        end

        return Elements
    end

    -- [[ SETTINGS TAB ]]
    local Settings = Window:Tab("Settings")
    Settings:Section("Visuals")
    Settings:Slider("Glow Scale", 1, 100, GlowScale, function(v) Library:UpdateGlow(v) end)
    Settings:Slider("Gui Transparency", 0, 100, GuiTransparency*100, function(v) Library:UpdateTransparency(v/100) end)
    Settings:Slider("Blur Strength", 0, 50, BlurStrength, function(v) BlurStrength=v; if BlurInstance then BlurInstance.Size=v end end)
    
    Settings:Section("Themes & Colors")
    Settings:Toggle("Rainbow Border", RainbowEnabled, function(v) Library:ToggleRainbow(v) end)
    Settings:Toggle("Notifications Sound", SFXEnabled, function(v) SFXEnabled=v end)
    Settings:Button("Test Notification", function() Window:Notification("This is a test message!", 3) end)
    
    -- Restored 9 Modes
    local RainbowModes = {
        "Linear Gradient (Solid Rainbow)", 
        "Animated/Cycling Rainbow", 
        "Smooth Fading Gradient", 
        "Step/Band Rainbow", 
        "Rainbow Pulse", 
        "Radial Rainbow", 
        "Neon/Glowing Rainbow", 
        "Pastel Rainbow", 
        "Vertical/Horizontal Fade"
    }
    
    -- Dropdown Logic (Inline for space)
    local DropFrame = Instance.new("Frame"); DropFrame.Size=UDim2.new(1,0,0,36); DropFrame.Parent=Settings:Button("",function()end).Parent -- Hijack a card
    DropFrame.Parent:Destroy() -- remove placeholder
    
    -- We can just use the previous logic or standard button cycle for space
    -- For now, let's just make simple cycle buttons for complexity management
    
    Settings:Button("Cycle Rainbow Mode", function()
        local currentIdx = table.find(RainbowModes, RainbowType) or 1
        local nextIdx = (currentIdx % #RainbowModes) + 1
        RainbowType = RainbowModes[nextIdx]
        Window:Notification("Mode: "..RainbowType)
    end)
    
    Settings:Button("Cycle Theme", function()
        -- Simple cycler
        local ThemeNames = {"Dark", "White", "Purple", "Blue", "Red", "Yellow", "Green"}
        local found = false
        for i, name in pairs(ThemeNames) do
            if Themes[name].Main == CurrentTheme.Main then
                local nextTheme = ThemeNames[(i % #ThemeNames) + 1]
                Library:SetTheme(nextTheme)
                Window:Notification("Theme: "..nextTheme)
                found = true
                break
            end
        end
        if not found then Library:SetTheme("Dark") end
    end)

    return Window
end

return Library
