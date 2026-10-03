local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Theme = {
    Background   = Color3.fromRGB(25, 25, 25),
    Surface      = Color3.fromRGB(35, 35, 35),
    Element      = Color3.fromRGB(45, 45, 45),
    ElementHover = Color3.fromRGB(55, 55, 55),
    ElementDisabled = Color3.fromRGB(32, 32, 32),
    Accent       = Color3.fromRGB(255, 255, 255),
    AccentDim    = Color3.fromRGB(120, 120, 120),
    Text         = Color3.fromRGB(230, 230, 230),
    TextDim      = Color3.fromRGB(150, 150, 150),
    TextDisabled = Color3.fromRGB(90, 90, 90),
    Stroke       = Color3.fromRGB(60, 60, 60),
    Font         = Enum.Font.Gotham,
    FontBold     = Enum.Font.GothamBold,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Ravage_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 2)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, all)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.PaddingLeft = UDim.new(0, all)
    p.PaddingRight = UDim.new(0, all)
    p.Parent = parent
    return p
end

local function listLayout(parent, pad, order)
    local l = Instance.new("UIListLayout")
    l.FillDirection = Enum.FillDirection.Vertical
    l.SortOrder = order or Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad or 4)
    l.Parent = parent
    return l
end

--========================================================
-- GRADIENT SYSTEM
--========================================================

local GradientSystem = {
    ActiveGradients = {},
    Scheme = "White",
    Animated = false,
    Speed = 120,
    Time = -1,
}

local function buildBeamSequence(base, beam)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, base),
        ColorSequenceKeypoint.new(0.30, base),
        ColorSequenceKeypoint.new(0.50, beam),
        ColorSequenceKeypoint.new(0.70, base),
        ColorSequenceKeypoint.new(1.00, base),
    })
end

local GradientSchemes = {
    White  = { buildBeamSequence(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 120)) },
    Red    = { buildBeamSequence(Color3.fromRGB(255, 60, 60),   Color3.fromRGB(120, 20, 20))   },
    Blue   = { buildBeamSequence(Color3.fromRGB(80, 150, 255),  Color3.fromRGB(30, 60, 130))   },
    Green  = { buildBeamSequence(Color3.fromRGB(80, 220, 120),  Color3.fromRGB(30, 100, 50))   },
    Purple = { buildBeamSequence(Color3.fromRGB(190, 100, 255), Color3.fromRGB(80, 30, 130))   },
    Gold   = { buildBeamSequence(Color3.fromRGB(255, 215, 80),  Color3.fromRGB(140, 100, 20))  },
}

local SchemeBaseColors = {
    White  = Color3.fromRGB(255, 255, 255),
    Red    = Color3.fromRGB(255, 60, 60),
    Blue   = Color3.fromRGB(80, 150, 255),
    Green  = Color3.fromRGB(80, 220, 120),
    Purple = Color3.fromRGB(190, 100, 255),
    Gold   = Color3.fromRGB(255, 215, 80),
}

local function applyAccentGradient(parent)
    local g = Instance.new("UIGradient")
    g.Color = GradientSchemes[GradientSystem.Scheme][1]
    g.Rotation = 0
    g.Offset = Vector2.new(GradientSystem.Time, 0)
    g.Parent = parent
    table.insert(GradientSystem.ActiveGradients, g)
    return g
end

RunService.RenderStepped:Connect(function(dt)
    if not GradientSystem.Animated then return end
    local step = dt * (GradientSystem.Speed / 300)
    GradientSystem.Time = GradientSystem.Time + step
    if GradientSystem.Time > 1 then
        GradientSystem.Time = -1
    end
    local offset = GradientSystem.Time
    for _, g in ipairs(GradientSystem.ActiveGradients) do
        if g and g.Parent then
            g.Offset = Vector2.new(offset, 0)
        end
    end
end)

--========================================================
-- ROOT UI
--========================================================

