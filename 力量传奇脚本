local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gycgchgyfytdttr/shenqin/refs/heads/main/ui.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local rainbowBorderAnimation
local currentBorderColorScheme = "彩虹颜色"
local currentFontColorScheme = "彩虹颜色"
local borderInitialized = false
local animationSpeed = 2
local borderEnabled = true
local fontColorEnabled = false
local uiScale = 1
local blurEnabled = false
local soundEnabled = true

local FONT_STYLES = {
    "SourceSansBold","SourceSansItalic","SourceSansLight","SourceSans",
    "GothamSSm","GothamSSm-Bold","GothamSSm-Medium","GothamSSm-Light",
    "GothamSSm-Black","GothamSSm-Book","GothamSSm-XLight","GothamSSm-Thin",
    "GothamSSm-Ultra","GothamSSm-SemiBold","GothamSSm-ExtraLight","GothamSSm-Heavy",
    "GothamSSm-ExtraBold","GothamSSm-Regular","Gotham","GothamBold",
    "GothamMedium","GothamBlack","GothamLight","Arial","ArialBold",
    "Code","CodeLight","CodeBold","Highway","HighwayBold","HighwayLight",
    "SciFi","SciFiBold","SciFiItalic","Cartoon","CartoonBold","Handwritten"
}

local FONT_DESCRIPTIONS = {
    ["SourceSansBold"] = "标准粗体",["SourceSansItalic"] = "斜体",["SourceSansLight"] = "细体",
    ["SourceSans"] = "标准体",["GothamSSm"] = "哥特标准",["GothamSSm-Bold"] = "哥特粗体",
    ["GothamSSm-Medium"] = "哥特中等",["GothamSSm-Light"] = "哥特细体",["GothamSSm-Black"] = "哥特黑体",
    ["GothamSSm-Book"] = "哥特书本体",["GothamSSm-XLight"] = "哥特超细体",["GothamSSm-Thin"] = "哥特极细体",
    ["GothamSSm-Ultra"] = "哥特超黑体",["GothamSSm-SemiBold"] = "哥特半粗体",["GothamSSm-ExtraLight"] = "哥特特细体",
    ["GothamSSm-Heavy"] = "哥特粗重体",["GothamSSm-ExtraBold"] = "哥特特粗体",["GothamSSm-Regular"] = "哥特常规体",
    ["Gotham"] = "经典哥特体",["GothamBold"] = "经典哥特粗体",["GothamMedium"] = "经典哥特中等",
    ["GothamBlack"] = "经典哥特黑体",["GothamLight"] = "经典哥特细体",["Arial"] = "标准Arial体",
    ["ArialBold"] = "Arial粗体",["Code"] = "代码字体",["CodeLight"] = "代码细体",
    ["CodeBold"] = "代码粗体",["Highway"] = "高速公路体",["HighwayBold"] = "高速公路粗体",
    ["HighwayLight"] = "高速公路细体",["SciFi"] = "科幻字体",["SciFiBold"] = "科幻粗体",
    ["SciFiItalic"] = "科幻斜体",["Cartoon"] = "卡通字体",["CartoonBold"] = "卡通粗体",
    ["Handwritten"] = "手写体"
}

local currentFontStyle = "SourceSansBold"

local COLOR_SCHEMES = {
    ["彩虹颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE"))}),"palette"},
    ["黑红颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1, Color3.fromHex("000000"))}),"alert-triangle"},
    ["蓝白颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FFFFFF")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFFFFF"))}),"droplet"},
    ["紫金颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFD700"))}),"crown"},
    ["蓝黑颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("000000"))}),"moon"},
    ["绿紫颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("800080")),ColorSequenceKeypoint.new(1, Color3.fromHex("00FF00"))}),"zap"},
    ["粉蓝颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00BFFF")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF69B4"))}),"heart"},
    ["橙青颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("00CED1")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF4500"))}),"sun"},
    ["红金颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF0000"))}),"award"},
    ["银蓝颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("4682B4")),ColorSequenceKeypoint.new(1, Color3.fromHex("C0C0C0"))}),"star"},
    ["霓虹颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(0.25, Color3.fromHex("00FFFF")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.75, Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("00FFFF"))}),"sparkles"},
    ["森林颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("228B22")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("32CD32")),ColorSequenceKeypoint.new(1, Color3.fromHex("228B22"))}),"tree"},
    ["火焰颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1, Color3.fromHex("FF8C00"))}),"flame"},
    ["海洋颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("000080")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1, Color3.fromHex("00BFFF"))}),"waves"},
    ["日落颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF8C00")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFD700"))}),"sunset"},
    ["银河颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1, Color3.fromHex("9370DB"))}),"galaxy"},
    ["糖果颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF1493")),ColorSequenceKeypoint.new(1, Color3.fromHex("FFB6C1"))}),"candy"},
    ["金属颜色"] = {ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5, Color3.fromHex("A9A9A9")),ColorSequenceKeypoint.new(1, Color3.fromHex("696969"))}),"shield"}
}

local fontColorAnimations = {}

