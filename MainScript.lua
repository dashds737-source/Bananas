--==================================================
-- BANANAS V4
--==================================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- REMOTES
local Remotes = RS:WaitForChild("Remotes")
local BuyItem = Remotes.Shop.BuyItem
local FastTravel = Remotes.Misc.FastTravel
local GetStorageData = Remotes.Inventory.GetStorageData

local UsePotions

pcall(function()
    for _, obj in ipairs(getnilinstances()) do
        if obj.Name == "UsePotions"
            and obj:GetDebugId() == "1_44578438" then
            UsePotions = obj
            break
        end
    end
end)

-- ITEM CATEGORIES
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

local TotemNames = {
    ["Strange Totem"] = true,
    ["Luck Totem"] = true,
    ["Friendship Totem"] = true,
    ["Luminati Totem"] = true
}

local Potions, Totems, Items, Waypoints = {}, {}, {}, {}
local SelectedItem, SelectedWaypoint
local CurrentTab = "Potions"

-- AUTO DETECT
local function ScanItems()
    table.clear(Potions)
    table.clear(Totems)
    table.clear(Items)

    local Folder = workspace:FindFirstChild("Purchasable")
    if not Folder then return end

    for _, Location in ipairs(Folder:GetChildren()) do
        for _, Item in ipairs(Location:GetChildren()) do
            local ShopItem = Item:FindFirstChild("ShopItem")

            if ShopItem then
                local Data = {
                    Name = Item.Name,
                    Location = Location.Name,
                    Object = ShopItem
                }

                if PotionNames[Item.Name] then
                    table.insert(Potions, Data)
                elseif TotemNames[Item.Name] then
                    table.insert(Totems, Data)
                else
                    table.insert(Items, Data)
                end
            end
        end
    end
end

local function ScanWaypoints()
    table.clear(Waypoints)

    local Map = workspace:FindFirstChild("Map")
    local Folder = Map and Map:FindFirstChild("Waypoints")

    if Folder then
        for _, Waypoint in ipairs(Folder:GetChildren()) do
            table.insert(Waypoints, Waypoint)
        end
    end
end

ScanItems()
ScanWaypoints()

-- GUI ROOT
local OldGui = PlayerGui:FindFirstChild("BANANAS")
if OldGui then OldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "BANANAS"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(285, 365)
Main.Position = UDim2.new(0.5, -142, 0.5, -182)
Main.BackgroundColor3 = Color3.fromRGB(13, 19, 34)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Border = Instance.new("UIStroke", Main)
Border.Color = Color3.fromRGB(0, 170, 255)
Border.Thickness = 1.4

local function Button(parent, text, pos, size, color)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = color or Color3.fromRGB(25, 39, 65)
    b.TextColor3 = Color3.fromRGB(230, 240, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 35)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "BANANAS V4"
Title.TextColor3 = Color3.fromRGB(0, 190, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Min = Button(Main, "-", UDim2.new(1, -65, 0, 6),
    UDim2.fromOffset(25, 23))
local Close = Button(Main, "X", UDim2.new(1, -35, 0, 6),
    UDim2.fromOffset(25, 23))

local Open = Button(Gui, "BANANAS", UDim2.new(0, 12, 0.5, -18),
    UDim2.fromOffset(90, 34), Color3.fromRGB(0, 105, 175))
Open.Visible = false

local TabsFrame = Instance.new("Frame")
TabsFrame.Position = UDim2.fromOffset(7, 40)
TabsFrame.Size = UDim2.new(1, -14, 0, 30)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = Main

local TabNames = {"Travel", "Potions", "Totems", "Items", "Vault"}
local TabButtons = {}

for i, name in ipairs(TabNames) do
    local b = Button(TabsFrame, name,
        UDim2.new((i - 1) * 0.2, 1, 0, 0),
        UDim2.new(0.2, -3, 1, 0))
    b.TextSize = 9
    TabButtons[name] = b
end

local Search = Instance.new("TextBox")
Search.Position = UDim2.fromOffset(8, 77)
Search.Size = UDim2.new(1, -16, 0, 27)
Search.BackgroundColor3 = Color3.fromRGB(23, 31, 49)
Search.TextColor3 = Color3.new(1, 1, 1)
Search.PlaceholderText = "Search..."
Search.Text = ""
Search.TextSize = 11
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main
Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 6)

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(8, 111)
List.Size = UDim2.new(1, -16, 0, 165)
List.BackgroundColor3 = Color3.fromRGB(18, 27, 43)
List.BorderSizePixel = 0
List.ScrollBarThickness = 3
List.CanvasSize = UDim2.new()
List.Parent = Main
Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 5)
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = List

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
end)

