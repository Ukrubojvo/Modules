function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

local cloneref = missing("function", cloneref, function(...) return ... end)
local sethidden = missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
local gethidden = missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
local queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
local httprequest = missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))

-- // AcrylicBlur Module // --
local AcrylicBlur = {}

function AcrylicBlur.ApplyToFrame(frame)
    local RunService = game:GetService('RunService')
    local HS = game:GetService('HttpService')
    local camera = workspace.CurrentCamera
    local MTREL = "Glass"
    local root = Instance.new('Folder', camera)
    root.Name = HS:GenerateGUID(true)
    
    local DepthOfField
    -- Find or create DepthOfField effect
    for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
        if v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
            DepthOfField = v
            break
        end
    end
    if not DepthOfField then
        DepthOfField = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
        DepthOfField.FarIntensity = 0
        DepthOfField.FocusDistance = 51.6
        DepthOfField.InFocusRadius = 50
        DepthOfField.NearIntensity = 1
        DepthOfField.Name = HS:GenerateGUID(true)
        DepthOfField:AddTag(".")
    end
    
    local function DrawTriangle(v1, v2, v3, p0, p1)
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local sz = 0.2
        local s1 = (v1 - v2).magnitude
        local s2 = (v2 - v3).magnitude
        local s3 = (v3 - v1).magnitude
        local smax = max(s1, s2, s3)
        local A, B, C
        if s1 == smax then
            A, B, C = v1, v2, v3
        elseif s2 == smax then
            A, B, C = v2, v3, v1
        elseif s3 == smax then
            A, B, C = v3, v1, v2
        end
        local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
        local perp = sqrt((C - A).magnitude^2 - para * para)
        local dif_para = (A - B).magnitude - para
        local st = CFrame.new(B, A)
        local za = CFrame.Angles(pi / 2, 0, 0)
        local cf0 = st
        local Top_Look = (cf0 * za).lookVector
        local Mid_Point = A + CFrame.new(A, B).lookVector * para
        local Needed_Look = CFrame.new(Mid_Point, C).lookVector
        local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z
        local ac = CFrame.Angles(0, 0, acos(dot))
        cf0 = cf0 * ac
        if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
            cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
        end
        cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))
        local cf1 = st * ac * CFrame.Angles(0, pi, 0)
        if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
            cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
        end
        cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)
        if not p0 then
            p0 = Instance.new('Part')
            p0.FormFactor = 'Custom'
            p0.TopSurface = 0
            p0.BottomSurface = 0
            p0.Anchored = true
            p0.CanCollide = false
            p0.CastShadow = false
            p0.Material = MTREL
            p0.Size = Vector3.new(sz, sz, sz)
            p0.Name = HS:GenerateGUID(true)
            local mesh = Instance.new('SpecialMesh', p0)
            mesh.MeshType = 2
            mesh.Name = HS:GenerateGUID(true)
        end
        p0[p0.Name].Scale = Vector3.new(0, perp / sz, para / sz)
        p0.CFrame = cf0
        if not p1 then
            p1 = p0:Clone()
        end
        p1[p1.Name].Scale = Vector3.new(0, perp / sz, dif_para / sz)
        p1.CFrame = cf1
        return p0, p1
    end
    
    local function DrawQuad(v1, v2, v3, v4, parts)
        parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
        parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
    end
    
    local parts = {}
    local f = Instance.new('Folder', root)
    f.Name = HS:GenerateGUID(true)
    local parents = {}
    local function add(child)
        if child:IsA('GuiObject') then
            parents[#parents + 1] = child
            add(child.Parent)
        end
    end
    add(frame)
    
    local function IsVisible(instance)
        while instance do
            if instance:IsA("GuiObject") then
                if not instance.Visible then
                    return false
                end
            elseif instance:IsA("ScreenGui") then
                if not instance.Enabled then
                    return false
                end
                break
            end
            instance = instance.Parent
        end
        return true
    end
    
    local function UpdateOrientation(fetchProps)
        if not IsVisible(frame) then
            for _, pt in pairs(parts) do
                pt.Parent = nil
            end
            return
        end
        local properties = {
            Transparency = 0.95,
            BrickColor = BrickColor.new('Institutional white'),
        }
        local zIndex = 1 - 0.05 * frame.ZIndex
        local tl = frame.AbsolutePosition + Vector2.new(1, 1)
        local br = frame.AbsolutePosition + frame.AbsoluteSize - Vector2.new(1, 1)
        local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
        
        local rot = 0
        for _, v in ipairs(parents) do
            rot = rot + v.Rotation
        end
        if rot ~= 0 and rot % 180 ~= 0 then
            local mid = tl:Lerp(br, 0.5)
            local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
            tl = Vector2.new(c * (tl.x - mid.x) - s * (tl.y - mid.y), s * (tl.x - mid.x) + c * (tl.y - mid.y)) + mid
            tr = Vector2.new(c * (tr.x - mid.x) - s * (tr.y - mid.y), s * (tr.x - mid.x) + c * (tr.y - mid.y)) + mid
            bl = Vector2.new(c * (bl.x - mid.x) - s * (bl.y - mid.y), s * (bl.x - mid.x) + c * (bl.y - mid.y)) + mid
            br = Vector2.new(c * (br.x - mid.x) - s * (br.y - mid.y), s * (br.x - mid.x) + c * (br.y - mid.y)) + mid
        end
        
        -- Wrap DrawQuad in pcall to catch potential errors
        local success, err = pcall(function()
            DrawQuad(
                camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
                camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
                camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
                camera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
                parts
            )
        end)
        if not success then
            warn("Error in DrawQuad: " .. tostring(err))
            return
        end
        
        if fetchProps then
            for _, pt in pairs(parts) do
                pt.Parent = f
            end
            for propName, propValue in pairs(properties) do
                for _, pt in pairs(parts) do
                    pt[propName] = propValue
                end
            end
        end
    end
    
    local function IsNotNaN(x)
        return x == x
    end
    
    -- Wait for valid camera coordinates
    while not IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x) do
        RunService.RenderStepped:Wait()
    end
    
    -- Use RenderStepped:Connect instead of BindToRenderStep
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local success, err = pcall(UpdateOrientation)
        if not success then
            warn("Error in UpdateOrientation: " .. tostring(err))
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    -- Initialize orientation
    local success, err = pcall(function() UpdateOrientation(true) end)
    if not success then
        warn("Initial UpdateOrientation failed: " .. tostring(err))
        if connection then
            connection:Disconnect()
        end
    end
    
    return {
        parts = parts,
        folder = f,
        connection = connection,
        destroy = function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if f then
                f:Destroy()
            end
            if root then
                root:Destroy()
            end
        end
    }
