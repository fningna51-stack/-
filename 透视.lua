--[[
    ESP 透视脚本 (基于提供的 UI 控件)
    包含: 方框/边角/填充/名字/距离/血条/血量数字/骨骼/高亮
    特性: 队友检测/可见性变色/方框旋转动画/呼吸脉冲/自定义颜色
    无报错、方框稳定不乱飞
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--============================================================
-- 设置表 (与 UI 控件一一对应)
--============================================================
local Settings = {
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    MaxDistance = 2000,
    FontSize = 10,
    GlobalTransparency = 0,

    Drawing = {
        Boxes = {
            Full = { Enabled = false, Transparency = 0, Color = Color3.fromRGB(255, 255, 255) },
            Corner = { Enabled = false, Transparency = 0, Color = Color3.fromRGB(255, 255, 255) },
            Filled = { Enabled = false, Transparency = 0.85, Color = Color3.fromRGB(0, 0, 0) },
            Animate = true,
            RotationSpeed = 100,
        },
        Names = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) },
        Distances = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) },
        Healthbar = {
            Enabled = true,
            HealthText = true,
            GradientRGB1 = Color3.fromRGB(0, 255, 0),
            GradientRGB3 = Color3.fromRGB(255, 0, 0),
        },
        Chams = {
            Enabled = true,
            Pulse = true,
            Fill_Transparency = 60,
            Outline_Transparency = 0,
            Color = Color3.fromRGB(255, 255, 255),
        },
        Skeleton = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) },
    },

    Options = {
        EnemyVisibleRGB = Color3.fromRGB(255, 0, 0),
        EnemyHiddenRGB = Color3.fromRGB(255, 0, 0),
        TeamVisibleRGB = Color3.fromRGB(0, 255, 0),
        TeamHiddenRGB = Color3.fromRGB(0, 255, 0),
    },
}

-- 自身/敌人高级高亮
local ChamsLogic = {
    Self = { Enabled = false, Rainbow = false, Color = Color3.fromRGB(255, 255, 255) },
    Enemy = {
        Enabled = false,
        TeamCheck = true,
        VisibleCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 0),
        OccludedColor = Color3.fromRGB(255, 0, 0),
    },
}

-- 子弹轨迹
local BulletTracer = {
    Enabled = false,
    Color = Color3.fromRGB(0, 255, 255),
    Width = 0.15,
    Duration = 0.5,
}

--============================================================
-- 工具函数
--============================================================
local function SafeDrawing(className, props)
    local ok, obj = pcall(function()
        local d = Drawing.new(className)
        for k, v in pairs(props) do
            d[k] = v
        end
        return d
    end)
    if ok then return obj end
    return nil
end

-- 世界坐标 -> 屏幕坐标 (返回 Vector2, 是否在屏幕内)
local function WorldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen and screenPos.Z > 0
end

-- 获取角色所有部件
local function GetCharacterParts(character)
    local parts = {}
    if not character then return parts end
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            parts[part.Name] = part
        end
    end
    return parts
end

-- 获取角色包围盒 (基于 HumanoidRootPart 和 Head)
local function GetBoundingBox(character)
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not hrp or not head then return nil end

    local hrpPos = hrp.Position
    local headPos = head.Position
    local height = (headPos - hrpPos).Magnitude + 1.2
    local width = height * 0.55
    local center = hrpPos + Vector3.new(0, height * 0.25, 0)

    return center, width, height
end

-- 判断是否队友
local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    if player == LocalPlayer then return true end
    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team
    if myTeam and theirTeam and myTeam == theirTeam then
        return true
    end
    return false
end

-- 判断是否可见 (射线检测)
local function IsVisible(character)
    if not Settings.VisibleCheck then return true end
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end

    local origin = Camera.CFrame.Position
    local direction = (hrp.Position - origin)
    local ray = Ray.new(origin, direction)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }

    local result = Workspace:Raycast(origin, direction, params)
    if result and result.Instance then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar == character then
            return true
        end
        return false
    end
    return true
end

-- 彩虹色
local function RainbowColor(speed)
    local t = tick() * (speed or 1)
    return Color3.fromHSV((t * 0.5) % 1, 1, 1)
