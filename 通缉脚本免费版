local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
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
            blur.Name = "UIYttrium hubBlur"
            blur.Parent = game:GetService("Lighting")
        end)
    else
        pcall(function()
            local existingBlur = game:GetService("Lighting"):FindFirstChild("UIYttrium hubBlur")
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
local gradientColors = {
    "rgb(255, 230, 235)",
    "rgb(255, 210, 220)",
    "rgb(255, 190, 205)",
    "rgb(255, 170, 190)",
    "rgb(255, 150, 175)",
    "rgb(245, 140, 180)",
    "rgb(235, 130, 185)",
    "rgb(225, 120, 190)",
    "rgb(215, 110, 195)",
    "rgb(205, 100, 200)"
}
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
    Title = 'Yttrium hub ',
    IconThemed = true,
    Icon = "crown",
    Content = "欢迎尊重的用户 " .. coloredUsername .. " \n使用Yttrium hub\n你的支持是我们更新的动力\n付费版",
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
function createUI()
    local Window = WindUI:CreateWindow({
        Title = 'Yttrium hub',
        Icon = "crown",
        IconThemed = true,
        Author = "v1.0 by Yttrium hub",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(300, 200),
        Transparent = true,
        Theme = "Dark",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        Background = "https://raw.githubusercontent.com/lyynb666nb/lyynb/refs/heads/main/20260206_234243530.webp",
        BackgroundImageTransparency = 0.5,
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
    Title = "Yttrium hub",
    Icon = "crown",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 4,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})
Window:Tag({
    Title = "正在寻求",
    Color = Color3.fromHex("#00008B") 
})
Window:Tag({
    Title = "3.0.1",
    Color = Color3.fromHex("#32CD32")
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
        initializeRainbowBorder("彩虹颜色", animationSpeed)
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


local infoTab = Window:Tab({Title = "通知", Icon = "layout-grid", Locked = false})

local infoSection = infoTab:Section({Title = "详情信息",Icon = "info", Opened = true})

infoSection:Divider()

infoSection:Paragraph({
    Title = "您当前的服务器为",
    Desc = "正在寻求\n欢迎使用此脚本",
    ThumbnailSize = 190,
})
infoSection:Paragraph({
    Title = "持续更新，有bug请提出来",
    ThumbnailSize = 190,
})
local infoSection = infoTab:Section({Title = "Yttrium hub",Icon = "info", Opened = true})

infoSection:Paragraph({
    Title = "脚本已稳定发布",
    ThumbnailSize = 190,
})
infoSection:Paragraph({
    Title = "付费",
    ThumbnailSize = 190,
})
infoSection:Paragraph({
    Title = "售后群专属",
    ThumbnailSize = 190,
})
local LockSection = Window:Section({
    Title = "人物",
    Icon = "crown",
    Opened = true,
})
local FlightControl = Window:Tab({Title = "人物功能", Icon = "gift"})
local FlyingEnabled = false
local SpinningEnabled = false
local FlightSpeed = 50
local SpinSpeed = 5
local CurrentAO, CurrentLV, CurrentMoverAttachment
local FlightConnection
local Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local LastControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local function getControlModule()
local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
return require(PlayerModule:WaitForChild("ControlModule"))
end
local function setupBodyMovers(character)
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local moverParent = workspace:FindFirstChildOfClass("Terrain") or workspace
local moverAttachment = Instance.new("Attachment", hrp)
moverAttachment.Name = "FlightAttachment"
local alignOrientation = Instance.new('AlignOrientation')
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.RigidityEnabled = true
alignOrientation.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
alignOrientation.CFrame = hrp.CFrame
alignOrientation.Attachment0 = moverAttachment
alignOrientation.Parent = moverParent
local linearVelocity = Instance.new('LinearVelocity')
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
linearVelocity.MaxForce = 9e9
linearVelocity.Attachment0 = moverAttachment
linearVelocity.Parent = moverParent
return alignOrientation, linearVelocity, humanoid, moverAttachment
end
local function getFlightVector(controlModule)
local moveVector = controlModule:GetMoveVector()
local camera = workspace.CurrentCamera
Control.F = -moveVector.Z
Control.B = moveVector.Z
Control.L = -moveVector.X
Control.R = moveVector.X
Control.Q = moveVector.Y
Control.E = -moveVector.Y
local UserInputService = game:GetService("UserInputService")
if UserInputService:IsKeyDown(Enum.KeyCode.W) then Control.F = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then Control.B = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then Control.L = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then Control.R = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Control.Q = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Control.E = 1 end
local flightVector = (camera.CFrame.LookVector * (Control.F - Control.B) +
camera.CFrame.RightVector * (Control.R - Control.L) +
Vector3.new(0, 1, 0) * (Control.Q - Control.E))
return flightVector.Magnitude > 0 and flightVector.Unit or flightVector
end
local function startFlying()
if FlyingEnabled then return end
local LocalPlayer = game:GetService("Players").LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
if not character then
WindUI:Notify({
Title = "飞行失败",
Content = "无法获取角色",
Duration = 2,
Icon = "x"
})
return
end
FlyingEnabled = true
SpinningEnabled = false
if CurrentAO then CurrentAO:Destroy() end
if CurrentLV then CurrentLV:Destroy() end
if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
CurrentAO, CurrentLV, humanoid, CurrentMoverAttachment = setupBodyMovers(character)
WindUI:Notify({
Title = "飞行开启",
Content = "速度: " .. FlightSpeed,
Duration = 2,
Icon = "check"
})
local controlModule = getControlModule()
FlightConnection = game:GetService("RunService").Heartbeat:Connect(function()
if not FlyingEnabled or not CurrentLV or not CurrentAO then
if FlightConnection then
FlightConnection:Disconnect()
FlightConnection = nil
end
return
end
local flightVector = getFlightVector(controlModule)
if flightVector.Magnitude > 0 then
CurrentLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
CurrentLV.VectorVelocity = flightVector * FlightSpeed
else
CurrentLV.VectorVelocity = Vector3.new(0, 0, 0)
end
if SpinningEnabled then
local targetPart = character.Humanoid.SeatPart or character.HumanoidRootPart
local spinCFrame = targetPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
CurrentAO.CFrame = spinCFrame
else
CurrentAO.CFrame = workspace.CurrentCamera.CFrame
end
if character.HumanoidRootPart then
character.Humanoid.PlatformStand = true
end
end)
character.AncestryChanged:Connect(function(_, parent)
if not parent and FlyingEnabled then
stopFlying()
end
end)
end
local function stopFlying()
if not FlyingEnabled then return end
FlyingEnabled = false
SpinningEnabled = false
Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
LastControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
if FlightConnection then
FlightConnection:Disconnect()
FlightConnection = nil
end
local LocalPlayer = game:GetService("Players").LocalPlayer
local character = LocalPlayer.Character
if character and character:FindFirstChild("Humanoid") then
character.Humanoid.PlatformStand = false
end
if CurrentAO then
CurrentAO:Destroy()
CurrentAO = nil
end
if CurrentLV then
CurrentLV:Destroy()
CurrentLV = nil
end
if CurrentMoverAttachment then
CurrentMoverAttachment:Destroy()
CurrentMoverAttachment = nil
end
WindUI:Notify({
Title = "飞行关闭",
Content = "飞行功能已禁用",
Duration = 2,
Icon = "x"
})
end
local function toggleSpinning()
if not FlyingEnabled then
WindUI:Notify({
Title = "提示",
Content = "请先开启飞行功能",
Duration = 2,
Icon = "info"
})
return
end
SpinningEnabled = not SpinningEnabled
if SpinningEnabled then
WindUI:Notify({
Title = "旋转开启",
Content = "旋转速度: " .. SpinSpeed,
Duration = 2,
Icon = "refresh-cw"
})
else
WindUI:Notify({
Title = "旋转关闭",
Content = "旋转功能已禁用",
Duration = 2,
Icon = "x"
})
end
end
FlightControl:Toggle({
Title = "飞行模式",
Default = FlyingEnabled,
Callback = function(v)
if v then
startFlying()
else
stopFlying()
end
end
})
FlightControl:Toggle({
Title = "旋转模式",
Default = SpinningEnabled,
Callback = function(v)
if v then
SpinningEnabled = true
else
SpinningEnabled = false
end
end
})
FlightControl:Slider({
Title = "飞行速度",
Value = {
Min = 1,
Max = 200,
Default = 50
},
Callback = function(value)
FlightSpeed = value
if FlyingEnabled then
WindUI:Notify({
Title = "速度已更新",
Content = "飞行速度: " .. value,
Duration = 1,
Icon = "zap"
})
end
end
})
FlightControl:Slider({
Title = "旋转速度",
Value = {
Min = 1,
Max = 50,
Default = 5
},
Callback = function(value)
SpinSpeed = value
if SpinningEnabled then
WindUI:Notify({
Title = "旋转速度已更新",
Content = "旋转速度: " .. value,
Duration = 1,
Icon = "refresh-cw"
})
end
end
})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
LocalPlayer.CharacterAdded:Connect(function()
if FlyingEnabled then
task.wait(0.5)
stopFlying()
task.wait(0.1)
startFlying()
end
end)
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
if child.Name == "CloudHub" and FlyingEnabled then
stopFlying()
end
end)
FlightControl:Divider()
local SpeedHack = false
local SpeedValue = 16
FlightControl:Toggle({
Title = "速度增加",
Default = SpeedHack,
Callback = function(v)
SpeedHack = v
if v then
task.spawn(function()
local sudu = game:GetService("RunService").Heartbeat:Connect(function()
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
local hum = game.Players.LocalPlayer.Character.Humanoid
if hum.MoveDirection.Magnitude > 0 then
game.Players.LocalPlayer.Character:TranslateBy(hum.MoveDirection * SpeedValue / 10)
end
end
end)
while SpeedHack do
task.wait()
end
sudu:Disconnect()
end)
else
print("速度：关闭")
end
end
})
FlightControl:Slider({
Title = "速度设置",
Value = {
Min = 1,
Max = 150,
Default = 16
},
Callback = function(v)
SpeedValue = v
end
})
FlightControl:Toggle({
    Title = "扩大视野",
    Default = false,
    Callback = function(v)
        if v == true then
            fovConnection = game:GetService("RunService").Heartbeat:Connect(function()
                workspace.CurrentCamera.FieldOfView = 120
            end)
        elseif not v and fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
    end
})
FlightControl:Divider()
FlightControl:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})

local LockSection = Window:Section({
    Title = "主要功能区域",
    Icon = "crown",
    Opened = true,
})

