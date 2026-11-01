local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local toolName = "Pharaoh's Pan"

local function findPan()
    return (player.Character and player.Character:FindFirstChild(toolName))
        or player.Backpack:FindFirstChild(toolName)
end

local function scan()
    local pan = findPan()

    if not pan then
        warn("Pharaoh's Pan tidak ditemukan")
        return
    end

    print("=== BANANAS AUTO DETECTION ===")
    print("Pan ditemukan:", pan.Name)

    for _, obj in ipairs(pan:GetDescendants()) do
        if obj:IsA("ValueBase") then
            print(obj.Name, obj.Value)
        end
    end

    for name, value in pairs(pan:GetAttributes()) do
        print("Attribute:", name, value)
    end
end

scan()