local BuyAmount = Instance.new("TextBox")
BuyAmount.Position = UDim2.fromOffset(10, 284)
BuyAmount.Size = UDim2.fromOffset(55, 23)
BuyAmount.BackgroundColor3 = Color3.fromRGB(23, 35, 55)
BuyAmount.TextColor3 = Color3.new(1, 1, 1)
BuyAmount.Text = "1"
BuyAmount.TextSize = 11
BuyAmount.Font = Enum.Font.GothamBold
BuyAmount.Parent = Main
Instance.new("UICorner", BuyAmount).CornerRadius = UDim.new(0, 5)

local BuyLabel = Instance.new("TextLabel")
BuyLabel.Position = UDim2.fromOffset(10, 267)
BuyLabel.Size = UDim2.fromOffset(80, 15)
BuyLabel.BackgroundTransparency = 1
BuyLabel.Text = "BUY AMOUNT"
BuyLabel.TextColor3 = Color3.fromRGB(180, 205, 230)
BuyLabel.TextSize = 9
BuyLabel.Font = Enum.Font.GothamBold
BuyLabel.TextXAlignment = Enum.TextXAlignment.Left
BuyLabel.Parent = Main

local UseAmount = Instance.new("TextBox")
UseAmount.Position = UDim2.fromOffset(155, 284)
UseAmount.Size = UDim2.fromOffset(55, 23)
UseAmount.BackgroundColor3 = Color3.fromRGB(23, 35, 55)
UseAmount.TextColor3 = Color3.new(1, 1, 1)
UseAmount.Text = "1"
UseAmount.TextSize = 11
UseAmount.Font = Enum.Font.GothamBold
UseAmount.Parent = Main
Instance.new("UICorner", UseAmount).CornerRadius = UDim.new(0, 5)

local UseLabel = Instance.new("TextLabel")
UseLabel.Position = UDim2.fromOffset(155, 267)
UseLabel.Size = UDim2.fromOffset(80, 15)
UseLabel.BackgroundTransparency = 1
UseLabel.Text = "USE AMOUNT"
UseLabel.TextColor3 = Color3.fromRGB(180, 205, 230)
UseLabel.TextSize = 9
UseLabel.Font = Enum.Font.GothamBold
UseLabel.TextXAlignment = Enum.TextXAlignment.Left
UseLabel.Parent = Main

local Buy = Button(Main, "BUY", UDim2.fromOffset(10, 315),
    UDim2.fromOffset(125, 28), Color3.fromRGB(0, 105, 175))

local Use = Button(Main, "USE", UDim2.fromOffset(150, 315),
    UDim2.fromOffset(125, 28), Color3.fromRGB(30, 105, 85))

local TravelButton = Button(Main, "TELEPORT",
    UDim2.fromOffset(10, 315), UDim2.new(1, -20, 0, 28),
    Color3.fromRGB(0, 105, 175))

local VaultButton = Button(Main, "OPEN VAULT ANYWHERE",
    UDim2.fromOffset(10, 315), UDim2.new(1, -20, 0, 28),
    Color3.fromRGB(105, 75, 180))

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8, 345)
Status.Size = UDim2.new(1, -16, 0, 15)
Status.BackgroundTransparency = 1
Status.Text = "BANANAS ready"
Status.TextColor3 = Color3.fromRGB(120, 190, 220)
Status.TextSize = 9
Status.Font = Enum.Font.Gotham
Status.Parent = Main

-- LIST MANAGEMENT
local function CurrentData()
    if CurrentTab == "Travel" then return Waypoints end
    if CurrentTab == "Potions" then return Potions end
    if CurrentTab == "Totems" then return Totems end
    if CurrentTab == "Items" then return Items end
    return {}