end

-- // AntiLua UI Library // --
local AntiLua = {}

-- // Services // --
local Services = setmetatable({}, {
    __index = function(self, name)
        self[name] = cloneref(game:GetService(name))
        return self[name]
    end
})

-- // Notification System // --
local notification_gui
local notification_count = 0

local function create_notification_gui()
	if notification_gui then return end
	
	local GUIParent = gethui and gethui() or game.CoreGui
	notification_gui = Instance.new("ScreenGui")
	notification_gui.Name = "AntiLuaNotifications"
	notification_gui.ResetOnSpawn = false
	notification_gui.IgnoreGuiInset = true
	notification_gui.Parent = GUIParent
	notification_gui.DisplayOrder = 2147483647
end

local function calculate_text_size(text, font, text_size, max_width)
	text = string.gsub(text, "\\n", "\n")
	
	local temp_label = Instance.new("TextLabel")
	temp_label.Size = UDim2.new(0, max_width, 0, math.huge)
	temp_label.BackgroundTransparency = 1
	temp_label.Text = text
	temp_label.Font = font
	temp_label.TextSize = text_size
	temp_label.TextWrapped = true
	temp_label.TextXAlignment = Enum.TextXAlignment.Left
	temp_label.TextYAlignment = Enum.TextYAlignment.Top
	temp_label.Parent = workspace
	
	Services.RunService.Heartbeat:Wait()
	
	local bounds = temp_label.TextBounds
	temp_label:Destroy()
	
	return bounds
end

