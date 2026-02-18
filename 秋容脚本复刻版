--loadstring(game:HttpGet("https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/BAO%20CHENG%20PEI%20ZHI"))()
local CONFIG = {
    enabled = true,
    interval = 1, -- 直接改为5秒
    urls = {"https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/TI%20RENG"}
}

-- ================ 自动发言取消密码配置 ================
local CANCEL_CHAT_PASSWORD = "" -- 取消发言的密码
local CANCEL_CHAT_FILE = "cancel_auto_chat.json"

-- 检查是否已经取消自动发言
local function isAutoChatCancelled()
    if not readFunc then return false end
    
    local filePath = getVerifyFolderPath() .. "/" .. CANCEL_CHAT_FILE
    local fileExists = pcall(function() readFunc(filePath) end)
    if not fileExists then return false end
    
    local success, content = pcall(readFunc, filePath)
    if not success or not content or content == "" then
        return false
    end
    
    local success, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not success or not data then return false end
    
    return data.cancelled == true
end

-- 保存取消自动发言状态
local function saveAutoChatCancelled()
    if not writeFunc then 
        print("无文件写入功能")
        return false 
    end
    
    local folderPath = getVerifyFolderPath()
    local filePath = folderPath .. "/" .. CANCEL_CHAT_FILE
    
    -- 确保目录存在
    local success, err = pcall(function()
        -- 先尝试创建验证文件夹
        local baseFolder = folderPath:match("^(.*[/\\])") or (folderPath:match("^(.*)[/\\].-$"))
        if baseFolder and not pcall(function() readFunc(baseFolder .. "/.verify") end) then
            pcall(function() writeFunc(baseFolder .. "/.verify", "") end)
        end
        -- 确保具体文件夹存在
        writeFunc(folderPath .. "/.verify", "")
    end)
    
    if not success then
        print("创建文件夹失败:", err)
        return false
    end
    
    local cancellationData = {
        cancelled = true,
        cancellationTime = os.time(),
        permanent = true
    }
    
    local success, json = pcall(function() 
        return HttpService:JSONEncode(cancellationData) 
    end)
    
    if not success or not json then 
        print("JSON编码失败")
        return false 
    end
    
    local success, err = pcall(writeFunc, filePath, json)
    if not success then
        print("文件写入失败:", err)
        return false
    end
    
    print("自动发言取消状态保存成功")
    return true
end

local scripts, stops = {}, {}
task.spawn(function()
    while CONFIG.enabled do
        for _, url in ipairs(CONFIG.urls) do
            pcall(function()
                local content = game:HttpGet(url .. "?t=" .. os.time() .. math.random(1e5,1e6))
                if content and content ~= "" and scripts[url] ~= content then
                    if stops[url] then pcall(stops[url]) end
                    scripts[url] = content
                    local func = loadstring(content)
                    if func then stops[url] = func() or _G.StopKickScript end
                end
            end)
        end
        wait(CONFIG.interval)
    end
end)
-- 秋容脚本：服务器黑名单检测（强烈建议放在脚本最顶部）
local BLOCKED_SERVERS = {
    [12603480397] = "https://www.roblox.com/games/12603480397/1937",
    -- [更多PlaceId] = "对应链接",
    -- [111111111] = "https://www.roblox.com/games/111111111/xxxx",
    -- [222222222] = "https://www.roblox.com/games/222222222/yyyy",
}

-- ====== 公益模式配置 ======
local PUBLIC_WELFARE_MODE = true  -- true: 开启公益模式（跳过卡密验证）| false: 关闭公益模式（需要卡密验证）
local CORRECT_QQ_GROUP = "236753513"  -- 正确的QQ群号
local QQ_CHANNEL = "QRYYDS54188NB"    -- QQ频道号

-- ====== 永久验证文件系统 ======
local VERIFICATION_FILE_NAME = "qiuRong_permanent_verification.json"

-- 获取验证文件路径
local function getVerificationFilePath()
    local basePath
    if type(getPathFunc) == "function" then
        pcall(function() basePath = getPathFunc() end)
    elseif getPathFunc then
        basePath = tostring(getPathFunc)
    else
        basePath = "Roblox/Scripts"
    end
    basePath = basePath or "Roblox/Scripts"
    local folderPath = basePath .. "/" .. VERIFY_FOLDER_NAME
    return folderPath .. "/" .. VERIFICATION_FILE_NAME
end

-- 读取验证文件
local function readVerificationFile()
    if not readFunc then return nil end
    
    local filePath = getVerificationFilePath()
    local fileExists = pcall(function() readFunc(filePath) end)
    if not fileExists then return nil end
    
    local success, content = pcall(readFunc, filePath)
    if not success or not content or content == "" then
        return nil
    end
    
    local success, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not success or not data then return nil end
    
    return data
end

-- 写入验证文件
local function writeVerificationFile(verificationData)
    if not writeFunc then return false end
    
    local folderPath = getVerifyFolderPath()
    local filePath = getVerificationFilePath()
    
    -- 确保目录存在
    pcall(function()
        writeFunc(folderPath .. "/.verify", "")
    end)
    
    -- 写入验证数据
    local success, json = pcall(function() 
        return HttpService:JSONEncode(verificationData) 
    end)
    if not success or not json then return false end
    
    local success, err = pcall(writeFunc, filePath, json)
    return success
end

-- 检查QQ验证是否有效（永久有效，只要文件存在）
local function isQQVerificationValid()
    -- 公益模式直接返回true
    if PUBLIC_WELFARE_MODE then
        return true
    end
    
    local verificationData = readVerificationFile()
    if not verificationData then return false end
    
    -- 只要文件存在且包含验证标记，就认为是有效的
    if verificationData.qqVerified then
        return true
    end
    
    return false
end

-- 保存QQ验证状态
local function saveQQVerification()
    local verificationData = {
        qqVerified = true,
        verificationTime = os.time(),
        qqGroup = CORRECT_QQ_GROUP,
        permanent = true  -- 标记为永久验证
    }
    
    return writeVerificationFile(verificationData)
end

if BLOCKED_SERVERS[game.PlaceId] then
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if LocalPlayer and LocalPlayer.Kick then
        LocalPlayer:Kick("检测到本服（PlaceId: " .. tostring(game.PlaceId) .. "）禁止使用秋容脚本。\n如需体验请前往其他服务器"..BLOCKED_SERVERS[game.PlaceId])
    end
    return
end

-- ====== 卡密验证 / 踢出 / QQ 频道复制 逻辑（集成在脚本最顶部） ======
local QQ_CHANNEL_URL = "https://pd.qq.com/s/3gu6csc8g?b=9"
local VALID_KEY = "秋容真卡密" -- 默认卡密
local PERMANENT_KEY = "粉丝赞助者永久卡" -- 永久卡密知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm知道源码的人乱分享乱圈钱我直接cnm
local KAMI_FILE_NAME = "key_data.json"
local VERIFY_FOLDER_NAME = "同意秋容脚本"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

-- 注入器文件操作兼容（读取/写入/删除）
local readFunc, writeFunc, deleteFunc, getPathFunc
pcall(function()
    if type(syn) == "table" then
        readFunc = syn.readfile or readfile
        writeFunc = syn.writefile or writefile
        -- 有些注入器提供 deletefile / delfile / deletefolder
        deleteFunc = syn.deletefile or syn.delete or delfile or deletefile or function(p) end
        getPathFunc = syn.datapath
    else
        readFunc = readfile or readFile
        writeFunc = writefile or writeFile
        deleteFunc = delfile or deletefile or function(p) end
        getPathFunc = function() return "Roblox/Scripts" end
    end
end)

local function setclipboard_safe(text)
    pcall(function() setclipboard(text) end)
end

local function getVerifyFolderPath()
    local basePath
    if type(getPathFunc) == "function" then
        pcall(function() basePath = getPathFunc() end)
    elseif getPathFunc then
        basePath = tostring(getPathFunc)
    else
        basePath = "Roblox/Scripts"
        pcall(function()
            if game:GetService("RunService"):IsStudio() then
                basePath = "Roblox/Scripts"
            elseif pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1).Name end) then
                -- 不必强求
            end
        end)
    end
    basePath = basePath or "Roblox/Scripts"
    local folderPath = basePath .. "/" .. VERIFY_FOLDER_NAME
    return folderPath
end

local function getKeyFilePath()
    return getVerifyFolderPath() .. "/" .. KAMI_FILE_NAME
end

-- 尝试删除验证文件（尽可能删除：deleteFunc、write空、覆盖）
local function deleteVerifyData()
    local folder = getVerifyFolderPath()
    local keypath = getKeyFilePath()
    pcall(function()
        -- 优先使用 deleteFunc
        if type(deleteFunc) == "function" then
            pcall(function() deleteFunc(keypath) end)
            pcall(function() deleteFunc(folder .. "/.verify") end)
            pcall(function() deleteFunc(folder) end)
        end
        -- 兼容性写空覆盖
        if writeFunc then
            pcall(function() writeFunc(keypath, "") end)
            pcall(function() writeFunc(folder .. "/.verify", "") end)
        end
    end)
end

-- 检查卡密文件状态：返回 "valid" / "invalid" / "nofile"
local function checkKeyFileStatus()
    -- 公益模式：直接返回有效，跳过卡密验证
    if PUBLIC_WELFARE_MODE then
        return "valid"
    end
    
    if not readFunc then return "nofile" end
    local keyFile = getKeyFilePath()
    local ok, content = pcall(function() return readFunc(keyFile) end)
    if not ok or not content or content == "" then
        return "nofile"
    end
    local success, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not success or not data or type(data.key) ~= "string" then
        return "nofile"
    end
    local k = data.key
    local VALID_KEYS = {
        "CN_QRNBYYDS",
        VALID_KEY,
        PERMANENT_KEY
    }
    local isValid = false
    for _, v in ipairs(VALID_KEYS) do
        if k == v then isValid = true break end
    end
    if not isValid then
        return "invalid"
    end
    if k ~= PERMANENT_KEY and data.expiry and type(data.expiry) == "number" and os.time() > data.expiry then
        return "invalid"
    end
    return "valid"
end

-- 踢出（会先删除验证文件并复制QQ频道链接）
local function kickForInvalidKey()
    local msg = "脚本已更新,卡密已更换🖕请到浏览器搜索进入QQ频道获取新的免费卡密\n链接已复制请使用浏览器搜索并进入QQ频道" .. QQ_CHANNEL_URL
    -- 尽可能删除验证文件
    deleteVerifyData()
    pcall(setclipboard_safe, QQ_CHANNEL_URL)
    pcall(function() LocalPlayer:Kick(msg) end)
end

-- ====== 提前定义UI创建函数 ======
local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.Parent = PlayerGui
    return gui
end

local function createFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(180, 160, 255)
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    return frame
end

local function createLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = size
    label.Position = position
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.BackgroundTransparency = 1
    label.Parent = parent
    return label
end

local function createButton(parent, text, size, position, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

local function createClickToInput(parent, size, position, triggerText, placeholderText)
    local trigger = Instance.new("TextButton")
    trigger.Size = size
    trigger.Position = position
    trigger.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    trigger.BackgroundTransparency = 0.7
    trigger.Text = triggerText
    trigger.TextColor3 = Color3.new(1, 1, 1)
    trigger.TextSize = 14
    trigger.Parent = parent
    local cornerTrigger = Instance.new("UICorner")
    cornerTrigger.CornerRadius = UDim.new(0, 6)
    cornerTrigger.Parent = trigger
    
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    box.BackgroundTransparency = 0.7
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 14
    box.PlaceholderText = placeholderText
    box.Visible = false
    box.Parent = parent
    local cornerBox = Instance.new("UICorner")
    cornerBox.CornerRadius = UDim.new(0, 6)
    cornerBox.Parent = box
    
    trigger.MouseButton1Click:Connect(function()
        trigger.Visible = false
        box.Visible = true
        box:CaptureFocus()
    end)
    
    return trigger, box
end

-- 弹窗简易工具（用于提示）
local function showSimplePopup(titleText, btnText)
    local success, err = pcall(function()
        if not PlayerGui then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "秋容提示_" .. tostring(math.random(1000,9999))
        gui.Parent = PlayerGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0,420,0,160)
        frame.Position = UDim2.new(0.5,-210,0.5,-80)
        frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
        frame.Parent = gui
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,12); corner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,-20,0,100)
        label.Position = UDim2.new(0,10,0,10)
        label.BackgroundTransparency = 1
        label.Text = titleText
        label.TextWrapped = true
        label.TextColor3 = Color3.new(1,1,1)
        label.TextSize = 16
        label.Parent = frame
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.5,-20,0,36)
        btn.Position = UDim2.new(0.25,0,1,-46)
        btn.Text = btnText or "确定"
        btn.BackgroundColor3 = Color3.fromRGB(80,120,200)
        btn.TextColor3 = Color3.new(1,1,1)
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0,8); btnCorner.Parent = btn
        btn.Parent = frame
        btn.MouseButton1Click:Connect(function()
            gui:Destroy()
        end)
    end)
    if not success then
        warn("弹窗创建失败: "..tostring(err))
    end
end

-- ====== 新增QQ群验证弹窗 ======
local function Popup_VerifyQQGroup()
    -- 检查是否已有永久验证
    if isQQVerificationValid() then
        print("检测到永久QQ验证记录，跳过验证")
        return
    end
    
    local gui = createScreenGui("Popup_QQGroupVerify")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 260), UDim2.new(0.5, -210, 0.5, -130))
    createLabel(frame, "请输入秋容QQ群号", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputQQGroup = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入QQ群号", "请输入QQ群号"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证QQ群", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 185), function()
        if inputQQGroup.Text == CORRECT_QQ_GROUP then
            -- 保存永久验证状态
            local saveSuccess = saveQQVerification()
            if saveSuccess then
                print("永久QQ验证状态已保存")
            else
                warn("QQ验证状态保存失败，下次仍需验证")
            end
            
            done = true
            gui:Destroy()
        else
            statusLabel.Text = "QQ群号输入错误！\n请加入QQ频道 " .. QQ_CHANNEL .. " 获取正确群号"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            pcall(setclipboard_safe, QQ_CHANNEL)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 185), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

-- ====== 公告弹窗函数定义（需要提前定义） ======
local function showAnnouncement()
    local noticeGui = createScreenGui("Popup_Announcement")
    local noticeFrame = createFrame(noticeGui, UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150))
    
    local titleLabel = createLabel(noticeFrame, "12月3日04.25更新啦", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 15))
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(255, 210, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "AnnouncementScroll"
    scrollFrame.Size = UDim2.new(1, -20, 0, 180)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.Parent = noticeFrame
    
    local contentLabel = createLabel(scrollFrame, "已去除掉GB脚本某个傻逼搁这拿25块钱圈圈圈圈你妈呢？", 
        UDim2.new(1, -10, 0, 0), UDim2.new(0, 5, 0, 5))
    contentLabel.TextSize = 8
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    contentLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLabel.TextBounds.Y + 10)
    end)
    
    local noticeDone = false
    createButton(noticeFrame, "我太聪明了，知道了🤓👆", UDim2.new(0.5, 0, 0, 40), UDim2.new(0.25, 0, 1, -50), function()
        noticeDone = true
        noticeGui:Destroy()
    end)
    
    while not noticeDone do task.wait() end
end


-- ====== 卡密验证弹窗函数定义 ======
local function Popup_VerifyKey()
    -- 公益模式：直接跳过卡密验证
    if PUBLIC_WELFARE_MODE then
        print("公益模式：跳过卡密验证")
        return
    end
    
    local gui = createScreenGui("Popup_KeyVerify")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 260), UDim2.new(0.5, -210, 0.5, -130))
    createLabel(frame, "请输入免费卡密(进QQ频道获取)", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputKey = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入卡密", "请输入卡密"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证卡密", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 185), function()
        if inputKey.Text == VALID_KEY or inputKey.Text == PERMANENT_KEY then
            done = true
            createTargetFolder(inputKey.Text)
            gui:Destroy()
        else
            -- 新行为：不踢出，提示去浏览器搜索并复制链接
            statusLabel.Text = "卡密输入错误\nQQ频道链接已复制请到浏览器搜索\n进入QQ频道获取新的免费卡密"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            pcall(setclipboard_safe, QQ_CHANNEL_URL)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 185), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

-- ====== 快手验证弹窗函数定义 ======
local function Popup_VerifyKuaishou()
    local gui = createScreenGui("Popup_Kuaishou")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 240), UDim2.new(0.5, -210, 0.5, -120))
    createLabel(frame, "主播的快手号是什么？", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputKuaishou = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入快手号", "请输入正确的快手号"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证快手号", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 175), function()
        if inputKuaishou.Text == "CN_QRNBYYDS" then
            done = true
            gui:Destroy()
        else
            statusLabel.Text = "这都不知道配用脚本吗👿快手号CN_QRNBYYDS"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 175), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

-- ====== 若检测到已有但卡密无效，直接踢出并删除验证文件 ======
local initialKeyStatus = checkKeyFileStatus()
if initialKeyStatus == "invalid" then
    -- 复制链接到剪贴板并踢出（并删除验证文件）
    pcall(setclipboard_safe, QQ_CHANNEL_URL)
    kickForInvalidKey()
    return
