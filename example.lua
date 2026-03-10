-- 1. load the library
local m0dznV1 = loadstring(game:HttpGet("github.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/raw/refs/heads/main/m0dzn-ui-libary.lua"))()

-- 2. create the window
local Window = m0dznV1:CreateWindow({
    Title = "TEST HUB",
    Keybind = Enum.KeyCode.M  -- press M to open and close the menu
})

-- 3. create tabs
local TestTab = Window:Tab("TEST")

-- section header
TestTab:Section("test all modules")

-- label: static text, good for info
TestTab:Label("this is a label element")

-- paragraph: longer block of text
TestTab:Paragraph("about this hub", "this ui library was made by m0dzn. it supports toggles, sliders, dropdowns, color pickers, keybinds, and more. all settings are saved through the config tab.")

-- button: runs code once when clicked
TestTab:Button("Test Button", function()
    Window:Notification("button works!")
end)

-- toggle: on/off switch
TestTab:Toggle("Test Toggle", false, function(State)
    -- State is true when on, false when off
    getgenv().TestLoop = State
    task.spawn(function()
        while getgenv().TestLoop do
            print("loop running")
            task.wait(1)
        end
    end)
end)

-- slider: picks a number in a range
TestTab:Slider("Test Slider", 0, 100, 50, function(Value)
    print("slider value:", Value)
end)

-- dropdown: pick one option from a list
TestTab:Dropdown("Test Dropdown", {"Option A", "Option B", "Option C"}, function(Option)
    print("selected:", Option)
    Window:Notification("picked " .. Option)
end)

-- textbox: user types something in
TestTab:Textbox("Test Textbox", "type something here...", function(Text)
    print("typed:", Text)
end)

-- keybind: user sets a key
TestTab:Keybind("Test Keybind", Enum.KeyCode.E, function(Key)
    print("keybind set to:", Key.Name)
end)

-- value: small inline input box, good for numbers
TestTab:Value("Test Value", "10", function(Value)
    print("value changed to:", Value)
end)

-- color picker: pick an RGB color
TestTab:ColorPicker("Test Color", Color3.fromRGB(100, 180, 255), function(Color)
    print("color picked:", Color)
end)

-- section: groups things together
TestTab:Section("notification types")

-- all 5 notification types
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

Window:Notification("test script loaded", "success")
