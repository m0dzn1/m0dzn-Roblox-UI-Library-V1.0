-- 1. load the library
local m0dznV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/m0dzn_ui_v1.lua"))()

local Window = m0dznV2:CreateWindow({
    Title   = "TEST HUB",
    Keybind = Enum.KeyCode.RightShift,  -- change this to any key you want

    -- you can use this to set the default theme
    -- Theme = "Purple",   -- Yellow / Red / Dark / Light / Purple / Blue / Green

    -- or you can use this to custom your default theme
    Theme = {
        Name   = "Ocean",               -- give it a name (used internally)
        Main   = {10,  18,  30},        -- window background
        Top    = {18,  28,  45},        -- topbar + tile backgrounds
        Text   = {220, 235, 255},       -- all labels
        Accent = {60,  160, 255},       -- toggles, sliders, accent bars
        Stroke = {35,  55,  90},        -- borders and dividers
    },
})

-- 3. create tabs
local TestTab = Window:Tab("TEST")

-- section header
TestTab:Section("test all modules")

-- label
TestTab:Label("this is a label element")

-- paragraph
TestTab:Paragraph("about this hub", "this ui library was made by m0dzn. it supports toggles, sliders, dropdowns, color pickers, keybinds, and more. all settings are saved through the config tab.")

-- button
TestTab:Button("Test Button", function()
    Window:Notification("button works!", "success")
end)

-- toggle
TestTab:Toggle("Test Toggle", false, function(State)
    getgenv().TestLoop = State
    task.spawn(function()
        while getgenv().TestLoop do
            print("loop running")
            task.wait(1)
        end
    end)
end)

-- slider
TestTab:Slider("Test Slider", 0, 100, 50, function(Value)
    print("slider value:", Value)
end)

-- dropdown
TestTab:Dropdown("Test Dropdown", {"Option A", "Option B", "Option C"}, function(Option)
    print("selected:", Option)
end)

-- textbox
TestTab:Textbox("Test Textbox", "type something here...", function(Text)
    print("typed:", Text)
end)

-- keybind
TestTab:Keybind("Test Keybind", Enum.KeyCode.E, function(Key)
    print("keybind set to:", Key.Name)
end)

-- value
TestTab:Value("Test Value", "10", function(Value)
    print("value changed to:", Value)
end)

-- color picker
TestTab:ColorPicker("Test Color", Color3.fromRGB(100, 180, 255), function(Color)
    print("color picked:", Color)
end)

-- section
TestTab:Section("notification types")

TestTab:Button("Default Notif", function()
    Window:Notification("this is a default notification")
end)
TestTab:Button("Success Notif", function()
    Window:Notification("action completed successfully", "success")
end)
TestTab:Button("Warning Notif", function()
    Window:Notification("be careful with this setting", "warning")
end)
TestTab:Button("Error Notif", function()
    Window:Notification("something went wrong", "error")
end)
TestTab:Button("Info Notif", function()
    Window:Notification("here is some useful info", "info")
end)

-- startup notification
Window:Notification("test script loaded", "success")
