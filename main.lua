local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");
local HttpService = game:GetService("HttpService");

local Vector3new = Vector3.new
local Vector2new = Vector2.new
local UDim2new = UDim2.new
local UDimnew = UDim.new
local CFramenew = CFrame.new
local BrickColornew = BrickColor.new
local Drawingnew = Drawing.new
local Color3new = Color3.new
local Color3fromRGB = Color3.fromRGB
local Color3fromHSV = Color3.fromHSV

local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse();

local GetCharacter = GetCharacter or function(Plr)
    if (Plr) then
        return Plr.Character or false
    end
end

hookfunction = hookfunction or function(func, newfunc)
    if (replaceclosure) then
        replaceclosure(func, newfunc);
        return newfunc
    end

    func = newcclosure and newcclosure(newfunc) or newfunc
    return newfunc
end

getconnections = getconnections or function()
    return {}
end

getrawmetatable = getrawmetatable or function()
    return setmetatable({}, {});
end

getnamecallmethod = getnamecallmethod or function()
    return ""
end

checkcaller = checkcaller or function()
    return false
end

getgc = getgc or function()
    return {}
end

local ISPF, PF_Network, PF_Client, GetBodyParts, GunTbl, Trajectory
if (game.PlaceId == 292439477) then
    if (not game:IsLoaded()) then
        game.Loaded:Wait();
    end
    ISPF = true
    for i, v in next, getgc(true) do
        if (type(v) == "table") then
            if (rawget(v, "send")) then
                PF_Network = v
            end
            if (rawget(v, "getbodyparts")) then
                GetBodyParts = rawget(v, "getbodyparts");
            end
            if (rawget(v, "setsprintdisable")) then
                GunTbl = v
            end
            if (rawget(v, "setsway")) then
                PF_Client = v
            end
        elseif (type(v) == "function") then
            local funcinfo = debug.getinfo(v);
            if (funcinfo.name == "trajectory") then
                Trajectory = v
            end
        end
        if (GunTbl and GetBodyParts and PF_Network and Trajectory and PF_Client) then
            break
        end
    end
    GetCharacter = function(Plr)
        if (Plr == LocalPlayer or not Plr) then
            return LocalPlayer.Character
        end
        local Char = GetBodyParts(Plr);
        if (type(Char) == "table") then
            if (rawget(Char, "rootpart")) then
                Plr.Character = rawget(Char, "rootpart").Parent
            end
        end
		return Plr and Plr.Character or nil
    end
end
local ISBB, BB_Network, Projectiles
if (game.PlaceId == 3233893879) then
    ISBB = true
    local Script = LocalPlayer.PlayerScripts.FriendlyNameScript
    for i, v in next, getgc(true) do
        if (type(v) == "table") then
            local Projectiles_ = rawget(v, "Projectiles"); 
            if (rawget(v, "Characters")) then
                BB_Network = v
            end
            if (Projectiles_ and type(Projectiles_) == "table") then
                Projectiles = v.Projectiles
            end
        end
        if (BB_Network and Projectiles) then
            break;
        end
    end
    GetCharacter = function(Plr)
        if (Plr == LocalPlayer or not Plr) then
            return LocalPlayer.Character
        end
        local Char = BB_Network.Characters:GetCharacter(Plr);
        if (Char and Char.Body) then
            Plr.Character = Char.Body
        end
        return Plr and Plr.Character or nil
    end
    local function BB_GetTeamColor(rgb)
        return Color3new(math.min(rgb.r * 1.3, 1), math.min(rgb.g * 1.3, 1), math.min(rgb.b * 1.3, 1));
    end
    local BB_Teams = BB_Network.Teams
    for i, v in next, Players:GetPlayers() do
        local Team = BB_Teams:GetPlayerTeam(v);
        v.TeamColor = BrickColornew(BB_GetTeamColor(BB_Teams.Colors[Team]));
    end
    for i, v in next, Players:GetPlayers() do
        local Team = BB_Teams:GetPlayerTeam(v);
        v.TeamColor = BrickColornew(BB_GetTeamColor(BB_Teams.Colors[BB_Teams:GetPlayerTeam(v)]));
    end
    BB_Teams.TeamChanged:Connect(function(Plr, Team)
        Plr.TeamColor = BrickColornew(BB_GetTeamColor(BB_Teams.Colors[Team]));
    end)
