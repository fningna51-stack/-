local repo = "https://raw.githubusercontent.com/SyndromeXph/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.luau"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local MODULE_ENGLISH = {
    ["依附"] = "ATTACH", ["环绕"] = "ORBIT", ["锁定传送"] = "LOCKTP",
    ["随机传送"] = "RANDOMTP", ["随机环绕"] = "RANDOMORBIT", ["自动普攻"] = "AUTOM",
    ["技能1"] = "SKILL1", ["技能2"] = "SKILL2", ["技能3"] = "SKILL3", ["技能4"] = "SKILL4",
    ["自动躲技能"] = "AUTODODGE", ["TPSpeed"] = "TPSPEED", ["飞行"] = "VFLY",
    ["防甩飞"] = "ANTIFLING", ["透视"] = "VESP",
    ["预判锁定"] = "PREDICT-L", ["预判随机"] = "PREDICT-R",
}

local MathUtils = {}
function MathUtils.lerp(a, b, t) return a + t * (b - a) end
function MathUtils.clamp(value, min, max) return math.max(min, math.min(value, max)) end

local ColorUtils = {}
ColorUtils.theme = { Color3.fromRGB(233, 168, 188), Color3.fromRGB(110, 200, 241), Color3.new(1, 1, 1) }
function ColorUtils.lerpColors(seconds, index, colors)
    if #colors == 0 then return Color3.new(1, 1, 1) end
    local time = 10000 / seconds
    local angle = (tick() * 1000 + index) % time
    local segmentTime = time / #colors
    local segmentIndex = math.floor(angle / segmentTime)
    local segmentIndexFloat = angle / segmentTime - segmentIndex
    local startColor = colors[segmentIndex + 1]
    local endColor = colors[(segmentIndex + 1) % #colors + 1]
    return startColor:Lerp(endColor, segmentIndexFloat)
end
function ColorUtils.getThemedColor(index) return ColorUtils.lerpColors(3.0, index, ColorUtils.theme) end
function ColorUtils.rainbow(offset)
    local hue = (tick() * 0.15 + (offset or 0)) % 1
    return Color3.fromHSV(hue, 0.65, 1)
end

local Module = {}
Module.__index = Module
function Module.new(name, settingDisplay, enabled)
    local self = setmetatable({}, Module)
    self.name = name or ""
    self.englishName = MODULE_ENGLISH[name] or name or ""
    self.settingDisplay = settingDisplay or ""
    self.enabled = enabled or false
    self.visibleInArrayList = true
    self.arrayListAnim = 0
    return self
end
function Module:setState(state) self.enabled = state end

local Arraylist = {}
Arraylist.__index = Arraylist
Arraylist.Display = { Outline = 0, Bar = 1, Split = 2, None = 3 }
function Arraylist.new()
    local self = setmetatable({}, Arraylist)
    self.mModules = {}; self.mInitialized = false
    self.mDisplay = Arraylist.Display.Split; self.mGlow = true
    self.mGlowStrength = 1.9; self.mGlowDensity = 2
    self.mFontSize = 20.0; self.mTopOffset = -60.0; self.mRightOffset = 4.0
    self.mWatermarkText = "XUNHAN"; self.mVisible = true; self.mWatermarkVisible = true
    self.mCustomColor = Color3.fromRGB(110, 200, 241); self.mCustomColorEnabled = false
    self.mRainbow = false; self.mRainbowList = false; self.mRainbowWatermark = false
    self.mRainbowGlow = false; self.mRainbowText = false
    return self
end
function Arraylist:initModules() if self.mInitialized then return end self.mInitialized = true end
function Arraylist:setModuleState(name, setting, enabled)
    for _, mod in ipairs(self.mModules) do
        if mod.name == name then mod:setState(enabled) return end
    end
    local mod = Module.new(name, setting, enabled)
    mod.visibleInArrayList = true
    table.insert(self.mModules, mod)
end
function Arraylist:setGlow(v) self.mGlow = v end
function Arraylist:setGlowDensity(v) self.mGlowDensity = v end
function Arraylist:setGlowRadius(v) self.mGlowStrength = v end
function Arraylist:setRightOffset(v) self.mRightOffset = v end
function Arraylist:setTopOffset(v) self.mTopOffset = v end
function Arraylist:setDisplay(v) self.mDisplay = v end
function Arraylist:setWatermarkText(v) self.mWatermarkText = v end
function Arraylist:setFontSize(v) self.mFontSize = v end
function Arraylist:setVisible(v) self.mVisible = v end
function Arraylist:setWatermarkVisible(v) self.mWatermarkVisible = v end
function Arraylist:setCustomColor(c) self.mCustomColor = c end
function Arraylist:setCustomColorEnabled(v) self.mCustomColorEnabled = v end
function Arraylist:setRainbow(v) self.mRainbow = v end
function Arraylist:setRainbowList(v) self.mRainbowList = v end
function Arraylist:setRainbowWatermark(v) self.mRainbowWatermark = v end
function Arraylist:setRainbowGlow(v) self.mRainbowGlow = v end
function Arraylist:setRainbowText(v) self.mRainbowText = v end
function Arraylist:getColor(index, part)
    if part == "watermark" and self.mRainbowWatermark then return ColorUtils.rainbow(0) end
    if part == "glow" and self.mRainbowGlow then return ColorUtils.rainbow(index * 0.1) end
    if part == "text" and self.mRainbowText then return ColorUtils.rainbow(index * 0.1 + 0.6) end
    if self.mRainbowList or self.mRainbow then return ColorUtils.rainbow(index * 0.05) end
    if self.mCustomColorEnabled then return self.mCustomColor end
    return ColorUtils.getThemedColor(index * 100)
end

local Notifications = {}
Notifications.__index = Notifications
function Notifications.new()
    local self = setmetatable({}, Notifications)
    self.mShowOnToggle = true; self.mLimitNotifications = false
    self.mMaxNotifications = 6; self.mAnimSpeed = 1.0
    self.mHoldTime = 0.4; self.mYOffset = 0.20; self.mXOffset = -288
    self.mNotifications = {}; self.mNotificationUIs = {}
    return self
end
function Notifications:add(msg, ntype, duration)
    local notif = {
        msg = msg, ntype = ntype or 0, duration = duration or 3.0,
        timeShown = 0, currentDuration = 0, isTimeUp = false,
        holdStartTime = nil, hold = self.mHoldTime or 0.4,
        id = tick() .. math.random(),
    }
    table.insert(self.mNotifications, 1, notif)
    if self.mLimitNotifications and #self.mNotifications > self.mMaxNotifications then
        for i = self.mMaxNotifications + 1, #self.mNotifications do
            self.mNotifications[i].isTimeUp = true
        end
    end
    return notif
end

local SolsticeUI = {}
SolsticeUI.__index = SolsticeUI
function SolsticeUI.new()
    local self = setmetatable({}, SolsticeUI)
    self.arraylist = Arraylist.new()
    self.notifications = Notifications.new()
    self.initialized = false
    return self
end
function SolsticeUI:init() self.arraylist:initModules() self.initialized = true end
function SolsticeUI:notify(text, ntype, duration) self.notifications:add(text, ntype or 0, duration or 3.0) end
function SolsticeUI:setGlow(v) self.arraylist:setGlow(v) end
function SolsticeUI:setGlowDensity(v) self.arraylist:setGlowDensity(v) end
function SolsticeUI:setGlowRadius(v) self.arraylist:setGlowRadius(v) end
function SolsticeUI:setRightOffset(v) self.arraylist:setRightOffset(v) end
function SolsticeUI:setTopOffset(v) self.arraylist:setTopOffset(v) end
function SolsticeUI:setDisplay(v) self.arraylist:setDisplay(v) end
function SolsticeUI:setWatermarkText(v) self.arraylist:setWatermarkText(v) end
function SolsticeUI:setFontSize(v) self.arraylist:setFontSize(v) end
function SolsticeUI:setModuleState(name, mode, enabled) self.arraylist:setModuleState(name, mode, enabled) end

local Solstice = SolsticeUI.new()
Solstice:init()

local function notifyToggle(msg, ntype)
    if Solstice.notifications.mShowOnToggle then
        Solstice:notify(msg, ntype or 0, 2.0)
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Workspace = workspace

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XUNHAN_Arraylist"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = playerGui

local watermarkFrame = Instance.new("Frame")
watermarkFrame.Name = "Watermark"; watermarkFrame.BackgroundTransparency = 1
watermarkFrame.Size = UDim2.new(0, 400, 0, 40)
watermarkFrame.Position = UDim2.new(1, -410, 0, 0)
watermarkFrame.Parent = screenGui

local watermarkText = Instance.new("TextLabel")
watermarkText.Name = "Text"; watermarkText.BackgroundTransparency = 1
watermarkText.Size = UDim2.new(1, 0, 1, 0)
watermarkText.Font = Enum.Font.GothamBold; watermarkText.TextSize = 28
watermarkText.TextXAlignment = Enum.TextXAlignment.Right
watermarkText.TextYAlignment = Enum.TextYAlignment.Top
watermarkText.TextStrokeTransparency = 0.8
watermarkText.TextStrokeColor3 = Color3.new(0, 0, 0)
watermarkText.Parent = watermarkFrame

local arraylistFrame = Instance.new("Frame")
arraylistFrame.Name = "Arraylist"; arraylistFrame.BackgroundTransparency = 1
arraylistFrame.Size = UDim2.new(0, 400, 1, -60)
arraylistFrame.Position = UDim2.new(1, -(400 + Solstice.arraylist.mRightOffset), 0, Solstice.arraylist.mTopOffset + 40)
arraylistFrame.Parent = screenGui

local arraylistLayout = Instance.new("UIListLayout")
arraylistLayout.SortOrder = Enum.SortOrder.LayoutOrder
arraylistLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
arraylistLayout.VerticalAlignment = Enum.VerticalAlignment.Top
arraylistLayout.Padding = UDim.new(0, 2)
arraylistLayout.Parent = arraylistFrame

local notifFrame = Instance.new("Frame")
notifFrame.Name = "Notifications"; notifFrame.BackgroundTransparency = 1
notifFrame.Size = UDim2.new(0, 280, 0, 520)
notifFrame.Position = UDim2.new(1, -288, 0.20, -260)
notifFrame.ClipsDescendants = true
notifFrame.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 6)
notifLayout.Parent = notifFrame

local moduleUIs = {}

local function createModuleUI(modName, parentFrame)
    local container = Instance.new("Frame")
    container.Name = modName .. "_Container"
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel = 0; container.ClipsDescendants = true
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
    local outline = Instance.new("UIStroke", container)
    outline.Name = "Outline"; outline.Thickness = 1; outline.Transparency = 1
    local glow = Instance.new("UIStroke", container)
    glow.Name = "Glow"; glow.Thickness = 2; glow.Transparency = 1
    local label = Instance.new("TextLabel", container)
    label.Name = "Text"; label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -16, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.TextYAlignment = Enum.TextYAlignment.Center
    local bar = Instance.new("Frame", container)
    bar.Name = "Bar"; bar.BackgroundTransparency = 0
    bar.Size = UDim2.new(0, 3, 1, -4); bar.Position = UDim2.new(1, -6, 0.5, 0)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local padding = Instance.new("UIPadding", container)
    padding.PaddingLeft = UDim.new(0, 10); padding.PaddingRight = UDim.new(0, 10)
    return { container = container, bar = bar, outline = outline, glow = glow, label = label }
end

local activeModuleList = {}
local lastActiveKey = ""

