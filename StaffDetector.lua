xpcall(function()
    if shared.StaffDetectorLoading then return end
    shared.StaffDetectorLoading = true
    repeat task.wait() until game:IsLoaded()
    local cloneref = cloneref or function(obj)
        return obj
    end

    local players = cloneref(game:GetService("Players"))
    local coregui = cloneref(game:GetService("CoreGui"))
    local lp = players.LocalPlayer

    if game.CreatorType ~= Enum.CreatorType.Group then
        return warn("This game isnt group game!")
    end

    local old = coregui:FindFirstChild("ModAlertNotification")
    if old then old:Destroy() end

    local function GetRole(plr, groupId)
        if plr and typeof(plr) == "Instance" then
            local method = plr.GetRoleInGroup
            if typeof(method) == "function" then
                return method(plr, groupId)
            end
        end
        return nil
    end

    local function detectmod()
        for _, plr in ipairs(players:GetPlayers()) do
            if plr and plr.GetRoleInGroup ~= nil then
                local role = GetRole(plr, game.CreatorId)
                if role and typeof(role) == "string" then
                    local r = string.lower(role)
                    if string.find(r, "mod") or string.find(r, "staff") or string.find(r, "contributor") or string.find(r, "script") or string.find(r, "build") then return true end
                end
            end
        end
        return false
    end

    if not detectmod() then
        return warn("Moderator doesnt detected!")
    end

    local screengui = Instance.new("ScreenGui")
    screengui.Name = "ModAlertNotification"
    screengui.ResetOnSpawn = false
    screengui.IgnoreGuiInset = true
    screengui.Parent = coregui

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.Position = UDim2.new(1, -20, 1, -20)
    frame.Size = UDim2.new(0, 260, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1
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
    title.Text = "Moderator Detected"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 15, 0, 10)
    title.Size = UDim2.new(1, -30, 0, 20)
    title.Parent = frame

    local desc = Instance.new("TextLabel")
    desc.Text = "A player with a moderator role is in this server."
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextColor3 = Color3.fromRGB(230, 230, 230)
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.new(0, 15, 0, 35)
    desc.Size = UDim2.new(1, -30, 1, -45)
    desc.TextWrapped = true
    desc.Parent = frame

    frame.BackgroundTransparency = 1
    title.TextTransparency = 1
    desc.TextTransparency = 1

    task.spawn(function()
        for i = 1, 10 do
            local a = i / 10
            frame.BackgroundTransparency = 1 - (0.9 * a)
            title.TextTransparency = 1 - a
            desc.TextTransparency = 1 - a
            task.wait(0.03)
        end
    end)

    task.delay(60, function()
        if screengui then
            screengui:Destroy()
        end
    end)
end, function(err)
    warn(err)
end)
