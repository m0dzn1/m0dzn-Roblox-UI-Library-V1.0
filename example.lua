-- load the m0dzn v1 ui library
local m0dznv1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1/refs/heads/main/m0dzn-Ui-Lib-V1.0.lua"))()

local Window = m0dznv1:CreateWindow({
    Title = "TEST HUB",
    Keybind = Enum.KeyCode.RightShift, -- key to open/close

    -- pick a built in theme like this
    -- Theme = "Purple", -- Yellow / Red / Dark / Light / Purple / Blue / Green

    -- or make ur own theme
    Theme = {
        Name = "Ocean",
        Main = {10, 18, 30},     -- bg
        Top = {18, 28, 45},      -- tiles
        Text = {220, 235, 255},  -- text
        Accent = {60, 160, 255}, -- toggles n sliders
        Stroke = {35, 55, 90},   -- borders
    },
})

local Tab = Window:Tab("TEST")

Tab:Section("elements")

Tab:Label("just a label lol")

Tab:Paragraph("test", "TEST")

Tab:Button("click me", function()
    Window:Notification("nice click", "success")
end)

Tab:Toggle("some toggle", false, function(on)
    print("toggle is now", on)
end)

-- slider 
Tab:Slider("Walk Speed", 0, 100, 16, function(v) -- 0 = min, 100 = max, 16 = default value
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

Tab:Dropdown("pick one", {"A", "B", "C"}, function(v)
    print("picked", v)
end)

Tab:Textbox("type here", "enter something...", function(v)
    print("typed:", v)
end)

Tab:Keybind("a keybind", Enum.KeyCode.E, function(k)
    print("key is now", k.Name)
end)

Tab:Value("some value", "10", function(v)
    print("changed to", v)
end)

Tab:ColorPicker("pick a color", Color3.fromRGB(100, 180, 255), function(c)
    print("color:", c)
end)

Tab:Section("notif types")

Tab:Button("default notif", function()
    Window:Notification("hey this is a notif")
end)
Tab:Button("success", function()
    Window:Notification("it worked!", "success")
end)
Tab:Button("warning", function()
    Window:Notification("careful with this", "warning")
end)
Tab:Button("error", function()
    Window:Notification("something broke lol", "error")
end)
Tab:Button("info", function()
    Window:Notification("just some info", "info")
end)

Window:Notification("script loaded", "success")