end
local ISCB = game.PlaceId == 301549746

local SilentAimingPlayer = nil
local SilentAimHitChance = 100
local AimBone = "Head"
local Wallbang = true

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
local __Namecall = OldMetaMethods.__namecall
local __Index = OldMetaMethods.__index
local __NewIndex = OldMetaMethods.__newindex

mt.__namecall = newcclosure(function(self, ...)
    local Args = {...}
    local Method = getnamecallmethod():gsub("%z.*", "");


    if (checkcaller()) then
        if (Method == "FindFirstChild" and ISBB) then
            return __Namecall(self, "Chest");
        end
        return __Namecall(self, ...);
    end

    if (not ISPF and self == Workspace and Method == "FindPartOnRay" and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then  
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
            end
        end
    end

    if (not ISPF and self == Workspace and Method == "FindPartOnRayWithIgnoreList" and SilentAimingPlayer and getcallingscript().Name ~= "CameraModule") then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                if (not ISCB) then
                    return Char[AimBone], Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
                end
                Args[1] = Ray.new(Args[1].Origin, (Char[AimBone].Position - Args[1].Origin));
                return __Namecall(self, unpack(Args));
            end
        end
    end

    return __Namecall(self, unpack(Args));
end)

mt.__index = newcclosure(function(Instance_, Index)
    if (checkcaller()) then
        if (Index == "HumanoidRootPart" and ISBB) then
            return __Index(Instance_, "Chest")
        end

        return __Index(Instance_, Index);
    end

    local SanitisedIndex = type(Index) == 'string' and Index:gsub("%z.*", "") or Index

    if (Instance_ == Mouse and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local ViewportPoint = Camera:WorldToViewportPoint(Char[AimBone].Position);
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (SanitisedIndex:lower() == "target") then
                if (Viewable or Wallbang) then
                    return Char[AimBone]
                end
            elseif (SanitisedIndex:lower() == "hit" and (Viewable or Wallbang)) then
                if (Viewable or Wallbang) then
                    return Char[AimBone].CFrame * CFramenew(math.random(1, 10) / 10, math.random(1, 10) / 10, math.random(1, 10) / 10);
                end
            elseif (SanitisedIndex:lower() == "x" and (Viewable or Wallbang)) then
                return ViewportPoint.X + (math.random(1, 10) / 10);
            elseif (SanitisedIndex == "y" and (Viewable or Wallbang)) then
                return ViewportPoint.Y + (math.random(1, 10) / 10);
            end
        end
    end

    return __Index(Instance_, Index);
end)

local OldFindPartOnRay
OldFindPartOnRay = hookfunction(Workspace.FindPartOnRay, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
            end
        end
    end
    return OldFindPartOnRay(...);
end))
local OldFindPartOnRayWithIgnoreList
OldFindPartOnRayWithIgnoreList = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer and getcallingscript().Name ~= "CameraModule") then
        local Args = {...}
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                if (not ISCB) then
                    return Char[AimBone], Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
                end
                Args[1] = Ray.new(Args[1].Origin, (Char[AimBone].Position - Args[1].Origin));
                return OldFindPartOnRayWithIgnoreList(unpack(Args));
            end
        end
    end
    return OldFindPartOnRayWithIgnoreList(...);
