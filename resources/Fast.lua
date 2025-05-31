local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local workspace = workspace
local Player = Players.LocalPlayer

local function SafeWaitForChild(parent, childName)
    local success, result = pcall(function()
        return parent:WaitForChild(childName)
    end)
    if not success or not result then
        warn("Failed to find child: "..childName)
    end
    return result
end

local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
local Net = SafeWaitForChild(Modules, "Net")

local Enemies = SafeWaitForChild(workspace, "Enemies")
local Characters = SafeWaitForChild(workspace, "Characters")

local Settings = {
    AutoClick = true,
    ClickDelay = 0,
}

local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

local function IsAlive(character)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function ProcessEnemies(OthersEnemies, Folder)
    local BasePart = nil
    for _, Enemy in pairs(Folder:GetChildren()) do
        local Head = Enemy:FindFirstChild("Head")
        if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < 100 then
            if Enemy ~= Player.Character then
                table.insert(OthersEnemies, {Enemy, Head})
                BasePart = Head
            end
        end
    end
    return BasePart
end

local function Attack(BasePart, OthersEnemies)
    if not BasePart or #OthersEnemies == 0 then return end
    RegisterAttack:FireServer(Settings.ClickDelay or 0)
    RegisterHit:FireServer(BasePart, OthersEnemies)
end

local function AttackNearest()
    local OthersEnemies = {}
    local Part1 = ProcessEnemies(OthersEnemies, Enemies)
    local Part2 = ProcessEnemies(OthersEnemies, Characters)
    if #OthersEnemies > 0 then
        Attack(Part1 or Part2, OthersEnemies)
    end
end

local function BladeHits()
    local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
    if Equipped and Equipped.ToolTip ~= "Gun" then
        AttackNearest()
    end
end

BladeHits()