local FULL_WIDTH  = 600
local FULL_HEIGHT = 380
local MIN_HEIGHT  = 30
local MIN_WIDTH   = 130

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FULL_WIDTH, 0, FULL_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -FULL_WIDTH / 2, 0.5, -FULL_HEIGHT / 2)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
corner(MainFrame, 4)
stroke(MainFrame, Theme.Stroke, 1)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Theme.Surface
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame
corner(TopBar, 4)
stroke(TopBar, Theme.Stroke, 1)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Ravage"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Theme.FontBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar
applyAccentGradient(TitleLabel)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -26, 0, 5)
CloseButton.BackgroundColor3 = Theme.Element
CloseButton.Text = "X"
CloseButton.TextColor3 = Theme.TextDim
CloseButton.Font = Theme.FontBold
CloseButton.TextSize = 12
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TopBar
corner(CloseButton, 2)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -50, 0, 5)
MinimizeButton.BackgroundColor3 = Theme.Element
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Theme.TextDim
MinimizeButton.Font = Theme.FontBold
MinimizeButton.TextSize = 14
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Parent = TopBar
corner(MinimizeButton, 2)

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -40)
TabBar.Position = UDim2.new(0, 5, 0, 35)
TabBar.BackgroundColor3 = Theme.Surface
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
corner(TabBar, 3)
stroke(TabBar, Theme.Stroke, 1)
padding(TabBar, 5)
listLayout(TabBar, 4)

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -140, 1, -40)
ContentFrame.Position = UDim2.new(0, 130, 0, 35)
ContentFrame.BackgroundColor3 = Theme.Surface
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame
corner(ContentFrame, 3)
stroke(ContentFrame, Theme.Stroke, 1)

local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local minimized = false
local sizeFull = UDim2.new(0, FULL_WIDTH, 0, FULL_HEIGHT)
local sizeMin  = UDim2.new(0, MIN_WIDTH,  0, MIN_HEIGHT)

local function SetMinimized(state)
    minimized = state
    MinimizeButton.Text = state and "+" or "-"
    TabBar.Visible = not state
    ContentFrame.Visible = not state
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, info, {
        Size = state and sizeMin or sizeFull,
    }):Play()
end

MinimizeButton.MouseButton1Click:Connect(function()
    SetMinimized(not minimized)
end)

local Pages = {}
local Tabs = {}

local function SelectTab(name)
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
    for n, t in pairs(Tabs) do
        if n == name then
            t.BackgroundColor3 = Theme.Surface
            t.TextColor3 = Theme.Text
        else
            t.BackgroundColor3 = Theme.Element
            t.TextColor3 = Theme.TextDim
        end
    end
end

local function CreateTab(name)
    local Tab = Instance.new("TextButton")
    Tab.Name = "Tab_" .. name
    Tab.Size = UDim2.new(1, 0, 0, 30)
    Tab.BackgroundColor3 = Theme.Element
    Tab.Text = name
    Tab.TextColor3 = Theme.TextDim
    Tab.Font = Theme.Font
    Tab.TextSize = 13
    Tab.BorderSizePixel = 0
    Tab.AutoButtonColor = false
    Tab.Parent = TabBar
    corner(Tab, 2)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Stroke
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = ContentFrame
    padding(Page, 8)
    listLayout(Page, 7)

    Pages[name] = Page
    Tabs[name] = Tab

    Tab.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)

    return Page
end

local function CreateSection(page, title)
    local Section = Instance.new("Frame")
    Section.Name = "Section_" .. title
    Section.Size = UDim2.new(1, -4, 0, 24)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Theme.Background
    Section.BorderSizePixel = 0
    Section.Parent = page
    corner(Section, 3)
    stroke(Section, Theme.Stroke, 1)
    padding(Section, 7)
    listLayout(Section, 5)

    local Header = Instance.new("TextLabel")
    Header.Name = "SectionTitle"
    Header.Size = UDim2.new(1, 0, 0, 16)
    Header.BackgroundTransparency = 1
    Header.Text = title
    Header.TextColor3 = Theme.Text
    Header.Font = Theme.FontBold
    Header.TextSize = 12
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 1
    Container.Parent = Section
    listLayout(Container, 5)

    return Container
end

local function CreateToggle(container, label, default, callback, isMaster, order)
    local state = default or false

    local Btn = Instance.new("TextButton")
    Btn.Name = "Toggle_" .. label
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Theme.Element
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.LayoutOrder = order or 0
    Btn.Parent = container
    corner(Btn, 2)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = isMaster and Theme.Text or Theme.TextDim
    Label.Font = isMaster and Theme.FontBold or Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 32, 0, 16)
    Indicator.Position = UDim2.new(1, -42, 0.5, -8)
    Indicator.BackgroundColor3 = state and Theme.Accent or Theme.Background
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Btn
    corner(Indicator, 3)
    stroke(Indicator, Theme.Stroke, 1)
    local IndicatorGradient = applyAccentGradient(Indicator)
    IndicatorGradient.Enabled = state

    local api = { Enabled = true }

    local function updateVisual()
        if api.Enabled then
            Btn.BackgroundColor3 = Theme.Element
            Label.TextColor3 = isMaster and Theme.Text or Theme.TextDim
            Indicator.BackgroundColor3 = state and Theme.Accent or Theme.Background
        else
            Btn.BackgroundColor3 = Theme.ElementDisabled
            Label.TextColor3 = Theme.TextDisabled
            Indicator.BackgroundColor3 = Theme.Background
        end
    end

    Btn.MouseEnter:Connect(function()
        if api.Enabled then Btn.BackgroundColor3 = Theme.ElementHover end
    end)
    Btn.MouseLeave:Connect(function()
        if api.Enabled then Btn.BackgroundColor3 = Theme.Element end
    end)
    Btn.MouseButton1Click:Connect(function()
        if not api.Enabled then return end
        state = not state
        IndicatorGradient.Enabled = state
        updateVisual()
        if callback then callback(state) end
    end)

    function api:SetEnabled(v)
        self.Enabled = v
        updateVisual()
    end

    function api:SetState(v)
        state = v
        IndicatorGradient.Enabled = state
        updateVisual()
    end

    updateVisual()
    return api
