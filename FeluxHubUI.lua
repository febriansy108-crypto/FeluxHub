local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)
WindUI:SetFont("rbxassetid://font-id-here")

WindUI:Gradient({                                                      
    ["0"] = { Color = Color3.fromHex("#1f1f23"), Transparency = 0 },            
    ["100"]   = { Color = Color3.fromHex("#18181b"), Transparency = 0 },      
}, {                                                                            
    Rotation = 0,                                                               
}), 
local Window = FeluxHub | Comunity:CreateWindow({
    Title = "FeluxHub | Free",
    Icon = "monitor", -- lucide icon
    Author = "by .ftgs and .ftgs",
    Folder = "FeluxHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
local Tab = Window:Tab({
    Title = "Tab Title",
    Icon = "bird", -- optional
    Locked = false, 
      }) 
    local Section = Felux:Section({
    Title = "Section for the tabs",
    Icon = "bird",
    Opened = true,
})
local Dialog = Premium:Dialog({
    Icon = "bird",
    Title = "Dialog Title",
    Content = "Blantant",
    Buttons = {
        {
            Title = "Confirm",
            Callback = function()
                print("Confirmed!")
            end,
        },
        {
            Title = "Cancel",
            Callback = function()
                print("Cancelled!")
            end,
        },
    },
})  
    Window:Tag({
    Title = "Free",
    Icon = "Founder : Randhy",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0, -- from 0 to 13
})
   local Keybind = Tab:Keybind({
    Title = "Keybind",
    Desc = "Keybind to open ui",
    Value = "F",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
      })