local function applyFontColorGradient(textElement, colorScheme)
    if not textElement or not textElement:IsA("TextLabel") and not textElement:IsA("TextButton") and not textElement:IsA("TextBox") then
        return
    end
    
    local existingGradient = textElement:FindFirstChild("FontColorGradient")
    if existingGradient then
        existingGradient:Destroy()
    end
    
    if fontColorAnimations[textElement] then
        fontColorAnimations[textElement]:Disconnect()
        fontColorAnimations[textElement] = nil
    end
    
    if not fontColorEnabled then
        textElement.TextColor3 = Color3.new(1, 1, 1)
        return
    end
    
    local schemeData = COLOR_SCHEMES[colorScheme or currentFontColorScheme]
    if not schemeData then return end
    
    local fontGradient = Instance.new("UIGradient")
    fontGradient.Name = "FontColorGradient"
    fontGradient.Color = schemeData[1]
    fontGradient.Rotation = 0
    fontGradient.Parent = textElement
    
    textElement.TextColor3 = Color3.new(1, 1, 1)
    
    local animation
    animation = game:GetService("RunService").Heartbeat:Connect(function()
        if not textElement or textElement.Parent == nil then
            animation:Disconnect()
            fontColorAnimations[textElement] = nil
            return
        end
        
        if not fontGradient or fontGradient.Parent == nil then
            animation:Disconnect()
            fontColorAnimations[textElement] = nil
            return
        end
        
        local time = tick()
        fontGradient.Rotation = (time * animationSpeed * 30) % 360
    end)
    
    fontColorAnimations[textElement] = animation
end

local function applyFontStyleToWindow(fontStyle)
    if not Window or not Window.UIElements then 
        wait(0.5)
        if not Window or not Window.UIElements then
            return false
        end
    end
    
    local successCount = 0
    local totalCount = 0
    
    local function processElement(element)
        for _, child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                totalCount = totalCount + 1
                pcall(function()
                    child.Font = Enum.Font[fontStyle]
                    successCount = successCount + 1
                end)
            end
        end
    end
    
    processElement(Window.UIElements.Main)
    
    return successCount, totalCount
end

local function applyFontColorsToWindow(colorScheme)
    if not Window or not Window.UIElements then return end
    
    local function processElement(element)
        for _, child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                applyFontColorGradient(child, colorScheme)
            end
        end
    end
    
    processElement(Window.UIElements.Main)
end

local function createRainbowBorder(window, colorScheme, speed)
    if not window or not window.UIElements then
        wait(1)
        if not window or not window.UIElements then
            return nil, nil
        end
    end
    
    local mainFrame = window.UIElements.Main
    if not mainFrame then
        return nil, nil
    end
    
    local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then
        local glowEffect = existingStroke:FindFirstChild("GlowEffect")
        if glowEffect then
            local schemeData = COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
            if schemeData then
                glowEffect.Color = schemeData[1]
            end
        end
        return existingStroke, rainbowBorderAnimation
    end
    
    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end
    
    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Thickness = 1.5
    rainbowStroke.Color = Color3.new(1, 1, 1)
    rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
    rainbowStroke.Enabled = borderEnabled
    rainbowStroke.Parent = mainFrame
    
    local glowEffect = Instance.new("UIGradient")
    glowEffect.Name = "GlowEffect"
    
    local schemeData = COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
    if schemeData then
        glowEffect.Color = schemeData[1]
    else
        glowEffect.Color = COLOR_SCHEMES["彩虹颜色"][1]
    end
    
    glowEffect.Rotation = 0
    glowEffect.Parent = rainbowStroke
    
    return rainbowStroke, nil
end

local function startBorderAnimation(window, speed)
    if not window or not window.UIElements then
        return nil
    end
    
    local mainFrame = window.UIElements.Main
    if not mainFrame then
        return nil
    end
    
    local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke or not rainbowStroke.Enabled then
        return nil
    end
    
    local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then
        return nil
    end
    
    if rainbowBorderAnimation then
        rainbowBorderAnimation:Disconnect()
        rainbowBorderAnimation = nil
    end
    
    local animation
    animation = game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent == nil or not rainbowStroke.Enabled then
            animation:Disconnect()
            return
        end
        
        local time = tick()
        glowEffect.Rotation = (time * speed * 60) % 360
    end)
    
    rainbowBorderAnimation = animation
    return animation
end

local function initializeRainbowBorder(scheme, speed)
    speed = speed or animationSpeed
    
    local rainbowStroke, _ = createRainbowBorder(Window, scheme, speed)
    if rainbowStroke then
        if borderEnabled then
            startBorderAnimation(Window, speed)
        end
        borderInitialized = true
        return true
    end
    return false
end

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local function playSound()
    if soundEnabled then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://9047002353"
            sound.Volume = 0.3
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end)
    end
end

local function applyBlurEffect(enabled)
    if enabled then
        pcall(function()
            local blur = Instance.new("BlurEffect")
            blur.Size = 8
            blur.Name = "UIXH HUBBlur"
            blur.Parent = game:GetService("Lighting")
        end)
    else
        pcall(function()
            local existingBlur = game:GetService("Lighting"):FindFirstChild("UIXH HUBBlur")
            if existingBlur then
                existingBlur:Destroy()
            end
        end)
    end
end

local function applyUIScale(scale)
    if Window and Window.UIElements and Window.UIElements.Main then
        local mainFrame = Window.UIElements.Main
        mainFrame.Size = UDim2.new(0, 600 * scale, 0, 400 * scale)
    end
end

local Confirmed = false
local username = game:GetService("Players").LocalPlayer.Name
local coloredUsername = ""
local gradientColors = {
    "#4169E1", 
    "#6A5ACD",  
    "#9370DB",  
    "#8A2BE2", 
    "#4B0082"   
}
local goldColor = "#FFD700"
for i = 1, #username do
    local char = username:sub(i, i)
    
    if char:match("[A-Za-z0-9]") then
        local colorIndex = (i - 1) % #gradientColors + 1
        coloredUsername = coloredUsername .. '<font color="' .. gradientColors[colorIndex] .. '">' .. char .. '</font>'
    else
        coloredUsername = coloredUsername .. '<font color="' .. goldColor .. '">' .. char .. '</font>'
    end