end

local function CreateSlider(container, label, min, max, default, callback)
    local value = default or min

    local Holder = Instance.new("Frame")
    Holder.Name = "Slider_" .. label
    Holder.Size = UDim2.new(1, 0, 0, 38)
    Holder.BackgroundColor3 = Theme.Element
    Holder.BorderSizePixel = 0
    Holder.Parent = container
    corner(Holder, 2)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = Theme.Text
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 18)
    ValueLabel.Position = UDim2.new(1, -60, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = Theme.Text
    ValueLabel.Font = Theme.Font
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 7)
    Bar.Position = UDim2.new(0, 10, 0, 24)
    Bar.BackgroundColor3 = Theme.Background
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder
    corner(Bar, 4)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    corner(Fill, 4)
    applyAccentGradient(Fill)

    local sliderDragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderDragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliderDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
end

local function CreateButton(container, label, callback, order)
    local Btn = Instance.new("TextButton")
    Btn.Name = "Button_" .. label
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Theme.Element
    Btn.Text = label
    Btn.TextColor3 = Theme.Text
    Btn.Font = Theme.Font
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.LayoutOrder = order or 0
    Btn.Parent = container
    corner(Btn, 2)

    Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Theme.ElementHover end)
    Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Theme.Element end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

--========================================================
-- ESP
--========================================================

local ESP = {
    Master = false,
    Box = false,
    NameTags = false,
    Highlight = false,
    Snaplines = false,
    Color = Color3.fromRGB(255, 255, 255),
    UseSchemeColor = false,
    Objects = {},
    Settings = {},
}

local hasDrawing = (typeof(Drawing) == "table" and typeof(Drawing.new) == "function")

local function newDrawing(class)
    if not hasDrawing then return nil end
    local ok, obj = pcall(Drawing.new, class)
    if ok then return obj end
    return nil
end

local function applyHideNameTags(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.NameDisplayDistance = 0
        hum.HealthDisplayDistance = 0
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

local function restoreNameTags(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.NameDisplayDistance = 100
        hum.HealthDisplayDistance = 100
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    end
end

local function getBoxPoints(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return nil end

    local size = Vector3.new(2, 5.5, 2)
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        size = Vector3.new(2, 6, 2)
    end

    local cf = hrp.CFrame
    local corners = {}
    local half = size / 2

    local offsets = {
        Vector3.new(-half.X, -half.Y, -half.Z),
        Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new( half.X,  half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z),
        Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new(-half.X,  half.Y,  half.Z),
        Vector3.new( half.X,  half.Y,  half.Z),
    }

    for _, off in ipairs(offsets) do
        local world = cf * off
        local screen = Camera:WorldToViewportPoint(world)
        if screen.Z <= 0 then
            return nil
        end
        table.insert(corners, { pos = Vector2.new(screen.X, screen.Y), z = screen.Z })
    end

    return corners
end

local function boundsFromCorners(corners)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, c in ipairs(corners) do
        if c.pos.X < minX then minX = c.pos.X end
        if c.pos.Y < minY then minY = c.pos.Y end
        if c.pos.X > maxX then maxX = c.pos.X end
        if c.pos.Y > maxY then maxY = c.pos.Y end
    end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    if ESP.Objects[plr] then return end

    local boxLines = {}
    if hasDrawing then
        for i = 1, 4 do
            local l = newDrawing("Line")
            if l then
                l.Thickness = 1
                l.Color = ESP.Color
                l.Transparency = 1
                l.Visible = false
                table.insert(boxLines, l)
            end
        end
    end

    local snapline = nil
    if hasDrawing then
        snapline = newDrawing("Line")
        if snapline then
            snapline.Thickness = 1
            snapline.Color = ESP.Color
            snapline.Transparency = 1
            snapline.Visible = false
        end
    end

    local nameGui = Instance.new("BillboardGui")
    nameGui.Name = "Ravage_ESP_Name"
    nameGui.Size = UDim2.new(0, 280, 0, 48)
    nameGui.ExtentsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
    nameGui.AlwaysOnTop = true
    nameGui.LightInfluence = 0
    nameGui.ResetOnSpawn = false
    nameGui.MaxDistance = 2000
    nameGui.Parent = ScreenGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 24)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = ESP.Color
    nameLabel.Font = Theme.FontBold
    nameLabel.TextSize = 18
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = nameGui

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 20)
    distLabel.Position = UDim2.new(0, 0, 0, 24)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0]"
    distLabel.TextColor3 = ESP.Color
    distLabel.Font = Theme.FontBold
    distLabel.TextSize = 16
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Parent = nameGui

    local highlight = Instance.new("Highlight")
    highlight.Name = "Ravage_ESP_Highlight"
    highlight.FillColor = ESP.Color
    highlight.OutlineColor = ESP.Color
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = ScreenGui

    ESP.Objects[plr] = {
        Lines = boxLines,
        Snapline = snapline,
        NameGui = nameGui,
        NameLabel = nameLabel,
        DistLabel = distLabel,
        Highlight = highlight,
    }
