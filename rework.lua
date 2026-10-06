-- ═══════════════════════════════════════════════════════════
-- Avelia UI Library v7 — FINAL INTEGRATED
-- API совместима с: maffanyax/ui library.lua
-- Добавлено: Notifications, Config System, Keybind List
-- Обновлено: Close/Minimize кнопка, Resize handle, Design
-- Accent: #E0218A | Font: GothamBold | Quint Animations
-- ═══════════════════════════════════════════════════════════

local Library = {}
do
Library = {
    Open = true;
    Folders = {
        main = "Avelia";
        configs = "Avelia/Configs";
    };
    Accent = Color3.fromRGB(224, 33, 138); -- #E0218A
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
    -- // Design constants
    COLOR_MAIN = Color3.fromRGB(28, 28, 28);
    COLOR_INLINE = Color3.fromRGB(8, 8, 8);
    COLOR_MIDDLE = Color3.fromRGB(11, 11, 11);
    COLOR_BORDER = Color3.new(0, 0, 0);
    COLOR_LINE = Color3.fromRGB(28, 28, 28);
    COLOR_TEXT_DIM = Color3.fromRGB(120, 120, 120);
    COLOR_GRAD_END = Color3.fromRGB(11, 11, 11);
    COLOR_DIVIDER = Color3.fromRGB(20, 20, 20);
    MinW = 320;
    MinH = 200;
    Icon = "rbxassetid://76003920414364";
}

local Flags = {};
local Dropdowns = {};
local Pickers = {};
local VisValues = {};

Library.__index = Library
Library.Pages.__index = Library.Pages
Library.Sections.__index = Library.Sections

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IS_TOUCH = UserInputService.TouchEnabled
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (встроенный)
-- ═══════════════════════════════════════════════════════════
local NotificationLib = {}
NotificationLib.__index = NotificationLib
NotificationLib.Accent = Library.Accent
NotificationLib.UIFont = Library.UIFont
NotificationLib.FontSize = Library.FontSize

local TYPE_COLORS = {
    Success = Color3.fromRGB(46, 204, 113),
    Error   = Color3.fromRGB(231, 76, 60),
    Warning = Color3.fromRGB(241, 196, 15),
}

local function BuildNotifIcon(kind, color)
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
        Part(8, 8, 14, 3, 45); Part(8, 8, 14, 3, -45)
    elseif kind == "Success" then
        Part(5.5, 10, 7, 3, 45); Part(10, 7.5, 11, 3, -45)
    elseif kind == "Warning" then
        Part(8, 6.5, 3, 9, 0); Part(8, 13, 3, 3, 0)
    else
        Part(8, 3.5, 3, 3, 0); Part(8, 9.5, 3, 9, 0)
    end
    return Box
end

local function makeNotifFadeList(root)
    local list = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("GuiObject") then
            local e = { o = d }
            if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageLabel") then e.bg = d.BackgroundTransparency end
            if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then e.tx = d.TextTransparency end
            if d:IsA("ImageLabel") then e.im = d.ImageTransparency end
            if d:IsA("UIStroke") then e.st = d.Transparency end
            table.insert(list, e)
        end
    end
    return list
end

local function notifFadeSetHidden(list)
    for _, e in ipairs(list) do
        if e.bg then e.o.BackgroundTransparency = 1 end
        if e.tx then e.o.TextTransparency = 1 end
        if e.im then e.o.ImageTransparency = 1 end
        if e.st then e.o.Transparency = 1 end
    end
end

local function notifFadeIn(list, duration)
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

local function notifFadeOut(list, duration)
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

function NotificationLib.new()
    local self = setmetatable({}, NotificationLib)
    self.Active = {}
    local parentGui = game:GetService("CoreGui")
    if RunService:IsStudio() then
        parentGui = LocalPlayer:WaitForChild("PlayerGui")
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AveliaNotifications"
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
    local Type     = Properties.Type or "Info"
    local TitleTxt = Properties.Title or string.lower(Type)
    local Message  = Properties.Message or ""
    local Duration = Properties.Duration or 5
    local typeColor = TYPE_COLORS[Type] or self.Accent
    if Type == "Info" then typeColor = self.Accent end

    local alive = true
    local entry = { IsInfo = (Type == "Info") }

    local Main = Instance.new("Frame", self.Container)
    Main.Name = "Notification"
    Main.Size = UDim2.new(1, 0, 0, 0)
    Main.BackgroundColor3 = Library.COLOR_MAIN
    Main.BorderColor3 = Library.COLOR_BORDER
    Main.BorderSizePixel = 1
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 3)
    entry.Main = Main

    local Inline = Instance.new("Frame", Main)
    Inline.Position = UDim2.new(0, 2, 0, 2)
    Inline.Size = UDim2.new(1, -4, 1, -4)
    Inline.BackgroundColor3 = Library.COLOR_INLINE
    Inline.BorderColor3 = Library.COLOR_BORDER
    Inline.BorderSizePixel = 1
    Instance.new("UICorner", Inline).CornerRadius = UDim.new(0, 2)

    local Top = Instance.new("Frame", Inline)
    Top.Size = UDim2.new(1, 0, 0, 22)
    Top.BackgroundColor3 = Library.COLOR_INLINE
    Top.BorderSizePixel = 0

    local Icon = BuildNotifIcon(Type, typeColor)
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
        ColorSequenceKeypoint.new(1, Library.COLOR_GRAD_END),
    }
    Grad.Rotation = 180
    entry.Grad = Grad

    local Middle = Instance.new("Frame", Inline)
    Middle.Position = UDim2.new(0, 0, 0, 23)
    Middle.BackgroundColor3 = Library.COLOR_MIDDLE
    Middle.BorderSizePixel = 0

    local MessageLabel = Instance.new("TextLabel", Middle)
    MessageLabel.Position = UDim2.new(0, 7, 0, 4)
    MessageLabel.Size = UDim2.new(1, -14, 0, 0)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Library.COLOR_TEXT_DIM
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

    local fadeList = makeNotifFadeList(Main)
    notifFadeSetHidden(fadeList)
    Main.Position = UDim2.new(0, 320, 0, 0)
    Main.Size = UDim2.new(1, 0, 0, 0)

    TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()
    TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, targetH),
    }):Play()
    task.delay(0.06, function()
        if alive then notifFadeIn(fadeList, 0.4) end
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
        notifFadeOut(fadeList, 0.28)
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

-- Глобальный инстанс уведомлений
local Notifications = NotificationLib.new()
Library.Notifications = Notifications

-- ═══════════════════════════════════════════════════════════
-- KEYBIND LIST SYSTEM (встроенный)
-- ═══════════════════════════════════════════════════════════
local KeybindListLib = {}
KeybindListLib.__index = KeybindListLib
KeybindListLib.Accent = Library.Accent
KeybindListLib.UIFont = Library.UIFont
KeybindListLib.FontSize = Library.FontSize
KeybindListLib.KeyboardIcon = "rbxassetid://82063092844430"

function KeybindListLib.new(Options)
    local Properties = Options or {}
    local self = setmetatable({}, KeybindListLib)
    self.Open = true
    self.Items = {}
    self.Title = Properties.Name or "keybinds"
    self.ThemeObjects = {}
    self.Instances = {}
    self._activeCount = 0

    local parentGui = game:GetService("CoreGui")
    if RunService:IsStudio() then
        parentGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AveliaKeybindList"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = parentGui

    local Main = Instance.new("Frame", ScreenGui)
    local Inline = Instance.new("Frame", Main)
    local Top = Instance.new("TextButton", Inline)
    local Icon = Instance.new("ImageLabel", Top)
    local Title = Instance.new("TextLabel", Top)
    local Line = Instance.new("Frame", Inline)
    local UIGradient = Instance.new("UIGradient", Line)
    local Middle = Instance.new("Frame", Inline)
    local Content = Instance.new("Frame", Middle)
    local UIListLayout = Instance.new("UIListLayout", Content)
    local UIPadding = Instance.new("UIPadding", Content)
    local Scale = Instance.new("UIScale", Main)

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
    Instance.new("UICorner", Inline).CornerRadius = UDim.new(0, 3)

    table.insert(self.Instances, Main)
    table.insert(self.ThemeObjects, Title)
    table.insert(self.ThemeObjects, Line)
    self.Icon = Icon

    Main.Name = "KeybindsMain"
    Main.Position = Properties.Position or UDim2.new(1, -210, 0.5, -60)
    Main.Size = UDim2.new(0, 195, 0, 37)
    Main.BackgroundColor3 = Library.COLOR_MAIN
    Main.BorderColor3 = Library.COLOR_BORDER
    Main.BorderSizePixel = 1
    Main.Active = true
    Main.ClipsDescendants = false
    Main.AutomaticSize = Enum.AutomaticSize.Y

    Inline.Name = "KeybindsInline"
    Inline.Position = UDim2.new(0, 2, 0, 2)
    Inline.Size = UDim2.new(1, -4, 1, -4)
    Inline.BackgroundColor3 = Library.COLOR_INLINE
    Inline.BorderColor3 = Library.COLOR_BORDER
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
    Icon.ImageColor3 = Color3.new(1, 1, 1)
    Icon.ScaleType = Enum.ScaleType.Fit

    Title.Name = "Title"
    Title.Position = UDim2.new(0, 35, 0, 0)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.BackgroundTransparency = 1
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
        ColorSequenceKeypoint.new(1, Library.COLOR_GRAD_END)
    }
    UIGradient.Rotation = 180

    Middle.Name = "Middle"
    Middle.Position = UDim2.new(0, 0, 0, 32)
    Middle.Size = UDim2.new(1, 0, 0, 0)
    Middle.BackgroundColor3 = Library.COLOR_MIDDLE
    Middle.BorderSizePixel = 0
    Middle.AutomaticSize = Enum.AutomaticSize.Y

    Content.Name = "Content"
    Content.Position = UDim2.new(0, 6, 0, 0)
    Content.Size = UDim2.new(1, -12, 0, 0)
    Content.BackgroundTransparency = 1
    Content.AutomaticSize = Enum.AutomaticSize.Y
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 3)
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.PaddingBottom = UDim.new(0, 6)

    -- // Плавный драгг
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
        Divider.AnchorPoint = Vector2.new(0, 1)
        Divider.Position = UDim2.new(0, 0, 1, 1)
        Divider.Size = UDim2.new(1, 0, 0, 1)
        Divider.BackgroundColor3 = Library.COLOR_DIVIDER
        Divider.BorderSizePixel = 0
        Divider.BackgroundTransparency = 1
        Item.Divider = Divider

        local lastState = nil

        local function animateBar(on)
            if Item._barTween then Item._barTween:Cancel() end
            if Item._barPulse then Item._barPulse:Cancel() end
            if on then
                AccentBar.Position = UDim2.new(0, -2, 0, 2)
                AccentBar.Size = UDim2.new(0, 2, 1, -4)
                Item._barTween = TweenService:Create(AccentBar,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0, 0, 0, 2) }
                )
                Item._barTween:Play()
                Item._barTween.Completed:Connect(function()
                    if not Item.State then return end
                    Item._barPulse = TweenService:Create(AccentBar,
                        TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                        { Size = UDim2.new(0, 2, 1, -7) }
                    )
                    Item._barPulse:Play()
                end)
            else
                Item._barTween = TweenService:Create(AccentBar,
                    TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0, -2, 0, 2), Size = UDim2.new(0, 2, 1, -4) }
                )
                Item._barTween:Play()
            end
        end

        local function animateLabel()
            if Item._labelTween then Item._labelTween:Cancel() end
            Label.TextTransparency = 0.3
            Item._labelTween = TweenService:Create(Label,
                TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { TextTransparency = 0 }
            )
            Item._labelTween:Play()
        end

        local function animateDivider(show)
            if Item._divTween then Item._divTween:Cancel() end
            Item._divTween = TweenService:Create(Divider,
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
                    Library.COLOR_TEXT_DIM:ToHex(), Item.Name, keytext, modeletter
                )
            end
            if lastState ~= nil and Item.State ~= lastState then
                animateBar(Item.State)
                animateLabel()
            else
                if lastState == nil then
                    AccentBar.Position = Item.State and UDim2.new(0, 0, 0, 2) or UDim2.new(0, -2, 0, 2)
                    if Item.State then
                        Item._barPulse = TweenService:Create(AccentBar,
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
        function Item:SetKey(key) Item.Key = key Item:Update() end
        function Item:SetMode(mode) Item.Mode = mode Item:Update() end
        function Item:Remove()
            local idx = table.find(list.Items, Item)
            if idx then table.remove(list.Items, idx) end
            if Item._removing then return end
            Item._removing = true
            if Item._barPulse then Item._barPulse:Cancel() end
            notifFadeOut(makeNotifFadeList(Row), 0.25)
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
        local fadeList = makeNotifFadeList(Main)
        if bool then
            Main.Visible = true
            Scale.Scale = 0.9
            notifFadeSetHidden(fadeList)
            TweenService:Create(Scale, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            notifFadeIn(fadeList, 0.5)
        else
            notifFadeOut(fadeList, 0.4)
            TweenService:Create(Scale, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.9 }):Play()
            task.delay(0.48, function()
                if not self.Open then Main.Visible = false end
            end)
        end
    end

    -- Entrance animation
    local entranceFade = makeNotifFadeList(Main)
    notifFadeSetHidden(entranceFade)
    Scale.Scale = 0.88
    local basePos = Properties.Position or UDim2.new(1, -210, 0.5, -60)
    Main.Position = basePos + UDim2.new(0, 6, 0, 14)
    task.delay(0.05, function()
        TweenService:Create(Scale, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = basePos,
        }):Play()
        notifFadeIn(entranceFade, 0.65)
    end)
    return self
