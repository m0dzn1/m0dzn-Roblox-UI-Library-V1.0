-- 1. LOAD THE LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/m0dzn1/m0dzn-Roblox-UI-Library-V1.0/refs/heads/main/m0dzn%20ui%20lib"))()

-- 2. CREATE THE WINDOW
local Window = Library:CreateWindow({
    Title = "TEST HUB",            -- Change the name of your hub here
    Keybind = Enum.KeyCode.RightControl  -- The key to Open/Close the menu
})

-- 3. CREATE TABS
-- You can name these whatever you want (e.g., "Farming", "Combat", "Misc")
local MainTab = Window:Tab("Main Features")
local PlayerTab = Window:Tab("Player Stats")
local MiscTab = Window:Tab("Misc & Text")

--[[ ----------------------------------------------
TAB 1: MAIN FEATURES (Button, Toggle, Notification)
---------------------------------------------------]

MainTab:Section("Basic Interactions") -- Creates a section title

-- BUTTON
-- Buttons run code once when clicked.
MainTab:Button("Test Notification", function()
    -- PUT YOUR CODE HERE
    -- This triggers a notification at the bottom right
    Window:Notification("Success! Button works.") 
end)

-- TOGGLE
-- Toggles turn things ON and OFF (good for loops).
MainTab:Toggle("Auto Print Loop", false, function(State)
    -- 'State' is true (ON) or false (OFF)
    getgenv().TestingLoop = State -- Set a global variable

    -- Example loop:
    task.spawn(function()
        while getgenv().TestingLoop do
            print("Loop is running...") -- PUT CODE TO REPEAT HERE
            task.wait(1) -- How fast the loop runs
        end
    end)

    if State then
        Window:Notification("Loop Started!")
    else
        Window:Notification("Loop Stopped!")
    end
end)

-- DROPDOWN
-- Allows selecting one item from a list.
MainTab:Dropdown("Select Weapon", {"Sword", "Gun", "Knife", "Bow"}, function(Option)
    -- 'Option' is the text they picked
    print("User selected: " .. Option)
    Window:Notification("Equipped: " .. Option)
    -- Put code to equip item here
end)

--[[-------------------------------------
TAB 2: PLAYER STATS (Slider, Value/Input)
-----------------------------------------]]

PlayerTab:Section("Character Modifiers")

-- SLIDER TEST
-- Used for Speed, Jump, FOV, etc. (Range of numbers).
-- Format: "Name", Min, Max, Default, Callback
PlayerTab:Slider("WalkSpeed", 16, 200, 16, function(Value)
    -- 'Value' is the number on the slider
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

PlayerTab:Slider("JumpPower", 50, 300, 50, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)

-- [ VALUE (INPUT) TEST ]
-- This is the new function you asked for.
-- Used for specific numbers like Hitbox Size or TP coordinates.
PlayerTab:Value("Hitbox Size", "10", function(Value)
    -- 'Value' is what the user typed in the box
    print("Hitbox size changed to: " .. Value)
    
    -- Example of using it (This is just a print test, not real hitbox code)
    Window:Notification("Hitbox set to " .. Value)
    
    -- REAL USAGE EXAMPLE:
    -- _G.HeadSize = tonumber(Value)
end)

--[[--------------------------
TAB 3: MISC (Keybind, Textbox)
------------------------------]]

MiscTab:Section("Text & Binds")

-- KEYBIND TEST
-- Lets the user choose a key to do something.
MiscTab:Keybind("Fly Toggle Key", Enum.KeyCode.F, function(Key)
    -- This runs when they CHANGE the key, not when they press it.
    -- To make it work, usually you check InputBegan or use a library flag.
    print("Keybind changed to: " .. Key.Name)
    Window:Notification("Keybind is now: " .. Key.Name)
end)

-- TEXTBOX
-- Used for typing names, messages, or scripts.
MiscTab:Textbox("Print Message", "Type here...", function(Text)
    -- 'Text' is what they typed
    print("User typed: " .. Text)
    Window:Notification("You typed: " .. Text)
end)

MiscTab:Section("Credits")
MiscTab:Button("Copy Discord Link", function()
    setclipboard("discord.gg/your-link") -- Copies text to their clipboard
    Window:Notification("Link copied to clipboard!")
end)

-- End of script
Window:Notification("Test Script Loaded!")