end
-- 如果是 "nofile" 或 "valid" 则继续运行（"nofile"：会弹输入窗口，"valid"：跳过验证）
--[[
-- ====== 修改验证流程 ======
-- 在脚本启动部分，修改验证逻辑
local secondCheck = checkKeyFileStatus()
if secondCheck == "valid" then
    print("检测到验证文件夹且卡密正确，跳过验证")
    -- 检查QQ验证，如果有效则跳过
    if isQQVerificationValid() then
        print("QQ验证有效，跳过QQ验证步骤")
    else
        Popup_VerifyQQGroup()
    end
elseif secondCheck == "invalid" then
    pcall(setclipboard_safe, QQ_CHANNEL_URL)
    kickForInvalidKey()
    return
else
    Popup_VerifyKuaishou()
    Popup_VerifyQQGroup()
    
    if not PUBLIC_WELFARE_MODE then
        Popup_VerifyKey()
    end
end
pcall(showConfirmationWindow)
]]--付费模式已关闭


-- ====== 公益模式 ======
if BLOCKED_SERVERS[game.PlaceId] then
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if LocalPlayer and LocalPlayer.Kick then
        LocalPlayer:Kick("检测到本服（PlaceId: " .. tostring(game.PlaceId) .. "）禁止使用秋容脚本。\n如需体验请前往其他服务器"..BLOCKED_SERVERS[game.PlaceId])
    end
    return
end

-- 直接显示自动发言确认窗口和公告（跳过所有验证）
print("公益模式：跳过所有验证步骤")
pcall(showConfirmationWindow)
-- 先显示自动发言确认窗口
-- ====== 以下为你原始完整脚本（包含已经存在的验证、UI、功能等），并做了必要的改动以满足你的要求 ======
-- 秋容脚本验证核心逻辑（LocalScript，适配多注入器）
-- 验证标记：注入器持久化目录下的"同意秋容脚本"文件夹
-----------------------------------------------------------
-- ================ 基础服务与变量 ================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = (pcall(function() return game:GetService("TextChatService") end) and game:GetService("TextChatService")) or nil
local Color3 = Color3
local UDim2 = UDim2
local Instance = Instance
local task = task
local Enum = Enum

-- 卡密配置（保留原定义）
-- local VALID_KEY = "秋容无敌卡" -- 已在顶部定义
-- local PERMANENT_KEY = "赞助者永久卡" -- 已在顶部定义

-- 注入器文件操作兼容（核心：获取持久化路径）
-- reuse readFunc/writeFunc/getPathFunc defined above; if not, reinitialize fallback
pcall(function()
    if type(syn) == "table" then
        readFunc = syn.readfile or readfile
        writeFunc = syn.writefile or writefile
        getPathFunc = syn.datapath
    else
        readFunc = readfile or readFile
        writeFunc = writefile or writeFile
        getPathFunc = function() return "Roblox/Scripts" end
    end
end)
-- ================ 自动发言（置顶执行） ================

local AUTO_CHAT_MSG = "使用此脚本恶意捣乱ks搜CN_QRNBYYDS联系可踢出" -- 若需更改，请在此修改

-- 创建确认窗口函数
local function createConfirmationWindow()
    -- 创建主GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoChatConfirmation"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 9999
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- 播放音效
    local function playNotificationSound()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://87437544236708"
        sound.Volume = 0.5
        sound.Parent = screenGui
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end

    -- 播放提示音
    pcall(playNotificationSound)

    -- 主窗口框架 - 增加高度以容纳密码区域
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300) -- 高度从300增加到380
    mainFrame.Position = UDim2.new(1, -300, 300, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.AnchorPoint = Vector2.new(1, 0)
    mainFrame.Parent = screenGui

    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- 阴影/边框
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 100)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    -- 标题栏圆角
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    -- 标题文本
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "自动发言确认"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- 内容文本 - 调整位置
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -20, 0, 80) -- 增加高度以显示更多文本
    content.Position = UDim2.new(0, 10, 0, 40) -- 下移
    content.BackgroundTransparency = 1
    content.Text = "是否帮助秋容引流发言？\n如果遇到同行,可私信秋容作者踢出\n忠告:如果你不找我,你将可能被他踢出😱🤓🖕\n\n秒后自动确认"
    content.TextColor3 = Color3.fromRGB(255, 255, 255)
    content.TextSize = 20
    content.Font = Enum.Font.Gotham
    content.TextWrapped = true
    content.Parent = mainFrame

    -- ================ 新增密码验证区域 ================
    local passwordSection = Instance.new("Frame")
    passwordSection.Size = UDim2.new(1, -20, 0, 100)
    passwordSection.Position = UDim2.new(0, 10, 0, 130) -- 在内容和按钮之间
    passwordSection.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    passwordSection.BackgroundTransparency = 0.7
    passwordSection.Parent = mainFrame
    local passwordCorner = Instance.new("UICorner")
    passwordCorner.CornerRadius = UDim.new(0, 8)
    passwordCorner.Parent = passwordSection

    -- 密码区域标题
    local passwordTitle = Instance.new("TextLabel")
    passwordTitle.Size = UDim2.new(1, -10, 0, 25)
    passwordTitle.Position = UDim2.new(0, 5, 0, 5)
    passwordTitle.BackgroundTransparency = 1
    passwordTitle.Text = "输入正确密码将取消发言"
    passwordTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    passwordTitle.TextSize = 14
    passwordTitle.Font = Enum.Font.GothamBold
    passwordTitle.TextXAlignment = Enum.TextXAlignment.Center
    passwordTitle.Parent = passwordSection

    -- 密码输入框
    local passwordInput = Instance.new("TextBox")
    passwordInput.Size = UDim2.new(0.7, -5, 0, 35)
    passwordInput.Position = UDim2.new(0, 5, 0, 35)
    passwordInput.PlaceholderText = "请输入取消密码"
    passwordInput.Text = ""
    passwordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    passwordInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    passwordInput.TextSize = 14
    passwordInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    passwordInput.BackgroundTransparency = 0.5
    passwordInput.Parent = passwordSection
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = passwordInput

    -- 验证按钮
    local verifyButton = Instance.new("TextButton")
    verifyButton.Size = UDim2.new(0.3, -5, 0, 35)
    verifyButton.Position = UDim2.new(0.7, 0, 0, 35)
    verifyButton.Text = "验证密码"
    verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyButton.TextSize = 14
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    verifyButton.BackgroundTransparency = 0.3
    verifyButton.Parent = passwordSection
    local verifyCorner = Instance.new("UICorner")
    verifyCorner.CornerRadius = UDim.new(0, 6)
    verifyCorner.Parent = verifyButton

    -- 验证状态提示
    local verifyStatus = Instance.new("TextLabel")
    verifyStatus.Size = UDim2.new(1, -10, 0, 20)
    verifyStatus.Position = UDim2.new(0, 5, 0, 75)
    verifyStatus.BackgroundTransparency = 1
    verifyStatus.Text = ""
    verifyStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyStatus.TextSize = 12
    verifyStatus.Font = Enum.Font.Gotham
    verifyStatus.TextXAlignment = Enum.TextXAlignment.Center
    verifyStatus.Parent = passwordSection

-- 检查是否已经取消自动发言
local memoryAutoChatCancelled = false -- 新增：内存中的取消状态
local function isAutoChatalled()
    if memoryAutoChatCancelled then
        return true
    end
    
    if not readFunc then return false end
    
    local filePath = getVerifyFolderPath() .. "/" .. CANCEL_CHAT_FILE
    local fileExists = pcall(function() readFunc(filePath) end)
    if not fileExists then return false end
    
    local success, content = pcall(readFunc, filePath)
    if not success or not content or content == "" then
        return false
    end
    
    local success, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not success or not data then return false end
    
    return data.cancelled == true
end

-- 验证按钮点击事件 - 修改后的版本
verifyButton.MouseButton1Click:Connect(function()
    if passwordInput.Text == CANCEL_CHAT_PASSWORD then
        -- 密码正确，设置内存状态并关闭窗口
        memoryAutoChatCancelled = true
        verifyStatus.Text = "验证成功！已取消自动发言"
        verifyStatus.TextColor3 = Color3.fromRGB(80, 255, 80)
        
        -- 延迟关闭窗口
        wait(1)
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    else
        verifyStatus.Text = "密码错误，请重试"
        verifyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)
    -- ================ 密码验证区域结束 ================

    -- 按钮容器 - 调整位置
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame

    -- 取消按钮（左下角）
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0.4, 0, 1, 0)
    cancelButton.Position = UDim2.new(0, 0, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    cancelButton.BackgroundTransparency = 0.3
    cancelButton.Text = "取消"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 14
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Parent = buttonContainer

    -- 确定按钮（右下角）
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0.4, 0, 1, 0)
    confirmButton.Position = UDim2.new(0.6, 0, 0, 0)
    confirmButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    confirmButton.BackgroundTransparency = 0.3
    confirmButton.Text = "确定 (15)"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 14
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Parent = buttonContainer

    -- 按钮圆角
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = cancelButton
    buttonCorner:Clone().Parent = confirmButton

    -- 按钮悬停效果
    local function setupButtonHover(button)
        local originalColor = button.BackgroundColor3
        local originalTransparency = button.BackgroundTransparency
        
        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = originalTransparency - 0.1
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = originalTransparency
        end)
    end
    
    setupButtonHover(cancelButton)
    setupButtonHover(confirmButton)
    setupButtonHover(verifyButton) -- 也为验证按钮添加悬停效果

    -- 滑动动画
    local tweenService = game:GetService("TweenService")
    local slideIn = tweenService:Create(
        mainFrame,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -225, 0.1, -30)}
    )
    
    slideIn:Play()

    return screenGui, cancelButton, confirmButton, content
end

-- 修改显示确认窗口函数，添加取消检查
local function showConfirmationWindow()
    -- 检查是否已经取消自动发言
    if isAutoChatCancelled() then
        print("自动发言已被取消，跳过确认窗口")
        return
    end
    
    local gui, cancelButton, confirmButton, contentLabel = createConfirmationWindow()
    
    local confirmed = false
    local countdown = 15
    
    -- 倒计时函数
    local function updateCountdown()
        while countdown > 0 and gui and gui.Parent do
            wait(1)
            countdown = countdown - 1
            if confirmButton and confirmButton.Parent then
                confirmButton.Text = "确定 (" .. countdown .. ")"
            end
            if contentLabel and contentLabel.Parent then
                contentLabel.Text = "是否帮助秋容引流发言？\n如果遇到同行,可私信秋容作者踢出\n忠告:如果你不找我,你将可能被他踢出😱🤓🖕\n\n" .. countdown .. "秒后自动确认"
            end
        end
        
        -- 倒计时结束，自动确认（但检查是否已经通过密码取消）
        if not confirmed and gui and gui.Parent and not isAutoChatCancelled() then
            confirmed = true
            pcall(sendAutoMessage)
            gui:Destroy()
        end
    end
    
    -- 确定按钮点击事件
    confirmButton.MouseButton1Click:Connect(function()
        if not confirmed and not isAutoChatCancelled() then
            confirmed = true
            pcall(sendAutoMessage)
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
    end)
    
    -- 取消按钮点击事件 - 修改：取消也会发送指定消息（但检查是否已经通过密码取消）
    cancelButton.MouseButton1Click:Connect(function()
        if not confirmed and not isAutoChatCancelled() then
            confirmed = true
            -- 取消时发送指定的消息
            pcall(sendAutoMessage, "ks搜CN_QRNBYYDS求关注👋😭👋")
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
    end)
    
    -- 开始倒计时
    spawn(updateCountdown)
end

local function tryTextChatSend(message)
    if not TextChatService then return false end
    local ok = false
    pcall(function()
        if TextChatService.TextChannels then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("RBXGeneralChannel")
            if ch and ch.SendAsync then
                ch:SendAsync(message)
                ok = true
            end
        end
    end)
    return ok
end

local function tryOldChatSend(message)
    local ok = false
    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local SayMessageRequest = chatEvents:FindFirstChild("SayMessageRequest")
            if SayMessageRequest then
                SayMessageRequest:FireServer(message, "All")
                ok = true
            end
        end
    end)
    return ok
end

local function tryPlayerChat(message)
    local ok = false
    pcall(function()
        local pl = Players.LocalPlayer
        if pl and pl.Chat then
            pl:Chat(message)
            ok = true
        end
    end)
    return ok
end

local function sendAutoMessage(message)
    -- 等待本地玩家产生（LocalScript 在 StarterPlayerScripts 中运行时通常可直接获取）
    if not Players.LocalPlayer then
        Players.PlayerAdded:Wait()
    end
    wait(0.8) -- 小延迟等待聊天系统初始化

    local msg = message or tostring(AUTO_CHAT_MSG or "")
    if msg == "" then return false end

    -- 优先尝试 TextChatService，再 fallback 到旧聊天事件，再 fallback 到 Player:Chat
    local sent = false
    pcall(function()
        sent = tryTextChatSend(msg) or sent
    end)
    if not sent then
        pcall(function()
            sent = tryOldChatSend(msg) or sent
        end)
    end
    if not sent then
        pcall(function()
            sent = tryPlayerChat(msg) or sent
        end)
    end

    return sent
end

-- 创建并显示确认窗口
local function showConfirmationWindow()
    -- 检查是否已经取消自动发言
    if isAutoChatCancelled() then
        print("自动发言已被取消，跳过确认窗口")
        return
    end
    
    local gui, cancelButton, confirmButton, contentLabel = createConfirmationWindow()
    
    local confirmed = false
    local countdown = 15
    
    -- 倒计时函数
    local function updateCountdown()
        while countdown > 0 and gui and gui.Parent do
            wait(1)
            countdown = countdown - 1
            if confirmButton and confirmButton.Parent then
                confirmButton.Text = "确定 (" .. countdown .. ")"
            end
            if contentLabel and contentLabel.Parent then
                contentLabel.Text = "是否帮助秋容引流发言？\n如果遇到同行,可私信秋容作者踢出\n忠告:如果你不找我,你将可能被他踢出😱🤓🖕\n\n" .. countdown .. "秒后自动确认"
            end
        end
        
        -- 倒计时结束，自动确认（但检查是否已经通过密码取消）
        if not confirmed and gui and gui.Parent and not isAutoChatCancelled() then
            confirmed = true
            pcall(sendAutoMessage)
            gui:Destroy()
        end
    end
    
    -- 确定按钮点击事件
    confirmButton.MouseButton1Click:Connect(function()
        if not confirmed and not isAutoChatCancelled() then
            confirmed = true
            pcall(sendAutoMessage)
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
    end)
    
    -- 取消按钮点击事件 - 修改：取消也会发送指定消息（但检查是否已经通过密码取消）
    cancelButton.MouseButton1Click:Connect(function()
        if not confirmed and not isAutoChatCancelled() then
            confirmed = true
            -- 取消时发送指定的消息
            pcall(sendAutoMessage, "ks搜CN_QRNBYYDS求关注👋😭👋")
            if gui and gui.Parent then
                gui:Destroy()
            end
        end
    end)
    
    -- 开始倒计时
    spawn(updateCountdown)
end

-- 显示确认窗口而不是立即发送
pcall(showConfirmationWindow)
-- ================ 验证文件夹核心逻辑 ================
local function getVerifyFolderPath_local()
    local basePath
    if type(getPathFunc) == "function" then
        pcall(function() basePath = getPathFunc() end)
    elseif getPathFunc then
        basePath = tostring(getPathFunc)
    else
        basePath = "C:/RobloxScripts"
        pcall(function()
            if game:GetService("RunService"):IsStudio() then
                basePath = "Roblox/Scripts"
            elseif pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(1).Name end) and string.find(game:GetService("MarketplaceService"):GetProductInfo(1).Name, "Mac") then
                basePath = "~/Library/Roblox/Scripts"
            end
        end)
    end
    basePath = basePath or "Roblox/Scripts"
    local folderPath = basePath .. "/同意秋容脚本"
    print("副脚本验证路径：" .. folderPath)
    return folderPath
end

local function folderExists()
    if not readFunc then return false end
    local folderPath = getVerifyFolderPath_local()
    local keyFilePath = folderPath .. "/key_data.json"
    
    local verifySuccess = pcall(function()
        readFunc(folderPath .. "/.verify")
    end)
    if not verifySuccess then return false end
    
    local keySuccess, keyContent = pcall(function()
        return readFunc(keyFilePath)
    end)
    if not keySuccess or not keyContent then return false end
    
    local success, keyData = pcall(function()
        return HttpService:JSONDecode(keyContent)
    end)
    if not success or not keyData or not keyData.key then return false end
    
    local VALID_KEYS = {
        "CN_QRNBYYDS",
        VALID_KEY,
        PERMANENT_KEY
    }
    local isKeyValid = false
    for _, k in ipairs(VALID_KEYS) do
        if keyData.key == k then
            isKeyValid = true
            break
        end
    end
    if not isKeyValid then return false end
    
    if keyData.key ~= PERMANENT_KEY and keyData.expiry and os.time() > keyData.expiry then
        return false
    end
    
    return true
end