end

-- Глобальный инстанс keybind list
local KeybindList = KeybindListLib.new({ Name = "keybinds" })
Library.KeybindList = KeybindList

-- ═══════════════════════════════════════════════════════════
-- CONFIG SYSTEM (XOR + Base64)
-- ═══════════════════════════════════════════════════════════
local CONFIG_KEY = "AveliaXOR2026K7mP9xQ2vR5tY8nB"
local CFG_FOLDER = "Avelia.cc/cfgs"

local HAS_BIT32 = (type(bit32) == "table" and type(bit32.bxor) == "function")
local function safeBxor(a, b)
    if HAS_BIT32 then return bit32.bxor(a, b) end
    local result = 0
    for i = 0, 7 do
        local ba = math.floor(a / (2 ^ i)) % 2
        local bb = math.floor(b / (2 ^ i)) % 2
        if ba ~= bb then result = result + (2 ^ i) end
    end
    return result
end

local function xorCrypt(data, key)
    local out = {}
    local klen = #key
    for i = 1, #data do
        local d = string.byte(data, i)
        local k = string.byte(key, ((i - 1) % klen) + 1)
        out[i] = string.char(safeBxor(d, k))
    end
    return table.concat(out)
end

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64_LOOKUP = {}
for i = 1, #B64_CHARS do B64_LOOKUP[string.sub(B64_CHARS, i, i)] = i - 1 end

