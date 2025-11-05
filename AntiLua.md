# AntiLua UI Library 📖

**AntiLua**의 UI는 **.antilua.**가 제작하였으며, 이를 라이브러리로 변환하는 과정은 **AI**의 도움을 받아 완성되었습니다.

## 🚀 빠른 시작

```lua
-- 라이브러리 로드
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

-- 기본 UI 생성
local ui = AntiLua.CreateUI({
    title = "내 스크립트",
    button_text = "시작",
    button_text_active = "실행중"
})
```

## 📋 기본 사용법

### UI 생성하기

```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

local ui = AntiLua.CreateUI({
    title = "My Script Hub",
    button_text = "Execute",
    button_text_active = "Running...",
    custom_code = function()
        print("스크립트가 실행되었습니다!")
        -- 여기에 실행할 코드 작성
    end,
    on_toggle = function(enabled)
        if enabled then
            print("활성화됨")
        else
            print("비활성화됨")
        end
    end
})
```

## ⚙️ 설정 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `title` | String | "AntiLua Script" | UI 상단에 표시될 제목 |
| `button_text` | String | "Activate Script" | 비활성화 상태 버튼 텍스트 |
| `button_text_active` | String | "Script Active" | 활성화 상태 버튼 텍스트 |
| `custom_code` | Function | function() end | 버튼 활성화시 실행될 코드 |
| `on_toggle` | Function | function(enabled) end | 토글 상태 변경시 실행될 콜백 |
| `toggle_key` | KeyCode | Enum.KeyCode.Insert | UI 숨김/표시 토글 키 |
| `size` | UDim2 | UDim2.new(0, 260, 0, 110) | UI 크기 |
| `position` | UDim2 | UDim2.new(0.5, 0, 0.5, 0) | UI 초기 위치 |
| `background_color` | Color3 | Color3.fromRGB(16, 16, 16) | 배경 색상 |
| `text_color` | Color3 | Color3.fromRGB(255, 255, 255) | 텍스트 색상 |
| `button_color` | Color3 | Color3.fromRGB(82, 82, 91) | 버튼 색상 |

## 🔔 알림 시스템

AntiLua는 오른쪽 하단에 알림을 표시하는 기능을 제공합니다.

```lua
-- 기본 알림
AntiLua.Notify("스크립트가 실행되었습니다!")

-- 지속 시간 설정 (기본: 3초)
AntiLua.Notify("5초간 표시되는 알림", 5)

-- 색상 설정
AntiLua.Notify("빨간색 알림", 3, Color3.fromRGB(255, 100, 100))
AntiLua.Notify("파란색 알림", 3, Color3.fromRGB(100, 150, 255))
```

## 📱 UI 제어 함수

생성된 UI 객체는 다음 함수들을 제공합니다:

```lua
local ui = AntiLua.CreateUI({ ... })

-- UI 삭제
ui.destroy()

-- 강제로 활성화/비활성화
ui.set_enabled(true)   -- 활성화
ui.set_enabled(false)  -- 비활성화

-- 현재 상태 확인
local is_active = ui.is_enabled()
print("현재 상태:", is_active)

-- UI 표시/숨김 제어
ui.toggle_visibility() -- UI 숨김/표시 토글
ui.set_visible(false)  -- UI 숨기기
ui.set_visible(true)   -- UI 표시하기
ui.is_visible()        -- UI 표시 상태 확인

-- 스크립트 토글 (버튼 클릭과 동일)
ui.toggle_script()
```

## 💡 실제 사용 예시

### 1. AntiFling 스크립트

```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

-- AntiFling 변수들
local Services = {
    Players = cloneref(game:GetService("Players")),
    RunService = cloneref(game:GetService("RunService"))
}
local player = Services.Players.LocalPlayer
local antifling_velocity_threshold = 85
local antifling_angular_threshold = 25
local antifling_last_safe_cframe = nil
local antifling_enabled = false
local antifling_connection

-- AntiFling 보호 함수
local function protect_character()
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart")

    if root and humanoid and antifling_enabled then
        if root.Velocity.Magnitude <= antifling_velocity_threshold then
            antifling_last_safe_cframe = root.CFrame
        end

        if root.Velocity.Magnitude > antifling_velocity_threshold then
            if antifling_last_safe_cframe then
                root.Velocity = Vector3.new(0,0,0)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                root.AssemblyAngularVelocity = Vector3.new(0,0,0)
                root.CFrame = antifling_last_safe_cframe
            end
        end

        if root.AssemblyAngularVelocity.Magnitude > antifling_angular_threshold then
            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end

        if humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- UI 생성
local ui = AntiLua.CreateUI({
    title = "Real-Time AntiFling",
    button_text = "Activate AntiFling",
    button_text_active = "AntiFling Activated",
    on_toggle = function(enabled)
        antifling_enabled = enabled
        
        if enabled then
            if not antifling_connection then
                antifling_connection = Services.RunService.Heartbeat:Connect(protect_character)
            end
            print("AntiFling 활성화!")
        else
            if antifling_connection then
                antifling_connection:Disconnect()
                antifling_connection = nil
            end
            print("AntiFling 비활성화!")
        end
    end
})
```

