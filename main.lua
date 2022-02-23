if (not game:IsLoaded()) then
    game.Loaded:Wait();
end

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-esp/main/ui.lua"))();

local PlaceId = game.PlaceId

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Workspace = game:GetService("Workspace");
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService");

local CurrentCamera = Workspace.CurrentCamera
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local GetPartsObscuringTarget = CurrentCamera.GetPartsObscuringTarget

local FindFirstChild = game.FindFirstChild
local IsA = game.IsA
local Vector2new = Vector2.new
local Vector3new = Vector3.new
local CFramenew = CFrame.new
local Color3new = Color3.new

local Tfind = table.find
local format = string.format
local floor = math.floor
local min = math.min
local gsub = string.gsub
local sub = string.sub
local lower = string.lower
local upper = string.upper
local random = math.random
local info = debug.info
local getupvalues = debug.getupvalues

local CallF = function(Func, Identity, ...)
    if (Func and Identity) then
        local CurrentIdentity = syn.get_thread_identity();
        syn.set_thread_identity(Identity or CurrentIdentity);
        local Ret = { Func(...); }
        syn.set_thread_identity(CurrentIdentity);
        return unpack(Ret);
    end
end

local DefaultSettings = {
    Esp = {
        NamesEnabled = true,
        DisplayNamesEnabled = false,
        DistanceEnabled = true,
        HealthEnabled = true,
        TracersEnabled = false,
        BoxEsp = false,
        TeamColors = true,
        Thickness = 1.5,
        TracerThickness = 1.6,
        Transparency = .9,
        TracerTrancparency = .7,
        Size = 16,
        RenderDistance = math.huge,
        Color = Color3.fromRGB(20, 226, 207),
        OutlineColor = Color3new(),
        TracerTo = "Head",
        BlacklistedTeams = {}
    },
    Aimbot = {
        Enabled = true,
        SilentAim = true,
        Wallbang = false,
        ShowFov = true,
        Snaplines = true,
        ThirdPerson = false,
        FirstPerson = false,
        ClosestCharacter = false,
        ClosestCursor = true,
        Smoothness = 1,
        SilentAimHitChance = 100,
        FovThickness = 1,
        FovTransparency = 1,
        FovSize = 150,
        FovColor = Color3.fromRGB(20, 226, 207),
        Aimlock = "Head",
        BlacklistedTeams = {}
    },
    WindowPosition = UDim2.new(0.5, -200, 0.5, -139);
}

local EncodeConfig, DecodeConfig;
do
    local deepsearchset;
    deepsearchset = function(tbl, ret, value)
        if (type(tbl) == 'table') then
            local new = {}
            for i, v in next, tbl do
                new[i] = v
                if (type(v) == 'table') then
                    new[i] = deepsearchset(v, ret, value);
                end
                if (ret(i, v)) then
                    new[i] = value(i, v);
                end
            end
            return new
        end
    end

    DecodeConfig = function(Config)
        local DecodedConfig = deepsearchset(Config, function(Index, Value)
            return type(Value) == "table" and (Value.HSVColor or Value.Position);
        end, function(Index, Value)
            local Color = Value.HSVColor
            local Position = Value.Position
            if (Color) then
                return Color3.fromHSV(Color.H, Color.S, Color.V);
            end
            if (Position) then
                return UDim2.new(UDim.new(Position.X.Scale, Position.X.Offset), UDim.new(Position.Y.Scale, Position.Y.Offset));
            end
        end);
        return DecodedConfig
    end

    EncodeConfig = function(Config)
        local ToHSV = Color3new().ToHSV
        local EncodedConfig = deepsearchset(Config, function(Index, Value)
            return typeof(Value) == "Color3" or typeof(Value) == "UDim2"
        end, function(Index, Value)
            local Color = typeof(Value) == "Color3"
            local Position = typeof(Value) == "UDim2"
            if (Color) then
                local H, S, V = ToHSV(Value);
                return { HSVColor = { H = H, S = S, V = V } };
            end
            if (Position) then
                return { Position = {
                    X = { Scale = Value.X.Scale, Offset = Value.X.Offset };
                    Y = { Scale = Value.Y.Scale, Offset = Value.Y.Offset }
                } };
            end
        end)
        return EncodedConfig
    end