local Main = Window:Tab({Title = "战斗功能", Icon = "swords"})
    local ForceLoadAll = false
    Main:Toggle({
        Title = "强制加载所有数据",
        Default = ForceLoadAll,
        Callback = function(v)
            ForceLoadAll = v
            if v then
                task.spawn(function()
                    local devv = require(game:GetService("ReplicatedStorage").Devv)
                    local Network = devv.load("Network")
                    local Players = game:GetService("Players")
                    local RunService = game:GetService("RunService")
                    local LocalPlayer = Players.LocalPlayer
                    
                    local function loadArea(position, radius)
                        if RunService:IsClient() then
                            pcall(function()
                                Network.InvokeServer("requestStreamAround", position, radius)
                            end)
                            pcall(function()
                                Network.FireServer("setReplicationFocus", position)
                            end)
                        end
                    end
                    
                    local function loadAllGizmos()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        if White then
                            for _,gizmo in ipairs(White:GetChildren()) do
                                if gizmo.PrimaryPart then
                                    loadArea(gizmo.PrimaryPart.Position, 50)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                    
                    local function loadAllPlayers()
                        for _,player in ipairs(Players:GetPlayers()) do
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                loadArea(player.Character.HumanoidRootPart.Position, 50)
                                task.wait(0.1)
                            end
                        end
                    end
                    
                    while ForceLoadAll do
                        loadAllGizmos()
                        loadAllPlayers()
                        loadArea(Vector3.new(0,0,0), 1000)
                        loadArea(Vector3.new(1000,0,1000), 1000)
                        loadArea(Vector3.new(-1000,0,-1000), 1000)
                        loadArea(Vector3.new(1000,0,-1000), 1000)
                        loadArea(Vector3.new(-1000,0,1000), 1000)
                        task.wait(5)
                    end
                end)
            else
                print("强制加载：关闭")
            end
        end
    })
    
    local AutoShoot = false
    local OriginalShoot = nil
    local ShooterModule = nil
    
    Main:Toggle({
        Title = "愤怒机器人[全枪]",
        Default = AutoShoot,
        Callback = function(v)
            AutoShoot = v
            if v then
                task.spawn(function()
                    ShooterModule = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
                    OriginalShoot = ShooterModule._shoot
                    
                    local trailColors = {
                        primary = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
                            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }
                    }
                    
                    local function createBezierCurve(p0, p1, p2, t)
                        return (1-t)^2 * p0 + 2*(1-t)*t * p1 + t^2 * p2
                    end
                    
                    local function createBeautifulTrail(origin, targetPos)
                        local trailContainer = Instance.new("Folder")
                        trailContainer.Name = "MagicTrail"
                        trailContainer.Parent = Workspace
                        
                        local midPoint = (origin + targetPos) / 2
                        local direction = (targetPos - origin).Unit
                        local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
                        local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)
                        
                        local curvePoints = {}
                        local numSegments = 20
                        
                        for i = 0, numSegments do
                            local t = i / numSegments
                            local point = createBezierCurve(origin, controlPoint, targetPos, t)
                            table.insert(curvePoints, point)
                        end
                        
                        for i = 1, #curvePoints - 1 do
                            local startPoint = curvePoints[i]
                            local endPoint = curvePoints[i + 1]
                            local distance = (endPoint - startPoint).Magnitude
                            
                            local beamPart = Instance.new("Part")
                            beamPart.Size = Vector3.new(0.15, 0.15, distance)
                            beamPart.Anchored = true
                            beamPart.CanCollide = false
                            beamPart.Material = Enum.Material.Neon
                            beamPart.Transparency = 0.3
                            beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance/2)
                            beamPart.Parent = trailContainer
                            
                            local pointLight = Instance.new("PointLight")
                            pointLight.Brightness = 5
                            pointLight.Range = 3
                            pointLight.Color = Color3.fromRGB(0, 170, 255)
                            pointLight.Parent = beamPart
                            
                            local particles = Instance.new("ParticleEmitter")
                            particles.Size = NumberSequence.new(0.1, 0.3)
                            particles.Transparency = NumberSequence.new(0.3, 0.8)
                            particles.Lifetime = NumberRange.new(0.5, 1)
                            particles.Rate = 50
                            particles.Speed = NumberRange.new(1, 2)
                            particles.VelocitySpread = 180
                            particles.Parent = beamPart
                        end
                        
                        task.spawn(function()
                            task.wait(1.5)
                            if trailContainer and trailContainer.Parent then
                                trailContainer:Destroy()
                            end
                        end)
                        
                        return trailContainer
                    end
                    
                    local function hasLineOfSight(shooterPos, targetPos)
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                        raycastParams.IgnoreWater = true
                        
                        local direction = (targetPos - shooterPos).Unit
                        local distance = (targetPos - shooterPos).Magnitude
                        local raycastResult = Workspace:Raycast(shooterPos, direction * distance, raycastParams)
                        
                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            if hitPart then
                                local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
                                if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
                                    return true
                                else
                                    return false
                                end
                            end
                        end
                        return true
                    end
                    
                    ShooterModule._shoot = function(self)
                        if not self or not self.tool then
                            return OriginalShoot(self)
                        end
                        
                        local Players = game:GetService("Players")
                        local LocalPlayer = game.Players.LocalPlayer
                        local LocalCharacter = LocalPlayer.Character
                        
                        if not LocalCharacter then
                            return OriginalShoot(self)
                        end
                        
                        local shooterPos = LocalCharacter.HumanoidRootPart and LocalCharacter.HumanoidRootPart.Position or LocalCharacter.PrimaryPart.Position
                        local nearestPlayer = nil
                        local nearestDistance = math.huge
                        
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPos = player.Character.HumanoidRootPart.Position
                                local distance = (shooterPos - targetPos).Magnitude
                                
                                if hasLineOfSight(shooterPos, targetPos) and distance < nearestDistance then
                                    nearestDistance = distance
                                    nearestPlayer = player
                                end
                            end
                        end
                        
                        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
                            self.aimpoint = targetPos
                            self.aimpoint2 = targetPos
                            
                            if self.tool.model and self.tool.model.PrimaryPart then
                                local muzzlePos = self.tool.model.PrimaryPart.Position
                                createBeautifulTrail(muzzlePos, targetPos)
                            else
                                createBeautifulTrail(shooterPos, targetPos)
                            end
                            
                            if self.tool then
                                self.tool.shooting = true
                                self.tool.fireDebounce = 0
                                self.tool.fireMode = "auto"
                            end
                        else
                            if self.tool then
                                self.tool.shooting = false
                            end
                        end
                        
                        return OriginalShoot(self)
                    end
                    
                    while AutoShoot do
                        if ShooterModule and ShooterModule._shoot then
                            local tool = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                            if tool then
                                local shooter = tool:FindFirstChild("Shooter")
                                if not shooter then
                                    shooter = {tool = tool}
                                end
                                pcall(function()
                                    ShooterModule._shoot(shooter)
                                end)
                            end
                        end
                        task.wait(0.2)
                    end
                    
                    if OriginalShoot then
                        ShooterModule._shoot = OriginalShoot
                    end
                end)
            else
                print("自动射击：关闭")
                if ShooterModule and OriginalShoot then
                    ShooterModule._shoot = OriginalShoot
                end
            end
        end
    })
    
    local AutoSell = false
    
    Main:Toggle({
        Title = "出售物品光环",
        Default = AutoSell,
        Callback = function(v)
            AutoSell = v
            if v then
                task.spawn(function()
                    while AutoSell do
                        for _, a in ipairs(game:GetService("ReplicatedStorage").Shared.Core.Network:GetChildren()) do
                            if a:IsA("RemoteFunction") or a:IsA("RemoteEvent") then
                                if not a.Name:find("moveHouse") and not a.Name:find("House") then
                                    pcall(function()
                                        a:InvokeServer()
                                    end)
                                end
                            end
                            if not AutoSell then
                                break
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("自动出售：关闭")
            end
        end
    })
    
    -- 刷钱功能标签
    local MoneyFarmTab = Window:Tab({Title = "刷钱功能", Icon = "dollar-sign"})
    
    local AutoBankCash = false
    
    MoneyFarmTab:Toggle({
        Title = "自动抢银行",
    
        Default = AutoBankCash,
        Callback = function(v)
            AutoBankCash = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end
                    
                    while AutoBankCash do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        
                        if White and RootPart and White:FindFirstChild("MainBankCash") and AutoBankCash then
                            local Item = White.MainBankCash
                            local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)
                            
                            if Target then
                                RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                task.wait(0.2)
                                
                                while AutoBankCash and White:FindFirstChild("MainBankCash") do
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(0.05)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    task.wait(0.5)
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("银行钱堆：关闭")
            end
        end
    })
    
    local HitATMAura = false
    
    MoneyFarmTab:Toggle({
        Title = "摧毁ATM光环",
     
        Default = HitATMAura,
        Callback = function(Value)
            HitATMAura = Value
            if Value then
                local devv = require(game:GetService("ReplicatedStorage").Devv)
                local Get = devv.GetModule("Network")
                local Players = game:GetService("Players")
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                
                local gizmoColors = {
                    "White", "Green", "Blue", "Purple", "Orange", "Red", "Yellow"
                }
                
                local isAttacking = false
                local cooldown = false
                
                local function attackATM(gizmo)
                    if not gizmo or not gizmo:FindFirstChild("Metal") then
                        return false
                    end
                    local metalPart = gizmo.Metal
                    local guid = gizmo:GetAttribute("objectId")
                    if not guid then
                        return false
                    end
                    
                    Get.FireServer("registerMeleeHits", {{
                        normal = Vector3.new(0, 0, 0),
                        direction = Vector3.new(0, 0, 0),
                        source = "Melee",
                        id = guid,
                        material = Enum.Material.Metal,
                        position = metalPart.Position,
                        gizmoType = "ATM",
                        processedPlayerId = localPlayer.UserId,
                        hit = metalPart,
                        speed = 50,
                        collisionPoint = metalPart.Position,
                        hitName = "Metal",
                        hitType = "gizmo"
                    }})
                    return true
                end
                
                local function isATMAlive(gizmo)
                    if not gizmo or not gizmo.Parent then
                        return false
                    end
                    if not gizmo:FindFirstChild("Metal") then
                        return false
                    end
                    return true
                end
                
                local function findAllATMs()
                    local allATMs = {}
                    for _, color in ipairs(gizmoColors) do
                        local colorFolder = Workspace.Local.Gizmos:FindFirstChild(color)
                        if colorFolder then
                            local atm = colorFolder:FindFirstChild("ATM")
                            if atm then
                                table.insert(allATMs, atm)
                            end
                        end
                    end
                    return allATMs
                end
                
                local function attackLoop()
                    while HitATMAura do
                        if cooldown then
                            task.wait(0.1)
                            continue
                        end
                        
                        local allATMs = findAllATMs()
                        
                        if #allATMs == 0 then
                            task.wait(1)
                            continue
                        end
                        
                        for _, atm in ipairs(allATMs) do
                            if not HitATMAura then break end
                            
                            local attackCount = 0
                            
                            while HitATMAura and isATMAlive(atm) and attackCount < 50 do
                                attackATM(atm)
                                attackCount += 1
                                task.wait(0.05)
                            end
                            
                            if HitATMAura then
                                task.wait(0.5)
                            end
                        end
                        
                        task.wait(0.1)
                    end
                end
                
                local function onCharacterDied()
                    if HitATMAura then
                        cooldown = true
                        task.wait(3)
                        cooldown = false
                    end
                end
                
                local function setupCharacterListeners()
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.Died:Connect(onCharacterDied)
                    end
                    
                    localPlayer.CharacterAdded:Connect(function(newChar)
                        character = newChar
                        humanoid = newChar:WaitForChild("Humanoid")
                        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
                        humanoid.Died:Connect(onCharacterDied)
                    end)
                end
                
                setupCharacterListeners()
                task.spawn(attackLoop)
            end
        end
    })
    
    local AutoATM = false
    
    MoneyFarmTab:Toggle({
        Title = "自动ATM",

        Default = AutoATM,
        Callback = function(Value)
            AutoATM = Value
            if Value then
                local TimeElapsedATM = 0
                local TimeoutThresholdATM = 30
                local RootPart = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                local GizmoFolder = Workspace.Local.Gizmos.White
                
                local ATMPatrolPoints = {
                    Vector3.new(-1137, 78, -1953),
                    Vector3.new(-44, 63, -2083),
                    Vector3.new(194, 60, -2884),
                    Vector3.new(-412, 106, -1301),
                    Vector3.new(-377, 410, -741),
                    Vector3.new(-985, 380, -1145),
                    Vector3.new(-854, 406, -1505)
                }
                
                local function GetBasePart(instance)
                    if instance:IsA("BasePart") then
                        return instance
                    end
                    for _, descendant in ipairs(instance:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            return descendant
                        end
                    end
                end
                
                local function IsValidATMTarget(instance)
                    local typeAttr = instance:GetAttribute("gizmoType")
                    return typeAttr == "ATM"
                end
                
                local function FindClosestATMTarget()
                    local minDistance = math.huge
                    local closestPart = nil
                    for _, item in ipairs(GizmoFolder:GetChildren()) do
                        if IsValidATMTarget(item) then
                            local part = GetBasePart(item)
                            if part then
                                local dist = (RootPart.Position - part.Position).Magnitude
                                if dist < minDistance then
                                    closestPart = part
                                    minDistance = dist
                                end
                            end
                        end
                    end
                    return closestPart
                end
                
                local function TeleportTo(target)
                    if typeof(target) ~= "Instance" then
                        if typeof(target) == "Vector3" then
                            RootPart.CFrame = CFrame.new(target)
                        end
                    else
                        RootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
                    end
                end
                
                local function SpamInteract(duration)
                    local start = tick()
                    while tick() - start < duration do
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                    end
                end
                
                local function ProcessATMCollection(targetPart)
                    local start = tick()
                    local maxWait = 3
                    while tick() - start < maxWait and (targetPart.Parent and not targetPart:GetAttribute("Collected")) do
                        task.wait(0.1)
                    end
                    SpamInteract(1.5)
                end
                
                task.spawn(function()
                    while AutoATM do
                        local target = FindClosestATMTarget()
                        if target then
                            TeleportTo(target)
                            task.wait(0.3)
                            SpamInteract(1.5)
                            ProcessATMCollection(target)
                            TimeElapsedATM = 0
                        else
                            TimeElapsedATM = TimeElapsedATM + 0.7
                            TeleportTo(ATMPatrolPoints[math.random(1, #ATMPatrolPoints)])
                            if TimeoutThresholdATM <= TimeElapsedATM then
                                TimeElapsedATM = 0
                            end
                        end
                        task.wait(0.7)
                    end
                end)
            end
        end
    })
    
    local AutoRegister = false
    
    MoneyFarmTab:Toggle({
        Title = "自动收银机",
        Default = AutoRegister,
        Callback = function(Value)
            AutoRegister = Value
            if Value then
                local TimeElapsedRegister = 0
                local TimeoutThresholdRegister = 30
                local RootPart = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                local GizmoFolder = Workspace.Local.Gizmos.White
                
                local RegisterPatrolPoints = {
                    Vector3.new(-1000, 100, -2000),
                    Vector3.new(-500, 100, -2200),
                    Vector3.new(100, 100, -2500)
                }
                
                local function GetBasePart(instance)
                    if instance:IsA("BasePart") then
                        return instance
                    end
                    for _, descendant in ipairs(instance:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            return descendant
                        end
                    end
                end
                
                local function IsValidRegisterTarget(instance)
                    local typeAttr = instance:GetAttribute("gizmoType")
                    return typeAttr == "Register"
                end
                
                local function FindClosestRegisterTarget()
                    local minDistance = math.huge
                    local closestPart = nil
                    for _, item in ipairs(GizmoFolder:GetChildren()) do
                        if IsValidRegisterTarget(item) then
                            local part = GetBasePart(item)
                            if part then
                                local dist = (RootPart.Position - part.Position).Magnitude
                                if dist < minDistance then
                                    closestPart = part
                                    minDistance = dist
                                end
                            end
                        end
                    end
                    return closestPart
                end
                
                local function TeleportTo(target)
                    if typeof(target) ~= "Instance" then
                        if typeof(target) == "Vector3" then
                            RootPart.CFrame = CFrame.new(target)
                        end
                    else
                        RootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
                    end
                end
                
                local function SpamInteract(duration)
                    local start = tick()
                    while tick() - start < duration do
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                    end
                end
                
                local function ProcessRegisterCollection(targetPart)
                    local start = tick()
                    local maxWait = 2
                    while tick() - start < maxWait and (targetPart.Parent and not targetPart:GetAttribute("Collected")) do
                        task.wait(0.1)
                    end
                    SpamInteract(1.2)
                end
                
                task.spawn(function()
                    while AutoRegister do
                        local target = FindClosestRegisterTarget()
                        if target then
                            TeleportTo(target)
                            task.wait(0.3)
                            SpamInteract(1.2)
                            ProcessRegisterCollection(target)
                            TimeElapsedRegister = 0
                        else
                            TimeElapsedRegister = TimeElapsedRegister + 0.7
                            TeleportTo(RegisterPatrolPoints[math.random(1, #RegisterPatrolPoints)])
                            if TimeoutThresholdRegister <= TimeElapsedRegister then
                                TimeElapsedRegister = 0
                            end
                        end
                        task.wait(0.7)
                    end
                end)
            end
        end
    })
    
    -- 自动拾取标签
    local AutoPickupTab = Window:Tab({Title = "自动拾取", Icon = "box"})
    
    local AutoGold = false
    
    AutoPickupTab:Toggle({
        Title = "自动拾取金条",
        Default = AutoGold,
        Callback = function(v)
            AutoGold = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end
                    
                    while AutoGold do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        
                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "Gold Bar" and AutoGold then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)
                                    
                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        
                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoGold
                                    end
                                end
                                
                                if not AutoGold then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
    
    local AutoWorldItem = false
    
    AutoPickupTab:Toggle({
        Title = "自动拾取全部礼物盒",
        Default = AutoWorldItem,
        Callback = function(v)
            AutoWorldItem = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end
                    
                    while AutoWorldItem do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        
                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "WorldItem" and AutoWorldItem then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)
                                    
                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        
                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoWorldItem
                                    end
                                end
                                
                                if not AutoWorldItem then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("礼物盒：关闭")
            end
        end
    })
    
    local AutoSilverBar = false
    
    AutoPickupTab:Toggle({
        Title = "自动拾取银条",
        Default = AutoSilverBar,
        Callback = function(v)
            AutoSilverBar = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end
                    
                    while AutoSilverBar do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        
                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "Silver Bar" and AutoSilverBar then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)
                                    
                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        
                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoSilverBar
                                    end
                                end
                                
                                if not AutoSilverBar then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("银条：关闭")
            end
        end
    })
    
    local AutoSapphire = false
    
    AutoPickupTab:Toggle({
        Title = "自动拾取蓝宝石",
        Default = AutoSapphire,
        Callback = function(v)
            AutoSapphire = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end
                    
                    while AutoSapphire do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        
                        if White and RootPart and White:FindFirstChild("Sapphire") and AutoSapphire then
                            local Item = White.Sapphire
                            local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)
                            
                            if Target then
                                RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                task.wait(0.2)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                
                                repeat
                                    task.wait(0.1)
                                until not White:FindFirstChild("Sapphire") or not AutoSapphire
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("蓝宝石：关闭")
            end
        end
    })
local Main = Window:Tab({Title = "绕过类", Icon = "wind"})
local ImmuneTurret = false

Main:Toggle({
    Title = "绕过炮塔伤害",
    Default = ImmuneTurret,
    Callback = function(v)
        ImmuneTurret = v
        if v then
            local oldFireServer = game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer
            game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer = function(self, event, ...)
                if event == "registerLocalHit" and ... == "Turret" then
                    return nil
                end
                return oldFireServer(self, event, ...)
            end
        else
            game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer = oldFireServer
        end
    end
})


    local WeaponTab = Window:Tab({Title = "武器修改", Icon = "target"})
    
    WeaponTab:Button({
        Title = "无限子弹",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.ammo = 9999
                self.totalAmmo = 9999
                return originalShoot(self)
            end
        end
    })
    
    WeaponTab:Button({
        Title = "无后坐力",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.recoil = {firstShotKick = 0, climb = 0, spread = 0}
                return originalShoot(self)
            end
        end
    })
    
    WeaponTab:Button({
        Title = "无扩散",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.aim = {spreadAngle = 0, zeroing = 1000}
                return originalShoot(self)
            end
        end
    })
    
    WeaponTab:Button({
        Title = "快速射击",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.tool.fireDebounce = 0
                self.tool.fireMode = "auto"
                return originalShoot(self)
            end
        end
    })
    
    WeaponTab:Button({
        Title = "无装弹",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.ammoData = {reloadTime = 0, magSize = 9999}
                return originalShoot(self)
            end
        end
    })

local Main = Window:Tab({Title = "自瞄", Icon = "crosshair"})

local isAiming = false
local isPredicting = false 
local isLowHealthPriority = false 
local fov = 50 
local plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Cam = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local targetPart = "Head"
local teamCheck = false
local aliveCheck = false
local predictionDistance = 1.5
local wallCheck = false
local smoothness = 0.5
local aimKey = Enum.KeyCode.Q
local aimLock = false
local aimLockSpeed = 0.2
local isAimingHead = false
local aimStyle = "平滑"
local lockTime = 0.5
local lastLockTime = 0
local lockedPlayer = nil
local lockDuration = 3
local lockExpire = 0
local isSilentAim = false
local silentFov = 30
local isRageMode = false
local silentAimChance = 100
local aimbotType = "传统"
local aimbotPriority = "距离"

-- 高级预测变量
local useAdvancedPrediction = false
local predictionType = "线性"
local advancedPredictionFactor = 1.2
local bulletSpeed = 500
local gravityFactor = 9.8
local pingCompensation = 0.1

-- 射击机器人变量
local isAutoShoot = false
local shootDelay = 0.1
local lastShotTime = 0
local shootRange = 500
local autoShootFov = 100
local isBurstFire = false
local burstCount = 3
local burstDelay = 0.1
local isRapidFire = false
local rapidFireRate = 0.05
local isTriggerBot = false
local triggerDelay = 0.2
local triggerHoldTime = 0.1
local targetVisibleTime = 0
local isAutoShootOnAim = false
local isSmartAim = false
local smartAimThreshold = 0.8
local isLagCompensation = false
local lagCompensationTime = 0.1

-- 自动射击模块变量
local ShooterModule = nil
local OriginalShoot = nil
local autoShootConnection = nil
local isAutoShootingActive = false

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(255, 0, 0) 
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

local SilentFOVring = Drawing.new("Circle")
SilentFOVring.Visible = false
SilentFOVring.Thickness = 1
SilentFOVring.Color = Color3.fromRGB(0, 255, 255)
SilentFOVring.Filled = false
SilentFOVring.Radius = silentFov
SilentFOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

local aimConnection = nil
local silentAimConnection = nil

-- 自动射击相关函数
local function initializeAutoShootModule()
    if not ShooterModule then
        local success, module = pcall(function()
            return require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
        end)
        
        if success and module then
            ShooterModule = module
            OriginalShoot = module._shoot
            return true
        end
    end
    return ShooterModule ~= nil
end

local function hasLineOfSight(shooterPos, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local direction = (targetPos - shooterPos).Unit
    local distance = (targetPos - shooterPos).Magnitude
    local raycastResult = Workspace:Raycast(shooterPos, direction * distance, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart then
            local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
            if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
                return true
            else
                return false
            end
        end
    end
    return true
end

local function createBeautifulTrail(origin, targetPos)
    local function createBezierCurve(p0, p1, p2, t)
        return (1-t)^2 * p0 + 2*(1-t)*t * p1 + t^2 * p2
    end
    
    local trailContainer = Instance.new("Folder")
    trailContainer.Name = "MagicTrail"
    trailContainer.Parent = Workspace
    
    local midPoint = (origin + targetPos) / 2
    local direction = (targetPos - origin).Unit
    local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
    local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)
    
    local curvePoints = {}
    local numSegments = 20
    
    for i = 0, numSegments do
        local t = i / numSegments
        local point = createBezierCurve(origin, controlPoint, targetPos, t)
        table.insert(curvePoints, point)
    end
    
    for i = 1, #curvePoints - 1 do
        local startPoint = curvePoints[i]
        local endPoint = curvePoints[i + 1]
        local distance = (endPoint - startPoint).Magnitude
        
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.15, 0.15, distance)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Transparency = 0.3
        beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance/2)
        beamPart.Parent = trailContainer
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 5
        pointLight.Range = 3
        pointLight.Color = Color3.fromRGB(0, 170, 255)
        pointLight.Parent = beamPart
        
        local particles = Instance.new("ParticleEmitter")
        particles.Size = NumberSequence.new(0.1, 0.3)
        particles.Transparency = NumberSequence.new(0.3, 0.8)
        particles.Lifetime = NumberRange.new(0.5, 1)
        particles.Rate = 50
        particles.Speed = NumberRange.new(1, 2)
        particles.VelocitySpread = 180
        particles.Parent = beamPart
    end
    
    task.spawn(function()
        task.wait(1.5)
        if trailContainer and trailContainer.Parent then
            trailContainer:Destroy()
        end
    end)
    
    return trailContainer
end

local function getLockedTargetPosition()
    if not isAiming then return nil end
    
    if aimLock and lockedPlayer and tick() - lastLockTime < lockDuration then
        if lockedPlayer.Character and lockedPlayer.Character:FindFirstChild(targetPart) then
            return lockedPlayer.Character[targetPart].Position
        end
    else
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            if aimLock then
                lockedPlayer = target
                lastLockTime = tick()
            end
            return target.Character[targetPart].Position
        end
    end
    return nil
end

local function hookAutoShoot()
    if not ShooterModule or not OriginalShoot then
        if not initializeAutoShootModule() then
            warn("自动射击模块初始化失败")
            return
        end
    end
    
    ShooterModule._shoot = function(self)
        if not self or not self.tool then
            return OriginalShoot(self)
        end
        
        local LocalPlayer = game.Players.LocalPlayer
        local LocalCharacter = LocalPlayer.Character
        
        if not LocalCharacter then
            return OriginalShoot(self)
        end
        
        -- 只在自瞄有锁定目标时进行自动射击
        local targetPos = getLockedTargetPosition()
        
        if targetPos and isAiming and isAutoShootOnAim then
            local shooterPos = LocalCharacter.HumanoidRootPart and LocalCharacter.HumanoidRootPart.Position or LocalCharacter.PrimaryPart.Position
            
            if hasLineOfSight(shooterPos, targetPos) then
                self.aimpoint = targetPos
                self.aimpoint2 = targetPos
                
                if self.tool.model and self.tool.model.PrimaryPart then
                    local muzzlePos = self.tool.model.PrimaryPart.Position
                    createBeautifulTrail(muzzlePos, targetPos)
                else
                    createBeautifulTrail(shooterPos, targetPos)
                end
                
                if self.tool then
                    self.tool.shooting = true
                    self.tool.fireDebounce = 0
                    self.tool.fireMode = "auto"
                end
            else
                if self.tool then
                    self.tool.shooting = false
                end
            end
        end
        
        return OriginalShoot(self)
    end
    
    print("自动射击挂钩已启用（仅在自瞄锁定目标时射击）")
end

local function startAutoShootLoop()
    if autoShootConnection then
        autoShootConnection:Disconnect()
    end
    
    autoShootConnection = RunService.Heartbeat:Connect(function()
        if not isAiming or not isAutoShootOnAim then return end
        
        local targetPos = getLockedTargetPosition()
        if not targetPos then return end
        
        local LocalPlayer = game.Players.LocalPlayer
        local LocalCharacter = LocalPlayer.Character
        
        if not LocalCharacter then return end
        
        local now = tick()
        if now - lastShotTime < shootDelay then return end
        
        local tool = LocalCharacter:FindFirstChildWhichIsA("Tool")
        if not tool then return end
        
        local shooter = tool:FindFirstChild("Shooter")
        if not shooter then
            shooter = {tool = tool}
        end
        
        if ShooterModule and ShooterModule._shoot then
            pcall(function()
                ShooterModule._shoot(shooter)
            end)
        end
        
        lastShotTime = now
    end)
    
    isAutoShootingActive = true
    print("自动射击循环已启动")
end

local function stopAutoShoot()
    if autoShootConnection then
        autoShootConnection:Disconnect()
        autoShootConnection = nil
    end
    
    isAutoShootingActive = false
    
    if ShooterModule and OriginalShoot then
        ShooterModule._shoot = OriginalShoot
    end
    
    print("自动射击已停止")
end

-- 高级预测函数
local function calculateAdvancedPrediction(playerPosition, playerVelocity, bulletVelocity, gravity, distance)
    if predictionType == "线性" then
        local travelTime = distance / bulletVelocity
        return playerPosition + playerVelocity * travelTime
    elseif predictionType == "抛物线" then
        local travelTime = distance / bulletVelocity
        local predictedPos = playerPosition + playerVelocity * travelTime
        local drop = Vector3.new(0, -0.5 * gravity * travelTime^2, 0)
        return predictedPos + drop
    elseif predictionType == "自适应" then
        local targetSpeed = playerVelocity.Magnitude
        local adaptiveFactor = 1 + (targetSpeed / 50) * advancedPredictionFactor
        local travelTime = distance / bulletVelocity
        return playerPosition + playerVelocity * travelTime * adaptiveFactor
    end
    return playerPosition
end

-- 瞄准功能
local function updateDrawings()
    FOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    SilentFOVring.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
end

local function getClosestPlayerInFOV()
    local nearest = nil
    local lastDistance = math.huge
    local lowestHealthPlayer = nil
    local lowestHealth = math.huge
    local nearestDistance = math.huge
    local playerMousePos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local fovToUse = silentFov
    local now = tick()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            if teamCheck and player.Team == plr.Team then continue end
            
            local character = player.Character
            if character and character:FindFirstChild(targetPart) then
                if aliveCheck and (not character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("Humanoid").Health <= 0) then continue end
                
                local part = character[targetPart]
                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                local screenDistance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude
                
                if screenDistance < fovToUse and isVisible then
                    local distance = (plr.Character and plr.Character.PrimaryPart and (part.Position - plr.Character.PrimaryPart.Position).Magnitude) or math.huge
                    
                    if aimbotPriority == "距离" and distance < nearestDistance then
                        nearestDistance = distance
                        nearest = player
                    elseif aimbotPriority == "屏幕距离" and screenDistance < lastDistance then
                        lastDistance = screenDistance
                        nearest = player
                    elseif aimbotPriority == "生命值" then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health < lowestHealth then
                            lowestHealth = humanoid.Health
                            lowestHealthPlayer = player
                        end
                    end
                end
            end
        end
    end

    if aimbotPriority == "生命值" and lowestHealthPlayer then
        return lowestHealthPlayer
    end

    return nearest
end

local function getPredictedPosition(player, deltaTime)
    if not isPredicting then
        return player.Character and player.Character:FindFirstChild(targetPart) and player.Character[targetPart].Position
    end
    
    if useAdvancedPrediction then
        local character = player.Character
        if not character or not character:FindFirstChild(targetPart) then return end
        
        local part = character[targetPart]
        local velocity = part.Velocity
        local distance = (part.Position - Cam.CFrame.Position).Magnitude
        
        return calculateAdvancedPrediction(part.Position, velocity, bulletSpeed, gravityFactor, distance)
    else
        local character = player.Character
        if not character or not character:FindFirstChild(targetPart) then return end

        local part = character[targetPart]
        local velocity = part.Velocity
        local nextPosition = part.Position + velocity * deltaTime * predictionDistance
        
        if isLagCompensation then
            nextPosition = nextPosition + velocity * lagCompensationTime
        end
        
        return nextPosition
    end
end

-- 智能瞄准函数
local function smartAimAt(targetPosition)
    local currentCFrame = Cam.CFrame
    local targetDirection = (targetPosition - currentCFrame.Position).Unit
    
    if aimStyle == "平滑" then
        local smoothFactor = smoothness
        if isRageMode then smoothFactor = smoothness * 0.3 end
        
        local lookVector = currentCFrame.LookVector:Lerp(targetDirection, smoothFactor)
        Cam.CFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + lookVector)
        
    elseif aimStyle == "直接" or isRageMode then
        Cam.CFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + targetDirection)
        
    elseif aimStyle == "震动" then
        local lookVector = currentCFrame.LookVector:Lerp(targetDirection, smoothness)
        local shake = Vector3.new(
            (math.random() - 0.5) * 0.1,
            (math.random() - 0.5) * 0.1,
            0
        )
        Cam.CFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + lookVector + shake)
    end
end

-- 静默瞄准功能
local function silentAim()
    if not isSilentAim then return nil end
    
    local target = getClosestPlayerInFOV()
    if not target or not target.Character or not target.Character:FindFirstChild(targetPart) then return nil end
    
    if math.random(1, 100) > silentAimChance then return nil end
    
    local part = target.Character[targetPart]
    local predictedPos = getPredictedPosition(target, 0.016)
    
    return predictedPos or part.Position
end

-- 瞄准主循环
local function aimLoop()
    if not isAiming then return end
    
    updateDrawings()
    
    local now = tick()
    local deltaTime = 0.016
    
    if aimLock and lockedPlayer and now - lastLockTime < lockDuration then
        if lockedPlayer.Character and lockedPlayer.Character:FindFirstChild(targetPart) then
            local targetPos = getPredictedPosition(lockedPlayer, deltaTime)
            if targetPos then
                smartAimAt(targetPos)
            end
        end
    else
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild(targetPart) then
            local targetPos = getPredictedPosition(target, deltaTime)
            if targetPos then
                smartAimAt(targetPos)
                
                if aimLock then
                    lockedPlayer = target
                    lastLockTime = now
                end
            end
        end
    end
end

-- 触发器功能
local function triggerBotLoop()
    if not isTriggerBot then return end
    
    local target = getClosestPlayerInFOV()
    if target and target.Character and target.Character:FindFirstChild(targetPart) then
        local part = target.Character[targetPart]
        local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
        
        if isVisible then
            targetVisibleTime = targetVisibleTime + 0.016
            if targetVisibleTime >= triggerDelay then
                -- 不自动射击，只在触发器模式下使用原来的射击逻辑
                targetVisibleTime = 0
            end
        else
            targetVisibleTime = 0
        end
    end
end

-- 控件
Main:Toggle({
    Title = "开启自瞄",
    Default = false,
    Callback = function(v)
        isAiming = v
        FOVring.Visible = v
        if v then
            if aimConnection then aimConnection:Disconnect() end
            aimConnection = RunService.RenderStepped:Connect(aimLoop)
        elseif aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
    end
})

Main:Toggle({
    Title = "静默瞄准",
    Default = false,
    Callback = function(v)
        isSilentAim = v
        SilentFOVring.Visible = v
    end
})

Main:Toggle({
    Title = "瞄准时自动射击",
    Default = false,
    Callback = function(v)
        isAutoShootOnAim = v
        if v then
            hookAutoShoot()
            startAutoShootLoop()
        else
            stopAutoShoot()
        end
    end
})

Main:Toggle({
    Title = "预判自瞄",
    Default = false,
    Callback = function(v)
        isPredicting = v
    end
})

Main:Toggle({
    Title = "高级预判",
    Default = false,
    Callback = function(v)
        useAdvancedPrediction = v
    end
})

Main:Toggle({
    Title = "锁定目标",
    Default = false,
    Callback = function(v)
        aimLock = v
    end
})

Main:Toggle({
    Title = "狂暴模式",
    Default = false,
    Callback = function(v)
        isRageMode = v
    end
})

Main:Section({Title = "瞄准设置"})

Main:Dropdown({
    Title = "瞄准风格",
    Values = {"平滑", "直接", "震动"},
    Default = "平滑",
    Callback = function(v)
        aimStyle = v
    end
})

Main:Dropdown({
    Title = "瞄准优先级",
    Values = {"距离", "屏幕距离", "生命值"},
    Default = "距离",
    Callback = function(v)
        aimbotPriority = v
    end
})

Main:Dropdown({
    Title = "自瞄身体部位",
    Values = {"头", "胸", "左手", "右手", "左腿", "右腿"},
    Default = "头",
    Callback = function(v)
        local partMap = {
            ["头"] = "Head",
            ["胸"] = "UpperTorso",
            ["左手"] = "LeftHand",
            ["右手"] = "RightHand",
            ["左腿"] = "LeftFoot",
            ["右腿"] = "RightFoot"
        }
        targetPart = partMap[v]
    end
})

Main:Dropdown({
    Title = "预判类型",
    Values = {"线性", "抛物线", "自适应"},
    Default = "线性",
    Callback = function(v)
        predictionType = v
    end
})

Main:Slider({
    Title = "FOV范围",
    Desc = "自瞄检测范围",
    Value = {
        Min = 1,
        Max = 500,
        Default = 50
    },
    Callback = function(v)
        fov = v
        FOVring.Radius = v
    end
})

Main:Slider({
    Title = "静默FOV",
    Desc = "静默瞄准范围",
    Value = {
        Min = 1,
        Max = 200,
        Default = 30
    },
    Callback = function(v)
        silentFov = v
        SilentFOVring.Radius = v
    end
})

Main:Slider({
    Title = "平滑度",
    Desc = "瞄准平滑程度",
    Value = {
        Min = 0.01,
        Max = 1,
        Default = 0.5
    },
    Callback = function(v)
        smoothness = v
    end
})

Main:Slider({
    Title = "预判距离",
    Desc = "预判移动距离",
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 1.5
    },
    Callback = function(v)
        predictionDistance = v
    end
})

Main:Slider({
    Title = "射击速度",
    Desc = "自动射击间隔",
    Value = {
        Min = 0.01,
        Max = 1,
        Default = 0.1
    },
    Callback = function(v)
        shootDelay = v
    end
})

Main:Slider({
    Title = "射击范围",
    Desc = "自动射击最大距离",
    Value = {
        Min = 10,
        Max = 2000,
        Default = 500
    },
    Callback = function(v)
        shootRange = v
    end
})

Main:Slider({
    Title = "静默命中率",
    Desc = "静默瞄准成功率(%)",
    Value = {
        Min = 1,
        Max = 100,
        Default = 100
    },
    Callback = function(v)
        silentAimChance = v
    end
})

Main:Slider({
    Title = "子弹速度",
    Desc = "用于高级预判",
    Value = {
        Min = 100,
        Max = 2000,
        Default = 500
    },
    Callback = function(v)
        bulletSpeed = v
    end
})

Main:Slider({
    Title = "锁定时间",
    Desc = "目标锁定持续时间(秒)",
    Value = {
        Min = 1,
        Max = 10,
        Default = 3
    },
    Callback = function(v)
        lockDuration = v
    end
})

Main:Section({Title = "其他功能"})

Main:Toggle({
    Title = "活体检测",
    Default = false,
    Callback = function(v)
        aliveCheck = v
    end
})

Main:Toggle({
    Title = "墙壁检测",
    Default = false,
    Callback = function(v)
        wallCheck = v
    end
})

Main:Toggle({
    Title = "团队检查",
    Default = false,
    Callback = function(v)
        teamCheck = v
    end
})

Main:Toggle({
    Title = "延迟补偿",
    Default = false,
    Callback = function(v)
        isLagCompensation = v
    end
})

local function cleanupAim()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    stopAutoShoot()
    if FOVring then
        FOVring:Remove()
    end
    if SilentFOVring then
        SilentFOVring:Remove()
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if isAiming then
        task.wait(1)
        if not aimConnection then
            aimConnection = RunService.RenderStepped:Connect(aimLoop)
        end
        if isAutoShootOnAim then
            task.wait(2)
            hookAutoShoot()
            startAutoShootLoop()
        end
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "CloudHub" then
        cleanupAim()
    end
end)

    
local Main = Window:Tab({Title = "透视", Icon = "user"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP 配置
local ESPConfig = {
    ESPEnabled = false,
    ShowBox = false,
    ShowHealth = false,
    ShowName = false,
    ShowDistance = false,
    ShowTracer = false,
    TeamCheck = false,
    ShowSkeleton = false,
    ShowRadar = false,
    ShowPlayerCount = false,
    ShowWeapon = false,
    ShowFOV = false,
    OutOfViewArrows = false,
    Chams = false,
    
    -- ESP 颜色配置
    TracerColor = Color3.new(1, 0, 0),
    SkeletonColor = Color3.new(0.2, 0.8, 1),
    BoxColor = Color3.new(1, 1, 1),
    HealthBarColor = Color3.new(0, 1, 0),
    HealthTextColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    DistanceColor = Color3.new(1, 1, 0),
    WeaponColor = Color3.new(1, 0.5, 0),
    ArrowColor = Color3.new(1, 0, 0),
    FOVColor = Color3.new(1, 1, 1),
    ChamsColor = Color3.new(1, 0, 0),
    
    -- ESP 样式配置
    BoxThickness = 1,
    TracerThickness = 1,
    SkeletonThickness = 2,
    FOVRadius = 100,
    ArrowSize = 15
}

-- 渐变颜色函数
local function getGradientColor(time)
    local r = math.sin(time * 2) * 0.5 + 0.5
    local g = math.sin(time * 3) * 0.5 + 0.5
    local b = math.sin(time * 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- 玩家计数文本
local playerCountText = Drawing.new("Text")
playerCountText.Visible = false
playerCountText.Color = Color3.new(1, 1, 1)
playerCountText.Size = 20
playerCountText.Font = Drawing.Fonts.Monospace
playerCountText.Outline = true
playerCountText.OutlineColor = Color3.new(0, 0, 0)
playerCountText.Position = Vector2.new(Camera.ViewportSize.X / 2, 10)

-- FOV 圆圈
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = ESPConfig.FOVColor
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = ESPConfig.FOVRadius
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- 更新玩家计数
local function updatePlayerCount()
    local playerCount = #Players:GetPlayers()
    playerCountText.Text = "在线玩家: " .. playerCount
    playerCountText.Visible = ESPConfig.ESPEnabled and ESPConfig.ShowPlayerCount

    local time = tick()
    playerCountText.Color = getGradientColor(time)
end

-- 更新 FOV 圆圈
local function updateFOV()
    fovCircle.Visible = ESPConfig.ShowFOV
    fovCircle.Color = ESPConfig.FOVColor
    fovCircle.Radius = ESPConfig.FOVRadius
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- ESP 组件存储
local ESPComponents = {}

-- 创建玩家 ESP
local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESPConfig.BoxColor
    box.Thickness = ESPConfig.BoxThickness
    box.Filled = false

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = ESPConfig.HealthBarColor
    healthBar.Thickness = 1
    healthBar.Filled = true

    local healthBarBackground = Drawing.new("Square")
    healthBarBackground.Visible = false
    healthBarBackground.Color = Color3.new(0, 0, 0)
    healthBarBackground.Transparency = 0.5
    healthBarBackground.Thickness = 1
    healthBarBackground.Filled = true

    local healthBarBorder = Drawing.new("Square")
    healthBarBorder.Visible = false
    healthBarBorder.Color = Color3.new(1, 1, 1)
    healthBarBorder.Thickness = 1
    healthBarBorder.Filled = false

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = ESPConfig.HealthTextColor
    healthText.Size = 14
    healthText.Font = Drawing.Fonts.Monospace
    healthText.Outline = true
    healthText.OutlineColor = Color3.new(0, 0, 0)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = ESPConfig.NameColor
    nameText.Size = 16
    nameText.Font = Drawing.Fonts.Monospace
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0, 0, 0)

    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = ESPConfig.DistanceColor
    distanceText.Size = 14
    distanceText.Font = Drawing.Fonts.Monospace
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)

    local weaponText = Drawing.new("Text")
    weaponText.Visible = false
    weaponText.Color = ESPConfig.WeaponColor
    weaponText.Size = 14
    weaponText.Font = Drawing.Fonts.Monospace
    weaponText.Outline = true
    weaponText.OutlineColor = Color3.new(0, 0, 0)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESPConfig.TracerColor
    tracer.Thickness = ESPConfig.TracerThickness

    local arrow = Drawing.new("Triangle")
    arrow.Visible = false
    arrow.Color = ESPConfig.ArrowColor
    arrow.Filled = true
    arrow.Thickness = 1

    local skeletonLines = {}
    local skeletonPoints = {}

    -- 创建骨骼线条
    local function createSkeleton()
        for i = 1, 15 do
            skeletonLines[i] = Drawing.new("Line")
            skeletonLines[i].Visible = false
            skeletonLines[i].Color = ESPConfig.SkeletonColor
            skeletonLines[i].Thickness = ESPConfig.SkeletonThickness
        end

        skeletonPoints["Head"] = Drawing.new("Circle")
        skeletonPoints["Head"].Visible = false
        skeletonPoints["Head"].Color = Color3.new(1, 0.5, 0)
        skeletonPoints["Head"].Thickness = 2
        skeletonPoints["Head"].Filled = true
        skeletonPoints["Head"].Radius = 4
    end

    createSkeleton()

    local lastHealth = 100
    local healthChangeTime = 0
    local smoothHealth = 100

    -- 存储 ESP 组件
    ESPComponents[player] = {
        box = box,
        healthBar = healthBar,
        healthBarBackground = healthBarBackground,
        healthBarBorder = healthBarBorder,
        healthText = healthText,
        nameText = nameText,
        distanceText = distanceText,
        weaponText = weaponText,
        tracer = tracer,
        arrow = arrow,
        skeletonLines = skeletonLines,
        skeletonPoints = skeletonPoints
    }

    -- 每帧更新 ESP
    RunService.RenderStepped:Connect(function()
        if not ESPConfig.ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player == LocalPlayer then
            -- 隐藏所有组件
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        -- 队伍检查
        if ESPConfig.TeamCheck and player.Team == LocalPlayer.Team then
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if rootPart and humanoid and humanoid.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos, _ = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local legPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            -- 获取武器名称
            local weaponName = "无武器"
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    weaponName = tool.Name
                    break
                end
            end

            -- 方框透视
            if ESPConfig.ShowBox and onScreen then
                box.Size = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
                box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
                box.Visible = true
                box.Color = ESPConfig.BoxColor
                box.Thickness = ESPConfig.BoxThickness
            else
                box.Visible = false
            end

            -- 血量条
            if ESPConfig.ShowHealth and onScreen then
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                local barWidth = 50
                local barHeight = 5
                local barX = headPos.X - barWidth / 2
                local barY = headPos.Y - 20

                healthBarBackground.Size = Vector2.new(barWidth, barHeight)
                healthBarBackground.Position = Vector2.new(barX, barY)
                healthBarBackground.Visible = true

                healthBarBorder.Size = Vector2.new(barWidth, barHeight)
                healthBarBorder.Position = Vector2.new(barX, barY)
                healthBarBorder.Visible = true

                smoothHealth = smoothHealth + (humanoid.Health - smoothHealth) * 0.1
                local smoothHealthPercentage = smoothHealth / humanoid.MaxHealth

                healthBar.Size = Vector2.new(barWidth * smoothHealthPercentage, barHeight)
                healthBar.Position = Vector2.new(barX, barY)

                -- 根据血量改变颜色
                if smoothHealthPercentage >= 0.8 then
                    healthBar.Color = Color3.new(0, 1, 0)
                elseif smoothHealthPercentage >= 0.5 then
                    healthBar.Color = Color3.new(1, 1, 0)
                elseif smoothHealthPercentage >= 0.2 then
                    healthBar.Color = Color3.new(1, 0.5, 0)
                else
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthBar.Visible = true

                -- 血量变化效果
                if humanoid.Health ~= lastHealth then
                    healthChangeTime = tick()
                    lastHealth = humanoid.Health
                end

                if tick() - healthChangeTime < 0.5 then
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthText.Position = Vector2.new(barX + barWidth + 5, barY - 5)
                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthText.Visible = true
            else
                healthBar.Visible = false
                healthBarBackground.Visible = false
                healthBarBorder.Visible = false
                healthText.Visible = false
            end

            -- 名字和距离
            if ESPConfig.ShowName and onScreen then
                nameText.Position = Vector2.new(headPos.X, headPos.Y - 35)
                nameText.Text = player.Name
                nameText.Visible = true

                if ESPConfig.ShowDistance then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    distanceText.Position = Vector2.new(headPos.X, headPos.Y + 10)
                    distanceText.Text = math.floor(distance) .. "m"
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end

                if ESPConfig.ShowWeapon then
                    weaponText.Position = Vector2.new(headPos.X, headPos.Y - 50)
                    weaponText.Text = weaponName
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end
            else
                nameText.Visible = false
                distanceText.Visible = false
                weaponText.Visible = false
            end

            -- 射线
            if ESPConfig.ShowTracer then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(headPos.X, headPos.Y)
                        tracer.Visible = true
                        tracer.Color = ESPConfig.TracerColor
                        tracer.Thickness = ESPConfig.TracerThickness
                        
                        
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        if distance < 20 then
                            tracer.Color = Color3.new(0, 1, 0)
                        elseif distance < 50 then
                            tracer.Color = Color3.new(1, 1, 0) 
                        else
                            tracer.Color = ESPConfig.TracerColor 
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end

          
            if ESPConfig.OutOfViewArrows and not onScreen then
                local direction = (rootPart.Position - Camera.CFrame.Position).Unit
                local dotProduct = Camera.CFrame.RightVector:Dot(direction)
                local crossProduct = Camera.CFrame.RightVector:Cross(direction)
                
                local screenPosition = Vector2.new(
                    Camera.ViewportSize.X / 2 + dotProduct * Camera.ViewportSize.X / 3,
                    Camera.ViewportSize.Y / 2 - crossProduct.Y * Camera.ViewportSize.Y / 3
                )
                
                screenPosition = Vector2.new(
                    math.clamp(screenPosition.X, ESPConfig.ArrowSize, Camera.ViewportSize.X - ESPConfig.ArrowSize),
                    math.clamp(screenPosition.Y, ESPConfig.ArrowSize, Camera.ViewportSize.Y - ESPConfig.ArrowSize)
                )
                
                local angle = math.atan2(screenPosition.Y - Camera.ViewportSize.Y / 2, screenPosition.X - Camera.ViewportSize.X / 2)
                
                arrow.PointA = screenPosition
                arrow.PointB = Vector2.new(
                    screenPosition.X - ESPConfig.ArrowSize * math.cos(angle - 0.5),
                    screenPosition.Y - ESPConfig.ArrowSize * math.sin(angle - 0.5)
                )
                arrow.PointC = Vector2.new(
                    screenPosition.X - ESPConfig.ArrowSize * math.cos(angle + 0.5),
                    screenPosition.Y - ESPConfig.ArrowSize * math.sin(angle + 0.5)
                )
                
                arrow.Color = ESPConfig.ArrowColor
                arrow.Visible = true
            else
                arrow.Visible = false
            end

       
            if ESPConfig.ShowSkeleton and onScreen then
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
                local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
                local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
                
                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos = Camera:WorldToViewportPoint(torso.Position)
                    local leftArmPos = Camera:WorldToViewportPoint(leftArm.Position)
                    local rightArmPos = Camera:WorldToViewportPoint(rightArm.Position)
                    local leftLegPos = Camera:WorldToViewportPoint(leftLeg.Position)
                    local rightLegPos = Camera:WorldToViewportPoint(rightLeg.Position)

                    skeletonPoints["Head"].Position = Vector2.new(headPos.X, headPos.Y)
                    skeletonPoints["Head"].Visible = true

               
                    skeletonLines[1].From = Vector2.new(headPos.X, headPos.Y)
                    skeletonLines[1].To = Vector2.new(torsoPos.X, torsoPos.Y) 
                    skeletonLines[1].Visible = true

                    skeletonLines[2].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[2].To = Vector2.new(leftArmPos.X, leftArmPos.Y)
                    skeletonLines[2].Visible = true

                    skeletonLines[3].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[3].To = Vector2.new(rightArmPos.X, rightArmPos.Y)
                    skeletonLines[3].Visible = true

                    skeletonLines[4].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[4].To = Vector2.new(leftLegPos.X, leftLegPos.Y)
                    skeletonLines[4].Visible = true

                    skeletonLines[5].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[5].To = Vector2.new(rightLegPos.X, rightLegPos.Y)
                    skeletonLines[5].Visible = true

                
                    if character:FindFirstChild("LeftLowerArm") then
                        local leftLowerArmPos = Camera:WorldToViewportPoint(character.LeftLowerArm.Position)
                        skeletonLines[6].From = Vector2.new(leftArmPos.X, leftArmPos.Y)
                        skeletonLines[6].To = Vector2.new(leftLowerArmPos.X, leftLowerArmPos.Y)
                        skeletonLines[6].Visible = true
                    end

                    if character:FindFirstChild("RightLowerArm") then
                        local rightLowerArmPos = Camera:WorldToViewportPoint(character.RightLowerArm.Position)
                        skeletonLines[7].From = Vector2.new(rightArmPos.X, rightArmPos.Y)
                        skeletonLines[7].To = Vector2.new(rightLowerArmPos.X, rightLowerArmPos.Y)
                        skeletonLines[7].Visible = true
                    end

                    if character:FindFirstChild("LeftLowerLeg") then
                        local leftLowerLegPos = Camera:WorldToViewportPoint(character.LeftLowerLeg.Position)
                        skeletonLines[8].From = Vector2.new(leftLegPos.X, leftLegPos.Y)
                        skeletonLines[8].To = Vector2.new(leftLowerLegPos.X, leftLowerLegPos.Y)
                        skeletonLines[8].Visible = true
                    end

                    if character:FindFirstChild("RightLowerLeg") then
                        local rightLowerLegPos = Camera:WorldToViewportPoint(character.RightLowerLeg.Position)
                        skeletonLines[9].From = Vector2.new(rightLegPos.X, rightLegPos.Y)
                        skeletonLines[9].To = Vector2.new(rightLowerLegPos.X, rightLowerLegPos.Y)
                        skeletonLines[9].Visible = true
                    end
                else
                    for _, line in pairs(skeletonLines) do
                        line.Visible = false
                    end
                    for _, point in pairs(skeletonPoints) do
                        point.Visible = false
                    end
                end
            else
                for _, line in pairs(skeletonLines) do
                    line.Visible = false
                end
                for _, point in pairs(skeletonPoints) do
                    point.Visible = false
                end
            end
        else
            -- 玩家死亡时隐藏所有组件
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
        end
    end)
end
local radar = Drawing.new("Circle")
radar.Visible = false
radar.Color = Color3.new(1, 1, 1)
radar.Thickness = 2
radar.Filled = false
radar.Radius = 100
radar.Position = Vector2.new(Camera.ViewportSize.X - 120, 120)

local radarCenter = Drawing.new("Circle")
radarCenter.Visible = false
radarCenter.Color = Color3.new(1, 1, 1)
radarCenter.Thickness = 2
radarCenter.Filled = true
radarCenter.Radius = 3
radarCenter.Position = radar.Position

local radarDirection = Drawing.new("Line")
radarDirection.Visible = false
radarDirection.Color = Color3.new(1, 1, 1)
radarDirection.Thickness = 2

local radarGridLines = {}
for i = 1, 4 do
    radarGridLines[i] = Drawing.new("Line")
    radarGridLines[i].Visible = false
    radarGridLines[i].Color = Color3.new(0.5, 0.5, 0.5)
    radarGridLines[i].Thickness = 1
end

local radarRangeText = Drawing.new("Text")
radarRangeText.Visible = false
radarRangeText.Color = Color3.new(1, 1, 1)
radarRangeText.Size = 14
radarRangeText.Font = Drawing.Fonts.Monospace
radarRangeText.Outline = true
radarRangeText.OutlineColor = Color3.new(0, 0, 0)
radarRangeText.Text = "100m"

local radarPlayers = {}

local function updateRadar()
    if not ESPConfig.ShowRadar then
        radar.Visible = false
        radarCenter.Visible = false
        radarDirection.Visible = false
        radarRangeText.Visible = false
        
        for _, line in pairs(radarGridLines) do
            line.Visible = false
        end
        
        for _, player in pairs(radarPlayers) do
            if player.dot then player.dot.Visible = false end
            if player.direction then player.direction.Visible = false end
            if player.name then player.name.Visible = false end
        end
        return
    end

    radar.Visible = true
    radarCenter.Visible = true
    radarDirection.Visible = true
    radarRangeText.Visible = true
    
    radarRangeText.Position = Vector2.new(radar.Position.X, radar.Position.Y + radar.Radius + 5)
    
  
    for i = 1, 4 do
        local angle = (i-1) * math.pi / 2
        radarGridLines[i].From = radar.Position
        radarGridLines[i].To = Vector2.new(
            radar.Position.X + math.cos(angle) * radar.Radius,
            radar.Position.Y + math.sin(angle) * radar.Radius
        )
        radarGridLines[i].Visible = true
    end
    
    radarDirection.From = radar.Position
    radarDirection.To = Vector2.new(radar.Position.X, radar.Position.Y - radar.Radius)

   
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local relativePosition = rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position
            
            local radarX = radar.Position.X + (relativePosition.X / 10)
            local radarY = radar.Position.Y + (relativePosition.Z / 10)
            
            local distanceFromCenter = math.sqrt((radarX - radar.Position.X)^2 + (radarY - radar.Position.Y)^2)
            
            if distanceFromCenter > radar.Radius then
                local angle = math.atan2(radarY - radar.Position.Y, radarX - radar.Position.X)
                radarX = radar.Position.X + math.cos(angle) * radar.Radius
                radarY = radar.Position.Y + math.sin(angle) * radar.Radius
            end
            
            if not radarPlayers[player] then
                radarPlayers[player] = {
                    dot = Drawing.new("Circle"),
                    direction = Drawing.new("Line"),
                    name = Drawing.new("Text")
                }
                
                radarPlayers[player].dot.Thickness = 1
                radarPlayers[player].dot.Filled = true
                radarPlayers[player].dot.Radius = 4
                
                radarPlayers[player].direction.Thickness = 2
                radarPlayers[player].direction.Visible = true
                
                radarPlayers[player].name.Size = 12
                radarPlayers[player].name.Font = Drawing.Fonts.Monospace
                radarPlayers[player].name.Outline = true
                radarPlayers[player].name.OutlineColor = Color3.new(0, 0, 0)
            end
            
         
            if player.Team == LocalPlayer.Team then
                radarPlayers[player].dot.Color = Color3.new(0, 1, 0)  
                radarPlayers[player].direction.Color = Color3.new(0, 0.8, 0)
                radarPlayers[player].name.Color = Color3.new(0, 1, 0)
            else
                radarPlayers[player].dot.Color = Color3.new(1, 0, 0) 
                radarPlayers[player].direction.Color = Color3.new(1, 0, 0)
                radarPlayers[player].name.Color = Color3.new(1, 0, 0)
            end
            
            radarPlayers[player].dot.Position = Vector2.new(radarX, radarY)
            radarPlayers[player].dot.Visible = true
            
         
            local lookVector = rootPart.CFrame.LookVector
            local directionLength = 10
            radarPlayers[player].direction.From = Vector2.new(radarX, radarY)
            radarPlayers[player].direction.To = Vector2.new(
                radarX + lookVector.X * directionLength,
                radarY + lookVector.Z * directionLength
            )
            
            radarPlayers[player].name.Position = Vector2.new(radarX, radarY - 15)
            radarPlayers[player].name.Text = player.Name
            radarPlayers[player].name.Visible = distanceFromCenter <= radar.Radius
        elseif radarPlayers[player] then
            radarPlayers[player].dot.Visible = false
            radarPlayers[player].direction.Visible = false
            radarPlayers[player].name.Visible = false
        end
    end
    for player, components in pairs(radarPlayers) do
        if not Players:FindFirstChild(player.Name) then
            components.dot.Visible = false
            components.direction.Visible = false
            components.name.Visible = false
            radarPlayers[player] = nil
        end
    end
end
RunService.RenderStepped:Connect(updateRadar)
RunService.RenderStepped:Connect(updatePlayerCount)
RunService.RenderStepped:Connect(updateFOV)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if ESPComponents[player] then
        for _, component in pairs(ESPComponents[player]) do
            if typeof(component) == "table" then
                for _, drawing in pairs(component) do
                    drawing:Remove()
                end
            else
                component:Remove()
            end
        end
        ESPComponents[player] = nil
    end
end)

