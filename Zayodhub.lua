-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") 

-- =========================
-- PLAYER STATE
-- =========================
local State = {
WalkSpeed = 16,
JumpPower = 50,
SpinSpeed = 0,
InfJump = false,
Noclip = false,
} 

local spinConnection, infJumpConnection, noclipConnection = nil, nil, nil 

local function getHumanoid()
local char = player.Character
if not char then return nil end
return char:FindFirstChildOfClass("Humanoid")
end 

local function applyWalkSpeed()
local hum = getHumanoid()
if hum then hum.WalkSpeed = State.WalkSpeed end
end 

local function applyJumpPower()
local hum = getHumanoid()
if hum then hum.UseJumpPower = true; hum.JumpPower = State.JumpPower end
end 

local function applySpin()
if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
if State.SpinSpeed > 0 then
spinConnection = RunService.Heartbeat:Connect(function(dt)
local char = player.Character
if char then
local root = char:FindFirstChild("HumanoidRootPart")
if root then
root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed * dt * 10), 0)
end
end
end)
end
end 

local function applyInfJump()
if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
if State.InfJump then
infJumpConnection = UserInputService.JumpRequest:Connect(function()
local hum = getHumanoid()
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
end
end 

local function applyNoclip()
if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
if State.Noclip then
noclipConnection = RunService.Stepped:Connect(function()
local char = player.Character
if char then
for _, v in ipairs(char:GetDescendants()) do
if v:IsA("BasePart") and v.CanCollide then
v.CanCollide = false
end
end
end
end)
end
end 

-- =========================
-- TROLL STATE
-- =========================
local Troll = {
Fling = false,
Orbit = false,
Freeze = false,
SpinAll = false,
FlingAll = false,
RandomTeleport = false,
} 

local trollConnections = {} 

local function stopTrollConnection(key)
if trollConnections[key] then
trollConnections[key]:Disconnect()
trollConnections[key] = nil
end
end 

local function startFling()
stopTrollConnection("Fling")
trollConnections["Fling"] = RunService.Heartbeat:Connect(function()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if hrp and myHrp then
if (hrp.Position - myHrp.Position).Magnitude < 5 then
hrp.Velocity = Vector3.new(1e6, 1e6, 1e6)
end
end
end
end
end)
end 

local function startOrbit()
stopTrollConnection("Orbit")
local angle = 0
trollConnections["Orbit"] = RunService.Heartbeat:Connect(function(dt)
angle = angle + dt * 3
local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
if not myHrp then return end
local i = 0
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
i = i + 1
local offset = Vector3.new(
math.cos(angle + i * 1.5) * 10,
3,
math.sin(angle + i * 1.5) * 10
)
hrp.CFrame = CFrame.new(myHrp.Position + offset)
end
end
end
end)
end 

local function startFreeze()
stopTrollConnection("Freeze")
trollConnections["Freeze"] = RunService.Heartbeat:Connect(function()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hum = p.Character:FindFirstChildOfClass("Humanoid")
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hum and hrp then
hum.WalkSpeed = 0
hum.JumpPower = 0
hrp.Anchored = true
end
end
end
end)
end 

local function startSpinAll()
stopTrollConnection("SpinAll")
trollConnections["SpinAll"] = RunService.Heartbeat:Connect(function(dt)
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(720 * dt), 0)
end
end
end
end)
end 

local function startFlingAll()
stopTrollConnection("FlingAll")
trollConnections["FlingAll"] = RunService.Heartbeat:Connect(function()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.Velocity = Vector3.new(1e6, 1e6, 1e6)
end
end
end
end)
end 

local function startRandomTeleport()
stopTrollConnection("RandomTeleport")
trollConnections["RandomTeleport"] = RunService.Heartbeat:Connect(function()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= player and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.CFrame = CFrame.new(
math.random(-500, 500),
math.random(50, 200),
math.random(-500, 500)
)
end
end
end
end)
end 