end))
if (ISPF and PF_Network and PF_Network.send) then
    local OldSend = PF_Network.send
    PF_Network.send = function(...)
        local Args = {...}
        local Type = Args[2]
        if (Type == "newbullets") then
            local Char
            if (SilentAimingPlayer) then
                Char = GetCharacter(SilentAimingPlayer);
            end
            local Chance = math.random(1, 100) < SilentAimHitChance
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Char and Char[AimBone] and Chance and (Viewable or Wallbang)) then
                local AimPos = Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10);
                Args[3].bullets[1][1] = Trajectory(PF_Client.basecframe * Vector3new(0, 0, 1), Vector3new(0, -Workspace.Gravity, 0), AimPos, GunTbl.currentgun.data.bulletspeed);
      
                OldSend(Args[1], "newbullets", Args[3], Args[4]);
                OldSend(Args[1], "bullethit", SilentAimingPlayer, AimPos, GetCharacter(SilentAimingPlayer).Head, Args[3].bullets[1][2]);
                return
            end
        end
        return OldSend(...)
    end
end
if (ISBB and Projectiles and Projectiles.InitProjectile) then
    local OldInitProjectile = Projectiles.InitProjectile
    Projectiles.InitProjectile = function(...)
        local Args = {...}
        local Char
        if (SilentAimingPlayer) then
            Char = GetCharacter(SilentAimingPlayer);
            local Chance = math.random(1, 100) < SilentAimHitChance
            local Viewable = not next(Camera.GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Char and Char[AimBone] and Chance and (Viewable or Wallbang)) then
                Args[3] = Char[AimBone].Position - Args[4]
                return OldInitProjectile(unpack(Args));
            end
        end
        return OldInitProjectile(...);
    end
end

local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/Roblox-Drawing-Lib/main/main.lua"))();

local Drawings = {}
local Window

