local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "恐鬼症",
    Footer = "付费版",
    ToggleKeybind = Enum.KeyCode.C,
    Center = true,
    AutoShow = true,
    ShowCustomCursor = false,
    --Icon = 77444606786842,
    IconSize = UDim2.fromOffset(40, 40),
    BackgroundImage = 77444606786842,
})

local TabPlayer = Window:AddTab("玩家", "user-round-pen", "本地玩家修改")
local GroupPlayer = TabPlayer:AddLeftGroupbox("玩家")
local GroupGame = TabPlayer:AddLeftGroupbox("游戏")
local GroupMatch = TabPlayer:AddRightGroupbox("对局")
local GroupZone = TabPlayer:AddRightGroupbox("区域")

local GhostRoomPart = nil -- 用于存储鬼房位置(r11_0)
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 玩家功能: 透视/夜视
GroupPlayer:AddButton({
    Text = "透视/夜视",
    Func = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        for _, v in pairs(Lighting:GetDescendants()) do
            v:Destroy()
        end
    end,
})

-- 玩家功能: 无限体力
GroupPlayer:AddButton({
    Text = "无限体力",
    Func = function()
        for i = 1, 10 do
            if LocalPlayer:FindFirstChild("DoubleStamina") then
                LocalPlayer.DoubleStamina.Value = true
            end
        end
    end,
})

-- 玩家功能: 白天可见(聊天窗)
local ChatWindowConn = nil
GroupPlayer:AddToggle("DaylightChat", {
    Text = "白天可见(聊天窗)",
    Default = false,
    Callback = function(Value)
        local ChatConfig = game:GetService("TextChatService").ChatWindowConfiguration
        if Value then
            ChatConfig.Enabled = true
            ChatWindowConn = ChatConfig:GetPropertyChangedSignal("Enabled"):Connect(function()
                ChatConfig.Enabled = true
            end)
        elseif ChatWindowConn then
            ChatWindowConn:Disconnect()
            ChatConfig.Enabled = false
        end
    end,
})

-- 玩家功能: 区域温度显示
GroupPlayer:AddToggle("ShowTemp", {
    Text = "区域温度",
    Default = false,
    Callback = function(Value)
        if LocalPlayer.PlayerGui:FindFirstChild("TemperatureDisplay") then
            LocalPlayer.PlayerGui.TemperatureDisplay.Enabled = Value
        end
    end,
})

-- 玩家功能: 高频精灵盒
local SpiritBoxConn = nil
GroupPlayer:AddToggle("AutoSpiritBox", {
    Text = "高频精灵盒对话",
    Default = false,
    Callback = function(Value)
        if Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Spirit Box") then
                SpiritBoxConn = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character:FindFirstChild("Spirit Box") then
                        LocalPlayer.Character["Spirit Box"].AskQuestion:FireServer("ButtonA")
                    end
                end)
            else
                Library:Notify("请确保角色手持了精灵盒", 5)
            end
        elseif SpiritBoxConn then
            SpiritBoxConn:Disconnect()
        end
    end,
})

-- 玩家功能: 透视幽灵仇恨
GroupPlayer:AddToggle("IgnoreGhost", {
    Text = "透视幽灵仇恨",
    Tooltip = "使用该功能会让幽灵无视你(请不要在房子内开启)",
    Default = false,
    Callback = function(Value)
        if LocalPlayer.Zone.Value ~= "Outside" and Value == true then
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, Workspace.Map.Zones.Outside, 0)
            task.wait(0.1)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, Workspace.Map.Zones.Outside, 1)
        end
        for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
            if not zone:IsA("Folder") then
                zone.CanTouch = not Value
            end
        end
    end,
})

-- 玩家功能: 远程互动
local ProximityConn = nil
GroupPlayer:AddToggle("RemoteInteract", {
    Text = "远程互动",
    Default = false,
    Callback = function(Value)
        if Value then
            if fireproximityprompt then
                ProximityConn = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                    fireproximityprompt(prompt)
                end)
            else
                Library:Notify("你的注入器不支持此命令(fireproximityprompt)", 5)
            end
        elseif ProximityConn then
            ProximityConn:Disconnect()
            ProximityConn = nil
        end
    end,
})