-- =========================
-- ANIMATION STATE
-- =========================
local Anim = {
Current = "Default",
} 

local animConnection = nil
local animTrack = nil 

local animIds = {
Zombie = "rbxassetid://616163682",
Ninja = "rbxassetid://656118852",
Dance = "rbxassetid://507771019",
Cartoon = "rbxassetid://742637542",
OldMan = "rbxassetid://10199101567",
} 

local function stopAnim()
if animConnection then animConnection:Disconnect(); animConnection = nil end
if animTrack then
pcall(function() animTrack:Stop() end)
animTrack = nil
end
end 

local function playAnimLoop(assetId)
stopAnim()
local char = player.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
local animator = hum:FindFirstChildOfClass("Animator")
if not animator then
animator = Instance.new("Animator")
animator.Parent = hum
end 

for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
v:Stop()
end 

local anim = Instance.new("Animation")
anim.AnimationId = assetId
animTrack = animator:LoadAnimation(anim)
animTrack.Looped = true
animTrack:Play() 

animConnection = RunService.Heartbeat:Connect(function()
if not char.Parent then
stopAnim()
return
end
if animTrack and not animTrack.IsPlaying then
animTrack:Play()
end
end)
end 

local function applyAnim()
if Anim.Current == "Default" then
stopAnim()
local char = player.Character
if char then
local animate = char:FindFirstChild("Animate")
if animate then animate.Disabled = false end
end
return
end 

local char = player.Character
if char then
local animate = char:FindFirstChild("Animate")
if animate then animate.Disabled = true end
end 

if animIds[Anim.Current] then
playAnimLoop(animIds[Anim.Current])
end
end 

local function setAnim(mode)
Anim.Current = mode or "Default"
applyAnim()
end 

-- Reapply on respawn
player.CharacterAdded:Connect(function()
task.wait(1)
applyWalkSpeed()
applyJumpPower()
applySpin()
applyInfJump()
applyNoclip()
applyAnim()
end) 

-- =========================
-- GUI SETUP
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZaedHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui 

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
ToggleButton.Text = "Z"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 28
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui 

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton 

local BloodGradient = Instance.new("UIGradient")
BloodGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 0, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 0)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 10, 10)),
})
BloodGradient.Rotation = 45
BloodGradient.Parent = ToggleButton 

local AuraStroke = Instance.new("UIStroke")
AuraStroke.Color = Color3.fromRGB(255, 0, 0)
AuraStroke.Thickness = 2
AuraStroke.Transparency = 0.2
AuraStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AuraStroke.Parent = ToggleButton 

local EdgeStroke = Instance.new("UIStroke")
EdgeStroke.Color = Color3.fromRGB(40, 0, 0)
EdgeStroke.Thickness = 1
EdgeStroke.Transparency = 0
EdgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
EdgeStroke.Parent = ToggleButton 

task.spawn(function()
while ToggleButton.Parent do
for i = 0, 1, 0.05 do
local pulse = math.sin(i * math.pi)
AuraStroke.Transparency = 0.6 - pulse * 0.5
AuraStroke.Thickness = 2 + pulse * 1.5
task.wait(0.03)
end
end
end) 

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui 

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame 

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(120, 0, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame 

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Sidebar.ZIndex = 3 

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar 

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "زايد هب اول نسخه"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Sidebar
Title.ZIndex = 4 

local Creator = Instance.new("TextLabel")
Creator.Size = UDim2.new(1, 0, 0, 20)
Creator.Position = UDim2.new(0, 15, 0, 45)
Creator.BackgroundTransparency = 1
Creator.Text = "من تطوير زايد"
Creator.TextColor3 = Color3.fromRGB(255, 215, 0)
Creator.TextSize = 14
Creator.Font = Enum.Font.GothamMedium
Creator.TextXAlignment = Enum.TextXAlignment.Left
Creator.Parent = Sidebar
Creator.ZIndex = 4 

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -180, 1, -20)
ContentArea.Position = UDim2.new(0, 170, 0, 10)
ContentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame
ContentArea.ZIndex = 3 

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentArea 

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = ContentArea
Scroll.ZIndex = 4 

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll 

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 10)
ListPadding.PaddingLeft = UDim.new(0, 10)
ListPadding.PaddingRight = UDim.new(0, 10)
ListPadding.PaddingBottom = UDim.new(0, 10)
ListPadding.Parent = Scroll 

