
--==================================================
-- BANANAS
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Purchasable = workspace:WaitForChild("Purchasable")

-- REMOTES
local BuyItem = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Shop")
    :WaitForChild("BuyItem")

local FastTravel = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Misc")
    :WaitForChild("FastTravel")

-- POTION NAMES
local PotionNames = {
    ["Basic Luck Potion"] = true,
    ["Basic Capacity Potion"] = true,
    ["Greater Luck Potion"] = true,
    ["Greater Capacity Potion"] = true,
    ["Merchant's Potion"] = true,
    ["Volcanic Luck Potion"] = true,
    ["Volcanic Strength Potion"] = true,
    ["Supreme Luck Potion"] = true,
    ["Frozen Luck Potion"] = true,
    ["Frozen Speed Potion"] = true,
    ["Cryonic Brew"] = true,
    ["Witches Brew"] = true,
    ["Ambrosia"] = true,
    ["Cosmic Potion"] = true,
    ["Stardust Shake"] = true,
    ["Traveler's Mix"] = true,
    ["Water of Life"] = true,
    ["Instability Potion"] = true,
    ["Quake Potion"] = true,
    ["Blitz Potion"] = true
}

-- TOTEM NAMES
local TotemNames = {
    ["Strange Totem"] = true,
    ["Luck Totem"] = true,
    ["Friendship Totem"] = true,
    ["Luminati Totem"] = true
}

-- DATA
local AllPotions = {}
local AllTotems = {}
local AllItems = {}
local Waypoints = {}

local SelectedItem = nil
local SelectedWaypoint = nil
local CurrentTab = "Potions"

-- GET NIL REMOTE
local function GetNil(Name, DebugId)
    if typeof(getnilinstances) ~= "function" then
        return nil
    end

    for _, Object in ipairs(getnilinstances()) do
        local Success, Result = pcall(function()
            return Object.Name == Name
                and Object:GetDebugId() == DebugId
        end)

        if Success and Result then
            return Object
        end
    end

    return nil
end

local UsePotions = GetNil("UsePotions", "1_44578438")

--==================================================
-- AUTO DETECT ITEMS
--==================================================

local function DetectItems()
    table.clear(AllPotions)
    table.clear(AllTotems)
    table.clear(AllItems)

    for _, Location in ipairs(Purchasable:GetChildren()) do
        for _, Item in ipairs(Location:GetChildren()) do
            local ShopItem = Item:FindFirstChild("ShopItem")

            if ShopItem then
                local Data = {
                    Name = Item.Name,
                    Location = Location.Name,
                    Object = ShopItem
                }

                if PotionNames[Item.Name] then
                    table.insert(AllPotions, Data)

                elseif TotemNames[Item.Name] then
                    table.insert(AllTotems, Data)

                else
                    table.insert(AllItems, Data)
                end
            end
        end
    end
end

--==================================================
-- AUTO DETECT WAYPOINTS
--==================================================

local function DetectWaypoints()
    table.clear(Waypoints)

    local Map = workspace:FindFirstChild("Map")
    local Folder = Map and Map:FindFirstChild("Waypoints")

    if Folder then
        for _, Waypoint in ipairs(Folder:GetChildren()) do
            table.insert(Waypoints, Waypoint)
        end
    end
end

DetectItems()
DetectWaypoints()

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Bananas"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 285, 0, 350)
Main.Position = UDim2.new(0.5, -142, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(13, 19, 34)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 170, 255)
Stroke.Thickness = 1.3
Stroke.Parent = Main