end

--============================================================
-- ESP 对象管理
--============================================================
local ESPCache = {}

local function CreateESP(player)
    local esp = {
        BoxFull = SafeDrawing("Square", { Thickness = 1, Filled = false, Visible = false }),
        BoxCorner = {
            TL = SafeDrawing("Line", { Thickness = 1, Visible = false }),
            TR = SafeDrawing("Line", { Thickness = 1, Visible = false }),
            BL = SafeDrawing("Line", { Thickness = 1, Visible = false }),
            BR = SafeDrawing("Line", { Thickness = 1, Visible = false }),
        },
        BoxFill = SafeDrawing("Square", { Filled = true, Visible = false }),
        Name = SafeDrawing("Text", { Size = Settings.FontSize, Center = true, Outline = true, Visible = false }),
        Distance = SafeDrawing("Text", { Size = Settings.FontSize, Center = true, Outline = true, Visible = false }),
        HealthBarBg = SafeDrawing("Square", { Filled = true, Visible = false }),
        HealthBarFill = SafeDrawing("Square", { Filled = true, Visible = false }),
        HealthText = SafeDrawing("Text", { Size = Settings.FontSize, Center = true, Outline = true, Visible = false }),
        SkeletonLines = {},
    }
    ESPCache[player] = esp
    return esp
end

local function RemoveESP(player)
    local esp = ESPCache[player]
    if not esp then return end
    if esp.BoxFull then esp.BoxFull:Remove() end
    for _, line in pairs(esp.BoxCorner) do
        if line then line:Remove() end
    end
    if esp.BoxFill then esp.BoxFill:Remove() end
    if esp.Name then esp.Name:Remove() end
    if esp.Distance then esp.Distance:Remove() end
    if esp.HealthBarBg then esp.HealthBarBg:Remove() end
    if esp.HealthBarFill then esp.HealthBarFill:Remove() end
    if esp.HealthText then esp.HealthText:Remove() end
    for _, line in ipairs(esp.SkeletonLines) do
        if line then line:Remove() end
    end
    ESPCache[player] = nil
end

local function HideESP(esp)
    if esp.BoxFull then esp.BoxFull.Visible = false end
    for _, line in pairs(esp.BoxCorner) do
        if line then line.Visible = false end
    end
    if esp.BoxFill then esp.BoxFill.Visible = false end
    if esp.Name then esp.Name.Visible = false end
    if esp.Distance then esp.Distance.Visible = false end
    if esp.HealthBarBg then esp.HealthBarBg.Visible = false end
    if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
    if esp.HealthText then esp.HealthText.Visible = false end
    for _, line in ipairs(esp.SkeletonLines) do
        if line then line.Visible = false end
    end
end

--============================================================
-- 骨骼绘制
--============================================================
local SKELETON_CONNECTIONS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function UpdateSkeleton(esp, character)
    local parts = GetCharacterParts(character)
    local lines = esp.SkeletonLines
    local color = Settings.Drawing.Skeleton.Color
    local trans = Settings.GlobalTransparency

    for i, conn in ipairs(SKELETON_CONNECTIONS) do
        local p1 = parts[conn[1]]
        local p2 = parts[conn[2]]
        if not lines[i] then
            lines[i] = SafeDrawing("Line", { Thickness = 1, Visible = false })
        end
        local line = lines[i]
        if not line then continue end

        if p1 and p2 then
            local v1, on1 = WorldToScreen(p1.Position)
            local v2, on2 = WorldToScreen(p2.Position)
            if on1 and on2 then
                line.From = v1
                line.To = v2
                line.Color = color
                line.Transparency = trans
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
    -- 隐藏多余的线
    for i = #SKELETON_CONNECTIONS + 1, #lines do
        if lines[i] then lines[i].Visible = false end
    end
end

--============================================================
-- 主更新循环
--============================================================
local rotationAngle = 0

