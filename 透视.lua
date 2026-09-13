local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local Settings = {
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    MaxDistance = 2000,
    FontSize = 10,
    GlobalTransparency = 0,
    Options = {
        EnemyVisibleRGB = Color3.fromRGB(255, 0, 0),
        EnemyHiddenRGB = Color3.fromRGB(255, 0, 0),
        TeamVisibleRGB = Color3.fromRGB(0, 255, 0),
        TeamHiddenRGB = Color3.fromRGB(0, 255, 0),
    },
    Drawing = {
        Boxes = {
            Full = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Corner = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Filled = { Enabled = false, Color = Color3.fromRGB(0, 0, 0), Transparency = 0.85 },
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
            Fill_Transparency = 60,
            Outline_Transparency = 0,
            Pulse = true,
        },
        Skeleton = { Enabled = true, Color = Color3.fromRGB(255, 255, 255) },
    },
}

local ChamsLogic = {
    Self = {
        Enabled = false,
        Rainbow = false,
        Color = Color3.fromRGB(255, 255, 255),
    },
    Enemy = {
        Enabled = false,
        TeamCheck = true,
        VisibleCheck = true,
        OccludedColor = Color3.fromRGB(255, 0, 0),
        VisibleColor = Color3.fromRGB(0, 255, 0),
    },
}

