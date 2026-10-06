-- reworked by avelia.cc
-- library reworked 
local Library = {};
do
Library = {
    Open = true;
    Folders = {
        main = "Avelia.cc";
        configs = "Avelia.cc/Configs";
    };
    Accent = Color3.fromRGB(224, 33, 138);
    Pages = {};
    Sections = {};
    Flags = {};
    UnNamedFlags = 0;
    ThemeObjects = {};
    Instances = {};
    Holder = nil;
    PageHolder = nil;
    Gradient = nil;
    UIGradient = nil;
    Keys = {
        [Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC", [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.LeftAlt] = "LA", [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1", [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3", [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5", [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7", [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9", [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~", [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.Semicolon] = ";",
        [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/", [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+", [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3"
    };
    Connections = {};
    UIFont = Font.fromEnum(Enum.Font.GothamBold);
    FontSize = 12;
}

local Flags = {};
local Dropdowns = {};
local Pickers = {};
local VisValues = {};

Library.__index = Library
Library.Pages.__index = Library.Pages
Library.Sections.__index = Library.Sections

local LocalPlayer = game:GetService('Players').LocalPlayer;
local Mouse = LocalPlayer:GetMouse();
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local IS_TOUCH = UserInputService.TouchEnabled
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (from notfic.txt)
-- ═══════════════════════════════════════════════════════════
local NotificationLib = {}
NotificationLib.__index = NotificationLib
NotificationLib.Accent = Library.Accent
NotificationLib.UIFont = Library.UIFont
NotificationLib.FontSize = Library.FontSize

local COLOR_MAIN         = Color3.new(0.1098, 0.1098, 0.1098)
local COLOR_INLINE       = Color3.new(0.0314, 0.0314, 0.0314)
local COLOR_MIDDLE       = Color3.new(0.0431, 0.0431, 0.0431)
local COLOR_BORDER       = Color3.new(0, 0, 0)
local COLOR_TEXT         = Color3.new(0.3059, 0.3059, 0.3059)
local COLOR_GRADIENT_END = Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033)

local TYPE_COLORS = {
    Success = Color3.fromRGB(46, 204, 113),
    Error   = Color3.fromRGB(231, 76, 60),
    Warning = Color3.fromRGB(241, 196, 15),
}

local function BuildIcon(kind, color)
    local Box = Instance.new("Frame")
    Box.Name = "Icon"
    Box.Size = UDim2.new(0, 16, 0, 16)
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    local function Part(x, y, w, h, rot)
        local p = Instance.new("Frame", Box)
        p.AnchorPoint = Vector2.new(0.5, 0.5)
        p.Position = UDim2.new(0, x, 0, y)
        p.Size = UDim2.new(0, w, 0, h)
        p.BackgroundColor3 = color
        p.BorderSizePixel = 0
        p.Rotation = rot or 0
        Instance.new("UICorner", p).CornerRadius = UDim.new(0, 1)
    end
    if kind == "Error" then
        Part(8, 8, 14, 3, 45)
        Part(8, 8, 14, 3, -45)
    elseif kind == "Success" then
        Part(5.5, 10, 7, 3, 45)
        Part(10, 7.5, 11, 3, -45)
    elseif kind == "Warning" then
        Part(8, 6.5, 3, 9, 0)
        Part(8, 13, 3, 3, 0)
    else
        Part(8, 3.5, 3, 3, 0)
        Part(8, 9.5, 3, 9, 0)
    end
    return Box
end

local function makeFadeList(root)
    local list = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("GuiObject") then
            local e = { o = d }
            if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageLabel") then e.bg = d.BackgroundTransparency end
            if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then e.tx = d.TextTransparency end
            if d:IsA("ImageLabel") then e.im = d.ImageTransparency end
            if d:IsA("UIStroke") then e.st = d.Transparency end
            if e.bg or e.tx or e.im or e.st then table.insert(list, e) end
        end
    end
    return list
end

local function fadeSetHidden(list)
    for _, e in ipairs(list) do
        if e.bg then e.o.BackgroundTransparency = 1 end
        if e.tx then e.o.TextTransparency = 1 end
        if e.im then e.o.ImageTransparency = 1 end
        if e.st then e.o.Transparency = 1 end
    end
end

local function fadeIn(list, duration)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    for _, e in ipairs(list) do
        local props = {}
        if e.bg then props.BackgroundTransparency = e.bg end
        if e.tx then props.TextTransparency = e.tx end
        if e.im then props.ImageTransparency = e.im end
        if e.st then props.Transparency = e.st end
        if next(props) then TweenService:Create(e.o, info, props):Play() end
    end
end

local function fadeOut(list, duration)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    for _, e in ipairs(list) do
        local props = {}
        if e.bg then props.BackgroundTransparency = 1 end
        if e.tx then props.TextTransparency = 1 end
        if e.im then props.ImageTransparency = 1 end
        if e.st then props.Transparency = 1 end
        if next(props) then TweenService:Create(e.o, info, props):Play() end
    end
end

function NotificationLib.new(Options)
    local self = setmetatable({}, NotificationLib)
    self.Active = {}
    local parentGui = game.CoreGui
    if RunService:IsStudio() then
        parentGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StandaloneNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 998
    ScreenGui.Parent = parentGui
    self.ScreenGui = ScreenGui

    local Container = Instance.new("Frame", ScreenGui)
    Container.Name = "Container"
    Container.Position = UDim2.new(1, -272, 0, 24)
    Container.Size = UDim2.new(0, 260, 1, -48)
    Container.BackgroundTransparency = 1
    self.Container = Container

    local Layout = Instance.new("UIListLayout", Container)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Top
    Layout.Padding = UDim.new(0, 8)
    return self
end

function NotificationLib:Notify(Options)
    local Properties = Options or {}
    local Type     = Properties.Type or Properties.type or "Info"
    local TitleTxt = Properties.Title or Properties.title or string.lower(Type)
    local Message  = Properties.Message or Properties.message or ""
    local Duration = Properties.Duration or Properties.duration or 5
    local typeColor = TYPE_COLORS[Type] or self.Accent
    if Type == "Info" then typeColor = self.Accent end

    local alive = true
    local entry = { IsInfo = (Type == "Info") }

    local Main = Instance.new("Frame", self.Container)
    Main.Name = "Notification"
    Main.Size = UDim2.new(1, 0, 0, 0)
    Main.BackgroundColor3 = COLOR_MAIN
    Main.BorderColor3 = COLOR_BORDER
    Main.BorderSizePixel = 1
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 3)
    entry.Main = Main

    local Inline = Instance.new("Frame", Main)
    Inline.Position = UDim2.new(0, 2, 0, 2)
    Inline.Size = UDim2.new(1, -4, 1, -4)
    Inline.BackgroundColor3 = COLOR_INLINE
    Inline.BorderColor3 = COLOR_BORDER
    Inline.BorderSizePixel = 1
    Instance.new("UICorner", Inline).CornerRadius = UDim.new(0, 2)

    local Top = Instance.new("Frame", Inline)
    Top.Size = UDim2.new(1, 0, 0, 22)
    Top.BackgroundColor3 = COLOR_INLINE
    Top.BorderSizePixel = 0

    local Icon = BuildIcon(Type, typeColor)
    Icon.Parent = Top
    Icon.Position = UDim2.new(0, 5, 0, 3)
    Icon.BackgroundTransparency = 1
    entry.Icon = Icon

    local Title = Instance.new("TextLabel", Top)
    Title.Position = UDim2.new(0, 26, 0, 0)
    Title.Size = UDim2.new(1, -32, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleTxt
    Title.TextColor3 = self.Accent
    Title.FontFace = self.UIFont
    Title.TextSize = self.FontSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.TextTruncate = Enum.TextTruncate.AtEnd
    entry.Title = Title

    local Line = Instance.new("Frame", Inline)
    Line.Position = UDim2.new(0, 0, 0, 22)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.BackgroundColor3 = Color3.new(1, 1, 1)
    Line.BorderSizePixel = 0
    local Grad = Instance.new("UIGradient", Line)
    Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Accent),
        ColorSequenceKeypoint.new(1, COLOR_GRADIENT_END),
    }
    Grad.Rotation = 180
    entry.Grad = Grad

    local Middle = Instance.new("Frame", Inline)
    Middle.Position = UDim2.new(0, 0, 0, 23)
    Middle.BackgroundColor3 = COLOR_MIDDLE
    Middle.BorderSizePixel = 0

    local MessageLabel = Instance.new("TextLabel", Middle)
    MessageLabel.Position = UDim2.new(0, 7, 0, 4)
    MessageLabel.Size = UDim2.new(1, -14, 0, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = COLOR_TEXT
    MessageLabel.FontFace = self.UIFont
    MessageLabel.TextSize = self.FontSize
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.TextWrapped = true
    entry.MessageLabel = MessageLabel

    local Prog = Instance.new("Frame", Inline)
    Prog.Position = UDim2.new(0, 0, 1, -2)
    Prog.Size = UDim2.new(1, 0, 0, 2)
    Prog.BackgroundColor3 = typeColor
    Prog.BorderSizePixel = 0
    Instance.new("UICorner", Prog).CornerRadius = UDim.new(0, 1)
    entry.Prog = Prog

    local msgH = MessageLabel.TextBounds.Y
    if msgH == 0 and Message ~= "" then msgH = 14 end
    local targetH = msgH + 37
    Middle.Size = UDim2.new(1, 0, 0, msgH + 10)
    MessageLabel.Size = UDim2.new(1, -14, 0, msgH)

    local fadeList = makeFadeList(Main)
    fadeSetHidden(fadeList)
    Main.Position = UDim2.new(0, 320, 0, 0)
    Main.Size = UDim2.new(1, 0, 0, 0)

    TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
    TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, targetH),
    }):Play()
    task.delay(0.06, function()
        if alive then fadeIn(fadeList, 0.4) end
    end)

    MessageLabel.Position = UDim2.new(0, 7, 0, 10)
    TweenService:Create(MessageLabel, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 7, 0, 4),
    }):Play()

    TweenService:Create(Prog, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2),
    }):Play()

    local function remove()
        if not alive then return end
        alive = false
        fadeOut(fadeList, 0.28)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 320, 0, 0),
        }):Play()
        task.delay(0.18, function()
            local collapse = TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
                Size = UDim2.new(1, 0, 0, 0),
            })
            collapse:Play()
            collapse.Completed:Connect(function()
                Main:Destroy()
                local idx = table.find(self.Active, entry)
                if idx then table.remove(self.Active, idx) end
            end)
        end)
    end
    entry.Remove = remove
    task.delay(Duration, remove)
    table.insert(self.Active, entry)
    return entry
end

function NotificationLib:Success(title, message, duration)
    return self:Notify({ Type = "Success", Title = title, Message = message, Duration = duration })
end
function NotificationLib:Error(title, message, duration)
    return self:Notify({ Type = "Error", Title = title, Message = message, Duration = duration })
end
function NotificationLib:Warning(title, message, duration)
    return self:Notify({ Type = "Warning", Title = title, Message = message, Duration = duration })
end
function NotificationLib:Info(title, message, duration)
    return self:Notify({ Type = "Info", Title = title, Message = message, Duration = duration })
end
function NotificationLib:Clear()
    for i = #self.Active, 1, -1 do
        self.Active[i].Remove()
    end
end
function NotificationLib:ChangeAccent(color)
    self.Accent = color
    for _, e in ipairs(self.Active) do
        e.Title.TextColor3 = color
        e.Grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, COLOR_GRADIENT_END),
        }
        if e.IsInfo then
            for _, part in ipairs(e.Icon:GetChildren()) do
                if part:IsA("Frame") then part.BackgroundColor3 = color end
            end
            e.Prog.BackgroundColor3 = color
        end
    end
end

Library.Notifications = NotificationLib.new()

-- ═══════════════════════════════════════════════════════════
-- KEYBIND LIST (from keybind.txt) — standalone
-- ═══════════════════════════════════════════════════════════
local KeybindListLib = {}
KeybindListLib.__index = KeybindListLib
KeybindListLib.Accent = Library.Accent
KeybindListLib.UIFont = Library.UIFont
KeybindListLib.FontSize = Library.FontSize
KeybindListLib.KeyboardIcon = "rbxassetid://82063092844430"

local KB_COLOR_MAIN         = Color3.new(0.1098, 0.1098, 0.1098)
local KB_COLOR_INLINE       = Color3.new(0.0314, 0.0314, 0.0314)
local KB_COLOR_MIDDLE       = Color3.new(0.0431, 0.0431, 0.0431)
local KB_COLOR_BORDER       = Color3.new(0, 0, 0)
local KB_COLOR_TEXT_OFF     = Color3.new(0.3059, 0.3059, 0.3059)
local KB_COLOR_GRADIENT_END = Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033)
local KB_COLOR_DIVIDER      = Color3.new(0.0784, 0.0784, 0.0784)

