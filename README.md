# 🤑 m0dzn UI Library — V1.0

A clean, dark, fully themeable UI library for Roblox scripts. Built with smooth animations, a real config system, live color picker, and 9 rainbow border modes. Default theme is **Red**.

---

## 📸 Preview

![preview](https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/Example.png)

---

## 🚀 Load the Library

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
```

---

## 🪟 Create a Window

```lua
local Window = Library:CreateWindow({
    Title = "My Hub",
    Keybind = Enum.KeyCode.M  -- press M to show/hide
})

local Main = Window:Tab("Main")
```

---

## 📋 Elements

### Section
Adds a small label to group things together.
```lua
Main:Section("Combat")
```

### Label
A single line of static text.
```lua
Main:Label("walkspeed is currently active")
```

### Paragraph
A text block with a title and a body. Auto-resizes.
```lua
Main:Paragraph("About", "made by m0dzn. use the config tab to save your settings.")
```

### Button
Runs a function when clicked.
```lua
Main:Button("Teleport Home", function()
    -- your code here
end)
```

### Toggle
An on/off switch. Perfect for loops and features.
```lua
Main:Toggle("Auto Farm", false, function(State)
    getgenv().AutoFarm = State
    while getgenv().AutoFarm do
        task.wait(1)
    end
end)
```

### Slider
Lets the user pick a number in a range.
```lua
-- label, min, max, default, callback
Main:Slider("WalkSpeed", 16, 500, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)
```

### Dropdown
A list where you pick one option.
```lua
Main:Dropdown("Team", {"Red", "Blue", "Green"}, function(Option)
    print("picked:", Option)
end)
```

### Textbox
A text input field.
```lua
Main:Textbox("Player Name", "type here...", function(Text)
    print("entered:", Text)
end)
```

### Keybind
Lets the user rebind a key.
```lua
Main:Keybind("Fly Key", Enum.KeyCode.F, function(Key)
    print("new key:", Key.Name)
end)
```

### Value
A small inline number input.
```lua
Main:Value("Hitbox Size", 10, function(Value)
    _G.HitboxSize = tonumber(Value)
end)
```

### Color Picker
An HSV picker with a saturation/value square, rainbow hue bar, and R G B inputs. Returns a real `Color3` so you can use it directly.
```lua
Main:ColorPicker("ESP Color", Color3.fromRGB(255, 100, 100), function(Color)
    _G.ESPColor = Color
    -- use like: Part.Color = Color
    -- or: Part.BrickColor = BrickColor.new(Color)
end)
```

---

## 🔔 Notifications

Notifications slide in from the bottom right with a fade, a colored left bar, a countdown timer, and a progress bar at the bottom.

| Type | Color | Call |
|------|-------|------|
| Default | 🩶 Light Grey | `Window:Notification("Title", "Body")` |
| Success | 🟢 Green | `Window:Notification("Title", "Body", "success")` |
| Warning | 🟡 Yellow | `Window:Notification("Title", "Body", "warning")` |
| Error | 🔴 Red | `Window:Notification("Title", "Body", "error")` |
| Info | 🩵 Cyan | `Window:Notification("Title", "Body", "info")` |

```lua
Window:Notification("Saved", "Config saved successfully", "success")
Window:Notification("Watch out", "High ping detected", "warning")
Window:Notification("Error", "Failed to load config", "error")
Window:Notification("Info", "Script version 2.0", "info")
Window:Notification("Hey", "Something just happened")  -- default grey
```

The left vertical bar and border color match the notification type. The countdown in the top right corner counts from `3.0` down to `0.0` in real time.

---

## ⌨️ Keybind

Press the keybind (default `M`) to show or hide the UI. The animation fades and scales — press it fast and it snaps instantly, no delay.

You can change it in the Settings tab or call:
```lua
Window:SetKeybind(Enum.KeyCode.RightShift)
```

---

## 🗑️ Unload

Plays a fade-out animation then destroys the UI completely.
```lua
Window:Unload()
-- or
Window:Destroy()  -- same thing
```

---

## ⚙️ Settings Tab

Added automatically. Options inside:

- 🌈 **Rainbow Edge** — animated RGB border around the window
- 🎨 **Rainbow Type** — 9 animation styles (cycling, gradient, pulse, pastel, etc.)
- 🖌️ **Theme** — full real-time color scheme switch
- ⌨️ **Menu Keybind** — change the show/hide key
- ❌ **Unload UI** — closes and removes the UI

### Themes
`Red` (default) · `Dark` · `Light` · `Purple` · `Blue` · `Yellow` · `Green`

### Rainbow Modes
1. Linear Gradient
2. Animated / Cycling
3. Smooth Fading Gradient
4. Step / Band
5. Rainbow Pulse
6. Radial
7. Neon / Glowing
8. Pastel
9. Vertical / Horizontal Fade

---

## 💾 Config Tab

Added automatically. Saves and loads all toggle, slider, dropdown, keybind, and value states.

1. **Config Name** — type the name you want to save as
2. **Select Config** — pick a saved config from the dropdown
3. **Refresh List** — refreshes the dropdown with your saved files
4. **Save Config** — writes current settings to a file
5. **Load Config** — loads the file and updates every element live
6. **Delete Config** — removes the selected file

---

## 📦 Flags

Every element writes its current value to `Library.Flags` so you can read it from anywhere.

```lua
print(Library.Flags["WalkSpeed"])    -- number
print(Library.Flags["Auto Farm"])    -- true/false
print(Library.Flags["ESP Color"])    -- Color3
print(Library.Flags["Fly Key"])      -- key name string
```

---

Made by **m0dzn** 🖤
