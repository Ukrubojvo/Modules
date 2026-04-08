--// Not original source / Modified by .antilua.
--// Add under any frame to apply

--// User Graphics quality must be greater than or equal to 8 (Depending on your system possibly 7)

local RunService = game:GetService('RunService')
local HS = game:GetService('HttpService')
local camera = workspace.CurrentCamera
local MTREL = "Glass"
local binds = {}
local root = Instance.new('Folder', camera)
local wedgeguid = HS:GenerateGUID(true)
root.Name = HS:GenerateGUID(true)

local DepthOfField
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

local frame = Instance.new('Frame')
frame.Parent = script.Parent
frame.Size = UDim2.new(0.97, 0, 0.97, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 1
frame.Name = HS:GenerateGUID(true)

do
	local function IsNotNaN(x)
		return x == x
	end
	local continue_ = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
	while not continue_ do
		RunService.RenderStepped:Wait()
		continue_ = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
	end
end

local DrawQuad do
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2

	function DrawTriangle(v1, v2, v3, p0, p1)
		local s1 = (v1 - v2).Magnitude
		local s2 = (v2 - v3).Magnitude
		local s3 = (v3 - v1).Magnitude
		local smax = max(s1, s2, s3)
		local A, B, C
		if s1 == smax then
			A, B, C = v1, v2, v3
		elseif s2 == smax then
			A, B, C = v2, v3, v1
		elseif s3 == smax then
			A, B, C = v3, v1, v2
		end

		local AB = B - A
		local AC = C - A
		local para = (AB.X*AC.X + AB.Y*AC.Y + AB.Z*AC.Z) / (A - B).Magnitude
		local perp = sqrt(AC.Magnitude^2 - para*para)
		local dif_para = (A - B).Magnitude - para

		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi/2, 0, 0)
		local cf0 = st

		local Top_Look = (cf0 * za).LookVector
		local Mid_Point = A + CFrame.new(A, B).LookVector * para
		local Needed_Look = CFrame.new(Mid_Point, C).LookVector
		local dot = Top_Look.X*Needed_Look.X + Top_Look.Y*Needed_Look.Y + Top_Look.Z*Needed_Look.Z
		dot = math.clamp(dot, -1, 1)

		local ac = CFrame.Angles(0, 0, acos(dot))
		cf0 = cf0 * ac
		if ((cf0 * za).LookVector - Needed_Look).Magnitude > 0.01 then
			cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if ((cf1 * za).LookVector - Needed_Look).Magnitude > 0.01 then
			cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

		local function makePart()
			local p = Instance.new('Part')
			p.TopSurface = Enum.SurfaceType.Smooth
			p.BottomSurface = Enum.SurfaceType.Smooth
			p.Anchored = true
			p.CanCollide = false
			p.CastShadow = false
			p.Material = Enum.Material[MTREL]
			p.Size = Vector3.new(sz, sz, sz)
			p.Name = HS:GenerateGUID(true)
			local mesh = Instance.new('SpecialMesh', p)
			mesh.MeshType = Enum.MeshType.Wedge
			mesh.Name = wedgeguid
			return p
		end

		if not p0 then
			p0 = makePart()
		end
		
		local mesh0 = p0:FindFirstChild(wedgeguid)
		if mesh0 then
			mesh0.Scale = Vector3.new(0, perp/sz, para/sz)
		end
		p0.CFrame = cf0

		if not p1 then
			p1 = makePart()
		end
		local mesh1 = p1:FindFirstChild(wedgeguid)
		if mesh1 then
			mesh1.Scale = Vector3.new(0, perp/sz, dif_para/sz)
		end
		p1.CFrame = cf1

		return p0, p1
	end

	function DrawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
		parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
	end
end

if binds[frame] then
	return binds[frame].parts
end

local parts = {}
local f = Instance.new('Folder', root)
f.Name = HS:GenerateGUID(true)

local parents = {}
do
	local function add(child)
		if child:IsA('GuiObject') then
			parents[#parents + 1] = child
			add(child.Parent)
		end
	end
	add(frame)
end

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
	fetchProps = fetchProps == true

	if not IsVisible(frame) then
		for _, pt in pairs(parts) do
			pt.Parent = nil
		end
		return
	end

	local properties = {
		Transparency = 0.98;
		BrickColor = BrickColor.new('Institutional white');
	}
	local zIndex = 1 - 0.05*frame.ZIndex

	local tl = frame.AbsolutePosition
	local br = frame.AbsolutePosition + frame.AbsoluteSize
	local tr = Vector2.new(br.X, tl.Y)
	local bl = Vector2.new(tl.X, br.Y)

	do
		local rot = 0
		for _, v in ipairs(parents) do
			rot = rot + v.Rotation
		end
		if rot ~= 0 and rot % 180 ~= 0 then
			local mid = tl:Lerp(br, 0.5)
			local s = math.sin(math.rad(rot))
			local c = math.cos(math.rad(rot))
			local function rotVec(v)
				return Vector2.new(
					c*(v.X - mid.X) - s*(v.Y - mid.Y),
					s*(v.X - mid.X) + c*(v.Y - mid.Y)
				) + mid
			end
			tl = rotVec(tl)
			tr = rotVec(tr)
			bl = rotVec(bl)
			br = rotVec(br)
		end
	end

	DrawQuad(
		camera:ScreenPointToRay(tl.X, tl.Y, zIndex).Origin,
		camera:ScreenPointToRay(tr.X, tr.Y, zIndex).Origin,
		camera:ScreenPointToRay(bl.X, bl.Y, zIndex).Origin,
		camera:ScreenPointToRay(br.X, br.Y, zIndex).Origin,
		parts
	)

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

UpdateOrientation(true)
RunService:BindToRenderStep(HS:GenerateGUID(true), 2000, UpdateOrientation)