local function refreshActiveModules()
    local al = Solstice.arraylist
    local newList = {}
    for i = 1, #al.mModules do
        local mod = al.mModules[i]
        if mod.arrayListAnim > 0.01 and mod.visibleInArrayList then
            newList[#newList + 1] = mod
        end
    end
    table.sort(newList, function(a, b) return #(a.englishName or a.name) > #(b.englishName or b.name) end)
    local key = ""
    for i = 1, #newList do key = key .. newList[i].name .. "|" end
    if key ~= lastActiveKey then activeModuleList = newList; lastActiveKey = key end
end

local function updateArraylist()
    local al = Solstice.arraylist
    if not al.mVisible then
        for _, ui in pairs(moduleUIs) do
            if ui.container.Visible then ui.container.Visible = false end
        end
        return
    end
    refreshActiveModules()
    local usedUIs = {}
    local baseFontSize = al.mFontSize; local displayMode = al.mDisplay
    local glow = al.mGlow; local glowDensity = al.mGlowDensity; local glowStrength = al.mGlowStrength
    local rowH = math.max(2, baseFontSize * 1.2)
    local barInsetY = math.max(2, baseFontSize * 0.2)
    for i = 1, #activeModuleList do
        local mod = activeModuleList[i]
        usedUIs[mod.name] = true
        local ui = moduleUIs[mod.name]
        if not ui then ui = createModuleUI(mod.name, arraylistFrame); moduleUIs[mod.name] = ui end
        local displayText = mod.englishName or mod.name
        if mod.settingDisplay ~= "" then displayText = displayText .. " " .. mod.settingDisplay end
        local colorList = al:getColor(i, "list")
        local colorText = al:getColor(i, "text")
        local colorGlow = al:getColor(i, "glow")
        local anim = mod.arrayListAnim
        ui.container.Size = UDim2.new(0, 0, 0, rowH * anim)
        ui.container.AutomaticSize = anim > 0.01 and Enum.AutomaticSize.X or Enum.AutomaticSize.None
        ui.container.BackgroundTransparency = 1 - (0.7 * anim)
        ui.container.Visible = anim > 0.01
        ui.container.LayoutOrder = i
        ui.label.Text = displayText; ui.label.TextSize = baseFontSize
        ui.label.TextColor3 = colorText; ui.label.TextStrokeTransparency = 1
        ui.bar.BackgroundColor3 = colorList
        ui.bar.Size = UDim2.new(0, 3, 1, -barInsetY * 2)
        if displayMode == Arraylist.Display.None then
            ui.bar.Visible = false; ui.outline.Transparency = 1; ui.glow.Transparency = 1
        elseif displayMode == Arraylist.Display.Bar then
            ui.bar.Visible = true; ui.outline.Transparency = 1; ui.glow.Transparency = 1
        elseif displayMode == Arraylist.Display.Outline then
            ui.bar.Visible = false
            ui.outline.Transparency = 1 - (0.6 * anim); ui.outline.Color = colorList
            ui.glow.Transparency = 1 - (glow and (0.5 * anim * (glowDensity / 5)) or 0)
            ui.glow.Color = colorGlow; ui.glow.Thickness = glowStrength
        elseif displayMode == Arraylist.Display.Split then
            ui.bar.Visible = true
            ui.outline.Transparency = 1 - (0.4 * anim); ui.outline.Color = colorList
            ui.glow.Transparency = 1 - (glow and (0.4 * anim * (glowDensity / 5)) or 0)
            ui.glow.Color = colorGlow; ui.glow.Thickness = glowStrength
        end
    end
    for name, ui in pairs(moduleUIs) do
        if not usedUIs[name] and ui.container.Visible then
            ui.container.Visible = false; ui.container.Size = UDim2.new(0, 0, 0, 0)
        end
    end
end

local function updateWatermark()
    local al = Solstice.arraylist
    if not al.mWatermarkVisible then
        if watermarkFrame.Visible then watermarkFrame.Visible = false end
        return
    end
    if not watermarkFrame.Visible then watermarkFrame.Visible = true end
    watermarkText.Text = al.mWatermarkText
    watermarkText.TextColor3 = al:getColor(0, "watermark")
    watermarkText.TextSize = al.mFontSize * 2
    watermarkFrame.Position = UDim2.new(1, -(400 + al.mRightOffset), 0, al.mTopOffset)
end

local function updateNotifications(dt)
    local notifs = Solstice.notifications
    local list = notifs.mNotifications
    if #list == 0 then return end
    local maxNotifs = notifs.mMaxNotifications; local limitEnabled = notifs.mLimitNotifications
    local animSpeedMul = notifs.mAnimSpeed
    for id, ui in pairs(notifs.mNotificationUIs) do
        local exists = false
        for i = 1, #list do if list[i].id == id then exists = true break end end
        if not exists then ui.wrapper:Destroy(); notifs.mNotificationUIs[id] = nil end
    end
    local activeCount = 0
    for i = 1, #list do
        local n = list[i]
        if limitEnabled and activeCount >= maxNotifs then n.isTimeUp = true end
        if n.isTimeUp and n.currentDuration <= 0.01 then continue end
        activeCount = activeCount + 1
        local ui = notifs.mNotificationUIs[n.id]
        if not ui then
            local wrapper = Instance.new("Frame")
            wrapper.Name = "NotifWrap_" .. n.id
            wrapper.BackgroundTransparency = 1
            wrapper.Size = UDim2.new(0, 260, 0, 0)
            wrapper.AutomaticSize = Enum.AutomaticSize.Y
            wrapper.Parent = notifFrame
            local container = Instance.new("Frame", wrapper)
            container.Name = "Card"; container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            container.BorderSizePixel = 0; container.Size = UDim2.new(1, 0, 1, 0)
            container.Position = UDim2.new(0, 260, 0, 0)
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", container)
            stroke.Thickness = 1.5
            local title = Instance.new("TextLabel", container)
            title.Name = "Title"; title.BackgroundTransparency = 1
            title.Size = UDim2.new(0, 244, 0, 22); title.Position = UDim2.new(0, 8, 0, 6)
            title.Font = Enum.Font.GothamBold; title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextWrapped = false; title.TextTruncate = Enum.TextTruncate.AtEnd
            local desc = Instance.new("TextLabel", container)
            desc.Name = "Desc"; desc.BackgroundTransparency = 1
            desc.Size = UDim2.new(0, 244, 0, 0); desc.Position = UDim2.new(0, 8, 0, 28)
            desc.Font = Enum.Font.Gotham; desc.TextSize = 12
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextWrapped = true; desc.TextTruncate = Enum.TextTruncate.AtEnd
            desc.AutomaticSize = Enum.AutomaticSize.Y
            local padding = Instance.new("UIPadding", container)
            padding.PaddingBottom = UDim.new(0, 8)
            ui = { wrapper = wrapper, container = container, stroke = stroke, title = title, desc = desc }
            notifs.mNotificationUIs[n.id] = ui
        end
        local color
        if n.ntype == 0 then color = Color3.fromRGB(100, 180, 255)
        elseif n.ntype == 1 then color = Color3.fromRGB(255, 200, 80)
        else color = Color3.fromRGB(255, 80, 80) end
        if not n.isTimeUp then
            local diff = 1 - n.currentDuration
            local speed = (0.10 + math.abs(diff) * 0.12) * animSpeedMul
            n.currentDuration = n.currentDuration + diff * math.min(speed * dt * 60, 1)
            if n.currentDuration >= 0.999 then
                n.currentDuration = 1
                if not n.holdStartTime then n.holdStartTime = tick() end
                if tick() - n.holdStartTime >= (n.hold or 0.4) then n.isTimeUp = true end
            end
        else
            local diff = 0 - n.currentDuration
            local speed = (0.10 + math.abs(diff) * 0.12) * animSpeedMul
            n.currentDuration = n.currentDuration + diff * math.min(speed * dt * 60, 1)
            if n.currentDuration < 0 then n.currentDuration = 0 end
        end
        local anim = n.currentDuration
        ui.container.Position = UDim2.new(0, (1 - anim) * 260, 0, 0)
        ui.container.BackgroundTransparency = 1 - (0.2 * anim)
        ui.stroke.Color = color; ui.stroke.Transparency = 1 - (0.5 * anim)
        ui.title.Text = n.ntype == 0 and "提示" or n.ntype == 1 and "警告" or "错误"
        ui.title.TextColor3 = color; ui.desc.Text = n.msg
        ui.desc.TextColor3 = Color3.fromRGB(220, 220, 220)
        ui.wrapper.LayoutOrder = #list - i + 1
        ui.wrapper.Visible = anim > 0.01
    end
end

local mrandom = math.random; local mcos = math.cos; local msin = math.sin
local clock = os.clock; local Vector3_new = Vector3.new
local Vector2_new = Vector2.new; local CFrame_new = CFrame.new
local CFrame_lookAt = CFrame.lookAt; local ZERO = Vector3.zero

local CONFIG = {
    FollowDistance = 1, FollowHeight = 0, FollowHiders = true, FollowPosition = "后面",
    TargetName = nil, FaceTarget = true, MultiTargets = {}, LockToDeath = false, LockIndex = 1,
    OrbitRadius = 1, OrbitSpeed = 2, OrbitHeight = 0,
    RandomDistance = 1, RandomHeight = 0, RandomDelay = 1,
    RandomOrbitRadius = 3, RandomOrbitSpeed = 2, RandomOrbitHeight = 0, RandomOrbitInterval = 1,
    RandomSpotDistance = 1, RandomSpotInterval = 1,
    LockSpotDistance = 1, LockSpotHeight = 0, LockSpotInterval = 1,
    TPSpeedEnabled = false, TPSpeedValue = 1,
    PredictBack = 4, PredictUp = 6, PredictMaxDist = 20, PredictExtraLead = 0.18, PredictHistoryMax = 10,
    PredictRandomInterval = 1,
}

local FOLLOW_KEYS = { "Follow", "Orbit", "RandomTeleport", "RandomOrbit", "RandomSpot", "LockSpot", "PredictLock", "PredictRandom" }

local function exclusiveOn(currentKey)
    for _, key in ipairs(FOLLOW_KEYS) do
        if key ~= currentKey then
            local t = Toggles[key]
            if t and t.Value then t:SetValue(false) end
        end
    end
end

local followConnection = nil; local orbitConnection = nil; local currentTarget = nil
local isFollowing = false; local isOrbiting = false; local orbitAngle = 0
local randomTpRunning = false; local randomTpTarget = nil; local randomTpNext = 0
local randomOrbitRunning = false; local randomOrbitTarget = nil
local randomOrbitAngle = 0; local randomOrbitNext = 0
local randomSpotRunning = false; local randomSpotTarget = nil
local randomSpotNext = 0; local randomSpotPosition = "后面"; local randomSpotPosTime = 0
local lockSpotRunning = false; local lockSpotTarget = nil; local tpSpeedConn = nil

local function IsPlayerSeeker(Player)
    local char = Player.Character
    if not char then return false end
    local bp = Player.Backpack
    if bp and bp:FindFirstChild("Knife") then return true end
    if char:FindFirstChild("Knife") then return true end
    return false
end

local function HasValidHRP(plr)
    if not plr or not plr.Parent then return false end
    local char = plr.Character
    if not char then return false end
    return char:FindFirstChild("HumanoidRootPart") ~= nil
end

local function isTargetDead(plr)
    if not plr or not plr.Parent then return true end
    local char = plr.Character
    if not char then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    if hum.Health <= 0 then return true end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return true end
    return false
end

local function getMultiNames()
    local raw = nil
    if Options.MultiTargets and Options.MultiTargets.Value ~= nil then raw = Options.MultiTargets.Value end
    if not raw then raw = CONFIG.MultiTargets end
    if type(raw) ~= "table" then return {} end
    local names = {}; local seen = {}
    for k, v in pairs(raw) do
        if type(k) == "string" and v == true and not seen[k] then
            names[#names + 1] = k; seen[k] = true
        elseif type(k) == "number" and type(v) == "string" and not seen[v] then
            names[#names + 1] = v; seen[v] = true
        elseif type(k) == "string" and type(v) == "string" and v == k and not seen[k] then
            names[#names + 1] = k; seen[k] = true
        elseif type(k) == "string" and type(v) == "table" and (v.enabled == true or v.Value == true) and not seen[k] then
            names[#names + 1] = k; seen[k] = true
        end
    end
    return names
end

local function pickRandomPlayer(filterFn)
    local count = 0; local chosen = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and HasValidHRP(plr) then
            if not filterFn or filterFn(plr) then
                count = count + 1
                if mrandom(count) == 1 then chosen = plr end
            end
        end
    end
    return chosen
end

local function namesToPlayers(names)
    local list = {}
    for _, name in ipairs(names) do
        local p = Players:FindFirstChild(name)
        if not p then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == name or plr.DisplayName == name then p = plr break end
            end
        end
        if p and p ~= player and HasValidHRP(p) and not isTargetDead(p) then
            list[#list + 1] = p
        end
    end
    return list
end

local function pickRandomFromMulti()
    local names = getMultiNames()
    if #names == 0 then return nil end
    local candidates = namesToPlayers(names)
    if #candidates == 0 then return nil end
    return candidates[mrandom(1, #candidates)]
end

local function pickOrderedFromMulti()
    local names = getMultiNames()
    if #names == 0 then return nil end
    local ordered = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        for _, name in ipairs(names) do
            if (plr.Name == name or plr.DisplayName == name)
               and plr ~= player and HasValidHRP(plr) and not isTargetDead(plr) then
                ordered[#ordered + 1] = plr; break
            end
        end
    end
    if #ordered == 0 then return nil end
    local idx = ((CONFIG.LockIndex - 1) % #ordered) + 1
    CONFIG.LockIndex = CONFIG.LockIndex + 1
    return ordered[idx]
end

local function getTargetRight()
    local names = getMultiNames()
    if #names > 0 then
        if CONFIG.LockToDeath then return pickOrderedFromMulti()
        else return pickRandomFromMulti() end
    end
    if CONFIG.FollowHiders then return pickRandomPlayer(function(p) return not IsPlayerSeeker(p) end)
    else return pickRandomPlayer(nil) end
end

local function getTarget()
    if CONFIG.TargetName and CONFIG.TargetName ~= "" then
        local targetName = tostring(CONFIG.TargetName)
        local p = Players:FindFirstChild(targetName)
        if not p then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == targetName or plr.DisplayName == targetName then p = plr break end
            end
        end
        if p and HasValidHRP(p) and not isTargetDead(p) then return p end
        Solstice:notify("指定玩家 " .. targetName .. " 不可用，改用随机", 1, 2.0)
        CONFIG.TargetName = nil
    end
    if CONFIG.FollowHiders then return pickRandomPlayer(function(p) return not IsPlayerSeeker(p) end)
    else return pickRandomPlayer(nil) end
end

local function refreshTarget(currentT, nextSwitchTime, interval)
    if CONFIG.LockToDeath then
        if not currentT or isTargetDead(currentT) then return pickOrderedFromMulti(), clock() + interval end
        return currentT, nextSwitchTime
    else
        if not currentT or isTargetDead(currentT) then return getTargetRight(), clock() + interval end
        if clock() >= nextSwitchTime then return getTargetRight(), clock() + interval end
        return currentT, nextSwitchTime
    end
end

local function getOffsetPosition()
    local d = CONFIG.FollowDistance; local h = CONFIG.FollowHeight; local p = CONFIG.FollowPosition
    if p == "前面" then return Vector3_new(0, h, -d)
    elseif p == "后面" then return Vector3_new(0, h, d)
    elseif p == "头顶" then return Vector3_new(0.001, d + h, 0.001)
    elseif p == "下面" then return Vector3_new(0.001, -(d + math.abs(h)), 0.001)
    elseif p == "左面" then return Vector3_new(-d, h, 0)
    elseif p == "右面" then return Vector3_new(d, h, 0)
    else return Vector3_new(0, h, d) end
end

local function getFollowCFrame(targetHRP)
    local offset = getOffsetPosition()
    local myPos = targetHRP.CFrame:PointToWorldSpace(offset)
    local targetPos = targetHRP.Position
    local p = CONFIG.FollowPosition
    if not CONFIG.FaceTarget then return CFrame_new(myPos) * (targetHRP.CFrame - targetHRP.CFrame.Position) end
    if p == "头顶" then return CFrame_new(myPos, myPos + Vector3_new(0, -1, 0.001))
    elseif p == "下面" then return CFrame_new(myPos, myPos + Vector3_new(0, 1, 0.001))
    else return CFrame_lookAt(myPos, targetPos) end
end

local function getBehindCFrame(targetHRP, distance, height)
    local h = height or 0
    local myPos = targetHRP.CFrame:PointToWorldSpace(Vector3_new(0, h, distance))
    return CFrame_lookAt(myPos, targetHRP.Position)
end

local predictHistory = {}

local function getPing()
    local ok, ping = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and ping and ping > 0 then return ping end
    return 100
end

local function recordPredict(hrp)
    if not hrp then return end
    local now = tick()
    table.insert(predictHistory, { time = now, pos = hrp.Position, cframe = hrp.CFrame })
    while #predictHistory > CONFIG.PredictHistoryMax do
        table.remove(predictHistory, 1)
    end
end

local function clearPredict() predictHistory = {} end

local function getPredictCFrame(targetHRP, distance, height)
    local h = height or 0
    local d = distance or CONFIG.PredictBack
    if #predictHistory < 2 then return getBehindCFrame(targetHRP, d, h) end

    local ping = getPing()
    local predictTime = ping / 1000 + CONFIG.PredictExtraLead
    local avgVel = Vector3_new(0, 0, 0)
    local totalAngle, totalDt, count = 0, 0, 0

    for i = 2, #predictHistory do
        local h1 = predictHistory[i-1]; local h2 = predictHistory[i]
        local dt = h2.time - h1.time
        if dt > 0.001 then
            avgVel = avgVel + (h2.pos - h1.pos) / dt
            local l1 = h1.cframe.LookVector; local l2 = h2.cframe.LookVector
            local cross = l1:Cross(l2); local dot = l1:Dot(l2)
            local angle = math.atan2(cross.Magnitude, dot)
            if dot < 0 then angle = math.pi - angle end
            totalAngle = totalAngle + angle; totalDt = totalDt + dt; count = count + 1
        end
    end
    if count > 0 then avgVel = avgVel / count end

    local dirChange, speedChange = 0, 0
    if #predictHistory >= 3 then
        local seg1 = predictHistory[#predictHistory-1].pos - predictHistory[#predictHistory-2].pos
        local seg2 = predictHistory[#predictHistory].pos - predictHistory[#predictHistory-1].pos
        if seg1.Magnitude > 0.01 and seg2.Magnitude > 0.01 then
            dirChange = 1 - math.abs(seg1.Unit:Dot(seg2.Unit))
        end
        if seg1.Magnitude > 0.1 then speedChange = math.abs(seg2.Magnitude - seg1.Magnitude) / seg1.Magnitude end
    end

    local penalty = math.min(1, dirChange * 0.8 + speedChange * 0.4)
    local coeff = 1 - penalty * 0.6
    local last = predictHistory[#predictHistory]
    local predPos = last.pos + avgVel * predictTime * coeff
    if (predPos - last.pos).Magnitude > CONFIG.PredictMaxDist then
        predPos = last.pos + (predPos - last.pos).Unit * CONFIG.PredictMaxDist
    end

    local predLook = last.cframe.LookVector
    local avgAngleSpeed = 0
    if totalDt > 0.001 then avgAngleSpeed = totalAngle / totalDt end
    if avgAngleSpeed ~= 0 then
        local rotAngle = avgAngleSpeed * predictTime
        local up = Vector3_new(0, 1, 0)
        local axis = predLook:Cross(up)
        if axis.Magnitude < 0.001 then axis = Vector3_new(1, 0, 0) end
        local angleCF = CFrame.fromAxisAngle(axis.Unit, rotAngle)
        predLook = angleCF:VectorToWorldSpace(predLook)
    end

    local behindPos = predPos - predLook * d + Vector3_new(0, h + CONFIG.PredictUp, 0)
    return CFrame_lookAt(behindPos, predPos)
end

local function clearMyVelocity()
    local myChar = player.Character
    if myChar then
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if myHRP then
            myHRP.AssemblyLinearVelocity = ZERO
            myHRP.AssemblyAngularVelocity = ZERO
        end
        if hum then hum.AutoRotate = true end
    end
end

local function stopFollowing() if not isFollowing then return end isFollowing = false currentTarget = nil followConnection = nil clearMyVelocity() end
local function stopOrbit() if orbitConnection then orbitConnection:Disconnect() orbitConnection = nil end if not isOrbiting then return end isOrbiting = false clearMyVelocity() end
local function stopRandomTeleport() randomTpRunning = false randomTpTarget = nil clearMyVelocity() end
local function stopRandomOrbit() randomOrbitRunning = false randomOrbitTarget = nil clearMyVelocity() end
local function stopRandomSpot() randomSpotRunning = false randomSpotTarget = nil clearMyVelocity() end
local function stopLockSpot() lockSpotRunning = false lockSpotTarget = nil clearMyVelocity() end

local predictLockRunning = false
local predictLockTarget = nil
local predictRandomRunning = false
local predictRandomTarget = nil
local predictRandomNext = 0

local function stopPredictLock()
    predictLockRunning = false
    clearPredict()
    clearMyVelocity()
end

local function stopPredictRandom()
    predictRandomRunning = false
    predictRandomTarget = nil
    predictRandomNext = 0
    clearPredict()
    clearMyVelocity()
end

local function killOthers(except)
    if except ~= "follow" and isFollowing then stopFollowing() end
    if except ~= "orbit" and isOrbiting then stopOrbit() end
    if except ~= "randomTp" and randomTpRunning then stopRandomTeleport() end
    if except ~= "randomOrbit" and randomOrbitRunning then stopRandomOrbit() end
    if except ~= "randomSpot" and randomSpotRunning then stopRandomSpot() end
    if except ~= "lockSpot" and lockSpotRunning then stopLockSpot() end
    if except ~= "predictLock" and predictLockRunning then stopPredictLock() end
    if except ~= "predictRandom" and predictRandomRunning then stopPredictRandom() end
end

local function startPredictLock()
    killOthers("predictLock")
    local oldName = predictLockTarget and predictLockTarget.Name or nil
    local target = nil

    if CONFIG.TargetName and CONFIG.TargetName ~= "" then
        local p = Players:FindFirstChild(CONFIG.TargetName)
        if not p then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name == CONFIG.TargetName or plr.DisplayName == CONFIG.TargetName then p = plr break end
            end
        end
        if p and p ~= player and HasValidHRP(p) then target = p end
    end

    if not target then
        local candidates = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and HasValidHRP(plr) and plr.Name ~= oldName then
                candidates[#candidates + 1] = plr
            end
        end
        if #candidates == 0 then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and HasValidHRP(plr) then candidates[#candidates + 1] = plr end
            end
        end
        if #candidates > 0 then target = candidates[mrandom(1, #candidates)] end
    end

    if not target then
        Solstice:notify("未找到可预判的目标！", 1, 2.0)
        Solstice:setModuleState("预判锁定", "", false)
        if Toggles["PredictLock"] then pcall(function() Toggles["PredictLock"]:SetValue(false) end) end
        return
    end

    predictLockTarget = target
    predictLockRunning = true
    clearPredict()

    task.spawn(function()
        while predictLockRunning do
            task.wait(0.01)
            if not predictLockRunning then break end

            if not predictLockTarget or not predictLockTarget.Parent then
                if CONFIG.TargetName and CONFIG.TargetName ~= "" then
                    stopPredictLock()
                    Solstice:setModuleState("预判锁定", "", false)
                    if Toggles["PredictLock"] then pcall(function() Toggles["PredictLock"]:SetValue(false) end) end
                    Solstice:notify("指定玩家已退服，预判已自动关闭", 1, 3.0)
                    break
                end

                local old = predictLockTarget and predictLockTarget.Name or nil
                local candidates = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and HasValidHRP(plr) and plr.Name ~= old then
                        candidates[#candidates + 1] = plr
                    end
                end
                if #candidates == 0 then
                    stopPredictLock()
                    Solstice:setModuleState("预判锁定", "", false)
                    if Toggles["PredictLock"] then pcall(function() Toggles["PredictLock"]:SetValue(false) end) end
                    break
                end
                predictLockTarget = candidates[mrandom(1, #candidates)]
                clearPredict()
            end

            local char = predictLockTarget.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                recordPredict(targetHRP)
                myHRP.CFrame = getPredictCFrame(targetHRP, CONFIG.PredictBack, 0)
            end
        end
    end)
end

local function startPredictRandom()
    killOthers("predictRandom")

    local function pickRandomTarget(skipName)
        local names = getMultiNames()
        local candidates = {}
        if #names > 0 then
            for _, plr in ipairs(Players:GetPlayers()) do
                for _, name in ipairs(names) do
                    if (plr.Name == name or plr.DisplayName == name)
                       and plr ~= player and HasValidHRP(plr)
                       and plr.Name ~= skipName then
                        candidates[#candidates + 1] = plr; break
                    end
                end
            end
        end
        if #candidates == 0 then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and HasValidHRP(plr) and plr.Name ~= skipName then
                    candidates[#candidates + 1] = plr
                end
            end
        end
        if #candidates == 0 then return nil end
        return candidates[mrandom(1, #candidates)]
    end

    local target = pickRandomTarget(nil)
    if not target then
        Solstice:notify("未找到可预判的目标！", 1, 2.0)
        Solstice:setModuleState("预判随机", "", false)
        if Toggles["PredictRandom"] then pcall(function() Toggles["PredictRandom"]:SetValue(false) end) end
        return
    end

    predictRandomTarget = target
    predictRandomRunning = true
    predictRandomNext = clock() + CONFIG.PredictRandomInterval
    clearPredict()

    task.spawn(function()
        while predictRandomRunning do
            task.wait(0.01)
            if not predictRandomRunning then break end

            local needSwitch = false
            local targetGone = (not predictRandomTarget) or (not predictRandomTarget.Parent)

            if targetGone then
                needSwitch = true
            elseif CONFIG.LockToDeath then
                if isTargetDead(predictRandomTarget) then needSwitch = true end
            else
                if clock() >= predictRandomNext then needSwitch = true end
            end

            if needSwitch then
                local old = predictRandomTarget and predictRandomTarget.Name or nil
                local nextT = pickRandomTarget(old)
                if not nextT then
                    stopPredictRandom()
                    Solstice:setModuleState("预判随机", "", false)
                    if Toggles["PredictRandom"] then pcall(function() Toggles["PredictRandom"]:SetValue(false) end) end
                    break
                end
                predictRandomTarget = nextT
                predictRandomNext = clock() + CONFIG.PredictRandomInterval
                clearPredict()
            end

            local char = predictRandomTarget.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                recordPredict(targetHRP)
                myHRP.CFrame = getPredictCFrame(targetHRP, CONFIG.PredictBack, 0)
            end
        end
    end)
end
local function startFollowing()
    killOthers("follow")
    local target = getTarget()
    if not target then
        Solstice:notify("未找到可依附的目标！", 1, 2.0)
        Solstice:setModuleState("依附", "", false)
        if Toggles["Follow"] then pcall(function() Toggles["Follow"]:SetValue(false) end) end
        return
    end
    currentTarget = target
    isFollowing = true
    task.spawn(function()
        while isFollowing do
            task.wait(0.01)
            if not isFollowing then break end
            local t = currentTarget
            if not t or not t.Parent then
                stopFollowing()
                Solstice:setModuleState("依附", "", false)
                if Toggles["Follow"] then pcall(function() Toggles["Follow"]:SetValue(false) end) end
                break
            end
            local char = t.Character
            if not char then continue end
            local targetHRP = char:FindFirstChild("HumanoidRootPart")
            if not targetHRP then continue end
            local myChar = player.Character
            if not myChar then continue end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            myHRP.CFrame = getFollowCFrame(targetHRP)
        end
    end)
end

local function startOrbit()
    killOthers("orbit")
    local target = getTarget()
    if not target then
        Solstice:notify("未找到可环绕的目标！", 1, 2.0)
        Solstice:setModuleState("环绕", "", false)
        if Toggles["Orbit"] then pcall(function() Toggles["Orbit"]:SetValue(false) end) end
        return
    end
    currentTarget = target
    isOrbiting = true
    orbitAngle = 0
    orbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not isOrbiting then return end
        local t = currentTarget
        if not t or not t.Parent then
            stopOrbit()
            Solstice:setModuleState("环绕", "", false)
            if Toggles["Orbit"] then pcall(function() Toggles["Orbit"]:SetValue(false) end) end
            return
        end
        local char = t.Character
        if not char then return end
        local targetHRP = char:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local myChar = player.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        orbitAngle = orbitAngle + dt * CONFIG.OrbitSpeed
        local radius = CONFIG.OrbitRadius
        local x = mcos(orbitAngle) * radius
        local z = msin(orbitAngle) * radius
        local y = CONFIG.OrbitHeight
        local myPos = targetHRP.Position + Vector3_new(x, y, z)
        myHRP.CFrame = CFrame_lookAt(myPos, targetHRP.Position)
    end)
end

local function startRandomTeleport()
    killOthers("randomTp")
    randomTpRunning = true
    randomTpTarget = nil
    randomTpNext = 0
    task.spawn(function()
        while randomTpRunning do
            task.wait(0.01)
            if not randomTpRunning then break end
            randomTpTarget, randomTpNext = refreshTarget(randomTpTarget, randomTpNext, CONFIG.RandomDelay)
            local t = randomTpTarget
            if t then
                local char = t.Character
                local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    myHRP.CFrame = getBehindCFrame(targetHRP, CONFIG.RandomDistance, CONFIG.RandomHeight)
                end
            end
        end
    end)
end

local function startRandomOrbit()
    killOthers("randomOrbit")
    randomOrbitTarget = nil
    randomOrbitAngle = 0
    randomOrbitNext = 0
    randomOrbitRunning = true
    task.spawn(function()
        while randomOrbitRunning do
            task.wait(0.01)
            if not randomOrbitRunning then break end
            randomOrbitTarget, randomOrbitNext = refreshTarget(randomOrbitTarget, randomOrbitNext, CONFIG.RandomOrbitInterval)
            if not randomOrbitTarget then
                stopRandomOrbit()
                Solstice:setModuleState("随机环绕", "", false)
                if Toggles["RandomOrbit"] then pcall(function() Toggles["RandomOrbit"]:SetValue(false) end) end
                break
            end
            randomOrbitAngle = randomOrbitAngle + 0.01 * CONFIG.RandomOrbitSpeed
            local char = randomOrbitTarget.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                local radius = CONFIG.RandomOrbitRadius
                local x = mcos(randomOrbitAngle) * radius
                local z = msin(randomOrbitAngle) * radius
                local y = CONFIG.RandomOrbitHeight
                local myPos = targetHRP.Position + Vector3_new(x, y, z)
                myHRP.CFrame = CFrame_lookAt(myPos, targetHRP.Position)
            end
        end
    end)
end

local function startRandomSpot()
    killOthers("randomSpot")
    randomSpotTarget = nil
    randomSpotNext = 0
    randomSpotPosition = "后面"
    randomSpotPosTime = 0
    randomSpotRunning = true
    task.spawn(function()
        while randomSpotRunning do
            task.wait(0.01)
            if not randomSpotRunning then break end
            randomSpotTarget, randomSpotNext = refreshTarget(randomSpotTarget, randomSpotNext, CONFIG.RandomSpotInterval)
            if not randomSpotTarget then
                stopRandomSpot()
                Solstice:setModuleState("随机传送", "", false)
                if Toggles["RandomSpot"] then pcall(function() Toggles["RandomSpot"]:SetValue(false) end) end
                break
            end
            if clock() >= randomSpotPosTime then
                local spots = { "前面", "后面", "头顶", "下面", "左面", "右面" }
                randomSpotPosition = spots[mrandom(1, #spots)]
                randomSpotPosTime = clock() + CONFIG.RandomSpotInterval
            end
            local char = randomSpotTarget.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                local d = CONFIG.RandomSpotDistance
                local p = randomSpotPosition
                local offset
                if p == "前面" then offset = Vector3_new(0, 0, -d)
                elseif p == "后面" then offset = Vector3_new(0, 0, d)
                elseif p == "头顶" then offset = Vector3_new(0.001, d, 0.001)
                elseif p == "下面" then offset = Vector3_new(0.001, -d, 0.001)
                elseif p == "左面" then offset = Vector3_new(-d, 0, 0)
                elseif p == "右面" then offset = Vector3_new(d, 0, 0)
                else offset = Vector3_new(0, 0, d) end
                local myPos = targetHRP.CFrame:PointToWorldSpace(offset)
                myHRP.CFrame = CFrame_lookAt(myPos, targetHRP.Position)
            end
        end
    end)
end

local function startLockSpot()
    killOthers("lockSpot")
    lockSpotTarget = getTarget()
    if lockSpotTarget and isTargetDead(lockSpotTarget) then lockSpotTarget = nil end
    if not lockSpotTarget then
        Solstice:notify("未找到可传送的目标！", 1, 2.0)
        Solstice:setModuleState("锁定传送", "", false)
        if Toggles["LockSpot"] then pcall(function() Toggles["LockSpot"]:SetValue(false) end) end
        return
    end
    lockSpotRunning = true
    local lockSpotNext = 0
    local lockSpotRandomPos = "后面"
    task.spawn(function()
        while lockSpotRunning do
            task.wait(0.01)
            if not lockSpotRunning then break end
            if not lockSpotTarget or isTargetDead(lockSpotTarget) then
                lockSpotTarget = getTarget()
                if not lockSpotTarget then
                    stopLockSpot()
                    Solstice:setModuleState("锁定传送", "", false)
                    if Toggles["LockSpot"] then pcall(function() Toggles["LockSpot"]:SetValue(false) end) end
                    break
                end
                lockSpotNext = 0
            end
            local now = clock()
            if now >= lockSpotNext then
                local spots = { "前面", "后面", "头顶", "下面", "左面", "右面" }
                lockSpotRandomPos = spots[mrandom(1, #spots)]
                lockSpotNext = now + CONFIG.LockSpotInterval
            end
            local char = lockSpotTarget.Character
            local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
            local myChar = player.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                local d = CONFIG.LockSpotDistance
                local h = CONFIG.LockSpotHeight
                local p = lockSpotRandomPos
                local offset
                if p == "前面" then offset = Vector3_new(0, h, -d)
                elseif p == "后面" then offset = Vector3_new(0, h, d)
                elseif p == "头顶" then offset = Vector3_new(0.001, d + h, 0.001)
                elseif p == "下面" then offset = Vector3_new(0.001, -(d + math.abs(h)), 0.001)
                elseif p == "左面" then offset = Vector3_new(-d, h, 0)
                elseif p == "右面" then offset = Vector3_new(d, h, 0)
                else offset = Vector3_new(0, h, d) end
                local myPos = targetHRP.CFrame:PointToWorldSpace(offset)
                local lookAt
                if p == "头顶" then lookAt = myPos + Vector3_new(0, -1, 0.001)
                elseif p == "下面" then lookAt = myPos + Vector3_new(0, 1, 0.001)
                else lookAt = targetHRP.Position end
                myHRP.CFrame = CFrame_lookAt(myPos, lookAt)
            end
        end
    end)
end

-- ============================================================
-- 自动普攻 / 技能 / 躲技能 / 飞行 / 防甩飞 / TPSpeed
-- ============================================================
local A1 = game:GetService("Players")
local A2 = A1.LocalPlayer
local A6 = game:GetService("UserInputService")
local A8 = workspace

local skillUsage = { firstskill = 0, secondskill = 0, thirdskill = 0, fourthskill = 0 }
local skills = {
    firstskill = {"Normal Punch", "Flowing Water", "Machine Gun Blows", "Flash Strike", "Homerun", "Quick Slice", "Bullet Barrage", "Crushing Pull"},
    secondskill = {"Atmos Cleave", "Windstorm Fury", "Ignition Burst", "Whirlwind Kick", "Beatdown", "Consecutive Punches", "Lethal Whirlwind Stream", "Vanishing Kick"},
    thirdskill = {"Shove", "Hunter's Grasp", "Blitz Shot", "Scatter", "Grand Slam", "Pinpoint Cut", "Stone Coffin", "Whirlwind Drop"},
    fourthskill = {"Split Second Counter", "Expulsive Push", "Jet Dive", "Explosive Shuriken", "Foul Ball", "Uppercut", "Head First", "Prey's Peril"}
}
local skillCooldowns = {}
for _, list in pairs(skills) do
    for _, s in ipairs(list) do skillCooldowns[s] = 0 end
end

local useFirstSkill, useSecondSkill, useThirdSkill, useFourthSkill = false, false, false, false

local function equipAndUseSkill(plr, skillType)
    local character = plr.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local backpack = plr.Backpack
    if not backpack then return end
    for _, skill in pairs(skills[skillType]) do
        local tool = backpack:FindFirstChild(skill) or character:FindFirstChild(skill)
        if tool then
            pcall(function() humanoid:EquipTool(tool) end)
            local communicate = character:FindFirstChild("Communicate")
            if communicate then
                local args = { [1] = { ["Mobile"] = true, ["Goal"] = "LeftClick", ["MousePos"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1) } }
                pcall(function() communicate:FireServer(unpack(args)) end)
                task.wait(0.02)
                local argsRelease = { [1] = { ["Goal"] = "LeftClickRelease", ["Mobile"] = true } }
                pcall(function() communicate:FireServer(unpack(argsRelease)) end)
            end
            pcall(function() humanoid:UnequipTools() end)
            if skillCooldowns[skill] then
                skillUsage[skillType] = tick()
                task.wait(skillCooldowns[skill])
            end
        end
    end
end

local function skillLoop()
    local p = game:GetService("Players").LocalPlayer
    while true do
        wait(0.1)
        local currentTime = tick()
        if useFirstSkill and (currentTime - skillUsage["firstskill"] >= skillCooldowns[skills.firstskill[1]]) then
            coroutine.wrap(equipAndUseSkill)(p, "firstskill") skillUsage["firstskill"] = currentTime
        end
        if useSecondSkill and (currentTime - skillUsage["secondskill"] >= skillCooldowns[skills.secondskill[1]]) then
            coroutine.wrap(equipAndUseSkill)(p, "secondskill") skillUsage["secondskill"] = currentTime
        end
        if useThirdSkill and (currentTime - skillUsage["thirdskill"] >= skillCooldowns[skills.thirdskill[1]]) then
            coroutine.wrap(equipAndUseSkill)(p, "thirdskill") skillUsage["thirdskill"] = currentTime
        end
        if useFourthSkill and (currentTime - skillUsage["fourthskill"] >= skillCooldowns[skills.fourthskill[1]]) then
            coroutine.wrap(equipAndUseSkill)(p, "fourthskill") skillUsage["fourthskill"] = currentTime
        end
    end
end
coroutine.wrap(skillLoop)()

local AutoDodging = false
local AutoDodgeConn = nil
local function startAutoDodge()
    if AutoDodgeConn then AutoDodgeConn:Disconnect() AutoDodgeConn = nil end
    local Animations = { 10479335397, 13380255751, 10468665991, 12272894215, 12534735382, 13376869471, 14004235777, 14003607057, 15290930205, 16139108718, 16139402582 }
    AutoDodgeConn = RunService.RenderStepped:Connect(function()
        if not AutoDodging then return end
        pcall(function()
            local myChar = A2.Character
            if not myChar or not myChar:FindFirstChild("Head") then return end
            for _, k in ipairs(workspace.Live:GetChildren()) do
                if k:IsA("Model") and k:FindFirstChild("Head") and k.Head:IsA("Part") and k.Head.Name == "Head" and k.Head ~= myChar.Head then
                    if (k.Head.Position - myChar.Head.Position).magnitude <= 25 then
                        local hum = k:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local isAttacking = false
                            for _, x in pairs(hum:GetPlayingAnimationTracks()) do
                                local animId = x.Animation.AnimationId:match("%d+")
                                if animId and table.find(Animations, tonumber(animId)) then isAttacking = true break end
                            end
                            if k:FindFirstChild("M1ing") or isAttacking then
                                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.CFrame = CFrame.new(k.Head.Position + k.Head.CFrame.lookVector * -20 + Vector3.new(0, 35, 0), k.Head.Position) end
                            end
                        end
                    end
                end
            end
        end)
    end)
end
local function stopAutoDodge() if AutoDodgeConn then AutoDodgeConn:Disconnect() AutoDodgeConn = nil end end

local function startTPSpeed()
    if tpSpeedConn then tpSpeedConn:Disconnect() tpSpeedConn = nil end
    tpSpeedConn = RunService.Heartbeat:Connect(function()
        if not CONFIG.TPSpeedEnabled then return end
        local char = A2.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local speed = CONFIG.TPSpeedValue
        if speed <= 16 then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local perFrame = (speed - 16) / 60
            hrp.CFrame = hrp.CFrame + moveDir * perFrame
        end
    end)
end
local function stopTPSpeed() if tpSpeedConn then tpSpeedConn:Disconnect() tpSpeedConn = nil end end

local FlyingEnabled, SpinningEnabled = false, false
local FlightSpeed, SpinSpeed = 50, 5
local CurrentAO, CurrentLV, CurrentMoverAttachment, FlightConnection
local Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local Camera = workspace.CurrentCamera

local function getControlModule()
    local PlayerModule = A2:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
    return require(PlayerModule:WaitForChild("ControlModule"))
end

local function setupBodyMovers(character)
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local moverParent = workspace:FindFirstChildOfClass("Terrain") or workspace
    local moverAttachment = Instance.new("Attachment", hrp)
    moverAttachment.Name = "FlightAttachment"
    local alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.RigidityEnabled = true
    alignOrientation.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    alignOrientation.CFrame = hrp.CFrame
    alignOrientation.Attachment0 = moverAttachment
    alignOrientation.Parent = moverParent
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.VectorVelocity = Vector3.zero
    linearVelocity.MaxForce = 9e9
    linearVelocity.Attachment0 = moverAttachment
    linearVelocity.Parent = moverParent
    return alignOrientation, linearVelocity, humanoid, moverAttachment
end

local function getFlightVector(controlModule)
    local moveVector = controlModule:GetMoveVector()
    Control.F = -moveVector.Z; Control.B = moveVector.Z
    Control.L = -moveVector.X; Control.R = moveVector.X
    Control.Q = moveVector.Y; Control.E = -moveVector.Y
    if A6:IsKeyDown(Enum.KeyCode.W) then Control.F = 1 end
    if A6:IsKeyDown(Enum.KeyCode.S) then Control.B = 1 end
    if A6:IsKeyDown(Enum.KeyCode.A) then Control.L = 1 end
    if A6:IsKeyDown(Enum.KeyCode.D) then Control.R = 1 end
    if A6:IsKeyDown(Enum.KeyCode.Space) then Control.Q = 1 end
    if A6:IsKeyDown(Enum.KeyCode.LeftControl) then Control.E = 1 end
    local fv = Camera.CFrame.LookVector * (Control.F - Control.B)
        + Camera.CFrame.RightVector * (Control.R - Control.L)
        + Vector3.new(0, 1, 0) * (Control.Q - Control.E)
    return fv.Magnitude > 0 and fv.Unit or fv
end

local function startFlying()
    if FlyingEnabled then return end
    local character = A2.Character or A2.CharacterAdded:Wait()
    if not character then return end
    FlyingEnabled = true
    SpinningEnabled = false
    if CurrentAO then CurrentAO:Destroy() end
    if CurrentLV then CurrentLV:Destroy() end
    if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
    CurrentAO, CurrentLV, humanoid, CurrentMoverAttachment = setupBodyMovers(character)
    local controlModule = getControlModule()
    FlightConnection = RunService.Heartbeat:Connect(function()
        if not FlyingEnabled or not CurrentLV or not CurrentAO then return end
        local fv = getFlightVector(controlModule)
        if fv.Magnitude > 0 then
            CurrentLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            CurrentLV.VectorVelocity = fv * FlightSpeed
        else
            CurrentLV.VectorVelocity = Vector3.zero
        end
        if SpinningEnabled then
            local targetPart = humanoid.SeatPart or character.HumanoidRootPart
            CurrentAO.CFrame = targetPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        else
            CurrentAO.CFrame = Camera.CFrame
        end
        humanoid.PlatformStand = true
    end)
    character.AncestryChanged:Connect(function(_, parent)
        if not parent and FlyingEnabled then stopFlying() end
    end)
end

local function stopFlying()
    if not FlyingEnabled then return end
    FlyingEnabled = false
    SpinningEnabled = false
    if FlightConnection then FlightConnection:Disconnect() FlightConnection = nil end
    if CurrentAO then CurrentAO:Destroy() end
    if CurrentLV then CurrentLV:Destroy() end
    if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
    local character = A2.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = false
    end
end

local AntiFlingConn = nil
local function startAntiFling()
    if AntiFlingConn then AntiFlingConn:Disconnect() AntiFlingConn = nil end
    AntiFlingConn = RunService.Heartbeat:Connect(function()
        local myChar = A2.Character
        if not myChar then return end
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.AssemblyLinearVelocity = Vector3.new()
        hrp.AssemblyAngularVelocity = Vector3.new()
        hrp.Velocity = Vector3.new()
        hrp.RotVelocity = Vector3.new()
    end)
end
local function stopAntiFling() if AntiFlingConn then AntiFlingConn:Disconnect() AntiFlingConn = nil end end

-- ============================================================
-- ESP 模块
-- ============================================================
local ESPPlayers = {}
local ESPRunning = false
local ESPConnection = nil
local ESPConfig = {
    Enabled = false, Box3D = true, Health = true, TeamCheck = false, Rainbow = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxColorEnemy = Color3.fromRGB(255, 60, 60),
    BoxColorTeam = Color3.fromRGB(60, 255, 60),
    BoxThickness = 1, MaxDistance = 1000,
}

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "XUNHAN_ESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESPGui.Parent = playerGui

local function createDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function getCharacterParts(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    return char, hrp, hum
end

local function isTeammate(plr) return plr.Team ~= nil and plr.Team == player.Team end

local function getBoxColor(plr)
    if ESPConfig.Rainbow then return ColorUtils.rainbow(0) end
    if ESPConfig.TeamCheck and isTeammate(plr) then return ESPConfig.BoxColorTeam
    elseif ESPConfig.TeamCheck then return ESPConfig.BoxColorEnemy end
    return ESPConfig.BoxColor
end

local function lerpColor(c1, c2, t)
    return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t)
end

local HP_COLORS = {
    Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 60),
    Color3.fromRGB(255, 140, 60), Color3.fromRGB(255, 180, 60), Color3.fromRGB(230, 220, 60),
    Color3.fromRGB(170, 230, 60), Color3.fromRGB(120, 235, 70), Color3.fromRGB(60, 230, 80),
    Color3.fromRGB(30, 220, 60),
}

local function getHpColor(hp)
    hp = math.clamp(hp, 0, 1)
    local idx = hp * 9
    local i1 = math.floor(idx) + 1
    local i2 = math.min(i1 + 1, 10)
    local t = idx - math.floor(idx)
    return lerpColor(HP_COLORS[i1], HP_COLORS[i2], t)
end

local function createESP(plr)
    local data = { Box3D = {} }
    for i = 1, 12 do
        data.Box3D[i] = createDrawing("Line", { Thickness = ESPConfig.BoxThickness, Color = ESPConfig.BoxColor, Visible = false })
    end
    data.HealthLine = createDrawing("Line", { Thickness = 6, Color = Color3.fromRGB(30, 220, 60), Visible = false })
    ESPPlayers[plr] = data
    return data
end

local function removeESP(plr)
    local data = ESPPlayers[plr]
    if not data then return end
    for i = 1, 12 do
        local l = data.Box3D[i]
        if l then l:Remove() end
    end
    if data.HealthLine then data.HealthLine:Remove() end
    ESPPlayers[plr] = nil
end

local boxEdges = {
    {1,2},{1,3},{1,5},{2,4},{2,6},{3,4},
    {3,7},{4,8},{5,6},{5,7},{6,8},{7,8},
}

local function update3DBox(plr, data, char, cam)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local width = 4; local height = 5.5; local half = width * 0.5
    local center = hrp.CFrame
    local corners = {}; local idx = 1
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local world = (center * CFrame_new(half * x, (height * 0.5) * y, half * z)).Position
                local screen, onScreen = cam:WorldToViewportPoint(world)
                corners[idx] = { pos = Vector2_new(screen.X, screen.Y), on = onScreen }
                idx = idx + 1
            end
        end
    end
    local color = getBoxColor(plr)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyVisible = false
    for i = 1, 12 do
        local e = boxEdges[i]
        local a, b = corners[e[1]], corners[e[2]]
        local line = data.Box3D[i]
        if a.on and b.on then
            line.From = a.pos; line.To = b.pos; line.Color = color
            line.Thickness = ESPConfig.BoxThickness; line.Visible = true
            anyVisible = true
            if a.pos.X < minX then minX = a.pos.X end
            if b.pos.X < minX then minX = b.pos.X end
            if a.pos.Y < minY then minY = a.pos.Y end
            if b.pos.Y < minY then minY = b.pos.Y end
            if a.pos.X > maxX then maxX = a.pos.X end
            if b.pos.X > maxX then maxX = b.pos.X end
            if a.pos.Y > maxY then maxY = a.pos.Y end
            if b.pos.Y > maxY then maxY = b.pos.Y end
        else
            if line.Visible then line.Visible = false end
        end
    end
    if not anyVisible then return nil end
    return minX, minY, maxX - minX, maxY - minY
end

local function hideAllESP(data)
    for i = 1, 12 do
        local l = data.Box3D[i]
        if l.Visible then l.Visible = false end
    end
    if data.HealthLine.Visible then data.HealthLine.Visible = false end
end

local function updateESP()
    if not ESPConfig.Enabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local lp = player
    local lpChar = lp.Character
    local lpPos = lpChar and lpChar:FindFirstChild("HumanoidRootPart") and lpChar.HumanoidRootPart.Position or nil
    local maxDist = ESPConfig.MaxDistance
    local healthEnabled = ESPConfig.Health
    for plr, data in pairs(ESPPlayers) do
        local char, hrp, hum = getCharacterParts(plr)
        if not char or plr == lp then hideAllESP(data) continue end
        local dist = lpPos and (hrp.Position - lpPos).Magnitude or 0
        if dist > maxDist then hideAllESP(data) continue end
        local bx, by, bw, bh = update3DBox(plr, data, char, cam)
        if bx and healthEnabled and hum then
            local hp = hum.Health / hum.MaxHealth
            if hp < 0 then hp = 0 elseif hp > 1 then hp = 1 end
            local barX = bx - 8
            local barBot = by + bh
            local barFillTop = barBot - bh * hp
            data.HealthLine.From = Vector2_new(barX, barBot)
            data.HealthLine.To = Vector2_new(barX, barFillTop)
            data.HealthLine.Color = getHpColor(hp)
            data.HealthLine.Thickness = 6
            data.HealthLine.Visible = true
        else
            if data.HealthLine.Visible then data.HealthLine.Visible = false end
        end
    end
end

local function startESP()
    if ESPRunning then return end
    ESPRunning = true
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and not ESPPlayers[plr] then createESP(plr) end
    end
    ESPConnection = RunService.RenderStepped:Connect(updateESP)
end

local function stopESP()
    ESPRunning = false
    if ESPConnection then ESPConnection:Disconnect() ESPConnection = nil end
    for plr, _ in pairs(ESPPlayers) do removeESP(plr) end
end

Players.PlayerAdded:Connect(function(plr) if plr ~= player then createESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)

-- ============================================================
-- 玩家退出清理
-- ============================================================
Players.PlayerRemoving:Connect(function(plr)
    if currentTarget == plr then
        if isFollowing then stopFollowing() end
        if isOrbiting then stopOrbit() end
    end
    if randomTpTarget == plr then randomTpTarget = nil randomTpNext = 0 end
    if randomOrbitTarget == plr then randomOrbitTarget = nil end
    if randomSpotTarget == plr then randomSpotTarget = nil end
    if lockSpotTarget == plr then lockSpotTarget = nil end
    if predictLockTarget == plr then predictLockTarget = nil clearPredict() end
    if predictRandomTarget == plr then predictRandomTarget = nil clearPredict() end
    if CONFIG.TargetName == plr.Name then
        CONFIG.TargetName = nil
        if Options.TargetPlayer then pcall(function() Options.TargetPlayer:SetValue(nil) end) end
    end
    if CONFIG.MultiTargets and CONFIG.MultiTargets[plr.Name] then
        CONFIG.MultiTargets[plr.Name] = nil
    end
end)
-- ============================================================
-- Obsidian UI
-- ============================================================
local Window = Library:CreateWindow({
    Title = "XUNHAN",
    Footer = "XUNHAN",
    Icon = 95816097006870,
    CornerElements = false,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Home = Window:AddTab("首页", "home", "创作者信息"),
    Main = Window:AddTab("主要", "user", "主要功能"),
    Auto = Window:AddTab("自动", "sword", "自动功能"),
    ESP = Window:AddTab("透视", "eye", "ESP"),
    Arraylist = Window:AddTab("列表", "boxes", "模块列表设置"),
    Notifications = Window:AddTab("通知", "bell", "通知设置"),
    Settings = Window:AddTab("设置", "settings", "UI 设置与配置"),
}

-- ---- 首页 ----
local HomeLeft = Tabs.Home:AddLeftGroupbox("创作者信息", "user")
local HomeRight = Tabs.Home:AddRightGroupbox("注入器信息", "info")

HomeLeft:AddLabel("主创作：浔涵吖", true)
HomeLeft:AddLabel("副创作：秋辞", true)
HomeLeft:AddLabel("版本：v1.0.0", false)
HomeLeft:AddDivider()
HomeLeft:AddLabel("本脚本由 浔涵吖 与 秋辞 联合制作", true)
HomeLeft:AddLabel("仅供学习交流，请勿用于商业用途", true)

local executorName = "未知"
if identifyexecutor then
    local ok, name = pcall(identifyexecutor)
    if ok and name then executorName = tostring(name) end
end
local gameName = "未知"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

HomeRight:AddLabel("XUNHAN", true)
HomeRight:AddLabel("感谢使用本脚本", true)
HomeRight:AddDivider()
HomeRight:AddLabel("注入器：" .. executorName, false)
HomeRight:AddLabel("玩家：" .. player.Name, false)
HomeRight:AddLabel("游戏：" .. gameName, false)
HomeRight:AddLabel("PlaceID：" .. tostring(game.PlaceId), false)
HomeRight:AddLabel("服务器人数：" .. tostring(#Players:GetPlayers()), false)
HomeRight:AddLabel("启动时间：" .. os.date("%Y-%m-%d %H:%M:%S"), false)
HomeRight:AddDivider()
HomeRight:AddButton("复制创作者信息", function()
    if setclipboard then setclipboard("主创作：浔涵吖\n副创作：秋辞\n版本：v1.0.0") end
end)
HomeRight:AddButton("复制注入器信息", function()
    if setclipboard then
        setclipboard(string.format("注入器：%s\n玩家：%s\n游戏：%s\nPlaceID：%s\n人数：%d",
            executorName, player.Name, gameName, tostring(game.PlaceId), #Players:GetPlayers()))
    end
end)

-- ---- 左边：吸附 / 环绕 ----
local FollowGroup = Tabs.Main:AddLeftGroupbox("吸附 / 环绕", "boxes")

local TargetPlayerDropdown
local function getPlayerList()
    local list = {}
    local players = Players:GetPlayers()
    for i = 1, #players do
        local p = players[i]
        if p ~= player then list[#list + 1] = p.Name end
    end
    return list
end

local function refreshTargetDropdown()
    local list = getPlayerList()
    if TargetPlayerDropdown then
        if TargetPlayerDropdown.Refresh then pcall(function() TargetPlayerDropdown:Refresh(list) end)
        elseif TargetPlayerDropdown.SetValues then pcall(function() TargetPlayerDropdown:SetValues(list) end)
        elseif Options.TargetPlayer and Options.TargetPlayer.SetValues then pcall(function() Options.TargetPlayer:SetValues(list) end) end
    end
end

TargetPlayerDropdown = FollowGroup:AddDropdown("TargetPlayer", {
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    EnablePlayerImages = true,
    Text = "指定玩家（留空则随机）",
    Searchable = true,
    Callback = function(Value)
        if Value and Value ~= "" and Value ~= "无" and Value ~= "None" then
            CONFIG.TargetName = tostring(Value)
            local p = Players:FindFirstChild(CONFIG.TargetName)
            if not p then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Name == CONFIG.TargetName or plr.DisplayName == CONFIG.TargetName then p = plr break end
                end
            end
            if p then notifyToggle("已指定目标：" .. p.Name, 0)
            else notifyToggle("找不到玩家：" .. CONFIG.TargetName, 2) CONFIG.TargetName = nil end
        else
            CONFIG.TargetName = nil
            notifyToggle("已取消指定目标，恢复随机", 1)
        end
        if isFollowing then stopFollowing() startFollowing() end
        if isOrbiting then stopOrbit() startOrbit() end
        if randomTpRunning then stopRandomTeleport() startRandomTeleport() end
        if randomOrbitRunning then stopRandomOrbit() startRandomOrbit() end
        if randomSpotRunning then stopRandomSpot() startRandomSpot() end
        if lockSpotRunning then stopLockSpot() startLockSpot() end
        if predictLockRunning then stopPredictLock() startPredictLock() end
        if predictRandomRunning then stopPredictRandom() startPredictRandom() end
    end,
})

-- ★ 预判锁定开关（紧跟指定玩家下拉）
FollowGroup:AddToggle("PredictLock", {
    Text = "预判传送（锁定）",
    Default = false,
    Tooltip = "对上方指定玩家持续预判；没指定则随机锁一个；指定玩家退服后自动关闭",
    Callback = function(Value)
        Solstice:setModuleState("预判锁定", "", Value)
        if Value then
            exclusiveOn("PredictLock")
            startPredictLock()
            notifyToggle("预判（锁定）已开启", 0)
        else
            stopPredictLock()
            notifyToggle("预判（锁定）已关闭", 1)
        end
    end,
})

FollowGroup:AddDivider()

Players.PlayerAdded:Connect(function() task.wait(0.2) refreshTargetDropdown() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) refreshTargetDropdown() end)

FollowGroup:AddToggle("Follow", {
    Text = "自动依附", Default = false, Tooltip = "开启后自动依附目标",
    Callback = function(Value)
        Solstice:setModuleState("依附", "", Value)
        if Value then exclusiveOn("Follow") startFollowing() notifyToggle("依附 已开启", 0)
        else stopFollowing() notifyToggle("依附 已关闭", 1) end
    end,
})

FollowGroup:AddToggle("FollowHiders", {
    Text = "只依附躲藏者", Default = true, Tooltip = "开启：只依附躲藏者；关闭：随机依附任意玩家",
    Callback = function(Value)
        CONFIG.FollowHiders = Value
        if isFollowing then stopFollowing() startFollowing() end
        if isOrbiting then stopOrbit() startOrbit() end
    end,
})

FollowGroup:AddDropdown("FollowPosition", {
    Values = { "前面", "后面", "头顶", "下面", "左面", "右面" },
    Default = "后面", Multi = false, Text = "依附位置",
    Callback = function(Value) CONFIG.FollowPosition = Value end,
})

FollowGroup:AddSlider("FollowDistance", { Text = "依附距离", Default = 1, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.FollowDistance = v end })
FollowGroup:AddSlider("FollowHeight", { Text = "依附高度", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) CONFIG.FollowHeight = v end })
FollowGroup:AddToggle("FaceTarget", { Text = "始终面向目标", Default = true, Callback = function(v) CONFIG.FaceTarget = v end })

FollowGroup:AddDivider()

FollowGroup:AddToggle("Orbit", {
    Text = "环绕模式", Default = false, Tooltip = "以目标为中心绕圈",
    Callback = function(Value)
        Solstice:setModuleState("环绕", "", Value)
        if Value then exclusiveOn("Orbit") startOrbit() notifyToggle("环绕 已开启", 0)
        else stopOrbit() notifyToggle("环绕 已关闭", 1) end
    end,
})
FollowGroup:AddSlider("OrbitRadius", { Text = "环绕半径", Default = 1, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.OrbitRadius = v end })
FollowGroup:AddSlider("OrbitSpeed", { Text = "环绕速度", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.OrbitSpeed = v end })
FollowGroup:AddSlider("OrbitHeight", { Text = "环绕高度", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) CONFIG.OrbitHeight = v end })

FollowGroup:AddDivider()

FollowGroup:AddToggle("LockSpot", {
    Text = "锁定传送（锁人随机部位）", Default = false,
    Tooltip = "锁单人，位置随机换，目标死了才换",
    Callback = function(Value)
        Solstice:setModuleState("锁定传送", "", Value)
        if Value then exclusiveOn("LockSpot") startLockSpot() notifyToggle("锁定传送 已开启", 0)
        else stopLockSpot() notifyToggle("锁定传送 已关闭", 1) end
    end,
})
FollowGroup:AddSlider("LockSpotDistance", { Text = "锁定距离", Default = 1, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.LockSpotDistance = v end })
FollowGroup:AddSlider("LockSpotHeight", { Text = "锁定高度", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) CONFIG.LockSpotHeight = v end })
FollowGroup:AddSlider("LockSpotInterval", { Text = "换位间隔", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.LockSpotInterval = v end })

-- ---- 右边：随机传送 ----
local RandomGroup = Tabs.Main:AddRightGroupbox("随机传送", "boxes")

RandomGroup:AddDropdown("MultiTargets", {
    Values = (function()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then table.insert(t, p.Name) end
        end
        return t
    end)(),
    Multi = true,
    Text = "多选玩家（勾了才传，不勾全服随机）",
    Tooltip = "只影响右边的随机功能",
    Searchable = true,
    Callback = function(Value)
        CONFIG.MultiTargets = Value or {}
        CONFIG.LockIndex = 1
        if randomTpRunning then stopRandomTeleport() startRandomTeleport() end
        if randomOrbitRunning then stopRandomOrbit() startRandomOrbit() end
        if randomSpotRunning then stopRandomSpot() startRandomSpot() end
        if predictRandomRunning then stopPredictRandom() startPredictRandom() end
    end,
})

-- ★ 预判随机开关（紧跟多选下拉）
RandomGroup:AddToggle("PredictRandom", {
    Text = "预判传送（随机）",
    Default = false,
    Tooltip = "对上方勾选的多选玩家持续预判；不勾则全服随机；退了自动换",
    Callback = function(Value)
        Solstice:setModuleState("预判随机", "", Value)
        if Value then
            exclusiveOn("PredictRandom")
            startPredictRandom()
            notifyToggle("预判（随机）已开启", 0)
        else
            stopPredictRandom()
            notifyToggle("预判（随机）已关闭", 1)
        end
    end,
})

-- ★ 预判传送间隔
RandomGroup:AddSlider("PredictRandomInterval", {
    Text = "预判传送间隔",
    Default = 1,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Tooltip = "预判随机在「锁定到死」关闭时，每隔多少秒换一个目标",
    Callback = function(v) CONFIG.PredictRandomInterval = v end,
})

RandomGroup:AddDivider()

local function refreshMultiDropdown()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(t, p.Name) end
    end
    if Options.MultiTargets and Options.MultiTargets.SetValues then
        pcall(function() Options.MultiTargets:SetValues(t) end)
    elseif Options.MultiTargets and Options.MultiTargets.Refresh then
        pcall(function() Options.MultiTargets:Refresh(t) end)
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.2) refreshMultiDropdown() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) refreshMultiDropdown() end)

RandomGroup:AddToggle("LockToDeath", {
    Text = "锁定到死（右组）",
    Tooltip = "开：锁人死了才换；关：按间隔换",
    Default = false,
    Callback = function(Value)
        CONFIG.LockToDeath = Value
        CONFIG.LockIndex = 1
        if randomTpRunning then stopRandomTeleport() startRandomTeleport() end
        if randomOrbitRunning then stopRandomOrbit() startRandomOrbit() end
        if randomSpotRunning then stopRandomSpot() startRandomSpot() end
        if predictRandomRunning then stopPredictRandom() startPredictRandom() end
    end,
})

RandomGroup:AddDivider()

RandomGroup:AddToggle("RandomTeleport", {
    Text = "随机传送敌人身后", Default = false, Tooltip = "每隔一段时间随机传送到一个敌人身后",
    Callback = function(Value)
        Solstice:setModuleState("随机传送", "", Value)
        if Value then exclusiveOn("RandomTeleport") startRandomTeleport() notifyToggle("随机传送 已开启", 0)
        else stopRandomTeleport() notifyToggle("随机传送 已关闭", 1) end
    end,
})
RandomGroup:AddSlider("RandomDistance", { Text = "传送距离", Default = 1, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.RandomDistance = v end })
RandomGroup:AddSlider("RandomHeight", { Text = "传送高度", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomHeight = v end })
RandomGroup:AddSlider("RandomDelay", { Text = "传送间隔", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomDelay = v end })

RandomGroup:AddDivider()

RandomGroup:AddToggle("RandomOrbit", {
    Text = "随机传送环绕", Default = false,
    Tooltip = "随机锁一个目标绕圈，目标死了才换下一个",
    Callback = function(Value)
        Solstice:setModuleState("随机环绕", "", Value)
        if Value then exclusiveOn("RandomOrbit") startRandomOrbit() notifyToggle("随机环绕 已开启", 0)
        else stopRandomOrbit() notifyToggle("随机环绕 已关闭", 1) end
    end,
})
RandomGroup:AddSlider("RandomOrbitRadius", { Text = "环绕半径", Default = 3, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.RandomOrbitRadius = v end })
RandomGroup:AddSlider("RandomOrbitSpeed", { Text = "环绕速度", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomOrbitSpeed = v end })
RandomGroup:AddSlider("RandomOrbitHeight", { Text = "环绕高度", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomOrbitHeight = v end })
RandomGroup:AddSlider("RandomOrbitInterval", { Text = "换人间隔", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomOrbitInterval = v end })

RandomGroup:AddDivider()

RandomGroup:AddToggle("RandomSpot", {
    Text = "随机传送（锁人换位）", Default = false,
    Tooltip = "锁定一个人，每隔一段时间在他上/下/前/后/左/右随机换位，锁定到死",
    Callback = function(Value)
        Solstice:setModuleState("随机传送", "", Value)
        if Value then exclusiveOn("RandomSpot") startRandomSpot() notifyToggle("随机传送 已开启", 0)
        else stopRandomSpot() notifyToggle("随机传送 已关闭", 1) end
    end,
})
RandomGroup:AddSlider("RandomSpotDistance", { Text = "传送距离", Default = 1, Min = 1, Max = 20, Rounding = 1, Callback = function(v) CONFIG.RandomSpotDistance = v end })
RandomGroup:AddSlider("RandomSpotInterval", { Text = "换位间隔", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) CONFIG.RandomSpotInterval = v end })

-- ---- Auto 页 ----
local AutoLeft = Tabs.Auto:AddLeftGroupbox("自动功能", "sword")
local AutoRight = Tabs.Auto:AddRightGroupbox("玩家调节", "user")

AutoLeft:AddToggle("AutoM1", {
    Text = "自动普攻", Default = false, Tooltip = "自动连续释放普攻攻击",
    Callback = function(Value)
        Solstice:setModuleState("自动普攻", "", Value)
        getgenv().AutoM1 = Value
        if Value then
            notifyToggle("自动普攻 已开启", 0)
            task.spawn(function()
                while getgenv().AutoM1 do
                    local args = {{ Mobile = true, Goal = "LeftClick", MousePos = CFrame.new(464.99, 437.5, 139.16, -0.0301, 0.3037, -0.9523, -0, 0.9527, 0.3039, 0.9995, 0.0092, -0.0287) }}
                    pcall(function() game:GetService("Players").LocalPlayer.Character:WaitForChild("Communicate"):FireServer(unpack(args)) end)
                    task.wait(0.1)
                end
            end)
        else notifyToggle("自动普攻 已关闭", 1) end
    end,
})

AutoLeft:AddToggle("Skill1Toggle", { Text = "自动放技能1", Default = false, Callback = function(v) useFirstSkill = v Solstice:setModuleState("技能1", "", v) end })
AutoLeft:AddToggle("Skill2Toggle", { Text = "自动放技能2", Default = false, Callback = function(v) useSecondSkill = v Solstice:setModuleState("技能2", "", v) end })
AutoLeft:AddToggle("Skill3Toggle", { Text = "自动放技能3", Default = false, Callback = function(v) useThirdSkill = v Solstice:setModuleState("技能3", "", v) end })
AutoLeft:AddToggle("Skill4Toggle", { Text = "自动放技能4", Default = false, Callback = function(v) useFourthSkill = v Solstice:setModuleState("技能4", "", v) end })

AutoLeft:AddToggle("AutoDodging", {
    Text = "自动躲技能", Default = false,
    Callback = function(Value)
        AutoDodging = Value
        Solstice:setModuleState("自动躲技能", "", Value)
        if Value then startAutoDodge() notifyToggle("自动躲技能 已开启", 0)
        else stopAutoDodge() notifyToggle("自动躲技能 已关闭", 1) end
    end,
})

AutoRight:AddToggle("TPSpeedEnabled", {
    Text = "TPSpeed 加速（瞬移式）", Default = false,
    Tooltip = "一步跨很远，腿部不会疯转",
    Callback = function(Value)
        CONFIG.TPSpeedEnabled = Value
        Solstice:setModuleState("TPSpeed", "", Value)
        if Value then startTPSpeed() notifyToggle("TPSpeed 已开启", 0)
        else stopTPSpeed() notifyToggle("TPSpeed 已关闭", 1) end
    end,
})

AutoRight:AddSlider("TPSpeedValue", {
    Text = "加速速度", Default = 1, Min = 1, Max = 200, Rounding = 0,
    Tooltip = "最终速度值（16 以下不瞬移，16 以上按值加速）",
    Callback = function(v) CONFIG.TPSpeedValue = v end,
})

AutoRight:AddToggle("FlyingToggle", {
    Text = "飞行模式", Default = false,
    Callback = function(Value)
        Solstice:setModuleState("飞行", "", Value)
        if Value then startFlying() notifyToggle("飞行 已开启", 0)
        else stopFlying() notifyToggle("飞行 已关闭", 1) end
    end,
})
AutoRight:AddSlider("FlightSpeedSlider", { Text = "飞行速度", Default = 50, Min = 1, Max = 200, Rounding = 0, Callback = function(Value) FlightSpeed = Value end })

AutoRight:AddToggle("AntiFlingToggle", {
    Text = "防甩飞", Default = false,
    Callback = function(Value)
        Solstice:setModuleState("防甩飞", "", Value)
        if Value then startAntiFling() notifyToggle("防甩飞 已开启", 0)
        else stopAntiFling() notifyToggle("防甩飞 已关闭", 1) end
    end,
})

-- ---- ESP ----
local ESPGroup = Tabs.ESP:AddLeftGroupbox("透视", "boxes")

ESPGroup:AddToggle("ESPEnabled", {
    Text = "开启透视（3D框）", Default = false,
    Callback = function(v)
        ESPConfig.Enabled = v
        Solstice:setModuleState("透视", "", v)
        if v then startESP() notifyToggle("透视 已开启", 0)
        else stopESP() notifyToggle("透视 已关闭", 1) end
    end,
})

ESPGroup:AddToggle("ESPHealth", { Text = "血量显示", Default = true, Callback = function(v) ESPConfig.Health = v end })
ESPGroup:AddToggle("ESPRainbow", { Text = "彩虹框", Default = false, Callback = function(v) ESPConfig.Rainbow = v end })
ESPGroup:AddToggle("ESPTeamCheck", { Text = "队友/敌人配色", Default = false, Callback = function(v) ESPConfig.TeamCheck = v end })
ESPGroup:AddSlider("ESPThickness", { Text = "线条粗细", Default = 1, Min = 1, Max = 5, Rounding = 1, Callback = function(v) ESPConfig.BoxThickness = v end })
ESPGroup:AddSlider("ESPMaxDistance", { Text = "最大距离", Default = 1000, Min = 50, Max = 5000, Rounding = 1, Callback = function(v) ESPConfig.MaxDistance = v end })

ESPGroup:AddLabel("颜色"):AddColorPicker("ESPBoxColor", { Default = Color3.fromRGB(255, 255, 255), Title = "框颜色", Callback = function(c) ESPConfig.BoxColor = c end })
ESPGroup:AddLabel("颜色"):AddColorPicker("ESPEnemyColor", { Default = Color3.fromRGB(255, 60, 60), Title = "敌人颜色", Callback = function(c) ESPConfig.BoxColorEnemy = c end })
ESPGroup:AddLabel("颜色"):AddColorPicker("ESPTeamColor", { Default = Color3.fromRGB(60, 255, 60), Title = "队友颜色", Callback = function(c) ESPConfig.BoxColorTeam = c end })

-- ---- Arraylist ----
local ArraylistLeft = Tabs.Arraylist:AddLeftGroupbox("设置", "sliders")

ArraylistLeft:AddToggle("ArraylistVisible", { Text = "显示模块列表", Default = true, Callback = function(v) Solstice.arraylist:setVisible(v) end })
ArraylistLeft:AddToggle("WatermarkVisible", { Text = "显示水印", Default = true, Callback = function(v) Solstice.arraylist:setWatermarkVisible(v) end })
ArraylistLeft:AddToggle("CustomColorEnabled", { Text = "自定义颜色", Default = false, Callback = function(v) Solstice.arraylist:setCustomColorEnabled(v) end })
ArraylistLeft:AddLabel("颜色"):AddColorPicker("ArraylistCustomColor", { Default = Color3.fromRGB(110, 200, 241), Title = "模块列表颜色", Callback = function(c) Solstice.arraylist:setCustomColor(c) end })
ArraylistLeft:AddToggle("RainbowList", { Text = "模块列表彩虹", Default = false, Callback = function(v) Solstice.arraylist:setRainbowList(v) end })
ArraylistLeft:AddToggle("RainbowWatermark", { Text = "水印彩虹", Default = false, Callback = function(v) Solstice.arraylist:setRainbowWatermark(v) end })
ArraylistLeft:AddToggle("RainbowGlow", { Text = "泛光彩虹", Default = false, Callback = function(v) Solstice.arraylist:setRainbowGlow(v) end })
ArraylistLeft:AddToggle("RainbowText", { Text = "字体彩虹", Default = false, Callback = function(v) Solstice.arraylist:setRainbowText(v) end })
ArraylistLeft:AddToggle("Glow", { Text = "发光", Default = true, Callback = function(v) Solstice:setGlow(v) end })
ArraylistLeft:AddSlider("GlowDensity", { Text = "发光密度", Default = 2, Min = 1, Max = 10, Rounding = 0, Callback = function(v) Solstice:setGlowDensity(v) end })
ArraylistLeft:AddSlider("GlowRadius", { Text = "发光强度", Default = 1.9, Min = 0, Max = 10, Rounding = 1, Callback = function(v) Solstice:setGlowRadius(v) end })
ArraylistLeft:AddSlider("RightOffset", {
    Text = "右侧偏移", Default = 4, Min = -200, Max = 200, Rounding = 0,
    Callback = function(v)
        Solstice:setRightOffset(v)
        arraylistFrame.Position = UDim2.new(1, -(400 + v), 0, Solstice.arraylist.mTopOffset + 40)
    end,
})
ArraylistLeft:AddSlider("TopOffset", {
    Text = "顶部偏移", Default = -60, Min = -200, Max = 200, Rounding = 0,
    Callback = function(v)
        Solstice:setTopOffset(v)
        arraylistFrame.Position = UDim2.new(1, -(400 + Solstice.arraylist.mRightOffset), 0, v + 40)
    end,
})
ArraylistLeft:AddSlider("FontSize", { Text = "字体大小", Default = 20, Min = 2, Max = 20, Rounding = 1, Callback = function(v) Solstice:setFontSize(v) end })
ArraylistLeft:AddDropdown("DisplayMode", {
    Values = { "Outline", "Bar", "Split", "None" }, Default = 3, Multi = false, Text = "显示模式",
    Callback = function(Value)
        local modes = { Outline = 0, Bar = 1, Split = 2, None = 3 }
        Solstice:setDisplay(modes[Value])
    end,
})
ArraylistLeft:AddInput("WatermarkText", { Default = "XUNHAN", Numeric = false, Finished = true, ClearTextOnFocus = false, Text = "水印文字", Placeholder = "输入水印文字...", Callback = function(v) Solstice:setWatermarkText(v) end })

-- ---- Notifications ----
local NotifLeft = Tabs.Notifications:AddLeftGroupbox("设置", "sliders")
NotifLeft:AddSlider("MaxNotifications", { Text = "最大通知数", Default = 6, Min = 1, Max = 20, Rounding = 0, Callback = function(v) Solstice.notifications.mMaxNotifications = v end })
NotifLeft:AddToggle("LimitNotifications", { Text = "限制通知数量", Default = false, Callback = function(v) Solstice.notifications.mLimitNotifications = v end })
NotifLeft:AddToggle("ShowOnToggle", { Text = "开关时显示通知", Default = true, Callback = function(v) Solstice.notifications.mShowOnToggle = v end })
NotifLeft:AddSlider("NotifAnimSpeed", { Text = "动画速度", Default = 1, Min = 0.2, Max = 5, Rounding = 1, Callback = function(v) Solstice.notifications.mAnimSpeed = v end })
NotifLeft:AddSlider("NotifHoldTime", { Text = "停留时间", Default = 0.4, Min = 0, Max = 5, Rounding = 1, Callback = function(v) Solstice.notifications.mHoldTime = v end })
NotifLeft:AddSlider("NotifYOffset", {
    Text = "通知位置", Default = 0.20, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) Solstice.notifications.mYOffset = v notifFrame.Position = UDim2.new(1, Solstice.notifications.mXOffset, v, -260) end,
})
NotifLeft:AddSlider("NotifXOffset", {
    Text = "左右位置", Default = -288, Min = -800, Max = -100, Rounding = 0,
    Callback = function(v) Solstice.notifications.mXOffset = v notifFrame.Position = UDim2.new(1, v, Solstice.notifications.mYOffset, -260) end,
})

local NotifRight = Tabs.Notifications:AddRightGroupbox("预览", "bell")
NotifRight:AddButton({ Text = "测试提示", Func = function() Solstice:notify("这是一条提示通知！", 0, 3.0) end, DoubleClick = false })
NotifRight:AddButton({ Text = "测试警告", Func = function() Solstice:notify("这是一条警告！", 1, 3.0) end, DoubleClick = false })
NotifRight:AddButton({ Text = "测试错误", Func = function() Solstice:notify("这是一条错误！", 2, 3.0) end, DoubleClick = false })

-- ---- 设置 ----
local MenuGroup = Tabs.Settings:AddLeftGroupbox("菜单", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "打开按键菜单", Callback = function(v) Library.KeybindFrame.Visible = v end })
MenuGroup:AddToggle("ShowCustomCursor", { Text = "自定义光标", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
MenuGroup:AddDropdown("NotificationSide", { Values = { "Left", "Right" }, Default = "Right", Text = "通知位置", Callback = function(v) Library:SetNotifySide(v) end })
MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%", Text = "DPI 缩放",
    Callback = function(v) v = v:gsub("%%", "") Library:SetDPIScale(tonumber(v)) end,
})
MenuGroup:AddSlider("UICornerSlider", { Text = "圆角半径", Default = Library.CornerRadius, Min = 0, Max = 20, Rounding = 0, Callback = function(v) Window:SetCornerRadius(v) end })
MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单按键"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "菜单按键绑定" })

-- ============================================================
-- 统一卸载清理
-- ============================================================
local function cleanupAll()
    pcall(function() if isFollowing then stopFollowing() end end)
    pcall(function() if isOrbiting then stopOrbit() end end)
    pcall(function() if randomTpRunning then stopRandomTeleport() end end)
    pcall(function() if randomOrbitRunning then stopRandomOrbit() end end)
    pcall(function() if randomSpotRunning then stopRandomSpot() end end)
    pcall(function() if lockSpotRunning then stopLockSpot() end end)
    pcall(function() if predictLockRunning then stopPredictLock() end end)
    pcall(function() if predictRandomRunning then stopPredictRandom() end end)
    pcall(function() if ESPRunning then stopESP() end end)
    pcall(function() if ESPGui then ESPGui:Destroy() end end)
    pcall(function() if screenGui then screenGui:Destroy() end end)
    pcall(function() if FlyingEnabled then stopFlying() end end)
    pcall(function() if AutoDodging then stopAutoDodge() end end)
    pcall(function() if AntiFlingConn then stopAntiFling() end end)
    pcall(function() if tpSpeedConn then stopTPSpeed() end end)
    pcall(function()
        for plr, _ in pairs(ESPPlayers) do removeESP(plr) end
        ESPPlayers = {}
    end)
    pcall(function()
        if Solstice and Solstice.notifications then
            for _, ui in pairs(Solstice.notifications.mNotificationUIs) do
                if ui.wrapper then ui.wrapper:Destroy() end
            end
            Solstice.notifications.mNotificationUIs = {}
            Solstice.notifications.mNotifications = {}
        end
    end)
end

MenuGroup:AddButton("卸载", function() cleanupAll() Library:Unload() end)
Library:OnUnload(function() cleanupAll() end)
Library.ToggleKeybind = Options.MenuKeybind

-- ============================================================
-- 渲染循环
-- ============================================================
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local deltaTime = currentTime - lastTime
    lastTime = currentTime
    if deltaTime <= 0 or deltaTime > 1 then deltaTime = 1 / 60 end
    local mods = Solstice.arraylist.mModules
    local dt60 = deltaTime * 60
    for i = 1, #mods do
        local mod = mods[i]
        local target = mod.enabled and 1.0 or 0.0
        local diff = target - mod.arrayListAnim
        if diff ~= 0 then
            local speed = 0.08 + math.abs(diff) * 0.08
            mod.arrayListAnim = mod.arrayListAnim + diff * math.min(speed * dt60, 1)
            if mod.arrayListAnim > 1 then mod.arrayListAnim = 1
            elseif mod.arrayListAnim < 0 then mod.arrayListAnim = 0 end
        end
    end
    local notifList = Solstice.notifications.mNotifications
    local nCount = #notifList
    if nCount > 0 then
        for i = nCount, 1, -1 do
            local n = notifList[i]
            if n.isTimeUp and n.currentDuration <= 0.01 then table.remove(notifList, i) end
        end
    end
    updateArraylist()
    updateWatermark()
    if nCount > 0 then updateNotifications(deltaTime) end
end)

-- ============================================================
-- 主题和配置
-- ============================================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("XUNHAN")
SaveManager:SetFolder("XUNHAN/configs")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:AddThemeOptions(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Solstice:notify("XUNHAN 加载完成！", 0, 3.0)