Main:Toggle({
    Title = "ESP总开关",
    Value = false,
    Callback = function(value)
        ESPConfig.ESPEnabled = value
    end
})

Main:Toggle({
    Title = "显示方框",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowBox = value
    end
})

Main:Toggle({
    Title = "显示血量",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowHealth = value
    end
})

Main:Toggle({
    Title = "显示名称",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowName = value
    end
})

Main:Toggle({
    Title = "显示距离",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowDistance = value
    end
})

Main:Toggle({
    Title = "显示射线",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowTracer = value
    end
})

Main:Toggle({
    Title = "队伍检查",
    Value = false,
    Callback = function(value)
        ESPConfig.TeamCheck = value
    end
})

Main:Toggle({
    Title = "显示骨骼",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowSkeleton = value
    end
})

Main:Toggle({
    Title = "显示雷达",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowRadar = value
    end
})

Main:Toggle({
    Title = "显示玩家计数",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowPlayerCount = value
    end
})

Main:Toggle({
    Title = "显示武器",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowWeapon = value
    end
})

Main:Toggle({
    Title = "屏幕外箭头",
    Value = false,
    Callback = function(value)
        ESPConfig.OutOfViewArrows = value
    end
})

Main:Toggle({
    Title = "显示 Chams",
    Value = false,
    Callback = function(value)
        ESPConfig.Chams = value
    end
})
Main:Slider({
    Title = "方框粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.BoxThickness,
    },
    Callback = function(Value)
        ESPConfig.BoxThickness = Value
    end
})