local function UpdateESP()
    if not Settings.Enabled then
        for player, esp in pairs(ESPCache) do
            HideESP(esp)
        end
        return
    end

    -- 更新旋转角度
    if Settings.Drawing.Boxes.Animate then
        rotationAngle = rotationAngle + (Settings.Drawing.Boxes.RotationSpeed / 100) * 0.05
        if rotationAngle > math.pi * 2 then rotationAngle = rotationAngle - math.pi * 2 end
    end

    local pulse = 0.5 + 0.5 * math.sin(tick() * 3)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local esp = ESPCache[player]
        if not esp then
            esp = CreateESP(player)
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoid or not hrp or humanoid.Health <= 0 then
            HideESP(esp)
            continue
        end

        -- 距离检测
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.MaxDistance then
            HideESP(esp)
            continue
        end

        -- 队友检测
        if IsTeammate(player) then
            HideESP(esp)
            continue
        end

        -- 包围盒计算
        local center, width, height = GetBoundingBox(character)
        if not center then
            HideESP(esp)
            continue
        end

        local screenCenter, onScreen = WorldToScreen(center)
        if not onScreen then
            HideESP(esp)
            continue
        end

        -- 计算屏幕尺寸
        local topWorld = center + Vector3.new(0, height / 2, 0)
        local bottomWorld = center - Vector3.new(0, height / 2, 0)
        local topScreen = WorldToScreen(topWorld)
        local bottomScreen = WorldToScreen(bottomWorld)

        local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
        local boxWidth = boxHeight * 0.55
        if boxHeight < 2 or boxWidth < 2 then
            HideESP(esp)
            continue
        end

        local x = screenCenter.X - boxWidth / 2
        local y = screenCenter.Y - boxHeight / 2

        -- 可见性
        local visible = IsVisible(character)

        -- 颜色选择
        local teamColor = visible and Settings.Options.TeamVisibleRGB or Settings.Options.TeamHiddenRGB
        local enemyColor = visible and Settings.Options.EnemyVisibleRGB or Settings.Options.EnemyHiddenRGB
        local baseColor = IsTeammate(player) and teamColor or enemyColor

        local globalTrans = Settings.GlobalTransparency

        --========== 方框 ==========
        if Settings.Drawing.Boxes.Full.Enabled then
            local box = esp.BoxFull
            if box then
                box.Size = Vector2.new(boxWidth, boxHeight)
                box.Position = Vector2.new(x, y)
                box.Color = baseColor
                box.Thickness = 1
                box.Transparency = globalTrans
                box.Visible = true
            end
        else
            if esp.BoxFull then esp.BoxFull.Visible = false end
        end

        --========== 边角方框 ==========
        if Settings.Drawing.Boxes.Corner.Enabled then
            local cornerLen = math.min(boxWidth, boxHeight) * 0.25
            local corners = esp.BoxCorner
            -- 左上
            corners.TL.From = Vector2.new(x, y + cornerLen)
            corners.TL.To = Vector2.new(x, y)
            corners.TL.Color = baseColor
            corners.TL.Transparency = globalTrans
            corners.TL.Visible = true
            -- 右上
            corners.TR.From = Vector2.new(x + boxWidth - cornerLen, y)
            corners.TR.To = Vector2.new(x + boxWidth, y)
            corners.TR.Color = baseColor
            corners.TR.Transparency = globalTrans
            corners.TR.Visible = true
            -- 左下
            corners.BL.From = Vector2.new(x, y + boxHeight - cornerLen)
            corners.BL.To = Vector2.new(x, y + boxHeight)
            corners.BL.Color = baseColor
            corners.BL.Transparency = globalTrans
            corners.BL.Visible = true
            -- 右下
            corners.BR.From = Vector2.new(x + boxWidth - cornerLen, y + boxHeight)
            corners.BR.To = Vector2.new(x + boxWidth, y + boxHeight)
            corners.BR.Color = baseColor
            corners.BR.Transparency = globalTrans
            corners.BR.Visible = true
        else
            for _, line in pairs(esp.BoxCorner) do
                if line then line.Visible = false end
            end
        end

        --========== 方框填充 ==========
        if Settings.Drawing.Boxes.Filled.Enabled then
            local fill = esp.BoxFill
            if fill then
                fill.Size = Vector2.new(boxWidth, boxHeight)
                fill.Position = Vector2.new(x, y)
                fill.Color = baseColor
                fill.Transparency = Settings.Drawing.Boxes.Filled.Transparency
                fill.Visible = true
            end
        else
            if esp.BoxFill then esp.BoxFill.Visible = false end
        end

        --========== 名字 ==========
        if Settings.Drawing.Names.Enabled then
            local nameText = esp.Name
            if nameText then
                nameText.Text = player.Name
                nameText.Size = Settings.FontSize
                nameText.Position = Vector2.new(screenCenter.X, y - Settings.FontSize - 4)
                nameText.Color = Settings.Drawing.Names.Color
                nameText.Transparency = globalTrans
                nameText.Visible = true
            end
        else
            if esp.Name then esp.Name.Visible = false end
        end

        --========== 距离 ==========
        if Settings.Drawing.Distances.Enabled then
            local distText = esp.Distance
            if distText then
                distText.Text = string.format("[%d]", math.floor(distance))
                distText.Size = Settings.FontSize
                distText.Position = Vector2.new(screenCenter.X, y + boxHeight + 2)
                distText.Color = Settings.Drawing.Distances.Color
                distText.Transparency = globalTrans
                distText.Visible = true
            end
        else
            if esp.Distance then esp.Distance.Visible = false end
        end

        --========== 血条 ==========
        if Settings.Drawing.Healthbar.Enabled then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barWidth = 3
            local barX = x - barWidth - 4
            local barY = y
            local barHeight = boxHeight

            local bg = esp.HealthBarBg
            local fill = esp.HealthBarFill
            if bg and fill then
                bg.Size = Vector2.new(barWidth, barHeight)
                bg.Position = Vector2.new(barX, barY)
                bg.Color = Color3.fromRGB(30, 30, 30)
                bg.Transparency = 0.3 + globalTrans
                bg.Visible = true

                local fillHeight = barHeight * healthPercent
                fill.Size = Vector2.new(barWidth, fillHeight)
                fill.Position = Vector2.new(barX, barY + barHeight - fillHeight)
                -- 血条渐变
                local c1 = Settings.Drawing.Healthbar.GradientRGB1
                local c3 = Settings.Drawing.Healthbar.GradientRGB3
                fill.Color = c1:Lerp(c3, 1 - healthPercent)
                fill.Transparency = globalTrans
                fill.Visible = true
            end

            -- 血量数字
            if Settings.Drawing.Healthbar.HealthText then
                local ht = esp.HealthText
                if ht then
                    if healthPercent < 1 then
                        ht.Text = tostring(math.floor(humanoid.Health))
                        ht.Size = Settings.FontSize
                        ht.Position = Vector2.new(screenCenter.X, y + boxHeight / 2)
                        ht.Color = Color3.fromRGB(255, 255, 255)
                        ht.Transparency = globalTrans
                        ht.Visible = true
                    else
                        ht.Visible = false
                    end
                end
            else
                if esp.HealthText then esp.HealthText.Visible = false end
            end
        else
            if esp.HealthBarBg then esp.HealthBarBg.Visible = false end
            if esp.HealthBarFill then esp.HealthBarFill.Visible = false end
            if esp.HealthText then esp.HealthText.Visible = false end
        end

        --========== 骨骼 ==========
        if Settings.Drawing.Skeleton.Enabled then
            UpdateSkeleton(esp, character)
        else
            for _, line in ipairs(esp.SkeletonLines) do
                if line then line.Visible = false end
            end
        end

        --========== 高亮 (Chams) ==========
        if Settings.Drawing.Chams.Enabled then
            local highlight = character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Parent = character
            end
            highlight.FillColor = baseColor
            highlight.OutlineColor = baseColor
            highlight.FillTransparency = Settings.Drawing.Chams.Fill_Transparency / 100
            highlight.OutlineTransparency = Settings.Drawing.Chams.Outline_Transparency / 100
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = character
        else
            local highlight = character:FindFirstChild("ESP_Highlight")
            if highlight then highlight:Destroy() end
        end
    end

    -- 清理已离开的玩家
    for player, esp in pairs(ESPCache) do
        if not player.Parent then
            RemoveESP(player)
        end
    end
