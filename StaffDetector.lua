--Rivals Only!!

xpcall(function()
    if (game.GameId ~= 6035872082) then return end
    if shared.StaffDetectorLoading then return end
    shared.StaffDetectorLoading = true
    repeat task.wait() until game:IsLoaded()
    local cloneref = cloneref or function(obj)
        return obj
    end

    local players = cloneref(game:GetService("Players"))
    local coregui = gethui() or cloneref(game:GetService("CoreGui"))
    local TS = game:GetService("TweenService")
    local TI = TweenInfo.new
    local http = game:GetService("HttpService")
    local lp = players.LocalPlayer
    local groupId = game.CreatorId
    local notify_sound = nil

    if game.CreatorType ~= Enum.CreatorType.Group then
        return
    end

    task.spawn(function()
        if not isfile("AntiLua/staffdetect.mp3") then writefile("AntiLua/staffdetect.mp3", tostring(game:HttpGetAsync("https://github.com/Ukrubojvo/api/raw/main/ap-disconnect-boeing.mp3"))) end
        notify_sound = Instance.new("Sound", workspace)
        notify_sound.SoundId = getcustomasset("AntiLua/staffdetect.mp3")
        notify_sound.Volume = 5
        notify_sound.Looped = true
    end)

    pcall(function()
        if not autoload then return end
        queue_on_teleport([[
            pcall(function()
                autoload = true;
                local GitRequests = loadstring(game:HttpGet("https://raw.githubusercontent.com/itchino/Roblox-GitRequests/refs/heads/main/GitRequests.lua"))()
                local Repo = GitRequests.Repo("Ukrubojvo", "Modules")
                loadstring(Repo:getFileContent("StaffDetector.lua"))()
            end)
        ]])
    end)

    local function fetchURL(url)
        local ok, res = pcall(game.HttpGet, game, url)
        if ok then
            local data = http:JSONDecode(res)
            return data
        end
        return nil
    end

    local function extractStaffRoleIds(groupId)
        local url = ("https://groups.roblox.com/v1/groups/%d/roles"):format(groupId)
        local data = fetchURL(url)
        local roleIds = {}

        if data and data.roles then
            for _, r in ipairs(data.roles) do
                local name = string.lower(r.name)
                if string.find(name, "mod") or string.find(name, "staff") or string.find(name, "contributor") 
                or string.find(name, "script") or string.find(name, "build") then
                    table.insert(roleIds, r.id)
                end
            end
        end

        return roleIds
    end

    local function fetchUsersInRole(groupId, roleId)
        local cursor = ""
        local collected = {}

        while true do
            local url = string.format("https://groups.roproxy.com/v1/groups/%d/roles/%d/users?limit=100&cursor=%s", groupId, roleId, cursor)

            local success, response = pcall(function()
                return game:HttpGet(url)
            end)

            if not success or not response then break end
            local json = http:JSONDecode(response)

            if json.data and type(json.data) == "table" then
                for _, user in ipairs(json.data) do
                    if user.userId then
                        collected[user.userId] = true
                    end
                end
            end

            if not json.nextPageCursor or json.nextPageCursor == "" then break end
            cursor = json.nextPageCursor
        end

        return collected
    end


    local staffRoleIds = extractStaffRoleIds(groupId)
    local staffUserIds = {}

    for _, roleId in ipairs(staffRoleIds) do
        local users = fetchUsersInRole(groupId, roleId)
        for uid, _ in pairs(users) do
            staffUserIds[uid] = true
        end
    end

    --[[
    local function GetUserRoleInGroup(userId, groupId)
        local url = string.format("https://groups.roproxy.com/v2/users/%d/groups/roles", userId)
        local success, response = pcall(game.HttpGet, game, url)
        if success then
            local data = http:JSONDecode(response)
            if data and data.data then
                for _, info in ipairs(data.data) do
                    if info.group and info.group.id == groupId then
                        return info.role and info.role.name or nil
                    end
                end
            end
        end
        return nil
    end
    ]]

    local function GetRole(plr, groupId)
        if plr and typeof(plr) == "Instance" then
            local method = plr.GetRoleInGroup
            if typeof(method) == "function" then
                return method(plr, groupId)
            end
        end
        return nil
    end

    local function isStaffRoleName(role)
        if role and typeof(role) == "string" then
            local r = string.lower(role)
            if string.find(r, "mod") or string.find(r, "staff") or string.find(r, "contributor") or string.find(r, "script") or string.find(r, "build") then
                return true
            end
        end
        return false
    end

    local function shortenName(name)
        if #name > 6 then
            return string.sub(name, 1, 6) .. "..."
        end
        return name
    end

    local function getStaffInfo()
        local total = #players:GetPlayers()
        local staffNames = {}
        for _, plr in ipairs(players:GetPlayers()) do
            local role = GetRole(plr, game.CreatorId)
            if isStaffRoleName(role) then
                table.insert(staffNames, shortenName(plr.Name))
            end
        end
        return staffNames, total
    end

    local function getFriendStaffInfo()
        local list = {}
        for _, plr in ipairs(players:GetPlayers()) do
            local ok, pages = pcall(function()
                return players:GetFriendsAsync(plr.UserId)
            end)
            if ok and pages then
                while true do
                    local page = pages:GetCurrentPage()
                    for _, friend in ipairs(page) do
                        if staffUserIds[friend.Id] then
                            table.insert(list, shortenName(friend.Username))
                        end
                    end
                    if pages.IsFinished then break end
                    pages:AdvanceToNextPageAsync()
                end
            end
        end
        return list
    end

    local function createLeaveUI(MessageText, OnYes, OnNo)
        local old = coregui:FindFirstChild("ModAlertLeaveUI")
        if old then return end

        local Gui = Instance.new("ScreenGui")
        Gui.Name = "ModAlertLeaveUI"
        Gui.ResetOnSpawn = false
        Gui.IgnoreGuiInset = true
        Gui.DisplayOrder = 2147483647
        Gui.Parent = coregui
        
        local Backdrop = Instance.new("Frame")
        Backdrop.Size = UDim2.new(1, 0, 1, 0)
        Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
        Backdrop.BackgroundTransparency = 1
        Backdrop.BorderSizePixel = 0
        Backdrop.Parent = Gui
        
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(0, 0, 0, 0)
        Container.Position = UDim2.new(0.5, 0, 0.5, 0)
        Container.AnchorPoint = Vector2.new(0.5, 0.5)
        Container.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        Container.BorderSizePixel = 0
        Container.ClipsDescendants = false
        Container.Parent = Gui
        
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 16)
        
        local GradientFrame = Instance.new("Frame")
        GradientFrame.Size = UDim2.new(1, 0, 0, 120)
        GradientFrame.BackgroundTransparency = 0.3
        GradientFrame.BorderSizePixel = 0
        GradientFrame.Parent = Container
        
        Instance.new("UICorner", GradientFrame).CornerRadius = UDim.new(0, 16)
        
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 40, 90)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 20))
        })
        Gradient.Rotation = 90
        Gradient.Parent = GradientFrame
        
        local Border = Instance.new("UIStroke")
        Border.Color = Color3.fromRGB(100, 80, 140)
        Border.Thickness = 1.5
        Border.Transparency = 0.4
        Border.Parent = Container
        
        local IconFrame = Instance.new("Frame")
        IconFrame.Size = UDim2.new(0, 52, 0, 52)
        IconFrame.Position = UDim2.new(0.5, 0, 0, 30)
        IconFrame.AnchorPoint = Vector2.new(0.5, 0)
        IconFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        IconFrame.BorderSizePixel = 0
        IconFrame.Parent = Container
        
        Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(1, 0)
        
        local IconGradient = Instance.new("UIGradient")
        IconGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 80))
        })
        IconGradient.Rotation = 45
        IconGradient.Parent = IconFrame
        
        local IconImage = Instance.new("ImageLabel")
        IconImage.Size = UDim2.new(0.6, 0, 0.6, 0)
        IconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
        IconImage.BackgroundTransparency = 1
        IconImage.Image = "rbxassetid://18797417802"
        IconImage.ImageColor3 = Color3.new(1, 1, 1)
        IconImage.Parent = IconFrame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -60, 0, 30)
        Title.Position = UDim2.new(0, 30, 0, 90)
        Title.BackgroundTransparency = 1
        Title.Text = "Moderator Detected"
        Title.TextColor3 = Color3.new(1, 1, 1)
        Title.TextSize = 20
        Title.Font = Enum.Font.GothamBold
        Title.Parent = Container
        
        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -60, 0, 40)
        Message.Position = UDim2.new(0, 30, 0, 120)
        Message.BackgroundTransparency = 1
        Message.Text = MessageText
        Message.RichText = true
        Message.TextColor3 = Color3.fromRGB(200, 200, 210)
        Message.TextSize = 15
        Message.Font = Enum.Font.Gotham
        Message.TextWrapped = true
        Message.Parent = Container
        
        local ButtonsFrame = Instance.new("Frame")
        ButtonsFrame.Size = UDim2.new(1, -60, 0, 48)
        ButtonsFrame.Position = UDim2.new(0, 30, 1, -68)
        ButtonsFrame.BackgroundTransparency = 1
        ButtonsFrame.Parent = Container
        
        local ButtonLayout = Instance.new("UIListLayout")
        ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ButtonLayout.Padding = UDim.new(0, 16)
        ButtonLayout.Parent = ButtonsFrame
        
        local function CreateButton(Text, Color)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 150, 1, 0)
            Btn.BackgroundColor3 = Color
            Btn.BorderSizePixel = 0
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = ButtonsFrame
            
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
            
            local BtnGradient = Instance.new("UIGradient")
            BtnGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(
                    math.max(Color.R * 255 - 20, 0),
                    math.max(Color.G * 255 - 20, 0),
                    math.max(Color.B * 255 - 20, 0)
                ))
            })
            BtnGradient.Rotation = 90
            BtnGradient.Parent = Btn
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.TextSize = 16
            Label.Font = Enum.Font.GothamBold
            Label.Parent = Btn
            
            Btn.MouseEnter:Connect(function()
                TS:Create(Btn, TI(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        math.min(Color.R * 255 + 15, 255),
                        math.min(Color.G * 255 + 15, 255),
                        math.min(Color.B * 255 + 15, 255)
                    ),
                    Size = UDim2.new(0, 155, 1, 2)
                }):Play()
            end)
            
            Btn.MouseLeave:Connect(function()
                TS:Create(Btn, TI(0.2), {
                    BackgroundColor3 = Color,
                    Size = UDim2.new(0, 150, 1, 0)
                }):Play()
            end)
            
            return Btn, Label
        end
        
        local YesBtn, YesLabel = CreateButton("Leave Server", Color3.fromRGB(220, 80, 80))
        local NoBtn, NoLabel = CreateButton("Stay Here", Color3.fromRGB(80, 140, 220))
        
        local function FadeOut(callback)
            local function FadeAllDescendants(obj)
                for _, v in ipairs(obj:GetDescendants()) do
                    if v:IsA("GuiObject") then
                        if v.BackgroundTransparency < 1 then
                            TS:Create(v, TI(0.3), {BackgroundTransparency = 1}):Play()
                        end
                    end
                    if v:IsA("TextLabel") or v:IsA("TextButton") then
                        TS:Create(v, TI(0.3), {TextTransparency = 1}):Play()
                    end
                    if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                        TS:Create(v, TI(0.3), {ImageTransparency = 1}):Play()
                    end
                    if v:IsA("UIStroke") then
                        TS:Create(v, TI(0.3), {Transparency = 1}):Play()
                    end
                end
            end
            
            FadeAllDescendants(Gui)
            task.wait(0.3)
            if callback then callback() end
            Gui:Destroy()
        end
        
        YesBtn.MouseButton1Click:Connect(function() FadeOut(OnYes) end)
        NoBtn.MouseButton1Click:Connect(function()
            if notify_sound then
                notify_sound:Stop()
            end
            FadeOut(OnNo) 
        end)
        
        TS:Create(Backdrop, TI(0.3), {BackgroundTransparency = 0.6}):Play()
        TS:Create(Container, TI(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 240)
        }):Play()
        
        return Gui
    end

    local function showNotification(name, statusText, statusColor, staffNames, friendStaffNames, totalCount, duration)
        local old = coregui:FindFirstChild("ModAlertNotification")
        if old then old:Destroy() end
        
        local screengui = Instance.new("ScreenGui")
        screengui.Name = name
        screengui.ResetOnSpawn = false
        screengui.DisplayOrder = 2147483647
        screengui.IgnoreGuiInset = true
        screengui.Parent = coregui

        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -20, 1, -20)
        frame.Size = UDim2.new(0, 260, 0, 80)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 0.15
        frame.Parent = screengui

        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(0, 10)
        uicorner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(90, 90, 90)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = frame

        local title = Instance.new("TextLabel")
        title.Text = "Moderator Detector"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.TextColor3 = Color3.fromRGB(236, 236, 236)
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 15, 0, 10)
        title.Size = UDim2.new(1, -30, 0, 20)
        title.Parent = frame

        local staffDisplay = #staffNames > 0 and table.concat(staffNames, ", ") or "None"
        local friendDisplay = #friendStaffNames > 0 and table.concat(friendStaffNames, ", ") or "None"

        local desc = Instance.new("TextLabel")
        desc.Text = statusText .. "\n<font color=\"rgb(150,150,150)\" size=\"13\">Server Moderators: " .. staffDisplay .. "</font>" .. "\n<font color=\"rgb(150,150,150)\" size=\"13\">Friend Moderators: " .. friendDisplay .. "</font>"
        desc.RichText = true
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 14
        desc.TextColor3 = statusColor
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.new(0, 15, 0, 32)
        desc.Size = UDim2.new(1, -30, 1, -45)
        desc.TextWrapped = true
        desc.Parent = frame

        task.delay(duration, function()
            pcall(function()
                if screengui then
                    screengui:Destroy()
                end
            end)
        end)
    end

    local staffNames, totalCount = getStaffInfo()
    local friendStaffNames = getFriendStaffInfo()

    local hasServerStaff = #staffNames > 0
    local hasFriendStaff = #friendStaffNames > 0
    local hasDetected = (hasServerStaff or hasFriendStaff)

    local statusText = ""
    if hasServerStaff then statusText = "Moderators detected!" end
    if hasFriendStaff then statusText = statusText .. (hasServerStaff and "\n" or "") .. "Staff friends detected!" end
    if statusText == "" then statusText = "No staff detected." end

    local statusColor = (hasServerStaff or hasFriendStaff) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    local duration = (hasServerStaff or hasFriendStaff) and 60 or 10

    if hasDetected then
        task.spawn(function()
            if notify_sound then
                notify_sound:Play()
            end
        end)
        createLeaveUI([[There is a <font color="#FF8888">moderator</font> in this server.<br/>Do you want to leave?]], function()
            game:GetService("TeleportService"):Teleport(17625359962)
        end, nil)
    end

    showNotification("ModAlertNotification", statusText, statusColor, staffNames, friendStaffNames, totalCount, duration)

    players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Wait()
        local role = GetRole(plr, game.CreatorId)
        if isStaffRoleName(role) then
            local staffNames, totalCount = getStaffInfo()
            local friendStaffNames = getFriendStaffInfo()
            local hasServerStaff = #staffNames > 0
            local hasFriendStaff = #friendStaffNames > 0
            local hasDetected = (hasServerStaff or hasFriendStaff)
            local statusText = ""
            if hasServerStaff then statusText = "Moderators detected!" end
            if hasFriendStaff then statusText = statusText .. (hasServerStaff and "\n" or "") .. "Staff friends detected!" end
            if statusText == "" then statusText = "No staff detected." end
            local statusColor = (hasServerStaff or hasFriendStaff) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
            local duration = (hasServerStaff or hasFriendStaff) and 60 or 10
            if hasDetected then
                task.spawn(function()
                    if notify_sound then
                        notify_sound:Play()
                    end
                end)
                createLeaveUI([[There is a <font color="#FF8888">moderator</font> in this server.<br/>Do you want to leave?]], function()
                    game:GetService("TeleportService"):Teleport(17625359962)
                end, nil)
            end
            showNotification("ModAlertNotification", statusText, statusColor, staffNames, friendStaffNames, totalCount, duration)
        end
    end)
end, function() end)