function KeybindListLib.new(Options)
    local Properties = Options or {}
    local self = setmetatable({}, KeybindListLib)
    self.Open = true
    self.Items = {}
    self.Title = Properties.Name or Properties.Title or "keybinds"
    self.ThemeObjects = {}
    self.Instances = {}
    self._activeCount = 0

    local parentGui = game.CoreGui
    if RunService:IsStudio() then
        parentGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StandaloneKeybindList"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = parentGui

    local Main      = Instance.new("Frame", ScreenGui)
    local Inline    = Instance.new("Frame", Main)
    local Top       = Instance.new("TextButton", Inline)
    local Icon      = Instance.new("ImageLabel", Top)
    local Title     = Instance.new("TextLabel", Top)
    local Line      = Instance.new("Frame", Inline)
    local UIGradient = Instance.new("UIGradient", Line)
    local Middle    = Instance.new("Frame", Inline)
    local Content   = Instance.new("Frame", Middle)
    local UIListLayout = Instance.new("UIListLayout", Content)
    local UIPadding = Instance.new("UIPadding", Content)
    local Scale     = Instance.new("UIScale", Main)

    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 4)
    local InlineCorner = Instance.new("UICorner", Inline)
    InlineCorner.CornerRadius = UDim.new(0, 3)

    table.insert(self.Instances, Main)
    table.insert(self.ThemeObjects, Title)
    table.insert(self.ThemeObjects, Line)
    self.Icon = Icon

    Main.Name = "KeybindsMain"
    Main.Position = Properties.Position or UDim2.new(1, -210, 0.5, -60)
    Main.Size = UDim2.new(0, 195, 0, 37)
    Main.BackgroundColor3 = KB_COLOR_MAIN
    Main.BorderColor3 = KB_COLOR_BORDER
    Main.BorderSizePixel = 1
    Main.Active = true
    Main.ClipsDescendants = false
    Main.AutomaticSize = Enum.AutomaticSize.Y

    Inline.Name = "KeybindsInline"
    Inline.Position = UDim2.new(0, 2, 0, 2)
    Inline.Size = UDim2.new(1, -4, 1, -4)
    Inline.BackgroundColor3 = KB_COLOR_INLINE
    Inline.BorderColor3 = KB_COLOR_BORDER
    Inline.BorderSizePixel = 1
    Inline.AutomaticSize = Enum.AutomaticSize.Y

    Top.Name = "Top"
    Top.Size = UDim2.new(1, 0, 0, 31)
    Top.BackgroundTransparency = 1
    Top.BorderSizePixel = 0
    Top.AutoButtonColor = false
    Top.Text = ""
    Top.Active = true

    Icon.Name = "Icon"
    Icon.Position = UDim2.new(0, 5, 0, 3)
    Icon.Size = UDim2.new(0, 25, 0, 25)
    Icon.BackgroundTransparency = 1
    Icon.Image = self.KeyboardIcon
    Icon.ImageColor3 = Properties.IconColor or Color3.new(1, 1, 1)
    Icon.ScaleType = Enum.ScaleType.Fit

    Title.Name = "Title"
    Title.Position = UDim2.new(0, 35, 0, 0)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.Text = self.Title
    Title.TextColor3 = self.Accent
    Title.FontFace = self.UIFont
    Title.TextSize = self.FontSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.RichText = true

    Line.Name = "Line"
    Line.Position = UDim2.new(0, 0, 0, 31)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.BackgroundColor3 = Color3.new(1, 1, 1)
    Line.BorderSizePixel = 0
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Accent),
        ColorSequenceKeypoint.new(1, KB_COLOR_GRADIENT_END)
    }
    UIGradient.Rotation = 180

    Middle.Name = "Middle"
    Middle.Position = UDim2.new(0, 0, 0, 32)
    Middle.Size = UDim2.new(1, 0, 0, 0)
    Middle.BackgroundColor3 = KB_COLOR_MIDDLE
    Middle.BorderSizePixel = 0
    Middle.AutomaticSize = Enum.AutomaticSize.Y

    Content.Name = "Content"
    Content.Position = UDim2.new(0, 6, 0, 0)
    Content.Size = UDim2.new(1, -12, 0, 0)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.AutomaticSize = Enum.AutomaticSize.Y
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 3)
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.PaddingBottom = UDim.new(0, 6)

    -- // ПЛАВНЫЙ ДРАГГ (исправлено)
    local dragging = false
    local grabOffset = Vector2.zero
    local targetPos = nil
    local currentPos = nil

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            grabOffset = Vector2.new(
                input.Position.X - Main.AbsolutePosition.X,
                input.Position.Y - Main.AbsolutePosition.Y
            )
            targetPos = Vector2.new(Main.AbsolutePosition.X, Main.AbsolutePosition.Y)
            if not currentPos then currentPos = targetPos end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            targetPos = Vector2.new(
                input.Position.X - grabOffset.X,
                input.Position.Y - grabOffset.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function(dt)
        if currentPos and targetPos then
            local alpha = 1 - math.exp(-25 * dt)
            currentPos = currentPos:Lerp(targetPos, alpha)
            Main.Position = UDim2.fromOffset(currentPos.X, currentPos.Y)
        end
    end)

    local function refreshTitle()
        local active = 0
        for _, it in ipairs(self.Items) do
            if it.State then active = active + 1 end
        end
        self._activeCount = active
        if active > 0 then
            Title.Text = string.format('%s <font color="#FFFFFF">(%d)</font>', self.Title, active)
        else
            Title.Text = self.Title
        end
    end

    local function CheckKey(input, isDown)
        for _, item in ipairs(self.Items) do
            if item.Key == nil then continue end
            local matches = false
            if typeof(item.Key) == "EnumItem" then
                if input.KeyCode == item.Key or input.UserInputType == item.Key then
                    matches = true
                end
            end
            if not matches then continue end
            if item.Mode == "Hold" then
                if item.State ~= isDown then
                    item.State = isDown
                    item:Update()
                    if item.Callback then item.Callback(isDown) end
                end
            elseif item.Mode == "Toggle" and isDown then
                item.State = not item.State
                item:Update()
                if item.Callback then item.Callback(item.State) end
            end
        end
        refreshTitle()
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        CheckKey(input, true)
    end)
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        CheckKey(input, false)
    end)

    local LayoutOrder = 0
    function self:Add(Name, Key, Mode, State, Callback)
        local list = self
        local Item = {
            Name = Name or "new bind",
            Key = Key,
            Mode = Mode or "Toggle",
            State = State or false,
            Callback = Callback or function() end,
        }
        LayoutOrder = LayoutOrder + 1

        local Row = Instance.new("Frame", Content)
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.Size = UDim2.new(1, 0, 0, 0)
        Row.LayoutOrder = LayoutOrder
        Row.ClipsDescendants = true

        local AccentBar = Instance.new("Frame", Row)
        AccentBar.Size = UDim2.new(0, 2, 1, -4)
        AccentBar.Position = UDim2.new(0, -2, 0, 2)
        AccentBar.BackgroundColor3 = list.Accent
        AccentBar.BorderSizePixel = 0
        AccentBar.BackgroundTransparency = 0
        Item.AccentBar = AccentBar

        local Label = Instance.new("TextLabel", Row)
        Label.BackgroundTransparency = 1
        Label.BorderSizePixel = 0
        Label.Size = UDim2.new(1, -4, 1, 0)
        Label.Position = UDim2.new(0, 4, 0, 0)
        Label.FontFace = list.UIFont
        Label.TextSize = list.FontSize
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.RichText = true
        table.insert(self.Instances, Label)

        local Divider = Instance.new("Frame", Row)
        Divider.Name = "Divider"
        Divider.AnchorPoint = Vector2.new(0, 1)
        Divider.Position = UDim2.new(0, 0, 1, 1)
        Divider.Size = UDim2.new(1, 0, 0, 1)
        Divider.BackgroundColor3 = KB_COLOR_DIVIDER
        Divider.BorderSizePixel = 0
        Divider.BackgroundTransparency = 1
        Divider.ZIndex = 0
        Item.Divider = Divider

        local lastState = nil

        local function animateBar(on)
            if Item._barTween then Item._barTween:Cancel() end
            if Item._barPulse then Item._barPulse:Cancel() end
            if on then
                AccentBar.Position = UDim2.new(0, -2, 0, 2)
                AccentBar.Size = UDim2.new(0, 2, 1, -4)
                Item._barTween = TweenService:Create(
                    AccentBar,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0, 0, 0, 2) }
                )
                Item._barTween:Play()
                Item._barTween.Completed:Connect(function()
                    if not Item.State then return end
                    Item._barPulse = TweenService:Create(
                        AccentBar,
                        TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                        { Size = UDim2.new(0, 2, 1, -7) }
                    )
                    Item._barPulse:Play()
                end)
            else
                Item._barTween = TweenService:Create(
                    AccentBar,
                    TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    {
                        Position = UDim2.new(0, -2, 0, 2),
                        Size = UDim2.new(0, 2, 1, -4),
                    }
                )
                Item._barTween:Play()
            end
        end

        local function animateLabel()
            if Item._labelTween then Item._labelTween:Cancel() end
            Label.TextTransparency = 0.3
            Item._labelTween = TweenService:Create(
                Label,
                TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { TextTransparency = 0 }
            )
            Item._labelTween:Play()
        end

        local function animateDivider(show)
            if Item._divTween then Item._divTween:Cancel() end
            Item._divTween = TweenService:Create(
                Divider,
                TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { BackgroundTransparency = show and 0 or 1 }
            )
            Item._divTween:Play()
        end

        function Item:Update()
            local keytext = "-"
            if typeof(Item.Key) == "EnumItem" then
                keytext = Library.Keys[Item.Key] or Item.Key.Name
            elseif typeof(Item.Key) == "string" then
                keytext = Item.Key
            end
            local modeletter = Item.Mode == "Hold" and "[H]"
                or Item.Mode == "Toggle" and "[T]"
                or "[A]"
            if Item.State then
                Label.Text = string.format(
                    '<b><font color="#FFFFFF">%s</font></b> <font color="#%s">[%s] %s</font>',
                    Item.Name, list.Accent:ToHex(), keytext, modeletter
                )
            else
                Label.Text = string.format(
                    '<font color="#%s">%s [%s] %s</font>',
                    KB_COLOR_TEXT_OFF:ToHex(), Item.Name, keytext, modeletter
                )
            end
            if lastState ~= nil and Item.State ~= lastState then
                animateBar(Item.State)
                animateLabel()
            else
                if lastState == nil then
                    AccentBar.Position = Item.State and UDim2.new(0, 0, 0, 2) or UDim2.new(0, -2, 0, 2)
                    if Item.State then
                        Item._barPulse = TweenService:Create(
                            AccentBar,
                            TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                            { Size = UDim2.new(0, 2, 1, -7) }
                        )
                        Item._barPulse:Play()
                    end
                end
            end
            lastState = Item.State
        end
        Item.Instance = Row

        function Item:SetState(bool)
            if Item.State ~= bool then
                Item.State = bool
                Item:Update()
                refreshTitle()
            end
        end
        function Item:SetKey(key)
            Item.Key = key
            Item:Update()
        end
        function Item:SetMode(mode)
            Item.Mode = mode
            Item:Update()
        end
        function Item:Remove()
            local idx = table.find(list.Items, Item)
            if idx then table.remove(list.Items, idx) end
            if Item._removing then return end
            Item._removing = true
            if Item._barPulse then Item._barPulse:Cancel() end
            fadeOut(makeFadeList(Row), 0.25)
            local collapse = TweenService:Create(Row, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
                Size = UDim2.new(1, 0, 0, 0),
            })
            collapse:Play()
            collapse.Completed:Connect(function() Row:Destroy() end)
            refreshTitle()
        end

        Item:Update()
        table.insert(self.Items, Item)
        if Item.Mode == "Always" then
            Item.State = true
            lastState = nil
            Item:Update()
            lastState = true
            Item.Callback(true)
        end

        Label.TextTransparency = 1
        Label.Position = UDim2.new(0, 12, 0, 0)
        Row.Size = UDim2.new(1, 0, 0, 0)
        AccentBar.Position = UDim2.new(0, -2, 0, 2)
        Divider.BackgroundTransparency = 1
        TweenService:Create(Row, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 15),
        }):Play()
        TweenService:Create(Label, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            Position = UDim2.new(0, 4, 0, 0),
        }):Play()
        task.delay(0.15, function()
            if Row.Parent then animateDivider(true) end
        end)
        refreshTitle()
        return Item
    end

    function self:Clear()
        local copy = table.clone(self.Items)
        for _, item in ipairs(copy) do item:Remove() end
        table.clear(self.Items)
        LayoutOrder = 0
        refreshTitle()
    end

    function self:SetOpen(bool)
        if self.Open == bool then return end
        self.Open = bool
        local fadeList = makeFadeList(Main)
        if bool then
            Main.Visible = true
            Scale.Scale = 0.9
            fadeSetHidden(fadeList)
            TweenService:Create(Scale, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            fadeIn(fadeList, 0.5)
        else
            fadeOut(fadeList, 0.4)
            TweenService:Create(Scale, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.9 }):Play()
            task.delay(0.48, function()
                if not self.Open then Main.Visible = false end
            end)
        end
    end

    function self:ChangeAccent(color)
        self.Accent = color
        if self._iconTinted then self.Icon.ImageColor3 = color end
        for _, obj in ipairs(self.ThemeObjects) do
            if obj:IsA("TextLabel") then
                obj.TextColor3 = color
            elseif obj:IsA("Frame") then
                local grad = obj:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, color),
                        ColorSequenceKeypoint.new(1, KB_COLOR_GRADIENT_END),
                    }
                end
            end
        end
        for _, item in ipairs(self.Items) do
            item.AccentBar.BackgroundColor3 = color
            item:Update()
        end
    end

    if Properties.IconColor then self._iconTinted = true end

    local entranceFade = makeFadeList(Main)
    fadeSetHidden(entranceFade)
    Scale.Scale = 0.88
    local basePos = Properties.Position or UDim2.new(1, -210, 0.5, -60)
    Main.Position = basePos + UDim2.new(0, 6, 0, 14)
    task.delay(0.05, function()
        TweenService:Create(Scale, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = basePos,
        }):Play()
        fadeIn(entranceFade, 0.65)
    end)
    return self
end

Library.Keybinds = KeybindListLib.new({ Name = "keybinds" })

