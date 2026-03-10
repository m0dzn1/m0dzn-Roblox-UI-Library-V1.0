# M0DZN UI LIBRARY V1.0

A clean, modern, and fully customizable UI library for Roblox. Light grey theme by default, smooth rounded corners, full config system, and 9 rainbow modes.

## EXAMPLE

![image alt](https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/Example.png)

---

## loading the library

```lua
local m0dznV1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/m0dzn-ui-libary-V1.lua"))()
```

---

## creating a window

```lua
local Window = m0dznV1:CreateWindow({
    Title = "TEST HUB",
    Keybind = Enum.KeyCode.M  -- default is M, press to show/hide with animation
})

local MainTab = Window:Tab("Main")
```

---

## functions and documentation

### 1. Section

Groups related elements together with a small label above them.

```lua
MainTab:Section("Combat Features")
```

### 2. Label

A single static line of text. Good for info or sub-titles.

```lua
MainTab:Label("speed is currently modified")
```

### 3. Paragraph

A block of longer text with a title and a body. Auto-resizes to fit.

```lua
MainTab:Paragraph("about this script", "this hub was made by m0dzn. use the config tab to save your settings.")
```

### 4. Button

Runs a function once when clicked.

```lua
MainTab:Button("Click Me", function()
    print("clicked!")
end)
```

### 5. Toggle

An on/off switch. Good for loops and features you want to enable or disable.

```lua
MainTab:Toggle("Auto Farm", false, function(State)
    getgenv().AutoFarm = State
    while getgenv().AutoFarm do
        print("farming...")
        task.wait(1)
    end
end)
```

### 6. Slider

Lets the user pick a number within a range.

```lua
-- text, min, max, default, callback
MainTab:Slider("WalkSpeed", 16, 200, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)
```

### 7. Dropdown

A list of options to choose one from.

```lua
MainTab:Dropdown("Select Weapon", {"Sword", "Gun", "Knife"}, function(Option)
    print("selected:", Option)
end)
```

### 8. Textbox

An input box where the user can type text or numbers.

```lua
MainTab:Textbox("Enter Message", "type here...", function(Text)
    print("typed:", Text)
end)
```

### 9. Keybind

Lets the user assign a key to something.

```lua
MainTab:Keybind("Fly Key", Enum.KeyCode.F, function(Key)
    print("keybind set to:", Key.Name)
end)
```

### 10. Value

A small inline input box, good for specific numbers like hitbox size.

```lua
MainTab:Value("Hitbox Size", "10", function(Value)
    _G.HeadSize = tonumber(Value)
end)
```

### 11. Color Picker

An HSV color picker with a saturation/value square, hue bar, and hex preview.

```lua
MainTab:ColorPicker("ESP Color", Color3.fromRGB(255, 100, 100), function(Color)
    _G.ESPColor = Color
end)
```

---

## notifications

Notifications appear in the bottom right corner and slide in with a progress bar. There are 5 types.

```lua
Window:Notification("something happened")                  -- default
Window:Notification("saved successfully", "success")       -- green
Window:Notification("check your settings", "warning")      -- yellow
Window:Notification("something went wrong", "error")       -- red
Window:Notification("here is some info", "info")           -- blue
```

---

## keybind behavior

Press the keybind (default `M`) to open or close the UI. Both directions have a smooth animation — the window shrinks down when hiding and expands when showing.

---

## unloading

`Window:Unload()` plays the close animation first, then destroys the UI completely.

```lua
Window:Unload()
```

`Window:Destroy()` does the same thing (kept for compatibility).

---

## settings and customization

The **Settings tab** is added automatically. Options:

1. **Rainbow Edge** — animated RGB border around the window
2. **Rainbow Type** — style of the rainbow animation (9 options)
3. **Theme** — full color scheme change (Light, Dark, White, Purple, Blue, Red, Yellow, Green)
4. **Menu Keybind** — change the open/close key
5. **UI SFX** — toggle sound effects on or off
6. **Unload UI** — removes the UI with an animation

### rainbow modes

1. Linear Gradient
2. Animated/Cycling
3. Smooth Fading Gradient
4. Step/Band
5. Rainbow Pulse
6. Radial
7. Neon/Glowing
8. Pastel
9. Vertical/Horizontal Fade

### themes

Light (default), Dark, White, Purple, Blue, Red, Yellow, Green

---

## config system

The **Config tab** is added automatically. It saves and loads the state of all toggles, sliders, dropdowns, keybinds, and value inputs.

1. **Config Name** — type the name for your save file
2. **Select Config** — pick a saved config from the list
3. **Refresh List** — updates the dropdown with the latest saved files
4. **Save Config** — saves all current settings to a file
5. **Load Config** — loads a saved file and updates all elements
6. **Delete Config** — deletes the selected config file

Files are stored in a folder named after your `Window.Title`.
