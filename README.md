# 🤑🤑 m0dzn UI Library — V1.0

clean fully themeable ui lib for roblox scripts. smooth animations, real config system, live color picker, 9 rainbow border modes

---

## 🚀 load

```lua
local m0dznv1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/m0dzn-Ui-lib-V1.lua"))()
```

---

## 💻 create a window

simplest setup:

```lua
local Window = m0dznv1:CreateWindow({
    Title   = "My Hub",
    Keybind = Enum.KeyCode.M,
})
local Main = Window:Tab("Main")
```

`Keybind` and `Theme` are both optional, just lets u customize the vibe for whoever uses ur script

---

## 🎨 themes

two ways to do it

### option 1 — built in themes

```lua
local Window = Library:CreateWindow({
    Title  = "My Hub",
    Theme  = "Purple",  -- Yellow · Red · Dark · Light · Purple · Blue · Green
})
```

### option 2 — make ur own

```lua
local Window = Library:CreateWindow({
    Title  = "My Hub",
    Theme  = {
        Name   = "Ocean",
        Main   = {10,  18,  30},    -- window bg
        Top    = {18,  28,  45},    -- tiles n topbar
        Text   = {220, 235, 255},   -- all text
        Accent = {60,  160, 255},   -- toggles, sliders, bars
        Stroke = {35,  55,  90},    -- borders n dividers
    },
})
```

u can also pass a real `Color3` instead of rgb table if u want:

```lua
Accent = Color3.fromRGB(60, 160, 255),
```

### color slots

| slot | what it does |
|------|--------------|
| `Main` | window background |
| `Top` | topbar + all tile backgrounds |
| `Text` | every label and button text |
| `Accent` | toggle on, slider fill, dropdown arrow, section labels |
| `Stroke` | toggle off, slider track, borders, dividers |

### change theme at runtime

```lua
Library:SetTheme("Purple")
Library:SetTheme("Ocean")  -- works with custom ones too if u gave it a Name
```

---

## 📋 elements

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
```lua
Main:Slider("WalkSpeed", 16, 500, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)
```

> when using inf/one-sided mode the track bar is hidden and a small `∞` shows next to the textbox. just type ur value and press enter

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
rgb inputs update in realtime while dragging. touch works too
```lua
Main:ColorPicker("ESP Color", Color3.fromRGB(255, 100, 100), function(Color)
    _G.ESPColor = Color
end)
```

---

## 🔔 notifications

stacks from bottom right, pushes older ones up. each one has title, optional body, colored bar, countdown timer and progress bar

| type | color | example |
|------|-------|---------|
| default | 🩶 grey | `Window:Notification("Title", "Body")` |
| success | 🟢 green | `Window:Notification("Title", "Body", "success")` |
| warning | 🟡 yellow | `Window:Notification("Title", "Body", "warning")` |
| error | 🔴 red | `Window:Notification("Title", "Body", "error")` |
| info | 🩵 cyan | `Window:Notification("Title", "Body", "info")` |

short 2 arg style works too:
```lua
Window:Notification("Done", "success")
```

notifs fire automatically on every element action btw

---

## 🪟 window buttons

| button | what it does |
|--------|--------------|
| `—` | collapse — hides content but keeps the titlebar, click again to expand |
| `✕` | hide — same as pressing ur keybind, closes the whole window |

icons are loaded from svg files written to `m0dzn_icons/` on first run. falls back to unicode if ur executor doesnt support file uris

---

## ⚙️ settings tab

- 🌈 **Rainbow Edge** — rgb animated border
- 🎨 **Rainbow Type** — 9 different styles
- 🚀 **Rainbow Speed** — 0 to 10 (1 is default)
- 🖌️ **Theme** — switch themes live
- ⌨️ **Menu Keybind** — change ur open/close key
- ❌ **Unload UI**

---

## 💾 config tab

type a name → **Save Config**. then pick from the dropdown → **Load Config** or **Delete Config**. dropdown updates right away after deleting

---

## 📦 flags

ok so basically every element u make automatically saves its current value into `Library.Flags`. the key is just whatever name u gave the element

so like if u made a slider called `"WalkSpeed"` u can just do this anywhere in ur script:

```lua
print(Library.Flags["WalkSpeed"])  -- prints whatever the slider is currently set to
```

thats it. the lib handles updating it for u, u dont have to do anything extra

---

### why is this useful

say u got a loop running and u want it to check the current slider value every tick instead of only when the user moves the slider. instead of making a variable and updating it manually in the callback u can just read the flag directly:

```lua
-- without flags (annoying, have to track it urself)
local mySpeed = 16
Main:Slider("WalkSpeed", 0, 500, 16, function(v)
    mySpeed = v  -- have to do this every time
end)

task.spawn(function()
    while true do
        print(mySpeed)  -- works but kinda ugly
        task.wait(0.1)
    end
end)
```

```lua
-- with flags (cleaner, just read it whenever)
Main:Slider("WalkSpeed", 0, 500, 16, function(v) end)

task.spawn(function()
    while true do
        print(Library.Flags["WalkSpeed"])  -- always up to date, no extra variable needed
        task.wait(0.1)
    end
end)
```

---

### what type each element saves

| element | what u get |
|---------|-----------|
| Slider | `number` — current value |
| Toggle | `boolean` — `true` or `false` |
| Dropdown | `string` — whatever option is selected |
| Textbox | `string` — whatever was typed |
| Keybind | `string` — key name like `"F"` or `"E"` |
| Value | `string` — whatever is in the box |
| ColorPicker | `Color3` — current picked color |

---

### quick example

```lua
Main:Toggle("Auto Farm", false, function(v) end)
Main:Slider("Farm Delay", 0, 5, 1, function(v) end)

task.spawn(function()
    while true do
        if Library.Flags["Auto Farm"] then  -- check if toggle is on
            print("farming with delay", Library.Flags["Farm Delay"])
            task.wait(Library.Flags["Farm Delay"])  -- use slider value as wait time
        else
            task.wait(0.1)
        end
    end
end)
```

basically just use `Library.Flags["element name"]` anywhere and it always has the latest value. pretty handy ngl

---