-- 玩家功能: 速度修改
local SpeedConn = nil
local TargetSpeed = 0
GroupPlayer:AddInput("WalkSpeed", {
    Text = "速度修改",
    Default = "负数关闭,正数开启",
    Numeric = true,
    Finished = true,
    Placeholder = "负数关闭,正数开启",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            if SpeedConn then
                TargetSpeed = num
            else
                SpeedConn = LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    LocalPlayer.Character.Humanoid.WalkSpeed = TargetSpeed
                end)
                LocalPlayer.Character.Humanoid.WalkSpeed = num
                TargetSpeed = num
            end
        elseif SpeedConn then
            SpeedConn:Disconnect()
            SpeedConn = nil
        end
    end,
})

-- 游戏功能: 删门
GroupGame:AddButton({
    Text = "删门",
    Func = function()
        for _, door in ipairs(Workspace.Map.Doors:GetChildren()) do
            door:Destroy()
        end
    end,
})

-- 游戏功能: 收集所有照片
local PhotoTypes = {
    "Cursed Object", "Ghost", "Dirty Water", "Stepped In Salt",
    "Written In Book", "Burning Crucifix", "Dead Body", "Boo-Boo Doll", "UV Print"
}
GroupGame:AddButton({
    Text = "收集所有照片",
    Func = function()
        if LocalPlayer.Character:FindFirstChild("Photo Camera") then
            for _, pType in pairs(PhotoTypes) do
                LocalPlayer.Character["Photo Camera"].Remote.FireCameraEvent:FireServer(unpack({
                    [1] = LocalPlayer.Character:FindFirstChild("Head").CFrame,
                    [2] = { Type = pType },
                }))
            end
        else
            Library:Notify("请确保角色手持了照相机", 5)
        end
    end,
})

-- 游戏功能: 凭空放盐
GroupGame:AddButton({
    Text = "凭空放盐",
    Func = function()
        if GhostRoomPart and LocalPlayer.Character:FindFirstChild("Salt") then
            LocalPlayer.Character.Salt.Remote.Drop:FireServer(unpack({
                [1] = GhostRoomPart.CFrame,
                [2] = LocalPlayer.Character.Salt.Ammo.Capacity,
            }))
        else
            Library:Notify("请确保角色手持了盐，且已探测到鬼房(最低温度)", 5)
        end
    end,
})

-- 游戏功能: 血月加成
GroupGame:AddButton({
    Text = "血月加成",
    Func = function()
        ReplicatedStorage.Remotes.BloodMoonEvent:FireServer()
    end,
})

