-- // AntiLua UI Library // --
local AntiLua = {}

-- // Services // --
local Services = {
	Players = cloneref(game:GetService("Players")),
	RunService = cloneref(game:GetService("RunService")),
	UserInputService = cloneref(game:GetService("UserInputService")),
	TweenService = cloneref(game:GetService("TweenService")),
	Debris = cloneref(game:GetService("Debris"))
}

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
	notification.BackgroundTransparency = 0.1
	notification.BorderSizePixel = 0
	notification.Parent = notification_gui
	
	local corner = Instance.new("UICorner", notification)
	corner.CornerRadius = UDim.new(0, 8)
	
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
	local drag_input, drag_start, start_pos
	local tween_info = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local drag_on = { BackgroundTransparency = 0 }
	local drag_off = { BackgroundTransparency = 0.5 }

	local function update_drag(input)
		local delta = input.Position - drag_start
		target_position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
		
		drag_btn.Position = UDim2.new(drag_start_pos.X.Scale, drag_start_pos.X.Offset + delta.X, drag_start_pos.Y.Scale, drag_start_pos.Y.Offset + delta.Y)
		drag_frame.Position = UDim2.new(drag_start_pos.X.Scale, drag_start_pos.X.Offset + delta.X, drag_start_pos.Y.Scale, drag_start_pos.Y.Offset + delta.Y)
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

	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and input == drag_input then
			update_drag(input)
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
		button_color = config.button_color or Color3.fromRGB(82, 82, 91)
	}

	-- // UI Setup // --
	local GUIParent = gethui and gethui() or game.CoreGui

	local blocker_ui = GUIParent:FindFirstChild("AntiLuaUI")
	if blocker_ui then
		blocker_ui:Destroy()
	end

	screen_gui = Instance.new("ScreenGui")
	screen_gui.Name = "AntiLuaUI"
	screen_gui.ResetOnSpawn = false
	screen_gui.IgnoreGuiInset = true
	screen_gui.Parent = GUIParent
	screen_gui.DisplayOrder = 2147483647

	main_frame = Instance.new("Frame")
	main_frame.Size = settings.size
	main_frame.Position = settings.position
	main_frame.BackgroundColor3 = settings.background_color
	main_frame.BackgroundTransparency = 0.15
	main_frame.BorderSizePixel = 0
	main_frame.AnchorPoint = Vector2.new(0.5, 0.5)
	main_frame.Active = true
	main_frame.Parent = screen_gui

	local corner = Instance.new("UICorner", main_frame)
	corner.CornerRadius = UDim.new(0, 12)

	local close_button = Instance.new("ImageButton")
	close_button.Size = UDim2.new(0, 24, 0, 24)
	close_button.Position = UDim2.new(1, -26, 0, 2)
	close_button.BackgroundTransparency = 1
	close_button.BorderSizePixel = 0
	close_button.Image = "rbxassetid://82404346839314"
	close_button.Parent = main_frame
	close_button.ZIndex = 10

	close_button.MouseButton1Click:Connect(function()
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

	-- // Toggle Button // --
	local toggle_button = Instance.new("TextButton")
	toggle_button.Size = UDim2.new(1, -30, 0, 40)
	toggle_button.Position = UDim2.new(0, 15, 0, 55)
	toggle_button.BackgroundColor3 = settings.button_color
	toggle_button.BackgroundTransparency = 0.5
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
		destroy = function()
			if screen_gui then
				screen_gui:Destroy()
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
		end
	}
end

return AntiLua