getgenv().HitLogsSettings = {
    Enabled = false,
    Duration = 3,
    Colors = {
        Background = Color3.fromRGB(0, 0, 0),
        TextPink = Color3.fromRGB(255, 182, 193),
        TextWhite = Color3.fromRGB(255, 255, 255),
    },
    Font = Font.new("rbxassetid://12187371840", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
}

local function IsAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(character)
    if not character then return false end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local origin = CurrentCamera.CFrame.Position
    local direction = (head.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character, LocalPlayer.Character, CurrentCamera }
    local result = Workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

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

local ESPCache = {}
local SkeletonCache = {}

local function CreateDrawing(class, props)
    local ok, obj = pcall(function()
        local d = Drawing.new(class)
        for k, v in pairs(props or {}) do
            d[k] = v
        end
        return d
    end)
    return ok and obj or nil
end

local function CleanupPlayerESP(cache)
    if not cache then return end
    for _, obj in pairs(cache) do
        if typeof(obj) == "table" then
            for _, sub in pairs(obj) do
                pcall(function() sub:Remove() end)
            end
        else
            pcall(function() obj:Remove() end)
        end
    end
end

local function CreatePlayerESP()
    local cache = {}
    cache.BoxFull = CreateDrawing("Square", {
        Thickness = 1,
        Filled = false,
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
    })
    cache.BoxCorner = {}
    for i = 1, 4 do
        cache.BoxCorner[i] = CreateDrawing("Line", {
            Thickness = 1,
            Visible = false,
            Color = Color3.fromRGB(255, 255, 255),
        })
    end
    cache.BoxFill = CreateDrawing("Square", {
        Filled = true,
        Visible = false,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.85,
    })
    cache.Name = CreateDrawing("Text", {
        Size = Settings.FontSize,
        Center = true,
        Outline = true,
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Font = 2,
    })
    cache.Distance = CreateDrawing("Text", {
        Size = Settings.FontSize,
        Center = true,
        Outline = true,
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Font = 2,
    })
    cache.HealthBarBg = CreateDrawing("Square", {
        Filled = true,
        Visible = false,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.4,
    })
    cache.HealthBarFill = CreateDrawing("Square", {
        Filled = true,
        Visible = false,
        Color = Color3.fromRGB(0, 255, 0),
    })
    cache.HealthText = CreateDrawing("Text", {
        Size = Settings.FontSize,
        Center = true,
        Outline = true,
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Font = 2,
    })
    cache.Highlight = nil
    return cache
end

local function CreateSkeletonESP()
    local lines = {}
    for i = 1, #SKELETON_CONNECTIONS do
        lines[i] = CreateDrawing("Line", {
            Thickness = 1,
            Visible = false,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 1,
        })
    end
    return lines
end

local function UpdateSkeleton(cache, character, color, alpha)
    if not cache then return end
    for i, conn in ipairs(SKELETON_CONNECTIONS) do
        local line = cache[i]
        if not line then continue end
        local p1 = character:FindFirstChild(conn[1])
        local p2 = character:FindFirstChild(conn[2])
        if p1 and p2 then
            local s1, on1 = CurrentCamera:WorldToViewportPoint(p1.Position)
            local s2, on2 = CurrentCamera:WorldToViewportPoint(p2.Position)
            if on1 and on2 then
                line.From = Vector2.new(s1.X, s1.Y)
                line.To = Vector2.new(s2.X, s2.Y)
                line.Color = color
                line.Transparency = alpha
                line.Visible = Settings.Drawing.Skeleton.Enabled
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function CleanupSkeleton(cache)
    if not cache then return end
    for _, line in ipairs(cache) do
        pcall(function() line:Remove() end)
    end
end

local pulseTime = 0
local rotateTime = 0

RunService.RenderStepped:Connect(function(dt)
    pulseTime = pulseTime + dt
    rotateTime = rotateTime + dt

    if not Settings.Enabled then
        -- 全部隐藏
        for _, cache in pairs(ESPCache) do
            CleanupPlayerESP(cache)
        end
        for _, cache in pairs(SkeletonCache) do
            CleanupSkeleton(cache)
        end
        ESPCache = {}
        SkeletonCache = {}
        return
    end

    local pulseAlpha = 1
    if Settings.Drawing.Chams.Pulse then
        pulseAlpha = 0.6 + 0.4 * math.sin(pulseTime * 4)
    end

    local localChar = LocalPlayer.Character
    local localPos = localChar and localChar:FindFirstChild("HumanoidRootPart") and localChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        if not IsAlive(character) then
            if ESPCache[player] then
                CleanupPlayerESP(ESPCache[player])
                ESPCache[player] = nil
            end
            if SkeletonCache[player] then
                CleanupSkeleton(SkeletonCache[player])
                SkeletonCache[player] = nil
            end
            continue
        end

        if Settings.TeamCheck and IsTeammate(player) then
            if ESPCache[player] then
                CleanupPlayerESP(ESPCache[player])
                ESPCache[player] = nil
            end
            if SkeletonCache[player] then
                CleanupSkeleton(SkeletonCache[player])
                SkeletonCache[player] = nil
            end
            continue
        end

        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        if not root then continue end

        local distance = localPos and (root.Position - localPos).Magnitude or 0
        if Settings.MaxDistance and distance > Settings.MaxDistance then
            if ESPCache[player] then
                CleanupPlayerESP(ESPCache[player])
                ESPCache[player] = nil
            end
            if SkeletonCache[player] then
                CleanupSkeleton(SkeletonCache[player])
                SkeletonCache[player] = nil
            end
            continue
        end

        local head = character:FindFirstChild("Head")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then continue end

        local headPos, headOnScreen = CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        if not headOnScreen and not rootOnScreen then
            if ESPCache[player] then
                CleanupPlayerESP(ESPCache[player])
                ESPCache[player] = nil
            end
            if SkeletonCache[player] then
                CleanupSkeleton(SkeletonCache[player])
                SkeletonCache[player] = nil
            end
            continue
        end

        if not ESPCache[player] then
            ESPCache[player] = CreatePlayerESP()
        end

        local cache = ESPCache[player]
        local hrpPos = hrp.Position
        local topPos = CurrentCamera:WorldToViewportPoint(hrpPos + Vector3.new(0, 3, 0))
        local bottomPos = CurrentCamera:WorldToViewportPoint(hrpPos - Vector3.new(0, 3, 0))

        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
        local boxWidth = boxHeight * 0.55
        local boxTop = Vector2.new(topPos.X - boxWidth / 2, topPos.Y)
        local boxBottom = Vector2.new(bottomPos.X + boxWidth / 2, bottomPos.Y)

        local isVisible = true
        if Settings.VisibleCheck then
            isVisible = IsVisible(character)
        end

        local isTeam = IsTeammate(player)
        local color
        if isTeam then
            color = isVisible and Settings.Options.TeamVisibleRGB or Settings.Options.TeamHiddenRGB
        else
            color = isVisible and Settings.Options.EnemyVisibleRGB or Settings.Options.EnemyHiddenRGB
        end

        local globalAlpha = 1 - Settings.GlobalTransparency

        if Settings.Drawing.Boxes.Full.Enabled then
            cache.BoxFull.Size = Vector2.new(boxWidth, boxHeight)
            cache.BoxFull.Position = boxTop
            cache.BoxFull.Color = color
            cache.BoxFull.Transparency = globalAlpha
            cache.BoxFull.Visible = true
        else
            cache.BoxFull.Visible = false
        end

        if Settings.Drawing.Boxes.Corner.Enabled then
            local cornerLen = math.min(boxWidth, boxHeight) * 0.25
            local corners = {
                {Vector2.new(boxTop.X, boxTop.Y), Vector2.new(boxTop.X + cornerLen, boxTop.Y)},
                {Vector2.new(boxTop.X, boxTop.Y), Vector2.new(boxTop.X, boxTop.Y + cornerLen)},
                {Vector2.new(boxBottom.X, boxTop.Y), Vector2.new(boxBottom.X - cornerLen, boxTop.Y)},
                {Vector2.new(boxBottom.X, boxTop.Y), Vector2.new(boxBottom.X, boxTop.Y + cornerLen)},
                {Vector2.new(boxTop.X, boxBottom.Y), Vector2.new(boxTop.X + cornerLen, boxBottom.Y)},
                {Vector2.new(boxTop.X, boxBottom.Y), Vector2.new(boxTop.X, boxBottom.Y - cornerLen)},
                {Vector2.new(boxBottom.X, boxBottom.Y), Vector2.new(boxBottom.X - cornerLen, boxBottom.Y)},
                {Vector2.new(boxBottom.X, boxBottom.Y), Vector2.new(boxBottom.X, boxBottom.Y - cornerLen)},
            }
            for i = 1, 4 do
                local line = cache.BoxCorner[i]
                if line then
                    line.From = corners[i * 2 - 1][1]
                    line.To = corners[i * 2 - 1][2]
                    line.Color = color
                    line.Transparency = globalAlpha
                    line.Visible = true
                end
            end
        else
            for i = 1, 4 do
                if cache.BoxCorner[i] then
                    cache.BoxCorner[i].Visible = false
                end
            end
        end

        if Settings.Drawing.Boxes.Filled.Enabled then
            cache.BoxFill.Size = Vector2.new(boxWidth, boxHeight)
            cache.BoxFill.Position = boxTop
            cache.BoxFill.Color = color
            cache.BoxFill.Transparency = Settings.Drawing.Boxes.Filled.Transparency
            cache.BoxFill.Visible = true
        else
            cache.BoxFill.Visible = false
        end

        if Settings.Drawing.Names.Enabled then
            cache.Name.Text = player.Name
            cache.Name.Position = Vector2.new(boxTop.X + boxWidth / 2, boxTop.Y - 16)
            cache.Name.Color = color
            cache.Name.Transparency = globalAlpha
            cache.Name.Size = Settings.FontSize
            cache.Name.Visible = true
        else
            cache.Name.Visible = false
        end

        if Settings.Drawing.Distances.Enabled then
            cache.Distance.Text = string.format("[%d]", math.floor(distance))
            cache.Distance.Position = Vector2.new(boxTop.X + boxWidth / 2, boxBottom.Y + 2)
            cache.Distance.Color = color
            cache.Distance.Transparency = globalAlpha
            cache.Distance.Size = Settings.FontSize
            cache.Distance.Visible = true
        else
            cache.Distance.Visible = false
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if Settings.Drawing.Healthbar.Enabled and humanoid then
            local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barWidth = 2
            local barX = boxTop.X - barWidth - 3
            local barHeight = boxHeight * hpRatio

            cache.HealthBarBg.Size = Vector2.new(barWidth, boxHeight)
            cache.HealthBarBg.Position = Vector2.new(barX, boxTop.Y)
            cache.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
            cache.HealthBarBg.Transparency = 0.4
            cache.HealthBarBg.Visible = true

            cache.HealthBarFill.Size = Vector2.new(barWidth, barHeight)
            cache.HealthBarFill.Position = Vector2.new(barX, boxBottom.Y - barHeight)
            local topColor = Settings.Drawing.Healthbar.GradientRGB1
            local bottomColor = Settings.Drawing.Healthbar.GradientRGB3
            cache.HealthBarFill.Color = topColor:Lerp(bottomColor, 1 - hpRatio)
            cache.HealthBarFill.Transparency = globalAlpha
            cache.HealthBarFill.Visible = true

            if Settings.Drawing.Healthbar.HealthText and hpRatio < 1 then
                cache.HealthText.Text = string.format("%d", math.floor(humanoid.Health))
                cache.HealthText.Position = Vector2.new(barX, boxBottom.Y + 2)
                cache.HealthText.Color = color
                cache.HealthText.Transparency = globalAlpha
                cache.HealthText.Size = Settings.FontSize
                cache.HealthText.Visible = true
            else
                cache.HealthText.Visible = false
            end
        else
            if cache.HealthBarBg then cache.HealthBarBg.Visible = false end
            if cache.HealthBarFill then cache.HealthBarFill.Visible = false end
            if cache.HealthText then cache.HealthText.Visible = false end
        end

        if Settings.Drawing.Chams.Enabled then
            if not cache.Highlight then
                local ok, hl = pcall(function()
                    local h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = CoreGui
                    return h
                end)
                if ok then cache.Highlight = hl end
            end
            if cache.Highlight then
                cache.Highlight.Adornee = character
                cache.Highlight.FillColor = color
                cache.Highlight.OutlineColor = color
                cache.Highlight.FillTransparency = Settings.Drawing.Chams.Fill_Transparency / 100
                cache.Highlight.OutlineTransparency = Settings.Drawing.Chams.Outline_Transparency / 100
                cache.Highlight.Enabled = true
            end
        else
            if cache.Highlight then
                cache.Highlight.Enabled = false
            end
        end

        if Settings.Drawing.Skeleton.Enabled then
            if not SkeletonCache[player] then
                SkeletonCache[player] = CreateSkeletonESP()
            end
            UpdateSkeleton(SkeletonCache[player], character, color, globalAlpha)
        else
            if SkeletonCache[player] then
                for _, line in ipairs(SkeletonCache[player]) do
                    line.Visible = false
                end
            end
        end
    end

    for player, cache in pairs(ESPCache) do
        if not player.Parent or not player.Character or not IsAlive(player.Character) then
            CleanupPlayerESP(cache)
            ESPCache[player] = nil
        end
    end
    for player, cache in pairs(SkeletonCache) do
        if not player.Parent or not player.Character or not IsAlive(player.Character) then
            CleanupSkeleton(cache)
            SkeletonCache[player] = nil
        end
    end
end)

local ChamsHighlights = {}

local function CreateChamsHighlight(adornee, fillColor, outlineColor, fillTrans, outlineTrans)
    local ok, hl = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "AdvancedChams"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = adornee
        h.FillColor = fillColor
        h.OutlineColor = outlineColor
        h.FillTransparency = fillTrans
        h.OutlineTransparency = outlineTrans
        h.Parent = CoreGui
        return h
    end)
    return ok and hl or nil