function AntiLua.Notify(message, duration, color, title)
	create_notification_gui()
	
	duration = duration or 3
	color = color or Color3.fromRGB(80, 200, 120)
	title = title or nil
	notification_count = notification_count + 1
	
	message = string.gsub(message, "\\n", "\n")
	if title then
		title = string.gsub(title, "\\n", "\n")
	end
	
	local text_width = 260
	local total_height = 20
	local title_height = 0
	local message_height = 0
	
	if title then
		local title_bounds = calculate_text_size(title, Enum.Font.GothamBold, 16, text_width)
		title_height = math.max(20, title_bounds.Y)
		total_height = total_height + title_height + 5
	end
	
	local message_bounds = calculate_text_size(message, Enum.Font.Gotham, 15, text_width)
	message_height = math.max(20, message_bounds.Y)
	total_height = total_height + message_height + 10
	
	local notification_height = math.max(60, math.min(300, total_height))
	
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, notification_height)
	notification.Position = UDim2.new(1, 320, 1, -notification_height - 20 - (notification_count * (notification_height + 10)))
	notification.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	notification.BackgroundTransparency = 0.3
	notification.BorderSizePixel = 0
	notification.Parent = notification_gui
	
	local corner = Instance.new("UICorner", notification)
	corner.CornerRadius = UDim.new(0, 8)
	
	-- Apply AcrylicBlur to notification
	local notification_blur = AcrylicBlur.ApplyToFrame(notification)
	
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.BackgroundColor3 = color
	accent.BorderSizePixel = 0
	accent.Parent = notification
	
	local accent_corner = Instance.new("UICorner", accent)
	accent_corner.CornerRadius = UDim.new(0, 8)
	
	local current_y = 10
	
	if title then
		local title_label = Instance.new("TextLabel")
		title_label.Size = UDim2.new(0, text_width, 0, title_height)
		title_label.Position = UDim2.new(0, 15, 0, current_y)
		title_label.BackgroundTransparency = 1
		title_label.Text = title
		title_label.Font = Enum.Font.GothamBold
		title_label.TextColor3 = Color3.fromRGB(255, 255, 255)
		title_label.TextSize = 16
		title_label.TextWrapped = true
		title_label.TextXAlignment = Enum.TextXAlignment.Left
		title_label.TextYAlignment = Enum.TextYAlignment.Top
		title_label.Parent = notification
		
		current_y = current_y + title_height + 5
	end
	
	local text_label = Instance.new("TextLabel")
	text_label.Size = UDim2.new(0, text_width, 0, message_height)
	text_label.Position = UDim2.new(0, 15, 0, current_y)
	text_label.BackgroundTransparency = 1
	text_label.Text = message
	text_label.Font = Enum.Font.Gotham
	text_label.TextColor3 = title and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
	text_label.TextSize = 15
	text_label.TextWrapped = true
	text_label.TextXAlignment = Enum.TextXAlignment.Left
	text_label.TextYAlignment = Enum.TextYAlignment.Top
	text_label.Parent = notification
	
	local slide_in = Services.TweenService:Create(
		notification,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(1, -320, 1, -notification_height - 20 - ((notification_count - 1) * (notification_height + 10))) }
	)
	slide_in:Play()
	
	Services.Debris:AddItem(notification, duration + 0.5)
	
	task.spawn(function()
		task.wait(duration)
		local slide_out = Services.TweenService:Create(
			notification,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 320, notification.Position.Y.Scale, notification.Position.Y.Offset) }
		)
		slide_out:Play()
		
		-- Clean up blur effect
		if notification_blur then
			notification_blur.destroy()
		end
		
		notification_count = notification_count - 1
	end)
end

-- // Services // --
local Services = {
	Players = cloneref(game:GetService("Players")),
	RunService = cloneref(game:GetService("RunService")),
	UserInputService = cloneref(game:GetService("UserInputService")),
	TweenService = cloneref(game:GetService("TweenService"))
}

-- // Spring Animation Variables // --
local spring_strength = 0.04
local spring_damping = 0.8
local target_position = UDim2.new(0.5, 0, 0.5, 0)
local current_velocity = Vector2.new(0, 0)
local original_drag_pos = UDim2.new(0.5, 0, 0.5, 65)
local drag_start_pos = UDim2.new(0.5, 0, 0.5, 65)

-- // UI Components // --
local screen_gui, main_frame, drag_btn, drag_frame