local Load = function()
    local Settings = HttpService:JSONDecode(readfile("fates-esp.json"));
    local NewSettings = {}
    for i, v in next, Settings do
        NewSettings[i] = v
        if (type(v) == "table") then
            for i2, v2 in next, v do
                if (type(v2) == "table") then
                    if (#v2 == 3) --[[Color3]] then
                        NewSettings[i][i2] = Color3fromHSV(v2[1], v2[2], v2[3]);
                    elseif (#v2 == 4) --[[UDim2]] then
                        NewSettings[i][i2] = UDim2new(UDimnew(v2[1], v2[2]), UDimnew(v2[3], v2[4]));
                    end
                else
                    NewSettings[i][i2] = v2
                end
            end
        end
    end
    return NewSettings
end
local Settings
local Debounce = 0
local Save = function()
    if ((tick() - Debounce) >= 1.5) then
        local NewSettings = {}
        for i, v in next, Settings do
            NewSettings[i] = v
        end
        for i, v in next, NewSettings do
            for i2, v2 in next, v do
                if (typeof(v2) == "Color3") then
                    local H, S, V = v2:ToHSV();
                    NewSettings[i][i2] = {H, S, V}
                elseif (typeof(v2) == "UDim2") then
                    local Pos = Window.GetPosition();
                    NewSettings[i][i2] = {Pos.X.Scale, Pos.X.Offset, Pos.Y.Scale, Pos.Y.Offset}
                end
            end
        end
        writefile("fates-esp.json", HttpService:JSONEncode(NewSettings));
        print("saved");
        Debounce = tick();
    end
end

Settings = isfile("fates-esp.json") and Load() or {
    TracerOptions = {
        Enabled = true,
        To = "Head",
        From = "Bottom",
        Thickness = 1.6,
        Transparency = .7,
    };
    EspOptions = {
        Enabled = true,
        TeamColors = true,
        Names = true,
        Health = true,
        Distance = false,
        Thickness = 1.5,
        Transparency = .9,
        Size = 16,
        Color = Color3fromRGB(20, 226, 207),
        OutlineColor = Color3new(),
        Team = "All",
        BoxEsp = true,
        SkeletonEsp = true,
    };
    AimbotOptions = {
        Enabled = true,
        SilentAim = false,
        ShowFov = false,
        FovThickness = 1,
        FovTransparency = 1,
        FovSize = 150,
        FovColor = Color3fromRGB(20, 226, 207),
        Snaplines = false,
        ThirdPerson = false,
        FirstPerson = false,
        ClosestCharacter = false,
        ClosestCursor = true,
        Team = "All",
    };
    UIOptions = {
        Position = UDim2new(0.5, -200, 0.5, -139);
    }
}
local TracerOptions, EspOptions, AimbotOptions, UIOptions = Settings.TracerOptions, Settings.EspOptions, Settings.AimbotOptions, Settings.UIOptions

local GetPart = function(Part, Char)
    if (not Char) then
        return false
    end
    if (Char:FindFirstChild(Part)) then
        return Part
    end
    if (Part == "Torso") then
        Part = "UpperTorso"
    elseif (Part == "Right Arm") then
        Part = "RightUpperArm"
    elseif (Part == "Left Arm") then
        Part = "LeftUpperArm"
    elseif (Part == "Right Leg") then
        Part = "RightLowerLeg"
    elseif (Part == "Left Leg") then
        Part = "LeftLowerLeg"
    end
    return Part
end

local GetVector2 = function(Plr, To)
    local Char = GetCharacter(Plr);
    To = GetPart(To, Char);
    if (Plr and Char and Char:FindFirstChild(To)) then
        return Camera:WorldToViewportPoint(Char:FindFirstChild(To or AimBone).Position);
    else
        return false
    end
end

local GetHumanoid = function(Plr)
    local Char = GetCharacter(Plr);
    if (Char and Char:FindFirstChildWhichIsA("Humanoid")) then
        return Char:FindFirstChildWhichIsA("Humanoid");
    else
        return false
    end
end

local GetMagnitude = function(Plr)
    local Char = GetCharacter(Plr);
    local Part = Char:FindFirstChild(GetPart(AimBone, Char));
    if (Char and Part) then
        local LPChar = GetCharacter(LocalPlayer);
        if (LPChar and LPChar:FindFirstChild("HumanoidRootPart")) then
            return (Part.Position - (GetCharacter(LocalPlayer) and GetCharacter(LocalPlayer).HumanoidRootPart.Position or Vector3new())).Magnitude
        else
            return math.huge
        end
    end
end

local AddDrawing = function(Plr)
    local Tracer = Drawingnew("Line");
    local Text = Drawingnew("Text");
    local Box = Drawingnew("Quad");
    local Skeleton = {
        Head = Drawingnew("Line"),
        UpperLeftArm = Drawingnew("Line"),
        LowerLeftArm = Drawingnew("Line"),
        UpperRightArm = Drawingnew("Line"),
        LowerRightArm = Drawingnew("Line"),
        UpperTorso = Drawingnew("Line"),
        LowerTorso = Drawingnew("Line"),
        UpperLeftLeg = Drawingnew("Line"),
        LowerLeftLeg = Drawingnew("Line"),
        UpperRightLeg = Drawingnew("Line"),
        LowerRightLeg = Drawingnew("Line"),
        LeftHand = Drawingnew("Line"),
        RightHand = Drawingnew("Line"),
    }

    local Tuple = GetVector2(Plr, TracerOptions.To);
    Drawings[Plr] = {}
    if (Tuple) then
        Tracer.To = Vector2new(Tuple.X, Tuple.Y);
        Text.Position = Vector2new(Tuple.X, Tuple.Y) + Vector2new(0, -100, 0);
    end

    Tracer.From = Vector2new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y);
    Tracer.Color = EspOptions.Color
    Tracer.Thickness = TracerOptions.Thickness
    Tracer.Transparency = TracerOptions.Transparency
    Tracer.Visible = TracerOptions.Enabled
    Drawings[Plr].Tracer = Tracer

    local From, ViewportSize = TracerOptions.From, Camera.ViewportSize
    Tracer.From = From == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or From == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or From == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or From == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);

    Text.Color = EspOptions.Color
    Text.OutlineColor = EspOptions.OutlineColor
    Text.Size = EspOptions.Size
    Text.Transparency = EspOptions.Transparency
    Text.Center = true
    Text.Outline = true
    Text.Visible = EspOptions.Enabled
    Drawings[Plr].Text = Text

    Box.PointA = Vector2new();
    Box.PointB = Vector2new();
    Box.PointC = Vector2new();
    Box.PointD = Vector2new();
    Box.Thickness = EspOptions.Thickness
    Box.Transparency = EspOptions.Transparency
    Box.Filled = false
    Box.Color = EspOptions.Color
    Box.Visible = EspOptions.Enabled    
    Drawings[Plr].Box = Box

    for i, v in next, Skeleton do
        v.Visible = EspOptions.Enabled
        v.Color = EspOptions.Color
        v.Thickness = EspOptions.Thickness
        v.Transparency = EspOptions.Transparency
    end
    Drawings[Plr].Skeleton = Skeleton