end

RunService.RenderStepped:Connect(function(dt)
    -- 自身高亮
    if ChamsLogic.Self.Enabled then
        local char = LocalPlayer.Character
        if char and IsAlive(char) then
            if not ChamsHighlights.Self then
                ChamsHighlights.Self = CreateChamsHighlight(char, ChamsLogic.Self.Color, ChamsLogic.Self.Color, 0.5, 0)
            end
            if ChamsHighlights.Self then
                ChamsHighlights.Self.Adornee = char
                local c = ChamsLogic.Self.Color
                if ChamsLogic.Self.Rainbow then
                    local t = tick()
                    c = Color3.fromHSV((t * 0.5) % 1, 1, 1)
                end
                ChamsHighlights.Self.FillColor = c
                ChamsHighlights.Self.OutlineColor = c
                ChamsHighlights.Self.Enabled = true
            end
        else
            if ChamsHighlights.Self then
                ChamsHighlights.Self.Enabled = false
            end
        end
    else
        if ChamsHighlights.Self then
            ChamsHighlights.Self.Enabled = false
        end
    end

    if ChamsLogic.Enemy.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not IsAlive(char) then
                if ChamsHighlights[player] then
                    pcall(function() ChamsHighlights[player]:Remove() end)
                    ChamsHighlights[player] = nil
                end
                continue
            end
            if ChamsLogic.Enemy.TeamCheck and IsTeammate(player) then
                if ChamsHighlights[player] then
                    pcall(function() ChamsHighlights[player]:Remove() end)
                    ChamsHighlights[player] = nil
                end
                continue
            end

            local color = ChamsLogic.Enemy.OccludedColor
            if ChamsLogic.Enemy.VisibleCheck then
                color = IsVisible(char) and ChamsLogic.Enemy.VisibleColor or ChamsLogic.Enemy.OccludedColor
            else
                color = ChamsLogic.Enemy.VisibleColor
            end

            if not ChamsHighlights[player] then
                ChamsHighlights[player] = CreateChamsHighlight(char, color, color, 0.5, 0)
            end
            if ChamsHighlights[player] then
                ChamsHighlights[player].Adornee = char
                ChamsHighlights[player].FillColor = color
                ChamsHighlights[player].OutlineColor = color
                ChamsHighlights[player].Enabled = true
            end
        end
    else
        for player, hl in pairs(ChamsHighlights) do
            if player ~= "Self" then
                pcall(function() hl:Remove() end)
                ChamsHighlights[player] = nil
            end
        end
    end
end)