local function fallbackB64Encode(data)
    local result = {}
    for i = 1, #data, 3 do
        local b1 = string.byte(data, i)
        local b2 = string.byte(data, i + 1)
        local b3 = string.byte(data, i + 2)
        local byte2 = b2 or 0
        local byte3 = b3 or 0
        local combined = b1 * 65536 + byte2 * 256 + byte3
        result[#result + 1] = string.sub(B64_CHARS, math.floor(combined / 262144) % 64 + 1, math.floor(combined / 262144) % 64 + 1)
        result[#result + 1] = string.sub(B64_CHARS, math.floor(combined / 4096) % 64 + 1, math.floor(combined / 4096) % 64 + 1)
        if b3 then
            result[#result + 1] = string.sub(B64_CHARS, math.floor(combined / 64) % 64 + 1, math.floor(combined / 64) % 64 + 1)
            result[#result + 1] = string.sub(B64_CHARS, combined % 64 + 1, combined % 64 + 1)
        elseif b2 then
            result[#result + 1] = string.sub(B64_CHARS, math.floor(combined / 64) % 64 + 1, math.floor(combined / 64) % 64 + 1)
            result[#result + 1] = "="
        else
            result[#result + 1] = "=="
        end
    end
    return table.concat(result)
end

local function fallbackB64Decode(data)
    data = data:gsub("[^" .. B64_CHARS:gsub("(%W)", "%%%1") .. "=]", "")
    local result = {}
    local buffer, bits = 0, 0
    for i = 1, #data do
        local c = string.sub(data, i, i)
        if c == "=" then break end
        local val = B64_LOOKUP[c]
        if val then
            buffer = buffer * 64 + val
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                local byte = math.floor(buffer / (2 ^ bits)) % 256
                result[#result + 1] = string.char(byte)
                buffer = buffer % (2 ^ bits)
            end
        end
    end
    return table.concat(result)
end

local function b64Encode(data)
    if type(base64_encode) == "function" then
        local ok, res = pcall(base64_encode, data)
        if ok and res then return res end
    end
    return fallbackB64Encode(data)
end

local function b64Decode(data)
    if type(base64_decode) == "function" then
        local ok, res = pcall(base64_decode, data)
        if ok and res then return res end
    end
    return fallbackB64Decode(data)
end

local function cfgEncrypt(text) return b64Encode(xorCrypt(text, CONFIG_KEY)) end
local function cfgDecrypt(encoded) return xorCrypt(b64Decode(encoded), CONFIG_KEY) end

local function ensureCfgFolders()
    pcall(function() if not isfolder("Avelia.cc") then makefolder("Avelia.cc") end end)
    pcall(function() if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)
end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. name .. ".avelia" end

function Library.SaveConfig(name, dataTable)
    ensureCfgFolders()
    local json = HttpService:JSONEncode(dataTable)
    local enc = cfgEncrypt(json)
    local ok, err = pcall(writefile, getCfgPath(name), enc)
    if not ok then
        Notifications:Error("error", "failed to save config: " .. tostring(err))
        return false
    end
    Notifications:Success("success", "config saved: " .. name)
    return true
end

function Library.LoadConfig(name)
    local path = getCfgPath(name)
    if not isfile(path) then
        Notifications:Error("error", "config not found: " .. name)
        return nil
    end
    local ok, content = pcall(readfile, path)
    if not ok then
        Notifications:Error("error", "failed to read config")
        return nil
    end
    local ok2, json = pcall(cfgDecrypt, content)
    if not ok2 then
        Notifications:Error("error", "failed to decrypt config")
        return nil
    end
    local ok3, data = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok3 then
        Notifications:Error("error", "failed to parse config")
        return nil
    end
    Notifications:Success("success", "config loaded: " .. name)
    return data
end

function Library.DeleteConfig(name)
    local path = getCfgPath(name)
    if isfile(path) then
        pcall(delfile, path)
        Notifications:Warning("warning", "config deleted: " .. name)
        return true
    end
    Notifications:Error("error", "config not found: " .. name)
    return false
end

function Library.ListConfigs()
    ensureCfgFolders()
    local names = {}
    if isfolder(CFG_FOLDER) then
        local ok, files = pcall(listfiles, CFG_FOLDER)
        if ok and files then
            for _, f in ipairs(files) do
                local n = f:match("([^/\\]+)%.avelia$")
                if n and not names[n] then names[n] = true end
            end
        end
    end
    local list = {}
    for n in pairs(names) do table.insert(list, n) end
    table.sort(list)
    return list
end

-- ═══════════════════════════════════════════════════════════
-- MISC FUNCTIONS
-- ═══════════════════════════════════════════════════════════
function Library:Connection(Signal, Callback)
    local Con = Signal:Connect(Callback)
    table.insert(self.Connections, Con)
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
            if typeof(Flags[i]) == "table" then
                Flags[i]:Set(v)
            else
                Flags[i](v)
            end
        end
    end
end

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
    and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
end

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
        ColorSequenceKeypoint.new(1, Library.COLOR_GRAD_END)
    }
    -- Update keybind list
    KeybindList:Clear()
    -- Update notifications accent
    Notifications.Accent = Color
end

-- ═══════════════════════════════════════════════════════════
-- COLORPICKER
-- ═══════════════════════════════════════════════════════════
function Library:NewPicker(default, defaultalpha, parent, count, flag, callback)
    local Icon = Instance.new('TextButton', parent)
    local Gradient = Instance.new('UIGradient', Icon)
    local Window = Instance.new('Frame', Icon)
    local Sat = Instance.new('ImageButton', Window)
    local Hue = Instance.new('ImageButton', Window)

    table.insert(Library.Instances, Icon)
    table.insert(Library.Instances, Window)
    table.insert(Library.Instances, Sat)
    table.insert(Library.Instances, Hue)
    table.insert(Pickers, Window)

    Icon.Name = "Icon"
    Icon.Position = UDim2.new(1, -30 - (count * 15) - (count * 6), 0, 4)
    Icon.Size = UDim2.new(0, 15, 0, 6)
    Icon.BackgroundColor3 = default
    Icon.BorderColor3 = Color3.new(0, 0, 0)
    Icon.AutoButtonColor = false
    Icon.Text = ""

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    Window.Name = "Window"
    Window.Position = UDim2.new(0, -120, 0, 10)
    Window.Size = UDim2.new(0, 150, 0, 133)
    Window.BackgroundColor3 = Library.COLOR_INLINE
    Window.BorderColor3 = Library.COLOR_LINE
    Window.ZIndex = 1220
    Window.Visible = false

    Sat.Name = "Sat"
    Sat.Position = UDim2.new(0, 5, 0, 5)
    Sat.Size = UDim2.new(0, 123, 0, 123)
    Sat.BackgroundColor3 = default
    Sat.BorderColor3 = Library.COLOR_LINE
    Sat.Image = "http://www.roblox.com/asset/?id=13882904626"
    Sat.AutoButtonColor = false
    Sat.ZIndex = 1220

    Hue.Name = "Hue"
    Hue.Position = UDim2.new(1, -15, 0, 5)
    Hue.Size = UDim2.new(0, 10, 0, 123)
    Hue.BackgroundColor3 = Color3.new(1, 1, 1)
    Hue.BorderColor3 = Library.COLOR_LINE
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
            if flag then Library.Flags[flag] = Library:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha) end
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
        if set_callback then set(Color3.fromHSV(curhuesizey or hue, sizeX, sizeY), alpha or defaultalpha, true, false) end
    end

    local slidingsaturation = false
    Sat.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then slidingsaturation = true updatesatval(input) end
    end)
    Sat.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then slidingsaturation = false updatesatval(input, true) end
    end)

    local slidinghue = false
    local function updatehue(input, set_callback)
        local sizeY = 1 - math.clamp((((input.Position.Y - 30) - Hue.AbsolutePosition.Y) + 36) / Hue.AbsoluteSize.Y, 0, 1)
        Sat.BackgroundColor3 = Color3.fromHSV(sizeY, 1, 1)
        curhuesizey = sizeY
        if set_callback then set(Color3.fromHSV(sizeY, sat, val), alpha or defaultalpha, true, true) end
    end
    Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then slidinghue = true updatehue(input) end
    end)
    Hue.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then slidinghue = false updatehue(input, true) end
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

-- ═══════════════════════════════════════════════════════════
-- LIBRARY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local Pages = Library.Pages
local Sections = Library.Sections

function Library:Window(Options)
    local Base = {
        Pages = {};
        Sections = {};
        Elements = {};
        Title = Options.Name or "avelia";
    }

    local ScreenGui = Instance.new('ScreenGui', RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"))
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
    local SectionsFrame = Instance.new('Frame', Middle)
    local PagesFrame = Instance.new('Frame', Top)
    local UIListLayout = Instance.new('UIListLayout', PagesFrame)
    local version = Instance.new('TextLabel', Bottom)
    local corner1 = Instance.new('UICorner', Main)
    local corner2 = Instance.new('UICorner', Inline)
    local stroke1 = Instance.new('UIStroke', Main)
    local stroke2 = Instance.new('UIStroke', Inline)
    local Scale = Instance.new('UIScale', Main)
    Scale.Scale = 1

    table.insert(Library.Instances, Main)
    table.insert(Library.Instances, Inline)
    table.insert(Library.Instances, Middle)
    table.insert(Library.Instances, Line)
    table.insert(Library.Instances, Line2)
    table.insert(Library.Instances, Gradient)
    table.insert(Library.Instances, Title)
    table.insert(Library.Instances, SectionsFrame)
    table.insert(Library.Instances, version)
    table.insert(Library.ThemeObjects, Title)
    table.insert(Library.ThemeObjects, version)

    ScreenGui.DisplayOrder = 2

    -- // Main
    Main.Name = "Main"
    local baseWidth = Options.Width or 580
    local baseHeight = Options.Height or 442
    local viewport = workspace.CurrentCamera.ViewportSize
    local startAbsX = math.floor(viewport.X * 0.5 - baseWidth * 0.5)
    local startAbsY = math.floor(viewport.Y * 0.5 - baseHeight * 0.5)
    Main.Position = UDim2.new(0, startAbsX, 0, startAbsY)
    Main.Size = UDim2.new(0, baseWidth, 0, baseHeight)
    Main.BackgroundColor3 = Library.COLOR_MAIN
    Main.BorderColor3 = Library.COLOR_BORDER
    Main.BorderSizePixel = 1
    Main.Active = true
    Main.ClipsDescendants = false
    Library.Holder = Main

    Inline.Name = "Inline"
    Inline.Position = UDim2.new(0, 2, 0, 2)
    Inline.Size = UDim2.new(1, -4, 1, -4)
    Inline.BackgroundColor3 = Library.COLOR_INLINE
    Inline.BorderColor3 = Library.COLOR_BORDER
    Inline.BorderSizePixel = 1

    Middle.Name = "Middle"
    Middle.Position = UDim2.new(0, -1, 0, 22)
    Middle.Size = UDim2.new(1, 2, 1, -44)
    Middle.BackgroundColor3 = Library.COLOR_MIDDLE
    Middle.BorderColor3 = Library.COLOR_BORDER
    Middle.BorderSizePixel = 1
    Middle.BorderMode = Enum.BorderMode.Inset

    Line.Name = "Line"
    Line.Position = UDim2.new(0, -1, 0, 0)
    Line.Size = UDim2.new(1, 2, 0, 1)
    Line.BackgroundColor3 = Library.COLOR_LINE
    Line.BorderSizePixel = 0

    Line2.Name = "Line2"
    Line2.Position = UDim2.new(0, -1, 1, -1)
    Line2.Size = UDim2.new(1, 2, 0, 1)
    Line2.BackgroundColor3 = Library.COLOR_LINE
    Line2.BorderSizePixel = 0

    Gradient.Name = "Gradient"
    Gradient.Position = UDim2.new(0.5, 0, 0, 2)
    Gradient.Size = UDim2.new(0.5, 0, 0, 1)
    Gradient.BackgroundColor3 = Color3.new(1, 1, 1)
    Gradient.BorderSizePixel = 0
    Library.Gradient = Gradient
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Library.Accent),
        ColorSequenceKeypoint.new(1, Library.COLOR_GRAD_END)
    }
    UIGradient.Rotation = 180
    Library.UIGradient = UIGradient

    Top.Name = "Top"
    Top.Size = UDim2.new(1, 0, 0, 22)
    Top.BackgroundColor3 = Color3.new(1, 1, 1)
    Top.BackgroundTransparency = 1
    Top.BorderSizePixel = 0
    Top.AutoButtonColor = false
    Top.Text = ""

    Title.Name = "Title"
    Title.Position = UDim2.new(0, 32, 0, 0)
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = Base.Title
    Title.TextColor3 = Library.Accent
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.RichText = true

    -- ═══════════════════════════════════════════════════════
    -- CLOSE / MINIMIZE BUTTONS (new design)
    -- ═══════════════════════════════════════════════════════
    local MinBtn = Instance.new('TextButton', Top)
    MinBtn.Name = "MinBtn"
    MinBtn.AnchorPoint = Vector2.new(1, 0.5)
    MinBtn.Position = UDim2.new(1, -28, 0.5, 0)
    MinBtn.Size = UDim2.new(0, 18, 0, 18)
    MinBtn.BackgroundColor3 = Library.COLOR_MAIN
    MinBtn.BorderColor3 = Library.COLOR_LINE
    MinBtn.BorderSizePixel = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Library.COLOR_TEXT_DIM
    MinBtn.FontFace = Library.UIFont
    MinBtn.TextSize = 10
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 10
    Instance.new('UICorner', MinBtn).CornerRadius = UDim.new(0, 2)
    table.insert(Library.Instances, MinBtn)

    local CloseBtn = Instance.new('TextButton', Top)
    CloseBtn.Name = "CloseBtn"
    CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    CloseBtn.Position = UDim2.new(1, -6, 0.5, 0)
    CloseBtn.Size = UDim2.new(0, 18, 0, 18)
    CloseBtn.BackgroundColor3 = Library.COLOR_MAIN
    CloseBtn.BorderColor3 = Library.COLOR_LINE
    CloseBtn.BorderSizePixel = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Library.COLOR_TEXT_DIM
    CloseBtn.FontFace = Library.UIFont
    CloseBtn.TextSize = 10
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 10
    Instance.new('UICorner', CloseBtn).CornerRadius = UDim.new(0, 2)
    table.insert(Library.Instances, CloseBtn)

    -- // Hover/press animations
    local function btnAnim(btn, state)
        local targetBg, targetText
        if state == "hover" then
            targetBg = Library.Accent
            targetText = Color3.new(1, 1, 1)
        elseif state == "press" then
            targetBg = Color3.fromRGB(180, 20, 100)
            targetText = Color3.new(1, 1, 1)
        else
            targetBg = Library.COLOR_MAIN
            targetText = Library.COLOR_TEXT_DIM
        end
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = targetBg,
            TextColor3 = targetText
        }):Play()
    end

    MinBtn.MouseEnter:Connect(function() btnAnim(MinBtn, "hover") end)
    MinBtn.MouseLeave:Connect(function() btnAnim(MinBtn, "idle") end)
    MinBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then btnAnim(MinBtn, "press") end end)
    MinBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then btnAnim(MinBtn, "hover") end end)

    CloseBtn.MouseEnter:Connect(function() btnAnim(CloseBtn, "hover") end)
    CloseBtn.MouseLeave:Connect(function() btnAnim(CloseBtn, "idle") end)
    CloseBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then btnAnim(CloseBtn, "press") end end)
    CloseBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then btnAnim(CloseBtn, "hover") end end)

    -- // Floating icon (minimized state)
    local FLOAT_SIZE = 54
    local FLOAT_ICON_SIZE = 46
    local FloatBtn = Instance.new("TextButton", ScreenGui)
    FloatBtn.Name = "FloatBtn"
    FloatBtn.Size = UDim2.new(0, FLOAT_SIZE, 0, FLOAT_SIZE)
    FloatBtn.Position = UDim2.new(0, 20, 0.5, -FLOAT_SIZE / 2)
    FloatBtn.BackgroundTransparency = 1
    FloatBtn.Text = ""
    FloatBtn.AutoButtonColor = false
    FloatBtn.Visible = false
    FloatBtn.Active = true
    FloatBtn.Draggable = true
    FloatBtn.ZIndex = 100

    local FloatIcon = Instance.new("ImageLabel", FloatBtn)
    FloatIcon.Name = "Icon"
    FloatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    FloatIcon.Size = UDim2.new(0, FLOAT_ICON_SIZE, 0, FLOAT_ICON_SIZE)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Image = Library.Icon
    FloatIcon.ImageColor3 = Library.Accent
    FloatIcon.ScaleType = Enum.ScaleType.Fit

    local isMinimized = false
    local savedPosition = Main.Position
    local savedSize = Main.Size

    local function minimizeGUI()
        if isMinimized then return end
        isMinimized = true
        savedPosition = Main.Position
        savedSize = Main.Size
        -- Fade out
        Library:SetOpen(false)
        task.delay(0.32, function()
            Main.Visible = false
            FloatBtn.Visible = true
            FloatIcon.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(FloatIcon,
                TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.new(0, FLOAT_ICON_SIZE, 0, FLOAT_ICON_SIZE) }
            ):Play()
        end)
    end

    local function restoreGUI()
        if not isMinimized then return end
        isMinimized = false
        Main.Visible = true
        Main.Position = savedPosition
        Main.Size = savedSize
        TweenService:Create(FloatIcon,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            { Size = UDim2.new(0, 0, 0, 0) }
        ):Play()
        task.delay(0.15, function()
            if not isMinimized then FloatBtn.Visible = false end
        end)
        Library:SetOpen(true)
    end

    MinBtn.MouseButton1Click:Connect(minimizeGUI)

    local floatPressTime = 0
    local floatPressPos = Vector2.zero
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatPressTime = os.clock()
            floatPressPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    FloatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local moved = (Vector2.new(input.Position.X, input.Position.Y) - floatPressPos).Magnitude
            if os.clock() - floatPressTime < 1.5 and moved < 12 then
                restoreGUI()
            end
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Library:SetOpen(false)
    end)

    Bottom.Name = "Bottom"
    Bottom.Position = UDim2.new(0, 0, 1, -22)
    Bottom.Size = UDim2.new(1, 0, 0, 22)
    Bottom.BackgroundTransparency = 1

    SectionsFrame.Name = "Sections"
    SectionsFrame.Position = UDim2.new(0, 10, 0, 13)
    SectionsFrame.Size = UDim2.new(0, 110, 1, -26)
    SectionsFrame.BackgroundColor3 = Library.COLOR_INLINE
    SectionsFrame.BorderColor3 = Library.COLOR_LINE
    SectionsFrame.BorderSizePixel = 1
    Instance.new('UICorner', SectionsFrame).CornerRadius = UDim.new(0, 3)

    PagesFrame.Name = "Pages"
    PagesFrame.Position = UDim2.new(0, 60, 0, 0)
    PagesFrame.Size = UDim2.new(1, -60, 1, 0)
    PagesFrame.BackgroundTransparency = 1
    PagesFrame.ZIndex = 52
    Library.PageHolder = PagesFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    version.Name = "version"
    version.Position = UDim2.new(0, 4, 0, 0)
    version.Size = UDim2.new(1, -4, 1, 0)
    version.BackgroundTransparency = 1
    version.Text = string.format('<font color="#4e4e4e">version: </font><font color="#%s">live</font>', Library.Accent:ToHex())
    version.TextColor3 = Library.Accent
    version.FontFace = Library.UIFont
    version.TextSize = Library.FontSize
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.RichText = true

    corner1.CornerRadius = UDim.new(0, 4)
    corner2.CornerRadius = UDim.new(0, 3)

    -- ═══════════════════════════════════════════════════════
    -- RESIZE HANDLE (new design — 3 bars)
    -- ═══════════════════════════════════════════════════════
    local HANDLE_SIZE = 36
    local resizeCorner = Instance.new("TextButton", Main)
    resizeCorner.Name = "ResizeCorner"
    resizeCorner.AnchorPoint = Vector2.new(1, 1)
    resizeCorner.Position = UDim2.new(1, -6, 1, -6)
    resizeCorner.Size = UDim2.new(0, HANDLE_SIZE, 0, HANDLE_SIZE)
    resizeCorner.BackgroundTransparency = 1
    resizeCorner.Text = ""
    resizeCorner.AutoButtonColor = false
    resizeCorner.ZIndex = 250
    resizeCorner.Active = true

    local iconHolder = Instance.new("Frame", resizeCorner)
    iconHolder.Name = "IconHolder"
    iconHolder.AnchorPoint = Vector2.new(1, 1)
    iconHolder.Position = UDim2.new(1, -1, 1, -1)
    iconHolder.Size = UDim2.new(0, 16, 0, 16)
    iconHolder.BackgroundTransparency = 1
    iconHolder.ZIndex = 251

    local barLengths = { 6, 9, 12 }
    local barOffsets = {
        Vector2.new(-1, -1),
        Vector2.new(-1, -5),
        Vector2.new(-1, -9),
    }
    local bars = {}
    for i = 1, 3 do
        local bar = Instance.new("Frame", iconHolder)
        bar.Name = "Bar" .. i
        bar.AnchorPoint = Vector2.new(1, 1)
        bar.Size = UDim2.new(0, barLengths[i], 0, 2)
        bar.Position = UDim2.new(1, barOffsets[i].X, 1, barOffsets[i].Y)
        bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        bar.BackgroundTransparency = 0.15
        bar.BorderSizePixel = 0
        bar.Rotation = -45
        bar.ZIndex = 251
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        bars[i] = bar
    end

    local function setBarsState(state)
        local targetColor, targetTransparency
        if state == "hover" then
            targetColor = Library.Accent
            targetTransparency = 0
        elseif state == "press" then
            targetColor = Color3.fromRGB(255, 150, 200)
            targetTransparency = 0
        else
            targetColor = Color3.fromRGB(255, 255, 255)
            targetTransparency = 0.15
        end
        for _, bar in ipairs(bars) do
            TweenService:Create(bar, TweenInfo.new(0.15), {
                BackgroundColor3 = targetColor,
                BackgroundTransparency = targetTransparency
            }):Play()
        end
    end

    resizeCorner.MouseEnter:Connect(function() setBarsState("hover") end)
    resizeCorner.MouseLeave:Connect(function() setBarsState("idle") end)

    -- // Drag state
    local currentPos = Vector2.new(startAbsX, startAbsY)
    local currentSize = Vector2.new(baseWidth, baseHeight)
    local targetPos = Vector2.new(startAbsX, startAbsY)
    local targetSize = Vector2.new(baseWidth, baseHeight)
    local dragging = false
    local resizing = false
    local dragStartMouse = Vector2.zero
    local dragStartPos = Vector2.zero
    local resizeStart = Vector2.zero
    local startSize = Vector2.zero

    local function applyMain()
        Main.Position = UDim2.new(0, currentPos.X, 0, currentPos.Y)
        Main.Size = UDim2.new(0, currentSize.X, 0, currentSize.Y)
    end

    local function clampPos(p, s)
        local vp = workspace.CurrentCamera.ViewportSize
        return Vector2.new(
            math.clamp(p.X, 0, math.max(0, vp.X - s.X)),
            math.clamp(p.Y, 0, math.max(0, vp.Y - s.Y))
        )
    end

    -- // Drag
    Top.InputBegan:Connect(function(input)
        if resizing then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            dragStartPos = currentPos
            targetPos = currentPos
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartMouse
            targetPos = clampPos(dragStartPos + delta, currentSize)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- // Resize
    resizeCorner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            dragging = false
            resizeStart = Vector2.new(input.Position.X, input.Position.Y)
            startSize = currentSize
            targetSize = currentSize
            setBarsState("press")
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStart
        local newW = math.max(Library.MinW, startSize.X + delta.X)
        local newH = math.max(Library.MinH, startSize.Y + delta.Y)
        local vp = workspace.CurrentCamera.ViewportSize
        newW = math.min(newW, vp.X - currentPos.X)
        newH = math.min(newH, vp.Y - currentPos.Y)
        targetSize = Vector2.new(newW, newH)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and resizing then
            resizing = false
            setBarsState("idle")
        end
    end)

    -- // Smooth interpolation
    RunService.RenderStepped:Connect(function(dt)
        local alpha = 1 - math.exp(-16 * dt)
        local dx = targetSize.X - currentSize.X
        local dy = targetSize.Y - currentSize.Y
        if math.abs(dx) < 0.05 then currentSize = Vector2.new(targetSize.X, currentSize.Y)
        else currentSize = Vector2.new(currentSize.X + dx * alpha, currentSize.Y) end
        if math.abs(dy) < 0.05 then currentSize = Vector2.new(currentSize.X, targetSize.Y)
        else currentSize = Vector2.new(currentSize.X, currentSize.Y + dy * alpha) end

        local px = targetPos.X - currentPos.X
        local py = targetPos.Y - currentPos.Y
        if math.abs(px) < 0.05 then currentPos = Vector2.new(targetPos.X, currentPos.Y)
        else currentPos = Vector2.new(currentPos.X + px * alpha, currentPos.Y) end
        if math.abs(py) < 0.05 then currentPos = Vector2.new(currentPos.X, targetPos.Y)
        else currentPos = Vector2.new(currentPos.X, currentPos.Y + py * alpha) end
        applyMain()
    end)

    -- // Entrance animation
    local fadeList = {}
    for _, d in ipairs(Main:GetDescendants()) do
        if d:IsA("GuiObject") then
            local e = { o = d }
            if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageLabel") then e.bg = d.BackgroundTransparency end
            if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then e.tx = d.TextTransparency end
            if d:IsA("ImageLabel") then e.im = d.ImageTransparency end
            if d:IsA("UIStroke") then e.st = d.Transparency end
            if e.bg or e.tx or e.im or e.st then table.insert(fadeList, e) end
        end
    end
    for _, e in ipairs(fadeList) do
        if e.bg then e.o.BackgroundTransparency = 1 end
        if e.tx then e.o.TextTransparency = 1 end
        if e.im then e.o.ImageTransparency = 1 end
        if e.st then e.o.Transparency = 1 end
    end
    task.delay(0.05, function()
        for _, e in ipairs(fadeList) do
            local props = {}
            if e.bg then props.BackgroundTransparency = e.bg end
            if e.tx then props.TextTransparency = e.tx end
            if e.im then props.ImageTransparency = e.im end
            if e.st then props.Transparency = e.st end
            if next(props) then
                TweenService:Create(e.o, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
            end
        end
    end)

    -- // SetOpen
    function Base:SetOpen(bool)
        Library:SetOpen(bool)
    end

    Base.Elements = {
        Main = Main, Title = Title, Middle = Middle,
        PageHolder = PagesFrame, SectionHolder = SectionsFrame
    }
    Base.ScreenGui = ScreenGui
    Base.FloatBtn = FloatBtn
    return setmetatable(Base, Library)
end

function Library:SetOpen(bool)
    if typeof(bool) ~= 'boolean' then return end
    Library.Open = bool
    if bool then Library.Holder.Visible = true end
    for _, v in next, Library.Instances do
        if v:IsA("Frame") or v:IsA("TextButton") then
            if v.BackgroundTransparency ~= 1 then
                task.spawn(function()
                    local t = TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {BackgroundTransparency = bool and 0 or 0.95})
                    t.Completed:Connect(function()
                        if bool == false then Library.Holder.Visible = false end
                    end)
                    t:Play()
                end)
            end
        elseif v:IsA("TextLabel") or v:IsA("TextBox") then
            if v.TextTransparency ~= 1 and v.BackgroundTransparency == 1 then
                task.spawn(function()
                    TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {TextTransparency = bool and 0 or 0.95}):Play()
                end)
            end
        elseif v:IsA("UIStroke") then
            task.spawn(function()
                TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Transparency = bool and 0 or 0.95}):Play()
            end)
        elseif v:IsA("ImageButton") then
            task.spawn(function()
                TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {ImageTransparency = bool and 0 or 0.95, BackgroundTransparency = bool and 0 or 0.95}):Play()
            end)
        end
    end
    task.spawn(function()
        TweenService:Create(Library.PageHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = bool and UDim2.new(0, 60, 0, 0) or UDim2.new(0, 0, 0, 0)}):Play()
        if bool then task.wait(0.05) end
        TweenService:Create(Library.Gradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = bool and UDim2.new(0.5, 0, 0, 2) or UDim2.new(1, 0, 0, 2)}):Play()
        TweenService:Create(Library.Gradient, TweenInfo.new(0.25, Enum.EasingStyle.Quint, bool and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Size = bool and UDim2.new(0.5, 0, 0, 1) or UDim2.new(0, 0, 0, 1)}):Play()
    end)