end
local RemoveDrawing = function(Plr)
    local PlrDrawings = Drawings[Plr]
    if (PlrDrawings) then
        for i, PlrDrawings_ in next, PlrDrawings do
            for _, Drawing_ in PlrDrawings do
                if (Drawing_.Remove) then
                    Drawing_:Remove();
                end
            end
        end
        Drawings[Plr] = nil
    end
end

for i, v in next, Players:GetPlayers() do
    if (v ~= LocalPlayer) then
        AddDrawing(v);
    end
end
Players.PlayerAdded:Connect(AddDrawing);
Players.PlayerRemoving:Connect(RemoveDrawing);

if (AimbotOptions.Enabled) then
    Drawings["SilentAim"] = {}
    local Circle = Drawingnew("Circle");
    Circle.Color = AimbotOptions.FovColor
    Circle.Thickness = AimbotOptions.FovThickness
    Circle.Transparency = AimbotOptions.FovTransparency
    Circle.Filled = false
    Circle.Radius = AimbotOptions.FovSize or 150
    Circle.Position = Vector2new(Mouse.X, Mouse.Y + 36);
    Circle.Visible = AimbotOptions.ShowFov
    Drawings.SilentAim.Fov = Circle

    local Snaplines = Drawingnew("Line");
    Snaplines.From = Vector2new(Mouse.X, Mouse.Y + 36);  
    Snaplines.Color = AimbotOptions.FovColor
    Snaplines.Thickness = .1
    Snaplines.Transparency = 1
    Snaplines.Visible = AimbotOptions.Snaplines
    Drawings.SilentAim.Snaplines = Snaplines
end