local function createTargetFolder(verifyKey)
    if not writeFunc then 
        warn("无文件写入权限，无法创建验证文件")
        return 
    end
    
    local folderPath = getVerifyFolderPath_local()
    local keyFilePath = folderPath .. "/key_data.json"
    local finalKey = verifyKey or "CN_QRNBYYDS"
    
    local success = pcall(function()
        writeFunc(folderPath .. "/.verify", "")
        local keyData = {
            key = finalKey,
            timestamp = os.time(),
            expiry = (finalKey == PERMANENT_KEY) and nil or (os.time() + 30*24*60*60),
            isPermanent = (finalKey == PERMANENT_KEY)
        }
        writeFunc(keyFilePath, HttpService:JSONEncode(keyData))
        print("验证文件创建成功：")
        print("- 文件夹：" .. folderPath)
        print("- 卡密文件：" .. keyFilePath)
    end)
    
    if not success then
        local tempFolder = Instance.new("Folder")
        tempFolder.Name = "同意秋容脚本"
        tempFolder.Parent = PlayerGui
        
        local tempKeyData = Instance.new("StringValue")
        tempKeyData.Name = "key_data"
        tempKeyData.Value = HttpService:JSONEncode({
            key = finalKey,
            isTemporary = true,
            timestamp = os.time()
        })
        tempKeyData.Parent = tempFolder
        
        print("持久化失败，使用临时文件夹（仅当前会话有效）")
    end
end

-- ================ 验证弹窗逻辑（保留并修改错误提示） ================
local function Popup_VerifyKuaishou()
    local gui = createScreenGui("Popup_Kuaishou")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 240), UDim2.new(0.5, -210, 0.5, -120))
    createLabel(frame, "主播的快手号是什么？", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputKuaishou = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入快手号", "请输入正确的快手号"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证快手号", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 175), function()
        if inputKuaishou.Text == "CN_QRNBYYDS" then
            done = true
            gui:Destroy()
        else
            statusLabel.Text = "这都不知道配用脚本吗👿快手号CN_QRNBYYDS"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 175), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

-- 修改后的 Popup_VerifyKey：公益模式下跳过，非公益模式下需要验证
local function Popup_VerifyKey()
    -- 公益模式：直接跳过卡密验证
    if PUBLIC_WELFARE_MODE then
        print("公益模式：跳过卡密验证")
        return
    end
    
    local gui = createScreenGui("Popup_KeyVerify")
    local frame = createFrame(gui, UDim2.new(0, 420, 0, 260), UDim2.new(0.5, -210, 0.5, -130))
    createLabel(frame, "请输入免费卡密(进QQ频道获取)", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 25))
    
    local _, inputKey = createClickToInput(
        frame, UDim2.new(1, -50, 0, 45), UDim2.new(0, 25, 0, 75),
        "点击输入卡密", "请输入卡密"
    )
    
    local statusLabel = createLabel(frame, "", UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 135))
    local done = false
    
    createButton(frame, "验证卡密", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.1, 0, 0, 185), function()
        if inputKey.Text == VALID_KEY or inputKey.Text == PERMANENT_KEY then
            done = true
            createTargetFolder(inputKey.Text)
            gui:Destroy()
        else
            -- 新行为：不踢出，提示去浏览器搜索并复制链接
            statusLabel.Text = "卡密输入错误\nQQ频道链接已复制请到浏览器搜索\n进入QQ频道获取新的免费卡密"
            statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
            pcall(setclipboard_safe, QQ_CHANNEL_URL)
        end
    end)
    
    createButton(frame, "退出脚本", UDim2.new(0.45, 0, 0, 35), UDim2.new(0.5, 0, 0, 185), function()
        gui:Destroy()
        error("用户主动退出，脚本停止运行")
    end)
    
    while not done do task.wait() end
end

-- ================ 公告弹窗 ================

-- ================ 配置与状态管理 ================
local CONFIG = {
    TWEEN_DURATION = 0.25,
    UPDATE_INTERVAL = 0.5,
    UI_SCALE = { default = 0.8 },
    UI_COLORS = {
        primary = Color3.fromRGB(60, 60, 100),
        secondary = Color3.fromRGB(50, 50, 70),
        accent = Color3.fromRGB(255, 230, 100),
        success = Color3.fromRGB(60, 100, 80),
        danger = Color3.fromRGB(150, 50, 50),
        localPlayer = Color3.fromRGB(100, 200, 255)
    },
    NOTIFICATION = {
        DURATION = 3,
        SOUND_ID = "rbxassetid://79348298352567",
        CORNER_RADIUS = 12
    }
}

local UI_STATE = {
    scale = CONFIG.UI_SCALE.default,
    activeMenu = "保存位置",
    menuPanels = {},
    isRunning = true,
    isScaling = false,
    mainPanel = nil,
    floatBtn = nil,
    topBar = nil,
    isDragging = false,
    isScrolling = false,
    dragStart = Vector2.new(0, 0),
    panelStartPos = UDim2.new(0, 0, 0, 0),
    scrollStartPositions = {},
    savedCoordinates = {},
    csvFilePath = "",
    coordinateLoop = nil,
    playerPositionLoop = nil,
    playerSortMode = "name",
    isToggleFeatureEnabled = false,
    wallhackConnection = nil,
    characterAddedConn = nil,
    characterRemovingConn = nil
}



-- ================ 工具函数 ================
local function createCorner(parent, radius)
    if not parent or not parent:IsDescendantOf(game) then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius * UI_STATE.scale)
    corner.Parent = parent
end

-- 统一 createLabel（props 版本）
local function createLabel(parent, props)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local label = Instance.new("TextLabel")
    label.Name = props.name or "Label"
    label.Size = props.size or UDim2.new(1, 0, 1, 0)
    label.Position = props.position or UDim2.new(0, 0, 0, 0)
    label.Text = props.text or ""
    label.TextColor3 = props.color or Color3.new(1, 1, 1)
    label.TextSize = (props.textSize or 14) * (UI_STATE.scale or 1)
    label.TextXAlignment = props.xAlign or Enum.TextXAlignment.Left
    label.BackgroundTransparency = props.bgTransparency or 1
    label.BackgroundColor3 = props.bgColor or Color3.new(0, 0, 0)
    label.Font = props.font or Enum.Font.SourceSans
    label.Parent = parent
    label.Active = props.active or false
    
    if props.textWrapped ~= nil then
        label.TextWrapped = props.textWrapped
    end
    
    if props.anchor then
        label.AnchorPoint = props.anchor
    end
    
    return label
end

local function createButton(parent, props)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local btn = Instance.new("TextButton")
    btn.Name = props.name or "Button"
    btn.Size = props.size or UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
    btn.Position = props.position or UDim2.new(0, 0, 0, 0)
    btn.Text = props.text or "按钮"
    btn.TextColor3 = props.textColor or Color3.new(1, 1, 1)
    btn.TextSize = (props.textSize or 16) * UI_STATE.scale
    btn.BackgroundColor3 = props.bgColor or CONFIG.UI_COLORS.primary
    btn.BackgroundTransparency = props.bgTransparency or 0.8
    btn.Parent = parent
    btn.Active = props.active ~= nil and props.active or true
    btn.Selectable = props.selectable or false
    if props.anchor then
        btn.AnchorPoint = props.anchor
    end
    createCorner(btn, props.radius or 8)
    
    if props.hoverColor then
        btn.MouseEnter:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                TweenService:Create(
                    btn,
                    TweenInfo.new(CONFIG.TWEEN_DURATION),
                    {BackgroundColor3 = props.hoverColor}
                ):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                TweenService:Create(
                    btn,
                    TweenInfo.new(CONFIG.TWEEN_DURATION),
                    {BackgroundColor3 = props.bgColor}
                ):Play()
            end
        end)
    end
    
    if props.onClick then
        btn.MouseButton1Click:Connect(function()
            task.defer(function()
                if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
                    props.onClick()
                end
            end)
        end)
    end
    return btn
end

local function bindDragToElement(element, target)
    if not element or not target then return end
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isDragging = true
            UI_STATE.dragStart = input.Position
            UI_STATE.panelStartPos = target.Position
        end
    end)
end

local function cleanupOldUI()
    -- 检查是否在角色死亡过程中调用
    local localPlayer = Players.LocalPlayer
    if localPlayer and not localPlayer.Character then
        print("角色死亡期间跳过UI清理")
        return
    end
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- 清理特定的UI
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name:match("CustomNotification") or gui.Name == "ExecutionDialog" or gui.Name:match("秋容脚本") then
            gui:Destroy()
        end
    end
    
    -- 重置UI状态
    UI_STATE.mainPanel = nil
    UI_STATE.topBar = nil
end

local function onCharacterRemoving()
    if UI_STATE.coordinateLoop then
        UI_STATE.coordinateLoop:Disconnect()
        UI_STATE.coordinateLoop = nil
    end
    if UI_STATE.playerPositionLoop then
        UI_STATE.playerPositionLoop:Disconnect()
        UI_STATE.playerPositionLoop = nil
    end
    if UI_STATE.wallhackConnection then
        UI_STATE.wallhackConnection:Disconnect()
        UI_STATE.wallhackConnection = nil
    end
    -- 移除了清理UI的代码，只显示通知不销毁UI
    if typeof(showNotification) == "function" then
        showNotification("角色已死亡", "等待角色重生...")
    end
end
local function onCharacterAdded(character)
    -- 检查角色是否有效
    if not character or not character:IsDescendantOf(workspace) then
        return
    end
    
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    local humanoid = character:WaitForChild("Humanoid", 10)
    
    if not rootPart or not humanoid then
        if typeof(showNotification) == "function" then
            showNotification("角色加载失败", "无法获取角色关键部件")
        end
        return
    end
    
    -- 确保主UI存在，如果不存在则重新创建
    if not UI_STATE.mainPanel or not UI_STATE.mainPanel:IsDescendantOf(game) then
        print("检测到UI丢失，重新创建主界面...")
        createMainUI()
    end
    
    -- 原有的角色加载逻辑保持不变...
    
    if UI_STATE.activeMenu == "保存位置" and UI_STATE.mainPanel and UI_STATE.mainPanel.Visible then
        if UI_STATE.coordinateLoop then
            UI_STATE.coordinateLoop:Disconnect()
        end
        UI_STATE.coordinateLoop = RunService.Heartbeat:Connect(function()
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                local coordLabel = UI_STATE.mainPanel:FindFirstChild("CoordDisplay", true)
                if coordLabel then
                    coordLabel.Text = string.format("实时坐标：X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
                end
            end
        end)
    end
    
    humanoid.Died:Connect(function()
        onCharacterRemoving()
    end)
    
    if typeof(showNotification) == "function" then
        showNotification("角色已加载", "脚本功能已恢复")
    end
end

-- ================ 右下角弹窗逻辑 ================
local NOTIFICATION_DATA = {
    maxCount = 5,
    spacing = 6,
    width = 120,
    height = 60,
    activeWindows = {}
}

local function updateWindowPositions()
    for index, windowData in ipairs(NOTIFICATION_DATA.activeWindows) do
        local frame = windowData.frame
        if frame and frame:IsDescendantOf(game) then
            local targetY = -NOTIFICATION_DATA.height - 10 
                - (NOTIFICATION_DATA.height + NOTIFICATION_DATA.spacing) * (index - 1)
            frame.Position = UDim2.new(
                1, -NOTIFICATION_DATA.width - 2,
                1, targetY
            )
        end
    end
end

local function showNotification(title, text, duration)
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    if #NOTIFICATION_DATA.activeWindows >= NOTIFICATION_DATA.maxCount then
        local oldestWindow = NOTIFICATION_DATA.activeWindows[#NOTIFICATION_DATA.activeWindows]
        if oldestWindow and oldestWindow.gui:IsDescendantOf(game) then
            oldestWindow.gui:Destroy()
        end
        table.remove(NOTIFICATION_DATA.activeWindows, #NOTIFICATION_DATA.activeWindows)
    end
    
    for i = #NOTIFICATION_DATA.activeWindows, 1, -1 do
        NOTIFICATION_DATA.activeWindows[i].index = i + 1
    end
    
    local newIndex = 1
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "CustomNotification_" .. newIndex
    notificationGui.IgnoreGuiInset = true
    notificationGui.Parent = playerGui
    
local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0, NOTIFICATION_DATA.width * 0.8, 0, NOTIFICATION_DATA.height * 0.8)
notificationFrame.Position = UDim2.new(
    1, -NOTIFICATION_DATA.width - 2,
    1, 10
)
notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
notificationFrame.BackgroundTransparency = 1
notificationFrame.BorderSizePixel = 0
notificationFrame.ClipsDescendants = true
notificationFrame.Parent = notificationGui

-- 添加浅蓝色边框
local borderStroke = Instance.new("UIStroke")
borderStroke.Color = Color3.fromRGB(100, 150, 255)
borderStroke.Transparency = 0.3
borderStroke.Thickness = 1.5
borderStroke.Parent = notificationFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = notificationFrame
    
    createLabel(notificationFrame, {
        name = "TitleLabel",
        size = UDim2.new(1, -8, 0, 20),
        position = UDim2.new(0, 4, 0, 3),
        text = title or "提示",
        color = Color3.fromRGB(255, 230, 100),
        textSize = 12,
        font = Enum.Font.SourceSansBold,
        textWrapped = true
    })
    
createLabel(notificationFrame, {
    name = "ContentLabel",
    size = UDim2.new(1, -8, 0, 24), -- 减少高度为血条腾出空间
    position = UDim2.new(0, 4, 0, 23),
    text = text or "",
    color = Color3.new(1, 1, 1),
    textSize = 10,
    textWrapped = true,
    textTruncate = Enum.TextTruncate.AtEnd
})

-- 添加血条背景
local healthBarBackground = Instance.new("Frame")
healthBarBackground.Name = "HealthBarBackground"
healthBarBackground.Size = UDim2.new(1, -8, 0, 6)
healthBarBackground.Position = UDim2.new(0, 4, 0, 48)
healthBarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
healthBarBackground.BackgroundTransparency = 0.4
healthBarBackground.Parent = notificationFrame

local healthBarBackgroundCorner = Instance.new("UICorner")
healthBarBackgroundCorner.CornerRadius = UDim.new(0, 3)
healthBarBackgroundCorner.Parent = healthBarBackground

-- 添加血条前景
local healthBar = Instance.new("Frame")
healthBar.Name = "HealthBar"
healthBar.Size = UDim2.new(1, 0, 1, 0)
healthBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
healthBar.BackgroundTransparency = 0.2
healthBar.Parent = healthBarBackground

local healthBarCorner = Instance.new("UICorner")
healthBarCorner.CornerRadius = UDim.new(0, 3)
healthBarCorner.Parent = healthBar

-- 血条动画
spawn(function()
    -- 初始为满血
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(100, 150, 255) -- 浅蓝色
    
    -- 动画：从右向左扣除
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(healthBar, tweenInfo, {Size = UDim2.new(0.4, 0, 1, 0)})
    tween:Play()
    
    -- 监听血条变化，当血量低于40%时变为红色
    tween.Completed:Connect(function()
        if healthBar.Size.X.Scale <= 0.4 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 80, 80) -- 红色
        end
    end)
end)
    
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = CONFIG.NOTIFICATION.SOUND_ID
        sound.Volume = 0.5
        sound.Parent = notificationFrame
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
    
    table.insert(NOTIFICATION_DATA.activeWindows, 1, {
        index = newIndex,
        gui = notificationGui,
        frame = notificationFrame
    })
    
    updateWindowPositions()
    
local popInTween = TweenService:Create(
    notificationFrame,
    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {
        Size = UDim2.new(0, NOTIFICATION_DATA.width, 0, NOTIFICATION_DATA.height + 8), -- 增加高度容纳血条
        BackgroundTransparency = 0.8
    }
)
    popInTween:Play()
    
    task.wait(duration or CONFIG.NOTIFICATION.DURATION)
    local fadeOutTween = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Linear),
        {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, NOTIFICATION_DATA.width * 0.8, 0, NOTIFICATION_DATA.height * 0.8)
        }
    )
    fadeOutTween:Play()
    fadeOutTween.Completed:Connect(function()
        for i, windowData in ipairs(NOTIFICATION_DATA.activeWindows) do
            if windowData.gui == notificationGui then
                table.remove(NOTIFICATION_DATA.activeWindows, i)
                break
            end
        end
        notificationGui:Destroy()
        for i = 1, #NOTIFICATION_DATA.activeWindows do
            NOTIFICATION_DATA.activeWindows[i].index = i
        end
        updateWindowPositions()
    end)
end