-- ═══════════════════════════════════════════════════════════
-- CONFIG SYSTEM (with dropdown)
-- ═══════════════════════════════════════════════════════════
local CONFIG_FOLDER = "Avelia.cc/cfgs"
local function ensureFolders()
    pcall(function()
        if not isfolder("Avelia.cc") then makefolder("Avelia.cc") end
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
end
local function getPath(name) return CONFIG_FOLDER .. "/" .. name .. ".cfg" end
local function saveConfig(name, data)
    ensureFolders()
    local ok, err = pcall(writefile, getPath(name), data)
    return ok, err
end
local function loadConfig(name)
    if isfile(getPath(name)) then
        local ok, data = pcall(readfile, getPath(name))
        if ok then return data end
    end
    return nil
end
local function deleteConfig(name)
    if isfile(getPath(name)) then
        pcall(delfile, getPath(name))
        return true
    end
    return false
end
local function listConfigs()
    ensureFolders()
    local names = {}
    if isfolder(CONFIG_FOLDER) then
        local ok, files = pcall(listfiles, CONFIG_FOLDER)
        if ok and files then
            for _, f in ipairs(files) do
                local n = f:match("([^/\\]+)%.cfg$")
                if n then table.insert(names, n) end
            end
        end
    end
    table.sort(names)
    return names
end
Library.Config = {
    Save = saveConfig,
    Load = loadConfig,
    Delete = deleteConfig,
    List = listConfigs,
}

-- ═══════════════════════════════════════════════════════════
-- MISC FUNCTIONS
-- ═══════════════════════════════════════════════════════════
do
    function Library:Connection(Signal, Callback)
        local Con = Signal:Connect(Callback)
        return Con
    end
    function Library:Disconnect(Connection)
        Connection:Disconnect()
    end
    function Library:Round(Number, Float)
        return Float * math.floor(Number / Float)
    end
    function Library.NextFlag()
        Library.UnNamedFlags = Library.UnNamedFlags + 1
        return string.format("%.14g", Library.UnNamedFlags)
    end
    function Library:RGBA(r, g, b, alpha)
        return Color3.fromRGB(r, g, b)
    end
    function Library:MakeDraggable(Instance, Button, Cutoff)
        Instance.Active = true;
        Button.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local ObjPos = Vector2.new(
                    Mouse.X - Instance.AbsolutePosition.X,
                    Mouse.Y - Instance.AbsolutePosition.Y
                );
                if ObjPos.Y > (Cutoff or 40) then return; end;
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(
                        0, Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                        0, Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                    );
                    RunService.RenderStepped:Wait();
                end;
            end;
        end);
    end;

    function Library:GetConfig()
        local Config = ""
        for Index, Value in pairs(self.Flags) do
            if Index ~= "ConfigConfig_List" and Index ~= "ConfigConfig_Load" and Index ~= "ConfigConfig_Save" then
                local Value2 = Value
                local Final = ""
                if typeof(Value2) == "Color3" then
                    local hue, sat, val = Value2:ToHSV()
                    Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, 1)
                elseif typeof(Value2) == "table" and Value2.Color and Value2.Transparency then
                    local hue, sat, val = Value2.Color:ToHSV()
                    Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, Value2.Transparency)
                elseif typeof(Value2) == "table" and Value.Mode then
                    local Values = Value.current
                    Final = ("key(%s,%s,%s)"):format(Values[1] or "nil", Values[2] or "nil", Value.Mode)
                elseif Value2 ~= nil then
                    if typeof(Value2) == "boolean" then
                        Value2 = ("bool(%s)"):format(tostring(Value2))
                    elseif typeof(Value2) == "table" then
                        local New = "table("
                        for Index2, Value3 in pairs(Value2) do New = New .. Value3 .. "," end
                        if New:sub(#New) == "," then New = New:sub(0, #New - 1) end
                        Value2 = New .. ")"
                    elseif typeof(Value2) == "string" then
                        Value2 = ("string(%s)"):format(Value2)
                    elseif typeof(Value2) == "number" then
                        Value2 = ("number(%s)"):format(Value2)
                    end
                    Final = Value2
                end
                Config = Config .. Index .. ": " .. tostring(Final) .. "\n"
            end
        end
        return Config
    end

    function Library:LoadConfig(Config)
        local Table = string.split(Config, "\n")
        local Table2 = {}
        for Index, Value in pairs(Table) do
            local Table3 = string.split(Value, ":")
            if Table3[1] ~= "ConfigConfig_List" and #Table3 >= 2 then
                local Value = Table3[2]:sub(2, #Table3[2])
                if Value:sub(1, 3) == "rgb" then
                    Value = string.split(Value:sub(5, #Value - 1), ",")
                elseif Value:sub(1, 3) == "key" then
                    local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                    if Table4[1] == "nil" and Table4[2] == "nil" then Table4[1] = nil Table4[2] = nil end
                    Value = Table4
                elseif Value:sub(1, 4) == "bool" then
                    Value = Value:sub(6, #Value - 1) == "true"
                elseif Value:sub(1, 5) == "table" then
                    Value = string.split(Value:sub(7, #Value - 1), ",")
                elseif Value:sub(1, 6) == "string" then
                    Value = Value:sub(8, #Value - 1)
                elseif Value:sub(1, 6) == "number" then
                    Value = tonumber(Value:sub(8, #Value - 1))
                end
                Table2[Table3[1]] = Value
            end
        end
        for i, v in pairs(Table2) do
            if Flags[i] then
                if typeof(Flags[i]) == "table" then Flags[i]:Set(v) else Flags[i](v) end
            end
        end
    end

    function Library:SetOpen(bool)
        if typeof(bool) == 'boolean' then
            Library.Open = bool;
            if bool then Library.Holder.Visible = true end
            for _,v in next, Library.Instances do
                if v:IsA("Frame") or v:IsA("TextButton") then
                    if v.BackgroundTransparency ~= 1 then
                        task.spawn(function()
                            local t = TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {BackgroundTransparency = bool and 0 or 0.95})
                            t.Completed:Connect(function()
                                if bool == false then Library.Holder.Visible = false end
                            end)
                            t:Play()
                        end)
                    end
                elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                    if v.TextTransparency ~= 1 and v.BackgroundTransparency == 1 then
                        task.spawn(function()
                            TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {TextTransparency = bool and 0 or 0.95}):Play()
                        end)
                    end
                elseif v:IsA("UIStroke") then
                    task.spawn(function()
                        TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Transparency = bool and 0 or 0.95}):Play()
                    end)
                elseif v:IsA("ImageButton") then
                    task.spawn(function()
                        TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {ImageTransparency = bool and 0 or 0.95, BackgroundTransparency = bool and 0 or 0.95}):Play()
                    end)
                end
            end
            task.spawn(function()
                TweenService:Create(Library.PageHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quad, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = bool and UDim2.new(0,60,0,0) or UDim2.new(0,0,0,0)}):Play()
                if bool then task.wait(0.05) end
                TweenService:Create(Library.Gradient, TweenInfo.new(0.25, Enum.EasingStyle.Quad, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = bool and UDim2.new(0.5,0,0,2) or UDim2.new(1,0,0,2)}):Play()
                TweenService:Create(Library.Gradient, TweenInfo.new(0.25, Enum.EasingStyle.Quad, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Size = bool and UDim2.new(0.5,0,0,1) or UDim2.new(0,0,0,1)}):Play()
            end)
        end
    end;

    function Library:ChangeAccent(Color)
        Library.Accent = Color
        for obj, theme in next, Library.ThemeObjects do
            if theme:IsA("Frame") or theme:IsA("TextButton") then
                theme.BackgroundColor3 = Color
            elseif theme:IsA("TextLabel") then
                theme.TextColor3 = Color
            end
        end
        Library.UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color),
            ColorSequenceKeypoint.new(1, Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033))
        }
        Library.Notifications:ChangeAccent(Color)
        Library.Keybinds:ChangeAccent(Color)
    end

    function Library:IsMouseOverFrame(Frame)
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
            return true;
        end;
    end;
end

-- ═══════════════════════════════════════════════════════════
-- COLORPICKER
-- ═══════════════════════════════════════════════════════════
do
    function Library:NewPicker(default, defaultalpha, parent, count, flag, callback)
        local Icon = Instance.new('TextButton', parent)
        local Gradient = Instance.new('UIGradient', Icon)
        local Window = Instance.new('Frame', Icon)
        local Sat = Instance.new('ImageButton', Window)
        local Hue = Instance.new('ImageButton', Window)

        do
            table.insert(Library.Instances, Icon)
            table.insert(Library.Instances, Window)
            table.insert(Library.Instances, Sat)
            table.insert(Library.Instances, Hue)
            table.insert(Pickers, Window)
        end

        Icon.Name = "Icon"
        Icon.Position = UDim2.new(1, -30 - (count * 15) - (count * 6), 0, 4)
        Icon.Size = UDim2.new(0, 15, 0, 6)
        Icon.BackgroundColor3 = default
        Icon.BorderColor3 = Color3.new(0, 0, 0)
        Icon.AutoButtonColor = false
        Icon.Text = ""

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        Window.Name = "Window"
        Window.Position = UDim2.new(0, -120, 0, 10)
        Window.Size = UDim2.new(0, 150, 0, 133)
        Window.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Window.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Window.ZIndex = 1220
        Window.Visible = false

        Sat.Name = "Sat"
        Sat.Position = UDim2.new(0, 5, 0, 5)
        Sat.Size = UDim2.new(0, 123, 0, 123)
        Sat.BackgroundColor3 = default
        Sat.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Sat.Image = "http://www.roblox.com/asset/?id=13882904626"
        Sat.AutoButtonColor = false
        Sat.ZIndex = 1220

        Hue.Name = "Hue"
        Hue.Position = UDim2.new(1, -15, 0, 5)
        Hue.Size = UDim2.new(0, 10, 0, 123)
        Hue.BackgroundColor3 = Color3.new(1, 1, 1)
        Hue.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Hue.Image = "http://www.roblox.com/asset/?id=13882976736"
        Hue.ZIndex = 1220
        Hue.AutoButtonColor = false

        local hue, sat, val = default:ToHSV()
        local hsv = default:ToHSV()
        local alpha = defaultalpha
        local oldcolor = hsv

        local function set(color, a, nopos, setcolor)
            if type(color) == "table" then
                a = color[4]
                color = Color3.fromHSV(color[1], color[2], color[3])
            end
            if type(color) == "string" then color = Color3.fromHex(color) end
            local oldalpha = alpha
            hue, sat, val = color:ToHSV()
            alpha = a or 1
            hsv = Color3.fromHSV(hue, sat, val)
            if hsv ~= oldcolor or alpha ~= oldalpha then
                Icon.BackgroundColor3 = hsv
                if not nopos and setcolor then
                    Sat.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                end
                if flag then
                    Library.Flags[flag] = Library:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
                end
                callback(Library:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha))
            end
        end
        Flags[flag] = set
        set(default, defaultalpha)

        local defhue = default:ToHSV()
        local curhuesizey = defhue
        local function updatesatval(input, set_callback)
            local sizeX = math.clamp((input.Position.X - Sat.AbsolutePosition.X) / Sat.AbsoluteSize.X, 0, 1)
            local sizeY = 1 - math.clamp((((input.Position.Y - 30) - Sat.AbsolutePosition.Y) + 36) / Sat.AbsoluteSize.Y, 0, 1)
            if set_callback then
                set(Color3.fromHSV(curhuesizey or hue, sizeX, sizeY), alpha or defaultalpha, true, false)
            end
        end
        local slidingsaturation = false
        Sat.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingsaturation = true
                updatesatval(input)
            end
        end)
        Sat.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidingsaturation = false
                updatesatval(input, true)
            end
        end)

        local slidinghue = false
        local function updatehue(input, set_callback)
            local sizeY = 1 - math.clamp((((input.Position.Y - 30) - Hue.AbsolutePosition.Y) + 36) / Hue.AbsoluteSize.Y, 0, 1)
            Sat.BackgroundColor3 = Color3.fromHSV(sizeY, 1, 1)
            curhuesizey = sizeY
            if set_callback then
                set(Color3.fromHSV(sizeY, sat, val), alpha or defaultalpha, true, true)
            end
        end
        Hue.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidinghue = true
                updatehue(input)
            end
        end)
        Hue.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slidinghue = false
                updatehue(input, true)
            end
        end)

        Library:Connection(UserInputService.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if slidinghue then updatehue(input, true) end
                if slidingsaturation then updatesatval(input, true) end
            end
        end)

        Icon.MouseButton1Click:Connect(function()
            Window.Visible = not Window.Visible
            slidinghue = false
            slidingsaturation = false
        end)

        local colorpickertypes = {}
        function colorpickertypes:Set(color, alpha) set(color) end

        Library:Connection(UserInputService.InputBegan, function(Input)
            if Window.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Library:IsMouseOverFrame(Window) and not Library:IsMouseOverFrame(Icon) then
                    Window.Visible = false
                end
            end
        end)
        return colorpickertypes, Window
    end
end