end

local GetConfig = function()
    local Good, Config = pcall(readfile, "fates-esp-v2.json");
    if (Good) then
        local Decoded = DecodeConfig(HttpService:JSONDecode(Config));
        return Decoded
    else
        local Encoded = HttpService:JSONEncode(EncodeConfig(DefaultSettings));
        writefile("fates-esp-v2.json", Encoded);
        return DefaultSettings
    end
end

local Settings = GetConfig();

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse();
local MouseVector = Vector2new(Mouse.X, Mouse.Y);

local filtergc = filtergc or function(Type, Args)
    local Results = {}
    for Index, Value in pairs(getgc(true)) do
        if (type(Value) == Type) then
            local Keys = Args.Keys
            local Good = true
            for Index2, Value2 in pairs(Keys) do
                if (not rawget(Value, Value2)) then
                    Good = false
                    break
                end
            end
            if (Good) then
                table.insert(Results, Value);
            end
        end
    end
    return Results
end

local Characters = {}

local CustomGet = {
    [0] = function()
        return {}
    end
}

local Get;
if (CustomGet[PlaceId]) then
    Get = CustomGet[PlaceId]();
end

local GetCharacter = function(Player)
    if (Get) then
        return Get.GetCharacter(Player);
    end
    return Player.Character
end
local CharacterAdded = function(Player, Callback)
    if (Get) then
        return
    end
    Player.CharacterAdded:Connect(Callback);
end
local CharacterRemoving = function(Player, Callback)
    if (Get) then
        return
    end
    Player.CharacterRemoving:Connect(Callback);
end

local GetTeam = function(Player)
    if (Get) then
        return Get.GetTeam(Player);
    end
    return Player.Team
end

local Drawings = {}

local AimbotSettings = Settings.Aimbot
local EspSettings = Settings.Esp

local FOV = Drawing.new("Circle");
FOV.Color = AimbotSettings.FovColor
FOV.Thickness = AimbotSettings.FovThickness
FOV.Transparency = AimbotSettings.FovTransparency
FOV.Filled = false
FOV.Radius = AimbotSettings.FovSize

local Snaplines = Drawing.new("Line");
Snaplines.Color = AimbotSettings.FovColor
Snaplines.Thickness = .1
Snaplines.Transparency = 1
Snaplines.Visible = AimbotSettings.Snaplines

table.insert(Drawings, FOV);
table.insert(Drawings, Snaplines);

local HandlePlayer = function(Player)
    local Character = GetCharacter(Player);
    if (Character) then
        Characters[Player] = Character
    end
    CharacterAdded(Player, function(Char)
        Characters[Player] = Char
    end);
    CharacterRemoving(Player, function(Char)
        Characters[Player] = nil
    end);

    if (Player == LocalPlayer) then return; end

    local Text = Drawing.new("Text");
    Text.Color = EspSettings.Color
    Text.OutlineColor = EspSettings.OutlineColor
    Text.Size = EspSettings.Size
    Text.Transparency = EspSettings.Transparency
    Text.Center = true
    Text.Outline = true

    local Tracer = Drawing.new("Line");
    Tracer.Color = EspSettings.Color
    Tracer.From = Vector2new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y);
    Tracer.Thickness = EspSettings.TracerThickness
    Tracer.Transparency = EspSettings.TracerTrancparency

    local Box = Drawing.new("Quad");
    Box.Thickness = EspSettings.Thickness
    Box.Transparency = EspSettings.Transparency
    Box.Filled = false
    Box.Color = EspSettings.Color

    Drawings[Player] = { Text = Text, Tracer = Tracer, Box = Box }
end

for Index, Player in pairs(Players:GetPlayers()) do
    HandlePlayer(Player);