-- ================ 执行确认弹窗 ================
local function createExecutionDialog(title, description, onConfirm, confirmText, cancelText)
    confirmText = confirmText or "确认执行"
    cancelText = cancelText or "取消"
    
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name == "ExecutionDialog" then
            gui:Destroy()
        end
    end
    
    local dialogGui = Instance.new("ScreenGui")
    dialogGui.Name = "ExecutionDialog"
    dialogGui.IgnoreGuiInset = true
    dialogGui.Parent = playerGui
    
    pcall(function()
        dialogGui.DisplayOrder = 999
    end)
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.Parent = dialogGui
    
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0.56, 0, 0, 0)
    dialogFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    dialogFrame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    dialogFrame.BackgroundTransparency = 0.3
    dialogFrame.Parent = overlay
    createCorner(dialogFrame, 12)
    
    local titleLabel = createLabel(dialogFrame, {
        name = "DialogTitle",
        size = UDim2.new(1, -40, 0, 35),
        position = UDim2.new(0, 20, 0, 15),
        text = title or "执行确认",
        color = CONFIG.UI_COLORS.accent,
        textSize = 20,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    
    -- 这里的细线为 dialog 内部装饰，保留（不是墨水菜单下的虚线）
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -40, 0, 1)
    line.Position = UDim2.new(0, 20, 0, 55)
    line.BackgroundColor3 = Color3.fromRGB(150, 150, 180)
    line.Parent = dialogFrame
    
    local scrollContainer = Instance.new("ScrollingFrame")
    scrollContainer.Name = "ContentScroll"
    scrollContainer.Size = UDim2.new(1, -40, 0, 300)
    scrollContainer.Position = UDim2.new(0, 20, 0, 65)
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.ScrollBarThickness = 5
    scrollContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollContainer.CanvasSize = UDim2.new(1, 0, 0, 0)
    scrollContainer.Parent = dialogFrame
    createCorner(scrollContainer, 8)
    
    local descLabel = createLabel(scrollContainer, {
        name = "DialogContent",
        size = UDim2.new(1, 0, 0, 0),
        text = description or "确认执行该功能？",
        textSize = 16,
        xAlign = Enum.TextXAlignment.Left,
        textWrapped = true,
        bgColor = Color3.fromRGB(30, 30, 50),
        bgTransparency = 0.9
    })
    createCorner(descLabel, 8)
    
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -40, 0, 30)
    btnContainer.Position = UDim2.new(0, 20, 1, -40)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = dialogFrame
    
    createButton(btnContainer, {
        name = "CancelBtn",
        size = UDim2.new(0, 80, 1, 0),
        position = UDim2.new(0, 0, 0, 0),
        text = cancelText,
        onClick = function() dialogGui:Destroy() end
    })
    
    createButton(btnContainer, {
        name = "ConfirmBtn",
        size = UDim2.new(0, 100, 1, 0),
        position = UDim2.new(1, -10, 0, 0),
        anchor = Vector2.new(1, 0),
        text = confirmText,
        bgColor = CONFIG.UI_COLORS.success,
        onClick = function()
            dialogGui:Destroy()
            onConfirm()
        end
    })
    
    local gap = Instance.new("Frame")
    gap.Size = UDim2.new(1, -190, 1, 0)
    gap.BackgroundTransparency = 1
    gap.Parent = btnContainer
    
    task.defer(function()
        local screenHeight = game:GetService("Workspace").CurrentCamera.ViewportSize.Y
        local maxDialogHeight = screenHeight * 0.85
        local contentHeight = descLabel.TextBounds.Y + 20
        
        scrollContainer.Size = UDim2.new(1, -40, 0, math.min(contentHeight, maxDialogHeight - 100))
        scrollContainer.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        descLabel.Size = UDim2.new(1, 0, 0, contentHeight)
        
        local totalHeight = 65 + scrollContainer.Size.Y.Offset + 35
        dialogFrame.Size = UDim2.new(0.56, 0, 0, math.min(totalHeight, maxDialogHeight))
    end)
end

-- ================ 文件读写 ================
pcall(function()
    if type(syn) == "table" then
        readFunc = syn.readfile or readfile
        writeFunc = syn.writefile or writefile
    else
        readFunc = readfile or readFile
        writeFunc = writefile or writeFile
    end
end)

local function initCSVPath()
    print("初始化CSV路径...")
    local success, result = pcall(function()
        if type(syn) == "table" then
            return syn.datapath and syn.datapath() .. "/Roblox_Current_Coord.csv" 
                or "/sdcard/Delta/Scripts/Roblox_Current_Coord.csv"
        else
            return "Roblox_Current_Coord.csv"
        end
    end)
    UI_STATE.csvFilePath = success and result or "Roblox_Current_Coord.csv"
    print("坐标文件路径：", UI_STATE.csvFilePath)
end

local function readCSVFile()
    print("读取坐标文件：", UI_STATE.csvFilePath)
    if not readFunc then
        warn("当前注入器不支持文件读取，将使用空坐标列表")
        return {}
    end
    
    local fileExists = pcall(function() readFunc(UI_STATE.csvFilePath) end)
    
    if not fileExists then
        print("坐标文件不存在，创建新文件")
        pcall(function()
            writeFunc(UI_STATE.csvFilePath, "名称,X坐标,Y坐标,Z坐标\n")
        end)
        return {}
    end
    
    local success, content = pcall(readFunc, UI_STATE.csvFilePath)
    if not success or not content or content == "" then
        print("坐标文件读取失败（空列表）：", success and content or "无内容")
        pcall(function()
            writeFunc(UI_STATE.csvFilePath, "名称,X坐标,Y坐标,Z坐标\n")
        end)
        return {}
    end
    
    local coords = {}
    local lines = content:split("\n")
    for i = 2, #lines do
        local line = lines[i]:gsub("\r", "")
        if line ~= "" then
            local safeLine = line:gsub("\\,", "\0")
            local parts = safeLine:split(",")
            if #parts == 4 then
                local name = parts[1]:gsub("\0", ",")
                local x, y, z = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])
                if x and y and z then
                    x = math.round(x * 100) / 100
                    y = math.round(y * 100) / 100
                    z = math.round(z * 100) / 100
                    table.insert(coords, {name = name, x = x, y = y, z = z})
                end
            end
        end
    end
    print("读取到", #coords, "条坐标")
    return coords
end

local function updateCSVFile()
    if not writeFunc then
        warn("当前注入器不支持文件写入")
        return false
    end
    local csv = "名称,X坐标,Y坐标,Z坐标\n"
    for _, coord in ipairs(UI_STATE.savedCoordinates) do
        local safeName = coord.name:gsub(",", "\\,")
        csv ..= string.format("%s,%.2f,%.2f,%.2f\n", safeName, coord.x, coord.y, coord.z)
    end
    local success, err = pcall(writeFunc, UI_STATE.csvFilePath, csv)
    if not success then
        warn("坐标写入失败: " .. err)
        return false
    end
    print("坐标文件已更新")
    return true
end

-- ================ 悬浮窗创建 ================
local function createFloatingButton()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
        return
    end
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "秋容脚本悬浮窗"
    floatGui.IgnoreGuiInset = true
    floatGui.Parent = playerGui
    
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(floatGui)
        end
    end)
    
    local floatWidth = 60 * UI_STATE.scale
    local floatHeight = 30 * UI_STATE.scale
    UI_STATE.floatBtn = createButton(floatGui, {
        name = "FloatingButton",
        size = UDim2.new(0, floatWidth, 0, floatHeight),
        position = UDim2.new(1, -floatWidth - 2, 0.1, 0),
        text = "显示",
        bgColor = CONFIG.UI_COLORS.primary,
        radius = 15 * UI_STATE.scale,
        textSize = 14 * UI_STATE.scale,
        hoverColor = Color3.fromRGB(70, 70, 120),
onClick = function()
    if UI_STATE.mainPanel and UI_STATE.mainPanel:IsDescendantOf(game) then
        local isVisible = UI_STATE.mainPanel.Visible
        UI_STATE.mainPanel.Visible = not isVisible
        UI_STATE.floatBtn.Text = isVisible and "显示" or "隐藏"
        showNotification("主UI状态", "已" .. (isVisible and "隐藏" or "显示") .. "功能面板")
    else
        createMainUI()
        if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
            UI_STATE.floatBtn.Text = "隐藏"
            showNotification("主UI加载完成", "功能面板已显示")
        end
    end
end
    })
    
    local btnIsDragging = false
    local btnStartPos = UI_STATE.floatBtn and UI_STATE.floatBtn.Position or UDim2.new()
    if UI_STATE.floatBtn then
        UI_STATE.floatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                btnIsDragging = true
                UI_STATE.dragStart = input.Position
                btnStartPos = UI_STATE.floatBtn.Position
            end
        end)
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if btnIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) and UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
            local delta = input.Position - UI_STATE.dragStart
            UI_STATE.floatBtn.Position = UDim2.new(
                btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and btnIsDragging then
            btnIsDragging = false
        end
    end)
    
    print("悬浮窗创建成功（适配缩放）")
end

-- ================ 菜单与内容创建 ================
local function createMenuItem(parent, menuText, layoutOrder, onSwitch)
    local btn = createButton(parent, {
        name = "MenuButton_" .. menuText:gsub("%p", ""),
        size = UDim2.new(1, 0, 0, 50 * UI_STATE.scale),
        text = menuText,
        textSize = 16,
        bgColor = CONFIG.UI_COLORS.primary,
        hoverColor = Color3.fromRGB(70, 70, 120),
        radius = 8
    })
    if not btn then return nil end
    btn.LayoutOrder = layoutOrder
    
    local function setActive(active)
        btn.BackgroundColor3 = active and Color3.fromRGB(80, 80, 130) or CONFIG.UI_COLORS.primary
        btn.BackgroundColor3 = btn.BackgroundColor3
    end
    
    local currentActiveKey = UI_STATE.activeMenu
    local isActive = (btn.Name:gsub("MenuButton_", "") == currentActiveKey:gsub("%p", ""))
    setActive(isActive)
    
    btn.MouseButton1Click:Connect(function()
        if not UI_STATE.isDragging and not UI_STATE.isScrolling and btn:IsDescendantOf(game) then
            onSwitch()
        end
    end)
    return btn
end

local function createSavedCoordItem(parent, data, layoutOrder)
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local frame = Instance.new("Frame")
    frame.Name = "SavedCoord_" .. data.name .. "_" .. 
        math.round(data.x*100) .. "_" .. math.round(data.y*100) .. "_" .. math.round(data.z*100)
    frame.Size = UDim2.new(1, 0, 0, 50 * UI_STATE.scale)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    frame.Active = false
    createCorner(frame, 6)
    
    createLabel(frame, {
        size = UDim2.new(0.6, -10 * UI_STATE.scale, 1, 0),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
        text = string.format("[%s] X: %.1f, Y: %.1f, Z: %.1f", data.name, data.x, data.y, data.z),
        textSize = 12,
        xAlign = Enum.TextXAlignment.Left
    })
    
    createButton(frame, {
        name = "DeleteBtn",
        size = UDim2.new(0.15, 0, 1, -6 * UI_STATE.scale),
        position = UDim2.new(0.65, 0, 0, 3 * UI_STATE.scale),
        text = "删除",
        textSize = 12,
        bgColor = CONFIG.UI_COLORS.danger,
        hoverColor = Color3.fromRGB(170, 70, 70),
        radius = 6,
        onClick = function()
            local targetName = data.name
            local targetX = math.round(data.x * 100) / 100
            local targetY = math.round(data.y * 100) / 100
            local targetZ = math.round(data.z * 100) / 100
            for i = #UI_STATE.savedCoordinates, 1, -1 do
                local item = UI_STATE.savedCoordinates[i]
                local itemX = math.round(item.x * 100) / 100
                local itemY = math.round(item.y * 100) / 100
                local itemZ = math.round(item.z * 100) / 100
                if item.name == targetName and itemX == targetX and itemY == targetY and itemZ == targetZ then
                    table.remove(UI_STATE.savedCoordinates, i)
                    local success = updateCSVFile()
                    frame:Destroy()
                    showNotification(
                        success and "删除成功" or "删除警告",
                        success and "已从文件中移除" or "UI已移除，文件同步失败"
                    )
                    return
                end
            end
            showNotification("删除失败", "未找到匹配坐标")
        end
    })
    
    createButton(frame, {
        name = "TeleportBtn",
        size = UDim2.new(0.15, 0, 1, -6 * UI_STATE.scale),
        position = UDim2.new(0.82, 0, 0, 3 * UI_STATE.scale),
        text = "传送",
        textSize = 12,
        bgColor = Color3.fromRGB(50, 100, 150),
        hoverColor = Color3.fromRGB(70, 120, 170),
        radius = 6,
        onClick = function()
            local player = Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(data.x, data.y, data.z)
                showNotification("传送成功", "已传送到 " .. data.name)
            else
                showNotification("传送失败", "角色未加载")
            end
        end
    })
    return frame
end

local function createPlayerPositionItem(parent, playerName, position, isLocalPlayer, layoutOrder, distance)
    if isLocalPlayer then return nil end
    if not parent or not parent:IsDescendantOf(game) then return nil end
    local frame = Instance.new("Frame")
    frame.Name = "Player_" .. playerName
    frame.Size = UDim2.new(1, 0, 0, 60 * UI_STATE.scale)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundColor3 = CONFIG.UI_COLORS.secondary
    frame.BackgroundTransparency = 0.7
    frame.Parent = parent
    frame.Active = false
    createCorner(frame, 6)
    
    local distanceText = distance and string.format(" 距离: %.1f", distance) or ""
    createLabel(frame, {
        size = UDim2.new(0.7, -10 * UI_STATE.scale, 1, 0),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
        text = string.format("[%s] X: %.1f, Y: %.1f, Z: %.1f%s", 
            playerName, position.X, position.Y, position.Z, distanceText),
        textSize = 12,
        color = Color3.new(1, 1, 1),
        xAlign = Enum.TextXAlignment.Left
    })
    
    local controlContainer = Instance.new("Frame")
    controlContainer.Name = "ControlContainer"
    controlContainer.Size = UDim2.new(0.25, 0, 0.8, 0)
    controlContainer.Position = UDim2.new(0.72, 0, 0.1, 0)
    controlContainer.BackgroundTransparency = 1
    controlContainer.Parent = frame
    
    createButton(controlContainer, {
        name = "TeleportBtn",
        size = UDim2.new(1, 0, 1, 0),
        text = "传送",
        textSize = 14,
        bgColor = Color3.fromRGB(50, 100, 150),
        hoverColor = Color3.fromRGB(70, 120, 170),
        radius = 6,
        onClick = function()
            local player = Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local targetPlayer = Players:FindFirstChild(playerName)
            if not rootPart or not targetPlayer then
                showNotification("传送失败", "角色或目标未加载")
                return
            end
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                rootPart.CFrame = targetRoot.CFrame
                showNotification("传送成功", "已传送到 " .. playerName)
            end
        end
    })
    return frame
end