end

local function Refresh()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    SelectedItem = nil
    SelectedWaypoint = nil

    local query = string.lower(Search.Text)

    for _, entry in ipairs(CurrentData()) do
        local name = entry.Name

        if string.find(string.lower(name), query, 1, true) then
            local b = Button(List, name, UDim2.new(),
                UDim2.new(1, -2, 0, 27))

            b.LayoutOrder = #List:GetChildren()

            b.MouseButton1Click:Connect(function()
                if CurrentTab == "Travel" then
                    SelectedWaypoint = entry
                    SelectedItem = nil
                else
                    SelectedItem = entry
                    SelectedWaypoint = nil
                end

                Status.Text = "Selected: " .. name

                for _, other in ipairs(List:GetChildren()) do
                    if other:IsA("TextButton") then
                        other.BackgroundColor3 =
                            Color3.fromRGB(25, 39, 65)
                    end
                end

                b.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
            end)
        end
    end
end

local function SwitchTab(name)
    CurrentTab = name
    SelectedItem = nil
    SelectedWaypoint = nil

    for tab, b in pairs(TabButtons) do
        b.BackgroundColor3 = tab == name
            and Color3.fromRGB(0, 105, 175)
            or Color3.fromRGB(25, 39, 65)
    end

    local isVault = name == "Vault"
    local isTravel = name == "Travel"
    local isPotion = name == "Potions"
    local isShop = not isVault and not isTravel

    Search.Visible = not isVault
    List.Visible = not isVault
    BuyLabel.Visible = isShop
    BuyAmount.Visible = isShop
    UseLabel.Visible = isPotion
    UseAmount.Visible = isPotion
    Buy.Visible = isShop
    Use.Visible = isPotion
    TravelButton.Visible = isTravel
    VaultButton.Visible = isVault

    Refresh()
    Status.Text = name .. " tab"
end

for name, b in pairs(TabButtons) do
    b.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

Search:GetPropertyChangedSignal("Text"):Connect(Refresh)

local function Amount(box)
    local n = tonumber(box.Text)
    if not n then return nil end
    n = math.floor(n)
    if n < 1 then return nil end
    return math.min(n, 999)
end

-- BUY SELECTED ITEM
Buy.MouseButton1Click:Connect(function()
    if not SelectedItem then
        Status.Text = "Select an item first"
        return
    end

    local n = Amount(BuyAmount)
    if not n then
        Status.Text = "Invalid buy amount"
        return
    end

    local ok, result = pcall(function()
        return BuyItem:InvokeServer(SelectedItem.Object, n)
    end)

    Status.Text = ok and "Purchase request sent"
        or ("Buy failed: " .. tostring(result))
end)

-- USE POTIONS
Use.MouseButton1Click:Connect(function()
    local n = Amount(UseAmount)

    if not n then
        Status.Text = "Invalid use amount"
        return
    end

    if not UsePotions then
        Status.Text = "UsePotions remote not found"
        return
    end

    local ok, result = pcall(function()
        return UsePotions:InvokeServer(n)
    end)

    Status.Text = ok and "Potion use request sent"
        or ("Use failed: " .. tostring(result))
end)

-- FAST TRAVEL
TravelButton.MouseButton1Click:Connect(function()
    if not SelectedWaypoint then
        Status.Text = "Select a waypoint first"
        return
    end

    local ok, err = pcall(function()
        FastTravel:FireServer(nil, SelectedWaypoint)
    end)

    Status.Text = ok and "Travel request sent"
        or ("Travel failed: " .. tostring(err))
end)

-- OPEN VAULT ANYWHERE
VaultButton.MouseButton1Click:Connect(function()
    local ok, result = pcall(function()
        local Storage = PlayerGui
            :WaitForChild("MainUI")
            :WaitForChild("StorageAccess")

        Storage.Visible = true

        return GetStorageData:InvokeServer("Chest1")
    end)

    Status.Text = ok and "Vault opened / data requested"
        or ("Vault error: " .. tostring(result))

    if ok then
        print("BANANAS Vault data:", result)
    else
        warn("BANANAS Vault error:", result)
    end
end)