Main:Slider({
    Title = "射线粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.TracerThickness,
    },
    Callback = function(Value)
        ESPConfig.TracerThickness = Value
    end
})

Main:Slider({
    Title = "骨骼粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.SkeletonThickness,
    },
    Callback = function(Value)
        ESPConfig.SkeletonThickness = Value
    end
})

Main:Slider({
    Title = "箭头大小",
    Desc = "滑动调整",
    Value = {
        Min = 5,
        Max = 30,
        Default = ESPConfig.ArrowSize,
    },
    Callback = function(Value)
        ESPConfig.ArrowSize = Value
    end
})
    -- 玩家传送标签
    local TeleportPlayerTab = Window:Tab({Title = "玩家传送", Icon = "user"})
    
    local TargetPlayerName = ""
    local TeleportPosition = "前方"
    
    TeleportPlayerTab:Input({
        Title = "输入玩家用户名",
        Placeholder = "输入玩家名称",
        Callback = function(v)
            TargetPlayerName = v
        end
    })
    
    TeleportPlayerTab:Dropdown({
        Title = "传送部位",
        Values = {"前方", "后方", "头顶", "左侧", "右侧"},
        Value = TeleportPosition,
        Callback = function(v)
            TeleportPosition = v
        end
    })
    
    TeleportPlayerTab:Button({
        Title = "传送一次",
        Callback = function()
            if TargetPlayerName and TeleportPosition then
                local targetPlayer = game.Players:FindFirstChild(TargetPlayerName)
                
                if targetPlayer and targetPlayer ~= game.Players.LocalPlayer then
                    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local p = game.Players.LocalPlayer
                        local c = p.Character or p.CharacterAdded:Wait()
                        local h = c:WaitForChild("HumanoidRootPart")
                        local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                        
                        if TeleportPosition == "前方" then
                            h.CFrame = targetCFrame * CFrame.new(0, 0, -5)
                        elseif TeleportPosition == "后方" then
                            h.CFrame = targetCFrame * CFrame.new(0, 0, 5)
                        elseif TeleportPosition == "头顶" then
                            h.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                        elseif TeleportPosition == "左侧" then
                            h.CFrame = targetCFrame * CFrame.new(-5, 0, 0)
                        elseif TeleportPosition == "右侧" then
                            h.CFrame = targetCFrame * CFrame.new(5, 0, 0)
                        end
                    end
                end
            end
        end
    })
    
    local FixedTeleport = false
    
    TeleportPlayerTab:Toggle({
        Title = "固定传送",
        Default = FixedTeleport,
        Callback = function(v)
            FixedTeleport = v
            if v then
                task.spawn(function()
                    while FixedTeleport do
                        if TargetPlayerName and TeleportPosition then
                            local targetPlayer = game.Players:FindFirstChild(TargetPlayerName)
                            
                            if targetPlayer and targetPlayer ~= game.Players.LocalPlayer then
                                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local p = game.Players.LocalPlayer
                                    local c = p.Character or p.CharacterAdded:Wait()
                                    local h = c:WaitForChild("HumanoidRootPart")
                                    local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                                    
                                    if TeleportPosition == "前方" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 0, -5)
                                    elseif TeleportPosition == "后方" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 0, 5)
                                    elseif TeleportPosition == "头顶" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                                    elseif TeleportPosition == "左侧" then
                                        h.CFrame = targetCFrame * CFrame.new(-5, 0, 0)
                                    elseif TeleportPosition == "右侧" then
                                        h.CFrame = targetCFrame * CFrame.new(5, 0, 0)
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })
    
    -- 传送功能标签
    local TeleportSection = Window:Tab({Title = "地点传送", Icon = "map-pin"})
    
    TeleportSection:Button({
        Title = "传送到奥菲的价值兑换",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-2907.68848, 37.1002731, 1444.74817, 0.848566413, 3.9380446e-8, -0.529088855, -1.774107e-8, 1, 4.5977092e-8, 0.529088855, -2.962804e-8, 0.848566413)
        end
    })
    
    TeleportSection:Button({
        Title = "传送到绿洲银行",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-431.537354, 39.6113892, -1400.08313, -0.901108384, -1.61008e-8, -0.433593899, -5.2681104e-9, 1, -2.618487e-8, 0.433593899, -2.1311186e-8, -0.901108384)
        end
    })
    
    TeleportSection:Button({
        Title = "传送到绿洲城警察",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(2578.02393, 119.169289, -718.579773, -0.395326763, -5.9598324e-8, -0.918540537, -9.65633e-9, 1, -5.232432e-8, 0.918540537, 7.947669e-8, -0.395326763)
        end
    })
    
    TeleportSection:Button({
        Title = "传送到金库",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-400.492279, 163.151733, -1242.72632, -0.912052214, -1.09039995e-8, -0.410074085, 1.4650267e-8, 1, -5.9174205e-8, 0.410074085, -5.997766e-8, -0.912052214)
        end
    })
    
    TeleportSection:Button({
        Title = "传送到犯罪基地",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-5981.50586, 37.2680244, 1245.22046, -0.733384013, -3.6538985e-8, -0.679814577, -1.7351333e-8, 1, -3.502984e-8, 0.679814577, -1.38946366e-8, -0.733384013)
        end
    })
    
    TeleportSection:Button({
        Title = "传送到烈焰要塞",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1494.58496, 41.16481, 3364.56055, 0.961387396, 1.07588015e-7, 0.275198698, -9.5233396e-8, 1, -5.8255473e-8, -0.275198698, 2.97983e-8, 0.961387396)
        end
    })
    
    -- 武器传送标签
    local GunsTab = Window:Tab({Title = "武器传送", Icon = "target"})
    
    GunsTab:Button({
        Title = "自动瞄准器",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-822.973816, 179.617432, -290.576813, -0.829824746, 4.1572e-8, 0.558024108, -1.7091425e-8, 1, -9.991484e-8, -0.558024108, -9.24494e-8, -0.829824746)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "UMP 45",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(1358.20264, 143.366074, -1218.008301, -0.711087286, 7.777568e-9, -0.703103721, 0.0004326, 1, 1.0624305e-8, 0.703103721, 7.2505e-9, -0.711087286)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "贝内利M1014",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(1345.20422, 141.041168, -4809.10693, -0.879722357, 4.0964014e-8, -0.475487679, 7.8684534e-9, 1, 7.159378e-8, 0.475487679, 5.92413e-8, -0.879722357)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "M4A1",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-6342.43115, 134.380051, -1328.82861, -0.984255195, 1.02914e-8, 0.176753372, 1.648925e-8, 1, 3.359626e-8, -0.176753372, 3.59818e-8, -0.984255195)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "AK-47",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-4825.20752, 21.3648071, 1192.14551, -0.907641709, 3.2050632e-8, -0.419745833, 5.61627e-8, 1, -4.508672e-8, 0.419745833, -6.44966e-8, -0.907641709)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "RPG-7",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1392.19739, 275.933319, 2199.5188, -0.999439657, -4.083614e-8, -0.0334718302, -4.136207e-8, 1, 1.50201e-8, 0.0334718302, 1.6396225e-8, -0.999439657)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
    
    GunsTab:Button({
        Title = "乌兹",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1348.55493, 1109.2014694, 2033.73645, -0.322550327, 6.191085e-8, -0.946552336, 8.2431725e-8, 1, 3.731697e-8, 0.946552336, -6.598934e-8, -0.322550327)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
local Main = Window:Tab({Title = "娱乐", Icon = "settings"})

_G.AUTO_CHAT_TEXT = "Yttrium hub ！！！"
_G.AUTO_CHAT_ENABLED = false
_G.AUTO_CHAT_INTERVAL = 1.5
_G.AUTO_CHAT_MODE = "自定义"
local chatSystem = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TextChatService = game:GetService("TextChatService"),
    messageIndex = 1,
    messageCount = 0,
    lastMessageTime = 0,
    chatModes = {
        ["自定义"] = function() return {_G.AUTO_CHAT_TEXT} end,
        ["7字经"] = function() return {"来老弟", "你有啥实力", "你活着干啥呢", "臭底层", "快来打压你爹", "我在这等着呢", "快来打压我"} end,
        ["14字经"] = function() return {"你有啥用", "你活着干啥呢", "赶紧跳了吧", "老弟家里几位在哪里", "来吧赶紧让我口吃", "你爹等着你呢", "你个窝囊废", "孩子快来呀", "怎么不敢和你爹对话了？", "你有什么用处", "你活着当技女吗？", "一句话", "来打压我", "哈哈哈笑死我了"} end,
        ["糖人语言"] = function() return {"我是奶龙", "奶龙是我", "你是谁？？", "我是谁", "你干嘛啊？"} end,
        ["宣传词"] = function() return {"Yttrium hub牛逼", "打败一切", "快来购买", "功能多多", "支持超多服务器"} end
    },
    connections = {},
    active = false
}
chatSystem.tryTextChatSend = function(msg)
    local ok = false
    pcall(function()
        local ch = chatSystem.TextChatService.TextChannels:FindFirstChild("RBXGeneral") or
                   chatSystem.TextChatService.TextChannels:FindFirstChild("RBXGeneralChannel")
        if ch and ch.SendAsync then
            ch:SendAsync(msg)
            ok = true
        end
    end)
    return ok