end

function Library:Page(Options)
    local Page = {
        Window = self;
        Open = false;
        Sections = {};
        Elements = {};
        Title = Options.Name or "legit"
    }

    local Holder = Instance.new('TextButton', Page.Window.Elements.PageHolder)
    local Button = Instance.new('Frame', Holder)
    local TopLine = Instance.new('Frame', Button)
    local Line = Instance.new('Frame', Button)
    local Left = Instance.new('Frame', Button)
    local Right = Instance.new('Frame', Button)
    local Black = Instance.new('Frame', Button)
    local Black2 = Instance.new('Frame', Button)
    local Title = Instance.new('TextLabel', Holder)
    local PageSections = Instance.new('Frame', Page.Window.Elements.SectionHolder)
    local UIListLayout = Instance.new('UIListLayout', PageSections)
    local SectionHolder = Instance.new('Frame', Page.Window.Elements.Middle)

    table.insert(Library.Instances, Button)
    table.insert(Library.Instances, TopLine)
    table.insert(Library.Instances, Line)
    table.insert(Library.Instances, Title)
    table.insert(Library.Instances, Left)
    table.insert(Library.Instances, Right)
    table.insert(Library.Instances, Black)
    table.insert(Library.Instances, Black2)
    table.insert(Library.ThemeObjects, TopLine)
    table.insert(Library.ThemeObjects, Left)
    table.insert(Library.ThemeObjects, Right)

    Holder.Name = "Page"
    Holder.Size = UDim2.new(0, 50, 1, 0)
    Holder.BackgroundTransparency = 1
    Holder.Text = ""
    Holder.AutoButtonColor = false
    Holder.ZIndex = 53

    Button.Name = "Button"
    Button.Position = UDim2.new(0, 0, 0, 3)
    Button.Size = UDim2.new(1, 0, 1, -2)
    Button.BackgroundColor3 = Library.COLOR_INLINE
    Button.BorderColor3 = Library.COLOR_LINE
    Button.ZIndex = 53
    Button.Visible = false

    TopLine.Name = "TopLine"
    TopLine.Position = UDim2.new(0, 3, 0, 0)
    TopLine.Size = UDim2.new(1, -5, 0, 1)
    TopLine.BackgroundColor3 = Library.Accent
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 53

    Line.Name = "Line"
    Line.Position = UDim2.new(0, 0, 1, 0)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.BackgroundColor3 = Library.COLOR_INLINE
    Line.BorderSizePixel = 0
    Line.ZIndex = 53

    Left.Name = "Left"
    Left.Position = UDim2.new(0, -1, 0, 2)
    Left.Size = UDim2.new(0, 5, 0, 1)
    Left.BackgroundColor3 = Library.Accent
    Left.BorderSizePixel = 0
    Left.Rotation = -45
    Left.ZIndex = 53

    Right.Name = "Right"
    Right.Position = UDim2.new(1, -4, 0, 2)
    Right.Size = UDim2.new(0, 5, 0, 1)
    Right.BackgroundColor3 = Library.Accent
    Right.BorderSizePixel = 0
    Right.Rotation = 45
    Right.ZIndex = 53

    Black.Name = "Black"
    Black.Position = UDim2.new(0, -5, 0, -2)
    Black.Size = UDim2.new(0, 7, 0, 6)
    Black.BackgroundColor3 = Library.COLOR_INLINE
    Black.BorderSizePixel = 0
    Black.Rotation = -45
    Black.ZIndex = 55

    Black2.Name = "Black2"
    Black2.Position = UDim2.new(1, -2, 0, -2)
    Black2.Size = UDim2.new(0, 7, 0, 6)
    Black2.BackgroundColor3 = Library.COLOR_INLINE
    Black2.BorderSizePixel = 0
    Black2.Rotation = 45
    Black2.ZIndex = 55

    Title.Name = "Title"
    Title.Position = UDim2.new(0, 0, 0, 2)
    Title.Size = UDim2.new(1, 0, 1, -2)
    Title.BackgroundTransparency = 1
    Title.Text = Page.Title
    Title.TextColor3 = Library.COLOR_TEXT_DIM
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
    Title.ZIndex = 53
    Title.RichText = true

    PageSections.Name = "PageSections"
    PageSections.Position = UDim2.new(0, 8, 0, 10)
    PageSections.Size = UDim2.new(1, -16, 1, -20)
    PageSections.BackgroundTransparency = 1
    PageSections.Visible = false
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 3)

    SectionHolder.Name = "SectionHolder"
    SectionHolder.Position = UDim2.new(0, 133, 0, 13)
    SectionHolder.Size = UDim2.new(1, -144, 1, -26)
    SectionHolder.BackgroundTransparency = 1
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
            Title.TextColor3 = Library.COLOR_TEXT_DIM
        end
        SectionHolder.Visible = Page.Open
    end

    Holder.MouseButton1Click:Connect(function()
        if not Page.Open then
            Page:Turn(true)
            for _, other_page in pairs(Page.Window.Pages) do
                if other_page.Open and other_page ~= Page then
                    other_page:Turn(false)
                end
            end
        end
    end)

    if #Page.Window.Pages == 0 then Page:Turn(true) end

    task.defer(function()
        Holder.Size = UDim2.new(0, Title.TextBounds.X + 16, 1, 0)
    end)

    Page.Elements = {ButtonHolder = PageSections, RealHold = SectionHolder}
    Page.Window.Pages[#Page.Window.Pages + 1] = Page
    return setmetatable(Page, Library.Pages)
end

function Pages:Section(Options)
    local Section = {
        Window = self.Window,
        Page = self,
        Open = false,
        Elements = {},
        Title = Options.Name or "aimbot",
        LeftName = Options.LeftTitle or "general",
        RightName = Options.RightTitle or "general",
    }

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

    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 0, 22)
    Button.BackgroundTransparency = 1
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
        ColorSequenceKeypoint.new(0, Color3.new(0.741, 0.741, 0.741)),
        ColorSequenceKeypoint.new(1, Color3.new(0.204, 0.204, 0.204))
    }
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0.5)
    }

    Title.Name = "Title"
    Title.Position = UDim2.new(0, 4, 0, 0)
    Title.Size = UDim2.new(1, -4, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = Options.Name
    Title.TextColor3 = Library.COLOR_TEXT_DIM
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
    Title.ZIndex = 54
    Title.TextXAlignment = Enum.TextXAlignment.Left

    NewSection.Name = "NewSection"
    NewSection.Size = UDim2.new(1, 0, 1, 0)
    NewSection.BackgroundTransparency = 1
    NewSection.Visible = false

    Left.Name = "Left"
    Left.Position = UDim2.new(0, 2, 0, 0)
    Left.Size = UDim2.new(0.5, -10, 1, 0)
    Left.BackgroundColor3 = Library.COLOR_INLINE
    Left.BorderColor3 = Library.COLOR_LINE
    Left.BorderSizePixel = 1
    Instance.new('UICorner', Left).CornerRadius = UDim.new(0, 3)

    Bar.Name = "Bar"
    Bar.Size = UDim2.new(1, 0, 0, 20)
    Bar.BackgroundColor3 = Library.COLOR_INLINE
    Bar.BorderColor3 = Library.COLOR_LINE

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    GradientLine.Name = "GradientLine"
    GradientLine.Position = UDim2.new(0, 0, 1, 0)
    GradientLine.Size = UDim2.new(1, 0, 0, 1)
    GradientLine.BackgroundColor3 = Color3.new(1, 1, 1)
    GradientLine.BorderSizePixel = 0
    UIGradient3.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Library.COLOR_LINE),
        ColorSequenceKeypoint.new(0.48, Library.COLOR_INLINE),
        ColorSequenceKeypoint.new(1, Library.COLOR_LINE)
    }

    LeftTitle.Name = "LeftTitle"
    LeftTitle.Position = UDim2.new(0, 4, 0, 0)
    LeftTitle.Size = UDim2.new(1, -4, 1, 0)
    LeftTitle.BackgroundTransparency = 1
    LeftTitle.Text = Section.LeftName
    LeftTitle.TextColor3 = Color3.fromRGB(120, 120, 120)
    LeftTitle.FontFace = Library.UIFont
    LeftTitle.TextSize = Library.FontSize
    LeftTitle.TextXAlignment = Enum.TextXAlignment.Left

    Right.Name = "Right"
    Right.Position = UDim2.new(0.5, 8, 0, 0)
    Right.Size = UDim2.new(0.5, -10, 1, 0)
    Right.BackgroundColor3 = Library.COLOR_INLINE
    Right.BorderColor3 = Library.COLOR_LINE
    Right.BorderSizePixel = 1
    Instance.new('UICorner', Right).CornerRadius = UDim.new(0, 3)

    Bar2.Name = "Bar2"
    Bar2.Size = UDim2.new(1, 0, 0, 20)
    Bar2.BackgroundColor3 = Library.COLOR_INLINE
    Bar2.BorderColor3 = Library.COLOR_LINE

    Gradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient2.Rotation = -90

    GradientLine2.Name = "GradientLine2"
    GradientLine2.Position = UDim2.new(0, 0, 1, 0)
    GradientLine2.Size = UDim2.new(1, 0, 0, 1)
    GradientLine2.BackgroundColor3 = Color3.new(1, 1, 1)
    GradientLine2.BorderSizePixel = 0
    UIGradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Library.COLOR_LINE),
        ColorSequenceKeypoint.new(0.48, Library.COLOR_INLINE),
        ColorSequenceKeypoint.new(1, Library.COLOR_LINE)
    }

    RightTitle.Name = "RightTitle"
    RightTitle.Position = UDim2.new(0, 4, 0, 0)
    RightTitle.Size = UDim2.new(1, -4, 1, 0)
    RightTitle.BackgroundTransparency = 1
    RightTitle.Text = Section.RightName
    RightTitle.TextColor3 = Color3.fromRGB(120, 120, 120)
    RightTitle.FontFace = Library.UIFont
    RightTitle.TextSize = Library.FontSize
    RightTitle.TextXAlignment = Enum.TextXAlignment.Left

    LeftContent.Name = "LeftContent"
    LeftContent.Position = UDim2.new(0, 10, 0, 30)
    LeftContent.Size = UDim2.new(1, -20, 1, -40)
    LeftContent.BackgroundTransparency = 1
    LeftUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftUIListLayout.Padding = UDim.new(0, 4)

    RightConnect.Name = "RightConnect"
    RightConnect.Position = UDim2.new(0, 10, 0, 30)
    RightConnect.Size = UDim2.new(1, -20, 1, -40)
    RightConnect.BackgroundTransparency = 1
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
            Title.TextColor3 = Library.COLOR_TEXT_DIM
        end
        Accent.BackgroundTransparency = Section.Open and 0 or 0.5
    end

    Button.MouseButton1Click:Connect(function()
        if not Section.Open then
            Section:Turn(true)
            for _, other_sec in pairs(Section.Page.Sections) do
                if other_sec.Open and other_sec ~= Section then
                    other_sec:Turn(false)
                end
            end
        end
    end)

    if #Section.Page.Sections == 0 then Section:Turn(true) end

    Section.Elements = {Left = LeftContent, Right = RightConnect}
    Section.Page.Sections[#Section.Page.Sections + 1] = Section
    return setmetatable(Section, Library.Sections)
end

-- ═══════════════════════════════════════════════════════════
-- ELEMENTS
-- ═══════════════════════════════════════════════════════════

function Sections:Toggle(Options)
    local Properties = Options or {}
    local Toggle = {
        Window = self.Window, Page = self.Page, Section = self,
        State = (Properties.state or Properties.State or false),
        Callback = (Properties.callback or function() end),
        Flag = (Properties.flag or Library.NextFlag()),
        Toggled = false, Colorpickers = 0,
    }

    local Holder = Instance.new('TextButton', Options.Side == "Left" and Toggle.Section.Elements.Left or Toggle.Section.Elements.Right)
    local Frame = Instance.new('Frame', Holder)
    local Accent = Instance.new('Frame', Frame)
    local Gradient = Instance.new('UIGradient', Accent)
    local TextLabel = Instance.new('TextLabel', Holder)

    table.insert(Library.Instances, Frame)
    table.insert(Library.Instances, Accent)
    table.insert(Library.Instances, TextLabel)
    table.insert(Library.ThemeObjects, Accent)

    Holder.Name = "Toggle"
    Holder.Size = UDim2.new(1, 0, 0, 14)
    Holder.BackgroundTransparency = 1
    Holder.Text = ""
    Holder.AutoButtonColor = false

    Frame.Position = UDim2.new(0, 0, 0, 4)
    Frame.Size = UDim2.new(0, 8, 0, 8)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.new(0, 0, 0)
    Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 2)

    Accent.Name = "Accent"
    Accent.Size = UDim2.new(1, 0, 1, 0)
    Accent.BackgroundColor3 = Library.Accent
    Accent.BorderSizePixel = 0
    Accent.Visible = false
    Instance.new('UICorner', Accent).CornerRadius = UDim.new(0, 2)

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    TextLabel.Position = UDim2.new(0, 18, 0, 0)
    TextLabel.Size = UDim2.new(1, -18, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Library.COLOR_TEXT_DIM
    TextLabel.FontFace = Library.UIFont
    TextLabel.TextSize = Library.FontSize
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Text = Options.Name or "toggle"

    local function SetState()
        Toggle.Toggled = not Toggle.Toggled
        if Toggle.Toggled then
            Accent.Visible = true
            TextLabel.TextColor3 = Color3.new(1, 1, 1)
        else
            Accent.Visible = false
            TextLabel.TextColor3 = Library.COLOR_TEXT_DIM
        end
        Library.Flags[Toggle.Flag] = Toggle.Toggled
        Toggle.Callback(Toggle.Toggled)
    end

    function Toggle:Keybind(Options)
        local Properties = Options or {}
        local Keybind = {
            State = Properties.state or nil,
            Mode = Properties.mode or "Toggle",
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
            Binding = nil, Connection = nil,
        }
        local Key, State = nil, false
        local Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3

        local KeyHolder = Instance.new('TextButton', Holder)
        local Value = Instance.new('TextLabel', Holder)
        local Mode = Instance.new('TextLabel', Holder)

        table.insert(Library.Instances, Value)
        table.insert(Library.Instances, Mode)

        KeyHolder.Size = UDim2.new(0, 40, 0, 14)
        KeyHolder.BackgroundTransparency = 1
        KeyHolder.Text = ""
        KeyHolder.AutoButtonColor = false
        KeyHolder.Position = UDim2.new(1, -45, 0, 0)

        Value.Position = UDim2.new(0, 15, 0, 0)
        Value.Size = UDim2.new(1, -30, 1, 0)
        Value.BackgroundTransparency = 1
        Value.Text = "[-]"
        Value.TextColor3 = Library.COLOR_TEXT_DIM
        Value.FontFace = Library.UIFont
        Value.TextSize = Library.FontSize
        Value.TextXAlignment = Enum.TextXAlignment.Right

        Mode.Position = UDim2.new(0, TextLabel.TextBounds.X + 20, 0, 0)
        Mode.Size = UDim2.new(1, -30, 1, 0)
        Mode.BackgroundTransparency = 1
        Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
        Mode.TextColor3 = Library.Accent
        Mode.FontFace = Library.UIFont
        Mode.TextSize = Library.FontSize
        Mode.TextXAlignment = Enum.TextXAlignment.Left

        -- // Register in Keybind List
        local kbItem = KeybindList:Add(Options.Name or "keybind", Keybind.State, Keybind.Mode, false, Keybind.Callback)

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
                    local text = Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", "")
                    Value.Text = "[" .. text .. "]"
                    kbItem:SetKey(newkey)
                end
                Library.Flags[Keybind.Flag .. "_KEY"] = newkey
            elseif table.find({"Always", "Toggle", "Hold"}, newkey) then
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
                Keybind.Binding = Library:Connection(UserInputService.InputBegan, function(input, gpe)
                    set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                    Library:Disconnect(Keybind.Binding)
                    task.wait()
                    Keybind.Binding = nil
                end)
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
            if Keybind.Mode == "Hold" and Key ~= nil then
                if inp.KeyCode == Key or inp.UserInputType == Key then
                    if Keybind.Connection then
                        Keybind.Connection:Disconnect()
                        if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                        if Keybind.Callback then Keybind.Callback(false) end
                    end
                end
            end
        end)

        Holder.MouseButton2Click:Connect(function()
            Cycle = Cycle + 1
            if Cycle > 3 then Cycle = 1 end
            if Cycle == 1 then set("Hold")
            elseif Cycle == 2 then set("Toggle")
            elseif Cycle == 3 then set("Always") end
        end)

        Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
        Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
        Flags[Keybind.Flag] = set
        Flags[Keybind.Flag .. "_KEY"] = set
        Flags[Keybind.Flag .. "_KEY STATE"] = set

        function Keybind:Set(key) set(key) end
        return Keybind
    end

    function Toggle:Colorpicker(Properties)
        Properties = Properties or {}
        local Colorpicker = {
            State = Properties.state or Color3.fromRGB(255, 0, 0),
            Alpha = Properties.alpha or 1,
            Callback = Properties.callback or function() end,
            Flag = Properties.flag or Library.NextFlag(),
        }
        Toggle.Colorpickers = Toggle.Colorpickers + 1
        local colorpickertypes = Library:NewPicker(
            Colorpicker.State, Colorpicker.Alpha, Holder,
            Toggle.Colorpickers - 1, Colorpicker.Flag, Colorpicker.Callback
        )
        function Colorpicker:Set(color) colorpickertypes:set(color, false, true) end
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
    local Properties = Options or {}
    local Slider = {
        Window = self.Window, Page = self.Page, Section = self,
        Name = Properties.Name or nil,
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

    table.insert(Library.Instances, Frame)
    table.insert(Library.Instances, Accent)
    table.insert(Library.Instances, Title)
    table.insert(Library.Instances, plus)
    table.insert(Library.Instances, minus)
    table.insert(Library.Instances, Value)
    table.insert(Library.ThemeObjects, Accent)

    Holder.Size = Slider.Name and UDim2.new(1, 0, 0, 28) or UDim2.new(1, 0, 0, 12)
    Holder.BackgroundTransparency = 1

    Frame.Position = Slider.Name and UDim2.new(0, 15, 0, 18) or UDim2.new(0, 15, 0, 3)
    Frame.Size = UDim2.new(1, -30, 0, 6)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.new(0, 0, 0)
    Frame.AutoButtonColor = false
    Frame.Text = ""
    Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 3)

    Accent.Name = "Accent"
    Accent.Size = UDim2.new(0, 0, 1, 0)
    Accent.BackgroundColor3 = Library.Accent
    Accent.BorderSizePixel = 0
    Accent.AutoButtonColor = false
    Accent.Text = ""
    Instance.new('UICorner', Accent).CornerRadius = UDim.new(0, 3)

    Gradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient2.Rotation = -90
    Gradient.Color = Gradient2.Color
    Gradient.Rotation = -90

    if Slider.Name then
        Title.Visible = true
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.Size = UDim2.new(1, 0, 0, 14)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Library.COLOR_TEXT_DIM
        Title.FontFace = Library.UIFont
        Title.TextSize = Library.FontSize
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Text = Slider.Name
    end

    plus.Position = Slider.Name and UDim2.new(1, -7, 0, 15) or UDim2.new(1, -7, 0, 0)
    plus.Size = UDim2.new(0, 8, 0, 8)
    plus.BackgroundTransparency = 1
    plus.Text = "+"
    plus.TextColor3 = Library.COLOR_TEXT_DIM
    plus.FontFace = Library.UIFont
    plus.TextSize = Library.FontSize

    minus.Position = Slider.Name and UDim2.new(0, -1, 0, 15) or UDim2.new(0, -1, 0, 0)
    minus.Size = UDim2.new(0, 8, 0, 8)
    minus.BackgroundTransparency = 1
    minus.Text = "-"
    minus.TextColor3 = Library.COLOR_TEXT_DIM
    minus.FontFace = Library.UIFont
    minus.TextSize = Library.FontSize

    Value.Position = Slider.Name and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, -1)
    Value.Size = Slider.Name and UDim2.new(1, -30, 0, 14) or UDim2.new(1, 0, 1, 0)
    Value.BackgroundTransparency = 1
    Value.Text = "50%"
    Value.TextColor3 = Library.COLOR_TEXT_DIM
    Value.FontFace = Library.UIFont
    Value.TextSize = Library.FontSize
    Value.TextXAlignment = Slider.Name and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center

    local Sliding = false
    local Val = Slider.State

    local function Set(value)
        value = math.clamp(Library:Round(value, Slider.Decimals), Slider.Min, Slider.Max)
        Value.TextColor3 = value == Slider.Min and Library.COLOR_TEXT_DIM or Color3.new(1, 1, 1)
        if Slider.Name then Title.TextColor3 = Value.TextColor3 end
        Value.Text = TextValue:gsub("%[value%]", string.format("%.14g", value))
        Val = value
        local sizeX = (value - Slider.Min) / (Slider.Max - Slider.Min)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true Slide(input) end
    end)
    Library:Connection(Frame.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
    end)
    Library:Connection(Accent.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true Slide(input) end
    end)
    Library:Connection(Accent.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
    end)
    Library:Connection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then Slide(input) end
    end)
    Library:Connection(plus.MouseButton1Click, function() Set(Val + 1) end)
    Library:Connection(minus.MouseButton1Click, function() Set(Val - 1) end)

    function Slider:Set(Value) Set(Value) end
    Flags[Slider.Flag] = Set
    return Slider