-- =====================================================
-- HELPERS
-- =====================================================
local function clearContent()
for _, child in ipairs(Scroll:GetChildren()) do
if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
child:Destroy()
end
end
end 

local function makeHeader(text)
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = text
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextSize = 18
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = Scroll
header.ZIndex = 5
end 

local function createScriptRow(scriptName, scriptURL)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 50)
row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
row.BorderSizePixel = 0
row.Parent = Scroll
row.ZIndex = 5 

local rowCorner = Instance.new("UICorner")
rowCorner.CornerRadius = UDim.new(0, 8)
rowCorner.Parent = row 

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -120, 1, 0)
nameLabel.Position = UDim2.new(0, 15, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = scriptName
nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
nameLabel.TextSize = 15
nameLabel.Font = Enum.Font.GothamSemibold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = row
nameLabel.ZIndex = 6 

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0, 90, 0, 34)
execBtn.Position = UDim2.new(1, -105, 0.5, -17)
execBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
execBtn.BorderSizePixel = 0
execBtn.Text = "تشغيل"
execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execBtn.TextSize = 14
execBtn.Font = Enum.Font.GothamBold
execBtn.Parent = row
execBtn.ZIndex = 6 

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 6)
execCorner.Parent = execBtn 

execBtn.MouseButton1Click:Connect(function()
local success, err = pcall(function()
loadstring(game:HttpGet(scriptURL, true))()
end)
if success then
execBtn.Text = "تم ✓"
execBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
task.wait(1.5)
execBtn.Text = "تشغيل"
execBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
else
execBtn.Text = "فشل ✕"
execBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
warn("Script error: " .. tostring(err))
task.wait(1.5)
execBtn.Text = "تشغيل"
execBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
end
end)
end 

local function makeSlider(label, minVal, maxVal, defaultVal, callback)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 50)
row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
row.BorderSizePixel = 0
row.Parent = Scroll
row.ZIndex = 5 

local rowCorner = Instance.new("UICorner")
rowCorner.CornerRadius = UDim.new(0, 8)
rowCorner.Parent = row 

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.35, 0, 1, 0)
lbl.Position = UDim2.new(0, 15, 0, 0)
lbl.BackgroundTransparency = 1
lbl.Text = label
lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
lbl.TextSize = 15
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = row
lbl.ZIndex = 6 

local valBox = Instance.new("TextLabel")
valBox.Size = UDim2.new(0, 40, 0, 24)
valBox.Position = UDim2.new(0.35, 0, 0.5, -12)
valBox.BackgroundTransparency = 1
valBox.Text = tostring(defaultVal)
valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
valBox.TextSize = 15
valBox.Font = Enum.Font.GothamBold
valBox.Parent = row
valBox.ZIndex = 6 

local track = Instance.new("Frame")
track.Size = UDim2.new(0.4, -20, 0, 6)
track.Position = UDim2.new(0.6, 0, 0.5, -3)
track.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
track.BorderSizePixel = 0
track.Parent = row
track.ZIndex = 6 

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track 

local fill = Instance.new("Frame")
fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
fill.BorderSizePixel = 0
fill.Parent = track
fill.ZIndex = 7 

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill 

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
knob.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
knob.BorderSizePixel = 0
knob.Parent = track
knob.ZIndex = 8 

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob 

local dragging = false 