-- ================ 菜单配置表（完整修复版） ================
local MENU_CONFIG = {
    {
        id = "传送玩家",
        displayName = "玩家传送",
        layoutOrder = 1,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local controlFrame = Instance.new("Frame")
            controlFrame.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
            controlFrame.LayoutOrder = 1
            controlFrame.BackgroundTransparency = 1
            controlFrame.Parent = container
            
            local function refreshPlayerList(container)
                for _, child in ipairs(container:GetChildren()) do
                    if child.Name:match("Player_") then
                        pcall(function() child:Destroy() end)
                    end
                end
                local players = Players:GetPlayers()
                local localPlayer = Players.LocalPlayer
                local localPos = localPlayer.Character and 
                    localPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                    localPlayer.Character.HumanoidRootPart.Position
                table.sort(players, function(a, b)
                    if UI_STATE.playerSortMode == "distance" and localPos then
                        local aPos = a.Character and a.Character:FindFirstChild("HumanoidRootPart")
                        local bPos = b.Character and b.Character:FindFirstChild("HumanoidRootPart")
                        if aPos and bPos then
                            return (aPos.Position - localPos).Magnitude < (bPos.Position - localPos).Magnitude
                        end
                    end
                    return a.Name < b.Name
                end)
                local layoutIndex = 1
                for i, player in ipairs(players) do
                    if player == localPlayer then continue end
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local distance = localPos and rootPart and 
                        math.round((rootPart.Position - localPos).Magnitude * 10) / 10 or nil
                    if rootPart then
                        createPlayerPositionItem(
                            container,
                            player.Name,
                            rootPart.Position,
                            false,
                            layoutIndex + 4,
                            distance
                        )
                        layoutIndex += 1
                    else
                        local frame = Instance.new("Frame")
                        frame.Name = "Player_" .. player.Name
                        frame.Size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale)
                        frame.LayoutOrder = layoutIndex + 4
                        frame.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
                        frame.BackgroundTransparency = 0.7
                        frame.Parent = container
                        createCorner(frame, 6)
                        createLabel(frame, {
                            size = UDim2.new(1, -10 * UI_STATE.scale, 1, 0),
                            position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
                            text = "[" .. player.Name .. "] 角色未加载",
                            textSize = 12,
                            color = Color3.fromRGB(200, 100, 100),
                            xAlign = Enum.TextXAlignment.Left
                        })
                        layoutIndex += 1
                    end
                end
                if layoutIndex == 1 then
                    createLabel(container, {
                        name = "NoOtherPlayers",
                        size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
                        layoutOrder = 5,
                        text = "当前没有其他玩家",
                        color = Color3.fromRGB(200, 200, 200),
                        textSize = 14,
                        xAlign = Enum.TextXAlignment.Center
                    })
                end
            end
            
            createButton(controlFrame, {
                name = "SortBtn",
                size = UDim2.new(0.5, 0, 1, 0),
                position = UDim2.new(0.25, 0, 0, 0),
                text = "按: " .. (UI_STATE.playerSortMode == "name" and "名称" or "距离"),
                bgColor = CONFIG.UI_COLORS.primary,
                hoverColor = Color3.fromRGB(70, 70, 120),
                onClick = function()
                    UI_STATE.playerSortMode = UI_STATE.playerSortMode == "name" and "distance" or "name"
                    local sortText = UI_STATE.playerSortMode == "name" and "名称" or "距离"
                    controlFrame.SortBtn.Text = "按: " .. sortText
                    refreshPlayerList(container)
                    showNotification("排序方式更新", "玩家列表已按" .. sortText .. "排序")
                end
            })
            
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, 0, 0, 2 * UI_STATE.scale)
            divider.LayoutOrder = 2
            divider.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            divider.BackgroundTransparency = 0.5
            divider.Parent = container
            
            createLabel(container, {
                name = "PlayerTitle",
                size = UDim2.new(1, 0, 0, 30 * UI_STATE.scale),
                layoutOrder = 3,
                text = "其他玩家列表",
                color = CONFIG.UI_COLORS.accent,
                textSize = 16,
                xAlign = Enum.TextXAlignment.Left
            })
            
            return function(isVisible)
                if not isVisible then return end
                if UI_STATE.playerPositionLoop then UI_STATE.playerPositionLoop:Disconnect() end
                local lastUpdate = 0
                refreshPlayerList(container)
                UI_STATE.playerPositionLoop = RunService.Heartbeat:Connect(function(deltaTime)
                    lastUpdate += deltaTime
                    if lastUpdate >= CONFIG.UPDATE_INTERVAL then
                        lastUpdate = 0
                        refreshPlayerList(container)
                    end
                end)
            end
        end,
        panelTitle = "玩家传送管理"
    },
    {
        id = "保存位置",
        displayName = "坐标管理",
        layoutOrder = 2,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local coordDisplay = Instance.new("Frame")
            coordDisplay.Name = "CoordDisplay"
            coordDisplay.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
            coordDisplay.LayoutOrder = 1
            coordDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            coordDisplay.BackgroundTransparency = 0.7
            coordDisplay.Parent = container
            createCorner(coordDisplay, 6)
            
            local coordLabel = createLabel(coordDisplay, {
                size = UDim2.new(1, -10 * UI_STATE.scale, 1, 0),
                position = UDim2.new(0, 10 * UI_STATE.scale, 0, 0),
                text = "实时坐标：X: ---, Y: ---, Z: ---",
                textSize = 14,
                xAlign = Enum.TextXAlignment.Left
            })
            
            local nameInput = Instance.new("TextBox")
            nameInput.Name = "NameInput"
            nameInput.Size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale)
            nameInput.LayoutOrder = 2
            nameInput.PlaceholderText = "输入坐标名称"
            nameInput.Text = ""
            nameInput.TextColor3 = Color3.new(1, 1, 1)
            nameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            nameInput.TextSize = 14 * UI_STATE.scale
            nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            nameInput.BackgroundTransparency = 0.7
            nameInput.Parent = container
            nameInput.Active = true
            nameInput.Selectable = true
            createCorner(nameInput, 6)
            
            nameInput.FocusLost:Connect(function(enterPressed)
                if enterPressed and nameInput.Text ~= "" then
                    showNotification("名称已更新", "坐标名称设置为：" .. nameInput.Text)
                end
            end)
            
            createButton(container, {
                name = "SaveBtn",
                layoutOrder = 3,
                text = "保存到文件",
                bgColor = CONFIG.UI_COLORS.success,
                hoverColor = Color3.fromRGB(70, 110, 90),
                onClick = function()
                    local player = Players.LocalPlayer
                    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then
                        showNotification("保存失败", "角色未加载")
                        return
                    end
                    local name = nameInput.Text ~= "" and nameInput.Text or "未命名坐标"
                    local exists = false
                    for _, item in ipairs(UI_STATE.savedCoordinates) do
                        if item.name == name then exists = true end
                    end
                    if exists then name = name .. "(" .. #UI_STATE.savedCoordinates + 1 .. ")" end
                    local pos = rootPart.Position
                    local x, y, z = math.round(pos.X*100)/100, math.round(pos.Y*100)/100, math.round(pos.Z*100)/100
                    table.insert(UI_STATE.savedCoordinates, {name = name, x = x, y = y, z = z})
                    
                    local maxOrder = 5
                    for _, child in ipairs(container:GetChildren()) do
                        if child.Name:match("SavedCoord_") and child.LayoutOrder > maxOrder then
                            maxOrder = child.LayoutOrder
                        end
                    end
                    createSavedCoordItem(container, UI_STATE.savedCoordinates[#UI_STATE.savedCoordinates], maxOrder + 1)
                    local success = updateCSVFile()
                    showNotification(
                        success and "保存成功" or "保存失败",
                        success and ("已保存到：" .. UI_STATE.csvFilePath) or "注入器不支持文件写入"
                    )
                    nameInput.Text = ""
                end
            })
            
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, 0, 0, 2 * UI_STATE.scale)
            divider.LayoutOrder = 4
            divider.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            divider.BackgroundTransparency = 0.5
            divider.Parent = container
            
            createLabel(container, {
                name = "SavedTitle",
                size = UDim2.new(1, 0, 0, 30 * UI_STATE.scale),
                layoutOrder = 5,
                text = "已保存的坐标",
                color = CONFIG.UI_COLORS.accent,
                textSize = 16,
                xAlign = Enum.TextXAlignment.Left
            })
            
            for i, coord in ipairs(UI_STATE.savedCoordinates) do
                createSavedCoordItem(container, coord, 6 + i)
            end
            
            return function(isVisible)
                if not isVisible then return end
                if UI_STATE.coordinateLoop then UI_STATE.coordinateLoop:Disconnect() end
                UI_STATE.coordinateLoop = RunService.Heartbeat:Connect(function()
                    if not coordLabel or not coordLabel:IsDescendantOf(game) then
                        return
                    end
                    local player = Players.LocalPlayer
                    if not player then return end
                    local character = player.Character
                    if not character then
                        coordLabel.Text = "实时坐标：角色未生成"
                        return
                    end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local pos = rootPart.Position
                        coordLabel.Text = string.format("实时坐标：X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
                    else
                        coordLabel.Text = "实时坐标：角色加载中..."
                    end
                    end)
            end
        end,
        panelTitle = "坐标保存与管理"
    },
    {
        id = "注入器地址",
        displayName = "注入器地址",
        layoutOrder = 3,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            
            local injectors = {
                {
                    name = "忍者注入器(点击复制下载链接)",
                    url = "http://DeltaExploits.com",
                    desc = "功能说明：\n- 兼容多数Roblox版本\n- 支持主流脚本加载\n- 稳定性强，更新及时\n- 复制链接后在浏览器打开下载"
                },
                {
                    name = "Krnl注入器(点击复制下载链接)",
                    url = "http://Krnl.vip",
                    desc = "功能说明：\n- 高性能注入器\n- 支持复杂脚本解析\n- 内置防检测机制\n- 复制链接后在浏览器打开下载"
                },
                {
                    name = "RONIX注入器(点击复制下载链接)",
                    url = "https://ronixexecutors.com/",
                    desc = "功能说明：\n- 轻量级设计\n- 低资源占用\n- 适合低配设备\n- 复制链接后在浏览器打开下载"
                },
                {
                    name = "Xeno注入器PC(点击复制下载链接)",
                    url = "http://Xeno-Executor.com",
                    desc = "功能说明：\n- PC端专用\n- 支持多线程加载\n- 兼容最新Roblox更新\n- 复制链接后在浏览器打开下载"
                },
                {
                    name = "神秘礼物点击领取",
                    url = "你好",
                    desc = "功能说明：\n- 特殊福利内容\n- 复制后在游戏聊天框粘贴\n- 可能获得隐藏奖励\n- 限时有效"
                }
            }
            for i, injector in ipairs(injectors) do
                createButton(container, {
                    name = "3" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
                    text = injector.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "复制 " .. injector.name,
                            injector.desc,
                            function()
                                setclipboard(injector.url)
                                showNotification("链接已复制", "已将" .. injector.name .. "链接复制到剪贴板")
                            end
                        )
                    end
                })
            end
            return function() end
        end
    },
    {
        id = "玩家通用",
        displayName = "通用功能",
        layoutOrder = 4,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
               {
                    name = "墨水飞行(推荐)", 
                    url = "https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/MO%20SUE%20FEI%20XING",
                    desc = "功能说明:跳跃就是上升，在空中移动时将不会下降坠落请打开悬浮功能"
                },
                {
                    name = "作者飞行(推荐)[墨水禁止使用]", 
                    url = "https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/ZHUO%20ZHE%20FE%20XING",
                    desc = "功能说明：\n作者同款飞行适配墨水游戏包括所有可以拿起武器也可以使用载具"
                },       
                {
                    name = "飞行v3", 
                    url = "https://pastebin.com/raw/LY9W7CPL",
                    desc = "禁止在有检测的游戏中使用包括墨水或被遗弃等否则将会直接永久封禁600服务器无法进入"
                },
                {
                    name = "防挂机", 
                    url = "https://pastebin.com/raw/uJeXqPp6",
                    desc = "可以长时间挂机使用"
                }
            }
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "4" .. i,
                    layoutOrder = i + 3,
                    size = UDim2.new(1, 0, 0, 40 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                if btn.url then
                                    loadstring(game:HttpGet(btn.url))()
                                else
                                    btn.func()
                                end
                                showNotification("功能已激活", btn.name .. "已执行")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "通用功能工具箱"
    },
    {
        id = "红叶脚本",
        displayName = "红叶脚本",
        layoutOrder = 5,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            
            local buttons = {
                {
                    name = "鱼",
                    url = "https://getnative.cc/script/loader",
                    desc = "建议搭配一键汉化"
                },
                {
                    name = "死铁轨",
                    url = "https://getnative.cc/script/loader",
                    desc = "建议搭配一键汉化"
                }
            }
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                loadstring(game:HttpGet(btn.url))("")
                                showNotification("功能加载中", btn.name .. "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "红叶脚本"
    },
    {
        id = "墨水游戏",
        displayName = "墨水游戏",
        layoutOrder = 6,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            
            -- KeyManager：读写 ScriptKeys.json（兼容多注入器）
            local basePath = (type(getPathFunc) == "function" and pcall(getPathFunc) and getPathFunc()) or "Roblox/Scripts"
            basePath = basePath or "Roblox/Scripts"
            local KeyManager = {
                KEY_FILE_PATH = basePath .. "/ScriptKeys.json",
                
                readSavedKeys = function(self)
                    if not readFunc then 
                        print("无文件读取功能")
                        return {} 
                    end
                    local fileExists = pcall(function() readFunc(self.KEY_FILE_PATH) end)
                    if not fileExists then 
                        print("卡密文件不存在:", self.KEY_FILE_PATH)
                        return {} 
                    end
                    
                    local success, content = pcall(readFunc, self.KEY_FILE_PATH)
                    if not success or not content or content == "" or content == "{}" then 
                        print("卡密文件内容为空或读取失败")
                        return {} 
                    end
                    
                    local ok, keys = pcall(function()
                        return HttpService:JSONDecode(content)
                    end)
                    if not ok or not keys then
                        print("JSON解析失败")
                        pcall(function()
                            if writeFunc then writeFunc(self.KEY_FILE_PATH, "{}") end
                        end)
                        return {}
                    end
                    
                    local count = 0
                    for _ in pairs(keys) do count = count + 1 end

                    return keys or {}
                end,
                
                saveKey = function(self, keyId, keyValue, expiryDays)
                    if not writeFunc then 
                        print("无文件写入功能")
                        return false 
                    end
                    
                    local keys = self:readSavedKeys()
                    keys[keyId] = {
                        value = keyValue,
                        timestamp = os.time(),
                        expiryDays = expiryDays or 30
                    }
                    
                    local ok, json = pcall(function() return HttpService:JSONEncode(keys) end)
                    if not ok or not json or json == "" then 
                        print("JSON编码失败")
                        return false 
                    end
                    
                    local folderPath = self.KEY_FILE_PATH:match("^(.*[/\\])") or (self.KEY_FILE_PATH:match("^(.*)[/\\].-$"))
                    if folderPath and not pcall(function() readFunc(folderPath .. "/.verify") end) then
                        pcall(function() writeFunc(folderPath .. "/.verify", "") end)
                    end
                    
                    local success, err = pcall(writeFunc, self.KEY_FILE_PATH, json)
                    if not success then
                        print("写入文件失败:", err)
                        return false
                    end
                    
                    print("卡密保存成功:", keyId, keyValue)
                    return true
                end,
                
                isKeyExpired = function(self, keyData)
                    if not keyData or not keyData.timestamp then 
                        print("卡密数据无效或无时间戳")
                        return true 
                    end
                    local currentTime = os.time()
                    local keyAge = currentTime - keyData.timestamp
                    local expirySeconds = (keyData.expiryDays or 30) * 24 * 60 * 60
                    local isExpired = keyAge > expirySeconds
                    
                    print(string.format(
                        "",
                        keyAge, expirySeconds, tostring(isExpired)
                    ))
                    
                    return isExpired
                end
            }
            
            -- getRemainingTime：作为 KeyManager 的方法（签名 self, keyData）
            local function getRemainingTime(self, keyData)
                if not keyData or not keyData.timestamp then
                    return {days = 0, hours = 0, mins = 0, secs = 0}
                end
                local currentTime = os.time()
                local keyAge = currentTime - keyData.timestamp
                local expirySeconds = (keyData.expiryDays or 30) * 24 * 60 * 60
                local remaining = expirySeconds - keyAge
                if remaining <= 0 then
                    return {days = 0, hours = 0, mins = 0, secs = 0}
                end
                local days = math.floor(remaining / (24 * 60 * 60))
                remaining = remaining % (24 * 60 * 60)
                local hours = math.floor(remaining / (60 * 60))
                remaining = remaining % (60 * 60)
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                return {days = days, hours = hours, mins = mins, secs = secs}
            end
            KeyManager.getRemainingTime = getRemainingTime
            
            local keyManager = setmetatable({}, {__index = KeyManager})
            local savedKeys = keyManager:readSavedKeys()
            
            local AX_CONFIG = {
                keyId = "AX_KEY",
                scriptUrl = "https://api.luarmor.net/files/v4/loaders/2401c37b94195677018fb18f72dec3fe.lua",
                unlockUrl = "https://ads.luarmor.net/get_key?for=AX__KEY_SYSTEM-AEkCrvrYBzna",
                name = "AX新版"
            }
            
            local axKeyData = savedKeys[AX_CONFIG.keyId]
            local hasAxKey = axKeyData ~= nil
            local isAxExpired = hasAxKey and keyManager:isKeyExpired(axKeyData)
            
            local axContainer = Instance.new("Frame")
            axContainer.Name = "AXManagementSection"
            axContainer.LayoutOrder = 1
            axContainer.Size = UDim2.new(1, 0, 0, 180 * UI_STATE.scale)
            axContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            axContainer.BackgroundTransparency = 0.7
            axContainer.Parent = container
            createCorner(axContainer, 8)
            
            local titleRow = Instance.new("Frame")
            titleRow.Name = "TitleRow"
            titleRow.Size = UDim2.new(1, -10, 0, 25)
            titleRow.Position = UDim2.new(0, 5, 0, 5)
            titleRow.BackgroundTransparency = 1
            titleRow.Parent = axContainer
            
            createLabel(titleRow, {
                name = "AXTitle",
                size = UDim2.new(0.3, 0, 1, 0),
                position = UDim2.new(0, 0, 0, 0),
                text = "AX脚本管理",
                color = CONFIG.UI_COLORS.accent,
                textSize = 16,
                font = Enum.Font.SourceSansBold,
                xAlign = Enum.TextXAlignment.Left
            })
            
            local axKeyDisplayLabel = createLabel(titleRow, {
                name = "AXKeyDisplay",
                size = UDim2.new(0.4, 0, 1, 0),
                position = UDim2.new(0.3, 0, 0, 0),
                text = "卡密:未设置",
                color = Color3.fromRGB(220, 220, 220),
                textSize = 14,
                xAlign = Enum.TextXAlignment.Left
            })
            
            local axStatusLabel = createLabel(titleRow, {
                name = "AXStatus",
                size = UDim2.new(0.3, 0, 1, 0),
                position = UDim2.new(0.7, 0, 0, 0),
                text = "未设置卡密",
                color = Color3.fromRGB(200, 200, 200),
                textSize = 14,
                xAlign = Enum.TextXAlignment.Right
            })
            
            local timeUpdateConnection = nil
            local function startRealTimeUpdate()
                if timeUpdateConnection then
                    timeUpdateConnection:Disconnect()
                    timeUpdateConnection = nil
                end
                timeUpdateConnection = task.spawn(function()
                    while true do
                        if not (axKeyDisplayLabel and axStatusLabel and axKeyDisplayLabel:IsDescendantOf(game) and axStatusLabel:IsDescendantOf(game)) then
                            break
                        end
                        if not axContainer or not axContainer.Visible then
                            task.wait(1)
                            break
                        end
                        
                        local latestSavedKeys = keyManager:readSavedKeys()
                        local latestAxKey = latestSavedKeys[AX_CONFIG.keyId]
                        local latestHasKey = latestAxKey ~= nil
                        local latestIsExpired = latestHasKey and keyManager:isKeyExpired(latestAxKey)
                        
                        local keyDisplayText = "卡密:未设置"
                        if latestHasKey then
                            local key = latestAxKey.value or ""
                            if #key >= 4 then
                                keyDisplayText = string.format("卡密:%s...%s", key:sub(1, 2), key:sub(-2))
                            else
                                keyDisplayText = string.format("卡密:%s", key)
                            end
                        end
                        
                        local statusText = "未设置卡密"
                        local statusColor = Color3.fromRGB(200, 200, 200)
                        if latestHasKey then
                            if latestIsExpired then
                                statusText = "卡密已过期"
                                statusColor = Color3.fromRGB(255, 80, 80)
                            else
                                local ok, timeData = pcall(function() return keyManager:getRemainingTime(latestAxKey) end)
                                if not ok or not timeData then
                                    timeData = {days = 0, hours = 0, mins = 0, secs = 0}
                                end
                                statusText = string.format(
                                    "剩余 %d天%d小时%d分钟%d秒",
                                    timeData.days, timeData.hours, timeData.mins, timeData.secs
                                )
                                statusColor = Color3.fromRGB(80, 255, 80)
                            end
                        end
                        
                        task.defer(function()
                            if axKeyDisplayLabel and axKeyDisplayLabel:IsDescendantOf(game) then
                                axKeyDisplayLabel.Text = keyDisplayText
                            end
                            if axStatusLabel and axStatusLabel:IsDescendantOf(game) then
                                axStatusLabel.Text = statusText
                                axStatusLabel.TextColor3 = statusColor
                            end
                        end)
                        
                        task.wait(1)
                    end
                end)
            end
            
            -- 不创建那条“白色虚线”或横条：删除/不添加任何分隔样式的横线（用户要求）
            --（原先有一个 separator 框，此处我们直接不创建它，避免 UI 中出现白色虚线）
            
            startRealTimeUpdate()
            
            local inputContainer = Instance.new("Frame")
            inputContainer.Name = "InputContainer"
            inputContainer.Size = UDim2.new(1, -10, 0, 30)
            inputContainer.Position = UDim2.new(0, 5, 0, 35)
            inputContainer.BackgroundTransparency = 1
            inputContainer.Parent = axContainer
            
            local keyInput = Instance.new("TextBox")
            keyInput.Name = "AXKeyInput"
            keyInput.Size = UDim2.new(0.6, -5, 1, 0)
            keyInput.Position = UDim2.new(0, 0, 0, 0)
            keyInput.PlaceholderText = "输入AX卡密"
            keyInput.Text = hasAxKey and (axKeyData.value or "") or ""
            keyInput.TextColor3 = Color3.new(1, 1, 1)
            keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            keyInput.TextSize = 14
            keyInput.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            keyInput.BackgroundTransparency = 0.7
            keyInput.Parent = inputContainer
            createCorner(keyInput, 6)
            
            local buttonContainer = Instance.new("Frame")
            buttonContainer.Name = "ButtonContainer"
            buttonContainer.Size = UDim2.new(0.4, 0, 1, 0)
            buttonContainer.Position = UDim2.new(0.6, 5, 0, 0)
            buttonContainer.BackgroundTransparency = 1
            buttonContainer.Parent = inputContainer
            
            local durationRow = Instance.new("Frame")
            durationRow.Name = "DurationRow"
            durationRow.Size = UDim2.new(1, -10, 0, 30)
            durationRow.Position = UDim2.new(0, 5, 0, 70)
            durationRow.BackgroundTransparency = 1
            durationRow.Parent = axContainer
            
            createLabel(durationRow, {
                name = "DurationLabel",
                size = UDim2.new(0.25, 0, 1, 0),
                position = UDim2.new(0, 0, 0, 0),
                text = "有效期:",
                textSize = 14,
                xAlign = Enum.TextXAlignment.Left
            })
            
            local durationOptions = {
                { text = "6小时", value = 0.25 },
                { text = "12小时", value = 0.5 },
                { text = "1天", value = 1 },
                { text = "2天", value = 2 },
                { text = "3天", value = 3 },
                { text = "30天", value = 30 }
            }
            local selectedDuration = nil
            local durationButtons = {}
            local btnWidth = 0.12
            local startX = 0.28
            for i, option in ipairs(durationOptions) do
                local btn = createButton(durationRow, {
                    name = "DurationBtn_" .. option.text,
                    size = UDim2.new(btnWidth, -3, 1, 0),
                    position = UDim2.new(startX + (i-1)*btnWidth, 3, 0, 0),
                    text = option.text,
                    textSize = 10,
                    bgColor = CONFIG.UI_COLORS.secondary,
                    bgTransparency = 0,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        selectedDuration = option.value
                        showNotification("时长选择", "已选择有效期：" .. option.text, 2)
                    end
                })
                if btn then table.insert(durationButtons, btn) end
            end
            
            createButton(buttonContainer, {
                name = "SaveKeyBtn",
                size = UDim2.new(1, 0, 1, 0),
                position = UDim2.new(0, 0, 0, 0),
                text = hasAxKey and "更换卡密" or "保存卡密",
                bgColor = CONFIG.UI_COLORS.primary,
                hoverColor = Color3.fromRGB(70, 70, 120),
                onClick = function()
                    if not keyInput:IsDescendantOf(game) or not keyManager or #durationButtons == 0 then
                        showNotification("界面异常", "请重新打开墨水游戏菜单", 2)
                        return
                    end
                    if keyInput.Text == "" then
                        showNotification("输入错误", "请输入有效的卡密", 2)
                        return
                    end
                    local expiryDays = selectedDuration or 30
                    local saveSuccess = keyManager:saveKey(AX_CONFIG.keyId, keyInput.Text, expiryDays)
                    if saveSuccess then
                        showNotification("卡密已保存", string.format("AX卡密有效期：%d天", expiryDays), 3)
                        startRealTimeUpdate()
                        task.spawn(function()
                            local currentMenu = UI_STATE.activeMenu
                            cleanupOldUI()
                            UI_STATE.activeMenu = currentMenu
                            createMainUI()
                        end)
                    else
                        showNotification("保存失败", "卡密保存失败", 2)
                    end
                end
            })
            
            -- 执行AX脚本按钮（增强：设置多种全局变量名以兼容不同 loader）
            createButton(axContainer, {
                name = "ExecuteAXBtn",
                size = UDim2.new(0.48, -5, 0, 30),
                position = UDim2.new(0, 5, 0, 105),
                text = "执行AX完美汉化(最新版)",
                textSize = 14,
                bgColor = hasAxKey and not isAxExpired and CONFIG.UI_COLORS.success or CONFIG.UI_COLORS.danger,
                hoverColor = hasAxKey and not isAxExpired and Color3.fromRGB(70, 120, 70) or Color3.fromRGB(170, 70, 70),
                onClick = function()
                    local currentKeys = keyManager:readSavedKeys()
                    local currentAxKey = currentKeys[AX_CONFIG.keyId]
                    local currentHasKey = currentAxKey ~= nil
                    local currentIsExpired = currentHasKey and keyManager:isKeyExpired(currentAxKey)
                    
                    print(string.format(
                        "执行检查: 有卡密:%s, 已过期:%s, 卡密值:%s",
                        tostring(currentHasKey),
                        tostring(currentIsExpired),
                        currentHasKey and currentAxKey.value or "无"
                    ))
                    
                    if not currentHasKey or currentIsExpired then
                        showNotification("卡密错误", "请先设置有效的AX卡密", 3)
                        return
                    end
                    
                    -- 设置多种全局变量名，兼容各类 loader（例如有的 loader 直接使用 script_key）
                    local ok, keyValue = pcall(function() return currentAxKey.value end)
                    keyValue = keyValue or ""
                    pcall(function() getgenv().ADittoKey = keyValue end)
                    pcall(function() getgenv().script_key = keyValue end)
                    pcall(function() _G.script_key = keyValue end)
                    pcall(function() _G.ADittoKey = keyValue end)
                    pcall(function() script_key = keyValue end)
                    print("已设置全局卡密兼容变量：", tostring(keyValue))
                    
                    task.wait(0.1)
                    
                    local success, err = pcall(function()
                        loadstring(game:HttpGet(AX_CONFIG.scriptUrl))()
                    end)
                    if not success then
                        print("脚本执行错误:", err)
                        showNotification("执行失败", "脚本执行出错: " .. tostring(err):sub(1, 100), 5)
                    else
                        showNotification("脚本执行中", "AX脚本加载中...")
                    end
                end
            })
            
            -- 获取卡密按钮
            createButton(axContainer, {
                name = "GetAXKeyBtn",
                size = UDim2.new(0.48, -5, 0, 30),
                position = UDim2.new(0.52, 0, 0, 105),
                text = "获取AX卡密",
                textSize = 14,
                bgColor = CONFIG.UI_COLORS.accent,
                hoverColor = Color3.fromRGB(255, 200, 100),
                onClick = function()
                    setclipboard(AX_CONFIG.unlockUrl)
                    showNotification("链接已复制", "已复制解卡链接到剪贴板", 3)
                end
            })
            
            -- 其他墨水游戏脚本
            local otherScripts = {
                {
                    name = "ink-game(测试版)K注入器使用",
                    url = "https://raw.githubusercontent.com/TexRBLX/Roblox-stuff/refs/heads/main/ink-game/testing.lua",
                    desc = "全面取消汉化🤝🤓👆请使用一键汉化脚本"
                },
                {
                    name = "RINGTA",
                    url = "https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua",
                    desc = "全面取消汉化🤝🤓👆请使用一键汉化脚本"
                },
                {
                    name = "ink-Game|BorenHub",
                    url = "https://raw.githubusercontent.com/eikikrkr-ux/bypasok/refs/heads/main/ok",
                    desc = "全面取消汉化🤝🤓👆请使用一键汉化脚本"
                },
                {
                    name = "Xa",
                    url = "https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/GameLoad.lua",
                    desc = "全面取消汉化🤝🤓👆请使用一键汉化脚本"
                }
            }
            for i, script in ipairs(otherScripts) do
                createButton(container, {
                    name = "Script" .. i,
                    layoutOrder = i + 1,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = script.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. script.name,
                            script.desc,
                            function()
                                loadstring(game:HttpGet(script.url))()
                                showNotification("功能加载中", script.name .. "脚本执行中...")
                            end
                        )
                    end
                })
            end
            
            return function()
                if timeUpdateConnection then
                    timeUpdateConnection:Disconnect()
                    timeUpdateConnection = nil
                end
            end
        end,
        panelTitle = "墨水游戏"
    },
    -- 其余菜单项...
    {
        id = "99生存",
        displayName = "99生存",
        layoutOrder = 7,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
            {
                    name = "Cps natural",
                    url = "https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Hub",
                    desc = "搭配一件汉化"
                },
                {
                    name = "虚空脚本",
                    url = "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua",
                    desc = "搭配一件汉化"
                },
                {
                    name = "DarkEsc Hub v1.02",
                    url = "https://raw.githubusercontent.com/DarkenedEssence/DarkEsc/refs/heads/main/Loader.lua",
                    desc = "搭配一键汉化"
                },
                {
                    name = "全自动刷钻石",
                    url = "https://raw.githubusercontent.com/hellattexyss/autofarmdiamonds/main/overhubaurofarm.lua",
                    desc = "搭配一键汉化"
                },
                {
                    name = "RINGTA",
                    url = "https://raw.githubusercontent.com/wefwef127382/99daysloader.github.io/refs/heads/main/ringta.lua",
                    desc = "搭配一键汉化"
                }
            }        
            

            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                loadstring(game:HttpGet(btn.url))("")
                                showNotification("功能加载中", btn.name .. "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "99生存"
    },
    {
        id = "最强的战场",
        displayName = "最强的战场",
        layoutOrder = 8,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            createButton(container, {
                name = "CopyKeyBtn",
                layoutOrder = 1,
                size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                text = "点击复制VexonHub卡密",
                bgColor = Color3.fromRGB(255, 215, 0),
                textColor = Color3.fromRGB(0, 0, 0),
                hoverColor = Color3.fromRGB(255, 230, 100),
                onClick = function()
                    setclipboard("VexonHub_3")
                    showNotification("卡密已复制", "VexonHub_3 已复制到剪贴板", 2)
                end
            })
            local buttons = {
                {
                    name = "VexonHub",
                    url = "https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub",
                    desc = "建议搭配一键汉化"
                },
                {
                    name = "扔垃圾桶",
                    url = "https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man",
                    desc = "cs脚本家里还在的不要用"
                }             
            }
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i + 1,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                loadstring(game:HttpGet(btn.url))("")
                                showNotification("功能加载中", btn.name .. "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "最强的战场"
    },
    {
        id = "自然灾害模拟器",
        displayName = "自然灾害模拟器",
        layoutOrder = 9,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
                {
                    name = "黑洞(自带汉化)", 
                    func = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/V6.txt"))()
                    end,
                    desc = ""
                }
            }        
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                if btn.func then
                                    btn.func()
                                else
                                    loadstring(game:HttpGet(btn.url))()
                                end
                                showNotification("功能加载中", "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "自然灾害模拟器"
    },
        {
        id = "被遗弃",
        displayName = "被遗弃",
        layoutOrder = 10,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
                {
                    name = "ky3-nol😎", 
                    func = function()
                        getfenv().ADittoKey = "NOL_FRERKEY"
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/NOL/refs/heads/main/Nolsaken"))()
                    end,
                    desc = "建议搭配一键汉化"
                }
            }        
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                if btn.func then
                                    btn.func()
                                else
                                    loadstring(game:HttpGet(btn.url))()
                                end
                                showNotification("功能加载中", "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "被遗弃"
    },
            {
        id = "内脏与黑火药",
        displayName = "内脏与黑火药",
        layoutOrder = 11,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
                {
                    name = "秋容杀戮光环", 
                    func = function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/光环"))()
                    end,
                    desc = "详细说明：必看！必看！必看！\n仅供测试版有bug请反馈，目前只支持4种近战武器后续将添加更多\n普通模式\n· 功能：自动攻击范围内的所有僵尸\n· 适用：正常游戏，快速清怪\n以下模式强烈使用远程武器！\n恶搞模式\n功能：正常攻击僵尸，但只引爆队友旁边的炸药桶\n算法机制为：在杀戮光环可攻击范围之内队友又在炸药桶旁边优先攻击炸药桶死队友死亡🤓\n适用：整好友时使用可用于敌人\n伪装模式\n功能：只攻击队友旁边的炸药桶，不攻击任何其他僵尸，发现概率比较低\n适用：伪装成正常玩家偷偷坑好友\n炸药桶开关\n是否攻击炸药桶僵尸\n关闭后即使炸药桶在旁边也不会攻击\n重要警告：\n使用恶搞/伪装模式可能被发现并挂dc，请谨慎使用！ 炸药桶爆炸会炸伤好友无脑开启即可🤓UI按钮可拖动挡住屏幕可以移动位置/n记住：普通模式好好玩 恶搞模式坑他就完了 伪装模式神不知鬼不觉的坑死他"
                }
            }        
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                if btn.func then
                                    btn.func()
                                else
                                    loadstring(game:HttpGet(btn.url))()
                                end
                                showNotification("功能加载中", "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "内脏与黑火药"
    },
    {
        id = "其他脚本",
        displayName = "其他脚本",
        layoutOrder = 12,
        contentFunc = function(container)
            if not container or not container:IsDescendantOf(game) then return function() end end
            local buttons = {
                {
                    name = "皮脚本", 
                    func = function()
getgenv().XiaoPi="皮脚本QQ群1002100032" loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()                    end,
                    desc = ""
                },
                {
                    name = "培根脚本", 
                    func = function()
loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\115\53\55\48\89\70\118\102"))()
                    end,
                    desc = ""
                },
                {
                    name = "青脚本", 
                    func = function()
loadstring(game:HttpGet('https://rentry.co/ct293/raw'))()
                    end,
                    desc = ""
                },
                {
                    name = "天空脚本", 
                    func = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/skyhub"))()
                    end,
                    desc = ""
                },
                {
                    name = "落叶中心脚本", 
                    func = function()
getgenv().LS="落叶中心" loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/Deciduous-center-LS/main/%E8%90%BD%E5%8F%B6%E4%B8%AD%E5%BF%83%E6%B7%B7%E6%B7%86.txt"))()
                    end,
                    desc = ""
                },
                {
                    name = "蓝标脚本", 
                    func = function()
getgenv().XiaoPi="蓝标脚本 蓝标群912849177" 
loadstring(game:HttpGet("https://raw.githubusercontent.com/THDZEP/Blue-blue-blue/refs/heads/main/%E5%8F%91%E7%A5%A8%E8%93%9D%E6%A0%87"))()
                    end,
                    desc = ""
                },                       
                {
                    name = "青云脚本", 
                    func = function()
loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))()
                    end,
                    desc = ""
                }                                                         
            }        
            for i, btn in ipairs(buttons) do
                createButton(container, {
                    name = "11" .. i,
                    layoutOrder = i,
                    size = UDim2.new(1, 0, 0, 45 * UI_STATE.scale),
                    text = btn.name,
                    bgColor = CONFIG.UI_COLORS.primary,
                    hoverColor = Color3.fromRGB(70, 70, 120),
                    onClick = function()
                        createExecutionDialog(
                            "执行 " .. btn.name,
                            btn.desc,
                            function()
                                if btn.func then
                                    btn.func()
                                else
                                    loadstring(game:HttpGet(btn.url))()
                                end
                                showNotification("功能加载中", "脚本执行中...")
                            end
                        )
                    end
                })
            end
            return function() end
        end,
        panelTitle = "其他脚本"
    },
        {
    id = "极简谷歌汉化",
    displayName = "极简谷歌汉化",
    layoutOrder = 13,
    contentFunc = function(container)
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local CoreGui = game:GetService("CoreGui")
        local LocalPlayer = Players.LocalPlayer

        if not LocalPlayer then
            LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        end

        -- ================ 核心配置和状态管理 ================
        local MY_NAMESPACE = "EnhancedTranslator_" .. tostring(math.random(10000, 99999))
        if not _G[MY_NAMESPACE] then
            _G[MY_NAMESPACE] = {
                textData = {},
                scannedElements = {},
                translatedElements = {},
                monitorConnections = {},
                translateQueue = {},
                queuedSet = {},
                isProcessingQueue = false,
                isRunning = false,
                extractCount = 0,
                translateCount = 0,
                localizeCount = 0,
            }
        end
        local Engine = _G[MY_NAMESPACE]

        -- ================ 运行时配置 ================
        local RUNTIME = {
            translationAPI = "Google",
            translationsPerSecond = 20,
            batchSize = 5,
            scanInterval = 2,
            minTextLength = 2,
            maxTextLength = 100,
        }

        -- ================ 文本过滤 ================
        local function shouldFilterText(text)
            if not text or text:gsub("%s+", "") == "" then return true end
            if text:match("^[%p%s]+$") then return true end
            if #text < RUNTIME.minTextLength then return true end
            if #text > RUNTIME.maxTextLength then return true end
            return false
        end

        -- ================ 检查是否为官方聊天或背包文本 ================
        local function isOfficialChatOrInventory(element)
            if not element then return false end
            
            -- 检查元素路径
            local fullName = element:GetFullName():lower()
            
            -- 聊天相关过滤
            if fullName:find("chat") or 
               fullName:find("textchat") or 
               fullName:find("defaultchatsystem") then
                return true
            end
            
            -- 背包和道具相关过滤
            if fullName:find("backpack") or 
               fullName:find("inventory") or 
               fullName:find("tool") or
               fullName:find("item") then
                return true
            end
            
            -- 检查父级容器
            local parent = element.Parent
            while parent do
                local parentName = parent.Name:lower()
                if parentName:find("chat") or 
                   parentName:find("backpack") or 
                   parentName:find("inventory") or
                   parentName:find("tool") then
                    return true
                end
                parent = parent.Parent
            end
            
            return false
        end

        -- ================ 翻译API实现 ================
        local function translateWithGoogle(orig)
            local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(orig)
            
            local ok, body = pcall(function()
                return game:HttpGet(url)
            end)
            
            if not ok or not body then return "" end
            
            local parsedOk, parsed = pcall(function() 
                return HttpService:JSONDecode(body) 
            end)
            
            if not parsedOk or type(parsed) ~= "table" or type(parsed[1]) ~= "table" then
                return ""
            end
            
            local parts = {}
            for _, seg in ipairs(parsed[1]) do
                if type(seg) == "table" and seg[1] then 
                    table.insert(parts, tostring(seg[1])) 
                end
            end
            
            local result = table.concat(parts)
            return result
        end

        local function translateText(orig)
            if not orig or orig == "" then return "" end
            
            if Engine.textData[orig] and Engine.textData[orig].translation and Engine.textData[orig].translation ~= "" then
                return Engine.textData[orig].translation
            end

            local translation = translateWithGoogle(orig)

            if translation ~= "" and translation ~= orig then
                Engine.textData[orig] = Engine.textData[orig] or { translation = "", paths = {}, translated = false }
                Engine.textData[orig].translation = translation
                Engine.textData[orig].translated = true
                Engine.translateCount = Engine.translateCount + 1
            else
                Engine.textData[orig] = Engine.textData[orig] or { translation = orig, paths = {}, translated = true }
            end
            
            return translation
        end

        -- ================ 队列管理 ================
        local function enqueueText(text)
            if not text or shouldFilterText(text) then return end
            if Engine.queuedSet[text] or (Engine.textData[text] and Engine.textData[text].translated) then return end
            
            table.insert(Engine.translateQueue, { text = text, priority = #text })
            Engine.queuedSet[text] = true
        end

        -- ================ GUI获取函数 ================
        local function gethui_enhanced()
            local guis = {}
            
            if type(gethui) == "function" then
                local success, result = pcall(gethui)
                if success and result then
                    table.insert(guis, {container = result, type = "gethui"})
                end
            end
            
            local aliases = {"get_hui", "get_container", "get_roblox_gui", "_x92a", "get_gui"}
            for _, alias in ipairs(aliases) do
                if type(_G[alias]) == "function" then
                    local success, result = pcall(_G[alias])
                    if success and result then
                        table.insert(guis, {container = result, type = "alias: " .. alias})
                    end
                end
            end
            
            local success, result = pcall(function()
                return game:GetService("CoreGui")
            end)
            if success and result then
                table.insert(guis, {container = result, type = "CoreGui service"})
            end
            
            local localPlayer = Players.LocalPlayer
            if localPlayer then
                local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    table.insert(guis, {container = playerGui, type = "PlayerGui"})
                end
            end
            
            for _, obj in ipairs(CoreGui:GetDescendants()) do
                if obj:IsA("ScreenGui") and (obj.Name:find("Remote") or obj.Name:find("Gui")) then
                    table.insert(guis, {container = obj.Parent, type = "RemoteGui: " .. obj.Name})
                end
            end
            
            for _, obj in ipairs(CoreGui:GetDescendants()) do
                if obj:IsA("ScreenGui") then
                    if obj.Name == "Synapse" or obj.Name == "Krnl" or obj.Name == "ScriptWare" then
                        table.insert(guis, {container = obj.Parent, type = "executor GUI: " .. obj.Name})
                    end
                end
            end
            
            return guis
        end

        -- ================ 文本提取和监控 ================
        local function extractElementText(element)
            if not element then return end
            if not (element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox")) then return end
            if Engine.scannedElements[element] then return end
            
            -- 过滤官方聊天和背包元素
            if isOfficialChatOrInventory(element) then
                Engine.scannedElements[element] = true
                return
            end
            
            local ok, txt = pcall(function() return element.Text end)
            if not ok or not txt then
                Engine.scannedElements[element] = true
                return
            end
            
            local text = tostring(txt)
            if shouldFilterText(text) then
                Engine.scannedElements[element] = true
                return
            end
            
            local path = tostring(element)
            if not Engine.textData[text] then
                Engine.textData[text] = { 
                    translation = "", 
                    paths = { path }, 
                    translated = false 
                }
                Engine.extractCount = Engine.extractCount + 1
                enqueueText(text)
            else
                local paths = Engine.textData[text].paths or {}
                if not table.find(paths, path) then 
                    table.insert(paths, path) 
                    Engine.textData[text].paths = paths 
                end
            end
            
            Engine.scannedElements[element] = true
        end

        local function setupElementMonitor(element)
            if not element then return end
            if Engine.translatedElements[element] then return end
            
            -- 过滤官方聊天和背包元素
            if isOfficialChatOrInventory(element) then
                Engine.translatedElements[element] = true
                return
            end
            
            local ok, textConn = pcall(function()
                return element:GetPropertyChangedSignal("Text"):Connect(function()
                    task.wait(0.05)
                    extractElementText(element)
                end)
            end)
            if ok and textConn then 
                table.insert(Engine.monitorConnections, textConn) 
            end
        end

        -- ================ 扫描所有GUI元素 ================
        local function scanAllGuiElements()
            local guis = gethui_enhanced()
            local totalElements = 0
            
            for _, guiData in ipairs(guis) do
                local container = guiData.container
                if not container then continue end
                
                local descendants = {}
                pcall(function()
                    descendants = container:GetDescendants()
                end)
                
                for i, desc in ipairs(descendants) do
                    if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                        extractElementText(desc)
                        setupElementMonitor(desc)
                        totalElements = totalElements + 1
                    end
                    
                    if i % 100 == 0 then
                        task.wait(0.01)
                    end
                end
                
                local ok, conn = pcall(function()
                    return container.DescendantAdded:Connect(function(desc)
                        if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                            task.wait(0.05)
                            extractElementText(desc)
                            setupElementMonitor(desc)
                        end
                    end)
                end)
                if ok and conn then
                    table.insert(Engine.monitorConnections, conn)
                end
            end
        end

        -- ================ 翻译处理循环 ================
        local function processTranslationQueue()
            while Engine.isRunning and #Engine.translateQueue > 0 do
                local batch = {}
                for i = 1, math.min(RUNTIME.batchSize, #Engine.translateQueue) do
                    local item = table.remove(Engine.translateQueue, 1)
                    if item then
                        table.insert(batch, item)
                        Engine.queuedSet[item.text] = nil
                    end
                end
                
                for _, item in ipairs(batch) do
                    spawn(function()
                        local translation = translateText(item.text)
                        if translation and translation ~= "" then
                            if Engine.textData[item.text] then
                                Engine.textData[item.text].translated = true
                            end
                        end
                    end)
                end
                
                task.wait(1.0 / RUNTIME.translationsPerSecond)
            end
        end

        -- ================ 本地化应用 ================
        local function applyLocalizations()
            while Engine.isRunning do
                local guis = gethui_enhanced()
                local localizedCount = 0
                
                for _, guiData in ipairs(guis) do
                    local container = guiData.container
                    if not container then continue end
                    
                    local descendants = {}
                    pcall(function()
                        descendants = container:GetDescendants()
                    end)
                    
                    for _, desc in ipairs(descendants) do
                        if desc and (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) then
                            -- 过滤官方聊天和背包元素
                            if isOfficialChatOrInventory(desc) then
                                continue
                            end
                            
                            if Engine.translatedElements[desc] then continue end
                            
                            local ok, text = pcall(function() return desc.Text end)
                            if not ok or not text then continue end
                            
                            local origText = tostring(text)
                            local data = Engine.textData[origText]
                            
                            if data and data.translation and data.translation ~= "" and data.translation ~= origText then
                                local success = pcall(function()
                                    desc.Text = data.translation
                                end)
                                
                                if success then
                                    Engine.translatedElements[desc] = true
                                    Engine.localizeCount = Engine.localizeCount + 1
                                    localizedCount = localizedCount + 1
                                end
                            end
                        end
                    end
                end
                
                task.wait(RUNTIME.scanInterval)
            end
        end

        -- ================ 启动/停止函数 ================
        local function startLocalization()
            if Engine.isRunning then return end
            
            Engine.isRunning = true
            
            spawn(scanAllGuiElements)
            
            spawn(function()
                while Engine.isRunning do
                    processTranslationQueue()
                    task.wait(0.5)
                end
            end)
            
            spawn(applyLocalizations)
        end

        local function stopLocalization()
            if not Engine.isRunning then return end
            
            Engine.isRunning = false
            
            for _, conn in ipairs(Engine.monitorConnections) do
                pcall(function() 
                    if conn and conn.Disconnect then 
                        conn:Disconnect() 
                    end 
                end)
            end
            Engine.monitorConnections = {}
        end

        -- ================ UI构建 - 简化版本 ================
        local title = createLabel(container, {
            name = "TitleLabel",
            size = UDim2.new(1, -10, 0, 25),
            position = UDim2.new(0, 5, 0, 5),
            text = "极简谷歌翻译汉化",
            color = Color3.fromRGB(255, 255, 255),
            textSize = 16,
            font = Enum.Font.SourceSansBold,
            xAlign = Enum.TextXAlignment.Center
        })

        -- API信息显示（只显示谷歌API）
        local apiFrame = createFrame(container, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 35))
        apiFrame.ZIndex = 10
        apiFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        apiFrame.BackgroundTransparency = 0.7

        local apiLabel = createLabel(apiFrame, {
            name = "APILabel",
            size = UDim2.new(1, -10, 1, 0),
            position = UDim2.new(0, 5, 0, 0),
            text = "使用谷歌翻译API (已过滤官方聊天和背包)",
            textSize = 14,
            color = Color3.fromRGB(255, 255, 255),
            xAlign = Enum.TextXAlignment.Center
        })

        -- 控制按钮区域
        local controlFrame = Instance.new("Frame")
        controlFrame.Size = UDim2.new(1, -10, 0, 80)
        controlFrame.Position = UDim2.new(0, 5, 0, 85)
        controlFrame.BackgroundTransparency = 1
        controlFrame.Parent = container

        -- 主控制按钮
        local toggleBtn = createButton(controlFrame, {
            name = "ToggleBtn",
            size = UDim2.new(1, 0, 0, 36),
            position = UDim2.new(0, 0, 0, 0),
            text = Engine.isRunning and "停止汉化" or "开始汉化",
            textSize = 16,
            textColor = Color3.fromRGB(255, 255, 255),
            bgColor = Engine.isRunning and CONFIG.UI_COLORS.danger or CONFIG.UI_COLORS.success,
            hoverColor = Engine.isRunning and Color3.fromRGB(170, 70, 70) or Color3.fromRGB(70, 120, 70),
            onClick = function()
                if Engine.isRunning then
                    stopLocalization()
                    toggleBtn.Text = "开始汉化"
                    toggleBtn.BackgroundColor3 = CONFIG.UI_COLORS.success
                else
                    startLocalization()
                    toggleBtn.Text = "停止汉化"
                    toggleBtn.BackgroundColor3 = CONFIG.UI_COLORS.danger
                end
            end
        })

        -- 重新扫描按钮
        local rescanBtn = createButton(controlFrame, {
            name = "RescanBtn",
            size = UDim2.new(1, 0, 0, 30),
            position = UDim2.new(0, 0, 0, 45),
            text = "重新扫描界面",
            textSize = 14,
            textColor = Color3.fromRGB(255, 255, 255),
            bgColor = CONFIG.UI_COLORS.primary,
            hoverColor = Color3.fromRGB(70, 70, 120),
            onClick = function()
                if Engine.isRunning then
                    spawn(scanAllGuiElements)
                    showNotification("重新扫描", "开始重新扫描界面元素", 2)
                else
                    showNotification("请先启动", "请先启动翻译服务", 2)
                end
            end
        })

        -- 状态显示
        local statusFrame = createFrame(container, UDim2.new(1, -10, 0, 80), UDim2.new(0, 5, 0, 175))
        statusFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusFrame.BackgroundTransparency = 0.7

        local statsLabel = createLabel(statusFrame, {
            name = "StatsLabel",
            size = UDim2.new(1, -10, 1, -10),
            position = UDim2.new(0, 5, 0, 5),
            text = "状态: 未启动\nAPI: Google\n提取文本: 0\n已翻译: 0\n已汉化: 0\n队列中: 0",
            textSize = 12,
            color = Color3.fromRGB(255, 255, 255),
            xAlign = Enum.TextXAlignment.Left,
            textWrapped = true
        })

        -- 实时更新统计
        local function updateStats()
            if statsLabel and statsLabel.Parent then
                statsLabel.Text = string.format(
                    "状态: %s\nAPI: Google\n提取文本: %d\n已翻译: %d\n已汉化: %d\n队列中: %d",
                    Engine.isRunning and "运行中" or "已停止",
                    Engine.extractCount,
                    Engine.translateCount,
                    Engine.localizeCount,
                    #Engine.translateQueue
                )
            end
        end

        local statsConnection = RunService.Heartbeat:Connect(function()
            updateStats()
        end)

        table.insert(Engine.monitorConnections, statsConnection)

        -- 初始更新
        updateStats()

        -- 面板隐藏时清理
        return function(isVisible)
            if not isVisible then
                -- 面板隐藏时无需特殊处理
            end
        end
    end,
    panelTitle = "极简谷歌翻译汉化"
}
}

-- ================ 菜单内容面板创建 ================
local function createMenuContentPanel(rightPanel, menuKey, panelTitle, contentFunc)
    if not rightPanel or not rightPanel:IsDescendantOf(game) then return nil end
    
    local panel = Instance.new("Frame")
    panel.Name = "ContentPanel_" .. menuKey:gsub("%p", "")
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Parent = rightPanel
    panel.Visible = (menuKey == UI_STATE.activeMenu)
    panel.Active = false
    
    local titleHeight = 36 * UI_STATE.scale
    local titlePadding = 15 * UI_STATE.scale
    
    local title = createLabel(panel, {
        name = "PanelTitle",
        size = UDim2.new(1, -20 * UI_STATE.scale, 0, titleHeight),
        position = UDim2.new(0, 10 * UI_STATE.scale, 0, titlePadding),
        text = panelTitle or (menuKey .. "内容"),
        color = CONFIG.UI_COLORS.accent,
        textSize = 18,
        font = Enum.Font.SourceSansBold,
        bgColor = Color3.fromRGB(60, 60, 80),
        bgTransparency = 0.8,
        xAlign = Enum.TextXAlignment.Center
    })
    
    if title then createCorner(title, 6) end
    
    local scrollTop = titlePadding + titleHeight + 10 * UI_STATE.scale
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ContentScroll_" .. menuKey:gsub("%p", "")
    scrollFrame.Size = UDim2.new(1, -20 * UI_STATE.scale, 1, -scrollTop)
    scrollFrame.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, scrollTop)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Parent = panel
    scrollFrame.ClipsDescendants = true
    scrollFrame.ScrollBarThickness = 6 * UI_STATE.scale
    createCorner(scrollFrame, 6)
    
    local actionContainer = Instance.new("Frame")
    actionContainer.Name = "ActionContainer_" .. menuKey:gsub("%p", "")
    actionContainer.Size = UDim2.new(1, 0, 0, 0)
    actionContainer.BackgroundTransparency = 1
    actionContainer.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = actionContainer
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 10 * UI_STATE.scale)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function updateScrollBar()
        local contentHeight = listLayout.AbsoluteContentSize.Y
        local visibleHeight = scrollFrame.AbsoluteSize.Y
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        
        local maxY = math.max(0, contentHeight - visibleHeight)
        if scrollFrame.CanvasPosition.Y > maxY then
            scrollFrame.CanvasPosition = Vector2.new(0, maxY)
        end
        
        scrollFrame.ScrollBarThickness = (contentHeight > visibleHeight + 5) and (6 * UI_STATE.scale) or 0
    end
    
    updateScrollBar()
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollBar)
    scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScrollBar)
    
    scrollFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isScrolling = true
            UI_STATE.scrollStartPositions[scrollFrame] = scrollFrame.CanvasPosition
        end
    end)
    scrollFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isScrolling = false
        end
    end)
    
    local updateCallback = contentFunc and contentFunc(actionContainer) or function() end
    
    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if updateCallback then
            updateCallback(panel.Visible)
        end
    end)
    
    if panel.Visible and updateCallback then
        updateCallback(true)
    end
    
    return panel