-- // Spring Animation Function // --
local function update_spring()
	if not main_frame then return end
	local dragging = drag_btn and drag_btn:GetAttribute("Dragging") or false
	
	if dragging then
		local current_pos = main_frame.Position
		local current_pixel = Vector2.new(current_pos.X.Offset, current_pos.Y.Offset)
		local target_pixel = Vector2.new(target_position.X.Offset, target_position.Y.Offset)
		
		local displacement = target_pixel - current_pixel
		
		local spring_force = displacement * spring_strength
		current_velocity = current_velocity + spring_force
		current_velocity = current_velocity * spring_damping
		
		local new_pixel = current_pixel + current_velocity
		local new_position = UDim2.new(
			target_position.X.Scale, new_pixel.X,
			target_position.Y.Scale, new_pixel.Y
		)
		
		main_frame.Position = new_position
	end
end

-- // Drag Function // --
local function setup_dragging()
	local dragging = false
	local main_dragging = false
	local drag_input, drag_start, start_pos
	local main_drag_input, main_drag_start, main_start_pos
	local tween_info = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local drag_on = { BackgroundTransparency = 0 }
	local drag_off = { BackgroundTransparency = 0.5 }

	local function update_drag(input)
		local delta = input.Position - drag_start
		target_position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
		
		drag_btn.Position = UDim2.new(drag_start_pos.X.Scale, drag_start_pos.X.Offset + delta.X, drag_start_pos.Y.Scale, drag_start_pos.Y.Offset + delta.Y)
		drag_frame.Position = UDim2.new(drag_start_pos.X.Scale, drag_start_pos.X.Offset + delta.X, drag_start_pos.Y.Scale, drag_start_pos.Y.Offset + delta.Y)
	end
	
	local function update_main_drag(input)
		local delta = input.Position - main_drag_start
		local new_position = UDim2.new(main_start_pos.X.Scale, main_start_pos.X.Offset + delta.X, main_start_pos.Y.Scale, main_start_pos.Y.Offset + delta.Y)
		main_frame.Position = new_position
		target_position = new_position
		
		drag_btn.Position = UDim2.new(new_position.X.Scale, new_position.X.Offset, new_position.Y.Scale, new_position.Y.Offset + 65)
		drag_frame.Position = UDim2.new(new_position.X.Scale, new_position.X.Offset, new_position.Y.Scale, new_position.Y.Offset + 65)
	end

	drag_btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local drag_starts = Services.TweenService:Create(drag_frame, tween_info, drag_on)
			drag_starts:Play()
			dragging = true
			drag_btn:SetAttribute("Dragging", true)
			drag_start = input.Position
			start_pos = main_frame.Position
			target_position = start_pos
			drag_start_pos = drag_btn.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					drag_starts:Cancel()
					local drag_stop = Services.TweenService:Create(drag_frame, tween_info, drag_off)
					drag_stop:Play()
					dragging = false
					drag_btn:SetAttribute("Dragging", false)
					current_velocity = Vector2.new(0, 0)
					main_frame.Position = target_position
					drag_btn.Position = UDim2.new(target_position.X.Scale, target_position.X.Offset, target_position.Y.Scale, target_position.Y.Offset + 65)
					drag_frame.Position = UDim2.new(target_position.X.Scale, target_position.X.Offset, target_position.Y.Scale, target_position.Y.Offset + 65)
				end
			end)
		end
	end)

	drag_btn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			drag_input = input
		end
	end)

	main_frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			main_dragging = true
			main_drag_start = input.Position
			main_start_pos = main_frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					main_dragging = false
				end
			end)
		end
	end)

	main_frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			main_drag_input = input
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and input == drag_input then
			update_drag(input)
		elseif main_dragging and input == main_drag_input then
			update_main_drag(input)
		end
	end)
end