end

local function RemoveESP(plr)
    local o = ESP.Objects[plr]
    if not o then return end
    for _, l in ipairs(o.Lines) do
        if l and l.Remove then l:Remove() end
    end
    if o.Snapline and o.Snapline.Remove then o.Snapline:Remove() end
    if o.NameGui then o.NameGui:Destroy() end
    if o.Highlight then o.Highlight:Destroy() end
    ESP.Objects[plr] = nil
end

local function ApplyESPSettings(plr)
    local o = ESP.Objects[plr]
    if not o then return end
    local showTags = ESP.Master and ESP.NameTags
    o.NameGui.Enabled = showTags
    o.NameLabel.Visible = showTags
    o.DistLabel.Visible = showTags
    o.Highlight.Enabled = ESP.Master and ESP.Highlight
    for _, l in ipairs(o.Lines) do
        if l then
            l.Visible = ESP.Master and ESP.Box
            l.Color = ESP.Color
        end
    end
    if o.Snapline then
        o.Snapline.Visible = ESP.Master and ESP.Snaplines
        o.Snapline.Color = ESP.Color
    end
end

local function ApplyNameTags(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    if ESP.Master and ESP.NameTags then
        applyHideNameTags(char)
    else
        restoreNameTags(char)
    end
end

local function ApplyESPSchemeColor()
    local c = ESP.UseSchemeColor and SchemeBaseColors[GradientSystem.Scheme] or Color3.fromRGB(255, 255, 255)
    ESP.Color = c
    for _, o in pairs(ESP.Objects) do
        if o.NameLabel then o.NameLabel.TextColor3 = c end
        if o.DistLabel then o.DistLabel.TextColor3 = c end
        if o.Highlight then
            o.Highlight.FillColor = c
            o.Highlight.OutlineColor = c
        end
        for _, l in ipairs(o.Lines) do
            if l then l.Color = c end
        end
        if o.Snapline then o.Snapline.Color = c end
    end
end

local function ApplyGradientScheme(name)
    if not GradientSchemes[name] then return end
    GradientSystem.Scheme = name
    local seq = GradientSchemes[name][1]
    for _, g in ipairs(GradientSystem.ActiveGradients) do
        if g and g.Parent then
            g.Color = seq
        end
    end
    if ESP.UseSchemeColor then
        ApplyESPSchemeColor()
    end
end

local function RefreshAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            CreateESP(plr)
            ApplyESPSettings(plr)
            ApplyNameTags(plr)
        end
    end
    for plr in pairs(ESP.Objects) do
        ApplyESPSettings(plr)
    end
    for name, toggle in pairs(ESP.Settings) do
        if name ~= "ESP" then
            toggle:SetEnabled(ESP.Master)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if not ESP.Objects[plr] then CreateESP(plr) end
        ApplyESPSettings(plr)
        ApplyNameTags(plr)
    end)
    if ESP.Master then
        CreateESP(plr)
        ApplyESPSettings(plr)
        ApplyNameTags(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    RemoveESP(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            if not ESP.Objects[plr] then CreateESP(plr) end
            ApplyESPSettings(plr)
            ApplyNameTags(plr)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Master then return end

    local originX = Camera.ViewportSize.X / 2
    local originY = 0

    if ESP.NameTags then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then applyHideNameTags(char) end
            end
        end
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for plr, o in pairs(ESP.Objects) do
        local char = plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local rootScreen = Camera:WorldToViewportPoint(hrp.Position)
        local behind = rootScreen.Z <= 0

        if o.NameGui then
            o.NameGui.Adornee = hrp
            o.NameGui.Enabled = ESP.NameTags and (not behind)
        end
        if o.Highlight then
            o.Highlight.Adornee = char
        end

        if ESP.NameTags and myRoot and o.DistLabel then
            local dist = math.floor((myRoot.Position - hrp.Position).Magnitude)
            o.DistLabel.Text = "[" .. dist .. "]"
        end

        if ESP.Box and hasDrawing then
            local corners = getBoxPoints(char)
            if corners and not behind then
                local topLeft, bottomRight = boundsFromCorners(corners)
                local x1, y1 = topLeft.X, topLeft.Y
                local x2, y2 = bottomRight.X, bottomRight.Y

                local segs = {
                    { x1, y1, x2, y1 },
                    { x2, y1, x2, y2 },
                    { x2, y2, x1, y2 },
                    { x1, y2, x1, y1 },
                }

                for i, l in ipairs(o.Lines) do
                    local s = segs[i]
                    if s then
                        l.From = Vector2.new(s[1], s[2])
                        l.To   = Vector2.new(s[3], s[4])
                        l.Visible = true
                    end
                end
            else
                for _, l in ipairs(o.Lines) do
                    if l then l.Visible = false end
                end
            end
        end

        if ESP.Snaplines and o.Snapline then
            local head = char:FindFirstChild("Head")
            local target = head or hrp
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if screenPos.Z > 0 and onScreen then
                o.Snapline.From = Vector2.new(originX, originY)
                o.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                o.Snapline.Visible = true
            else
                o.Snapline.Visible = false
            end
        end
    end
end)

--========================================================
-- BUILD UI
--========================================================

local CombatPage   = CreateTab("Combat")
local VisualsPage  = CreateTab("Visuals")
local SettingsPage = CreateTab("Settings")

local combatAim = CreateSection(CombatPage, "Aim")
local DEFAULT_FOV = 70
CreateSlider(combatAim, "FOV", 70, 120, DEFAULT_FOV, function(value)
    Camera.FieldOfView = value
end)

local visualsEsp = CreateSection(VisualsPage, "ESP")

local masterToggle = CreateToggle(visualsEsp, "ESP", false, function(state)
    ESP.Master = state
    RefreshAll()
end, true, 1)
ESP.Settings["ESP"] = masterToggle

ESP.Settings["NameTags"] = CreateToggle(visualsEsp, "NameTags", false, function(state)
    ESP.NameTags = state
    RefreshAll()
end, false, 2)

ESP.Settings["Highlight"] = CreateToggle(visualsEsp, "Highlight", false, function(state)
    ESP.Highlight = state
    RefreshAll()
end, false, 3)

ESP.Settings["Box"] = CreateToggle(visualsEsp, "Box", false, function(state)
    ESP.Box = state
    RefreshAll()
end, false, 4)

ESP.Settings["Snaplines"] = CreateToggle(visualsEsp, "Snaplines", false, function(state)
    ESP.Snaplines = state
    RefreshAll()
end, false, 5)

--========================================================
-- SETTINGS TAB
--========================================================

local settingsGradient = CreateSection(SettingsPage, "Gradient")

CreateToggle(settingsGradient, "Animated", false, function(state)
    if state then GradientSystem.Time = -1 end
    GradientSystem.Animated = state
end, false, 1)

CreateSlider(settingsGradient, "Speed", 80, 210, 120, function(value)
    GradientSystem.Speed = value
end)

local settingsColor = CreateSection(SettingsPage, "Color Scheme")

CreateToggle(settingsColor, "Apply to ESP", false, function(state)
    ESP.UseSchemeColor = state
    ApplyESPSchemeColor()
end, false, 0)

local schemes = {
    { "White", "White" },
    { "Red", "Red" },
    { "Blue", "Blue" },
    { "Green", "Green" },
    { "Purple", "Purple" },
    { "Gold", "Gold" },
}

for i, s in ipairs(schemes) do
    local displayName = s[1]
    local key = s[2]
    CreateButton(settingsColor, displayName, function()
        ApplyGradientScheme(key)
    end, i)
end

SelectTab("Combat")
