--[[ 
███╗   ███╗ ██████╗ ██████╗ ███████╗███╗   ██╗
████╗ ████║██╔═████╗██╔══██╗╚══███╔╝████╗  ██║
██╔████╔██║██║██╔██║██║  ██║  ███╔╝ ██╔██╗ ██║
██║╚██╔╝██║████╔╝██║██║  ██║ ███╔╝  ██║╚██╗██║
██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗██║ ╚████║
╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝
           M0DZN LIBRARY V1.0 (CONFIG SYSTEM NOT WORK)
]]

print([[
script loaded
 ███╗   ███╗  ██████╗  ██████╗  ███████╗ ███╗   ██╗
 ████╗ ████║ ██╔═████╗ ██╔══██╗ ╚══███╔╝ ████╗  ██║
 ██╔████╔██║ ██║██╔██║ ██║  ██║   ███╔╝  ██╔██╗ ██║
 ██║╚██╔╝██║ ████╔╝██║ ██║  ██║  ███╔╝   ██║╚██╗██║
 ██║ ╚═╝ ██║ ╚██████╔╝ ██████╔╝ ███████╗ ██║ ╚████║
 ╚═╝     ╚═╝  ╚═════╝  ╚═════╝  ╚══════╝ ╚═╝  ╚═══╝
               M0DZN LIBRARY V1.0 (CONFIG SYSTEM NOT WORK)
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
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {} 

local Sounds = {
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
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

local function AddToRegistry(obj, prop, themeIndex)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex})
    obj[prop] = CurrentTheme[themeIndex]
end

local function Tween(obj, props, time)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
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

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0dzn UI"
    local Keybind = Config.Keybind 
    local IsVisible = true
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V6.0"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16) 
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5 
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")

    local Grad = Instance.new("UIGradient")
    Grad.Parent = Stroke
    Grad.Enabled = false

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
                end
            else
                Grad.Enabled = false
                Stroke.Color = CurrentTheme.Stroke
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 50)
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 16)
    AddToRegistry(Topbar, "BackgroundColor3", "Top")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -65)
    Content.Position = UDim2.new(0, 10, 0, 55)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 150, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8); TabList.Parent = TabContainer

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -170, 1, 0)
    PageContainer.Position = UDim2.new(0, 170, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 400)}, 0.6)

    function Window:ToggleUI()
        IsVisible = not IsVisible
        if IsVisible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 400), BackgroundTransparency = 0}, 0.5)
        else
            local t = Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
            t.Completed:Connect(function() if not IsVisible then MainFrame.Visible = false end end)
        end
    end

    function Window:Unload()
        local t = Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
        t.Completed:Connect(function() ScreenGui:Destroy() end)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            Window:ToggleUI()
        end
    end)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame"); Notif.Size = UDim2.new(0, 250, 0, 50); Notif.Position = UDim2.new(1, 20, 1, -70); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
            local NText = Instance.new("TextLabel"); NText.Text = text; NText.Size = UDim2.new(1,-20,1,0); NText.Position = UDim2.new(0,10,0,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamBold; NText.TextSize = 14; AddToRegistry(NText, "TextColor3", "Text")
            Tween(Notif, {Position = UDim2.new(1, -270, 1, -70)}, 0.5); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -70)}, 0.5); task.wait(0.5); Notif:Destroy()
        end)
    end

    local firstTab = true
    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamMedium
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
        PageList.Padding = UDim.new(0, 8); PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 10) end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab) 
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150)}) end end
            Page.Visible = true; Tween(TabBtn, {BackgroundTransparency = 0.9, TextColor3 = CurrentTheme.Text}); Tween(TabBtn, {BackgroundColor3 = CurrentTheme.Accent})
        end)

        if firstTab then firstTab = false; Page.Visible = true; TabBtn.TextColor3 = CurrentTheme.Text; TabBtn.BackgroundTransparency = 0.9; TabBtn.BackgroundColor3 = CurrentTheme.Accent end

        local Elements = {}

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,60); Frame.Parent = Page; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,8); AddToRegistry(Frame, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-110,0,25); Lbl.Position = UDim2.new(0,15,0,8); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(0, 60, 0, 25); Input.Position = UDim2.new(1, -75, 0, 8); Input.Text = tostring(Val); Input.Font = Enum.Font.GothamBold; Input.TextSize = 13; Input.Parent = Frame; Instance.new("UICorner", Input).CornerRadius = UDim.new(0,6); AddToRegistry(Input, "BackgroundColor3", "Main"); AddToRegistry(Input, "TextColor3", "Accent")

            local Bar = Instance.new("TextButton"); Bar.Text = ""; Bar.Size = UDim2.new(1,-30,0,8); Bar.Position = UDim2.new(0,15,0,42); Bar.BackgroundColor3 = Color3.fromRGB(50,50,50); Bar.AutoButtonColor = false; Bar.Parent = Frame; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
            local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Val-min)/(max-min),0,1,0); Fill.Parent = Bar; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0); AddToRegistry(Fill, "BackgroundColor3", "Accent")

            local function Update(new_val, ignore_input)
                Val = math.clamp(new_val, min, max)
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p,0,1,0)}, 0.2)
                if not ignore_input then Input.Text = tostring(Val) end
                ConfigObjects[text].Value = Val
                callback(Val)
            end

            Input.FocusLost:Connect(function()
                local n = tonumber(Input.Text)
                if n then Update(n) else Input.Text = tostring(Val) end
            end)

            local sliding
            Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; PlaySound(Sounds.Slide) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            UserInputService.InputChanged:Connect(function(i) 
                if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then 
                    local p = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Update(math.floor(min + ((max - min) * p)))
                end 
            end)

            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(v) Update(v) end}
        end

        function Elements:Dropdown(text, options, callback)
            local Dropped = false
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,45); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text..": "..options[1]; Lbl.Size = UDim2.new(1,-40,1,0); Lbl.Position = UDim2.new(0,15,0,0); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.GothamMedium; Lbl.TextSize = 16; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Btn; AddToRegistry(Lbl, "TextColor3", "Text")
            
            local Container = Instance.new("Frame"); Container.Size = UDim2.new(1,0,0,0); Container.Visible = false; Container.ClipsDescendants = true; Container.Parent = Page; Instance.new("UICorner", Container).CornerRadius = UDim.new(0,8); AddToRegistry(Container, "BackgroundColor3", "Top")
            local List = Instance.new("UIListLayout"); List.Parent = Container

            local function Select(opt)
                Dropped = false; Lbl.Text = text..": "..opt; callback(opt)
                ConfigObjects[text].Value = opt
                Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.3); task.wait(0.3); Container.Visible = false
            end
            
            local function Refresh(newOpts)
                for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton"); O.Size = UDim2.new(1,0,0,35); O.Text = opt; O.TextColor3 = Color3.fromRGB(180,180,180); O.Font = Enum.Font.Gotham; O.TextSize = 15; O.BackgroundTransparency = 1; O.Parent = Container
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                end
            end
            Refresh(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped; PlaySound(Sounds.Click)
                if Dropped then Container.Visible = true; Tween(Container, {Size = UDim2.new(1,0,0, #Container:GetChildren()*35)}, 0.3)
                else Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.3); task.wait(0.3); Container.Visible = false end
            end)

            ConfigObjects[text] = {Type = "Dropdown", Value = options[1], Set = function(v) Select(v) end, Refresh = Refresh}
            return {Refresh = Refresh}
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.7,0,1,0); Title.Position = UDim2.new(0,15,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.Gotham; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local Switch = Instance.new("Frame"); Switch.Size = UDim2.new(0,42,0,22); Switch.Position = UDim2.new(1,-55,0.5,-11); Switch.Parent = Btn; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0); Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)
            local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0,18,0,18); Dot.Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9); Dot.BackgroundColor3 = Color3.new(1,1,1); Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            local function Update()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
                callback(Enabled)
                ConfigObjects[text].Value = Enabled
            end

            Btn.MouseButton1Click:Connect(function() Enabled = not Enabled; PlaySound(Sounds.Click); Update() end)
            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(v) Enabled = v; Update() end}
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = text; Btn.Font = Enum.Font.Gotham; Btn.TextSize = 14; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8); AddToRegistry(Btn, "BackgroundColor3", "Top"); AddToRegistry(Btn, "TextColor3", "Text")
            Btn.MouseButton1Click:Connect(function() PlaySound(Sounds.Click); callback() end)
        end

        function Elements:Section(text)
            local S = Instance.new("TextLabel"); S.Text = text; S.Size = UDim2.new(1, 0, 0, 25); S.BackgroundTransparency = 1; S.Font = Enum.Font.GothamBold; S.TextSize = 13; S.TextXAlignment = Enum.TextXAlignment.Left; S.Parent = Page; AddToRegistry(S, "TextColor3", "Accent")
        end

        return Elements
    end

    local Settings = Window:Tab("Settings")
    Settings:Section("Interface")
    Settings:Button("Close UI", function() Window:ToggleUI() end)
    Settings:Button("Unload Library", function() Window:Unload() end)
    Settings:Toggle("Rainbow Border", false, function(v) Library:ToggleRainbow(v) end)
    Settings:Dropdown("Theme", {"Dark", "White", "Purple", "Blue", "Red", "Yellow", "Green"}, function(v) Library:SetTheme(v) end)
    Settings:Toggle("Sound Effects", true, function(v) SFXEnabled = v end)

    return Window
end

return Library