end

WindUI:Popup({
    Title = 'Yttrium Hub',
    IconThemed = true,
    Icon = "crown",
    Content = "欢迎Yttrium Hub用户 " .. coloredUsername .. " \n力量传奇",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})

local function setupAntiAFK()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

_G.airStrike = false
_G.switchServers = false
_G.positionLock = false
local startTime = tick()

local targetPosition = Vector3.new(-8775.1904296875, 256.52142333984, -5853.5532226562)
local positionLockConnection

local autoKillConnection
local autoPunchConnection

local function startPositionLock()
    if positionLockConnection then
        positionLockConnection:Disconnect()
    end
    
    positionLockConnection = RunService.Heartbeat:Connect(function()
        if _G.positionLock then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                
                local platform = workspace:FindFirstChild("TeleportPlatform")
                if not platform then
                    platform = Instance.new("Part")
                    platform.Name = "TeleportPlatform"
                    platform.Parent = workspace
                    platform.CFrame = CFrame.new(-8775.1904296875, 251.52142333984, -5853.5532226562)
                    platform.Size = Vector3.new(10, 0, 10)
                    platform.Anchored = true
                end
            end
        end
    end)
end

local function autoKill()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHead = player.Character:FindFirstChild("Head")
            local myCharacter = LocalPlayer.Character
            
            if targetHead and myCharacter then
                local myLeftHand = myCharacter:FindFirstChild("LeftHand")
                
                if myLeftHand then
                    pcall(function()
                        firetouchinterest(targetHead, myLeftHand, 0)
                        task.wait(0.01)
                        firetouchinterest(targetHead, myLeftHand, 1)
                    end)
                end
            end
        end
    end
end

local function autoPunch()
    pcall(function()
        LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
        
        local character = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        
        if character and backpack then
            local punchTool = backpack:FindFirstChild("Punch")
            if punchTool then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:EquipTool(punchTool)
                end
            end
        end
    end)
end

local function serverHop()
    local success, errorMsg = pcall(function()
        local baseUrl = "https://games.roblox.com/v1/games/"
        local placeId = game.PlaceId
        local url = baseUrl .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
        
        local function findServer(cursor)
            local fullUrl = cursor and (url .. "&cursor=" .. cursor) or url
            local response = game:HttpGet(fullUrl)
            
            if not response then return nil end
            
            local data = game:GetService("HttpService"):JSONDecode(response)
            if not data then return nil end
            
            for _, server in ipairs(data.data) do
                if server.playing >= 14 and server.playing < server.maxPlayers then
                    return server.id
                end
            end
            
            if data.nextPageCursor then
                return findServer(data.nextPageCursor)
            end
            
            return nil
        end
        
        local serverId = findServer()
        
        if serverId then
            TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
        else
            TeleportService:Teleport(placeId, LocalPlayer)
        end
    end)
    
    if not success then
        warn("服务器跳转失败:", errorMsg)
    end
end

local function resetAllFeatures()
    _G.airStrike = false
    _G.switchServers = false
    _G.positionLock = false
    
    if getgenv() then
        getgenv().fly = false
        getgenv().AutoWeight = false
        getgenv().AutoPushups = false
        getgenv().AutoSitups = false
        getgenv().AutoHandstands = false
        getgenv().AutoAllTrain = false
        getgenv().AutoTrainTriple = false
        getgenv().AutoPushup = false
        getgenv().AutoSitup = false
        getgenv().AutoHandstand = false
    end
    
    if autoKillConnection then
        autoKillConnection:Disconnect()
        autoKillConnection = nil
    end
    
    if autoPunchConnection then
        autoPunchConnection:Disconnect()
        autoPunchConnection = nil
    end
    
    if positionLockConnection then
        positionLockConnection:Disconnect()
        positionLockConnection = nil
    end
    
    if getgenv() and getgenv().FlyLoop then
        getgenv().FlyLoop:Disconnect()
        getgenv().FlyLoop = nil
    end
    
    if getgenv() and getgenv().noclipConnection then
        getgenv().noclipConnection:Disconnect()
        getgenv().noclipConnection = nil
    end
    
    local character = game.Players.LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
            character.Humanoid.PlatformStand = false
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    WindUI:Notify({
        Title = "功能重置",
        Content = "玩家死亡，所有功能已重置",
        Duration = 3,
    })
end

local function setupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            resetAllFeatures()
        end)
    end)
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            resetAllFeatures()
        end)
    end
end