-- 游戏功能: 蜡烛互动距离
GroupGame:AddSlider("CandleDistance", {
    Text = "蜡烛互动距离",
    Default = 4,
    Min = 4,
    Max = 10,
    Compact = false,
    Callback = function(Value)
        for _, v in ipairs(Workspace.Map:FindFirstChild("Candles"):GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.MaxActivationDistance = Value
            end
        end
    end,
})

-- 对局功能: 辅助函数
local CrashConn = nil
local function ClearPictures()
    for _, v in ipairs(Workspace.Map.Items:GetDescendants()) do
        if v.Name == "PictureGui" then v:Destroy() end
    end
end

local function RandomString(len)
    math.randomseed(os.time())
    local chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    local str = ""
    for i = 1, len do
        local r = math.random(1, #chars)
        str = str .. string.sub(chars, r, r)
    end
    return str
end

-- 对局功能: 轰炸清理
GroupMatch:AddButton({
    Text = "轰炸对局清理",
    Tooltip = "如果在使用炸对局功能时使用者出现严重卡顿，请使用此功能",
    Func = function()
        ClearPictures()
    end,
})

local EnableAdMsg = true
GroupMatch:AddToggle("AdMsg", {
    Text = "使用广告(炸对局发送消息)",
    Tooltip = "高程度避免被视频录制举报",
    Default = false,
    Callback = function(Value)
        EnableAdMsg = not Value -- 逻辑取反
    end,
})

local LoadedCrashBot = true
GroupMatch:AddToggle("CrashMatch", {
    Text = "炸对局",
    Tooltip = "该功能会致使对局中所有人卡顿掉线(设备好则不会崩退)",
    Default = false,
    Callback = function(Value)
        if Value then
            if LoadedCrashBot then
                LoadedCrashBot = false
                loadstring(game:HttpGet("https://raw.githubusercontent.com/longchneg/GAl/refs/heads/main/%E6%9C%BA%E5%99%A8%E4%BA%BA"))()
            end
            if EnableAdMsg then
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("Yttrium Hub[炸对局]功能开启:" .. RandomString(10))
            end
            ClearPictures()
            task.wait(2)
            CrashConn = RunService.Stepped:Connect(function()
                if Workspace.Map.Items:FindFirstChild("Photo Camera") then
                    Workspace.Map.Items["Photo Camera"].Remote.FireCameraEvent:FireServer(LocalPlayer.Character.HumanoidRootPart.CFrame, {})
                else
                    print("未找到照相机")
                end
            end)
        elseif CrashConn then
            CrashConn:Disconnect()
        end
    end,
})

-- 区域功能
local ZoneList = {}
for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
    if not zone:IsA("Folder") then
        table.insert(ZoneList, zone.Name)
    end
end

local OldZoneSize = nil
local OldZoneName = nil
local HuntTpConn = nil
local HasModdedZone = false

GroupZone:AddLabel([[
友情提示:该功能开启前请务必搭配[狩猎传回]，否则幽灵在外面猎杀,目标只有你一个

开启后这会导致撤离前需要等待30秒才能撤离

当你选择了区域后[狩猎传回]将自动转换为频繁而不是单次(如果在选择区域前就已经开启了[狩猎传回]就需要重新开启该功能)]], true)

GroupZone:AddToggle("HuntTp", {
    Text = "狩猎传回",
    Default = false,
    Tooltip = "当猎杀后本地玩家会被传送到安全点避免被猎杀",
    Callback = function(Value)
        if Value then
            if HasModdedZone then
                HuntTpConn = RunService.Stepped:Connect(function()
                    if ReplicatedStorage.Disruption.Value == true and LocalPlayer.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.TempSpawn.SpawnPart.CFrame + Vector3.new(0, 5, 0)
                    end
                end)
            else
                HuntTpConn = ReplicatedStorage.Disruption:GetPropertyChangedSignal("Value"):Connect(function()
                    if ReplicatedStorage.Disruption.Value == true and LocalPlayer.Character then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.TempSpawn.SpawnPart.CFrame + Vector3.new(0, 5, 0)
                    end
                end)
            end
        else
            if HuntTpConn then HuntTpConn:Disconnect() end
        end
    end,
})

GroupZone:AddDropdown("SelectZone", {
    Values = ZoneList,
    Default = nil,
    Multi = false,
    Text = "选择区域",
    Tooltip = "该功能让你不进房子就能减少理智或者吸引仇恨(找到名为[Outside]即可关闭)",
    Callback = function(Value)
        HasModdedZone = true
        -- 恢复旧区域
        if OldZoneName then
            for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
                if zone.Name == OldZoneName then
                    zone.Size = OldZoneSize
                end
            end
            OldZoneSize = nil
            OldZoneName = nil
        end

        -- 设置Outside为极小
        for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
            if zone.Name == "Outside" then
                zone.Size = Vector3.new(1, 1, 1)
            end
        end
        
        -- 设置新区域
        for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
            if zone.Name == Value then
                OldZoneSize = zone.Size
                OldZoneName = zone.Name
                zone.Size = Vector3.new(2048, 2048, 2048)
            end
        end
    end,
})

-- ESP 系统
local IsGhostRoomESP = false
local ESPFolderGUID = game:GetService("HttpService"):GenerateGUID(false)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = ESPFolderGUID
ESPFolder.Parent = Workspace

local function CreateESP(adornee, name, text, color, offset, useHighlight)
    if not Workspace:FindFirstChild(ESPFolderGUID) then
        local f = Instance.new("Folder")
        f.Name = ESPFolderGUID
        f.Parent = Workspace
    end
    
    if Workspace:FindFirstChild(ESPFolderGUID) and adornee then
        -- 检查是否已存在
        for _, child in ipairs(Workspace:FindFirstChild(ESPFolderGUID):GetChildren()) do
            if child.Name == name and child.Adornee == adornee then
                child:FindFirstChild("Name").Text = text
                return 
            end
        end

        local bg = Instance.new("BillboardGui")
        local txtName = Instance.new("TextLabel")
        local txtDist = Instance.new("TextLabel")
        
        bg.AlwaysOnTop = true
        bg.Name = name
        bg.Size = UDim2.new(0, 100, 0, 40)
        bg.ClipsDescendants = true
        bg.Adornee = adornee
        bg.MaxDistance = math.huge
        bg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        bg.StudsOffset = offset or Vector3.new(0, 3, 0)
        bg.Parent = Workspace:FindFirstChild(ESPFolderGUID)
        
        txtName.Name = "Name"
        txtName.TextWrapped = true
        txtName.TextStrokeTransparency = 0
        txtName.TextScaled = true
        txtName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        txtName.Size = UDim2.new(1, 0, 0.5, 0)
        txtName.Text = text or "nil"
        txtName.TextColor3 = color or Color3.new(1, 1, 1)
        txtName.BackgroundTransparency = 1
        txtName.Parent = bg
        
        txtDist.Name = "Distance"
        txtDist.TextWrapped = true
        txtDist.TextStrokeTransparency = 0.4
        txtDist.TextScaled = true
        txtDist.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        txtDist.Size = UDim2.new(1, 0, 0.5, 0)
        txtDist.Text = "[无数据]"
        txtDist.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        txtDist.BackgroundTransparency = 1
        txtDist.Position = UDim2.new(0, 0, 0.5, 0)
        txtDist.Parent = bg
        
        if useHighlight then
            local hl = Instance.new("Highlight")
            hl.OutlineTransparency = 1
            hl.Adornee = adornee
            hl.FillColor = color
            hl.FillTransparency = 0.6
            hl.Parent = bg
        end
    end
end

local function ClearESP(name)
    for _, v in ipairs(Workspace:FindFirstChild(ESPFolderGUID):GetChildren()) do
        if v.Name == name then v:Destroy() end
    end
end

local ESPList = { "诅咒道具", "幽灵球", "幽灵", "最低温度", "巫毒娃娃", "互动", "发电电机", "血月定鬼房" }
local OrbConn, GhostESPConn, EMFConn = nil, nil, nil
local BloodMoonConns = {}

local function UpdateESP(selected)
    if table.find(selected, "诅咒道具") then
        local cursedItems = {"Music Box", "Spirit Board", "SummoningCircle", "Tarot Cards"}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if table.find(cursedItems, v.Name) and (v:IsA("Tool") or v:IsA("Model")) then
                CreateESP(v, "CursedESP", "诅咒道具", Color3.fromRGB(255, 234, 0), nil, true)
            end
        end
    else
        ClearESP("CursedESP")
    end

    if table.find(selected, "幽灵球") then
        CreateESP(Workspace.Map.Orbs:FindFirstChild("OrbPart"), "OrbPart", "幽灵球", Color3.fromRGB(121, 255, 248), Vector3.new(0, 0, 0), false)
        if not OrbConn then
            OrbConn = Workspace.Map.Orbs.ChildAdded:Connect(function(child)
                CreateESP(child, "OrbPart", "幽灵球", Color3.fromRGB(121, 255, 248), Vector3.new(0, 0, 0), false)
            end)
        end
    elseif OrbConn then
        OrbConn:Disconnect()
        OrbConn = nil
        ClearESP("OrbPart")
    end

    if table.find(selected, "幽灵") and not GhostESPConn then
        GhostESPConn = Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Ghost" and child:IsA("Model") then
                CreateESP(child, "GhostESP", "幽灵", Color3.fromRGB(255, 119, 56), Vector3.new(0, 0, 0), false)
            end
        end)
    elseif GhostESPConn then
        GhostESPConn:Disconnect()
        GhostESPConn = nil
        ClearESP("GhostESP")
    end

    if table.find(selected, "最低温度") then
        IsGhostRoomESP = true
        CreateESP(GhostRoomPart, "GhostRoomESP", "最低温度房间", Color3.fromRGB(186, 250, 144), Vector3.new(0, 0, 0), true)
    else
        IsGhostRoomESP = false
        ClearESP("GhostRoomESP")
    end

    if table.find(selected, "巫毒娃娃") then
        for _, v in ipairs(Workspace:GetChildren()) do
            if v.Name == "BooBooDoll" then
                CreateESP(v, "BooBooDollESP", "巫毒娃娃", Color3.fromRGB(179, 113, 255), Vector3.new(0, 0, 0), true)
            end
        end
    else
        ClearESP("BooBooDollESP")
    end

    if table.find(selected, "发电机") then
        if Workspace.Map.Generators:FindFirstChild("GeneratorMesh") then
            CreateESP(Workspace.Map.Generators:FindFirstChild("GeneratorMesh"), "GeneratorsESP", "发电机", Color3.fromRGB(12, 156, 125), nil, true)
        end
    else
        ClearESP("GeneratorsESP")
    end

    if table.find(selected, "互动") and not EMFConn then
        EMFConn = Workspace.Map.DescendantAdded:Connect(function(child)
            if child:IsA("Part") and child.Name == "EMFPart" then
                CreateESP(child, "EMFPartESP", "互动", Color3.fromRGB(79, 153, 79), Vector3.new(0, 0, 0), false)
            end
        end)
    elseif EMFConn then
        EMFConn:Disconnect()
        EMFConn = nil
        ClearESP("EMFPartESP")
    end

    if table.find(selected, "血月定鬼房") then
        for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
            table.insert(BloodMoonConns, zone.ChildAdded:Connect(function(child)
                if child:IsA("Sound") then
                    CreateESP(child.Parent, "BloodMoonSound", "准确鬼房(血月)", Color3.fromRGB(255, 112, 172), Vector3.new(0, 0, 0), false)
                end
            end))
        end
    else
        for _, conn in pairs(BloodMoonConns) do conn:Disconnect() end
        ClearESP("BloodMoonSound")
    end
end

-- 绘制 Tab
local TabESP = Window:AddTab("绘制", "map-pinned", "绘制工作区对象"):AddLeftGroupbox("绘制")
local ESPWarning = TabESP:AddLabel("<font color='rgb(255,0,0)'>!!!正在等待车门开启,确保绘制正常运行!!!</font>")

-- 数据 Tab
local TabData = Window:AddTab("数据", "ghost", "录幽灵数值")
local GroupGhostData = TabData:AddLeftGroupbox("幽灵")
local GhostSpeedLabel = GroupGhostData:AddLabel("最低: 幽灵未出现\n速度: 幽灵未出现\n最高: 幽灵未出现", true)
GroupGhostData:AddDivider()
local GhostFadeLabel = GroupGhostData:AddLabel("透明度变化时间: 幽灵未出现\n平均值: 幽灵未出现", true)

local MinSpeed = 100
local CurrentSpeed = 0
local MaxSpeed = 0
local AvgFadeTime = 0
local LastFadeTime = 0
local FadeTimes = {}

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Ghost" and child:IsA("Model") then
        task.wait(0.5)
        local Humanoid = child:FindFirstChild("Humanoid")
        if Humanoid then
            GhostSpeedLabel:SetText("最低: " .. string.format("%.2f", Humanoid.WalkSpeed) .. "\n速度: " .. string.format("%.2f", Humanoid.WalkSpeed) .. "\n最高: " .. string.format("%.2f", Humanoid.WalkSpeed))
            Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                CurrentSpeed = Humanoid.WalkSpeed
                if CurrentSpeed < MinSpeed then MinSpeed = CurrentSpeed end
                if CurrentSpeed > MaxSpeed then MaxSpeed = CurrentSpeed end
                GhostSpeedLabel:SetText("最低: " .. string.format("%.2f", MinSpeed) .. "\n速度: " .. string.format("%.2f", CurrentSpeed) .. "\n最高: " .. string.format("%.2f", MaxSpeed))
            end)
        end

        local Head = child:FindFirstChild("Head")
        if Head then
            local lastTrans = Head.Transparency
            local startTime = tick()
            Head:GetPropertyChangedSignal("Transparency"):Connect(function()
                if lastTrans < Head.Transparency then
                    LastFadeTime = tick() - startTime
                    if LastFadeTime <= 8 then
                        table.insert(FadeTimes, LastFadeTime)
                        local sum = 0
                        for _, t in ipairs(FadeTimes) do sum = sum + t end
                        AvgFadeTime = sum / #FadeTimes
                        GhostFadeLabel:SetText("透明度变化时间: " .. string.format("%.2f", LastFadeTime) .. "秒\n平均值: " .. string.format("%.2f", AvgFadeTime) .. "秒")
                    end
                end
                lastTrans = Head.Transparency
                startTime = tick()
            end)
        end
    end