local function MakeButton(Parent, Text, Position, Size)
    local Button = Instance.new("TextButton")
    Button.Text = Text
    Button.Position = Position
    Button.Size = Size
    Button.BackgroundColor3 = Color3.fromRGB(25, 39, 65)
    Button.TextColor3 = Color3.fromRGB(220, 240, 255)
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.Parent = Parent

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    return Button
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -85, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BANANAS"
Title.TextColor3 = Color3.fromRGB(0, 190, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Minimize = MakeButton(
    Main, "-", UDim2.new(1, -65, 0, 6), UDim2.new(0, 25, 0, 23)
)

local Close = MakeButton(
    Main, "X", UDim2.new(1, -35, 0, 6), UDim2.new(0, 25, 0, 23)
)

local TabFrame = Instance.new("Frame")
TabFrame.Position = UDim2.new(0, 7, 0, 40)
TabFrame.Size = UDim2.new(1, -14, 0, 30)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Tabs = {"Fast Travel", "Potions", "Totems", "Items"}
local TabButtons = {}

for i, Name in ipairs(Tabs) do
    local Button = MakeButton(
        TabFrame,
        Name,
        UDim2.new((i - 1) * 0.25, 2, 0, 0),
        UDim2.new(0.25, -4, 1, 0)
    )

    Button.TextSize = 9
    TabButtons[Name] = Button
end

local Search = Instance.new("TextBox")
Search.Position = UDim2.new(0, 8, 0, 77)
Search.Size = UDim2.new(1, -16, 0, 27)
Search.BackgroundColor3 = Color3.fromRGB(23, 31, 49)
Search.TextColor3 = Color3.new(1, 1, 1)
Search.PlaceholderText = "Search..."
Search.PlaceholderColor3 = Color3.fromRGB(130, 145, 165)
Search.Text = ""
Search.TextSize = 11
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 6)

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.new(0, 8, 0, 111)
List.Size = UDim2.new(1, -16, 0, 155)
List.BackgroundColor3 = Color3.fromRGB(18, 27, 43)
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.Name
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = List

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize = UDim2.new(
        0, 0, 0, Layout.AbsoluteContentSize.Y + 10
    )
end)

-- AMOUNT INPUTS

local BuyLabel = Instance.new("TextLabel")
BuyLabel.Position = UDim2.new(0, 10, 0, 273)
BuyLabel.Size = UDim2.new(0, 85, 0, 22)
BuyLabel.BackgroundTransparency = 1
BuyLabel.Text = "Buy Amount"
BuyLabel.TextColor3 = Color3.fromRGB(180, 205, 230)
BuyLabel.TextSize = 10
BuyLabel.Font = Enum.Font.Gotham
BuyLabel.TextXAlignment = Enum.TextXAlignment.Left
BuyLabel.Parent = Main

local BuyAmount = Instance.new("TextBox")
BuyAmount.Position = UDim2.new(0, 95, 0, 273)
BuyAmount.Size = UDim2.new(0, 55, 0, 22)
BuyAmount.BackgroundColor3 = Color3.fromRGB(23, 35, 55)
BuyAmount.TextColor3 = Color3.new(1, 1, 1)
BuyAmount.Text = "1"
BuyAmount.TextSize = 11
BuyAmount.Font = Enum.Font.GothamBold
BuyAmount.Parent = Main

Instance.new("UICorner", BuyAmount).CornerRadius = UDim.new(0, 5)

local UseLabel = Instance.new("TextLabel")
UseLabel.Position = UDim2.new(0, 155, 0, 273)
UseLabel.Size = UDim2.new(0, 75, 0, 22)
UseLabel.BackgroundTransparency = 1
UseLabel.Text = "Use Amount"
UseLabel.TextColor3 = Color3.fromRGB(180, 205, 230)
UseLabel.TextSize = 10
UseLabel.Font = Enum.Font.Gotham
UseLabel.TextXAlignment = Enum.TextXAlignment.Left
UseLabel.Parent = Main

local UseAmount = Instance.new("TextBox")
UseAmount.Position = UDim2.new(0, 230, 0, 273)
UseAmount.Size = UDim2.new(0, 45, 0, 22)
UseAmount.BackgroundColor3 = Color3.fromRGB(23, 35, 55)
UseAmount.TextColor3 = Color3.new(1, 1, 1)
UseAmount.Text = "1"
UseAmount.TextSize = 11
UseAmount.Font = Enum.Font.GothamBold
UseAmount.Parent = Main

Instance.new("UICorner", UseAmount).CornerRadius = UDim.new(0, 5)

local BuyButton = MakeButton(
    Main, "BUY", UDim2.new(0, 10, 0, 303), UDim2.new(0, 125, 0, 30)
)

local UseButton = MakeButton(
    Main, "USE", UDim2.new(0, 150, 0, 303), UDim2.new(0, 125, 0, 30)
)