### 2. 스피드 핵 스크립트

```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

local original_speed = 16
local speed_enabled = false

local ui = AntiLua.CreateUI({
    title = "Speed Hack",
    button_text = "Enable Speed",
    button_text_active = "Speed Active",
    background_color = Color3.fromRGB(25, 35, 45),
    text_color = Color3.fromRGB(0, 255, 127),
    on_toggle = function(enabled)
        speed_enabled = enabled
        local char = game.Players.LocalPlayer.Character
        
        if char and char:FindFirstChild("Humanoid") then
            if enabled then
                char.Humanoid.WalkSpeed = 100
            else
                char.Humanoid.WalkSpeed = original_speed
            end
        end
    end
})
```

### 3. 점프 핵 스크립트

```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

local jump_connection
local original_jump_power = 50

local ui = AntiLua.CreateUI({
    title = "Infinite Jump",
    button_text = "Enable Jump",
    button_text_active = "Jump Active",
    button_color = Color3.fromRGB(100, 50, 150),
    custom_code = function()
        local char = game.Players.LocalPlayer.Character
        if char then
            char.Humanoid.JumpPower = 200
        end
    end,
    on_toggle = function(enabled)
        local char = game.Players.LocalPlayer.Character
        
        if enabled then
            jump_connection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState("Jumping")
                end
            end)
        else
            if jump_connection then
                jump_connection:Disconnect()
                jump_connection = nil
            end
            if char then
                char.Humanoid.JumpPower = original_jump_power
            end
        end
    end
})
```

## 🎨 커스터마이징 예시

### 토글 키 사용하기

```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

local ui = AntiLua.CreateUI({
    title = "My Script",
    toggle_key = Enum.KeyCode.F1, -- F1 키로 UI 토글
    button_text = "Start",
    button_text_active = "Running"
})

-- 다른 키 예시들:
-- Enum.KeyCode.Insert (기본값)
-- Enum.KeyCode.F1, F2, F3 등
-- Enum.KeyCode.LeftControl
-- Enum.KeyCode.RightShift
-- Enum.KeyCode.Home, End 등
```

### 다크 테마
```lua
local ui = AntiLua.CreateUI({
    title = "Dark Theme Script",
    background_color = Color3.fromRGB(10, 10, 15),
    text_color = Color3.fromRGB(200, 200, 255),
    button_color = Color3.fromRGB(40, 40, 60),
    toggle_key = Enum.KeyCode.F2
})
```
```lua
local ui = AntiLua.CreateUI({
    title = "Big Script Hub",
    size = UDim2.new(0, 350, 0, 150),
    button_text = "Launch All Scripts"
})
```

## 🔧 고급 사용법

### 수동으로 UI 제어하기
```lua
local ui = AntiLua.CreateUI({ ... })

-- 3초 후 자동 활성화
wait(3)
ui.set_enabled(true)

-- 현재 상태 확인
if ui.is_enabled() then
    print("스크립트가 실행중입니다!")
end

-- 10초 후 UI 삭제
wait(10)
ui.destroy()
```

### 여러 UI 동시 사용
```lua
local AntiLua = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ukrubojvo/Modules/main/AntiLua.lua"))()

-- 첫 번째 UI
local speed_ui = AntiLua.CreateUI({
    title = "Speed Hack",
    position = UDim2.new(0.2, 0, 0.3, 0)
})

-- 두 번째 UI
local jump_ui = AntiLua.CreateUI({
    title = "Jump Hack", 
    position = UDim2.new(0.8, 0, 0.3, 0)
})
```

## ✨ 특징

- **토글 키 지원**: 지정한 키를 눌러 UI를 숨기고 표시할 수 있음 (기본: Insert 키)
- **드래그 가능**: UI를 마우스로 드래그하여 이동 가능
- **알림 시스템**: 오른쪽 하단에 슬라이드 애니메이션과 함께 알림 표시
- **부드러운 애니메이션**: 스프링 기반 움직임으로 자연스러운 느낌
- **완전 커스터마이징**: 색상, 크기, 텍스트 모두 변경 가능
- **간단한 API**: 몇 줄의 코드로 전문적인 UI 생성
- **안전함**: gethui() 지원으로 안정적인 실행

## 🛠️ 팁

- `custom_code`는 버튼이 활성화될 때만 실행됩니다
- `on_toggle`은 활성화/비활성화 양쪽 모두에서 실행됩니다
- UI는 자동으로 화면 중앙에 배치되며 드래그로 이동 가능합니다
- 기본적으로 Insert 키를 눌러 UI를 숨기고 표시할 수 있습니다
- `toggle_key`를 다른 키로 설정하여 원하는 키로 변경 가능합니다
- 알림은 여러 개가 동시에 표시될 수 있으며 자동으로 위치가 조정됩니다
- 여러 UI를 동시에 사용할 때는 `position`과 `toggle_key`를 다르게 설정하세요

## 📞 지원

문제가 있거나 기능 요청이 있으시면 언제든 연락주세요!