end

function Sections:List(Options)
    local Properties = Options or {}
    local Dropdown = {
        Window = self.Window, Page = self.Page, Section = self,
        Open = false,
        Name = Properties.Name or nil,
        Options = Properties.options or {"1", "2", "3"},
        State = Properties.state or nil,
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

    table.insert(Library.Instances, Frame)
    table.insert(Library.Instances, Value)
    table.insert(Library.Instances, Icon)
    table.insert(Library.Instances, Content)
    table.insert(Library.Instances, Title)
    table.insert(Dropdowns, Content)

    Holder.Size = UDim2.new(1, 0, 0, 34)
    Holder.BackgroundTransparency = 1

    Frame.Position = UDim2.new(0, 15, 0, 16)
    Frame.Size = UDim2.new(1, -30, 0, 18)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.new(0, 0, 0)
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 3)

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    Value.Position = UDim2.new(0, 4, 0, 0)
    Value.Size = UDim2.new(1, -20, 1, 0)
    Value.BackgroundTransparency = 1
    Value.Text = ""
    Value.TextColor3 = Library.COLOR_TEXT_DIM
    Value.FontFace = Library.UIFont
    Value.TextSize = Library.FontSize
    Value.TextXAlignment = Enum.TextXAlignment.Left
    Value.ClipsDescendants = true

    Icon.Position = UDim2.new(1, -14, 0, 0)
    Icon.Size = UDim2.new(0, 14, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "▼"
    Icon.TextColor3 = Library.COLOR_TEXT_DIM
    Icon.FontFace = Library.UIFont
    Icon.TextSize = 10
    Icon.TextXAlignment = Enum.TextXAlignment.Right

    Content.Position = UDim2.new(0, 0, 0, 20)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Content.BorderColor3 = Color3.new(0, 0, 0)
    Content.Visible = false
    Content.ZIndex = 110
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new('UICorner', Content).CornerRadius = UDim.new(0, 3)

    Gradient2.Color = Gradient.Color
    Gradient2.Rotation = -90
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 14)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Library.COLOR_TEXT_DIM
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
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
                if opt ~= option then tbl.text.TextColor3 = Library.COLOR_TEXT_DIM end
            end
            Chosen = option
            Value.Text = option
            text.TextColor3 = Color3.new(1, 1, 1)
            Library.Flags[Dropdown.Flag] = option
            Dropdown.Callback(option)
        end)
    end

    local function createoptions(tbl)
        for _, option in next, tbl do
            Dropdown.OptionInsts[option] = {}
            local Option = Instance.new('TextButton', Content)
            local OptionName = Instance.new('TextLabel', Option)
            Option.Size = UDim2.new(1, 0, 0, 18)
            Option.BackgroundTransparency = 1
            Option.Text = ""
            Option.AutoButtonColor = false
            Dropdown.OptionInsts[option].button = Option
            Option.ZIndex = 111

            OptionName.Position = UDim2.new(0, 4, 0, 0)
            OptionName.Size = UDim2.new(1, 0, 1, 0)
            OptionName.BackgroundTransparency = 1
            OptionName.Text = option
            OptionName.TextColor3 = Library.COLOR_TEXT_DIM
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
            if opt ~= option then tbl.text.TextColor3 = Library.COLOR_TEXT_DIM end
        end
        if table.find(Dropdown.Options, option) then
            Chosen = option
            Value.Text = option
            Dropdown.OptionInsts[option].text.TextColor3 = Color3.new(1, 1, 1)
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
    local Properties = Options or {}
    local Dropdown = {
        Window = self.Window, Page = self.Page, Section = self,
        Open = false,
        Name = Properties.Name or nil,
        Options = Properties.options or {"1", "2", "3"},
        State = Properties.state or nil,
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
    local UIListLayout = Instance.new('UIListLayout', Content)
    local Title = Instance.new('TextLabel', Holder)

    table.insert(Library.Instances, Frame)
    table.insert(Library.Instances, Value)
    table.insert(Library.Instances, Icon)
    table.insert(Library.Instances, Content)
    table.insert(Library.Instances, Title)
    table.insert(Dropdowns, Content)

    Holder.Size = UDim2.new(1, 0, 0, 34)
    Holder.BackgroundTransparency = 1

    Frame.Position = UDim2.new(0, 15, 0, 16)
    Frame.Size = UDim2.new(1, -30, 0, 18)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.new(0, 0, 0)
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 3)

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    Value.Position = UDim2.new(0, 4, 0, 0)
    Value.Size = UDim2.new(1, -20, 1, 0)
    Value.BackgroundTransparency = 1
    Value.Text = ""
    Value.TextColor3 = Library.COLOR_TEXT_DIM
    Value.FontFace = Library.UIFont
    Value.TextTruncate = Enum.TextTruncate.SplitWord
    Value.TextSize = Library.FontSize
    Value.TextXAlignment = Enum.TextXAlignment.Left
    Value.ClipsDescendants = true

    Icon.Position = UDim2.new(1, -14, 0, 0)
    Icon.Size = UDim2.new(0, 14, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "▼"
    Icon.TextColor3 = Library.COLOR_TEXT_DIM
    Icon.FontFace = Library.UIFont
    Icon.TextSize = 10
    Icon.TextXAlignment = Enum.TextXAlignment.Right

    Content.Position = UDim2.new(0, 0, 0, 20)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Content.BorderColor3 = Color3.new(0, 0, 0)
    Content.Visible = false
    Content.ZIndex = 110
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new('UICorner', Content).CornerRadius = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 14)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Library.COLOR_TEXT_DIM
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
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
                text.TextColor3 = Library.COLOR_TEXT_DIM
            else
                if #chosen == Dropdown.Max then
                    Dropdown.OptionInsts[chosen[1]].text.TextColor3 = Library.COLOR_TEXT_DIM
                    table.remove(chosen, 1)
                end
                table.insert(chosen, option)
                text.TextColor3 = Color3.new(1, 1, 1)
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
            Option.Size = UDim2.new(1, 0, 0, 18)
            Option.BackgroundTransparency = 1
            Option.Text = ""
            Option.AutoButtonColor = false
            Dropdown.OptionInsts[option].button = Option
            Option.ZIndex = 111
            OptionName.Position = UDim2.new(0, 4, 0, 0)
            OptionName.Size = UDim2.new(1, 0, 1, 0)
            OptionName.BackgroundTransparency = 1
            OptionName.Text = option
            OptionName.TextColor3 = Library.COLOR_TEXT_DIM
            OptionName.FontFace = Library.UIFont
            OptionName.TextSize = Library.FontSize
            OptionName.TextXAlignment = Enum.TextXAlignment.Left
            Dropdown.OptionInsts[option].text = OptionName
            OptionName.ZIndex = 111
            handleoptionclick(option, Option, OptionName)
        end
    end
    createoptions(Dropdown.Options)

    local function set(option)
        table.clear(chosen)
        option = type(option) == "table" and option or {}
        for opt, tbl in next, Dropdown.OptionInsts do
            if not table.find(option, opt) then tbl.text.TextColor3 = Library.COLOR_TEXT_DIM end
        end
        for _, opt in next, option do
            if table.find(Dropdown.Options, opt) and #chosen < Dropdown.Max then
                table.insert(chosen, opt)
                Dropdown.OptionInsts[opt].text.TextColor3 = Color3.new(1, 1, 1)
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
    local Properties = Options or {}
    local Keybind = {
        Section = self,
        Name = Properties.Name or "Keybind",
        State = Properties.state or nil,
        Mode = Properties.mode or "Toggle",
        Callback = Properties.callback or function() end,
        Flag = Properties.flag or Library.NextFlag(),
        Binding = nil, Connection = nil,
    }
    local Key, State = nil, false
    local Cycle = Keybind.Mode == "Hold" and 1 or Keybind.Mode == "Toggle" and 2 or 3

    local Holder = Instance.new('TextButton', Options.Side == "Left" and Keybind.Section.Elements.Left or Keybind.Section.Elements.Right)
    local Title = Instance.new('TextLabel', Holder)
    local Value = Instance.new('TextLabel', Holder)
    local Mode = Instance.new('TextLabel', Holder)

    table.insert(Library.Instances, Title)
    table.insert(Library.Instances, Value)
    table.insert(Library.Instances, Mode)

    Holder.Size = UDim2.new(1, 0, 0, 14)
    Holder.BackgroundTransparency = 1
    Holder.Text = ""
    Holder.AutoButtonColor = false

    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Library.COLOR_TEXT_DIM
    Title.FontFace = Library.UIFont
    Title.TextSize = Library.FontSize
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = Keybind.Name

    Value.Position = UDim2.new(0, 15, 0, 0)
    Value.Size = UDim2.new(1, -30, 1, 0)
    Value.BackgroundTransparency = 1
    Value.Text = "[-]"
    Value.TextColor3 = Library.COLOR_TEXT_DIM
    Value.FontFace = Library.UIFont
    Value.TextSize = Library.FontSize
    Value.TextXAlignment = Enum.TextXAlignment.Right

    Mode.Position = UDim2.new(0, Title.TextBounds.X + 20, 0, 0)
    Mode.Size = UDim2.new(1, -30, 1, 0)
    Mode.BackgroundTransparency = 1
    Mode.Text = Keybind.Mode == "Hold" and "[H]" or Keybind.Mode == "Toggle" and "[T]" or "[A]"
    Mode.TextColor3 = Library.Accent
    Mode.FontFace = Library.UIFont
    Mode.TextSize = Library.FontSize
    Mode.TextXAlignment = Enum.TextXAlignment.Left

    -- // Register in Keybind List
    local kbItem = KeybindList:Add(Keybind.Name, Keybind.State, Keybind.Mode, false, Keybind.Callback)

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
                local text = Library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", "")
                Value.Text = "[" .. text .. "]"
                kbItem:SetKey(newkey)
            end
            Library.Flags[Keybind.Flag .. "_KEY"] = newkey
        elseif table.find({"Always", "Toggle", "Hold"}, newkey) then
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
            Keybind.Binding = Library:Connection(UserInputService.InputBegan, function(input, gpe)
                set(input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType)
                Library:Disconnect(Keybind.Binding)
                task.wait()
                Keybind.Binding = nil
            end)
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
        if Keybind.Mode == "Hold" and Key ~= nil then
            if inp.KeyCode == Key or inp.UserInputType == Key then
                if Keybind.Connection then
                    Keybind.Connection:Disconnect()
                    if Keybind.Flag then Library.Flags[Keybind.Flag] = false end
                    if Keybind.Callback then Keybind.Callback(false) end
                end
            end
        end
    end)

    Holder.MouseButton2Click:Connect(function()
        Cycle = Cycle + 1
        if Cycle > 3 then Cycle = 1 end
        if Cycle == 1 then set("Hold")
        elseif Cycle == 2 then set("Toggle")
        elseif Cycle == 3 then set("Always") end
    end)

    Library.Flags[Keybind.Flag .. "_KEY"] = Keybind.State
    Library.Flags[Keybind.Flag .. "_KEY STATE"] = Keybind.Mode
    Flags[Keybind.Flag] = set
    Flags[Keybind.Flag .. "_KEY"] = set
    Flags[Keybind.Flag .. "_KEY STATE"] = set

    function Keybind:Set(key) set(key) end
    task.defer(function()
        Mode.Position = UDim2.new(0, Title.TextBounds.X + 20, 0, 0)
    end)
    return Keybind