end
Players.PlayerAdded:Connect(function(Player)
    HandlePlayer(Player);
end);

Players.PlayerRemoving:Connect(function(Player)
    Characters[Player] = nil
    local PlayerDrawings = Drawings[Player]
    for Index, Drawing in pairs(PlayerDrawings or {}) do
        Drawing.Visible = false
    end
    Drawings[Player] = nil
end);

local SetProperties = function(Properties)
    for Player, PlayerDrawings in pairs(Drawings) do
        if (type(Player) ~= "number") then
            for Property, Value in pairs(Properties.Tracer or {}) do
                PlayerDrawings.Tracer[Property] = Value
            end
            for Property, Value in pairs(Properties.Text or {}) do
                PlayerDrawings.Text[Property] = Value
            end
            for Property, Value in pairs(Properties.Box or {}) do
                PlayerDrawings.Box[Property] = Value
            end
        end
    end
end

local Closest = table.create(4);
local GetClosestPlayerAndRender = function()
    MouseVector = Vector2new(Mouse.X, Mouse.Y + 36);

    local Vector2Distance = math.huge
    local Vector3DistanceOnScreen = math.huge
    local Vector3Distance = math.huge

    if (AimbotSettings.ShowFov) then
        FOV.Position = MouseVector
        FOV.Visible = true
        Snaplines.Visible = false
    else
        FOV.Visible = false
    end

    local LocalRoot = Characters[LocalPlayer] and Characters[LocalPlayer]:FindFirstChild("HumanoidRootPart");
    for Player, Character in pairs(Characters) do
        if (Player == LocalPlayer) then continue; end
        local PlayerDrawings = Drawings[Player]
        local PlayerRoot = Character:FindFirstChild("HumanoidRootPart");
        local PlayerTeam = GetTeam(Player);
        if (PlayerRoot) then
            local Redirect = Character:FindFirstChild(AimbotSettings.Aimlock);
            if (not Redirect) then
                PlayerDrawings.Text.Visible = false
                PlayerDrawings.Box.Visible = false
                PlayerDrawings.Tracer.Visible = false
                continue;
            end
            local RedirectPos = Redirect.Position
            local Tuple, Visible = WorldToViewportPoint(CurrentCamera, RedirectPos);
            local CharacterVec2 = Vector2new(Tuple.X, Tuple.Y);
            local Vector2Magnitude = (MouseVector - CharacterVec2).Magnitude
            local Vector3Magnitude = LocalRoot and (RedirectPos - LocalRoot.Position).Magnitude or math.huge
            local InRenderDistance = Vector3Magnitude <= EspSettings.RenderDistance

            if (not Tfind(AimbotSettings.BlacklistedTeams, PlayerTeam)) then
                local InFovRadius = Vector2Magnitude <= FOV.Radius
                if (InFovRadius) then
                    if (Visible and Vector2Magnitude <= Vector2Distance and AimbotSettings.ClosestCursor) then
                        Vector2Distance = Vector2Magnitude
                        Closest = {Character, CharacterVec2, Player, Redirect}
                        if (AimbotSettings.Snaplines) then
                            Snaplines.Visible = true
                            Snaplines.From = MouseVector
                            Snaplines.To = CharacterVec2
                        else
                            Snaplines.Visible = false
                        end
                    end

                    if (Visible and Vector3Magnitude <= Vector3DistanceOnScreen and Settings.ClosestPlayer) then
                        Vector3DistanceOnScreen = Vector3Magnitude
                        Closest = {Character, CharacterVec2, Player, Redirect}
                    end
                end
            end

            if (InRenderDistance and Visible and not Tfind(EspSettings.BlacklistedTeams, PlayerTeam)) then
                local CharacterHumanoid = Character:FindFirstChildWhichIsA("Humanoid") or { Health = 0, MaxHealth = 0 };
                PlayerDrawings.Text.Text = format("%s\n%s%s",
                        EspSettings.NamesEnabled and Player.Name or "",
                        EspSettings.DistanceEnabled and format("[%s]",
                            floor(Vector3Magnitude)
                        ) or "",
                        EspSettings.HealthEnabled and format(" [%s/%s]",
                            floor(CharacterHumanoid.Health),
                            floor(CharacterHumanoid.MaxHealth)
                        )  or ""
                    );

                PlayerDrawings.Text.Position = Vector2new(Tuple.X, Tuple.Y - 40);

                if (EspSettings.TracersEnabled) then
                    PlayerDrawings.Tracer.To = CharacterVec2
                end

                if (EspSettings.BoxEsp) then
                    local Parts = {}
                    for Index, Part in pairs(Character:GetChildren()) do
                        if (IsA(Part, "BasePart")) then
                            local ViewportPos = WorldToViewportPoint(CurrentCamera, Part.Position);
                            Parts[Part] = Vector2new(ViewportPos.X, ViewportPos.Y);
                        end
                    end

                    local Top, Bottom, Left, Right
                    local Distance = math.huge
                    local ClosestPart = nil
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(Tuple.X, 0)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Top = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(Tuple.X, CurrentCamera.ViewportSize.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Bottom = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(0, Tuple.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Left = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge
                    for i2, Pos in next, Parts do
                        local Mag = (Pos - Vector2new(CurrentCamera.ViewportSize.X, Tuple.Y)).Magnitude;
                        if (Mag <= Distance) then
                            ClosestPart = Pos
                            Distance = Mag
                        end
                    end
                    Right = ClosestPart
                    ClosestPart = nil
                    Distance = math.huge

                    PlayerDrawings.Box.PointA = Vector2new(Right.X, Top.Y);
                    PlayerDrawings.Box.PointB = Vector2new(Left.X, Top.Y);
                    PlayerDrawings.Box.PointC = Vector2new(Left.X, Bottom.Y);
                    PlayerDrawings.Box.PointD = Vector2new(Right.X, Bottom.Y);
                end

                if (EspSettings.TeamColors) then
                    local TeamColor;
                    if (PlayerTeam) then
                        local BrickTeamColor = PlayerTeam.TeamColor
                        TeamColor = BrickTeamColor.Color
                    else
                        TeamColor = Color3new(0.639216, 0.635294, 0.647059);
                    end
                    PlayerDrawings.Text.Color = TeamColor
                    PlayerDrawings.Box.Color = TeamColor
                    PlayerDrawings.Tracer.Color = TeamColor
                end

                PlayerDrawings.Text.Visible = true
                PlayerDrawings.Box.Visible = EspSettings.BoxEsp
                PlayerDrawings.Tracer.Visible = EspSettings.TracersEnabled
            else
                PlayerDrawings.Text.Visible = false
                PlayerDrawings.Box.Visible = false
                PlayerDrawings.Tracer.Visible = false
            end
        else
            PlayerDrawings.Text.Visible = false
            PlayerDrawings.Box.Visible = false
            PlayerDrawings.Tracer.Visible = false
        end
    end

    return unpack(Closest);
end

local Locked = false
UserInputService.InputBegan:Connect(function(Inp)
    if (Inp.UserInputType == Enum.UserInputType.MouseButton2) then
        Locked = true
    end
end);
UserInputService.InputEnded:Connect(function(Inp)
    if (Inp.UserInputType == Enum.UserInputType.MouseButton2) then
        Locked = false
    end
end);

local ClosestCharacter, Vector, Player, Aimlock;
RunService.RenderStepped:Connect(function()
    ClosestCharacter, Vector, Player, Aimlock = GetClosestPlayerAndRender();
end);

local Hooks = {
    HookedFunctions = {},
    OldMetaMethods = {},
    MetaMethodHooks = {},
    HookedSignals = {}
}

local OtherDeprecated = {
    Children = "GetChildren"
}

local RealMethods = {}
local FakeMethods = {}

local HookedFunctions = Hooks.HookedFunctions
local MetaMethodHooks = Hooks.MetaMethodHooks
local OldMetaMethods = Hooks.OldMetaMethods

MetaMethodHooks.Index = function(...)
    local __Index = OldMetaMethods.__index

    if (Player and Aimlock and ... == Mouse and not checkcaller()) then
        local CallingScript = getfenv(2).script;
        if (CallingScript.Name == "CallingScript") then
            return __Index(...);
        end

        local Mouse, Index = ...
        if (type(Index) == 'string') then
            Index = gsub(sub(Index, 0, 100), "%z.*", "");
        end
        local PassedChance = random(1, 100) < AimbotSettings.SilentAimHitChance
        if (PassedChance) then
            local Viewable = not next(GetPartsObscuringTarget(CurrentCamera, {CurrentCamera.CFrame.Position, Aimlock.Position}, {LocalPlayer.Character, ClosestCharacter}));
            local LowerIndex = lower(Index);
            local Wallbang = AimbotSettings.Wallbang
            local Hit = Viewable or Wallbang
            if (LowerIndex == "target" and Hit) then
                return Aimlock
            end
            if (LowerIndex == "hit" and Hit) then
                return Aimlock.CFramenew * CFramenew(random(1, 10) / 10, random(1, 10) / 10, random(1, 10) / 10);
            end
            if (LowerIndex == "x" and Hit) then
                return Vector.X + (random(1, 10) / 10);
            end
            if (LowerIndex == "y" and Hit) then
                return Vector.Y + (random(1, 10) / 10);
            end
        end
    end

    return __Index(...);
end

MetaMethodHooks.Namecall = function(...)
    local __Namecall = OldMetaMethods.__namecall
    local self = ...
    local Method = gsub(getnamecallmethod() or "", "^%l", upper);
    local ClassName = CallF(Hooks.OldMetaMethods.__index, 3, self, "ClassName");
    local RMethods = RealMethods[ClassName]
    local FMethods = FakeMethods[ClassName]

    if (not RMethods) then
        RealMethods[ClassName] = {}
        RMethods = RealMethods[ClassName]
    end
    if (not FMethods) then
        FakeMethods[ClassName] = {}
        FMethods = FakeMethods[ClassName]
    end

    if (RMethods[Method]) then
        local Hooked = HookedFunctions[Method] or HookedFunctions[OtherDeprecated[Method]]
        if (Hooked) then
            return Hooked[1](...);
        end
    elseif (not FMethods[Method]) then
        local IsMethod = pcall(function()
            return self[Method]
        end)
        if (IsMethod) then
            RMethods[Method] = true
        else
            FMethods[Method] = true
        end
    end

    return __Namecall(...);
end

for MMName, MMFunc in pairs(MetaMethodHooks) do
    local MetaMethod = string.format("__%s", string.lower(MMName));
    Hooks.OldMetaMethods[MetaMethod] = hookmetamethod(game, MetaMethod, MMFunc);
end

HookedFunctions.FindPartOnRay = {Workspace.FindPartOnRay, function(self, ...)
    local OldFindPartOnRay = HookedFunctions.FindPartOnRay[3]
    if (self == Workspace and Player and Aimlock and not checkcaller()) then
        local PassedChance = random(1, 100) < AimbotSettings.SilentAimHitChance
        if (ClosestCharacter and PassedChance) then
            local Viewable = not next(GetPartsObscuringTarget(CurrentCamera, {CurrentCamera.CFrame.Position, Aimlock}, {LocalPlayer.Character, ClosestCharacter}));
            if (Viewable or AimbotSettings.Wallbang) then
                return Aimlock, Aimlock.Position + (Vector3new(random(1, 10), random(1, 10), random(1, 10)) / 10), Vector3new(0, 1, 0), Aimlock.Material
            end
        end
    end
    return OldFindPartOnRay(self, ...);
end};

HookedFunctions.FindPartOnRayWithIgnoreList = {Workspace.FindPartOnRayWithIgnoreList, function(self, ...)
    local OldFindPartOnRayWithIgnoreList = HookedFunctions.FindPartOnRayWithIgnoreList[3]
    if (self == Workspace and Player and Aimlock and not checkcaller()) then
        local CallingScript = getfenv(2).script;
        local PassedChance = random(1, 100) < AimbotSettings.SilentAimHitChance
        if (CallingScript.Name ~= "ControlModule" and  ClosestCharacter and PassedChance) then
            local Viewable = not next(GetPartsObscuringTarget(CurrentCamera, {CurrentCamera.CFrame.Position, Aimlock}, {LocalPlayer.Character, ClosestCharacter}));
            if (Viewable or AimbotSettings.Wallbang) then
                return Aimlock, Aimlock.Position + (Vector3new(random(1, 10), random(1, 10), random(1, 10)) / 10), Vector3new(0, 1, 0), Aimlock.Material
            end
        end
    end
    return OldFindPartOnRayWithIgnoreList(self, ...);
end};

for Index, Function in pairs(HookedFunctions) do
    Function[3] = hookfunction(Function[1], Function[2]);
end

local MainUI = UILibrary.new(Color3.fromRGB(255, 79, 87));
local Window = MainUI:LoadWindow('<font color="#ff4f57">fates</font> esp', UDim2.fromOffset(400, 279));
local ESP = Window.NewPage("esp");
local Aimbot = Window.NewPage("aimbot");
local EspSettingsUI = ESP.NewSection("Esp");
local TracerSettingsUI = ESP.NewSection("Tracers");
local AimbotUI = Aimbot.NewSection("Aimbot");
local AimbotConfigUI = Aimbot.NewSection("Config");

EspSettingsUI.Toggle("Show Names", EspSettings.NamesEnabled, function(Callback)
    EspSettings.NamesEnabled = Callback
end);
EspSettingsUI.Toggle("Show Health", EspSettings.HealthEnabled, function(Callback)
    EspSettings.HealthEnabled = Callback
end);
EspSettingsUI.Toggle("Show Distance", EspSettings.DistanceEnabled, function(Callback)
    EspSettings.DistanceEnabled = Callback
end);
EspSettingsUI.Toggle("Box Esp", EspSettings.BoxEsp, function(Callback)
    EspSettings.BoxEsp = Callback
    SetProperties({ Box = { Visible = Callback } });
end);
EspSettingsUI.Slider("Render Distance", { Min = 0, Max = 50000, Default = math.clamp(EspSettings.RenderDistance, 0, 50000), Step = 10 }, function(Callback)
    EspSettings.RenderDistance = Callback
end);
EspSettingsUI.Slider("Esp Size", { Min = 0, Max = 30, Default = EspSettings.Size, Step = 1}, function(Callback)
    EspSettings.Size = Callback
    SetProperties({ Text = { Size = Callback } });
end);
EspSettingsUI.ColorPicker("Esp Color", EspSettings.Color, function(Callback)
    EspSettings.TeamColors = false
    EspSettings.Color = Callback
    SetProperties({ Box = { Color = Callback }, Text = { Color = Callback }, Tracer = { Color = Callback } });
end);
EspSettingsUI.Toggle("Team Colors", EspSettings.TeamColors, function(Callback)
    EspSettings.TeamColors = Callback
    if (not Callback) then
        SetProperties({ Tracer = { Color = EspSettings.Color }; Box = { Color = EspSettings.Color }; Text = { Color = EspSettings.Color }  })
    end
end);
EspSettingsUI.Dropdown("Teams", {"Allies", "Enemies", "All"}, function(Callback)
    table.clear(EspSettings.BlacklistedTeams);
    if (Callback == "Enemies") then
        table.insert(EspSettings.BlacklistedTeams, LocalPlayer.Team);
    end
    if (Callback == "Allies") then
        local AllTeams = Teams:GetTeams();
        table.remove(AllTeams, table.find(AllTeams, LocalPlayer.Team));
        EspSettings.BlacklistedTeams = AllTeams
    end
end);
TracerSettingsUI.Toggle("Enable Tracers", EspSettings.TracersEnabled, function(Callback)
    EspSettings.TracersEnabled = Callback
    SetProperties({ Tracer = { Visible = Callback } });
end);
TracerSettingsUI.Dropdown("To", {"Head", "Torso"}, function(Callback)
    AimbotSettings.Aimlock = Callback == "Torso" and "HumanoidRootPart" or Callback
end);
TracerSettingsUI.Dropdown("From", {"Top", "Bottom", "Left", "Right"}, function(Callback)
    local ViewportSize = CurrentCamera.ViewportSize
    local From = Callback == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or Callback == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or Callback == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or Callback == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);
    EspSettings.TracerFrom = From
    SetProperties({ Tracer = { From = From } });
end);
TracerSettingsUI.Slider("Tracer Transparency", {Min = 0, Max = 1, Default = EspSettings.TracerTrancparency, Step = .1}, function(Callback)
    EspSettings.TracerTrancparency = Callback
    SetProperties({ Tracer = { Transparency = Callback } });
end);
TracerSettingsUI.Slider("Tracer Thickness", {Min = 0, Max = 5, Default = EspSettings.TracerThickness, Step = .1}, function(Callback)
    EspSettings.TracerThickness = Callback
    SetProperties({ Tracer = { Thickness = Callback } });
end);

AimbotUI.Toggle("Silent Aim", AimbotSettings.SilentAim, function(Callback)
    AimbotSettings.SilentAim = Callback
end);
AimbotUI.Toggle("Wallbang", AimbotSettings.Wallbang, function(Callback)
    AimbotSettings.Wallbang = Callback
end);
AimbotUI.Dropdown("Aimbone", {"Head", "Torso"}, function(Callback)
    AimbotSettings.Aimlock = Callback
end);
AimbotUI.Slider("Hit Chance", {Min = 0, Max = 100, Default = AimbotSettings.SilentAimHitChance, Step = 1}, function(Callback)
    AimbotSettings.SilentAimHitChance = Callback
end);
AimbotUI.Toggle("Aimbot (Hold M2)", AimbotSettings.Aimbot, function(Callback)
    AimbotSettings.Aimbot = Callback
end);
AimbotUI.Slider("Aimbot Smoothness", {Min = 1, Max = 10, Default = AimbotSettings.Smoothness, Step = .5}, function(Callback)
    AimbotSettings.Smoothness = Callback
end);
AimbotUI.Dropdown("Team", {"Allies", "Enemies", "All"}, function(Callback)
    AimbotSettings.Team = Callback
end);
AimbotUI.Dropdown("Lock Type", {"Closest Cursor", "Closest Player"}, function(Callback)
    if (Callback == "Closest Cursor") then
        AimbotSettings.ClosestCharacter = false
        AimbotSettings.ClosestCursor = true
    else
        AimbotSettings.ClosestCharacter = true
        AimbotSettings.ClosestCursor = false
    end
end);

AimbotConfigUI.Toggle("Show Fov", AimbotSettings.ShowFov, function(Callback)
    AimbotSettings.ShowFov = Callback
    FOV.Visible = Callback
end);
AimbotConfigUI.ColorPicker("Fov Color", AimbotSettings.FovColor, function(Callback)
    AimbotSettings.FovColor = Callback
    FOV.Color = Callback
    Snaplines.Color = Callback
end);
AimbotConfigUI.Slider("Fov Size", {Min = 70, Max = 500, Default = AimbotSettings.FovSize, Step = 10}, function(Callback)
    AimbotSettings.FovSize = Callback
    FOV.Radius = Callback
end);
AimbotConfigUI.Toggle("Enable Snaplines", AimbotSettings.Snaplines, function(Callback)
    AimbotSettings.Snaplines = Callback
end);
Window.SetPosition(Settings.WindowPosition);

MainUI.UI.Parent = game.CoreGui

while wait(5) do
    Settings.WindowPosition = Window.GetPosition();
    local Encoded = HttpService:JSONEncode(EncodeConfig(Settings));
    writefile("fates-esp-v2.json", Encoded);
end