local Render = RunService.RenderStepped:Connect(function()
    local MouseVector = Vector2new(Mouse.X, Mouse.Y + 36);

    local SilentAim = Drawings["SilentAim"]
    local Circle, Snaplines = SilentAim.Fov, SilentAim.Snaplines
    Circle.Position = MouseVector
    Snaplines.From = MouseVector
    Snaplines.Visible = false

    local TargetCursor = nil
    local TargetCharacter = nil
    local TargetAimbone = nil
    local TargetTuple = nil
    local TargetViewable = false
    local Vector2Distance = math.huge
    local Vector3Distance = math.huge
    
    for i, v in next, Drawings do
        if (not i) then
            continue
        end
        if (i == LocalPlayer or not v.Tracer and not v.Box and not v.Text) then
            continue
        end
        local Char = GetCharacter(i);
        if (not Char) then
            v.Tracer.Visible = false
            v.Text.Visible = false
            v.Box.Visible = false
            continue
        end

        if (EspOptions.Team == "All") then
            
        elseif (EspOptions.Team == "Allies" and i.Team ~= LocalPlayer.Team) then
            v.Tracer.Visible = false
            v.Text.Visible = false
            v.Box.Visible = false
            continue
        elseif (EspOptions.Team == "Enemies" and i.Team == LocalPlayer.Team) then
            v.Tracer.Visible = false
            v.Text.Visible = false
            v.Box.Visible = false
            continue
        end

        local TracerTuple, TracerVisible = GetVector2(i, TracerOptions.To);
        local TextTuple, TextVisible = GetVector2(i, "Head");
        if (TracerTuple and TracerVisible and TracerOptions.Enabled) then
            v.Tracer.Visible = true
            v.Tracer.To = Vector2new(TracerTuple.X, TracerTuple.Y);
            if (EspOptions.TeamColors) then
                v.Tracer.Color = BrickColornew(tostring(i.TeamColor)).Color
            end
        else
            v.Tracer.Visible = false            
        end
        if (TextTuple and TextVisible) then
            v.Text.Visible = true
            local Magnitude, Humanoid = GetMagnitude(i), GetHumanoid(i) or {Health=0,MaxHealth=0}
            v.Text.Position = Vector2new(TextTuple.X, TextTuple.Y - 40);
            v.Text.Text = ("%s\n%s %s"):format(EspOptions.Names and i.Name or "", EspOptions.Distance and ("[%s]"):format(math.floor(Magnitude or math.huge)) or "", EspOptions.Health and ("[%s/%s]"):format(math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth)) or "");
            if (EspOptions.TeamColors) then
                local Color = BrickColornew(tostring(i.TeamColor)).Color
                v.Text.Color = Color
                v.Box.Color = Color
                for i2, v2 in next, v.Skeleton do
                    v2.Color = Color
                end
            end
            local Parts = {}
            for i2, Part in next, Char:GetChildren() do
                if (Part:IsA("BasePart")) then
                    local ViewportPos = Camera:WorldToViewportPoint(Part.Position);
                    Parts[Part] = Vector2new(ViewportPos.X, ViewportPos.Y);
                end
            end

            if (EspOptions.BoxEsp) then
                local Top, Bottom, Left, Right
                local Distance = math.huge
                local Closest = nil
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(TextTuple.X, 0)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Top = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(TextTuple.X, Camera.ViewportSize.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Bottom = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(0, TextTuple.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Left = Closest
                Closest = nil
                Distance = math.huge
                for i2, Pos in next, Parts do
                    local Mag = (Pos - Vector2new(Camera.ViewportSize.X, TextTuple.Y)).Magnitude;
                    if (Mag <= Distance) then
                        Closest = Pos
                        Distance = Mag
                    end
                end
                Right = Closest
                Closest = nil
                Distance = math.huge
    
                v.Box.PointA = Vector2new(Right.X, Top.Y);
                v.Box.PointB = Vector2new(Left.X, Top.Y);
                v.Box.PointC = Vector2new(Left.X, Bottom.Y);
                v.Box.PointD = Vector2new(Right.X, Bottom.Y);
                v.Box.Visible = true
            end

            if (EspOptions.SkeletonEsp) then

            end
        else
            v.Text.Visible = false
            v.Box.Visible = false
        end

        if (AimbotOptions.Team == "All") then
    
        elseif (AimbotOptions.Team == "Allies" and i.Team ~= LocalPlayer.Team) then
            continue
        elseif (AimbotOptions.Team == "Enemies" and i.Team == LocalPlayer.Team) then
            continue
        end
        
        local Part = GetPart(AimBone, Char);
        if (Char and Char:FindFirstChild("HumanoidRootPart") and Char:FindFirstChild(Part)) then
            local Tuple, Viewable = Camera:WorldToViewportPoint(Char[AimBone].Position);
            local Vector2Magnitude = (MouseVector - Vector2new(Tuple.X, Tuple.Y)).Magnitude
            local Vector3Magnitide = GetMagnitude(i);
            if (Viewable and Vector2Magnitude <= Vector2Distance and Vector2Magnitude <= AimbotOptions.FovSize) then
                TargetCursor = i
                TargetAimbone = AimbotOptions.ClosestCursor and Char[AimBone] or TargetAimbone
                TargetTuple = AimbotOptions.ClosestCursor and Tuple or TargetTuple
                TargetViewable = AimbotOptions.ClosestCursor and Viewable or TargetViewable
                Vector2Distance = Vector2Magnitude
                
                if (AimbotOptions.Snaplines and AimbotOptions.ShowFov) then
                    Snaplines.Visible = true
                    Snaplines.To = Vector2new(Tuple.X, Tuple.Y);
                else
                    Snaplines.Visible = false
                end
            end
            if (Vector3Magnitide <= Vector3Distance) then
                TargetCharacter = i
                TargetAimbone = AimbotOptions.ClosestCharacter and Char[AimBone] or TargetAimbone
                TargetTuple = AimbotOptions.ClosestCharacter and Tuple or TargetTuple
                TargetViewable = AimbotOptions.ClosestCharacter and Viewable or TargetViewable
                Vector3Distance = Vector3Magnitide
            end
        end
    end

    if (AimbotOptions.SilentAim) then
        SilentAimingPlayer = AimbotOptions.ClosestCursor and TargetCursor or AimbotOptions.ClosestCharacter and TargetCharacter or TargetCursor
    end
    if (TargetViewable and AimbotOptions.FirstPerson and TargetAimbone) then
        Camera.CoordinateFrame = CFramenew(Camera.CoordinateFrame.p, TargetAimbone.Position);
    end
    if (TargetViewable and AimbotOptions.ThirdPerson and TargetTuple and mousemoveabs) then
        mousemoveabs(TargetTuple.X, TargetTuple.Y);
    end
end)

local UILibrary = loadfile("uilib.txt")();--loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-esp/main/ui.lua"))(); --loadfile("uilib.txt")()
local UI = UILibrary.new(Color3fromRGB(255, 79, 87))
Window = UI:LoadWindow('<font color="#ff4f57">fates</font> esp', UDim2.fromOffset(400, 279));
local ESP = Window.NewPage("esp")
local AIMBOT = Window.NewPage("aimbot")
local AimbotSection = AIMBOT.NewSection("Aimbot");
local ConfigSection = AIMBOT.NewSection("Config");
local TracersSection = ESP.NewSection("Tracers")
local EspSection = ESP.NewSection("Other")

Window.SetPosition(UIOptions.Position);

TracersSection.Toggle("Enable Tracers", TracerOptions.Enabled, function(Callback)
	TracerOptions.Enabled = Callback
    Save();
end)
TracersSection.Dropdown("To", {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}, function(Callback)
	TracerOptions.To = Callback
    Save();
end)
TracersSection.Dropdown("From", {"Top", "Bottom", "Left", "Right"}, function(Callback)
    local ViewportSize = Camera.ViewportSize
    TracerOptions.From = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.From = Callback == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or Callback == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or Callback == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or Callback == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);
        end
    end
    Save();
end)

