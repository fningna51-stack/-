local repo = 'https://raw.githubusercontent.com/DevSloPo/obsidian_UI/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")

local Options = Library.Options
local Toggles = Library.Toggles
local A1 = game:GetService("Players")
local A2 = A1.LocalPlayer
local A3 = game:GetService("RunService")
local A4 = game:GetService("Lighting")
local A5 = game:GetService("CoreGui")
local A6 = game:GetService("UserInputService")
local A7 = game:GetService("TeleportService")
local A8 = workspace
local A9 = game:GetService("HttpService")

local Window = Library:CreateWindow({
    Title = "AF Hub丨死铁轨",
    Footer = "By 秋辞",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

if Window and Window.TitleLabel then
    Window.TitleLabel.RichText = true
end

local Tabs = {
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local LeftGroup = Tabs.Main:AddLeftGroupbox("局内金钱美化")
local Nmtnba = Tabs.Main:AddLeftGroupbox("攻击")
local Misc2Group = Tabs.Main:AddLeftGroupbox("战斗")
local Qcnbcos = Tabs.Main:AddLeftGroupbox("传送")
local Ksqcnbcos = Tabs.Main:AddRightGroupbox("玩家功能（主要）")
local  Misc1Group= Tabs.Main:AddRightGroupbox("次要")

LeftGroup:AddInput('SetMoney', {
    Default = '',
    Numeric = true,
    Finished = true,
    Text = '设置金币',
    Placeholder = '输入金币数量...',
    Callback = function(Value)
        local Players = game:GetService("Players")
        local money = Players.LocalPlayer:FindFirstChild("leaderstats") and Players.LocalPlayer.leaderstats:FindFirstChild("Money")

        if money then
            money.Value = tonumber(Value) or 0
            print("[回调] 金币已设置为:", money.Value)
        else
            warn("未找到 leaderstats 或 Money")
        end
    end
})

--攻击标签页
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local SwingRemote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Universe")
    :WaitForChild("Network")
    :WaitForChild("RemoteEvent")
    :WaitForChild("SwingMelee")

local attackSpeed = 0.1
local autoAttackEnabled = false
local connection

Nmtnba:AddToggle('AutoAttack', {
    Text = '快速自动打击',
    Default = false,
    Tooltip = '开启后自动 SwingMelee',
    Callback = function(Value)
        autoAttackEnabled = Value

        if Value then
            connection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end

                local shovel = char:FindFirstChild("Shovel")
                if not shovel then return end

                local args = {
                    shovel,
                    1781412962.632762,
                    Vector3.new(0.673945367, -0.232261673, 0.701321661)
                }

                SwingRemote:FireServer(unpack(args))
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

Nmtnba:AddInput('AttackSpeed', {
    Default = '0.1',
    Numeric = true,
    Finished = true,
    Text = '攻击间隔 (秒)',
    Placeholder = '例: 0.05',
    Callback = function(Value)
        attackSpeed = tonumber(Value) or 0.1
    end
})

Nmtnba:AddToggle('AutoReload', {
    Text = '自动循环装弹',
    Default = false,
    Tooltip = '开启后自动无限 Reload',

    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")

        local LocalPlayer = Players.LocalPlayer
        local ReloadRemote = ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("Weapon")
            :WaitForChild("Reload")

        local connection

        if Value then
            connection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end

                local revolver = char:FindFirstChild("Revolver")
                if not revolver then return end

                local args = {
                    1781413527.979564,
                    revolver
                }

                ReloadRemote:FireServer(unpack(args))
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local meleeSpamEnabled = false
local meleeSpamConnection = nil

local SwingDelay = 0.05
local SwingsPerDelay = 2

local ClientMeleeHandler = require(
    ReplicatedStorage
        :WaitForChild("Client")
        :WaitForChild("Game")
        :WaitForChild("Melee")
        :WaitForChild("ClientMeleeHandler")
)

local originalHandler = ClientMeleeHandler._meleeActionHandler

local currentMeleeTool, currentAttackTime, currentLookVector

local function Swing()
    if not currentMeleeTool or not currentAttackTime or not currentLookVector then return end

    ReplicatedStorage
        .Shared
        .Universe
        .Network
        .RemoteEvent
        .SwingMelee:FireServer(
            currentMeleeTool,
            currentAttackTime,
            currentLookVector
        )
end

ClientMeleeHandler._meleeActionHandler = function(actionName, inputState, inputObject)
    if meleeSpamEnabled then
        if inputState == Enum.UserInputState.Begin then
            local char = LocalPlayer.Character
            if char then
                currentMeleeTool = char:FindFirstChildWhichIsA("Tool")
                if currentMeleeTool then
                    currentAttackTime = workspace:GetServerTimeNow()
                    local mouse = LocalPlayer:GetMouse()
                    currentLookVector =
                        (mouse and mouse.Hit) and mouse.Hit.LookVector
                        or char:GetPivot().LookVector

                    if meleeSpamConnection then
                        meleeSpamConnection:Disconnect()
                    end

                    meleeSpamConnection = RunService.Heartbeat:Connect(function()
                        for i = 1, SwingsPerDelay do
                            Swing()
                            task.wait(SwingDelay)
                        end
                    end)
                end
            end
        elseif inputState == Enum.UserInputState.End then
            if meleeSpamConnection then
                meleeSpamConnection:Disconnect()
                meleeSpamConnection = nil
            end
        end
    end

    if originalHandler then
        return originalHandler(actionName, inputState, inputObject)
    end
end

Nmtnba:AddToggle('MeleeSpam', {
    Text = '近战杀戮（Hold）',
    Default = false,
    Tooltip = '按住鼠标左键高速连击',
    Callback = function(Value)
        meleeSpamEnabled = Value
        if not Value and meleeSpamConnection then
            meleeSpamConnection:Disconnect()
            meleeSpamConnection = nil
        end
    end
})

Nmtnba:AddSlider('MeleeSpamSpeed', {
    Text = '近战连点间隔',
    Default = 0.05,
    Min = 0.01,
    Max = 0.2,
    Rounding = 3,
    Callback = function(Value)
        SwingDelay = Value
    end
})

Nmtnba:AddSlider('MeleeSpamCount', {
    Text = '每次触发次数',
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        SwingsPerDelay = Value
    end
})

Qcnbcos:AddButton("传送至火车", function()
for i, v in pairs(workspace:GetChildren()) do
if v:IsA("Model") and v:FindFirstChild("RequiredComponents") then
if v.RequiredComponents:FindFirstChild("Controls") and v.RequiredComponents.Controls:FindFirstChild("ConductorSeat") and v.RequiredComponents.Controls.ConductorSeat:FindFirstChild("VehicleSeat") then
game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(v.RequiredComponents.Controls.ConductorSeat:FindFirstChild("VehicleSeat").CFrame)
end
end
end
end)

Qcnbcos:AddButton("传送至狼人城堡", function()
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
wait(0.5)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(57, 3, -9000)
repeat task.wait() until workspace.RuntimeItems:FindFirstChild("MaximGun")
wait(0.3)
for i, v in pairs(workspace.RuntimeItems:GetChildren()) do
if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") then
v.VehicleSeat.Disabled = false
end
end
wait(0.5)
for i, v in pairs(workspace.RuntimeItems:GetChildren()) do
if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.VehicleSeat.Position).Magnitude < 400 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.VehicleSeat.CFrame
end
end
wait(1)
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
end)

Qcnbcos:AddButton("传送至特斯拉工厂", function()
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
wait(0.5)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.TeslaLab.Generator.Generator.CFrame
repeat task.wait() until workspace.RuntimeItems:FindFirstChild("Chair")
wait(0.3)
for i, v in pairs(workspace.RuntimeItems:GetChildren()) do
if v.Name == "Chair" and v:FindFirstChild("Seat") then
v.Seat.Disabled = false
end
end
wait(0.5)
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
repeat task.wait()
for i, v in pairs(workspace.RuntimeItems:GetChildren()) do
if v.Name == "Chair" and v:FindFirstChild("Seat") and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Seat.Position).Magnitude < 250 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Seat.CFrame
end
end
until game.Players.LocalPlayer.Character.Humanoid.Sit == true
wait(0.5)
game.Players.LocalPlayer.Character.Humanoid.Sit = false
end)

Qcnbcos:AddButton("传送至终点", function()
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
wait(0.5)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-424, 30, -49041)
repeat task.wait() until workspace.Baseplates:FindFirstChild("FinalBasePlate")
BasePart = workspace.Baseplates:FindFirstChild("FinalBasePlate")
OurLaw = BasePart:FindFirstChild("OutlawBase") 
Sen = OurLaw:FindFirstChild("Sentries")
if Sen:FindFirstChild("TurretSpot") and Sen.TurretSpot:FindFirstChild("MaximGun") and Sen.TurretSpot.MaximGun:FindFirstChild("VehicleSeat") then
wait(1.5)
for i, v in pairs(Sen:FindFirstChild("TurretSpot"):GetChildren()) do
if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") then
v.VehicleSeat.Disabled = false
end
end
wait(0.5)
game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
repeat task.wait()
for i, v in pairs(Sen:FindFirstChild("TurretSpot"):GetChildren()) do
if v.Name == "MaximGun" and v:FindFirstChild("VehicleSeat") then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v:FindFirstChild("VehicleSeat").CFrame
end
end
until game.Players.LocalPlayer.Character.Humanoid.Sit == true
wait(0.5)
game.Players.LocalPlayer.Character.Humanoid.Sit = false
end
end)

--玩家功能标签页
Ksqcnbcos:AddSlider("WalkSpeedSlider", {Text="移动速度(可在墨水使用)",Default=16,Min=16,Max=200,Rounding=0,Compact=false,Callback=function(Value)
        if (A2 and A2.Character) then
                local Humanoid = A2.Character:FindFirstChild("Humanoid");
                if Humanoid then
                        Humanoid.WalkSpeed = Value;
                end
        end
end});

Ksqcnbcos:AddInput("WalkSpeedInput", {Text="移动速度设置",Default="",Placeholder="输入移动速度值",Numeric=true,Finished=false,Callback=function(Value)
        local numValue = tonumber(Value);
        if (numValue and A2 and A2.Character) then
                local Humanoid = A2.Character:FindFirstChild("Humanoid");
                if Humanoid then
                        Humanoid.WalkSpeed = numValue;
                end
        end
end});

Ksqcnbcos:AddToggle("Full Bright", {
    Text = "夜视（高亮）",
    Default = false, 
    Callback = function(Value) 
_G.FullBright = Value
while _G.FullBright do
game.Lighting.Brightness = 2
game.Lighting.ClockTime = 14
game.Lighting.FogEnd = 100000
game.Lighting.GlobalShadows = false
game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
task.wait()
end
for i, v in pairs(_G.GetOldBright) do
game.Lighting[i] = v
end
    end
})

Ksqcnbcos:AddToggle("No Fog", {
    Text = "无雾",
    Default = false, 
    Callback = function(Value) 
_G.Nofog = Value
while _G.Nofog do
game:GetService("Lighting").FogStart = 100000
game:GetService("Lighting").FogEnd = 200000
for i, v in pairs(game:GetService("Lighting"):GetChildren()) do
if v.ClassName == "Atmosphere" then
v.Density = 0
v.Haze = 0
end
end
task.wait()
end
game:GetService("Lighting").FogStart = 0
game:GetService("Lighting").FogEnd = 1000
for i, v in pairs(game:GetService("Lighting"):GetChildren()) do
if v.ClassName == "Atmosphere" then
v.Density = 0.3
v.Haze = 1
end
end
    end
})

Ksqcnbcos:AddButton({Text="穿墙模式",Func=function()
        A19 = not A19;
        if A22 then
                A22:Disconnect();
                A22 = nil;
        end
        if A19 then
                A22 = A3.Stepped:Connect(function()
                        if A2.Character then
                                for _, Part in pairs(A2.Character:GetDescendants()) do
                                        if Part:IsA("BasePart") then
                                                Part.CanCollide = false;
                                        end
                                end
                        end
                end);
        end
end});

Ksqcnbcos:AddButton({Text="无限跳",Func=function()
        A20 = not A20;
        if A25 then
                A25:Disconnect();
                A25 = nil;
        end
        if A20 then
                A25 = A6.JumpRequest:Connect(function()
                        if A2.Character then
                                local Humanoid = A2.Character:FindFirstChildOfClass("Humanoid");
                                if Humanoid then
                                        Humanoid:ChangeState("Jumping");
                                end
                        end
                end);
        end
end});

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isWarpFlying = false
local flySpeed = 50

local MICRO_STEP_INTERVAL = 0.001
local MAX_STEP_SIZE = 10

local hrp, hum
local ControlModule = require(
    lp.PlayerScripts:WaitForChild("PlayerModule")
):GetControls()

local microStepConn, healthLockConn, diedConn
local originalCanCollide = {}
local descendantConnection

local function clearFlyRes()
    pcall(function()
        for part, state in pairs(originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = state
            end
        end
        table.clear(originalCanCollide)

        if descendantConnection then descendantConnection:Disconnect() end
        if microStepConn then microStepConn:Cancel() end
        if healthLockConn then healthLockConn:Disconnect() end
        if diedConn then diedConn:Disconnect() end

        if hrp and hum then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

local function microStepLoop()
    local targetPos = hrp.Position
    local lastTime = tick()

    while isWarpFlying do
        local now = tick()
        local dt = now - lastTime
        lastTime = now

        local mv = ControlModule:GetMoveVector()
        local cf = camera.CFrame

        local moveDir =
            (cf.LookVector * -mv.Z) +
            (cf.RightVector * mv.X)

        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        end

        local totalDelta =
            (moveDir + Vector3.new(0, vertical, 0)) *
            flySpeed * dt

        targetPos += totalDelta

        local currentPos = hrp.Position
        local remaining = targetPos - currentPos
        local distance = remaining.Magnitude

        if distance > 0 then
            local steps = math.ceil(distance / MAX_STEP_SIZE)
            local stepVec = remaining / steps

            for i = 1, steps do
                if not isWarpFlying then break end
                currentPos += stepVec
                hrp.CFrame =
                    CFrame.new(currentPos) * hrp.CFrame.Rotation
                hrp.Velocity = Vector3.zero
            end
        else
            hrp.CFrame =
                CFrame.new(targetPos) * hrp.CFrame.Rotation
            hrp.Velocity = Vector3.zero
        end

        hum:ChangeState(Enum.HumanoidStateType.Climbing)
        task.wait(MICRO_STEP_INTERVAL)
    end
end

local function healthLockLoop()
    while isWarpFlying do
        if hum and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        RunService.Heartbeat:Wait()
    end
end

local function onDied()
    if hum and isWarpFlying then
        hum.Health = hum.MaxHealth
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

local function startWarpFly()
    if isWarpFlying then return end

    local char = lp.Character
    if not char then return end

    hrp = char:FindFirstChild("HumanoidRootPart")
    hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    descendantConnection = char.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            originalCanCollide[desc] = desc.CanCollide
            desc.CanCollide = false
        end
    end)

    isWarpFlying = true
    hum:ChangeState(Enum.HumanoidStateType.Climbing)

    microStepConn = task.spawn(microStepLoop)
    healthLockConn = task.spawn(healthLockLoop)
    diedConn = hum.Died:Connect(onDied)
end
local function stopWarpFly()
    isWarpFlying = false
    clearFlyRes()
end
Ksqcnbcos:AddToggle('FlyToggle', {
    Text = '平滑飞行(无视墙体，不会死亡，不能在墨水使用)',
    Default = false,
    Tooltip = '开启 / 关闭硬核不死飞行',
    Callback = function(Value)
        if Value then
            startWarpFly()
        else
            stopWarpFly()
        end
    end
})
Ksqcnbcos:AddSlider('FlySpeedSlider', {
    Text = '飞行速度',
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Suffix = '',
    Callback = function(Value)
        flySpeed = Value
    end
})
local function bindCharacter()
    local char = lp.Character or lp.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")

    char.AncestryChanged:Connect(function(_, parent)
        if not parent then
            stopWarpFly()
            bindCharacter()
        end
    end)
end
bindCharacter()
print("✅飞行不死版已加载")
local CurrentCamera = workspace.CurrentCamera
if not CurrentCamera then
    warn("未找到 CurrentCamera")
    return
end

Ksqcnbcos:AddToggle("Unlock Person", {
    Text = "解锁第三人称",
    Default = false, 
    Callback = function(Value) 
_G.UnlockPerson = Value
if _G.UnlockPerson then
if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
end
game.Players.LocalPlayer.CameraMode = "Classic"
game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
game.Players.LocalPlayer.CameraMinZoomDistance = 0
else
game.Players.LocalPlayer.CameraMode = "LockFirstPerson"
end
    end
})

Ksqcnbcos:AddToggle("自动添加燃料", {
    Text = "自动添煤炭",
    Default = false, 
    Callback = function(Value) 
_G.FuelTrain = Value
while _G.FuelTrain do
for i, v in pairs(workspace.RuntimeItems:GetChildren()) do
if v.ClassName == "Model" and v:FindFirstChild("ObjectInfo") and v.PrimaryPart ~= nil and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude < 5 then
for h, m in pairs(v.ObjectInfo:GetChildren()) do
if m.Name == "TextLabel" and m.Text == "Fuel" and m.Text ~= "Valuable" and m.Text ~= "Bounty" then
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.RequestStartDrag:FireServer(v)
wait(0.3)
for a, k in pairs(workspace:GetChildren()) do
if k:IsA("Model") and k:FindFirstChild("RequiredComponents") and k.RequiredComponents:FindFirstChild("FuelZone") then
v:SetPrimaryPartCFrame(k.RequiredComponents:FindFirstChild("FuelZone").CFrame)
end
end
wait(0.3)
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.RequestStopDrag:FireServer()
end
end
end
end
task.wait()
end
    end
}):AddKeyPicker("AutoFuel", {
   Default = "J",
   Text = "Auto Fuel",
   Mode = "Toggle",
   SyncToggleState = true
})

Misc1Group:AddDropdown("ChooseCollect", {
    Text = "选择自动拾取的物品",
    Values = {"金钱", "蛇油", "绷带", "债券", "弹药", "圣水", "枪支", "燃烧瓶", "近战武器"},
    Default = "",
    Multi = true
})

Misc1Group:AddToggle("Auto Collect", {
    Text = "自动拾取",
    Default = false, 
    Callback = function(Value) 
_G.CollectAuto = Value
while _G.CollectAuto do
for i, v in pairs(workspace:FindFirstChild("RuntimeItems"):GetChildren()) do
if Options.ChooseCollect.Value["Money"] then
if v.Name == "Moneybag" and v:FindFirstChild("MoneyBag") and v.MoneyBag:FindFirstChild("CollectPrompt") then
if 50 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MoneyBag").Position).Magnitude then
v.MoneyBag:FindFirstChild("CollectPrompt").HoldDuration = 0
if fireproximityprompt then
fireproximityprompt(v.MoneyBag:FindFirstChild("CollectPrompt"))
end
end
end
end
if Options.ChooseCollect.Value["Snake Oil"] then
if v.Name == "Snake Oil" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
if Options.ChooseCollect.Value["Bandage"] then
if v.Name == "Bandage" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
end
if Options.ChooseCollect.Value["Bond"] then
if v.Name:find("Bond") then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Shared.Network.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
end
end
end
end
if Options.ChooseCollect.Value["Ammo"] then
if v.Name:find("Ammo") or v.Name:find("Shells") then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Shared.Network.RemotePromise.Remotes.C_ActivateObject:FireServer(v)
end
end
end
end
if Options.ChooseCollect.Value["Holy Water"] then
if v.Name == "Holy Water" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
end
if Options.ChooseCollect.Value["Molotov"] then
if v.Name == "Molotov" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
end
if Options.ChooseCollect.Value["Gun"] then
if v:FindFirstChild("ServerWeaponState") then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
elseif v:FindFirstChild("ObjectInfo") then
for h, m in pairs(v.ObjectInfo:GetChildren()) do
if m.Name == "TextLabel" and m.Text == "Gun" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
end
end
end
if Options.ChooseCollect.Value["Melee"] then
if v:FindFirstChild("ObjectInfo") then
for h, m in pairs(v.ObjectInfo:GetChildren()) do
if m.Name == "TextLabel" and m.Text == "Melee" then
for c, a in pairs(v:GetChildren()) do
if a:IsA("BasePart") and 20 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - a.Position).Magnitude then
game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(v)
end
end
end
end
end
end
end
end
task.wait()
end
    end
})

Misc1Group:AddToggle("Banjo", {
    Text = "自动弹琴",
    Default = false, 
    Tooltip = "Class Music",
    Callback = function(Value) 
_G.BanjoHeal = Value
while _G.BanjoHeal do
for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
if v.Name == "Banjo" then
v.Parent = game.Players.LocalPlayer.Character
end
end
for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
if v.Name == "Banjo" then
v2.Events.PlayBanjo:FireServer(v, 1)
end
end
task.wait()
end
    end
})

Misc1Group:AddToggle("NotificationUnicorn", {
    Text = "透视独角兽",
    Default = false, 
    Callback = function(Value) 
_G.NotificationUnicorn = Value
if _G.NotificationUnicorn == false then
for i, v in pairs(workspace:GetDescendants()) do
if v:IsA("Model") and v.Name == "Unicorn" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Esp_Unicorn") or v:FindFirstChild("Esp_UnicornGui") and not game.Players:GetPlayerFromCharacter(v) then
v:FindFirstChild("Esp_Unicorn"):Destroy()
v:FindFirstChild("Esp_UnicornGui"):Destroy()
end
end
if NotificationUnicornGet then
NotificationUnicornGet:Disconnect()
NotificationUnicornGet = nil
end
elseif _G.NotificationUnicorn == true then
spawn(function()
for i, v in pairs(workspace:GetDescendants()) do
if v:IsA("Model") and v.Name:find("Unicorn") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Esp_Unicorn") and not game.Players:GetPlayerFromCharacter(v) then
if v:FindFirstChild("Esp_Unicorn") == nil or v:FindFirstChild("Esp_UnicornGui") == nil then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
Notification("Unicorn Spawn / Health [ "..v.Humanoid.Health.." ]", 7)
else
Notification("Unicorn Spawn [ Dead ]", 7)
end
repeat task.wait() 
if v:FindFirstChild("Esp_UnicornGui") == nil then
GuiItemEsp = Instance.new("BillboardGui", v)
GuiItemEsp.Adornee = v
GuiItemEsp.Name = "Esp_UnicornGui"
GuiItemEsp.Size = UDim2.new(0, 50, 0, 50)
GuiItemEsp.AlwaysOnTop = true
GuiItemEsp.StudsOffset = Vector3.new(0, 3, 0)
GuiItemEspFrame = Instance.new("Frame", GuiItemEsp)
GuiItemEspFrame.BackgroundTransparency = 1
GuiItemEspFrame.Size = UDim2.new(1, 0, 1, 0)
local GuiItemUICorner = Instance.new("UICorner")
GuiItemUICorner.CornerRadius = UDim.new(2, 0)
GuiItemUICorner.Parent = GuiItemEspFrame
local GuiItemUIStroke = Instance.new("UIStroke")
GuiItemUIStroke.Color = Color3.fromRGB(0, 255, 0)
GuiItemUIStroke.Thickness = 2
GuiItemUIStroke.Parent = GuiItemEspFrame
end
if v:FindFirstChild("Esp_Unicorn") == nil then
local Highlight = Instance.new("Highlight")
Highlight.Name = "Esp_Unicorn"
Highlight.FillColor = Color3.fromRGB(0, 255, 0)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0
Highlight.Adornee = v
Highlight.Parent = v
end
until _G.NotificationUnicorn == false or v:FindFirstChild("HumanoidRootPart") == nil or v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0
for i, v in pairs(workspace:GetDescendants()) do
if v:IsA("Model") and v.Name == "Unicorn" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Esp_Unicorn") and v:FindFirstChild("Esp_UnicornGui") and not game.Players:GetPlayerFromCharacter(v) then
v:FindFirstChild("Esp_Unicorn"):Destroy()
v:FindFirstChild("Esp_UnicornGui"):Destroy()
end
end
end
end
end
end)
NotificationUnicornGet = workspace.DescendantAdded:Connect(function(v)
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not game.Players:GetPlayerFromCharacter(v) then
if v.Name:find("Unicorn") then
if v:FindFirstChild("Esp_Unicorn") == nil or v:FindFirstChild("Esp_UnicornGui") == nil then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
Notification("Unicorn Spawn / Health [ "..v.Humanoid.Health.." ]", 7)
else
Notification("Unicorn Spawn [ Dead ]", 7)
end
repeat task.wait() 
if v:FindFirstChild("Esp_UnicornGui") == nil then
GuiItemEsp = Instance.new("BillboardGui", v)
GuiItemEsp.Adornee = v
GuiItemEsp.Name = "Esp_UnicornGui"
GuiItemEsp.Size = UDim2.new(0, 50, 0, 50)
GuiItemEsp.AlwaysOnTop = true
GuiItemEspFrame = Instance.new("Frame", GuiItemEsp)
GuiItemEspFrame.BackgroundTransparency = 1
GuiItemEspFrame.Size = UDim2.new(1, 0, 1, 0)
local GuiItemUICorner = Instance.new("UICorner")
GuiItemUICorner.CornerRadius = UDim.new(2, 0)
GuiItemUICorner.Parent = GuiItemEspFrame
local GuiItemUIStroke = Instance.new("UIStroke")
GuiItemUIStroke.Color = Color3.fromRGB(0, 255, 0)
GuiItemUIStroke.Thickness = 2
GuiItemUIStroke.Parent = GuiItemEspFrame
end
if v:FindFirstChild("Esp_Unicorn") == nil then
local Highlight = Instance.new("Highlight")
Highlight.Name = "Esp_Unicorn"
Highlight.FillColor = Color3.fromRGB(0, 255, 0)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0
Highlight.Adornee = v
Highlight.Parent = v
end
until _G.NotificationUnicorn == false or v:FindFirstChild("HumanoidRootPart") == nil or v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0
for i, v in pairs(workspace:GetDescendants()) do
if v:IsA("Model") and v.Name == "Unicorn" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Esp_Unicorn") and v:FindFirstChild("Esp_UnicornGui") and not game.Players:GetPlayerFromCharacter(v) then
v:FindFirstChild("Esp_Unicorn"):Destroy()
v:FindFirstChild("Esp_UnicornGui"):Destroy()
end
end
end
end
end
end)
end
    end
})

Misc1Group:AddDropdown("Spawn Notification", {
    Text = "生成通知",
Values = {"斯特林", "特斯拉", "静水监狱", "宪法堡"},
    Default = "",
    Multi = true
})

function NotifySpawn(v)
if Options["Spawn Notification"].Value["Sterling"] and v.Name == "Sterling" then
Notification("Spawn Sterling", 7)
end
if Options["Spawn Notification"].Value["Tesla"] and v.Name == "TeslaLab" then
if v:FindFirstChild("ExperimentTable") then
Notification("Spawn TeslaLab", 7)
end
end
if Options["Spawn Notification"].Value["Stillwater Prison"] and v.Name == "StillwaterPrison" then
Notification("Spawn Stillwater Prison", 7)
end
if Options["Spawn Notification"].Value["Fort Constitution"] and v.Name == "FortConstitution" then
Notification("Spawn Fort Constitution", 7)
end
end
Misc1Group:AddToggle("NotificationSpawn", {
    Text = "通知弹窗",
    Default = false, 
    Callback = function(Value) 
_G.NotificationSpawn = Value
if _G.NotificationSpawn == false then
if NotificationSpawnGet then
NotificationSpawnGet:Disconnect()
NotificationSpawnGet = nil
end
elseif _G.NotificationSpawn == true then
for i, v in pairs(workspace:GetChildren()) do
NotifySpawn(v)
end
NotificationSpawnGet = workspace.ChildAdded:Connect(function(v)
NotifySpawn(v)
end)
end
    end
})

Misc1Group:AddToggle("WalkSpeed", {
    Text = "行走速度",
    Default = false, 
    Callback = function(Value) 
_G.WalkSpeed = Value
if _G.WalkSpeed == false then
if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
end
end
while _G.WalkSpeed do
if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16.5
wait(6.5)
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 18.5
end
task.wait(6.7)
end
    end
})

Misc2Group:AddToggle("Show Health Bar Mods", {
    Text = "显示血条功能",
    Default = false, 
    Callback = function(Value) 
_G.HealthBarMods = Value
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
    end
})

Misc2Group:AddDropdown("CharacterMods", {
    Text = "选择部位",
Values = {"头部", "身体核心"},
    Default = "",
    Multi = false,
    Callback = function(Value)
_G.CharacterMods = Value
    end
})

Misc2Group:AddDropdown("NoMods", {
    Text = "忽略怪物",
Values = {"马", "狼", "狼人"},
    Default = "",
    Multi = true
})

Misc2Group:AddDropdown("CharacterMods", {
    Text = "攻击方式",
Values = {"蓄力", "快速攻击", "稳定击杀(卡)", "稳定击杀(不卡)"},
    Default = "",
    Multi = false,
    Callback = function(Value)
_G.MeleeAttack = Value
    end
})

Misc2Group:AddToggle("Auto Attack Melee", {
    Text = "自动近战攻击",
    Default = false, 
    Callback = function(Value) 
_G.AutoAttackMelee = Value
while _G.AutoAttackMelee do
if _G.MeleeAttack == "Attack Fast" then
for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
if v:IsA("Tool") and v:FindFirstChild("Configuration") and v.Configuration:FindFirstChild("Animations") and v.Configuration.Animations:FindFirstChild("SwingAnimation") then
v.Parent = game.Players.LocalPlayer.Character
end
end
end
for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
if v:IsA("Tool") and v:FindFirstChild("Configuration") and v.Configuration:FindFirstChild("Animations") and v.Configuration.Animations:FindFirstChild("SwingAnimation") then
if _G.MeleeAttack == "Attack Fast" then
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.ChargeMelee:FireServer(v, 1747454200.211104)
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.SwingMelee:FireServer(v, 1747454200.211104, Vector3.new(-0.998392641544342, 0.001820647856220603, 0.05664642155170441))
elseif _G.MeleeAttack == "Charge" then
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.ChargeMelee:FireServer(v, 1747454200.211104)
elseif _G.MeleeAttack:find("Ustal Kill") then
for i = 1, 12 do
for u = 1, (_G.MeleeAttack == "Ustal Kill No Lag" and 150 or 300) do
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.ChargeMelee:FireServer(v, 1747454200.211104)
game:GetService("ReplicatedStorage").Shared.Network.RemoteEvent.SwingMelee:FireServer(v, 1747454200.211104, Vector3.new(-0.998392641544342, 0.001820647856220603, 0.05664642155170441))
end
end
end
end
end
task.wait()
end
    end
}):AddKeyPicker("AttackMelee", {
   Default = "U",
   Text = "Auto Attack Melee",
   Mode = "Toggle",
   SyncToggleState = true
})

Misc2Group:AddDropdown("GunFastAura", {
    Text = "枪械光环",
Values = {"快速", "普通"},
    Default = "",
    Multi = false,
    Callback = function(Value)
_G.GunAuraKillSkib = Value
    end
})

Misc2Group:AddSlider("Delay Shot", {
    Text = "射击延迟",
    Default = 0.25,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
_G.DelayShot = Value
    end
})

Misc2Group:AddSlider("Reach Shot", {
    Text = "射击范围",
    Default = 250,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
_G.ReachShot = Value
    end
})

_G.ModsAntilag = {
	GunAura = {},
	Aimbot = {},
	Camlock = {},
	Hitbox = {},
	EatHeal = {}
}
function Checkmods(v)
	if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") and not game.Players:GetPlayerFromCharacter(v) then
	    if v.Humanoid.Health > 0 then
			for i, v1 in pairs(_G.ModsAntilag) do
				if i ~= "EatHeal" then
			        table.insert(_G.ModsAntilag[i], v)
				end
			end
		elseif v.Humanoid.Health <= 0 then
			table.insert(_G.ModsAntilag["EatHeal"], v)
		end
	end
end
for i, v in ipairs(workspace:GetDescendants()) do
	Checkmods(v)
end
workspace.DescendantAdded:Connect(function(v)
	if v:IsA("Model") then 
		Checkmods(v)
	end
end)

_G.DelayShot = 0.25
_G.ReachShot = 250
Misc2Group:AddToggle("Gun Aura", {
    Text = "枪械光环",
    Default = false, 
    Callback = function(Value) 
_G.KillAuraGun = Value
while _G.KillAuraGun do
local DistanceGunAura, ModsTargetShotHead, ModsTargetShotHumanoid = math.huge, nil, nil
for i, v in pairs(_G.ModsAntilag.GunAura) do
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Head") and not game.Players:GetPlayerFromCharacter(v) then
local DistanceGun = (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.HumanoidRootPart.Position).Magnitude
if DistanceGun < DistanceGunAura and DistanceGun < _G.ReachShot then
if not Options.NoMods.Value["Horse"] or (not v.Name:find("Horse") and not v.Name:find("Unicorn")) then
if not Options.NoMods.Value["Wolf"] or not v.Name:find("Wolf") then
if not Options.NoMods.Value["Werewolf"] or not v.Name:find("Werewolf") then
if not v.Name:find("Soldier") then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then 
ModsTargetShotHead, ModsTargetShotHumanoid, DistanceGunAura = v:FindFirstChild(_G.CharacterMods or "Head"), v.Humanoid, DistanceGun
if _G.HealthBarMods == true and game.CoreGui:FindFirstChild("Gun Health Track").Enabled == false then
game.CoreGui["Gun Health Track"].Enabled = true
elseif game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = ((#(v.Name:gsub("Model_", "")) > 13) and (string.sub(v.Name:gsub("Model_", ""), 1, 9).."...") or v.Name:gsub("Model_", "")).." Health\n"..string.format("%.0f", v.Humanoid.Health).." / " ..v.Humanoid.MaxHealth
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1, 0)
end
end
end
end
end
end
end
end
if v:FindFirstChild("HumanoidRootPart") == nil or (v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0) then
	for i = #_G.ModsAntilag.GunAura, 1, -1 do
		if _G.ModsAntilag.GunAura[i] == v then
			table.remove(_G.ModsAntilag.GunAura, i)
		end
	end
end
end
if ModsTargetShotHead and ModsTargetShotHumanoid then
_G.ModsShotgun = {}
ShotNow = {14, 8, 2, 5, 11, 17}
if _G.GunAuraKillSkib == "Fast" then
for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:FindFirstChild("ClientWeaponState") and v.ClientWeaponState:FindFirstChild("CurrentAmmo") then
			if v.ClientWeaponState.CurrentAmmo.Value ~= 0 then
				if v.Name == "Shotgun" or v.Name == "Sawed-Off Shotgun" then
					for i, v in pairs(ShotNow) do
					    _G.ModsShotgun[v] = ModsTargetShotHumanoid
					end
				else
					_G.ModsShotgun["2"] = ModsTargetShotHumanoid
				end
				if _G.ModsShotgun ~= nil then
					game.ReplicatedStorage.Remotes.Weapon.Shoot:FireServer(game.Workspace:GetServerTimeNow(), v, ModsTargetShotHead.CFrame, _G.ModsShotgun)
					game.ReplicatedStorage.Remotes.Weapon.Reload:FireServer(game.Workspace:GetServerTimeNow(), v)
				end
			end
        end
    end
elseif _G.GunAuraKillSkib == "Normal" then
for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:FindFirstChild("ClientWeaponState") and v.ClientWeaponState:FindFirstChild("CurrentAmmo") then
			if v.ClientWeaponState.CurrentAmmo.Value ~= 0 then
				if v.Name == "Shotgun" or v.Name == "Sawed-Off Shotgun" then
					for i, v in pairs(ShotNow) do
					    _G.ModsShotgun[v] = ModsTargetShotHumanoid
					end
				else
					_G.ModsShotgun["2"] = ModsTargetShotHumanoid
				end
				if _G.ModsShotgun ~= nil then
					game.ReplicatedStorage.Remotes.Weapon.Shoot:FireServer(game.Workspace:GetServerTimeNow(), v, ModsTargetShotHead.CFrame, _G.ModsShotgun)
				end
			elseif v.ClientWeaponState.CurrentAmmo.Value == 0 then
				game.ReplicatedStorage.Remotes.Weapon.Reload:FireServer(game.Workspace:GetServerTimeNow(), v)
				repeat task.wait() until v.ClientWeaponState.CurrentAmmo.Value ~= 0
			end
        end
    end
end
else
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
end
task.wait(_G.DelayShot)
end
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
    end
}):AddKeyPicker("GunAuraKill", {
   Default = "M",
   Text = "Gun Aura",
   Mode = "Toggle",
   SyncToggleState = true
})

Misc2Group:AddToggle("Hitbox Mods", {
    Text = "扩大命中箱",
    Default = false, 
    Callback = function(Value) 
_G.Hitbox = Value
if _G.Hitbox == false then
for i, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
        v:FindFirstChild("Head").Size = _G.CharacterToYour["Head"]
    end
end
end
while _G.Hitbox do
for i, v in pairs(_G.ModsAntilag.Hitbox) do
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and not game.Players:GetPlayerFromCharacter(v) then
if not Options.NoMods.Value["Horse"] or (not v.Name:find("Horse") and not v.Name:find("Unicorn")) then
if not Options.NoMods.Value["Wolf"] or not v.Name:find("Wolf") then
if not Options.NoMods.Value["Werewolf"] or not v.Name:find("Werewolf") then
if not v.Name:find("Soldier") then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then 
v:FindFirstChild("Head").Size = Vector3.new(6, 6, 6)
end
end
end
end
end
end
if v:FindFirstChild("HumanoidRootPart") == nil or v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0 then
for i, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
        v:FindFirstChild("Head").Size = _G.CharacterToYour["Head"]
    end
end
for i = #_G.ModsAntilag.Hitbox, 1, -1 do
	if _G.ModsAntilag.Hitbox[i] == v then
		table.remove(_G.ModsAntilag.Hitbox, i)
	end
end
end
end
task.wait()
end
    end
})

Misc2Group:AddToggle("Eat Mods", {
    Text = "吞噬怪物",
    Default = false,
    Tooltip = "Class Zombie",
    Callback = function(Value) 
_G.EatMods = Value
while _G.EatMods do
for i, v in pairs(_G.ModsAntilag.EatHeal) do
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
if v.Humanoid.Health <= 0 and 8 >= (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude then
for i, s in pairs(v.HumanoidRootPart:GetChildren()) do
if s:IsA("ProximityPrompt") then
if fireproximityprompt then
fireproximityprompt(s)
end
end
end
end
end
end
task.wait()
end
    end
})

function CheckWall(Target, Target1)
    local Direction = (Target.Position - game.Workspace.CurrentCamera.CFrame.Position).unit * (Target.Position - game.Workspace.CurrentCamera.CFrame.Position).Magnitude
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character, game.Workspace.CurrentCamera}
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local Result = game.Workspace:Raycast(game.Workspace.CurrentCamera.CFrame.Position, Direction, RaycastParams)
    return Result == nil or Result.Instance:IsDescendantOf(Target1)
end
Misc2Group:AddToggle("Aimbot Mods", {
    Text = "自动瞄准",
    Default = false, 
    Callback = function(Value) 
_G.AimbotMods = Value
while _G.AimbotMods do
local DistanceMath, ModsTarget = math.huge, nil
for i, v in pairs(_G.ModsAntilag.Aimbot) do
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and not game.Players:GetPlayerFromCharacter(v) then
if not CheckWall(v:FindFirstChild("Head"), v) then 
	continue
end
local Distance = (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.HumanoidRootPart.Position).Magnitude
if Distance < DistanceMath then
if not Options.NoMods.Value["Horse"] or (not v.Name:find("Horse") and not v.Name:find("Unicorn")) then
if not Options.NoMods.Value["Wolf"] or not v.Name:find("Wolf") then
if not Options.NoMods.Value["Werewolf"] or not v.Name:find("Werewolf") then
if not v.Name:find("Soldier") then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then 
ModsTarget, DistanceMath = v:FindFirstChild(_G.CharacterMods or "Head"), Distance
if _G.HealthBarMods == true and game.CoreGui:FindFirstChild("Gun Health Track").Enabled == false then
game.CoreGui["Gun Health Track"].Enabled = true
elseif game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = ((#(v.Name:gsub("Model_", "")) > 13) and (string.sub(v.Name:gsub("Model_", ""), 1, 9).."...") or v.Name:gsub("Model_", "")).." Health\n"..string.format("%.0f", v.Humanoid.Health).." / " ..v.Humanoid.MaxHealth
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1, 0)
end
end
end
end
end
end
end
end
if v:FindFirstChild("HumanoidRootPart") == nil or (v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0) then
	for i = #_G.ModsAntilag.Aimbot, 1, -1 do
	    if _G.ModsAntilag.Aimbot[i] == v then
	        table.remove(_G.ModsAntilag.Aimbot, i)
	    end
	end
end
end
if ModsTarget then
game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.Position, game.Workspace.CurrentCamera.CFrame.Position + (ModsTarget.Position - game.Workspace.CurrentCamera.CFrame.Position).unit)
else
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
end
task.wait()
end
if FOVring then
FOVring.Visible = false
end
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
    end
}):AddKeyPicker("AimbotMods", {
   Default = "R",
   Text = "Aimbot Mods",
   Mode = "Toggle",
   SyncToggleState = true
})

Misc2Group:AddToggle("Camlock Mods", {
    Text = "镜头锁定",
    Default = false, 
    Callback = function(Value) 
_G.CamlockMods = Value
while _G.CamlockMods do
local DistanceMathMods = math.huge
local ModsTargetHead
for i, v in pairs(_G.ModsAntilag.Camlock) do
if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") and not game.Players:GetPlayerFromCharacter(v) then
local Distance2 = (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.HumanoidRootPart.Position).Magnitude
if Distance2 < DistanceMathMods then
if not Options.NoMods.Value["Horse"] or (not v.Name:find("Horse") and not v.Name:find("Unicorn")) then
if not Options.NoMods.Value["Wolf"] or not v.Name:find("Wolf") then
if not Options.NoMods.Value["Werewolf"] or not v.Name:find("Werewolf") then
if not v.Name:find("Soldier") then
if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then 
if game.Players.LocalPlayer.Character:FindFirstChild("Esp_LocalPlayer") == nil then
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Esp_LocalPlayer"
	Highlight.FillColor = Color3.fromRGB(0, 255, 0) 
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = game.Players.LocalPlayer.Character
	Highlight.Parent = game.Players.LocalPlayer.Character
end
ModsTargetHead, DistanceMathMods = v:FindFirstChild(_G.CharacterMods or "Head"), Distance2
if _G.HealthBarMods == true and game.CoreGui:FindFirstChild("Gun Health Track").Enabled == false then
game.CoreGui["Gun Health Track"].Enabled = true
elseif game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = ((#(v.Name:gsub("Model_", "")) > 13) and (string.sub(v.Name:gsub("Model_", ""), 1, 9).."...") or v.Name:gsub("Model_", "")).." Health\n"..string.format("%.0f", v.Humanoid.Health).." / " ..v.Humanoid.MaxHealth
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1, 0)
end
end
end
end
end
end
end
end
if v:FindFirstChild("HumanoidRootPart") == nil or (v:FindFirstChild("Humanoid") and v.Humanoid.Health <= 0) then
	for i = #_G.ModsAntilag.Camlock, 1, -1 do
		if _G.ModsAntilag.Camlock[i] == v then
			table.remove(_G.ModsAntilag.Camlock, i)
		end
	end
end
end
if ModsTargetHead then
if game.Workspace.CurrentCamera.CameraSubject ~= ModsTargetHead then
game.Workspace.CurrentCamera.CameraSubject = ModsTargetHead
end
else
if game.Players.LocalPlayer.Character:FindFirstChild("Esp_LocalPlayer") then
game.Players.LocalPlayer.Character:FindFirstChild("Esp_LocalPlayer"):Destroy()
end
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Workspace.CurrentCamera.CameraSubject ~= game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
end
end
task.wait()
end
if game.Players.LocalPlayer.Character:FindFirstChild("Esp_LocalPlayer") then
game.Players.LocalPlayer.Character:FindFirstChild("Esp_LocalPlayer"):Destroy()
end
if game.CoreGui:FindFirstChild("Gun Health Track").Enabled == true then
game.CoreGui["Gun Health Track"].Enabled = false
game.CoreGui["Gun Health Track"].Frame:FindFirstChild("TextLabel").Text = "Nah Health: Nil"
game.CoreGui["Gun Health Track"].Frame.Frame:FindFirstChild("Frame1").Size = UDim2.new(1, 0, 1, 0)
end
if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
end
    end
}):AddKeyPicker("CamlockMods", {
   Default = "K",
   Text = "Camlock Mods",
   Mode = "Toggle",
   SyncToggleState = true
})

Misc2Group:AddSlider("Health Heal", {
    Text = "回血阈值",
    Default = 68,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
_G.HealthyHeal = Value
    end
})

Misc2Group:AddDropdown("HealNowBro", {
    Text = "自动回血",
Values = {"蛇油", "绷带"},
    Default = "",
    Multi = true
})

Misc2Group:AddToggle("Auto Heal", {
    Text = "自动回血",
    Default = false, 
    Callback = function(Value) 
_G.AutoHeal = Value
while _G.AutoHeal do
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health < (_G.HealthyHeal or 68) then
if Options.HealNowBro.Value["Bandage"] then
if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Bandage") and game:GetService("Players").LocalPlayer.Backpack["Bandage"]:FindFirstChild("Use") then
game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Bandage").Use:FireServer()
end
end
if Options.HealNowBro.Value["Snake Oil"] then
if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Snake Oil") and game:GetService("Players").LocalPlayer.Backpack["Snake Oil"]:FindFirstChild("Use") then
game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Snake Oil").Use:FireServer(game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Snake Oil"))
end
end
end
task.wait()
end
    end
})

local MenuGroup = Tabs.Settings:AddLeftGroupbox("菜单")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Text = "显示按键绑定菜单",
    Default = Library.KeybindFrame.Visible,
    Callback = function(State)
        Library.KeybindFrame.Visible = State
    end
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "自定义光标",
    Default = false,
    Callback = function(State)
        Library.ShowCustomCursor = State
    end
})

MenuGroup:AddDropdown("NotificationSide", {
    Text = "通知位置",
    Default = "右侧",
    Values = { "左侧", "右侧" },
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end
})

MenuGroup:AddDropdown("DPIDropdown", {
    Text = "界面缩放 (DPI)",
    Default = "100%",
    Values = {
        "50%", "75%", "100%", "125%", "150%", "175%", "200%"
    },
    Callback = function(Value)
        local Scale = tonumber(Value:gsub("%%", ""))
        Library:SetDPIScale(Scale / 100)
    end
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("菜单快捷键")
    :AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "菜单快捷键"
    })

MenuGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)


Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("MyScriptTheme")
SaveManager:SetFolder("MyScriptConfig")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)