end)

GroupGhostData:AddDivider()
local HuntTimeLabel = GroupGhostData:AddLabel("剩余时间: 幽灵未出现", true)
ReplicatedStorage.ChildAdded:Connect(function(child)
    if child.Name == "HuntDuration" then
        child:GetPropertyChangedSignal("Value"):Connect(function()
            HuntTimeLabel:SetText("剩余时间: " .. tostring(child.Value))
        end)
    end
end)

GroupGhostData:AddToggle("Watermark", {
    Text = "显示水印",
    Default = false,
    Callback = function(Value)
        Library:SetWatermarkVisibility(Value)
    end,
})

local GroupEvidence = TabData:AddRightGroupbox("证据")
local MinRoomTemp = math.huge
local TempLabel = GroupEvidence:AddLabel("最低房间温度\n无数据", true)

-- 温度监控循环
for _, zone in ipairs(Workspace.Map.Zones:GetChildren()) do
    if zone.Name ~= "Outside" then
        for _, v in ipairs(zone:GetDescendants()) do
            if v.Name == "_____Temperature" and v:IsA("NumberValue") then
                v:GetPropertyChangedSignal("Value"):Connect(function()
                    if v.Value < MinRoomTemp then
                        MinRoomTemp = v.Value
                        if TempLabel then
                            TempLabel:SetText("最低房间温度\n" .. tostring(string.format("%.2f", MinRoomTemp)))
                        end
                        GhostRoomPart = v.Parent -- 更新鬼房
                        if IsGhostRoomESP then
                            ClearESP("GhostRoomESP")
                            CreateESP(GhostRoomPart, "GhostRoomESP", "最低温度房间", Color3.fromRGB(186, 250, 144), Vector3.new(0, 0, 0), true)
                        end
                    end
                end)
            end
        end
    end