end

--============================================================
-- 自身/敌人 高级高亮 (ChamsLogic)
--============================================================
local function UpdateChamsLogic()
    -- 自身高亮
    local myChar = LocalPlayer.Character
    if myChar then
        local selfHL = myChar:FindFirstChild("SelfChams_Highlight")
        if ChamsLogic.Self.Enabled then
            if not selfHL then
                selfHL = Instance.new("Highlight")
                selfHL.Name = "SelfChams_Highlight"
                selfHL.Parent = myChar
                selfHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
            local color = ChamsLogic.Self.Rainbow and RainbowColor(1) or ChamsLogic.Self.Color
            selfHL.FillColor = color
            selfHL.OutlineColor = color
            selfHL.FillTransparency = 0.5
            selfHL.OutlineTransparency = 0
            selfHL.Adornee = myChar
        else
            if selfHL then selfHL:Destroy() end
        end
    end

    -- 敌人高级高亮
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end

        local enemyHL = char:FindFirstChild("EnemyChams_Highlight")
        if ChamsLogic.Enemy.Enabled then
            if ChamsLogic.Enemy.TeamCheck and IsTeammate(player) then
                if enemyHL then enemyHL:Destroy() end
                continue
            end

            if not enemyHL then
                enemyHL = Instance.new("Highlight")
                enemyHL.Name = "EnemyChams_Highlight"
                enemyHL.Parent = char
                enemyHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end

            local visible = true
            if ChamsLogic.Enemy.VisibleCheck then
                visible = IsVisible(char)
            end
            local color = visible and ChamsLogic.Enemy.VisibleColor or ChamsLogic.Enemy.OccludedColor
            enemyHL.FillColor = color
            enemyHL.OutlineColor = color
            enemyHL.FillTransparency = 0.5
            enemyHL.OutlineTransparency = 0
            enemyHL.Adornee = char
        else
            if enemyHL then enemyHL:Destroy() end
        end
    end