local function updateFromX(mouseX)
local trackAbsPos = track.AbsolutePosition.X
local trackAbsSize = track.AbsoluteSize.X
local alpha = math.clamp((mouseX - trackAbsPos) / trackAbsSize, 0, 1)
local value = math.floor(minVal + alpha * (maxVal - minVal))
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, -8, 0.5, -8)
valBox.Text = tostring(value)
callback(value)
end 

track.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
updateFromX(input.Position.X)
end
end) 

UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateFromX(input.Position.X)
end
end) 

UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
end 

local function makeToggle(label, defaultVal, callback)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 50)
row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
row.BorderSizePixel = 0
row.Parent = Scroll
row.ZIndex = 5 

local rowCorner = Instance.new("UICorner")
rowCorner.CornerRadius = UDim.new(0, 8)
rowCorner.Parent = row 

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.7, 0, 1, 0)
lbl.Position = UDim2.new(0, 15, 0, 0)
lbl.BackgroundTransparency = 1
lbl.Text = label
lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
lbl.TextSize = 15
lbl.Font = Enum.Font.GothamSemibold
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = row
lbl.ZIndex = 6 

local switch = Instance.new("TextButton")
switch.Size = UDim2.new(0, 44, 0, 24)
switch.Position = UDim2.new(1, -60, 0.5, -12)
switch.BackgroundColor3 = defaultVal and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(60, 60, 60)
switch.Text = ""
switch.BorderSizePixel = 0
switch.Parent = row
switch.ZIndex = 6 

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(1, 0)
switchCorner.Parent = switch 

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, 18, 0, 18)
switchKnob.Position = defaultVal and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
switchKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switch
switchKnob.ZIndex = 7 

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = switchKnob 

local state = defaultVal 

switch.MouseButton1Click:Connect(function()
state = not state
if state then
switch.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
switchKnob.Position = UDim2.new(1, -20, 0.5, -9)
else
switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
switchKnob.Position = UDim2.new(0, 2, 0.5, -9)
end
callback(state)
end)
end 

-- =====================================================
-- CATEGORY: أساسي
-- =====================================================
local function showMainContent()
clearContent()
makeHeader("أساسي") 

createScriptRow("ايم بوت شامل", "https://raw.githubusercontent.com/pid4k/scripts/main/universalaimbot.lua")
createScriptRow("اوامر ادمن و تخريب", "https://rawscripts.net/raw/admn-hzyn-or-thdyth-altbra-7zN-83277")
end 

-- =====================================================
-- CATEGORY: لاعب
-- =====================================================
local function showPlayerContent()
clearContent()
makeHeader("لاعب") 

makeSlider("سرعة المشي", 16, 200, State.WalkSpeed, function(v)
State.WalkSpeed = v
applyWalkSpeed()
end) 

makeSlider("قوة القفز", 50, 500, State.JumpPower, function(v)
State.JumpPower = v
applyJumpPower()
end) 

makeSlider("دوران اللاعب", 0, 100, State.SpinSpeed, function(v)
State.SpinSpeed = v
applySpin()
end) 

makeToggle("قفز لا نهائي", State.InfJump, function(on)
State.InfJump = on
applyInfJump()
end) 

makeToggle("اختراق الجدران", State.Noclip, function(on)
State.Noclip = on
applyNoclip()
end)
end 

-- =====================================================
-- CATEGORY: تخريب
-- =====================================================
local function showTrollContent()
clearContent()
makeHeader("تخريب") 

makeToggle("فلينج عند اللمس", Troll.Fling, function(on)
Troll.Fling = on
if on then startFling() else stopTrollConnection("Fling") end
end) 

makeToggle("دوران حولي", Troll.Orbit, function(on)
Troll.Orbit = on
if on then startOrbit() else stopTrollConnection("Orbit") end
end) 

makeToggle("تجميد الكل", Troll.Freeze, function(on)
Troll.Freeze = on
if on then startFreeze() else stopTrollConnection("Freeze") end
end) 