end

chatSystem.tryOldChatSend = function(msg)
    local ok = false
    pcall(function()
        local ev = chatSystem.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local req = ev and ev:FindFirstChild("SayMessageRequest")
        if req then
            req:FireServer(msg, "All")
            ok = true
        end
    end)
    return ok
end

chatSystem.tryPlayerChat = function(msg)
    local ok = false
    pcall(function()
        local pl = chatSystem.Players.LocalPlayer
        if pl and pl.Chat then
            pl:Chat(msg)
            ok = true
        end
    end)
    return ok
end

chatSystem.doSend = function(msg)
    local sent = false
    sent = chatSystem.tryTextChatSend(msg) or sent
    if not sent then sent = chatSystem.tryOldChatSend(msg) or sent end
    if not sent then sent = chatSystem.tryPlayerChat(msg) or sent end
    
    if sent then
        chatSystem.messageCount = chatSystem.messageCount + 1
        chatSystem.lastMessageTime = os.time()
    end
    return sent
end
chatSystem.startAutoChat = function()
    if chatSystem.active then return end
    chatSystem.active = true
    
    chatSystem.connections.autoChat = game:GetService("RunService").Heartbeat:Connect(function()
        if _G.AUTO_CHAT_ENABLED and chatSystem.chatModes[_G.AUTO_CHAT_MODE] then
            local currentTime = tick()
            local lastSendTime = chatSystem.lastSendTime or 0
            local interval = tonumber(_G.AUTO_CHAT_INTERVAL) or 1.5
            
            if currentTime - lastSendTime >= interval then
                local messages = chatSystem.chatModes[_G.AUTO_CHAT_MODE]()
                if messages and #messages > 0 then
                    local message = messages[chatSystem.messageIndex]
                    chatSystem.doSend(tostring(message))
                    chatSystem.messageIndex = (chatSystem.messageIndex % #messages) + 1
                    chatSystem.lastSendTime = currentTime
                end
            end
        end
    end)
end

chatSystem.stopAutoChat = function()
    chatSystem.active = false
    if chatSystem.connections.autoChat then
        chatSystem.connections.autoChat:Disconnect()
        chatSystem.connections.autoChat = nil
    end
end
chatSystem.init = function()
    chatSystem.startAutoChat()
end
chatSystem.sendNow = function(message)
    if not message or message == "" then
        message = _G.AUTO_CHAT_TEXT
    end
    return chatSystem.doSend(message)
end
chatSystem.cleanup = function()
    for name, connection in pairs(chatSystem.connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    chatSystem.connections = {}
    chatSystem.active = false
end
task.spawn(chatSystem.init)
Main:Dropdown({
    Title = "发言模式",
    Values = {"自定义", "7字经", "14字经", "糖人语言", "宣传词"},
    Value = "自定义",
    Callback = function(value)
        _G.AUTO_CHAT_MODE = value
        chatSystem.messageIndex = 1 -- 重置消息索引
        WindUI:Notify({
            Title = "发言模式",
            Content = "已切换到: " .. value,
            Duration = 2,
            Icon = "message-circle"
        })
    end
})

Main:Input({
    Title = "自定义发言内容",
    Placeholder = "输入要发送的消息",
    Value = "Yttrium hub ！！！",
    Callback = function(value)
        _G.AUTO_CHAT_TEXT = value
        WindUI:Notify({
            Title = "自定义内容",
            Content = "已设置: " .. value,
            Duration = 2,
            Icon = "edit"
        })
    end
})

Main:Toggle({
    Title = "开启自动发言",
    Value = false,
    Callback = function(value)
        _G.AUTO_CHAT_ENABLED = value
        if value and not chatSystem.active then
            chatSystem.startAutoChat()
        elseif not value then
            chatSystem.stopAutoChat()
        end
        WindUI:Notify({
            Title = "自动发言",
            Content = value and "已开启" or "已关闭",
            Duration = 2,
            Icon = value and "play" or "square"
        })
    end
})

Main:Slider({
    Title = "发言间隔",
    Desc = "设置发送消息的时间间隔（秒）",
    Value = {Min = 0.5, Max = 10, Default = 1.5},
    Callback = function(value)
        _G.AUTO_CHAT_INTERVAL = value
        WindUI:Notify({
            Title = "发言间隔",
            Content = "已设置为: " .. value .. "秒",
            Duration = 2,
            Icon = "clock"
        })
    end
})
_G.ChatSystem = chatSystem



local weatherSettings = {
    ["雨天"] = "Rainy",
    ["阴天"] = "Overcast",
    ["晴天"] = "Clear",
    ["雪天"] = "Snowy"
}
local selectedWeather = "晴天"
local function changeWeather(weatherType)
    local lighting = game:GetService("Lighting")
    lighting.ClockTime = 14 
    lighting.Brightness = 1
    lighting.FogEnd = 10000
    lighting.GlobalShadows = true
    
   
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("ParticleEmitter") or obj.Name == "WeatherEffect" then
            obj:Destroy()
        end
    end
    
    
    if weatherType == "Rainy" then
       
        lighting.Brightness = 0.7
        lighting.FogEnd = 5000
        lighting.ExposureCompensation = -0.5
        
       
        local rain = Instance.new("ParticleEmitter")
        rain.Name = "WeatherEffect"
        rain.Parent = lighting
        rain.Texture = "rbxassetid://2530913495"
        rain.Size = NumberSequence.new(0.5)
        rain.Transparency = NumberSequence.new(0.3)
        rain.Lifetime = NumberRange.new(5)
        rain.Rate = 100
        rain.Speed = NumberRange.new(20)
        rain.VelocitySpread = 90
        rain.Rotation = NumberRange.new(0, 360)
        rain.RotSpeed = NumberRange.new(10)
        rain.LightEmission = 0.1
        
    elseif weatherType == "Overcast" then
        -- 阴天设置
        lighting.Brightness = 0.6
        lighting.FogEnd = 3000
        lighting.ExposureCompensation = -0.8
        lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        
    elseif weatherType == "Clear" then
        -- 晴天设置
        lighting.Brightness = 2
        lighting.FogEnd = 20000
        lighting.ExposureCompensation = 0.3
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
    elseif weatherType == "Snowy" then
        -- 雪天设置
        lighting.Brightness = 1.2
        lighting.FogEnd = 8000
        lighting.ExposureCompensation = 0.1
        
       
        local snow = Instance.new("ParticleEmitter")
        snow.Name = "WeatherEffect"
        snow.Parent = lighting
        snow.Texture = "rbxassetid://2530914826"
        snow.Size = NumberSequence.new(0.3)
        snow.Transparency = NumberSequence.new(0.1)
        snow.Lifetime = NumberRange.new(8)
        snow.Rate = 80
        snow.Speed = NumberRange.new(5)
        snow.VelocitySpread = 45
        snow.Rotation = NumberRange.new(0, 360)
        snow.RotSpeed = NumberRange.new(5)
        snow.LightEmission = 0.5
        snow.LightInfluence = 0
    end
    
    print("天气已切换至: " .. weatherType)
end
Main:Dropdown({
    Title = "选择天气",
    Values = {"雨天", "阴天", "晴天", "雪天"},
    Value = "晴天",
    Callback = function(option)
        selectedWeather = option
    end
})

Main:Button({
    Title = "确认变换天气",
    Callback = function()
        changeWeather(weatherSettings[selectedWeather])
    end
})

local skySettings = {
    ["动漫猫羽雫天空"] = "http://www.roblox.com/asset/?id=16060333448",
    ["动漫猫羽雫天空"] = "http://www.roblox.com/asset/?id=16060333448",
    ["动漫猫羽雫天空"] = "http://www.roblox.com/asset/?id=16060333448"
}

local selectedSky = "神青天空1"


local function changeSky(skyboxId)
    local lighting = game:GetService("Lighting")
    

    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end
    
   
    local sky = Instance.new("Sky")
    sky.CelestialBodiesShown = false
    sky.Parent = lighting
    sky.SkyboxUp = skyboxId
    sky.SkyboxBk = skyboxId
    sky.SkyboxDn = skyboxId
    sky.SkyboxRt = skyboxId
    sky.SkyboxLf = skyboxId
    sky.SkyboxFt = skyboxId
    
    print("天空已切换至: " .. selectedSky)
end

Main:Dropdown({
    Title = "选择天空盒",
    Values = {"神青天空1", "神青天空2", "动漫猫羽雫天空"},
    Value = "神青天空1",
    Callback = function(option)
        selectedSky = option
    end
})

Main:Button({
    Title = "确认变换天空",
    Callback = function()
        changeSky(skySettings[selectedSky])
    end
})


















local Settings = Window:Tab({Title = "ui设置", Icon = "palette"})
Settings:Paragraph({
    Title = "ui设置",
    Desc = "二改wind原版ui",
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
    Value = "彩虹颜色",
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
        setclipboard("Yttrium hub V2 设置: " .. game:GetService("HttpService"):JSONEncode(settings))
        playSound()
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