BuyButton.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
UseButton.BackgroundColor3 = Color3.fromRGB(30, 105, 85)

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 8, 0, 336)
Status.Size = UDim2.new(1, -16, 0, 12)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(120, 190, 220)
Status.TextSize = 9
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--==================================================
-- LIST SYSTEM
--==================================================

local function ClearList()
    for _, Object in ipairs(List:GetChildren()) do
        if Object:IsA("TextButton") then
            Object:Destroy()
        end
    end
end

local function GetCurrentData()
    if CurrentTab == "Potions" then
        return AllPotions
    elseif CurrentTab == "Totems" then
        return AllTotems
    elseif CurrentTab == "Items" then
        return AllItems
    end

    return Waypoints
end

local function RefreshList()
    ClearList()

    SelectedItem = nil
    SelectedWaypoint = nil

    local Query = string.lower(Search.Text)
    local Data = GetCurrentData()

    for _, Entry in ipairs(Data) do
        local Name = Entry.Name

        if string.find(string.lower(Name), Query, 1, true) then
            local Button = MakeButton(
                List,
                Name,
                UDim2.new(),
                UDim2.new(1, -2, 0, 27)
            )

            Button.LayoutOrder = #List:GetChildren()

            Button.MouseButton1Click:Connect(function()
                if CurrentTab == "Fast Travel" then
                    SelectedWaypoint = Entry
                    SelectedItem = nil
                else
                    SelectedItem = Entry
                    SelectedWaypoint = nil
                end

                Status.Text = "Selected: " .. Name

                for _, Child in ipairs(List:GetChildren()) do
                    if Child:IsA("TextButton") then
                        Child.BackgroundColor3 =
                            Color3.fromRGB(25, 39, 65)
                    end
                end

                Button.BackgroundColor3 =
                    Color3.fromRGB(0, 105, 175)
            end)
        end
    end

    if #Data == 0 then
        Status.Text = "No items detected"
    end
end

local function SwitchTab(Name)
    CurrentTab = Name
    SelectedItem = nil
    SelectedWaypoint = nil

    for TabName, Button in pairs(TabButtons) do
        Button.BackgroundColor3 =
            TabName == Name
            and Color3.fromRGB(0, 105, 175)
            or Color3.fromRGB(25, 39, 65)
    end

    BuyLabel.Visible = Name ~= "Fast Travel"
    BuyAmount.Visible = Name ~= "Fast Travel"
    UseLabel.Visible = Name == "Potions"
    UseAmount.Visible = Name == "Potions"

    BuyButton.Visible = Name ~= "Fast Travel"
    UseButton.Visible = Name == "Potions"

    RefreshList()
    Status.Text = Name .. " tab"
end

for Name, Button in pairs(TabButtons) do
    Button.MouseButton1Click:Connect(function()
        SwitchTab(Name)
    end)
end

Search:GetPropertyChangedSignal("Text"):Connect(RefreshList)

--==================================================
-- AMOUNT VALIDATION
--==================================================

local function ReadAmount(Box)
    local Amount = tonumber(Box.Text)

    if not Amount then
        return nil
    end

    Amount = math.floor(Amount)

    if Amount < 1 then
        return nil
    end

    return math.min(Amount, 999)
end

--==================================================
-- BUY
--==================================================

BuyButton.MouseButton1Click:Connect(function()
    if CurrentTab == "Fast Travel" then
        return
    end

    if not SelectedItem then
        Status.Text = "Select an item first"
        return
    end

    if not SelectedItem.Object or not SelectedItem.Object.Parent then
        Status.Text = "Item is no longer available"
        return
    end

    local Amount = ReadAmount(BuyAmount)

    if not Amount then
        Status.Text = "Invalid buy amount"
        return
    end

    local Success, Result = pcall(function()
        return BuyItem:InvokeServer(
            SelectedItem.Object,
            Amount
        )
    end)

    if Success then
        Status.Text = "Purchase request sent"
    else
        Status.Text = "Buy failed: " .. tostring(Result)
    end
end)

--==================================================
-- USE POTIONS
--==================================================