end

local OrbLabel = GroupEvidence:AddLabel("幽灵球\n不存在", true)
Workspace.Map.Orbs.ChildAdded:Connect(function() OrbLabel:SetText("幽灵球\n存在") end)

local SaltLabel = GroupEvidence:AddLabel("盐罐\n未踩", true)
Workspace.Map.Misc.ChildAdded:Connect(function(c)
    if c.Name == "SaltStepped" and c:IsA("MeshPart") then SaltLabel:SetText("盐罐\n已踩") end
end)

local SpiritBoxLabel = GroupEvidence:AddLabel("精灵盒\n不存在/未知", true)
for _, v in ipairs(Workspace:GetDescendants()) do
    if v.Name == "Spirit Box" and v:IsA("Tool") and v:FindFirstChild("Handle") then
        v.Handle.ChildAdded:Connect(function(c)
            if c:IsA("Sound") then SpiritBoxLabel:SetText("精灵盒\n存在") end
        end)
    end
end

local EMFCount = 0
local EMFLabel = GroupEvidence:AddLabel("互动\n未出现", true)
Workspace.Map.DescendantAdded:Connect(function(c)
    if c:IsA("Part") and c.Name == "EMFPart" then
        EMFCount = EMFCount + 1
        EMFLabel:SetText("互动\n出现次数: " .. EMFCount)
    end
end)

