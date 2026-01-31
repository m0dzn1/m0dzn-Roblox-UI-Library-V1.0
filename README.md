# M0DZN UI LIBRARY V1.0

A sleek, modern, and fully customizable UI Library for Roblox. Features a built-in config system, modern animations, custom themes, and 9 different rainbow modes.

 🚀 Loading the Library

Copy the script below and paste it into your executor or anything

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/m0dzn1/m0dzn-ui-lib-test/refs/heads/main/m0dzn%20ui%20lib](https://raw.githubusercontent.com/m0dzn1/m0dzn-ui-lib-test/refs/heads/main/m0dzn%20ui%20lib)"))()

```

---

## 🛠️ Creating a Window

This sets up the main GUI window. The folder name for configs will match your Title.

```lua
local Window = Library:CreateWindow({
    Title = "TEST HUB",                  -- Title shown at top
    Keybind = Enum.KeyCode.RightControl  -- Key to hide/show UI
})

-- Create a Tab
local MainTab = Window:Tab("Main")

```

---

## 📜 Functions & Documentation

Here are all the elements you can add to your UI.

### 1. Section

Used to organize features into categories.

```lua
MainTab:Section("Main Features")

```

### 2. Button

A simple clickable button.

```lua
-- Text, Callback
MainTab:Button("Click Me", function()
    print("Button clicked!")
end)

```

### 3. Toggle

A switch for looping scripts (Auto Farm, Auto Heal, etc).

```lua
-- Text, Default (true/false), Callback
MainTab:Toggle("Auto Farm", false, function(Value)
    getgenv().AutoFarm = Value
    
    while getgenv().AutoFarm do
        print("Farming...")
        task.wait(1)
    end
end)

```

### 4. Slider

Allows selecting a number within a range.

```lua
-- Text, Min, Max, Default, Callback
MainTab:Slider("WalkSpeed", 16, 200, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

```

### 5. Value (Input Box)

**New Feature:** A text box that allows users to type a specific number or text. Great for Hitbox sizes.

```lua
-- Text, Default Input, Callback
MainTab:Value("Hitbox Size", "10", function(Value)
    print("Hitbox changed to: " .. Value)
end)

```

### 6. Dropdown

A list of options for the user to select.

```lua
-- Text, Options Table, Callback
MainTab:Dropdown("Select Weapon", {"Sword", "Gun", "Knife"}, function(Option)
    print("User selected: " .. Option)
end)

```

### 7. Keybind

Allows the user to set a custom key for an action.

```lua
-- Text, Default Key, Callback
MainTab:Keybind("Fly Key", Enum.KeyCode.F, function(Key)
    print("Keybind set to: " .. Key.Name)
end)

```

### 8. Textbox (Long)

A larger input box for typing messages or IDs.

```lua
-- Text, Placeholder, Callback
MainTab:Textbox("Enter Message", "Type here...", function(Text)
    print("Typed: " .. Text)
end)

```

---

## 🔔 Notifications

Send Warning or credit or anything to the user at the bottom right corner.

```lua
Window:Notification("Config Saved!")
Window:Notification("⚠️ Warning: Dangerous Feature")
Window:Notification("Script by M0dzn")

```

---

## ⚙️ Settings & Customization

The library includes a **Settings Tab** by default with these features:

### 🌈 Rainbow Modes (9 Types)

1. **Linear Gradient** (Solid Rainbow)
2. **Animated/Cycling** (Moving Colors)
3. **Smooth Fading Gradient**
4. **Step/Band Rainbow**
5. **Rainbow Pulse**
6. **Radial Rainbow**
7. **Neon/Glowing Rainbow**
8. **Pastel Rainbow**
9. **Vertical/Horizontal Fade**

### 🎨 Themes (7 Presets)

1. **Dark** (Default)
2. **White** (Light Mode)
3. **Purple**
4. **Blue**
5. **Red**
6. **Yellow**
7. **Green**

### 💾 Config System

* **Save:** Automatically saves all Toggles, Sliders, Values, and Keybinds.
* **Load:** Instantly restores saved settings.
* **Auto-Folder:** Creates a folder in workspace named after your Window Title.

---