TracersSection.Slider("Tracer Transparency", {Min = 0, Max = 1, Default = TracerOptions.Transparency, Step = .1}, function(Callback)
    TracerOptions.Transparency = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.Transparency = Callback
        end
    end
    Save();
end)
TracersSection.Slider("Tracer Thickness", {Min = 0, Max = 5, Default = TracerOptions.Thickness, Step = .1}, function(Callback)
    TracerOptions.Thickness = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.Thickness = Callback
        end
    end
    Save();
end)

EspSection.Toggle("Team Colors", EspOptions.TeamColors, function(Callback)
    EspOptions.TeamColors = Callback
    if (Callback == false) then
        for i, v in next, Drawings do
            if (v.Tracer and v.Text) then
                v.Tracer.Color = EspOptions.Color
                v.Text.Color = EspOptions.Color
            end
        end
    end
    Save();
end)
EspSection.ColorPicker("Esp Color", EspOptions.Color, function(Callback)
    EspOptions.TeamColors = false
    EspOptions.Color = Callback
    for i, v in next, Drawings do
        if (v.Tracer and v.Text and v.Box) then
            v.Tracer.Color = Callback
            v.Text.Color = Callback
            v.Box.Color = Callback
        end
    end
    Save();
end)
EspSection.Toggle("Show Names", EspOptions.Names, function(Callback)
    EspOptions.Names = Callback
    Save();
end)
EspSection.Toggle("Show Health", EspOptions.Health, function(Callback)
    EspOptions.Health = Callback
    Save();
end)
EspSection.Toggle("Show Distance", EspOptions.Distance, function(Callback)
    EspOptions.Distance = Callback
    Save();
end)
EspSection.Dropdown("Team", {"Allies", "Enemies", "All"}, function(Callback)
    EspOptions.Team = Callback
    Save();
end)
EspSection.Toggle("Box Esp", EspOptions.BoxEsp, function(Callback)
    EspOptions.BoxEsp = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Visible = Callback
        end
    end
    Save();
end)
EspSection.Slider("Box Thickness", {Min = 0, Max = 5, Default = EspOptions.Transparency, Step = .1}, function(Callback)
    EspOptions.Thickness = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Thickness = Callback
        end
    end
    Save();
end)
EspSection.Slider("Box Transparency", {Min = 0, Max = 1, Default = EspOptions.Transparency, Step = .1}, function(Callback)
    EspOptions.Transparency = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Transparency = Callback
        end
    end
    Save();
end)