makeToggle("تدوير الكل", Troll.SpinAll, function(on)
Troll.SpinAll = on
if on then startSpinAll() else stopTrollConnection("SpinAll") end
end) 

makeToggle("فلينج الكل", Troll.FlingAll, function(on)
Troll.FlingAll = on
if on then startFlingAll() else stopTrollConnection("FlingAll") end
end) 

makeToggle("تنقل عشوائي للكل", Troll.RandomTeleport, function(on)
Troll.RandomTeleport = on
if on then startRandomTeleport() else stopTrollConnection("RandomTeleport") end
end)
end 

-- =====================================================
-- CATEGORY: حركات
-- =====================================================
local function makeAnimButton(label, mode)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 45)
row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
row.BorderSizePixel = 0
row.Parent = Scroll
row.ZIndex = 5 

local rowCorner = Instance.new("UICorner")
rowCorner.CornerRadius = UDim.new(0, 8)
rowCorner.Parent = row 

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 1, -10)
btn.Position = UDim2.new(0, 10, 0, 5)
btn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
btn.BorderSizePixel = 0
btn.Text = label
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 15
btn.Font = Enum.Font.GothamSemibold
btn.Parent = row
btn.ZIndex = 6 

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn 

btn.MouseButton1Click:Connect(function()
setAnim(mode)
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
task.wait(0.3)
btn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
end)
end 

local function showAnimContent()
clearContent()
makeHeader("حركات") 

makeAnimButton("افتراضي (إلغاء)", "Default")
makeAnimButton("زومبي", "Zombie")
makeAnimButton("نينجا", "Ninja")
makeAnimButton("رقص", "Dance")
makeAnimButton("كرتوني", "Cartoon")
makeAnimButton("عجوز", "OldMan")
end 

-- =====================================================
-- CATEGORY BUTTONS
-- =====================================================
local function createCategoryButton(name, yOffset, contentFunction)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 130, 0, 35)
button.Position = UDim2.new(0, 15, 0, yOffset)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.BorderSizePixel = 0
button.Text = name
button.TextColor3 = Color3.fromRGB(200, 200, 200)
button.TextSize = 14
button.Font = Enum.Font.GothamSemibold
button.TextXAlignment = Enum.TextXAlignment.Left
button.Parent = Sidebar
button.ZIndex = 4 

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.Parent = button 

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = button 

local Indicator = Instance.new("Frame")
Indicator.Name = "Indicator"
Indicator.Size = UDim2.new(0, 3, 1, 0)
Indicator.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Indicator.BorderSizePixel = 0
Indicator.Visible = false
Indicator.Parent = button
Indicator.ZIndex = 5 

button.MouseButton1Click:Connect(function()
for _, child in pairs(Sidebar:GetChildren()) do
if child:IsA("TextButton") then
child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
child.TextColor3 = Color3.fromRGB(200, 200, 200)
if child:FindFirstChild("Indicator") then
child.Indicator.Visible = false
end
end
end 

button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Indicator.Visible = true 

contentFunction()
end) 

return button
end 

createCategoryButton("أساسي", 90, showMainContent)
createCategoryButton("لاعب", 135, showPlayerContent)
createCategoryButton("تخريب", 180, showTrollContent)
createCategoryButton("حركات", 225, showAnimContent) 

-- Show main by default
showMainContent() 

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame
CloseButton.ZIndex = 10 

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton 

CloseButton.MouseButton1Click:Connect(function()
MainFrame.Visible = false
end) 

-- Dragging
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil 

local function updateDrag(input)
local delta = input.Position - mousePos
MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
end 

MainFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
mousePos = input.Position
framePos = MainFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end) 

MainFrame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end) 

UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
updateDrag(input)
end
end) 

-- Toggle
ToggleButton.MouseButton1Click:Connect(function()
MainFrame.Visible = not MainFrame.Visible
end)