-- // Main Library Function // --
function AntiLua.CreateUI(config)
	-- // Default Configuration // --
	local settings = {
		title = config.title or "AntiLua Script",
		button_text = config.button_text or "Activate Script",
		button_text_active = config.button_text_active or "Script Active",
		on_toggle = config.on_toggle or function(enabled) end,
		custom_code = config.custom_code or function() end,
		toggle_key = config.toggle_key or Enum.KeyCode.Insert,
		size = config.size or UDim2.new(0, 260, 0, 110),
		position = config.position or UDim2.new(0.5, 0, 0.5, 0),
		background_color = config.background_color or Color3.fromRGB(16, 16, 16),
		text_color = config.text_color or Color3.fromRGB(255, 255, 255),
		button_color = config.button_color or Color3.fromRGB(82, 82, 91),
		enable_blur = config.enable_blur ~= false  -- Default to true
	}

	-- // UI Setup // --
	local GUIParent = gethui and gethui() or game.CoreGui

	local blocker_ui = GUIParent:FindFirstChild(settings.title)
	if blocker_ui then
		blocker_ui:Destroy()
	end

	screen_gui = Instance.new("ScreenGui")
	screen_gui.Name = settings.title
	screen_gui.ResetOnSpawn = false
	screen_gui.IgnoreGuiInset = true
	screen_gui.Parent = GUIParent
	screen_gui.DisplayOrder = 2147483647

	main_frame = Instance.new("Frame")
	main_frame.Size = settings.size
	main_frame.Position = settings.position
	main_frame.BackgroundColor3 = settings.background_color
	main_frame.BackgroundTransparency = settings.enable_blur and 0.3 or 0.15
	main_frame.BorderSizePixel = 0
	main_frame.AnchorPoint = Vector2.new(0.5, 0.5)
	main_frame.Active = true

	main_frame.Parent = screen_gui

	local corner = Instance.new("UICorner", main_frame)
	corner.CornerRadius = UDim.new(0, 12)

	-- Apply AcrylicBlur to main frame if enabled
	local main_blur
	if settings.enable_blur then
		main_blur = AcrylicBlur.ApplyToFrame(main_frame)
	end

	local close_button = Instance.new("ImageButton")
	close_button.Size = UDim2.new(0, 24, 0, 24)
	close_button.Position = UDim2.new(1, -26, 0, 2)
	close_button.BackgroundTransparency = 1
	close_button.BorderSizePixel = 0
	close_button.Image = "rbxassetid://82404346839314"
	close_button.Parent = main_frame
	close_button.ZIndex = 10

	close_button.MouseButton1Click:Connect(function()
		if main_blur then
			main_blur.destroy()
		end
		screen_gui:Destroy()
	end)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundColor3 = Color3.fromRGB(255,255,255)
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Text = settings.title
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = settings.text_color
	title.TextSize = 18
	title.ZIndex = 50
	title.Parent = main_frame

	local title_corner = Instance.new("UICorner", title)
	title_corner.CornerRadius = UDim.new(0, 12)

	drag_btn = Instance.new("TextButton")
	drag_btn.Size = UDim2.new(0, 130, 0, 15)
	drag_btn.Position = UDim2.new(0.5, 0, 0.5, 65)
	drag_btn.BackgroundTransparency = 1
	drag_btn.BorderSizePixel = 0
	drag_btn.AnchorPoint = Vector2.new(0.5, 0.5)
	drag_btn.Text = ""
	drag_btn.ZIndex = 999
	drag_btn.Parent = screen_gui

	drag_frame = Instance.new("Frame")
	drag_frame.Size = UDim2.new(0, 130, 0, 4)
	drag_frame.Position = UDim2.new(0.5, 0, 0.5, 65)
	drag_frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	drag_frame.BackgroundTransparency = 0.5
	drag_frame.BorderSizePixel = 0
	drag_frame.AnchorPoint = Vector2.new(0.5, 0.5)
	drag_frame.Parent = screen_gui

	local drag_corner = Instance.new("UICorner", drag_frame)
	drag_corner.CornerRadius = UDim.new(0, 60)

	-- // Setup Dragging // --
	setup_dragging()

	local function sync_drag_elements()
		if not (drag_btn:GetAttribute("Dragging") or false) then
			local main_pos = main_frame.Position
			drag_btn.Position = UDim2.new(main_pos.X.Scale, main_pos.X.Offset, main_pos.Y.Scale, main_pos.Y.Offset + 65)
			drag_frame.Position = UDim2.new(main_pos.X.Scale, main_pos.X.Offset, main_pos.Y.Scale, main_pos.Y.Offset + 65)
			target_position = main_pos
		end
	end
	
	Services.RunService.Heartbeat:Connect(sync_drag_elements)

	-- // Toggle Button // --
	local toggle_button = Instance.new("TextButton")
	toggle_button.Size = UDim2.new(1, -30, 0, 40)
	toggle_button.Position = UDim2.new(0, 15, 0, 55)
	toggle_button.BackgroundColor3 = settings.button_color
	toggle_button.BackgroundTransparency = settings.enable_blur and 0.6 or 0.5
	toggle_button.TextColor3 = settings.text_color
	toggle_button.Font = Enum.Font.GothamBold
	toggle_button.TextSize = 16
	toggle_button.Text = settings.button_text
	toggle_button.AutoButtonColor = true
	toggle_button.BorderSizePixel = 0
	toggle_button.ZIndex = 2
	toggle_button.Parent = main_frame

	local toggle_corner = Instance.new("UICorner", toggle_button)
	toggle_corner.CornerRadius = UDim.new(0, 8)

	-- Apply AcrylicBlur to toggle button if enabled
	local button_blur
	if settings.enable_blur then
		button_blur = AcrylicBlur.ApplyToFrame(toggle_button)
	end

	-- // Button State Tracking // --
	local script_enabled = false
	local ui_visible = true

	-- // Toggle Function // --
	local function toggle_script()
		script_enabled = not script_enabled
		toggle_button.Text = script_enabled and settings.button_text_active or settings.button_text
		
		-- Call custom code when enabled
		if script_enabled then
			settings.custom_code()
		end
		
		-- Call on_toggle callback
		settings.on_toggle(script_enabled)
	end

	-- // UI Visibility Toggle Function // --
	local function toggle_ui_visibility()
		ui_visible = not ui_visible
		screen_gui.Enabled = ui_visible
	end

	toggle_button.MouseButton1Click:Connect(toggle_script)

	-- // Keyboard Input Handler // --
	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == settings.toggle_key then
			toggle_ui_visibility()
		end
	end)

	-- // Start Spring Animation Loop // --
	Services.RunService.Heartbeat:Connect(update_spring)

	-- // Return UI Controls // --
	return {
		gui = screen_gui,
		frame = main_frame,
		toggle_button = toggle_button,
		blur_effects = {
			main_blur = main_blur,
			button_blur = button_blur
		},
		destroy = function()
			-- Clean up blur effects first
			if main_blur then
				main_blur.destroy()
				main_blur = nil
			end
			if button_blur then
				button_blur.destroy()
				button_blur = nil
			end
			-- Then destroy the GUI
			if screen_gui then
				screen_gui:Destroy()
				screen_gui = nil
			end
		end,
		set_enabled = function(enabled)
			script_enabled = enabled
			toggle_button.Text = script_enabled and settings.button_text_active or settings.button_text
			if script_enabled then
				settings.custom_code()
			end
			settings.on_toggle(script_enabled)
		end,
		is_enabled = function()
			return script_enabled
		end,
		toggle_visibility = function()
			toggle_ui_visibility()
		end,
		set_visible = function(visible)
			ui_visible = visible
			screen_gui.Enabled = ui_visible
		end,
		is_visible = function()
			return ui_visible
		end,
		toggle_script = function()
			toggle_script()
		end,
		toggle_blur = function(enable)
			if enable == nil then enable = not settings.enable_blur end
			settings.enable_blur = enable
			
			if enable then
				if not main_blur then
					main_blur = AcrylicBlur.ApplyToFrame(main_frame)
				end
				if not button_blur then
					button_blur = AcrylicBlur.ApplyToFrame(toggle_button)
				end
				main_frame.BackgroundTransparency = 0.3
				toggle_button.BackgroundTransparency = 0.6
			else
				if main_blur then
					main_blur.destroy()
					main_blur = nil
				end
				if button_blur then
					button_blur.destroy()
					button_blur = nil
				end
				main_frame.BackgroundTransparency = 0.15
				toggle_button.BackgroundTransparency = 0.5
			end
		end
	}
end

-- // Example Usage // --
--[[
local ui = AntiLua.CreateUI({
	title = "My Glass UI",
	button_text = "Activate",
	button_text_active = "Active",
	enable_blur = true,  -- Enable glass effect
	on_toggle = function(enabled)
		if enabled then
			AntiLua.Notify("Script activated!", 3, Color3.fromRGB(0, 255, 0), "Success")
		else
			AntiLua.Notify("Script deactivated!", 3, Color3.fromRGB(255, 100, 100), "Info")
		end
	end,
	custom_code = function()
		print("Custom code executed!")
	end
})

-- Toggle blur effect
ui.toggle_blur(true)  -- Enable blur
ui.toggle_blur(false) -- Disable blur
ui.toggle_blur()      -- Toggle current state
--]]

return AntiLua