local SLSCount = 0
local SLSLabel = GroupEvidence:AddLabel("SLS异常\n未出现", true)
Workspace.ChildAdded:Connect(function(c)
    if c.Name == "SLS_Sitting" and c:IsA("Model") then
        SLSCount = SLSCount + 1
        SLSLabel:SetText("SLS异常\n出现次数: " .. SLSCount)
    end
end)

local UVCount = 0
local UVLabel = GroupEvidence:AddLabel("紫外线\n未出现", true)
Workspace.Map.Prints.ChildAdded:Connect(function()
    UVCount = UVCount + 1
    UVLabel:SetText("紫外线\n出现次数: " .. UVCount)
end)

local ShadowCount = 0
local ShadowLabel = GroupEvidence:AddLabel("黑影人物\n未出现", true)
Workspace.ChildAdded:Connect(function(c)
    if c.Name == "ShadowyFigure" and c:IsA("Model") then
        ShadowCount = ShadowCount + 1
        ShadowLabel:SetText("黑影人物\n出现次数: " .. ShadowCount)
    end
end)

local GroupLocalStats = TabData:AddLeftGroupbox("本地玩家")
local SanityLabel = GroupLocalStats:AddLabel("理智\n0%/100%", true)
local LivesLabel = GroupLocalStats:AddLabel("生命\n0条", true)