end

--============================================================
-- 子弹轨迹
--============================================================
local function InitializeHooks()
    -- 简单的子弹轨迹: 监听 Workspace 中的新实例
    local tracerFolder = Workspace:FindFirstChild("ESP_BulletTracers")
    if not tracerFolder then
        tracerFolder = Instance.new("Folder")
        tracerFolder.Name = "ESP_BulletTracers"
        tracerFolder.Parent = Workspace
    end

    local connection
    connection = Workspace.DescendantAdded:Connect(function(descendant)
        if not BulletTracer.Enabled then return end
        if not descendant:IsA("BasePart") then return end
        if not descendant.Name:lower():find("bullet") and not descendant.Name:lower():find("tracer") then return end

        local startPos = descendant.Position
        local velocity = descendant.AssemblyLinearVelocity
        if velocity.Magnitude < 1 then return end

        local endPos = startPos + velocity.Unit * 50

        local line = SafeDrawing("Line", {
            From = Vector2.new(0, 0),
            To = Vector2.new(0, 0),
            Thickness = BulletTracer.Width,
            Color = BulletTracer.Color,
            Transparency = 0.2,
            Visible = true,
        })

        local startTime = tick()
        local updateConn
        updateConn = RunService.RenderStepped:Connect(function()
            if not line then return end
            if tick() - startTime > BulletTracer.Duration then
                line.Visible = false
                line:Remove()
                updateConn:Disconnect()
                return
            end
            local s, on1 = WorldToScreen(startPos)
            local e, on2 = WorldToScreen(endPos)
            if on1 and on2 then
                line.From = s
                line.To = e
                line.Visible = true
            else
                line.Visible = false
            end
        end)
    end)

    getgenv().ESP_BulletConnection = connection
end

getgenv().InitializeHooks = InitializeHooks

--============================================================
-- 启动主循环
--============================================================
RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateChamsLogic)
end)

-- 玩家离开时清理
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- 角色移除时清理高亮
local function onCharacterAdded(character)
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            local hl = character:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(onCharacterAdded)
        if player.Character then onCharacterAdded(player.Character) end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(onCharacterAdded)
    end
end)

print("[ESP] 透视脚本加载成功!")