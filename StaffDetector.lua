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
    local http = game:GetService("HttpService")
    local lp = players.LocalPlayer
    local groupId = game.CreatorId

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

    local statusText = ""
    if hasServerStaff then statusText = "Moderators detected!" end
    if hasFriendStaff then statusText = statusText .. (hasServerStaff and "\n" or "") .. "Staff friends detected!" end
    if statusText == "" then statusText = "No staff detected." end

    local statusColor = (hasServerStaff or hasFriendStaff) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    local duration = (hasServerStaff or hasFriendStaff) and 60 or 10

    showNotification("ModAlertNotification", statusText, statusColor, staffNames, friendStaffNames, totalCount, duration)

    players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Wait()
        local role = GetRole(plr, game.CreatorId)
        if isStaffRoleName(role) then
            local staffNames, totalCount = getStaffInfo()
            local friendStaffNames = getFriendStaffInfo()
            local hasServerStaff = #staffNames > 0
            local hasFriendStaff = #friendStaffNames > 0
            local statusText = ""
            if hasServerStaff then statusText = "Moderators detected!" end
            if hasFriendStaff then statusText = statusText .. (hasServerStaff and "\n" or "") .. "Staff friends detected!" end
            if statusText == "" then statusText = "No staff detected." end
            local statusColor = (hasServerStaff or hasFriendStaff) and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
            local duration = (hasServerStaff or hasFriendStaff) and 60 or 10
            showNotification("ModAlertNotification", statusText, statusColor, staffNames, friendStaffNames, totalCount, duration)
        end
    end)
end, function() end)