LocalPlayer:FindFirstChild("Sanity"):GetPropertyChangedSignal("Value"):Connect(function()
    SanityLabel:SetText("理智\n" .. tostring(string.format("%.2f", LocalPlayer.Sanity.Value)) .. "%")
end)
LocalPlayer:FindFirstChild("Lives"):GetPropertyChangedSignal("Value"):Connect(function()
    LivesLabel:SetText("生命\n" .. LocalPlayer.Lives.Value .. "条")
end)

-- 清理其它玩家的图片GUI
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character and p.Character:FindFirstChild("Photo Camera") and p.Character["Photo Camera"]:FindFirstChild("PictureGui") then
        p.Character["Photo Camera"].PictureGui:Destroy()
    end
end

-- 等待车门开启激活ESP选择
local TimeVal = ReplicatedStorage:FindFirstChild("Time")
local TimeConn = nil
TimeConn = TimeVal:GetPropertyChangedSignal("Value"):Connect(function()
    if TimeVal.Value >= 3 then
        TimeConn:Disconnect()
        ESPWarning:SetVisible(false)
        TabESP:AddDropdown("SelectESP", {
            Values = ESPList,
            Default = nil,
            Multi = true,
            Text = "选择对象",
            Callback = function(Val)
                local selected = {}
                for k, v in pairs(Val) do table.insert(selected, k) end
                UpdateESP(selected)
            end,
        })
    end
end)

-- 新玩家加入踢出保护
Players.ChildAdded:Connect(function(p)
    LocalPlayer:Kick("[新玩家加入]为确保您的账号安全已将你踢出对局\n玩家名字：" .. p.Name .. "\n玩家ID：" .. p.UserId)
end)

-- 主循环
RunService.Stepped:Connect(function()
    -- ESP 距离更新
    for _, v in ipairs(Workspace:FindFirstChild(ESPFolderGUID):GetChildren()) do
        if v.Adornee.Parent == nil then
            v:Destroy()
        elseif v.Adornee and LocalPlayer.Character then
            local pos = v.Adornee:IsA("BasePart") and v.Adornee.Position or v.Adornee:GetPivot().Position
            v:FindFirstChild("Distance").Text = "[" .. math.floor((pos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
        end
    end

    ReplicatedStorage.Remotes.FreezingTempatureObjective:FireServer()
    
    if LocalPlayer.PlayerGui.Rewards.Frame:FindFirstChild("MapThumbnail") then
        LocalPlayer.PlayerGui.Rewards.Frame.MapThumbnail.Title.Text = "Yttrium Hub 付费版脚本"
    end
    
    Library:SetWatermark("速度:<font color='#55ff00'>" .. string.format("%.2f", CurrentSpeed) .. "</font> | 透明度平均值:<font color='#55ff00'>" .. string.format("%.2f", AvgFadeTime) .. "</font>")
end)

if LocalPlayer:WaitForChild("SanityTracker") then
    LocalPlayer.SanityTracker.Value = true
    Library:Notify("已经为您自动解锁[便携理智查看器]", 5)
end

LocalPlayer.DoubleStamina:GetPropertyChangedSignal("Value"):Connect(function()
    LocalPlayer.DoubleStamina.Value = false -- 这里的逻辑似乎是如果被重置则重新设为false，原脚本如此，可能意图是防检测或重置？原脚本是设为false，这里保持原样
end)

-- 设置界面
local TabSettings = Window:AddTab("设置", "settings")
local GroupMenu = TabSettings:AddLeftGroupbox("菜单")

GroupMenu:AddToggle("KeybindMenu", {
    Default = Library.KeybindFrame.Visible,
    Text = "打开按键绑定菜单",
    Callback = function(Value) Library.KeybindFrame.Visible = Value end,
})
GroupMenu:AddToggle("CustomCursor", {
    Text = "自定义光标",
    Default = false,
    Callback = function(Value) Library.ShowCustomCursor = Value end,
})
GroupMenu:AddDropdown("DPI", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
    Default = "100%",
    Text = "DPI 比例",
    Callback = function(Value) Library:SetDPIScale(tonumber(Value:gsub("%%", ""))) end,
})
GroupMenu:AddLabel("菜单显示绑定"):AddKeyPicker("MenuKey", {
    Default = "C",
    NoUI = true,
    Text = "Menu keybind",
})
GroupMenu:AddButton("关闭UI", function() Library:Unload() end)

Library.ToggleKeybind = Library.Options.MenuKey
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(TabSettings)
SaveManager:LoadAutoloadConfig()