end

function Sections:Textbox(Options)
    local Properties = Options or {}
    local Textbox = {
        Window = self.Window, Page = self.Page, Section = self,
        Placeholder = Properties.placeholder or "",
        State = Properties.state or "",
        Callback = Properties.callback or function() end,
        Flag = Properties.flag or Library.NextFlag(),
    }

    local Holder = Instance.new('Frame', Options.Side == "Left" and Textbox.Section.Elements.Left or Textbox.Section.Elements.Right)
    local TextFrame = Instance.new('Frame', Holder)
    local Gradient = Instance.new('UIGradient', TextFrame)
    local TextBox = Instance.new('TextBox', TextFrame)

    table.insert(Library.Instances, TextFrame)
    table.insert(Library.Instances, TextBox)

    Holder.Size = UDim2.new(1, 0, 0, 18)
    Holder.BackgroundTransparency = 1

    TextFrame.Position = UDim2.new(0, 15, 0, 0)
    TextFrame.Size = UDim2.new(1, -30, 1, 0)
    TextFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TextFrame.BorderColor3 = Color3.new(0, 0, 0)
    Instance.new('UICorner', TextFrame).CornerRadius = UDim.new(0, 3)

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    TextBox.Size = UDim2.new(1, -8, 1, 0)
    TextBox.Position = UDim2.new(0, 4, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = Textbox.State
    TextBox.TextColor3 = Color3.new(1, 1, 1)
    TextBox.FontFace = Library.UIFont
    TextBox.TextSize = Library.FontSize
    TextBox.PlaceholderText = Textbox.Placeholder
    TextBox.PlaceholderColor3 = Library.COLOR_TEXT_DIM
    TextBox.ClearTextOnFocus = false
    TextBox.TextWrapped = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left

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
        Window = self.Window, Page = self.Page, Section = self,
        Name = Properties.Name or "button",
        Callback = Properties.callback or function() end,
    }

    local Holder = Instance.new('Frame', Options.Side == "Left" and Button.Section.Elements.Left or Button.Section.Elements.Right)
    local TextFrame = Instance.new('Frame', Holder)
    local Gradient = Instance.new('UIGradient', TextFrame)
    local Textbutton = Instance.new('TextButton', TextFrame)

    table.insert(Library.Instances, TextFrame)
    table.insert(Library.Instances, Textbutton)

    Holder.Size = UDim2.new(1, 0, 0, 22)
    Holder.BackgroundTransparency = 1

    TextFrame.Position = UDim2.new(0, 15, 0, 0)
    TextFrame.Size = UDim2.new(1, -30, 1, 0)
    TextFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TextFrame.BorderColor3 = Color3.new(0, 0, 0)
    Instance.new('UICorner', TextFrame).CornerRadius = UDim.new(0, 3)

    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.78, 0.75, 0.8)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    Gradient.Rotation = -90

    Textbutton.Size = UDim2.new(1, 0, 1, 0)
    Textbutton.BackgroundTransparency = 1
    Textbutton.Text = Button.Name
    Textbutton.TextColor3 = Library.COLOR_TEXT_DIM
    Textbutton.FontFace = Library.UIFont
    Textbutton.TextSize = Library.FontSize
    Instance.new('UICorner', Textbutton).CornerRadius = UDim.new(0, 3)

    Textbutton.MouseButton1Click:Connect(function()
        Button.Callback()
    end)
    Textbutton.MouseButton1Down:Connect(function()
        Textbutton.TextColor3 = Library.Accent
        TweenService:Create(TextFrame, TweenInfo.new(0.15), {BackgroundColor3 = Library.Accent}):Play()
    end)
    Textbutton.MouseButton1Up:Connect(function()
        Textbutton.TextColor3 = Library.COLOR_TEXT_DIM
        TweenService:Create(TextFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    end)
    return Button
end

function Sections:Colorpicker(Options)
    local Properties = Options or {}
    local Colorpicker = {
        Window = self.Window, Page = self.Page, Section = self,
        Name = Properties.Name or "Colorpicker",
        State = Properties.state or Color3.fromRGB(255, 0, 0),
        Alpha = Properties.alpha or 1,
        Callback = Properties.callback or function() end,
        Flag = Properties.flag or Library.NextFlag(),
        Colorpickers = 0,
    }

    local Color = Instance.new('TextButton', Options.Side == "Left" and Colorpicker.Section.Elements.Left or Colorpicker.Section.Elements.Right)
    local TextLabel = Instance.new('TextLabel', Color)

    table.insert(Library.Instances, TextLabel)

    Color.Size = UDim2.new(1, 0, 0, 14)
    Color.BackgroundTransparency = 1
    Color.Text = ""
    Color.AutoButtonColor = false

    TextLabel.Position = UDim2.new(0, 15, 0, 0)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Library.COLOR_TEXT_DIM
    TextLabel.FontFace = Library.UIFont
    TextLabel.TextSize = Library.FontSize
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Text = Colorpicker.Name

    Colorpicker.Colorpickers = Colorpicker.Colorpickers + 1
    local colorpickertypes = Library:NewPicker(
        Colorpicker.State, Colorpicker.Alpha, Color,
        Colorpicker.Colorpickers - 1, Colorpicker.Flag, Colorpicker.Callback
    )
    function Colorpicker:Set(color) colorpickertypes:set(color, false, true) end
    return Colorpicker
end

-- ═══════════════════════════════════════════════════════════
-- STARTUP NOTIFICATION
-- ═══════════════════════════════════════════════════════════
task.delay(0.5, function()
    Notifications:Success("avelia", "ui library loaded successfully")
end)

end
return Library