-- MINIMIZE / CLOSE / REOPEN
local minimized = false

Min.MouseButton1Click:Connect(function()
    minimized = not minimized

    TabsFrame.Visible = not minimized
    Search.Visible = not minimized and CurrentTab ~= "Vault"
    List.Visible = not minimized and CurrentTab ~= "Vault"
    BuyLabel.Visible = not minimized and
        (CurrentTab == "Potions" or CurrentTab == "Totems" or CurrentTab == "Items")
    BuyAmount.Visible = BuyLabel.Visible
    UseLabel.Visible = not minimized and CurrentTab == "Potions"
    UseAmount.Visible = UseLabel.Visible
    Buy.Visible = BuyLabel.Visible
    Use.Visible = UseLabel.Visible
    TravelButton.Visible = not minimized and CurrentTab == "Travel"
    VaultButton.Visible = not minimized and CurrentTab == "Vault"

    Main.Size = minimized
        and UDim2.fromOffset(285, 40)
        or UDim2.fromOffset(285, 365)
end)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Open.Visible = true
end)

Open.MouseButton1Click:Connect(function()
    Main.Visible = true
    Open.Visible = false
end)

-- TOUCH / MOUSE DRAG
local dragging = false
local dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- PERIODIC AUTO DETECTION
task.spawn(function()
    while Gui.Parent do
        task.wait(10)
        ScanItems()
        ScanWaypoints()

        if Main.Visible then
            Refresh()
        end
    end
end)

SwitchTab("Potions")
print("BANANAS V4 loaded")
-- QUALITY DETECTOR
local QualityLabel = PlayerGui
    :WaitForChild("ToolUI")
    :WaitForChild("FillingPan")
    :WaitForChild("Quality")

task.spawn(function()
    local LastQuality = nil

    while task.wait(0.2) do
        local CurrentQuality = QualityLabel.Text

        if CurrentQuality ~= LastQuality then
            print("BANANAS V5 | Pan Quality:", CurrentQuality)
            LastQuality = CurrentQuality
        end
    end
end)
-- BANANAS V5 | QUALITY DETECTOR

local QualityLabel = PlayerGui
    :WaitForChild("ToolUI")
    :WaitForChild("FillingPan")
    :WaitForChild("Quality")

local WasActive = false
local LastQualityValue = nil

task.spawn(function()
    while task.wait(0.2) do
        local CurrentText = QualityLabel.Text
        local NumberText = string.match(CurrentText, "(%d+%.?%d*)%s*%%")
        local QualityValue = tonumber(NumberText)

        if QualityValue ~= nil then

            if QualityValue > 0 then
                WasActive = true
            end

            if QualityValue ~= LastQualityValue then
                print("BANANAS V5 | Pan Quality:", QualityValue .. "%")
                LastQualityValue = QualityValue
            end

            if QualityValue == 0 and WasActive then
                print("BANANAS V5 | Shake selesai!")

                WasActive = false
            end
        end
    end
end)

--==================================================
-- BANANAS V5 | SET DIG & SET SHAKE
--==================================================

local DigPosition = nil
local ShakePosition = nil

local SetDigButton = Button(
    Main,
    "SET DIG",
    UDim2.fromOffset(10, 315),
    UDim2.fromOffset(125, 28),
    Color3.fromRGB(0, 105, 175)
)

local SetShakeButton = Button(
    Main,
    "SET SHAKE",
    UDim2.fromOffset(150, 315),
    UDim2.fromOffset(125, 28),
    Color3.fromRGB(105, 75, 180)
)

SetDigButton.MouseButton1Click:Connect(function()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Status.Text = "Character not found"
        return
    end

    DigPosition = Root.Position

    Status.Text = "Dig position saved!"

    print("BANANAS V5 | Dig Position:", DigPosition)
end)

SetShakeButton.MouseButton1Click:Connect(function()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Status.Text = "Character not found"
        return
    end

    ShakePosition = Root.Position

    Status.Text = "Shake position saved!"

    print("BANANAS V5 | Shake Position:", ShakePosition)
end)