-- ═══════════════════════════════════════════════════════════
-- LIBRARY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
do
    local Pages = Library.Pages;
    local Sections = Library.Sections;

    function Library:Window(Options)
        local Base = {
            Pages = {};
            Sections = {};
            Elements = {};
            Dragging = { false, UDim2.new(0, 0, 0, 0) };
            Title = Options.Name or Options.Name or Options.Name or "new ui";
        };

        local ScreenGui = Instance.new('ScreenGui', RunService:IsStudio() and game.Players.LocalPlayer.PlayerGui or game.CoreGui)
        local Main = Instance.new('Frame', ScreenGui)
        local Inline = Instance.new('Frame', Main)
        local Middle = Instance.new('Frame', Inline)
        local Line = Instance.new('Frame', Middle)
        local Line2 = Instance.new('Frame', Middle)
        local Gradient = Instance.new('Frame', Middle)
        local UIGradient = Instance.new('UIGradient', Gradient)
        local Top = Instance.new('TextButton', Inline)
        local Title = Instance.new('TextLabel', Top)
        local Bottom = Instance.new('Frame', Inline)
        local Sections = Instance.new('Frame', Middle)
        local Pages = Instance.new('Frame', Top)
        local UIListLayout = Instance.new('UIListLayout', Pages)
        local version = Instance.new('TextLabel', Bottom)
        local corner1 = Instance.new('UICorner', Main)
        local corner2 = Instance.new('UICorner', Inline)
        local stroke1 = Instance.new('UIStroke', Main)
        local stroke2 = Instance.new('UIStroke', Inline)

        do
            table.insert(Library.Instances, Main)
            table.insert(Library.Instances, Inline)
            table.insert(Library.Instances, Middle)
            table.insert(Library.Instances, Line)
            table.insert(Library.Instances, Line2)
            table.insert(Library.Instances, Gradient)
            table.insert(Library.Instances, Title)
            table.insert(Library.Instances, Sections)
            table.insert(Library.Instances, version)
            table.insert(Library.ThemeObjects, Title)
            table.insert(Library.ThemeObjects, version)
        end

        ScreenGui.DisplayOrder = 2

        -- // MOBILE FLOATING ICON (from ui.txt)
        local IconAsset = "rbxassetid://76003920414364"
        local ICON_BTN_SIZE = IS_MOBILE and 26 or 24
        local IconBtn = Instance.new('TextButton', Top)
        IconBtn.Name = "IconBtn"
        IconBtn.AnchorPoint = Vector2.new(0, 0.5)
        IconBtn.Position = UDim2.new(0, 2, 0.5, 0)
        IconBtn.Size = UDim2.new(0, ICON_BTN_SIZE, 0, ICON_BTN_SIZE)
        IconBtn.BackgroundTransparency = 1
        IconBtn.BorderSizePixel = 0
        IconBtn.Text = ""
        IconBtn.AutoButtonColor = false
        IconBtn.ZIndex = 60

        local IconImg = Instance.new('ImageLabel', IconBtn)
        IconImg.Name = "Icon"
        IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        IconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        IconImg.Size = UDim2.new(1, 0, 1, 0)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = IconAsset
        IconImg.ImageColor3 = Library.Accent
        IconImg.ScaleType = Enum.ScaleType.Fit

        local function setIconState(state)
            local targetColor
            if state == "hover" then
                targetColor = Color3.fromRGB(255, 110, 190)
            elseif state == "press" then
                targetColor = Color3.fromRGB(255, 50, 150)
            else
                targetColor = Library.Accent
            end
            TweenService:Create(IconImg, TweenInfo.new(0.12), {
                ImageColor3 = targetColor
            }):Play()
        end

        -- // Float button для телефонов
        local FLOAT_SIZE = IS_MOBILE and 64 or 54
        local FLOAT_ICON_SIZE = IS_MOBILE and 56 or 46
        local FloatBtn = Instance.new("TextButton", ScreenGui)
        FloatBtn.Name = "FloatBtn"
        FloatBtn.Size = UDim2.new(0, FLOAT_SIZE, 0, FLOAT_SIZE)
        FloatBtn.Position = UDim2.new(0, 20, 0.5, -FLOAT_SIZE / 2)
        FloatBtn.BackgroundTransparency = 1
        FloatBtn.BorderSizePixel = 0
        FloatBtn.Text = ""
        FloatBtn.AutoButtonColor = false
        FloatBtn.Visible = false
        FloatBtn.Active = true
        FloatBtn.Draggable = true

        local FloatIcon = Instance.new("ImageLabel", FloatBtn)
        FloatIcon.Name = "Icon"
        FloatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        FloatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        FloatIcon.Size = UDim2.new(0, FLOAT_ICON_SIZE, 0, FLOAT_ICON_SIZE)
        FloatIcon.BackgroundTransparency = 1
        FloatIcon.Image = IconAsset
        FloatIcon.ImageColor3 = Library.Accent
        FloatIcon.ScaleType = Enum.ScaleType.Fit

        local function setFloatState(state)
            local targetColor, targetIconSize
            if state == "hover" then
                targetColor = Color3.fromRGB(255, 110, 190)
                targetIconSize = FLOAT_ICON_SIZE + 4
            elseif state == "press" then
                targetColor = Color3.fromRGB(255, 50, 150)
                targetIconSize = FLOAT_ICON_SIZE - 4
            else
                targetColor = Library.Accent
                targetIconSize = FLOAT_ICON_SIZE
            end
            TweenService:Create(FloatIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                ImageColor3 = targetColor,
                Size = UDim2.new(0, targetIconSize, 0, targetIconSize)
            }):Play()
        end

        local isMinimized = false
        local function minimizeGUI()
            if isMinimized then return end
            isMinimized = true
            Main.Visible = false
            FloatBtn.Visible = true
            FloatIcon.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(FloatIcon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, FLOAT_ICON_SIZE, 0, FLOAT_ICON_SIZE)
            }):Play()
        end

        local function restoreGUI()
            if not isMinimized then return end
            isMinimized = false
            Main.Visible = true
            TweenService:Create(FloatIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.delay(0.15, function()
                if not isMinimized then FloatBtn.Visible = false end
            end)
        end

        local iconPressTime = 0
        IconBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                iconPressTime = os.clock()
                setIconState("press")
            end
        end)
        IconBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                setIconState("idle")
                if os.clock() - iconPressTime < 1.5 then
                    minimizeGUI()
                end
            end
        end)
        IconBtn.MouseEnter:Connect(function()
            if not isMinimized then setIconState("hover") end
        end)
        IconBtn.MouseLeave:Connect(function() setIconState("idle") end)

        local floatPressTime = 0
        local floatPressPos = Vector2.zero
        local function getInputPos(input)
            if input and input.UserInputType == Enum.UserInputType.Touch then
                return Vector2.new(input.Position.X, input.Position.Y)
            end
            return UserInputService:GetMouseLocation()
        end
        FloatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                floatPressTime = os.clock()
                floatPressPos = getInputPos(input)
                setFloatState("press")
            end
        end)
        FloatBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                setFloatState("idle")
                local moved = (getInputPos(input) - floatPressPos).Magnitude
                if os.clock() - floatPressTime < 1.5 and moved < 12 then
                    restoreGUI()
                end
            end
        end)
        FloatBtn.MouseEnter:Connect(function() setFloatState("hover") end)
        FloatBtn.MouseLeave:Connect(function() setFloatState("idle") end)

        Main.Name = "Main"
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.Size = UDim2.new(0, 580, 0, 442)
        Main.BackgroundColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Main.BorderColor3 = Color3.new(0, 0, 0)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Library.Holder = Main

        Inline.Name = "Inline"
        Inline.Position = UDim2.new(0, 2, 0, 2)
        Inline.Size = UDim2.new(1, -4, 1, -4)
        Inline.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Inline.BorderColor3 = Color3.new(0, 0, 0)

        Middle.Name = "Middle"
        Middle.Position = UDim2.new(0, -1, 0, 22)
        Middle.Size = UDim2.new(1, 2, 1, -44)
        Middle.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Middle.BorderColor3 = Color3.new(0, 0, 0)
        Middle.BorderMode = Enum.BorderMode.Inset

        Line.Name = "Line"
        Line.Position = UDim2.new(0, -1, 0, 0)
        Line.Size = UDim2.new(1, 2, 0, 1)
        Line.BackgroundColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Line.BorderSizePixel = 0
        Line.BorderColor3 = Color3.new(0, 0, 0)

        Line2.Name = "Line2"
        Line2.Position = UDim2.new(0, -1, 1, -1)
        Line2.Size = UDim2.new(1, 2, 0, 1)
        Line2.BackgroundColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Line2.BorderSizePixel = 0
        Line2.BorderColor3 = Color3.new(0, 0, 0)

        Gradient.Name = "Gradient"
        Gradient.Position = UDim2.new(0.5, 0, 0, 2)
        Gradient.Size = UDim2.new(0.5, 0, 0, 1)
        Gradient.BackgroundColor3 = Color3.new(1, 1, 1)
        Gradient.BorderSizePixel = 0
        Gradient.BorderColor3 = Color3.new(0, 0, 0)
        Library.Gradient = Gradient
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Library.Accent),
            ColorSequenceKeypoint.new(1, Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033))
        }
        UIGradient.Rotation = 180
        Library.UIGradient = UIGradient

        Top.Name = "Top"
        Top.Size = UDim2.new(1, 0, 0, 22)
        Top.BackgroundColor3 = Color3.new(1, 1, 1)
        Top.BackgroundTransparency = 1
        Top.BorderSizePixel = 0
        Top.BorderColor3 = Color3.new(0, 0, 0)
        Top.AutoButtonColor = false
        Top.Text = ""

        Title.Name = "Title"
        Title.Position = UDim2.new(0, ICON_BTN_SIZE + 8, 0, 0)
        Title.Size = UDim2.new(1, -4, 1, 0)
        Title.BackgroundColor3 = Color3.new(1, 1, 1)
        Title.BackgroundTransparency = 1
        Title.BorderSizePixel = 0
        Title.BorderColor3 = Color3.new(0, 0, 0)
        Title.Text = Base.Title
        Title.TextColor3 = Library.Accent
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.RichText = true

        Bottom.Name = "Bottom"
        Bottom.Position = UDim2.new(0, 0, 1, -22)
        Bottom.Size = UDim2.new(1, 0, 0, 22)
        Bottom.BackgroundColor3 = Color3.new(1, 1, 1)
        Bottom.BackgroundTransparency = 1
        Bottom.BorderSizePixel = 0
        Bottom.BorderColor3 = Color3.new(0, 0, 0)

        Sections.Name = "Sections"
        Sections.Position = UDim2.new(0, 10, 0, 13)
        Sections.Size = UDim2.new(0, 110, 1, -26)
        Sections.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Sections.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)

        Pages.Name = "Pages"
        Pages.Position = UDim2.new(0, 132, 0, 0)
        Pages.Size = UDim2.new(1, -132, 1, 0)
        Pages.BackgroundColor3 = Color3.new(1, 1, 1)
        Pages.BackgroundTransparency = 1
        Pages.BorderSizePixel = 0
        Pages.BorderColor3 = Color3.new(0, 0, 0)
        Pages.ZIndex = 52
        Library.PageHolder = Pages
        UIListLayout.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 6)

        version.Name = "version"
        version.Position = UDim2.new(0, 4, 0, 0)
        version.Size = UDim2.new(1, -4, 1, 0)
        version.BackgroundColor3 = Color3.new(1, 1, 1)
        version.BackgroundTransparency = 1
        version.BorderSizePixel = 0
        version.BorderColor3 = Color3.new(0, 0, 0)
        version.Text = "<font color=\"#4e4e4e\">version: </font> live"
        version.TextColor3 = Library.Accent
        version.FontFace = Library.UIFont
        version.TextSize = Library.FontSize
        version.TextXAlignment = Enum.TextXAlignment.Left
        version.RichText = true

        corner1.CornerRadius = UDim.new(0, 2)
        corner2.CornerRadius = UDim.new(0, 2)

        -- // Dragging (оригинал)
        Library:Connection(Top.MouseButton1Down, function()
            local Location = UserInputService:GetMouseLocation()
            Base.Dragging[1] = true
            Base.Dragging[2] = UDim2.new(0, Location.X - Main.AbsolutePosition.X, 0, Location.Y - Main.AbsolutePosition.Y)
        end)
        Library:Connection(Top.MouseButton1Up, function()
            Base.Dragging[1] = false
            Base.Dragging[2] = UDim2.new(0, 0, 0, 0)
        end)
        Library:Connection(UserInputService.InputChanged, function(Input)
            local Location = UserInputService:GetMouseLocation()
            if Base.Dragging[1] then
                Main.Position = UDim2.new(
                    0, Location.X - Base.Dragging[2].X.Offset + (Main.Size.X.Offset * Main.AnchorPoint.X),
                    0, Location.Y - Base.Dragging[2].Y.Offset + (Main.Size.Y.Offset * Main.AnchorPoint.Y)
                )
            end
        end)

        Base.Elements = {
            Main = Main, Title = Title, Middle = Middle,
            PageHolder = Pages, SectionHolder = Sections,
            IconBtn = IconBtn, IconImg = IconImg,
            FloatBtn = FloatBtn, FloatIcon = FloatIcon
        }
        Base.Minimize = minimizeGUI
        Base.Restore = restoreGUI
        return setmetatable(Base, Library);
    end

    function Library:Page(Options)
        local Page = {
            Window = self;
            Open = false;
            Sections = {};
            Elements = {};
            Title = Options.Name or Options.Name or Options.Name or "legit"
        };

        local Holder = Instance.new('TextButton', Page.Window.Elements.PageHolder)
        local Button = Instance.new('Frame', Holder)
        local TopLine = Instance.new('Frame', Button)
        local Line = Instance.new('Frame', Button)
        local Left = Instance.new('Frame', Button)
        local RIght = Instance.new('Frame', Button)
        local Black = Instance.new('Frame', Button)
        local Black2 = Instance.new('Frame', Button)
        local Title = Instance.new('TextLabel', Holder)
        local PageSections = Instance.new('Frame', Page.Window.Elements.SectionHolder)
        local UIListLayout = Instance.new('UIListLayout', PageSections)
        local SectionHolder = Instance.new('Frame', Page.Window.Elements.Middle)

        do
            table.insert(Library.Instances, Button)
            table.insert(Library.Instances, TopLine)
            table.insert(Library.Instances, Line)
            table.insert(Library.Instances, Title)
            table.insert(Library.Instances, Left)
            table.insert(Library.Instances, RIght)
            table.insert(Library.Instances, Black)
            table.insert(Library.Instances, Black2)
            table.insert(Library.ThemeObjects, TopLine)
            table.insert(Library.ThemeObjects, Left)
            table.insert(Library.ThemeObjects, RIght)
        end

        Holder.Name = "Page"
        Holder.Size = UDim2.new(0, 50, 1, 0)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1
        Holder.BorderSizePixel = 0
        Holder.BorderColor3 = Color3.new(0, 0, 0)
        Holder.Text = ""
        Holder.TextColor3 = Color3.new(0, 0, 0)
        Holder.AutoButtonColor = false
        Holder.Font = Enum.Font.SourceSans
        Holder.TextSize = 14
        Holder.ZIndex = 53

        Button.Name = "Button"
        Button.Position = UDim2.new(0, 0, 0, 3)
        Button.Size = UDim2.new(1, 0, 1, -2)
        Button.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Button.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)
        Button.ZIndex = 53
        Button.Visible = false

        TopLine.Name = "TopLine"
        TopLine.Position = UDim2.new(0, 3, 0, 0)
        TopLine.Size = UDim2.new(1, -5, 0, 1)
        TopLine.BackgroundColor3 = Library.Accent
        TopLine.BorderSizePixel = 0
        TopLine.BorderColor3 = Color3.new(0, 0, 0)
        TopLine.ZIndex = 53

        Line.Name = "Line"
        Line.Position = UDim2.new(0, 0, 1, 0)
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Line.BorderSizePixel = 0
        Line.BorderColor3 = Color3.new(0, 0, 0)
        Line.ZIndex = 53

        Left.Name = "Left"
        Left.Position = UDim2.new(0, -1, 0, 2)
        Left.Size = UDim2.new(0, 5, 0, 1)
        Left.BackgroundColor3 = Library.Accent
        Left.BorderSizePixel = 0
        Left.BorderColor3 = Color3.new(0, 0, 0)
        Left.Rotation = -45
        Left.ZIndex = 53

        RIght.Name = "RIght"
        RIght.Position = UDim2.new(1, -4, 0, 2)
        RIght.Size = UDim2.new(0, 5, 0, 1)
        RIght.BackgroundColor3 = Library.Accent
        RIght.BorderSizePixel = 0
        RIght.BorderColor3 = Color3.new(0, 0, 0)
        RIght.Rotation = 45
        RIght.ZIndex = 53

        Black.Name = "Black"
        Black.Position = UDim2.new(0, -5, 0, -2)
        Black.Size = UDim2.new(0, 7, 0, 6)
        Black.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Black.BorderSizePixel = 0
        Black.BorderColor3 = Color3.new(0, 0, 0)
        Black.Rotation = -45
        Black.ZIndex = 55

        Black2.Name = "Black2"
        Black2.Position = UDim2.new(1, -2, 0, -2)
        Black2.Size = UDim2.new(0, 7, 0, 6)
        Black2.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Black2.BorderSizePixel = 0
        Black2.BorderColor3 = Color3.new(0, 0, 0)
        Black2.Rotation = 45
        Black2.ZIndex = 55

        Title.Name = "Title"
        Title.Position = UDim2.new(0, 0, 0, 2)
        Title.Size = UDim2.new(1, 0, 1, -2)
        Title.BackgroundColor3 = Color3.new(1, 1, 1)
        Title.BackgroundTransparency = 1
        Title.BorderSizePixel = 0
        Title.BorderColor3 = Color3.new(0, 0, 0)
        Title.Text = Page.Title
        Title.TextColor3 = Color3.fromRGB(78, 78, 78)
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.ZIndex = 53
        Title.RichText = true

        PageSections.Name = "PageSections"
        PageSections.Position = UDim2.new(0, 8, 0, 10)
        PageSections.Size = UDim2.new(1, -16, 1, -20)
        PageSections.BackgroundColor3 = Color3.new(1, 1, 1)
        PageSections.BackgroundTransparency = 1
        PageSections.BorderSizePixel = 0
        PageSections.BorderColor3 = Color3.new(0, 0, 0)
        PageSections.Visible = false
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 3)

        SectionHolder.Name = "SectionHolder"
        SectionHolder.Position = UDim2.new(0, 133, 0, 13)
        SectionHolder.Size = UDim2.new(1, -144, 1, -26)
        SectionHolder.BackgroundColor3 = Color3.new(1, 1, 1)
        SectionHolder.BackgroundTransparency = 1
        SectionHolder.BorderSizePixel = 0
        SectionHolder.BorderColor3 = Color3.new(0, 0, 0)
        SectionHolder.ZIndex = 53
        SectionHolder.Visible = false

        function Page:Turn(bool)
            Page.Open = bool
            PageSections.Visible = Page.Open
            Button.Visible = Page.Open
            if Page.Open then
                table.insert(Library.ThemeObjects, Title)
                Title.TextColor3 = Library.Accent
            else
                local idx = table.find(Library.ThemeObjects, Title)
                if idx then table.remove(Library.ThemeObjects, idx) end
                Title.TextColor3 = Color3.fromRGB(78, 78, 78)
            end
            SectionHolder.Visible = Page.Open
        end;

        Holder.MouseButton1Click:Connect(function()
            if not Page.Open then
                Page:Turn(true)
                for index, other_page in pairs(Page.Window.Pages) do
                    if other_page.Open and other_page ~= Page then
                        other_page:Turn(false)
                    end
                end
            end
        end)

        if #Page.Window.Pages == 0 then Page:Turn(true); end;

        task.defer(function()
            Holder.Size = UDim2.new(0, Title.TextBounds.X + 16, 1, 0)
        end)

        Page.Elements = { ButtonHolder = PageSections, RealHold = SectionHolder }
        Page.Window.Pages[#Page.Window.Pages + 1] = Page;
        return setmetatable(Page, Library.Pages);
    end

    function Pages:Section(Options)
        local Section = {
            Window = self.Window,
            Page = self,
            Open = false,
            Elements = {},
            Title = Options.Name or Options.Name or Options.Name or "aimbot",
            LeftName = Options.LeftTitle or Options.lefttitle or "general",
            RightName = Options.RightTitle or Options.righttitle or "general",
        };

        local Button = Instance.new('TextButton', Section.Page.Elements.ButtonHolder)
        local Accent = Instance.new('Frame', Button)
        local Frame = Instance.new('Frame', Button)
        local UIGradient = Instance.new('UIGradient', Frame)
        local Title = Instance.new('TextLabel', Frame)
        local NewSection = Instance.new('Frame', Section.Page.Elements.RealHold)
        local Left = Instance.new('Frame', NewSection)
        local Bar = Instance.new('Frame', Left)
        local Gradient = Instance.new('UIGradient', Bar)
        local GradientLine = Instance.new('Frame', Bar)
        local UIGradient3 = Instance.new('UIGradient', GradientLine)
        local LeftTitle = Instance.new('TextLabel', Bar)
        local Right = Instance.new('Frame', NewSection)
        local Bar2 = Instance.new('Frame', Right)
        local Gradient2 = Instance.new('UIGradient', Bar2)
        local GradientLine2 = Instance.new('Frame', Bar2)
        local UIGradient2 = Instance.new('UIGradient', GradientLine2)
        local RightTitle = Instance.new('TextLabel', Bar2)
        local LeftContent = Instance.new('Frame', Left)
        local LeftUIListLayout = Instance.new('UIListLayout', LeftContent)
        local RightConnect = Instance.new('Frame', Right)
        local RightUIListLayout = Instance.new('UIListLayout', RightConnect)

        do
            table.insert(Library.Instances, Accent)
            table.insert(Library.Instances, Frame)
            table.insert(Library.Instances, Title)
            table.insert(Library.Instances, Left)
            table.insert(Library.Instances, Bar)
            table.insert(Library.Instances, GradientLine)
            table.insert(Library.Instances, LeftTitle)
            table.insert(Library.Instances, Right)
            table.insert(Library.Instances, Bar2)
            table.insert(Library.Instances, GradientLine2)
            table.insert(Library.Instances, RightTitle)
            table.insert(Library.ThemeObjects, Accent)
        end

        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 0, 22)
        Button.BackgroundColor3 = Color3.new(1, 1, 1)
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.ZIndex = 54
        Button.AutoButtonColor = false
        Button.Text = ""

        Accent.Name = "Accent"
        Accent.Size = UDim2.new(0, 1, 1, 0)
        Accent.BackgroundColor3 = Library.Accent
        Accent.BorderSizePixel = 0
        Accent.ZIndex = 54
        Accent.BackgroundTransparency = 0.5

        Frame.Position = UDim2.new(0, 1, 0, 0)
        Frame.Size = UDim2.new(1, -2, 1, 0)
        Frame.BackgroundColor3 = Color3.new(0.149, 0.149, 0.149)
        Frame.BorderSizePixel = 0
        Frame.ZIndex = 54

        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7411764860153198, 0.7411764860153198, 0.7411764860153198)),
            ColorSequenceKeypoint.new(1, Color3.new(0.20392157137393951, 0.20392157137393951, 0.20392157137393951))
        }
        UIGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.5, 0),
            NumberSequenceKeypoint.new(1, 0.5, 0)
        }
        UIGradient.Enabled = true

        Title.Name = "Title"
        Title.Position = UDim2.new(0, 4, 0, 0)
        Title.Size = UDim2.new(1, -4, 0, 20)
        Title.BackgroundColor3 = Color3.new(0.298, 0.6353, 0.9882)
        Title.BackgroundTransparency = 1
        Title.Text = Options.Name
        Title.TextColor3 = Color3.fromRGB(78, 78, 78)
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.ZIndex = 54
        Title.TextXAlignment = Enum.TextXAlignment.Left

        NewSection.Name = "NewSection"
        NewSection.Size = UDim2.new(1, 0, 1, 0)
        NewSection.BackgroundColor3 = Color3.new(1, 1, 1)
        NewSection.BackgroundTransparency = 1
        NewSection.BorderSizePixel = 0
        NewSection.BorderColor3 = Color3.new(0, 0, 0)
        NewSection.Visible = false

        Left.Name = "Left"
        Left.Position = UDim2.new(0, 2, 0, 0)
        Left.Size = UDim2.new(0.5, -10, 1, 0)
        Left.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Left.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)

        Bar.Name = "Bar"
        Bar.Size = UDim2.new(1, 0, 0, 20)
        Bar.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Bar.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        GradientLine.Name = "GradientLine"
        GradientLine.Position = UDim2.new(0, 0, 1, 0)
        GradientLine.Size = UDim2.new(1, 0, 0, 1)
        GradientLine.BackgroundColor3 = Color3.new(1, 1, 1)
        GradientLine.BorderSizePixel = 0
        GradientLine.BorderColor3 = Color3.new(0, 0, 0)
        UIGradient3.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.10980392247438431, 0.10980392247438431, 0.10980392247438431)),
            ColorSequenceKeypoint.new(0.4826989769935608, Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033)),
            ColorSequenceKeypoint.new(1, Color3.new(0.10980392247438431, 0.10980392247438431, 0.10980392247438431))
        }

        LeftTitle.Name = "LeftTitle"
        LeftTitle.Position = UDim2.new(0, 4, 0, 0)
        LeftTitle.Size = UDim2.new(1, -4, 1, 0)
        LeftTitle.BackgroundColor3 = Color3.new(1, 1, 1)
        LeftTitle.BackgroundTransparency = 1
        LeftTitle.BorderSizePixel = 0
        LeftTitle.BorderColor3 = Color3.new(0, 0, 0)
        LeftTitle.Text = Section.LeftName
        LeftTitle.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        LeftTitle.FontFace = Library.UIFont
        LeftTitle.TextSize = Library.FontSize
        LeftTitle.TextXAlignment = Enum.TextXAlignment.Left

        Right.Name = "Right"
        Right.Position = UDim2.new(0.5, 8, 0, 0)
        Right.Size = UDim2.new(0.5, -10, 1, 0)
        Right.BackgroundColor3 = Color3.new(0.0314, 0.0314, 0.0314)
        Right.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)

        Bar2.Name = "Bar2"
        Bar2.Size = UDim2.new(1, 0, 0, 20)
        Bar2.BackgroundColor3 = Color3.new(0.0431, 0.0431, 0.0431)
        Bar2.BorderColor3 = Color3.new(0.1098, 0.1098, 0.1098)

        Gradient2.Name = "Gradient2"
        Gradient2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient2.Rotation = -90

        GradientLine2.Name = "GradientLine2"
        GradientLine2.Position = UDim2.new(0, 0, 1, 0)
        GradientLine2.Size = UDim2.new(1, 0, 0, 1)
        GradientLine2.BackgroundColor3 = Color3.new(1, 1, 1)
        GradientLine2.BorderSizePixel = 0
        GradientLine2.BorderColor3 = Color3.new(0, 0, 0)
        UIGradient2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.10980392247438431, 0.10980392247438431, 0.10980392247438431)),
            ColorSequenceKeypoint.new(0.4826989769935608, Color3.new(0.04313725605607033, 0.04313725605607033, 0.04313725605607033)),
            ColorSequenceKeypoint.new(1, Color3.new(0.10980392247438431, 0.10980392247438431, 0.10980392247438431))
        }

        RightTitle.Name = "RightTitle"
        RightTitle.Position = UDim2.new(0, 4, 0, 0)
        RightTitle.Size = UDim2.new(1, -4, 1, 0)
        RightTitle.BackgroundColor3 = Color3.new(1, 1, 1)
        RightTitle.BackgroundTransparency = 1
        RightTitle.BorderSizePixel = 0
        RightTitle.BorderColor3 = Color3.new(0, 0, 0)
        RightTitle.Text = Section.RightName
        RightTitle.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        RightTitle.FontFace = Library.UIFont
        RightTitle.TextSize = Library.FontSize
        RightTitle.TextXAlignment = Enum.TextXAlignment.Left

        LeftContent.Name = "LeftContent"
        LeftContent.Position = UDim2.new(0, 10, 0, 30)
        LeftContent.Size = UDim2.new(1, -20, 1, -40)
        LeftContent.BackgroundColor3 = Color3.new(1, 1, 1)
        LeftContent.BackgroundTransparency = 1
        LeftContent.BorderSizePixel = 0
        LeftContent.BorderColor3 = Color3.new(0, 0, 0)
        LeftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftUIListLayout.Padding = UDim.new(0, 4)

        RightConnect.Name = "RightConnect"
        RightConnect.Position = UDim2.new(0, 10, 0, 30)
        RightConnect.Size = UDim2.new(1, -20, 1, -40)
        RightConnect.BackgroundColor3 = Color3.new(1, 1, 1)
        RightConnect.BackgroundTransparency = 1
        RightConnect.BorderSizePixel = 0
        RightConnect.BorderColor3 = Color3.new(0, 0, 0)
        RightUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightUIListLayout.Padding = UDim.new(0, 4)

        function Section:Turn(bool)
            Section.Open = bool
            NewSection.Visible = Section.Open
            if Section.Open then
                table.insert(Library.ThemeObjects, Title)
                Title.TextColor3 = Library.Accent
            else
                local idx = table.find(Library.ThemeObjects, Title)
                if idx then table.remove(Library.ThemeObjects, idx) end
                Title.TextColor3 = Color3.fromRGB(78, 78, 78)
            end
            Accent.BackgroundTransparency = Section.Open and 0 or 0.5
        end;

        Button.MouseButton1Click:Connect(function()
            if not Section.Open then
                Section:Turn(true)
                for index, other_sec in pairs(Section.Page.Sections) do
                    if other_sec.Open and other_sec ~= Section then
                        other_sec:Turn(false)
                    end
                end
            end
        end)

        if #Section.Page.Sections == 0 then Section:Turn(true); end;

        Section.Elements = { Left = LeftContent, Right = RightConnect };
        Section.Page.Sections[#Section.Page.Sections + 1] = Section;
        return setmetatable(Section, Library.Sections)
    end

    function Sections:Toggle(Options)
        local Properties = Options or {}
        local Toggle = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            State = (Properties.state or Properties.State or false),
            Callback = (Properties.callback or function() end),
            Flag = (Properties.flag or Library.NextFlag()),
            Toggled = false,
            Colorpickers = 0,
        };

        local Holder = Instance.new('TextButton', Options.Side == "Left" and Toggle.Section.Elements.Left or Toggle.Section.Elements.Right)
        local Frame = Instance.new('Frame', Holder)
        local Accent = Instance.new('Frame', Frame)
        local Gradient = Instance.new('UIGradient', Accent)
        local TextLabel = Instance.new('TextLabel', Holder)

        do
            table.insert(Library.Instances, Frame)
            table.insert(Library.Instances, Accent)
            table.insert(Library.Instances, TextLabel)
            table.insert(Library.ThemeObjects, Accent)
        end

        Holder.Name = "Toggle"
        Holder.Size = UDim2.new(1, 0, 0, 10)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1
        Holder.Text = ""
        Holder.TextColor3 = Color3.new(0, 0, 0)
        Holder.AutoButtonColor = false
        Holder.Font = Enum.Font.SourceSans
        Holder.TextSize = 14

        Frame.Position = UDim2.new(0, 0, 0, 3)
        Frame.Size = UDim2.new(0, 6, 0, 6)
        Frame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Frame.BorderColor3 = Color3.new(0, 0, 0)

        Accent.Name = "Accent"
        Accent.Size = UDim2.new(1, 0, 1, 0)
        Accent.BackgroundColor3 = Library.Accent
        Accent.BorderSizePixel = 0
        Accent.Visible = false

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        TextLabel.Position = UDim2.new(0, 15, 0, 0)
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        TextLabel.FontFace = Library.UIFont
        TextLabel.TextSize = Library.FontSize
        TextLabel.ZIndex = 105
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Text = Options.Name or "toggle"

        local function SetState()
            Toggle.Toggled = not Toggle.Toggled
            if Toggle.Toggled then
                Accent.Visible = true
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Accent.Visible = false
                TextLabel.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
            end
            Library.Flags[Toggle.Flag] = Toggle.Toggled
            Toggle.Callback(Toggle.Toggled)
        end

        function Toggle:Keybind(Options)
            local Properties = Options or {};
            local Keybind = {
                State = Properties.state or nil,
                Mode = Properties.mode or "Toggle",
                Callback = Properties.callback or function() end,
                Flag = Properties.flag or Library.NextFlag(),
                Binding = nil,
                Connection = nil,
                Name = Options.Name or Properties.Name or Options.Name,
            }
            local Key
            local State = false
            local Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3

            local KeyHolder = Instance.new('TextButton', Holder)
            local Value = Instance.new('TextLabel', Holder)
            local Mode = Instance.new('TextLabel', Holder)

            do
                table.insert(Library.Instances, Value)
                table.insert(Library.Instances, Mode)
            end

            KeyHolder.Name = "Holder"
            KeyHolder.Size = UDim2.new(0, 40, 0, 10)
            KeyHolder.BackgroundColor3 = Color3.new(1, 1, 1)
            KeyHolder.BackgroundTransparency = 1
            KeyHolder.Text = ""
            KeyHolder.TextColor3 = Color3.new(0, 0, 0)
            KeyHolder.AutoButtonColor = false
            KeyHolder.Font = Enum.Font.SourceSans
            KeyHolder.TextSize = 14
            KeyHolder.Position = UDim2.new(1, -45, 0, 0)

            Value.Name = "Value"
            Value.Position = UDim2.new(0, 15, 0, 0)
            Value.Size = UDim2.new(1, -30, 1, 0)
            Value.BackgroundColor3 = Color3.new(1, 1, 1)
            Value.BackgroundTransparency = 1
            Value.Text = "[-]"
            Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
            Value.FontFace = Library.UIFont
            Value.TextSize = Library.FontSize
            Value.ZIndex = 105
            Value.TextXAlignment = Enum.TextXAlignment.Right

            Mode.Name = "Mode"
            Mode.Position = UDim2.new(0, TextLabel.TextBounds.X + 20, 0, 0)
            Mode.Size = UDim2.new(1, -30, 1, 0)
            Mode.BackgroundColor3 = Color3.new(1, 1, 1)
            Mode.BackgroundTransparency = 1
            Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
            Mode.TextColor3 = Color3.new(1, 1, 1)
            Mode.FontFace = Library.UIFont
            Mode.TextSize = Library.FontSize
            Mode.ZIndex = 105
            Mode.TextXAlignment = Enum.TextXAlignment.Left

            -- // Автоматически добавляем в KeybindList
            local kbItem = Library.Keybinds:Add(
                Keybind.Name or Options.Name or "keybind",
                Keybind.State,
                Keybind.Mode,
                false,
                Keybind.Callback
            )

            local function set(newkey)
                if string.find(tostring(newkey), "Enum") then
                    if Keybind.Connection then
                        Keybind.Connection:Disconnect()
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                        Keybind.Callback(false)
                    end
                    if tostring(newkey):find("Enum.KeyCode.") then
                        newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                    elseif tostring(newkey):find("Enum.UserInputType.") then
                        newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
                    end
                    if newkey == Enum.KeyCode.Backspace then
                        Key = nil
                        Value.Text = "[-]"
                        kbItem:SetKey(nil)
                    elseif newkey ~= nil then
                        Key = newkey
                        local text = (Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))
                        Value.Text = "[" .. text .. "]"
                        kbItem:SetKey(newkey)
                    end
                    Library.Flags[Keybind.Flag .. "_KEY"] = newkey
                elseif table.find({ "Always", "Toggle", "Hold" }, newkey) then
                    Library.Flags[Keybind.Flag .. "_KEY STATE"] = newkey
                    Keybind.Mode = newkey
                    Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
                    kbItem:SetMode(newkey)
                    Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3
                    if Keybind.Mode == "Always" then
                        State = true
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                        Keybind.Callback(true)
                        kbItem:SetState(true)
                    end
                else
                    State = newkey
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = newkey end
                    Keybind.Callback(newkey)
                    kbItem:SetState(newkey)
                end
            end

            set(Keybind.State)
            set(Keybind.Mode)

            KeyHolder.MouseButton1Click:Connect(function()
                if not Keybind.Binding then
                    Value.Text = "[-]"
                    Keybind.Binding = Library:Connection(
                        UserInputService.InputBegan,
                        function(input, gpe)
                            set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                            Library:Disconnect(Keybind.Binding)
                            task.wait()
                            Keybind.Binding = nil
                        end
                    )
                end
            end)

            Library:Connection(UserInputService.InputBegan, function(inp)
                if (inp.KeyCode == Key or inp.UserInputType == Key) and not Keybind.Binding then
                    if Keybind.Mode == "Hold" then
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = true end
                        Keybind.Connection = Library:Connection(RunService.RenderStepped, function()
                            if Keybind.Callback then Keybind.Callback(true) end
                        end)
                    elseif Keybind.Mode == "Toggle" then
                        State = not State
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                        Keybind.Callback(State)
                    end
                end
            end)

            Library:Connection(UserInputService.InputEnded, function(inp)
                if Keybind.Mode == "Hold" then
                    if Key ~= "" or Key ~= nil then
                        if inp.KeyCode == Key or inp.UserInputType == Key then
                            if Keybind.Connection then
                                Keybind.Connection:Disconnect()
                                if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                                if Keybind.Callback then Keybind.Callback(false) end
                            end
                        end
                    end
                end
            end)

            Holder.MouseButton2Click:Connect(function()
                Cycle += 1
                if Cycle > 3 then
                    Cycle = 1
                    set("Hold")
                    Mode.Text = "[H]"
                elseif Cycle == 2 then
                    set("Toggle")
                    Mode.Text = "[T]"
                elseif Cycle == 3 then
                    set("Always")
                    Mode.Text = "[A]"
                elseif Cycle == 1 then
                    set("Hold")
                    Mode.Text = "[H]"
                end
            end)

            Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
            Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
            Flags[Keybind.Flag] = set
            Flags[Keybind.Flag .. "_KEY"] = set
            Flags[Keybind.Flag .. "_KEY STATE"] = set

            function Keybind:Set(key) set(key) end
            task.defer(function()
                Mode.Position = UDim2.new(0, TextLabel.TextBounds.X + 20, 0, 0)
            end)
            return Keybind
        end

        function Toggle:Colorpicker(Properties)
            local Properties = Properties or {}
            local Colorpicker = {
                State = Properties.state or Color3.fromRGB(255, 0, 0),
                Alpha = Properties.alpha or 1,
                Callback = Properties.callback or function() end,
                Flag = Properties.flag or Library.NextFlag(),
            }
            Toggle.Colorpickers = Toggle.Colorpickers + 1
            local colorpickertypes = Library:NewPicker(
                Colorpicker.State,
                Colorpicker.Alpha,
                Holder,
                Toggle.Colorpickers - 1,
                Colorpicker.Flag,
                Colorpicker.Callback
            )
            function Colorpicker:Set(color)
                colorpickertypes:set(color, false, true)
            end
            return Colorpicker
        end

        function Toggle.Set(bool)
            bool = type(bool) == "boolean" and bool or false
            if Toggle.Toggled ~= bool then SetState() end
        end
        Toggle.Set(Toggle.State)
        Library.Flags[Toggle.Flag] = Toggle.State
        Flags[Toggle.Flag] = Toggle.Set

        Library:Connection(Holder.MouseButton1Click, SetState)
        return Toggle
    end

    function Sections:Slider(Options)
        local Properties = Options or {};
        local Slider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Properties.Title or Properties.Name or nil,
            Min = Properties.min or 0,
            State = Properties.state or 10,
            Max = Properties.max or 100,
            Sub = Properties.suffix or "",
            Decimals = Properties.decimals or 1,
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
        }
        local TextValue = ("[value]" .. Slider.Sub)

        local Holder = Instance.new('Frame', Options.Side == "Left" and Slider.Section.Elements.Left or Slider.Section.Elements.Right)
        local Frame = Instance.new('TextButton', Holder)
        local Accent = Instance.new('TextButton', Frame)
        local Gradient2 = Instance.new('UIGradient', Accent)
        local Gradient = Instance.new('UIGradient', Frame)
        local Title = Instance.new('TextLabel', Holder)
        local plus = Instance.new('TextButton', Holder)
        local minus = Instance.new('TextButton', Holder)
        local Value = Instance.new('TextLabel', Slider.Name and Holder or Frame)
        Title.Visible = false

        do
            table.insert(Library.Instances, Frame)
            table.insert(Library.Instances, Accent)
            table.insert(Library.Instances, Title)
            table.insert(Library.Instances, plus)
            table.insert(Library.Instances, minus)
            table.insert(Library.Instances, Value)
            table.insert(Library.ThemeObjects, Accent)
        end

        Holder.Name = "Slider"
        Holder.Size = Slider.Name and UDim2.new(1, 0, 0, 25) or UDim2.new(1, 0, 0, 10)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1

        Frame.Position = Slider.Name and UDim2.new(0, 15, 0, 16) or UDim2.new(0, 15, 0, 3)
        Frame.Size = UDim2.new(1, -30, 0, 6)
        Frame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Frame.BorderColor3 = Color3.new(0, 0, 0)
        Frame.AutoButtonColor = false
        Frame.Text = ""

        Accent.Name = "Accent"
        Accent.Size = UDim2.new(0, 0, 1, 0)
        Accent.BackgroundColor3 = Library.Accent
        Accent.BorderSizePixel = 0
        Accent.AutoButtonColor = false
        Accent.Text = ""

        Gradient2.Name = "Gradient2"
        Gradient2.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient2.Rotation = -90
        Gradient.Name = "Gradient"
        Gradient.Color = Gradient2.Color
        Gradient.Rotation = -90

        if Slider.Name then
            Title.Visible = true
            Title.Name = "Title"
            Title.Position = UDim2.new(0, 15, 0, 0)
            Title.Size = UDim2.new(1, 0, 0, 10)
            Title.BackgroundColor3 = Color3.new(1, 1, 1)
            Title.BackgroundTransparency = 1
            Title.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
            Title.FontFace = Library.UIFont
            Title.TextSize = Library.FontSize
            Title.ZIndex = 105
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Text = Slider.Name
        end

        plus.Name = "plus"
        plus.Position = Slider.Name and UDim2.new(1, -7, 0, 13) or UDim2.new(1, -7, 0, 0)
        plus.Size = UDim2.new(0, 8, 0, 8)
        plus.BackgroundColor3 = Color3.new(1, 1, 1)
        plus.BackgroundTransparency = 1
        plus.BorderSizePixel = 0
        plus.BorderColor3 = Color3.new(0, 0, 0)
        plus.Text = "+"
        plus.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        plus.FontFace = Library.UIFont
        plus.TextSize = Library.FontSize

        minus.Name = "minus"
        minus.Position = Slider.Name and UDim2.new(0, -1, 0, 13) or UDim2.new(0, -1, 0, 0)
        minus.Size = UDim2.new(0, 8, 0, 8)
        minus.BackgroundColor3 = Color3.new(1, 1, 1)
        minus.BackgroundTransparency = 1
        minus.BorderSizePixel = 0
        minus.BorderColor3 = Color3.new(0, 0, 0)
        minus.Text = "-"
        minus.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        minus.FontFace = Library.UIFont
        minus.TextSize = Library.FontSize

        Value.Name = "Value"
        Value.Position = Slider.Name and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, -1)
        Value.Size = Slider.Name and UDim2.new(1, -30, 0, 10) or UDim2.new(1, 0, 1, 0)
        Value.BackgroundColor3 = Color3.new(1, 1, 1)
        Value.BackgroundTransparency = 1
        Value.Text = "50%"
        Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Value.FontFace = Library.UIFont
        Value.TextSize = Library.FontSize
        Value.ZIndex = 105
        Value.TextXAlignment = Slider.Name and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center

        local Sliding = false
        local Val = Slider.State;
        local function Set(value)
            value = math.clamp(Library:Round(value, Slider.Decimals), Slider.Min, Slider.Max)
            if value == Slider.Min then
                Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                if Slider.Name then Title.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059) end
            else
                Value.TextColor3 = Color3.fromRGB(255, 255, 255)
                if Slider.Name then Title.TextColor3 = Color3.fromRGB(255, 255, 255) end
            end
            Value.Text = TextValue:gsub("%[value%]", string.format("%.14g", value))
            Val = value
            local sizeX = ((value - Slider.Min) / (Slider.Max - Slider.Min))
            Accent.Size = UDim2.new(sizeX, 0, 1, 0)
            Library.Flags[Slider.Flag] = value
            Slider.Callback(value)
        end
        Set(Slider.State)

        local function Slide(input)
            local sizeX = (input.Position.X - Frame.AbsolutePosition.X) / Frame.AbsoluteSize.X
            local value = ((Slider.Max - Slider.Min) * sizeX) + Slider.Min
            Set(value)
        end

        Library:Connection(Frame.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Sliding = true
                Slide(input)
            end
        end)
        Library:Connection(Frame.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Sliding = false
            end
        end)
        Library:Connection(Accent.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Sliding = true
                Slide(input)
            end
        end)
        Library:Connection(Accent.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Sliding = false
            end
        end)
        Library:Connection(UserInputService.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if Sliding then Slide(input) end
            end
        end)
        Library:Connection(plus.MouseButton1Click, function() Set(Val + 1) end)
        Library:Connection(minus.MouseButton1Click, function() Set(Val - 1) end)

        function Slider:Set(Value) Set(Value) end
        Flags[Slider.Flag] = Set
        return Slider
    end

    function Sections:List(Options)
        local Properties = Options or {};
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Open = false,
            Name = Properties.Title or Properties.Name or nil,
            Options = Properties.options or Properties.Options or { "1", "2", "3" },
            State = Properties.state or Properties.State or nil,
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
            OptionInsts = {},
        }

        local Holder = Instance.new('Frame', Options.Side == "Left" and Dropdown.Section.Elements.Left or Dropdown.Section.Elements.Right)
        local Frame = Instance.new('TextButton', Holder)
        local Gradient = Instance.new('UIGradient', Frame)
        local Value = Instance.new('TextLabel', Frame)
        local Icon = Instance.new('TextLabel', Frame)
        local Content = Instance.new('Frame', Frame)
        local Gradient2 = Instance.new('UIGradient', Content)
        local UIListLayout = Instance.new('UIListLayout', Content)
        local Title = Instance.new('TextLabel', Holder)

        do
            table.insert(Library.Instances, Frame)
            table.insert(Library.Instances, Value)
            table.insert(Library.Instances, Icon)
            table.insert(Library.Instances, Content)
            table.insert(Library.Instances, Title)
            table.insert(Dropdowns, Content)
        end

        Holder.Name = "Holder"
        Holder.Size = UDim2.new(1, 0, 0, 34)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1

        Frame.Position = UDim2.new(0, 15, 0, 16)
        Frame.Size = UDim2.new(1, -30, 0, 15)
        Frame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Frame.BorderColor3 = Color3.new(0, 0, 0)
        Frame.Text = ""
        Frame.AutoButtonColor = false

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        Value.Name = "Value"
        Value.Position = UDim2.new(0, 2, 0, 0)
        Value.Size = UDim2.new(1, -10, 1, 0)
        Value.BackgroundColor3 = Color3.new(1, 1, 1)
        Value.BackgroundTransparency = 1
        Value.Text = ""
        Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Value.FontFace = Library.UIFont
        Value.TextSize = Library.FontSize
        Value.ZIndex = 105
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ClipsDescendants = true

        Icon.Name = "Icon"
        Icon.Position = UDim2.new(0, -4, 0, 0)
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundColor3 = Color3.new(1, 1, 1)
        Icon.BackgroundTransparency = 1
        Icon.BorderSizePixel = 0
        Icon.Text = "-"
        Icon.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Icon.FontFace = Library.UIFont
        Icon.TextSize = Library.FontSize
        Icon.ZIndex = 105
        Icon.TextXAlignment = Enum.TextXAlignment.Right

        Content.Name = "Content"
        Content.Position = UDim2.new(0, 0, 0, 18)
        Content.Size = UDim2.new(1, 0, 0, 0)
        Content.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Content.BorderColor3 = Color3.new(0, 0, 0)
        Content.Visible = false
        Content.ZIndex = 110
        Content.AutomaticSize = Enum.AutomaticSize.Y

        Gradient2.Name = "Gradient2"
        Gradient2.Color = Gradient.Color
        Gradient2.Rotation = -90

        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        Title.Name = "Title"
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.Size = UDim2.new(1, 0, 0, 10)
        Title.BackgroundColor3 = Color3.new(1, 1, 1)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.ZIndex = 105
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Text = Dropdown.Name

        Library:Connection(Frame.MouseButton1Click, function()
            Content.Visible = not Content.Visible
        end)
        Library:Connection(UserInputService.InputBegan, function(Input)
            if Content.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Library:IsMouseOverFrame(Content) and not Library:IsMouseOverFrame(Holder) then
                    Content.Visible = false
                end
            end
        end)

        local Chosen = nil

        local function handleoptionclick(option, button, text)
            button.MouseButton1Click:Connect(function()
                for opt, tbl in next, Dropdown.OptionInsts do
                    if opt ~= option then tbl.text.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059) end
                end
                Chosen = option
                Value.Text = option
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                Library.Flags[Dropdown.Flag] = option
                Dropdown.Callback(option)
            end)
        end

        local function createoptions(tbl)
            for _, option in next, tbl do
                Dropdown.OptionInsts[option] = {}
                local Option = Instance.new('TextButton', Content)
                local OptionName = Instance.new('TextLabel', Option)
                Option.Name = "Option"
                Option.Size = UDim2.new(1, 0, 0, 15)
                Option.BackgroundColor3 = Color3.new(1, 1, 1)
                Option.BackgroundTransparency = 1
                Option.BorderSizePixel = 0
                Option.BorderColor3 = Color3.new(0, 0, 0)
                Option.Text = ""
                Option.TextColor3 = Color3.new(0, 0, 0)
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.SourceSans
                Option.TextSize = 14
                Dropdown.OptionInsts[option].button = Option
                Option.ZIndex = 111
                OptionName.Name = "OptionName"
                OptionName.Position = UDim2.new(0, 2, 0, 0)
                OptionName.Size = UDim2.new(1, 0, 1, 0)
                OptionName.BackgroundColor3 = Color3.new(1, 1, 1)
                OptionName.BackgroundTransparency = 1
                OptionName.BorderSizePixel = 0
                OptionName.BorderColor3 = Color3.new(0, 0, 0)
                OptionName.Text = option
                OptionName.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                OptionName.FontFace = Library.UIFont
                OptionName.TextSize = Library.FontSize
                OptionName.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.OptionInsts[option].text = OptionName
                OptionName.ZIndex = 111
                handleoptionclick(option, Option, OptionName)
            end
        end
        createoptions(Dropdown.Options)

        function Dropdown:Set(option)
            for opt, tbl in next, Dropdown.OptionInsts do
                if opt ~= option then tbl.text.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059) end
            end
            if table.find(Dropdown.Options, option) then
                Chosen = option
                Value.Text = option
                Dropdown.OptionInsts[option].text.TextColor3 = Color3.fromRGB(255, 255, 255)
                Library.Flags[Dropdown.Flag] = Chosen
                Dropdown.Callback(Chosen)
            else
                Chosen = nil
                Value.Text = ""
                Library.Flags[Dropdown.Flag] = Chosen
                Dropdown.Callback(Chosen)
            end
        end

        function Dropdown:Refresh(tbl)
            for _, opt in next, Dropdown.OptionInsts do
                coroutine.wrap(function() opt.button:Destroy() end)()
            end
            table.clear(Dropdown.OptionInsts)
            createoptions(tbl)
            Chosen = nil
            Library.Flags[Dropdown.Flag] = Chosen
            Dropdown.Callback(Chosen)
        end

        Flags[Dropdown.Flag] = Dropdown
        Dropdown:Set(Dropdown.State)
        return Dropdown
    end

    function Sections:Multibox(Options)
        local Properties = Options or {};
        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Open = false,
            Name = Properties.Title or Properties.Name or nil,
            Options = Properties.options or Properties.Options or { "1", "2", "3" },
            State = Properties.state or Properties.State or nil,
            Max = Properties.max or 1,
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
            OptionInsts = {},
        }

        local Holder = Instance.new('Frame', Options.Side == "Left" and Dropdown.Section.Elements.Left or Dropdown.Section.Elements.Right)
        local Frame = Instance.new('TextButton', Holder)
        local Gradient = Instance.new('UIGradient', Frame)
        local Value = Instance.new('TextLabel', Frame)
        local Icon = Instance.new('TextLabel', Frame)
        local Content = Instance.new('Frame', Frame)
        local Gradient2 = Instance.new('UIGradient', Content)
        local UIListLayout = Instance.new('UIListLayout', Content)
        local Title = Instance.new('TextLabel', Holder)

        do
            table.insert(Library.Instances, Frame)
            table.insert(Library.Instances, Value)
            table.insert(Library.Instances, Icon)
            table.insert(Library.Instances, Content)
            table.insert(Library.Instances, Title)
            table.insert(Dropdowns, Content)
        end

        Holder.Name = "Holder"
        Holder.Size = UDim2.new(1, 0, 0, 34)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1

        Frame.Position = UDim2.new(0, 15, 0, 16)
        Frame.Size = UDim2.new(1, -30, 0, 15)
        Frame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Frame.BorderColor3 = Color3.new(0, 0, 0)
        Frame.Text = ""
        Frame.AutoButtonColor = false

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        Value.Name = "Value"
        Value.Position = UDim2.new(0, 2, 0, 0)
        Value.Size = UDim2.new(1, -10, 1, 0)
        Value.BackgroundColor3 = Color3.new(1, 1, 1)
        Value.BackgroundTransparency = 1
        Value.Text = ""
        Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Value.FontFace = Library.UIFont
        Value.TextTruncate = Enum.TextTruncate.SplitWord
        Value.TextSize = Library.FontSize
        Value.ZIndex = 105
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.ClipsDescendants = true

        Icon.Name = "Icon"
        Icon.Position = UDim2.new(0, -4, 0, 0)
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundColor3 = Color3.new(1, 1, 1)
        Icon.BackgroundTransparency = 1
        Icon.BorderSizePixel = 0
        Icon.Text = "-"
        Icon.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Icon.FontFace = Library.UIFont
        Icon.TextSize = Library.FontSize
        Icon.ZIndex = 105
        Icon.TextXAlignment = Enum.TextXAlignment.Right

        Content.Name = "Content"
        Content.Position = UDim2.new(0, 0, 0, 18)
        Content.Size = UDim2.new(1, 0, 0, 0)
        Content.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        Content.BorderColor3 = Color3.new(0, 0, 0)
        Content.Visible = false
        Content.ZIndex = 110
        Content.AutomaticSize = Enum.AutomaticSize.Y

        Gradient2.Name = "Gradient2"
        Gradient2.Color = Gradient.Color
        Gradient2.Rotation = -90
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

        Title.Name = "Title"
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.Size = UDim2.new(1, 0, 0, 10)
        Title.BackgroundColor3 = Color3.new(1, 1, 1)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.ZIndex = 105
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Text = Dropdown.Name

        Library:Connection(Frame.MouseButton1Click, function()
            Content.Visible = not Content.Visible
        end)
        Library:Connection(UserInputService.InputBegan, function(Input)
            if Content.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Library:IsMouseOverFrame(Content) and not Library:IsMouseOverFrame(Holder) then
                    Content.Visible = false
                end
            end
        end)

        local chosen = {}

        local function handleoptionclick(option, button, text)
            button.MouseButton1Click:Connect(function()
                if table.find(chosen, option) then
                    table.remove(chosen, table.find(chosen, option))
                    text.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                else
                    if #chosen == Dropdown.Max then
                        Dropdown.OptionInsts[chosen[1]].text.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                        table.remove(chosen, 1)
                    end
                    table.insert(chosen, option)
                    text.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                Value.Text = #chosen == 0 and "" or table.concat(chosen, ", ")
                Library.Flags[Dropdown.Flag] = chosen
                Dropdown.Callback(chosen)
            end)
        end

        local function createoptions(tbl)
            for _, option in next, tbl do
                Dropdown.OptionInsts[option] = {}
                local Option = Instance.new('TextButton', Content)
                local OptionName = Instance.new('TextLabel', Option)
                Option.Name = "Option"
                Option.Size = UDim2.new(1, 0, 0, 15)
                Option.BackgroundColor3 = Color3.new(1, 1, 1)
                Option.BackgroundTransparency = 1
                Option.BorderSizePixel = 0
                Option.BorderColor3 = Color3.new(0, 0, 0)
                Option.Text = ""
                Option.TextColor3 = Color3.new(0, 0, 0)
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.SourceSans
                Option.TextSize = 14
                Dropdown.OptionInsts[option].button = Option
                Option.ZIndex = 111
                OptionName.Name = "OptionName"
                OptionName.Position = UDim2.new(0, 2, 0, 0)
                OptionName.Size = UDim2.new(1, 0, 1, 0)
                OptionName.BackgroundColor3 = Color3.new(1, 1, 1)
                OptionName.BackgroundTransparency = 1
                OptionName.BorderSizePixel = 0
                OptionName.BorderColor3 = Color3.new(0, 0, 0)
                OptionName.Text = option
                OptionName.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                OptionName.FontFace = Library.UIFont
                OptionName.TextSize = Library.FontSize
                OptionName.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.OptionInsts[option].text = OptionName
                OptionName.ZIndex = 111
                handleoptionclick(option, Option, OptionName)
            end
        end
        createoptions(Dropdown.Options)

        local set
        set = function(option)
            table.clear(chosen)
            option = type(option) == "table" and option or {}
            for opt, tbl in next, Dropdown.OptionInsts do
                if not table.find(option, opt) then
                    tbl.text.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
                end
            end
            for i, opt in next, option do
                if table.find(Dropdown.Options, opt) and #chosen < Dropdown.Max then
                    table.insert(chosen, opt)
                    Dropdown.OptionInsts[opt].text.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
            Value.Text = #chosen == 0 and "" or table.concat(chosen, ", ")
            Library.Flags[Dropdown.Flag] = chosen
            Dropdown.Callback(chosen)
        end
        function Dropdown:Set(option) set(option) end

        function Dropdown:Refresh(tbl)
            for _, opt in next, Dropdown.OptionInsts do
                coroutine.wrap(function() opt.button:Destroy() end)()
            end
            table.clear(Dropdown.OptionInsts)
            createoptions(tbl)
            table.clear(chosen)
            Library.Flags[Dropdown.Flag] = chosen
            Dropdown.Callback(chosen)
        end

        Flags[Dropdown.Flag] = set
        Dropdown:Set(Dropdown.State)
        return Dropdown
    end

    function Sections:Keybind(Options)
        local Properties = Options or {};
        local Keybind = {
            Section = self,
            Name = Properties.Title or Properties.Name or "Keybind",
            State = Properties.state or nil,
            Mode = Properties.mode or "Toggle",
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
            Binding = nil,
            Connection = nil,
        }
        local Key
        local State = false
        local Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3

        local Holder = Instance.new('TextButton', Options.Side == "Left" and Keybind.Section.Elements.Left or Keybind.Section.Elements.Right)
        local Title = Instance.new('TextLabel', Holder)
        local Value = Instance.new('TextLabel', Holder)
        local Mode = Instance.new('TextLabel', Holder)

        do
            table.insert(Library.Instances, Title)
            table.insert(Library.Instances, Value)
            table.insert(Library.Instances, Mode)
        end

        Holder.Name = "Holder"
        Holder.Size = UDim2.new(1, 0, 0, 10)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1
        Holder.Text = ""
        Holder.TextColor3 = Color3.new(0, 0, 0)
        Holder.AutoButtonColor = false
        Holder.Font = Enum.Font.SourceSans
        Holder.TextSize = 14

        Title.Name = "Title"
        Title.Position = UDim2.new(0, 15, 0, -1)
        Title.Size = UDim2.new(1, -30, 1, 0)
        Title.BackgroundColor3 = Color3.new(1, 1, 1)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.ZIndex = 105
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Text = Keybind.Name

        Value.Name = "Value"
        Value.Position = UDim2.new(0, 15, 0, -1)
        Value.Size = UDim2.new(1, -30, 1, 0)
        Value.BackgroundColor3 = Color3.new(1, 1, 1)
        Value.BackgroundTransparency = 1
        Value.Text = "[-]"
        Value.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Value.FontFace = Library.UIFont
        Value.TextSize = Library.FontSize
        Value.ZIndex = 105
        Value.TextXAlignment = Enum.TextXAlignment.Right

        Mode.Name = "Mode"
        Mode.Position = UDim2.new(0, Title.TextBounds.X + 20, 0, -1)
        Mode.Size = UDim2.new(1, -30, 1, 0)
        Mode.BackgroundColor3 = Color3.new(1, 1, 1)
        Mode.BackgroundTransparency = 1
        Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
        Mode.TextColor3 = Color3.new(1, 1, 1)
        Mode.FontFace = Library.UIFont
        Mode.TextSize = Library.FontSize
        Mode.ZIndex = 105
        Mode.TextXAlignment = Enum.TextXAlignment.Left

        -- // Автоматически добавляем в KeybindList
        local kbItem = Library.Keybinds:Add(
            Keybind.Name,
            Keybind.State,
            Keybind.Mode,
            false,
            Keybind.Callback
        )

        local function set(newkey)
            if string.find(tostring(newkey), "Enum") then
                if Keybind.Connection then
                    Keybind.Connection:Disconnect()
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                    Keybind.Callback(false)
                end
                if tostring(newkey):find("Enum.KeyCode.") then
                    newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
                elseif tostring(newkey):find("Enum.UserInputType.") then
                    newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
                end
                if newkey == Enum.KeyCode.Backspace then
                    Key = nil
                    Value.Text = "[-]"
                    kbItem:SetKey(nil)
                elseif newkey ~= nil then
                    Key = newkey
                    local text = (Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))
                    Value.Text = "[" .. text .. "]"
                    kbItem:SetKey(newkey)
                end
                Library.Flags[Keybind.Flag .. "_KEY"] = newkey
            elseif table.find({ "Always", "Toggle", "Hold" }, newkey) then
                Library.Flags[Keybind.Flag .. "_KEY STATE"] = newkey
                Keybind.Mode = newkey
                Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
                kbItem:SetMode(newkey)
                Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3
                if Keybind.Mode == "Always" then
                    State = true
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                    Keybind.Callback(true)
                    kbItem:SetState(true)
                end
            else
                State = newkey
                if Keybind.Flag then Library.Flags[Keybind.Flag] = newkey end
                Keybind.Callback(newkey)
                kbItem:SetState(newkey)
            end
        end

        set(Keybind.State)
        set(Keybind.Mode)

        Holder.MouseButton1Click:Connect(function()
            if not Keybind.Binding then
                Value.Text = "[-]"
                Keybind.Binding = Library:Connection(
                    UserInputService.InputBegan,
                    function(input, gpe)
                        set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                        Library:Disconnect(Keybind.Binding)
                        task.wait()
                        Keybind.Binding = nil
                    end
                )
            end
        end)

        Library:Connection(UserInputService.InputBegan, function(inp)
            if (inp.KeyCode == Key or inp.UserInputType == Key) and not Keybind.Binding then
                if Keybind.Mode == "Hold" then
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = true end
                    Keybind.Connection = Library:Connection(RunService.RenderStepped, function()
                        if Keybind.Callback then Keybind.Callback(true) end
                    end)
                elseif Keybind.Mode == "Toggle" then
                    State = not State
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = State end
                    Keybind.Callback(State)
                end
            end
        end)

        Library:Connection(UserInputService.InputEnded, function(inp)
            if Keybind.Mode == "Hold" then
                if Key ~= "" or Key ~= nil then
                    if inp.KeyCode == Key or inp.UserInputType == Key then
                        if Keybind.Connection then
                            Keybind.Connection:Disconnect()
                            if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                            if Keybind.Callback then Keybind.Callback(false) end
                        end
                    end
                end
            end
        end)

        Holder.MouseButton2Click:Connect(function()
            Cycle += 1
            if Cycle > 3 then
                Cycle = 1
                set("Hold")
                Mode.Text = "[H]"
            elseif Cycle == 2 then
                set("Toggle")
                Mode.Text = "[T]"
            elseif Cycle == 3 then
                set("Always")
                Mode.Text = "[A]"
            elseif Cycle == 1 then
                set("Hold")
                Mode.Text = "[H]"
            end
        end)

        Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
        Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
        Flags[Keybind.Flag] = set
        Flags[Keybind.Flag .. "_KEY"] = set
        Flags[Keybind.Flag .. "_KEY STATE"] = set

        function Keybind:Set(key) set(key) end
        task.defer(function()
            Mode.Position = UDim2.new(0, Title.TextBounds.X + 20, 0, -1)
        end)
        return Keybind
    end

    function Sections:Textbox(Options)
        local Properties = Options or {}
        local Textbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Placeholder = Properties.placeholder or "",
            State = Properties.state or "",
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
        }

        local Holder = Instance.new('Frame', Options.Side == "Left" and Textbox.Section.Elements.Left or Textbox.Section.Elements.Right)
        local TextFrame = Instance.new('Frame', Holder)
        local Gradient = Instance.new('UIGradient', TextFrame)
        local TextBox = Instance.new('TextBox', TextFrame)

        do
            table.insert(Library.Instances, TextFrame)
            table.insert(Library.Instances, TextBox)
        end

        Holder.Name = "Holder"
        Holder.Size = UDim2.new(1, 0, 0, 15)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1
        Holder.BorderSizePixel = 0
        Holder.BorderColor3 = Color3.new(0, 0, 0)

        TextFrame.Name = "TextFrame"
        TextFrame.Position = UDim2.new(0, 15, 0, 0)
        TextFrame.Size = UDim2.new(1, -30, 1, 0)
        TextFrame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        TextFrame.BorderColor3 = Color3.new(0, 0, 0)

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        TextBox.Size = UDim2.new(1, 0, 1, 0)
        TextBox.BackgroundColor3 = Color3.new(1, 1, 1)
        TextBox.BackgroundTransparency = 1
        TextBox.BorderSizePixel = 0
        TextBox.BorderColor3 = Color3.new(0, 0, 0)
        TextBox.Text = Textbox.State
        TextBox.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        TextBox.FontFace = Library.UIFont
        TextBox.TextSize = Library.FontSize
        TextBox.PlaceholderText = Textbox.Placeholder
        TextBox.PlaceholderColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        TextBox.ClearTextOnFocus = false
        TextBox.TextWrapped = true

        TextBox.FocusLost:Connect(function()
            Textbox.Callback(TextBox.Text)
            Library.Flags[Textbox.Flag] = TextBox.Text
        end)

        local function set(str)
            TextBox.Text = str
            Library.Flags[Textbox.Flag] = str
            Textbox.Callback(str)
        end
        Flags[Textbox.Flag] = set
        return Textbox
    end

    function Sections:Button(Options)
        local Properties = Options or {}
        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Properties.Title or Properties.Name or "button",
            Callback = Properties.callback or function() end,
        }

        local Holder = Instance.new('Frame', Options.Side == "Left" and Button.Section.Elements.Left or Button.Section.Elements.Right)
        local TextFrame = Instance.new('Frame', Holder)
        local Gradient = Instance.new('UIGradient', TextFrame)
        local Textbutton = Instance.new('TextButton', TextFrame)

        do
            table.insert(Library.Instances, TextFrame)
            table.insert(Library.Instances, Textbutton)
        end

        Holder.Name = "Holder"
        Holder.Size = UDim2.new(1, 0, 0, 15)
        Holder.BackgroundColor3 = Color3.new(1, 1, 1)
        Holder.BackgroundTransparency = 1
        Holder.BorderSizePixel = 0
        Holder.BorderColor3 = Color3.new(0, 0, 0)

        TextFrame.Name = "TextFrame"
        TextFrame.Position = UDim2.new(0, 15, 0, 0)
        TextFrame.Size = UDim2.new(1, -30, 1, 0)
        TextFrame.BackgroundColor3 = Color3.new(0.0784, 0.0784, 0.0784)
        TextFrame.BorderColor3 = Color3.new(0, 0, 0)

        Gradient.Name = "Gradient"
        Gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(0.7803921699523926, 0.7490196228027344, 0.800000011920929)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }
        Gradient.Rotation = -90

        Textbutton.Name = "textbutton"
        Textbutton.Size = UDim2.new(1, 0, 1, 0)
        Textbutton.BackgroundColor3 = Color3.new(1, 1, 1)
        Textbutton.BackgroundTransparency = 1
        Textbutton.BorderSizePixel = 0
        Textbutton.BorderColor3 = Color3.new(0, 0, 0)
        Textbutton.Text = Button.Name
        Textbutton.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        Textbutton.FontFace = Library.UIFont
        Textbutton.TextSize = Library.FontSize

        Textbutton.MouseButton1Click:Connect(function()
            Button.Callback()
        end)
        Textbutton.MouseButton1Down:Connect(function()
            Textbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        Textbutton.MouseButton1Up:Connect(function()
            Textbutton.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        end)
        return Button
    end

    function Sections:Colorpicker(Options)
        local Properties = Options or {}
        local Colorpicker = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Properties.title or Properties.Title or Properties.Name or "Colorpicker",
            State = Properties.state or Properties.State or Color3.fromRGB(255, 0, 0),
            Alpha = Properties.alpha or 1,
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
            Colorpickers = 0,
        }

        local Color = Instance.new('TextButton', Options.Side == "Left" and Colorpicker.Section.Elements.Left or Colorpicker.Section.Elements.Right)
        local TextLabel = Instance.new('TextLabel', Color)

        table.insert(Library.Instances, TextLabel)

        Color.Name = "Color"
        Color.Size = UDim2.new(1, 0, 0, 10)
        Color.BackgroundColor3 = Color3.new(1, 1, 1)
        Color.BackgroundTransparency = 1
        Color.Text = ""
        Color.TextColor3 = Color3.new(0, 0, 0)
        Color.AutoButtonColor = false
        Color.Font = Enum.Font.SourceSans
        Color.TextSize = 14

        TextLabel.Position = UDim2.new(0, 15, 0, 0)
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Color3.new(0.3059, 0.3059, 0.3059)
        TextLabel.FontFace = Library.UIFont
        TextLabel.TextSize = Library.FontSize
        TextLabel.ZIndex = 105
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Text = Colorpicker.Name

        Colorpicker.Colorpickers = Colorpicker.Colorpickers + 1
        local colorpickertypes = Library:NewPicker(
            Colorpicker.State,
            Colorpicker.Alpha,
            Color,
            Colorpicker.Colorpickers - 1,
            Colorpicker.Flag,
            Colorpicker.Callback
        )
        function Colorpicker:Set(color)
            colorpickertypes:set(color, false, true)
        end
        return Colorpicker
    end
end
end

task.delay(0.5, function()
    Library.Notifications:Success("avelia", "ui library loaded successfully")
end)

return Library
