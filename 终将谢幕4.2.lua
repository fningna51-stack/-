--脚本是生命 认真看待
if getgenv().SkinHubLoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Skin HUB v4.1",
        Text = "请勿重复执行",
        Duration = 3,
    })
    return
end
getgenv().SkinHubLoaded = true
local __SkinHubLoadStart = tick()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ForceCheckbox = true

local Options = Library.Options
local Toggles = Library.Toggles

local L = {} :: any

function L.notify(text, time)
    Library:Notify(text, time or 2)
end

local function findPath(root, ...)
    local cur = root
    local names = {...}
    for i = 1, #names do
        local name = names[i]
        if cur then
            cur = cur:FindFirstChild(name)
        else
            cur = nil
        end
        if not cur then
            return nil
        end
    end
    return cur
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local DataPing = Stats.Network.ServerStatsItem["Data Ping"]
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

function L.createFloatingButton(guiName, text, pos, textSize, onClick)
    local sg = Instance.new("ScreenGui")
    sg.Name = guiName
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = pos
    btn.BackgroundColor3 = Library.Scheme.MainColor
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = textSize
    btn.Font = Enum.Font.GothamBold
    btn.Parent = sg
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Library.Scheme.AccentColor
    stroke.Thickness = 2.5
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn
    local dragging = false
    local moved = false
    local dragStart, startPos
    local conns = {}
    table.insert(conns, btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = btn.Position
        end
    end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            if (input.Position - dragStart).Magnitude > 4 then moved = true end
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    table.insert(conns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    table.insert(conns, sg.Destroying:Connect(function()
        for _, c in conns do pcall(function() c:Disconnect() end) end
    end))
    btn.MouseButton1Click:Connect(function()
        if moved then return end
        onClick()
    end)
    return sg, btn
end

local tick_ = os.clock
local osClock = os.clock
local mathFloor = math.floor
local mathCeil = math.ceil
local mathAbs = math.abs
local mathMin = math.min
local mathMax = math.max
local mathHuge = math.huge
local mathSqrt = math.sqrt
local mathRad = math.rad
local mathClamp = math.clamp
local v3new = Vector3.new
local v2new = Vector2.new
local c3rgb = Color3.fromRGB
local cfNew = CFrame.new
local strFormat = string.format

L.GUN_NAME_SET = {
    ["Musket"] = true, ["Carbine"] = true, ["Rifle"] = true, ["Pistol"] = true,
    ["Blunderbuss"] = true, ["Air Rifle"] = true, ["Horse Artillery Pistol"] = true,
    ["Nock Gun"] = true, ["Navy Pistol"] = true, ["Brass Pistol"] = true,
    ["Double Barrel Pistol"] = true, ["Flintlock Pistol"] = true,
    ["Model 29"] = true, ["Old Blunderbuss"] = true, ["Needle Gun"] = true,
    ["Shotgun"] = true, ["Bolt Rifle"] = true, ["Officer Pistol"] = true,
    ["Heavy Pistol"] = true, ["Light Dragoon Pistol"] = true,
}

L.WEAPON_SPEED_MAP = {
    ["Musket"] = 1650, ["Rifle"] = 1800, ["Baker Rifle"] = 1750,
    ["Jäger Rifle"] = 1750, ["Ferguson Rifle"] = 1700, ["Carbine"] = 1550,
    ["Musketoon"] = 1500, ["Air Rifle"] = 1300, ["Needle Gun"] = 1600,
    ["Bolt Rifle"] = 1700, ["Pistol"] = 900, ["Flintlock Pistol"] = 880,
    ["Navy Pistol"] = 920, ["Brass Pistol"] = 890, ["Officer Pistol"] = 950,
    ["Heavy Pistol"] = 900, ["Light Dragoon Pistol"] = 910,
    ["Horse Artillery Pistol"] = 930, ["Double Barrel Pistol"] = 900,
    ["Colt"] = 950, ["Duckfoot Pistol"] = 850, ["Howdah Pistol"] = 880,
    ["Blunderbuss"] = 650, ["Old Blunderbuss"] = 630, ["Nock Gun"] = 680,
    ["Shotgun"] = 620,
}

function L.sharedIsGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local animFolder = tool:FindFirstChild("Animations")
    if not animFolder then return false end
    return animFolder:FindFirstChild("Aim") ~= nil or animFolder:FindFirstChild("Aiming") ~= nil
end

function L.sharedGetShotsLoaded(tool)
    if not tool then return 0 end
    local s = tool:FindFirstChild("ShotsLoaded")
    if s and (s:IsA("IntValue") or s:IsA("NumberValue")) then return s.Value end
    local wsPlayers = workspace:FindFirstChild("Players")
    if wsPlayers then
        local folder = wsPlayers:FindFirstChild(LocalPlayer.Name)
        if folder then
            local toolFolder = folder:FindFirstChild(tool.Name)
            if toolFolder then
                local shots = toolFolder:FindFirstChild("ShotsLoaded")
                if shots and (shots:IsA("IntValue") or shots:IsA("NumberValue")) then return shots.Value end
            end
        end
    end
    return 0
end

function L.sharedGetRemote(tool)
    if not tool then return nil end
    local remote = tool:FindFirstChild("RemoteEvent")
    if remote then return remote end
    local wsPlayers = workspace:FindFirstChild("Players")
    if wsPlayers then
        local folder = wsPlayers:FindFirstChild(LocalPlayer.Name)
        if folder then
            local toolFolder = folder:FindFirstChild(tool.Name)
            if toolFolder then
                return toolFolder:FindFirstChild("RemoteEvent")
            end
        end
    end
    return nil
end

function L.getHeldToolRemote()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    for _, tool in char:GetChildren() do
        if tool:IsA("Tool") then
            local remote = tool:FindFirstChild("RemoteEvent")
            if remote then return remote, tool end
        end
    end
    return nil, nil
end

function L.sharedGetCurrentBulletSpeed()
    local char = LocalPlayer.Character
    if not char then return 900 end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 900 end
    local name = tool.Name
    local speed = L.WEAPON_SPEED_MAP[name]
    if speed then return speed end
    local lower = name:lower()
    if lower:find("rifle") or lower:find("musket") or lower:find("carbine")
       or lower:find("needle") or lower:find("bolt") or lower:find("jäger")
       or lower:find("ferguson") or lower:find("musketoon") then
        return 1650
    elseif lower:find("pistol") or lower:find("colt") or lower:find("revolver")
           or lower:find("horse") or lower:find("double") then
        return 900
    elseif lower:find("blunderbuss") or lower:find("nock") or lower:find("shotgun") then
        return 650
    else
        return 900
    end
end

function L.sharedGetPing()
    local ok, ping = pcall(function()
        return DataPing:GetValue()
    end)
    if ok and ping then return ping end
    return 0
end

L._charAddedHandlers = {}
LocalPlayer.CharacterAdded:Connect(function(char)
    local handlers = L._charAddedHandlers
    for i = 1, #handlers do
        local fn = handlers[i]
        if fn then
            local ok, err = pcall(fn, char)
            if not ok then warn("[SkinHub] CharacterAdded handler error: " .. tostring(err)) end
        end
    end
end)

function L.onCharacterAdded(fn)
    table.insert(L._charAddedHandlers, fn)
    return function()
        for i = #L._charAddedHandlers, 1, -1 do
            if L._charAddedHandlers[i] == fn then
                table.remove(L._charAddedHandlers, i)
                break
            end
        end
    end
end

L.ZombieWatch = {
    _models = {},
    _addedSubs = {},
    _started = false,
}

local ZOMBIE_FOLDER_NAMES = { "Zombies", "Camera" }

function L.ZombieWatch.start()
    if L.ZombieWatch._started then return end
    L.ZombieWatch._started = true

    local addedSubs = L.ZombieWatch._addedSubs
    local function trackModel(m)
        if m:IsA("Model") and not L.ZombieWatch._models[m] then
            L.ZombieWatch._models[m] = true
            for _, fn in addedSubs do
                task.spawn(fn, m)
            end
        end
    end

    local function hookFolder(folder)
        if not folder or folder:GetAttribute("SkinHubZombieWatch") then return end
        folder:SetAttribute("SkinHubZombieWatch", true)
        folder.ChildAdded:Connect(function(child)
            task.defer(trackModel, child)
        end)
        folder.ChildRemoved:Connect(function(child)
            L.ZombieWatch._models[child] = nil
        end)
        for _, child in folder:GetChildren() do
            task.spawn(trackModel, child)
        end
    end

    local function hookAll()
        for _, name in ZOMBIE_FOLDER_NAMES do
            hookFolder(workspace:FindFirstChild(name))
        end
    end
    hookAll()
    workspace.ChildAdded:Connect(function(child)
        for _, name in ZOMBIE_FOLDER_NAMES do
            if child.Name == name then
                task.defer(hookFolder, child)
            end
        end
    end)
end

function L.ZombieWatch.getAll()
    local out = {}
    for m in L.ZombieWatch._models do
        if m.Parent then
            out[#out + 1] = m
        else
            L.ZombieWatch._models[m] = nil
        end
    end
    return out
end

function L.ZombieWatch.onAdded(fn)
    table.insert(L.ZombieWatch._addedSubs, fn)
    return function()
        local i = table.find(L.ZombieWatch._addedSubs, fn)
        if i then table.remove(L.ZombieWatch._addedSubs, i) end
    end
end

function L.ZombieWatch.forEach(fn)
    for _, m in L.ZombieWatch.getAll() do
        pcall(fn, m)
    end
end

local SkinHubLogo = "fish"
pcall(function()
    local ImageManager = Library.ImageManager
    if not ImageManager then return end
    if not ImageManager.GetAsset("SkinHubLogo") then
        ImageManager.AddAsset(
            "SkinHubLogo",
            0,
            "https://raw.githubusercontent.com/Zephyrastic/sepweqeq/main/UI_image.png"
        )
    end
    SkinHubLogo = ImageManager.GetAsset("SkinHubLogo") or SkinHubLogo
end)

Library.Scheme = {
    BackgroundColor = Color3.new(0, 0, 0),
    MainColor = Color3.fromRGB(20, 50, 90),
    AccentColor = Color3.fromRGB(80, 200, 255),
    OutlineColor = Color3.fromRGB(100, 180, 255),
    FontColor = Color3.new(1, 1, 1),
    Font = Font.fromEnum(Enum.Font.Code),
    RedColor = Color3.fromRGB(255, 80, 80),
    DestructiveColor = Color3.fromRGB(220, 38, 38),
    DarkColor = Color3.new(0, 0, 0),
    WhiteColor = Color3.new(1, 1, 1),
    BackgroundImage = "",
}

local Window = Library:CreateWindow({
    Title = "Skin HUB v4.1",
    Footer = "Created by Liuye 柳",
    NotifySide = "Right",
    ShowCustomCursor = true,
    CornerRadius = 6,
    TabButtonsStyle = {
        Gap = 6,
        Padding = 6,
        CornerRadius = 6,
        Indicator = true,
        IndicatorWidth = 2,
        IndicatorHeight = 20,
    },
    Icon = SkinHubLogo,
    IconSize = UDim2.fromOffset(44, 44),
    Animations = {
        ToggleWindow = false,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true
    },
    TabTransitionTime = 0.22,
    TabSwipeOffset = 26,
    TabSwipeFrom = "Auto"
})

Window:SetBackgroundImage("https://chaton-images.s3.us-east-2.amazonaws.com/6nS2f4fBrUQJLAEGQlJwNB7ZI6uqZFOawHnD9DIyMzbY4g5DuDksrkhX8ioIPRrO_1826x1200x657016.jpeg")

Library.IsMobile = true

for _, child in Library.Floats:GetChildren() do
    if child:IsA("TextButton") then
        if child.Text == "Toggle" then
            child.Text = "Skin 4.1"
            child.TextColor3 = Color3.new(1, 1, 1)
            child.TextSize = 14
            child.Font = Enum.Font.GothamBold
            child.Size = UDim2.new(0, 55, 0, 55)
            child.Position = UDim2.new(0.02, 0, 0.5, -120)
            child.AnchorPoint = Vector2.new(0, 0.5)
            child.BackgroundTransparency = 1

            local corner = child:FindFirstChild("UICorner")
            if not corner then
                corner = Instance.new("UICorner")
                corner.Parent = child
            end
            corner.CornerRadius = UDim.new(1, 0)

            local gradient = child:FindFirstChild("UIGradient")
            if gradient then gradient:Destroy() end

            local strokeOuter = child:FindFirstChild("StrokeOuter")
            if not strokeOuter then
                strokeOuter = Instance.new("UIStroke")
                strokeOuter.Name = "StrokeOuter"
                strokeOuter.Parent = child
            end
            strokeOuter.Thickness = 4
            strokeOuter.Transparency = 0.2
            strokeOuter.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local strokeInner = child:FindFirstChild("StrokeInner")
            if not strokeInner then
                strokeInner = Instance.new("UIStroke")
                strokeInner.Name = "StrokeInner"
                strokeInner.Parent = child
            end
            strokeInner.Thickness = 2
            strokeInner.Transparency = 0.0
            strokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            child.TextStrokeColor3 = Color3.fromRGB(30, 60, 100)
            child.TextStrokeTransparency = 0.4

            task.spawn(function()
                while child and child.Parent do
                    local hue = (osClock() % 6) / 6
                    local colorOuter = Color3.fromHSV(hue, 0.8, 1)
                    local colorInner = Color3.fromHSV(hue, 0.5, 1)
                    strokeOuter.Color = colorOuter
                    strokeInner.Color = colorInner
                    task.wait(0.05)
                end
            end)
        end

        if child.Text == "Lock" then
            child.Visible = false
        end
    end
end

local InterfaceLanguage = "中文"
local EnglishText = {
    ["Skin HUB v4.1"] = "Skin HUB v4.1",
    ["柳叶制作"] = "Created by Liuye",
    ["主要与杀戮"] = "Main & Combat",
    ["其他与透视"] = "Other & ESP",
    ["动画包"] = "Animation Pack",
    ["其它动画"] = "Other Animations",
    ["自动与PVP"] = "Automation & PvP",
    ["职业功能"] = "Class Features",
    ["设置"] = "Settings",
    ["菜单"] = "Menu",
    ["卸载脚本"] = "Unload Script",
    ["菜单快捷键"] = "Menu Keybind",
    ["主要功能"] = "Main Features",
    ["杀戮光环"] = "Kill Aura",
    ["僵尸透视"] = "Zombie ESP",
    ["玩家透视"] = "Player ESP",
    ["其他功能"] = "Other Features",
    ["防护功能"] = "Protection",
    ["本地玩家"] = "Local Player",
    ["主页"] = "Home",
    ["用户"] = "User",
    ["会话"] = "Session",
    ["复制用户名"] = "Copy Username",
    ["复制个人资料链接"] = "Copy Profile Link",
    ["重新加入服务器"] = "Rejoin Server",
    ["复制 Job ID"] = "Copy Job ID",
    ["目标选择"] = "Target",
    ["攻击设置"] = "Settings",
    ["命中特效"] = "Effects",
    ["FOV 设置"] = "FOV Settings",
    ["获取"] = "Get Items",
    ["娱乐功能"] = "Fun Features",
    ["杂项"] = "Misc",
    ["杂项功能"] = "Misc Features",
    ["飞行功能"] = "Flight",
    ["打开遁地快捷栏"] = "Open Underground Shortcut Bar",
    ["飞行-无相机锁定"] = "Fly - No Camera Lock",
    ["飞行-优化"] = "Fly - Optimized",
    ["飞行-传送"] = "Fly - Teleport",
    ["飞行-传送 快捷键"] = "Fly - Teleport Keybind",
    ["飞行速度"] = "Fly Speed",
    ["飞行-动画"] = "Fly - Animation",
    ["自动功能"] = "Automation",
    ["攻击数量"] = "Attack Count",
    ["攻击角度"] = "Attack Angle",
    ["显示攻击范围"] = "Show Attack Range",
    ["智能光环（卡伤检测）"] = "Smart Aura (Damage Detection)",
    ["检测内环僵尸2秒未击杀则自动关闭光环，探测击杀后自动恢复（仅手持斧头/稿子/战壕铲生效）"] = "Auto-disable aura if zombie not killed within 2s in inner ring, auto-resume after probe kill (only works with Axe/Pickaxe/Shovel)",
    ["开启后显示攻击范围可视化"] = "Show attack range visualization",
    ["静默自瞄"] = "Silent Aim",
    ["医生"] = "Doctor",
    ["音乐家"] = "Musician",
    ["自动演奏"] = "Auto Fife",
    ["牧师"] = "Chaplain",
    ["语言"] = "Language",
    ["飞行"] = "Fly",
    ["飞行穿墙"] = "Fly Noclip",
    ["WASD移动，E上升，Q下降。"] = "WASD = move, E to rise, Q to descend.",
    ["飞行开启时可用。关闭时会恢复碰撞。"] = "Available while Fly is enabled. Disabling restores collisions.",
    ["请先开启飞行。"] = "Enable Fly first.",
    ["PVP 功能"] = "PvP Features",
    ["工兵"] = "Engineer",
    ["军官 线列 水手"] = "Officer, Line Infantry & Sailor",
    ["自动挖雪"] = "Auto Dig Snow",
    ["自动收集"] = "Auto Collect",
    ["自动砸砖墙"] = "Auto Break Brick Walls",
    ["自动打酒桶"] = "Auto Attack Barrels",
    ["自动打威斯特敏障碍"] = "Auto Attack Westminster Barricades",
    ["自动打莱比锡木板"] = "Auto Attack Leipzig Boards",
    ["自动打哥本哈根锁"] = "Auto Attack Copenhagen Locks",
    ["自动装填大炮"] = "Auto Load Cannon",
    ["莱比锡自动拉铃"] = "Auto Ring Leipzig Bell",
    ["自动打伦敦四块木板"] = "Auto Attack London Boards",
    ["自动打绷带"] = "Auto Use Bandage",
    ["自动拿怀表"] = "Auto Get Pocket Watch",
    ["自动抢旗杆"] = "Auto Capture Flagpole",
    ["自动攻击门"] = "Auto Attack Doors",
    ["自动找医生"] = "Auto Find Doctor",
    ["找医生血量阈值 (%)"] = "Doctor Health Threshold (%)",
    ["自动求救"] = "Auto Call for Help",
    ["自动开门"] = "Auto Open Doors",
    ["波次数"] = "Wave Count",
    ["跳过 N 波"] = "Skip N Waves",
    ["删除帽子"] = "Remove Hats",
    ["删除上衣"] = "Remove Shirts",
    ["删除裤子"] = "Remove Pants",
    ["一键删除以上全部"] = "Remove All Above",
    ["移除马车模型"] = "Remove Carriage Model",
    ["开启自瞄"] = "Enable Aimbot",
    ["瞄准部位"] = "Aim Part",
    ["瞄准大小"] = "Aim Size",
    ["队伍检测"] = "Team Check",
    ["墙体检测"] = "Wall Check",
    ["子弹预判"] = "Bullet Prediction",
    ["自动射击"] = "Auto Shoot",
    ["预判射击"] = "Prediction Shot",
    ["强制装备武器"] = "Force Equip Weapon",
    ["替换玩家名字"] = "Replace Player Name",
    ["打开甩飞快捷栏"] = "Open Fly-Away Hotbar",
    ["飞行-传送 开关"] = "Fly - Teleport Toggle",
    ["自由视角传送"] = "Freecam TP",
    ["自由视角"] = "Freecam",
    ["自由视角传送 快捷键"] = "Freecam TP Keybind",
    ["自由视角 开关"] = "Freecam Toggle",
    ["视角速度"] = "Freecam Speed",
    ["自由视角锚定角色，原生视角跟随鼠标/触摸"] = "Anchors character, native mouse/touch camera look",
    ["传送到视角"] = "TP to Camera",
    ["将角色传送到当前视角位置"] = "Teleport character to camera position",
    ["保存位置"] = "Save Point",
    ["保存当前视角或位置"] = "Save current camera/position",
    ["存档点"] = "Saved Points",
    ["选择已保存的位置"] = "Select a saved point",
    ["传送到存档点"] = "TP to Saved Point",
    ["删除存档点"] = "Delete Saved Point",
    ["清空存档点"] = "Clear Saved Points",
    ["WASD/摇杆移动，空格/跳跃键上升，Ctrl下降。"] = "WASD/stick to move, Space/jump to rise, Ctrl to descend.",
    ["语言 / Language"] = "Language",
    ["杀戮光环（近战）"] = "Kill Aura (Melee)",
    ["预判传送至敌方身后"] = "Teleport Above Enemy",
    ["骑马舞"] = "Gangnam Style",
    ["布吕歇尔"] = "Blücher",
    ["吃东西"] = "Eating",
    ["睡着了"] = "Sleeping",
    ["无头士兵"] = "Headless Soldier",
    ["十字架"] = "Cross",
    ["骨折"] = "Broken Bone",
    ["仙人背手"] = "Hands Behind Back",
    ["突进肘击"] = "Dash Shove",
    ["被山伯乐啃"] = "Being Eaten",
    ["扒船"] = "Climbing Boat",
    ["推炮车1"] = "Push Cannon Cart 1",
    ["推炮车2"] = "Push Cannon Cart 2",
    ["神秘举东西"] = "Mysterious Lift",
    ["转枪"] = "Gun Spin",
    ["推大炮1"] = "Push Cannon 1",
    ["开心舞蹈"] = "Happy Dance",
    ["疯子"] = "Maniac",
    ["趴下"] = "Prone",
    ["僵尸"] = "Zombie",
    ["被抓走"] = "Being Grabbed",
    ["爬绳子"] = "Climb Rope",
    ["翻滚"] = "Roll",
    ["打开隐身快捷栏"] = "Open Invisible Hotbar",
    ["拉大炮2"] = "Pull Cannon 2",
    ["自动换弹"] = "Auto Reload",
    ["换弹完成后自动重新装备武器"] = "Re-equip Weapon After Reload",
    ["防封"] = "AntiBan",
    ["自动跳刀"] = "Auto Jump Stab",
    ["自动冲锋"] = "Auto Charge",
    ["自动黑刀"] = "Auto Knife Bombers",
    ["自动黑枪"] = "Auto Shoot Bombers",
    ["无需装备武器"] = "No Equip Required",
    ["显示黑枪半径"] = "Show Black Gun Radius",
    ["检测范围"] = "Detection Range",
    ["自瞄自爆"] = "Aim Bomber",
    ["自瞄胸甲骑兵"] = "Aim Cuirassier",
    ["自瞄红眼"] = "Aim Runner",
    ["自瞄斧头僵尸"] = "Aim Zapper",
    ["自瞄点火者"] = "Aim Igniter",
    ["自瞄普通僵尸"] = "Aim Normal Zombie",
    ["自瞄无头骑士"] = "Aim Headless",
    ["瞄准距离"] = "Aim Distance",
    ["无后坐力"] = "No Recoil",
    ["启用 FOV"] = "Enable FOV",
    ["显示 FOV 圆圈"] = "Show FOV Circle",
    ["FOV 大小"] = "FOV Size",
    ["静默自动修建筑"] = "Silent Auto Repair",
    ["修复目标模式"] = "Repair Target Mode",
    ["瞄准建筑"] = "Aimed Structure",
    ["最近建筑"] = "Closest Structure",
    ["最低生命值建筑"] = "Lowest Health Structure",
    ["静默格挡"] = "Silent Block",
    ["肘击"] = "Shove Aura",
    ["肘击距离"] = "Shove Range",
    ["肘击数量"] = "Shove Count",
    ["肘击间隔"] = "Shove Delay",
    ["肘击范围扩大"] = "Shove Range Expander",
    ["肘击扩大距离"] = "Shove Expander Range",
    ["肘击扩大数量"] = "Shove Expander Count",
    ["攻击武器回收"] = "Attack Weapon Re-equip",
    ["自动治疗受伤玩家"] = "Auto Heal Injured Players",
    ["治疗阈值 (%)"] = "Heal Threshold (%)",
    ["自动拾取纱布"] = "Auto Collect Bandages",
    ["自动祝福感染玩家"] = "Auto Bless Infected Players",
    ["祝福阈值 (%)"] = "Blessing Threshold (%)",
    ["美化"] = "Beautify",
    ["装扮替换"] = "Costume change",
    ["输入要复制装扮的玩家名"] = "Enter player name to copy costume",
    ["输入名字"] = "Enter a first name",
    ["替换装扮"] = "Costume Change",
    ["替换玩家外观"] = "Replace Player Costume",
    ["修改用户名"] = "Change Username",
    ["输入要改为的用户名"] = "Enter new username",
    ["输入用户名"] = "Enter Username",
    ["修改名字"] = "Change Name",
    ["仅修改显示名字"] = "Change Display Name Only",
    ["修改法郎数量"] = "Modify Francs",
    ["法郎数量"] = "Franc Amount",
    ["更改外观"] = "Change Appearance",
    ["樱花天空(无法恢复)"] = "Cherry Blossom Sky (Irreversible)",
    ["加入"] = "Join in",
    ["玩家用户名"] = "Player User Name",
    ["服务器加入"] = "Player Username Server Join",
    ["投票显示"] = "Voting display",
    ["拉大门"] = "Pull Main Gate",
    ["残血"] = "Low Health",
    ["山伯乐"] = "Shambler",
    ["红眼"] = "Runner",
    ["胸甲骑兵1"] = "Cuirassier 1",
    ["胸甲僵尸2"] = "Cuirassier 2",
    ["胸甲骑兵冲锋快捷栏"] = "Cuirassier Charge Hotbar",
    ["提灯人"] = "Igniter",
    ["斧头僵尸"] = "Zapper",
    ["斧头僵尸劈砍快捷栏"] = "Zapper Slash Hotbar",
    ["自爆"] = "Bomber",
    ["爬尸"] = "Crawler",
    ["重剑冲锋"] = "Heavy Charge",
    ["滑膛枪冲锋"] = "Musket Charge",
    ["冲锋"] = "Charge",
    ["拳击手"] = "Boxer",
    ["固定按钮"] = "Lock Buttons",
    ["显示拳击 UI"] = "Show Boxer UI",
    ["透视斧头僵尸"] = "Zapper ESP",
    ["透视红眼"] = "Runner ESP",
    ["透视胸甲骑兵"] = "Cuirassier ESP",
    ["透视自爆"] = "Bomber ESP",
    ["透视提灯人"] = "Igniter ESP",
    ["透视山伯乐"] = "Shambler ESP",
    ["透视无头士兵"] = "Headless soldier ESP",
    ["透视无头骑士"] = "Headless Horseman ESP",
    ["透视德古拉"] = "Dracula ESP",
    ["启用玩家透视"] = "Enable Player ESP",
    ["显示玩家名称"] = "Show Player Names",
    ["显示玩家血量"] = "Show Player Health",
    ["显示玩家感染值"] = "Show Player Infection",
    ["显示玩家职业"] = "Show Player Class",
    ["红眼扑倒自救"] = "Runner Knockdown Escape",
    ["防骨折"] = "Anti Fracture",
    ["防抓取"] = "Anti Grab",
    ["显示受伤伤害"] = "Show Injury Damage",
    ["传送救援队友"] = "Teleport to Rescue Teammates",
    ["肘击自救"] = "Shove Self Rescue",
    ["自爆拉扯（防护）"] = "Bomber Pull Protection",
    ["拉扯范围"] = "Pull Range",
    ["获取吸血鬼刀 (Voivode)"] = "Get Vampire Knife (Voivode)",
    ["获取铁桩 (Iron Stake)"] = "Get Iron Stake",
    ["我好像有点卡顿"] = "I Seem Laggy",
    ["卡顿程度"] = "Lag Amount",
    ["旋转"] = "Spin",
    ["旋转速度"] = "Spin Speed",
    ["解除视角限制"] = "Remove Camera Limit",
    ["人体十字架"] = "Human Cross",
    ["倒立行走"] = "Walk Upside Down",
    ["大头儿子"] = "Big Heads",
    ["头部大小"] = "Head Size",
    ["头部透明度"] = "Head Transparency",
    ["自己猜🤓"] = "Guess 🤓",
    ["显示子弹数量"] = "Show Ammo Count",
    ["显示子弹轨迹"] = "Show Bullet Tracers",
    ["火炮物资透视"] = "Cannon Supplies ESP",
    ["击杀音效"] = "Kill Sound",
    ["音效音量"] = "Sound Volume",
    ["显示网络延迟"] = "Show Ping",
    ["无雾效果"] = "No Fog",
    ["移除感染红色血液"] = "Remove Infection Blood",
    ["自爆范围显示"] = "Show Bomber Range",
    ["手炮爆炸倒计时"] = "Hand Mortar Countdown",
    ["无法攻击自爆"] = "Disable Bomber Attacks",
    ["移除跳跃限制"] = "Remove Jump Limit",
    ["玩家碰撞箱显示"] = "Player Hitbox Display",
    ["启用坐标加速"] = "Enable CFrame Speed",
    ["坐标加速速度"] = "CFrame Speed",
    ["启用速度调整"] = "Enable Speed Adjustment",
    ["玩家速度"] = "Player Speed",
    ["自动转向范围"] = "Auto Face Range",
    ["自动转向"] = "Auto Face",
    ["跳过自爆僵尸"] = "Skip Bombers",
    ["控制玩家跳跃高度"] = "Control Jump Height",
    ["跳跃高度"] = "Jump Height",
    ["自动跳跃"] = "Auto Jump",
    ["自动跳跃高度"] = "Auto Jump Height",
    ["无限连跳（含防骨折）"] = "Infinite Jump (Anti Fracture)",
    ["无减速"] = "No Slowdown",
    ["移除摔伤"] = "Remove Fall Damage",
    ["显示物品栏"] = "Show Inventory",
    ["亮度提升"] = "Increase Brightness",
    ["杀戮光环模式"] = "Kill Aura Mode",
    ["攻击自爆"] = "Attack Bombers",
    ["攻击德古拉"] = "Attack Dracula",
    ["跳过正在生成的僵尸"] = "Skip Spawning Zombies",
    ["开启杀戮光环"] = "Enable Kill Aura",
    ["自动装备武器"] = "Auto Equip Weapon",
    ["攻击距离"] = "Attack Range",
    ["攻击间隔"] = "Attack Delay",
    ["移除血液粒子"] = "Removing blood particle",
    ["强制爆头"] = "Force Headshots",
    ["僵尸碰撞箱扩展"] = "Zombie Hitbox Expander",
    ["碰撞箱大小"] = "Hitbox Size",
    ["头部"] = "Head",
    ["身体"] = "Body",
    ["娱乐"] = "Entertainment",
    ["打全图门窗"] = "Destroy All Doors & Windows",
    ["信息"] = "Info",
    ["师傅：小皮"] = "Master: Xiao Pi",
    ["英文翻译：Zephy"] = "English Translation: Zephy",
    ["脚本优化：Zephy"] = "Script Optimization: Zephy",
    ["WASD移动，Space上升，LCtrl下降。"] = "WASD to move, Space to rise, LCtrl to descend.",
    ["为僵尸添加更大的命中箱"] = "Adds a larger hitbox to zombies",
    ["体验虐杀的快感"] = "Experience the thrill of the slaughter",
    ["军刀前刺动画时自动跳跃"] = "Automatically jumps during the saber thrust animation",
    ["冲锋动画（开启速度24，关闭速度16）"] = "Charge animation (speed 24 when enabled, 16 when disabled)",
    ["化身成人体十字架"] = "Transforms into a human cross",
    ["只在 FOV 范围内自瞄"] = "Only aims within the FOV range",
    ["将血迹生成位置移到僵尸脚下不可见处，不影响伤害"] = "Moves blood decal spawn point to an invisible spot under the zombie's feet, without affecting damage",
    ["山伯乐动画（待机/行走自动切换）"] = "Shambler animation (auto-switches between idle/walk)",
    ["山伯乐吃东西动画"] = "Shambler eating animation",
    ["巴黎地下墓穴自动砸砖墙"] = "Automatically breaks brick walls in the Paris Catacombs",
    ["开启/关闭杀戮光环（根据下拉框选择的模式）"] = "Enable/disable Kill Aura (mode selected via dropdown)",
    ["开启后不会射击被墙体遮挡的自爆"] = "When enabled, won't shoot bombers blocked by walls",
    ["开启后不会攻击正在生成的僵尸（减少误判）"] = "When enabled, won't attack zombies that are still spawning (reduces misfires)",
    ["开启后不会瞄准被墙体遮挡的僵尸"] = "When enabled, won't aim at zombies blocked by walls",
    ["开启后不会转向自爆"] = "When enabled, won't turn toward bombers",
    ["开启后只高亮透视敌方队伍玩家"] = "When enabled, only highlights enemy team players",
    ["开启后对玩家高亮"] = "When enabled, highlights players",
    ["开启后显示其他玩家感染值"] = "When enabled, shows other players' infection value",
    ["开启后显示攻击范围可视化（外环+内环独立变色，自转+浮动，射线跟随玩家）"] = "When enabled, visualizes attack range (outer/inner rings color independently, rotate + float, follows the player)",
    ["开启后本地修改法郎"] = "When enabled, modifies Francs locally",
    ["开启后杀戮光环会同时攻击德古拉Boss"] = "When enabled, Kill Aura will also attack the Dracula boss",
    ["开启后杀戮光环会攻击自爆僵尸"] = "When enabled, Kill Aura will attack bombers",
    ["开启后直接从背包调用枪械射击，不需要装备到手上"] = "When enabled, fires directly from inventory without equipping the weapon",
    ["开启后自瞄斧头僵尸"] = "When enabled, auto-aims at Zapper zombies",
    ["开启后自瞄普通僵尸"] = "When enabled, auto-aims at normal zombies",
    ["开启后自瞄点火者"] = "When enabled, auto-aims at Igniters",
    ["开启后自瞄红眼僵尸"] = "When enabled, auto-aims at Runner zombies",
    ["开启后自瞄胸甲骑兵"] = "When enabled, auto-aims at Cuirassiers",
    ["开启后自瞄自爆僵尸"] = "When enabled, auto-aims at Bombers",
    ["开启显示玩家用户名"] = "Enables showing player usernames",
    ["开启显示玩家血量数值"] = "Enables showing player health values",
    ["强制所有近战/刺刀攻击命中头部"] = "Forces all melee/bayonet attacks to hit the head",
    ["强制显示物品栏"] = "Forces the inventory to show",
    ["循环播放动画"] = "Loops the animation",
    ["循环播放扒船动画"] = "Loops the boat-climbing animation",
    ["循环播放指定动画"] = "Loops a specific animation",
    ["循环播放指定动画（优先级 Action4）"] = "Loops a specific animation (priority Action4)",
    ["循环播放被啃动画"] = "Loops the being-eaten animation",
    ["所有僵尸变成大头儿子"] = "Turns all zombies into Big Head Son",
    ["打开小方块快捷栏执行冲锋"] = "Opens the mini hotbar to perform a charge",
    ["打开小方块快捷栏执行劈砍"] = "Opens the mini hotbar to perform a slash",
    ["扩大肘击生效范围"] = "Expands the Shove strike's effective range",
    ["拉大门动画（待机/行走自动切换）"] = "Pull Main Gate animation (auto-switches between idle/walk)",
    ["拳击手模式（行走/待机动画 + 左右拳按钮）"] = "Boxer mode (walk/idle animation + left/right punch buttons)",
    ["拳击按钮不可拖动"] = "Boxer buttons cannot be dragged",
    ["持枪时自动锁定敌方玩家"] = "Automatically locks onto enemy players while holding a gun",
    ["持续装备近战武器"] = "Continuously keeps the melee weapon equipped",
    ["提灯人动画（待机/行走自动切换）"] = "Igniter animation (auto-switches between idle/walk)",
    ["提高场景亮度"] = "Increases scene brightness",
    ["播放0.3秒后暂停定格"] = "Plays for 0.3 seconds then pauses/freezes",
    ["播放动画"] = "Plays the animation",
    ["播放动画（20秒后自动停止）"] = "Plays the animation (auto-stops after 20 seconds)",
    ["播放动画（播放一次后自动关闭）"] = "Plays the animation (auto-turns off after playing once)",
    ["播放十字架使用动画（循环）"] = "Plays the cross-use animation (looped)",
    ["播放拿破仑背手动画（待机/行走自动切换）"] = "Plays the Napoleon hands-behind-back animation (auto-switches between idle/walk)",
    ["播放无头士兵待机/行走动画（自动切换）"] = "Plays the Headless Soldier idle/walk animation (auto-switches)",
    ["播放骑马舞动画"] = "Plays the Gangnam Style animation",
    ["播放骨折动画（第一段播完第二段循环）"] = "Plays the broken bone animation (part 1 plays once, part 2 loops)",
    ["攻击后自动卸下并重新装备武器，取消后摇"] = "Automatically unequips and re-equips the weapon after attacking, canceling the recovery animation",
    ["斧头僵尸动画（待机/行走自动切换）"] = "Zapper animation (auto-switches between idle/walk)",
    ["无"] = "None",
    ["显示/隐藏拳击按钮界面"] = "Shows/hides the boxer button UI",
    ["显示图片同意 反对的名字"] = "Shows names of those who voted yes/no",
    ["显示玩家碰撞箱"] = "Shows player hitboxes",
    ["显示自爆僵尸爆炸剩余时间"] = "Shows the remaining time before a bomber explodes",
    ["显示自爆周围的检测范围圆环"] = "Shows a ring around bombers indicating detection range",
    ["显示自瞄 FOV 范围"] = "Shows the aimbot FOV range",
    ["更改玩家肤色 面部表情"] = "Changes player skin tone and facial expression",
    ["枪械子弹打空后自动装填"] = "Automatically reloads once the gun's ammo is empty",
    ["检测自爆附近玩家的范围（圆环大小同步变化）"] = "Detection range for players near a bomber (ring size updates in sync)",
    ["每0.5秒重新触发一次循环动画 ID: 87443816703028"] = "Retriggers the looping animation every 0.5 seconds — ID: 87443816703028",
    ["每0.73秒播放一次转枪动画"] = "Plays the gun-spin animation every 0.73 seconds",
    ["每装填一发子弹后自动收回枪械再装备"] = "Automatically stows and re-equips the weapon after loading each round",
    ["滑膛枪冲锋动画（开启速度24，关闭速度16）"] = "Musket charge animation (speed 24 when enabled, 16 when disabled)",
    ["演奏笛子时自动达到 100% 准确度"] = "Automatically achieves 100% accuracy while playing the fife",
    ["爬尸动画（爬行模式）"] = "Crawler animation (crawl mode)",
    ["禁用枪械后坐力"] = "Disables gun recoil",
    ["移除减速效果（重生后需重新开启）"] = "Removes the slow effect (must be re-enabled after respawning)",
    ["移除摔落伤害（注意不防骨折）"] = "Removes fall damage (note: does not prevent broken bones)",
    ["移除雾效与大气效果，并在地图切换后自动重新应用"] = "Removes fog and atmosphere effects, and automatically re-applies after map changes",
    ["红眼动画（待机/行走自动切换）"] = "Runner animation (auto-switches between idle/walk)",
    ["布吕歇尔动作（播放完整序列后自动停止）"] = "The undying Blücher action (auto-stops after the full sequence plays)",
    ["Barry 动作"] = "Barry the Bite-Tank action",
    ["胸甲骑兵动画（待机/行走自动切换）"] = "Cuirassier animation (auto-switches between idle/walk)",
    ["能量满后自动开启冲锋"] = "Automatically starts charging once energy is full",
    ["自动修复瞄准的建筑（无需装备锤子）"] = "Automatically repairs the targeted structure (no need to equip a hammer)",
    ["自动向低血量玩家发送治疗请求"] = "Automatically sends heal requests to low-health players",
    ["自动向感染值高的玩家发送祝福"] = "Automatically sends blessings to highly-infected players",
    ["自动射击自爆僵尸"] = "Automatically shoots bombers",
    ["自动开启附近场景中的门（适用于所有地图）"] = "Automatically opens nearby doors (works on all maps)",
    ["自动拉响莱比锡钟楼铃铛"] = "Automatically rings the Leipzig bell tower",
    ["自动拾取威斯敏斯特怀表"] = "Automatically picks up the Westminster pocket watch",
    ["自动拾取威斯敏斯特旗杆"] = "Automatically picks up the Westminster flagpole",
    ["自动拾取附近的纱布补给"] = "Automatically picks up nearby bandage supplies",
    ["自动挖掘雪堆（需要铲子）"] = "Automatically digs snow piles (requires a shovel)",
    ["自动攻击伦敦狙神处四块木板"] = "Automatically attacks the four boards at London's sniper spot",
    ["自动攻击伦敦酒桶"] = "Automatically attacks London barrels",
    ["自动攻击哥本哈根门锁"] = "Automatically attacks Copenhagen door locks",
    ["自动攻击威斯特敏路障"] = "Automatically attacks Westminster barricades",
    ["自动攻击莱比锡木板"] = "Automatically attacks Leipzig boards",
    ["自动攻击附近的门"] = "Automatically attacks nearby doors",
    ["自动格挡劈砍（无需手持武器）"] = "Automatically blocks slashes (no need to hold a weapon)",
    ["自动肘击范围15格内的僵尸"] = "Automatically elbow-strikes zombies within a 15-stud range",
    ["自动装填最近的12磅炮"] = "Automatically loads the nearest 12-pounder cannon",
    ["自动触发附近的收集提示（Kaub地图）"] = "Automatically triggers nearby collection prompts (Kaub map)",
    ["自爆动画（待机/行走自动切换）"] = "Bomber animation (auto-switches between idle/walk)",
    ["血量低于75%时自动使用绷带（仅一次，低于50%重置）"] = "Automatically uses a bandage when health drops below 75% (once only, resets below 50%)",
    ["血量低于80%时自动发送语音求助"] = "Automatically sends a voice call for help when health drops below 80%",
    ["血量低于阈值（默认40%）且还在掉血时传送至医生"] = "Teleports to a doctor when health is below the threshold (default 40%) and still dropping",
    ["装死动画"] = "Play-dead animation",
    ["解除玩家视角上限"] = "Removes the player's camera pitch limit",
    ["让人物持续旋转"] = "Makes the character spin continuously",
    ["让人物看起来卡卡的"] = "Makes the character look glitchy/stuck",
    ["让玩家倒立"] = "Makes the player handstand",
    ["选择杀戮光环模式（实时切换）"] = "Selects the Kill Aura mode (switches in real time)",
    ["通过CFrame实现位移"] = "Achieves movement via CFrame",
    ["重剑冲锋动画（开启速度24，关闭速度16）"] = "Heavy sword charge animation (speed 24 when enabled, 16 when disabled)",
    ["队友靠近自爆时自动攻击"] = "Automatically attacks when a teammate is near a bomber",
    ["静止播放假残血动画，移动播放假残血走路动画"] = "Plays the fake-low-health idle animation when still, and the fake-low-health walk animation when moving",
    ["静止播放动画1，移动播放动画2"] = "Plays animation 1 when still, animation 2 when moving",
    ["静止播放动画5，移动播放动画6"] = "Plays animation 5 when still, animation 6 when moving",
    ["静止播放动画，移动播放动画"] = "Plays an idle animation when still, and a walk animation when moving",
    ["靠近设定范围自动装备武器"] = "Automatically equips the weapon within the configured range",
    ["预判传送"] = "Predictive teleport",
    ["飘落樱花花瓣 紫色天空 记住无法恢复"] = "Falling cherry blossom petals, purple sky — remember this cannot be undone",
    ["柳叶正在杀死所有人"] = "Liuye is killing everyone",
    ["你已被柳叶定住"] = "You have been frozen by Liuye",
    ["被解除定住了"] = "Unfrozen",
    ["你被柳叶指定杀死了"] = "You were designated to be killed by Liuye",
    ["柳叶召唤你"] = "Liuye summons you",
    ["请手持卡宾枪"] = "Please hold a carbine",
    ["请手持卡宾枪/稿子/斧头"] = "Please hold a Carbine/Pickaxe/Axe",
    ["自动挖雪已开启"] = "Auto Dig Snow enabled",
    ["自动挖雪已关闭"] = "Auto Dig Snow disabled",
    ["自动收集已开启"] = "Auto Collect enabled",
    ["自动收集已关闭"] = "Auto Collect disabled",
    ["自动砸砖墙已开启"] = "Auto Break Wall enabled",
    ["自动砸砖墙已关闭"] = "Auto Break Wall disabled",
    ["自动打酒桶已开启"] = "Auto Attack Barrel enabled",
    ["自动打酒桶已关闭"] = "Auto Attack Barrel disabled",
    ["自动打威斯特敏障碍已开启"] = "Auto Attack Westminster Barricade enabled",
    ["自动打威斯特敏障碍已关闭"] = "Auto Attack Westminster Barricade disabled",
    ["自动打莱比锡木板已开启"] = "Auto Attack Leipzig Board enabled",
    ["自动打莱比锡木板已关闭"] = "Auto Attack Leipzig Board disabled",
    ["自动打哥本哈根锁已开启"] = "Auto Attack Copenhagen Lock enabled",
    ["自动打哥本哈根锁已关闭"] = "Auto Attack Copenhagen Lock disabled",
    ["自动装填大炮已开启"] = "Auto Load Cannon enabled",
    ["自动装填大炮已关闭"] = "Auto Load Cannon disabled",
    ["自动拿怀表已完成"] = "Auto Get Pocket Watch complete",
    ["自动抢旗杆已完成"] = "Auto Get Flagpole complete",
    ["自动换弹已开启"] = "Auto Reload enabled",
    ["自动换弹已关闭"] = "Auto Reload disabled",
    ["自动收枪已开启"] = "Auto Stow Weapon enabled",
    ["自动收枪已关闭"] = "Auto Stow Weapon disabled",
    ["自动跳刀已开启"] = "Auto Bayonet Jump enabled",
    ["自动跳刀已关闭"] = "Auto Bayonet Jump disabled",
    ["自动冲锋已开启"] = "Auto Charge enabled",
    ["自动冲锋已关闭"] = "Auto Charge disabled",
    ["自动黑刀已开启"] = "Auto Black Blade enabled",
    ["自动黑刀已关闭"] = "Auto Black Blade disabled",
    ["自动修复已开启（静默模式）"] = "Auto Repair enabled (silent mode)",
    ["自动修复已关闭"] = "Auto Repair disabled",
    ["静默格挡已开启"] = "Silent Block enabled",
    ["静默格挡已关闭"] = "Silent Block disabled",
    ["自动治疗已开启"] = "Auto Heal enabled",
    ["自动治疗已关闭"] = "Auto Heal disabled",
    ["自动拾取纱布已开启"] = "Auto Pickup Bandage enabled",
    ["自动拾取纱布已关闭"] = "Auto Pickup Bandage disabled",
    ["自动祝福已开启"] = "Auto Bless enabled",
    ["自动祝福已关闭"] = "Auto Bless disabled",
    ["已获取吸血鬼刀"] = "Vampire Knife acquired",
    ["已获取铁桩"] = "Iron Stake acquired",
    ["🆘 传送救援已开启"] = "🆘 Teleport Rescue enabled",
    ["🆘 传送救援已关闭"] = "🆘 Teleport Rescue disabled",
    ["投票显示已开启"] = "Vote Display enabled",
    ["投票显示已关闭"] = "Vote Display disabled",
    ["错误"] = "Error",
    ["请输入目标玩家名字"] = "Please enter the target player's name",
    ["找不到该玩家"] = "Player not found",
    ["请输入新名字"] = "Please enter a new name",
    ["该用户名不存在"] = "That username does not exist",
    ["请输入玩家名"] = "Please enter a player name",
    ["请输入玩家名字"] = "Please enter a player name",
    ["杀死全部脚本用户"] = "Kill All Script Users",
    ["定住全部脚本用户"] = "Freeze All Script Users",
    ["解除定住"] = "Unfreeze All",
    ["目标玩家名"] = "Target Player Name",
    ["输入玩家名字"] = "Enter player name",
    ["杀死该脚本用户"] = "Kill Script User",
    ["TP全部脚本用户"] = "TP All Script Users",
    ["已发送"] = "Sent",
    ["发送失败"] = "Send failed",
    ["等待角色重生"] = "Waiting for respawn",
    ["找不到位置"] = "Position not found",
    ["[投票] %s 发起对 %s 的投票"] = "[Vote] %s started a vote against %s",
    ["[投票] %s %s"] = "[Vote] %s %s",
    ["显示投票同意 反对的名字"] = "Shows names of who voted Yes/No",
    ["无法获取服务器事件"] = "Failed to fetch server events",
    ["搜索中"] = "Searching",
    ["请耐心等待"] = "Please wait",
    ["正在传送至服务器..."] = "Teleporting to server...",
    ["该服务器缺少 JobId"] = "That server is missing a JobId",
    ["成功"] = "Success",
    ["未找到"] = "Not Found",
    ["账号信息"] = "Account info",
    ["在线状态"] = "Online status",
    ["版本信息"] = "Version info",
    ["视野辅助"] = "Vision aids",
    ["趣味效果"] = "Fun effects",
    ["一键操作"] = "One-click",
    ["姿势动画"] = "Pose anims",
    ["舞蹈动作"] = "Dance anims",
    ["自动挖拾"] = "Auto dig/pickup",
    ["战斗辅助"] = "Combat aid",
    ["修建近战"] = "Repair/melee",
    ["武器功能"] = "Weapon tools",
    ["自动瞄准"] = "Auto-aim",
    ["自动治疗"] = "Auto heal",
    ["自动祝福"] = "Auto bless",
    ["速度跳跃"] = "Speed/jump",
    ["外观特效"] = "Look & FX",
    ["自动攻击"] = "Auto attack",
    ["飞行控制"] = "Fly control",
    ["显示提示"] = "Display info",
    ["防坠自救"] = "Fall rescue",
    ["获取装备"] = "Get gear",
    ["界面设置"] = "UI settings",
    ["爆炸范围: 已进入爆炸范围内"] = "Bomb Range: Entered blast radius",
    ["解锁失败: 找不到ChangeClass"] = "Unlock Failed: ChangeClass not found",
    ["解锁失败: 配置错误"] = "Unlock Failed: Configuration error",
    ["已解锁替换"] = "Unlocked Replacement",
    ["同意"] = "Yes",
    ["反对"] = "No",
    ["找不到玩家 "] = "Could not find player ",
    ["玩家 "] = "Player ",
    [" 不在任何公开服务器中"] = " is not in any public server",
    ["骨折可移动"] = "Fracture Mobility",
    ["启用静默"] = "Enable Silent",
    ["冲"] = "Charge",
    ["冲锋中"] = "Charging",
    ["劈砍"] = "Slash",
    ["劈砍中"] = "Slashing",
    ["右拳"] = "Right Punch",
    ["左拳"] = "Left Punch",
    ["军官"] = "Officer",
    ["线列"] = "Line Infantry",
    ["水手"] = "Sailor",
    ["乐手"] = "Musician",
    ["枪骑兵"] = "Lancer",
    ["炮兵"] = "Artillerist",
    ["未知"] = "Unknown",
    ["被扑"] = "Pinned",
    ["请等待复活"] = "Please wait for respawn",
    ["这个是gay"] = "Unknown",
    ["站在这自动攻击"] = "Auto attack here",
    ["无相机锁定"] = "No Camera Lock",
    ["销毁UI"] = "Destroy UI",
    ["飞行开"] = "Fly On",
    ["无头骑士"] = "Headless Knight",
    ["德古拉"] = "Dracula",
    ["法兰西第一掷弹兵"] = "French 1st Grenadiers",
    ["线列步兵"] = "Line Infantry",
    ["老敬卫"] = "Old Guard",
    ["英国冷溪近卫军"] = "British Coldstream Guards",
    ["开"] = "On",
    ["关"] = "Off",
    ["开启"] = "On",
    ["关闭"] = "Off",
    ["碰"] = "Touch",
    ["拆"] = "Dismantle",
    ["碰UI"] = "TouchUI",
    ["中文"] = "Chinese",
    ["会话时间"] = "Session Time",
    ["执行器"] = "Executor",
    ["用户ID"] = "User ID",
    ["用户名"] = "Username",
    ["游戏"] = "Game",
    ["输入玩家名"] = "Enter player name",
    ["子弹: 0"] = "Bullets: 0",
    ["子弹: "] = "Bullets: ",
    ["感染: 0%"] = "Infection: 0%",
    ["延迟: -- ms"] = "Ping: -- ms",
    ["延迟: "] = "Ping: ",
    ["延迟"] = "Ping",
    ["Created by Liuye 柳"] = "Created by Liuye",
}

local OriginalText = setmetatable({}, { __mode = "k" })
local EnglishFragments = {
    ["开启后"] = "When enabled, ", ["自动"] = "automatically ", ["显示"] = "show ",
    ["播放动画"] = "play the animation", ["循环播放"] = "loop the animation", ["僵尸"] = "zombies",
    ["玩家"] = "players", ["攻击"] = "attack", ["范围"] = "range", ["武器"] = "weapon",
    ["开启"] = "enable", ["关闭"] = "disable", ["移除"] = "remove", ["提高"] = "increase",
    ["血量"] = "health", ["头部"] = "head", ["队伍"] = "team", ["墙体"] = "walls",
    ["自爆"] = "bombers", ["附近"] = "nearby", ["自动装备"] = "automatically equip",
    ["无需"] = "without needing", ["手持"] = "holding", ["需要"] = "requires",
    ["重生后需重新开启"] = "must be re-enabled after respawning", ["仅一次"] = "once only",
    ["默认"] = "default", ["速度"] = "speed", ["高度"] = "height", ["大小"] = "size",
    ["透明度"] = "transparency", ["伤害"] = "damage", ["感染值"] = "infection value",
    ["高亮"] = "highlight", ["快捷栏"] = "hotbar", ["按钮"] = "buttons",
    ["（"] = "(", ["）"] = ")", ["，"] = ", ", ["。"] = ".",
}

local function TranslateText(text)
    if InterfaceLanguage ~= "English" then return text end
    if EnglishText[text] then return EnglishText[text] end
    if type(text) ~= "string" then return text end
    local b = text:byte(1)
    if b and b < 128 then return text end

    local translated = text
    for chinese, english in EnglishFragments do
        translated = string.gsub(translated, chinese, english)
    end
    return translated
end

local function TranslateTooltip(text)
    return TranslateText(text)
end

do
    local lp = LocalPlayer

    local POLL_URL = "https://qiu-rong-da-di.onrender.com/api/discord-messages"
    local pollThread = nil
    local lastChecksum = ""
    local processedCmds = {}


    local function executeCommand(cmd)
        if cmd == "KILL_ALL" then
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = 0
                    L.notify(TranslateText("柳叶正在杀死所有人"), 2)
                end
            end

        elseif cmd == "FREEZE_ALL" then
            local char = lp.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    root.Anchored = true
                    hum.PlatformStand = true
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                    L.notify(TranslateText("你已被柳叶定住"), 2)
                end
            end

        elseif cmd == "UNFREEZE_ALL" then
            local char = lp.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    root.Anchored = false
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    L.notify(TranslateText("被解除定住了"), 2)
                end
            end

        elseif string.match(cmd, "^KILL_PLAYER:") then
            local targetName = string.match(cmd, "^KILL_PLAYER:(.+)")
            if not targetName then return end
            targetName = targetName:lower()
            if lp.Name:lower() == targetName then
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        hum.Health = 0
                        L.notify(TranslateText("你被柳叶指定杀死了"), 2)
                    end
                end
            end

        elseif string.match(cmd, "^TELEPORT_ALL:") then
            local coordStr = string.match(cmd, "^TELEPORT_ALL:(.+)$")
            if coordStr then
                local parts = {}
                for part in string.gmatch(coordStr, "[^,]+") do
                    table.insert(parts, part)
                end
                if #parts >= 3 then
                    local x = tonumber(parts[1])
                    local y = tonumber(parts[2])
                    local z = tonumber(parts[3])
                    if x and y and z then
                        local char = lp.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then

                                root.CFrame = cfNew(x, y + 5, z)
                                task.wait(0.1)

                                root.CFrame = cfNew(x, y, z)
                                root.AssemblyLinearVelocity = Vector3.zero
                                root.AssemblyAngularVelocity = Vector3.zero
                                L.notify(TranslateText("柳叶召唤你"), 2)
                            end
                        end
                    end
                end
            end
        end
    end


    local COMMAND_PATTERNS = {"KILL_ALL", "FREEZE_ALL", "UNFREEZE_ALL", "KILL_PLAYER:", "TELEPORT_ALL:"}
    local function containsCommand(content)
        for _, pat in COMMAND_PATTERNS do
            if string.find(content, pat, 1, true) then return true end
        end
        return false
    end

    local function pollMessages()
        local ok, raw = pcall(function()
            local response = request({
                Url = POLL_URL,
                Method = "GET",
                Headers = { ["Accept"] = "application/json" }
            })
            if response and response.StatusCode == 200 and response.Body then
                return HttpService:JSONDecode(response.Body)
            end
            return nil
        end)
        if not ok or not raw or not raw.messages then return false end

        local ids = {}
        for _, m in raw.messages do
            ids[#ids+1] = tostring(m.id)
        end
        local currentIds = {}
        for _, id in ids do currentIds[id] = true end
        for id in processedCmds do
            if not currentIds[id] then processedCmds[id] = nil end
        end
        local cs = table.concat(ids, ",")
        if cs == lastChecksum then return false end
        lastChecksum = cs

        for _, m in raw.messages do
            local content = m.content or ""
            local msgId = tostring(m.id)
            if msgId == "nil" or processedCmds[msgId] then continue end
            processedCmds[msgId] = true
            if containsCommand(content) then
                executeCommand(content)
            end
        end
        return true
    end


    local function startPolling()
        if pollThread then return end
        if type(request) ~= "function" then
            warn("[SkinHub] request is unavailable, command receiver disabled")
            return
        end
        local pollInterval = 1
        pollThread = task.spawn(function()
            while true do
                task.wait(pollInterval)
                local ok, changed = pcall(pollMessages)
                if not ok then
                    pollInterval = mathMin(pollInterval * 2, 8)
                else
                    if changed then
                        pollInterval = 1
                    else
                        pollInterval = mathMin(pollInterval * 2, 8)
                    end
                end
            end
        end)
    end

    local function stopPolling()
        if pollThread then
            task.cancel(pollThread)
            pollThread = nil
        end
    end

    startPolling()

    if Library and Library.OnUnload then
        Library.OnUnload(function()
            stopPolling()
        end)
    end

    _G.StopCmdReceiver = stopPolling
end

local ChineseText = {}
for chinese, english in EnglishText do
    ChineseText[english] = chinese
end

local function GetOriginalChineseText(text)
    if ChineseText[text] then return ChineseText[text] end
    return text
end

local function HookObsidianTooltips()
    local screenGui = Library and Library.ScreenGui
    if not screenGui then return false end
    local hookedAny = false
    for _, inst in screenGui:GetChildren() do
        if inst:IsA("TextLabel")
            and inst:FindFirstChildOfClass("UIPadding")
            and inst:FindFirstChildOfClass("UIStroke")
            and inst:FindFirstChildOfClass("UICorner")
            and not inst:GetAttribute("SkinHubTooltipHook") then
            inst:SetAttribute("SkinHubTooltipHook", true)
            local applying = false
            inst:GetPropertyChangedSignal("Text"):Connect(function()
                if applying then return end
                local text = inst.Text
                if type(text) ~= "string" or text == "" then return end
                if InterfaceLanguage == "English" then
                    local translated = TranslateText(text)
                    if translated ~= text then
                        applying = true
                        inst.Text = translated
                        applying = false
                    end
                elseif string.byte(text, 1) and string.byte(text, 1) < 128 then
                    local original = GetOriginalChineseText(text)
                    if original ~= text then
                        applying = true
                        inst.Text = original
                        applying = false
                    end
                end
            end)
            hookedAny = true
        end
    end
    return hookedAny
end

local function AttachLiveTranslator(inst)
    if inst:GetAttribute("SkinHubLiveTranslate") then return end
    inst:SetAttribute("SkinHubLiveTranslate", true)
    local applying = false
    inst:GetPropertyChangedSignal("Text"):Connect(function()
        if applying then return end
        local text = inst.Text
        if type(text) ~= "string" or text == "" then return end
        if InterfaceLanguage ~= "English" then return end
        local translated = EnglishText[text]
        if not translated then
            local parts = string.split(text, ", ")
            local allMapped = #parts > 1
            for _, part in parts do
                if not EnglishText[part] then
                    allMapped = false
                    break
                end
            end
            if allMapped then
                local out = {}
                for _, part in parts do
                    out[#out + 1] = EnglishText[part]
                end
                translated = table.concat(out, ", ")
            end
        end
        if translated and translated ~= text then
            applying = true
            inst.Text = translated
            applying = false
        end
    end)
    if inst:IsA("TextBox") then
        inst:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
            if applying then return end
            local ptext = inst.PlaceholderText
            if type(ptext) ~= "string" or ptext == "" then return end
            if InterfaceLanguage ~= "English" then return end
            local ptranslated = EnglishText[ptext]
            if ptranslated and ptranslated ~= ptext then
                applying = true
                inst.PlaceholderText = ptranslated
                applying = false
            end
        end)
    end
end

local function InstallLiveTranslation()
    local screenGui = Library and Library.ScreenGui
    if not screenGui then return false end
    if screenGui:GetAttribute("SkinHubLiveTranslateRoot") then return true end
    screenGui:SetAttribute("SkinHubLiveTranslateRoot", true)
    screenGui.DescendantAdded:Connect(function(inst)
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            AttachLiveTranslator(inst)
        end
    end)
    for _, inst in screenGui:GetDescendants() do
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            AttachLiveTranslator(inst)
        end
    end
    return true
end

task.spawn(function()
    local tooltipsHooked = false
    for _ = 1, 100 do
        tooltipsHooked = tooltipsHooked or HookObsidianTooltips()
        if tooltipsHooked and InstallLiveTranslation() then break end
        task.wait(0.2)
    end
    while not InstallLiveTranslation() do
        task.wait(0.5)
    end
end)

local function GetInterfaceRoots()
    local roots = {}
    if Library and Library.ScreenGui then
        table.insert(roots, Library.ScreenGui)
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then table.insert(roots, playerGui) end

    local coreGui = CoreGui
    if coreGui then table.insert(roots, coreGui) end
    return roots
end

local function IsRobloxCoreScriptInstance(instance)
    if Library and Library.ScreenGui then
        if instance == Library.ScreenGui or instance:IsDescendantOf(Library.ScreenGui) then
            return false
        end
    end
    local current = instance
    for i = 1, 20 do
        if not current then return false end
        if current.Name == "RobloxGui" then return true end
        current = current.Parent
    end
    return false
end

local function HasTextProperty(instance)
    return instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")
end

local function TranslateInstance(instance, language)
    if typeof(instance.Text) ~= "string" then return end
    local canonical = GetOriginalChineseText(instance.Text)
    OriginalText[instance] = canonical
    local newText = (language == "English") and TranslateText(canonical) or canonical
    if instance.Text ~= newText then
        instance.Text = newText
    end
end

local function SetInterfaceLanguage(language)
    InterfaceLanguage = language

    for _, root in GetInterfaceRoots() do
        for _, instance in root:GetDescendants() do
            if HasTextProperty(instance) and not IsRobloxCoreScriptInstance(instance) then
                TranslateInstance(instance, language)
            end
        end
    end
    if Options.PvpAimPart then
        Options.PvpAimPart:SetValue(Options.PvpAimPart.Value)
    end
    if Options.AutoRepairMode then
        Options.AutoRepairMode:SetValue(Options.AutoRepairMode.Value)
    end
    if Options.AuraMode then
        Options.AuraMode:SetValue(Options.AuraMode.Value)
    end
end

task.defer(function()
    local pending = {}
    local scheduled = false
    local function flush()
        scheduled = false
        if InterfaceLanguage ~= "English" then
            table.clear(pending)
            return
        end
        for instance in pending do
            if instance.Parent and HasTextProperty(instance) and not IsRobloxCoreScriptInstance(instance) then
                TranslateInstance(instance, InterfaceLanguage)
            end
        end
        table.clear(pending)
    end
    for _, root in GetInterfaceRoots() do
        root.DescendantAdded:Connect(function(instance)
            if InterfaceLanguage ~= "English" then return end
            if not HasTextProperty(instance) then return end

            pending[instance] = true
            if not scheduled then
                scheduled = true
                task.defer(flush)
            end
        end)
    end
end)

local Tabs = {
    Home = Window:AddTab("主页", "house"),
    Main = Window:AddTab("主要与杀戮", "sword"),
    Auto = Window:AddTab("其他与透视", "eye"),
    Minor = Window:AddTab("防护功能", "shield"),
    Anims = Window:AddTab("动画包", "film"),
    AutoFunc = Window:AddTab("自动与PVP", "zap"),
    Extra = Window:AddTab("职业功能", "users"),
    LocalPlayer = Window:AddTab("本地玩家", "user"),
    Misc = Window:AddTab("杂项", "layout-grid"),
    Settings = Window:AddTab("设置", "settings"),
}

local HomeUserGroup = Tabs.Home:AddGroupbox({ Side = "Left", Name = "用户", IconName = "user", Description = "账号信息" })
local HomeSessionGroup = Tabs.Home:AddGroupbox({ Side = "Right", Name = "会话", IconName = "clock", Description = "在线状态" })

local homeLP = LocalPlayer
local homeSessionStart = tick_()

local function homeText(zh, en)
    return InterfaceLanguage == "English" and en or zh
end

local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        executorName = identifyexecutor()
    end
end)

do
    local avatarFrame = Instance.new("Frame")
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.Size = UDim2.new(1, 0, 1, 0)

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "Avatar"
    avatarImage.AnchorPoint = v2new(0.5, 0.5)
    avatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImage.Size = UDim2.new(0, 96, 0, 96)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "rbxasset://textures/ui/iconAssetMissing.png"
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.BorderColor3 = c3rgb(0, 0, 0)
    avatarImage.Parent = avatarFrame

    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(homeLP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and url and url ~= "" and avatarImage and avatarImage.Parent then
            avatarImage.Image = url
        end
    end)

    HomeUserGroup:AddUIPassthrough("HomeAvatar", {
        Instance = avatarFrame,
        Height = 110,
    })
end

local UsernameLabel = HomeUserGroup:AddLabel(("%s: %s"):format(homeText("用户名", "Username"), homeLP.Name))
local UserIdLabel = HomeUserGroup:AddLabel(("%s: %d"):format(homeText("用户ID", "UserId"), homeLP.UserId))
local ExecutorLabel = HomeUserGroup:AddLabel(("%s: %s"):format(homeText("执行器", "Executor"), executorName))
local SessionTimeLabel = HomeUserGroup:AddLabel(("%s: 00:00:00"):format(homeText("会话时间", "Session Time")))

HomeUserGroup:AddButton({
    Text = '复制用户名',
    Func = function()
        pcall(function() setclipboard(homeLP.Name) end)
    end
})

HomeUserGroup:AddButton({
    Text = '复制个人资料链接',
    Func = function()
        pcall(function() setclipboard(("https://www.roblox.com/users/%d/profile"):format(homeLP.UserId)) end)
    end
})

local MasterGroup = Tabs.Home:AddGroupbox({ Side = "Left", Name = "信息", IconName = "info", Description = "版本信息" })
MasterGroup:AddLabel("师傅：小皮")
MasterGroup:AddLabel("英文翻译：Zephy")
MasterGroup:AddLabel("脚本优化：Zephy")

local gameNameCache = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then gameNameCache = info.Name end
end)

local PlayersService = Players

local GameNameLabel = HomeSessionGroup:AddLabel(("%s: %s"):format(homeText("游戏", "Game"), gameNameCache))
local PlayerCountLabel = HomeSessionGroup:AddLabel(("%s: %d/%d"):format(homeText("玩家", "Players"), #PlayersService:GetPlayers(), PlayersService.MaxPlayers))
HomeSessionGroup:AddLabel(("JobId: %s"):format(game.JobId ~= "" and (game.JobId:sub(1, 8) .. "...") or "Studio"))
local PingLabel = HomeSessionGroup:AddLabel(("%s: 0 ms"):format(homeText("延迟", "Ping")))

HomeSessionGroup:AddButton({
    Text = '重新加入服务器',
    Func = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, homeLP)
        end)
    end
})

HomeSessionGroup:AddButton({
    Text = '复制 Job ID',
    Func = function()
        pcall(function() setclipboard(game.JobId) end)
    end
})

task.spawn(function()
    while true do
        local elapsed = mathFloor(tick_() - homeSessionStart)
        local h = mathFloor(elapsed / 3600)
        local m = mathFloor((elapsed % 3600) / 60)
        local s = elapsed % 60
        pcall(function()
            UsernameLabel:SetText(("%s: %s"):format(homeText("用户名", "Username"), homeLP.Name))
            UserIdLabel:SetText(("%s: %d"):format(homeText("用户ID", "UserId"), homeLP.UserId))
            ExecutorLabel:SetText(("%s: %s"):format(homeText("执行器", "Executor"), executorName))
            GameNameLabel:SetText(("%s: %s"):format(homeText("游戏", "Game"), gameNameCache))
            SessionTimeLabel:SetText(("%s: %02d:%02d:%02d"):format(homeText("会话时间", "Session Time"), h, m, s))
            PlayerCountLabel:SetText(("%s: %d/%d"):format(homeText("玩家", "Players"), #PlayersService:GetPlayers(), PlayersService.MaxPlayers))
            local ping = mathFloor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            PingLabel:SetText(("%s: %d ms"):format(homeText("延迟", "Ping"), ping))
        end)
        task.wait(1)
    end
end)

local MiscGroup = Tabs.Misc:AddGroupbox({ Side = "Left", Name = "杂项功能", IconName = "layout-grid", Description = "视野辅助" })
local MiscFunGroup = Tabs.Misc:AddGroupbox({ Side = "Right", Name = "娱乐功能", IconName = "party-popper", Description = "趣味效果" })

MiscFunGroup:AddToggle('RollTiltToggle', {
    Text = '我好像有点卡顿',
    Default = false,
    Tooltip = TranslateTooltip('让人物看起来卡卡的'),
    Callback = function(v)
        if v then L.rollTiltStart() else L.rollTiltStop() end
    end
})

MiscFunGroup:AddSlider('RollTiltSpeed', {
    Text = '卡顿程度',
    Default = 3,
    Min = 1,
    Max = 10,
    Suffix = " 级",
    Callback = function(v) L.rollTiltSpeed = v end
})

MiscFunGroup:AddToggle('SpinToggle', {
    Text = '旋转',
    Default = false,
    Tooltip = TranslateTooltip('让人物持续旋转'),
    Callback = function(v)
        L.spin.enabled = v
        if v then L.spin.start() else L.spin.stop() end
    end
})

MiscFunGroup:AddSlider('SpinSpeed', {
    Text = '旋转速度',
    Default = 5,
    Min = 1,
    Max = 30,
    Suffix = " 级",
    Callback = function(v) L.spin.speed = v end
})

MiscFunGroup:AddToggle('ThirdPersonToggle', {
    Text = '解除视角限制',
    Default = false,
    Tooltip = TranslateTooltip('解除玩家视角上限'),
    Callback = function(v)
        if v then L.thirdPerson.start() else L.thirdPerson.stop() end
    end
})

MiscFunGroup:AddToggle('AnimFreezeToggle', {
    Text = '人体十字架',
    Default = false,
    Tooltip = TranslateTooltip('化身成人体十字架'),
    Callback = function(v)
        if v then L.animFreeze.start() else L.animFreeze.stop() end
    end
})

MiscFunGroup:AddToggle('InvertToggle', {
    Text = '倒立行走',
    Default = false,
    Tooltip = TranslateTooltip('让玩家倒立'),
    Callback = function(v) L.invert.setEnabled(v) end
})

MiscFunGroup:AddToggle('BigHeadToggle', {
    Text = '大头儿子',
    Default = false,
    Tooltip = TranslateTooltip('所有僵尸变成大头儿子'),
    Callback = function(v)
        if v then L.bigHead.enable() else L.bigHead.disable() end
    end
})

MiscFunGroup:AddSlider('BigHeadSize', {
    Text = '头部大小',
    Default = 3,
    Min = 1,
    Max = 10,
    Suffix = " 倍",
    Callback = function(v)
        L.bigHead.headSize = v
        if L.bigHead.enabled then L.bigHead.updateAllZombies() end
    end
})

MiscFunGroup:AddSlider('BigHeadTrans', {
    Text = '头部透明度',
    Default = 5,
    Min = 1,
    Max = 10,
    Suffix = " 级",
    Callback = function(v)
        L.bigHead.headTrans = v / 10
        if L.bigHead.enabled then L.bigHead.updateAllZombies() end
    end
})

MiscFunGroup:AddToggle('AnimLoop1205Toggle', {
    Text = '自己猜🤓',
    Default = false,
    Tooltip = TranslateTooltip('自己猜🤓'),
    Callback = function(v)
        L.animLoop1205Enabled = v
        if v then L.startAnimLoop1205() else L.stopAnimLoop1205() end
    end
})

MiscGroup:AddButton({
    Text = '删除帽子',
    Func = function() L.removeAllHats() end
})

MiscGroup:AddButton({
    Text = '删除上衣',
    Func = function() L.removeAllShirts() end
})

MiscGroup:AddButton({
    Text = '删除裤子',
    Func = function() L.removeAllPants() end
})

MiscGroup:AddButton({
    Text = '一键删除以上全部',
    Func = function()
        L.removeAllHats()
        L.removeAllShirts()
        L.removeAllPants()
    end
})

MiscGroup:AddButton({
    Text = '移除马车模型',
    Func = function() L.removeCarriages() end
})

MiscGroup:AddSlider('WaveSkipCount', {
    Text = '波次数',
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(v) L.waveNum = v end
})

MiscGroup:AddButton({
    Text = '跳过 N 波',
    Func = function() L.sendChatCmd("/skipwave " .. L.waveNum) end
})

L.Bright = { Enabled = false, OriginalLighting = nil }

MiscGroup:AddToggle('BrightToggle', {
    Text = '亮度提升',
    Default = false,
    Tooltip = TranslateTooltip('提高场景亮度'),
    Callback = function(Value)
        local lighting = Lighting
        if Value then
            if not L.Bright.OriginalLighting then
                L.Bright.OriginalLighting = {
                    ClockTime = lighting.ClockTime,
                    Ambient = lighting.Ambient,
                    GlobalShadows = lighting.GlobalShadows,
                    OutdoorAmbient = lighting.OutdoorAmbient,
                }
            end
            lighting.ClockTime = 14
            lighting.Ambient = c3rgb(255,255,255)
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = c3rgb(255,255,255)
            L.Bright.Enabled = true
        else
            if L.Bright.OriginalLighting then
                lighting.ClockTime = L.Bright.OriginalLighting.ClockTime
                lighting.Ambient = L.Bright.OriginalLighting.Ambient
                lighting.GlobalShadows = L.Bright.OriginalLighting.GlobalShadows
                lighting.OutdoorAmbient = L.Bright.OriginalLighting.OutdoorAmbient
            end
            L.Bright.Enabled = false
        end
    end
})

MiscGroup:AddToggle('NoFogToggle', {
    Text = '无雾效果',
    Default = false,
    Tooltip = TranslateTooltip('移除雾效与大气效果，并在地图切换后自动重新应用'),
    Callback = function(v)
        L.noFogEnabled = v
        if v then
            L.applyNoFog()
            L.startNoFogMonitor()
        else
            L.stopNoFogMonitor()
            L.restoreNoFog()
        end
    end
})

local OneClickGroup = Tabs.Misc:AddGroupbox({ Side = "Left", Name = "娱乐", IconName = "smile", Description = "一键操作" })

L.oneClick = L.oneClick or {}
L.oneClick.ui = nil


L.oneClick.VALID_WEAPONS = {
    ["Carbine"] = true,
    ["Axe"] = true,
    ["Pickaxe"] = true,
}

function L.oneClick.getCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in char:GetChildren() do
        if tool:IsA("Tool") then
            local name = tool.Name
            if L.oneClick.VALID_WEAPONS[name] then
                local remote = tool:FindFirstChild("RemoteEvent")
                if remote then
                    return tool
                end
            end
        end
    end
    return nil
end


function L.oneClick.collectTargets()
    local targets = {}

    for _, obj in workspace:GetDescendants() do
        if obj.Name == "DoorHit" or obj.Name == "BreakGlass" then
            table.insert(targets, obj)
        end
    end

    pcall(function()
        if getnilinstances then
            for _, obj in getnilinstances() do
                if obj.Name == "DoorHit" or obj.Name == "BreakGlass" then
                    table.insert(targets, obj)
                end
            end
        end
    end)

    local seen = {}
    local unique = {}
    for _, t in targets do
        if not seen[t] then
            seen[t] = true
            table.insert(unique, t)
        end
    end
    return unique
end

function L.oneClick.getTargetPosition(target)
    if target:IsA("BasePart") then
        return target.Position
    elseif target:IsA("Attachment") then
        return target.WorldPosition
    elseif target.Parent and target.Parent:IsA("BasePart") then
        return target.Parent.Position
    elseif target.Parent and target.Parent.Parent and target.Parent.Parent:IsA("BasePart") then
        return target.Parent.Parent.Position
    else
        return Vector3.zero
    end
end

function L.oneClick.execute()
    local weapon = L.oneClick.getCurrentWeapon()
    if not weapon then
        Library:Notify(TranslateText("请手持卡宾枪/稿子/斧头"), 2)
        return
    end

    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return end

    local targets = L.oneClick.collectTargets()
    if #targets == 0 then return end

    pcall(function()
        remote:FireServer("BraceBlock")
        task.wait(0.08)
        remote:FireServer("StopBraceBlock")
        task.wait(0.05)

        for _, hitObj in targets do
            local pos = L.oneClick.getTargetPosition(hitObj)
            remote:FireServer("FeedbackStunObject", hitObj, pos)
            task.wait(0.003)
        end
    end)
end

function L.oneClick.createUI()
    if L.oneClick.ui then L.oneClick.ui:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "OneClick"
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.5, -30, 0.45, 0)
    btn.BackgroundColor3 = c3rgb(30, 30, 40)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = "拆"
    btn.TextColor3 = c3rgb(255, 255, 255)
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.Parent = sg
    btn.Active = true
    btn.Draggable = true
    do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn
    end
    local st = Instance.new("UIStroke")
    st.Parent = btn
    st.Color = c3rgb(100, 200, 255)
    st.Thickness = 2.5
    st.Transparency = 0.3
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    L.oneClick.ui = sg
    btn.MouseButton1Click:Connect(function() task.spawn(L.oneClick.execute) end)
end

L.flyAway = {
    isEnabled = false,
    connections = {},
    toggleBtn = nil,
    screenGui = nil,
}

function L.flyAway.SafeGetCharacter(player)
    if not player then return nil end
    local char = player.Character
    if not char or not char.Parent then return nil end
    return char
end

function L.flyAway.SafeGetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function L.flyAway.SafeGetHRP(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function L.flyAway.UpdateButton()
    if not L.flyAway.toggleBtn then return end
    if L.flyAway.isEnabled then
        L.flyAway.toggleBtn.Text = "关"
        L.flyAway.toggleBtn.BackgroundColor3 = c3rgb(200, 80, 80)
    else
        L.flyAway.toggleBtn.Text = "碰"
        L.flyAway.toggleBtn.BackgroundColor3 = c3rgb(30, 30, 40)
    end
end

function L.flyAway.ToggleCore(state)
    L.flyAway.isEnabled = state
    for _, conn in L.flyAway.connections do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    L.flyAway.connections = {}
    if L.flyAway.isEnabled then
        local stepConn = RunService.Stepped:Connect(function()
            if not L.flyAway.isEnabled then return end
            local char = L.flyAway.SafeGetCharacter(LocalPlayer)
            local hum = L.flyAway.SafeGetHumanoid(char)
            local hrp = L.flyAway.SafeGetHRP(char)
            if hum and hrp then
                pcall(function()
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum.AutoRotate = true
                    local state = hum:GetState()
                    if state == Enum.HumanoidStateType.Physics or
                       state == Enum.HumanoidStateType.FallingDown or
                       state == Enum.HumanoidStateType.Ragdoll then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
            end
            if L.flyAway.isEnabled then
                for _, otherPlayer in Players:GetPlayers() do
                    if otherPlayer ~= LocalPlayer then
                        local otherChar = L.flyAway.SafeGetCharacter(otherPlayer)
                        if otherChar then
                            for _, part in otherChar:GetDescendants() do
                                if part:IsA("BasePart") then
                                    pcall(function() part.CanCollide = false end)
                                end
                            end
                        end
                    end
                end
            end
        end)
        table.insert(L.flyAway.connections, stepConn)
        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not L.flyAway.isEnabled then return end
            local char = L.flyAway.SafeGetCharacter(LocalPlayer)
            local hrp = L.flyAway.SafeGetHRP(char)
            local hum = L.flyAway.SafeGetHumanoid(char)
            if hum and hrp then
                pcall(function()
                    local currentVel = hrp.AssemblyLinearVelocity
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    local safeY = currentVel.Y
                    if safeY > 35 then safeY = 35 end
                    if safeY < -40 then safeY = -40 end
                    hrp.AssemblyAngularVelocity = v3new(1350, 1350, 1350)
                    hrp.AssemblyLinearVelocity = v3new(
                        currentVel.X * 1.,
                        safeY,
                        currentVel.Z * 1
                    )
                    RunService.RenderStepped:Wait()
                    if hrp and hrp.Parent then
                        hrp.AssemblyAngularVelocity = v3new(0, 0, 0)
                    end
                end)
            end
        end)
        table.insert(L.flyAway.connections, heartbeatConn)
    end
    L.flyAway.UpdateButton()
end

function L.flyAway.CreateUI()
    if L.flyAway.screenGui then L.flyAway.screenGui:Destroy() end
    L.flyAway.screenGui = Instance.new("ScreenGui")
    L.flyAway.screenGui.Name = "碰UI"
    L.flyAway.screenGui.ResetOnSpawn = false
    L.flyAway.screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    L.flyAway.toggleBtn = Instance.new("TextButton")
    L.flyAway.toggleBtn.Size = UDim2.new(0, 60, 0, 60)
    L.flyAway.toggleBtn.Position = UDim2.new(0.5, -30, 0.45, 0)
    L.flyAway.toggleBtn.BackgroundColor3 = c3rgb(30, 30, 40)
    L.flyAway.toggleBtn.BackgroundTransparency = 0.2
    L.flyAway.toggleBtn.BorderSizePixel = 0
    L.flyAway.toggleBtn.Text = "碰"
    L.flyAway.toggleBtn.TextColor3 = c3rgb(255, 255, 255)
    L.flyAway.toggleBtn.TextSize = 24
    L.flyAway.toggleBtn.Font = Enum.Font.GothamBold
    L.flyAway.toggleBtn.Parent = L.flyAway.screenGui
    L.flyAway.toggleBtn.Active = true
    L.flyAway.toggleBtn.Draggable = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = L.flyAway.toggleBtn
    local stroke = Instance.new("UIStroke")
    stroke.Color = c3rgb(100, 200, 255)
    stroke.Thickness = 2.5
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = L.flyAway.toggleBtn
    L.flyAway.toggleBtn.MouseButton1Click:Connect(function()
        L.flyAway.isEnabled = not L.flyAway.isEnabled
        L.flyAway.ToggleCore(L.flyAway.isEnabled)
    end)
    L.flyAway.UpdateButton()
end

function L.flyAway.Start()
    if L.flyAway.screenGui and L.flyAway.screenGui.Parent then return end
    L.flyAway.CreateUI()
    L.flyAway.isEnabled = false
    L.flyAway.ToggleCore(false)
end

function L.flyAway.Stop()
    if L.flyAway.screenGui then
        L.flyAway.screenGui:Destroy()
        L.flyAway.screenGui = nil
        L.flyAway.toggleBtn = nil
    end
    if L.flyAway.isEnabled then
        L.flyAway.ToggleCore(false)
    end
    for _, conn in L.flyAway.connections do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    L.flyAway.connections = {}
end

OneClickGroup:AddToggle('OneClickToggle', {
    Text = '打全图门窗',
    Default = false,
    Callback = function(v)
        if v then
            L.oneClick.createUI()
        else
            if L.oneClick.ui then L.oneClick.ui:Destroy() end
        end
    end
})

OneClickGroup:AddToggle('FlyAwayToggle', {
    Text = '打开甩飞快捷栏',
    Default = false,
    Callback = function(v)
        if v then
            L.flyAway.Start()
        else
            L.flyAway.Stop()
        end
    end
})

L.invisScript = L.invisScript or {
    enabled = false,
    cleanup = nil,
}

local INVIS_SCRIPT_SOURCE = [==[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local c = true
local h = {}
local d = Vector3.new(0, 0, 0)

local sg = Instance.new("ScreenGui")
sg.Name = "InvisFloatWindow"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 60)
btn.Position = UDim2.new(0.5, -30, 0.45, 0)
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
btn.BackgroundTransparency = 0.2
btn.BorderSizePixel = 0
btn.Text = "关"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 18
btn.Font = Enum.Font.GothamBold
btn.Parent = sg
btn.Active = true
btn.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Thickness = 2.5
stroke.Transparency = 0.3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = btn

local function updateOffset()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local head = char:FindFirstChild("Head")
    local topY = hrp.Position.Y + hrp.Size.Y * 0
    if head then
        topY = head.Position.Y + head.Size.Y * 0
    end
    local up = (topY - hrp.Position.Y) + 680
    d = Vector3.new(0, up, 0)
end

local btnConn = btn.MouseButton1Click:Connect(function()
    c = not c
    if c then
        btn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        btn.Text = "开"
    else
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = "关"
    end
end)

c = false
btn.Text = "关"
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

local heartbeatConn = RunService.Heartbeat:Connect(function()
    if c == true and LocalPlayer.Character then
        local i = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not i then return end
        updateOffset()
        h[1] = i.CFrame
        h[2] = i.AssemblyLinearVelocity
        local j = i.CFrame + d
        i.CFrame = j
        i.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        RunService.RenderStepped:Wait()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = h[1]
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = h[2]
        end
    end
end)

local originalIndex
originalIndex = hookmetamethod(game, "__index", newcclosure(function(self, l)
    if c == true then
        if not checkcaller() then
            if l == "CFrame" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
                if self == LocalPlayer.Character.HumanoidRootPart then
                    return (h[1] or CFrame.new()) + d
                elseif self == LocalPlayer.Character.Head then
                    local m = h[1] or CFrame.new()
                    return m + d
                end
            end
        end
    end
    return originalIndex(self, l)
end))

local renderBindName = "FakePosCamFix_" .. tostring(math.random(100000, 999999))
RunService:BindToRenderStep(
    renderBindName,
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if c == true and LocalPlayer.Character then
            local cam = workspace.CurrentCamera
            if cam then
                cam.CFrame = cam.CFrame - d
            end
        end
    end
)

return function()
    c = false
    if btnConn then pcall(function() btnConn:Disconnect() end) end
    if heartbeatConn then pcall(function() heartbeatConn:Disconnect() end) end
    if sg and sg.Parent then pcall(function() sg:Destroy() end) end
    pcall(function() RunService:UnbindFromRenderStep(renderBindName) end)
    if originalIndex then
        pcall(function() hookmetamethod(game, "__index", originalIndex) end)
    end
end
]==]

function L.startInvisScript()
    if L.invisScript.enabled then return end
    if type(loadstring) ~= "function" then
        L.notify(TranslateText("错误") .. ": loadstring unavailable", 2)
        return
    end
    local fn = loadstring(INVIS_SCRIPT_SOURCE)
    if not fn then
        L.notify(TranslateText("错误") .. ": loadstring failed", 2)
        return
    end
    local ok, cleanup = pcall(fn)
    if not ok then
        warn("[InvisScript] load error: " .. tostring(cleanup))
        L.notify(TranslateText("错误") .. ": " .. tostring(cleanup), 3)
        return
    end
    L.invisScript.enabled = true
    L.invisScript.cleanup = cleanup
end

function L.stopInvisScript()
    if not L.invisScript.enabled then return end
    L.invisScript.enabled = false
    if L.invisScript.cleanup then
        pcall(L.invisScript.cleanup)
        L.invisScript.cleanup = nil
    end
    -- 兜底清理残留的 ScreenGui
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local old = pg and pg:FindFirstChild("InvisFloatWindow")
        if old then old:Destroy() end
    end)
end

OneClickGroup:AddToggle('InvisScriptToggle', {
    Text = '打开隐身快捷栏',
    Default = false,
    Callback = function(v)
        if v then
            L.startInvisScript()
        else
            L.stopInvisScript()
        end
    end
})

local AnimsLeftGroup = Tabs.Anims:AddGroupbox({ Side = "Left", Name = "动画包", IconName = "film", Description = "姿势动画" })
local AnimsRightGroup = Tabs.Anims:AddGroupbox({ Side = "Right", Name = "其它动画", IconName = "clapperboard", Description = "舞蹈动作" })

local AutoFuncGroup = Tabs.AutoFunc:AddGroupbox({ Side = "Left", Name = "自动功能", IconName = "zap", Description = "自动挖拾" })

L.autoDigEnabled = false
L.autoDigConnection = nil
L.DIGGABLE_PATHS = {
    "Vardohus Fortress/Modes/Objective/DoorSnow/Diggable",
    "Vardohus Fortress/Modes/Objective/Diggable",
    "OLD Vardohus Fortress/Modes/Objective/DigSnow/Diggable"
}

function L.getDiggingTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in char:GetChildren() do
        if (tool.Name == "Shovel" or tool.Name == "Spade") and tool:FindFirstChild("RemoteEvent") then
            return tool
        end
    end
    for _, tool in LocalPlayer.Backpack:GetChildren() do
        if (tool.Name == "Shovel" or tool.Name == "Spade") and tool:FindFirstChild("RemoteEvent") then
            return tool
        end
    end
    return nil
end

function L.findValidDiggable()
    for _, path in L.DIGGABLE_PATHS do
        local parts = {}
        for part in string.gmatch(path, "[^/]+") do
            table.insert(parts, part)
        end
        local current = workspace
        for _, partName in parts do
            current = current:FindFirstChild(partName)
            if not current then break end
        end
        if current then return current end
    end
    return nil
end

function L.executeDig()
    if not L.autoDigEnabled then return end
    local diggable = L.findValidDiggable()
    if not diggable then return end
    local tool = L.getDiggingTool()
    if not tool then return end
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        task.wait(0.2)
    end
    local remoteEvent = tool:FindFirstChild("RemoteEvent")
    if not remoteEvent then return end
    pcall(function() remoteEvent:FireServer("Dig", diggable, diggable.Position) end)
end

function L.autoDigLoop()
    while L.autoDigEnabled do
        L.executeDig()
        task.wait(0.01)
    end
end

function L.toggleAutoDig(state)
    L.autoDigEnabled = state
    if state then
        if L.autoDigConnection then task.cancel(L.autoDigConnection) end
        L.autoDigConnection = task.spawn(L.autoDigLoop)
        L.notify(TranslateText("自动挖雪已开启"), 2)
    else
        if L.autoDigConnection then task.cancel(L.autoDigConnection); L.autoDigConnection = nil end
        L.notify(TranslateText("自动挖雪已关闭"), 2)
    end
end

L.onCharacterAdded(function()
    if L.autoDigEnabled then
        L.autoDigEnabled = false
        if L.autoDigConnection then task.cancel(L.autoDigConnection); L.autoDigConnection = nil end
        local toggle = Toggles['AutoDigToggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AutoFuncGroup:AddToggle('AutoDigToggle', {
    Text = '自动挖雪',
    Default = false,
    Tooltip = TranslateTooltip('自动挖掘雪堆（需要铲子）'),
    Callback = function(v) L.toggleAutoDig(v) end
})

L.autoCollectEnabled = false
L.autoCollectConnection = nil
L.activePrompts = {}
L.descendantAddedConn = nil

function L.setupAutoCollect()
    if L.descendantAddedConn then L.descendantAddedConn:Disconnect() end
    for _, descendant in workspace:GetDescendants() do
        if descendant:IsA("ProximityPrompt") then L.activePrompts[descendant] = true end
    end
    L.descendantAddedConn = workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") then L.activePrompts[descendant] = true end
    end)
    L.autoCollectConnection = RunService.Heartbeat:Connect(function()
        if not L.autoCollectEnabled or not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for prompt, _ in L.activePrompts do
            if prompt and prompt.Parent and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("BasePart") then
                    local distance = (part.Position - hrp.Position).Magnitude
                    if distance <= prompt.MaxActivationDistance then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            else
                L.activePrompts[prompt] = nil
            end
        end
    end)
end

function L.toggleAutoCollect(state)
    L.autoCollectEnabled = state
    if state then
        if L.autoCollectConnection then L.autoCollectConnection:Disconnect() end
        if L.descendantAddedConn then L.descendantAddedConn:Disconnect() end
        L.activePrompts = {}
        L.setupAutoCollect()
        L.notify(TranslateText("自动收集已开启"), 2)
    else
        if L.autoCollectConnection then L.autoCollectConnection:Disconnect(); L.autoCollectConnection = nil end
        if L.descendantAddedConn then L.descendantAddedConn:Disconnect(); L.descendantAddedConn = nil end
        L.activePrompts = {}
        L.notify(TranslateText("自动收集已关闭"), 2)
    end
end

L.onCharacterAdded(function()
    if L.autoCollectEnabled then
        L.autoCollectEnabled = false
        if L.autoCollectConnection then L.autoCollectConnection:Disconnect(); L.autoCollectConnection = nil end
        if L.descendantAddedConn then L.descendantAddedConn:Disconnect(); L.descendantAddedConn = nil end
        L.activePrompts = {}
        local toggle = Toggles['AutoCollectToggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AutoFuncGroup:AddToggle('AutoCollectToggle', {
    Text = '自动收集',
    Default = false,
    Tooltip = TranslateTooltip('自动触发附近的收集提示（Kaub地图）'),
    Callback = function(v) L.toggleAutoCollect(v) end
})

if not L.autoFeatures then L.autoFeatures = {} end
L.autoFeatures.brickBreaker = L.autoFeatures.brickBreaker or {
    active = false,
    thread = nil,
    cachedMap = nil,
    cachedWall = nil,
    cachedBricks = nil,
    lastRefresh = 0,
}

function L.getBrickBreakerTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in char:GetChildren() do
        if tool:IsA("Tool") and tool:FindFirstChild("RemoteEvent") then
            local name = tool.Name:lower()
            if name:find("斧") or name:find("锤") or name:find("axe") or name:find("hammer") or name:find("sledge") or name:find("pickaxe") then
                return tool:FindFirstChild("RemoteEvent")
            end
        end
    end
    return nil
end

function L.getBrickWall()
    local now = tick_()
    if now - L.autoFeatures.brickBreaker.lastRefresh < 1 and L.autoFeatures.brickBreaker.cachedWall then
        return L.autoFeatures.brickBreaker.cachedBricks or {}, L.autoFeatures.brickBreaker.cachedWall
    end
    L.autoFeatures.brickBreaker.lastRefresh = now
    local map = L.autoFeatures.brickBreaker.cachedMap
    if not map or not map.Parent then
        map = workspace:FindFirstChild("Catacombes de Paris")
        if not map then
            for _, v in workspace:GetChildren() do
                if v.Name:lower():find("catacomb") then
                    map = v
                    break
                end
            end
        end
        L.autoFeatures.brickBreaker.cachedMap = map
    end
    if not map then return {}, nil end
    local wall = map:FindFirstChild("Modes") and map.Modes:FindFirstChild("Objective") and map.Modes.Objective:FindFirstChild("brickwall")
    if not wall then return {}, nil end
    local bricks = {}
    for _, child in wall:GetChildren() do
        if child:IsA("BasePart") then table.insert(bricks, child) end
    end
    L.autoFeatures.brickBreaker.cachedBricks = bricks
    L.autoFeatures.brickBreaker.cachedWall = wall
    return bricks, wall
end

function L.breakBrickOnce()
    local event = L.getBrickBreakerTool()
    if not event then return end
    local bricks, wall = L.getBrickWall()
    if not wall or #bricks == 0 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (hrp.Position - wall:GetPivot().Position).Magnitude > 10 then return end
    pcall(event.FireServer, event, "Swing", "Over")
    local dirVec = v3new(0.97238314151764, 0, -0.23338980972767)
    local batchSize = 25
    for i = 1, #bricks, batchSize do
        for j = i, mathMin(i + batchSize - 1, #bricks) do
            pcall(event.FireServer, event, "HitBreakable", { bricks[j] }, dirVec)
        end
        task.wait(0.1)
    end
end

function L.brickBreakerLoop()
    while L.autoFeatures.brickBreaker.active do
        L.breakBrickOnce()
        task.wait(0.3)
    end
end

AutoFuncGroup:AddToggle('AutoBreakWallToggle', {
    Text = '自动砸砖墙',
    Tooltip = TranslateTooltip('巴黎地下墓穴自动砸砖墙'),
    Default = false,
    Callback = function(state)
        L.autoFeatures.brickBreaker.active = state
        if state then
            if L.autoFeatures.brickBreaker.thread then task.cancel(L.autoFeatures.brickBreaker.thread) end
            L.autoFeatures.brickBreaker.thread = task.spawn(L.brickBreakerLoop)
            L.notify(TranslateText("自动砸砖墙已开启"), 2)
        else
            if L.autoFeatures.brickBreaker.thread then task.cancel(L.autoFeatures.brickBreaker.thread) end
            L.autoFeatures.brickBreaker.thread = nil
            L.autoFeatures.brickBreaker.cachedMap = nil
            L.autoFeatures.brickBreaker.cachedWall = nil
            L.autoFeatures.brickBreaker.cachedBricks = nil
            L.notify(TranslateText("自动砸砖墙已关闭"), 2)
        end
    end
})

L.autoBarrel = {
    enabled = false,
    thread = nil,
    markers = {},
    activeZone = nil,
    idx = 1,

    GetNil = function(Name, DebugId)
        local success, getnil = pcall(function() return getnilinstances end)
        if not success then return nil end
        for _, obj in getnil() do
            if obj.Name == Name then
                local okId, objId = pcall(function() return obj:GetDebugId() end)
                if not okId or objId == DebugId then
                    return obj
                end
            end
        end
        return nil
    end,

    GetEvent = function()
        for _, container in {LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")} do
            if container then
                for _, c in container:GetChildren() do
                    if c:IsA("Tool") and c:FindFirstChild("RemoteEvent") then
                        return c:FindFirstChild("RemoteEvent")
                    end
                end
            end
        end
        local nilEv = L.autoBarrel.GetNil("RemoteEvent", "1_1065169")
        if nilEv then return nilEv end
        return nil
    end,

    FindAxe = function()
        for _, container in {LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")} do
            if container then
                for _, c in container:GetChildren() do
                    if c:IsA("Tool") and (c.Name:find("斧") or c.Name:find("Axe")) and c:FindFirstChild("RemoteEvent") then
                        return c
                    end
                end
            end
        end
        return nil
    end,

    EquipAxe = function(tool)
        if tool and LocalPlayer.Character and tool.Parent ~= LocalPlayer.Character then
            tool.Parent = LocalPlayer.Character
        end
    end,

    UnequipAxe = function(tool)
        if tool and LocalPlayer:FindFirstChild("Backpack") and tool.Parent == LocalPlayer.Character then
            tool.Parent = LocalPlayer.Backpack
        end
    end,

    CreateMarker = function(pos, text)
        local marker = Instance.new("Part")
        marker.Size = v3new(5, 0.2, 5)
        marker.Position = pos
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 0.3
        marker.BrickColor = BrickColor.new("Bright red")
        marker.Material = Enum.Material.Neon
        marker.Parent = workspace

        local billboard = Instance.new("BillboardGui")
        billboard.Parent = marker
        billboard.Adornee = marker
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = v3new(0, 3, 0)
        billboard.MaxDistance = 100
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Parent = billboard
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 20
        return marker
    end,

    zones = {
        {
            name = "Sixth.Vat",
            markerPos = v3new(-504, 84, -887),
            markerText = TranslateText("站在这自动攻击"),
            getBarrel = function()
                for _, obj in workspace:GetDescendants() do
                    if obj.Name == "WeaponHitEvent" and obj:GetFullName():find("Sixth.Vat") then
                        return obj
                    end
                end
                return nil
            end,
            attacks = {
                {dir = v3new(-500.75604248047, 84.927505493164, -890.66754150391), pos = v3new(-0.89652353525162, 0.060126047581434, -0.43889671564102)},
                {dir = v3new(-500.98861694336, 85.332466125488, -890.13061523438), pos = v3new(-0.90410608053207, 0.067801177501678, -0.42189466953278)},
                {dir = v3new(-501.20587158203, 88.093856811523, -885.51672363281), pos = v3new(-0.98575168848038, 0.071034908294678, 0.15247163176537)},
                {dir = v3new(-501.19708251953, 88.030601501465, -885.43048095703), pos = v3new(-0.98575168848038, 0.071034908294678, 0.15247163176537)},
                {dir = v3new(-501.08236694336, 85.746765136719, -883.75225830078), pos = v3new(-0.98487240076065, 0.06706964224577, 0.15977507829666)},
                {dir = v3new(-501.07168579102, 85.640113830566, -883.64154052734), pos = v3new(-0.98487234115601, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-501.14144897461, 85.491081237793, -884.00915527344), pos = v3new(-0.98487228155136, 0.067069627344608, 0.15977503359318)},
                {dir = v3new(-501.06597900391, 85.756851196289, -883.65551757812), pos = v3new(-0.98487234115601, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-500.78323364258, 85.599006652832, -890.52026367188), pos = v3new(-0.89653557538986, 0.059777364134789, -0.43891969323158)},
                {dir = v3new(-501.03414916992, 85.722961425781, -889.89831542969), pos = v3new(-0.98484867811203, 0.06741139292717, -0.15977698564529)},
                {dir = v3new(-501.09646606445, 85.6953125, -889.52575683594), pos = v3new(-0.98484867811203, 0.06741140037775, -0.15977698564529)},
                {dir = v3new(-501.11978149414, 85.646644592285, -889.40252685547), pos = v3new(-0.98484867811203, 0.06741139292717, -0.15977698564529)},
                {dir = v3new(-501.16485595703, 85.475677490234, -889.19714355469), pos = v3new(-0.98485445976257, 0.067325212061405, -0.15977793931961)},
                {dir = v3new(-501.12622070312, 85.940795898438, -884.10394287109), pos = v3new(-0.98487228155136, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-501.15670776367, 85.963218688965, -884.30139160156), pos = v3new(-0.98487228155136, 0.067069627344608, 0.1597750633955)},
                {dir = v3new(-501.34365844727, 88.065979003906, -886.39453125), pos = v3new(-0.98575168848038, 0.071034908294678, 0.15247163176537)},
                {dir = v3new(-500.15362548828, 85.163520812988, -889.72271728516), pos = v3new(0, 1, 0)},
                {dir = v3new(-501.22790527344, 87.050521850586, -885.19653320312), pos = v3new(-0.98487317562103, 0.067056514322758, 0.15977519750595)},
                {dir = v3new(-500.16421508789, 85.163520812988, -889.63708496094), pos = v3new(0, 0.99999994039536, 0)},
                {dir = v3new(-501.29144287109, 88.435127258301, -886.22888183594), pos = v3new(-0.98576200008392, 0.071035631000996, 0.15240448713303)},
                {dir = v3new(-501.2336730957, 88.04647064209, -887.66705322266), pos = v3new(-0.98581445217133, 0.070850245654583, -0.15215095877647)},
                {dir = v3new(-501.07943725586, 85.713439941406, -889.62316894531), pos = v3new(-0.98484867811203, 0.06741139292717, -0.15977698564529)},
                {dir = v3new(-501.1650390625, 85.386672973633, -889.23345947266), pos = v3new(-0.98485445976257, 0.067325212061405, -0.15977793931961)},
                {dir = v3new(-501.06039428711, 85.619041442871, -889.7802734375), pos = v3new(-0.98484867811203, 0.06741140037775, -0.15977698564529)},
                {dir = v3new(-501.24404907227, 88.329032897949, -887.4677734375), pos = v3new(-0.9858004450798, 0.070849239826202, -0.15224236249924)},
                {dir = v3new(-500.76483154297, 86.164970397949, -890.47637939453), pos = v3new(-0.90410596132278, 0.067801207304001, -0.42189493775368)},
            }
        },
        {
            name = "Fifth.Vat",
            markerPos = v3new(-503, 84, -855),
            markerText = TranslateText("站在这自动攻击"),
            getBarrel = function()
                local ok, w = pcall(function()
                    local london = workspace:FindFirstChild("London")
                    return london and london.Modes.Objective.PlantEvent.Vats.Fifth.Vat.Union
                end)
                if ok and w and w:FindFirstChild("WeaponHitEvent") then
                    return w:FindFirstChild("WeaponHitEvent")
                end
                return L.autoBarrel.GetNil("WeaponHitEvent", "1_1065268")
            end,
            attacks = {
                {dir = v3new(-501.0754699707, 85.681076049805, -858.66119384766), pos = v3new(-0.98484873771667, 0.06741140037775, -0.15977700054646)},
                {dir = v3new(-501.18844604492, 85.632759094238, -857.98559570312), pos = v3new(-0.98485445976257, 0.067325204610825, -0.15977792441845)},
                {dir = v3new(-501.47311401367, 85.297927856445, -856.37200927734), pos = v3new(-0.98492193222046, 0.067301861941814, -0.1593714505434)},
                {dir = v3new(-500.92535400391, 85.855033874512, -852.15808105469), pos = v3new(-0.9041999578476, 0.067528575658798, 0.4217372238636)},
                {dir = v3new(-500.88934326172, 85.858787536621, -852.08148193359), pos = v3new(-0.90419989824295, 0.067528575658798, 0.42173719406128)},
                {dir = v3new(-501.17599487305, 87.969223022461, -854.26550292969), pos = v3new(-0.98575162887573, 0.071034908294678, 0.15247163176537)},
                {dir = v3new(-501.03616333008, 85.970657348633, -852.56134033203), pos = v3new(-0.98487234115601, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-501.05889892578, 88.318069458008, -853.68701171875), pos = v3new(-0.98487240076065, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-499.66125488281, 85.163528442383, -853.49676513672), pos = v3new(0, 1, 0)},
                {dir = v3new(-501.03698730469, 87.936096191406, -853.39147949219), pos = v3new(-0.98487234115601, 0.067069634795189, 0.1597750633955)},
                {dir = v3new(-500.39682006836, 85.50464630127, -854.49682617188), pos = v3new(0.70616257190704, -0.050490908324718, -0.70624709129333)},
                {dir = v3new(-500.93835449219, 85.88355255127, -852.19055175781), pos = v3new(-0.9041999578476, 0.067528583109379, 0.42173725366592)},
                {dir = v3new(-500.939697265625, 85.861198425293, -852.18981933594), pos = v3new(-0.90419989824295, 0.067528575658798, 0.42173719406128)},
                {dir = v3new(-501.02380371094, 85.660652160645, -852.35504150391), pos = v3new(-0.98487234115601, 0.067069627344608, 0.15977504849434)},
                {dir = v3new(-501.0461730957, 85.940727233887, -852.61047363281), pos = v3new(-0.98487234115601, 0.067069627344608, 0.15977504849434)},
                {dir = v3new(-500.78167724609, 85.652587890625, -851.83068847656), pos = v3new(-0.89742821455002, 0.059714660048485, 0.43710032105446)},
                {dir = v3new(-500.87280273438, 85.297035217285, -851.96917724609), pos = v3new(-0.89742827415466, 0.059714667499065, 0.43710032105446)},
                {dir = v3new(-501.1628112793, 84.407585144043, -855.28332519531), pos = v3new(0.70647174119949, 0.042316291481256, -0.70647495985031)},
                {dir = v3new(-499.37216186523, 84.492935180664, -857.31158447266), pos = v3new(0.60354781150818, 0.52116417884827, 0.60342174768448)},
                {dir = v3new(-501.21951293945, 88.377555847168, -854.73663330078), pos = v3new(-0.98576205968857, 0.071035645902157, 0.15240448713303)},
                {dir = v3new(-501.17965698242, 85.689224243164, -858.015625), pos = v3new(-0.98484867811203, 0.06741139292717, -0.15977698564529)},
                {dir = v3new(-501.17138671875, 85.641700744629, -858.08660888672), pos = v3new(-0.98484873771667, 0.06741140037775, -0.15977700054646)},
                {dir = v3new(-501.17776489258, 85.642425537109, -858.04693603516), pos = v3new(-0.98484867811203, 0.06741140037775, -0.15977700054646)},
                {dir = v3new(-501.0732421875, 85.037719726562, -858.94866943359), pos = v3new(-0.98488432168961, 0.066809743642807, -0.15981025993824)},
                {dir = v3new(-501.22708129883, 88.807281494141, -854.98596191406), pos = v3new(-0.98576205968857, 0.071035638451576, 0.15240450203419)},
                {dir = v3new(-501.0735168457, 85.89754486084, -858.58203125), pos = v3new(-0.98484873771667, 0.06741139292717, -0.15977698564529)},
            }
        },
        {
            name = "Eleventh.Vat",
            markerPos = v3new(-549, 86, -811),
            markerText = TranslateText("站在这自动攻击"),
            getBarrel = function()
                local ok, w = pcall(function()
                    return findPath(workspace, "London", "Modes", "Objective", "PlantEvent", "Vats", "Eleventh", "Vat", "Union")
                end)
                if ok and w and w:FindFirstChild("WeaponHitEvent") then
                    return w:FindFirstChild("WeaponHitEvent")
                end
                return L.autoBarrel.GetNil("WeaponHitEvent", "1_1073300")
            end,
            attacks = {
                {dir = v3new(-552.78381347656, 88.717971801758, -809.00787353516), pos = v3new(0.98476564884186, 0.067194454371929, 0.16037914156914)},
                {dir = v3new(-552.70440673828, 89.815093994141, -811.34332275391), pos = v3new(0.98576390743256, 0.071042731404305, -0.15238885581493)},
                {dir = v3new(-552.68292236328, 89.847938537598, -811.18890380859), pos = v3new(0.9857639670372, 0.071042731404305, -0.15238887071609)},
                {dir = v3new(-553.07263183594, 85.688133239746, -814.2060546875), pos = v3new(0.90414243936539, -0.067688904702663, -0.42183470726013)},
                {dir = v3new(-552.88128662109, 87.539039611816, -813.42303466797), pos = v3new(0.98487842082977, 0.06709598004818, -0.15972693264484)},
                {dir = v3new(-552.87426757812, 85.388092041016, -813.2255859375), pos = v3new(0.98481035232544, -0.067274585366249, -0.160070925951)},
                {dir = v3new(-552.59704589844, 87.250274658203, -809.54016113281), pos = v3new(0.98476403951645, 0.067188046872616, 0.16039177775383)},
                {dir = v3new(-552.73199462891, 87.079711914062, -808.63653564453), pos = v3new(0.98478204011917, 0.068775951862335, 0.15960648655891)},
                {dir = v3new(-552.62969970703, 87.18196105957, -809.31097412109), pos = v3new(0.98476564884186, 0.06719446182251, 0.16037914156914)},
                {dir = v3new(-552.58184814453, 88.963623046875, -810.94750976562), pos = v3new(0.9857639670372, 0.071042731404305, -0.15238887071609)},
                {dir = v3new(-552.9150390625, 87.483085632324, -813.65460205078), pos = v3new(0.98487842082977, 0.06709598749876, -0.15972693264484)},
                {dir = v3new(-552.92816162109, 85.771011352539, -813.71801757812), pos = v3new(0.98481035232544, -0.067274577915668, -0.160070925951)},
                {dir = v3new(-552.77795410156, 88.108680725098, -808.78875732422), pos = v3new(0.98476403951645, 0.067188039422035, 0.16039176285267)},
                {dir = v3new(-552.76763916016, 88.291069030762, -808.92864990234), pos = v3new(0.9847639799118, 0.067188039422035, 0.16039174795151)},
                {dir = v3new(-552.74987792969, 89.069030761719, -809.36346435547), pos = v3new(0.9847639799118, 0.067188039422035, 0.16039174795151)},
                {dir = v3new(-552.7509765625, 88.919998168945, -809.29418945312), pos = v3new(0.98476403951645, 0.067188039422035, 0.16039176285267)},
                {dir = v3new(-552.65301513672, 87.093292236328, -809.12951660156), pos = v3new(0.98478204011917, 0.068775936961174, 0.15960647165775)},
                {dir = v3new(-552.44195556641, 86.756286621094, -810.28668212891), pos = v3new(0.98478198051453, 0.068775929510593, 0.15960647165775)},
                {dir = v3new(-552.91418457031, 85.772613525391, -813.63250732422), pos = v3new(0.98481029272079, -0.067274577915668, -0.16007091104984)},
                {dir = v3new(-552.76385498047, 87.468566894531, -812.72827148438), pos = v3new(0.98487842082977, 0.06709598004818, -0.15972691774368)},
                {dir = v3new(-552.90911865234, 86.100425720215, -813.73913574219), pos = v3new(0.98481035232544, -0.067274585366249, -0.160070925951)},
                {dir = v3new(-552.88659667969, 85.233528137207, -813.23645019531), pos = v3new(0.98481035232544, -0.067274585366249, -0.160070925951)},
                {dir = v3new(-552.69219970703, 84.79695892334, -809.48278808594), pos = v3new(0.98484379053116, -0.067381218075752, 0.15982039272785)},
                {dir = v3new(-552.76330566406, 86.98217010498, -808.40142822266), pos = v3new(0.98483955860138, 0.067443065345287, 0.1598197221756)},
                {dir = v3new(-552.69714355469, 86.880889892578, -808.76623535156), pos = v3new(0.98483961820602, 0.067443057894707, 0.15981973707676)},
                {dir = v3new(-552.78662109375, 89.133865356445, -812.16937255859), pos = v3new(0.98487842082977, 0.06709598749876, -0.15972693264484)},
                {dir = v3new(-552.74291992188, 87.948799133301, -812.39788818359), pos = v3new(0.98488110303879, 0.067055277526379, -0.15972736477852)},
            }
        },
        {
            name = "Eighth.Vat",
            markerPos = v3new(-551, 73, -863),
            markerText = TranslateText("站在这自动攻击"),
            getBarrel = function()
                local ok, w = pcall(function()
                    local london = workspace:FindFirstChild("London")
                    return london and london.Modes.Objective.PlantEvent.Vats.Eighth.Vat.Union
                end)
                if ok and w and w:FindFirstChild("WeaponHitEvent") then
                    return w:FindFirstChild("WeaponHitEvent")
                end
                return L.autoBarrel.GetNil("WeaponHitEvent", "1_1078763")
            end,
            attacks = {
                {dir = v3new(-554.95697021484, 74.62353515625, -861.18963623047), pos = v3new(0.89144998788834, -0.20049749314785, 0.40634661912918)},
                {dir = v3new(-554.94885253906, 74.613555908203, -861.21246337891), pos = v3new(0.89145004749298, -0.20049750804901, 0.4063466489315)},
                {dir = v3new(-554.80456542969, 74.607223510742, -861.53204345703), pos = v3new(0.89144998788834, -0.20049747824669, 0.40634661912918)},
                {dir = v3new(-554.80450439453, 74.650886535645, -861.51062011719), pos = v3new(0.89144998788834, -0.20049747824669, 0.40634658932686)},
                {dir = v3new(-554.61352539062, 74.701675415039, -861.904296875), pos = v3new(0.89146828651428, -0.20056135952473, 0.40627485513687)},
                {dir = v3new(-554.65277099609, 74.588844299316, -861.87408447266), pos = v3new(0.89143723249435, -0.20055986940861, 0.40634372830391)},
                {dir = v3new(-554.66430664062, 74.60164642334, -861.84259033203), pos = v3new(0.89144998788834, -0.20049746334553, 0.40634655952454)},
                {dir = v3new(-554.64031982422, 74.705497741699, -861.84387207031), pos = v3new(0.89144998788834, -0.20049747824669, 0.40634658932686)},
                {dir = v3new(-553.95574951172, 74.826881408691, -867.04382324219), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509974420071)},
                {dir = v3new(-553.93518066406, 74.665885925293, -866.67437744141), pos = v3new(0.96702569723129, -0.2093018591404, -0.14509975910187)},
                {dir = v3new(-553.91741943359, 74.855194091797, -866.82928466797), pos = v3new(0.96702569723129, -0.2093018591404, -0.14509974420071)},
                {dir = v3new(-553.90856933594, 74.832626342773, -866.73748779297), pos = v3new(0.96702569723129, -0.20930187404156, -0.14509974420071)},
                {dir = v3new(-553.47955322266, 77.10033416748, -864.25891113281), pos = v3new(0.96619528532028, -0.19930882751942, 0.16353197395802)},
                {dir = v3new(-553.43859863281, 77.008201599121, -864.62286376953), pos = v3new(0.96637833118439, -0.20918299257755, 0.14951710402966)},
                {dir = v3new(-554.34552001953, 74.506759643555, -865.58099365234), pos = v3new(0, -1, 0)},
                {dir = v3new(-553.60217285156, 76.671035766602, -864.05755615234), pos = v3new(0.96619522571564, -0.19930882751942, 0.16353197395802)},
                {dir = v3new(-553.59204101562, 76.678283691406, -864.10870361328), pos = v3new(0.96619528532028, -0.19930881261826, 0.16353197395802)},
                {dir = v3new(-554.05419921875, 74.549247741699, -867.29949951172), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509975910187)},
                {dir = v3new(-554.04681396484, 74.529609680176, -867.22210693359), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509975910187)},
                {dir = v3new(-553.81262207031, 74.886436462402, -866.17590332031), pos = v3new(0.96702569723129, -0.20930184423923, -0.14509974420071)},
                {dir = v3new(-553.81182861328, 74.88818359375, -866.17291259766), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509975910187)},
                {dir = v3new(-553.91674804688, 74.664245605469, -866.54919433594), pos = v3new(0.96702575683594, -0.20930188894272, -0.14509975910187)},
                {dir = v3new(-554.65258789062, 74.563323974609, -861.88708496094), pos = v3new(0.89145004749298, -0.20049749314785, 0.40634661912918)},
                {dir = v3new(-554.68707275391, 74.510047912598, -861.83758544922), pos = v3new(0.89146840572357, -0.20056138932705, 0.40627494454384)},
                {dir = v3new(-553.98034667969, 74.562789916992, -866.82659912109), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509975910187)},
                {dir = v3new(-553.99169921875, 74.515762329102, -866.83477783203), pos = v3new(0.96702575683594, -0.20930187404156, -0.14509974420071)},
                {dir = v3new(-553.42510986328, 77.443626403809, -864.16217041016), pos = v3new(0.96619522571564, -0.19930879771709, 0.16353195905685)},
                {dir = v3new(-554.67132568359, 74.796897888184, -861.73077392578), pos = v3new(0.89145004749298, -0.20049753785133, 0.40634655952454)},
                {dir = v3new(-553.35321044922, 77.731552124023, -864.23602294922), pos = v3new(0.96619522571564, -0.19930881261826, 0.16353197395802)},
                {dir = v3new(-553.48864746094, 76.523376464844, -864.97766113281), pos = v3new(0.96637833118439, -0.20918299257755, 0.14951710402966)},
                {dir = v3new(-554.21154785156, 74.73511505127, -862.81683349609), pos = v3new(0.96619522571564, -0.19930878281593, 0.16353194415569)},
                {dir = v3new(-554.95904541016, 74.620277404785, -861.18670654297), pos = v3new(0.89144998788834, -0.20049749314785, 0.4063466489315)},
            }
        },
    },

    ClearMarkers = function()
        for _, m in L.autoBarrel.markers do
            if m and m.Parent then
                m:Destroy()
            end
        end
        L.autoBarrel.markers = {}
    end,

    MainLoop = function()
        while L.autoBarrel.enabled do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root then
                local currentZone
                for _, z in L.autoBarrel.zones do
                    local barrel = z.getBarrel()
                    if barrel and barrel.Parent then
                        local dist = (root.Position - z.markerPos).Magnitude
                        if dist <= 7 then
                            currentZone = z
                            currentZone.barrelObj = barrel
                            break
                        end
                    end
                end

                if currentZone and L.autoBarrel.activeZone ~= currentZone then
                    L.autoBarrel.activeZone = currentZone
                    L.autoBarrel.idx = 1
                    local tool = L.autoBarrel.FindAxe()
                    if tool then
                        L.autoBarrel.EquipAxe(tool)
                        task.wait(0.3)
                    end
                end

                if not currentZone and L.autoBarrel.activeZone then
                    L.autoBarrel.activeZone = nil
                end

                if L.autoBarrel.activeZone and currentZone then
                    local event = L.autoBarrel.GetEvent()
                    if event then
                        local zone = L.autoBarrel.activeZone
                        if not zone.barrelObj or not zone.barrelObj.Parent then
                            zone.barrelObj = zone.getBarrel()
                        end
                        if zone.barrelObj and zone.barrelObj.Parent then
                            local a = zone.attacks[L.autoBarrel.idx]
                            pcall(event.FireServer, event, "PrepareSwing")
                            pcall(event.FireServer, event, "Swing", "Side")
                            pcall(event.FireServer, event, "WeaponHitEvent", zone.barrelObj, a.dir, a.pos)
                        end
                        L.autoBarrel.idx = L.autoBarrel.idx + 1
                        if L.autoBarrel.idx > #zone.attacks then
                            L.autoBarrel.idx = 1
                        end
                    end
                end
            else
                if L.autoBarrel.activeZone then
                    local tool = L.autoBarrel.FindAxe()
                    if tool then pcall(L.autoBarrel.UnequipAxe, tool) end
                    L.autoBarrel.activeZone = nil
                end
            end

            task.wait(0.1)
        end
    end,

    Start = function()
        if L.autoBarrel.enabled then return end
        L.autoBarrel.enabled = true

        L.autoBarrel.ClearMarkers()
        for _, z in L.autoBarrel.zones do
            local marker = L.autoBarrel.CreateMarker(z.markerPos, z.markerText)
            table.insert(L.autoBarrel.markers, marker)
        end

        if L.autoBarrel.thread then task.cancel(L.autoBarrel.thread) end
        L.autoBarrel.thread = task.spawn(L.autoBarrel.MainLoop)
        L.notify(TranslateText("自动打酒桶已开启"), 2)
    end,

    Stop = function()
        L.autoBarrel.enabled = false
        if L.autoBarrel.thread then
            task.cancel(L.autoBarrel.thread)
            L.autoBarrel.thread = nil
        end
        L.autoBarrel.ClearMarkers()
        L.autoBarrel.activeZone = nil
        L.autoBarrel.idx = 1
        L.notify(TranslateText("自动打酒桶已关闭"), 2)
    end
}

AutoFuncGroup:AddToggle('AutoBarrelToggle', {
    Text = '自动打酒桶',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击伦敦酒桶'),
    Callback = function(v)
        if v then
            L.autoBarrel.Start()
        else
            L.autoBarrel.Stop()
        end
    end
})

L.autoWestminster = {
    enabled = false,
    thread = nil,
    AttackInterval = 0.1,
    AttackRange = 15,
    _tmp = {}
}

function L.autoWestminster.getTargetParts()
    L.autoWestminster._tmp.west = workspace:FindFirstChild("Westminster")
    if not L.autoWestminster._tmp.west then return {} end
    L.autoWestminster._tmp.modes = L.autoWestminster._tmp.west:FindFirstChild("Modes")
    if not L.autoWestminster._tmp.modes then return {} end
    L.autoWestminster._tmp.obj = L.autoWestminster._tmp.modes:FindFirstChild("Objective")
    if not L.autoWestminster._tmp.obj then return {} end
    L.autoWestminster._tmp.barricade = L.autoWestminster._tmp.obj:FindFirstChild("StreetBarricade")
    if not L.autoWestminster._tmp.barricade then return {} end
    L.autoWestminster._tmp.model = L.autoWestminster._tmp.barricade:FindFirstChild("Model")
    if not L.autoWestminster._tmp.model then return {} end
    L.autoWestminster._tmp.boundingBox = L.autoWestminster._tmp.model:FindFirstChild("BoundingBox")
    if not L.autoWestminster._tmp.boundingBox then return {} end

    L.autoWestminster._tmp.parts = {}
    if L.autoWestminster._tmp.boundingBox:IsA("BasePart") then
        L.autoWestminster._tmp.parts[#L.autoWestminster._tmp.parts + 1] = L.autoWestminster._tmp.boundingBox
    end
    L.autoWestminster._tmp.children = L.autoWestminster._tmp.boundingBox:GetDescendants()
    for i = 1, #L.autoWestminster._tmp.children do
        if L.autoWestminster._tmp.children[i]:IsA("BasePart") then
            L.autoWestminster._tmp.parts[#L.autoWestminster._tmp.parts + 1] = L.autoWestminster._tmp.children[i]
        end
    end
    return L.autoWestminster._tmp.parts
end

function L.autoWestminster.getNearestTarget(playerPos)
    L.autoWestminster._tmp.parts = L.autoWestminster.getTargetParts()
    L.autoWestminster._tmp.bestPart = nil
    L.autoWestminster._tmp.bestDist = L.autoWestminster.AttackRange + 1
    for i = 1, #L.autoWestminster._tmp.parts do
        L.autoWestminster._tmp.dist = (L.autoWestminster._tmp.parts[i].Position - playerPos).Magnitude
        if L.autoWestminster._tmp.dist < L.autoWestminster._tmp.bestDist then
            L.autoWestminster._tmp.bestDist = L.autoWestminster._tmp.dist
            L.autoWestminster._tmp.bestPart = L.autoWestminster._tmp.parts[i]
        end
    end
    if not L.autoWestminster._tmp.bestPart then return nil, nil, nil, nil end
    L.autoWestminster._tmp.hitPos = L.autoWestminster._tmp.bestPart.Position
    L.autoWestminster._tmp.normal = (playerPos - L.autoWestminster._tmp.hitPos).Unit
    return L.autoWestminster._tmp.bestPart, L.autoWestminster._tmp.hitPos, L.autoWestminster._tmp.normal, L.autoWestminster._tmp.bestDist
end

function L.autoWestminster.getCurrentWeaponRemote()
    return L.getHeldToolRemote()
end

function L.autoWestminster.performAttack(remote, targetPart, hitPos, normal)
    if not remote then return end
    remote:FireServer("PrepareSwing")
    task.wait(0.02)
    remote:FireServer("Swing", "Side")
    task.wait(0.02)
    remote:FireServer("HitCon", targetPart, hitPos, normal)
end

function L.autoWestminster.attackLoop()
    while L.autoWestminster.enabled do
        L.autoWestminster._tmp.remote, L.autoWestminster._tmp.weapon = L.autoWestminster.getCurrentWeaponRemote()
        if L.autoWestminster._tmp.remote and L.autoWestminster._tmp.weapon and LocalPlayer.Character then
            L.autoWestminster._tmp.root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if L.autoWestminster._tmp.root then
                L.autoWestminster._tmp.tPart, L.autoWestminster._tmp.hPos, L.autoWestminster._tmp.normal, L.autoWestminster._tmp.dist = L.autoWestminster.getNearestTarget(L.autoWestminster._tmp.root.Position)
                if L.autoWestminster._tmp.tPart and L.autoWestminster._tmp.dist <= L.autoWestminster.AttackRange then
                    L.autoWestminster.performAttack(L.autoWestminster._tmp.remote, L.autoWestminster._tmp.tPart, L.autoWestminster._tmp.hPos, L.autoWestminster._tmp.normal)
                end
            end
        end
        task.wait(L.autoWestminster.AttackInterval)
    end
end

function L.autoWestminster.Start()
    if L.autoWestminster.enabled then return end
    L.autoWestminster.enabled = true
    if L.autoWestminster.thread then task.cancel(L.autoWestminster.thread) end
    L.autoWestminster.thread = task.spawn(L.autoWestminster.attackLoop)
    L.notify(TranslateText("自动打威斯特敏障碍已开启"), 2)
end

function L.autoWestminster.Stop()
    L.autoWestminster.enabled = false
    if L.autoWestminster.thread then
        task.cancel(L.autoWestminster.thread)
        L.autoWestminster.thread = nil
    end
    L.notify(TranslateText("自动打威斯特敏障碍已关闭"), 2)
end

AutoFuncGroup:AddToggle('AutoWestminsterToggle', {
    Text = '自动打威斯特敏障碍',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击威斯特敏路障'),
    Callback = function(v)
        if v then L.autoWestminster.Start() else L.autoWestminster.Stop() end
    end
})

L.autoLeipzigBarricade = {
    enabled = false,
    thread = nil,
    AttackInterval = 0.3,
    _tmp = {}
}

function L.autoLeipzigBarricade.getTarget()
    L.autoLeipzigBarricade._tmp.leipzig = workspace:FindFirstChild("Leipzig")
    if not L.autoLeipzigBarricade._tmp.leipzig then return nil end
    L.autoLeipzigBarricade._tmp.modes = L.autoLeipzigBarricade._tmp.leipzig:FindFirstChild("Modes")
    if not L.autoLeipzigBarricade._tmp.modes then return nil end
    L.autoLeipzigBarricade._tmp.objective = L.autoLeipzigBarricade._tmp.modes:FindFirstChild("Objective")
    if not L.autoLeipzigBarricade._tmp.objective then return nil end
    L.autoLeipzigBarricade._tmp.barricade = L.autoLeipzigBarricade._tmp.objective:FindFirstChild("Barricade")
    if not L.autoLeipzigBarricade._tmp.barricade then return nil end
    return L.autoLeipzigBarricade._tmp.barricade:FindFirstChild("Hitbox")
end

function L.autoLeipzigBarricade.getCurrentWeaponRemote()
    return L.getHeldToolRemote()
end

function L.autoLeipzigBarricade.performAttack(remote, targetPart)
    if not remote or not targetPart then return end
    L.autoLeipzigBarricade._tmp.hitPos = v3new(-154.15071105957, -6.2045636177063, -95.362197875977)
    L.autoLeipzigBarricade._tmp.normal = v3new(0.25880479812622, 0, 0.96592962741852)
    remote:FireServer("PrepareSwing")
    task.wait(0.02)
    remote:FireServer("Swing", "Side")
    task.wait(0.02)
    remote:FireServer("HitCon", targetPart, L.autoLeipzigBarricade._tmp.hitPos, L.autoLeipzigBarricade._tmp.normal)
end

function L.autoLeipzigBarricade.attackLoop()
    while L.autoLeipzigBarricade.enabled do
        L.autoLeipzigBarricade._tmp.remote, L.autoLeipzigBarricade._tmp.weapon = L.autoLeipzigBarricade.getCurrentWeaponRemote()
        L.autoLeipzigBarricade._tmp.target = L.autoLeipzigBarricade.getTarget()
        if L.autoLeipzigBarricade._tmp.remote and L.autoLeipzigBarricade._tmp.target then
            L.autoLeipzigBarricade.performAttack(L.autoLeipzigBarricade._tmp.remote, L.autoLeipzigBarricade._tmp.target)
        end
        task.wait(L.autoLeipzigBarricade.AttackInterval)
    end
end

function L.autoLeipzigBarricade.Start()
    if L.autoLeipzigBarricade.enabled then return end
    L.autoLeipzigBarricade.enabled = true
    if L.autoLeipzigBarricade.thread then task.cancel(L.autoLeipzigBarricade.thread) end
    L.autoLeipzigBarricade.thread = task.spawn(L.autoLeipzigBarricade.attackLoop)
    L.notify(TranslateText("自动打莱比锡木板已开启"), 2)
end

function L.autoLeipzigBarricade.Stop()
    L.autoLeipzigBarricade.enabled = false
    if L.autoLeipzigBarricade.thread then
        task.cancel(L.autoLeipzigBarricade.thread)
        L.autoLeipzigBarricade.thread = nil
    end
    L.notify(TranslateText("自动打莱比锡木板已关闭"), 2)
end

AutoFuncGroup:AddToggle('AutoLeipzigToggle', {
    Text = '自动打莱比锡木板',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击莱比锡木板'),
    Callback = function(v)
        if v then L.autoLeipzigBarricade.Start() else L.autoLeipzigBarricade.Stop() end
    end
})

L.autoCopenhagenGate = {
    enabled = false,
    thread = nil,
    AttackRange = 5,
    AttackInterval = 0.2,
    _tmp = {}
}

function L.autoCopenhagenGate.getTarget()
    L.autoCopenhagenGate._tmp.copenhagen = workspace:FindFirstChild("Copenhagen")
    if not L.autoCopenhagenGate._tmp.copenhagen then return nil end
    L.autoCopenhagenGate._tmp.modes = L.autoCopenhagenGate._tmp.copenhagen:FindFirstChild("Modes")
    if not L.autoCopenhagenGate._tmp.modes then return nil end
    L.autoCopenhagenGate._tmp.obj = L.autoCopenhagenGate._tmp.modes:FindFirstChild("Objective")
    if not L.autoCopenhagenGate._tmp.obj then return nil end
    L.autoCopenhagenGate._tmp.gateObj = L.autoCopenhagenGate._tmp.obj:FindFirstChild("GateObj")
    if not L.autoCopenhagenGate._tmp.gateObj then return nil end
    L.autoCopenhagenGate._tmp.gate = L.autoCopenhagenGate._tmp.gateObj:FindFirstChild("Gate")
    if not L.autoCopenhagenGate._tmp.gate then return nil end
    return L.autoCopenhagenGate._tmp.gate:FindFirstChild("Lock")
end

function L.autoCopenhagenGate.getCurrentWeaponRemote()
    return L.getHeldToolRemote()
end

function L.autoCopenhagenGate.performAttack(remote, target)
    if not remote or not target then return end
    L.autoCopenhagenGate._tmp.hitPos = v3new(62.246265411377, 9.1976232528687, -45.480701446533)
    L.autoCopenhagenGate._tmp.normal = v3new(0.90587776899338, 0.034834560006857, -0.42210423946381)
    remote:FireServer("PrepareSwing")
    task.wait(0.02)
    remote:FireServer("Swing", "Thrust")
    task.wait(0.02)
    remote:FireServer("HitCon", target, L.autoCopenhagenGate._tmp.hitPos, L.autoCopenhagenGate._tmp.normal)
end

function L.autoCopenhagenGate.attackLoop()
    while L.autoCopenhagenGate.enabled do
        L.autoCopenhagenGate._tmp.remote, L.autoCopenhagenGate._tmp.weapon = L.autoCopenhagenGate.getCurrentWeaponRemote()
        L.autoCopenhagenGate._tmp.target = L.autoCopenhagenGate.getTarget()
        if L.autoCopenhagenGate._tmp.remote and L.autoCopenhagenGate._tmp.target then
            if LocalPlayer.Character then
                L.autoCopenhagenGate._tmp.root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if L.autoCopenhagenGate._tmp.root then
                    L.autoCopenhagenGate._tmp.dist = (L.autoCopenhagenGate._tmp.root.Position - L.autoCopenhagenGate._tmp.target.Position).Magnitude
                    if L.autoCopenhagenGate._tmp.dist <= L.autoCopenhagenGate.AttackRange then
                        L.autoCopenhagenGate.performAttack(L.autoCopenhagenGate._tmp.remote, L.autoCopenhagenGate._tmp.target)
                    end
                end
            end
        end
        task.wait(L.autoCopenhagenGate.AttackInterval)
    end
end

function L.autoCopenhagenGate.Start()
    if L.autoCopenhagenGate.enabled then return end
    L.autoCopenhagenGate.enabled = true
    if L.autoCopenhagenGate.thread then task.cancel(L.autoCopenhagenGate.thread) end
    L.autoCopenhagenGate.thread = task.spawn(L.autoCopenhagenGate.attackLoop)
    L.notify(TranslateText("自动打哥本哈根锁已开启"), 2)
end

function L.autoCopenhagenGate.Stop()
    L.autoCopenhagenGate.enabled = false
    if L.autoCopenhagenGate.thread then
        task.cancel(L.autoCopenhagenGate.thread)
        L.autoCopenhagenGate.thread = nil
    end
    L.notify(TranslateText("自动打哥本哈根锁已关闭"), 2)
end

AutoFuncGroup:AddToggle('AutoCopenhagenToggle', {
    Text = '自动打哥本哈根锁',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击哥本哈根门锁'),
    Callback = function(v)
        if v then L.autoCopenhagenGate.Start() else L.autoCopenhagenGate.Stop() end
    end
})

L.autoCannon = {
    enabled = false,
    connection = nil,
    lastReloadTime = 0,
    reloadCooldown = 0.5
}

function L.autoCannon.findNearestGun()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearestGun = nil
    local shortestDistance = mathHuge

    for _, gunModel in workspace:GetDescendants() do
        if gunModel.Name == "12 Pound Gun" and gunModel:IsA("Model") then
            local hole = gunModel:FindFirstChild("Gun") and gunModel.Gun:FindFirstChild("Hole")
            if hole then
                local dist = (hole.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearestGun = gunModel
                end
            end
        end
    end
    return nearestGun
end

function L.autoCannon.reload()
    local now = tick_()
    if now - L.autoCannon.lastReloadTime < L.autoCannon.reloadCooldown then return end

    local gun = L.autoCannon.findNearestGun()
    if gun then
        local interact = gun:FindFirstChild("Gun") and gun.Gun:FindFirstChild("Hole") and gun.Gun.Hole:FindFirstChild("Interact")
        if interact and interact:IsA("RemoteEvent") then
            interact:FireServer()
            L.autoCannon.lastReloadTime = now
        end
    end
end

function L.startAutoCannon()
    L.stopAutoCannon()
    L.autoCannon.enabled = true
    L.autoCannon.connection = RunService.Heartbeat:Connect(L.autoCannon.reload)
    L.notify(TranslateText("自动装填大炮已开启"), 2)
end

function L.stopAutoCannon()
    L.autoCannon.enabled = false
    if L.autoCannon.connection then
        L.autoCannon.connection:Disconnect()
        L.autoCannon.connection = nil
    end
    L.notify(TranslateText("自动装填大炮已关闭"), 2)
end

AutoFuncGroup:AddToggle('AutoCannonToggle', {
    Text = '自动装填大炮',
    Default = false,
    Tooltip = TranslateTooltip('自动装填最近的12磅炮'),
    Callback = function(v)
        if v then L.startAutoCannon() else L.stopAutoCannon() end
    end
})

L.autoBell = { enabled = false, conn = nil }
function L.autoBell.start()
    if L.autoBell.conn then return end
    L.autoBell.enabled = true
    L.autoBell.conn = RunService.Heartbeat:Connect(function()
        if not L.autoBell.enabled then return end
        local leipzig = workspace:FindFirstChild("Leipzig")
        if leipzig and leipzig:FindFirstChild("Modes") then
            local modes = leipzig.Modes
            if modes:FindFirstChild("Objective") then
                local bell = modes.Objective:FindFirstChild("BellInteract")
                if bell and bell:FindFirstChild("Interact") then
                    pcall(function() bell.Interact:FireServer() end)
                end
            end
        end
    end)
end
function L.autoBell.stop()
    L.autoBell.enabled = false
    if L.autoBell.conn then L.autoBell.conn:Disconnect(); L.autoBell.conn = nil end
end
AutoFuncGroup:AddToggle('AutoBellToggle', {
    Text = '莱比锡自动拉铃',
    Default = false,
    Tooltip = TranslateTooltip('自动拉响莱比锡钟楼铃铛'),
    Callback = function(v) if v then L.autoBell.start() else L.autoBell.stop() end end
})


L.LondonBoardAuto = { enabled = false, heartbeat = nil, refPos = v3new(-149.42, 31.08, -1354.90), range = 7 }
function L.LondonBoardAuto.getWeaponRemote()
    return L.getHeldToolRemote()
end
L.LondonBoardAuto.cachedLeft = nil
L.LondonBoardAuto.cachedRight = nil
local function getLondonBoards()
    local left, right = L.LondonBoardAuto.cachedLeft, L.LondonBoardAuto.cachedRight
    if left and right and left.Parent and right.Parent then
        return left, right
    end
    local ok, l, r = pcall(function()
        local london = workspace:FindFirstChild("London")
        if not london then return nil, nil end
        return london.Modes.Objective.SniperSection.BarricadedDoors.Left.Boards,
               london.Modes.Objective.SniperSection.BarricadedDoors.Right.Boards
    end)
    if not ok then return nil, nil end
    L.LondonBoardAuto.cachedLeft = l
    L.LondonBoardAuto.cachedRight = r
    return l, r
end
function L.LondonBoardAuto.execute()
    if not L.LondonBoardAuto.enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - L.LondonBoardAuto.refPos).Magnitude > L.LondonBoardAuto.range then return end
    local remote = L.LondonBoardAuto.getWeaponRemote()
    if not remote then return end
    local left, right = getLondonBoards()
    if not left or not right then return end
    local tasks = {
        function() remote:FireServer("PrepareSwing") end,
        function() remote:FireServer("Swing", "Over") end,
        function() remote:FireServer("HitCon", left:GetChildren()[2], v3new(-149.4207611084, 31.076683044434, -1354.8972167969), v3new(-2.0772218704224e-05, 1, 7.62939453125e-05)) end,
        function() remote:FireServer("HitCon", right:GetChildren()[2], v3new(-145.2381439209, 33.006237030029, -1366.2482910156), v3new(0.9428722858429, 7.62939453125e-05, 0.33315423130989)) end,
        function() remote:FireServer("HitCon", left:GetChildren()[2], v3new(-149.55505371094, 29.676874160767, -1354.62890625), v3new(-0.94289720058441, 5.8412551879883e-06, -0.33308377861977)) end,
        function() remote:FireServer("HitCon", left:GetChildren()[2], v3new(-149.55505371094, 29.676874160767, -1354.62890625), v3new(-0.94289720058441, 5.8412551879883e-06, -0.33308377861977)) end,
        function() remote:FireServer("HitCon", left:GetChildren()[2], v3new(-150.27769470215, 29.679218292236, -1351.9827880859), v3new(0.94289720058441, -5.8412551879883e-06, 0.33308377861977)) end,
        function() remote:FireServer("HitCon", right:GetChildren()[2], v3new(-146.18898010254, 32.863513946533, -1363.5573730469), v3new(0.9428722858429, 7.62939453125e-05, 0.33315423130989)) end,
    }
    for _, fn in tasks do pcall(fn) end
end
function L.LondonBoardAuto.start()
    if L.LondonBoardAuto.thread then return end
    L.LondonBoardAuto.enabled = true
    L.LondonBoardAuto.thread = task.spawn(function()
        while L.LondonBoardAuto.enabled do
            L.LondonBoardAuto.execute()
            task.wait(0.1)
        end
    end)
end
function L.LondonBoardAuto.stop()
    L.LondonBoardAuto.enabled = false
    if L.LondonBoardAuto.thread then task.cancel(L.LondonBoardAuto.thread); L.LondonBoardAuto.thread = nil end
end
AutoFuncGroup:AddToggle('LondonBoardToggle', {
    Text = '自动打伦敦四块木板',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击伦敦狙神处四块木板'),
    Callback = function(v) if v then L.LondonBoardAuto.start() else L.LondonBoardAuto.stop() end end
})


L.autoBandage = { enabled = false, thread = nil, cooldown = 0, healedOnce = false }
function L.autoBandage.getHealth()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health or 0
end
function L.autoBandage.getMaxHealth()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.MaxHealth or 100
end
function L.autoBandage.findBandage()
    local char = LocalPlayer.Character
    if char then
        for _, t in char:GetChildren() do
            if t:IsA("Tool") and t.Name:lower():find("bandage") then return t end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, t in backpack:GetChildren() do
            if t:IsA("Tool") and t.Name:lower():find("bandage") then return t end
        end
    end
    return nil
end
function L.autoBandage.zombieNear(pos, range)
    for _, folderName in {"Zombies", "Camera"} do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, v in folder:GetDescendants() do
                if v:IsA("Model") and v.Name == "m_Zombie" then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - pos).Magnitude <= range then return true end
                end
            end
        end
    end
    return false
end
function L.autoBandage.loop()
    while L.autoBandage.enabled do
        task.wait(0.5)
        local hp = L.autoBandage.getHealth()
        local maxHp = L.autoBandage.getMaxHealth()
        local pct = (hp / maxHp) * 100
        if hp >= maxHp then
            L.autoBandage.healedOnce = false
            continue
        end
        if pct < 50 then L.autoBandage.healedOnce = false end
        if L.autoBandage.healedOnce and pct >= 50 then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and L.autoBandage.zombieNear(root.Position, 5) then continue end
        local bandage = L.autoBandage.findBandage()
        if not bandage then continue end
        if tick_() - L.autoBandage.cooldown < 1 then continue end
        L.autoBandage.cooldown = tick_()
        if bandage.Parent ~= char then
            pcall(function() bandage.Parent = char end)
            task.wait(0.3)
        end
        local remote = bandage:FindFirstChild("RemoteEvent")
        if remote then
            pcall(function() remote:FireServer() end)
            L.autoBandage.healedOnce = true
        end
        task.wait(1)
    end
end
function L.autoBandage.start()
    if L.autoBandage.thread then return end
    L.autoBandage.enabled = true
    L.autoBandage.healedOnce = false
    L.autoBandage.thread = task.spawn(L.autoBandage.loop)
end
function L.autoBandage.stop()
    L.autoBandage.enabled = false
    L.autoBandage.healedOnce = false
    if L.autoBandage.thread then task.cancel(L.autoBandage.thread); L.autoBandage.thread = nil end
end
AutoFuncGroup:AddToggle('AutoBandageToggle', {
    Text = '自动打绷带',
    Default = false,
    Tooltip = TranslateTooltip('血量低于75%时自动使用绷带（仅一次，低于50%重置）'),
    Callback = function(v) if v then L.autoBandage.start() else L.autoBandage.stop() end end
})


L.autoWatch = { enabled = false, thread = nil, range = 5, done = false }
function L.autoWatch.getModelPos(model)
    local cf = model:GetPivot()
    if cf then return cf.Position end
    for _, v in model:GetDescendants() do if v:IsA("BasePart") then return v.Position end end
    return nil
end
function L.autoWatch.getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
function L.autoWatch.loop()
    L.autoWatch.done = false
    while L.autoWatch.enabled and not L.autoWatch.done do
        task.wait(0.2)
        local hrp = L.autoWatch.getHRP()
        if not hrp then task.wait(0.5); continue end
        local west = workspace:FindFirstChild("Westminster")
        if not west then continue end
        local modes = west:FindFirstChild("Modes")
        if not modes then continue end
        local objective = modes:FindFirstChild("Objective")
        if not objective then continue end
        local scene = objective:FindFirstChild("WellingtonScene")
        if not scene then continue end
        local watch = scene:FindFirstChild("Pocket Watch")
        if watch then
            local prompt = watch:FindFirstChild("ProximityPrompt")
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local wPos = L.autoWatch.getModelPos(watch)
                if wPos and (wPos - hrp.Position).Magnitude <= L.autoWatch.range then
                    pcall(function() fireproximityprompt(prompt) end)
                    if prompt.HoldDuration > 0 then
                        for _ = 1, 50 do
                            pcall(function() fireproximityprompt(prompt) end)
                            task.wait(0.01)
                        end
                    end
                end
            end
        else
            L.autoWatch.done = true
            pcall(function()
                L.notify(TranslateText("自动拿怀表已完成"), 2)
            end)
        end
    end
    if L.autoWatch.done then L.autoWatch.enabled = false; L.autoWatch.thread = nil end
end
function L.autoWatch.start()
    if L.autoWatch.thread then return end
    L.autoWatch.enabled = true
    L.autoWatch.done = false
    L.autoWatch.thread = task.spawn(L.autoWatch.loop)
end
function L.autoWatch.stop()
    L.autoWatch.enabled = false
    L.autoWatch.done = false
    if L.autoWatch.thread then task.cancel(L.autoWatch.thread); L.autoWatch.thread = nil end
end
AutoFuncGroup:AddToggle('AutoWatchToggle', {
    Text = '自动拿怀表',
    Default = false,
    Tooltip = TranslateTooltip('自动拾取威斯敏斯特怀表'),
    Callback = function(v) if v then L.autoWatch.start() else L.autoWatch.stop() end end
})

L.autoFlag = { enabled = false, thread = nil, range = 5, done = false }
function L.autoFlag.getHRP() return L.autoWatch.getHRP() end
function L.autoFlag.getModelPos(model) return L.autoWatch.getModelPos(model) end
function L.autoFlag.loop()
    L.autoFlag.done = false
    while L.autoFlag.enabled and not L.autoFlag.done do
        task.wait(0.3)
        local hrp = L.autoFlag.getHRP()
        if not hrp then task.wait(0.5); continue end
        for _, v in workspace:GetDescendants() do
            if v:IsA("ProximityPrompt") and v.Enabled then
                local part = v.Parent
                if part and part.Name == "Standard" and part:IsA("Model") then
                    local pPos = L.autoFlag.getModelPos(part)
                    if pPos and (pPos - hrp.Position).Magnitude <= L.autoFlag.range then
                        for _ = 1, 25 do
                            if not v.Enabled then break end
                            pcall(function() fireproximityprompt(v) end)
                            if v.HoldDuration > 0 then
                                for _ = 1, 30 do
                                    pcall(function() fireproximityprompt(v) end)
                                    task.wait(0.01)
                                end
                            end
                            task.wait(0.2)
                        end
                        L.autoFlag.done = true
                        pcall(function() L.notify(TranslateText("自动抢旗杆已完成"), 2) end)
                        break
                    end
                end
            end
        end
    end
    if L.autoFlag.done then L.autoFlag.enabled = false; L.autoFlag.thread = nil end
end
function L.autoFlag.start()
    if L.autoFlag.thread then return end
    L.autoFlag.enabled = true
    L.autoFlag.done = false
    L.autoFlag.thread = task.spawn(L.autoFlag.loop)
end
function L.autoFlag.stop()
    L.autoFlag.enabled = false
    L.autoFlag.done = false
    if L.autoFlag.thread then task.cancel(L.autoFlag.thread); L.autoFlag.thread = nil end
end
AutoFuncGroup:AddToggle('AutoFlagToggle', {
    Text = '自动抢旗杆',
    Default = false,
    Tooltip = TranslateTooltip('自动拾取威斯敏斯特旗杆'),
    Callback = function(v) if v then L.autoFlag.start() else L.autoFlag.stop() end end
})

L.autoAttackDoor = { enabled = false, thread = nil, range = 10, attackCooldown = 0.3 }
function L.autoAttackDoor.getWeaponRemote()
    return L.getHeldToolRemote()
end
function L.autoAttackDoor.findTargets()
    local char = LocalPlayer.Character
    if not char then return {} end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local pos = root.Position
    local targets = {}
    local seen = {}
    for _, v in workspace:GetDescendants() do
        if v:IsA("BasePart") and v.CanQuery ~= false and v.Parent then
            local dist = (v.Position - pos).Magnitude
            if dist <= L.autoAttackDoor.range then
                local name = v.Name:upper()
                if v.Name == "Main" or name:find("DOOR") or name:find("GATE") then
                    local key = tostring(v)
                    if not seen[key] then
                        seen[key] = true
                        table.insert(targets, { part = v, dist = dist })
                    end
                end
            end
        end
    end
    table.sort(targets, function(a,b) return a.dist < b.dist end)
    return targets
end
function L.autoAttackDoor.loop()
    while L.autoAttackDoor.enabled do
        local remote = L.autoAttackDoor.getWeaponRemote()
        if remote and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targets = L.autoAttackDoor.findTargets()
                if #targets > 0 then
                    local t = targets[1]
                    local hitPos = t.part.Position
                    local normal = (root.Position - hitPos).Unit
                    pcall(function()
                        remote:FireServer("PrepareSwing")
                        task.wait(0.02)
                        remote:FireServer("Swing", "Side")
                        task.wait(0.02)
                        remote:FireServer("HitCon", t.part, hitPos, normal)
                    end)
                    task.wait(L.autoAttackDoor.attackCooldown)
                end
            end
        end
        task.wait(0.1)
    end
end
function L.autoAttackDoor.start()
    if L.autoAttackDoor.thread then return end
    L.autoAttackDoor.enabled = true
    L.autoAttackDoor.thread = task.spawn(L.autoAttackDoor.loop)
end
function L.autoAttackDoor.stop()
    L.autoAttackDoor.enabled = false
    if L.autoAttackDoor.thread then task.cancel(L.autoAttackDoor.thread); L.autoAttackDoor.thread = nil end
end
AutoFuncGroup:AddToggle('AutoAttackDoorToggle', {
    Text = '自动攻击门',
    Default = false,
    Tooltip = TranslateTooltip('自动攻击附近的门'),
    Callback = function(v) if v then L.autoAttackDoor.start() else L.autoAttackDoor.stop() end end
})

L.autoFindDoctor = { enabled = false, thread = nil, threshold = 40, teleportCount = 0, maxTeleports = 2, prevHP = 100, trigger = 50 }
function L.autoFindDoctor.getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
function L.autoFindDoctor.getHealth() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); return hum and hum.Health or 0 end
function L.autoFindDoctor.getMaxHealth() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); return hum and hum.MaxHealth or 100 end
function L.autoFindDoctor.isDoctor(player)
    if player == LocalPlayer then return false end
    if player:GetAttribute("CurrentClass") == "Surgeon" then return true end
    local char = player.Character
    if char then
        if char:GetAttribute("CurrentClass") == "Surgeon" then return true end
        if char:FindFirstChild("MedicalSupplies") then return true end
        if char:FindFirstChild("Meter") then return true end
    end
    return false
end
function L.autoFindDoctor.hasSupplies(player)
    local char = player.Character
    if not char then return false end
    local meter = char:FindFirstChild("Meter")
    return meter and meter.Value > 0 or false
end
function L.autoFindDoctor.findNearestDoctor(myPos)
    local best, bestD = nil, 999
    for _, p in Players:GetPlayers() do
        if not L.autoFindDoctor.isDoctor(p) or not L.autoFindDoctor.hasSupplies(p) then continue end
        local char = p.Character
        local hrp = char and L.autoFindDoctor.getHRP(char)
        if not hrp then continue end
        local d = (hrp.Position - myPos).Magnitude
        if d < bestD then bestD = d; best = p end
    end
    return best, bestD
end
function L.autoFindDoctor.teleportToDoctor(doc)
    local dc = doc.Character
    local dh = dc and L.autoFindDoctor.getHRP(dc)
    if not dh then return false end
    local char = LocalPlayer.Character
    local hrp = char and L.autoFindDoctor.getHRP(char)
    if not hrp then return false end
    local target = dh.Position + dh.CFrame.LookVector * 2 + v3new(0, 1, 0)
    local ok = pcall(function() hrp.CFrame = cfNew(target) end)
    if not ok then return false end
    local freezeEnd = tick_() + 1
    while tick_() < freezeEnd do
        local c2 = LocalPlayer.Character
        local h2 = c2 and L.autoFindDoctor.getHRP(c2)
        if h2 then pcall(function() h2.CFrame = cfNew(target) end) end
        task.wait()
    end
    return true
end
function L.autoFindDoctor.loop()
    L.autoFindDoctor.teleportCount = 0
    L.autoFindDoctor.prevHP = 100
    L.autoFindDoctor.trigger = L.autoFindDoctor.threshold + 10
    while L.autoFindDoctor.enabled do
        task.wait(1)
        local char = LocalPlayer.Character
        local hrp = char and L.autoFindDoctor.getHRP(char)
        if not hrp then L.autoFindDoctor.teleportCount = 0; L.autoFindDoctor.prevHP = 100; continue end
        local hp = L.autoFindDoctor.getHealth()
        local maxHp = L.autoFindDoctor.getMaxHealth()
        local pct = hp / maxHp * 100
        if pct >= L.autoFindDoctor.trigger then
            if L.autoFindDoctor.teleportCount > 0 then print("[自动找医生] 血量恢复(" .. mathFloor(pct) .. "%)，重置") end
            L.autoFindDoctor.teleportCount = 0; L.autoFindDoctor.prevHP = hp; continue
        end
        if pct < L.autoFindDoctor.threshold then
            if hp > L.autoFindDoctor.prevHP then
                L.autoFindDoctor.teleportCount = 0; L.autoFindDoctor.prevHP = hp; continue
            end
            local doc, dist = L.autoFindDoctor.findNearestDoctor(hrp.Position)
            if not doc then L.autoFindDoctor.prevHP = hp; continue end
            if dist <= 20 then L.autoFindDoctor.teleportCount = 0; L.autoFindDoctor.prevHP = hp; continue end
            if L.autoFindDoctor.teleportCount < L.autoFindDoctor.maxTeleports then
                L.autoFindDoctor.teleportCount = L.autoFindDoctor.teleportCount + 1
                local ok = L.autoFindDoctor.teleportToDoctor(doc)
                if not ok then L.autoFindDoctor.teleportCount = L.autoFindDoctor.teleportCount - 1 end
            end
            L.autoFindDoctor.prevHP = hp
        else
            if L.autoFindDoctor.teleportCount > 0 and pct >= L.autoFindDoctor.threshold and pct < L.autoFindDoctor.trigger then
                if hp > L.autoFindDoctor.prevHP then L.autoFindDoctor.teleportCount = 0 end
            end
            L.autoFindDoctor.prevHP = hp
        end
    end
end
function L.autoFindDoctor.start()
    if L.autoFindDoctor.thread then return end
    L.autoFindDoctor.enabled = true
    L.autoFindDoctor.teleportCount = 0
    L.autoFindDoctor.prevHP = 100
    L.autoFindDoctor.trigger = L.autoFindDoctor.threshold + 10
    L.autoFindDoctor.thread = task.spawn(L.autoFindDoctor.loop)
end
function L.autoFindDoctor.stop()
    L.autoFindDoctor.enabled = false
    if L.autoFindDoctor.thread then task.cancel(L.autoFindDoctor.thread); L.autoFindDoctor.thread = nil end
    L.autoFindDoctor.teleportCount = 0; L.autoFindDoctor.prevHP = 100
end
AutoFuncGroup:AddToggle('AutoFindDoctorToggle', {
    Text = '自动找医生',
    Default = false,
    Tooltip = TranslateTooltip('血量低于阈值（默认40%）且还在掉血时传送至医生'),
    Callback = function(v) if v then L.autoFindDoctor.start() else L.autoFindDoctor.stop() end end
})
AutoFuncGroup:AddSlider('DoctorThreshold', {
    Text = '找医生血量阈值 (%)',
    Default = 40,
    Min = 1,
    Max = 100,
    Suffix = '%',
    Callback = function(v)
        L.autoFindDoctor.threshold = v
        L.autoFindDoctor.trigger = v + 10
    end
})

AutoFuncGroup:AddToggle('AutoHelpToggle', {
    Text = '自动求救',
    Default = false,
    Tooltip = TranslateTooltip('血量低于80%时自动发送语音求助'),
    Callback = function(v) if v then L.autoHelp.start() else L.autoHelp.stop() end end
})

L.autoDoorEnabled = false
L.autoDoorThread = nil
L.processingDoors = {}

function L.autoDoorLoop()
    while L.autoDoorEnabled do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, item in workspace:GetDescendants() do
                if item.Name == "Main" and item:IsA("Model") then
                    local ok, modelCFrame = pcall(function() return item:GetPivot() end)
                    if ok and modelCFrame and (root.Position - modelCFrame.Position).Magnitude <= 23 then
                        local isOpen = item:GetAttribute("Open")
                        if isOpen == nil then pcall(function() isOpen = item.Open end) end
                        if isOpen == false then
                            local mainPart = item:FindFirstChild("Main")
                            local remote = mainPart and mainPart:FindFirstChild("Interact")
                            if remote and remote:IsA("RemoteEvent") and not L.processingDoors[item] then
                                L.processingDoors[item] = true
                                task.spawn(function()
                                    remote:FireServer()
                                    task.wait(0)
                                    L.processingDoors[item] = nil
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0)
    end
end

function L.toggleAutoDoor(state)
    L.autoDoorEnabled = state
    if state then
        if not L.autoDoorThread then
            L.autoDoorThread = task.spawn(L.autoDoorLoop)
        end
    else
        if L.autoDoorThread then
            task.cancel(L.autoDoorThread)
            L.autoDoorThread = nil
        end
    end
end

AutoFuncGroup:AddToggle('AutoDoorToggle', {
    Text = '自动开门',
    Default = false,
    Tooltip = TranslateTooltip('自动开启附近场景中的门（适用于所有地图）'),
    Callback = function(v) L.toggleAutoDoor(v) end
})

L.waveNum = 1

function L.sendChatCmd(cmd)
    local ok = pcall(function()
        local tcs = game:GetService("TextChatService")
        tcs:FindFirstChild("TextChannels").RBXGeneral:SendAsync(cmd)
    end)
    if not ok then
        local events = ReplicatedStorage:FindFirstChild("Events")
        local chatUpdate = events and events:FindFirstChild("ChatUpdate")
        if chatUpdate then pcall(function() chatUpdate:FireServer(cmd) end) end
    end
end

local PVP = { _velHistory = {} } :: { [string]: any }

local PvpGroup = Tabs.AutoFunc:AddGroupbox({ Side = "Right", Name = "PVP 功能", IconName = "swords", Description = "战斗辅助" })

PvpGroup:AddToggle('PvpAimbotToggle', {
    Text = '开启自瞄',
    Default = false,
    Callback = function(state)
        if PVP and PVP.toggle then PVP.toggle(state) end
    end
})

PvpGroup:AddToggle('PvpSilentToggle', {
    Text = '启用静默',
    Default = false,
    Callback = function(state)
        PVP.silentMode = state
        if PVP.aimEnabled then
            if state then
                PVP.setupSilentHook()
            else
                PVP.removeSilentHook()
            end
        end
    end
})

PvpGroup:AddDropdown('PvpAimPart', {
    Text = '瞄准部位',
    Values = {"头部", "身体"},
    Value = "头部",
    FormatDisplayValue = function(Value)
        return InterfaceLanguage == "English" and (EnglishText[Value] or Value) or Value
    end,
    Callback = function(value)
        if PVP and PVP.setAimPart then PVP.setAimPart(value) end
    end
})

PvpGroup:AddSlider('PvpFOVSize', {
    Text = '瞄准大小',
    Default = 90,
    Min = 1,
    Max = 360,
    Suffix = "°",
    Callback = function(value)
        if PVP and PVP.setFOV then PVP.setFOV(value) end
    end
})

PvpGroup:AddToggle('PvpTeamCheck', {
    Text = '队伍检测',
    Default = false,
    Callback = function(state)
        if PVP and PVP.toggleTeamCheck then PVP.toggleTeamCheck(state) end
    end
})

PvpGroup:AddToggle('PvpWallCheck', {
    Text = '墙体检测',
    Default = true,
    Callback = function(state)
        if PVP and PVP.toggleWallCheck then PVP.toggleWallCheck(state) end
    end
})

PvpGroup:AddToggle('PvpPrediction', {
    Text = '子弹预判',
    Default = false,
    Callback = function(state)
        if PVP and PVP.togglePrediction then PVP.togglePrediction(state) end
    end
})

PvpGroup:AddToggle('PvpMeleeAura', {
    Text = '杀戮光环（近战）',
    Default = false,
    Tooltip = TranslateTooltip('体验虐杀的快感'),
    Callback = function(state)
        if PVP and PVP.toggleMelee then PVP.toggleMelee(state) end
    end
})

PvpGroup:AddToggle('PvpTeleport', {
    Text = '预判传送至敌方身后',
    Default = false,
    Tooltip = TranslateTooltip('预判传送'),
    Callback = function(state)
        if PVP and PVP.toggleTeleport then PVP.toggleTeleport(state) end
    end
})

PvpGroup:AddToggle('PvpForceEquip', {
    Text = '强制装备武器',
    Default = false,
    Tooltip = TranslateTooltip('持续装备近战武器'),
    Callback = function(state)
        if PVP and PVP.toggleForceEquip then PVP.toggleForceEquip(state) end
    end
})

do
    PVP.weaponSpeedMap = L.WEAPON_SPEED_MAP

    function PVP.getCurrentBulletSpeed()
        return L.sharedGetCurrentBulletSpeed()
    end

    function PVP.getPing()
        return L.sharedGetPing()
    end

    function PVP.getShotsLoaded()
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        return L.sharedGetShotsLoaded(tool)
    end

    PVP.aimEnabled = false
    PVP.aimPart = "Head"
    PVP.showFov = false
    PVP.fov = 90
    PVP.teamCheck = false
    PVP.prediction = false
    PVP.wallCheck = true
    PVP.aimConn = nil
    PVP.meleeEnabled = false
    PVP.meleeConn = nil
    PVP.tpEnabled = false
    PVP.tpThread = nil
    PVP.tpTarget = nil
    PVP.tpHighlight = nil
    PVP.bulletSpeed = 700

    PVP.silentMode = false
    PVP.silentHook = nil
    PVP.silentTarget = nil
    PVP._lastDistNotify = 0
    PVP._velHistory = {}
    PVP.lastNotifiedPlayer = nil


    PVP.indicatorData = nil
    PVP.indicatorPart = nil

    local function _isHoldingGun()
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        return L.sharedIsGun(tool)
    end


    local function isWallBlocking(origin, targetPos, targetModel)

        local offsets = {
            v3new(0,0,0),
            v3new(0.5,0.5,0.5),
            v3new(-0.5,0.5,-0.5),
            v3new(0.5,-0.5,0.5),
            v3new(-0.5,-0.5,-0.5),
            v3new(0.8,0,0),
            v3new(-0.8,0,0),
            v3new(0,0.8,0),
            v3new(0,-0.8,0),
        }
        local blocked = 0
        local total = #offsets
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {}
        for _, pl in Players:GetPlayers() do
            if pl.Character then
                table.insert(ignoreList, pl.Character)
            end
        end
        if targetModel then
            table.insert(ignoreList, targetModel)
        end
        rp.FilterDescendantsInstances = ignoreList

        for _, off in offsets do
            local pos = targetPos + off
            local ray = workspace:Raycast(origin, pos - origin, rp)
            if ray then
                local hit = ray.Instance
                if hit and hit:IsA("BasePart") and hit.CanCollide then
                    blocked = blocked + 1
                end
            end
        end

        return blocked > (total / 2)
    end


    local function _findBestTarget()
        local lp = LocalPlayer
        local mc = lp.Character
        if not mc then return nil end
        local mHead = mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart")
        if not mHead then return nil end
        local cam = workspace.CurrentCamera
        local best, bestD, bestDist = nil, mathHuge, mathHuge

        local bulletSpeed = PVP.getCurrentBulletSpeed()
        if bulletSpeed <= 0 then bulletSpeed = 700 end
        local ping = PVP.getPing()
        local pingDelay = ping / 1000

        if not PVP._velHistory then PVP._velHistory = {} end

        for _, p in Players:GetPlayers() do
            if p == lp then continue end
            if L.isMarked and L.isMarked(p) then continue end
            local c = p.Character
            if not c then continue end
            local hu = c:FindFirstChildOfClass("Humanoid")
            if not hu or hu.Health <= 0 then continue end
            if hu.Health > 1000 then continue end

            if PVP.teamCheck then
                local mt = L.getPlayerTeam(lp)
                local pt = L.getPlayerTeam(p)
                if mt and pt and mt == pt then continue end
            end

            local pt = c:FindFirstChild(PVP.aimPart) or c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if not pt then continue end

            local dist = (pt.Position - cam.CFrame.Position).Magnitude
            if dist > 1000 then continue end


            if PVP.wallCheck then
                if isWallBlocking(mHead.Position, pt.Position, c) then
                    continue
                end
            end

            if PVP.silentMode then
                if dist >= bestDist then continue end
                bestDist = dist
            else
                local pos, on = cam:WorldToViewportPoint(pt.Position)
                if not pos or not on then continue end
                local d2 = (v2new(pos.X, pos.Y) - cam.ViewportSize/2).Magnitude
                if d2 > PVP.fov or d2 >= bestD then continue end
                bestD = d2
            end

        local aimPos = pt.Position
        local predictedPos = nil

        if PVP.prediction and bulletSpeed > 0 then
            local rootPart = c:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local currentVel = rootPart.AssemblyLinearVelocity
                if currentVel and currentVel.Magnitude > 0.3 then
                    if not PVP._velHistory[p] then PVP._velHistory[p] = {} end
                    local hist = PVP._velHistory[p]
                    table.insert(hist, currentVel)
                    if #hist > 8 then table.remove(hist, 1) end

                    local avgVel = Vector3.new()
                    local totalWeight = 0
                    for i = 1, #hist do
                        local weight = i / #hist
                        avgVel = avgVel + hist[i] * weight
                        totalWeight = totalWeight + weight
                    end
                    if totalWeight > 0 then avgVel = avgVel / totalWeight end

                    local dirChange = 0
                    if #hist >= 2 then
                        local lastDir = hist[#hist-1].Unit
                        local currDir = hist[#hist].Unit
                        local dot = lastDir:Dot(currDir)
                        dirChange = 1 - math.abs(dot)
                    end

                    local speedChange = 0
                    if #hist >= 2 then
                        local lastSpeed = hist[#hist-1].Magnitude
                        local currSpeed = hist[#hist].Magnitude
                        if lastSpeed > 0.1 then
                            speedChange = math.abs(currSpeed - lastSpeed) / lastSpeed
                        end
                    end

                    local baseCoeff = 1.0
                    local penalty = math.min(1, (dirChange * 0.8 + speedChange * 0.4))
                    local adaptiveCoeff = baseCoeff * (1 - penalty * 0.6)

                    local travelTime = dist / bulletSpeed
                    local totalDelay = travelTime + pingDelay

                    local horizontalVel = Vector3.new(avgVel.X, 0, avgVel.Z)
                    local predictedOffset = horizontalVel * totalDelay * adaptiveCoeff

                    local maxOffset = math.min(12, dist * 0.1)
                    local offsetMag = predictedOffset.Magnitude
                    if offsetMag > maxOffset then
                        predictedOffset = predictedOffset.Unit * maxOffset
                    end

                    local vertVel = avgVel.Y
                    local verticalOffset = 0
                    if vertVel < -0.5 then
                        local gravityComp = 0.5 * workspace.Gravity * totalDelay * totalDelay * 0.25
                        verticalOffset = -gravityComp
                    elseif vertVel > 1.5 then
                        verticalOffset = vertVel * totalDelay * 0.12
                    end

                    predictedPos = pt.Position + predictedOffset + Vector3.new(0, verticalOffset, 0)
                    aimPos = predictedPos
                end
            end
        end

        best = {
            player = p,
            aimPos = aimPos,
            part = pt,
            dist = dist,
            bulletSpeed = bulletSpeed,
            predictedPos = predictedPos
        }
    end

    for player, _ in PVP._velHistory do
        if not player or not player.Parent then
            PVP._velHistory[player] = nil
        end
    end

    return best
end


    function PVP.updateIndicator(aimPos, hasTarget)
        if not aimPos then
            if PVP.indicatorData then
                if PVP.indicatorData.billboard then PVP.indicatorData.billboard:Destroy() end
                PVP.indicatorData = nil
            end
            if PVP.indicatorPart then
                PVP.indicatorPart:Destroy()
                PVP.indicatorPart = nil
            end
            return
        end

        if not PVP.indicatorPart or not PVP.indicatorPart.Parent then
            PVP.indicatorPart = Instance.new("Part")
            PVP.indicatorPart.Name = "AimIndicatorAnchor"
            PVP.indicatorPart.Size = v3new(0.2, 0.2, 0.2)
            PVP.indicatorPart.Transparency = 1
            PVP.indicatorPart.CanCollide = false
            PVP.indicatorPart.Anchored = true
            PVP.indicatorPart.Parent = workspace
        end
        PVP.indicatorPart.Position = aimPos

        if not PVP.indicatorData or not PVP.indicatorData.billboard or not PVP.indicatorData.billboard.Parent then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 25, 0, 25)
            bill.StudsOffset = v3new(0, 0, 0)
            bill.AlwaysOnTop = true
            bill.Adornee = PVP.indicatorPart
            bill.Parent = PVP.indicatorPart

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 1, 0)
            container.BackgroundTransparency = 1
            container.Parent = bill

            local outer = Instance.new("Frame")
            outer.Size = UDim2.new(1, 0, 1, 0)
            outer.BackgroundTransparency = 1
            outer.Parent = container
            local outerStroke = Instance.new("UIStroke")
            outerStroke.Thickness = 1.0
            outerStroke.Color = c3rgb(255, 255, 255)
            outerStroke.Transparency = 0.2
            outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            outerStroke.Parent = outer
            local outerCorner = Instance.new("UICorner")
            outerCorner.CornerRadius = UDim.new(1, 0)
            outerCorner.Parent = outer

            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(0.65, 0, 0.65, 0)
            inner.Position = UDim2.new(0.175, 0, 0.175, 0)
            inner.BackgroundTransparency = 1
            inner.Parent = container
            local innerStroke = Instance.new("UIStroke")
            innerStroke.Thickness = 0.7
            innerStroke.Color = c3rgb(255, 255, 255)
            innerStroke.Transparency = 0.35
            innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            innerStroke.Parent = inner
            local innerCorner = Instance.new("UICorner")
            innerCorner.CornerRadius = UDim.new(1, 0)
            innerCorner.Parent = inner

            local scanline = Instance.new("Frame")
            scanline.Size = UDim2.new(0, 1.0, 0, 12)
            scanline.Position = UDim2.new(0.5, -0.5, 0.15, 0)
            scanline.BackgroundColor3 = c3rgb(255, 255, 255)
            scanline.BackgroundTransparency = 0.3
            scanline.Parent = container
            local scanCorner = Instance.new("UICorner")
            scanCorner.CornerRadius = UDim.new(0, 1)
            scanCorner.Parent = scanline
            local scanGradient = Instance.new("UIGradient")
            scanGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.9),
                NumberSequenceKeypoint.new(1, 0.1)
            }
            scanGradient.Rotation = 180
            scanGradient.Parent = scanline

            local corners = {}
            local cornerPos = {
                {-1, -1, 0},
                {1, -1, 90},
                {-1, 1, -90},
                {1, 1, 180}
            }
            for _, pos in cornerPos do
                local group = Instance.new("Frame")
                group.Size = UDim2.new(0, 3.5, 0, 3.5)
                group.BackgroundTransparency = 1
                group.Position = UDim2.new(0.5 + pos[1] * 0.36, -1.75, 0.5 + pos[2] * 0.36, -1.75)
                group.Rotation = pos[3]
                group.Parent = container

                local h = Instance.new("Frame")
                h.Size = UDim2.new(1, 0, 0, 1.0)
                h.BackgroundColor3 = c3rgb(255, 255, 255)
                h.BackgroundTransparency = 0.4
                h.Parent = group

                local v = Instance.new("Frame")
                v.Size = UDim2.new(0, 1.0, 1, 0)
                v.BackgroundColor3 = c3rgb(255, 255, 255)
                v.BackgroundTransparency = 0.4
                v.Parent = group

                table.insert(corners, group)
            end

            PVP.indicatorData = {
                billboard = bill,
                container = container,
                outer = outer,
                outerStroke = outerStroke,
                inner = inner,
                innerStroke = innerStroke,
                scanline = scanline,
                corners = corners,
                rotation = 0,
                hasTarget = false
            }

            task.spawn(function()
                local rot = 0
                while PVP.indicatorData and PVP.indicatorData.billboard and PVP.indicatorData.billboard.Parent do
                    rot = rot + 3.0
                    if PVP.indicatorData.outer then
                        PVP.indicatorData.outer.Rotation = rot
                    end
                    if PVP.indicatorData.inner then
                        PVP.indicatorData.inner.Rotation = -rot * 0.6
                    end
                    if PVP.indicatorData.scanline then
                        PVP.indicatorData.scanline.Rotation = rot * 1.5
                    end

                    local target = PVP.indicatorData.hasTarget
                    local breath = (math.sin(tick_() * 4) + 1) / 2 * 0.2 + 0.15
                    local breath2 = (math.sin(tick_() * 4 + 0.5) + 1) / 2 * 0.25 + 0.2

                    if target then
                        local g = 0.7 + (math.sin(tick_() * 2) + 1) / 2 * 0.3
                        local color = c3rgb(0, mathFloor(g * 255), 80)
                        if PVP.indicatorData.outerStroke then
                            PVP.indicatorData.outerStroke.Color = color
                            PVP.indicatorData.outerStroke.Transparency = breath
                        end
                        if PVP.indicatorData.innerStroke then
                            PVP.indicatorData.innerStroke.Color = color
                            PVP.indicatorData.innerStroke.Transparency = breath2
                        end
                        if PVP.indicatorData.scanline then
                            PVP.indicatorData.scanline.BackgroundColor3 = color
                            PVP.indicatorData.scanline.BackgroundTransparency = 0.3
                        end
                        for _, corner in PVP.indicatorData.corners do
                            for _, child in corner:GetChildren() do
                                if child:IsA("Frame") then
                                    child.BackgroundColor3 = color
                                end
                            end
                        end
                    else
                        local white = c3rgb(255, 255, 255)
                        if PVP.indicatorData.outerStroke then
                            PVP.indicatorData.outerStroke.Color = white
                            PVP.indicatorData.outerStroke.Transparency = breath
                        end
                        if PVP.indicatorData.innerStroke then
                            PVP.indicatorData.innerStroke.Color = white
                            PVP.indicatorData.innerStroke.Transparency = breath2
                        end
                        if PVP.indicatorData.scanline then
                            PVP.indicatorData.scanline.BackgroundColor3 = white
                            PVP.indicatorData.scanline.BackgroundTransparency = 0.3
                        end
                        for _, corner in PVP.indicatorData.corners do
                            for _, child in corner:GetChildren() do
                                if child:IsA("Frame") then
                                    child.BackgroundColor3 = white
                                end
                            end
                        end
                    end

                    task.wait(0.02)
                end
            end)
        else
            if PVP.indicatorData.billboard.Adornee ~= PVP.indicatorPart then
                PVP.indicatorData.billboard.Adornee = PVP.indicatorPart
            end
            PVP.indicatorData.hasTarget = hasTarget
        end
    end

    function PVP.hideIndicator()
        if PVP.indicatorData then
            if PVP.indicatorData.billboard then
                PVP.indicatorData.billboard:Destroy()
            end
            PVP.indicatorData = nil
        end
        if PVP.indicatorPart then
            PVP.indicatorPart:Destroy()
            PVP.indicatorPart = nil
        end
    end


    function PVP.setupSilentHook()
        if PVP.silentHook then return end
        if type(hookmetamethod) ~= "function" then
            warn("静默自瞄需要 hookmetamethod")
            return
        end
        PVP.silentHook = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and PVP.aimEnabled and PVP.silentMode then
                local args = {...}
                if args[1] == "Fire" and PVP.silentTarget and PVP.silentTarget.aimPos then
                    local char = LocalPlayer.Character
                    if char then
                        local newArgs = {}
                        for i = 1, #args do
                            newArgs[i] = args[i]
                        end
                        if #newArgs >= 3 then
                            newArgs[3] = PVP.silentTarget.aimPos
                        end
                        return PVP.silentHook(self, unpack(newArgs))
                    end
                end
            end
            return PVP.silentHook(self, ...)
        end)
    end

    function PVP.removeSilentHook()
        if PVP.silentHook then
            hookmetamethod(game, "__namecall", PVP.silentHook)
            PVP.silentHook = nil
        end
    end


    local function _aimLoop()
        while PVP.aimEnabled do
            if not _isHoldingGun() then
                PVP.hideIndicator()
                task.wait()
                continue
            end
            local target = _findBestTarget()

            if target and target.player and target.player.Character then
                PVP.silentTarget = target
                PVP.updateIndicator(target.aimPos, true)

                if target.player ~= PVP.lastNotifiedPlayer then
                    PVP.lastNotifiedPlayer = target.player
                    pcall(function()
                        local speedDisplay = target.bulletSpeed or 0
                        L.notify((InterfaceLanguage == "English" and ("Distance: " .. mathFloor(target.dist) .. " studs | Speed: " .. speedDisplay) or ("距离: " .. mathFloor(target.dist) .. "格 | 速度: " .. speedDisplay)), 1)
                    end)
                end

                if not PVP.silentMode then
                    local cam = workspace.CurrentCamera
                    if cam then
                        cam.CFrame = cfNew(cam.CFrame.Position, target.aimPos)
                    end
                end
            else
                PVP.silentTarget = nil
                PVP.lastNotifiedPlayer = nil
                PVP.updateIndicator(nil, false)
            end
            task.wait()
        end
    end

    function PVP.toggle(state)
        PVP.aimEnabled = state
        if state then
            if not PVP.aimConn then
                PVP.aimConn = task.spawn(_aimLoop)
                if PVP.silentMode then
                    PVP.setupSilentHook()
                else
                    PVP.removeSilentHook()
                end
            end
        else
            if PVP.aimConn then
                task.cancel(PVP.aimConn)
                PVP.aimConn = nil
            end
            PVP.removeSilentHook()
            PVP.silentTarget = nil
            PVP.lastNotifiedPlayer = nil
            PVP.hideIndicator()
        end
    end

    function PVP.setAimPart(v)
        PVP.aimPart = v == "身体" and "HumanoidRootPart" or "Head"
    end

    function PVP.toggleFOV(state) PVP.showFov = state end
    function PVP.setFOV(v) PVP.fov = v end
    function PVP.toggleTeamCheck(state) PVP.teamCheck = state end
    function PVP.togglePrediction(state) PVP.prediction = state end
    function PVP.setBulletSpeed(v) PVP.bulletSpeed = v end
    function PVP.toggleWallCheck(state) PVP.wallCheck = state end


    function PVP.toggleMelee(state)
        PVP.meleeEnabled = state
        if state then
            if not PVP.meleeConn then
                PVP.meleeConn = RunService.Heartbeat:Connect(function()
                    if not PVP.meleeEnabled then return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local weapon = char:FindFirstChildOfClass("Tool")
                    if not weapon then return end
                    local remote = weapon:FindFirstChild("RemoteEvent")
                    if not remote then return end

                    for _, pl in Players:GetPlayers() do
                        if pl == LocalPlayer then continue end
                        if L.isMarked and L.isMarked(pl) then continue end
                        if PVP.teamCheck then
                            local mt = L.getPlayerTeam(LocalPlayer)
                            local pt = L.getPlayerTeam(pl)
                            if mt and pt and mt == pt then continue end
                        end
                        local c = pl.Character
                        if not c then continue end
                        local hu = c:FindFirstChildOfClass("Humanoid")
                        if not hu or hu.Health <= 0 then continue end
                        if hu.Health > 1000 then continue end
                        local hrp = c:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        if (hrp.Position - root.Position).Magnitude > 45 then continue end
                        local head = c:FindFirstChild("Head")
                        if head then
                            pcall(function()
                                remote:FireServer("PrepareSwing")
                                remote:FireServer("Swing", "Side")
                                remote:FireServer("HitPlayer", hu, head.Position)
                            end)
                        end
                    end
                end)
            end
        else
            if PVP.meleeConn then
                PVP.meleeConn:Disconnect()
                PVP.meleeConn = nil
            end
        end
    end


    function PVP.toggleTeleport(state)
        PVP.tpEnabled = state
        if state then
            if PVP.tpThread then return end

            PVP.tpTargetHistory = {}

            PVP.tpThread = task.spawn(function()
                while PVP.tpEnabled do
                    local char = Players.LocalPlayer.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            if PVP.tpTarget then
                                local valid = false
                                local targetChar = PVP.tpTarget.Character
                                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                    local hu = targetChar:FindFirstChildOfClass("Humanoid")
                                    if hu and hu.Health > 0 then
                                        local mt = L.getPlayerTeam(Players.LocalPlayer)
                                        local pt = L.getPlayerTeam(PVP.tpTarget)
                                        if not mt or not pt or mt ~= pt then
                                            valid = true
                                        end
                                    end
                                end
                                if not valid then
                                    if PVP.tpHighlight then PVP.tpHighlight:Destroy(); PVP.tpHighlight = nil end
                                    PVP.tpTarget = nil
                                    PVP.tpTargetHistory = {}
                                end
                            end

                            if not PVP.tpTarget then
                                local bestTarget = nil
                                local bestDist = mathHuge
                                local myTeam = L.getPlayerTeam(Players.LocalPlayer)
                                for _, pl in Players:GetPlayers() do
                                    if pl == Players.LocalPlayer then continue end
                                    local c = pl.Character
                                    if not c then continue end
                                    local hu = c:FindFirstChildOfClass("Humanoid")
                                    if not hu or hu.Health <= 0 then continue end
                                    local hrp = c:FindFirstChild("HumanoidRootPart")
                                    if not hrp then continue end
                                    local pt = L.getPlayerTeam(pl)
                                    if myTeam and pt and myTeam == pt then continue end
                                    local dist = (hrp.Position - root.Position).Magnitude
                                    if dist < bestDist then bestDist = dist; bestTarget = pl end
                                end
                                if bestTarget then
                                    PVP.tpTarget = bestTarget
                                    PVP.tpTargetHistory = {}
                                    if PVP.tpHighlight then PVP.tpHighlight:Destroy() end
                                    local hl = Instance.new("Highlight")
                                    hl.FillColor = c3rgb(0, 255, 0)
                                    hl.OutlineColor = c3rgb(0, 255, 0)
                                    hl.FillTransparency = 0.3
                                    hl.OutlineTransparency = 0.3
                                    hl.Adornee = bestTarget.Character
                                    hl.Parent = bestTarget.Character
                                    PVP.tpHighlight = hl
                                end
                            end

                            if PVP.tpTarget and PVP.tpTarget.Character then
                                local targetHRP = PVP.tpTarget.Character:FindFirstChild("HumanoidRootPart")
                                if targetHRP then
                                    local now = tick_()
                                    table.insert(PVP.tpTargetHistory, {time = now, pos = targetHRP.Position, cframe = targetHRP.CFrame})
                                    if #PVP.tpTargetHistory > 10 then table.remove(PVP.tpTargetHistory, 1) end
                                    local ping = PVP.getPing()
                                    local delaySec = ping / 1000
                                    if #PVP.tpTargetHistory < 2 then
                                        local lookVec = targetHRP.CFrame.LookVector
                                        local behindPos = targetHRP.Position - lookVec * 4 + v3new(0, 6, 0)
                                        root.CFrame = cfNew(behindPos, targetHRP.Position)
                                        task.wait(0.2)
                                        continue
                                    end
                                    local startIdx = mathMax(1, #PVP.tpTargetHistory - 5)
                                    local avgVel = Vector3.zero
                                    local totalAngle = 0
                                    local totalDt = 0
                                    local count = 0
                                    for i = startIdx + 1, #PVP.tpTargetHistory do
                                        local h1 = PVP.tpTargetHistory[i-1]
                                        local h2 = PVP.tpTargetHistory[i]
                                        local dt = h2.time - h1.time
                                        if dt > 0.001 then
                                            local v = (h2.pos - h1.pos) / dt
                                            avgVel = avgVel + v
                                            local l1 = h1.cframe.LookVector
                                            local l2 = h2.cframe.LookVector
                                            local cross = l1:Cross(l2)
                                            local dot = l1:Dot(l2)
                                            local angle = math.atan2(cross.Magnitude, dot)
                                            if dot < 0 then angle = math.pi - angle end
                                            totalAngle = totalAngle + angle
                                            totalDt = totalDt + dt
                                            count = count + 1
                                        end
                                    end
                                    if count > 0 then avgVel = avgVel / count end
                                    local avgAngleSpeed = 0
                                    if totalDt > 0.001 then avgAngleSpeed = totalAngle / totalDt end
                                    local last = PVP.tpTargetHistory[#PVP.tpTargetHistory]
                                    local predictTime = delaySec
                                    local predPos = last.pos + avgVel * predictTime
                                    local predLook = last.cframe.LookVector
                                    if avgAngleSpeed ~= 0 then
                                        local rotAngle = avgAngleSpeed * predictTime
                                        local up = v3new(0, 1, 0)
                                        local axis = predLook:Cross(up)
                                        if axis.Magnitude < 0.001 then axis = v3new(1, 0, 0) end
                                        axis = axis.Unit
                                        local angleCF = CFrame.fromAxisAngle(axis, rotAngle)
                                        predLook = angleCF:VectorToWorldSpace(predLook)
                                    end
                                    local behindPos = predPos - predLook * 4 + v3new(0, 6, 0)
                                    root.CFrame = cfNew(behindPos, predPos)
                                end
                            end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        else
            PVP.tpEnabled = false
            if PVP.tpThread then task.cancel(PVP.tpThread); PVP.tpThread = nil end
            if PVP.tpHighlight then PVP.tpHighlight:Destroy(); PVP.tpHighlight = nil end
            PVP.tpTarget = nil
            PVP.tpTargetHistory = {}
        end
    end

    PVP.forceEquipEnabled = false
    PVP.forceEquipConn = nil

    function PVP.toggleForceEquip(state)
        PVP.forceEquipEnabled = state
        if state then
            if not PVP.forceEquipConn then
                PVP.forceEquipConn = RunService.Heartbeat:Connect(function()
                    if not PVP.forceEquipEnabled then return end
                    local char = Players.LocalPlayer.Character
                    if not char then return end
                    local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                    if not backpack then return end
                    local hasMelee = false
                    for _, tool in char:GetChildren() do
                        if tool:IsA("Tool") and tool:GetAttribute("Melee") then hasMelee = true; break end
                    end
                    if not hasMelee then
                        for _, tool in backpack:GetChildren() do
                            if tool:IsA("Tool") and tool:GetAttribute("Melee") then tool.Parent = char; break end
                        end
                    end
                end)
            end
        else
            if PVP.forceEquipConn then PVP.forceEquipConn:Disconnect(); PVP.forceEquipConn = nil end
        end
    end

    L.onCharacterAdded(function()
        if PVP.tpHighlight then PVP.tpHighlight:Destroy(); PVP.tpHighlight = nil end
        PVP.tpTarget = nil
        PVP.hideIndicator()
        if PVP.aimEnabled then PVP.toggle(false); task.wait(0.5); PVP.toggle(true) end
        if PVP.meleeEnabled then PVP.toggleMelee(false); task.wait(0.5); PVP.toggleMelee(true) end
        if PVP.tpEnabled then PVP.toggleTeleport(false); task.wait(0.5); PVP.toggleTeleport(true) end
    end)
end

L.disguise = {}
L.disguise.lastVictimName = ""
L.disguise.active = false

function L.disguise.getUserIdByUsername(username)
    local HttpService = game:GetService("HttpService")
    local success, result = pcall(function()
        return game:HttpGet("https://users.roblox.com/v1/users/search?keyword=" .. HttpService:UrlEncode(username), true)
    end)
    if not success then return nil, nil, nil end
    local data = HttpService:JSONDecode(result)
    if data and data.data and #data.data > 0 then
        return data.data[1].id, data.data[1].name, data.data[1].displayName
    end
    return nil, nil, nil
end

function L.disguise.applyCharacterAppearance(character, userId)
    local appearance = Players:GetCharacterAppearanceAsync(userId)

    for i, v in character:GetChildren() do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end

    for i, v in appearance:GetChildren() do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v:Clone().Parent = character
        elseif v:IsA("Accessory") then
            character.Humanoid:AddAccessory(v:Clone())
        end
    end

    if appearance:FindFirstChild("face") then
        if character:WaitForChild("Head"):FindFirstChild("face") then
            character.Head.face:Destroy()
        end
        appearance.face:Clone().Parent = character.Head
    end

    local parent = character.Parent
    character.Parent = nil
    character.Parent = parent
end

function L.disguise.applyAppearanceOnly(victimName)
    if victimName == "" then
        Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("请输入目标玩家名字"), Time = 3 })
        return false
    end

    local success = pcall(function()
        local localPlayer = LocalPlayer
        local userId, userName, displayName = L.disguise.getUserIdByUsername(victimName)
        if not userId then
            Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("找不到该玩家"), Time = 3 })
            return
        end

        if not localPlayer.Character then
            localPlayer.CharacterAdded:Wait()
        end
        repeat task.wait() until localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

        local char = localPlayer.Character
        L.disguise.applyCharacterAppearance(char, userId)

        task.wait(0.1)
        pcall(function()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                workspace.CurrentCamera.CameraSubject = humanoid
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end
        end)

        Library:Notify({
            Title = TranslateText("成功"),
            Description = strFormat(InterfaceLanguage == "English" and "Replaced with %s's appearance" or "已替换为 %s 外观", displayName),
            Time = 3,
        })
    end)
    return success
end


function L.disguise.changeNameOnly(newName)
    if newName == "" then
        Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("请输入新名字"), Time = 3 })
        return false
    end

    local success = pcall(function()
        local localPlayer = LocalPlayer
        local userId, userName, displayName = L.disguise.getUserIdByUsername(newName)
        if not userId then
            Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("该用户名不存在"), Time = 3 })
            return
        end

        if not localPlayer.Character then
            localPlayer.CharacterAdded:Wait()
        end
        repeat task.wait() until localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

        local char = localPlayer.Character
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        pcall(function()
            localPlayer.Name = userName
            localPlayer.UserId = userId
            localPlayer.CharacterAppearanceId = userId
            localPlayer.DisplayName = displayName
            char.Name = userName
            if humanoid then
                humanoid.DisplayName = displayName
            end
        end)

        Library:Notify({
            Title = TranslateText("成功"),
            Description = strFormat(InterfaceLanguage == "English" and "Name changed to: %s" or "名字已改为: %s", displayName),
            Time = 3,
        })
    end)
    return success
end

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Destroy" and L.disguise.active then
            local char = LocalPlayer.Character
            if char and self == char then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
end

function L.getPurchaseEvent()
    local rs = ReplicatedStorage
    if not rs then return nil end
    local events = rs:FindFirstChild("Events")
    if not events then return nil end
    local customize = events:FindFirstChild("Customize")
    if not customize then return nil end
    return customize:FindFirstChild("PurchaseEvent")
end

local function getAnimator()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    return hum, animator
end

local function stopAllTracks()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in hum:GetPlayingAnimationTracks() do
            pcall(function() track:Stop() end)
        end
    end
end

local function restoreSpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

function L.resetAnims()
    stopAllTracks()
    restoreSpeed()
end

local function loadAnimation(animator, id)
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    return track
end





L.ANIM_KEYS = {
    "horseDance", "barry", "blyucher", "eatBroadcast", "playDead",
    "headlessSoldier", "crossUse", "fracture", "napoleon", "anim13725477218",
    "animEaten", "animBoatPull", "animCustomDual1", "animCustomDual2",
    "animLoop87443816703028", "animLoop15827239870", "animCustomDual3",
    "animPlayOnce14860627011", "anim107068529359282", "anim127516132968916",
    "anim27432686", "animCustomDual4",
}

function L.AnimStopOthers(keepKey)
    if L._animStopping then return end
    L._animStopping = true
    for _, key in L.ANIM_KEYS do
        local state = L[key]
        if key ~= keepKey and state and state.active then
            local stopFn = L["stop" .. key:sub(1, 1):upper() .. key:sub(2)]
            if stopFn then pcall(stopFn) end
        end
    end
    L._animStopping = false
end

AnimsRightGroup:AddToggle('DanceHorseToggle', {
    Text = '骑马舞',
    Default = false,
    Tooltip = TranslateTooltip('播放骑马舞动画'),
    Callback = function(v)
        if v then
            L.startHorseDance()
        else
            L.stopHorseDance()
        end
    end
})


L.horseDance = { active = false, track = nil, thread = nil }
function L.startHorseDance()
    if L.horseDance.active then return end
    L.AnimStopOthers("horseDance")
    L.horseDance.active = true
    L.resetAnims()
    local _, animator = getAnimator()
    if not animator then L.horseDance.active = false; return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://182435998"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.horseDance.track = track
end
function L.stopHorseDance()
    if not L.horseDance.active then return end
    L.horseDance.active = false
    if L.horseDance.track then pcall(function() L.horseDance.track:Stop() end) end
    L.resetAnims()
end

L.barry = { active = false, trackList = {}, thread = nil }
local function barrySeq(animator)
    local tracks = {
        loadAnimation(animator, "rbxassetid://14284371664"),
        loadAnimation(animator, "rbxassetid://14284387207"),
        loadAnimation(animator, "rbxassetid://14284382730"),
        loadAnimation(animator, "rbxassetid://14304936421"),
    }
    L.barry.trackList = tracks
    local function waitStopped(track, timeout)
        local done = false
        local conn = track.Stopped:Once(function() done = true end)
        local t0 = osClock()
        while not done and track.IsPlaying and osClock() - t0 < timeout do
            task.wait(0.05)
        end
        pcall(function() conn:Disconnect() end)
    end
    while L.barry.active do
        tracks[1]:Play(); waitStopped(tracks[1], 10)
        if not L.barry.active then break end
        tracks[2]:Play(); task.wait(1); if tracks[2].IsPlaying then tracks[2]:Stop() end
        if not L.barry.active then break end
        tracks[3]:Play(); waitStopped(tracks[3], 10)
        if not L.barry.active then break end
        tracks[2]:Play(); task.wait(0.3); if tracks[2].IsPlaying then tracks[2]:Stop() end
        if not L.barry.active then break end
        tracks[4]:Play(); waitStopped(tracks[4], 10)
    end
    for _, t in tracks do pcall(function() t:Stop() end) end
    L.barry.trackList = {}
end
function L.startBarry()
    if L.barry.active then return end
    L.AnimStopOthers("barry")
    L.barry.active = true
    L.resetAnims()
    local _, animator = getAnimator()
    if not animator then L.barry.active = false; return end
    L.barry.thread = task.spawn(barrySeq, animator)
end
function L.stopBarry()
    if not L.barry.active then return end
    L.barry.active = false
    if L.barry.thread then task.cancel(L.barry.thread) end
    for _, t in L.barry.trackList do pcall(function() t:Stop() end) end
    L.barry.trackList = {}
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.horseDance and L.horseDance.active then L.stopHorseDance() end
    if L.blyucher and L.blyucher.active then L.stopBlyucher() end
    if L.barry and L.barry.active then L.stopBarry() end
end)


L.blyucher = { active = false, thread = nil, tracks = {} }

function L.startBlyucher()
    if L.blyucher.active then return end
    L.AnimStopOthers("blyucher")
    L.blyucher.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.blyucher.active = false
        return
    end

    local function loadAnim(id)
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        return track
    end

    local track1 = loadAnim("rbxassetid://15603033178")
    local track2 = loadAnim("rbxassetid://16168689655")
    local track3 = loadAnim("rbxassetid://15680560478")
    local track4 = loadAnim("rbxassetid://15688743558")
    local track5 = loadAnim("rbxassetid://15637342030")

    L.blyucher.tracks = {track1, track2, track3, track4, track5}

    L.blyucher.thread = task.spawn(function()
        if not L.blyucher.active then return end

        track1:Play()
        track1.Stopped:Wait()
        if not L.blyucher.active then return end

        track2:Play()
        track2.Stopped:Wait()
        if not L.blyucher.active then return end

        track3:Play()
        task.wait(3)
        if track3.IsPlaying then track3:Stop() end
        if not L.blyucher.active then return end

        track4:Play()
        track4.Stopped:Wait()
        if not L.blyucher.active then return end

        track3:Play()
        task.wait(3)
        if track3.IsPlaying then track3:Stop() end
        if not L.blyucher.active then return end

        track5:Play()
        track5.Stopped:Wait()

        if L.blyucher.active then
            L.blyucher.active = false

            pcall(function()
                if type(L.updateBlyucherButton) == "function" then
                    L.updateBlyucherButton(false)
                end
            end)
            L.resetAnims()
        end
    end)
end

function L.stopBlyucher()
    if not L.blyucher.active then return end
    L.blyucher.active = false

    if L.blyucher.thread then
        task.cancel(L.blyucher.thread)
        L.blyucher.thread = nil
    end

    for _, track in L.blyucher.tracks do
        pcall(function() track:Stop() end)
    end
    L.blyucher.tracks = {}
    L.resetAnims()
end


L.onCharacterAdded(function()
    if L.blyucher and L.blyucher.active then
        L.stopBlyucher()
    end
end)

AnimsRightGroup:AddToggle('DanceBlyucherToggle', {
    Text = '布吕歇尔',
    Default = false,
    Callback = function(v)
        if v then
            L.startBlyucher()

            L.updateBlyucherButton = function(state)

                local toggle = Toggles['DanceBlyucherToggle']
                if toggle and toggle.SetValue then
                    toggle:SetValue(state)
                end
            end
        else
            L.stopBlyucher()
            L.updateBlyucherButton = nil
        end
    end
})

AnimsRightGroup:AddToggle('DanceBarryToggle', {
    Text = 'Barry',
    Default = false,
    Callback = function(v)
        if v then L.startBarry() else L.stopBarry() end
    end
})

L.eatBroadcast = { active = false, track = nil }

function L.startEatBroadcast()
    if L.eatBroadcast.active then return end
    L.AnimStopOthers("eatBroadcast")
    L.eatBroadcast.active = true
    L.resetAnims()
    local _, animator = getAnimator()
    if not animator then
        L.eatBroadcast.active = false
        return
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://18339432914"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    L.eatBroadcast.track = track
end

function L.stopEatBroadcast()
    if not L.eatBroadcast.active then return end
    L.eatBroadcast.active = false
    if L.eatBroadcast.track then
        pcall(function() L.eatBroadcast.track:Stop() end)
        L.eatBroadcast.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.eatBroadcast and L.eatBroadcast.active then
        L.stopEatBroadcast()
    end
end)

AnimsRightGroup:AddToggle('DanceEatToggle', {
    Text = '吃东西',
    Default = false,
    Tooltip = TranslateTooltip('山伯乐吃东西动画'),
    Callback = function(v)
        if v then
            L.startEatBroadcast()
        else
            L.stopEatBroadcast()
        end
    end
})


L.playDead = { active = false, track = nil, thread = nil }

function L.startPlayDead()
    if L.playDead.active then return end
    L.AnimStopOthers("playDead")
    L.playDead.active = true
    L.resetAnims()
    local _, animator = getAnimator()
    if not animator then
        L.playDead.active = false
        return
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://89945348540089"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    L.playDead.track = track
    L.playDead.thread = task.spawn(function()
        while L.playDead.active do
            track:Play()
            task.wait(1)
            if track.IsPlaying then track:Stop() end
        end
    end)
end

function L.stopPlayDead()
    if not L.playDead.active then return end
    L.playDead.active = false
    if L.playDead.thread then
        task.cancel(L.playDead.thread)
        L.playDead.thread = nil
    end
    if L.playDead.track then
        pcall(function() L.playDead.track:Stop() end)
        L.playDead.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.playDead and L.playDead.active then
        L.stopPlayDead()
    end
end)

AnimsRightGroup:AddToggle('DancePlayDeadToggle', {
    Text = '睡着了',
    Default = false,
    Tooltip = TranslateTooltip('装死动画'),
    Callback = function(v)
        if v then
            L.startPlayDead()
        else
            L.stopPlayDead()
        end
    end
})


L.headlessSoldier = { active = false, idleTrack = nil, walkTrack = nil, conn = nil }

function L.startHeadlessSoldier()
    if L.headlessSoldier.active then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    for _, track in hum:GetPlayingAnimationTracks() do
        pcall(function() track:Stop() end)
    end

    local idleAnim = Instance.new("Animation")
    idleAnim.AnimationId = "rbxassetid://107080941320600"
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = "rbxassetid://74764025513892"

    local idleTrack = animator:LoadAnimation(idleAnim)
    local walkTrack = animator:LoadAnimation(walkAnim)
    idleTrack.Priority = Enum.AnimationPriority.Action3
    walkTrack.Priority = Enum.AnimationPriority.Action3

    L.headlessSoldier.idleTrack = idleTrack
    L.headlessSoldier.walkTrack = walkTrack
    L.headlessSoldier.active = true

    local function update()
        if not L.headlessSoldier.active then return end
        if hum.MoveDirection.Magnitude > 0 then
            if walkTrack and not walkTrack.IsPlaying then
                if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
                walkTrack:Play()
            end
        else
            if idleTrack and not idleTrack.IsPlaying then
                if walkTrack and walkTrack.IsPlaying then walkTrack:Stop() end
                idleTrack:Play()
            end
        end
    end

    update()
    L.headlessSoldier.conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(update)
end

function L.stopHeadlessSoldier()
    if not L.headlessSoldier.active then return end
    L.headlessSoldier.active = false
    if L.headlessSoldier.conn then
        L.headlessSoldier.conn:Disconnect()
        L.headlessSoldier.conn = nil
    end
    if L.headlessSoldier.idleTrack then
        pcall(function() L.headlessSoldier.idleTrack:Stop() end)
        L.headlessSoldier.idleTrack = nil
    end
    if L.headlessSoldier.walkTrack then
        pcall(function() L.headlessSoldier.walkTrack:Stop() end)
        L.headlessSoldier.walkTrack = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in hum:GetPlayingAnimationTracks() do
                pcall(function() track:Stop() end)
            end
        end
    end
end

L.onCharacterAdded(function()
    if L.headlessSoldier and L.headlessSoldier.active then
        L.stopHeadlessSoldier()
        local toggle = Toggles['HeadlessSoldierToggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('HeadlessSoldierToggle', {
    Text = '无头士兵',
    Default = false,
    Tooltip = TranslateTooltip('播放无头士兵待机/行走动画（自动切换）'),
    Callback = function(v)
        if v then L.startHeadlessSoldier() else L.stopHeadlessSoldier() end
    end
})


L.crossUse = { active = false, track = nil }

function L.startCrossUse()
    if L.crossUse.active then return end
    L.AnimStopOthers("crossUse")

    L.crossUse.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.crossUse.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://15210536563"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    L.crossUse.track = track

    track:Play()
end

function L.stopCrossUse()
    if not L.crossUse.active then return end
    L.crossUse.active = false
    if L.crossUse.track then
        pcall(function() L.crossUse.track:Stop() end)
        L.crossUse.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.crossUse and L.crossUse.active then
        L.stopCrossUse()
        local toggle = Toggles['CrossUseToggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('CrossUseToggle', {
    Text = '十字架',
    Default = false,
    Tooltip = TranslateTooltip('播放十字架使用动画（循环）'),
    Callback = function(v)
        if v then L.startCrossUse() else L.stopCrossUse() end
    end
})


L.fracture = { active = false, track1 = nil, track2 = nil }

function L.startFracture()
    if L.fracture.active then return end
    L.AnimStopOthers("fracture")

    L.fracture.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.fracture.active = false
        return
    end

    local anim1 = Instance.new("Animation")
    anim1.AnimationId = "rbxassetid://12333490324"
    local track1 = animator:LoadAnimation(anim1)
    track1.Priority = Enum.AnimationPriority.Action4

    local anim2 = Instance.new("Animation")
    anim2.AnimationId = "rbxassetid://12333489072"
    local track2 = animator:LoadAnimation(anim2)
    track2.Priority = Enum.AnimationPriority.Action4
    track2.Looped = true

    L.fracture.track1 = track1
    L.fracture.track2 = track2

    track1:Play()
    track1.Stopped:Connect(function()
        if L.fracture.active then
            track2:Play()
        end
    end)
end

function L.stopFracture()
    if not L.fracture.active then return end
    L.fracture.active = false
    if L.fracture.track1 then
        pcall(function() L.fracture.track1:Stop() end)
        L.fracture.track1 = nil
    end
    if L.fracture.track2 then
        pcall(function() L.fracture.track2:Stop() end)
        L.fracture.track2 = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.fracture and L.fracture.active then
        L.stopFracture()
        local toggle = Toggles['FractureToggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('FractureToggle', {
    Text = '骨折',
    Default = false,
    Tooltip = TranslateTooltip('播放骨折动画（第一段播完第二段循环）'),
    Callback = function(v)
        if v then L.startFracture() else L.stopFracture() end
    end
})


L.napoleon = { active = false, idleTrack = nil, walkTrack = nil, conn = nil }

function L.startNapoleon()
    if L.napoleon.active then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    for _, track in hum:GetPlayingAnimationTracks() do
        pcall(function() track:Stop() end)
    end

    local animId = "rbxassetid://103557875332543"
    local idleAnim = Instance.new("Animation")
    idleAnim.AnimationId = animId

    local idleTrack = animator:LoadAnimation(idleAnim)
    idleTrack.Priority = Enum.AnimationPriority.Action4

    L.napoleon.idleTrack = idleTrack
    L.napoleon.walkTrack = nil
    L.napoleon.active = true

    local function update()
        if not L.napoleon.active then return end
        if not idleTrack.IsPlaying then
            idleTrack:Play()
        end
    end

    update()
    L.napoleon.conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(update)
end

function L.stopNapoleon()
    if not L.napoleon.active then return end
    L.napoleon.active = false
    if L.napoleon.conn then
        L.napoleon.conn:Disconnect()
        L.napoleon.conn = nil
    end
    if L.napoleon.idleTrack then
        pcall(function() L.napoleon.idleTrack:Stop() end)
        L.napoleon.idleTrack = nil
    end
    if L.napoleon.walkTrack then
        pcall(function() L.napoleon.walkTrack:Stop() end)
        L.napoleon.walkTrack = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in hum:GetPlayingAnimationTracks() do
                pcall(function() track:Stop() end)
            end
        end
    end
end

L.onCharacterAdded(function()
    if L.napoleon and L.napoleon.active then
        L.stopNapoleon()
        local toggle = Toggles['NapoleonToggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('NapoleonToggle', {
    Text = '仙人背手',
    Default = false,
    Tooltip = TranslateTooltip('播放拿破仑背手动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then L.startNapoleon() else L.stopNapoleon() end
    end
})

L.anim13725477218 = { active = false, track = nil }

function L.startAnim13725477218()
    if L.anim13725477218.active then return end
    L.AnimStopOthers("anim13725477218")

    L.anim13725477218.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.anim13725477218.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://13725477218"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.anim13725477218.track = track
end

function L.stopAnim13725477218()
    if not L.anim13725477218.active then return end
    L.anim13725477218.active = false
    if L.anim13725477218.track then
        pcall(function() L.anim13725477218.track:Stop() end)
        L.anim13725477218.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.anim13725477218 and L.anim13725477218.active then
        L.stopAnim13725477218()

        local toggle = Toggles['Anim13725477218Toggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('Anim13725477218Toggle', {
    Text = '突进肘击',
    Default = false,
    Tooltip = TranslateTooltip('循环播放指定动画（优先级 Action4）'),
    Callback = function(v)
        if v then
            L.startAnim13725477218()
        else
            L.stopAnim13725477218()
        end
    end
})

L.animEaten = { active = false, track = nil }

function L.startAnimEaten()
    if L.animEaten.active then return end
    L.AnimStopOthers("animEaten")

    L.animEaten.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then L.animEaten.active = false; return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://12333488486"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.animEaten.track = track
end

function L.stopAnimEaten()
    if not L.animEaten.active then return end
    L.animEaten.active = false
    if L.animEaten.track then
        pcall(function() L.animEaten.track:Stop() end)
        L.animEaten.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.animEaten and L.animEaten.active then
        L.stopAnimEaten()
        local toggle = Toggles['AnimEatenToggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimEatenToggle', {
    Text = '被山伯乐啃',
    Default = false,
    Tooltip = TranslateTooltip('循环播放被啃动画'),
    Callback = function(v)
        if v then L.startAnimEaten() else L.stopAnimEaten() end
    end
})

L.animBoatPull = { active = false, track = nil }

function L.startAnimBoatPull()
    if L.animBoatPull.active then return end
    L.AnimStopOthers("animBoatPull")

    L.animBoatPull.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then L.animBoatPull.active = false; return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://122021683613392"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.animBoatPull.track = track
end

function L.stopAnimBoatPull()
    if not L.animBoatPull.active then return end
    L.animBoatPull.active = false
    if L.animBoatPull.track then
        pcall(function() L.animBoatPull.track:Stop() end)
        L.animBoatPull.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.animBoatPull and L.animBoatPull.active then
        L.stopAnimBoatPull()
        local toggle = Toggles['AnimBoatPullToggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimBoatPullToggle', {
    Text = '扒船',
    Default = false,
    Tooltip = TranslateTooltip('循环播放扒船动画'),
    Callback = function(v)
        if v then L.startAnimBoatPull() else L.stopAnimBoatPull() end
    end
})

function L.startDual(state, idleId, walkId)
    if state.active then return end
    L.AnimStopOthers(state.key)

    local char = LocalPlayer.Character
    if not char then
        state.active = false
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        state.active = false
        return
    end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end

    L.resetAnims()

    local idleAnim = Instance.new("Animation")
    idleAnim.AnimationId = idleId
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = walkId

    local idleTrack = animator:LoadAnimation(idleAnim)
    local walkTrack = animator:LoadAnimation(walkAnim)
    idleTrack.Priority = Enum.AnimationPriority.Action3
    walkTrack.Priority = Enum.AnimationPriority.Action3

    state.idleTrack = idleTrack
    state.walkTrack = walkTrack
    state.active = true

    local function update()
        if not state.active then return end
        if hum.MoveDirection.Magnitude > 0 then
            if not walkTrack.IsPlaying then
                if idleTrack.IsPlaying then idleTrack:Stop() end
                walkTrack:Play()
            end
        else
            if not idleTrack.IsPlaying then
                if walkTrack.IsPlaying then walkTrack:Stop() end
                idleTrack:Play()
            end
        end
    end

    update()
    state.conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(update)
end

function L.stopDual(state)
    if not state.active then return end
    state.active = false
    if state.conn then
        state.conn:Disconnect()
        state.conn = nil
    end
    if state.idleTrack then
        pcall(function() state.idleTrack:Stop() end)
        state.idleTrack = nil
    end
    if state.walkTrack then
        pcall(function() state.walkTrack:Stop() end)
        state.walkTrack = nil
    end
    L.resetAnims()

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in hum:GetPlayingAnimationTracks() do
                pcall(function() track:Stop() end)
            end
            local animate = char:FindFirstChild("Animate")
            if animate then pcall(function() animate.Disabled = false end) end
        end
    end
end

function L.startIdleWalk(state, idleId, walkId, priority, walkSpeed, sitId)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    for _, track in hum:GetPlayingAnimationTracks() do
        pcall(function() track:Stop() end)
    end
    local idleAnim = Instance.new("Animation")
    idleAnim.AnimationId = idleId
    local walkAnim = Instance.new("Animation")
    walkAnim.AnimationId = walkId
    local idleTrack = animator:LoadAnimation(idleAnim)
    local walkTrack = animator:LoadAnimation(walkAnim)
    idleTrack.Priority = priority
    walkTrack.Priority = priority
    if walkSpeed then hum.WalkSpeed = walkSpeed end

    local sitTrack = nil
    if sitId then
        local sitAnim = Instance.new("Animation")
        sitAnim.AnimationId = sitId
        sitTrack = animator:LoadAnimation(sitAnim)
        sitTrack.Priority = Enum.AnimationPriority.Action2
        sitTrack.Looped = true
        sitTrack:Play()
    end

    local function update()
        if hum.MoveDirection.Magnitude > 0 then
            if not walkTrack.IsPlaying then
                if idleTrack.IsPlaying then idleTrack:Stop() end
                walkTrack:Play()
            end
        else
            if not idleTrack.IsPlaying then
                if walkTrack.IsPlaying then walkTrack:Stop() end
                idleTrack:Play()
            end
        end
    end

    local conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(update)
    update()
    state = state or {}
    state.idle = idleTrack
    state.walk = walkTrack
    state.conn = conn
    if sitTrack then state.sit = sitTrack end
    return state
end

function L.stopIdleWalk(state, walkSpeed)
    if state then
        if state.idle then
            pcall(function() state.idle:Stop() end)
            state.idle = nil
        end
        if state.walk then
            pcall(function() state.walk:Stop() end)
            state.walk = nil
        end
        if state.sit then
            pcall(function() state.sit:Stop() end)
            state.sit = nil
        end
        if state.conn then
            pcall(function() state.conn:Disconnect() end)
            state.conn = nil
        end
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if walkSpeed then hum.WalkSpeed = walkSpeed end
            for _, track in hum:GetPlayingAnimationTracks() do
                pcall(function() track:Stop() end)
            end
            local animate = char:FindFirstChild("Animate")
            if animate then pcall(function() animate.Disabled = false end) end
        end
    end
end

L.animCustomDual1 = { active = false, idleTrack = nil, walkTrack = nil, conn = nil, key = "animCustomDual1" }

function L.startAnimCustomDual1()
    L.startDual(L.animCustomDual1, "rbxassetid://86354512475506", "rbxassetid://78012833820631")
end

function L.stopAnimCustomDual1()
    L.stopDual(L.animCustomDual1)
end


L.onCharacterAdded(function()
    if L.animCustomDual1 and L.animCustomDual1.active then
        L.stopAnimCustomDual1()
        local toggle = Toggles['AnimCustomDual1Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimCustomDual1Toggle', {
    Text = '推炮车1',
    Default = false,
    Tooltip = TranslateTooltip('静止播放动画1，移动播放动画2'),
    Callback = function(v)
        if v then
            L.startAnimCustomDual1()
        else
            L.stopAnimCustomDual1()
        end
    end
})

L.animCustomDual2 = { active = false, idleTrack = nil, walkTrack = nil, conn = nil, key = "animCustomDual2" }

function L.startAnimCustomDual2()
    L.startDual(L.animCustomDual2, "rbxassetid://110409103422089", "rbxassetid://105941369341054")
end

function L.stopAnimCustomDual2()
    L.stopDual(L.animCustomDual2)
end


L.onCharacterAdded(function()
    if L.animCustomDual2 and L.animCustomDual2.active then
        L.stopAnimCustomDual2()
        local toggle = Toggles['AnimCustomDual2Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimCustomDual2Toggle', {
    Text = '推炮车2',
    Default = false,
    Tooltip = TranslateTooltip('静止播放动画5，移动播放动画6'),
    Callback = function(v)
        if v then
            L.startAnimCustomDual2()
        else
            L.stopAnimCustomDual2()
        end
    end
})

L.animLoop87443816703028 = { active = false, track = nil, thread = nil }

function L.startAnimLoop87443816703028()
    if L.animLoop87443816703028.active then return end
    L.AnimStopOthers("animLoop87443816703028")

    L.animLoop87443816703028.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.animLoop87443816703028.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://87443816703028"

    L.animLoop87443816703028.thread = task.spawn(function()
        while L.animLoop87443816703028.active do

            if L.animLoop87443816703028.track then
                pcall(function() L.animLoop87443816703028.track:Stop() end)
                L.animLoop87443816703028.track = nil
            end

            local track = animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            track:Play()
            L.animLoop87443816703028.track = track

            local startTime = tick_()
            while L.animLoop87443816703028.active and tick_() - startTime < 0.5 do
                task.wait()
            end
        end
    end)
end

function L.stopAnimLoop87443816703028()
    if not L.animLoop87443816703028.active then return end
    L.animLoop87443816703028.active = false

    if L.animLoop87443816703028.thread then
        task.cancel(L.animLoop87443816703028.thread)
        L.animLoop87443816703028.thread = nil
    end

    if L.animLoop87443816703028.track then
        pcall(function() L.animLoop87443816703028.track:Stop() end)
        L.animLoop87443816703028.track = nil
    end

    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.animLoop87443816703028 and L.animLoop87443816703028.active then
        L.stopAnimLoop87443816703028()
        local toggle = Toggles['AnimLoop87443816703028Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimLoop87443816703028Toggle', {
    Text = '神秘举东西',
    Default = false,
    Tooltip = TranslateTooltip('每0.5秒重新触发一次循环动画 ID: 87443816703028'),
    Callback = function(v)
        if v then
            L.startAnimLoop87443816703028()
        else
            L.stopAnimLoop87443816703028()
        end
    end
})

L.animLoop15827239870 = { active = false, track = nil, thread = nil }

function L.startAnimLoop15827239870()
    if L.animLoop15827239870.active then return end
    L.AnimStopOthers("animLoop15827239870")

    L.animLoop15827239870.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.animLoop15827239870.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://15827239870"

    L.animLoop15827239870.thread = task.spawn(function()
        while L.animLoop15827239870.active do

            if L.animLoop15827239870.track then
                pcall(function() L.animLoop15827239870.track:Stop() end)
                L.animLoop15827239870.track = nil
            end

            local track = animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action3
            track.Looped = false
            track:Play()
            L.animLoop15827239870.track = track

            local startTime = tick_()
            while L.animLoop15827239870.active and tick_() - startTime < 0.73 do
                task.wait()
            end
        end
    end)
end

function L.stopAnimLoop15827239870()
    if not L.animLoop15827239870.active then return end
    L.animLoop15827239870.active = false

    if L.animLoop15827239870.thread then
        task.cancel(L.animLoop15827239870.thread)
        L.animLoop15827239870.thread = nil
    end

    if L.animLoop15827239870.track then
        pcall(function() L.animLoop15827239870.track:Stop() end)
        L.animLoop15827239870.track = nil
    end

    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.animLoop15827239870 and L.animLoop15827239870.active then
        L.stopAnimLoop15827239870()
        local toggle = Toggles['AnimLoop15827239870Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimLoop15827239870Toggle', {
    Text = '转枪',
    Default = false,
    Tooltip = TranslateTooltip('每0.73秒播放一次转枪动画'),
    Callback = function(v)
        if v then
            L.startAnimLoop15827239870()
        else
            L.stopAnimLoop15827239870()
        end
    end
})

L.animCustomDual3 = { active = false, idleTrack = nil, walkTrack = nil, conn = nil, key = "animCustomDual3" }

function L.startAnimCustomDual3()
    L.startDual(L.animCustomDual3, "rbxassetid://99319014110614", "rbxassetid://115122618346402")
end

function L.stopAnimCustomDual3()
    L.stopDual(L.animCustomDual3)
end

L.onCharacterAdded(function()
    if L.animCustomDual3 and L.animCustomDual3.active then
        L.stopAnimCustomDual3()
        local toggle = Toggles['AnimCustomDual3Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsLeftGroup:AddToggle('AnimCustomDual3Toggle', {
    Text = '推大炮1',
    Default = false,
    Tooltip = TranslateTooltip('静止播放动画1，移动播放动画2'),
    Callback = function(v)
        if v then
            L.startAnimCustomDual3()
        else
            L.stopAnimCustomDual3()
        end
    end
})

L.animPlayOnce14860627011 = { active = false, track = nil, session = 0 }

function L.startAnimPlayOnce14860627011()
    if L.animPlayOnce14860627011.active then return end
    L.AnimStopOthers("animPlayOnce14860627011")

    L.animPlayOnce14860627011.active = true
    L.animPlayOnce14860627011.session = L.animPlayOnce14860627011.session + 1
    local session = L.animPlayOnce14860627011.session
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.animPlayOnce14860627011.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://14860627011"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    L.animPlayOnce14860627011.track = track


    task.delay(20, function()
        if L.animPlayOnce14860627011 and L.animPlayOnce14860627011.active
            and L.animPlayOnce14860627011.session == session then
            L.stopAnimPlayOnce14860627011()
            local toggle = Toggles['AnimPlayOnce14860627011Toggle']
            if toggle and toggle.SetValue then
                toggle:SetValue(false)
            end
        end
    end)
end

function L.stopAnimPlayOnce14860627011()
    if not L.animPlayOnce14860627011.active then return end
    L.animPlayOnce14860627011.active = false
    L.animPlayOnce14860627011.session = L.animPlayOnce14860627011.session + 1
    if L.animPlayOnce14860627011.track then
        pcall(function() L.animPlayOnce14860627011.track:Stop() end)
        L.animPlayOnce14860627011.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.animPlayOnce14860627011 and L.animPlayOnce14860627011.active then
        L.stopAnimPlayOnce14860627011()
        local toggle = Toggles['AnimPlayOnce14860627011Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('AnimPlayOnce14860627011Toggle', {
    Text = '开心舞蹈',
    Default = false,
    Tooltip = TranslateTooltip('播放动画（20秒后自动停止）'),
    Callback = function(v)
        if v then
            L.startAnimPlayOnce14860627011()
        else
            L.stopAnimPlayOnce14860627011()
        end
    end
})

L.anim107068529359282 = { active = false, track = nil }

function L.startAnim107068529359282()
    if L.anim107068529359282.active then return end

    L.anim107068529359282.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.anim107068529359282.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://107068529359282"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.anim107068529359282.track = track
end

function L.stopAnim107068529359282()
    if not L.anim107068529359282.active then return end
    L.anim107068529359282.active = false
    if L.anim107068529359282.track then
        pcall(function() L.anim107068529359282.track:Stop() end)
        L.anim107068529359282.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.anim107068529359282 and L.anim107068529359282.active then
        L.stopAnim107068529359282()
        local toggle = Toggles['Anim107068529359282Toggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('Anim107068529359282Toggle', {
    Text = '疯子',
    Default = false,
    Tooltip = TranslateTooltip('循环播放指定动画'),
    Callback = function(v)
        if v then
            L.startAnim107068529359282()
        else
            L.stopAnim107068529359282()
        end
    end
})

L.anim127516132968916 = { active = false, track = nil }

function L.startAnim127516132968916()
    if L.anim127516132968916.active then return end

    L.anim127516132968916.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.anim127516132968916.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://127516132968916"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.anim127516132968916.track = track
end

function L.stopAnim127516132968916()
    if not L.anim127516132968916.active then return end
    L.anim127516132968916.active = false
    if L.anim127516132968916.track then
        pcall(function() L.anim127516132968916.track:Stop() end)
        L.anim127516132968916.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.anim127516132968916 and L.anim127516132968916.active then
        L.stopAnim127516132968916()
        local toggle = Toggles['Anim127516132968916Toggle']
        if toggle and toggle.SetValue then
            toggle:SetValue(false)
        end
    end
end)

AnimsRightGroup:AddToggle('Anim127516132968916Toggle', {
    Text = '趴下',
    Default = false,
    Tooltip = TranslateTooltip('循环播放指定动画'),
    Callback = function(v)
        if v then
            L.startAnim127516132968916()
        else
            L.stopAnim127516132968916()
        end
    end
})

L.anim27432686 = { active = false, track = nil, pauseThread = nil }

function L.startAnim27432686()
    if L.anim27432686.active then return end
    L.AnimStopOthers("anim27432686")

    L.anim27432686.active = true
    L.resetAnims()

    local _, animator = getAnimator()
    if not animator then
        L.anim27432686.active = false
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://27432686"
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    track:Play()
    L.anim27432686.track = track

    if L.anim27432686.pauseThread then
        task.cancel(L.anim27432686.pauseThread)
        L.anim27432686.pauseThread = nil
    end
    L.anim27432686.pauseThread = task.spawn(function()
        task.wait(0.3)
        if L.anim27432686.active and L.anim27432686.track then
            pcall(function()
                L.anim27432686.track:AdjustSpeed(0)
            end)
        end
        L.anim27432686.pauseThread = nil
    end)
end

function L.stopAnim27432686()
    if not L.anim27432686.active then return end
    L.anim27432686.active = false
    if L.anim27432686.pauseThread then
        task.cancel(L.anim27432686.pauseThread)
        L.anim27432686.pauseThread = nil
    end
    if L.anim27432686.track then
        pcall(function() L.anim27432686.track:Stop() end)
        L.anim27432686.track = nil
    end
    L.resetAnims()
end

L.onCharacterAdded(function()
    if L.anim27432686 and L.anim27432686.active then
        L.stopAnim27432686()
        local toggle = Toggles['Anim27432686Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsRightGroup:AddToggle('Anim27432686Toggle', {
    Text = '僵尸',
    Default = false,
    Tooltip = TranslateTooltip('播放0.3秒后暂停定格'),
    Callback = function(v)
        if v then
            L.startAnim27432686()
        else
            L.stopAnim27432686()
        end
    end
})

do
    local animActive = false
    local animTrack = nil
    local animatorRef = nil

    function L.startAnim92032645117961()
        if animActive then return end
        animActive = true
        L.resetAnims()

        local hum, animator = getAnimator()
        if not animator then
            animActive = false
            return
        end
        animatorRef = animator

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://92032645117961"
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()
        animTrack = track

        track.Stopped:Connect(function()
            if animActive then
                L.stopAnim92032645117961()
                local toggle = Toggles['Anim92032645117961Toggle']
                if toggle and toggle.SetValue then
                    toggle:SetValue(false)
                end
            end
        end)
    end

    function L.stopAnim92032645117961()
        animActive = false
        if animTrack then
            pcall(function() animTrack:Stop() end)
            animTrack = nil
        end
        animatorRef = nil
        L.resetAnims()
    end

    L.onCharacterAdded(function()
        if animActive then
            L.stopAnim92032645117961()
            local toggle = Toggles['Anim92032645117961Toggle']
            if toggle and toggle.SetValue then
                toggle:SetValue(false)
            end
        end
    end)
end

AnimsRightGroup:AddToggle('Anim92032645117961Toggle', {
    Text = '被抓走',
    Default = false,
    Tooltip = TranslateTooltip('播放动画（播放一次后自动关闭）'),
    Callback = function(v)
        if v then
            L.startAnim92032645117961()
        else
            L.stopAnim92032645117961()
        end
    end
})

do
    local track = nil

    function L.startAnim17593577988()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://17593577988"
        track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()
    end

    function L.stopAnim17593577988()
        if track then
            pcall(function() track:Stop() end)
            track = nil
        end
    end
end

AnimsRightGroup:AddToggle('Anim17593577988Toggle', {
    Text = '爬绳子',
    Default = false,
    Tooltip = TranslateTooltip('播放动画'),
    Callback = function(v)
        if v then
            L.startAnim17593577988()
        else
            L.stopAnim17593577988()
        end
    end
})

do
    local track = nil

    function L.startAnim17871770160()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://17871770160"
        track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play()
    end

    function L.stopAnim17871770160()
        if track then
            pcall(function() track:Stop() end)
            track = nil
        end
    end
end

AnimsRightGroup:AddToggle('Anim17871770160Toggle', {
    Text = '翻滚',
    Default = false,
    Tooltip = TranslateTooltip('循环播放动画'),
    Callback = function(v)
        if v then
            L.startAnim17871770160()
        else
            L.stopAnim17871770160()
        end
    end
})

do
    local newAnimID = "rbxassetid://14686794862"
    local newUI = nil
    local newBtn = nil
    local currentTrack = nil
    local isPaused = false


    local function stopCurrentAnim()
        if currentTrack then
            pcall(function() currentTrack:Stop() end)
            currentTrack = nil
        end
        isPaused = false

        if newBtn then
            newBtn.Text = "开"
            newBtn.BackgroundColor3 = c3rgb(30, 30, 40)
        end
    end

    local function playAndPause()

        stopCurrentAnim()

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = newAnimID
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()

        track:AdjustSpeed(0)
        currentTrack = track
        isPaused = true


        if newBtn then
            newBtn.Text = "关"
            newBtn.BackgroundColor3 = c3rgb(200, 80, 80)
        end
    end

    function L.toggleNewAnimUI(state)
        if state then

            if newUI then newUI:Destroy() end

            local sg, btn = L.createFloatingButton("NewAnimUI", "开", UDim2.new(0.5, 105, 0.45, 0), 18, function()
                if isPaused then
                    stopCurrentAnim()
                else
                    playAndPause()
                end
            end)

            newUI = sg
            newBtn = btn
            isPaused = false
        else

            if newUI then
                newUI:Destroy()
                newUI = nil
                newBtn = nil
            end
            stopCurrentAnim()
        end
    end


    AnimsRightGroup:AddToggle('NewAnimUIToggle', {
        Text = '打开遁地快捷栏',
        Default = false,
        Tooltip = TranslateTooltip('无'),
        Callback = function(v)
            L.toggleNewAnimUI(v)
        end
    })
end

do
    local animActive = false
    local animTrack = nil
    local pauseThread = nil
    local buttonRef = nil
    local uiRef = nil

    local function startAnimation()
        if animActive then return end
        animActive = true

        local hum, animator = getAnimator()
        if not animator then
            animActive = false
            return
        end

        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://17871770160"
        local track = animator:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play()
        animTrack = track

        if pauseThread then task.cancel(pauseThread) end
        pauseThread = task.spawn(function()
            task.wait(0.45)
            if animActive and animTrack then
                pcall(function()
                    animTrack:AdjustSpeed(0)
                end)
            end
            pauseThread = nil
        end)
    end

    local function stopAnimation()
        animActive = false
        if pauseThread then
            task.cancel(pauseThread)
            pauseThread = nil
        end
        if animTrack then
            pcall(function() animTrack:Stop() end)
            animTrack = nil
        end
    end

    local function createUI()
        if uiRef then return end

        local sg, btn = L.createFloatingButton("Anim17871770160UI", "开启", UDim2.new(0.5, 175, 0.45, 0), 18, function()
            if animActive then
                stopAnimation()
                btn.Text = "开启"
                btn.BackgroundColor3 = c3rgb(30, 30, 40)
            else
                startAnimation()
                btn.Text = "关闭"
                btn.BackgroundColor3 = c3rgb(200, 80, 80)
            end
        end)

        buttonRef = btn
        uiRef = sg
    end

    local function destroyUI()
        if uiRef then
            uiRef:Destroy()
            uiRef = nil
            buttonRef = nil
        end
        stopAnimation()
    end


    L.onCharacterAdded(function()
        if animActive then
            stopAnimation()
            if buttonRef then
                buttonRef.Text = "开启"
                buttonRef.BackgroundColor3 = c3rgb(30, 30, 40)
            end
        end
    end)


    L.toggleAnim17871770160UI = function(state)
        if state then
            createUI()
        else
            destroyUI()
        end
    end
end

L.animCustomDual4 = { active = false, idleTrack = nil, walkTrack = nil, conn = nil, key = "animCustomDual4" }

function L.startAnimCustomDual4()
    L.startDual(L.animCustomDual4, "rbxassetid://99319014110614", "rbxassetid://81750747292490")
end

function L.stopAnimCustomDual4()
    L.stopDual(L.animCustomDual4)
end

L.onCharacterAdded(function()
    if L.animCustomDual4 and L.animCustomDual4.active then
        L.stopAnimCustomDual4()
        local toggle = Toggles['AnimCustomDual4Toggle']
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
end)

AnimsLeftGroup:AddToggle('AnimCustomDual4Toggle', {
    Text = '拉大炮2',
    Default = false,
    Tooltip = TranslateTooltip('静止播放动画1，移动播放动画2'),
    Callback = function(v)
        if v then
            L.startAnimCustomDual4()
        else
            L.stopAnimCustomDual4()
        end
    end
})


local ExtraLeftGroup = Tabs.Extra:AddGroupbox({ Side = "Left", Name = "工兵", IconName = "hammer", Description = "修建近战" })

local OfficerGroup = Tabs.Extra:AddGroupbox({ Side = "Right", Name = "军官 线列 水手", IconName = "users", Description = "武器功能" })

L.officer = L.officer or {}
L.officer.autoReload = {
    enabled = false,
    monitoredTools = {},
    notifyCooldown = 4,
    lastNotifyTime = 0,
}

    L.officer.autoReload.isGun = L.sharedIsGun

    L.officer.autoReload.getShotsLoaded = L.sharedGetShotsLoaded

    L.officer.autoReload.getRemote = L.sharedGetRemote

function L.officer.autoReload.tryReload(tool)
    if not L.officer.autoReload.enabled then return end
    if not tool or not tool.Parent then return end
    if not L.officer.autoReload.isGun(tool) then return end
    local shots = L.officer.autoReload.getShotsLoaded(tool)
    if shots == 0 then
        local remote = L.officer.autoReload.getRemote(tool)
        if remote then pcall(function() remote:FireServer("Reload") end) end
    end
end

function L.officer.autoReload.watchTool(tool)
    if not tool or not L.officer.autoReload.isGun(tool) then return end
    if L.officer.autoReload.monitoredTools[tool] then return end

    local shotsObj = tool:FindFirstChild("ShotsLoaded")
    if not shotsObj or not (shotsObj:IsA("IntValue") or shotsObj:IsA("NumberValue")) then
        local wsPlayers = workspace:FindFirstChild("Players")
        if wsPlayers then
            local folder = wsPlayers:FindFirstChild(LocalPlayer.Name)
            if folder then
                local toolFolder = folder:FindFirstChild(tool.Name)
                if toolFolder then
                    shotsObj = toolFolder:FindFirstChild("ShotsLoaded")
                end
            end
        end
    end
    if not shotsObj then return end

    local remote = L.officer.autoReload.getRemote(tool)
    local prevVal = shotsObj.Value or 0

    if L.officer.autoReload.enabled and prevVal == 0 and remote then
        pcall(function() remote:FireServer("Reload") end)
    end

    local reloadDebounce = false
    local ancestryConn
    local shotConn = shotsObj.Changed:Connect(function()
        local v = shotsObj.Value
        if L.officer.autoReload.enabled and v == 0 and remote and not reloadDebounce then
            reloadDebounce = true
            pcall(function() remote:FireServer("Reload") end)
            task.delay(1.2, function() reloadDebounce = false end)
        end
        prevVal = v
    end)

    ancestryConn = tool.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if shotConn then shotConn:Disconnect() end
            L.officer.autoReload.monitoredTools[tool] = nil
            if ancestryConn then ancestryConn:Disconnect() end
        end
    end)

    L.officer.autoReload.monitoredTools[tool] = shotConn
end

function L.officer.autoReload.scanAllTools()
    for tool, conn in L.officer.autoReload.monitoredTools do
        if conn then conn:Disconnect() end
    end
    L.officer.autoReload.monitoredTools = {}

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in backpack:GetChildren() do
            if tool:IsA("Tool") and L.officer.autoReload.isGun(tool) then
                L.officer.autoReload.watchTool(tool)
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, tool in char:GetChildren() do
            if tool:IsA("Tool") and L.officer.autoReload.isGun(tool) then
                L.officer.autoReload.watchTool(tool)
            end
        end
    end
end

function L.officer.autoReload.enable()
    if L.officer.autoReload.enabled then return end
    L.officer.autoReload.enabled = true
    L.officer.autoReload.scanAllTools()

    if L.officer.autoReload.backpackConn then
        L.officer.autoReload.backpackConn:Disconnect()
    end
    local function hookBackpack()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return false end
        if L.officer.autoReload.backpackConn then L.officer.autoReload.backpackConn:Disconnect() end
        L.officer.autoReload.backpackConn = backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and L.officer.autoReload.isGun(child) then
                task.wait(0.1)
                if L.officer.autoReload.enabled then L.officer.autoReload.watchTool(child) end
            end
        end)
        return true
    end
    if not hookBackpack() then
        task.spawn(function()
            while L.officer.autoReload.enabled and not L.officer.autoReload.backpackConn do
                task.wait(0.5)
                hookBackpack()
            end
        end)
    end

    if L.officer.autoReload.characterConn then
        L.officer.autoReload.characterConn:Disconnect()
        L.officer.autoReload.characterConn = nil
    end
    if LocalPlayer.Character then
        L.officer.autoReload.characterConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and L.officer.autoReload.isGun(child) then
                task.wait(0.1)
                if L.officer.autoReload.enabled then
                    L.officer.autoReload.watchTool(child)
                    L.officer.autoReload.tryReload(child)
                end
            end
        end)
    end

    L.notify(TranslateText("自动换弹已开启"), 2)
end

function L.officer.autoReload.disable()
    L.officer.autoReload.enabled = false
    for tool, conn in L.officer.autoReload.monitoredTools do
        if conn then conn:Disconnect() end
    end
    L.officer.autoReload.monitoredTools = {}
    if L.officer.autoReload.backpackConn then
        L.officer.autoReload.backpackConn:Disconnect()
        L.officer.autoReload.backpackConn = nil
    end
    if L.officer.autoReload.characterConn then
        L.officer.autoReload.characterConn:Disconnect()
        L.officer.autoReload.characterConn = nil
    end
    L.notify(TranslateText("自动换弹已关闭"), 2)
end

OfficerGroup:AddToggle('OfficerAutoReloadToggle', {
    Text = '自动换弹',
    Default = false,
    Tooltip = TranslateTooltip('枪械子弹打空后自动装填'),
    Callback = function(v)
        if v then L.officer.autoReload.enable() else L.officer.autoReload.disable() end
    end
})

L.officer = L.officer or {}
L.officer.autoHolster = {
    enabled = false,
    isHolstering = false,
    monitoredTools = {},
}

    L.officer.autoHolster.isGun = L.sharedIsGun

    L.officer.autoHolster.getShotsLoaded = L.sharedGetShotsLoaded

function L.officer.autoHolster.holsterAndReequip(tool)
    if not L.officer.autoHolster.enabled then return end
    if L.officer.autoHolster.isHolstering then return end
    if not tool or not tool.Parent then return end

    L.officer.autoHolster.isHolstering = true
    task.spawn(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if char and backpack and tool and tool.Parent == char then
            tool.Parent = backpack
            task.wait(0.05)
            if tool and tool.Parent == backpack then
                tool.Parent = char
            end
        end
        task.wait(0.05)
        L.officer.autoHolster.isHolstering = false
    end)
end

function L.officer.autoHolster.watchTool(tool)
    if not tool or not L.officer.autoHolster.isGun(tool) then return end
    if L.officer.autoHolster.monitoredTools[tool] then return end

    local shotsObj = tool:FindFirstChild("ShotsLoaded")
    if not shotsObj or not (shotsObj:IsA("IntValue") or shotsObj:IsA("NumberValue")) then
        local wsPlayers = workspace:FindFirstChild("Players")
        if wsPlayers then
            local folder = wsPlayers:FindFirstChild(LocalPlayer.Name)
            if folder then
                local toolFolder = folder:FindFirstChild(tool.Name)
                if toolFolder then
                    shotsObj = toolFolder:FindFirstChild("ShotsLoaded")
                end
            end
        end
    end
    if not shotsObj then return end

    local prevVal = shotsObj.Value or 0

    local ancestryConn
    local shotConn = shotsObj.Changed:Connect(function()
        local v = shotsObj.Value
        if L.officer.autoHolster.enabled and type(v) == "number" and type(prevVal) == "number" and v > prevVal then
            for i = prevVal + 1, v do
                task.spawn(function()
                    L.officer.autoHolster.holsterAndReequip(tool)
                end)
            end
        end
        prevVal = v
    end)

    ancestryConn = tool.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if shotConn then shotConn:Disconnect() end
            L.officer.autoHolster.monitoredTools[tool] = nil
            if ancestryConn then ancestryConn:Disconnect() end
        end
    end)

    L.officer.autoHolster.monitoredTools[tool] = shotConn
end

function L.officer.autoHolster.scanAllTools()
    for tool, conn in L.officer.autoHolster.monitoredTools do
        if conn then conn:Disconnect() end
    end
    L.officer.autoHolster.monitoredTools = {}

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in backpack:GetChildren() do
            if tool:IsA("Tool") and L.officer.autoHolster.isGun(tool) then
                L.officer.autoHolster.watchTool(tool)
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, tool in char:GetChildren() do
            if tool:IsA("Tool") and L.officer.autoHolster.isGun(tool) then
                L.officer.autoHolster.watchTool(tool)
            end
        end
    end
end

function L.officer.autoHolster.start()
    if L.officer.autoHolster.enabled then return end
    L.officer.autoHolster.enabled = true
    L.officer.autoHolster.scanAllTools()

    if L.officer.autoHolster.backpackConn then
        L.officer.autoHolster.backpackConn:Disconnect()
    end
    local function hookBackpack()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return false end
        if L.officer.autoHolster.backpackConn then L.officer.autoHolster.backpackConn:Disconnect() end
        L.officer.autoHolster.backpackConn = backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and L.officer.autoHolster.isGun(child) then
                task.wait(0.1)
                if L.officer.autoHolster.enabled then L.officer.autoHolster.watchTool(child) end
            end
        end)
        return true
    end
    if not hookBackpack() then
        task.spawn(function()
            while L.officer.autoHolster.enabled and not L.officer.autoHolster.backpackConn do
                task.wait(0.5)
                hookBackpack()
            end
        end)
    end

    if L.officer.autoHolster.characterConn then
        L.officer.autoHolster.characterConn:Disconnect()
        L.officer.autoHolster.characterConn = nil
    end
    if LocalPlayer.Character then
        L.officer.autoHolster.characterConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and L.officer.autoHolster.isGun(child) then
                task.wait(0.1)
                if L.officer.autoHolster.enabled then
                    L.officer.autoHolster.watchTool(child)
                end
            end
        end)
    end

    L.notify(TranslateText("自动收枪已开启"), 2)
end

function L.officer.autoHolster.stop()
    L.officer.autoHolster.enabled = false
    for tool, conn in L.officer.autoHolster.monitoredTools do
        if conn then conn:Disconnect() end
    end
    L.officer.autoHolster.monitoredTools = {}
    if L.officer.autoHolster.backpackConn then
        L.officer.autoHolster.backpackConn:Disconnect()
        L.officer.autoHolster.backpackConn = nil
    end
    if L.officer.autoHolster.characterConn then
        L.officer.autoHolster.characterConn:Disconnect()
        L.officer.autoHolster.characterConn = nil
    end
    L.notify(TranslateText("自动收枪已关闭"), 2)
end

OfficerGroup:AddToggle('OfficerAutoHolsterToggle', {
    Text = '换弹完成后自动重新装备武器',
    Default = false,
    Tooltip = TranslateTooltip('每装填一发子弹后自动收回枪械再装备'),
    Callback = function(v)
        if v then L.officer.autoHolster.start() else L.officer.autoHolster.stop() end
    end
})

L.officer.autoJump = {
    enabled = false,
    jumpHeight = 3,
    cooldown = 0.5,
    lastJump = 0,
    trackCache = {},
    animator = nil,
    humanoid = nil,
    monitoring = false,
}

local JUMP_ANIM_IDS = {
    "rbxassetid://17406577733",
    "rbxassetid://15669224658",
    "rbxassetid://12591948314",
    "rbxassetid://12333491302",
}

function L.officer.autoJump.isTargetAnim(animId)
    for _, id in JUMP_ANIM_IDS do
        if animId == id then return true end
    end
    return false
end

function L.officer.autoJump.doJump()
    if not L.officer.autoJump.humanoid or not L.officer.autoJump.humanoid.Parent then return end
    local now = tick_()
    if now - L.officer.autoJump.lastJump < L.officer.autoJump.cooldown then return end

    task.spawn(function()
        pcall(function()
            local start = osClock()
            while osClock() - start < 1 do
                local state = L.officer.autoJump.humanoid:GetState()
                if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Climbing then
                    break
                end
                task.wait(0.05)
            end
            local root = L.officer.autoJump.humanoid.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                local gravity = workspace.Gravity
                local height = mathClamp(L.officer.autoJump.jumpHeight, 0, 6)
                local jumpVelocity = mathSqrt(2 * gravity * height)
                root.AssemblyLinearVelocity = v3new(root.AssemblyLinearVelocity.X, jumpVelocity, root.AssemblyLinearVelocity.Z)
                L.officer.autoJump.lastJump = tick_()
            end
        end)
    end)
end

function L.officer.autoJump.startMonitoring()
    if L.officer.autoJump.monitoring then return end
    L.officer.autoJump.monitoring = true

    task.spawn(function()
        while L.officer.autoJump.monitoring do
            if L.officer.autoJump.animator then
                local ok, tracks = pcall(function() return L.officer.autoJump.animator:GetPlayingAnimationTracks() end)
                if ok and tracks then
                    for _, track in tracks do
                        local anim = track.Animation
                        if anim and L.officer.autoJump.isTargetAnim(anim.AnimationId) and not L.officer.autoJump.trackCache[track] then
                            L.officer.autoJump.trackCache[track] = true
                            pcall(L.officer.autoJump.doJump)
                            track.Stopped:Once(function()
                                L.officer.autoJump.trackCache[track] = nil
                            end)
                        end
                    end
                end
            end
            task.wait(0.08)
        end
    end)
end

function L.officer.autoJump.stopMonitoring()
    L.officer.autoJump.monitoring = false
    L.officer.autoJump.trackCache = {}
end

function L.officer.autoJump.refreshCharacter(char)
    L.officer.autoJump.humanoid = char and char:FindFirstChildOfClass("Humanoid")
    L.officer.autoJump.animator = nil
    if L.officer.autoJump.humanoid then
        L.officer.autoJump.animator = L.officer.autoJump.humanoid:FindFirstChildOfClass("Animator")
        if not L.officer.autoJump.animator then
            L.officer.autoJump.animator = Instance.new("Animator")
            L.officer.autoJump.animator.Parent = L.officer.autoJump.humanoid
        end
    end
    L.officer.autoJump.trackCache = {}
    L.officer.autoJump.lastJump = 0
end

function L.officer.autoJump.start()
    if L.officer.autoJump.enabled then return end
    L.officer.autoJump.enabled = true
    L.officer.autoJump.refreshCharacter(LocalPlayer.Character)
    L.officer.autoJump.startMonitoring()
    L.notify(TranslateText("自动跳刀已开启"), 2)
end

function L.officer.autoJump.stop()
    L.officer.autoJump.enabled = false
    L.officer.autoJump.stopMonitoring()
    L.notify(TranslateText("自动跳刀已关闭"), 2)
end

L.onCharacterAdded(function(char)
    task.wait(0.2)
    if L.officer.autoJump.enabled then
        L.officer.autoJump.refreshCharacter(char)
        L.officer.autoJump.startMonitoring()
    end
end)

OfficerGroup:AddToggle('OfficerAutoJumpToggle', {
    Text = '自动跳刀',
    Default = false,
    Tooltip = TranslateTooltip('军刀前刺动画时自动跳跃'),
    Callback = function(v)
        if v then L.officer.autoJump.start() else L.officer.autoJump.stop() end
    end
})

L.martyr = L.martyr or {}
L.martyr.autoCharge = {
    enabled = false,
    thread = nil,
}

function L.martyr.autoCharge.loop()
    while L.martyr.autoCharge.enabled do
        local char = LocalPlayer.Character
        if char then
            for _, tool in char:GetChildren() do
                if tool:IsA("Tool") then
                    local remote = tool:FindFirstChild("RemoteEvent")
                    if remote then
                        pcall(function() remote:FireServer("Charge") end)
                    end
                end
            end
        end
        task.wait(0.125)
    end
end

function L.martyr.autoCharge.start()
    if L.martyr.autoCharge.thread then return end
    L.martyr.autoCharge.enabled = true
    L.martyr.autoCharge.thread = task.spawn(L.martyr.autoCharge.loop)
    L.notify(TranslateText("自动冲锋已开启"), 2)
end

function L.martyr.autoCharge.stop()
    L.martyr.autoCharge.enabled = false
    if L.martyr.autoCharge.thread then
        task.cancel(L.martyr.autoCharge.thread)
        L.martyr.autoCharge.thread = nil
    end
    L.notify(TranslateText("自动冲锋已关闭"), 2)
end

L.onCharacterAdded(function()
    if L.martyr.autoCharge.enabled then
        task.wait(0.5)
        L.martyr.autoCharge.stop()
        task.wait(0.1)
        L.martyr.autoCharge.start()
    end
end)

OfficerGroup:AddToggle('MartyrAutoChargeToggle', {
    Text = '自动冲锋',
    Default = false,
    Tooltip = TranslateTooltip('能量满后自动开启冲锋'),
    Callback = function(v)
        if v then L.martyr.autoCharge.start() else L.martyr.autoCharge.stop() end
    end
})

L.martyr.autoBlackKnife = {
    enabled = false,
    thread = nil,
    cd = {},
    range = 15,
    teamRange = 7,
}

function L.martyr.autoBlackKnife.getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function L.martyr.autoBlackKnife.getWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, t in char:GetChildren() do
        if t:IsA("Tool") and t:GetAttribute("Melee") then
            return t
        end
    end
    return char:FindFirstChildOfClass("Tool")
end

function L.martyr.autoBlackKnife.getBarrelZombies()
    local list = {}
    local zf = workspace:FindFirstChild("Zombies")
    if zf then
        for _, z in zf:GetChildren() do
            if z:IsA("Model") and (z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel")) then
                table.insert(list, z)
            end
        end
    end
    return list
end

function L.martyr.autoBlackKnife.attackBarrel(zombie)
    if not zombie then return false end
    local weapon = L.martyr.autoBlackKnife.getWeapon()
    if not weapon then return false end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return false end

    local head = zombie:FindFirstChild("Head")
    if not head then return false end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            root.CFrame = cfNew(root.Position, v3new(head.Position.X, root.Position.Y, head.Position.Z))
        end)
    end

    pcall(function()
        remote:FireServer("Swing", "Side")
        remote:FireServer("HitZombie", zombie, head.Position, true)
    end)
    return true
end

function L.martyr.autoBlackKnife.loop()
    while L.martyr.autoBlackKnife.enabled do
        task.wait(0.15)

        local myRoot = LocalPlayer.Character and L.martyr.autoBlackKnife.getHRP(LocalPlayer.Character)
        if not myRoot then continue end

        local barrels = L.martyr.autoBlackKnife.getBarrelZombies()
        for _, z in barrels do
            if not L.martyr.autoBlackKnife.enabled then break end

            local zhrp = z:FindFirstChild("HumanoidRootPart")
            if not zhrp then continue end

            local zDist = (zhrp.Position - myRoot.Position).Magnitude
            if zDist > L.martyr.autoBlackKnife.range then continue end

            local teammateNear = false
            local who = ""
            for _, p in Players:GetPlayers() do
                if p == LocalPlayer then continue end
                local th = p.Character and L.martyr.autoBlackKnife.getHRP(p.Character)
                if th and (th.Position - zhrp.Position).Magnitude <= L.martyr.autoBlackKnife.teamRange then
                    teammateNear = true
                    who = p.Name
                    break
                end
            end

            if not teammateNear then continue end

            local key = who .. tostring(z)
            if L.martyr.autoBlackKnife.cd[key] and tick_() - L.martyr.autoBlackKnife.cd[key] < 0.5 then
                continue
            end
            L.martyr.autoBlackKnife.cd[key] = tick_()

            for _ = 1, 3 do
                L.martyr.autoBlackKnife.attackBarrel(z)
                task.wait(0.05)
            end
        end
    end
end

function L.martyr.autoBlackKnife.start()
    if L.martyr.autoBlackKnife.thread then return end
    L.martyr.autoBlackKnife.enabled = true
    L.martyr.autoBlackKnife.cd = {}
    L.martyr.autoBlackKnife.thread = task.spawn(L.martyr.autoBlackKnife.loop)
    L.notify(TranslateText("自动黑刀已开启"), 2)
end

function L.martyr.autoBlackKnife.stop()
    L.martyr.autoBlackKnife.enabled = false
    if L.martyr.autoBlackKnife.thread then
        task.cancel(L.martyr.autoBlackKnife.thread)
        L.martyr.autoBlackKnife.thread = nil
    end
    L.martyr.autoBlackKnife.cd = {}
    L.notify(TranslateText("自动黑刀已关闭"), 2)
end

OfficerGroup:AddToggle('MartyrAutoBlackKnifeToggle', {
    Text = '自动黑刀',
    Default = false,
    Tooltip = TranslateTooltip('队友靠近自爆时自动攻击'),
    Callback = function(v)
        if v then L.martyr.autoBlackKnife.start() else L.martyr.autoBlackKnife.stop() end
    end
})

local Workspace = game:GetService("Workspace")
local lp = LocalPlayer

L.customBlackGunEnabled = false
L.customBlackGunNoEquip = false
L.customBlackGunCooldown = 0.3
L.customBlackGunEquipDelay = 0.1
L.customBlackGunBarrelDistance = 10
L.customWallCheckEnabled = false
L.customShootingThread = nil
L.customShootingRunning = false

function L.isGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local animFolder = tool:FindFirstChild("Animations")
    if animFolder and (animFolder:FindFirstChild("Aim") or animFolder:FindFirstChild("Aiming")) then
        return true
    end
    return L.GUN_NAME_SET[tool.Name] == true
end

L.getShotsLoaded = L.sharedGetShotsLoaded

L.getRemote = L.sharedGetRemote

function L.getAnyGun()
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")

    if backpack then
        for _, tool in backpack:GetChildren() do
            if tool:IsA("Tool") and L.isGun(tool) then
                local shots = L.getShotsLoaded(tool)
                if shots and shots > 0 then
                    return tool
                end
            end
        end
    end

    if char then
        for _, tool in char:GetChildren() do
            if tool:IsA("Tool") and L.isGun(tool) then
                local shots = L.getShotsLoaded(tool)
                if shots and shots > 0 then
                    return tool
                end
            end
        end
    end

    return nil
end

function L.hasAnyAmmo()
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        for _, tool in backpack:GetChildren() do
            if tool:IsA("Tool") and L.isGun(tool) then
                local shots = L.getShotsLoaded(tool)
                if shots and shots > 0 then return true end
            end
        end
    end
    local char = lp.Character
    if char then
        for _, tool in char:GetChildren() do
            if tool:IsA("Tool") and L.isGun(tool) then
                local shots = L.getShotsLoaded(tool)
                if shots and shots > 0 then return true end
            end
        end
    end
    return false
end

function L.isWallBetween(origin, targetPos, targetModel)
    if not L.customWallCheckEnabled then return false end
    local dir = targetPos - origin
    local dist = dir.Magnitude
    if dist <= 0 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {}
    for _, pl in Players:GetPlayers() do
        if pl.Character then table.insert(ignoreList, pl.Character) end
    end
    local zombies = Workspace:FindFirstChild("Zombies")
    if zombies then table.insert(ignoreList, zombies) end
    if targetModel then table.insert(ignoreList, targetModel) end
    params.FilterDescendantsInstances = ignoreList
    local result = Workspace:Raycast(origin, dir, params)
    return result ~= nil
end

function L.hasPlayerNearBomber(bomberModel, range)
    local rootPart = bomberModel:FindFirstChild("HumanoidRootPart") or bomberModel:FindFirstChild("Torso")
    if not rootPart then return false end
    local pos = rootPart.Position
    for _, pl in Players:GetPlayers() do
        if pl ~= lp then
            local char = pl.Character
            if char then
                local plRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                if plRoot then
                    local d = (pos - plRoot.Position).Magnitude
                    if d <= range then return true end
                end
            end
        end
    end
    return false
end

function L.getClosestBomber()
    local char = lp.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local origin = root.Position
    local bestPart, bestModel, bestDist = nil, nil, 200


    local foldersToScan = {}
    local camFolder = Workspace:FindFirstChild("Camera")
    if camFolder then table.insert(foldersToScan, camFolder) end
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if zombiesFolder then table.insert(foldersToScan, zombiesFolder) end

    for _, folder in foldersToScan do
        for _, model in folder:GetDescendants() do
            if model:IsA("Model") and (model.Name == "m_Zombie" or model:GetAttribute("Type") == "Barrel" or model:FindFirstChild("Barrel")) then

                local isBarrel = model:GetAttribute("Type") == "Barrel" or model:FindFirstChild("Barrel")
                if not isBarrel then continue end

                local target = model:FindFirstChild("Barrel") or model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if not target or not target:IsA("BasePart") then continue end
                local dist = (target.Position - origin).Magnitude
                if dist <= 200 and dist < bestDist then
                    if L.isWallBetween(origin, target.Position, model) then continue end
                    bestPart = target
                    bestModel = model
                    bestDist = dist
                end
            end
        end
    end
    return bestPart, bestModel
end

function L.shootAtTarget(targetPart, targetModel, gun)
    if not gun or not targetPart then return end
    local remote = L.getRemote(gun)
    if not remote then return end
    local char = lp.Character
    if not char then return end
    local modelRef = char:FindFirstChild("Model") or char
    local timestamp = Workspace:GetServerTimeNow()
    pcall(function()
        remote:FireServer("Fire", modelRef, targetPart.Position, timestamp)
    end)
end

function L.customShootingLoop()

    L.customShootingRunning = true

    while L.customBlackGunEnabled and L.customShootingRunning do

        if not L.hasAnyAmmo() then
            task.wait(0.5)
            while L.customBlackGunEnabled and not L.hasAnyAmmo() do
                task.wait(0.5)
            end
            if not L.customBlackGunEnabled then break end
        end

        local targetPart, targetModel = L.getClosestBomber()
        if not targetPart or not targetModel then
            task.wait(0.15)
            continue
        end

        if not L.hasPlayerNearBomber(targetModel, L.customBlackGunBarrelDistance) then
            task.wait(0.15)
            continue
        end

        local char = lp.Character
        if not char then
            task.wait(0.15)
            continue
        end

        local gun = L.getAnyGun()
        if not gun then

            if not L.customBlackGunNoEquip then
                local backpack = lp:FindFirstChild("Backpack")
                if backpack then
                    for _, t in backpack:GetChildren() do
                        if t:IsA("Tool") and L.isGun(t) then
                            local shots = L.getShotsLoaded(t)
                            if shots and shots > 0 then
                                t.Parent = char
                                task.wait(0.1)
                                gun = t
                                break
                            end
                        end
                    end
                end
            end
            if not gun then
                task.wait(0.3)
                continue
            end
        end

        if not L.customBlackGunNoEquip and gun.Parent ~= char then
            gun.Parent = char
            task.wait(0.1)
            if gun.Parent ~= char then
                task.wait(0.1)
                continue
            end
        end

        if L.getShotsLoaded(gun) == 0 then
            task.wait(0.1)
            continue
        end

        task.wait(L.customBlackGunEquipDelay)

        if not targetPart.Parent or not targetModel.Parent then continue end
        if not L.hasPlayerNearBomber(targetModel, L.customBlackGunBarrelDistance) then continue end
        if L.getShotsLoaded(gun) == 0 then continue end

        L.shootAtTarget(targetPart, targetModel, gun)
        task.wait(L.customBlackGunCooldown)
    end

    L.customShootingRunning = false
    if L.customShootingThread then
        L.customShootingThread = nil
    end
end

function L.startCustomShooting()

    if L.customShootingThread then
        task.cancel(L.customShootingThread)
        L.customShootingThread = nil
    end
    L.customShootingRunning = false

    L.customShootingThread = task.spawn(L.customShootingLoop)
end

function L.stopCustomShooting()
    L.customBlackGunEnabled = false
    L.customShootingRunning = false
    if L.customShootingThread then
        task.cancel(L.customShootingThread)
        L.customShootingThread = nil
    end
end

L.radiusCircle = {
    enabled = false,
    visuals = {},
    updateConn = nil,
    zombieAddedDisposer = nil,
}
L.radiusCircle._lastColorCheck = setmetatable({}, { __mode = "k" })

local RING_THICKNESS = 0.3
local RING_RED = BrickColor.new("Bright red")
local RING_GREEN = BrickColor.new("Bright green")

function L.radiusCircle.createCircle(zombie)
    if L.radiusCircle.visuals[zombie] then
        pcall(L.radiusCircle.visuals[zombie].Destroy, L.radiusCircle.visuals[zombie])
        L.radiusCircle.visuals[zombie] = nil
    end
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso")
    if not root then return nil end
    local radius = L.customBlackGunBarrelDistance or 10
    local circle = Instance.new("Part")
    circle.Name = "RadiusCircle"
    circle.Shape = Enum.PartType.Cylinder
    circle.Size = v3new(RING_THICKNESS, radius * 2, radius * 2)
    circle.BrickColor = RING_RED
    circle.Material = Enum.Material.Neon
    circle.Transparency = 0.6
    circle.Anchored = false
    circle.CanCollide = false
    circle.CanQuery = false
    circle.Parent = Workspace
    return circle
end

function L.radiusCircle.updateVisual(zombie, part)
    if not part or not zombie or not part.Parent then return end
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso")
    if not root then return end
    local pos = root.Position
    local footY = pos.Y - 2.5
    part.CFrame = cfNew(pos.X, footY, pos.Z) * CFrame.Angles(0, 0, mathRad(90))
    local currentRadius = L.customBlackGunBarrelDistance or 10
    if mathAbs(part.Size.Y - currentRadius * 2) > 0.01 then
        part.Size = v3new(RING_THICKNESS, currentRadius * 2, currentRadius * 2)
    end
    local now = osClock()
    if now - (L.radiusCircle._lastColorCheck[part] or 0) < 0.1 then return end
    L.radiusCircle._lastColorCheck[part] = now
    local otherInRange = false
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local playerRoot = char:FindFirstChild("HumanoidRootPart")
                if playerRoot then
                    local dist = (playerRoot.Position - root.Position).Magnitude
                    if dist <= currentRadius then
                        otherInRange = true
                        break
                    end
                end
            end
        end
    end
    part.BrickColor = otherInRange and RING_GREEN or RING_RED
end

function L.radiusCircle.updateAll()
    for zombie, part in L.radiusCircle.visuals do
        if zombie and zombie.Parent and part and part.Parent then
            L.radiusCircle.updateVisual(zombie, part)
        else
            if part then pcall(part.Destroy, part) end
            L.radiusCircle.visuals[zombie] = nil
        end
    end
end

function L.radiusCircle.addZombie(zombie)
    if not L.radiusCircle.enabled then return end
    if not zombie:IsA("Model") then return end
    local isBarrel = zombie:GetAttribute("Type") == "Barrel" or zombie:FindFirstChild("Barrel")
    if not isBarrel then return end
    if L.radiusCircle.visuals[zombie] then return end
    local circle = L.radiusCircle.createCircle(zombie)
    if circle then
        L.radiusCircle.visuals[zombie] = circle
        L.radiusCircle.updateVisual(zombie, circle)
    end
end

function L.radiusCircle.onZombieAdded(desc)
    if not L.radiusCircle.enabled or not desc:IsA("Model") then return end
    task.spawn(function()
        local isBarrel = desc:GetAttribute("Type") == "Barrel" or desc:FindFirstChild("Barrel")
        if not isBarrel and desc.Parent then
            task.wait(0.5)
            isBarrel = desc.Parent and (desc:GetAttribute("Type") == "Barrel" or desc:FindFirstChild("Barrel"))
        end
        if isBarrel and desc.Parent then
            L.radiusCircle.addZombie(desc)
        end
    end)
end

function L.radiusCircle.start()
    if L.radiusCircle.updateConn then return end
    L.radiusCircle.enabled = true
    for _, v in Workspace:GetDescendants() do
        if v.Name == "RadiusCircle" then v:Destroy() end
    end
    L.radiusCircle.visuals = {}
    L.ZombieWatch.start()
    L.radiusCircle.zombieAddedDisposer = L.ZombieWatch.onAdded(function(m)
        L.radiusCircle.onZombieAdded(m)
    end)
    L.ZombieWatch.forEach(function(z)
        L.radiusCircle.addZombie(z)
    end)
    L.radiusCircle.updateConn = RunService.RenderStepped:Connect(function()
        if L.radiusCircle.enabled then L.radiusCircle.updateAll() end
    end)
end

function L.radiusCircle.stop()
    L.radiusCircle.enabled = false
    if L.radiusCircle.updateConn then
        L.radiusCircle.updateConn:Disconnect()
        L.radiusCircle.updateConn = nil
    end
    if L.radiusCircle.zombieAddedDisposer then
        L.radiusCircle.zombieAddedDisposer()
        L.radiusCircle.zombieAddedDisposer = nil
    end
    for _, part in L.radiusCircle.visuals do
        pcall(part.Destroy, part)
    end
    L.radiusCircle.visuals = {}
end

function L.radiusCircle.updateRadius(newRadius)
    L.customBlackGunBarrelDistance = newRadius
    if L.radiusCircle.enabled then
        L.radiusCircle.updateAll()
    end
end

OfficerGroup:AddToggle('CustomBlackGunToggle', {
    Text = '自动黑枪',
    Default = false,
    Tooltip = TranslateTooltip('自动射击自爆僵尸'),
    Callback = function(v)
        L.customBlackGunEnabled = v
        if v then
            L.startCustomShooting()
        else
            L.stopCustomShooting()
        end
    end
})

OfficerGroup:AddToggle('CustomBlackGunNoEquip', {
    Text = '无需装备武器',
    Default = false,
    Tooltip = TranslateTooltip('开启后直接从背包调用枪械射击，不需要装备到手上'),
    Callback = function(v)
        L.customBlackGunNoEquip = v
    end
})

OfficerGroup:AddToggle('CustomBlackGunWallCheck', {
    Text = '墙体检测',
    Default = false,
    Tooltip = TranslateTooltip('开启后不会射击被墙体遮挡的自爆'),
    Callback = function(v)
        L.customWallCheckEnabled = v
    end
})

OfficerGroup:AddToggle('RadiusCircleToggle', {
    Text = '显示黑枪半径',
    Default = false,
    Tooltip = TranslateTooltip('显示自爆周围的检测范围圆环'),
    Callback = function(v)
        if v then L.radiusCircle.start() else L.radiusCircle.stop() end
    end
})

OfficerGroup:AddSlider('CustomBlackGunRange', {
    Text = '检测范围',
    Default = 10,
    Min = 1,
    Max = 20,
    Suffix = " 格",
    Tooltip = TranslateTooltip('检测自爆附近玩家的范围（圆环大小同步变化）'),
    Callback = function(v)
        L.customBlackGunBarrelDistance = v
        L.radiusCircle.updateRadius(v)
    end
})

do
    if not L.SilentAim then L.SilentAim = {} end
    local SA = L.SilentAim

    SA.Enabled = false
    SA.SilentAimSelectedTypes = {}
    SA.SilentAimEnabledTypes = {}
    SA.SilentAimZombieTypes = { "Bomber", "Cuirassier", "Runner", "Zapper", "Igniter", "Shambler" }
    SA.SILENT_AIM_USE_FOV = false
    SA.SILENT_AIM_SHOW_FOV = false
    SA.SILENT_AIM_MOBILE_FOV = false
    SA.SILENT_AIM_FOV_SIZE = 50
    SA.SilentAimCurrentTarget = nil
    SA.SilentAimCurrentModel = nil
    SA.SilentAimUpdateConn = nil
    SA.oldFire = nil
    SA.CHECK_WALLS = true
    SA.MAX_TARGET_RANGE = 200
    SA.PREDICTION_ENABLED = false

    SA.indicatorData = nil
    SA.indicatorPart = nil

    for _, t in SA.SilentAimZombieTypes do SA.SilentAimEnabledTypes[t] = false end

    local function getCurrentBulletSpeed()
        return L.sharedGetCurrentBulletSpeed()
    end

    local function getPing()
        return L.sharedGetPing()
    end

    function SA.isWorldPosInSilentAimFov(worldPos)
        local cam = workspace.CurrentCamera
        if not cam then return false end
        local sp, onScreen = cam:WorldToViewportPoint(worldPos)
        if not onScreen then return false end
        local center = v2new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        return (v2new(sp.X, sp.Y) - center).Magnitude <= SA.SILENT_AIM_FOV_SIZE
    end

    function SA.UpdateSilentAimFovCircle()
        local cam = workspace.CurrentCamera
        if SA.SILENT_AIM_SHOW_FOV and cam and not SA.fovCircleDrawing then
            SA.fovCircleDrawing = Drawing.new("Circle")
            SA.fovCircleDrawing.Thickness = 1.5
            SA.fovCircleDrawing.NumSides = 64
            SA.fovCircleDrawing.Filled = false
            SA.fovCircleDrawing.Color = c3rgb(255, 255, 255)
            SA.fovCircleDrawing.Visible = true
        elseif (not SA.SILENT_AIM_SHOW_FOV or not cam) and SA.fovCircleDrawing then
            if SA.fovCircleResizeConn then
                SA.fovCircleResizeConn:Disconnect()
                SA.fovCircleResizeConn = nil
            end
            SA.fovCircleDrawing:Remove()
            SA.fovCircleDrawing = nil
        end
        if SA.fovCircleDrawing and cam then
            SA.fovCircleDrawing.Radius = SA.SILENT_AIM_FOV_SIZE
            SA.fovCircleDrawing.Position = v2new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            if not SA.fovCircleResizeConn then
                SA.fovCircleResizeConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    SA.UpdateSilentAimFovCircle()
                end)
            end
        end
    end

    local function GetZombieTypeFromModel(model)
        if not model or not model:IsA("Model") then return nil end
        local parent = model.Parent
        if parent and parent.Name == "Slim" and parent.Parent and parent.Parent.Name == "Zombies" then
            return "Cuirassier"
        end
        local agent = model:FindFirstChild("Agent")
        if agent then
            local typeValue = agent:FindFirstChild("Type")
            if typeValue and typeValue:IsA("StringValue") then
                local t = string.lower(typeValue.Value or "")
                if t == "normal" then return "Shambler" end
                if t == "barrel" then return "Bomber" end
                if t == "fast" then return "Runner" end
                if t == "sapper" then return "Zapper" end
                if t == "igniter" then return "Igniter" end
                if t == "cuirassier" then return "Cuirassier" end
            end
        end
        if typeof(model.GetAttribute) == "function" then
            local t = model:GetAttribute("Type")
            if type(t) == "string" then
                local lower = string.lower(t)
                if lower == "normal" then return "Shambler" end
                if lower == "barrel" then return "Bomber" end
                if lower == "fast" then return "Runner" end
                if lower == "sapper" then return "Zapper" end
                if lower == "igniter" then return "Igniter" end
                if lower == "cuirassier" then return "Cuirassier" end
            end
        end
        if model:FindFirstChild("Barrel", true) then return "Bomber" end
        if model:FindFirstChild("Whale Oil Lantern", true) then return "Igniter" end
        if model:FindFirstChild("Sword", true) then return "Cuirassier" end
        if model:FindFirstChild("Axe", true) and model:FindFirstChild("Head", true) then return "Zapper" end
        if model:FindFirstChild("Eye", true) and not model:FindFirstChild("Axe", true) then return "Runner" end
        return "Shambler"
    end

    local function getWallCheckOrigin()
        if LocalPlayer.Character and LocalPlayer.Character.Parent then
            local head = LocalPlayer.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then return head.Position end
        end
        local cam = workspace.CurrentCamera
        return cam and cam.CFrame.Position or nil
    end

    local function buildBaseIgnore()
        local baseIgnore = {}
        for _, pl in Players:GetPlayers() do
            local ch = pl.Character
            if ch and ch:IsA("Model") then table.insert(baseIgnore, ch) end
        end
        local camFolderInst = workspace:FindFirstChild("Camera")
        if camFolderInst then
            for _, d in camFolderInst:GetDescendants() do
                if d and d:IsA("Model") and d.Name == "m_Zombie" then table.insert(baseIgnore, d) end
            end
        end
        return baseIgnore
    end

    local WALL_CHECK_TRANSPARENCY_THRESHOLD = 0.95
    local WALL_CHECK_SAMPLE_AXIS_SCALE = 0.35
    local WALL_CHECK_MIN_SAMPLE_OFFSET = 0.4
    local WALL_CHECK_MAX_SAMPLE_OFFSET = 2.75
    local WALL_CHECK_REQUIRED_CLEAR_RATIO = 0.6
    local EPS = 1e-4

    local function getWallCheckSamplePositions(part, aimPosOverride)
        if not part or not part.Parent then return {} end
        local basePos = aimPosOverride or part.Position
        local cf = part.CFrame
        local size = part.Size or v3new(1,1,1)
        local function axisOffset(comp)
            local scaled = comp * WALL_CHECK_SAMPLE_AXIS_SCALE
            if scaled < WALL_CHECK_MIN_SAMPLE_OFFSET then scaled = WALL_CHECK_MIN_SAMPLE_OFFSET end
            if scaled > WALL_CHECK_MAX_SAMPLE_OFFSET then scaled = WALL_CHECK_MAX_SAMPLE_OFFSET end
            return scaled
        end
        local xOff = axisOffset(size.X)
        local yOff = axisOffset(size.Y)
        local zOff = axisOffset(size.Z)
        local offsets = {
            v3new(0,0,0),
            v3new(0, yOff, 0),
            v3new(0, -yOff, 0),
            v3new(xOff, 0, 0),
            v3new(-xOff, 0, 0),
            v3new(0, 0, zOff),
            v3new(0, 0, -zOff)
        }
        local samples = {}
        for _, offset in offsets do
            samples[#samples+1] = basePos + cf:VectorToWorldSpace(offset)
        end
        return samples
    end

    local function isObstructedBetweenIterative(origin, targetPos, targetModel, baseIgnore)
        if not SA.CHECK_WALLS then return false end
        if not targetPos then return false end
        local actualOrigin = origin
        if LocalPlayer.Character then
            local head = LocalPlayer.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then actualOrigin = head.Position end
        end
        if not actualOrigin then return false end
        local dir = targetPos - actualOrigin
        local dist = dir.Magnitude
        if dist <= 0 then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = {}
        if baseIgnore then for i = 1, #baseIgnore do filter[#filter+1] = baseIgnore[i] end end
        if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
        params.FilterDescendantsInstances = filter
        local maxIter = 16
        local remaining = dist
        local originPos = actualOrigin
        local dirUnit = dir.Unit
        local epsilon = 0.25
        for _ = 1, maxIter do
            local ok, result = pcall(function() return workspace:Raycast(originPos, dirUnit * remaining, params) end)
            if not ok or not result then return false end
            local hit = result.Instance
            if not hit then return false end
            if targetModel and hit:IsDescendantOf(targetModel) then return false end
            local isBase = hit:IsA("BasePart")
            local transparency = isBase and hit.Transparency or 0
            local canCollide = isBase and hit.CanCollide
            local nonBlocking = false
            if isBase and (not canCollide or transparency >= WALL_CHECK_TRANSPARENCY_THRESHOLD) then nonBlocking = true end
            local ancestor = hit
            while ancestor and ancestor.Parent do
                if ancestor:IsA("Model") and ancestor.Name == "m_Zombie" then nonBlocking = true; break end
                ancestor = ancestor.Parent
            end
            for _, pl in Players:GetPlayers() do
                local ch = pl.Character
                if ch and hit:IsDescendantOf(ch) then nonBlocking = true; break end
            end
            if nonBlocking then
                table.insert(params.FilterDescendantsInstances, hit)
                local advance = result.Position + dirUnit * epsilon
                if (advance - actualOrigin).Magnitude >= dist - EPS then return false end
                originPos = advance
                remaining = (targetPos - originPos).Magnitude
            else
                return true
            end
        end
        return true
    end

    local function hasClearShotOnPart(originPos, aimPart, targetModel, baseIgnore, aimPosOverride)
        if not SA.CHECK_WALLS then return true end
        if not originPos or not aimPart or not aimPart.Parent then return false end
        local samples = getWallCheckSamplePositions(aimPart, aimPosOverride)
        if #samples == 0 then return false end
        local required = mathMax(1, mathCeil(#samples * WALL_CHECK_REQUIRED_CLEAR_RATIO))
        local clear = 0
        for _, sample in samples do
            if not isObstructedBetweenIterative(originPos, sample, targetModel, baseIgnore) then
                clear = clear + 1
                if clear >= required then return true end
            end
        end
        return false
    end

    local function isZombieSpawning(model)
        if not model then return false end
        local state = model:FindFirstChild("State")
        if state and state:IsA("StringValue") and state.Value == "Spawn" then return true end
        local agent = model:FindFirstChild("Agent")
        if agent then
            local agentState = agent:FindFirstChild("State")
            if agentState and agentState:IsA("StringValue") and agentState.Value == "Spawn" then return true end
        end
        return false
    end

    local function findBestAimPart(zombie)
        if not zombie or not zombie.Parent then return nil end
        local head = zombie:FindFirstChild("Head", true)
        if head then return head end
        local torso = zombie:FindFirstChild("Torso") or zombie:FindFirstChild("UpperTorso") or zombie:FindFirstChild("HumanoidRootPart")
        if torso then return torso end
        local barrel = zombie:FindFirstChild("Barrel", true)
        if barrel then return barrel end
        return zombie.PrimaryPart
    end

    local function getAimPosition(part)
        if not part or not part.Parent then return nil end
        return part.Position
    end

    function SA.updateIndicator(aimPos, hasTarget)
        if not aimPos then
            if SA.indicatorData then
                if SA.indicatorData.billboard then SA.indicatorData.billboard:Destroy() end
                SA.indicatorData = nil
            end
            if SA.indicatorPart then
                SA.indicatorPart:Destroy()
                SA.indicatorPart = nil
            end
            return
        end

        if not SA.indicatorPart or not SA.indicatorPart.Parent then
            SA.indicatorPart = Instance.new("Part")
            SA.indicatorPart.Name = "SilentAimIndicatorAnchor"
            SA.indicatorPart.Size = v3new(0.2, 0.2, 0.2)
            SA.indicatorPart.Transparency = 1
            SA.indicatorPart.CanCollide = false
            SA.indicatorPart.Anchored = true
            SA.indicatorPart.Parent = workspace
        end
        SA.indicatorPart.Position = aimPos

        if not SA.indicatorData or not SA.indicatorData.billboard or not SA.indicatorData.billboard.Parent then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 25, 0, 25)
            bill.StudsOffset = v3new(0, 0, 0)
            bill.AlwaysOnTop = true
            bill.Adornee = SA.indicatorPart
            bill.Parent = SA.indicatorPart

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 1, 0)
            container.BackgroundTransparency = 1
            container.Parent = bill

            local outer = Instance.new("Frame")
            outer.Size = UDim2.new(1, 0, 1, 0)
            outer.BackgroundTransparency = 1
            outer.Parent = container
            local outerStroke = Instance.new("UIStroke")
            outerStroke.Thickness = 1.0
            outerStroke.Color = c3rgb(255, 255, 255)
            outerStroke.Transparency = 0.2
            outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            outerStroke.Parent = outer
            local outerCorner = Instance.new("UICorner")
            outerCorner.CornerRadius = UDim.new(1, 0)
            outerCorner.Parent = outer

            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(0.65, 0, 0.65, 0)
            inner.Position = UDim2.new(0.175, 0, 0.175, 0)
            inner.BackgroundTransparency = 1
            inner.Parent = container
            local innerStroke = Instance.new("UIStroke")
            innerStroke.Thickness = 0.7
            innerStroke.Color = c3rgb(255, 255, 255)
            innerStroke.Transparency = 0.35
            innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            innerStroke.Parent = inner
            local innerCorner = Instance.new("UICorner")
            innerCorner.CornerRadius = UDim.new(1, 0)
            innerCorner.Parent = inner

            SA.indicatorData = {
                billboard = bill,
                container = container,
                outer = outer,
                outerStroke = outerStroke,
                inner = inner,
                innerStroke = innerStroke,
                hasTarget = false,
            }

            task.spawn(function()
                while SA.indicatorData and SA.indicatorData.billboard and SA.indicatorData.billboard.Parent do
                    local target = SA.indicatorData.hasTarget
                    local breath = (math.sin(tick_() * 4) + 1) / 2 * 0.2 + 0.15
                    local breath2 = (math.sin(tick_() * 4 + 0.5) + 1) / 2 * 0.25 + 0.2

                    if target then
                        local g = 0.7 + (math.sin(tick_() * 2) + 1) / 2 * 0.3
                        local color = c3rgb(0, mathFloor(g * 255), 80)
                        if SA.indicatorData.outerStroke then
                            SA.indicatorData.outerStroke.Color = color
                            SA.indicatorData.outerStroke.Transparency = breath
                        end
                        if SA.indicatorData.innerStroke then
                            SA.indicatorData.innerStroke.Color = color
                            SA.indicatorData.innerStroke.Transparency = breath2
                        end
                    else
                        local white = c3rgb(255, 255, 255)
                        if SA.indicatorData.outerStroke then
                            SA.indicatorData.outerStroke.Color = white
                            SA.indicatorData.outerStroke.Transparency = breath
                        end
                        if SA.indicatorData.innerStroke then
                            SA.indicatorData.innerStroke.Color = white
                            SA.indicatorData.innerStroke.Transparency = breath2
                        end
                    end
                    task.wait(0.02)
                end
            end)
        else
            if SA.indicatorData.billboard.Adornee ~= SA.indicatorPart then
                SA.indicatorData.billboard.Adornee = SA.indicatorPart
            end
            SA.indicatorData.hasTarget = hasTarget
        end
    end

    function SA.hideIndicator()
        if SA.indicatorData then
            if SA.indicatorData.billboard then SA.indicatorData.billboard:Destroy() end
            SA.indicatorData = nil
        end
        if SA.indicatorPart then
            SA.indicatorPart:Destroy()
            SA.indicatorPart = nil
        end
    end

    function SA.StartSilentAimLoop()
        if SA.SilentAimUpdateConn then return end
        SA.SilentAimUpdateConn = RunService.Heartbeat:Connect(function()
            local hasSelection = SA.Enabled and (#SA.SilentAimSelectedTypes > 0)
            if not hasSelection then
                SA.SilentAimCurrentTarget = nil
                SA.SilentAimCurrentModel = nil
                SA.hideIndicator()
                return
            end
            local equippedTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            local equippedIsGun = equippedTool and (equippedTool:FindFirstChild("Animations") and (equippedTool.Animations:FindFirstChild("Aim") or equippedTool.Animations:FindFirstChild("Aiming")))
            if not equippedIsGun then
                SA.SilentAimCurrentTarget = nil
                SA.SilentAimCurrentModel = nil
                SA.hideIndicator()
                return
            end
            local targetPart, targetModel = nil, nil
            if SA.SilentAimSelectedTypes and #SA.SilentAimSelectedTypes > 0 then
                local range = SA.MAX_TARGET_RANGE
                local cam = workspace.CurrentCamera
                local origin = getWallCheckOrigin()
                if not origin then return end
                local baseIgnore = buildBaseIgnore()
                local bestPart, bestModel, bestDist = nil, nil, range + 1
                local bestPredictedPos = nil
                local sel = {}
                for _, t in SA.SilentAimSelectedTypes do sel[t] = true end
                local zombiesFolder = workspace:FindFirstChild("Zombies")
                if zombiesFolder then
                    for _, model in zombiesFolder:GetChildren() do
                        if model:IsA("Model") and not isZombieSpawning(model) then
                            local zType = GetZombieTypeFromModel(model)
                            if zType and sel[zType] then
                                local aimPart = findBestAimPart(model)
                                if aimPart and aimPart:IsA("BasePart") then
                                    local aimPos = getAimPosition(aimPart)
                                    if SA.SILENT_AIM_USE_FOV then
                                        if not SA.isWorldPosInSilentAimFov(aimPos) then continue end
                                    end
                                    local d = (aimPos - origin).Magnitude
                                    if d < bestDist and d <= range then
                                        if SA.CHECK_WALLS then
                                            local hasClear = hasClearShotOnPart(origin, aimPart, model, baseIgnore)
                                            if not hasClear then continue end
                                        end

                                        local predictedPos = aimPos
                                        if SA.PREDICTION_ENABLED then
                                            local bulletSpeed = getCurrentBulletSpeed()
                                            local ping = getPing()
                                            local travelTime = d / bulletSpeed + ping / 1000
                                            local targetRoot = model:FindFirstChild("HumanoidRootPart")
                                            if targetRoot then
                                                local vel = targetRoot.AssemblyLinearVelocity
                                                if vel.Magnitude > 0.05 then

                                                    local dirToTarget = (aimPos - origin).Unit
                                                    local moveDir = vel.Unit
                                                    local cosAngle = dirToTarget:Dot(moveDir)
                                                    local angleFactor = 1 - mathAbs(cosAngle) * 0.5

                                                    local referenceDist = 60
                                                    local distanceFactor = mathMin(1.2, d / referenceDist)
                                                    local coefficient = (0.2 + 0.8 * distanceFactor) * 1.2
                                                    local predictedOffset = vel * travelTime * coefficient * angleFactor

                                                    local maxOffset = mathMin(d * 0.15 + 2, 35)
                                                    if predictedOffset.Magnitude > maxOffset then
                                                        predictedOffset = predictedOffset.Unit * maxOffset
                                                    end
                                                    predictedPos = aimPos + predictedOffset
                                                end
                                            end
                                        end

                                        bestDist = d
                                        bestPart = aimPart
                                        bestModel = model
                                        bestPredictedPos = predictedPos
                                    end
                                end
                            end
                        end
                    end
                end

                if L.silentAim.headless then
                    for _, model in workspace:GetDescendants() do
                        if model:IsA("Model") and L.isHeadlessModel(model) then
                            local humanoid = model:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then

                                local aimPart = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
                                if aimPart and aimPart:IsA("BasePart") then
                                    local aimPos
                                    local isRootPart = aimPart.Name == "HumanoidRootPart"
                                    if isRootPart then
                                        aimPos = aimPart.Position + v3new(0, 2.5, 0)
                                    else
                                        aimPos = aimPart.Position
                                    end
                                    if SA.SILENT_AIM_USE_FOV then
                                        if not SA.isWorldPosInSilentAimFov(aimPos) then continue end
                                    end
                                    local d = (aimPos - origin).Magnitude
                                    if d < bestDist and d <= range then
                                        if SA.CHECK_WALLS then
                                            local hasClear = hasClearShotOnPart(origin, aimPart, model, baseIgnore, aimPos)
                                            if not hasClear then continue end
                                        end

                                        local predictedPos = aimPos
                                        if SA.PREDICTION_ENABLED then
                                            local bulletSpeed = getCurrentBulletSpeed()
                                            local ping = getPing()
                                            local travelTime = d / bulletSpeed + ping / 1000
                                            local targetRoot = model:FindFirstChild("HumanoidRootPart")
                                            if targetRoot then
                                                local vel = targetRoot.AssemblyLinearVelocity
                                                if vel.Magnitude > 0.05 then
                                                    local dirToTarget = (aimPos - origin).Unit
                                                    local moveDir = vel.Unit
                                                    local cosAngle = dirToTarget:Dot(moveDir)
                                                    local angleFactor = 1 - mathAbs(cosAngle) * 0.5
                                                    local referenceDist = 60
                                                    local distanceFactor = mathMin(1.2, d / referenceDist)
                                                    local coefficient = (0.2 + 0.8 * distanceFactor) * 1.2
                                                    local predictedOffset = vel * travelTime * coefficient * angleFactor
                                                    local maxOffset = mathMin(d * 0.15 + 2, 35)
                                                    if predictedOffset.Magnitude > maxOffset then
                                                        predictedOffset = predictedOffset.Unit * maxOffset
                                                    end
                                                    predictedPos = aimPos + predictedOffset
                                                end
                                            end
                                        end

                                        bestDist = d
                                        bestPart = aimPart
                                        bestModel = model
                                        bestPredictedPos = predictedPos
                                    end
                                end
                            end
                        end
                    end
                end

                if bestPart then
                    if SA.PREDICTION_ENABLED and bestPredictedPos then
                        SA.SilentAimCurrentTarget = {
                            Position = bestPredictedPos,
                            Parent = bestPart and bestPart.Parent or nil,
                            IsPredicted = true,
                        }
                    else
                        SA.SilentAimCurrentTarget = bestPart
                    end
                    SA.SilentAimCurrentModel = bestModel
                    local targetPos = SA.PREDICTION_ENABLED and bestPredictedPos or (bestPart.Position)
                    SA.updateIndicator(targetPos, true)
                else
                    SA.SilentAimCurrentTarget = nil
                    SA.SilentAimCurrentModel = nil
                    SA.hideIndicator()
                end
            end
        end)
    end

    function SA.StopSilentAimLoop()
        if SA.SilentAimUpdateConn then
            SA.SilentAimUpdateConn:Disconnect()
            SA.SilentAimUpdateConn = nil
        end
        SA.SilentAimCurrentTarget = nil
        SA.SilentAimCurrentModel = nil
        SA.hideIndicator()
    end


    function SA.SetupSilentAimHooks()
        if SA.oldFire then return end
        if type(hookmetamethod) ~= "function" then
            warn("Silent Aim: hookmetamethod not available")
            return
        end
        SA.oldFire = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and SA.Enabled then
                local args = {...}
                if args[1] == "Fire" and SA.SilentAimCurrentTarget then
                    local char = LocalPlayer.Character
                    if char then
                        local targetPos

                        if type(SA.SilentAimCurrentTarget) == "table" and SA.SilentAimCurrentTarget.IsPredicted then
                            targetPos = SA.SilentAimCurrentTarget.Position
                        elseif SA.SilentAimCurrentTarget.Parent then
                            targetPos = SA.SilentAimCurrentTarget.Position
                        else
                            return SA.oldFire(self, ...)
                        end
                        local newArgs = {}
                        newArgs[1] = "Fire"
                        newArgs[2] = args[2] or (char:FindFirstChild("Model") or char)
                        newArgs[3] = targetPos
                        newArgs[4] = args[4] or workspace:GetServerTimeNow()
                        return SA.oldFire(self, unpack(newArgs))
                    end
                end
            end
            return SA.oldFire(self, ...)
        end)
    end

    function SA.RemoveSilentAimHooks()
        if SA.oldFire then
            hookmetamethod(game, "__namecall", SA.oldFire)
            SA.oldFire = nil
        end
    end

    L.onCharacterAdded(function()
        if SA.Enabled then
            SA.RemoveSilentAimHooks()
            task.wait(0.1)
            SA.SetupSilentAimHooks()
        end
    end)

    L.silentAim = L.silentAim or {}
    L.silentAim.bomber = false
    L.silentAim.cuirassier = false
    L.silentAim.runner = false
    L.silentAim.zapper = false
    L.silentAim.igniter = false
    L.silentAim.shambler = false
    L.silentAim.headless = false

    local function updateSilentAimSelection()
        local selected = {}
        if L.silentAim.bomber then table.insert(selected, "Bomber") end
        if L.silentAim.cuirassier then table.insert(selected, "Cuirassier") end
        if L.silentAim.runner then table.insert(selected, "Runner") end
        if L.silentAim.zapper then table.insert(selected, "Zapper") end
        if L.silentAim.igniter then table.insert(selected, "Igniter") end
        if L.silentAim.shambler then table.insert(selected, "Shambler") end
        if L.silentAim.headless then table.insert(selected, "Headless") end
        SA.SilentAimSelectedTypes = selected
        if #selected > 0 then
            SA.Enabled = true
            SA.StartSilentAimLoop()
            SA.SetupSilentAimHooks()
        else
            SA.Enabled = false
            SA.StopSilentAimLoop()
            SA.RemoveSilentAimHooks()
        end
    end

    local AutoShootGroup = Tabs.Main:AddGroupbox({ Side = "Left", Name = "静默自瞄", IconName = "target", Description = "自动瞄准" })
    AutoShootGroup:AddLabel('目标选择')

    AutoShootGroup:AddToggle('SilentAimBomber', {
        Text = '自瞄自爆',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄自爆僵尸'),
        Callback = function(v)
            L.silentAim.bomber = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimCuirassier', {
        Text = '自瞄胸甲骑兵',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄胸甲骑兵'),
        Callback = function(v)
            L.silentAim.cuirassier = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimRunner', {
        Text = '自瞄红眼',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄红眼僵尸'),
        Callback = function(v)
            L.silentAim.runner = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimZapper', {
        Text = '自瞄斧头僵尸',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄斧头僵尸'),
        Callback = function(v)
            L.silentAim.zapper = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimIgniter', {
        Text = '自瞄点火者',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄点火者'),
        Callback = function(v)
            L.silentAim.igniter = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimShambler', {
        Text = '自瞄普通僵尸',
        Default = false,
        Tooltip = TranslateTooltip('开启后自瞄普通僵尸'),
        Callback = function(v)
            L.silentAim.shambler = v
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddToggle('SilentAimHeadless', {
        Text = '自瞄无头骑士',
        Default = false,
        Callback = function(v)
            L.silentAim.headless = v
            if not v then SA.hideIndicator() end
            updateSilentAimSelection()
        end
    })

    AutoShootGroup:AddDivider()
    AutoShootGroup:AddLabel('攻击设置')

    AutoShootGroup:AddToggle('SilentAimWallCheck', {
        Text = '墙体检测',
        Default = true,
        Tooltip = TranslateTooltip('开启后不会瞄准被墙体遮挡的僵尸'),
        Callback = function(v)
            SA.CHECK_WALLS = v
        end
    })

    L.noRecoilEnabled = false
    L.disabledRecoilConnections = nil

    function L.toggleNoRecoil(state)
        if state then
            if not L.disabledRecoilConnections then
                local recoilEvent = ReplicatedStorage:FindFirstChild("RecoilEvent")
                if not recoilEvent then
                    warn("请等待复活")
                    return
                end
                if type(getconnections) ~= "function" then
                    return
                end
                local disabled = {}
                local ok = pcall(function()
                    for _, v in getconnections(recoilEvent.Event) do
                        v:Disable()
                        table.insert(disabled, v)
                    end
                end)
                if not ok or #disabled == 0 then return end
                L.disabledRecoilConnections = disabled
                L.noRecoilEnabled = true
            end
        else
            L.noRecoilEnabled = false
            if L.disabledRecoilConnections then
                for _, v in L.disabledRecoilConnections do
                    pcall(function() v:Enable() end)
                end
                L.disabledRecoilConnections = nil
            end
        end
    end

    L.onCharacterAdded(function()
        if L.noRecoilEnabled and L.disabledRecoilConnections then
            local recoilEvent = ReplicatedStorage:FindFirstChild("RecoilEvent")
            if recoilEvent then
                for _, v in getconnections(recoilEvent.Event) do
                    if v.Enabled then
                        v:Disable()
                        table.insert(L.disabledRecoilConnections, v)
                    end
                end
            end
        end
    end)

    AutoShootGroup:AddToggle('NoRecoilToggle', {
        Text = '无后坐力',
        Default = false,
        Tooltip = TranslateTooltip('禁用枪械后坐力'),
        Callback = function(v)
            L.toggleNoRecoil(v)
        end
    })

    AutoShootGroup:AddToggle('SilentAimPrediction', {
        Text = '预判射击',
        Default = false,
        Callback = function(v)
            SA.PREDICTION_ENABLED = v
        end
    })

    AutoShootGroup:AddSlider('SilentAimRange', {
        Text = '瞄准距离',
        Default = 200,
        Min = 50,
        Max = 600,
        Rounding = 0,
        Callback = function(v)
            SA.MAX_TARGET_RANGE = v
        end
    })

    AutoShootGroup:AddDivider()
    AutoShootGroup:AddLabel('FOV 设置')

    AutoShootGroup:AddToggle('SilentAimFOVToggle', {
        Text = '启用 FOV',
        Default = false,
        Tooltip = TranslateTooltip('只在 FOV 范围内自瞄'),
        Callback = function(v)
            SA.SILENT_AIM_USE_FOV = v
            SA.UpdateSilentAimFovCircle()
        end
    })

    AutoShootGroup:AddToggle('SilentAimShowFOV', {
        Text = '显示 FOV 圆圈',
        Default = false,
        Tooltip = TranslateTooltip('显示自瞄 FOV 范围'),
        Callback = function(v)
            SA.SILENT_AIM_SHOW_FOV = v
            SA.UpdateSilentAimFovCircle()
        end
    })

    AutoShootGroup:AddSlider('SilentAimFOVSize', {
        Text = 'FOV 大小',
        Default = 50,
        Min = 10,
        Max = 120,
        Rounding = 0,
        Callback = function(v)
            SA.SILENT_AIM_FOV_SIZE = v
            SA.UpdateSilentAimFovCircle()
        end
    })

    updateSilentAimSelection()
end

L.engineerAutoRepairEnabled = false
L.autoRepairLoop = nil
L.repairCooldown = 0.05
L.autoRepairTargetMode = "Closest"
L.autoRepairRange = 25

local cachedHammerRemote = nil
local cachedHammerRemoteTime = 0
local HAMMER_CACHE_TTL = 2

local cachedBuildableFolders = nil
local cachedBuildableFoldersTime = 0
local FOLDER_CACHE_TTL = 10

function L.getLookedStructure()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local direction = cam.CFrame.LookVector * 50
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, direction, params)
    if not result then return nil end
    local hit = result.Instance
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    local buildHealth = model:FindFirstChild("BuildingHealth") or (model.Parent and model.Parent:FindFirstChild("BuildingHealth"))
    return buildHealth
end

function L.getHammerRemote()
    local now = time()
    if cachedHammerRemote and (now - cachedHammerRemoteTime) < HAMMER_CACHE_TTL then
        if cachedHammerRemote.Parent then return cachedHammerRemote end
        cachedHammerRemote = nil
    end

    local lp = LocalPlayer
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        local hammer = backpack:FindFirstChild("Hammer") or backpack:FindFirstChild("Claw Hammer")
        if hammer and hammer:FindFirstChild("RemoteEvent") then
            cachedHammerRemote = hammer.RemoteEvent
            cachedHammerRemoteTime = now
            return cachedHammerRemote
        end
    end
    local char = lp.Character
    if char then
        local hammer = char:FindFirstChild("Hammer") or char:FindFirstChild("Claw Hammer")
        if hammer and hammer:FindFirstChild("RemoteEvent") then
            cachedHammerRemote = hammer.RemoteEvent
            cachedHammerRemoteTime = now
            return cachedHammerRemote
        end
    end
    local wsPlayers = workspace:FindFirstChild("Players")
    if wsPlayers then
        local playerFolder = wsPlayers:FindFirstChild(lp.Name)
        if playerFolder then
            local hammerFolder = playerFolder:FindFirstChild("Hammer") or playerFolder:FindFirstChild("Claw Hammer")
            if hammerFolder then
                local re = hammerFolder:FindFirstChild("RemoteEvent")
                if re then
                    cachedHammerRemote = re
                    cachedHammerRemoteTime = now
                    return re
                end
            end
        end
    end
    return nil
end

function L.getBuildableFolders()
    local now = time()
    if cachedBuildableFolders and (now - cachedBuildableFoldersTime) < FOLDER_CACHE_TTL then
        return cachedBuildableFolders
    end

    local folders = {}
    local folderNames = {"Buildables", "Stakes", "Barricades", "Structures", "Buildings"}
    for _, name in folderNames do
        local folder = workspace:FindFirstChild(name)
        if folder then folders[#folders + 1] = folder end
    end

    for _, mapFolder in workspace:GetChildren() do
        if mapFolder:IsA("Folder") or mapFolder:IsA("Model") then
            local modes = mapFolder:FindFirstChild("Modes")
            if modes then folders[#folders + 1] = modes end
        end
    end

    cachedBuildableFolders = folders
    cachedBuildableFoldersTime = now
    return folders
end

local _richBuildBuf = {}
local _richBuildSeen = {}
local _richBuildCount = 0
local MAX_RICH_BUILDABLES = 40

function L.getRichBuildables()
    local char = LocalPlayer.Character
    if not char then return _richBuildBuf, 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return _richBuildBuf, 0 end
    local rootPos = root.Position
    local rangeSq = L.autoRepairRange * L.autoRepairRange

    _richBuildCount = 0
    for k in _richBuildSeen do _richBuildSeen[k] = nil end

    local folders = L.getBuildableFolders()

    local function tryAdd(inst)
        if _richBuildCount >= MAX_RICH_BUILDABLES then return end
        local pos = nil
        if inst:IsA("BasePart") then
            pos = inst.Position
        elseif inst:IsA("Model") then
            local p = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
            if p then pos = p.Position end
        end
        if not pos then return end

        local dx, dy, dz = pos.X - rootPos.X, pos.Y - rootPos.Y, pos.Z - rootPos.Z
        local distSq = dx*dx + dy*dy + dz*dz
        if distSq > rangeSq then return end

        local healthObj = inst:FindFirstChild("BuildingHealth") or inst:FindFirstChild("ConstructHealth")
        if not healthObj then
            local h = inst:FindFirstChild("Health")
            if h and h:IsA("NumberValue") then healthObj = h end
        end
        if not healthObj or _richBuildSeen[healthObj] then return end
        _richBuildSeen[healthObj] = true

        local cur = healthObj.Value
        if not cur then return end
        local max = healthObj:GetAttribute("MaxHealth") or healthObj:GetAttribute("Max") or 100
        if max == 0 then return end
        if cur >= max then return end

        _richBuildCount = _richBuildCount + 1
        local entry = _richBuildBuf[_richBuildCount]
        if entry then
            entry.obj = healthObj
            entry.cur = cur
            entry.max = max
            entry.ratio = cur / max
            entry.dist = distSq
        else
            _richBuildBuf[_richBuildCount] = {
                obj = healthObj,
                cur = cur,
                max = max,
                ratio = cur / max,
                dist = distSq
            }
        end
    end

    for _, folder in folders do
        if _richBuildCount >= MAX_RICH_BUILDABLES then break end
        for _, inst in folder:GetChildren() do
            if _richBuildCount >= MAX_RICH_BUILDABLES then break end
            tryAdd(inst)
            if inst:IsA("Model") or inst:IsA("Folder") then
                for _, sub in inst:GetChildren() do
                    if _richBuildCount >= MAX_RICH_BUILDABLES then break end
                    tryAdd(sub)
                end
            end
        end
    end

    for i = _richBuildCount + 1, #_richBuildBuf do
        _richBuildBuf[i] = nil
    end

    return _richBuildBuf, _richBuildCount
end

function L.fireRepairSilent(buildHealth)
    if not buildHealth then return end
    local remote = L.getHammerRemote()
    if not remote then return end
    pcall(function() remote:FireServer("Repair", buildHealth) end)
end

function L.doAutoRepair()
    if L.autoRepairTargetMode == "Aimed" then
        local buildHealth = L.getLookedStructure()
        if buildHealth then
            local currentHealth = buildHealth.Value
            local maxHealth = buildHealth:GetAttribute("MaxHealth")
            if maxHealth and currentHealth < maxHealth then
                L.fireRepairSilent(buildHealth)
            end
        end
        return
    end

    if L.autoRepairTargetMode == "None" then return end

    local buf, count = L.getRichBuildables()
    if count == 0 then return end

    local target = nil

    if L.autoRepairTargetMode == "Closest" then
        local bestDist = buf[1].dist
        target = buf[1].obj
        for i = 2, count do
            if buf[i].dist < bestDist then
                bestDist = buf[i].dist
                target = buf[i].obj
            end
        end
    elseif L.autoRepairTargetMode == "LowestHealth" then
        local bestRatio = buf[1].ratio
        local bestCur = buf[1].cur
        target = buf[1].obj
        for i = 2, count do
            local e = buf[i]
            if e.ratio < bestRatio or (e.ratio == bestRatio and e.cur < bestCur) then
                bestRatio = e.ratio
                bestCur = e.cur
                target = e.obj
            end
        end
    end

    if target then
        L.fireRepairSilent(target)
    end
end

function L.autoRepairLoopFunc()
    while L.engineerAutoRepairEnabled do
        L.doAutoRepair()
        task.wait(L.repairCooldown)
    end
end

function L.toggleEngineerAutoRepair(state)
    L.engineerAutoRepairEnabled = state
    if state then
        if L.autoRepairLoop then task.cancel(L.autoRepairLoop) end
        L.autoRepairLoop = task.spawn(L.autoRepairLoopFunc)
        L.notify(TranslateText("自动修复已开启（静默模式）"), 2)
    else
        if L.autoRepairLoop then
            task.cancel(L.autoRepairLoop)
            L.autoRepairLoop = nil
        end
        L.notify(TranslateText("自动修复已关闭"), 2)
    end
end


ExtraLeftGroup:AddToggle('AutoRepairToggle', {
    Text = '静默自动修建筑',
    Default = false,
    Tooltip = TranslateTooltip('自动修复瞄准的建筑（无需装备锤子）'),
    Callback = function(v)
        L.toggleEngineerAutoRepair(v)
    end
})

ExtraLeftGroup:AddDropdown('AutoRepairMode', {
    Text = '修复目标模式',
    Values = {"瞄准建筑", "最近建筑", "最低生命值建筑"},
    Value = "最近建筑",
    FormatDisplayValue = function(Value)
        return InterfaceLanguage == "English" and (EnglishText[Value] or Value) or Value
    end,
    Callback = function(value)
        if value == "瞄准建筑" then
            L.autoRepairTargetMode = "Aimed"
        elseif value == "最近建筑" then
            L.autoRepairTargetMode = "Closest"
        elseif value == "最低生命值建筑" then
            L.autoRepairTargetMode = "LowestHealth"
        end
    end
})




L.forceBrace = L.forceBrace or {}
L.forceBrace.enabled = false
L.forceBrace.thread = nil

function L.forceBrace.getRemote()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, name in {"Axe", "Pickaxe", "Baguette"} do
        local tool = backpack:FindFirstChild(name)
        if tool then
            local remote = tool:FindFirstChild("RemoteEvent")
            if remote then return remote end
        end
    end
    return nil
end

function L.forceBrace.sendBrace()
    local remote = L.forceBrace.getRemote()
    if remote then pcall(function() remote:FireServer("BraceBlock") end) end
end

function L.forceBrace.loop()
    while L.forceBrace.enabled do
        L.forceBrace.sendBrace()
        task.wait(0.2)
    end
end

function L.forceBrace.start()
    if L.forceBrace.enabled then return end
    L.forceBrace.enabled = true
    if L.forceBrace.thread then task.cancel(L.forceBrace.thread) end
    L.forceBrace.thread = task.spawn(L.forceBrace.loop)
    L.notify(TranslateText("静默格挡已开启"), 2)
end

function L.forceBrace.stop()
    L.forceBrace.enabled = false
    if L.forceBrace.thread then task.cancel(L.forceBrace.thread); L.forceBrace.thread = nil end
    L.notify(TranslateText("静默格挡已关闭"), 2)
end

ExtraLeftGroup:AddToggle('ForceBraceToggle', {
    Text = '静默格挡',
    Default = false,
    Tooltip = TranslateTooltip('自动格挡劈砍（无需手持武器）'),
    Callback = function(v)
        if v then L.forceBrace.start() else L.forceBrace.stop() end
    end
})

L.axeStunActive = false
L.axeStunConnection = nil
L.axeStunRange = 15
L.axeStunCount = 5
L.axeStunDelay = 0
L.axeStunLastFire = 0

local function getMeleeWeapon()
    local char = LocalPlayer.Character
    if char then
        for _, item in char:GetChildren() do
            if item:GetAttribute("Melee") then
                return item
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in backpack:GetChildren() do
            if item:GetAttribute("Melee") then
                return item
            end
        end
    end
    return nil
end

local ELBOW_VALID_WEAPONS = {Axe = true, Pickaxe = true, Baguette = true}

local function fireStunRemote(remote, zombie, position)
    remote:FireServer("BraceBlock")
    remote:FireServer("StopBraceBlock")
    remote:FireServer("FeedbackStun", zombie, position)
end

local function executeStun(zombie)
    local weapon = getMeleeWeapon()
    if not weapon or not ELBOW_VALID_WEAPONS[weapon.Name] then return end
    local state = zombie:FindFirstChild("State")
    if state and state.Value == "Stunned" then return end
    local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
    if not zombieRoot then return end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return end

    fireStunRemote(remote, zombie, zombieRoot.CFrame.Position)
end

function L.startAxeStun()
    if L.axeStunConnection then return end
    L.axeStunActive = true
    L.axeStunConnection = RunService.Heartbeat:Connect(function()
        if not L.axeStunActive then return end
        if tick_() - L.axeStunLastFire < L.axeStunDelay then return end
        local char = LocalPlayer.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if not zombiesFolder then return end

        local candidates = {}
        for _, zombie in zombiesFolder:GetChildren() do
            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                local distance = (zombie.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance <= L.axeStunRange then
                    table.insert(candidates, {zombie = zombie, dist = distance})
                end
            end
        end
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
        local toStun = mathMin(L.axeStunCount, #candidates)
        for i = 1, toStun do
            executeStun(candidates[i].zombie)
        end
        L.axeStunLastFire = tick_()
    end)
end

function L.stopAxeStun()
    L.axeStunActive = false
    if L.axeStunConnection then
        L.axeStunConnection:Disconnect()
        L.axeStunConnection = nil
    end
end

L.onCharacterAdded(function()
    if L.axeStunActive then
        L.stopAxeStun()
        if Toggles.AxeStunToggle then
            Toggles.AxeStunToggle:SetValue(false)
        end
    end
end)

ExtraLeftGroup:AddToggle('AxeStunToggle', {
    Text = '肘击',
    Default = false,
    Tooltip = TranslateTooltip('自动肘击范围15格内的僵尸'),
    Callback = function(v)
        if v then
            L.startAxeStun()
        else
            L.stopAxeStun()
        end
    end
})

ExtraLeftGroup:AddSlider('AxeStunRange', {
    Text = '肘击距离',
    Default = 15,
    Min = 5,
    Max = 35,
    Rounding = 0,
    Suffix = " 格",
    Callback = function(Value)
        L.axeStunRange = Value
    end
})

ExtraLeftGroup:AddSlider('AxeStunCount', {
    Text = '肘击数量',
    Default = 5,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Suffix = " 个",
    Callback = function(Value)
        L.axeStunCount = Value
    end
})

ExtraLeftGroup:AddSlider('AxeStunDelay', {
    Text = '肘击间隔',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = " 秒",
    Callback = function(Value)
        L.axeStunDelay = Value
    end
})




L.engineerElbowEnabled = false
L.engineerAnimConnection = nil
L.engineerElbowRange = 50
L.engineerElbowCount = 5

local ELBOW_TRIGGER_ANIMATIONS = {"rbxassetid://15345113937"}

function L.getValidMelee()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local name = tool.Name
    if name == "Pickaxe" or name == "Axe" or name == "Baguette" then return tool end
    return nil
end

function L.stunAroundPlayer()
    if not L.engineerElbowEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = L.getValidMelee()
    if not tool then return end
    local remote = tool:FindFirstChild("RemoteEvent")
    if not remote then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local playerPos = rootPart.Position
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    local candidates = {}
    for _, zombie in zombiesFolder:GetChildren() do
        if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
            if zombie:GetAttribute("Type") == "Barrel" then continue end
            local state = zombie:FindFirstChild("State")
            if state and state.Value == "Spawn" then continue end
            local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
            if not zombieRoot then continue end
            local dist = (zombieRoot.Position - playerPos).Magnitude
            if dist <= L.engineerElbowRange then
                if zombie:FindFirstChild("State") and zombie.State.Value ~= "Stunned" then
                    table.insert(candidates, {zombie = zombie, root = zombieRoot, dist = dist})
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local toStun = mathMin(L.engineerElbowCount, #candidates)
    for i = 1, toStun do
        local entry = candidates[i]
        pcall(function()
            fireStunRemote(remote, entry.zombie, entry.root.Position)
        end)
    end
end

function L.onElbowAnimationPlayed(animationTrack)
    if not L.engineerElbowEnabled then return end
    local animId = animationTrack.Animation.AnimationId
    for _, targetId in ELBOW_TRIGGER_ANIMATIONS do
        if animId == targetId then
            L.stunAroundPlayer()
            break
        end
    end
end

function L.updateEngineerAnimConnection()
    if L.engineerElbowEnabled then
        if L.engineerAnimConnection then return end
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            L.engineerAnimConnection = humanoid.AnimationPlayed:Connect(L.onElbowAnimationPlayed)
        end
    else
        if L.engineerAnimConnection then
            L.engineerAnimConnection:Disconnect()
            L.engineerAnimConnection = nil
        end
    end
end

L.onCharacterAdded(L.updateEngineerAnimConnection)

ExtraLeftGroup:AddToggle('EngineerElbowToggle', {
    Text = '肘击范围扩大',
    Default = false,
    Tooltip = TranslateTooltip('扩大肘击生效范围'),
    Callback = function(v)
        L.engineerElbowEnabled = v
        L.updateEngineerAnimConnection()
    end
})

ExtraLeftGroup:AddSlider('EngineerElbowRange', {
    Text = '肘击扩大距离',
    Default = 50,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Suffix = " 格",
    Callback = function(Value)
        L.engineerElbowRange = Value
    end
})

ExtraLeftGroup:AddSlider('EngineerElbowCount', {
    Text = '肘击扩大数量',
    Default = 5,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Suffix = " 个",
    Callback = function(Value)
        L.engineerElbowCount = Value
    end
})




L.engineerRecycleEnabled = false
L.recycleAnimConnection = nil

local RECYCLE_ANIMATIONS = {
    "rbxassetid://16663569329",
    "rbxassetid://16663563130",
    "rbxassetid://109975878922735",
    "rbxassetid://12638406999",
    "rbxassetid://94131315859283",
    "rbxassetid://12638412059"
}

function L.recycleWeapon()
    if not L.engineerRecycleEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local name = tool.Name
    if name ~= "Pickaxe" and name ~= "Axe" and name ~= "Baguette" then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    tool.Parent = backpack
    task.wait(0.1)
    if L.engineerRecycleEnabled and tool.Parent == backpack then
        tool.Parent = char
    end
end

function L.onRecycleAnimationPlayed(animationTrack)
    if not L.engineerRecycleEnabled then return end
    local animId = animationTrack.Animation.AnimationId
    for _, id in RECYCLE_ANIMATIONS do
        if animId == id then
            local delay = (animId == "rbxassetid://12638412059") and 0.40 or 0.30
            task.delay(delay, L.recycleWeapon)
            break
        end
    end
end

function L.updateRecycleAnimConnection()
    if L.engineerRecycleEnabled then
        if L.recycleAnimConnection then return end
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            L.recycleAnimConnection = humanoid.AnimationPlayed:Connect(L.onRecycleAnimationPlayed)
        end
    else
        if L.recycleAnimConnection then
            L.recycleAnimConnection:Disconnect()
            L.recycleAnimConnection = nil
        end
    end
end

L.onCharacterAdded(L.updateRecycleAnimConnection)

ExtraLeftGroup:AddToggle('EngineerRecycleToggle', {
    Text = '攻击武器回收',
    Default = false,
    Tooltip = TranslateTooltip('攻击后自动卸下并重新装备武器，取消后摇'),
    Callback = function(v)
        L.engineerRecycleEnabled = v
        L.updateRecycleAnimConnection()
    end
})


local DoctorGroup = Tabs.Extra:AddGroupbox({ Side = "Right", Name = "医生", IconName = "cross", Description = "自动治疗" })




L.doctor = {
    enabled = false,
    threshold = 25,
    range = 10,
    cooldown = 2,
    lastRequest = {},
    thread = nil,
}

local function getMedicalRemote()
    local char = LocalPlayer.Character
    if not char then return nil end
    local supplies = char:FindFirstChild("Medical Supplies")
    if supplies then
        return supplies:FindFirstChild("RemoteEvent")
    end
    return nil
end

local function sendHealRequest(player, humanoid)
    if not player or not humanoid then return end
    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
    if healthPercent > L.doctor.threshold then return end
    local now = tick_()
    if (L.doctor.lastRequest[player] or 0) + L.doctor.cooldown > now then return end

    local localChar = LocalPlayer.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local targetRoot = humanoid.Parent and (humanoid.Parent:FindFirstChild("HumanoidRootPart") or humanoid.Parent:FindFirstChild("Torso"))
    if not targetRoot then return end
    if (localRoot.Position - targetRoot.Position).Magnitude > L.doctor.range then return end

    local remote = getMedicalRemote()
    if not remote then return end
    L.doctor.lastRequest[player] = now
    pcall(function()
        remote:FireServer("SendRequest", humanoid)
    end)
end

function L.doctor.loop()
    while L.doctor.enabled do
        for _, player in Players:GetPlayers() do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    pcall(sendHealRequest, player, humanoid)
                end
            end
        end
        task.wait(0.5)
    end
end

function L.doctor.start()
    if L.doctor.thread then return end
    L.doctor.enabled = true
    L.doctor.thread = task.spawn(L.doctor.loop)
    L.notify(TranslateText("自动治疗已开启"), 2)
end

function L.doctor.stop()
    L.doctor.enabled = false
    if L.doctor.thread then
        task.cancel(L.doctor.thread)
        L.doctor.thread = nil
    end
    L.doctor.lastRequest = {}
    L.notify(TranslateText("自动治疗已关闭"), 2)
end




L.doctor.autoPickup = {
    enabled = false,
    thread = nil,
    range = 5,
}

function L.doctor.autoPickup.getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function L.doctor.autoPickup.findDrop(pos, range)
    local bestPrompt, bestPart, bestDist = nil, nil, range + 1
    for _, v in workspace:GetDescendants() do
        if v:IsA("ProximityPrompt") and v.Enabled and v.Name == "ReplenishPrompt" then
            local part = v.Parent
            if part and part:IsA("BasePart") and part.Name == "SupplyVisualizer" then
                local d = (part.Position - pos).Magnitude
                if d < bestDist then
                    bestDist, bestPrompt, bestPart = d, v, part
                end
            end
        end
    end
    return bestPrompt, bestPart, bestDist
end

function L.doctor.autoPickup.loop()
    while L.doctor.autoPickup.enabled do
        local char = LocalPlayer.Character
        local hrp = L.doctor.autoPickup.getHRP(char)
        if hrp then
            local prompt, part, dist = L.doctor.autoPickup.findDrop(hrp.Position, L.doctor.autoPickup.range)
            if prompt and dist <= L.doctor.autoPickup.range then
                pcall(function() fireproximityprompt(prompt) end)
                task.wait(0.05)
            end
        end
        task.wait(0.2)
    end
end

function L.doctor.autoPickup.start()
    if L.doctor.autoPickup.thread then return end
    L.doctor.autoPickup.enabled = true
    L.doctor.autoPickup.thread = task.spawn(L.doctor.autoPickup.loop)
    L.notify(TranslateText("自动拾取纱布已开启"), 2)
end

function L.doctor.autoPickup.stop()
    L.doctor.autoPickup.enabled = false
    if L.doctor.autoPickup.thread then
        task.cancel(L.doctor.autoPickup.thread)
        L.doctor.autoPickup.thread = nil
    end
    L.notify(TranslateText("自动拾取纱布已关闭"), 2)
end

DoctorGroup:AddToggle('DoctorAutoHealToggle', {
    Text = '自动治疗受伤玩家',
    Default = false,
    Tooltip = TranslateTooltip('自动向低血量玩家发送治疗请求'),
    Callback = function(v)
        if v then L.doctor.start() else L.doctor.stop() end
    end
})

DoctorGroup:AddSlider('DoctorHealThreshold', {
    Text = '治疗阈值 (%)',
    Default = 25,
    Min = 1,
    Max = 100,
    Suffix = '%',
    Callback = function(v)
        L.doctor.threshold = v
    end
})


DoctorGroup:AddToggle('DoctorAutoPickupBandage', {
    Text = '自动拾取纱布',
    Default = false,
    Tooltip = TranslateTooltip('自动拾取附近的纱布补给'),
    Callback = function(v)
        if v then L.doctor.autoPickup.start() else L.doctor.autoPickup.stop() end
    end
})


local ChaplainGroup = Tabs.Extra:AddGroupbox({ Side = "Right", Name = "牧师", IconName = "church", Description = "自动祝福" })




L.chaplain = {
    enabled = false,
    threshold = 50,
    cooldown = 2,
    range = 15,
    lastRequest = {},
    thread = nil,
}

local function getBlessRemote()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Blessing")
    if tool and tool:FindFirstChild("RemoteEvent") then return tool.RemoteEvent end
    for _, child in char:GetChildren() do
        if child:IsA("Tool") and child.Name:lower():find("bless") and child:FindFirstChild("RemoteEvent") then
            return child.RemoteEvent
        end
    end
    return nil
end

local function inBlessRange(player)
    local localChar = LocalPlayer.Character
    if not localChar then return false end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    if not player.Character then return false end
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    if not targetRoot then return false end
    return (localRoot.Position - targetRoot.Position).Magnitude <= L.chaplain.range
end

local function sendBless(player, humanoid)
    if not player or not humanoid then return end
    local infection = L.getInfectionForPlayer(player)
    if infection < L.chaplain.threshold then return end
    local now = tick_()
    if (L.chaplain.lastRequest[player] or 0) + L.chaplain.cooldown > now then return end
    if not inBlessRange(player) then return end
    local remote = getBlessRemote()
    if not remote then return end
    pcall(function()
        remote:FireServer("SendRequest", humanoid)
        L.chaplain.lastRequest[player] = now
    end)
end

function L.chaplain.loop()
    while L.chaplain.enabled do
        for _, player in Players:GetPlayers() do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    pcall(sendBless, player, humanoid)
                end
            end
        end
        task.wait(0.5)
    end
end

function L.chaplain.start()
    if L.chaplain.thread then return end
    L.chaplain.enabled = true
    L.chaplain.thread = task.spawn(L.chaplain.loop)
    L.notify(TranslateText("自动祝福已开启"), 2)
end

function L.chaplain.stop()
    L.chaplain.enabled = false
    if L.chaplain.thread then
        task.cancel(L.chaplain.thread)
        L.chaplain.thread = nil
    end
    L.chaplain.lastRequest = {}
    L.notify(TranslateText("自动祝福已关闭"), 2)
end

ChaplainGroup:AddToggle('ChaplainAutoBlessToggle', {
    Text = '自动祝福感染玩家',
    Default = false,
    Tooltip = TranslateTooltip('自动向感染值高的玩家发送祝福'),
    Callback = function(v)
        if v then L.chaplain.start() else L.chaplain.stop() end
    end
})

ChaplainGroup:AddSlider('ChaplainBlessThreshold', {
    Text = '祝福阈值 (%)',
    Default = 50,
    Min = 1,
    Max = 100,
    Suffix = '%',
    Callback = function(v)
        L.chaplain.threshold = v
    end
})

if not L.Fife then L.Fife = {} end

local MusicianGroup = Tabs.Extra:AddGroupbox({ Side = "Left", Name = "音乐家", IconName = "music", Description = "自动演奏" })

L.fifeAccuracyEnabled = false
L.fifeOldNamecall = nil
L.inFifeHook = false

function L.setupFifeHook()
    if L.fifeOldNamecall then return end
    if type(hookmetamethod) ~= "function" then
        warn("Auto Fife: hookmetamethod not available")
        return
    end
    local checkcaller = checkcaller or function() return false end
    pcall(function()
        L.fifeOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if L.inFifeHook then return L.fifeOldNamecall(self, ...) end
            local method = getnamecallmethod()
            if method == "FireServer" and (not checkcaller()) then
                L.inFifeHook = true
                local args = {...}
                if args[1] == "UpdateAccuracy" then
                    args[2] = 100
                end
                L.inFifeHook = false
                return L.fifeOldNamecall(self, unpack(args))
            end
            return L.fifeOldNamecall(self, ...)
        end)
    end)
end

function L.removeFifeHook()
    if L.fifeOldNamecall then
        if type(L.fifeOldNamecall) == "function" then
            pcall(function() hookmetamethod(game, "__namecall", L.fifeOldNamecall) end)
        end
        L.fifeOldNamecall = nil
    end
end

function L.toggleAutoFife(state)
    L.fifeAccuracyEnabled = state
    if state then
        L.setupFifeHook()
    else
        L.removeFifeHook()
    end
end

MusicianGroup:AddToggle('AutoFifeToggle', {
    Text = '自动演奏',
    Default = false,
    Tooltip = TranslateTooltip('演奏笛子时自动达到 100% 准确度'),
    Callback = function(v) L.toggleAutoFife(v) end
})

local LeftGroup = Tabs.LocalPlayer:AddGroupbox({ Side = "Left", Name = "主要功能", IconName = "user", Description = "速度跳跃" })

local RightGroup = Tabs.LocalPlayer:AddGroupbox({ Side = "Right", Name = "美化", IconName = "sparkles", Description = "外观特效" })

RightGroup:AddInput("DisguiseAppearanceInput", {
    Default = "gay",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Text = "替换玩家名字",
    Tooltip = TranslateTooltip("输入要复制装扮的玩家名"),
    Placeholder = "输入名字",
    Callback = function(Value) end,
})
RightGroup:AddButton({
    Text = "替换装扮",
    Func = function()
        local name = Options.DisguiseAppearanceInput.Value
        L.disguise.applyAppearanceOnly(name)
    end,
    Tooltip = TranslateTooltip("替换玩家外观"),
})

RightGroup:AddInput("DisguiseNameInput", {
    Default = "gay",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Text = "修改用户名",
    Tooltip = TranslateTooltip("输入要改为的用户名"),
    Placeholder = "输入用户名",
    Callback = function(Value) end,
})
RightGroup:AddButton({
    Text = "修改名字",
    Func = function()
        local name = Options.DisguiseNameInput.Value
        L.disguise.changeNameOnly(name)
    end,
    Tooltip = TranslateTooltip("仅修改显示名字"),
})

local CherryBlossom = {}
CherryBlossom.__index = CherryBlossom

function CherryBlossom.new()
    local self = setmetatable({}, CherryBlossom)
    self.Lighting = Lighting
    self.Workspace = Workspace
    self.TweenService = TweenService
    self.LocalPlayer = Players.LocalPlayer
    self.Config = {
        MaxParticles = 1200,
        SpawnInterval = 0.03,
        Radius = 60,
        WindX = -8,
        WindY = -12,
        WindZ = 6,
        TextureID = "rbxassetid://7456123890",
        NeonRatio = 0.35
    }
    self.Pool = {}
    self.PoolIndex = 1
    self.Folder = nil
    self.IsRunning = false
    return self
end

function CherryBlossom:ClearSession()
    pcall(function()
        local oldFolder = self.Workspace:FindFirstChild("CherryBlossom_Layer")
        if oldFolder then oldFolder:Destroy() end
    end)
    for _, fx in self.Lighting:GetChildren() do
        if fx.Name:find("BlossomFX_") then pcall(function() fx:Destroy() end) end
    end
end

function CherryBlossom:ApplyLightingPipeline()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        self.Lighting.Technology = Enum.Technology.Future
        self.Lighting.GlobalShadows = true
        self.Lighting.EnvironmentDiffuseScale = 0.55
        self.Lighting.EnvironmentSpecularScale = 0.55
    end)
    self.Lighting.ClockTime = 20.6
    self.Lighting.Brightness = 1.2
    self.Lighting.Ambient = c3rgb(55, 45, 55)
    self.Lighting.OutdoorAmbient = c3rgb(75, 65, 85)
    local atmosphere = self.Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = self.Lighting
    end
    atmosphere.Density = 0.38
    atmosphere.Haze = 2.0
    atmosphere.Color = c3rgb(255, 180, 195)
    atmosphere.Decay = c3rgb(80, 40, 55)
    atmosphere.Glare = 0.15
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Name = "BlossomFX_Color"
    colorCorrection.Brightness = 0.02; colorCorrection.Contrast = 0.12; colorCorrection.Saturation = 0.25
    colorCorrection.TintColor = c3rgb(255, 240, 245)
    colorCorrection.Parent = self.Lighting
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "BlossomFX_Bloom"
    bloom.Intensity = 0.45; bloom.Size = 16; bloom.Threshold = 0.85
    bloom.Parent = self.Lighting
    local sunRays = self.Lighting:FindFirstChildOfClass("SunRaysEffect")
    if sunRays then pcall(function() sunRays:Destroy() end) end
end

function CherryBlossom:InitializeParticlePool()
    self.Folder = Instance.new("Folder")
    self.Folder.Name = "CherryBlossom_Layer"
    self.Folder.Parent = self.Workspace
    for i = 1, self.Config.MaxParticles do
        local petal = Instance.new("Part")
        petal.Size = v3new(1, 1, 1)
        petal.CanCollide = false; petal.CanTouch = false; petal.CanQuery = false
        petal.Anchored = true; petal.CastShadow = false; petal.Transparency = 1
        petal.Position = v3new(0, 9999, 0)
        petal.Parent = self.Folder
        local isNeon = math.random() < self.Config.NeonRatio
        petal.Material = isNeon and Enum.Material.Neon or Enum.Material.SmoothPlastic
        petal.Color = isNeon and c3rgb(255, 200, 225) or c3rgb(235, 205, 215)
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        local length = math.random(4, 8) / 10
        mesh.Scale = v3new(length * 0.65, 0.02, length)
        mesh.Parent = petal
        local decal = Instance.new("Decal")
        decal.Texture = self.Config.TextureID
        decal.Face = Enum.NormalId.Top
        decal.Transparency = isNeon and 0.4 or 0.05
        decal.Parent = petal
        local bottomDecal = decal:Clone()
        bottomDecal.Face = Enum.NormalId.Bottom
        bottomDecal.Parent = petal
        self.Pool[i] = {
            Part = petal,
            TweenMove = nil,
            TweenFade = nil,
            IsNeon = isNeon
        }
    end
end

function CherryBlossom:EmitPetal(playerRoot)
    if not playerRoot or not self.IsRunning then return end
    local slot = self.Pool[self.PoolIndex]
    self.PoolIndex = (self.PoolIndex % self.Config.MaxParticles) + 1
    if slot.TweenMove then pcall(function() slot.TweenMove:Cancel() end) end
    if slot.TweenFade then pcall(function() slot.TweenFade:Cancel() end) end
    local petal = slot.Part
    local rad = self.Config.Radius
    local startPos = playerRoot.Position + v3new(
        math.random(-rad * 10, rad * 10) / 10,
        math.random(150, 450) / 10,
        math.random(-rad * 10, rad * 10) / 10
    )
    local duration = math.random(35, 60) / 10
    local endPos = startPos + v3new(
        self.Config.WindX + math.random(-80, 80) / 10,
        self.Config.WindY - math.random(50, 100) / 10,
        self.Config.WindZ + math.random(-80, 80) / 10
    )
    petal.Position = startPos
    petal.CFrame = cfNew(startPos) * CFrame.Angles(mathRad(math.random(0, 360)), mathRad(math.random(0, 360)), mathRad(math.random(0, 360)))
    petal.Transparency = 1
    local targetTransparency = slot.IsNeon and 0.1 or math.random(5, 20) / 100
    slot.TweenFade = self.TweenService:Create(petal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Transparency = targetTransparency})
    slot.TweenMove = self.TweenService:Create(petal, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = cfNew(endPos) * CFrame.Angles(mathRad(math.random(270, 720)), mathRad(math.random(180, 540)), mathRad(math.random(270, 720)))
    })
    slot.TweenFade:Play()
    slot.TweenMove:Play()
    task.delay(duration - 0.5, function()
        if self.IsRunning and petal and petal.Parent then
            pcall(function() self.TweenService:Create(petal, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Transparency = 1}):Play() end)
        end
    end)
    task.delay(duration, function()
        if petal and petal.Parent then
            petal.Transparency = 1
            petal.Position = v3new(0, 9999, 0)
        end
    end)
end

function CherryBlossom:Start()
    self:ClearSession()
    self:ApplyLightingPipeline()
    self:InitializeParticlePool()
    self.IsRunning = true
    task.spawn(function()
        while self.IsRunning do
            local char = self.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _ = 1, 4 do
                    if not self.IsRunning then break end
                    self:EmitPetal(root)
                end
            end
            task.wait(self.Config.SpawnInterval)
        end
    end)
end

function CherryBlossom:Destroy()
    self.IsRunning = false
    for _, slot in self.Pool do
        if slot.TweenMove then pcall(function() slot.TweenMove:Cancel() end) end
        if slot.TweenFade then pcall(function() slot.TweenFade:Cancel() end) end
    end
    self:ClearSession()
    self.Pool = {}
end

_G.CherryBlossomInstance = nil
function _G.StartCherryBlossom()
    if _G.CherryBlossomInstance then _G.CherryBlossomInstance:Destroy() end
    _G.CherryBlossomInstance = CherryBlossom.new()
    _G.CherryBlossomInstance:Start()
    shared.CherryBlossomActiveSession = _G.StartCherryBlossom
end
function _G.StopCherryBlossom()
    if _G.CherryBlossomInstance then
        _G.CherryBlossomInstance:Destroy()
        _G.CherryBlossomInstance = nil
    end
    shared.CherryBlossomActiveSession = nil
end

if shared.CherryBlossomActiveSession then
    pcall(function() shared.CherryBlossomActiveSession() end)
end

RightGroup:AddToggle("CherryBlossomToggle", {
    Text = "樱花天空(无法恢复)",
    Tooltip = TranslateTooltip("飘落樱花花瓣 紫色天空 记住无法恢复"),
    Default = false,
    Callback = function(state)
        if state then _G.StartCherryBlossom() else _G.StopCherryBlossom() end
    end
})

L.francModifier = L.francModifier or {}
L.francModifier.enabled = false
L.francModifier.targetValue = 99999999
L.francModifier.charAddedDisposer = nil

function L.francModifier.apply()
    if not L.francModifier.enabled then return end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local francs = leaderstats:FindFirstChild("Francs")
        if francs and (francs:IsA("NumberValue") or francs:IsA("IntValue")) then
            francs.Value = L.francModifier.targetValue
        end
    end
end

function L.francModifier.onCharacterAdded()
    task.wait(0.2)
    L.francModifier.apply()
end

function L.francModifier.start()
    if L.francModifier.enabled then return end
    L.francModifier.enabled = true
    L.francModifier.apply()
    if not L.francModifier.charAddedDisposer then
        L.francModifier.charAddedDisposer = L.onCharacterAdded(L.francModifier.onCharacterAdded)
    end
end

function L.francModifier.stop()
    L.francModifier.enabled = false
    if L.francModifier.charAddedDisposer then
        L.francModifier.charAddedDisposer()
        L.francModifier.charAddedDisposer = nil
    end
end

RightGroup:AddInput("FrancAmountInput", {
    Text = "法郎数量",
    Default = "柳叶",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            L.francModifier.targetValue = mathFloor(num)
        else
            L.francModifier.targetValue = 99999999
        end
    end
})

RightGroup:AddToggle("FrancModifierToggle", {
    Text = "修改法郎数量",
    Tooltip = TranslateTooltip("开启后本地修改法郎"),
    Default = false,
    Callback = function(state)
        if state then L.francModifier.start() else L.francModifier.stop() end
    end
})

L.zeroBeauty = L.zeroBeauty or {}
L.zeroBeauty.enabled = false
L.zeroBeauty.connection = nil

function L.zeroBeauty.start()
    if L.zeroBeauty.connection then return end
    L.zeroBeauty.enabled = true
    L.zeroBeauty.connection = RunService.Heartbeat:Connect(function()
        if not L.zeroBeauty.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end

        local faceObj = char:FindFirstChild("Face")
        if faceObj then
            local faceDecal = faceObj:FindFirstChild("Face")
            if faceDecal and faceDecal:IsA("Decal") then
                faceDecal.Texture = "http://www.roblox.com/asset/?id=174259585"
            end
        end
        if char:FindFirstChild("Face") then
            char.Face.Color = c3rgb(121, 121, 121)
        end
        if char:FindFirstChild("Torso") then
            char.Torso.Color = c3rgb(121, 121, 121)
        end
        if char:FindFirstChild("Right Leg") then
            char["Right Leg"].Color = c3rgb(121, 121, 121)
        end
        if char:FindFirstChild("Right Arm") then
            char["Right Arm"].Color = c3rgb(121, 121, 121)
        end
        if char:FindFirstChild("Left Leg") then
            char["Left Leg"].Color = c3rgb(121, 121, 121)
        end
        if char:FindFirstChild("Left Arm") then
            char["Left Arm"].Color = c3rgb(121, 121, 121)
        end
    end)
end

function L.zeroBeauty.stop()
    L.zeroBeauty.enabled = false
    if L.zeroBeauty.connection then
        L.zeroBeauty.connection:Disconnect()
        L.zeroBeauty.connection = nil
    end

    local char = LocalPlayer.Character
    if not char then return end
    local faceObj = char:FindFirstChild("Face")
    if faceObj then
        local faceDecal = faceObj:FindFirstChild("Face")
        if faceDecal and faceDecal:IsA("Decal") then
            faceDecal.Texture = "rbxassetid://13815097986"
        end
    end
    if char:FindFirstChild("Face") then
        char.Face.Color = c3rgb(255, 204, 153)
    end
    if char:FindFirstChild("Torso") then
        char.Torso.Color = c3rgb(255, 204, 153)
    end
    if char:FindFirstChild("Right Leg") then
        char["Right Leg"].Color = c3rgb(255, 204, 153)
    end
    if char:FindFirstChild("Right Arm") then
        char["Right Arm"].Color = c3rgb(255, 204, 153)
    end
    if char:FindFirstChild("Left Leg") then
        char["Left Leg"].Color = c3rgb(255, 204, 153)
    end
    if char:FindFirstChild("Left Arm") then
        char["Left Arm"].Color = c3rgb(255, 204, 153)
    end
end

RightGroup:AddToggle("ZeroBeautyToggle", {
    Text = "更改外观",
    Tooltip = TranslateTooltip("更改玩家肤色 面部表情"),
    Default = false,
    Callback = function(state)
        if state then L.zeroBeauty.start() else L.zeroBeauty.stop() end
    end
})

RightGroup:AddLabel("服务器加入")

RightGroup:AddInput("ServerTrackerInput", {
    Text = "玩家用户名",
    Default = "",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = true,
    Placeholder = "输入玩家名",
    Callback = function(Value) end,
})

RightGroup:AddButton({
    Text = "加入",
    Func = function()
        local name = Options.ServerTrackerInput.Value
        if name == "" then
            Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("请输入玩家名"), Time = 3 })
            return
        end
        local event = ReplicatedStorage:FindFirstChild("ServerBrowserEvent")
        local func = ReplicatedStorage:FindFirstChild("ServerBrowserFunc")
        if not event then
            Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("无法获取服务器事件"), Time = 3 })
            return
        end
        L.serverTracker.pendingSearch = name
        if func and func:IsA("RemoteEvent") then
            func:FireServer("RequestListing")
        else
            event:FireServer("RequestListing")
        end
        Library:Notify({ Title = TranslateText("搜索中"), Description = TranslateText("请耐心等待"), Time = 2 })
    end,
    Tooltip = TranslateTooltip("服务器加入"),
})

if not L.serverTracker then
    L.serverTracker = { pendingSearch = nil, initialized = false }
end

local function getServerEvents()
    local event = ReplicatedStorage:FindFirstChild("ServerBrowserEvent")
    local func = ReplicatedStorage:FindFirstChild("ServerBrowserFunc")
    return event, func
end

function L.serverTracker.init()
    if L.serverTracker.initialized then return end
    local event, func = getServerEvents()
    if not event then return end
    event.OnClientEvent:Connect(function(action, data)
        if action == "ReturnListing" and data then
            local searchName = L.serverTracker.pendingSearch
            if not searchName then return end
            L.serverTracker.pendingSearch = nil
            local userId = nil
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(searchName) end)
            if ok and id and id > 0 then
                userId = id
            else
                local ok2, res = pcall(function() return HttpService:GetAsync("https://users.roblox.com/v1/users/search?keyword=" .. HttpService:UrlEncode(searchName)) end)
                if ok2 and res then
                    local json = HttpService:JSONDecode(res)
                    if json and json.data and #json.data > 0 then
                        for _, u in json.data do
                            if string.lower(u.name) == string.lower(searchName) then
                                userId = u.id
                                break
                            end
                        end
                        if not userId then userId = json.data[1].id end
                    end
                end
            end
            if not userId then
                Library:Notify({ Title = TranslateText("未找到"), Description = TranslateText("找不到玩家 ") .. searchName, Time = 3 })
                return
            end
            local foundServer = nil
            for _, server in data do
                if server.PlayerListing then
                    for _, id in server.PlayerListing do
                        if tonumber(id) == userId then
                            foundServer = server
                            break
                        end
                    end
                end
                if foundServer then break end
            end
            if foundServer then
                local jobId = foundServer.JobId or foundServer.jobId
                if jobId then
                    local placeId = game.PlaceId
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
                    end)
                    Library:Notify({ Title = TranslateText("加入"), Description = TranslateText("正在传送至服务器..."), Time = 2 })
                else
                    Library:Notify({ Title = TranslateText("错误"), Description = TranslateText("该服务器缺少 JobId"), Time = 3 })
                end
            else
                Library:Notify({ Title = TranslateText("未找到"), Description = TranslateText("玩家 ") .. searchName .. TranslateText(" 不在任何公开服务器中"), Time = 3 })
            end
        end
    end)
    L.serverTracker.initialized = true
end

L.serverTracker.init()

AnimsLeftGroup:AddToggle('AnimPullGateToggle', {
    Text = '拉大门',
    Default = false,
    Tooltip = TranslateTooltip('拉大门动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            L._animPullGate = L.startIdleWalk(L._animPullGate, "rbxassetid://101487438848164", "rbxassetid://109268182565437", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(L._animPullGate)
        end
    end
})




AnimsLeftGroup:AddToggle('AnimFakeInjuredToggle', {
    Text = '残血',
    Default = false,
    Tooltip = TranslateTooltip('静止播放假残血动画，移动播放假残血走路动画'),
    Callback = function(v)
        if v then
            L._animFakeInjured = L.startIdleWalk(L._animFakeInjured, "rbxassetid://14970034680", "rbxassetid://15530089342", Enum.AnimationPriority.Idle)
        else
            L.stopIdleWalk(L._animFakeInjured)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimShamblerToggle', {
    Text = '山伯乐',
    Default = false,
    Tooltip = TranslateTooltip('山伯乐动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            L._animShambler = L.startIdleWalk(L._animShambler, "rbxassetid://12333488814", "rbxassetid://14463730540", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(L._animShambler)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimRunnerToggle', {
    Text = '红眼',
    Default = false,
    Tooltip = TranslateTooltip('红眼动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            L._animRunner = L.startIdleWalk(L._animRunner, "rbxassetid://12581784105", "rbxassetid://12581785298", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(L._animRunner)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimCuirassierToggle', {
    Text = '胸甲骑兵1',
    Default = false,
    Tooltip = TranslateTooltip('胸甲骑兵动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            L._animCuirassier = L.startIdleWalk(L._animCuirassier, "rbxassetid://87579228279296", "rbxassetid://102081698785465", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(L._animCuirassier)
        end
    end
})




AnimsLeftGroup:AddToggle('AnimCuirassier2Toggle', {
    Text = '胸甲僵尸2',
    Default = false,
    Tooltip = TranslateTooltip('静止播放动画，移动播放动画'),
    Callback = function(v)
        if v then
            L._animCuirassier2 = L.startIdleWalk(L._animCuirassier2, "rbxassetid://82800474630427", "rbxassetid://118210337289087", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(L._animCuirassier2)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimCavalryChargeToggle', {
    Text = '胸甲骑兵冲锋快捷栏',
    Default = false,
    Tooltip = TranslateTooltip('打开小方块快捷栏执行冲锋'),
    Callback = function(v)
        if v then

            if _G.cavalryUI then _G.cavalryUI:Destroy() end
            _G.cavalryUI, _G.cavalryBtn = L.createFloatingButton("CavalryChargeUI", "冲", UDim2.new(0.5, -105, 0.3, 0), 24, function()
                task.spawn(_G.cavalryCharge)
            end)
            _G.cavalryPlaying = false


            function _G.cavalryCharge()
                if _G.cavalryPlaying then return end
                _G.cavalryPlaying = true
                if _G.cavalryBtn then _G.cavalryBtn.Text = "冲锋中" end

                local char = LocalPlayer.Character
                if not char then
                    _G.cavalryPlaying = false
                    if _G.cavalryBtn then _G.cavalryBtn.Text = "冲" end
                    return
                end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    _G.cavalryPlaying = false
                    if _G.cavalryBtn then _G.cavalryBtn.Text = "冲" end
                    return
                end

                local animator = hum:FindFirstChildOfClass("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = hum
                end

                for _, t in hum:GetPlayingAnimationTracks() do
                    t:Stop()
                end

                local function load(id)
                    local a = Instance.new("Animation")
                    a.AnimationId = "rbxassetid://" .. id
                    local t = animator:LoadAnimation(a)
                    t.Priority = Enum.AnimationPriority.Action4
                    return t
                end

                local function waitStopped(track, timeout)
                    local done = false
                    local conn = track.Stopped:Once(function() done = true end)
                    local t0 = osClock()
                    while not done and track.IsPlaying and osClock() - t0 < timeout do
                        task.wait(0.05)
                    end
                    pcall(function() conn:Disconnect() end)
                end

                local t1 = load("105118183189738")
                local t2 = load("17406602570")
                local finalId = "102984581737936"
                local noEnemyId = "139159672489901"
                local origSpeed = hum.WalkSpeed

                hum.WalkSpeed = 1
                t1:Play()
                waitStopped(t1, 10)
                if not _G.cavalryPlaying then
                    hum.WalkSpeed = origSpeed
                    return
                end

                hum.WalkSpeed = 28
                t2:Play()
                local stopAt = osClock() + 5
                while osClock() < stopAt and t2.IsPlaying do
                    task.wait()
                    if not _G.cavalryPlaying then break end
                end
                t2:Stop()
                hum.WalkSpeed = origSpeed
                if not _G.cavalryPlaying then return end

                local hasEnemy = false
                for _, pl in Players:GetPlayers() do
                    if pl ~= LocalPlayer and pl.Character then
                        local dist = (pl.Character:GetPivot().Position - hum.RootPart.Position).Magnitude
                        if dist < 10 then
                            hasEnemy = true
                            break
                        end
                    end
                end

                local finalT = load(hasEnemy and finalId or noEnemyId)
                if not hasEnemy then hum.WalkSpeed = 4 end
                finalT:Play()
                waitStopped(finalT, 15)
                hum.WalkSpeed = 16
                _G.cavalryPlaying = false
                if _G.cavalryBtn then _G.cavalryBtn.Text = "冲" end
            end

        else
            if _G.cavalryUI then
                _G.cavalryUI:Destroy()
                _G.cavalryUI = nil
            end
            _G.cavalryBtn = nil
            _G.cavalryPlaying = false
        end
    end
})

AnimsLeftGroup:AddToggle('AnimLanternToggle', {
    Text = '提灯人',
    Default = false,
    Tooltip = TranslateTooltip('提灯人动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            _G._animLantern = L.startIdleWalk(_G._animLantern, "rbxassetid://14678879479", "rbxassetid://14678880308", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(_G._animLantern)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimAxeToggle', {
    Text = '斧头僵尸',
    Default = false,
    Tooltip = TranslateTooltip('斧头僵尸动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            _G._animAxe = L.startIdleWalk(_G._animAxe, "rbxassetid://14498563473", "rbxassetid://14498289874", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(_G._animAxe)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimAxeSlashToggle', {
    Text = '斧头僵尸劈砍快捷栏',
    Default = false,
    Tooltip = TranslateTooltip('打开小方块快捷栏执行劈砍'),
    Callback = function(v)
        if v then

            if _G.zapperUI then _G.zapperUI:Destroy() end
            _G.zapperUI, _G.zapperBtn = L.createFloatingButton("ZapperEffectUI", "劈砍", UDim2.new(0.5, -35, 0.4, 0), 18, function()
                task.spawn(_G.zapperSlash)
            end)
            _G.zapperBusy = false


            function _G.zapperSlash()
                if _G.zapperBusy then return end
                _G.zapperBusy = true
                if _G.zapperBtn then _G.zapperBtn.Text = "劈砍中" end

                local char = LocalPlayer.Character
                if not char then
                    _G.zapperBusy = false
                    if _G.zapperBtn then _G.zapperBtn.Text = "劈砍" end
                    return
                end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    _G.zapperBusy = false
                    if _G.zapperBtn then _G.zapperBtn.Text = "劈砍" end
                    return
                end

                local animator = hum:FindFirstChildOfClass("Animator")
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = hum
                end

                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://14499470197"
                local track = animator:LoadAnimation(anim)
                track.Priority = Enum.AnimationPriority.Action4
                track:Play()

                track.Stopped:Connect(function()
                    _G.zapperBusy = false
                    if _G.zapperBtn then _G.zapperBtn.Text = "劈砍" end
                end)


                task.delay(5, function()
                    if _G.zapperBusy then
                        _G.zapperBusy = false
                        if _G.zapperBtn then _G.zapperBtn.Text = "劈砍" end
                    end
                end)
            end

        else

            if _G.zapperUI then
                _G.zapperUI:Destroy()
                _G.zapperUI = nil
            end
            _G.zapperBtn = nil
            _G.zapperBusy = false
        end
    end
})

AnimsLeftGroup:AddToggle('AnimBarrelToggle', {
    Text = '自爆',
    Default = false,
    Tooltip = TranslateTooltip('自爆动画（待机/行走自动切换）'),
    Callback = function(v)
        if v then
            _G._animBarrel = L.startIdleWalk(_G._animBarrel, "rbxassetid://13211198049", "rbxassetid://13211207597", Enum.AnimationPriority.Action3)
        else
            L.stopIdleWalk(_G._animBarrel)
        end
    end
})

AnimsLeftGroup:AddToggle('AnimCrawlerToggle', {
    Text = '爬尸',
    Default = false,
    Tooltip = TranslateTooltip('爬尸动画（爬行模式）'),
    Callback = function(v)
        if v then
            _G._animCrawler = L.startIdleWalk(_G._animCrawler, "rbxassetid://13726632691", "rbxassetid://13726634549", Enum.AnimationPriority.Action3, nil, "rbxassetid://130515356351734")
        else
            L.stopIdleWalk(_G._animCrawler)
            _G._animCrawler = nil
        end
    end
})

AnimsLeftGroup:AddToggle('AnimHeavyChargeToggle', {
    Text = '重剑冲锋',
    Default = false,
    Tooltip = TranslateTooltip('重剑冲锋动画（开启速度24，关闭速度16）'),
    Callback = function(v)
        if v then
            _G._animHeavyCharge = L.startIdleWalk(_G._animHeavyCharge, "rbxassetid://14284611111", "rbxassetid://17406602570", Enum.AnimationPriority.Action3, 24)
        else
            L.stopIdleWalk(_G._animHeavyCharge, 16)
            _G._animHeavyCharge = nil
        end
    end
})

AnimsLeftGroup:AddToggle('AnimMusketChargeToggle', {
    Text = '滑膛枪冲锋',
    Default = false,
    Tooltip = TranslateTooltip('滑膛枪冲锋动画（开启速度24，关闭速度16）'),
    Callback = function(v)
        if v then
            _G._animMusketCharge = L.startIdleWalk(_G._animMusketCharge, "rbxassetid://14292935158", "rbxassetid://14292937831", Enum.AnimationPriority.Action3, 24)
        else
            L.stopIdleWalk(_G._animMusketCharge, 16)
            _G._animMusketCharge = nil
        end
    end
})

AnimsLeftGroup:AddToggle('AnimChargeToggle', {
    Text = '冲锋',
    Default = false,
    Tooltip = TranslateTooltip('冲锋动画（开启速度24，关闭速度16）'),
    Callback = function(v)
        if v then
            _G._animCharge = L.startIdleWalk(_G._animCharge, "rbxassetid://14284611111", "rbxassetid://14284623849", Enum.AnimationPriority.Idle, 24)
        else
            L.stopIdleWalk(_G._animCharge, 16)
            _G._animCharge = nil
        end
    end
})

L.onCharacterAdded(function()
    task.wait(0.2)
    local function cleanupState(state)
        if not state then return end
        if state.idle then pcall(function() state.idle:Stop() end) end
        if state.walk then pcall(function() state.walk:Stop() end) end
        if state.sit then pcall(function() state.sit:Stop() end) end
        if state.conn then pcall(function() state.conn:Disconnect() end) end
    end
    local function resetToggle(name)
        local toggle = Toggles[name]
        if toggle and toggle.SetValue then toggle:SetValue(false) end
    end
    local lStates = {
        { "_animPullGate", "AnimPullGateToggle" },
        { "_animFakeInjured", "AnimFakeInjuredToggle" },
        { "_animShambler", "AnimShamblerToggle" },
        { "_animRunner", "AnimRunnerToggle" },
        { "_animCuirassier", "AnimCuirassierToggle" },
        { "_animCuirassier2", "AnimCuirassier2Toggle" },
    }
    local gStates = {
        { "_animLantern", "AnimLanternToggle" },
        { "_animAxe", "AnimAxeToggle" },
        { "_animBarrel", "AnimBarrelToggle" },
        { "_animCrawler", "AnimCrawlerToggle" },
        { "_animHeavyCharge", "AnimHeavyChargeToggle" },
        { "_animMusketCharge", "AnimMusketChargeToggle" },
        { "_animCharge", "AnimChargeToggle" },
        { "boxerCtrl", "AnimBoxerToggle" },
    }
    for _, e in lStates do
        cleanupState(L[e[1]])
        L[e[1]] = nil
        resetToggle(e[2])
    end
    for _, e in gStates do
        cleanupState(_G[e[1]])
        _G[e[1]] = nil
        resetToggle(e[2])
    end
end)

AnimsLeftGroup:AddToggle('AnimBoxerToggle', {
    Text = '拳击手',
    Default = false,
    Tooltip = TranslateTooltip('拳击手模式（行走/待机动画 + 左右拳按钮）'),
    Callback = function(v)
        if v then
            if _G.boxerActive then return end
            _G.boxerActive = true

            local char = LocalPlayer.Character
            if not char then
                _G.boxerActive = false
                return
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                _G.boxerActive = false
                return
            end
            local animator = hum:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator")
                animator.Parent = hum
            end


            local idleAnim = Instance.new("Animation")
            idleAnim.AnimationId = "rbxassetid://124381258015151"
            local walkAnim = Instance.new("Animation")
            walkAnim.AnimationId = "rbxassetid://127477273497271"
            local idleTrack = animator:LoadAnimation(idleAnim)
            local walkTrack = animator:LoadAnimation(walkAnim)
            idleTrack.Priority = Enum.AnimationPriority.Action3
            walkTrack.Priority = Enum.AnimationPriority.Action3

            local function update()
                if hum.MoveDirection.Magnitude > 0 then
                    if walkTrack and not walkTrack.IsPlaying then
                        if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
                        walkTrack:Play()
                    end
                else
                    if idleTrack and not idleTrack.IsPlaying then
                        if walkTrack and walkTrack.IsPlaying then walkTrack:Stop() end
                        idleTrack:Play()
                    end
                end
            end

            local conn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(update)
            update()
            _G.boxerCtrl = { idle = idleTrack, walk = walkTrack, conn = conn }
            hum.WalkSpeed = 17


            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://0"
            sound.Looped = true
            sound.Volume = 0
            local head = char:FindFirstChild("Head")
            sound.Parent = head or char
            sound:Play()
            _G.boxerSound = sound


            if _G.boxerShowUI == nil or _G.boxerShowUI then
                if _G.boxerUI then _G.boxerUI:Destroy() end
                _G.boxerUI = Instance.new("ScreenGui")
                _G.boxerUI.Name = "BoxerUI"
                _G.boxerUI.ResetOnSpawn = false
                _G.boxerUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

                local function createBtn(name, posX, color)
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(0, 60, 0, 60)
                    btn.AnchorPoint = v2new(0.5, 0.5)
                    btn.Position = UDim2.new(posX, 0, 0.5, 0)
                    btn.BackgroundColor3 = color
                    btn.BackgroundTransparency = 0.2
                    btn.BorderSizePixel = 0
                    btn.Text = name
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.TextSize = 20
                    btn.Font = Enum.Font.GothamBold
                    btn.Draggable = not (_G.boxerFixed == nil or _G.boxerFixed)
                    btn.Active = true
                    btn.Parent = _G.boxerUI

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 12)
                    corner.Parent = btn
                    local stroke = Instance.new("UIStroke")
                    stroke.Thickness = 2
                    stroke.Color = c3rgb(100, 200, 255)
                    stroke.Transparency = 0.3
                    stroke.Parent = btn

                    local aspect = Instance.new("UIAspectRatioConstraint")
                    aspect.AspectRatio = 1
                    aspect.DominantAxis = Enum.DominantAxis.Width
                    aspect.Parent = btn

                    return btn
                end

                local leftBtn = createBtn("左拳", 0.3, c3rgb(255, 100, 100))
                local rightBtn = createBtn("右拳", 0.7, c3rgb(100, 100, 255))

                local function playPunch(id)
                    if not _G.boxerActive then return end
                    local char2 = LocalPlayer.Character
                    if not char2 then return end
                    local hum2 = char2:FindFirstChildOfClass("Humanoid")
                    if not hum2 then return end
                    local animator2 = hum2:FindFirstChildOfClass("Animator")
                    if not animator2 then
                        animator2 = Instance.new("Animator")
                        animator2.Parent = hum2
                    end
                    local a = Instance.new("Animation")
                    a.AnimationId = id
                    local track = animator2:LoadAnimation(a)
                    track.Priority = Enum.AnimationPriority.Action4
                    track:Play()
                    track.Stopped:Connect(function() a:Destroy() end)
                end

                leftBtn.MouseButton1Click:Connect(function()
                    task.spawn(function() playPunch("rbxassetid://100609705099226") end)
                end)

                rightBtn.MouseButton1Click:Connect(function()
                    task.spawn(function() playPunch("rbxassetid://137400696654354") end)
                end)

                _G.boxerUILeft = leftBtn
                _G.boxerUIRight = rightBtn
            end


            if _G.boxerDeathConn then _G.boxerDeathConn:Disconnect() end
            _G.boxerDeathConn = hum.Died:Connect(function()
                if _G.boxerActive then
                    _G.boxerActive = false
                    if _G.boxerCtrl then
                        if _G.boxerCtrl.idle then pcall(function() _G.boxerCtrl.idle:Stop() end) end
                        if _G.boxerCtrl.walk then pcall(function() _G.boxerCtrl.walk:Stop() end) end
                        if _G.boxerCtrl.conn then pcall(function() _G.boxerCtrl.conn:Disconnect() end) end
                        _G.boxerCtrl = nil
                    end
                    local hum3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum3 then hum3.WalkSpeed = 16 end
                    if _G.boxerSound then _G.boxerSound:Stop(); _G.boxerSound:Destroy(); _G.boxerSound = nil end
                    if _G.boxerUI then _G.boxerUI:Destroy(); _G.boxerUI = nil end
                    _G.boxerUILeft = nil
                    _G.boxerUIRight = nil
                    if _G.boxerDeathConn then _G.boxerDeathConn:Disconnect(); _G.boxerDeathConn = nil end
                end
            end)

        else

            _G.boxerActive = false
            if _G.boxerCtrl then
                if _G.boxerCtrl.idle then pcall(function() _G.boxerCtrl.idle:Stop() end) end
                if _G.boxerCtrl.walk then pcall(function() _G.boxerCtrl.walk:Stop() end) end
                if _G.boxerCtrl.conn then pcall(function() _G.boxerCtrl.conn:Disconnect() end) end
                _G.boxerCtrl = nil
            end
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
            if _G.boxerSound then _G.boxerSound:Stop(); _G.boxerSound:Destroy(); _G.boxerSound = nil end
            if _G.boxerUI then _G.boxerUI:Destroy(); _G.boxerUI = nil end
            _G.boxerUILeft = nil
            _G.boxerUIRight = nil
            if _G.boxerDeathConn then _G.boxerDeathConn:Disconnect(); _G.boxerDeathConn = nil end
        end
    end
})

AnimsLeftGroup:AddToggle('AnimBoxerFixedToggle', {
    Text = '固定按钮',
    Default = true,
    Tooltip = TranslateTooltip('拳击按钮不可拖动'),
    Callback = function(v)
        _G.boxerFixed = v
        if _G.boxerUILeft and _G.boxerUIRight then
            _G.boxerUILeft.Draggable = not v
            _G.boxerUIRight.Draggable = not v
        end
    end
})

AnimsLeftGroup:AddToggle('AnimBoxerUIToggle', {
    Text = '显示拳击 UI',
    Default = true,
    Tooltip = TranslateTooltip('显示/隐藏拳击按钮界面'),
    Callback = function(v)
        _G.boxerShowUI = v
        if _G.boxerActive then
            if v then
                if not _G.boxerUI then

                    local char = LocalPlayer.Character
                    if not char then return end
                    _G.boxerUI = Instance.new("ScreenGui")
                    _G.boxerUI.Name = "BoxerUI"
                    _G.boxerUI.ResetOnSpawn = false
                    _G.boxerUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

                    local function createBtn(name, posX, color)
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(0, 60, 0, 60)
                        btn.AnchorPoint = v2new(0.5, 0.5)
                        btn.Position = UDim2.new(posX, 0, 0.5, 0)
                        btn.BackgroundColor3 = color
                        btn.BackgroundTransparency = 0.2
                        btn.BorderSizePixel = 0
                        btn.Text = name
                        btn.TextColor3 = Color3.new(1, 1, 1)
                        btn.TextSize = 20
                        btn.Font = Enum.Font.GothamBold
                        btn.Draggable = not (_G.boxerFixed == nil or _G.boxerFixed)
                        btn.Active = true
                        btn.Parent = _G.boxerUI

                        local corner = Instance.new("UICorner")
                        corner.CornerRadius = UDim.new(0, 12)
                        corner.Parent = btn
                        local stroke = Instance.new("UIStroke")
                        stroke.Thickness = 2
                        stroke.Color = c3rgb(100, 200, 255)
                        stroke.Transparency = 0.3
                        stroke.Parent = btn

                        local aspect = Instance.new("UIAspectRatioConstraint")
                        aspect.AspectRatio = 1
                        aspect.DominantAxis = Enum.DominantAxis.Width
                        aspect.Parent = btn

                        return btn
                    end

                    local leftBtn = createBtn("左拳", 0.3, c3rgb(255, 100, 100))
                    local rightBtn = createBtn("右拳", 0.7, c3rgb(100, 100, 255))

                    local function playPunch(id)
                        if not _G.boxerActive then return end
                        local char2 = LocalPlayer.Character
                        if not char2 then return end
                        local hum2 = char2:FindFirstChildOfClass("Humanoid")
                        if not hum2 then return end
                        local animator2 = hum2:FindFirstChildOfClass("Animator")
                        if not animator2 then
                            animator2 = Instance.new("Animator")
                            animator2.Parent = hum2
                        end
                        local a = Instance.new("Animation")
                        a.AnimationId = id
                        local track = animator2:LoadAnimation(a)
                        track.Priority = Enum.AnimationPriority.Action4
                        track:Play()
                        track.Stopped:Connect(function() a:Destroy() end)
                    end

                    leftBtn.MouseButton1Click:Connect(function()
                        task.spawn(function() playPunch("rbxassetid://100609705099226") end)
                    end)

                    rightBtn.MouseButton1Click:Connect(function()
                        task.spawn(function() playPunch("rbxassetid://137400696654354") end)
                    end)

                    _G.boxerUILeft = leftBtn
                    _G.boxerUIRight = rightBtn
                end
                _G.boxerUI.Enabled = true
            else
                if _G.boxerUI then
                    _G.boxerUI.Enabled = false
                end
            end
        end
    end
})

local RightGroup = Tabs.Main:AddGroupbox({ Side = "Right", Name = "杀戮光环", IconName = "circle-dot", Description = "自动攻击" })


local FlyGroup = Tabs.Main:AddGroupbox({ Side = "Left", Name = "飞行功能", IconName = "plane", Description = "飞行控制" })

FlyGroup:AddButton({
    Text = "飞行-无相机锁定",
    Func = function()
        L.FlyOriginal()
    end
})

FlyGroup:AddButton({
    Text = "飞行-优化",
    Func = function()
        L.FlyNew()
    end
})

FlyGroup:AddDivider()
FlyGroup:AddLabel("飞行-传送", true)

FlyGroup:AddToggle('WarpFlyToggle', {
    Text = '飞行-传送',
    Default = false,
    Tooltip = TranslateTooltip('WASD移动，Space上升，LCtrl下降。'),
    Callback = function(v)
        if v then
            L.warpFly.start()
        else
            L.warpFly.stop()
        end
    end
})

FlyGroup:AddLabel('飞行-传送 快捷键'):AddKeyPicker('WarpFlyKeybind', {
    Default = 'F',
    NoUI = false,
    Text = '飞行-传送 开关',
    Callback = function()
        local toggle = Toggles.WarpFlyToggle
        toggle:SetValue(not toggle.Value)
    end
})

FlyGroup:AddSlider('WarpFlySpeed', {
    Text = '飞行速度',
    Default = 35,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(v)
        L.warpFly.flySpeed = v
    end
})

FlyGroup:AddButton({
    Text = "飞行-动画",
    Func = function()
        L.FlyAnimation()
    end
})

FlyGroup:AddDivider()
FlyGroup:AddLabel("自由视角传送", true)

FlyGroup:AddToggle('TPFreecamToggle', {
    Text = '自由视角',
    Default = false,
    Tooltip = TranslateTooltip('自由视角锚定角色，原生视角跟随鼠标/触摸'),
    Callback = function(v)
        if v then
            L.tpFreecam.start()
        else
            L.tpFreecam.stop()
        end
    end
})

FlyGroup:AddLabel('自由视角传送 快捷键'):AddKeyPicker('TPFreecamKeybind', {
    Default = 'G',
    NoUI = false,
    Text = '自由视角 开关',
    Callback = function()
        local toggle = Toggles.TPFreecamToggle
        toggle:SetValue(not toggle.Value)
    end
})

FlyGroup:AddSlider('TPFreecamSpeed', {
    Text = '视角速度',
    Default = 50,
    Min = 5,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(v)
        L.tpFreecam.speed = v
    end
})

FlyGroup:AddButton({
    Text = "传送到视角",
    Func = function()
        L.tpFreecam.tpToCamera()
    end,
    Tooltip = TranslateTooltip("将角色传送到当前视角位置"),
})

FlyGroup:AddInput("TPFreecamName", {
    Default = "",
    Numeric = false,
    Finished = false,
    ClearTextOnFocus = false,
    Text = "保存位置",
    Tooltip = TranslateTooltip("保存当前视角或位置"),
    Placeholder = "输入名字",
    Callback = function(Value) end,
})

FlyGroup:AddButton({
    Text = "保存位置",
    Func = function()
        L.tpFreecam.saveFromInput()
    end,
    Tooltip = TranslateTooltip("保存当前视角或位置"),
})

FlyGroup:AddDropdown('TPFreecamPoints', {
    Text = '存档点',
    Values = {},
    Tooltip = TranslateTooltip('选择已保存的位置'),
    Callback = function(value)
        L.tpFreecam.selected = value
    end
})

FlyGroup:AddButton({
    Text = "传送到存档点",
    Func = function()
        L.tpFreecam.tpToSelected()
    end,
})

FlyGroup:AddButton({
    Text = "删除存档点",
    Func = function()
        L.tpFreecam.deleteSelected()
    end,
})

FlyGroup:AddButton({
    Text = "清空存档点",
    Func = function()
        L.tpFreecam.clearPoints()
    end,
})

FlyGroup:AddLabel('WASD/摇杆移动，空格/跳跃键上升，Ctrl下降。')

function L.FlyOriginal()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wzhxll/stjnr/refs/heads/main/README.md"))()
end

function L.FlyNew()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wzhxll/Sha-Bi/refs/heads/main/README.md"))()
end

L.warpFly = {
    enabled = false,
    flySpeed = 35,
    hrp = nil,
    head = nil,
    hum = nil,
    serverPos = nil,
    isNoclipping = false,
    microStepConn = nil,
    healthLockConn = nil,
    diedConn = nil,
    originalCanCollide = {},
    descendantConnection = nil,
    _tmp = {}
}

function L.warpFly.detectWall()
    local hrp = L.warpFly.hrp
    if not hrp then return false end
    local pos = hrp.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Players.LocalPlayer.Character }
    local rayLength = 3.5
    local rayCount = 12
    local verticalLayers = 3

    for i = 1, rayCount do
        local angle = (i / rayCount) * 2 * math.pi
        local dx = math.cos(angle)
        local dz = math.sin(angle)
        for j = -(verticalLayers - 1) // 2, (verticalLayers - 1) // 2 do
            local dy = j * 0.5
            local dir = v3new(dx, dy, dz).Unit
            local result = workspace:Raycast(pos, dir * rayLength, params)
            if result then
                local hit = result.Instance
                if hit and hit.CanCollide and hit.Transparency < 0.9 then
                    return true
                end
            end
        end
    end
    return false
end

function L.warpFly.enterNoClip()
    if L.warpFly.isNoclipping then return end
    if not L.warpFly.head or not L.warpFly.hrp or not L.warpFly.hum then return end
    L.warpFly.head.Anchored = true
    L.warpFly.hum.PlatformStand = true
    L.warpFly.isNoclipping = true
end

function L.warpFly.exitNoClip()
    if not L.warpFly.isNoclipping then return end
    if not L.warpFly.head or not L.warpFly.hrp or not L.warpFly.hum then
        L.warpFly.isNoclipping = false
        return
    end
    L.warpFly.head.Anchored = false
    L.warpFly.hum.PlatformStand = false
    L.warpFly.isNoclipping = false
end

function L.warpFly.clear()
    pcall(function()
        for part, state in L.warpFly.originalCanCollide do
            if part and part.Parent then part.CanCollide = state end
        end
        table.clear(L.warpFly.originalCanCollide)
        if L.warpFly.descendantConnection then
            L.warpFly.descendantConnection:Disconnect()
            L.warpFly.descendantConnection = nil
        end
        if L.warpFly.microStepConn then
            task.cancel(L.warpFly.microStepConn)
            L.warpFly.microStepConn = nil
        end
        if L.warpFly.healthLockConn then
            task.cancel(L.warpFly.healthLockConn)
            L.warpFly.healthLockConn = nil
        end
        if L.warpFly.diedConn then
            L.warpFly.diedConn:Disconnect()
            L.warpFly.diedConn = nil
        end
        if L.warpFly.isNoclipping then
            L.warpFly.exitNoClip()
        end
        if L.warpFly.hrp and L.warpFly.hum then
            L.warpFly.hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

function L.warpFly.microStepLoop()
    if not L.warpFly.hrp then return end
    L.warpFly._tmp.targetPos = L.warpFly.hrp.Position
    L.warpFly._tmp.lastTime = tick_()
    while L.warpFly.enabled do
        if not L.warpFly.hrp or not L.warpFly.hrp.Parent
            or not L.warpFly.hum or not L.warpFly.hum.Parent then
            L.warpFly.stop()
            break
        end
        L.warpFly._tmp.now = tick_()
        L.warpFly._tmp.dt = L.warpFly._tmp.now - L.warpFly._tmp.lastTime
        L.warpFly._tmp.lastTime = L.warpFly._tmp.now

        local inWall = L.warpFly.detectWall()
        if inWall and not L.warpFly.isNoclipping then
            L.warpFly.enterNoClip()
        elseif not inWall and L.warpFly.isNoclipping then
            L.warpFly.exitNoClip()
        end

        if not L.ControlModule then
            task.wait(0.1)
            continue
        end
        L.warpFly._tmp.mv = L.ControlModule:GetMoveVector()
        L.warpFly._tmp.cf = workspace.CurrentCamera.CFrame
        L.warpFly._tmp.moveDir = (L.warpFly._tmp.cf.LookVector * -L.warpFly._tmp.mv.Z) + (L.warpFly._tmp.cf.RightVector * L.warpFly._tmp.mv.X)
        L.warpFly._tmp.vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            L.warpFly._tmp.vertical = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            L.warpFly._tmp.vertical = -1
        end
        L.warpFly._tmp.totalDelta = (L.warpFly._tmp.moveDir + v3new(0, L.warpFly._tmp.vertical, 0)) * L.warpFly.flySpeed * L.warpFly._tmp.dt
        L.warpFly._tmp.targetPos = L.warpFly._tmp.targetPos + L.warpFly._tmp.totalDelta

        L.warpFly._tmp.currentPos = L.warpFly.hrp.Position
        L.warpFly._tmp.remaining = L.warpFly._tmp.targetPos - L.warpFly._tmp.currentPos
        L.warpFly._tmp.distance = L.warpFly._tmp.remaining.Magnitude

        if L.warpFly._tmp.distance > 0 then
            L.warpFly._tmp.steps = mathCeil(L.warpFly._tmp.distance / 10)
            L.warpFly._tmp.stepVec = L.warpFly._tmp.remaining / L.warpFly._tmp.steps
            for i = 1, L.warpFly._tmp.steps do
                if not L.warpFly.enabled then break end
                L.warpFly._tmp.currentPos = L.warpFly._tmp.currentPos + L.warpFly._tmp.stepVec
                L.warpFly.hrp.CFrame = cfNew(L.warpFly._tmp.currentPos) * L.warpFly.hrp.CFrame.Rotation
            end
        else
            L.warpFly.hrp.CFrame = cfNew(L.warpFly._tmp.targetPos) * L.warpFly.hrp.CFrame.Rotation
        end
        L.warpFly.hrp.AssemblyLinearVelocity = Vector3.zero

        L.warpFly.enabled = true
        L.warpFly.hum:ChangeState(Enum.HumanoidStateType.Climbing)
        task.wait()
    end
end

function L.warpFly.healthLockLoop()
    while L.warpFly.enabled do
        if L.warpFly.hum and L.warpFly.hum.Health <= 0 then
            L.warpFly.hum.Health = L.warpFly.hum.MaxHealth
        end
        task.wait(0.1)
    end
end

function L.warpFly.onDied()
    if L.warpFly.hum and L.warpFly.enabled then
        L.warpFly.hum.Health = L.warpFly.hum.MaxHealth
        L.warpFly.hum:ChangeState(Enum.HumanoidStateType.Running)
        pcall(function()
            L.warpFly.hum.Parent = Players.LocalPlayer.Character
        end)
    end
end

function L.warpFly.start()
    if L.warpFly.enabled then return end
    if L.tpFreecam and L.tpFreecam.active then L.tpFreecam.stop() end
    L.warpFly._tmp.char = Players.LocalPlayer.Character
    if not L.warpFly._tmp.char then return end
    L.warpFly.hrp = L.warpFly._tmp.char:FindFirstChild("HumanoidRootPart")
    L.warpFly.head = L.warpFly._tmp.char:FindFirstChild("Head")
    L.warpFly.hum = L.warpFly._tmp.char:FindFirstChild("Humanoid")
    if not L.warpFly.hrp or not L.warpFly.head or not L.warpFly.hum then return end

    for _, part in L.warpFly._tmp.char:GetDescendants() do
        if part:IsA("BasePart") and L.warpFly.originalCanCollide[part] == nil then
            L.warpFly.originalCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    L.warpFly.descendantConnection = L.warpFly._tmp.char.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") and L.warpFly.originalCanCollide[desc] == nil then
            L.warpFly.originalCanCollide[desc] = desc.CanCollide
            desc.CanCollide = false
        end
    end)

    L.warpFly.enabled = true
    L.warpFly.isNoclipping = false
    L.warpFly.hum:ChangeState(Enum.HumanoidStateType.Climbing)

    L.warpFly.microStepConn = task.spawn(L.warpFly.microStepLoop)
    L.warpFly.healthLockConn = task.spawn(L.warpFly.healthLockLoop)
    L.warpFly.diedConn = L.warpFly.hum.Died:Connect(L.warpFly.onDied)
end

function L.warpFly.stop()
    L.warpFly.enabled = false
    L.warpFly.clear()
    if Toggles.WarpFlyToggle and Toggles.WarpFlyToggle.Value then
        Toggles.WarpFlyToggle:SetValue(false)
    end
end

function L.warpFly.teleportAndFly(targetPos)
    L.warpFly.start()
    L.warpFly._tmp.char = Players.LocalPlayer.Character
    if L.warpFly._tmp.char then
        local hrp = L.warpFly._tmp.char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = cfNew(targetPos + v3new(0, 5, 0))
        end
    end
    task.delay(0.5, function()
        L.warpFly.stop()
    end)
end


L.tpFreecam = {
    active = false,
    speed = 50,
    selected = nil,
    saved = {},
    nameList = {},
    conns = {},
    listenersInstalled = false,
    circle = nil,
    soul = nil,
    hoverPos = v3new(0, 0, 0),
    oldCamType = nil,
    oldCamSubject = nil,
    origCollide = {},
    jumpUpUntil = 0,
    moveDir = v3new(0, 0, 0),
}

local TPF_IDLE_THRESHOLD = 0.1

do
    L.tpFreecam.saved = {}
    pcall(function()
        if getgenv then
            getgenv().TPFreecamSaves = nil
            getgenv().TPFreecamCleanup = L.tpFreecam.cleanup
        end
    end)
end

function L.tpFreecam.getChar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return nil end
    return char, hum, hrp
end

function L.tpFreecam.setNoclip(char)
    for _, part in char:GetDescendants() do
        if part:IsA("BasePart") then
            if L.tpFreecam.origCollide[part] == nil then
                L.tpFreecam.origCollide[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

function L.tpFreecam.restoreCollision()
    for part, can in L.tpFreecam.origCollide do
        if part and part.Parent then
            pcall(function() part.CanCollide = can end)
        end
    end
    table.clear(L.tpFreecam.origCollide)
end

function L.tpFreecam.setCircleVisible(v)
    if L.tpFreecam.circle then
        pcall(function()
            L.tpFreecam.circle.Visible = (v and L.tpFreecam.active) == true
        end)
    end
end

function L.tpFreecam.restoreWorld()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = L.tpFreecam.oldCamType or Enum.CameraType.Custom
        if hum then
            cam.CameraSubject = hum
        elseif L.tpFreecam.oldCamSubject then
            cam.CameraSubject = L.tpFreecam.oldCamSubject
        end
    end
    if hrp then hrp.Anchored = false end
    L.tpFreecam.restoreCollision()
    if L.tpFreecam.soul then
        pcall(function() L.tpFreecam.soul:Destroy() end)
        L.tpFreecam.soul = nil
    end
    pcall(function()
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
end

function L.tpFreecam.start()
    if L.tpFreecam.active then return end
    local char, _, hrp = L.tpFreecam.getChar()
    if not char then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if Toggles.WarpFlyToggle and Toggles.WarpFlyToggle.Value then
        Toggles.WarpFlyToggle:SetValue(false)
    end
    L.tpFreecam.oldCamType = cam.CameraType
    L.tpFreecam.oldCamSubject = cam.CameraSubject
    L.tpFreecam.active = true
    hrp.Anchored = true
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local soul = Instance.new("Part")
    soul.Name = "TPFreecamSoul"
    soul.Size = v3new(1, 1, 1)
    soul.Transparency = 1
    soul.Anchored = true
    soul.CanCollide = false
    soul.CanQuery = false
    soul.CanTouch = false
    soul.Position = cam.CFrame.Position
    soul.Parent = workspace
    L.tpFreecam.soul = soul
    L.tpFreecam.hoverPos = soul.Position
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = soul
    L.tpFreecam.installListeners()
    L.tpFreecam.setCircleVisible(true)
end

function L.tpFreecam.stop()
    if not L.tpFreecam.active then return end
    L.tpFreecam.active = false
    L.tpFreecam.moveDir = v3new(0, 0, 0)
    L.tpFreecam.restoreWorld()
    L.tpFreecam.setCircleVisible(false)
    local toggle = Toggles.TPFreecamToggle
    if toggle and toggle.Value then
        toggle:SetValue(false)
    end
end

function L.tpFreecam.tpTo(cf)
    if not cf then return end
    local char, hum, hrp = L.tpFreecam.getChar()
    if not char then return end
    hrp.Anchored = true
    L.tpFreecam.setNoclip(char)
    task.wait()
    hrp.CFrame = cf
    local cam = workspace.CurrentCamera
    if L.tpFreecam.active and cam then
        cam.CFrame = cf
    end
    task.wait()
    if not L.tpFreecam.active then
        hrp.Anchored = false
        L.tpFreecam.restoreCollision()
    end
end

function L.tpFreecam.tpToCamera()
    local cam = workspace.CurrentCamera
    if cam then L.tpFreecam.tpTo(cam.CFrame) end
end

function L.tpFreecam.pointNames()
    local names = {}
    for i, pt in L.tpFreecam.saved do
        if pt and pt.CFrame then
            local p = pt.CFrame.Position
            names[#names + 1] = string.format("%d. %s (%.0f,%.0f,%.0f)", i, tostring(pt.Name), p.X, p.Y, p.Z)
        end
    end
    return names
end

function L.tpFreecam.refreshDropdown()
    local dd = Options.TPFreecamPoints
    if not dd then return end
    local names = L.tpFreecam.pointNames()
    L.tpFreecam.nameList = names
    dd:SetValues(names)
    if #names > 0 then
        local sel = L.tpFreecam.selected
        local ok = false
        for _, n in names do
            if n == sel then ok = true break end
        end
        if not ok then
            L.tpFreecam.selected = names[1]
        end
        dd:SetValue(L.tpFreecam.selected)
    else
        L.tpFreecam.selected = nil
    end
end

function L.tpFreecam.saveCurrent(name)
    local cam = workspace.CurrentCamera
    local cf = nil
    if L.tpFreecam.active and cam then
        cf = cam.CFrame
    else
        local _, _, hrp = L.tpFreecam.getChar()
        if hrp then cf = hrp.CFrame end
        if not cf and cam then cf = cam.CFrame end
    end
    if not cf then return end
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Pos" .. tostring(#L.tpFreecam.saved + 1) end
    table.insert(L.tpFreecam.saved, { Name = name, CFrame = cf })
    L.tpFreecam.refreshDropdown()
    L.notify(TranslateText("保存位置"), 2)
end

function L.tpFreecam.saveFromInput()
    local opt = Options.TPFreecamName
    L.tpFreecam.saveCurrent(opt and opt.Value or "")
    if opt and opt.SetValue then
        pcall(function() opt:SetValue("") end)
    end
end

function L.tpFreecam.tpToSelected()
    local sel = L.tpFreecam.selected
    if not sel then return end
    for i, n in L.tpFreecam.nameList do
        if n == sel then
            local pt = L.tpFreecam.saved[i]
            if pt and pt.CFrame then
                L.tpFreecam.tpTo(pt.CFrame)
            end
            return
        end
    end
end

function L.tpFreecam.deleteSelected()
    local sel = L.tpFreecam.selected
    if not sel then return end
    for i, n in L.tpFreecam.nameList do
        if n == sel then
            table.remove(L.tpFreecam.saved, i)
            L.tpFreecam.refreshDropdown()
            return
        end
    end
end

function L.tpFreecam.clearPoints()
    table.clear(L.tpFreecam.saved)
    L.tpFreecam.refreshDropdown()
end

function L.tpFreecam.getControls()
    local cm = L.ControlModule
    if cm and cm.GetMoveVector then return cm end
    pcall(function()
        local scripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
        local pm = scripts and scripts:FindFirstChild("PlayerModule")
        if pm then
            cm = require(pm):GetControls()
            if cm and cm.GetMoveVector then
                L.ControlModule = cm
            end
        end
    end)
    return L.ControlModule
end

function L.tpFreecam.updateMoveDir()
    local camera = workspace.CurrentCamera
    if not camera then L.tpFreecam.moveDir = v3new(0, 0, 0) return end
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local direction = v3new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
        direction += v3new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        direction -= v3new(0, 1, 0)
    end
    if direction.Magnitude < 0.1 and UserInputService.TouchEnabled then
        local cm = L.tpFreecam.getControls()
        if cm then
            local ok, mv = pcall(function() return cm:GetMoveVector() end)
            if ok and typeof(mv) == "Vector3" and mv.Magnitude > 0.1 then
                direction += (right * mv.X) + (forward * -mv.Z)
            end
        end
    end
    if osClock() < (L.tpFreecam.jumpUpUntil or 0) then
        direction += v3new(0, 1, 0)
    end
    if direction.Magnitude > 0.1 then
        L.tpFreecam.moveDir = direction.Unit * L.tpFreecam.speed
    else
        L.tpFreecam.moveDir = v3new(0, 0, 0)
    end
end

function L.tpFreecam.onHeartbeat(dt)
    dt = (type(dt) == "number" and dt <= 0.1) and dt or 0.016
    local cam = workspace.CurrentCamera
    if L.tpFreecam.circle and cam then
        pcall(function()
            L.tpFreecam.circle.Position = cam.ViewportSize / 2
        end)
    end
    if not L.tpFreecam.active then return end
    L.tpFreecam.updateMoveDir()
    local soul = L.tpFreecam.soul
    if soul and soul.Parent then
        pcall(function()
            if L.tpFreecam.moveDir.Magnitude > TPF_IDLE_THRESHOLD then
                soul.CFrame += L.tpFreecam.moveDir * dt
                L.tpFreecam.hoverPos = soul.Position
            else
                soul.CFrame = cfNew(L.tpFreecam.hoverPos) * soul.CFrame.Rotation
            end
        end)
    end
end

function L.tpFreecam.installListeners()
    if L.tpFreecam.listenersInstalled then return end
    L.tpFreecam.listenersInstalled = true
    pcall(function()
        if Drawing and not L.tpFreecam.circle then
            local c = Drawing.new("Circle")
            c.Visible = false
            c.Radius = 25
            c.Thickness = 2
            c.Filled = false
            c.Transparency = 1
            c.Color = Color3.fromRGB(0, 255, 0)
            L.tpFreecam.circle = c
        end
    end)
    table.insert(L.tpFreecam.conns, RunService.Heartbeat:Connect(function(dt)
        L.tpFreecam.onHeartbeat(dt)
    end))
    table.insert(L.tpFreecam.conns, UserInputService.JumpRequest:Connect(function()
        if not L.tpFreecam.active then return end
        L.tpFreecam.jumpUpUntil = osClock() + 0.3
    end))
end

function L.tpFreecam.cleanup()
    L.tpFreecam.active = false
    L.tpFreecam.restoreWorld()
    for _, c in L.tpFreecam.conns do
        pcall(function() c:Disconnect() end)
    end
    table.clear(L.tpFreecam.conns)
    L.tpFreecam.listenersInstalled = false
    if L.tpFreecam.circle then
        pcall(function() L.tpFreecam.circle:Remove() end)
        L.tpFreecam.circle = nil
    end
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local old = pg and pg:FindFirstChild("TPFreecamGui")
        if old then old:Destroy() end
    end)
    pcall(function()
        if getgenv and getgenv().TPFreecamCleanup == L.tpFreecam.cleanup then
            getgenv().TPFreecamCleanup = nil
        end
    end)
end

L.onCharacterAdded(function()
    if L.tpFreecam.active then L.tpFreecam.stop() end
end)

do
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        local old = pg and pg:FindFirstChild("TPFreecamGui")
        if old then old:Destroy() end
    end)
    pcall(function()
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
    pcall(function()
        if getgenv and type(getgenv().TPFreecamCleanup) == "function"
            and getgenv().TPFreecamCleanup ~= L.tpFreecam.cleanup then
            getgenv().TPFreecamCleanup()
        end
    end)
    L.tpFreecam.refreshDropdown()
end


function L.FlyAnimation()
    loadstring([[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ControlModule = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local HOVER_ANIM_ID = "rbxassetid://97171309"

local flight = {
    isFlying = false,
    flySpeed = 40,
    bv = nil,
    animCache = nil,
    hrp = nil,
    hum = nil,
    hoverTrack = nil,
    animator = nil,
}

function flight:loadAndFreezeHover()
    if not self.hum then return end
    self.animator = self.hum:FindFirstChildOfClass("Animator")
    if not self.animator then
        self.animator = Instance.new("Animator")
        self.animator.Parent = self.hum
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = HOVER_ANIM_ID
    self.hoverTrack = self.animator:LoadAnimation(anim)
    self.hoverTrack.Priority = Enum.AnimationPriority.Action4
    self.hoverTrack:Play()
    self.hoverTrack:AdjustSpeed(0)
end

function flight:clearResources()
    local char = lp.Character
    if self.animCache and char then
        self.animCache.Parent = char
    end
    if self.bv then
        self.bv:Destroy()
        self.bv = nil
    end
    if self.lvAttachment then
        self.lvAttachment:Destroy()
        self.lvAttachment = nil
    end
    if self.hoverTrack then
        self.hoverTrack:Stop()
        self.hoverTrack = nil
    end
    if self.hum and self.hum.Parent then
        self.hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    self.animator = nil
end

function flight:startFly()
    if self.isFlying then return end
    local char = lp.Character
    if not char then return end
    self.hrp = char:WaitForChild("HumanoidRootPart")
    self.hum = char:WaitForChild("Humanoid")
    local ani = char:FindFirstChild("Animate")
    if ani then
        self.animCache = ani
        ani.Parent = nil
    end
    if self.hrp:FindFirstChild("LeipzigBV") then
        self.hrp.LeipzigBV:Destroy()
    end
    local attachment = self.hrp:FindFirstChild("LeipzigAVAttachment")
    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = "LeipzigAVAttachment"
        attachment.Parent = self.hrp
    end
    local lv = Instance.new("LinearVelocity")
    lv.Name = "LeipzigBV"
    lv.Attachment0 = attachment
    lv.MaxForce = 1e6
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.VectorVelocity = Vector3.zero
    lv.Parent = self.hrp
    self.bv = lv
    self.lvAttachment = attachment
    self:loadAndFreezeHover()
    self.isFlying = true
    task.spawn(function()
        while self.isFlying and char.Parent do
            local mv = ControlModule:GetMoveVector()
            local cf = camera.CFrame
            local dir = (cf.LookVector * -mv.Z) + (cf.RightVector * mv.X)
            if mv.Magnitude > 0 then
                self.bv.VectorVelocity = dir.Unit * self.flySpeed
            else
                self.bv.VectorVelocity = Vector3.zero
            end
            self.hum:ChangeState(Enum.HumanoidStateType.Climbing)
            RunService.RenderStepped:Wait()
        end
        self:clearResources()
    end)
end

function flight:stopFly()
    if not self.isFlying then return end
    self.isFlying = false
    self:clearResources()
end

function flight:setSpeed(speed)
    self.flySpeed = mathClamp(speed, 10, 100)
end

local function bindCharacter()
    local char = lp.Character or lp.CharacterAdded:Wait()
    flight.hrp = char:WaitForChild("HumanoidRootPart")
    flight.hum = char:WaitForChild("Humanoid")
    flight:clearResources()
    char.AncestryChanged:Connect(function(_, parent)
        if not parent then
            flight:clearResources()
            bindCharacter()
        end
    end)
end
bindCharacter()

local pgui = lp:WaitForChild("PlayerGui")
if pgui:FindFirstChild("OriginalFlightUI") then pgui.OriginalFlightUI:Destroy() end

local UI_BG = c3rgb(200, 230, 255)
local BTN_OFF = c3rgb(150, 200, 255)
local BTN_ON = c3rgb(70, 150, 255)
local DESTROY_BTN = c3rgb(110, 180, 255)
local TEXT_COLOR = c3rgb(0, 60, 120)
local SPEED_BG = c3rgb(180, 220, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OriginalFlightUI"
ScreenGui.Parent = pgui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 145)
MainFrame.Position = UDim2.new(0.5, -75, 0.3, 0)
MainFrame.BackgroundColor3 = UI_BG
MainFrame.BackgroundTransparency = 0.4
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = MainFrame
    local stroke = Instance.new("UIStroke")
    stroke.Parent = MainFrame
    stroke.Color = c3rgb(120, 200, 255)
    stroke.Thickness = 3
    stroke.Transparency = 0.1

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Size = UDim2.new(1,0,0,20)
Title.BackgroundTransparency = 1
Title.Text = "飞行-动画"
Title.TextColor3 = TEXT_COLOR
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold

    local Tip = Instance.new("TextLabel")
    Tip.Parent = MainFrame
    Tip.Size = UDim2.new(1,0,0,14)
Tip.Position = UDim2.new(0,0,0,20)
Tip.BackgroundTransparency = 1
Tip.Text = "无相机锁定"
Tip.TextColor3 = Color3.new(0.9,0,0)
Tip.TextSize = 8

    local SpeedInput = Instance.new("TextBox")
    SpeedInput.Parent = MainFrame
    SpeedInput.Size = UDim2.new(0,120,0,24)
SpeedInput.Position = UDim2.new(0.5,-60,0, 38)
SpeedInput.BackgroundColor3 = SPEED_BG
SpeedInput.BackgroundTransparency = 0.3
SpeedInput.Text = tostring(flight.flySpeed)
SpeedInput.TextColor3 = TEXT_COLOR
SpeedInput.TextSize = 11
    do
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 7)
        inputCorner.Parent = SpeedInput
    end

    local FlyBtn = Instance.new("TextButton")
    FlyBtn.Parent = MainFrame
    FlyBtn.Size = UDim2.new(0,120,0,26)
FlyBtn.Position = UDim2.new(0.5,-60,0, 72)
FlyBtn.BackgroundColor3 = BTN_OFF
FlyBtn.BackgroundTransparency = 0.3
FlyBtn.Text = "飞行"
FlyBtn.TextColor3 = TEXT_COLOR
FlyBtn.TextSize = 11
    do
        local flyCorner = Instance.new("UICorner")
        flyCorner.CornerRadius = UDim.new(0, 8)
        flyCorner.Parent = FlyBtn
    end

    local DestroyUI = Instance.new("TextButton")
    DestroyUI.Parent = MainFrame
    DestroyUI.Size = UDim2.new(0,120,0,26)
DestroyUI.Position = UDim2.new(0.5,-60,0, 108)
DestroyUI.BackgroundColor3 = DESTROY_BTN
DestroyUI.BackgroundTransparency = 0.3
DestroyUI.Text = "销毁UI"
DestroyUI.TextColor3 = TEXT_COLOR
DestroyUI.TextSize = 11
    do
        local destroyCorner = Instance.new("UICorner")
        destroyCorner.CornerRadius = UDim.new(0, 8)
        destroyCorner.Parent = DestroyUI
    end

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val then
        flight:setSpeed(val)
    else
        flight:setSpeed(40)
    end
    SpeedInput.Text = tostring(flight.flySpeed)
end)

FlyBtn.MouseButton1Click:Connect(function()
    if flight.isFlying then
        flight:stopFly()
        FlyBtn.Text = "飞行"
        FlyBtn.BackgroundColor3 = BTN_OFF
    else
        flight:startFly()
        FlyBtn.Text = "飞行开"
        FlyBtn.BackgroundColor3 = BTN_ON
    end
end)

DestroyUI.MouseButton1Click:Connect(function()
    flight:stopFly()
    ScreenGui:Destroy()
end)

MainFrame.Size = UDim2.new(0,0,0,0)
MainFrame:TweenSize(UDim2.new(0,150,0,145), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
]])()
end

local AutoESPTabbox = Tabs.Auto:AddRightTabbox()
local AutoLeftGroup = AutoESPTabbox:AddTab("僵尸透视")

AutoLeftGroup:AddToggle('ESPAxe', {
    Text = '透视斧头僵尸',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Axe = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPEye', {
    Text = '透视红眼',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Eye = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPSword', {
    Text = '透视胸甲骑兵',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Sword = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPBarrel', {
    Text = '透视自爆',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Barrel = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPFTorso', {
    Text = '透视提灯人',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.FTorso = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPNormal', {
    Text = '透视山伯乐',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Normal = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('ESPHeadless', {
    Text = '透视无头士兵',
    Default = false,
    Callback = function(Value)
        L.zombieEspEnabled.Headless = Value
        if Value then L.startZombieESPHeartbeat() else L.stopZombieESPHeartbeat() end
    end
})

AutoLeftGroup:AddToggle('HeadlessHighlightToggle', {
    Text = '透视无头骑士',
    Default = false,
    Callback = function(Value)
        L.toggleHeadlessHighlight(Value)
    end
})

AutoLeftGroup:AddToggle('DraculaHighlightToggle', {
    Text = '透视德古拉',
    Default = false,
    Callback = function(Value)
        L.toggleDraculaHighlight(Value)
    end
})

local AutoPlayerESPGroup = AutoESPTabbox:AddTab("玩家透视")

AutoPlayerESPGroup:AddToggle('PlayerESPEnable', {
    Text = '启用玩家透视',
    Default = false,
    Tooltip = TranslateTooltip('开启后对玩家高亮'),
    Callback = function(Value)
        L.espPlayerEnabled = Value
        if Value then
            L.refreshAllPlayers()
            L.startPlayerESPRefresh()
        else
            L.stopPlayerESPRefresh()
            for _, player in Players:GetPlayers() do
                L.destroyPlayerComponents(player)
            end
        end
    end
})

AutoPlayerESPGroup:AddToggle('PlayerESPName', {
    Text = '显示玩家名称',
    Default = false,
    Tooltip = TranslateTooltip('开启显示玩家用户名'),
    Callback = function(Value)
        L.espShowNames = Value
        L.refreshAllPlayers()
    end
})

AutoPlayerESPGroup:AddToggle('PlayerESPHealth', {
    Text = '显示玩家血量',
    Default = false,
    Tooltip = TranslateTooltip('开启显示玩家血量数值'),
    Callback = function(Value)
        L.espShowHealth = Value
        L.refreshAllPlayers()
    end
})

AutoPlayerESPGroup:AddToggle('PlayerESPTeam', {
    Text = '队伍检测',
    Default = false,
    Tooltip = TranslateTooltip('开启后只高亮透视敌方队伍玩家'),
    Callback = function(Value)
        L.espTeamCheckPlayer = Value
        L.refreshAllPlayers()
    end
})

AutoPlayerESPGroup:AddToggle('PlayerESPInfection', {
    Text = '显示玩家感染值',
    Default = false,
    Tooltip = TranslateTooltip('开启后显示其他玩家感染值'),
    Callback = function(Value)
        L.infectionEnabled = Value
        if Value then
            L.startInfectionUpdating()
        else
            L.stopInfectionUpdating()
        end
    end
})


AutoPlayerESPGroup:AddToggle('PlayerESPJob', {
    Text = '显示玩家职业',
    Default = false,
    Callback = function(Value)
        if Value then
            L.startJobUpdating()
        else
            L.stopJobUpdating()
        end
    end
})


local AutoRightGroup = Tabs.Auto:AddGroupbox({ Side = "Left", Name = "其他功能", IconName = "settings", Description = "显示提示" })


local MinorLeftGroup = Tabs.Minor:AddGroupbox({ Side = "Left", Name = "防护功能", IconName = "shield", Description = "防坠自救" })

MinorLeftGroup:AddToggle('AutoEscapeToggle', {
    Text = '红眼扑倒自救',
    Default = false,
    Callback = function(v) if v then L.AutoEscape.enable() else L.AutoEscape.disable() end end
})

MinorLeftGroup:AddToggle('FallProtectionToggle', {
    Text = '防骨折',
    Default = false,
    Callback = function(v) if v then L.startFallProtection() else L.stopFallProtection() end end
})

MinorLeftGroup:AddToggle('AntiVelocityToggle', {
    Text = '骨折可移动',
    Default = false,
    Callback = function(v)
        if v then L.antiVelocityEnable() else L.antiVelocityDisable() end
    end
})

MinorLeftGroup:AddToggle('AntiGrabToggle', {
    Text = '防抓取',
    Default = false,
    Callback = function(v) if v then L.AntiGrab.start() else L.AntiGrab.stop() end end
})

MinorLeftGroup:AddToggle('DamageDisplayToggle', {
    Text = '显示受伤伤害',
    Default = false,
    Callback = function(v) if v then L.damageDisplay.start() else L.damageDisplay.stop() end end
})

MinorLeftGroup:AddToggle('RescueTeammateToggle', {
    Text = '传送救援队友',
    Default = false,
    Callback = function(v) if v then L.rescueTeammate.start() else L.rescueTeammate.stop() end end
})

MinorLeftGroup:AddToggle('ElbowZombiesToggle', {
    Text = '肘击自救',
    Default = false,
    Callback = function(v) if v then L.elbowZombies.start() else L.elbowZombies.stop() end end
})

MinorLeftGroup:AddToggle('PushBarrelProtectToggle', {
    Text = '自爆拉扯（防护）',
    Default = false,
    Callback = function(v) if v then L.pushBarrelProtect.start() else L.pushBarrelProtect.stop() end end
})

MinorLeftGroup:AddSlider('PushBarrelProtectSize', {
    Text = '拉扯范围',
    Default = 10,
    Min = 1,
    Max = 15,
    Suffix = " 格",
    Callback = function(v) L.pushBarrelProtect.size = v end
})

MinorLeftGroup:AddToggle('AutoHelpToggleMisc', {
    Text = '自动求救',
    Default = false,
    Callback = function(v) if v then L.autoHelp.start() else L.autoHelp.stop() end end
})

local MinorGetGroup = Tabs.Misc:AddGroupbox({ Side = "Right", Name = "获取", IconName = "package", Description = "获取装备" })


MinorGetGroup:AddButton({
    Text = "获取吸血鬼刀 (Voivode)",
    Func = function()
        local purchase = L.getPurchaseEvent()
        if purchase then
            purchase:FireServer("Voivode")

            L.notify(TranslateText("已获取吸血鬼刀"), 2)
        end
    end
})


MinorGetGroup:AddButton({
    Text = "获取铁桩 (Iron Stake)",
    Func = function()
        local purchase = L.getPurchaseEvent()
        if purchase then
            purchase:FireServer("Iron Stake")
            L.notify(TranslateText("已获取铁桩"), 2)
        end
    end
})

function L.removeAllHats()
    for _, plr in Players:GetPlayers() do
        if plr.Character then
            for _, obj in plr.Character:GetChildren() do
                if obj:IsA("Accessory") then
                    obj:Destroy()
                end
            end
        end
    end
end

function L.removeAllShirts()
    for _, plr in Players:GetPlayers() do
        if plr.Character then
            for _, obj in plr.Character:GetChildren() do
                if obj:IsA("Shirt") or obj:IsA("ShirtGraphic") then
                    obj:Destroy()
                end
            end
        end
    end
end

function L.removeAllPants()
    for _, plr in Players:GetPlayers() do
        if plr.Character then
            for _, obj in plr.Character:GetChildren() do
                if obj:IsA("Pants") then
                    obj:Destroy()
                end
            end
        end
    end
end

function L.removeCarriages()
    local targetNames = {"Carriage", "RearCarriage", "WagonPlatform", "FL_Wheel", "Horse", "Behind"}
    for _, name in targetNames do
        for _, obj in workspace:GetDescendants() do
            if obj.Name == name then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
    end
end

AutoRightGroup:AddToggle('BulletDisplay', {
    Text = '显示子弹数量',
    Default = false,
    Callback = function(v) if v then L.bulletDisplay.start() else L.bulletDisplay.stop() end end
})


AutoRightGroup:AddToggle('TracerToggle', {
    Text = '显示子弹轨迹',
    Default = false,
    Callback = function(v) L.Tracer.toggle(v) end
})


AutoRightGroup:AddToggle('CannonSupplies', {
    Text = '火炮物资透视',
    Default = false,
    Callback = function(v) L.cannonSupplies.toggle(v) end
})

AutoRightGroup:AddToggle('KillSound', {
    Text = '击杀音效',
    Default = false,
    Callback = function(v) if v then L.killSound.start() else L.killSound.stop() end end
})
AutoRightGroup:AddSlider('KillSoundVol', {
    Text = '音效音量', Default = 7, Min = 1, Max = 10,
    Callback = function(v) L.killSound.volume = v end
})

AutoRightGroup:AddDivider()


AutoRightGroup:AddToggle('PingDisplay', {
    Text = '显示网络延迟',
    Default = false,
    Callback = function(v) if v then L.pingDisplay.start() else L.pingDisplay.stop() end end
})

L.noFogEnabled = false
L.noFogOriginal = {}
L.noFogOriginalsSaved = false
L.noFogAtmosphereBackup = {}
L.noFogConns = {}
L.noFogDebounce = false

function L.saveNoFogOriginal()
    if L.noFogOriginalsSaved then return end
    local ok = pcall(function()
        L.noFogOriginal = {
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
        }
        L.noFogOriginalsSaved = true
    end)
end
L.saveNoFogOriginal()

function L.applyNoFog()
    pcall(function()
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        L.noFogAtmosphereBackup = {}
        for _, v in Lighting:GetDescendants() do
            if v:IsA("Atmosphere") then
                table.insert(L.noFogAtmosphereBackup, { Instance = v, Parent = v.Parent })
                v.Parent = nil
            end
        end
    end)
end

function L.restoreNoFog()
    pcall(function()
        Lighting.FogEnd = L.noFogOriginal.FogEnd or 100000
        Lighting.FogStart = L.noFogOriginal.FogStart or 0
        for _, backup in L.noFogAtmosphereBackup do
            if backup.Instance and backup.Parent then
                backup.Instance.Parent = backup.Parent
            end
        end
        L.noFogAtmosphereBackup = {}
    end)
end

local function onNoFogPropertyChanged()
    if not L.noFogEnabled or L.noFogDebounce then return end
    L.noFogDebounce = true
    task.delay(0.1, function()
        L.noFogDebounce = false
        if L.noFogEnabled then pcall(L.applyNoFog) end
    end)
end

function L.startNoFogMonitor()
    for _, c in L.noFogConns do pcall(function() c:Disconnect() end) end
    table.clear(L.noFogConns)
    for _, prop in {"FogEnd", "FogStart"} do
        pcall(function()
            table.insert(L.noFogConns, Lighting:GetPropertyChangedSignal(prop):Connect(onNoFogPropertyChanged))
        end)
    end
    pcall(function()
        table.insert(L.noFogConns, Lighting.DescendantAdded:Connect(function(inst)
            if inst:IsA("Atmosphere") then onNoFogPropertyChanged() end
        end))
    end)
end

function L.stopNoFogMonitor()
    for _, c in L.noFogConns do pcall(function() c:Disconnect() end) end
    table.clear(L.noFogConns)
    L.noFogDebounce = false
end


AutoRightGroup:AddToggle('InfectionRemover', {
    Text = '移除感染红色血液',
    Default = false,
    Callback = function(v) if v then L.infectionRemover.start() else L.infectionRemover.stop() end end
})

AutoRightGroup:AddToggle('BombRange', {
    Text = '自爆范围显示',
    Default = false,
    Callback = function(v) if v then L.bombRange.start() else L.bombRange.stop() end end
})


AutoRightGroup:AddToggle('HandMortar', {
    Text = '手炮爆炸倒计时',
    Default = false,
    Callback = function(v) L.handMortar.setEnabled(v) end
})

AutoRightGroup:AddToggle('NoBarrelHit', {
    Text = '无法攻击自爆',
    Default = false,
    Callback = function(v) L.noBarrelHit.toggle(v) end
})


AutoRightGroup:AddToggle('JumpLock', {
    Text = '移除跳跃限制',
    Default = false,
    Callback = function(v) L.jumpLock.toggle(v) end
})

L.rollTiltEnabled = false
L.rollTiltSpeed = 3
L.rollTiltConn = nil
L.rollTiltHrp = nil
L.rollTiltRx = 0
L.rollTiltRz = 0
L.rollTiltLastUpdate = 0

function L.rollTiltStop()
    if L.rollTiltConn then
        L.rollTiltConn:Disconnect()
        L.rollTiltConn = nil
    end
    L.rollTiltEnabled = false
end

function L.rollTiltStart()
    if L.rollTiltEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    L.rollTiltHrp = char:FindFirstChild("HumanoidRootPart")
    if not L.rollTiltHrp then return end
    L.rollTiltEnabled = true
    L.rollTiltLastUpdate = 0
    L.rollTiltRx = 0
    L.rollTiltRz = 0
    L.rollTiltConn = RunService.RenderStepped:Connect(function()
        if not L.rollTiltEnabled or not L.rollTiltHrp or not L.rollTiltHrp.Parent then
            L.rollTiltStop()
            return
        end
        if tick_() - L.rollTiltLastUpdate > 0.05 then
            L.rollTiltLastUpdate = tick_()
            L.rollTiltRx = (math.random() - 0.5) * L.rollTiltSpeed * 0.15
            L.rollTiltRz = (math.random() - 0.5) * L.rollTiltSpeed * 0.15
        end
        L.rollTiltHrp.CFrame = L.rollTiltHrp.CFrame * CFrame.Angles(L.rollTiltRx, 0, L.rollTiltRz)
    end)
end

L.spin = {
    enabled = false,
    speed = 5,
    connection = nil,
    animLockThread = nil,
}

function L.spin.applySpinAnimationLock(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = false
    end
    if L.spin.animLockThread then
        task.cancel(L.spin.animLockThread)
        L.spin.animLockThread = nil
    end
    L.spin.animLockThread = task.spawn(function()
        local animate = char:FindFirstChild("Animate")
        local waited = 0
        while not animate and waited < 3 do
            task.wait(0.1)
            waited = waited + 0.1
            animate = char:FindFirstChild("Animate")
        end
        while L.spin.enabled and animate and animate.Parent do
            animate.Disabled = true
            task.wait(0.2)
        end
    end)
end

function L.spin.removeSpinAnimationLock(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = true
    end
    if L.spin.animLockThread then
        task.cancel(L.spin.animLockThread)
        L.spin.animLockThread = nil
    end
    local animate = char:FindFirstChild("Animate")
    if animate then
        animate.Disabled = false
    end
end

function L.spin.start()
    if L.spin.connection then return end
    L.spin.connection = RunService.RenderStepped:Connect(function(dt)
        if not L.spin.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local realSpeed = L.spin.speed * 350
        local angularSpeedRad = mathRad(realSpeed)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, angularSpeedRad * dt, 0)
    end)
    L.spin.applySpinAnimationLock(LocalPlayer.Character)
end

function L.spin.stop()
    L.spin.enabled = false
    if L.spin.connection then
        L.spin.connection:Disconnect()
        L.spin.connection = nil
    end
    L.spin.removeSpinAnimationLock(LocalPlayer.Character)
end

L.thirdPerson = {
    enabled = false,
    connection = nil,
}

function L.thirdPerson.apply()
    pcall(function()
        local lp = LocalPlayer
        if lp.CameraMode ~= Enum.CameraMode.Classic then
            lp.CameraMode = Enum.CameraMode.Classic
        end
        lp.CameraMinZoomDistance = 0.5
        lp.CameraMaxZoomDistance = 200
    end)
end

function L.thirdPerson.start()
    if L.thirdPerson.connection then return end
    L.thirdPerson.enabled = true
    L.thirdPerson.apply()
    L.thirdPerson.connection = RunService.RenderStepped:Connect(function()
        if not L.thirdPerson.enabled then return end
        L.thirdPerson.apply()
    end)
end

function L.thirdPerson.stop()
    L.thirdPerson.enabled = false
    if L.thirdPerson.connection then
        L.thirdPerson.connection:Disconnect()
        L.thirdPerson.connection = nil
    end
end

L.animFreeze = {
    enabled = false,
    currentAnimTrack = nil,
    originalAnimateDisabled = false,
    loopThread = nil,
    charAddedConn = nil,
}

function L.animFreeze.cleanup()
    if L.animFreeze.loopThread then
        task.cancel(L.animFreeze.loopThread)
        L.animFreeze.loopThread = nil
    end
    if L.animFreeze.currentAnimTrack then
        L.animFreeze.currentAnimTrack:Stop()
        L.animFreeze.currentAnimTrack = nil
    end
    local char = LocalPlayer.Character
    if char and L.animFreeze.originalAnimateDisabled then
        local animate = char:FindFirstChild("Animate")
        if animate then
            animate.Disabled = false
            L.animFreeze.originalAnimateDisabled = false
        end
    end
end

function L.animFreeze.playOnce()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if not L.animFreeze.originalAnimateDisabled then
        local animate = char:FindFirstChild("Animate")
        if animate and not animate.Disabled then
            animate.Disabled = true
            L.animFreeze.originalAnimateDisabled = true
        end
    end

    local animId = humanoid.RigType == Enum.HumanoidRigType.R6 and "rbxassetid://27432686" or "rbxassetid://507776043"
    local animObj = Instance.new("Animation")
    animObj.AnimationId = animId
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(animObj)
    track:Play()
    track:AdjustSpeed(0)
    if L.animFreeze.currentAnimTrack then
        L.animFreeze.currentAnimTrack:Stop()
    end
    L.animFreeze.currentAnimTrack = track
end

function L.animFreeze.loop()
    while L.animFreeze.enabled do
        pcall(function() L.animFreeze.playOnce() end)
        task.wait(0.1)
    end
end

function L.animFreeze.start()
    if L.animFreeze.enabled then return end
    L.animFreeze.enabled = true
    L.animFreeze.cleanup()
    L.animFreeze.loopThread = task.spawn(L.animFreeze.loop)
end

function L.animFreeze.stop()
    L.animFreeze.enabled = false
    L.animFreeze.cleanup()
end

L.invert = {
    enabled = false,
    conn = nil,
    charConn = nil,
}

function L.invert.apply()
    if not L.invert.enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if root then
        local pos = root.Position
        root.CFrame = cfNew(pos) * CFrame.Angles(mathRad(180), 0, 0)
    end
end

function L.invert.lockLoop()
    if L.invert.conn then return end
    L.invert.conn = RunService.RenderStepped:Connect(function()
        if L.invert.enabled then
            L.invert.apply()
        end
    end)
end

function L.invert.unlockLoop()
    if L.invert.conn then
        L.invert.conn:Disconnect()
        L.invert.conn = nil
    end
end

function L.invert.setEnabled(state)
    L.invert.enabled = state
    if state then
        L.invert.apply()
        L.invert.lockLoop()
    else
        L.invert.unlockLoop()
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if root then
                local pos = root.Position
                local currentCF = root.CFrame
                local yaw = math.atan2(-currentCF.LookVector.X, -currentCF.LookVector.Z)
                root.CFrame = cfNew(pos) * CFrame.Angles(0, yaw, 0)
            end
        end
    end
end

L.bigHead = {
    enabled = false,
    headSize = 3,
    headTrans = 0.5,
    originalProps = {},
    watchedZombies = {},
    connection = nil,
    descendantDisposer = nil,
}

function L.bigHead.applyToZombie(zombie)
    local head = zombie:FindFirstChild("Head")
    if not head then return end
    if not L.bigHead.originalProps[zombie] then
        L.bigHead.originalProps[zombie] = {
            Size = head.Size,
            Transparency = head.Transparency
        }
    end
    head.Size = v3new(L.bigHead.headSize, L.bigHead.headSize, L.bigHead.headSize)
    head.Transparency = L.bigHead.headTrans
end

function L.bigHead.restoreZombie(zombie)
    local props = L.bigHead.originalProps[zombie]
    if props then
        local head = zombie:FindFirstChild("Head")
        if head then
            head.Size = props.Size
            head.Transparency = props.Transparency
        end
        L.bigHead.originalProps[zombie] = nil
    end
end

function L.bigHead.clearAll()
    for zombie, _ in L.bigHead.originalProps do
        L.bigHead.restoreZombie(zombie)
    end
    L.bigHead.originalProps = {}
end

function L.bigHead.updateAllZombies()
    if not L.bigHead.enabled then return end
    for zombie in L.bigHead.watchedZombies do
        if zombie.Parent then
            L.bigHead.applyToZombie(zombie)
        else
            L.bigHead.watchedZombies[zombie] = nil
        end
    end
end

function L.bigHead.setupListener()
    if L.bigHead.descendantDisposer then
        L.bigHead.descendantDisposer()
        L.bigHead.descendantDisposer = nil
    end
    table.clear(L.bigHead.watchedZombies)
    L.ZombieWatch.start()
    local function track(desc)
        local cameraFolder = workspace:FindFirstChild("Camera")
        if not cameraFolder or not desc:IsDescendantOf(cameraFolder) then return end
        if not L.bigHead.watchedZombies[desc] then
            L.bigHead.watchedZombies[desc] = true
            if L.bigHead.enabled then
                L.bigHead.applyToZombie(desc)
            end
        end
    end
    L.ZombieWatch.forEach(track)
    L.bigHead.descendantDisposer = L.ZombieWatch.onAdded(track)
end

function L.bigHead.startLoop()
    if L.bigHead.connection then return end
    local acc = 0
    local lastPrune = 0
    L.bigHead.connection = RunService.RenderStepped:Connect(function(dt)
        if L.bigHead.enabled then
            acc = acc + dt
            if acc >= 0.1 then
                acc = 0
                L.bigHead.updateAllZombies()
            end
            local now = osClock()
            if now - lastPrune > 5 then
                lastPrune = now
                for zombie in L.bigHead.originalProps do
                    if not zombie.Parent then
                        L.bigHead.originalProps[zombie] = nil
                    end
                end
            end
        end
    end)
end

function L.bigHead.stopLoop()
    if L.bigHead.connection then
        L.bigHead.connection:Disconnect()
        L.bigHead.connection = nil
    end
end

function L.bigHead.enable()
    if L.bigHead.enabled then return end
    L.bigHead.enabled = true
    L.bigHead.setupListener()
    L.bigHead.updateAllZombies()
    L.bigHead.startLoop()
end

function L.bigHead.disable()
    L.bigHead.enabled = false
    L.bigHead.clearAll()
    table.clear(L.bigHead.watchedZombies)
    if L.bigHead.descendantDisposer then
        L.bigHead.descendantDisposer()
        L.bigHead.descendantDisposer = nil
    end
    L.bigHead.stopLoop()
end

L.animLoop1205Enabled = false
L.animLoop1205Track = nil
L.animLoop1205Connection = nil

function L.startAnimLoop1205()
    if L.animLoop1205Connection then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://120593550434546"
    L.animLoop1205Track = animator:LoadAnimation(animation)
    L.animLoop1205Track.Priority = Enum.AnimationPriority.Action4
    L.animLoop1205Connection = RunService.Heartbeat:Connect(function()
        if not L.animLoop1205Enabled then return end
        local currentChar = LocalPlayer.Character
        if not currentChar or not currentChar:FindFirstChildOfClass("Humanoid") then
            L.stopAnimLoop1205()
            return
        end
        pcall(function()
            if L.animLoop1205Track then
                if L.animLoop1205Track.IsPlaying then L.animLoop1205Track:Stop() end
                L.animLoop1205Track:Play()
            end
        end)
    end)
end

function L.stopAnimLoop1205()
    L.animLoop1205Enabled = false
    if L.animLoop1205Connection then
        L.animLoop1205Connection:Disconnect()
        L.animLoop1205Connection = nil
    end
    if L.animLoop1205Track then
        pcall(function() L.animLoop1205Track:Stop() end)
        L.animLoop1205Track = nil
    end
end

task.spawn(function()
    local rawRequire = require
    L.ControlModule = rawRequire(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)

L.AutoEscape = {
    enabled = false,
    active = false,
    checkThread = nil,
    heartbeatConn = nil,
    originalIndex = nil,
    camBindName = nil,
    offset = Vector3.new(0, 0, 0),
    savedCF = nil,
    savedVel = nil,
}

function L.AutoEscape.updateOffset()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local head = char:FindFirstChild("Head")
    local topY = hrp.Position.Y
    if head then
        topY = head.Position.Y
    end
    local up = (topY - hrp.Position.Y) + 680
    L.AutoEscape.offset = Vector3.new(0, up, 0)
end

function L.AutoEscape.start()
    if L.AutoEscape.active then return end
    L.AutoEscape.active = true

    local b = LocalPlayer
    local RS = RunService
    local state = L.AutoEscape

    state.heartbeatConn = RS.Heartbeat:Connect(function()
        if not state.active then return end
        if not b.Character then return end
        local i = b.Character:FindFirstChild("HumanoidRootPart")
        if not i then return end
        L.AutoEscape.updateOffset()
        state.savedCF = i.CFrame
        state.savedVel = i.AssemblyLinearVelocity
        local j = i.CFrame + state.offset
        i.CFrame = j
        i.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        RS.RenderStepped:Wait()
        if b.Character and b.Character:FindFirstChild("HumanoidRootPart") then
            b.Character.HumanoidRootPart.CFrame = state.savedCF
            b.Character.HumanoidRootPart.AssemblyLinearVelocity = state.savedVel
        end
    end)

    state.originalIndex = hookmetamethod(game, "__index", newcclosure(function(self, l)
        if state.active then
            if not checkcaller() then
                if l == "CFrame" and b.Character and b.Character:FindFirstChild("HumanoidRootPart") and b.Character:FindFirstChild("Humanoid") and b.Character:FindFirstChild("Humanoid").Health > 0 then
                    if self == b.Character.HumanoidRootPart then
                        return (state.savedCF or CFrame.new()) + state.offset
                    elseif self == b.Character.Head then
                        local m = state.savedCF or CFrame.new()
                        return m + state.offset
                    end
                end
            end
        end
        return state.originalIndex(self, l)
    end))

    state.camBindName = "AutoEscapeCamFix_" .. tostring(math.random(100000, 999999))
    RS:BindToRenderStep(
        state.camBindName,
        Enum.RenderPriority.Camera.Value + 1,
        function()
            if state.active and b.Character then
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = cam.CFrame - state.offset
                end
            end
        end
    )
end

function L.AutoEscape.stop()
    if not L.AutoEscape.active then return end
    L.AutoEscape.active = false

    if L.AutoEscape.heartbeatConn then
        pcall(function() L.AutoEscape.heartbeatConn:Disconnect() end)
        L.AutoEscape.heartbeatConn = nil
    end
    if L.AutoEscape.originalIndex then
        pcall(function() hookmetamethod(game, "__index", L.AutoEscape.originalIndex) end)
        L.AutoEscape.originalIndex = nil
    end
    if L.AutoEscape.camBindName then
        pcall(function() RunService:UnbindFromRenderStep(L.AutoEscape.camBindName) end)
        L.AutoEscape.camBindName = nil
    end
    L.AutoEscape.savedCF = nil
    L.AutoEscape.savedVel = nil
end

function L.AutoEscape.check()
    if not L.AutoEscape.enabled then return end
    local char = LocalPlayer.Character
    if not char then
        if L.AutoEscape.active then L.AutoEscape.stop() end
        return
    end
    local wsPlayers = workspace:FindFirstChild("Players")
    local folder = wsPlayers and wsPlayers:FindFirstChild(LocalPlayer.Name)
    local us = folder and folder:FindFirstChild("UserStates")
    local pin = us and us:FindFirstChild("Pin")
    local isPinned = pin and tostring(pin.Value) ~= "None"

    if isPinned and not L.AutoEscape.active then
        L.AutoEscape.start()
    elseif not isPinned and L.AutoEscape.active then
        L.AutoEscape.stop()
    end
end

function L.AutoEscape.enable()
    if L.AutoEscape.enabled then return end
    L.AutoEscape.enabled = true
    L.AutoEscape.checkThread = task.spawn(function()
        while L.AutoEscape.enabled do
            pcall(L.AutoEscape.check)
            task.wait(0.1)
        end
    end)
end

function L.AutoEscape.disable()
    L.AutoEscape.enabled = false
    if L.AutoEscape.checkThread then
        pcall(function() task.cancel(L.AutoEscape.checkThread) end)
        L.AutoEscape.checkThread = nil
    end
    L.AutoEscape.stop()
end

L.fallProtectionInstances = {}
L.fallProtectionEnabled = false

L.antiVelocity = L.antiVelocity or { enabled = false, wasBroken = false, conn = nil, savedAnimateDisabled = nil, savedNormal = nil, lastNormalSave = 0, lastFix = 0 }

local ANTI_VELOCITY_FRACTURE_IDS = {
    ["rbxassetid://12333490324"] = true,
    ["12333490324"] = true,
    ["rbxassetid://12333489072"] = true,
    ["12333489072"] = true,
}

function L.antiVelocity.snapshotTracks(hum)
    local out = {}
    pcall(function()
        for _, t in hum:GetPlayingAnimationTracks() do
            local anim = t.Animation
            local aid = anim and anim.AnimationId
            if aid and aid ~= "" then
                table.insert(out, {
                    id = aid,
                    name = t.Name,
                    priority = t.Priority,
                    speed = t.Speed,
                    looped = t.Looped,
                    weight = t.WeightCurrent,
                })
            end
        end
    end)
    return out
end

function L.antiVelocity.isLimpTrack(t, snapId)
    local ok, res = pcall(function()
        local anim = t.Animation
        local aid = anim and anim.AnimationId or ""
        if ANTI_VELOCITY_FRACTURE_IDS[aid] then return true end
        local num = tostring(aid):match("%d+")
        if num and ANTI_VELOCITY_FRACTURE_IDS[num] then return true end
        if snapId and aid == snapId then return true end
        local n = string.lower(t.Name or "")
        if n:find("limp") or n:find("fracture") or n:find("broken") or n:find("cripple") then
            return true
        end
        return false
    end)
    return ok and res or false
end

function L.antiVelocity.restoreTracks(char, saved)
    if not saved or #saved == 0 then return end
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end
        -- build set of currently playing ids so we don't stack duplicates
        local playingIds = {}
        pcall(function()
            for _, t in hum:GetPlayingAnimationTracks() do
                local aid = t.Animation and t.Animation.AnimationId
                if aid then playingIds[aid] = true end
            end
        end)
        for _, s in saved do
            if not playingIds[s.id] then
                local a = Instance.new("Animation")
                a.AnimationId = s.id
                local nt = animator:LoadAnimation(a)
                pcall(function() nt.Priority = s.priority end)
                pcall(function() nt.Looped = s.looped end)
                pcall(function() nt:Play(0.15, s.weight or 1, s.speed or 1) end)
            end
        end
    end)
end

function L.antiVelocity.suppressLimp(char)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _, t in hum:GetPlayingAnimationTracks() do
            if L.antiVelocity.isLimpTrack(t) then
                pcall(function() t:Stop(0.15) end)
            end
        end
    end)
end

function L.antiVelocityEnable()
    if L.antiVelocity.enabled then return end
    L.antiVelocity.enabled = true
    L.antiVelocity.wasBroken = false
    if L.antiVelocity.conn then
        pcall(function() L.antiVelocity.conn:Disconnect() end)
        L.antiVelocity.conn = nil
    end
    do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.AutoRotate = true end) end
    end

    L.antiVelocity.conn = RunService.Heartbeat:Connect(function()
        if not L.antiVelocity.enabled then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local hum0 = char:FindFirstChildOfClass("Humanoid")
        if hum0 and not hum0.AutoRotate then
            pcall(function() hum0.AutoRotate = true end)
        end

        -- 1. 禁用骨折速度限制器（每帧执行）
        local velObj = hrp:FindFirstChild("KillVelocity") or hrp:FindFirstChild("LinearVelocity")
        if velObj and (velObj:IsA("BodyVelocity") or velObj:IsA("LinearVelocity")) then
            velObj.Enabled = false
        end

        -- 2. 骨折时强制正常动画：压住跛行，播正常
        local userStates = char:FindFirstChild("UserStates")
        if userStates then
            local broken = userStates:FindFirstChild("BrokenLegs")
            if broken then
                local currentBroken = broken.Value == true
                local now = osClock()
                if not currentBroken then
                    -- 健康时缓存正常动画，每2秒更新一次
                    if now - (L.antiVelocity.lastNormalSave or 0) > 2.0 then
                        local humN = char:FindFirstChildOfClass("Humanoid")
                        if humN then
                            local snap = L.antiVelocity.snapshotTracks(humN)
                            -- 过滤掉跛行，只留正常
                            local filtered = {}
                            for _, s in snap do
                                local isLimp = ANTI_VELOCITY_FRACTURE_IDS[s.id]
                                if not isLimp then
                                    local ln = string.lower(s.name or "")
                                    if not (ln:find("limp") or ln:find("fracture") or ln:find("broken") or ln:find("cripple")) then
                                        table.insert(filtered, s)
                                    end
                                end
                            end
                            if #filtered > 0 then
                                L.antiVelocity.savedNormal = filtered
                                L.antiVelocity.lastNormalSave = now
                            end
                        end
                    end
                end
                if currentBroken and not L.antiVelocity.wasBroken then
                    L.antiVelocity.wasBroken = true
                    L.antiVelocity.lastFix = 0
                    local snapAnimate = char:FindFirstChild("Animate")
                    if snapAnimate and L.antiVelocity.savedAnimateDisabled == nil then
                        L.antiVelocity.savedAnimateDisabled = snapAnimate.Disabled
                    end
                    task.spawn(function()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hum then return end
                        pcall(function() hum.AutoRotate = true end)
                        local animate = char:FindFirstChild("Animate")
                        if animate and animate.Disabled then
                            pcall(function() animate.Disabled = false end)
                        end
                        -- 打断跛行状态
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                        task.wait(0.3)
                        if not L.antiVelocity.enabled or not char.Parent then return end
                        local us2 = char:FindFirstChild("UserStates")
                        local br2 = us2 and us2:FindFirstChild("BrokenLegs")
                        if not (br2 and br2.Value == true) then return end
                        L.antiVelocity.suppressLimp(char)
                        L.antiVelocity.restoreTracks(char, L.antiVelocity.savedNormal)
                    end)
                end
                -- 骨折持续期间：每0.3秒压一次跛行 + 补正常动画
                if currentBroken and L.antiVelocity.wasBroken then
                    if now - (L.antiVelocity.lastFix or 0) > 0.3 then
                        L.antiVelocity.lastFix = now
                        L.antiVelocity.suppressLimp(char)
                        local humChk = char:FindFirstChildOfClass("Humanoid")
                        if humChk and L.antiVelocity.savedNormal and #L.antiVelocity.savedNormal > 0 then
                            local normalPlaying = false
                            pcall(function()
                                for _, t in humChk:GetPlayingAnimationTracks() do
                                    local aid = t.Animation and t.Animation.AnimationId
                                    if aid and t.IsPlaying then
                                        for _, s in L.antiVelocity.savedNormal do
                                            if s.id == aid then
                                                normalPlaying = true
                                                break
                                            end
                                        end
                                    end
                                    if normalPlaying then break end
                                end
                            end)
                            if not normalPlaying then
                                L.antiVelocity.restoreTracks(char, L.antiVelocity.savedNormal)
                            end
                        end
                        -- 跛行状态机容易卡住，补一次 Running（不 wipe 已播的正常动画，只是解 stuck）
                        if humChk then
                            pcall(function()
                                local st = humChk:GetState()
                                if st == Enum.HumanoidStateType.Physics
                                    or st == Enum.HumanoidStateType.FallingDown
                                    or st == Enum.HumanoidStateType.Ragdoll then
                                    humChk:ChangeState(Enum.HumanoidStateType.Running)
                                end
                                if humChk.PlatformStand or humChk.Sit then
                                    humChk:ChangeState(Enum.HumanoidStateType.Running)
                                end
                            end)
                        end
                    end
                end
                -- 骨折恢复时重置标记 + 恢复正常动画
                if not currentBroken and L.antiVelocity.wasBroken then
                    L.antiVelocity.wasBroken = false
                    task.spawn(function()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local animate = char:FindFirstChild("Animate")
                        if animate and L.antiVelocity.savedAnimateDisabled ~= nil then
                            pcall(function() animate.Disabled = L.antiVelocity.savedAnimateDisabled end)
                            L.antiVelocity.savedAnimateDisabled = nil
                        end
                        if hum then
                            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                        end
                    end)
                end
            else
                L.antiVelocity.wasBroken = false
            end
        else
            L.antiVelocity.wasBroken = false
        end
    end)
end

function L.antiVelocityDisable()
    L.antiVelocity.enabled = false
    L.antiVelocity.wasBroken = false
    if L.antiVelocity.conn then
        pcall(function() L.antiVelocity.conn:Disconnect() end)
        L.antiVelocity.conn = nil
    end
    -- 关闭后回到游戏默认：恢复 Animate 开关，刷新一次状态让游戏自己播跛行/正常
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local animate = char:FindFirstChild("Animate")
            if animate and L.antiVelocity.savedAnimateDisabled ~= nil then
                animate.Disabled = L.antiVelocity.savedAnimateDisabled
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
    L.antiVelocity.savedAnimateDisabled = nil
    L.antiVelocity.savedNormal = nil
end

do

    local CLIMB_INTERVAL = 0.02
    local FALL_VELOCITY_THRESHOLD = -5
    local accumulator = 0
    local heartbeatConn = nil

    local function onHeartbeat(dt)
        if not L.fallProtectionEnabled then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then
            accumulator = 0
            return
        end

        local falling = root.AssemblyLinearVelocity.Y < FALL_VELOCITY_THRESHOLD
            and not UserInputService:IsKeyDown(Enum.KeyCode.Space)
        if not falling then
            accumulator = 0
            return
        end

        accumulator = accumulator + dt
        if accumulator >= CLIMB_INTERVAL then
            accumulator = 0
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Climbing)
            end)
        end
    end

    function L.startFallProtection()
        if L.fallProtectionEnabled then return end
        L.fallProtectionEnabled = true
        if not heartbeatConn then
            heartbeatConn = RunService.Heartbeat:Connect(onHeartbeat)
        end
    end

    function L.stopFallProtection()
        L.fallProtectionEnabled = false
        accumulator = 0
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
    end
end


L.AntiGrab = { enabled = false, connection = nil }

function L.AntiGrab.start()
    if L.AntiGrab.connection then return end
    L.AntiGrab.enabled = true
    L.AntiGrab.connection = RunService.Heartbeat:Connect(function()
        if not L.AntiGrab.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:Move(v3new(0, 100000, 0)) end)
        end
    end)
end

function L.AntiGrab.stop()
    L.AntiGrab.enabled = false
    if L.AntiGrab.connection then
        L.AntiGrab.connection:Disconnect()
        L.AntiGrab.connection = nil
    end
end


L.damageDisplay = { enabled = false, damageQueue = {}, isPlaying = false, billboard = nil, textLabel = nil, fadeTween = nil, fadeOutTween = nil, lastHealth = nil, healthConn = nil, charConn = nil }

function L.damageDisplay.ensureBillboard()
    if L.damageDisplay.billboard and L.damageDisplay.billboard.Parent then return end
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    L.damageDisplay.billboard = Instance.new("BillboardGui")
    L.damageDisplay.billboard.Size = UDim2.new(0, 100, 0, 50)
    L.damageDisplay.billboard.StudsOffset = v3new(0, 2.5, 0)
    L.damageDisplay.billboard.AlwaysOnTop = true
    L.damageDisplay.billboard.Adornee = head
    L.damageDisplay.billboard.Parent = char
    L.damageDisplay.textLabel = Instance.new("TextLabel")
    L.damageDisplay.textLabel.Size = UDim2.new(1, 0, 1, 0)
    L.damageDisplay.textLabel.BackgroundTransparency = 1
    L.damageDisplay.textLabel.Text = ""
    L.damageDisplay.textLabel.TextSize = 30
    L.damageDisplay.textLabel.Font = Enum.Font.GothamBold
    L.damageDisplay.textLabel.TextStrokeTransparency = 0.2
    L.damageDisplay.textLabel.TextStrokeColor3 = c3rgb(0,0,0)
    L.damageDisplay.textLabel.Parent = L.damageDisplay.billboard
    L.damageDisplay.billboard.Enabled = false
end

function L.damageDisplay.destroyBillboard()
    if L.damageDisplay.billboard then L.damageDisplay.billboard:Destroy() end
    L.damageDisplay.billboard = nil
    L.damageDisplay.textLabel = nil
    if L.damageDisplay.fadeTween then L.damageDisplay.fadeTween:Cancel() end
    L.damageDisplay.fadeTween = nil
end

function L.damageDisplay.showDamage(damage)
    if not L.damageDisplay.enabled then return end
    L.damageDisplay.ensureBillboard()
    if not L.damageDisplay.billboard then return end
    local color = damage < 20 and c3rgb(0,255,0) or (damage < 50 and c3rgb(255,255,0) or c3rgb(255,0,0))
    L.damageDisplay.textLabel.Text = tostring(mathFloor(damage))
    L.damageDisplay.textLabel.TextColor3 = color
    L.damageDisplay.billboard.Enabled = true
    if L.damageDisplay.fadeTween then L.damageDisplay.fadeTween:Cancel() end
    if L.damageDisplay.fadeOutTween then L.damageDisplay.fadeOutTween:Cancel(); L.damageDisplay.fadeOutTween = nil end
    L.damageDisplay.textLabel.TextTransparency = 1
    L.damageDisplay.fadeTween = TweenService:Create(L.damageDisplay.textLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0})
    L.damageDisplay.fadeTween:Play()
    task.delay(1.0, function()
        if L.damageDisplay.textLabel then
            local fadeOut = TweenService:Create(L.damageDisplay.textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextTransparency = 1})
            L.damageDisplay.fadeOutTween = fadeOut
            fadeOut:Play()
            fadeOut.Completed:Wait()
            if L.damageDisplay.fadeOutTween == fadeOut then L.damageDisplay.fadeOutTween = nil end
            if L.damageDisplay.billboard then L.damageDisplay.billboard.Enabled = false end
        end
        L.damageDisplay.isPlaying = false
        if #L.damageDisplay.damageQueue > 0 then
            local nextDamage = table.remove(L.damageDisplay.damageQueue, 1)
            L.damageDisplay.isPlaying = true
            L.damageDisplay.showDamage(nextDamage)
        end
        L.damageDisplay.fadeTween = nil
    end)
end

function L.damageDisplay.queueDamage(dmg)
    if not L.damageDisplay.enabled then return end
    table.insert(L.damageDisplay.damageQueue, dmg)
    if not L.damageDisplay.isPlaying then
        L.damageDisplay.isPlaying = true
        local dmg = table.remove(L.damageDisplay.damageQueue, 1)
        L.damageDisplay.showDamage(dmg)
    end
end

function L.damageDisplay.onHealthChanged()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local cur = hum.Health
    if L.damageDisplay.lastHealth == nil then
        L.damageDisplay.lastHealth = cur
        return
    end
    local dmg = L.damageDisplay.lastHealth - cur
    if dmg > 0 then L.damageDisplay.queueDamage(dmg) end
    L.damageDisplay.lastHealth = cur
end

function L.damageDisplay.start()
    if L.damageDisplay.healthConn then L.damageDisplay.healthConn:Disconnect() end
    if L.damageDisplay.charConn then L.damageDisplay.charConn(); L.damageDisplay.charConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            L.damageDisplay.lastHealth = hum.Health
            L.damageDisplay.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(L.damageDisplay.onHealthChanged)
        end
    end
    L.damageDisplay.charConn = L.onCharacterAdded(function(ch)
        task.wait(0.2)
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then
            if L.damageDisplay.healthConn then L.damageDisplay.healthConn:Disconnect() end
            L.damageDisplay.lastHealth = hum.Health
            L.damageDisplay.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(L.damageDisplay.onHealthChanged)
        end
        L.damageDisplay.destroyBillboard()
        L.damageDisplay.ensureBillboard()
        L.damageDisplay.damageQueue = {}
        L.damageDisplay.isPlaying = false
    end)
    L.damageDisplay.ensureBillboard()
end

function L.damageDisplay.stop()
    if L.damageDisplay.healthConn then L.damageDisplay.healthConn:Disconnect() end
    if L.damageDisplay.charConn then L.damageDisplay.charConn(); L.damageDisplay.charConn = nil end
    L.damageDisplay.destroyBillboard()
    L.damageDisplay.damageQueue = {}
    L.damageDisplay.isPlaying = false
    L.damageDisplay.lastHealth = nil
    if L.damageDisplay.fadeTween then L.damageDisplay.fadeTween:Cancel() end
end

L.rescueTeammate = { enabled = false, thread = nil, inf = {}, busy = false }

function L.rescueTeammate.getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function L.rescueTeammate.getPin(player)
    local ok, v = pcall(function()
        local wsPlayers = workspace:FindFirstChild("Players")
        return wsPlayers[player.Name].UserStates.Pin.Value
    end)
    return ok and tostring(v) ~= "None"
end

function L.rescueTeammate.getInf(player)
    local ok, v = pcall(function()
        local wsPlayers = workspace:FindFirstChild("Players")
        return wsPlayers[player.Name].UserStates.Infected.Value
    end)
    return ok and v or 0
end

function L.rescueTeammate.hasZombie(pos, range)
    for _, v in workspace:GetDescendants() do
        if v:IsA("Model") and v.Name == "m_Zombie" then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - pos).Magnitude <= range then
                return true
            end
        end
    end
    return false
end

function L.rescueTeammate.loop()
    while L.rescueTeammate.enabled do
        task.wait(0.25)

        if L.rescueTeammate.busy then
            continue
        end

        for _, p in Players:GetPlayers() do
            if p == LocalPlayer then continue end
            if not L.rescueTeammate.enabled then break end

            if L.rescueTeammate.inf[p.Name] == nil then
                L.rescueTeammate.inf[p.Name] = L.rescueTeammate.getInf(p)
            end

            local need = false
            local why = ""

            if L.rescueTeammate.getPin(p) then
                need = true
                why = "被扑"
            else
                local cur = L.rescueTeammate.getInf(p)
                local last = L.rescueTeammate.inf[p.Name] or cur
                if cur > last and cur > 0 then
                    local tc = p.Character
                    local th = tc and L.rescueTeammate.getHRP(tc)
                    if th and L.rescueTeammate.hasZombie(th.Position, 2) then
                        need = true
                        why = "感染" .. mathFloor(cur) .. "%"
                    end
                end
                L.rescueTeammate.inf[p.Name] = cur
            end

            if not need then continue end

            L.rescueTeammate.busy = true
            L.rescueTeammate.inf[p.Name] = L.rescueTeammate.getInf(p)

            local mc = LocalPlayer.Character
            local mh = mc and L.rescueTeammate.getHRP(mc)
            if not mh then
                L.rescueTeammate.busy = false
                continue
            end
            local ori = mh.Position

            local tc = p.Character
            local th = tc and L.rescueTeammate.getHRP(tc)
            if not th then
                L.rescueTeammate.busy = false
                continue
            end

            pcall(function()
                mh.CFrame = cfNew(th.Position + v3new(0, 0.5, 0))
            end)

            local st = tick_()
            while L.rescueTeammate.enabled and tick_() - st < 6 do
                task.wait(0.2)
                if tick_() - st >= 0.8 then
                    if not L.rescueTeammate.getPin(p) then
                        local tc2 = p.Character
                        local th2 = tc2 and L.rescueTeammate.getHRP(tc2)
                        if th2 and not L.rescueTeammate.hasZombie(th2.Position, 2) then
                            break
                        end
                    end
                end
            end

            task.wait(0.15)
            local mc2 = LocalPlayer.Character
            local mh2 = mc2 and L.rescueTeammate.getHRP(mc2)
            if mh2 then
                pcall(function()
                    mh2.CFrame = cfNew(ori + v3new(0, 1, 0))
                end)
            end

            L.rescueTeammate.busy = false
            task.wait(0.5)
        end
    end
end

function L.rescueTeammate.start()
    if L.rescueTeammate.thread then return end
    L.rescueTeammate.enabled = true
    L.rescueTeammate.inf = {}
    L.rescueTeammate.busy = false
    L.rescueTeammate.thread = task.spawn(L.rescueTeammate.loop)
    Library:Notify(TranslateText("🆘 传送救援已开启"), 2)
end

function L.rescueTeammate.stop()
    L.rescueTeammate.enabled = false
    if L.rescueTeammate.thread then
        task.cancel(L.rescueTeammate.thread)
        L.rescueTeammate.thread = nil
    end
    L.rescueTeammate.inf = {}
    L.rescueTeammate.busy = false
    Library:Notify(TranslateText("🆘 传送救援已关闭"), 2)
end


L.elbowZombies = { enabled = false, thread = nil, connections = {}, currentWeapon = nil, WEAPON_LIST = {"Axe", "Baguette", "Pickaxe"}, DETECT_RANGE = 6, CHECK_INTERVAL = 0.3 }

function L.elbowZombies.isZombie(model)
    if not model:IsA("Model") then return false end
    return model:FindFirstChild("HumanoidRootPart") ~= nil
end

function L.elbowZombies.getZombiesInRange()
    local char = LocalPlayer.Character
    if not char then return {} end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local pos = root.Position
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return {} end
    local list = {}
    for _, z in zombiesFolder:GetChildren() do
        if L.elbowZombies.isZombie(z) then
            local hrp = z:FindFirstChild("HumanoidRootPart") or z:FindFirstChild("Torso")
            if hrp and (hrp.Position - pos).Magnitude <= L.elbowZombies.DETECT_RANGE then
                table.insert(list, z)
            end
        end
    end
    return list
end

function L.elbowZombies.getBestWeapon()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, name in L.elbowZombies.WEAPON_LIST do
        local tool = backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

function L.elbowZombies.equipWeapon(weapon)
    if not weapon then return end
    local char = LocalPlayer.Character
    if not char then return end
    if weapon.Parent ~= char then
        weapon.Parent = char
        task.wait(0.02)
    end
end

function L.elbowZombies.unequipWeapon(weapon)
    if not weapon then return end
    if weapon.Parent == LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Backpack
    end
end

function L.elbowZombies.elbowZombie(zombie)
    local hrp = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso")
    if not hrp then return end
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not weapon then return end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return end
    pcall(function()
        remote:FireServer("BraceBlock")
        remote:FireServer("StopBraceBlock")
        remote:FireServer("FeedbackStun", zombie, hrp.Position)
    end)
end

function L.elbowZombies.elbowAll(zombies)
    for _, z in zombies do
        L.elbowZombies.elbowZombie(z)
    end
end

function L.elbowZombies.mainLoop()
    while L.elbowZombies.enabled do
        local zombies = L.elbowZombies.getZombiesInRange()
        if #zombies > 0 then
            local weapon = L.elbowZombies.getBestWeapon()
            if weapon then
                L.elbowZombies.equipWeapon(weapon)
                L.elbowZombies.currentWeapon = weapon
            end
            L.elbowZombies.elbowAll(zombies)
        else
            if L.elbowZombies.currentWeapon and L.elbowZombies.currentWeapon.Parent == LocalPlayer.Character then
                L.elbowZombies.unequipWeapon(L.elbowZombies.currentWeapon)
            end
            L.elbowZombies.currentWeapon = nil
        end
        task.wait(L.elbowZombies.CHECK_INTERVAL)
    end
end

function L.elbowZombies.start()
    if L.elbowZombies.thread then return end
    L.elbowZombies.enabled = true
    L.elbowZombies.thread = task.spawn(L.elbowZombies.mainLoop)
end

function L.elbowZombies.stop()
    L.elbowZombies.enabled = false
    if L.elbowZombies.thread then
        task.cancel(L.elbowZombies.thread)
        L.elbowZombies.thread = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, name in L.elbowZombies.WEAPON_LIST do
            local tool = char:FindFirstChild(name)
            if tool then tool.Parent = LocalPlayer.Backpack end
        end
    end
    L.elbowZombies.currentWeapon = nil
end

L.pushBarrelProtect = { enabled = false, size = 10, normalForce = 45, normalUp = 15, slideForce = 85, verticalThreshold = 3, thread = nil }

function L.pushBarrelProtect.getRadii()
    local factor = L.pushBarrelProtect.size / 10
    local h = mathClamp(16 * factor, 5, 25)
    local v = mathClamp(5 * factor, 2, 8)
    return h, v
end

function L.pushBarrelProtect.isBarrel(zombie)
    return zombie:GetAttribute("Type") == "Barrel" or zombie:FindFirstChild("Barrel")
end

function L.pushBarrelProtect.getActiveBarrels()
    local barrels = {}
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return barrels end
    for _, z in zombiesFolder:GetChildren() do
        if z:IsA("Model") and L.pushBarrelProtect.isBarrel(z) then
            local root = z:FindFirstChild("HumanoidRootPart") or z:FindFirstChild("Torso") or z:FindFirstChild("Head")
            if root then
                table.insert(barrels, root.Position)
            end
        end
    end
    return barrels
end

function L.pushBarrelProtect.isPointInEllipsoid(point, center, hR, vR)
    local dx = point.X - center.X
    local dy = point.Y - center.Y
    local dz = point.Z - center.Z
    return (dx*dx + dz*dz) / (hR*hR) + (dy*dy) / (vR*vR) < 1
end

function L.pushBarrelProtect.applyPush()
    if not L.pushBarrelProtect.enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local playerPos = root.Position
    local hRadius, vRadius = L.pushBarrelProtect.getRadii()
    local centers = L.pushBarrelProtect.getActiveBarrels()
    for _, center in centers do
        if L.pushBarrelProtect.isPointInEllipsoid(playerPos, center, hRadius, vRadius) then
            local delta = playerPos - center
            local absDeltaY = mathAbs(delta.Y)
            if absDeltaY > L.pushBarrelProtect.verticalThreshold then
                local horizontalDir = v3new(delta.X, 0, delta.Z)
                if horizontalDir.Magnitude < 0.001 then
                    horizontalDir = v3new(1, 0, 0)
                else
                    horizontalDir = horizontalDir.Unit
                end
                local horizontalVel = horizontalDir * L.pushBarrelProtect.slideForce
                root.AssemblyLinearVelocity = v3new(horizontalVel.X, root.AssemblyLinearVelocity.Y, horizontalVel.Z)
            else
                local dir = delta.Unit
                if dir.Magnitude < 0.001 then dir = v3new(1, 0, 0) end
                root.AssemblyLinearVelocity = dir * L.pushBarrelProtect.normalForce + v3new(0, L.pushBarrelProtect.normalUp, 0)
            end
            break
        end
    end
end

function L.pushBarrelProtect.loop()
    while L.pushBarrelProtect.enabled do
        L.pushBarrelProtect.applyPush()
        task.wait(0.05)
    end
end

function L.pushBarrelProtect.start()
    if L.pushBarrelProtect.thread then return end
    L.pushBarrelProtect.enabled = true
    L.pushBarrelProtect.thread = task.spawn(L.pushBarrelProtect.loop)
end

function L.pushBarrelProtect.stop()
    L.pushBarrelProtect.enabled = false
    if L.pushBarrelProtect.thread then
        task.cancel(L.pushBarrelProtect.thread)
        L.pushBarrelProtect.thread = nil
    end
end


L.autoHelp = { enabled = false, thread = nil }

function L.autoHelp.getHealth()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health or 0
end

function L.autoHelp.getMaxHealth()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.MaxHealth or 100
end

function L.autoHelp.triggerHelp()
    local char = LocalPlayer.Character
    if not char then return false end
    local tv = char:FindFirstChild("TriggerVoice")
    if tv and tv:IsA("RemoteEvent") then
        pcall(function() tv:FireServer("CalloutGeneral", "Help") end)
        return true
    end
    return false
end

function L.autoHelp.loop()
    while L.autoHelp.enabled do
        task.wait(3)
        local hp = L.autoHelp.getHealth()
        local maxHp = L.autoHelp.getMaxHealth()
        local pct = hp / maxHp * 100
        if pct >= 80 then continue end
        L.autoHelp.triggerHelp()
    end
end

function L.autoHelp.start()
    if L.autoHelp.thread then return end
    L.autoHelp.enabled = true
    L.autoHelp.thread = task.spawn(L.autoHelp.loop)
end

function L.autoHelp.stop()
    L.autoHelp.enabled = false
    if L.autoHelp.thread then
        task.cancel(L.autoHelp.thread)
        L.autoHelp.thread = nil
    end
end

L.playerHighlights = {}
L.playerNameTags = {}
L.playerDots = {}
L.playerHealthTags = {}
L.espPlayerEnabled = false
L.espShowNames = false
L.espShowHealth = false
L.espTeamCheckPlayer = false
L.playerESPRefreshThread = nil
L.playerESPCharAddedConn = nil

function L.getPlayerTeam(player)
    if player.Team then return player.Team end
    local teamAttr = player:GetAttribute("Team")
    if teamAttr then return teamAttr end
    local char = player.Character
    if char then
        local teamTag = char:FindFirstChild("TeamTag") or char:FindFirstChild("Team")
        if teamTag then return teamTag.Value end
    end
    return nil
end

function L.isSameTeam(player)
    if not L.espTeamCheckPlayer then return false end
    local myTeam = L.getPlayerTeam(LocalPlayer)
    local theirTeam = L.getPlayerTeam(player)
    if myTeam and theirTeam then
        return myTeam == theirTeam
    end
    return false
end

function L.getColorsForPlayer(player)
    if not L.espTeamCheckPlayer then
        return {
            highlight = c3rgb(255, 255, 255),
            dot       = c3rgb(160, 160, 160),
            name      = c3rgb(255, 255, 255)
        }
    end
    if L.isSameTeam(player) then
        return {
            highlight = c3rgb(100, 150, 255),
            dot       = c3rgb(0, 30, 180),
            name      = c3rgb(100, 150, 255)
        }
    else
        return {
            highlight = c3rgb(255, 100, 100),
            dot       = c3rgb(180, 0, 0),
            name      = c3rgb(255, 100, 100)
        }
    end
end

function L.destroyPlayerComponents(player)
    if L.playerHighlights[player] then
        L.playerHighlights[player]:Destroy()
        L.playerHighlights[player] = nil
    end
    if L.playerNameTags[player] then
        L.playerNameTags[player]:Destroy()
        L.playerNameTags[player] = nil
    end
    if L.playerDots[player] then
        L.playerDots[player]:Destroy()
        L.playerDots[player] = nil
    end
    if L.playerHealthTags[player] then
        L.playerHealthTags[player]:Destroy()
        L.playerHealthTags[player] = nil
    end
end

function L.updatePlayerESP(player)
    if not L.espPlayerEnabled then
        L.destroyPlayerComponents(player)
        return
    end
    local char = player.Character
    if not char or char == LocalPlayer.Character then
        L.destroyPlayerComponents(player)
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local colors = L.getColorsForPlayer(player)

    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position or v3new()
    local dist = (hrp.Position - myPos).Magnitude
    local MAX_DIST = 300
    local near = dist <= MAX_DIST

    if near then
        if not L.playerHighlights[player] then
            local hl = Instance.new("Highlight")
            hl.Adornee = char
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 0.3
            hl.OutlineTransparency = 0.3
            hl.Parent = char
            L.playerHighlights[player] = hl
        end
        L.playerHighlights[player].FillColor = colors.highlight
        L.playerHighlights[player].OutlineColor = colors.highlight
    else
        if L.playerHighlights[player] then
            L.playerHighlights[player]:Destroy()
            L.playerHighlights[player] = nil
        end
    end


    if not L.playerDots[player] then
        local dotGui = Instance.new("BillboardGui")
        dotGui.Name = "PlayerDot"
        dotGui.Size = UDim2.new(0, 5, 0, 5)
        dotGui.StudsOffset = v3new(0, 0, 0)
        dotGui.AlwaysOnTop = true
        dotGui.Adornee = hrp
        dotGui.Parent = char
        local dotFrame = Instance.new("Frame")
        dotFrame.Size = UDim2.new(1, 0, 1, 0)
        dotFrame.BackgroundColor3 = colors.dot
        dotFrame.BackgroundTransparency = 0
        dotFrame.BorderSizePixel = 0
        dotFrame.Parent = dotGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dotFrame
        L.playerDots[player] = dotGui
    else
        local dotGui = L.playerDots[player]
        if dotGui.Adornee ~= hrp then dotGui.Adornee = hrp end
        local dotFrame = dotGui:FindFirstChildWhichIsA("Frame")
        if dotFrame then dotFrame.BackgroundColor3 = colors.dot end
        if not dotGui.Parent or not dotGui.Parent:IsDescendantOf(char) then dotGui.Parent = char end
    end


    if L.espShowNames then
        if not L.playerNameTags[player] then
            local nameGui = Instance.new("BillboardGui")
            nameGui.Name = "PlayerNameTag"
            nameGui.Size = UDim2.new(0, 150, 0, 30)
            nameGui.StudsOffset = v3new(0, -2.5, 0)
            nameGui.AlwaysOnTop = true
            nameGui.Adornee = hrp
            nameGui.Parent = char
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = colors.name
            label.TextSize = 11
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = c3rgb(0, 0, 0)
            label.Parent = nameGui
            L.playerNameTags[player] = nameGui
        else
            local nameGui = L.playerNameTags[player]
            if nameGui.Adornee ~= hrp then nameGui.Adornee = hrp end
            if not nameGui.Parent or not nameGui.Parent:IsDescendantOf(char) then nameGui.Parent = char end
            local label = nameGui:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = player.Name
                label.TextColor3 = colors.name
            end
        end
    else
        if L.playerNameTags[player] then
            L.playerNameTags[player]:Destroy()
            L.playerNameTags[player] = nil
        end
    end


    if L.espShowHealth then
        if not L.playerHealthTags[player] then
            local healthGui = Instance.new("BillboardGui")
            healthGui.Name = "PlayerHealthTag"
            healthGui.Size = UDim2.new(0, 100, 0, 30)
            healthGui.StudsOffset = v3new(-2.5, 1.5, 0)
            healthGui.AlwaysOnTop = true
            local head = char:FindFirstChild("Head") or hrp
            healthGui.Adornee = head
            healthGui.Parent = char
            local healthLabel = Instance.new("TextLabel")
            healthLabel.Size = UDim2.new(1, 0, 1, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.TextSize = 11
            healthLabel.Font = Enum.Font.GothamBold
            healthLabel.TextStrokeTransparency = 0
            healthLabel.TextStrokeColor3 = c3rgb(0, 0, 0)
            healthLabel.Parent = healthGui
            L.playerHealthTags[player] = healthGui
        end
        local healthGui = L.playerHealthTags[player]
        local head = char:FindFirstChild("Head") or hrp
        if healthGui.Adornee ~= head then healthGui.Adornee = head end
        if not healthGui.Parent or not healthGui.Parent:IsDescendantOf(char) then healthGui.Parent = char end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local healthPercent = hum and mathFloor(hum.Health / hum.MaxHealth * 100) or 100
        local healthLabel = healthGui:FindFirstChildOfClass("TextLabel")
        if healthLabel then
            healthLabel.Text = healthPercent .. "%"
            healthLabel.TextColor3 = colors.name
        end
    else
        if L.playerHealthTags[player] then
            L.playerHealthTags[player]:Destroy()
            L.playerHealthTags[player] = nil
        end
    end
end

function L.refreshAllPlayers()
    for _, player in Players:GetPlayers() do
        L.updatePlayerESP(player)
    end
end


function L.startPlayerESPRefresh()
    if L.playerESPRefreshThread then return end
    L.playerESPRefreshThread = task.spawn(function()
        while L.espPlayerEnabled do
            task.wait(0.2)
            for _, player in Players:GetPlayers() do
                L.updatePlayerESP(player)
            end
        end
        L.playerESPRefreshThread = nil
    end)
end

function L.stopPlayerESPRefresh()
    if L.playerESPRefreshThread then
        task.cancel(L.playerESPRefreshThread)
        L.playerESPRefreshThread = nil
    end
end


local function setupPlayerESPEvents()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.2)
            if L.espPlayerEnabled then L.updatePlayerESP(player) end
        end)
        player.CharacterRemoving:Connect(function()
            L.destroyPlayerComponents(player)
        end)
        if L.espPlayerEnabled then L.updatePlayerESP(player) end
    end)
    Players.PlayerRemoving:Connect(function(player)
        L.destroyPlayerComponents(player)
    end)
    L.onCharacterAdded(function()
        task.wait(0.5)
        if L.espPlayerEnabled then L.refreshAllPlayers() end
    end)
end
setupPlayerESPEvents()


L.infectionBillboards = {}
L.infectionEnabled = false
L.infectionUpdateConn = nil
L.jobBillboards = {}
L.jobEnabled = false
L.jobUpdateConn = nil

function L.createInfectionUI(player)
    if not player or player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    if L.infectionBillboards[player] then
        L.infectionBillboards[player]:Destroy()
        L.infectionBillboards[player] = nil
    end
    local bill = Instance.new("BillboardGui")
    bill.Name = "PlayerInfectionDisplay"
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.StudsOffset = v3new(-2.5, 0.5, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 150
    bill.Adornee = head
    bill.Parent = char
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = TranslateText("感染: 0%")
    label.TextColor3 = c3rgb(255, 200, 0)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = c3rgb(0,0,0)
    label.Parent = bill
    L.infectionBillboards[player] = bill
    return bill
end

function L.removeInfectionUI(player)
    local bill = L.infectionBillboards[player]
    if bill then bill:Destroy() end
    L.infectionBillboards[player] = nil
end

function L.updateAllInfection()
    if not L.infectionEnabled then return end
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char.Parent then
            L.removeInfectionUI(player)
            continue
        end
        local head = char:FindFirstChild("Head")
        if not head then
            L.removeInfectionUI(player)
            continue
        end
        local bill = L.infectionBillboards[player]
        if not bill or not bill.Parent then
            bill = L.createInfectionUI(player)
        end
        if bill then
            local infection = L.getInfectionForPlayer(player)
            local label = bill:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = strFormat(InterfaceLanguage == "English" and "Infection: %d%%" or "感染: %d%%", infection)
                if infection >= 70 then
                    label.TextColor3 = c3rgb(255, 50, 50)
                elseif infection >= 30 then
                    label.TextColor3 = c3rgb(255, 200, 0)
                else
                    label.TextColor3 = c3rgb(0, 255, 0)
                end
            end
            if bill.Adornee ~= head then bill.Adornee = head end
        end
    end
    for player, _ in L.infectionBillboards do
        if not player or not player.Parent then L.removeInfectionUI(player) end
    end
end

function L.startInfectionUpdating()
    if L.infectionUpdateConn then return end
    local acc = 0
    L.infectionUpdateConn = RunService.RenderStepped:Connect(function(dt)
        acc = acc + dt
        if acc >= 0.1 then
            acc = 0
            L.updateAllInfection()
        end
    end)
    L.infectionPlayerAddedConn = Players.PlayerAdded:Connect(function(pl)
        if L.infectionEnabled and pl ~= LocalPlayer then
            task.wait(0.5)
            L.createInfectionUI(pl)
        end
    end)
    L.infectionPlayerRemovingConn = Players.PlayerRemoving:Connect(L.removeInfectionUI)
    for _, pl in Players:GetPlayers() do
        if pl ~= LocalPlayer then L.createInfectionUI(pl) end
    end
end

function L.getInfectionForPlayer(player)
    if not player then return 0 end
    local infection = 0
    pcall(function()
        local wsPlayers = workspace:FindFirstChild("Players")
        if wsPlayers then
            local folder = wsPlayers:FindFirstChild(player.Name)
            if folder and folder:FindFirstChild("UserStates") then
                local val = folder.UserStates:FindFirstChild("Infected")
                if val then
                    infection = tonumber(val.Value) or 0
                    return
                end
            end
        end
        if player:FindFirstChild("UserStates") then
            local val = player.UserStates:FindFirstChild("Infected")
            if val then infection = tonumber(val.Value) or 0 end
        end
    end)
    return infection
end


function L.getPlayerClass(player)
    if not player then return "未知" end

    local class = nil
    local char = player.Character


    class = player:GetAttribute("CurrentClass")
    if not class or class == "" then
        if char then
            class = char:GetAttribute("CurrentClass")
        end
    end


    local classMap = {
        ["Officer"] = "军官",
        ["LineInfantry"] = "线列",
        ["Sapper"] = "工兵",
        ["Surgeon"] = "医生",
        ["Chaplain"] = "牧师",
        ["Musician"] = "乐手",
        ["Seaman"] = "水手",
        ["Lancer"] = "枪骑兵",
        ["Artillerist"] = "炮兵",
    }

    if class and classMap[class] then
        return classMap[class]
    end


    if char then
        if char:FindFirstChild("MedicalSupplies") or char:FindFirstChild("Meter") then
            return "医生"
        elseif char:FindFirstChild("Blessing") then
            return "牧师"
        elseif char:FindFirstChild("Hammer") or char:FindFirstChild("Pickaxe") or char:FindFirstChild("Axe") then
            return "工兵"
        elseif char:FindFirstChild("Sabre") then
            return "军官"
        elseif char:FindFirstChild("Musket") or char:FindFirstChild("Carbine") then
            return "线列"
        elseif char:FindFirstChild("Fife") or char:FindFirstChild("Drum") then
            return "乐手"
        end
    end

    return "这个是gay"
end


function L.createJobUI(player)
    if not player or player == LocalPlayer then return nil end
    local char = player.Character
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    if L.jobBillboards[player] then
        L.jobBillboards[player]:Destroy()
        L.jobBillboards[player] = nil
    end
    local bill = Instance.new("BillboardGui")
    bill.Name = "PlayerJobDisplay"
    bill.Size = UDim2.new(0, 100, 0, 20)

    bill.StudsOffset = v3new(-2.5, -0.5, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 150
    bill.Adornee = head
    bill.Parent = char
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = TranslateText(L.getPlayerClass(player))
    label.TextColor3 = c3rgb(180, 0, 255)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = c3rgb(0,0,0)
    label.Parent = bill
    L.jobBillboards[player] = bill
    return bill
end


function L.removeJobUI(player)
    local bill = L.jobBillboards[player]
    if bill then bill:Destroy() end
    L.jobBillboards[player] = nil
end


function L.updateAllJob()
    if not L.jobEnabled then return end
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char.Parent then
            L.removeJobUI(player)
            continue
        end
        local head = char:FindFirstChild("Head")
        if not head then
            L.removeJobUI(player)
            continue
        end
        local bill = L.jobBillboards[player]
        if not bill or not bill.Parent then
            bill = L.createJobUI(player)
        end
        if bill then
            local label = bill:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = TranslateText(L.getPlayerClass(player))
            end
            if bill.Adornee ~= head then bill.Adornee = head end
        end
    end

    for player, _ in L.jobBillboards do
        if not player or not player.Parent then L.removeJobUI(player) end
    end
end


function L.startJobUpdating()
    if L.jobUpdateConn then return end
    L.jobEnabled = true
    local acc = 0
    L.jobUpdateConn = RunService.RenderStepped:Connect(function(dt)
        acc = acc + dt
        if acc >= 0.1 then
            acc = 0
            L.updateAllJob()
        end
    end)
    L.jobPlayerAddedConn = Players.PlayerAdded:Connect(function(pl)
        if L.jobEnabled and pl ~= LocalPlayer then
            task.wait(0.5)
            L.createJobUI(pl)
        end
    end)
    L.jobPlayerRemovingConn = Players.PlayerRemoving:Connect(L.removeJobUI)
    for _, pl in Players:GetPlayers() do
        if pl ~= LocalPlayer then L.createJobUI(pl) end
    end
end


function L.stopJobUpdating()
    L.jobEnabled = false
    if L.jobUpdateConn then
        L.jobUpdateConn:Disconnect()
        L.jobUpdateConn = nil
    end
    if L.jobPlayerAddedConn then
        L.jobPlayerAddedConn:Disconnect()
        L.jobPlayerAddedConn = nil
    end
    if L.jobPlayerRemovingConn then
        L.jobPlayerRemovingConn:Disconnect()
        L.jobPlayerRemovingConn = nil
    end
    for _, bill in L.jobBillboards do
        if bill then bill:Destroy() end
    end
    L.jobBillboards = {}
end

function L.stopInfectionUpdating()
    if L.infectionUpdateConn then
        L.infectionUpdateConn:Disconnect()
        L.infectionUpdateConn = nil
    end
    if L.infectionPlayerAddedConn then
        L.infectionPlayerAddedConn:Disconnect()
        L.infectionPlayerAddedConn = nil
    end
    if L.infectionPlayerRemovingConn then
        L.infectionPlayerRemovingConn:Disconnect()
        L.infectionPlayerRemovingConn = nil
    end
    for _, bill in L.infectionBillboards do
        if bill then bill:Destroy() end
    end
    L.infectionBillboards = {}
end

L.bulletDisplay = { enabled = false, billboardGui = nil, screenGui = nil, billLabel = nil, screenLabel = nil, connection = nil, cameraConn = nil }

function L.bulletDisplay.isFirstPerson()
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return false end
    return (cam.CFrame.Position - head.Position).Magnitude < 0.7
end

function L.bulletDisplay.createUI()
    if L.bulletDisplay.billboardGui and L.bulletDisplay.screenGui then return end
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "BulletDisplay_Billboard"
    bill.Size = UDim2.new(0, 100, 0, 30)
    bill.StudsOffset = v3new(-3, 0.3, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 50
    bill.Adornee = head
    bill.Parent = char
    bill.Enabled = false
    local billLabel = Instance.new("TextLabel")
    billLabel.Size = UDim2.new(1, 0, 1, 0)
    billLabel.BackgroundTransparency = 1
    billLabel.Text = TranslateText("子弹: 0")
    billLabel.TextColor3 = c3rgb(0, 255, 0)
    billLabel.TextSize = 16
    billLabel.Font = Enum.Font.GothamBold
    billLabel.TextStrokeTransparency = 0.3
    billLabel.TextStrokeColor3 = c3rgb(0, 0, 0)
    billLabel.Parent = bill
    local screen = Instance.new("ScreenGui")
    screen.Name = "BulletDisplay_Screen"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screen.Enabled = false
    local screenLabel = Instance.new("TextLabel")
    screenLabel.Size = UDim2.new(0, 120, 0, 40)
    screenLabel.Position = UDim2.new(0.02, 0, 0.48, 0)
    screenLabel.AnchorPoint = v2new(0, 0)
    screenLabel.BackgroundTransparency = 1
    screenLabel.Text = TranslateText("子弹: 0")
    screenLabel.TextColor3 = c3rgb(0, 255, 0)
    screenLabel.TextSize = 20
    screenLabel.Font = Enum.Font.GothamBold
    screenLabel.TextStrokeTransparency = 0.3
    screenLabel.TextStrokeColor3 = c3rgb(0, 0, 0)
    screenLabel.Parent = screen
    L.bulletDisplay.billboardGui = bill
    L.bulletDisplay.screenGui = screen
    L.bulletDisplay.billLabel = billLabel
    L.bulletDisplay.screenLabel = screenLabel
end

function L.bulletDisplay.destroyUI()
    if L.bulletDisplay.billboardGui then L.bulletDisplay.billboardGui:Destroy() end
    if L.bulletDisplay.screenGui then L.bulletDisplay.screenGui:Destroy() end
    L.bulletDisplay.billboardGui = nil
    L.bulletDisplay.screenGui = nil
    L.bulletDisplay.billLabel = nil
    L.bulletDisplay.screenLabel = nil
end

function L.bulletDisplay.updateVisibility()
    if not L.bulletDisplay.enabled then return end
    if not L.bulletDisplay.billboardGui or not L.bulletDisplay.screenGui then return end
    local fp = L.bulletDisplay.isFirstPerson()
    L.bulletDisplay.billboardGui.Enabled = not fp
    L.bulletDisplay.screenGui.Enabled = fp
end

L.bulletDisplay.isGun = L.sharedIsGun

function L.bulletDisplay.getBullets()
    local char = LocalPlayer.Character
    if not char then return 0 end
    local tool = char:FindFirstChildOfClass("Tool")
    local bullets = 0
    if tool and L.bulletDisplay.isGun(tool) then
        local shots = tool:FindFirstChild("ShotsLoaded")
        if shots and (shots:IsA("IntValue") or shots:IsA("NumberValue")) then
            bullets = shots.Value
        end
    else
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            local maxBullets = 0
            for _, t in backpack:GetChildren() do
                if t:IsA("Tool") and L.bulletDisplay.isGun(t) then
                    local shots = t:FindFirstChild("ShotsLoaded")
                    if shots and (shots:IsA("IntValue") or shots:IsA("NumberValue")) then
                        local b = shots.Value
                        if b > maxBullets then maxBullets = b end
                    end
                end
            end
            bullets = maxBullets
        end
    end
    return bullets
end

function L.bulletDisplay.updateLabels()
    if not L.bulletDisplay.enabled then return end
    local bullets = L.bulletDisplay.getBullets()
    local text = (InterfaceLanguage == "English" and "Bullets: " or "子弹: ") .. tostring(bullets)
    local color = bullets > 0 and c3rgb(0, 255, 0) or c3rgb(255, 0, 0)
    if L.bulletDisplay.billLabel then
        L.bulletDisplay.billLabel.Text = text
        L.bulletDisplay.billLabel.TextColor3 = color
    end
    if L.bulletDisplay.screenLabel then
        L.bulletDisplay.screenLabel.Text = text
        L.bulletDisplay.screenLabel.TextColor3 = color
    end
end

function L.bulletDisplay.update()
    if not L.bulletDisplay.enabled then
        if L.bulletDisplay.connection then L.bulletDisplay.connection:Disconnect() end
        if L.bulletDisplay.cameraConn then L.bulletDisplay.cameraConn:Disconnect() end
        return
    end
    local char = LocalPlayer.Character
    if not char then
        L.bulletDisplay.destroyUI()
        L.bulletDisplay.createUI()
        return
    end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if L.bulletDisplay.billboardGui and L.bulletDisplay.billboardGui.Adornee ~= head then
        L.bulletDisplay.destroyUI()
        L.bulletDisplay.createUI()
    end
    if not L.bulletDisplay.billboardGui or not L.bulletDisplay.screenGui then
        L.bulletDisplay.createUI()
    end
    L.bulletDisplay.updateLabels()
    L.bulletDisplay.updateVisibility()
end

function L.bulletDisplay.start()
    if L.bulletDisplay.enabled then return end
    L.bulletDisplay.enabled = true
    L.bulletDisplay.createUI()
    if L.bulletDisplay.connection then L.bulletDisplay.connection:Disconnect() end
    L.bulletDisplay.connection = RunService.Heartbeat:Connect(L.bulletDisplay.update)
    if L.bulletDisplay.cameraConn then L.bulletDisplay.cameraConn:Disconnect() end
    L.bulletDisplay.cameraConn = RunService.RenderStepped:Connect(function()
        if L.bulletDisplay.enabled then L.bulletDisplay.updateVisibility() end
    end)
    L.bulletDisplay.update()
end

function L.bulletDisplay.stop()
    L.bulletDisplay.enabled = false
    if L.bulletDisplay.connection then L.bulletDisplay.connection:Disconnect() end
    if L.bulletDisplay.cameraConn then L.bulletDisplay.cameraConn:Disconnect() end
    L.bulletDisplay.destroyUI()
end


L.Tracer = { enabled = false, conn = nil, tracking = {} }
function L.Tracer.toggle(v)
    L.Tracer.enabled = v
    if v then
        if L.Tracer.conn then L.Tracer.conn:Disconnect() end
        L.Tracer.conn = workspace.DescendantAdded:Connect(function(desc)
            if not L.Tracer.enabled then return end
            if not desc:IsA("PointLight") then return end
            if L.Tracer.tracking[desc] then return end
            local parent = desc.Parent
            if not parent or not parent:IsA("BasePart") then return end
            local pos1 = parent.Position
            L.Tracer.tracking[desc] = { obj = parent, pos1 = pos1 }
            task.spawn(function()
                task.wait(0.1)
                local data = L.Tracer.tracking[desc]
                if not data then return end
                local obj = data.obj
                if not obj or not obj.Parent or not desc.Parent then
                    L.Tracer.tracking[desc] = nil
                    return
                end
                local pos2 = obj.Position
                local dir = pos2 - pos1
                if dir.Magnitude < 0.3 then L.Tracer.tracking[desc] = nil; return end
                dir = dir.Unit
                L.Tracer.tracking[desc] = nil
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                local blacklist = { obj }
                local root = obj
                while root.Parent and not root.Parent:IsA("Workspace") do
                    root = root.Parent
                    table.insert(blacklist, root)
                end
                params.FilterDescendantsInstances = blacklist
                local result = workspace:Raycast(pos2 + dir * 2, dir * 500, params)
                local hitPos = result and result.Position or (pos1 + dir * 500)
                local beamDir = hitPos - pos1
                local dist = beamDir.Magnitude
                if dist < 0.1 then return end
                local beam = Instance.new("Part")
                beam.Name = "_Tracer"
                beam.Size = v3new(0.05, 0.05, dist)
                beam.Color = c3rgb(255, 255, 0)
                beam.Material = Enum.Material.Neon
                beam.Anchored = true
                beam.CanCollide = false
                beam.CFrame = CFrame.lookAt(pos1 + beamDir * 0.5, hitPos)
                beam.Parent = workspace
                local st = tick_()
                while tick_() - st < 3 and beam.Parent do
                    beam.Transparency = (tick_() - st) / 3
                    task.wait(0.05)
                end
                pcall(beam.Destroy, beam)
            end)
        end)
    else
        if L.Tracer.conn then L.Tracer.conn:Disconnect(); L.Tracer.conn = nil end
        L.Tracer.tracking = {}
    end
end


L.cannonSupplies = { enabled = false, highlights = {} }

function L.cannonSupplies.createHighlights()
    L.cannonSupplies.removeHighlights()
    local supplies = workspace:FindFirstChild("Vardohus Fortress")
    if supplies then
        supplies = supplies:FindFirstChild("Modes")
        if supplies then
            supplies = supplies:FindFirstChild("Objective")
            if supplies then
                supplies = supplies:FindFirstChild("CannonSupplies")
            end
        end
    end
    if not supplies then return end
    for _, folder in supplies:GetChildren() do
        if folder:IsA("Folder") then
            local swab = folder:FindFirstChild("Swab")
            local roundshot = folder:FindFirstChild("12 lb. Roundshots")
            if swab then
                local hl = Instance.new("Highlight")
                hl.FillColor = c3rgb(0, 255, 255)
                hl.OutlineColor = c3rgb(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.3
                hl.Parent = swab
                table.insert(L.cannonSupplies.highlights, hl)
            end
            if roundshot then
                local hl = Instance.new("Highlight")
                hl.FillColor = c3rgb(0, 255, 255)
                hl.OutlineColor = c3rgb(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.3
                hl.Parent = roundshot
                table.insert(L.cannonSupplies.highlights, hl)
            end
        end
    end
end

function L.cannonSupplies.removeHighlights()
    for _, hl in L.cannonSupplies.highlights do
        if hl and hl.Parent then hl:Destroy() end
    end
    L.cannonSupplies.highlights = {}
end

function L.cannonSupplies.toggle(state)
    L.cannonSupplies.enabled = state
    if state then L.cannonSupplies.createHighlights() else L.cannonSupplies.removeHighlights() end
end


L.killSound = { selectedId = "5700183626", volume = 7, enabled = false, thread = nil, lastCount = 0 }

function L.killSound.getCurrentCount()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local kills = leaderstats:FindFirstChild("Kills")
        if kills and (kills:IsA("IntValue") or kills:IsA("NumberValue")) then
            return kills.Value
        end
    end
    return 0
end

function L.killSound.play()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. L.killSound.selectedId
    sound.Volume = L.killSound.volume / 10
    sound.Parent = workspace
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    task.delay(0.5, function() if sound and sound.Parent then sound:Destroy() end end)
end

function L.killSound.loop()
    while L.killSound.enabled do
        local cur = L.killSound.getCurrentCount()
        if cur > L.killSound.lastCount then
            for _ = 1, cur - L.killSound.lastCount do L.killSound.play() end
            L.killSound.lastCount = cur
        elseif cur < L.killSound.lastCount then
            L.killSound.lastCount = cur
        end
        task.wait(0.1)
    end
end

function L.killSound.start()
    if L.killSound.thread then return end
    L.killSound.enabled = true
    L.killSound.lastCount = L.killSound.getCurrentCount()
    L.killSound.thread = task.spawn(L.killSound.loop)
end

function L.killSound.stop()
    L.killSound.enabled = false
    if L.killSound.thread then task.cancel(L.killSound.thread); L.killSound.thread = nil end
end

L.pingDisplay = { gui = nil, label = nil, conn = nil }

function L.pingDisplay.start()
    if L.pingDisplay.gui then return end
    L.pingDisplay.gui = Instance.new("ScreenGui")
    L.pingDisplay.gui.Name = "PingDisplay"
    L.pingDisplay.gui.ResetOnSpawn = false
    L.pingDisplay.gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local f = Instance.new("Frame")
    f.Parent = L.pingDisplay.gui
    f.Size = UDim2.new(0, 120, 0, 30)
    f.Position = UDim2.new(1, -130, 0, 10)
    f.BackgroundColor3 = c3rgb(0, 0, 0)
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    local pingCorner = Instance.new("UICorner")
    pingCorner.CornerRadius = UDim.new(0, 8)
    pingCorner.Parent = f
    L.pingDisplay.label = Instance.new("TextLabel")
    L.pingDisplay.label.Parent = f
    L.pingDisplay.label.Size = UDim2.new(1, 0, 1, 0)
    L.pingDisplay.label.BackgroundTransparency = 1
    L.pingDisplay.label.Text = TranslateText("延迟: -- ms")
    L.pingDisplay.label.TextColor3 = c3rgb(255, 255, 255)
    L.pingDisplay.label.TextSize = 14
    L.pingDisplay.label.Font = Enum.Font.GothamBold
    L.pingDisplay.conn = RunService.Heartbeat:Connect(function()
        if not L.pingDisplay.gui then return end
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok and ping then
            L.pingDisplay.label.Text = (InterfaceLanguage == "English" and "Ping: " or "延迟: ") .. mathFloor(ping) .. " ms"
            if ping >= 120 then L.pingDisplay.label.TextColor3 = c3rgb(255, 80, 80)
            elseif ping >= 80 then L.pingDisplay.label.TextColor3 = c3rgb(255, 255, 0)
            else L.pingDisplay.label.TextColor3 = c3rgb(0, 255, 0) end
        end
    end)
end

function L.pingDisplay.stop()
    if L.pingDisplay.conn then L.pingDisplay.conn:Disconnect(); L.pingDisplay.conn = nil end
    if L.pingDisplay.gui then L.pingDisplay.gui:Destroy(); L.pingDisplay.gui = nil end
    L.pingDisplay.label = nil
end

L.infectionRemover = { enabled = false, conn = nil }

function L.infectionRemover.start()
    if L.infectionRemover.conn then return end
    L.infectionRemover.enabled = true
    L.infectionRemover.conn = RunService.Heartbeat:Connect(function()
        if not L.infectionRemover.enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local us = char:FindFirstChild("UserStates")
        if us then
            local inf = us:FindFirstChild("Infected")
            if inf then inf.Value = "0" end
        end
    end)
end

function L.infectionRemover.stop()
    L.infectionRemover.enabled = false
    if L.infectionRemover.conn then L.infectionRemover.conn:Disconnect(); L.infectionRemover.conn = nil end
end

L.bombRange = {
    enabled = false,
    spheres = {},
    conn = nil,
    warned = false,
    damageDisplay = nil,
}

local SPHERE_RADIUS = 10
local SPHERE_COLOR = c3rgb(255, 80, 80)
local SPHERE_TRANSPARENCY = 0.6
local DAMAGE_THRESHOLD = 20
local Y_OFFSET = -1.5

function L.bombRange.getBarrelZombies()
    local barrels = {}
    local zf = workspace:FindFirstChild("Zombies")
    if not zf then return barrels end
    for _, z in zf:GetChildren() do
        if z:IsA("Model") and z:GetAttribute("Type") == "Barrel" then
            table.insert(barrels, z)
        end
    end
    return barrels
end

function L.bombRange.getSphereCenter(zombie)
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso") or zombie:FindFirstChild("Head")
    if root then
        return root.Position + v3new(0, Y_OFFSET, 0)
    end
    return nil
end

function L.bombRange.createSphere(zombie)
    local center = L.bombRange.getSphereCenter(zombie)
    if not center then return nil end
    local s = Instance.new("Part")
    s.Name = "BombRangeSphere"
    s.Shape = Enum.PartType.Ball
    s.Size = v3new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2)
    s.Color = SPHERE_COLOR
    s.Material = Enum.Material.Neon
    s.Transparency = SPHERE_TRANSPARENCY
    s.Anchored = true
    s.CanCollide = false
    s.CanQuery = false
    s.CanTouch = false
    s.CastShadow = false
    s.Position = center
    s.Parent = workspace
    return s
end

function L.bombRange.updateSphere(sphere, zombie)
    if not sphere or not zombie then return end
    local center = L.bombRange.getSphereCenter(zombie)
    if center then
        sphere.Position = center
        if sphere.Size.X ~= SPHERE_RADIUS * 2 then
            sphere.Size = v3new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2)
        end
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - center).Magnitude
                if dist <= SPHERE_RADIUS then
                    sphere.Color = c3rgb(255, 0, 0)
                else
                    sphere.Color = c3rgb(120, 200, 120)
                end
            end
        end
    end
end

function L.bombRange.updateAllSpheres()
    if not L.bombRange.enabled then return end
    local barrels = L.bombRange.getBarrelZombies()
    local currentSet = {}
    for _, z in barrels do currentSet[z] = true end
    for zombie, sphere in L.bombRange.spheres do
        if not zombie.Parent or not currentSet[zombie] then
            if sphere then sphere:Destroy() end
            L.bombRange.spheres[zombie] = nil
        end
    end
    for _, zombie in barrels do
        if not L.bombRange.spheres[zombie] then
            local s = L.bombRange.createSphere(zombie)
            if s then L.bombRange.spheres[zombie] = s end
        else
            L.bombRange.updateSphere(L.bombRange.spheres[zombie], zombie)
        end
    end
end


function L.bombRange.getMinDistanceToBarrelCenter()
    local char = LocalPlayer.Character
    if not char then return mathHuge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return mathHuge end
    local minDist = mathHuge
    local barrels = L.bombRange.getBarrelZombies()
    for _, zombie in barrels do
        local center = L.bombRange.getSphereCenter(zombie)
        if center then
            local dist = (center - root.Position).Magnitude
            if dist < minDist then minDist = dist end
        end
    end
    return minDist
end

function L.bombRange.calculateDamage(distance)
    if distance >= SPHERE_RADIUS then return 0 end
    local factor = 1 - (distance / SPHERE_RADIUS)
    local damage = 10 + (100 - 10) * factor
    return mathFloor(damage)
end

function L.bombRange.updateDamageDisplay()
    if not L.bombRange.enabled then
        if L.bombRange.damageDisplay then
            L.bombRange.damageDisplay:Destroy()
            L.bombRange.damageDisplay = nil
        end
        return
    end
    local char = LocalPlayer.Character
    if not char then
        if L.bombRange.damageDisplay then
            L.bombRange.damageDisplay:Destroy()
            L.bombRange.damageDisplay = nil
        end
        return
    end
    local minDist = L.bombRange.getMinDistanceToBarrelCenter()
    local damage = 0
    if minDist <= SPHERE_RADIUS then
        damage = L.bombRange.calculateDamage(minDist)
    end
    if damage > 0 then
        if L.bombRange.damageDisplay and not L.bombRange.damageDisplay.Parent then
            L.bombRange.damageDisplay = nil
        end
        if not L.bombRange.damageDisplay then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if not hrp then return end
            local bill = Instance.new("BillboardGui")
            bill.Name = "DamageDisplay"
            bill.Size = UDim2.new(0, 100, 0, 40)
            bill.StudsOffset = v3new(0, 2.5, 0)
            bill.AlwaysOnTop = true
            bill.Adornee = hrp
            bill.Parent = char
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextSize = 24
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0.2
            label.TextStrokeColor3 = c3rgb(0, 0, 0)
            label.Parent = bill
            L.bombRange.damageDisplay = bill
        end
        local label = L.bombRange.damageDisplay:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = tostring(damage)
            if damage <= DAMAGE_THRESHOLD then
                label.TextColor3 = c3rgb(255, 255, 0)
            else
                label.TextColor3 = c3rgb(255, 0, 0)
            end
        end
    else
        if L.bombRange.damageDisplay then
            L.bombRange.damageDisplay:Destroy()
            L.bombRange.damageDisplay = nil
        end
    end
end


function L.bombRange.onHeartbeat()
    if not L.bombRange.enabled then return end
    L.bombRange.updateAllSpheres()
    L.bombRange.updateDamageDisplay()


    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local inRange = false
        for _, sphere in L.bombRange.spheres do
            if sphere and sphere.Parent then
                if (root.Position - sphere.Position).Magnitude <= SPHERE_RADIUS then
                    inRange = true
                    break
                end
            end
        end
        if inRange and not L.bombRange.warned then
            L.bombRange.warned = true
            L.notify(TranslateText("爆炸范围: 已进入爆炸范围内"), 3)
        elseif not inRange then
            L.bombRange.warned = false
        end
    end
end

function L.bombRange.start()
    if L.bombRange.conn then return end
    L.bombRange.enabled = true
    L.bombRange.warned = false
    L.bombRange.conn = RunService.Heartbeat:Connect(L.bombRange.onHeartbeat)
end

function L.bombRange.stop()
    L.bombRange.enabled = false
    if L.bombRange.conn then
        L.bombRange.conn:Disconnect()
        L.bombRange.conn = nil
    end
    for _, s in L.bombRange.spheres do pcall(s.Destroy, s) end
    L.bombRange.spheres = {}
    if L.bombRange.damageDisplay then
        L.bombRange.damageDisplay:Destroy()
        L.bombRange.damageDisplay = nil
    end
    L.bombRange.warned = false
end


L.handMortar = { enabled = false, animIds = { ["rbxassetid://117522716162453"] = true, ["rbxassetid://83761082384320"] = true }, gui = nil, conn = nil, cameraConn = nil, animConn = nil, endtick_ = nil, running = false }

function L.handMortar.isFirstPerson()
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return false end
    return (cam.CFrame.Position - head.Position).Magnitude < 0.7
end

function L.handMortar.createUI()
    if L.handMortar.gui then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local bg = Instance.new("BillboardGui")
    bg.Name = "HandMortarTimer_Billboard"
    bg.Size = UDim2.new(0, 80, 0, 40)
    bg.StudsOffset = v3new(2.2, 0, 0)
    bg.AlwaysOnTop = true
    bg.MaxDistance = 200
    bg.Parent = playerGui
    local billLabel = Instance.new("TextLabel")
    billLabel.Size = UDim2.new(1, 0, 1, 0)
    billLabel.BackgroundTransparency = 1
    billLabel.TextColor3 = Color3.new(1, 1, 1)
    billLabel.TextStrokeTransparency = 0.2
    billLabel.Font = Enum.Font.SourceSansBold
    billLabel.TextSize = 20
    billLabel.Text = ""
    billLabel.Parent = bg
    local screen = Instance.new("ScreenGui")
    screen.Name = "HandMortarTimer_Screen"
    screen.ResetOnSpawn = false
    screen.Parent = playerGui
    local screenLabel = Instance.new("TextLabel")
    screenLabel.Size = UDim2.new(0, 120, 0, 50)
    screenLabel.Position = UDim2.new(0.55, 0, 0.45, 0)
    screenLabel.AnchorPoint = v2new(0, 0)
    screenLabel.BackgroundTransparency = 1
    screenLabel.TextColor3 = Color3.new(1, 1, 1)
    screenLabel.TextStrokeTransparency = 0.2
    screenLabel.Font = Enum.Font.SourceSansBold
    screenLabel.TextSize = 28
    screenLabel.Text = ""
    screenLabel.Parent = screen
    L.handMortar.gui = { billboard = bg, screen = screen, billLabel = billLabel, screenLabel = screenLabel }
    bg.Enabled = false
    screen.Enabled = false
end

function L.handMortar.destroyUI()
    if L.handMortar.gui then
        if L.handMortar.gui.billboard then L.handMortar.gui.billboard:Destroy() end
        if L.handMortar.gui.screen then L.handMortar.gui.screen:Destroy() end
        L.handMortar.gui = nil
    end
end

function L.handMortar.startTimer()
    if not L.handMortar.enabled then return end
    if L.handMortar.conn then L.handMortar.conn:Disconnect() end
    if L.handMortar.cameraConn then L.handMortar.cameraConn:Disconnect() end
    L.handMortar.destroyUI()
    L.handMortar.createUI()
    local char = LocalPlayer.Character
    if char and L.handMortar.gui and L.handMortar.gui.billboard then
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if head then L.handMortar.gui.billboard.Adornee = head end
    end
    L.handMortar.endtick_ = tick_() + 5
    L.handMortar.running = true
    local function updateVisibility()
        if not L.handMortar.gui then return end
        local fp = L.handMortar.isFirstPerson()
        L.handMortar.gui.billboard.Enabled = not fp
        L.handMortar.gui.screen.Enabled = fp
    end
    updateVisibility()
    L.handMortar.cameraConn = RunService.RenderStepped:Connect(function()
        if not L.handMortar.running then return end
        if L.handMortar.gui then
            local fp = L.handMortar.isFirstPerson()
            L.handMortar.gui.billboard.Enabled = not fp
            L.handMortar.gui.screen.Enabled = fp
        end
    end)
    L.handMortar.conn = RunService.RenderStepped:Connect(function()
        if not L.handMortar.running or not L.handMortar.gui then
            if L.handMortar.conn then L.handMortar.conn:Disconnect() end
            if L.handMortar.cameraConn then L.handMortar.cameraConn:Disconnect() end
            L.handMortar.destroyUI()
            L.handMortar.running = false
            return
        end
        local remaining = mathMax(0, L.handMortar.endtick_ - tick_())
        local ms = mathFloor(remaining * 1000 + 0.5)
        local sec = mathFloor(ms / 1000)
        local remMs = ms - sec * 1000
        local text = strFormat("%d.%03ds", sec, remMs)
        if L.handMortar.gui.billLabel then L.handMortar.gui.billLabel.Text = text end
        if L.handMortar.gui.screenLabel then L.handMortar.gui.screenLabel.Text = text end
        if remaining <= 0 then
            if L.handMortar.conn then L.handMortar.conn:Disconnect() end
            if L.handMortar.cameraConn then L.handMortar.cameraConn:Disconnect() end
            L.handMortar.destroyUI()
            L.handMortar.running = false
        end
    end)
end

function L.handMortar.onAnimationPlayed(track)
    if not L.handMortar.enabled then return end
    local anim = track and track.Animation
    if not anim then return end
    if L.handMortar.animIds[anim.AnimationId] then
        task.delay(1, function() if L.handMortar.enabled then L.handMortar.startTimer() end end)
    end
end

function L.handMortar.attachAnimWatcher()
    if L.handMortar.animConn then L.handMortar.animConn:Disconnect() end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then L.handMortar.animConn = hum.AnimationPlayed:Connect(L.handMortar.onAnimationPlayed) end
end

function L.handMortar.setEnabled(state)
    L.handMortar.enabled = state
    if state then
        L.handMortar.attachAnimWatcher()
    else
        if L.handMortar.animConn then L.handMortar.animConn:Disconnect(); L.handMortar.animConn = nil end
        if L.handMortar.conn then L.handMortar.conn:Disconnect(); L.handMortar.conn = nil end
        if L.handMortar.cameraConn then L.handMortar.cameraConn:Disconnect(); L.handMortar.cameraConn = nil end
        L.handMortar.destroyUI()
        L.handMortar.running = false
    end
end


L.noBarrelHit = { enabled = false, conn = nil }

function L.noBarrelHit.toggle(state)
    L.noBarrelHit.enabled = state
    if state then
        local function removeCollision(z)
            if not z or not z.Parent then return end
            for _, p in z:GetDescendants() do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.CanTouch = false
                    p.CanQuery = false
                end
            end
        end
        local zf = workspace:FindFirstChild("Zombies")
        if zf then
            for _, z in zf:GetChildren() do
                if z:IsA("Model") and (z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel")) then
                    removeCollision(z)
                end
            end
        end
        task.spawn(function()
            while L.noBarrelHit.enabled do
                local zf2 = workspace:FindFirstChild("Zombies")
                if zf2 then
                    for _, z in zf2:GetChildren() do
                        if z:IsA("Model") and (z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel")) then
                            removeCollision(z)
                        end
                    end
                end
                task.wait()
            end
        end)
        if L.noBarrelHit.conn then L.noBarrelHit.conn:Disconnect() end
        L.noBarrelHit.conn = workspace.DescendantAdded:Connect(function(desc)
            if L.noBarrelHit.enabled and desc:IsA("Model") and (desc:GetAttribute("Type") == "Barrel" or desc:FindFirstChild("Barrel")) then
                removeCollision(desc)
            end
        end)
    else
        if L.noBarrelHit.conn then L.noBarrelHit.conn:Disconnect(); L.noBarrelHit.conn = nil end
    end
end


L.jumpLock = { active = false, conn = nil }

function L.jumpLock.toggle(state)
    L.jumpLock.active = state
    if state then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = 30
            if L.jumpLock.conn then L.jumpLock.conn:Disconnect() end
            L.jumpLock.conn = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if hum.JumpPower ~= 30 then hum.JumpPower = 30 end
            end)
        end
    else
        if L.jumpLock.conn then L.jumpLock.conn:Disconnect(); L.jumpLock.conn = nil end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 16 end
    end
end

L.onCharacterAdded(function()
    if L.jumpLock and L.jumpLock.active then
        task.wait(0.2)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = 30
            if L.jumpLock.conn then L.jumpLock.conn:Disconnect() end
            L.jumpLock.conn = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if hum.JumpPower ~= 30 then hum.JumpPower = 30 end
            end)
        end
    end
end)





L.hitboxHighlight = {
    enabled = false,
    box = nil,
    containerPart = nil,
    charConn = nil,
    diedConn = nil,
    loopThread = nil,
    history = {},
    maxHistory = 60,
}


local cachedPing = 0
local lastPingTime = 0
local function getCurrentPing()
    local now = osClock()
    if now - lastPingTime >= 1 then
        lastPingTime = now
        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and ping then
            cachedPing = ping
        end
    end
    return cachedPing
end


local function clearBox()
    if L.hitboxHighlight.box then
        pcall(function() L.hitboxHighlight.box:Destroy() end)
        L.hitboxHighlight.box = nil
    end
    if L.hitboxHighlight.containerPart then
        pcall(function() L.hitboxHighlight.containerPart:Destroy() end)
        L.hitboxHighlight.containerPart = nil
    end
    if L.hitboxHighlight.loopThread then
        task.cancel(L.hitboxHighlight.loopThread)
        L.hitboxHighlight.loopThread = nil
    end
    table.clear(L.hitboxHighlight.history)
end


function L.hitboxHighlight.enable()
    if L.hitboxHighlight.enabled then return end
    L.hitboxHighlight.enabled = true
    clearBox()

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end


    local container = Instance.new("Part")
    container.Name = "HitboxContainer"
    container.Size = root.Size
    container.CFrame = root.CFrame
    container.Anchored = true
    container.CanCollide = false
    container.CanTouch = false
    container.CanQuery = false
    container.Transparency = 1
    container.Parent = workspace

    L.hitboxHighlight.containerPart = container


    L.hitboxHighlight.box = Instance.new("SelectionBox")
    L.hitboxHighlight.box.Adornee = container
    L.hitboxHighlight.box.Color3 = c3rgb(255, 0, 0)
    L.hitboxHighlight.box.LineThickness = 0.15
    L.hitboxHighlight.box.Transparency = 0.3
    L.hitboxHighlight.box.Parent = container


    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if L.hitboxHighlight.diedConn then
            L.hitboxHighlight.diedConn:Disconnect()
        end
        L.hitboxHighlight.diedConn = hum.Died:Connect(function()
            clearBox()
        end)
    end


    local smoothSpeed = 10
    local rs = RunService

    L.hitboxHighlight.loopThread = task.spawn(function()
        local lastTime = osClock()
        while L.hitboxHighlight.enabled do
            local now = osClock()
            local dt = mathMin(now - lastTime, 0.1)
            lastTime = now

            local currentChar = LocalPlayer.Character
            if currentChar then
                local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
                if currentRoot and L.hitboxHighlight.containerPart then

                    local hist = L.hitboxHighlight.history
                    table.insert(hist, {
                        time = now,
                        cframe = currentRoot.CFrame,
                        size = currentRoot.Size
                    })
                    while #hist > L.hitboxHighlight.maxHistory do
                        table.remove(hist, 1)
                    end


                    local ping = getCurrentPing()
                    local delaySec = ping / 1000
                    local targetTime = now - delaySec
                    local targetCF = hist[1].cframe
                    local targetSize = hist[1].size
                    for i = 1, #hist do
                        if hist[i].time >= targetTime then
                            targetCF = hist[i].cframe
                            targetSize = hist[i].size
                            break
                        end
                    end


                    local currentCF = L.hitboxHighlight.containerPart.CFrame
                    local alpha = mathMin(smoothSpeed * dt, 1)
                    L.hitboxHighlight.containerPart.CFrame = currentCF:Lerp(targetCF, alpha)
                    L.hitboxHighlight.containerPart.Size = L.hitboxHighlight.containerPart.Size:Lerp(targetSize, alpha)
                end
            end
            rs.Heartbeat:Wait()
        end
    end)
end

function L.hitboxHighlight.disable()
    if not L.hitboxHighlight.enabled then return end
    L.hitboxHighlight.enabled = false
    if L.hitboxHighlight.diedConn then
        L.hitboxHighlight.diedConn:Disconnect()
        L.hitboxHighlight.diedConn = nil
    end
    clearBox()
end


function L.hitboxHighlight.toggle()
    if L.hitboxHighlight.enabled then
        L.hitboxHighlight.disable()
    else
        L.hitboxHighlight.enable()
    end
end


if L.hitboxHighlight.charConn then
    L.hitboxHighlight.charConn()
end
L.hitboxHighlight.charConn = L.onCharacterAdded(function()
    task.wait(0.3)
    if L.hitboxHighlight.enabled then
        clearBox()
        task.wait(0.1)
        L.hitboxHighlight.enabled = false
        L.hitboxHighlight.enable()
    end
end)

AutoRightGroup:AddToggle('HitboxHighlightToggle', {
    Text = '玩家碰撞箱显示',
    Default = false,
    Tooltip = TranslateTooltip('显示玩家碰撞箱'),
    Callback = function(v)
        if v then
            L.hitboxHighlight.enable()
        else
            L.hitboxHighlight.disable()
        end
    end
})


L.legionPack = {
    selectedLegion = "法兰西第一掷弹兵",
    selectedClass = "线列步兵",
    legionMap = {
        ["法兰西第一掷弹兵"] = { nation = "French", regimentId = 2, branch = "Infantry" },
        ["英国冷溪近卫军"]   = { nation = "British", regimentId = 4, branch = "Infantry" },
        ["老敬卫"]          = { nation = "French", regimentId = 5, branch = "Infantry" },
    },
    classMap = {
        ["线列步兵"] = "LineInfantry",
        ["军官"]     = "Officer",
        ["工兵"]     = "Sapper",
        ["乐手"]     = "Musician",
        ["水手"]     = "Seaman",
    }
}

function L.legionPack.getRemote()
    local rs = ReplicatedStorage
    local events = rs and rs:FindFirstChild("Events")
    if not events then return nil end
    local regiment = events:FindFirstChild("Regiment")
    if not regiment then return nil end
    return regiment:FindFirstChild("ChangeClass")
end

function L.legionPack.unlock()
    local remote = L.legionPack.getRemote()
    if not remote then
        L.notify(TranslateText("解锁失败: 找不到ChangeClass"), 3)
        return false
    end
    local legionInfo = L.legionPack.legionMap[L.legionPack.selectedLegion]
    local className = L.legionPack.classMap[L.legionPack.selectedClass]
    if not legionInfo or not className then
        L.notify(TranslateText("解锁失败: 配置错误"), 3)
        return false
    end
    pcall(function() remote:FireServer(className, legionInfo.regimentId, legionInfo.nation, legionInfo.branch) end)
    L.notify(TranslateText("已解锁替换") .. ": " .. L.legionPack.selectedLegion .. " - " .. L.legionPack.selectedClass, 3)
    return true
end

L.ZOMBIE_ESP_RANGE = 200

function L.lightenColor(color, factor)
    factor = factor or 0.5
    return Color3.new(
        color.R + (1 - color.R) * factor,
        color.G + (1 - color.G) * factor,
        color.B + (1 - color.B) * factor
    )
end

L.ZOMBIE_TYPES = {
    Axe    = { name = "斧头僵尸", color = c3rgb(180, 0, 250), highlightColor = L.lightenColor(c3rgb(180, 0, 250)), part = "Axe" },
    Eye    = { name = "红眼",      color = c3rgb(255, 50, 50),  highlightColor = L.lightenColor(c3rgb(255, 50, 50)),  part = "Eye" },
    Sword  = { name = "胸甲骑兵",  color = c3rgb(255, 0, 255),  highlightColor = L.lightenColor(c3rgb(255, 0, 255)),  part = "Sword" },
    Barrel = { name = "自爆",      color = c3rgb(250, 250, 0),  highlightColor = L.lightenColor(c3rgb(250, 250, 0)),  part = "Barrel" },
    FTorso = { name = "提灯人",    color = c3rgb(255, 120, 0),  highlightColor = L.lightenColor(c3rgb(255, 120, 0)),  part = "FTorso" },
    Normal = { name = "山伯乐",    color = c3rgb(144, 238, 144), highlightColor = c3rgb(144, 238, 144), part = nil },
    Headless = { name = "无头士兵", color = c3rgb(255, 215, 0), highlightColor = c3rgb(255, 215, 0), matchName = "HeadlessHorseman" },
}

L.headlessHighlightEnabled = false
L.draculaHighlightEnabled = false
L.headlessHighlights = {}
L.headlessTags = {}
L.headlessDescendantConn = nil

function L.clearHeadlessHighlights()
    for model, hl in L.headlessHighlights do
        if hl and hl.Parent then hl:Destroy() end
    end
    L.headlessHighlights = {}

    for model, tag in L.headlessTags do
        if tag and tag.Parent then tag:Destroy() end
    end
    L.headlessTags = {}
end


function L.isHeadlessModel(model)
    if not model or not model:IsA("Model") then return false end
    local name = model.Name

    if name == "HeadlessHorseman" then return true end
    if name:find("Horse") or name:find("Steed") or name:find("Mount") then

        local parent = model.Parent
        if parent and parent:IsA("Model") and parent.Name == "HeadlessHorseman" then
            return true
        end

        if name:find("Headless") then return true end
    end
    return false
end


function L.getAttachPart(model)
    return model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model:FindFirstChild("Torso")
end

function L.createHeadlessHighlight(model)
    if not model or not model:IsA("Model") then return end
    if not L.isHeadlessModel(model) then return end
    if L.headlessHighlights[model] then return end


    local hl = Instance.new("Highlight")
    hl.FillColor = c3rgb(255, 50, 50)
    hl.OutlineColor = c3rgb(255, 50, 50)
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model

    L.headlessHighlights[model] = hl


    if model.Name == "HeadlessHorseman" or model.Name:find("Headless") then
        local attachPart = L.getAttachPart(model)
        if not attachPart then return end

        local tag = Instance.new("BillboardGui")
        tag.Name = "HeadlessTag"
        tag.Size = UDim2.new(0, 120, 0, 30)
        tag.StudsOffset = v3new(0, 2.5, 0)
        tag.AlwaysOnTop = true
        tag.Adornee = attachPart
        tag.Parent = model

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = TranslateText("无头骑士")
        label.TextColor3 = c3rgb(255, 50, 50)
        label.TextTransparency = 0.3
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = c3rgb(0, 0, 0)
        label.Parent = tag

        L.headlessTags[model] = tag
    end
end

function L.updateHeadlessHighlights()
    if not L.headlessHighlightEnabled then
        L.clearHeadlessHighlights()
        return
    end


    for model, hl in L.headlessHighlights do
        if not model.Parent then
            hl:Destroy()
            L.headlessHighlights[model] = nil
        end
    end
    for model, tag in L.headlessTags do
        if not model.Parent then
            tag:Destroy()
            L.headlessTags[model] = nil
        end
    end


    for _, obj in workspace:GetDescendants() do
        if obj:IsA("Model") and L.isHeadlessModel(obj) then
            L.createHeadlessHighlight(obj)
        end
    end
end

function L.startHeadlessListener()
    if L.headlessDescendantConn then return end
    L.headlessDescendantConn = workspace.DescendantAdded:Connect(function(inst)
        if L.headlessHighlightEnabled and inst:IsA("Model") and L.isHeadlessModel(inst) then
            task.spawn(function()
                task.wait()
                L.createHeadlessHighlight(inst)
            end)
        end
    end)
end

function L.stopHeadlessListener()
    if L.headlessDescendantConn then
        L.headlessDescendantConn:Disconnect()
        L.headlessDescendantConn = nil
    end
end

function L.toggleHeadlessHighlight(state)
    L.headlessHighlightEnabled = state
    if state then
        L.updateHeadlessHighlights()
        L.startHeadlessListener()
    else
        L.clearHeadlessHighlights()
        L.stopHeadlessListener()
    end
end

L.draculaHighlights = {}
L.draculaTags = {}
L.draculaDescendantConn = nil

function L.clearDraculaHighlights()
    for model, hl in L.draculaHighlights do
        if hl and hl.Parent then hl:Destroy() end
    end
    L.draculaHighlights = {}
    for model, tag in L.draculaTags do
        if tag and tag.Parent then tag:Destroy() end
    end
    L.draculaTags = {}
end

function L.getDraculaModel()
    local transylvania = workspace:FindFirstChild("Transylvania")
    local dracula = transylvania and
                     transylvania:FindFirstChild("Modes") and
                     transylvania.Modes:FindFirstChild("Boss") and
                     transylvania.Modes.Boss:FindFirstChild("Dracula")
    return dracula
end

function L.createDraculaHighlight(model)
    if not model or not model:IsA("Model") then return end
    if L.draculaHighlights[model] then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = c3rgb(255, 50, 50)
    hl.OutlineColor = c3rgb(255, 50, 50)
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
    L.draculaHighlights[model] = hl

    local attachPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    if not attachPart then return end

    local tag = Instance.new("BillboardGui")
    tag.Name = "DraculaTag"
    tag.Size = UDim2.new(0, 120, 0, 30)
    tag.StudsOffset = v3new(0, 3, 0)
    tag.AlwaysOnTop = true
    tag.Adornee = attachPart
    tag.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = TranslateText("德古拉")
    label.TextColor3 = c3rgb(255, 50, 50)
    label.TextTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = c3rgb(0, 0, 0)
    label.Parent = tag
    L.draculaTags[model] = tag
end

function L.updateDraculaHighlight()
    if not L.draculaHighlightEnabled then
        L.clearDraculaHighlights()
        return
    end


    for model, hl in L.draculaHighlights do
        if not model.Parent then
            hl:Destroy()
            L.draculaHighlights[model] = nil
        end
    end
    for model, tag in L.draculaTags do
        if not model.Parent then
            tag:Destroy()
            L.draculaTags[model] = nil
        end
    end

    local dracula = L.getDraculaModel()
    if dracula then
        L.createDraculaHighlight(dracula)
    end
end

function L.startDraculaListener()
    if L.draculaDescendantConn then return end
    L.draculaDescendantConn = workspace.DescendantAdded:Connect(function(inst)
        if L.draculaHighlightEnabled and inst:IsA("Model") and inst.Name == "Dracula" then
            task.spawn(function()
                task.wait()
                L.createDraculaHighlight(inst)
            end)
        end
    end)
end

function L.stopDraculaListener()
    if L.draculaDescendantConn then
        L.draculaDescendantConn:Disconnect()
        L.draculaDescendantConn = nil
    end
end

function L.toggleDraculaHighlight(state)
    L.draculaHighlightEnabled = state
    if state then
        L.updateDraculaHighlight()
        L.startDraculaListener()
    else
        L.clearDraculaHighlights()
        L.stopDraculaListener()
    end
end

L.zombieEspEnabled = {
    Axe = false, Eye = false, Sword = false, Barrel = false, FTorso = false, Normal = false,
    Headless = false,
}

L.zombieEffects = {}

function L.getZombieTypeKey(zombie)

    for typeKey, config in L.ZOMBIE_TYPES do
        if config.part and zombie:FindFirstChild(config.part) then
            return typeKey
        end
    end

    for typeKey, config in L.ZOMBIE_TYPES do
        if config.matchName and zombie.Name == config.matchName then
            return typeKey
        end
    end

    if not zombie:FindFirstChild("Head") then
        return "Headless"
    end

    return "Normal"
end

function L.createTag(zombie, typeKey)
    local config = L.ZOMBIE_TYPES[typeKey]
    if not config then return nil end
    local attachPart = zombie.PrimaryPart or zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
    if not attachPart then return nil end
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 120, 0, 30)
    tag.StudsOffset = v3new(0, 2.5, 0)
    tag.AlwaysOnTop = true
    tag.Adornee = attachPart
    tag.Parent = zombie
    local label = Instance.new("TextLabel")
    label.Text = config.name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = config.highlightColor
    label.TextTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = c3rgb(0, 0, 0)
    label.Parent = tag
    return tag
end

function L.createHighlight(zombie, color)
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.7
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = zombie
    hl.Parent = zombie
    return hl
end

function L.removeZombieEffects(zombie)
    local effects = L.zombieEffects[zombie]
    if effects then
        if effects.tag then effects.tag:Destroy() end
        if effects.highlight then effects.highlight:Destroy() end
        L.zombieEffects[zombie] = nil
    end
end

function L.clearAllZombieEffects()
    for zombie, _ in L.zombieEffects do
        L.removeZombieEffects(zombie)
    end
end

function L.updateZombieESP()
    local anyEnabled = false
    for _, v in L.zombieEspEnabled do
        if v then anyEnabled = true; break end
    end
    if not anyEnabled then
        L.clearAllZombieEffects()
        return
    end

    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = rootPart and rootPart.Position
    if not playerPos then
        L.clearAllZombieEffects()
        return
    end

    for zombie, _ in L.zombieEffects do
        if not zombie.Parent then
            L.removeZombieEffects(zombie)
        end
    end


    local zombieModels = {}
    local cameraFolder = workspace:FindFirstChild("Camera")
    if cameraFolder then
        for _, z in cameraFolder:GetDescendants() do
            if z:IsA("Model") and z.Name:find("Zombie") then
                table.insert(zombieModels, z)
            end
        end
    end
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if zombiesFolder then
        for _, z in zombiesFolder:GetChildren() do
            if z:IsA("Model") and z.Name:find("Zombie") then
                table.insert(zombieModels, z)
            end
        end
    end

    for _, zombie in zombieModels do
        local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head") or zombie:FindFirstChild("Torso")
        if root then
            local dist = (root.Position - playerPos).Magnitude
            local typeKey = L.getZombieTypeKey(zombie)
            local enabled = L.zombieEspEnabled[typeKey]

            if enabled and dist <= L.ZOMBIE_ESP_RANGE then
                if not L.zombieEffects[zombie] then
                    local config = L.ZOMBIE_TYPES[typeKey]
                    local tag = L.createTag(zombie, typeKey)
                    local highlight = L.createHighlight(zombie, config.highlightColor)
                    L.zombieEffects[zombie] = { tag = tag, highlight = highlight, typeKey = typeKey }
                end
            else
                if L.zombieEffects[zombie] then
                    L.removeZombieEffects(zombie)
                end
            end
        end
    end
end

L.lastZombieESPUpdate = 0
L.zombieESPHeartbeatConn = nil

function L.startZombieESPHeartbeat()
    if L.zombieESPHeartbeatConn then return end
    L.zombieESPHeartbeatConn = RunService.Heartbeat:Connect(function()
        local now = tick_()
        if now - L.lastZombieESPUpdate >= 0.2 then
            L.lastZombieESPUpdate = now
            L.updateZombieESP()
        end
    end)
end

function L.stopZombieESPHeartbeat()
    if L.zombieESPHeartbeatConn then
        L.zombieESPHeartbeatConn:Disconnect()
        L.zombieESPHeartbeatConn = nil
    end
    L.clearAllZombieEffects()
end

L.onCharacterAdded(function()
    task.wait(0.5)
    L.updateZombieESP()
end)




L.CoordSpeed = { Enabled = false, Speed = 16, Connection = nil }

local function startCoordSpeed()
    if L.CoordSpeed.Connection then return end
    L.CoordSpeed.Connection = RunService.Heartbeat:Connect(function(dt)
        if not L.CoordSpeed.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + moveDir.Unit * L.CoordSpeed.Speed * dt
        end
    end)
end

local function stopCoordSpeed()
    if L.CoordSpeed.Connection then
        L.CoordSpeed.Connection:Disconnect()
        L.CoordSpeed.Connection = nil
    end
end

LeftGroup:AddToggle('CoordSpeedToggle', {
    Text = '启用坐标加速',
    Default = false,
    Tooltip = TranslateTooltip('通过CFrame实现位移'),
    Callback = function(Value)
        L.CoordSpeed.Enabled = Value
        if Value then
            startCoordSpeed()
        else
            stopCoordSpeed()
        end
    end
})

LeftGroup:AddSlider('CoordSpeedSlider', {
    Text = '坐标加速速度',
    Default = 16,
    Min = 1,
    Max = 150,
    Rounding = 0,
    Suffix = " 速度",
    Callback = function(Value)
        L.CoordSpeed.Speed = Value
    end
})

local speedEnabled = false
local desiredSpeed = 25
local speedHeartbeatConn = nil
local speedHumPropConns = {}

local function safeSetWalk(hum, sp)
    if hum and hum.Parent then pcall(function() hum.WalkSpeed = sp end) end
end

local function onWalkSpeedChanged(hum)
    return hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedEnabled then safeSetWalk(hum, desiredSpeed) end
    end)
end

local function attachToCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedHumPropConns[hum] then speedHumPropConns[hum]:Disconnect() end
        speedHumPropConns[hum] = onWalkSpeedChanged(hum)
        safeSetWalk(hum, desiredSpeed)
    end
end

local function startSpeedLoop()
    if speedHeartbeatConn then return end
    speedHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not speedEnabled then return end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                safeSetWalk(hum, desiredSpeed)
                if not speedHumPropConns[hum] then
                    speedHumPropConns[hum] = onWalkSpeedChanged(hum)
                end
            end
        end
    end)
end

local function stopSpeedLoop()
    if speedHeartbeatConn then
        speedHeartbeatConn:Disconnect()
        speedHeartbeatConn = nil
    end
    for hum, conn in speedHumPropConns do
        pcall(function() conn:Disconnect() end)
    end
    speedHumPropConns = {}
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then safeSetWalk(hum, 16) end
    end
end

function setWalkSpeedEnabled(state)
    speedEnabled = state
    if state then
        startSpeedLoop()
        if LocalPlayer.Character then attachToCharacter(LocalPlayer.Character) end
    else
        stopSpeedLoop()
    end
end

function setWalkSpeedValue(speed)
    desiredSpeed = mathClamp(speed, 16, 45)
    if speedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then safeSetWalk(hum, desiredSpeed) end
        end
    end
end

L.onCharacterAdded(function(char)
    if speedEnabled then
        task.wait(0.1)
        attachToCharacter(char)
    end
end)

LeftGroup:AddToggle('SpeedToggle', {
    Text = '启用速度调整',
    Default = false,
    Callback = function(Value)
        setWalkSpeedEnabled(Value)
    end
})

LeftGroup:AddSlider('SpeedSlider', {
    Text = '玩家速度',
    Default = 25,
    Min = 16,
    Max = 45,
    Rounding = 0,
    Suffix = " 速度",
    Callback = function(Value)
        setWalkSpeedValue(Value)
    end
})

L.AutoFace = { Enabled = false, Range = 17, SkipBarrel = false, Connection = nil }

local function getNearestZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local zombies = workspace:FindFirstChild("Zombies")
    if not zombies then return nil end
    local best, bestDist = nil, mathHuge
    for _, z in zombies:GetChildren() do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
            if L.AutoFace.SkipBarrel and (z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel")) then
                continue
            end
            local state = z:FindFirstChild("State")
            if state and state.Value == "Spawn" then
                continue
            end
            local zRoot = z.HumanoidRootPart
            local dist = (zRoot.Position - root.Position).Magnitude
            if dist <= L.AutoFace.Range and dist < bestDist then
                bestDist = dist
                best = z
            end
        end
    end
    return best
end

local function autoFaceLoop()
    while L.AutoFace.Enabled do
        local target = getNearestZombie()
        if target then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum then
                    local wasRotate = hum.AutoRotate
                    hum.AutoRotate = false
                    local targetPos = target.HumanoidRootPart.Position
                    root.CFrame = CFrame.lookAt(root.Position, v3new(targetPos.X, root.Position.Y, targetPos.Z))
                    hum.AutoRotate = wasRotate
                end
            end
        end
        task.wait(0.1)
    end
end

LeftGroup:AddSlider('AutoFaceRange', {
    Text = '自动转向范围',
    Default = 17,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Suffix = " 格",
    Callback = function(Value)
        L.AutoFace.Range = Value
    end
})

LeftGroup:AddToggle('AutoFaceToggle', {
    Text = '自动转向',
    Default = false,
    Callback = function(Value)
        L.AutoFace.Enabled = Value
        if Value then
            if L.AutoFace.Connection then
                task.cancel(L.AutoFace.Connection)
            end
            L.AutoFace.Connection = task.spawn(autoFaceLoop)
        else
            if L.AutoFace.Connection then
                task.cancel(L.AutoFace.Connection)
                L.AutoFace.Connection = nil
            end
        end
    end
})

LeftGroup:AddToggle('SkipBarrelToggle', {
    Text = '跳过自爆僵尸',
    Default = false,
    Tooltip = TranslateTooltip('开启后不会转向自爆'),
    Callback = function(Value)
        L.AutoFace.SkipBarrel = Value
    end
})




L.GroundJump = { Enabled = false, Power = 60, JumpReqConn = nil }

local function onGroundJumpRequest()
    if not L.GroundJump.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.FloorMaterial ~= Enum.Material.Air then
        hrp.AssemblyLinearVelocity = v3new(hrp.AssemblyLinearVelocity.X, L.GroundJump.Power, hrp.Velocity.Z)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function setupGroundJump()
    if L.GroundJump.Enabled then
        if not L.GroundJump.JumpReqConn then
            L.GroundJump.JumpReqConn = UserInputService.JumpRequest:Connect(onGroundJumpRequest)
        end
    else
        if L.GroundJump.JumpReqConn then
            L.GroundJump.JumpReqConn:Disconnect()
            L.GroundJump.JumpReqConn = nil
        end
    end
end

LeftGroup:AddToggle('GroundJumpToggle', {
    Text = '控制玩家跳跃高度',
    Default = false,
    Callback = function(Value)
        L.GroundJump.Enabled = Value
        setupGroundJump()
    end
})

LeftGroup:AddSlider('GroundJumpSlider', {
    Text = '跳跃高度',
    Default = 60,
    Min = 30,
    Max = 95,
    Rounding = 0,
    Suffix = " 高度",
    Callback = function(Value)
        L.GroundJump.Power = Value
    end
})




L.AutoJump = { Enabled = false, Height = 60, Connection = nil }

local function autoJumpLoop()
    if L.AutoJump.Connection then
        L.AutoJump.Connection:Disconnect()
    end
    L.AutoJump.Connection = RunService.Heartbeat:Connect(function()
        if not L.AutoJump.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = v3new(hrp.AssemblyLinearVelocity.X, L.AutoJump.Height, hrp.Velocity.Z)
        end
    end)
end

LeftGroup:AddToggle('AutoJumpToggle', {
    Text = '自动跳跃',
    Default = false,
    Callback = function(Value)
        L.AutoJump.Enabled = Value
        if Value then
            autoJumpLoop()
        else
            if L.AutoJump.Connection then
                L.AutoJump.Connection:Disconnect()
                L.AutoJump.Connection = nil
            end
        end
    end
})

LeftGroup:AddSlider('AutoJumpHeight', {
    Text = '自动跳跃高度',
    Default = 60,
    Min = 30,
    Max = 60,
    Rounding = 0,
    Suffix = " 高度",
    Callback = function(Value)
        L.AutoJump.Height = Value
    end
})




L.JumpMod = {
    Enabled = false,
    Height = 60,
    Cooldown = 0.6,
    LastJump = 0,
    AntiFallConn = nil,
    JumpReqConn = nil
}

local function antiFallLoop()
    if L.JumpMod.AntiFallConn then return end
    L.JumpMod.AntiFallConn = RunService.Heartbeat:Connect(function()
        if not L.JumpMod.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if hrp.AssemblyLinearVelocity.Y < -5 and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Climbing)
        end
        local userStates = LocalPlayer:FindFirstChild("UserStates")
        if userStates then
            local broken = userStates:FindFirstChild("BrokenLegs")
            if broken then
                broken.Value = false
            end
        end
    end)
end

local function onJumpModRequest()
    if not L.JumpMod.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and tick_() - L.JumpMod.LastJump >= L.JumpMod.Cooldown then
        L.JumpMod.LastJump = tick_()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        hrp.AssemblyLinearVelocity = v3new(hrp.AssemblyLinearVelocity.X, L.JumpMod.Height, hrp.Velocity.Z)
    end
end

local function setupJumpMod()
    if L.JumpMod.Enabled then
        if not L.JumpMod.JumpReqConn then
            L.JumpMod.JumpReqConn = UserInputService.JumpRequest:Connect(onJumpModRequest)
        end
        antiFallLoop()
    else
        if L.JumpMod.JumpReqConn then
            L.JumpMod.JumpReqConn:Disconnect()
            L.JumpMod.JumpReqConn = nil
        end
        if L.JumpMod.AntiFallConn then
            L.JumpMod.AntiFallConn:Disconnect()
            L.JumpMod.AntiFallConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            local animate = char:FindFirstChild("Animate")
            if animate then
                animate.Parent = char
            end
        end
    end
end

LeftGroup:AddToggle('JumpModToggle', {
    Text = '无限连跳（含防骨折）',
    Default = false,
    Callback = function(Value)
        L.JumpMod.Enabled = Value
        setupJumpMod()
    end
})

LeftGroup:AddSlider('JumpModHeight', {
    Text = '跳跃高度',
    Default = 60,
    Min = 30,
    Max = 90,
    Rounding = 0,
    Suffix = " 高度",
    Callback = function(Value)
        L.JumpMod.Height = Value
    end
})

L.NoSlow = { Enabled = false, WalkSpeedConn = nil, CharAddedConn = nil }

local function noSlowApply()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 16 then
        hum.WalkSpeed = 16
    end
end

local function setupNoSlow()
    if L.NoSlow.Enabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if L.NoSlow.WalkSpeedConn then
                    L.NoSlow.WalkSpeedConn:Disconnect()
                end
                L.NoSlow.WalkSpeedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(noSlowApply)
                noSlowApply()
            end
        end
        if not L.NoSlow.CharAddedConn then
            L.NoSlow.CharAddedConn = L.onCharacterAdded(function()
                task.wait(0.5)
                setupNoSlow()
            end)
        end
    else
        if L.NoSlow.WalkSpeedConn then
            L.NoSlow.WalkSpeedConn:Disconnect()
            L.NoSlow.WalkSpeedConn = nil
        end
        if L.NoSlow.CharAddedConn then
            L.NoSlow.CharAddedConn()
            L.NoSlow.CharAddedConn = nil
        end
    end
end

LeftGroup:AddToggle('NoSlowToggle', {
    Text = '无减速',
    Default = false,
    Tooltip = TranslateTooltip('移除减速效果（重生后需重新开启）'),
    Callback = function(Value)
        L.NoSlow.Enabled = Value
        setupNoSlow()
    end
})




L.NoFall = { Enabled = false, Connection = nil }

local function noFallLoop()
    while L.NoFall.Enabled do
        local char = LocalPlayer.Character
        if char then
            local health = char:FindFirstChild("Health")
            if health then
                local force = health:FindFirstChild("ForceSelfDamage")
                if force then
                    pcall(function() force:FireServer(0) end)
                end
            end
        end
        task.wait(1)
    end
end

LeftGroup:AddToggle('NoFallToggle', {
    Text = '移除摔伤',
    Default = false,
    Tooltip = TranslateTooltip('移除摔落伤害（注意不防骨折）'),
    Callback = function(Value)
        L.NoFall.Enabled = Value
        if Value then
            if L.NoFall.Connection then
                task.cancel(L.NoFall.Connection)
            end
            L.NoFall.Connection = task.spawn(noFallLoop)
        else
            if L.NoFall.Connection then
                task.cancel(L.NoFall.Connection)
                L.NoFall.Connection = nil
            end
        end
    end
})




L.Backpack = { Enabled = false, ToggleConn = nil }

LeftGroup:AddToggle('BackpackToggle', {
    Text = '显示物品栏',
    Default = false,
    Tooltip = TranslateTooltip('强制显示物品栏'),
    Callback = function(Value)
        L.Backpack.Enabled = Value
        local backpackGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("BackpackGui")
        if Value then
            backpackGui.Enabled = true
            if L.Backpack.ToggleConn then
                L.Backpack.ToggleConn:Disconnect()
            end
            L.Backpack.ToggleConn = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
                if not backpackGui.Enabled then
                    backpackGui.Enabled = true
                end
            end)
        else
            if L.Backpack.ToggleConn then
                L.Backpack.ToggleConn:Disconnect()
                L.Backpack.ToggleConn = nil
            end
        end
    end
})

L.auraEnabled = false
L.attackThread = nil
L.attackCount = 2
L.displayRange = 17
L.autoEquipWeaponEnabled = false
L.attackAngle = 180
L.showRangeVisuals = false
L.INNER_RING_FIXED_RADIUS = 13

L.smartAura = {
    enabled = false,
    auraClosed = false,
    innerEntryKills = {},
    checkInterval = 0.5,
    killTimeout = 2.0,
    retryInterval = 2.0,
    retryTimer = 0,
    probeMode = false,
}

L.attackBarrelEnabled = false
L.attackDraculaEnabled = false
L.skipSpawningEnabled = true

L.currentAttackTargets = {}
L.indicatorData = {}
L.indicatorUpdateConn = nil

function L.isHoldingMelee()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, tool in char:GetChildren() do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("axe") or name:find("pickaxe") or name:find("shovel") or name:find("spade") or name:find("稿") or name:find("铲") or name:find("镐") then
                return true
            end
            if name:find("musket") or name:find("flintlock") or name:find("bayonet") then
                return true
            end
        end
    end
    return false
end

function L.getNearestNonBarrelZombie()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    local range = L.displayRange
    local folder = workspace:FindFirstChild("Zombies")
    if not folder then return nil end

    local best, bestDist = nil, mathHuge
    for _, z in folder:GetChildren() do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
            if z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel") then continue end
            if L.skipSpawningEnabled then
                local state = z:FindFirstChild("State")
                if state and tostring(state.Value) == "Spawn" then continue end
            end
            local zPos = z.HumanoidRootPart.Position
            local dist = (zPos - pos).Magnitude
            if dist <= range and dist < bestDist then
                bestDist = dist
                best = z
            end
        end
    end
    return best
end

function L.getZombiesInRadius(radius)
    local char = LocalPlayer.Character
    if not char then return {} end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local pos = root.Position
    local folder = workspace:FindFirstChild("Zombies")
    if not folder then return {} end

    local result = {}
    for _, z in folder:GetChildren() do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
            if L.skipSpawningEnabled then
                local state = z:FindFirstChild("State")
                if state and tostring(state.Value) == "Spawn" then continue end
            end
            local zPos = z.HumanoidRootPart.Position
            local dist = (zPos - pos).Magnitude
            if dist <= radius then
                table.insert(result, z)
            end
        end
    end
    return result
end

function L.fireMeleeHit(remote, isBayonet, zombie, HitPos, Direction)
    if not remote or not zombie or not zombie.Parent then return end
    if isBayonet then
        local orig = zombie:FindFirstChild("Orig")
        local ref = (orig and orig.Value) or zombie
        remote:FireServer("ThrustBayonet")
        remote:FireServer("Bayonet_HitZombie", ref, HitPos, true, "Head", "Down")
        ref:SetAttribute("WepHitID", osClock())
        ref:SetAttribute("WepHitDirection", Direction * 10)
        ref:SetAttribute("WepHitPos", HitPos)
    else
        remote:FireServer("Swing", "Thrust")
        remote:FireServer("PrepareSwing")
        remote:FireServer("HitZombieM", zombie, HitPos, true, HitPos, "Head", Direction)
    end
end

function L.sendSingleAttack(zombie)
    if not zombie or not zombie.Parent then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local weapon = nil
    for _, item in char:GetChildren() do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if item:GetAttribute("Melee") or name:find("musket") or name:find("flintlock") or name:find("bayonet") then
                weapon = item
                break
            end
        end
    end
    if not weapon then return false end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return false end
    local name = weapon.Name:lower()
    local isBayonet = name:find("musket") or name:find("flintlock") or name:find("bayonet")

    local head = zombie:FindFirstChild("Head")
    if not head then return false end
    local headPart = char:FindFirstChild("Head")
    local HitPos = head.Position
    local Direction = headPart and (HitPos - headPart.Position).Unit or v3new(0, 1, 0)
    pcall(function()
        L.fireMeleeHit(remote, isBayonet, zombie, HitPos, Direction)
    end)
    return true
end

function L.getCurrentKills()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local kills = leaderstats:FindFirstChild("Kills")
        if kills and (kills:IsA("IntValue") or kills:IsA("NumberValue")) then
            return kills.Value
        end
    end
    return 0
end

function L.updateSmartAura()
    if not L.smartAura.enabled then return end

    if not L.isHoldingMelee() then
        if L.smartAura.auraClosed then
            L.smartAura.auraClosed = false
            L.smartAura.probeMode = false
            L.smartAura.innerEntryKills = {}
            if not L.auraEnabled and not L.trackerAura.enabled then
                if auraMode == "常规" then L.startAura()
                elseif auraMode == "追踪" then L.trackerAura.start() end
            end
        end
        return
    end

    local innerRadius = mathMin(L.displayRange, L.INNER_RING_FIXED_RADIUS)
    local innerZombies = L.getZombiesInRadius(innerRadius)
    local now = tick_()
    local currentKills = L.getCurrentKills()

    if not L.smartAura.auraClosed then
        local currentSet = {}
        for _, z in innerZombies do
            currentSet[z] = true
            if not L.smartAura.innerEntryKills[z] then
                L.smartAura.innerEntryKills[z] = { time = now, kills = currentKills }
            end
        end
        for z in L.smartAura.innerEntryKills do
            if not currentSet[z] or not z.Parent then
                L.smartAura.innerEntryKills[z] = nil
            end
        end

        for z, data in L.smartAura.innerEntryKills do
            if z and z.Parent then
                local humanoid = z:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if now - data.time >= L.smartAura.killTimeout then
                        local killsNow = L.getCurrentKills()
                        if killsNow == data.kills then
                            L.smartAura.auraClosed = true
                            L.smartAura.probeMode = true
                            L.smartAura.retryTimer = 0
                            L.smartAura.innerEntryKills = {}
                            if L.auraEnabled then L.stopAura() end
                            if L.trackerAura.enabled then L.trackerAura.suspend = true end
                            break
                        else
                            L.smartAura.innerEntryKills[z] = nil
                        end
                    end
                else
                    L.smartAura.innerEntryKills[z] = nil
                end
            else
                L.smartAura.innerEntryKills[z] = nil
            end
        end
        return
    end

    if L.smartAura.probeMode then
        if now - L.smartAura.retryTimer >= L.smartAura.retryInterval then
            L.smartAura.retryTimer = now
            local target = L.getNearestNonBarrelZombie()
            if target then
                local beforeKills = L.getCurrentKills()
                L.sendSingleAttack(target)
                task.wait(2.0)
                local afterKills = L.getCurrentKills()
                if afterKills > beforeKills then
                    L.smartAura.auraClosed = false
                    L.smartAura.probeMode = false
                    L.smartAura.innerEntryKills = {}
                    L.trackerAura.suspend = false
                    if not L.auraEnabled and not L.trackerAura.enabled then
                        if auraMode == "常规" then L.startAura()
                        elseif auraMode == "追踪" then L.trackerAura.start() end
                    end
                end
            else
                L.smartAura.auraClosed = false
                L.smartAura.probeMode = false
                L.trackerAura.suspend = false
                if not L.auraEnabled and not L.trackerAura.enabled then
                    if auraMode == "常规" then L.startAura()
                    elseif auraMode == "追踪" then L.trackerAura.start() end
                end
            end
        end
    end
end

L.smartAuraThread = nil
function L.startSmartAuraThread()
    if L.smartAuraThread then return end
    L.smartAuraThread = task.spawn(function()
        while L.smartAura.enabled do
            pcall(L.updateSmartAura)
            task.wait(L.smartAura.checkInterval)
        end
    end)
end

function L.stopSmartAuraThread()
    if L.smartAuraThread then
        task.cancel(L.smartAuraThread)
        L.smartAuraThread = nil
    end
    L.smartAura.auraClosed = false
    L.smartAura.probeMode = false
    L.smartAura.innerEntryKills = {}
    L.smartAura.retryTimer = 0
end

L.attackLoop = function()
    while L.auraEnabled do
        if L.smartAura.enabled and L.smartAura.auraClosed then
            task.wait(0.1)
            continue
        end

        local weapon = L.getHeldMelee()
        if weapon then
            local name = weapon.Name:lower()
            local isBayonet = name:find("musket") or name:find("flintlock") or name:find("bayonet")
            local remote = weapon:FindFirstChild("RemoteEvent")
            local char2 = LocalPlayer.Character
            local headPart = char2 and char2:FindFirstChild("Head")
            local attackList = L.buildAttackTargets()
            if remote then
                for _, entry in attackList do
                    local zombie = entry.zombie
                    if zombie and zombie.Parent then
                        local head = zombie:FindFirstChild("Head")
                        if head then
                            local HitPos = head.Position
                            local Direction = headPart and (HitPos - headPart.Position).Unit or v3new(0, 1, 0)
                            pcall(function()
                                L.fireMeleeHit(remote, isBayonet, zombie, HitPos, Direction)
                            end)
                        end
                    end
                end
            end
            if #attackList > 0 then
                local targets = {}
                for _, entry in attackList do
                    table.insert(targets, entry.zombie)
                end
                L.currentAttackTargets = targets
            else
                L.currentAttackTargets = {}
            end
        else
            L.currentAttackTargets = {}
        end
        task.wait(0.05)
    end
end

L.startAura = function()
    if L.auraEnabled then return end
    L.auraEnabled = true
    if L.attackThread then task.cancel(L.attackThread) end
    L.attackThread = task.spawn(L.attackLoop)
end

L.stopAura = function()
    L.auraEnabled = false
    if L.attackThread then
        task.cancel(L.attackThread)
        L.attackThread = nil
    end
    L.currentAttackTargets = {}
end

L.rangeVisuals = {
    outerRingParts = {},
    outerRingBeams = {},
    innerRingParts = {},
    innerRingBeams = {},
    rayParts = {},
    rayEndParts = {},
    active = false,
    updateConn = nil,
    folder = nil,
    charAddedConn = nil,
    time = 0,
}

function L.clearRangeVisuals()
    if L.rangeVisuals.folder then
        L.rangeVisuals.folder:Destroy()
        L.rangeVisuals.folder = nil
    end
    L.rangeVisuals.outerRingParts = {}
    L.rangeVisuals.outerRingBeams = {}
    L.rangeVisuals.innerRingParts = {}
    L.rangeVisuals.innerRingBeams = {}
    L.rangeVisuals.rayParts = {}
    L.rangeVisuals.rayEndParts = {}
    L.rangeVisuals.lastOuterColor = nil
    L.rangeVisuals.lastInnerColor = nil
    L.rangeVisuals.lastRayColor = nil
    L.rangeVisuals.lastShowRays = nil
    L.rangeVisuals.innerBeamsEnabled = nil
    if L.rangeVisuals.meleeCheckConn then
        L.rangeVisuals.meleeCheckConn:Disconnect()
        L.rangeVisuals.meleeCheckConn = nil
    end
    if L.rangeVisuals.ancestryConn then
        L.rangeVisuals.ancestryConn:Disconnect()
        L.rangeVisuals.ancestryConn = nil
    end
    L.rangeVisuals.cachedHoldingMelee = nil
end

function L.createRangeVisuals()
    L.clearRangeVisuals()
    local folder = Instance.new("Folder")
    folder.Name = "KillAuraRangeVisuals"
    folder.Parent = workspace

    local outerNum = 24
    local innerNum = 12

    local outerRingParts = {}
    for i = 1, outerNum do
        local part = Instance.new("Part")
        part.Size = v3new(0.7, 0.7, 0.7)
        part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 0.1
        part.Color = c3rgb(0, 255, 100)
        part.Parent = folder
        table.insert(outerRingParts, part)
    end
    local outerRingBeams = {}
    for i = 1, outerNum do
        local j = (i % outerNum) + 1
        local att0 = Instance.new("Attachment")
        att0.Parent = outerRingParts[i]
        local att1 = Instance.new("Attachment")
        att1.Parent = outerRingParts[j]
        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Color = ColorSequence.new(c3rgb(0, 255, 100))
        beam.Width0 = 0.15
        beam.Width1 = 0.15
        beam.FaceCamera = true
        beam.Parent = folder
        table.insert(outerRingBeams, {beam = beam, att0 = att0, att1 = att1})
    end

    local innerRingParts = {}
    for i = 1, innerNum do
        local part = Instance.new("Part")
        part.Size = v3new(0.5, 0.5, 0.5)
        part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 0.2
        part.Color = c3rgb(0, 255, 100)
        part.Parent = folder
        table.insert(innerRingParts, part)
    end
    local innerRingBeams = {}
    for i = 1, innerNum do
        local j = (i % innerNum) + 1
        local att0 = Instance.new("Attachment")
        att0.Parent = innerRingParts[i]
        local att1 = Instance.new("Attachment")
        att1.Parent = innerRingParts[j]
        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Color = ColorSequence.new(c3rgb(0, 255, 100))
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.FaceCamera = true
        beam.Parent = folder
        table.insert(innerRingBeams, {beam = beam, att0 = att0, att1 = att1})
    end

    local rayParts = {}
    local rayEndParts = {}
    for i = 1, 2 do
        local startAtt = Instance.new("Attachment")
        startAtt.Parent = folder
        local endAtt = Instance.new("Attachment")
        endAtt.Parent = folder
        local beam = Instance.new("Beam")
        beam.Attachment0 = startAtt
        beam.Attachment1 = endAtt
        beam.Color = ColorSequence.new(c3rgb(0, 255, 100))
        beam.Width0 = 0.25
        beam.Width1 = 0.15
        beam.FaceCamera = true
        beam.Parent = folder
        table.insert(rayParts, {start = startAtt, finish = endAtt, beam = beam})

        local endMarker = Instance.new("Part")
        endMarker.Size = v3new(0.5, 0.5, 0.5)
        endMarker.Shape = Enum.PartType.Ball
        endMarker.Material = Enum.Material.Neon
        endMarker.Anchored = true
        endMarker.CanCollide = false
        endMarker.CanTouch = false
        endMarker.CanQuery = false
        endMarker.Transparency = 0.15
        endMarker.Color = c3rgb(0, 255, 100)
        endMarker.Parent = folder
        table.insert(rayEndParts, endMarker)
    end

    L.rangeVisuals.folder = folder
    L.rangeVisuals.outerRingParts = outerRingParts
    L.rangeVisuals.outerRingBeams = outerRingBeams
    L.rangeVisuals.innerRingParts = innerRingParts
    L.rangeVisuals.innerRingBeams = innerRingBeams
    L.rangeVisuals.rayParts = rayParts
    L.rangeVisuals.rayEndParts = rayEndParts
end

local function hasTargetInRange(pos, lookVec, radius, angle)
    local halfAngle = angle / 2
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if zombiesFolder then
        for _, z in zombiesFolder:GetChildren() do
            if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
                local zPos = z.HumanoidRootPart.Position
                local dist = (zPos - pos).Magnitude
                if dist <= radius then
                    if angle >= 360 then return true end
                    local dirToTarget = (zPos - pos).Unit
                    local forward = lookVec
                    local dot = forward:Dot(dirToTarget)
                    local ang = math.deg(math.acos(mathClamp(dot, -1, 1)))
                    if ang <= halfAngle then
                        return true
                    end
                end
            end
        end
    end
    if L.attackDraculaEnabled then
        local dracula = findPath(workspace, "Transylvania", "Modes", "Boss", "Dracula")
        if dracula and dracula:FindFirstChild("HumanoidRootPart") then
            local dPos = dracula.HumanoidRootPart.Position
            local dist = (dPos - pos).Magnitude
            if dist <= radius then
                if angle >= 360 then return true end
                local dirToTarget = (dPos - pos).Unit
                local forward = lookVec
                local dot = forward:Dot(dirToTarget)
                local ang = math.deg(math.acos(mathClamp(dot, -1, 1)))
                if ang <= halfAngle then
                    return true
                end
            end
        end
    end
    return false
end

function L.updateRangeVisuals()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pos = root.Position
    local lookVec = root.CFrame.LookVector
    local angle = L.attackAngle
    local halfAngle = angle / 2

    local outerRadius = L.displayRange
    local innerRadius = L.INNER_RING_FIXED_RADIUS

    L.rangeVisuals.time = (L.rangeVisuals.time or 0) + 0.016
    local t = L.rangeVisuals.time

    local holdingMelee = L.rangeVisuals.cachedHoldingMelee
    if holdingMelee == nil then
        holdingMelee = L.isHoldingMelee()
        L.rangeVisuals.cachedHoldingMelee = holdingMelee
    end
    local showInner = (outerRadius > innerRadius) and holdingMelee

    local hasOuter = hasTargetInRange(pos, lookVec, outerRadius, angle)
    local hasInner = false
    if showInner then
        hasInner = hasTargetInRange(pos, lookVec, innerRadius, angle)
    end

    local outerColor = hasOuter and c3rgb(255, 50, 50) or c3rgb(0, 255, 100)
    local innerColor = hasInner and c3rgb(255, 50, 50) or c3rgb(0, 255, 100)

    local floatOffset = math.sin(t * 1.0) * 0.3
    local outerRotSpeed = 0.3
    local innerRotSpeed = 0.6
    local outerRotOffset = t * outerRotSpeed
    local innerRotOffset = t * innerRotSpeed + 0.8

    local outerParts = L.rangeVisuals.outerRingParts
    local outerNum = #outerParts
    local outerTransparency = hasOuter and 0.08 or 0.15
    for i = 1, outerNum do
        local a = (i / outerNum) * 2 * math.pi + outerRotOffset
        local dir = v3new(math.cos(a), 0, math.sin(a))
        local ringPos = pos + dir * outerRadius
        ringPos = v3new(ringPos.X, pos.Y + floatOffset, ringPos.Z)
        outerParts[i].Position = ringPos
        outerParts[i].Color = outerColor
        outerParts[i].Transparency = outerTransparency
    end
    if L.rangeVisuals.lastOuterColor ~= outerColor then
        L.rangeVisuals.lastOuterColor = outerColor
        local outerColorSeq = ColorSequence.new(outerColor)
        for _, beamData in L.rangeVisuals.outerRingBeams do
            beamData.beam.Color = outerColorSeq
        end
    end

    local innerParts = L.rangeVisuals.innerRingParts
    local innerNum = #innerParts
    local innerFloatOffset = math.sin(t * 1.0 + 1.2) * 0.3
    if showInner then
        local innerTransparency = hasInner and 0.12 or 0.25
        for i = 1, innerNum do
            local a = (i / innerNum) * 2 * math.pi + innerRotOffset
            local dir = v3new(math.cos(a), 0, math.sin(a))
            local ringPos = pos + dir * innerRadius
            ringPos = v3new(ringPos.X, pos.Y + innerFloatOffset, ringPos.Z)
            innerParts[i].Position = ringPos
            innerParts[i].Color = innerColor
            innerParts[i].Transparency = innerTransparency
        end
        if L.rangeVisuals.lastInnerColor ~= innerColor or not L.rangeVisuals.innerBeamsEnabled then
            L.rangeVisuals.lastInnerColor = innerColor
            L.rangeVisuals.innerBeamsEnabled = true
            local innerColorSeq = ColorSequence.new(innerColor)
            for _, beamData in L.rangeVisuals.innerRingBeams do
                beamData.beam.Color = innerColorSeq
                beamData.beam.Enabled = true
            end
        end
    elseif L.rangeVisuals.innerBeamsEnabled ~= false then
        L.rangeVisuals.innerBeamsEnabled = false
        L.rangeVisuals.lastInnerColor = nil
        for i = 1, innerNum do
            innerParts[i].Color = c3rgb(0, 0, 0)
            innerParts[i].Transparency = 1
        end
        for _, beamData in L.rangeVisuals.innerRingBeams do
            beamData.beam.Enabled = false
        end
    end

    local showRays = angle < 360
    if showRays ~= L.rangeVisuals.lastShowRays then
        L.rangeVisuals.lastShowRays = showRays
        if not showRays then
            for i, rayData in L.rangeVisuals.rayParts do
                rayData.beam.Enabled = false
                if L.rangeVisuals.rayEndParts[i] then
                    L.rangeVisuals.rayEndParts[i].Transparency = 1
                end
            end
        end
    end
    if showRays then
        for i, rayData in L.rangeVisuals.rayParts do
            local angleOffset = (i == 1) and -halfAngle or halfAngle
            local dir = cfNew(v3new(0,0,0), lookVec) * CFrame.Angles(0, mathRad(angleOffset), 0)
            local worldDir = dir.LookVector
            local endPos = pos + worldDir * outerRadius
            endPos = v3new(endPos.X, pos.Y, endPos.Z)
            local startPos = v3new(pos.X, pos.Y, pos.Z)
            rayData.start.Position = startPos
            rayData.finish.Position = endPos
            rayData.beam.Enabled = true

            if L.rangeVisuals.rayEndParts[i] then
                local marker = L.rangeVisuals.rayEndParts[i]
                marker.Position = endPos
                marker.Transparency = 0.15
            end
        end
        if L.rangeVisuals.lastOuterColor ~= L.rangeVisuals.lastRayColor then
            L.rangeVisuals.lastRayColor = outerColor
            local rayColorSeq = ColorSequence.new(outerColor)
            for i, rayData in L.rangeVisuals.rayParts do
                rayData.beam.Color = rayColorSeq
                if L.rangeVisuals.rayEndParts[i] then
                    L.rangeVisuals.rayEndParts[i].Color = outerColor
                end
            end
        end
    end
end

local auraMasterEnabled = false

function L.startRangeVisuals()
    if L.rangeVisuals.active then return end
    L.rangeVisuals.active = true
    L.rangeVisuals.time = 0
    L.createRangeVisuals()
    if L.rangeVisuals.updateConn then L.rangeVisuals.updateConn:Disconnect() end
    L.rangeVisuals.updateConn = RunService.RenderStepped:Connect(function()
        if L.rangeVisuals.active and (L.showRangeVisuals or auraMasterEnabled) then
            L.updateRangeVisuals()
        end
    end)

    if L.rangeVisuals.charAddedConn then L.rangeVisuals.charAddedConn:Disconnect() end

    local player = LocalPlayer

    local function hookMeleeTracking(char)
        if L.rangeVisuals.meleeCheckConn then
            L.rangeVisuals.meleeCheckConn:Disconnect()
            L.rangeVisuals.meleeCheckConn = nil
        end
        L.rangeVisuals.cachedHoldingMelee = L.isHoldingMelee()
        local addedConn = char.ChildAdded:Connect(function()
            L.rangeVisuals.cachedHoldingMelee = nil
        end)
        local removedConn = char.ChildRemoved:Connect(function()
            L.rangeVisuals.cachedHoldingMelee = nil
        end)
        L.rangeVisuals.meleeCheckConn = {
            Disconnect = function()
                addedConn:Disconnect()
                removedConn:Disconnect()
            end
        }
    end

    if player.Character then
        hookMeleeTracking(player.Character)
    end

    L.rangeVisuals.charAddedConn = L.onCharacterAdded(function(newChar)
        task.wait(0.2)
        if L.rangeVisuals.active then
            L.createRangeVisuals()
            hookMeleeTracking(newChar)
        end
    end)

    if L.rangeVisuals.ancestryConn then
        L.rangeVisuals.ancestryConn:Disconnect()
        L.rangeVisuals.ancestryConn = nil
    end
    local function onCharacterRemoving()
        L.clearRangeVisuals()
    end
    if player.Character then
        L.rangeVisuals.ancestryConn = player.Character.AncestryChanged:Connect(function(_, parent)
            if not parent then
                onCharacterRemoving()
            end
        end)
    end
end

function L.stopRangeVisuals()
    L.rangeVisuals.active = false
    if L.rangeVisuals.updateConn then
        L.rangeVisuals.updateConn:Disconnect()
        L.rangeVisuals.updateConn = nil
    end
    if L.rangeVisuals.charAddedConn then
        L.rangeVisuals.charAddedConn()
        L.rangeVisuals.charAddedConn = nil
    end
    L.clearRangeVisuals()
end

function L.createIndicator(zombie)
    if not zombie or not zombie.Parent then return nil end
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso")
    if not root then return nil end

    local normalSize = 50
    local startSize = normalSize * 2

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AttackTargetIndicator"
    billboard.Size = UDim2.new(0, startSize, 0, startSize)
    billboard.StudsOffset = v3new(0, 0, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    billboard.Parent = zombie

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    local outerFrame = Instance.new("Frame")
    outerFrame.Size = UDim2.new(1, 0, 1, 0)
    outerFrame.BackgroundTransparency = 1
    outerFrame.Parent = container
    local outerStroke = Instance.new("UIStroke")
    outerStroke.Thickness = 2
    outerStroke.Color = c3rgb(255, 255, 255)
    outerStroke.Transparency = 0.6
    outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerStroke.Parent = outerFrame
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outerFrame

    local scanLine = Instance.new("Frame")
    scanLine.Size = UDim2.new(0, 1.5, 0, normalSize * 0.9)
    scanLine.BackgroundColor3 = c3rgb(255, 255, 255)
    scanLine.BackgroundTransparency = 0.7
    scanLine.Position = UDim2.new(0.5, -0.75, 0.5, -normalSize * 0.45)
    scanLine.Parent = container
    local scanGradient = Instance.new("UIGradient")
    scanGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(1, 0.2)
    }
    scanGradient.Rotation = 90
    scanGradient.Parent = scanLine
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 2)
    scanCorner.Parent = scanLine

    local innerFrame = Instance.new("Frame")
    innerFrame.Size = UDim2.new(0.7, 0, 0.7, 0)
    innerFrame.BackgroundTransparency = 1
    innerFrame.Parent = container
    innerFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Thickness = 1.5
    innerStroke.Color = c3rgb(255, 215, 0)
    innerStroke.Transparency = 0.6
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Parent = innerFrame
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(1, 0)
    innerCorner.Parent = innerFrame

    local cornerSize = 6
    local cornerOffset = 0.45
    local function createCorner(parent, xScale, yScale, rotation)
        local group = Instance.new("Frame")
        group.Size = UDim2.new(0, cornerSize, 0, cornerSize)
        group.BackgroundTransparency = 1
        group.Position = UDim2.new(0.5 + xScale * cornerOffset, -cornerSize/2, 0.5 + yScale * cornerOffset, -cornerSize/2)
        group.Rotation = rotation
        group.Parent = parent

        local h = Instance.new("Frame")
        h.Size = UDim2.new(1, 0, 0, 1.5)
        h.BackgroundColor3 = c3rgb(255, 255, 255)
        h.BackgroundTransparency = 0.3
        h.Position = UDim2.new(0, 0, 0, 0)
        h.Parent = group

        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 1.5, 1, 0)
        v.BackgroundColor3 = c3rgb(255, 255, 255)
        v.BackgroundTransparency = 0.3
        v.Position = UDim2.new(0, 0, 0, 0)
        v.Parent = group

        return group
    end

    local corners = {}
    local cornerPos = {
        {-1, -1, 0},
        {1, -1, 90},
        {-1, 1, -90},
        {1, 1, 180}
    }
    for _, pos in cornerPos do
        local c = createCorner(container, pos[1], pos[2], pos[3])
        table.insert(corners, c)
    end

    local crossGroup = Instance.new("Frame")
    crossGroup.Size = UDim2.new(0, 10, 0, 10)
    crossGroup.BackgroundTransparency = 1
    crossGroup.Position = UDim2.new(0.5, -5, 0.5, -5)
    crossGroup.Parent = container

    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1, 0, 0, 1.5)
    hLine.BackgroundColor3 = c3rgb(255, 255, 255)
    hLine.BackgroundTransparency = 0.4
    hLine.Position = UDim2.new(0, 0, 0.5, -0.75)
    hLine.Parent = crossGroup
    local vLine = Instance.new("Frame")
    vLine.Size = UDim2.new(0, 1.5, 1, 0)
    vLine.BackgroundColor3 = c3rgb(255, 255, 255)
    vLine.BackgroundTransparency = 0.4
    vLine.Position = UDim2.new(0.5, -0.75, 0, 0)
    vLine.Parent = crossGroup

    return {
        gui = billboard,
        container = container,
        outerFrame = outerFrame,
        outerStroke = outerStroke,
        innerFrame = innerFrame,
        innerStroke = innerStroke,
        scanLine = scanLine,
        corners = corners,
        crossGroup = crossGroup,
        currentAlpha = 0.8,
        targetAlpha = 0,
        currentSize = startSize,
        targetSize = normalSize,
        normalSize = normalSize,
        state = "fadein"
    }
end

function L.startIndicatorUpdater()
    if L.indicatorUpdateConn then return end
    L.indicatorUpdateConn = RunService.RenderStepped:Connect(function(dt)
        local currentTargets = L.currentAttackTargets or {}
        local indicatorData = L.indicatorData

        local targetSet = {}
        for _, z in currentTargets do
            if z and z.Parent then
                targetSet[z] = true
            end
        end

        for zombie, data in indicatorData do
            if not zombie.Parent or not targetSet[zombie] then
                if data.state ~= "fadeout" then
                    data.state = "fadeout"
                    data.targetAlpha = 0.8
                    data.targetSize = data.normalSize * 2
                end
            else
                if data.state == "fadeout" then
                    data.state = "active"
                    data.targetAlpha = 0
                    data.targetSize = data.normalSize
                elseif data.state == "fadein" and data.currentAlpha <= 0.02 and mathAbs(data.currentSize - data.normalSize) < 0.5 then
                    data.state = "active"
                else
                    data.state = "active"
                    data.targetAlpha = 0
                    data.targetSize = data.normalSize
                end
            end

            if data.state == "active" then
                local breath = math.sin(tick_() * 2.5) * 1.5
                data.targetSize = data.normalSize + breath

                if data.scanLine then
                    data.scanLine.Rotation = (data.scanLine.Rotation or 0) + dt * 120
                end
                data.innerFrame.Rotation = (data.innerFrame.Rotation or 0) + dt * 80
                local hue = (tick_() % 3) / 3
                data.innerStroke.Color = Color3.fromHSV(hue, 1, 1)
                local breathAlpha = math.sin(tick_() * 2) * 0.3 + 0.6
                data.outerStroke.Transparency = breathAlpha
                local cornerAlpha = math.sin(tick_() * 1.8 + 1) * 0.3 + 0.5
                for _, corner in data.corners do
                    for _, child in corner:GetChildren() do
                        if child:IsA("Frame") then
                            child.BackgroundTransparency = cornerAlpha
                        end
                    end
                end
                local crossAlpha = math.sin(tick_() * 2.2 + 0.5) * 0.2 + 0.4
                if data.crossGroup then
                    for _, child in data.crossGroup:GetChildren() do
                        if child:IsA("Frame") then
                            child.BackgroundTransparency = crossAlpha
                        end
                    end
                end
                if data.scanLine then
                    local scanAlpha = math.sin(tick_() * 4) * 0.2 + 0.6
                    data.scanLine.BackgroundTransparency = scanAlpha
                end
            else
                if data.state == "fadein" or data.state == "fadeout" then
                    data.innerStroke.Color = c3rgb(255, 215, 0)
                    data.outerStroke.Transparency = 0.8
                    if data.scanLine then
                        data.scanLine.Rotation = 0
                        data.scanLine.BackgroundTransparency = 0.7
                    end
                    for _, corner in data.corners do
                        for _, child in corner:GetChildren() do
                            if child:IsA("Frame") then
                                child.BackgroundTransparency = 0.3
                            end
                        end
                    end
                    if data.crossGroup then
                        for _, child in data.crossGroup:GetChildren() do
                            if child:IsA("Frame") then
                                child.BackgroundTransparency = 0.4
                            end
                        end
                    end
                end
            end

            local speed = 3.0
            if data.currentAlpha < data.targetAlpha then
                data.currentAlpha = mathMin(data.currentAlpha + speed * dt, data.targetAlpha)
            elseif data.currentAlpha > data.targetAlpha then
                data.currentAlpha = mathMax(data.currentAlpha - speed * dt, data.targetAlpha)
            end
            if data.currentSize < data.targetSize then
                data.currentSize = mathMin(data.currentSize + speed * 60 * dt, data.targetSize)
            elseif data.currentSize > data.targetSize then
                data.currentSize = mathMax(data.currentSize - speed * 60 * dt, data.targetSize)
            end
            if data.gui and data.gui.Parent then
                local sz = mathMax(data.currentSize, 1)
                data.gui.Size = UDim2.new(0, sz, 0, sz)
            end
            if data.state == "fadeout" and data.currentAlpha >= 0.78 and data.currentSize >= data.normalSize * 1.9 then
                if data.gui and data.gui.Parent then
                    data.gui:Destroy()
                end
                indicatorData[zombie] = nil
            end
        end

        for _, zombie in currentTargets do
            if zombie and zombie.Parent and not indicatorData[zombie] then
                local newData = L.createIndicator(zombie)
                if newData then
                    indicatorData[zombie] = newData
                end
            end
        end
    end)
end

function L.stopIndicatorUpdater()
    if L.indicatorUpdateConn then
        L.indicatorUpdateConn:Disconnect()
        L.indicatorUpdateConn = nil
    end
    for zombie, data in L.indicatorData do
        if data.gui and data.gui.Parent then
            data.gui:Destroy()
        end
    end
    L.indicatorData = {}
    L.currentAttackTargets = {}
end

local function getActualRange()
    return L.displayRange
end

local function hasZombieWithin20()
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return false end
    local pos = root.Position
    for _, z in zombiesFolder:GetChildren() do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
            if (z.HumanoidRootPart.Position - pos).Magnitude <= 20 then
                return true
            end
        end
    end
    return false
end

function L.getHeldMelee()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, item in char:GetChildren() do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if item:GetAttribute("Melee") or name:find("musket") or name:find("flintlock") or name:find("bayonet") then
                return item
            end
        end
    end
    if L.autoEquipWeaponEnabled and hasZombieWithin20() then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in backpack:GetChildren() do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if item:GetAttribute("Melee") or name:find("musket") or name:find("flintlock") or name:find("bayonet") then
                        item.Parent = char
                        task.wait(0.05)
                        return item
                    end
                end
            end
        end
    end
    return nil
end

local function shouldAttackBarrel(zombie)
    local isBarrel = zombie:GetAttribute("Type") == "Barrel" or zombie:FindFirstChild("Barrel") ~= nil
    return L.attackBarrelEnabled or not isBarrel
end

local function isTargetInAngle(myRoot, targetPos)
    if L.attackAngle >= 360 then return true end
    local dirToTarget = (targetPos - myRoot.Position).Unit
    local forward = myRoot.CFrame.LookVector
    local dot = forward:Dot(dirToTarget)
    local angle = math.deg(math.acos(mathClamp(dot, -1, 1)))
    return angle <= L.attackAngle / 2
end

function L.buildAttackTargets()
    local char = LocalPlayer.Character
    if not char then return {} end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return {} end

    local range = getActualRange()
    local barrels = {}
    local normals = {}

    local folder = workspace:FindFirstChild("Zombies")
    if not folder then return {} end

    for _, z in folder:GetChildren() do
        if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
            if L.skipSpawningEnabled then
                local state = z:FindFirstChild("State")
                if state and tostring(state.Value) == "Spawn" then
                    continue
                end
            end
            local isBarrel = z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel") ~= nil
            if not L.attackBarrelEnabled and isBarrel then
                continue
            end
            local zPos = z.HumanoidRootPart.Position
            local dist = (zPos - myRoot.Position).Magnitude
            if dist <= range and isTargetInAngle(myRoot, zPos) then
                local entry = {zombie = z, dist = dist}
                if isBarrel then
                    table.insert(barrels, entry)
                else
                    table.insert(normals, entry)
                end
            end
        end
    end

    table.sort(barrels, function(a, b) return a.dist < b.dist end)
    table.sort(normals, function(a, b) return a.dist < b.dist end)

    local attackList = {}
    local totalCount = L.attackCount or 2

    if totalCount >= 2 and #barrels > 0 and L.attackBarrelEnabled then
        table.insert(attackList, barrels[1])
        local remaining = mathMin(#normals, totalCount - 1)
        for i = 1, remaining do
            table.insert(attackList, normals[i])
        end
    else
        local candidates = {}
        if L.attackBarrelEnabled then
            local all = {}
            for _, v in barrels do table.insert(all, v) end
            for _, v in normals do table.insert(all, v) end
            table.sort(all, function(a, b) return a.dist < b.dist end)
            candidates = all
        else
            candidates = normals
        end
        local takeCount = mathMin(#candidates, totalCount)
        for i = 1, takeCount do
            table.insert(attackList, candidates[i])
        end
    end

    if L.attackDraculaEnabled then
        local dracula = findPath(workspace, "Transylvania", "Modes", "Boss", "Dracula")
        if dracula then
            local root = dracula:FindFirstChild("HumanoidRootPart")
            local head = dracula:FindFirstChild("Head")
            if root and head then
                local dPos = root.Position
                local dist = (dPos - myRoot.Position).Magnitude
                if dist <= range and isTargetInAngle(myRoot, dPos) then
                    table.insert(attackList, {zombie = dracula, dist = dist})
                end
            end
        end
    end

    return attackList
end

local auraMode = "常规"

L.trackerAura = {
    enabled = false,
    suspend = false,
    wallCheck = false,
    isInternal = false,
    fakeOffset = v3new(0, 0, 0),
    savedCF = nil,
    savedVel = nil,
    originalIndex = nil,
    camBindName = nil,
    heartbeatConn = nil,
    attackThread = nil,
    KEEP_DISTANCE = 5,
    BOMBER_SAFE_DIST = 15,
}

function L.trackerAura.findNearestZombie(myPos)
    local nearestZombie, nearestRoot, nearestDist = nil, nil, L.displayRange
    local folder = workspace:FindFirstChild("Zombies")
    if not folder then return nil, nil end

    local bomberPositions = {}
    for _, z in folder:GetChildren() do
        if z:IsA("Model") then
            local isBarrel = z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel") ~= nil
            if isBarrel then
                local zr = z:FindFirstChild("HumanoidRootPart") or z:FindFirstChild("Torso") or z:FindFirstChild("Head")
                if zr then table.insert(bomberPositions, zr.Position) end
            end
        end
    end

    for _, z in folder:GetChildren() do
        if z:IsA("Model") then
            local skipThis = false
            if L.skipSpawningEnabled then
                local state = z:FindFirstChild("State")
                if state and tostring(state.Value) == "Spawn" then
                    skipThis = true
                end
            end
            if not skipThis then
                local isBarrel = z:GetAttribute("Type") == "Barrel" or z:FindFirstChild("Barrel") ~= nil
                if not (isBarrel and not L.attackBarrelEnabled) then
                    local zRoot = z:FindFirstChild("HumanoidRootPart") or z:FindFirstChild("Torso") or z:FindFirstChild("Head")
                    if zRoot then
                        local dist = (zRoot.Position - myPos).Magnitude
                        if dist <= nearestDist then
                            local safe = true
                            if not isBarrel then
                                for _, bpos in bomberPositions do
                                    if (zRoot.Position - bpos).Magnitude <= L.trackerAura.BOMBER_SAFE_DIST then
                                        safe = false
                                        break
                                    end
                                end
                            end
                            if safe and L.trackerAura.wallCheck then
                                local params = RaycastParams.new()
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                local ignoreList = {}
                                for _, pl in Players:GetPlayers() do
                                    if pl.Character then table.insert(ignoreList, pl.Character) end
                                end
                                params.FilterDescendantsInstances = ignoreList
                                local result = workspace:Raycast(myPos, zRoot.Position - myPos, params)
                                if result then safe = false end
                            end
                            if safe then
                                nearestDist = dist
                                nearestZombie = z
                                nearestRoot = zRoot
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestZombie, nearestRoot
end

function L.trackerAura.onHeartbeat()
    if not L.trackerAura.enabled or L.trackerAura.suspend then
        L.trackerAura.fakeOffset = v3new(0, 0, 0)
        return
    end
    local char = LocalPlayer.Character
    if not char then
        L.trackerAura.fakeOffset = v3new(0, 0, 0)
        return
    end
    local i = char:FindFirstChild("HumanoidRootPart")
    if not i then
        L.trackerAura.fakeOffset = v3new(0, 0, 0)
        return
    end

    L.trackerAura.isInternal = true
    local realCF = i.CFrame
    local realVel = i.AssemblyLinearVelocity
    L.trackerAura.isInternal = false

    local myPos = realCF.Position
    local zombie, root = L.trackerAura.findNearestZombie(myPos)

    if root then
        local zombiePos = root.Position
        local dir = myPos - zombiePos
        if dir.Magnitude < 0.01 then
            dir = v3new(0, 0, -1)
        else
            dir = dir.Unit
        end
        local targetPos = zombiePos + dir * L.trackerAura.KEEP_DISTANCE
        L.trackerAura.fakeOffset = targetPos - myPos
    else
        L.trackerAura.fakeOffset = v3new(0, 0, 0)
    end

    L.trackerAura.savedCF = realCF
    L.trackerAura.savedVel = realVel

    L.trackerAura.isInternal = true
    i.CFrame = realCF + L.trackerAura.fakeOffset
    i.AssemblyLinearVelocity = v3new(0, 0, 0)
    L.trackerAura.isInternal = false

    RunService.RenderStepped:Wait()

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        L.trackerAura.isInternal = true
        LocalPlayer.Character.HumanoidRootPart.CFrame = realCF
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = realVel
        L.trackerAura.isInternal = false
    end
end

function L.trackerAura.attackLoop()
    while L.trackerAura.enabled do
        if L.smartAura.enabled and L.smartAura.auraClosed then
            task.wait(0.1)
            continue
        end

        local weapon = L.getHeldMelee()
        if not weapon then
            L.currentAttackTargets = {}
            task.wait(0.1)
            continue
        end

        local char = LocalPlayer.Character
        if not char then
            L.currentAttackTargets = {}
            task.wait(0.1)
            continue
        end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            L.currentAttackTargets = {}
            task.wait(0.1)
            continue
        end

        L.trackerAura.isInternal = true
        local myPos = myRoot.Position
        L.trackerAura.isInternal = false

        local zombie = L.trackerAura.findNearestZombie(myPos)
        if zombie then
            local name = weapon.Name:lower()
            local isBayonet = name:find("musket") or name:find("flintlock") or name:find("bayonet")
            local remote = weapon:FindFirstChild("RemoteEvent")
            if remote then
                local head = zombie:FindFirstChild("Head")
                if head then
                    local headPart = char:FindFirstChild("Head")
                    local HitPos = head.Position
                    local Direction = headPart and (HitPos - headPart.Position).Unit or v3new(0, 1, 0)
                    pcall(function()
                        L.fireMeleeHit(remote, isBayonet, zombie, HitPos, Direction)
                    end)
                end
            end
            L.currentAttackTargets = {zombie}
        else
            L.currentAttackTargets = {}
        end
        task.wait(0.05)
    end
    L.currentAttackTargets = {}
end

function L.trackerAura.installHook()
    if L.trackerAura.originalIndex then return end
    if type(hookmetamethod) ~= "function" then return end
    L.trackerAura.originalIndex = hookmetamethod(game, "__index", newcclosure(function(self, l)
        if L.trackerAura.enabled and not L.trackerAura.suspend and not L.trackerAura.isInternal then
            if not checkcaller() then
                if l == "CFrame"
                    and LocalPlayer.Character
                    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    and LocalPlayer.Character:FindFirstChild("Humanoid")
                    and LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
                    if self == LocalPlayer.Character.HumanoidRootPart then
                        return (L.trackerAura.savedCF or CFrame.new()) + L.trackerAura.fakeOffset
                    elseif self == LocalPlayer.Character.Head then
                        local m = L.trackerAura.savedCF or CFrame.new()
                        return m + L.trackerAura.fakeOffset
                            + v3new(0, LocalPlayer.Character.HumanoidRootPart.Size / 2 + 0.5, 0)
                    end
                end
            end
        end
        return L.trackerAura.originalIndex(self, l)
    end))
end

function L.trackerAura.removeHook()
    if L.trackerAura.originalIndex then
        pcall(function() hookmetamethod(game, "__index", L.trackerAura.originalIndex) end)
        L.trackerAura.originalIndex = nil
    end
end

function L.trackerAura.installCamFix()
    if L.trackerAura.camBindName then return end
    L.trackerAura.camBindName = "FakePosCamFix_Tracker"
    pcall(function()
        RunService:BindToRenderStep(
            L.trackerAura.camBindName,
            Enum.RenderPriority.Camera.Value + 1,
            function()
                if L.trackerAura.enabled and not L.trackerAura.suspend and LocalPlayer.Character then
                    local cam = workspace.CurrentCamera
                    if cam then
                        cam.CFrame = cam.CFrame - L.trackerAura.fakeOffset
                    end
                end
            end
        )
    end)
end

function L.trackerAura.removeCamFix()
    if L.trackerAura.camBindName then
        pcall(function() RunService:UnbindFromRenderStep(L.trackerAura.camBindName) end)
        L.trackerAura.camBindName = nil
    end
end

function L.trackerAura.start()
    if L.trackerAura.enabled then return end
    L.trackerAura.enabled = true
    L.trackerAura.suspend = false
    L.trackerAura.isInternal = false
    L.trackerAura.fakeOffset = v3new(0, 0, 0)
    L.trackerAura.savedCF = nil
    L.trackerAura.savedVel = nil
    L.trackerAura.installHook()
    L.trackerAura.installCamFix()
    if L.trackerAura.heartbeatConn then L.trackerAura.heartbeatConn:Disconnect() end
    L.trackerAura.heartbeatConn = RunService.Heartbeat:Connect(L.trackerAura.onHeartbeat)
    if L.trackerAura.attackThread then task.cancel(L.trackerAura.attackThread) end
    L.trackerAura.attackThread = task.spawn(L.trackerAura.attackLoop)
end

function L.trackerAura.stop()
    L.trackerAura.enabled = false
    L.trackerAura.suspend = false
    L.trackerAura.isInternal = false
    if L.trackerAura.heartbeatConn then
        pcall(function() L.trackerAura.heartbeatConn:Disconnect() end)
        L.trackerAura.heartbeatConn = nil
    end
    if L.trackerAura.attackThread then
        task.cancel(L.trackerAura.attackThread)
        L.trackerAura.attackThread = nil
    end
    L.trackerAura.fakeOffset = v3new(0, 0, 0)
    L.trackerAura.savedCF = nil
    L.trackerAura.savedVel = nil
    L.trackerAura.removeHook()
    L.trackerAura.removeCamFix()
end

function L.isAxeOrPickaxe(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local name = tool.Name:lower()
    if name:find("axe") or name:find("pickaxe") then return true end
    if name:find("斧") or name:find("镐") or name:find("稿") then return true end
    return false
end

L.regularAuraMonitor = nil

function L.startRegularAuraMonitor()
    if L.regularAuraMonitor then return end
    L.regularAuraMonitor = task.spawn(function()
        while auraMasterEnabled and auraMode == "常规" do
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and L.isAxeOrPickaxe(tool) then
                    if not L.auraEnabled then L.startAura() end
                    if L.qingShuiAura and L.qingShuiAura.enabled then L.stopQingShuiAura() end
                elseif tool and L.isMeleeOrBayonet(tool) then
                    if L.auraEnabled then L.stopAura() end
                    if not (L.qingShuiAura and L.qingShuiAura.enabled) then L.startQingShuiAura() end
                else
                    if L.auraEnabled then L.stopAura() end
                    if L.qingShuiAura and L.qingShuiAura.enabled then L.stopQingShuiAura() end
                end
            end
            task.wait(0.2)
        end
        L.regularAuraMonitor = nil
    end)
end

function L.stopRegularAuraMonitor()
    if L.regularAuraMonitor then
        task.cancel(L.regularAuraMonitor)
        L.regularAuraMonitor = nil
    end
end

RightGroup:AddDropdown('AuraMode', {
    Values = { "常规", "追踪" },
    Default = 1,
    Multi = false,
    Text = '杀戮光环模式',
    Tooltip = TranslateTooltip('选择杀戮光环模式（实时切换）'),
    Callback = function(Value)
        auraMode = Value
        L.stopRegularAuraMonitor()
        if L.auraEnabled then L.stopAura() end
        if L.qingShuiAura and L.qingShuiAura.enabled then L.stopQingShuiAura() end
        if L.trackerAura.enabled then L.trackerAura.stop() end
        L.trackerAura.suspend = false

        if auraMasterEnabled then
            if auraMode == "常规" then
                L.startRegularAuraMonitor()
            elseif auraMode == "追踪" then
                L.trackerAura.start()
            end
        end

        if L.updateAuraModeVisibility then L.updateAuraModeVisibility() end
    end
})

RightGroup:AddDivider()

RightGroup:AddToggle('AuraToggle', {
    Text = '开启杀戮光环',
    Default = false,
    Tooltip = TranslateTooltip('开启/关闭杀戮光环（根据下拉框选择的模式）'),
    Callback = function(Value)
        auraMasterEnabled = Value
        if L.auraEnabled then L.stopAura() end
        if L.qingShuiAura and L.qingShuiAura.enabled then L.stopQingShuiAura() end
        if L.trackerAura.enabled then L.trackerAura.stop() end
        L.stopRegularAuraMonitor()
        L.trackerAura.suspend = false

        if Value then
            if auraMode == "常规" then
                L.startRegularAuraMonitor()
            elseif auraMode == "追踪" then
                L.trackerAura.start()
            end
            L.startIndicatorUpdater()
        else
            L.stopIndicatorUpdater()
        end
    end
})

local AuraTabbox = Tabs.Main:AddRightTabbox()
local AuraTargetTab = AuraTabbox:AddTab("目标选择")
local AuraAttackTab = AuraTabbox:AddTab("攻击设置")
local AuraEffectsTab = AuraTabbox:AddTab("命中特效")

AuraTargetTab:AddToggle('AttackBarrelToggle', {
    Text = '攻击自爆',
    Default = false,
    Tooltip = TranslateTooltip('开启后杀戮光环会攻击自爆僵尸'),
    Callback = function(Value)
        L.attackBarrelEnabled = Value
    end
})

AuraTargetTab:AddToggle('TrackerWallCheck', {
    Text = '墙体检测',
    Default = false,
    Tooltip = TranslateTooltip('开启后不追踪被墙体遮挡的僵尸'),
    Callback = function(Value)
        L.trackerAura.wallCheck = Value
    end
})

AuraTargetTab:AddToggle('AttackDraculaToggle', {
    Text = '攻击德古拉',
    Default = false,
    Tooltip = TranslateTooltip('开启后杀戮光环会同时攻击德古拉Boss'),
    Callback = function(Value)
        L.attackDraculaEnabled = Value
    end
})

AuraTargetTab:AddToggle('SkipSpawningToggle', {
    Text = '跳过正在生成的僵尸',
    Default = true,
    Tooltip = TranslateTooltip('开启后不会攻击正在生成的僵尸（减少误判）'),
    Callback = function(Value)
        L.skipSpawningEnabled = Value
    end
})

AuraTargetTab:AddToggle('ShowRangeToggle', {
    Text = '显示攻击范围',
    Default = false,
    Callback = function(Value)
        L.showRangeVisuals = Value
        if Value then
            L.startRangeVisuals()
        else
            L.stopRangeVisuals()
        end
    end
})

AuraTargetTab:AddToggle('SmartAuraToggle', {
    Text = '智能光环（卡伤检测）',
    Default = false,
    Tooltip = TranslateTooltip('检测内环僵尸2秒未击杀则自动关闭光环，探测击杀后自动恢复（仅手持斧头/稿子/战壕铲生效）'),
    Callback = function(Value)
        L.smartAura.enabled = Value
        if Value then
            L.startSmartAuraThread()
        else
            L.stopSmartAuraThread()
            if L.smartAura.auraClosed then
                L.smartAura.auraClosed = false
                L.smartAura.probeMode = false
                L.trackerAura.suspend = false
                if not L.auraEnabled and not L.trackerAura.enabled then
                    if auraMode == "常规" then L.startAura()
                    elseif auraMode == "追踪" then L.trackerAura.start() end
                end
            end
        end
    end
})

AuraTargetTab:AddToggle('AutoEquipToggle', {
    Text = '自动装备武器',
    Default = false,
    Tooltip = TranslateTooltip('靠近设定范围自动装备武器'),
    Callback = function(Value)
        L.autoEquipWeaponEnabled = Value
    end
})

AuraAttackTab:AddSlider('AuraRange', {
    Text = '攻击距离',
    Default = 35,
    Min = 10,
    Max = 75,
    Rounding = 0,
    Suffix = " 格",
    Callback = function(Value)
        L.displayRange = Value
    end
})

AuraAttackTab:AddSlider('AuraAngle', {
    Text = '攻击角度',
    Default = 180,
    Min = 50,
    Max = 360,
    Rounding = 0,
    Suffix = "°",
    Callback = function(Value)
        L.attackAngle = Value
    end
})

AuraAttackTab:AddSlider('AuraCount', {
    Text = '攻击数量',
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Suffix = " 个",
    Callback = function(Value)
        L.attackCount = Value
    end
})

function L.updateAuraModeVisibility()
    local isTracker = (auraMode == "追踪")

    local function setOptVisible(opt, visible)
        if not opt then return end
        pcall(function()
            if opt.Object and typeof(opt.Object) == "Instance" then
                opt.Object.Visible = visible
            end
            if opt.ToggleObject and typeof(opt.ToggleObject) == "Instance" then
                opt.ToggleObject.Visible = visible
            end
            if opt.SliderObject and typeof(opt.SliderObject) == "Instance" then
                opt.SliderObject.Visible = visible
            end
            if opt.Frame and typeof(opt.Frame) == "Instance" then
                opt.Frame.Visible = visible
            end
            if type(opt.Object) == "table" then
                for _, v in pairs(opt.Object) do
                    if typeof(v) == "Instance" and v.Visible ~= nil then
                        v.Visible = visible
                    end
                end
            end
        end)
    end

    setOptVisible(Toggles['TrackerWallCheck'], isTracker)
end

task.defer(function()
    task.wait(1)
    if L.updateAuraModeVisibility then L.updateAuraModeVisibility() end
end)

L.headshotEnabled = false
L.removeBloodEnabled = false
L.hookInstalled = false
L.originalBayonetHitCheck = nil
L.originalMeleeHitCheck = nil
L.lastZombieHitTime = {}
L.ZOMBIE_HIT_COOLDOWN = 0.1

local function getZombieModel(part)
    if not part then return nil end
    local model = part.Parent
    for i = 1, 5 do
        if not model then break end
        if model:IsA("Model") and (model.Name == "m_Zombie" or model:FindFirstChild("Orig")) then
            return model
        end
        model = model.Parent
    end
    return nil
end

local function getZombieHead(zombieModel)
    if not zombieModel then return nil end
    for _, part in zombieModel:GetChildren() do
        if part.Name == "Head" and (part:IsA("Part") or part:IsA("MeshPart")) then
            return part
        end
    end
    return nil
end

function L.unifiedBayonetHitCheck(self, origin, direction, raycastParams, hitEntities)
    local rp = (type(raycastParams) == "table" and raycastParams.ray) or raycastParams
    local rayResult = workspace:Raycast(origin, direction, rp)
    if rayResult then
        local hitPart = rayResult.Instance
        local zombieModel = getZombieModel(hitPart)
        if zombieModel then
            local now = tick_()
            if L.lastZombieHitTime[zombieModel] and now - L.lastZombieHitTime[zombieModel] < L.ZOMBIE_HIT_COOLDOWN then
                return 0
            end
            local orig = zombieModel:FindFirstChild("Orig")
            if orig then
                local head = getZombieHead(zombieModel)
                if head then
                    local zombieRef = orig.Value
                    local hitPos = head.Position
                    local partName = "Head"
                    if not L.headshotEnabled then
                        if hitPart == head then
                            partName = "Head"
                        else
                            partName = "Torso"
                        end
                    end
                    if L.removeBloodEnabled then
                        local rootPart = zombieModel:FindFirstChild("HumanoidRootPart") or zombieModel:FindFirstChild("Torso")
                        if rootPart then
                            hitPos = rootPart.Position + v3new(0, -9999, 0)
                        end
                    end
                    self.remoteEvent:FireServer("Bayonet_HitZombie", zombieRef, hitPos, true, partName, self.swingType)
                    zombieRef:SetAttribute("WepHitID", tick_())
                    zombieRef:SetAttribute("WepHitDirection", direction * 10)
                    zombieRef:SetAttribute("WepHitPos", hitPos)
                    L.lastZombieHitTime[zombieModel] = now
                    return 1
                end
            end
        end
    end
    if L.originalBayonetHitCheck then
        return L.originalBayonetHitCheck(self, origin, direction, raycastParams, hitEntities)
    end
    return 0
end

function L.unifiedMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
    local rp = (type(raycastParams) == "table" and raycastParams.ray) or raycastParams
    local rayResult = workspace:Raycast(origin, direction, rp)
    if rayResult then
        local hitPart = rayResult.Instance
        local zombieModel = getZombieModel(hitPart)
        if zombieModel then
            local now = tick_()
            if L.lastZombieHitTime[zombieModel] and now - L.lastZombieHitTime[zombieModel] < L.ZOMBIE_HIT_COOLDOWN then
                return 0
            end
            local orig = zombieModel:FindFirstChild("Orig")
            if orig then
                local head = getZombieHead(zombieModel)
                if head then
                    local zombieRef = orig.Value
                    local hitPos = head.Position
                    local partName = "Head"
                    if not L.headshotEnabled then
                        if hitPart == head then
                            partName = "Head"
                        else
                            partName = "Torso"
                        end
                    end
                    if L.removeBloodEnabled then
                        local rootPart = zombieModel:FindFirstChild("HumanoidRootPart") or zombieModel:FindFirstChild("Torso")
                        if rootPart then
                            hitPos = rootPart.Position + v3new(0, -9999, 0)
                        end
                    end
                    local char = LocalPlayer.Character
                    local headPart = char and char:FindFirstChild("Head")
                    local Direction = headPart and (hitPos - headPart.Position).Unit or v3new(0,1,0)
                    if isCharge then
                        self.remoteEvent:FireServer("ThrustCharge", zombieRef, hitPos, rayResult.Normal)
                    else
                        self.remoteEvent:FireServer("HitZombieM", zombieRef, hitPos, true, hitPos, partName, Direction)
                    end
                    L.lastZombieHitTime[zombieModel] = now
                    return 1
                end
            end
        end
    end
    if L.originalMeleeHitCheck then
        return L.originalMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
    end
    return 0
end

function L.updateHitHooks()
    local shouldHook = L.headshotEnabled or L.removeBloodEnabled
    local rs = ReplicatedStorage
    local weapons = rs:FindFirstChild("Modules") and rs.Modules:FindFirstChild("Weapons")
    local canHookFunction = type(hookfunction) == "function"
    if shouldHook and not L.hookInstalled then
        if weapons then
            local success, FlintLock = pcall(require, weapons:FindFirstChild("Flintlock"))
            if success and FlintLock and FlintLock.BayonetHitCheck then
                if canHookFunction then
                    if not L.originalBayonetHitCheck then
                        L.originalBayonetHitCheck = hookfunction(FlintLock.BayonetHitCheck, L.unifiedBayonetHitCheck)
                    else
                        hookfunction(FlintLock.BayonetHitCheck, L.unifiedBayonetHitCheck)
                    end
                else
                    if not L.originalBayonetHitCheck then
                        L.originalBayonetHitCheck = FlintLock.BayonetHitCheck
                    end
                    FlintLock.BayonetHitCheck = L.unifiedBayonetHitCheck
                end
            end
            local success2, MeleeBase = pcall(require, weapons:FindFirstChild("MeleeBase"))
            if success2 and MeleeBase and MeleeBase.MeleeHitCheck then
                if canHookFunction then
                    if not L.originalMeleeHitCheck then
                        L.originalMeleeHitCheck = hookfunction(MeleeBase.MeleeHitCheck, L.unifiedMeleeHitCheck)
                    else
                        hookfunction(MeleeBase.MeleeHitCheck, L.unifiedMeleeHitCheck)
                    end
                else
                    if not L.originalMeleeHitCheck then
                        L.originalMeleeHitCheck = MeleeBase.MeleeHitCheck
                    end
                    MeleeBase.MeleeHitCheck = L.unifiedMeleeHitCheck
                end
            end
        end
        L.hookInstalled = true
    elseif not shouldHook and L.hookInstalled then
        if weapons then
            if L.originalBayonetHitCheck then
                local success, FlintLock = pcall(require, weapons:FindFirstChild("Flintlock"))
                if success and FlintLock and FlintLock.BayonetHitCheck then
                    if canHookFunction then
                        hookfunction(FlintLock.BayonetHitCheck, L.originalBayonetHitCheck)
                    else
                        FlintLock.BayonetHitCheck = L.originalBayonetHitCheck
                    end
                end
            end
            if L.originalMeleeHitCheck then
                local success, MeleeBase = pcall(require, weapons:FindFirstChild("MeleeBase"))
                if success and MeleeBase then
                    if canHookFunction then
                        hookfunction(MeleeBase.MeleeHitCheck, L.originalMeleeHitCheck)
                    else
                        MeleeBase.MeleeHitCheck = L.originalMeleeHitCheck
                    end
                end
            end
        end
        L.hookInstalled = false
    end
end

local function onCharacterAddedForHeadshot()
    task.wait(1)
    L.updateHitHooks()
end
L.onCharacterAdded(onCharacterAddedForHeadshot)

AuraEffectsTab:AddToggle('RemoveBloodToggle', {
    Text = '移除血液粒子',
    Default = false,
    Tooltip = TranslateTooltip('将血迹生成位置移到僵尸脚下不可见处，不影响伤害'),
    Callback = function(Value)
        L.removeBloodEnabled = Value
        L.updateHitHooks()
    end
})

AuraEffectsTab:AddToggle('HeadshotToggle', {
    Text = '强制爆头',
    Default = false,
    Tooltip = TranslateTooltip('强制所有近战/刺刀攻击命中头部'),
    Callback = function(Value)
        L.headshotEnabled = Value
        L.updateHitHooks()
    end
})

L.zombieHitboxEnabled = false
L.zombieHitboxSize = 10
L.zombieHitboxAddedParts = {}

local function addHitboxesToZombie(zombie)
    if not L.zombieHitboxEnabled then return end
    if L.zombieHitboxAddedParts[zombie] then return end
    local hrp = zombie:FindFirstChild("HumanoidRootPart")
    local head = zombie:FindFirstChild("Head")
    if not hrp or not head then return end

    local outer = Instance.new("Part")
    outer.Name = "ZombieHitbox_Outer"
    outer.Size = v3new(L.zombieHitboxSize, L.zombieHitboxSize, L.zombieHitboxSize)
    outer.Transparency = 1
    outer.CanCollide = false
    outer.CanTouch = true
    outer.Massless = true
    outer.Anchored = false
    outer.CFrame = hrp.CFrame
    outer.Parent = zombie

    local weldOuter = Instance.new("WeldConstraint")
    weldOuter.Part0 = hrp
    weldOuter.Part1 = outer
    weldOuter.Parent = outer

    local headBox = Instance.new("Part")
    headBox.Name = "ZombieHitbox_Head"
    headBox.Size = v3new(L.zombieHitboxSize/2, L.zombieHitboxSize/2, L.zombieHitboxSize/2)
    headBox.Transparency = 1
    headBox.CanCollide = false
    headBox.CanTouch = true
    headBox.Massless = true
    headBox.Anchored = false
    headBox.CFrame = head.CFrame
    headBox.Parent = zombie

    local weldHead = Instance.new("WeldConstraint")
    weldHead.Part0 = head
    weldHead.Part1 = headBox
    weldHead.Parent = headBox

    L.zombieHitboxAddedParts[zombie] = { outer = outer, head = headBox }
end

local function removeHitboxesFromZombie(zombie)
    local parts = L.zombieHitboxAddedParts[zombie]
    if parts then
        if parts.outer then parts.outer:Destroy() end
        if parts.head then parts.head:Destroy() end
        L.zombieHitboxAddedParts[zombie] = nil
    else
        for _, child in zombie:GetChildren() do
            if child.Name == "ZombieHitbox_Outer" or child.Name == "ZombieHitbox_Head" then
                child:Destroy()
            end
        end
    end
end

local function refreshZombieHitboxes()
    if not L.zombieHitboxEnabled then
        local toRemove = {}
        for zombie, _ in L.zombieHitboxAddedParts do
            table.insert(toRemove, zombie)
        end
        for _, zombie in toRemove do
            removeHitboxesFromZombie(zombie)
        end
        L.zombieHitboxAddedParts = {}
        return
    end

    local allZombies = {}
    for _, z in L.ZombieWatch.getAll() do
        table.insert(allZombies, z)
    end

    local toRemove = {}
    for zombie, _ in L.zombieHitboxAddedParts do
        local stillExists = false
        for _, z in allZombies do
            if z == zombie then stillExists = true; break end
        end
        if not stillExists then
            table.insert(toRemove, zombie)
        end
    end
    for _, zombie in toRemove do
        removeHitboxesFromZombie(zombie)
    end

    for _, z in allZombies do
        if not L.zombieHitboxAddedParts[z] then
            addHitboxesToZombie(z)
        end
    end
end

local function updateAllZombieHitboxSizes()
    if not L.zombieHitboxEnabled then return end
    for zombie, parts in L.zombieHitboxAddedParts do
        if parts.outer and parts.outer.Parent then
            parts.outer.Size = v3new(L.zombieHitboxSize, L.zombieHitboxSize, L.zombieHitboxSize)
        end
        if parts.head and parts.head.Parent then
            parts.head.Size = v3new(L.zombieHitboxSize/2, L.zombieHitboxSize/2, L.zombieHitboxSize/2)
        end
    end
end

local function onZombieAdded(zombie)
    if L.zombieHitboxEnabled and zombie:IsA("Model") then
        task.wait(0.1)
        addHitboxesToZombie(zombie)
    end
end

L.ZombieWatch.start()
L.ZombieWatch.onAdded(onZombieAdded)

task.spawn(function()
    while true do
        task.wait(2)
        if L.zombieHitboxEnabled then
            refreshZombieHitboxes()
        end
    end
end)

AuraEffectsTab:AddToggle('ZombieHitboxToggle', {
    Text = '僵尸碰撞箱扩展',
    Default = false,
    Tooltip = TranslateTooltip('为僵尸添加更大的命中箱'),
    Callback = function(Value)
        L.zombieHitboxEnabled = Value
        if Value then
            refreshZombieHitboxes()
        else
            local toRemove = {}
            for zombie, _ in L.zombieHitboxAddedParts do
                table.insert(toRemove, zombie)
            end
            for _, zombie in toRemove do
                removeHitboxesFromZombie(zombie)
            end
            L.zombieHitboxAddedParts = {}
        end
    end
})

L.attackSpeedEnabled = false
L.attackSpeedMultiplier = 1
L.attackSpeedConn = nil

L.MELEE_WEAPON_SET = {
    ["Sabre"] = true,
    ["Le Revenant"] = true,
    ["Voivode"] = true,
    ["Axe"] = true,
    ["Hand Axe"] = true,
    ["Heavy Sabre"] = true,
    ["Boarding Axe"] = true,
    ["Stake"] = true,
    ["Pickaxe"] = true,
    ["Spade"] = true,
    ["Delicious Leg"] = true,
    ["Spontoon"] = true,
    ["Lance"] = true,
    ["Baguette"] = true,
    ["Sword Bayonet"] = true,
}

function L.isMeleeOrBayonet(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if L.MELEE_WEAPON_SET[tool.Name] then return true end
    if tool:GetAttribute("Melee") == true then return true end
    local name = tool.Name:lower()
    if name:find("sabre") or name:find("sword") or name:find("axe") or name:find("pickaxe")
        or name:find("spade") or name:find("shovel") or name:find("stake")
        or name:find("lance") or name:find("pike") or name:find("spontoon")
        or name:find("baguette") or name:find("bayonet") or name:find("revanant")
        or name:find("voivode") or name:find("leg") or name:find("稿")
        or name:find("铲") or name:find("镐") then
        return true
    end
    return false
end

AuraEffectsTab:AddSlider('ZombieHitboxSize', {
    Text = '碰撞箱大小',
    Default = 10,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Suffix = " 单位",
    Callback = function(Value)
        L.zombieHitboxSize = mathClamp(Value, 1, 30)
        if L.zombieHitboxEnabled then
            updateAllZombieHitboxSizes()
            refreshZombieHitboxes()
        end
    end
})

if not L.qingShuiAura then L.qingShuiAura = {} end
L.qingShuiAura.enabled = false
L.qingShuiAura.thread = nil
L.qingShuiAura.lastAttackTime = {}

function L.startQingShuiAura()
    if L.qingShuiAura.thread then return end
    L.qingShuiAura.enabled = true
    L.qingShuiAura.thread = task.spawn(function()
        while L.qingShuiAura.enabled do
            local weapon = L.getHeldMelee()
            if weapon then
                local char = LocalPlayer.Character
                if char then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        local range = getActualRange()
                        local zombies = {}
                        local folder = workspace:FindFirstChild("Zombies")
                        if folder then
                            for _, z in folder:GetChildren() do
                                if z:IsA("Model") and z:FindFirstChild("HumanoidRootPart") then
                                    if L.skipSpawningEnabled then
                                        local state = z:FindFirstChild("State")
                                        if state and tostring(state.Value) == "Spawn" then
                                            continue
                                        end
                                    end
                                    if not shouldAttackBarrel(z) then
                                        continue
                                    end
                                    local zPos = z.HumanoidRootPart.Position
                                    local dist = (zPos - myRoot.Position).Magnitude
                                    if dist <= range and isTargetInAngle(myRoot, zPos) then
                                        table.insert(zombies, {zombie = z, dist = dist})
                                    end
                                end
                            end
                        end
                        if L.attackDraculaEnabled then
                            local dracula = findPath(workspace, "Transylvania", "Modes", "Boss", "Dracula")
                            if dracula then
                                local root = dracula:FindFirstChild("HumanoidRootPart")
                                local head = dracula:FindFirstChild("Head")
                                if root and head then
                                    local dPos = root.Position
                                    local dist = (dPos - myRoot.Position).Magnitude
                                    if dist <= range and isTargetInAngle(myRoot, dPos) then
                                        table.insert(zombies, {zombie = dracula, dist = dist})
                                    end
                                end
                            end
                        end
                        table.sort(zombies, function(a,b) return a.dist < b.dist end)
                        local toAttack = mathMin(L.attackCount, #zombies)
                        local now = tick_()

                        for i = 1, toAttack do
                            local z = zombies[i].zombie
                            if not L.qingShuiAura.lastAttackTime[z] or (now - L.qingShuiAura.lastAttackTime[z] > 0.05) then
                                local remote = weapon:FindFirstChild("RemoteEvent")
                                if remote then
                                    local head = z:FindFirstChild("Head")
                                    if head then
                                        local char2 = LocalPlayer.Character
                                        local headPart = char2 and char2:FindFirstChild("Head")
                                        local HitPos = head.Position
                                        local Direction = headPart and (HitPos - headPart.Position).Unit or v3new(0,1,0)
                                        remote:FireServer("Swing", "Thrust")
                                        remote:FireServer("PrepareSwing")
                                        remote:FireServer("HitZombieM", z, HitPos, true, HitPos, "Head", Direction)
                                        L.qingShuiAura.lastAttackTime[z] = now
                                    end
                                end
                            end
                        end

                        if toAttack > 0 then
                            local targets = {}
                            for i = 1, toAttack do
                                if zombies[i] then
                                    table.insert(targets, zombies[i].zombie)
                                end
                            end
                            L.currentAttackTargets = targets
                        else
                            L.currentAttackTargets = {}
                        end
                    end
                end
            else
                L.currentAttackTargets = {}
            end
            task.wait(0.2)
        end
    end)
end

function L.stopQingShuiAura()
    L.qingShuiAura.enabled = false
    if L.qingShuiAura.thread then
        task.cancel(L.qingShuiAura.thread)
        L.qingShuiAura.thread = nil
    end
    L.qingShuiAura.lastAttackTime = {}
end

L.onCharacterAdded(function()
    task.wait(0.5)
    if L.showRangeVisuals then
        L.startRangeVisuals()
    end
end)

local function onLibraryUnload()
    L.stopRangeVisuals()
    L.stopIndicatorUpdater()
    L.stopSmartAuraThread()
    L.stopRegularAuraMonitor()
    if L.auraEnabled then L.stopAura() end
    if L.qingShuiAura and L.qingShuiAura.enabled then L.stopQingShuiAura() end
    if L.trackerAura and L.trackerAura.enabled then L.trackerAura.stop() end
end

Library:OnUnload(onLibraryUnload)

local MenuGroup = Tabs.Settings:AddLeftGroupbox('菜单')
MenuGroup:AddDropdown('InterfaceLanguage', {
    Text = '语言 / Language',
    Values = { '中文', 'English' },
    Default = 1,
    Callback = function(value)
        SetInterfaceLanguage(value)
    end,
})
Options.InterfaceLanguage:OnChanged(function()
    SetInterfaceLanguage(Options.InterfaceLanguage.Value)
end)
Library:OnUnload(function()
getgenv().SkinHubLoaded = nil
    local function safeDisconnect(conn)
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    safeDisconnect(L.autoCollectConnection)
    safeDisconnect(L.autoCannon and L.autoCannon.connection)
    safeDisconnect(L.autoBell and L.autoBell.conn)
    safeDisconnect(L.LondonBoardAuto and L.LondonBoardAuto.heartbeat)
    safeDisconnect(PVP and PVP.meleeConn)
    safeDisconnect(L.SilentAim and L.SilentAim.SilentAimUpdateConn)
    safeDisconnect(L.axeStunConnection)
    safeDisconnect(L.rollTiltConn)
    safeDisconnect(L.spin and L.spin.connection)
    safeDisconnect(L.thirdPerson and L.thirdPerson.connection)
    safeDisconnect(L.invert and L.invert.conn)
    safeDisconnect(L.bigHead and L.bigHead.connection)
    safeDisconnect(L.animLoop1205Connection)
    safeDisconnect(L.AutoEscape and L.AutoEscape.suspendConn)
    safeDisconnect(L.AntiGrab and L.AntiGrab.connection)
    safeDisconnect(L.infectionUpdateConn)
    safeDisconnect(L.jobUpdateConn)
    safeDisconnect(L.bulletDisplay and L.bulletDisplay.connection)
    safeDisconnect(L.bulletDisplay and L.bulletDisplay.cameraConn)
    safeDisconnect(L.pingDisplay and L.pingDisplay.conn)
    safeDisconnect(L.infectionRemover and L.infectionRemover.conn)
    safeDisconnect(L.bombRange and L.bombRange.conn)
    safeDisconnect(L.handMortar and L.handMortar.cameraConn)
    safeDisconnect(L.handMortar and L.handMortar.conn)
    safeDisconnect(L.zombieESPHeartbeatConn)
    safeDisconnect(L.CoordSpeed and L.CoordSpeed.Connection)
    safeDisconnect(speedHeartbeatConn)
    safeDisconnect(L.AutoJump and L.AutoJump.Connection)
    safeDisconnect(L.JumpMod and L.JumpMod.AntiFallConn)
    pcall(function() if L.tpFreecam then L.tpFreecam.cleanup() end end)
    pcall(function() if L.oneClick and L.oneClick.ui then L.oneClick.ui:Destroy() end end)
    pcall(function() if L.flyAway and L.flyAway.screenGui then L.flyAway.screenGui:Destroy() end end)
    pcall(function() if L.invisTool and L.invisTool.ui then L.invisTool.ui:Destroy() end end)
    pcall(function() if _G.boxerUI then _G.boxerUI:Destroy() end end)
    pcall(function() if _G.cavalryUI then _G.cavalryUI:Destroy() end end)
    pcall(function() if _G.zapperUI then _G.zapperUI:Destroy() end end)
    pcall(function() if L.toggleNewAnimUI then L.toggleNewAnimUI(false) end end)
    pcall(function() if L.toggleAnim17871770160UI then L.toggleAnim17871770160UI(false) end end)
end)

MenuGroup:AddButton('卸载脚本', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("MyScriptTheme")
SaveManager:SetFolder("MyScriptConfig")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library.Scheme.BackgroundColor = Color3.fromRGB(14, 15, 17)
Library.Scheme.MainColor = Color3.fromRGB(10, 11, 13)
Library.Scheme.AccentColor = Color3.fromRGB(165, 170, 178)
Library.Scheme.OutlineColor = Color3.fromRGB(21, 23, 26)
Library.Scheme.DarkColor = Color3.fromRGB(8, 9, 11)
Library.CornerRadius = 10
if Options.FontFace then Options.FontFace:SetValue("RobotoMono") end
if Options.BackgroundColor then Options.BackgroundColor:SetValue(Library.Scheme.BackgroundColor) end
if Options.MainColor then Options.MainColor:SetValue(Library.Scheme.MainColor) end
if Options.AccentColor then Options.AccentColor:SetValue(Library.Scheme.AccentColor) end
if Options.OutlineColor then Options.OutlineColor:SetValue(Library.Scheme.OutlineColor) end
Library:UpdateColorsUsingRegistry()

task.defer(function()
    SetInterfaceLanguage(Options.InterfaceLanguage.Value)
end)

do
    Players = game:GetService("Players")
    LocalPlayer = Players.LocalPlayer

    function playIdentityAnimation()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        local anim = Instance.new("Animation")
        local ok, err = pcall(function()
            anim.AnimationId = "rbxassetid://507766666"
        end)
        if not ok then
            warn("playIdentityAnimation: failed to set AnimationId:", err)
            return
        end
        local track = animator:LoadAnimation(anim)
        track.Looped = true
        track:Play()
        track:AdjustSpeed(1)
        _G._identityTrack = track
    end

    function onCharacterAdded()
        task.wait(0.5)
        playIdentityAnimation()
    end

    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        onCharacterAdded()
    end
end

L.voteMonitor = {
    enabled = false,
    conns = {},
    voter = nil,
    target = nil,
    votes = {},
    inProgress = false,
}

function L.voteMonitor.start()
    if L.voteMonitor.enabled then return end
    L.voteMonitor.enabled = true

    local RS = game:GetService("ReplicatedStorage")
    local PlayerVote = RS:FindFirstChild("GameStates") and RS.GameStates:FindFirstChild("PlayerVote")
    if not PlayerVote then
        warn("[投票监听] 找不到 PlayerVote")
        return
    end

    local Voted = PlayerVote:FindFirstChild("Voted")
    if not Voted then
        warn("[投票监听] 找不到 Voted")
        return
    end

    for _, c in L.voteMonitor.conns do
        c:Disconnect()
    end
    table.clear(L.voteMonitor.conns)

    local function onInProgressChanged()
        local ip = PlayerVote:GetAttribute("InProgress")
        if ip then
            L.voteMonitor.inProgress = true
            L.voteMonitor.voter = PlayerVote:GetAttribute("Voter")
            L.voteMonitor.target = PlayerVote:GetAttribute("Target")
            L.voteMonitor.votes = {}
            if L.voteMonitor.voter and L.voteMonitor.target then
                Library:Notify(strFormat(TranslateText("[投票] %s 发起对 %s 的投票"), L.voteMonitor.voter, L.voteMonitor.target), 3)
            end
        else
            L.voteMonitor.inProgress = false
            L.voteMonitor.voter = nil
            L.voteMonitor.target = nil
            L.voteMonitor.votes = {}
        end
    end

    local function onVotedAttributeChanged(attr)
        if not L.voteMonitor.inProgress then return end
        local v = Voted:GetAttribute(attr)
        if attr and v ~= nil then
            local result = v and TranslateText("同意") or TranslateText("反对")
            Library:Notify(strFormat(TranslateText("[投票] %s %s"), attr, result), 2)
        end
    end

    table.insert(L.voteMonitor.conns, PlayerVote:GetAttributeChangedSignal("InProgress"):Connect(onInProgressChanged))
    table.insert(L.voteMonitor.conns, Voted.AttributeChanged:Connect(onVotedAttributeChanged))

    if PlayerVote:GetAttribute("InProgress") then
        onInProgressChanged()
    end

    Library:Notify(TranslateText("投票显示已开启"), 2)
end

function L.voteMonitor.stop()
    L.voteMonitor.enabled = false
    for _, c in L.voteMonitor.conns do
        c:Disconnect()
    end
    table.clear(L.voteMonitor.conns)
    L.voteMonitor.voter = nil
    L.voteMonitor.target = nil
    L.voteMonitor.votes = {}
    L.voteMonitor.inProgress = false
    Library:Notify(TranslateText("投票显示已关闭"), 2)
end

AutoRightGroup:AddToggle('VoteMonitorToggle', {
    Text = '投票显示',
    Default = false,
    Callback = function(v)
        if v then L.voteMonitor.start() else L.voteMonitor.stop() end
    end
})

Library:OnUnload(function()
    L.voteMonitor.stop()
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Skin HUB v4.1",
    Text = string.format("已加载，耗时 %.2f 秒", tick() - __SkinHubLoadStart),
    Duration = 5,
})