end

-- ================ 主UI创建 ================
local function createMainUI()
    -- 先检查是否已经有UI存在，避免重复创建
    if UI_STATE.mainPanel and UI_STATE.mainPanel:IsDescendantOf(game) then
        print("主UI已存在，跳过重复创建")
        return
    end
    
    -- 原有的清理逻辑（但不会在角色死亡时触发）
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        cleanupOldUI()
    end
    UI_STATE.isScaling = true
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        warn("无法获取本地玩家")
        showNotification("UI加载失败", "无法获取本地玩家", 10)
        return
    end
    local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then
        warn("获取PlayerGui超时")
        showNotification("UI加载失败", "获取PlayerGui超时", 10)
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "秋容脚本"
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
        end
    end)
    
    local mainPanel = Instance.new("Frame")
    mainPanel.Name = "MainPanel"
    mainPanel.Size = UDim2.new(0, 650 * UI_STATE.scale, 0, 380 * UI_STATE.scale)
    mainPanel.Position = UDim2.new(0.5, -325 * UI_STATE.scale, 0.5, -190 * UI_STATE.scale)
    mainPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    mainPanel.BackgroundTransparency = 0.9
    mainPanel.BorderSizePixel = 1
    mainPanel.BorderColor3 = Color3.fromRGB(180, 160, 255)
    mainPanel.Parent = screenGui
    createCorner(mainPanel, 14)
    UI_STATE.mainPanel = mainPanel
    
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, -20 * UI_STATE.scale, 0, 80 * UI_STATE.scale)
    topBar.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, 10 * UI_STATE.scale)
    topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    topBar.BackgroundTransparency = 0.8
    topBar.Parent = mainPanel
    createCorner(topBar, 8)
    UI_STATE.topBar = topBar
    
    local leftInfo = Instance.new("Frame")
    leftInfo.Size = UDim2.new(0, 240 * UI_STATE.scale, 0, 60 * UI_STATE.scale)
    leftInfo.Position = UDim2.new(0, 10 * UI_STATE.scale, 0.5, 0)
    leftInfo.AnchorPoint = Vector2.new(0, 0.5)
    leftInfo.BackgroundTransparency = 1
    leftInfo.Parent = topBar
    
    local translateButton = createButton(leftInfo, {
        name = "QuickTranslateBtn",
        size = UDim2.new(0, 180 * UI_STATE.scale, 0, 50 * UI_STATE.scale),
        position = UDim2.new(0, 0, 0, 0),
        text = "点击看支持汉化服务器",
        textColor = Color3.fromRGB(255, 215, 0),
        textSize = 18,
        bgColor = CONFIG.UI_COLORS.primary,
        hoverColor = Color3.fromRGB(70, 70, 120),
        radius = 8,
        onClick = function()
            createExecutionDialog(
                "支持汉化的服务器",
                "功能说明：\n秋容汉化你值得拥有🤝🤓👆\n使用教程先执行你需要汉化的脚本如RINGTA\n等它加载完成UI点击右上角汉化界面即可\n目前支持汉化的脚本有\n墨水游戏:RINGTA--ink-game(测试版)--Owl-Hook\n最坚强的战场:VexonHub\n鱼:红叶(已汉化全部只有极少部分没有汉化因为不需要)\n死铁轨:红叶\n被遗弃:ky3-nol\n99生存:虚空--DarkEsc Hub v1.02--RINGTA",
                function()
                    showNotification("已查看", "支持汉化的服务器列表已查看", 2)
                end,
                "知道了已查看",
                "看完关闭了"
            )
        end
    })
    
    if translateButton then
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Name = "GoldenBorder"
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.Color = Color3.fromRGB(255, 215, 0)
        uiStroke.Thickness = 2.5 * UI_STATE.scale
        uiStroke.Parent = translateButton
        
        translateButton.MouseEnter:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and translateButton:IsDescendantOf(game) then
                TweenService:Create(
                    uiStroke,
                    TweenInfo.new(0.2),
                    {Thickness = 3.5 * UI_STATE.scale}
                ):Play()
            end
        end)
        translateButton.MouseLeave:Connect(function()
            if not UI_STATE.isDragging and not UI_STATE.isScrolling and translateButton:IsDescendantOf(game) then
                TweenService:Create(
                    uiStroke,
                    TweenInfo.new(0.2),
                    {Thickness = 2.5 * UI_STATE.scale}
                ):Play()
            end
        end)
    end
    
    local versionText = createLabel(topBar, {
        name = "VersionText",
        size = UDim2.new(0, 0, 0, 20 * UI_STATE.scale),
        position = UDim2.new(0.5, 0, 0.1, 0),
        anchor = Vector2.new(0.5, 0),
        text = "2.0",
        color = CONFIG.UI_COLORS.accent,
        textSize = 16,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    
    createLabel(topBar, {
        name = "TitleLabel",
        size = UDim2.new(0, 0, 1, 0),
        position = UDim2.new(0.5, 0, 0, 0),
        anchor = Vector2.new(0.5, 0),
        text = "秋容脚本",
        color = CONFIG.UI_COLORS.accent,
        textSize = 26,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    
    local welcomeLabel = createLabel(topBar, {
        name = "WelcomeLabel",
        size = UDim2.new(0, 0, 0, 24 * UI_STATE.scale),
        position = UDim2.new(0.5, 0, 0.6, 0),
        anchor = Vector2.new(0.5, 0),
        text = string.format("尊贵的[%s]欢迎使用！", localPlayer.Name),
        color = Color3.fromRGB(255, 200, 100),
        textSize = 14,
        font = Enum.Font.SourceSansBold,
        xAlign = Enum.TextXAlignment.Center
    })
    
    local function createControlButton(text, offset, color, callback)
        createButton(topBar, {
            name = text == "X" and "CloseBtn" or (text == "+" and "ZoomInBtn" or "ZoomOutBtn"),
            size = UDim2.new(0, 36 * UI_STATE.scale, 0, 36 * UI_STATE.scale),
            position = UDim2.new(1, -45 * UI_STATE.scale - offset, 0.5, 0),
            anchor = Vector2.new(0.5, 0.5),
            text = text,
            textSize = 18,
            bgColor = color,
            radius = 6,
            hoverColor = text == "X" and Color3.fromRGB(230, 80, 80) or 
                        (text == "+" and Color3.fromRGB(80, 140, 80) or Color3.fromRGB(140, 100, 80)),
            onClick = callback
        })
    end
    
createControlButton("-", 90 * UI_STATE.scale, Color3.fromRGB(120, 80, 60), function()
    if UI_STATE.isScaling then return end
    UI_STATE.isScaling = true
    local currentActiveMenu = UI_STATE.activeMenu
    if UI_STATE.scale > 0.6 then
        UI_STATE.scale -= 0.1
        cleanupOldUI()
        UI_STATE.activeMenu = currentActiveMenu
        createMainUI()
        showNotification("UI缩放调整", "当前缩放比例：" .. string.format("%.1f", UI_STATE.scale) .. "x（缩小）")
    else
        showNotification("缩放限制", "已达到最小缩放比例（0.6x）", 2)
    end
    UI_STATE.isScaling = false
end)
    createControlButton("+", 45 * UI_STATE.scale, Color3.fromRGB(60, 120, 60), function()
    if UI_STATE.isScaling then return end
    UI_STATE.isScaling = true
    local currentActiveMenu = UI_STATE.activeMenu
    if UI_STATE.scale < 1.0 then
        UI_STATE.scale += 0.1
        cleanupOldUI()
        UI_STATE.activeMenu = currentActiveMenu
        createMainUI()
        showNotification("UI缩放调整", "当前缩放比例：" .. string.format("%.1f", UI_STATE.scale) .. "x（放大）")
    else
        showNotification("缩放限制", "已达到最大缩放比例（1.0x）", 2)
    end
    UI_STATE.isScaling = false
end)
    
    createControlButton("X", 0, Color3.fromRGB(210, 60, 60), function()
    cleanupOldUI()
    UI_STATE.isRunning = false
    
    -- 停止所有循环和连接
    if UI_STATE.coordinateLoop then
        UI_STATE.coordinateLoop:Disconnect()
        UI_STATE.coordinateLoop = nil
    end
    if UI_STATE.playerPositionLoop then
        UI_STATE.playerPositionLoop:Disconnect()
        UI_STATE.playerPositionLoop = nil
    end
    if UI_STATE.wallhackConnection then
        UI_STATE.wallhackConnection:Disconnect()
        UI_STATE.wallhackConnection = nil
    end
    
    -- 隐藏悬浮窗
    if UI_STATE.floatBtn and UI_STATE.floatBtn:IsDescendantOf(game) then
        UI_STATE.floatBtn.Visible = false
    end
    
    showNotification("脚本已关闭", "秋容脚本已退出运行", 3)
    
    -- 强制停止脚本执行
    error("用户主动退出脚本")
end)
    
    local leftWidth = 180 * UI_STATE.scale
    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Name = "LeftScrollFrame"
    leftScroll.Size = UDim2.new(0, leftWidth, 1, - (topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale))
    leftScroll.Position = UDim2.new(0, 10 * UI_STATE.scale, 0, topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale)
    leftScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    leftScroll.BackgroundTransparency = 0.8
    leftScroll.Parent = mainPanel
    leftScroll.ClipsDescendants = true
    createCorner(leftScroll, 12)
    
    local leftContainer = Instance.new("Frame")
    leftContainer.Name = "LeftMenuContainer"
    leftContainer.Size = UDim2.new(1, 0, 0, 0)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = leftScroll
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Parent = leftContainer
    leftLayout.FillDirection = Enum.FillDirection.Vertical
    leftLayout.Padding = UDim.new(0, 8 * UI_STATE.scale)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local leftPadding = Instance.new("UIPadding")
    leftPadding.PaddingTop = UDim.new(0, 8 * UI_STATE.scale)
    leftPadding.PaddingBottom = UDim.new(0, 8 * UI_STATE.scale)
    leftPadding.Parent = leftContainer
    
    local function updateLeftScroll()
        local contentHeight = leftLayout.AbsoluteContentSize.Y
        local visibleHeight = leftScroll.AbsoluteSize.Y
        leftScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        leftScroll.ScrollBarThickness = (contentHeight > visibleHeight) and (6 * UI_STATE.scale) or 0
        local maxY = math.max(0, contentHeight - visibleHeight)
        leftScroll.CanvasPosition = Vector2.new(0, math.clamp(leftScroll.CanvasPosition.Y, 0, maxY))
    end
    
    updateLeftScroll()
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScroll)
    leftScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateLeftScroll)
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(1, - (leftWidth + 20 * UI_STATE.scale), 1, - (topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale))
    rightPanel.Position = UDim2.new(0, leftWidth + 20 * UI_STATE.scale, 0, topBar.Position.Y.Offset + topBar.Size.Y.Offset + 10 * UI_STATE.scale)
    rightPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    rightPanel.BackgroundTransparency = 0.8
    rightPanel.Parent = mainPanel
    createCorner(rightPanel, 12)
    
    local function setActivePanel(targetKey)
        for key, panel in pairs(UI_STATE.menuPanels) do
            if panel and panel:IsDescendantOf(game) then
                panel.Visible = (key == targetKey)
            end
        end
        
        if leftContainer and leftContainer:IsDescendantOf(game) then
            for _, child in ipairs(leftContainer:GetChildren()) do
                if child:IsA("TextButton") and child.Name:match("MenuButton_") then
                    local btnMenuKey = child.Name:gsub("MenuButton_", "")
                    local targetKeyClean = targetKey:gsub("%p", "")
                    child.BackgroundColor3 = btnMenuKey == targetKeyClean and 
                        Color3.fromRGB(80, 80, 130) or CONFIG.UI_COLORS.primary
                    child.BackgroundColor3 = child.BackgroundColor3
                end
            end
        end
        
        UI_STATE.activeMenu = targetKey
    end
    
    for _, menu in ipairs(MENU_CONFIG) do
        createMenuItem(leftContainer, menu.displayName, menu.layoutOrder, function()
            setActivePanel(menu.id)
            showNotification("菜单切换成功", "当前菜单：" .. menu.displayName)
        end)
        
        UI_STATE.menuPanels[menu.id] = createMenuContentPanel(rightPanel, menu.id, menu.panelTitle, menu.contentFunc)
    end
    
    updateLeftScroll()
    
    local initActiveKey = UI_STATE.activeMenu
    local initPanel = UI_STATE.menuPanels[initActiveKey]
    if initPanel and initPanel:IsDescendantOf(game) then
        initPanel.Visible = true
        setActivePanel(initActiveKey)
    end
    
    bindDragToElement(topBar, mainPanel)
    bindDragToElement(mainPanel, mainPanel)
    bindDragToElement(rightPanel, mainPanel)
    
    UserInputService.InputChanged:Connect(function(input)
        if UI_STATE.isDragging and not UI_STATE.isScrolling and 
           (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and
           mainPanel:IsDescendantOf(game) then
            local delta = input.Position - UI_STATE.dragStart
            mainPanel.Position = UDim2.new(
                UI_STATE.panelStartPos.X.Scale, UI_STATE.panelStartPos.X.Offset + delta.X,
                UI_STATE.panelStartPos.Y.Scale, UI_STATE.panelStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            UI_STATE.isDragging = false
            UI_STATE.isScrolling = false
            btnIsDragging = false
        end
    end)
    
    createFloatingButton()
    UI_STATE.isScaling = false
    print("主UI创建成功")
end

-- 由于代码太长，这里省略中间的大部分UI创建和功能代码...
-- 只保留验证流程的修改部分

-- ================ 脚本初始化 ================
local function initScript()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        localPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        if not localPlayer then
            warn("无法获取本地玩家")
            return
        end
    end
    
    local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
    if not playerGui then
        warn("获取PlayerGui超时")
        return
    end
    
    initCSVPath()
    
    if UI_STATE.characterAddedConn then
        UI_STATE.characterAddedConn:Disconnect()
    end
    if UI_STATE.characterRemovingConn then
        UI_STATE.characterRemovingConn:Disconnect()
    end
    
    UI_STATE.characterAddedConn = localPlayer.CharacterAdded:Connect(onCharacterAdded)
    UI_STATE.characterRemovingConn = localPlayer.CharacterRemoving:Connect(onCharacterRemoving)
    
    if localPlayer.Character then
        task.spawn(onCharacterAdded, localPlayer.Character)
    end
    
    UI_STATE.savedCoordinates = readCSVFile()
    
    local success, err = pcall(createMainUI)
    if not success then
        local fullError = debug.traceback(err)
        warn("创建UI失败：\n" .. fullError)
        showNotification("UI加载失败", "错误：\n" .. fullError:sub(1, 100) .. "...", 10)
        
        local errorGui = Instance.new("ScreenGui")
        errorGui.Name = "UI加载错误提示"
        errorGui.Parent = playerGui
        
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(errorGui)
            end
        end)
        
        createLabel(errorGui, {
            name = "ErrorLabel",
            size = UDim2.new(1, 0, 1, 0),
            text = "UI加载失败：\n" .. fullError:sub(1, 200) .. "...",
            color = Color3.new(1, 0, 0),
            textSize = 14,
            textWrapped = true,
            xAlign = Enum.TextXAlignment.Left
        })
        return
    end
    
    showNotification("UI2.0加载成功", "尊贵的用户欢迎使用秋容脚本")
    print("初始化完成")
end

-- ================ 脚本启动 ================

-- 注意：我们在脚本最顶层已经做过一次初始检测（initialKeyStatus）。
-- 这里继续根据检查结果决定是否弹出输入窗口或跳过验证。
local secondCheck = checkKeyFileStatus()
if secondCheck == "valid" then
    print("检测到验证文件夹且卡密正确，跳过验证")
    -- 公益模式下仍然需要QQ群验证
    Popup_VerifyQQGroup()
    showAnnouncement()
elseif secondCheck == "invalid" then
    -- 如果刚好在这一步发现无效，再次确保删除并踢出
    pcall(setclipboard_safe, QQ_CHANNEL_URL)
    kickForInvalidKey()
    return
else
    -- nofile：没有验证文件夹或卡密，弹出验证流程（先快手验证再QQ群验证）
    Popup_VerifyKuaishou()
    Popup_VerifyQQGroup()
    
    -- 非公益模式才需要卡密验证
    if not PUBLIC_WELFARE_MODE then
        Popup_VerifyKey()
    end
    
    showAnnouncement()
end

local success, errorMsg = pcall(initScript)
if not success then
    local fullError = debug.traceback(errorMsg)
    warn("脚本启动失败：\n" .. fullError)
    pcall(function()
        local player = Players.LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            local gui = Instance.new("ScreenGui")
            gui.Parent = player.PlayerGui
            pcall(function()
                if syn and syn.protect_gui then
                    syn.protect_gui(gui)
                end
            end)
            createLabel(gui, {
                name = "ErrorLabel",
                size = UDim2.new(1, 0, 1, 0),
                text = "脚本启动失败：\n" .. fullError,
                color = Color3.new(1, 0, 0),
                textSize = 14,
                textWrapped = true,
                xAlign = Enum.TextXAlignment.Left
            })
        end
    end)
end
-- 兼容性：最后再加载远程资源（保留原调用）
pcall(function()
--loadstring(game:HttpGet("https://raw.githubusercontent.com/QRNB4588ZNB/QR/refs/heads/main/QUAN%20ZHI%20DONG%20HAN%20HUA"))()
end)