function createUI()
    local Window = WindUI:CreateWindow({
        Title = 'Yttrium Hub',
        Icon = "crown",
        IconThemed = true,
        Author = "力量传奇",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(375, 278),
        Transparent = true,
        Theme = "Dark",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        Background = "https://raw.githubusercontent.com/122525a/OHIO/main/Image_1771401973057_62.jpg",
        BackgroundImageTransparency = 0.45,
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么", 
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
        Search = {
            Enabled = true,
            Placeholder = "搜索...",
            Callback = function(searchText)
                print("搜索内容:", searchText)
            end
        },
        SidePanel = {
            Enabled = true,
            Content = {
                {
                    Type = "Button", 
                    Text = "",
                    Style = "Subtle", 
                    Size = UDim2.new(1, -20, 0, 30),
                    Callback = function()
                    end
                }
            }
        }
    })

    Window:EditOpenButton({
        Title = "力量传奇",
        Icon = "crown",
        CornerRadius = UDim.new(0,16),
        StrokeThickness = 4,
        Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
        Draggable = true,
    })
    Window:Tag({
        Title = "Yttrium Hub",
        Color = Color3.fromHex("#FFA500") 
    })
    
    spawn(function()
        while true do
            for hue = 0, 1, 0.01 do  
                local color = Color3.fromHSV(hue, 0.8, 1)  
                Window:EditOpenButton({
                    Color = ColorSequence.new(color)
                })
                wait(0.04)  
            end
        end
    end)
    
    if not borderInitialized then
        spawn(function()
            wait(0.5)
            initializeRainbowBorder("糖果颜色", animationSpeed)
            wait(1)
            applyFontStyleToWindow(currentFontStyle)
        end)
    end

    local windowOpen = true

    Window:OnClose(function()
        windowOpen = false
        if rainbowBorderAnimation then
            rainbowBorderAnimation:Disconnect()
            rainbowBorderAnimation = nil
        end
    end)

    local originalOpenFunction = Window.Open
    Window.Open = function(...)
        windowOpen = true
        local result = originalOpenFunction(...)
        
        if borderInitialized and borderEnabled and not rainbowBorderAnimation then
            wait(0.1)
            startBorderAnimation(Window, animationSpeed)
        end
        
        return result
    end

    setupAntiAFK()
    setupDeathListener()

    local infoTab = Window:Tab({Title = "通知", Icon = "layout-grid", Locked = false})

    local infoSection = infoTab:Section({Title = "详情信息",Icon = "info", Opened = true})

    infoSection:Divider()

    infoSection:Paragraph({
        Title = "您当前的服务器为",
        Desc = "力量传奇\n欢迎使用Yttrium Hub",
        ThumbnailSize = 190,
    })
    infoSection:Paragraph({
        Title = "Yttrium Hub",
        ThumbnailSize = 190,
    })

    local Settings = Window:Tab({Title = "UI设置", Icon = "palette"})
    Settings:Paragraph({
        Title = "UI设置",
        Desc = "绝妙二改WindUI",
        Image = "settings",
        ImageSize = 20,
        Color = "White"
    })

    Settings:Toggle({
        Title = "启用边框",
        Value = borderEnabled,
        Callback = function(value)
            borderEnabled = value
            local mainFrame = Window.UIElements and Window.UIElements.Main
            if mainFrame then
                local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
                if rainbowStroke then
                    rainbowStroke.Enabled = value
                    if value and windowOpen and not rainbowBorderAnimation then
                        startBorderAnimation(Window, animationSpeed)
                    elseif not value and rainbowBorderAnimation then
                        rainbowBorderAnimation:Disconnect()
                        rainbowBorderAnimation = nil
                    end
                    
                    WindUI:Notify({
                        Title = "边框",
                        Content = value and "已启用" or "已禁用",
                        Duration = 2,
                        Icon = value and "eye" or "eye-off"
                    })
                end
            end
        end
    })

    Settings:Toggle({
        Title = "启用字体颜色",
        Value = fontColorEnabled,
        Callback = function(value)
            fontColorEnabled = value
            applyFontColorsToWindow(currentFontColorScheme)
            
            WindUI:Notify({
                Title = "字体颜色",
                Content = value and "已启用" or "已禁用",
                Duration = 2,
                Icon = value and "type" or "type"
            })
        end
    })

    Settings:Toggle({
        Title = "启用音效",
        Value = soundEnabled,
        Callback = function(value)
            soundEnabled = value
            WindUI:Notify({
                Title = "音效",
                Content = value and "已启用" or "已禁用",
                Duration = 2,
                Icon = value and "volume-2" or "volume-x"
            })
        end
    })

    Settings:Toggle({
        Title = "启用背景模糊",
        Value = blurEnabled,
        Callback = function(value)
            blurEnabled = value
            applyBlurEffect(value)
            WindUI:Notify({
                Title = "背景模糊",
                Content = value and "已启用" or "已禁用",
                Duration = 2,
                Icon = value and "cloud-rain" or "cloud"
            })
        end
    })

    local colorSchemeNames = {}
    for name, _ in pairs(COLOR_SCHEMES) do
        table.insert(colorSchemeNames, name)
    end
    table.sort(colorSchemeNames)

    Settings:Dropdown({
        Title = "边框颜色方案",
        Desc = "选择喜欢的颜色组合",
        Values = colorSchemeNames,
        Value = "糖果颜色",
        Callback = function(value)
            currentBorderColorScheme = value
            local success = initializeRainbowBorder(value, animationSpeed)
            playSound()
        end
    })

    Settings:Dropdown({
        Title = "字体颜色方案",
        Desc = "选择文字颜色组合",
        Values = colorSchemeNames,
        Value = "彩虹颜色",
        Callback = function(value)
            currentFontColorScheme = value
            applyFontColorsToWindow(value)
            playSound()
        end
    })

    local fontOptions = {}
    for _, fontName in ipairs(FONT_STYLES) do
        local description = FONT_DESCRIPTIONS[fontName] or fontName
        table.insert(fontOptions, {text = description, value = fontName})
    end

    table.sort(fontOptions, function(a, b)
        return a.text < b.text
    end)

    local fontValues = {}
    local fontValueToName = {}
    for _, option in ipairs(fontOptions) do
        table.insert(fontValues, option.text)
        fontValueToName[option.text] = option.value
    end

    Settings:Dropdown({
        Title = "字体样式",
        Desc = "选择文字字体样式 (" .. #FONT_STYLES .. " 种可用)",
        Values = fontValues,
        Value = "标准粗体",
        Callback = function(value)
            local fontName = fontValueToName[value]
            if fontName then
                currentFontStyle = fontName
                local successCount, totalCount = applyFontStyleToWindow(fontName)
                playSound()
            end
        end
    })

    Settings:Slider({
        Title = "边框转动速度",
        Desc = "调整边框旋转的快慢",
        Value = { 
            Min = 1,
            Max = 10,
            Default = 5,
        },
        Callback = function(value)
            animationSpeed = value
            if rainbowBorderAnimation then
                rainbowBorderAnimation:Disconnect()
                rainbowBorderAnimation = nil
            end
            if borderEnabled then
                startBorderAnimation(Window, animationSpeed)
            end
            
            applyFontColorsToWindow(currentFontColorScheme)
            playSound()
        end
    })

    Settings:Slider({
        Title = "UI整体缩放",
        Desc = "调整UI大小比例",
        Value = { 
            Min = 0.5,
            Max = 1.5,
            Default = 1,
        },
        Step = 0.1,
        Callback = function(value)
            uiScale = value
            applyUIScale(value)
            playSound()
        end
    })

    Settings:Divider()

    Settings:Slider({
        Title = "UI透明度",
        Desc = "调整整个UI的透明度",
        Value = { 
            Min = 0,
            Max = 1,
            Default = 0.2,
        },
        Step = 0.1,
        Callback = function(value)
            Window:ToggleTransparency(tonumber(value) > 0)
            WindUI.TransparencyValue = tonumber(value)
            playSound()
        end
    })

    Settings:Slider({
        Title = "调整UI宽度",
        Desc = "调整窗口的宽度",
        Value = { 
            Min = 500,
            Max = 800,
            Default = 600,
        },
        Callback = function(value)
            if Window.UIElements and Window.UIElements.Main then
                Window.UIElements.Main.Size = UDim2.fromOffset(value, 400)
            end
            playSound()
        end
    })

    Settings:Slider({
        Title = "调整UI高度",
        Desc = "调整窗口的高度",
        Value = { 
            Min = 300,
            Max = 600,
            Default = 400,
        },
        Callback = function(value)
            if Window.UIElements and Window.UIElements.Main then
                local currentWidth = Window.UIElements.Main.Size.X.Offset
                Window.UIElements.Main.Size = UDim2.fromOffset(currentWidth, value)
            end
            playSound()
        end
    })

    Settings:Slider({
        Title = "边框粗细",
        Desc = "调整边框的粗细",
        Value = { 
            Min = 1,
            Max = 5,
            Default = 1.5,
        },
        Step = 0.5,
        Callback = function(value)
            local mainFrame = Window.UIElements and Window.UIElements.Main
            if mainFrame then
                local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
                if rainbowStroke then
                    rainbowStroke.Thickness = value
                end
            end
            playSound()
        end
    })

    Settings:Slider({
        Title = "圆角大小",
        Desc = "调整UI圆角的大小",
        Value = { 
            Min = 0,
            Max = 20,
            Default = 16,
        },
        Callback = function(value)
            local mainFrame = Window.UIElements and Window.UIElements.Main
            if mainFrame then
                local corner = mainFrame:FindFirstChildOfClass("UICorner")
                if not corner then
                    corner = Instance.new("UICorner")
                    corner.Parent = mainFrame
                end
                corner.CornerRadius = UDim.new(0, value)
            end
            playSound()
        end
    })

    Settings:Button({
        Title = "恢复UI到原位",
        Icon = "rotate-ccw",
        Callback = function()
            if Window.UIElements and Window.UIElements.Main then
                Window.UIElements.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
                playSound()
            end
        end
    })

    Settings:Button({
        Title = "重置UI大小",
        Icon = "maximize-2",
        Callback = function()
            if Window.UIElements and Window.UIElements.Main then
                Window.UIElements.Main.Size = UDim2.fromOffset(600, 400)
                playSound()
            end
        end
    })

    Settings:Button({
        Title = "随机字体",
        Icon = "shuffle",
        Callback = function()
            local randomFont = FONT_STYLES[math.random(1, #FONT_STYLES)]
            currentFontStyle = randomFont
            applyFontStyleToWindow(randomFont)
            playSound()
        end
    })

    Settings:Button({
        Title = "随机颜色",
        Icon = "palette",
        Callback = function()
            local randomColor = colorSchemeNames[math.random(1, #colorSchemeNames)]
            currentBorderColorScheme = randomColor
            initializeRainbowBorder(randomColor, animationSpeed)
            playSound()
        end
    })

    Settings:Divider()

    Settings:Button({
        Title = "刷新字体颜色",
        Icon = "refresh-cw",
        Callback = function()
            applyFontColorsToWindow(currentFontColorScheme)
            playSound()
        end
    })

    Settings:Button({
        Title = "刷新字体样式",
        Icon = "refresh-cw",
        Callback = function()
            local successCount, totalCount = applyFontStyleToWindow(currentFontStyle)
            playSound()
        end
    })

    Settings:Button({
        Title = "测试所有字体",
        Icon = "check-circle",
        Callback = function()
            local workingFonts = {}
            local totalFonts = #FONT_STYLES
            
            for i, fontName in ipairs(FONT_STYLES) do
                local success = pcall(function()
                    local test = Enum.Font[fontName]
                end)
                
                if success then
                    table.insert(workingFonts, fontName)
                end
            end
            playSound()
        end
    })

    Settings:Button({
        Title = "导出设置",
        Icon = "download",
        Callback = function()
            local settings = {
                font = currentFontStyle,
                borderColor = currentBorderColorScheme,
                fontSize = currentFontColorScheme,
                speed = animationSpeed,
                scale = uiScale
            }
            setclipboard("Yttrium Hub设置: " .. game:GetService("HttpService"):JSONEncode(settings))
            playSound()
        end
    })

    local MainTab = Window:Tab({Title = "杀戮类", Icon = "target"})
    local PlayerTab = Window:Tab({Title = "修改类", Icon = "edit"})
    local AutoTab = Window:Tab({Title = "自动类", Icon = "zap"})
    local NoAutoTab = Window:Tab({Title = "自动锻炼类", Icon = "dumbbell"})
    local LOLTab = Window:Tab({Title = "通用类", Icon = "settings"})
    local InfoTab = Window:Tab({Title = "信息类", Icon = "info"})

    local MainSection = MainTab:Section({Title = "杀戮功能", Icon = "target", Opened = true})
    local PlayerSection = PlayerTab:Section({Title = "修改功能", Icon = "edit", Opened = true})
    local AutoSection = AutoTab:Section({Title = "自动功能", Icon = "zap", Opened = true})
    local NoAutoSection = NoAutoTab:Section({Title = "自动锻炼功能", Icon = "dumbbell", Opened = true})
    local LOLSection = LOLTab:Section({Title = "通用功能", Icon = "settings", Opened = true})
    local InfoSection = InfoTab:Section({Title = "信息", Icon = "info", Opened = true})

    MainSection:Toggle({
        Title = "自动击杀",
        Value = false,
        Callback = function(value)
            _G.airStrike = value
            
            if value then
                if autoKillConnection then
                    autoKillConnection:Disconnect()
                end
                autoKillConnection = RunService.Heartbeat:Connect(function()
                    if _G.airStrike then
                        autoKill()
                    end
                end)
            else
                if autoKillConnection then
                    autoKillConnection:Disconnect()
                    autoKillConnection = nil
                end
            end
        end
    })

    MainSection:Toggle({
        Title = "自动挥拳",
        Value = false,
        Callback = function(value)
            if value then
                if autoPunchConnection then
                    autoPunchConnection:Disconnect()
                end
                autoPunchConnection = RunService.Heartbeat:Connect(function()
                    autoPunch()
                end)
            else
                if autoPunchConnection then
                    autoPunchConnection:Disconnect()
                    autoPunchConnection = nil
                end
            end
        end
    })

    MainSection:Toggle({
        Title = "锁定坐标(位置)",
        Value = false,
        Callback = function(value)
            _G.positionLock = value
            
            if value then
                startPositionLock()
            else
                if positionLockConnection then
                    positionLockConnection:Disconnect()
                    positionLockConnection = nil
                end
            end
        end
    })

    MainSection:Toggle({
        Title = "自动换服",
        Value = false,
        Callback = function(value)
            _G.switchServers = value
            
            if value then
                LocalPlayer.CharacterAdded:Connect(function(character)
                    local humanoid = character:WaitForChild("Humanoid")
                    humanoid.Died:Connect(function()
                        if _G.switchServers then
                            WindUI:Notify({
                                Title = "自动换服",
                                Content = "玩家死亡，正在执行换服...",
                                Duration = 3,
                            })
                            serverHop()
                        end
                    end)
                end)
                
                RunService.Heartbeat:Connect(function()
                    if _G.switchServers then
                        if tick() - startTime >= 180 then
                            WindUI:Notify({
                                Title = "自动换服",
                                Content = "180秒时间到，正在执行换服...",
                                Duration = 3,
                            })
                            serverHop()
                        end
                    end
                end)
            end
        end
    })

    PlayerSection:Input({
        Title = "修改力量",
        Placeholder = "请输入数值",
        Callback = function(value)
            game:GetService("Players").LocalPlayer.leaderstats.Strength.Value = value
        end
    })

    PlayerSection:Input({
        Title = "修改重生数",
        Placeholder = "请输入数值",
        Callback = function(value)
            game:GetService("Players").LocalPlayer.leaderstats.Rebirths.Value = value
        end
    })

    PlayerSection:Input({
        Title = "修改击杀数",
        Placeholder = "请输入数值",
        Callback = function(value)
            game:GetService("Players").LocalPlayer.leaderstats.Kills.Value = value
        end
    })

    PlayerSection:Input({
        Title = "修改获胜数",
        Placeholder = "请输入数值",
        Callback = function(value)
            game:GetService("Players").LocalPlayer.leaderstats.Brawls.Value = value
        end
    })

    AutoSection:Toggle({
        Title = "自动重生",
        Value = false,
        Callback = function(value)
            if value then
                spawn(function()
                    while value do
                        game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        wait()
                    end
                end)
            end
        end
    })

    AutoSection:Button({
        Title = "调整体积为2",
        Callback = function()
            game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize",2)
        end
    })

    AutoSection:Toggle({
        Title = "自动传送肌肉大王",
        Value = false,
        Callback = function(value)
            if value then
                spawn(function()
                    while value do
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8625.9296875, 13.566278457641602, -5730.4736328125)
                        wait()
                    end
                end)
            end
        end
    })

    AutoSection:Paragraph({
        Title = "以下为自动锻炼功能",
        Content = "不可以边锻炼边走 但是别人不会对LocalPlayer(本地玩家)造成伤害"
    })

    AutoSection:Toggle({
        Title = "自动执行所有锻炼",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoTrainTriple = value
            end
            local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local part = Instance.new('Part', workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            
            spawn(function()
                while value do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if not char then wait(1) continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
                    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if v.ClassName == "Tool" and (v.Name == "Handstands" or v.Name == "Situps" or v.Name == "Pushups" or v.Name == "Weight") then
                            if v:FindFirstChildOfClass("NumberValue") then
                                v:FindFirstChildOfClass("NumberValue").Value = 0
                            end
                            repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            char:WaitForChild("Humanoid"):EquipTool(v)
                            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                        end
                    end
                end
                part:Destroy()
                local char = game.Players.LocalPlayer.Character
                if char then
                    char.HumanoidRootPart.CFrame = oldPos
                    char:WaitForChild("Humanoid"):UnequipTools()
                end
            end)
        end
    })

    AutoSection:Toggle({
        Title = "自动举哑铃",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoWeight = value
            end
            local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local part = Instance.new('Part', workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            
            spawn(function()
                while value do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if not char then wait(1) continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if v.ClassName == "Tool" and v.Name == "Weight" then
                            v.Parent = char
                        end
                    end
                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                end
                part:Destroy()
                local char = game.Players.LocalPlayer.Character
                if char then
                    char.HumanoidRootPart.CFrame = oldPos
                    char:WaitForChild("Humanoid"):UnequipTools()
                end
            end)
        end
    })

    AutoSection:Toggle({
        Title = "自动俯卧撑",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoPushup = value
            end
            local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local part = Instance.new('Part', workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            
            spawn(function()
                while value do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if not char then wait(1) continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if v.ClassName == "Tool" and v.Name == "Pushups" then
                            v.Parent = char
                        end
                    end
                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                end
                part:Destroy()
                local char = game.Players.LocalPlayer.Character
                if char then
                    char.HumanoidRootPart.CFrame = oldPos
                    char:WaitForChild("Humanoid"):UnequipTools()
                end
            end)
        end
    })

    AutoSection:Toggle({
        Title = "自动仰卧起坐",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoSitup = value
            end
            local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local part = Instance.new('Part', workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            
            spawn(function()
                while value do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if not char then wait(1) continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if v.ClassName == "Tool" and v.Name == "Situps" then
                            v.Parent = char
                        end
                    end
                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                end
                part:Destroy()
                local char = game.Players.LocalPlayer.Character
                if char then
                    char.HumanoidRootPart.CFrame = oldPos
                    char:WaitForChild("Humanoid"):UnequipTools()
                end
            end)
        end
    })

    AutoSection:Toggle({
        Title = "自动倒立",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoHandstand = value
            end
            local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local part = Instance.new('Part', workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            
            spawn(function()
                while value do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if not char then wait(1) continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0)
                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                        if v.ClassName == "Tool" and v.Name == "Handstands" then
                            v.Parent = char
                        end
                    end
                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                end
                part:Destroy()
                local char = game.Players.LocalPlayer.Character
                if char then
                    char.HumanoidRootPart.CFrame = oldPos
                    char:WaitForChild("Humanoid"):UnequipTools()
                end
            end)
        end
    })

    NoAutoSection:Paragraph({
        Title = "以下为自动锻炼功能",
        Content = "可以边锻炼边走 但是别人会对LocalPlayer(本地玩家)造成伤害"
    })

    NoAutoSection:Toggle({
        Title = "自动举哑铃",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoWeight = value
            end
            spawn(function()
                while value do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then 
                            wait(2)
                        else
                            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                if v.ClassName == "Tool" and v.Name == "Weight" then
                                    v.Parent = char
                                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                                    wait(0.03)
                                    v.Parent = game.Players.LocalPlayer.Backpack
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait()
                end
                if not value then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and v.Name == "Weight" then
                            v.Parent = game.Players.LocalPlayer.Backpack
                        end
                    end
                end
            end)
        end
    })

    NoAutoSection:Toggle({
        Title = "自动俯卧撑",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoPushups = value
            end
            spawn(function()
                while value do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then 
                            wait(2)
                        else
                            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                if v.ClassName == "Tool" and v.Name == "Pushups" then
                                    v.Parent = char
                                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                                    wait(0.03)
                                    v.Parent = game.Players.LocalPlayer.Backpack
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait()
                end
                if not value then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and v.Name == "Pushups" then
                            v.Parent = game.Players.LocalPlayer.Backpack
                        end
                    end
                end
            end)
        end
    })

    NoAutoSection:Toggle({
        Title = "自动仰卧起坐",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoSitups = value
            end
            spawn(function()
                while value do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then 
                            wait(2)
                        else
                            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                if v.ClassName == "Tool" and v.Name == "Situps" then
                                    v.Parent = char
                                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                                    wait(0.03)
                                    v.Parent = game.Players.LocalPlayer.Backpack
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait()
                end
                if not value then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and v.Name == "Situps" then
                            v.Parent = game.Players.LocalPlayer.Backpack
                        end
                    end
                end
            end)
        end
    })

    NoAutoSection:Toggle({
        Title = "自动倒立",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoHandstands = value
            end
            spawn(function()
                while value do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then 
                            wait(2)
                        else
                            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                if v.ClassName == "Tool" and v.Name == "Handstands" then
                                    v.Parent = char
                                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                                    wait(0.03)
                                    v.Parent = game.Players.LocalPlayer.Backpack
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait()
                end
                if not value then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and v.Name == "Handstands" then
                            v.Parent = game.Players.LocalPlayer.Backpack
                        end
                    end
                end
            end)
        end
    })

    NoAutoSection:Toggle({
        Title = "自动锻炼全部",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().AutoAllTrain = value
            end
            spawn(function()
                while value do
                    pcall(function()
                        local char = game.Players.LocalPlayer.Character
                        if not char then 
                            wait(2)
                        else
                            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                if v.ClassName == "Tool" and (v.Name == "Weight" or v.Name == "Handstands" or v.Name == "Pushups" or v.Name == "Situps") then
                                    v.Parent = char
                                    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                                    wait(0.02)
                                    v.Parent = game.Players.LocalPlayer.Backpack
                                    wait(0.2)
                                end
                            end
                        end
                    end)
                    wait()
                end
                if not value then
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v:IsA("Tool") and (v.Name == "Weight" or v.Name == "Handstands" or v.Name == "Pushups" or v.Name == "Situps") then
                            v.Parent = game.Players.LocalPlayer.Backpack
                        end
                    end
                end
            end)
        end
    })

    local flySpeed = 150
    local flyMultiplier = 5

    LOLSection:Slider({
        Title = "飞行速度",
        Desc = "调整飞行速度",
        Value = { 
            Min = 1,
            Max = 20,
            Default = 5,
        },
        Increment = 0.1,
        Callback = function(value)
            flyMultiplier = value
        end
    })

    LOLSection:Toggle({
        Title = "飞行开关",
        Value = false,
        Callback = function(value)
            if getgenv() then
                getgenv().fly = value
            end
            if value then
                local controlModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'):WaitForChild("ControlModule"))
                local character = game.Players.LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local function setupFlight(character)
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
                    if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
                    
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "VelocityHandler"
                    bv.Parent = hrp
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    
                    local bg = Instance.new("BodyGyro")
                    bg.Name = "GyroHandler"
                    bg.Parent = hrp
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    bg.P = 1000
                    bg.D = 50
                    
                    return bv, bg
                end
                
                local bv, bg = setupFlight(character)
                
                local camera = game.Workspace.CurrentCamera
                if getgenv() then
                    getgenv().FlyLoop = game:GetService("RunService").RenderStepped:Connect(function()
                        local currentCharacter = game.Players.LocalPlayer.Character
                        local hrp = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
                        if currentCharacter and hrp and hrp:FindFirstChild("VelocityHandler") and hrp:FindFirstChild("GyroHandler") and getgenv().fly then
                            currentCharacter.Humanoid.PlatformStand = true
                            hrp.GyroHandler.CFrame = camera.CFrame
                            
                            local direction = controlModule:GetMoveVector()
                            local actualSpeed = flySpeed * flyMultiplier
                            
                            hrp.VelocityHandler.Velocity = Vector3.new()
                            if direction.X ~= 0 then
                                hrp.VelocityHandler.Velocity = hrp.VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * actualSpeed)
                            end
                            if direction.Z ~= 0 then
                                hrp.VelocityHandler.Velocity = hrp.VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * actualSpeed)
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                                hrp.VelocityHandler.Velocity = hrp.VelocityHandler.Velocity + Vector3.new(0, actualSpeed/2, 0)
                            end
                            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                                hrp.VelocityHandler.Velocity = hrp.VelocityHandler.Velocity - Vector3.new(0, actualSpeed/2, 0)
                            end
                        end
                    end)
                end
            else
                if getgenv() and getgenv().FlyLoop then
                    getgenv().FlyLoop:Disconnect()
                end
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
                    if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
                    character.Humanoid.PlatformStand = false
                end
            end
        end
    })

    LOLSection:Toggle({
        Title = "穿墙",
        Value = false,
        Callback = function(value)
            if value then
                if getgenv() then
                    getgenv().noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                        local LocalPlayer = game:GetService("Players").LocalPlayer
                        if LocalPlayer.Character then
                            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            else
                if getgenv() and getgenv().noclipConnection then
                    getgenv().noclipConnection:Disconnect()
                    getgenv().noclipConnection = nil
                end
                
                local LocalPlayer = game:GetService("Players").LocalPlayer
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })

    InfoSection:Paragraph({
        Title = "Yttrium Hub",
        Content = "付费脚本"
    })


    InfoSection:Button({
        Title = "手动重置所有功能",
        Callback = function()
            resetAllFeatures()
            WindUI:Notify({
                Title = "手动重置",
                Content = "所有功能已手动重置",
                Duration = 3,
            })
        end
    })


    Window:OnClose(function()
        windowOpen = false
        if rainbowBorderAnimation then
            rainbowBorderAnimation:Disconnect()
            rainbowBorderAnimation = nil
        end
        applyBlurEffect(false)
    end)

    Window:OnDestroy(function()
        windowOpen = false
        if rainbowBorderAnimation then
            rainbowBorderAnimation:Disconnect()
            rainbowBorderAnimation = nil
        end
        for _, animation in pairs(fontColorAnimations) do
            animation:Disconnect()
        end
        fontColorAnimations = {}
        applyBlurEffect(false)
    end)
end