UseButton.MouseButton1Click:Connect(function()
    if CurrentTab ~= "Potions" then
        return
    end

    local Amount = ReadAmount(UseAmount)

    if not Amount then
        Status.Text = "Invalid use amount"
        return
    end

    if not UsePotions then
        Status.Text = "UsePotions remote not found"
        return
    end

    local Success, Result = pcall(function()
        return UsePotions:InvokeServer(Amount)
    end)

    if Success then
        Status.Text = "Potion use request sent"
    else
        Status.Text = "Use failed: " .. tostring(Result)
    end
end)

--==================================================
-- FAST TRAVEL
--==================================================

local function TravelToWaypoint()
    if not SelectedWaypoint then
        Status.Text = "Select a waypoint first"
        return
    end

    local Success, Result = pcall(function()
        FastTravel:FireServer(nil, SelectedWaypoint)
    end)

    if Success then
        Status.Text = "Fast travel request sent"
    else
        Status.Text = "Travel failed: " .. tostring(Result)
    end
end

-- Fast travel uses the selected waypoint when tapped.
-- Add a dedicated button for it:
local TravelButton = MakeButton(
    Main, "TELEPORT",
    UDim2.new(0, 10, 0, 303),
    UDim2.new(1, -20, 0, 30)
)

TravelButton.Visible = false

TabButtons["Fast Travel"].MouseButton1Click:Connect(function()
    TravelButton.Visible = true
    BuyButton.Visible = false
    UseButton.Visible = false
end)

TravelButton.MouseButton1Click:Connect(TravelToWaypoint)

local OriginalSwitchTab = SwitchTab

-- Keep the travel button visible only in its tab.
for Name, Button in pairs(TabButtons) do
    Button.MouseButton1Click:Connect(function()
        TravelButton.Visible = Name == "Fast Travel"
    end)
end

-- OPEN VAULT ANYWHERE

local GetStorageData = game:GetService("ReplicatedStorage")
    .Remotes.Inventory.GetStorageData

local VaultButton = MakeButton(
    Main,
    "VAULT",
    UDim2.new(1, -125, 0, 6),
    UDim2.new(0, 55, 0, 23)
)

VaultButton.BackgroundColor3 = Color3.fromRGB(105, 75, 180)

VaultButton.MouseButton1Click:Connect(function()
    Status.Text = "Requesting Vault data..."

    local Success, Result = pcall(function()
        return GetStorageData:InvokeServer("Chest1")
    end)

    if Success then
        Status.Text = "Vault data received"
        print("VAULT DATA:", Result)
    else
        Status.Text = "Vault request failed"
        warn(Result)
    end
end)
--==================================================
-- MINIMIZE / CLOSE / REOPEN
--==================================================

local OpenButton = MakeButton(
    ScreenGui,
    "OPEN HUB",
    UDim2.new(0, 12, 0.5, -18),
    UDim2.new(0, 90, 0, 32)
)

OpenButton.Visible = false
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 105, 175)

local Minimized = false

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    TabFrame.Visible = not Minimized
    Search.Visible = not Minimized
    List.Visible = not Minimized
    BuyLabel.Visible = not Minimized and CurrentTab ~= "Fast Travel"
    BuyAmount.Visible = not Minimized and CurrentTab ~= "Fast Travel"
    UseLabel.Visible = not Minimized and CurrentTab == "Potions"
    UseAmount.Visible = not Minimized and CurrentTab == "Potions"
    BuyButton.Visible = not Minimized and CurrentTab ~= "Fast Travel"
    UseButton.Visible = not Minimized and CurrentTab == "Potions"
    TravelButton.Visible = not Minimized and CurrentTab == "Fast Travel"

    Main.Size = Minimized
        and UDim2.new(0, 285, 0, 40)
        or UDim2.new(0, 285, 0, 350)
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)

--==================================================
-- MOBILE DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Dragging and (
        Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch
    ) then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- AUTO REFRESH DETECTION
--==================================================

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(10)

        DetectItems()
        DetectWaypoints()

        if Main.Visible then
            RefreshList()
        end
    end
end)

-- START
SwitchTab("Potions")
Status.Text = "BANANAS Ready"

print("BANANAS Loaded")
print("BANANAS")

loadstring(game:HttpGet("https://raw.githubusercontent.com/dashds737-source/Bananas/main/AutoDetection.lua"))()
