xpcall(function()
    if shared.StaffDetectorLoading then return end
    shared.StaffDetectorLoading = true
    repeat task.wait() until game:IsLoaded()
    local cloneref = cloneref or function(obj)
        return obj
    end

    local players = cloneref(game:GetService("Players"))
    local coregui = gethui() or cloneref(game:GetService("CoreGui"))
    local lp = players.LocalPlayer

    if game.CreatorType ~= Enum.CreatorType.Group then
        return
    end

    pcall(function()
        if not autoload then return end
        queue_on_teleport([[
            pcall(function()
                autoload = true;
                local GitRequests = loadstring(game:HttpGet("https://raw.githubusercontent.com/itchino/Roblox-GitRequests/refs/heads/main/GitRequests.lua"))()
                local Repo = GitRequests.Repo("Ukrubojvo", "Modules")
                task.wait(10);
                loadstring(Repo:getFileContent("StaffDetector.lua"))()
            end)
        ]])
    end)

    local function GetRole(plr, groupId)
        if plr and typeof(plr) == "Instance" then
            local method = plr.GetRoleInGroup
            if typeof(method) == "function" then
                return method(plr, groupId)
            end
        end
        return nil
    end

    local function isStaffRole(role)
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
            return string.sub(name, 1, 3) .. "..."
        end
        return name
    end

    local function getStaffInfo()
        local total = #players:GetPlayers()
        local staffNames = {}
        for _, plr in ipairs(players:GetPlayers()) do
            if plr and plr.GetRoleInGroup ~= nil then
                local role = GetRole(plr, game.CreatorId)
                if isStaffRole(role) then
                    table.insert(staffNames, shortenName(plr.Name))
                end
            end
        end
        return staffNames, total
    end

    local function showNotification(name, statusText, statusColor, staffNames, totalCount, duration)
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
        title.Position = UDim2.new(0, 15, 0, 14)
        title.Size = UDim2.new(1, -30, 0, 20)
        title.Parent = frame

        local staffDisplay
        if #staffNames > 0 then
            staffDisplay = table.concat(staffNames, ", ")
        else
            staffDisplay = "None"
        end

        local desc = Instance.new("TextLabel")
        desc.Text = statusText .. "\n<font color=\"rgb(150,150,150)\" size=\"13\">Moderators: " .. staffDisplay .. "</font>"
        desc.RichText = true
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 14
        desc.TextColor3 = statusColor
        desc.BackgroundTransparency = 1
        desc.Position = UDim2.new(0, 15, 0, 33)
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

    if #staffNames > 0 then
        showNotification("ModAlertNotification", "Moderators detected!", Color3.fromRGB(255, 100, 100), staffNames, totalCount, 60)
    else
        showNotification("ModAlertNotification", "No Moderators detected.", Color3.fromRGB(255, 255, 255), staffNames, totalCount, 10)
    end

    players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Wait()
        local role = GetRole(plr, game.CreatorId)
        if isStaffRole(role) then
            local staffNames, totalCount = getStaffInfo()
            showNotification("ModAlertNotification", "Moderators detected!", Color3.fromRGB(255, 100, 100), staffNames, totalCount, 60)
        end
    end)
end, function() end)
