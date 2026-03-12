# 🤑🤑 m0dzn UI Library — V1.0

A clean, fully themeable UI library for Roblox scripts. Smooth animations, real config system, live color picker, 9 rainbow border modes. Default theme is **Yellow**.

---

## 🚀 Load

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
```

---

## 🪟 Create a Window

The simplest setup:

```lua
local Window = Library:CreateWindow({
    Title   = "My Hub",
    Keybind = Enum.KeyCode.M,
})
local Main = Window:Tab("Main")
```

Both `Keybind` and `Theme` are optional — they just let you customise the experience for whoever uses your script.

---

## ⌨️ Custom Keybind

Pass any `Enum.KeyCode` value as `Keybind`. The user can also change it live in the Settings tab, but whatever you put here is the starting keybind.

```lua
local Window = Library:CreateWindow({
    Title   = "My Hub",
    Keybind = Enum.KeyCode.RightShift,  -- change to any key
})
```

Common choices: `Enum.KeyCode.M`, `Enum.KeyCode.RightShift`, `Enum.KeyCode.Insert`, `Enum.KeyCode.F4`

---

## 🎨 Custom Theme

There are two ways to set a theme.

### Option A — Pick a built-in

Pass the name of any built-in theme as a string:

```lua
local Window = Library:CreateWindow({
    Title  = "My Hub",
    Theme  = "Purple",  -- Yellow · Red · Dark · Light · Purple · Blue · Green
})
```

### Option B — Define your own colors

Pass a table with RGB values. You only need to fill in the slots you want to change — anything you leave out falls back to the current default.

```lua
local Window = Library:CreateWindow({
    Title  = "My Hub",
    Theme  = {
        Name   = "Ocean",           -- internal name, used by :SetTheme() later
        Main   = {10,  18,  30},    -- window background
        Top    = {18,  28,  45},    -- topbar + element tile backgrounds
        Text   = {220, 235, 255},   -- all text labels
        Accent = {60,  160, 255},   -- toggles ON, slider fill, accent bars
        Stroke = {35,  55,  90},    -- borders, dividers, toggle OFF color
    },
})
```

You can also pass a real `Color3` instead of an RGB table if you prefer:

```lua
Accent = Color3.fromRGB(60, 160, 255),
```

### Color slot reference

| Slot | What it colors |
|------|---------------|
| `Main` | Window background |
| `Top` | Topbar + all element tile backgrounds |
| `Text` | Every label, button text, dropdown text |
| `Accent` | Toggle ON, slider fill + number, dropdown arrow, section labels, left accent bars |
| `Stroke` | Toggle OFF, slider track, all border strokes, dividers |

### Switch theme at runtime

```lua
Library:SetTheme("Purple")   -- switch to any built-in
Library:SetTheme("Ocean")    -- or any theme you registered in Theme.Name
```

---

## 📋 Elements

### Section
```lua
Main:Section("Combat")
```

### Label
```lua
Main:Label("walkspeed is active")
```

### Paragraph
```lua
Main:Paragraph("About", "made by m0dzn.")
```

### Button
```lua
Main:Button("Teleport", function() end)
```

### Toggle
```lua
Main:Toggle("Auto Farm", false, function(State)
    getgenv().AutoFarm = State
end)
```

### Slider
Click the number box on the right to type a value directly.
```lua
Main:Slider("WalkSpeed", 16, 500, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)
```

### Dropdown
```lua
Main:Dropdown("Team", {"Red", "Blue", "Green"}, function(Option)
    print(Option)
end)
```

### Textbox
```lua
Main:Textbox("Name", "type here...", function(Text)
    print(Text)
end)
```

### Keybind
```lua
Main:Keybind("Fly Key", Enum.KeyCode.F, function(Key)
    print(Key.Name)
end)
```

### Value
```lua
Main:Value("Hitbox Size", 10, function(Value)
    _G.HitboxSize = tonumber(Value)
end)
```

### Color Picker
RGB inputs update in realtime while dragging. Touch supported.
```lua
Main:ColorPicker("ESP Color", Color3.fromRGB(255, 100, 100), function(Color)
    _G.ESPColor = Color
end)
```

---

## 🔔 Notifications

Stack from the bottom-right corner, pushing older ones up. Each has a title, optional body, colored left bar, countdown timer, and a progress bar.

| Type | Color | Example |
|------|-------|---------|
| Default | 🩶 Grey | `Window:Notification("Title", "Body")` |
| Success | 🟢 Green | `Window:Notification("Title", "Body", "success")` |
| Warning | 🟡 Yellow | `Window:Notification("Title", "Body", "warning")` |
| Error | 🔴 Red | `Window:Notification("Title", "Body", "error")` |
| Info | 🩵 Cyan | `Window:Notification("Title", "Body", "info")` |

Short 2-arg style still works:
```lua
Window:Notification("Done", "success")
```

Notifications fire automatically on every element action.

---

## 🪟 Window Controls (Topbar)

| Button | Action |
|--------|--------|
| `—` / `□` | Collapse — hides content, keeps the titlebar |
| `↗` / `↙` | Minimize — shrinks to a small bar, click to restore |
| `✕` | Close — hides the window, shows the floating pill |

Icons are loaded from SVG files written to `m0dzn_icons/` on first run. Falls back to Unicode if the executor doesn't support `file://` URIs.

---

## 📱 Floating Pill

Shows up after closing the window. Draggable anywhere on screen (PC + mobile touch). Tap to reopen with an animation. Has a small `✕` to fully unload.

---

## ⚙️ Settings Tab

- 🌈 **Rainbow Edge** — animated RGB border (off = normal border)
- 🎨 **Rainbow Type** — 9 styles
- 🚀 **Rainbow Speed** — 1–100 (10 = default)
- 🖌️ **Theme** — live theme switcher
- ⌨️ **Menu Keybind** — change show/hide key
- ❌ **Unload UI**

---

## 💾 Config Tab

Type a name  **Save Config**. Later: pick from dropdown  **Load Config** or **Delete Config**. Dropdown resets in realtime after delete.

Files at: `YourTitle/Config/name.json`

---

## 📦 Flags

```lua
Library.Flags["WalkSpeed"]  -- number
Library.Flags["Auto Farm"]  -- bool
Library.Flags["ESP Color"]  -- Color3
Library.Flags["Fly Key"]    -- string
```

---