AimbotSection.Toggle("Silent Aim", AimbotOptions.SilentAim, function(Callback)
    AimbotOptions.SilentAim = Callback
    Save();
end)
AimbotSection.Toggle("Wallbang", Wallbang, function(Callback)
    Wallbang = Callback
end)
AimbotSection.Dropdown("Aimbone", {"Head","Torso","UpperTorso"}, function(Callback)
	AimBone = Callback
end)
AimbotSection.Slider("Hit Chance", {Min = 0, Max = 100, Default = SilentAimHitChance, Step = 1}, function(Callback)
    SilentAimHitChance = Callback
end)
AimbotSection.Toggle("3rd P Aimlock", AimbotOptions.ThirdPerson, function(Callback)
    AimbotOptions.ThirdPerson = Callback
    Save();
end)
AimbotSection.Toggle("1st P Aimlock", AimbotOptions.FirstPerson, function(Callback)
    AimbotOptions.FirstPerson = Callback
    Save();
end)
AimbotSection.Dropdown("Team", {"Allies", "Enemies", "All"}, function(Callback)
    AimbotOptions.Team = Callback
    Save();
end)
AimbotSection.Dropdown("Lock Type", {"Closest Cursor", "Closest Player"}, function(Callback)
    if (Callback == "Closest Cursor") then
        AimbotOptions.ClosestCharacter = false
        AimbotOptions.ClosestCursor = true       
    else
        AimbotOptions.ClosestCharacter = true
        AimbotOptions.ClosestCursor = false
    end
    Save();
end)

ConfigSection.Toggle("Show Fov", AimbotOptions.ShowFov, function(Callback)
    AimbotOptions.ShowFov = Callback
    Drawings.SilentAim.Fov.Visible = Callback
    Save();
end)
ConfigSection.ColorPicker("Fov Color", AimbotOptions.FovColor, function(Callback)
    Drawings.SilentAim.Fov.Color = Callback
    Drawings.SilentAim.Snaplines.Color = Callback
    Save();
end)
ConfigSection.Slider("Fov Size", {Min = 70, Max = 500, Default = AimbotOptions.FovSize, Step = 10}, function(Callback)
    AimbotOptions.FovSize = Callback
    Drawings.SilentAim.Fov.Radius = Callback
    Save();
end)
ConfigSection.Toggle("Enable Snaplines", AimbotOptions.Snaplines, function(Callback)
    AimbotOptions.Snaplines = Callback
    Save();
end)

if (not isfile("fates-esp.json")) then
    Save();
end