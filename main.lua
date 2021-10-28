if (Activated) then
	return
end

local game = game
if (not game.IsLoaded(game)) then
    local Loaded = game.Loaded
    Loaded.Wait(Loaded);
end

local Drawing = Drawing or loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/fatesc/Roblox-Drawing-Lib/main/main.lua"))();

local GetService = game.GetService
local Services = setmetatable({
    RunService = GetService(game, "RunService"),
    Players = GetService(game, "Players"),
    UserInputService = GetService(game, "UserInputService"),
    Workspace = GetService(game, "Workspace"),
    HttpService = GetService(game, "HttpService")
}, {
    __index = function(self, Property)
        local NoError, Service = pcall(GetService, game, Property);
        if (NoError) then
            self[Property] = Service
            return Service
        end
    end
})

local GetPlayers = Services.Players.GetPlayers
local JSONEncode, JSONDecode, GenerateGUID = 
    Services.HttpService.JSONEncode, 
    Services.HttpService.JSONDecode,
    Services.HttpService.GenerateGUID

local GetPropertyChangedSignal, Changed = 
    game.GetPropertyChangedSignal,
    game.Changed

local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local IsA = game.IsA
local FindFirstChild, FindFirstChildWhichIsA, WaitForChild = 
    game.FindFirstChild,
    game.FindFirstChildWhichIsA,
    game.WaitForChild

local Tfind, sort, concat, pack, unpack;
do
    local table = table
    Tfind, sort, concat, pack, unpack = 
        table.find, 
        table.sort,
        table.concat,
        table.pack,
        table.unpack
end

local lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte;
do
    local string = string
    lower, Sfind, split, sub, format, len, match, gmatch, gsub, byte = 
        string.lower,
        string.find,
        string.split, 
        string.sub,
        string.format,
        string.len,
        string.match,
        string.gmatch,
        string.gsub,
        string.byte
end

local random, floor, round, abs, atan, cos, sin, rad;
do
    local math = math
    random, floor, round, abs, atan, cos, sin, rad, clamp = 
        math.random,
        math.floor,
        math.round,
        math.abs,
        math.atan,
        math.cos,
        math.sin,
        math.rad,
        math.clamp
end

local Instancenew = Instance.new
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
local ToHSV = Color3new().ToHSV

local Camera = Services.Workspace.CurrentCamera
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer.GetMouse(LocalPlayer);

local Destroy, Clone = game.Destroy, game.Clone

local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect

local Disconnect;
do
    local CalledConnection = CConnect(Connection, function() end);
    Disconnect = CalledConnection.Disconnect
end

local GetCharacter = GetCharacter or function(Plr)
    if (Plr) then
        return Plr.Character or false
    end
end

local hookfunction, getconnections;
do
    local GEnv = getgenv();

    local newcclosure = newcclosure or function(f)
        return f
    end

    hookfunction = GEnv.hookfunction or function(func, newfunc, applycclosure)
        if (replaceclosure) then
            replaceclosure(func, newfunc);
            return func
        end
        func = applycclosure and newcclosure or newfunc
        return func
    end

    local CachedConnections = setmetatable({}, {
        mode = "v"
    });
    getconnections = function(Connection, FromCache)
        local getconnections = GEnv.getconnections
        if (not getconnections) then
            return {}
        end
        
        local CachedConnection;
        for i, v in next, CachedConnections do
            if (i == Connection) then
                CachedConnection = v
                break;
            end
        end
        if (CachedConnection and FromCache) then
            return CachedConnection
        end

        local Connections = GEnv.getconnections(Connection);
        CachedConnections[Connection] = Connections
        return Connections
    end
end

local Connections = {}
local AddConnection = function(...)
    local ConnectionsToAdd = {...}
    for i = 1, #ConnectionsToAdd do
        Connections[#Connections + 1] = ConnectionsToAdd[i]
    end
    return ...
end

local getrawmetatable = getrawmetatable or function()
    return setmetatable({}, {});
end

local getnamecallmethod = getnamecallmethod or function()
    return ""
end

local checkcaller = checkcaller or function()
    return false
end

local getgc = getgc or function()
    return {}
end

local hookmetamethod = hookmetamethod or function(metatable, metamethod, func)
    setreadonly(metatable, false);
    Old = hookfunction(metatable[metamethod], func, true);
    setreadonly(metatable, true);
    return Old
end

local GetAllParents = function(Instance_)
    if (typeof(Instance_) == 'Instance') then
        local Parents = {}
        local Current = Instance_
        repeat
            local Parent = Current.Parent
            Parents[#Parents + 1] = Parent
            Current = Parent
        until not Current
        return Parents
    end
    return {}
end

local filter = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            if (ret(i, v)) then
                new[#new + 1] = v
            end
        end
        return new
    end
end

local ISPF, PF_Network, PF_Client, GetBodyParts, GunTbl, Trajectory
if (game.PlaceId == 292439477) then
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
        local Char = BB_Network.Characters.GetCharacter(BB_Network.Characters, Plr);
        if (Char and Char.Body) then
            Plr.Character = Char.Body
        end
        return Plr and Plr.Character or nil
    end
    local function BB_GetTeamColor(rgb)
        return Color3new(math.min(rgb.r * 1.3, 1), math.min(rgb.g * 1.3, 1), math.min(rgb.b * 1.3, 1));
    end
    local BB_Teams = BB_Network.Teams
    for i, v in next, GetPlayers(Players) do
        local Team = BB_Teams.GetPlayerTeam(BB_Teams, v);
        v.TeamColor = BrickColornew(BB_GetTeamColor(BB_Teams.Colors[Team]));
    end
    BB_Teams.TeamChanged.Connect(BB_Teams.TeamChanged, function(Plr, Team)
        Plr.TeamColor = BrickColornew(BB_GetTeamColor(BB_Teams.Colors[Team]));
    end)
end
local ISCB = game.PlaceId == 301549746

local SilentAimingPlayer = nil
local SilentAimHitChance = 100
local AimBone = "Head"
local Wallbang = true

local Methods = {
    "FindFirstChild",
    "FindFirstChildWhichIsA",
    "FindFirstChildOfClass",
    "IsA"
}

local ProtectedInstances = {}
local ProtectInstance = function(Instance_)
    if (not Tfind(ProtectedInstances, Instance_)) then
        ProtectedInstances[#ProtectedInstances + 1] = Instance_
    end
end

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
local MetaMethodHooks = {}

local CameraModule = FindFirstChild(LocalPlayer.PlayerScripts, "CameraModule", true)

MetaMethodHooks.Namecall = function(...)
    local __Namecall = OldMetaMethods.__namecall
    local Method = gsub(getnamecallmethod(), "%z.*", "");
    local Args = {...}
    local self = Args[1]
    if (checkcaller()) then
        return __Namecall(...);
    end

    if (not ISPF and self == Services.Workspace and Method == "FindPartOnRay" and SilentAimingPlayer and getcallingscript() ~= CameraModule) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then  
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3new(random(1, 10), random(1, 10), random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
            end
        end
    end

    if (not ISPF and self == Services.Workspace and Method == "FindPartOnRayWithIgnoreList" and SilentAimingPlayer and getcallingscript() ~= CameraModule) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = random(1, 100) < SilentAimHitChance
        
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                if (not ISCB) then
                    return Char[AimBone], Char[AimBone].Position + (Vector3new(random(1, 10), random(1, 10), random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
                end
                Args[2] = Ray.new(Args[1].Origin, (Char[AimBone].Position - Args[2].Origin));
                return __Namecall(unpack(Args));
            end
        end
    end

    local Protected = Tfind(ProtectedInstances, self);

    if (Protected) then
        if (Tfind(Methods, Method)) then
            return Method == "IsA" and false or nil
        end
    end

    if (Method == "GetChildren" or Method == "GetDescendants") then
        return filter(__Namecall(...), function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end

    if (Method == "GetFocusedTextBox") then
        if (Tfind(ProtectedInstances, __Namecall(...))) then
            return nil
        end
    end

    return __Namecall(...);
end

MetaMethodHooks.Index = function(...)
    local __Index = OldMetaMethods.__index

    local Instance_, Index = ...

    if (checkcaller()) then
        if (Index == "HumanoidRootPart" and ISBB) then
            return __Index(Instance_, "Chest")
        end
        return __Index(Instance_, Index);
    end

    local SanitisedIndex = Index
    if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
        SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
    end

    if (Instance_ == Mouse and SilentAimingPlayer and getcallingscript() ~= CameraModule) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local ViewportPoint = WorldToViewportPoint(Camera, Char[AimBone].Position);
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (lower(SanitisedIndex) == "target") then
                if (Viewable or Wallbang) then
                    return Char[AimBone]
                end
            elseif (lower(SanitisedIndex) == "hit" and (Viewable or Wallbang)) then
                if (Viewable or Wallbang) then
                    return Char[AimBone].CFrame * CFramenew(random(1, 10) / 10, random(1, 10) / 10, random(1, 10) / 10);
                end
            elseif (lower(SanitisedIndex) == "x" and (Viewable or Wallbang)) then
                return ViewportPoint.X + (random(1, 10) / 10);
            elseif (SanitisedIndex == "y" and (Viewable or Wallbang)) then
                return ViewportPoint.Y + (random(1, 10) / 10);
            end
        end
    end

    if (Tfind(ProtectedInstances, __Index(...))) then
        return nil
    end

    return __Index(...);
end

MetaMethodHooks.NewIndex = function(...)
    local __NewIndex = OldMetaMethods.__newindex
    local Instance_, Index, Value = ...
    if (checkcaller()) then
        if (Index == "Parent") then
            local ProtectedInstance = Tfind(ProtectedInstances, Instance_)
            if (ProtectedInstance) then
                local Parents = GetAllParents(Value);
                for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                    v.Disable(v);
                end
                for i = 1, #Parents do
                    local Parent = Parents[i]
                    for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                        v.Disable(v);
                    end
                end
                local Ret = __NewIndex(...);
                for i = 1, #Parents do
                    local Parent = Parents[i]
                    for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                        v.Enable(v);
                    end
                end
                for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                    v.Enable(v);
                end
                return Ret
            end
        end
    end
    return __NewIndex(...);
end

OldMetaMethods.__namecall = hookmetamethod(game, "__namecall", MetaMethodHooks.Namecall);
OldMetaMethods.__index = hookmetamethod(game, "__index", MetaMethodHooks.Index);
OldMetaMethods.__newindex = hookmetamethod(game, "__newindex", MetaMethodHooks.NewIndex);

local OldFindFirstChild
OldFindFirstChild = hookfunction(FindFirstChild, newcclosure(function(...)
    if (checkcaller()) then
        local Args = {...}
        if (Args[2] == "HumanoidRootPart" and ISBB) then
            Args[2] = "Chest"
            return OldFindFirstChild(unpack(Args));
        end
    end
    return OldFindFirstChild(...);
end));

local OldGetChildren
OldGetChildren = hookfunction(game.GetChildren, newcclosure(function(...)
    if (not checkcaller()) then
        local Children = OldGetChildren(...);
        return filter(Children, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return OldGetChildren(...);
end));

local OldGetDescendants
OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = OldGetDescendants(...);
        return filter(Descendants, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return OldGetDescendants(...);
end));

local OldFindPartOnRay
OldFindPartOnRay = hookfunction(Workspace.FindPartOnRay, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer) then
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Viewable or Wallbang) then
                return Char[AimBone], Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10), Vector3new(0, 1, 0), Char[AimBone].Material
            end
        end
    end
    return OldFindPartOnRay(...);
end))

local OldFindPartOnRayWithIgnoreList
OldFindPartOnRayWithIgnoreList = hookfunction(Workspace.FindPartOnRayWithIgnoreList, newcclosure(function(...)
    if (not ISPF and SilentAimingPlayer) then
        local Args = {...}
        local Char = GetCharacter(SilentAimingPlayer);
        local Chance = math.random(1, 100) < SilentAimHitChance
        if (Char and Char[AimBone] and Chance) then
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
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
end));

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
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Char and Char[AimBone] and Chance and (Viewable or Wallbang)) then
                local AimPos = Char[AimBone].Position + (Vector3new(math.random(1, 10), math.random(1, 10), math.random(1, 10)) / 10);
                Args[3].bullets[1][1] = Trajectory(PF_Client.basecframe * Vector3new(0, 0, 1), Vector3new(0, -Workspace.Gravity, 0), AimPos, GunTbl.currentgun.data.bulletspeed);
      
                OldSend(Args[1], "newbullets", Args[3], Args[4]);
                OldSend(Args[1], "bullethit", SilentAimingPlayer, AimPos, GetCharacter(SilentAimingPlayer).Head, Args[3].bullets[1][2]);
                return
            end
        end
        return OldSend(...);
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
            local Viewable = not next(GetPartsObscuringTarget(Camera, {Camera.CFrame.Position, Char[AimBone].Position}, {LocalPlayer.Character, Char}));
            if (Char and Char[AimBone] and Chance and (Viewable or Wallbang)) then
                Args[3] = Char[AimBone].Position - Args[4]
                return OldInitProjectile(unpack(Args));
            end
        end
        return OldInitProjectile(...);
    end
end


local Window

local Load = function()
    local Succ, Settings = pcall(JSONDecode, Services.HttpService, readfile("fates-esp.json"));
    if (type(Settings) ~= 'table') then
        delfile("fates-esp.json");
        return nil
    end
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

local Settings = isfile("fates-esp.json") and Load() or {
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
        BoxEsp = false,
        RenderDistance = 7000
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
                    local H, S, V = ToHSV(v2);
                    NewSettings[i][i2] = {H, S, V}
                elseif (typeof(v2) == "UDim2") then
                    local Pos = Window.GetPosition();
                    NewSettings[i][i2] = {Pos.X.Scale, Pos.X.Offset, Pos.Y.Scale, Pos.Y.Offset}
                end
            end
        end
        writefile("fates-esp.json", JSONEncode(Services.HttpService, NewSettings));
        Settings = Load();
        TracerOptions, EspOptions, AimbotOptions, UIOptions = Settings.TracerOptions, Settings.EspOptions, Settings.AimbotOptions, Settings.UIOptions
        Debounce = tick();
    end
end

local GetPart = function(Part, Char)
    if (not Char) then
        return false
    end
    if (FindFirstChild(Char, Part)) then
        return Part
    end
    if (Part == "Torso") then
        return "UpperTorso"
    elseif (Part == "Right Arm") then
        return "RightUpperArm"
    elseif (Part == "Left Arm") then
        return "LeftUpperArm"
    elseif (Part == "Right Leg") then
        Part = "RightLowerLeg"
    elseif (Part == "Left Leg") then
        return "LeftLowerLeg"
    end
    return Part
end

local GetVector2 = function(Plr, To)
    local Char = GetCharacter(Plr);
    To =  FindFirstChild(Char, GetPart(To, Char) or AimBone);
    if (Plr and Char and To) then
        return WorldToViewportPoint(Camera, To.Position);
    else
        return false
    end
end

local GetHumanoid = function(Plr)
    local Char = GetCharacter(Plr);
    local Humanoid = FindFirstChildWhichIsA(Char, "Humanoid")
    if (Char and Humanoid) then
        return Humanoid
    else
        return false
    end
end

local GetMagnitude = function(Plr)
    local Char = GetCharacter(Plr);
    local Part = FindFirstChild(Char, "HumanoidRootPart") or FindFirstChild(Char, "Chest");
    if (Char and Part) then
        local LPChar = GetCharacter(LocalPlayer);
        if (LPChar) then
            local HumanoidRootPart = FindFirstChild(LPChar, "HumanoidRootPart") or FindFirstChild(LPChar, "Chest");
            if (HumanoidRootPart) then
                return (Part.Position - HumanoidRootPart.Position).Magnitude
            end
        end
    end
    return math.huge
end

local Drawings = {}
local MainUI
local KillScript = function()
    for i = 1, #Connections do
        Disconnect(Connections[i]);
    end
	if (MainUI) then
        Destroy(MainUI);
    end
    for Player, PlayerDrawings in next, Drawings do
        for i, Drawing in next, PlayerDrawings do
            Drawing.Visible = false
            Drawing.Remove(Drawing);
        end
    end
    setreadonly(mt, false);
    mt = OldMetaMethods
    setreadonly(mt, true);
	getgenv().Activated = nil
end

local AddDrawing = function(Plr)
    local Tracer = Drawingnew("Line");
    local Text = Drawingnew("Text");
    local Box = Drawingnew("Quad");
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

end
local RemoveDrawing = function(Plr)
    local PlrDrawings = Drawings[Plr]
    if (PlrDrawings) then
        for i, Drawing_ in next, PlrDrawings do
            if (Drawing_.Remove) then
                Drawing_.Remove(Drawing_);
            end
        end
        Drawings[Plr] = nil
    end
end

for i, v in next, GetPlayers(Services.Players) do
    if (v ~= LocalPlayer) then
        AddDrawing(v);
    end
end
AddConnection(CConnect(Services.Players.PlayerAdded, AddDrawing));
AddConnection(CConnect(Services.Players.PlayerRemoving, RemoveDrawing));

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

local SilentAim = Drawings["SilentAim"]

    local Circle, Snaplines = SilentAim.Fov, SilentAim.Snaplines

    local TargetCursor = nil
    local TargetCharacter = nil
    local TargetAimbone = nil
    local TargetTuple = nil
    local TargetViewable = false
    local Vector2Distance = math.huge
    local Vector3Distance = math.huge

local Render = AddConnection(CConnect(Services.RunService.RenderStepped, function()
    local MouseVector = Vector2new(Mouse.X, Mouse.Y + 36);

    Circle.Position = MouseVector
    Snaplines.From = MouseVector
    Snaplines.Visible = false
    
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

        local TTeam, LTeam = i.Team, LocalPlayer.Team

        if (EspOptions.Team == "All") then
            
        elseif (EspOptions.Team == "Allies" and TTeam ~= LTeam) then
            v.Tracer.Visible = false
            v.Text.Visible = false
            v.Box.Visible = false
            continue
        elseif (EspOptions.Team == "Enemies" and TTeam == LTeam) then
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
            if (Magnitude >= EspOptions.RenderDistance and not (ISBB or ISPF or ISCB)) then
                v.Text.Visible = false
                v.Box.Visible = false
                v.Tracer.Visible = false
                continue
            end
            v.Text.Position = Vector2new(TextTuple.X, TextTuple.Y - 40);
            v.Text.Text = format(("%s\n%s %s"), EspOptions.Names and i.Name or "", EspOptions.Distance and format("[%s]", (math.floor(Magnitude or math.huge))) or "", EspOptions.Health and format("[%s/%s]", math.floor(Humanoid.Health), math.floor(Humanoid.MaxHealth)) or "");
            if (EspOptions.TeamColors) then
                local Color = BrickColornew(tostring(i.TeamColor)).Color
                v.Text.Color = Color
                v.Box.Color = Color
            end

            if (EspOptions.BoxEsp) then
                local Parts = {}
                for i2, Part in next, GetChildren(Char) do
                    if (IsA(Part, "BasePart")) then
                        local ViewportPos = WorldToViewportPoint(Camera, Part.Position);
                        Parts[Part] = Vector2new(ViewportPos.X, ViewportPos.Y);
                    end
                end

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
        if (Char and FindFirstChild(Char, "HumanoidRootPart") and FindFirstChild(Char, Part)) then
            local Tuple, Viewable = Camera.WorldToViewportPoint(Camera, Char[AimBone].Position);
            local Vector2Magnitude = (MouseVector - Vector2new(Tuple.X, Tuple.Y)).Magnitude
            local Vector3Magnitide = GetMagnitude(i);
            if (Viewable and Vector2Magnitude <= Vector2Distance and Vector2Magnitude <= AimbotOptions.FovSize) then
                TargetCursor = i
                TargetAimbone = AimbotOptions.ClosestCursor and Char[AimBone] or TargetAimbone
                TargetTuple = AimbotOptions.ClosestCursor and Tuple or TargetTuple
                TargetViewable = AimbotOptions.ClosestCursor and Viewable or TargetViewable
                Vector2Distance = Vector2Magnitude
                
                if (AimbotOptions.Snaplines) then
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
end))


local UIElements = Services.InsertService:LoadLocalAsset("rbxassetid://6945229203");
local GuiObjects = UIElements.GuiObjects
local UILibrary = {}
local Utils = {}

local Colors = {
	PageTextPressed = Color3fromRGB(200, 200, 200);
	PageBackgroundPressed = Color3fromRGB(15, 15, 15);
	PageBorderPressed = Color3fromRGB(20, 20, 20);
	PageTextHover = Color3fromRGB(175, 175, 175);
	PageBackgroundHover = Color3fromRGB(16, 16, 16);
	PageTextIdle = Color3fromRGB(150, 150, 150);
	PageBackgroundIdle = Color3fromRGB(18, 18, 18);
	PageBorderIdle = Color3fromRGB(18, 18, 18);
	ElementBackground = Color3fromRGB(25, 25, 25);
}


local CThread;
do
    local wrap = coroutine.wrap
    CThread = function(Func, ...)
        if (type(Func) ~= 'function') then
            return nil
        end
        local Varag = ...
        return function()
            local Success, Ret = pcall(wrap(Func, Varag));
            if (Success) then
                return Ret
            end
            if (Debug) then
                warn("[FA Error]: " .. debug.traceback(Ret));
            end
        end
    end
end

local Debounce = function(Func)
	local Debounce_ = false
	return function(...)
		if (not Debounce_) then
			Debounce_ = true
			Func(...);
			Debounce_ = false
		end
	end
end

local function RandomString(Length)
	local String = ""
	for _ = 1, Length do
		String = String .. char(random(65, 122))
	end
	return String
end

local Guis = {}
local ParentGui = function(Gui, Parent)
    Gui.Name = sub(gsub(GenerateGUID(Services.HttpService, false), '-', ''), 1, random(25, 30))
    Gui.DisplayOrder = 69420
    Gui.ResetOnSpawn = false
    ProtectInstance(Gui);
    Gui.Parent = Parent or Services.CoreGui
    Guis[#Guis + 1] = Gui
    return Gui
end

local Utils = {}

Utils.SmoothScroll = function(content, SmoothingFactor) -- by Elttob
	content.ScrollingEnabled = false

	local input = Clone(content);
	
	input.ClearAllChildren(input);
	input.BackgroundTransparency = 1
	input.ScrollBarImageTransparency = 1
	input.ZIndex = content.ZIndex + 1
	input.Name = "_smoothinputframe"
	input.ScrollingEnabled = true
	input.Parent = content.Parent

	local function syncProperty(prop)
        AddConnection(CConnect(GetPropertyChangedSignal(content, prop), function()
			if prop == "ZIndex" then
				input[prop] = content[prop] + 1
			else
				input[prop] = content[prop]
			end
		end));
	end

	syncProperty "CanvasSize"
	syncProperty "Position"
	syncProperty "Rotation"
	syncProperty "ScrollingDirection"
	syncProperty "ScrollBarThickness"
	syncProperty "BorderSizePixel"
	syncProperty "ElasticBehavior"
	syncProperty "SizeConstraint"
	syncProperty "ZIndex"
	syncProperty "BorderColor3"
	syncProperty "Size"
	syncProperty "AnchorPoint"
	syncProperty "Visible"

	local smoothConnection = AddConnection(CConnect(Services.RunService.RenderStepped, function()
		local a = content.CanvasPosition
		local b = input.CanvasPosition
		local c = SmoothingFactor
		local d = (b - a) * c + a
		
		content.CanvasPosition = d
	end));

	AddConnection(CConnect(content.AncestryChanged, function()
		if content.Parent == nil then
			Destroy(input);
			Disconnect(smoothConnection);
		end
	end));
end

do
    local TweenService = Services.TweenService
    Utils.Tween = function(Object, Style, Direction, Time, Goal)
        local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
        local Tween = TweenService.Create(TweenService, Object, TInfo, Goal)
        Tween.Play(Tween);   
        return Tween
    end
end

Utils.MultColor3 = function(Color, Delta)
	return Color3new(clamp(Color.R * Delta, 0, 1), clamp(Color.G * Delta, 0, 1), clamp(Color.B * Delta, 0, 1))
end

Utils.Draggable = function(UI, DragUi)
	local DragSpeed = 0
	local StartPos
	local DragToggle, DragInput, DragStart

	if not DragUi then
		DragUi = UI
	end
	
	local function UpdateInput(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y);

		Utils.Tween(UI, "Linear", "Out", .25, {
			Position = Position
		});
	end
    local CoreGui = Services.CoreGui
    local UserInputService = Services.UserInputService

	AddConnection(CConnect(UI.InputBegan, function(Input)
		if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not UserInputService.GetFocusedTextBox(UserInputService)) then
			DragToggle = true
			DragStart = Input.Position
			StartPos = UI.Position

			local Objects = CoreGui.GetGuiObjectsAtPosition(CoreGui, DragStart.X, DragStart.Y);

			AddConnection(CConnect(Input.Changed, function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					DragToggle = false
				end
			end));
		end
	end));

	AddConnection(CConnect(UI.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			DragInput = Input
		end
	end));

	AddConnection(CConnect(UserInputService.InputChanged, function(Input)
		if (Input == DragInput and DragToggle) then
			UpdateInput(Input);
		end
	end));
end

Utils.Click = function(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9);
	}

	local Press = {
		[Goal] = Utils.MultColor3(Object[Goal], 1.2);
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	AddConnection(CConnect(Object.MouseEnter, function()
		Utils.Tween(Object, "Quad", "Out", .25, Hover);
	end))

	AddConnection(CConnect(Object.MouseLeave, function()
		Utils.Tween(Object, "Quad", "Out", .25, Origin);
	end));

	AddConnection(CConnect(Object.MouseButton1Down, function()
		Utils.Tween(Object, "Quad", "Out", .3, Press);
	end));

    AddConnection(CConnect(Object.MouseButton1Up, function()
		Utils.Tween(Object, "Quad", "Out", .4, Hover);
	end));
end

Utils.Hover = function(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9);
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	AddConnection(CConnect(Object.MouseEnter, function()
		Utils.Tween(Object, "Sine", "Out", .5, Hover);
	end));

	AddConnection(CConnect(Object.MouseLeave, function()
		Utils.Tween(Object, "Sine", "Out", .5, Origin);
	end));
end

Utils.Blink = function(Object, Goal, Color1, Color2, Time)
	local Normal = {
		[Goal] = Color1
	}

	local Blink = {
		[Goal] = Color2
	}
	
	CThread(function()
		local T1 = Utils.Tween(Object, "Quad", "Out", Time, Blink).Completed
        T1.Wait(T1);
        local T2 = Utils.Tween(Object, "Quad", "Out", Time, Normal);
	end)()
end

Utils.TweenTrans = function(Object, Transparency)
	local Properties = {
		TextBox = "TextTransparency",
		TextLabel = "TextTransparency",
		TextButton = "TextTransparency",
		ImageButton = "ImageTransparency",
		ImageLabel = "ImageTransparency"
	}

    local Descendants = GetDescendants(Object);
	for i = 1, #Descendants do
        local Instance_ = Descendants[i]
		if (IsA(Instance_, "GuiObject")) then
			for Class, Property in next, Properties do
				if (IsA(Instance_, Class) and Instance_[Property] ~= 1) then
					Utils.Tween(Instance_, "Quad", "Out", .5, {
						[Property] = Transparency
					});
					break
				end
			end
			if Instance_.Name == "Overlay" and Transparency == 0 then -- check for overlay
				Utils.Tween(Object, "Quad", "Out", .5, {
					BackgroundTransparency = .5
				});
			elseif (Instance_.BackgroundTransparency ~= 1) then
				Utils.Tween(Instance_, "Quad", "Out", .5, {
					BackgroundTransparency = Transparency
				});
			end
		end
	end

	return Utils.Tween(Object, "Quad", "Out", .5, {
		BackgroundTransparency = Transparency
	});
end

Utils.Intro = function(Object)
	local Frame = Instancenew("Frame")
	local UICorner = Instancenew("UICorner")
	local CornerRadius = Object:FindFirstChild("UICorner") and Object.UICorner.CornerRadius or UDim.new(0, 0)

	Frame.Name = "IntroFrame"
	Frame.ZIndex = 1000
	Frame.Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.Position = UDim2.new(Object.Position.X.Scale, Object.Position.X.Offset + (Object.AbsoluteSize.X / 2), Object.Position.Y.Scale, Object.Position.Y.Offset + (Object.AbsoluteSize.Y / 2))
	Frame.BackgroundColor3 = Object.BackgroundColor3
	Frame.BorderSizePixel = 0

	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Frame

	Frame.Parent = Object.Parent

	if (Object.Visible) then
		Frame.BackgroundTransparency = 1

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 0
		});

        CWait(Tween.Completed);
		Object.Visible = false

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(0, 0);
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = UDimnew(1, 0);
		});

		CWait(Tween.Completed);
		Destroy(Frame);
	else
		Frame.Visible = true
		Frame.Size = UDim2.fromOffset(0, 0)
		UICorner.CornerRadius = UDimnew(1, 0)

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y);
		});

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = CornerRadius
		});

		CWait(Tween.Completed);
		Object.Visible = true

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 1
		});

		CWait(Tween.Completed);
		Destroy(Frame);
	end
end

Utils.MakeGradient = function(ColorTable)
	local Table = {}
	for Time, Color in pairs(ColorTable) do
		Table[#Table + 1] = ColorSequenceKeypoint.new(Time, Color)
	end
	return ColorSequence.new(Table)
end

UILibrary.__index = UILibrary

UILibrary.new = function(ColorTheme)
	assert(typeof(ColorTheme) == "Color3", "[UI] ColorTheme must be a Color3.");

	local NewUI = {}
	local UI = Instancenew("ScreenGui");
	setmetatable(NewUI, UILibrary)
	ParentGui(UI);
    MainUI = UI
	NewUI.UI = UI
	NewUI.ColorTheme = ColorTheme
	return NewUI
end

function UILibrary:LoadWindow(Title, Size)
	local Window = Clone(GuiObjects.Load.Window);
	local Main = Window.Main
	local Overlay = Main.Overlay
	local OverlayMain = Overlay.Main
	local ColorPicker = OverlayMain.ColorPicker
	local Settings = OverlayMain.Settings
	local ClosePicker = OverlayMain.Close
	local ColorCanvas = ColorPicker.ColorCanvas
	local ColorSlider = ColorPicker.ColorSlider
	local ColorGradient = ColorCanvas.ColorGradient
	local DarkGradient = ColorGradient.DarkGradient
	local CanvasBar = ColorGradient.Bar
	local RainbowGradient = ColorSlider.RainbowGradient
	local SliderBar = RainbowGradient.Bar
	local CanvasHitbox = ColorCanvas.Hitbox
	local SliderHitbox = ColorSlider.Hitbox
	local ColorPreview = Settings.ColorPreview
	local ColorOptions = Settings.Options
	local RedTextBox = ColorOptions.Red.TextBox
	local BlueTextBox = ColorOptions.Blue.TextBox
	local GreenTextBox = ColorOptions.Green.TextBox
	local RainbowToggle = ColorOptions.Rainbow
	Utils.Click(OverlayMain.Close, "BackgroundColor3");
	
	Window.Size = Size
	Window.Position = UDim2new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2);
	Window.Main.Title.Text = Title
	Window.Parent = self.UI
	
	Utils.Draggable(Window);

	local Idle = false
	local LeftWindow = false
	local Timer = tick();
	AddConnection(CConnect(Window.MouseEnter, function()
		LeftWindow = false
		if Idle then
			Idle = false
			Utils.TweenTrans(Window, 0)
		end
	end));
	AddConnection(CConnect(Window.MouseLeave, function()
		LeftWindow = true
		Timer = tick();
	end))
	
	AddConnection(CConnect(Services.RunService.RenderStepped, function()
		if LeftWindow then
			local Time = tick() - Timer
			if Time >= 3 and not Idle then
				Utils.TweenTrans(Window, .75);
				Idle = true
			end
		end
	end));
	
	
	local WindowLibrary = {}
	local PageCount = 0
	local SelectedPage
	
	WindowLibrary.GetPosition = function()
		return Window.Position
	end
	WindowLibrary.SetPosition = function(NewPos)
		Window.Position = NewPos
	end

	function WindowLibrary.NewPage(Title)
		local Page = Clone(GuiObjects.New.Page);
		local TextButton = Clone(GuiObjects.New.TextButton);

		if (PageCount == 0) then
			TextButton.TextColor3 = Colors.PageTextPressed
			TextButton.BackgroundColor3 = Colors.PageBackgroundPressed
			TextButton.BorderColor3 = Colors.PageBorderPressed
			SelectedPage = Page
		end
		
		AddConnection(CConnect(TextButton.MouseEnter, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextHover;
					BackgroundColor3 = Colors.PageBackgroundHover;
					BorderColor3 = Colors.PageBorderHover;
				});
			end
		end));
		
		AddConnection(CConnect(TextButton.MouseLeave, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				});
			end
		end));
		
		AddConnection(CConnect(TextButton.MouseButton1Down, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
				});
			end
		end));
		
		AddConnection(CConnect(TextButton.MouseButton1Click, function()
			if (SelectedPage.Name ~= TextButton.Name) then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
					BackgroundColor3 = Colors.PageBackgroundPressed;
					BorderColor3 = Colors.PageBorderPressed;
				});
				
				Utils.Tween(Window.Main.Selection[SelectedPage.Name], "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				});
				
				SelectedPage = Page
				Window.Main.Container.UIPageLayout:JumpTo(SelectedPage)
			end
		end));

		
		Page.Name = Title
		TextButton.Name = Title
		TextButton.Text = Title
		
		Page.Parent = Window.Main.Container
		TextButton.Parent = Window.Main.Selection
		
		PageCount = PageCount + 1
		
		local PageLibrary = {}
		
		function PageLibrary.NewSection(Title)
			local Section = GuiObjects.Section.Container:Clone()
			local SectionOptions = Section.Options
			local SectionUIListLayout = Section.Options.UIListLayout

			-- Utils.SmoothScroll(Section.Options, .14)
			Section.Title.Text = Title
			Section.Parent = Page.Selection
			
			AddConnection(CConnect(GetPropertyChangedSignal(SectionUIListLayout, "AbsoluteContentSize"), function()
				SectionOptions.CanvasSize = UDim2.fromOffset(0, SectionUIListLayout.AbsoluteContentSize.Y + 5)
			end))
			
			local ElementLibrary = {}
			
			
			local function ToggleFunction(Container, Enabled, Callback) -- fpr color picker
				local Switch = Container.Switch
				local Hitbox = Container.Hitbox
				Container.BackgroundColor3 = self.ColorTheme
				
				if (not Enabled) then
					Switch.Position = UDim2.fromOffset(2, 2);
					Container.BackgroundColor3 = Colors.ElementBackground
				end
				
				AddConnection(CConnect(Hitbox.MouseButton1Click, function()
					Enabled = not Enabled
					
					Utils.Tween(Switch, "Quad", "Out", .25, {
						Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
					});
					Utils.Tween(Container, "Quad", "Out", .25, {
						BackgroundColor3 = Enabled and self.ColorTheme or Colors.ElementBackground
					});
					
					Callback(Enabled);
				end));
			end
			
			
			function ElementLibrary.Toggle(Title, Enabled, Callback)
				local Toggle = Clone(GuiObjects.Elements.Toggle);
				local Container = Toggle.Container
				ToggleFunction(Container, Enabled, Callback);
				
				Toggle.Title.Text = Title
				Toggle.Parent = Section.Options
			end
			
			
			function ElementLibrary.Slider(Title, Args, Callback)
				local Slider = Clone(GuiObjects.Elements.Slider);
				local Container = Slider.Container
				local ContainerSliderBar = Container.SliderBar
				local BarFrame = ContainerSliderBar.BarFrame
				local Bar = BarFrame.Bar
				local Label = Bar.Label
				local Hitbox = Container.Hitbox
				
				Bar.BackgroundColor3 = self.ColorTheme
				Bar.Size = UDim2.fromScale(Args.Default / Args.Max, 1);
				Label.Text = tostring(Args.Default);
				Label.BackgroundTransparency = 1
				Label.TextTransparency = 1
				Container.Min.Text = tostring(Args.Min);
				Container.Max.Text = tostring(Args.Max);
				Slider.Title.Text = Title
								
				local Moving = false
				
				local function Update()
					local RightBound = BarFrame.AbsoluteSize.X
					local Position = clamp(Mouse.X - BarFrame.AbsolutePosition.X, 0, RightBound);
					local Value = Args.Min + (Args.Max - Args.Min) * (Position / RightBound) -- get difference then add min value, lol lerp
					
					Value = Value - (Value % Args.Step);
					Callback(Value);
					
					local Precent = Value / Args.Max
					local Size = UDim2.fromScale(Precent, 1);
					local Tween = Utils.Tween(Bar, "Linear", "Out", .05, {
						Size = Size
					});
					
					Label.Text = Value
					CWait(Tween.Completed);
				end
			
				AddConnection(CConnect(Hitbox.MouseButton1Down, function()
					Moving = true
					
					Utils.Tween(Label, "Quad", "Out", .25, {
						BackgroundTransparency = 0;
						TextTransparency = 0;
					});
					
					Update();
				end))
				
				AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
					if (Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving) then
						Moving = false
						
						Utils.Tween(Label, "Quad", "Out", .25, {
							BackgroundTransparency = 1;
							TextTransparency = 1;
						});
					end
				end));
				
				AddConnection(CConnect(Mouse.Move, Debounce(function()
					if Moving then
						Update()
					end
				end)))
				
				Slider.Parent = Section.Options
			end
			
			function ElementLibrary.ColorPicker(Title, DefaultColor, Callback)
				local SelectColor = Clone(GuiObjects.Elements.SelectColor);
				local CurrentColor = DefaultColor
				local Button = SelectColor.Button
							   
				local H, S, V = DefaultColor.ToHSV(DefaultColor);
				local Opened = false
				local Rainbow = false
				
				local function UpdateText()
					RedTextBox.PlaceholderText = tostring(floor(CurrentColor.R * 255));
					GreenTextBox.PlaceholderText = tostring(floor(CurrentColor.G * 255));
					BlueTextBox.PlaceholderText = tostring(floor(CurrentColor.B * 255));
				end
				
				local function UpdateColor()
					H, S, V = CurrentColor.ToHSV(CurrentColor);
					
					SliderBar.Position = UDim2new(0, 0, H, 2);
					CanvasBar.Position = UDim2new(S, 2, 1 - V, 2);
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[0] = Color3new(1, 1, 1);
						[1] = Color3fromHSV(H, 1, 1);
					});
					
					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText();
				end

				local function UpdateHue(Hue)
					SliderBar.Position = UDim2.new(0, 0, Hue, 2)
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[0] = Color3.new(1, 1, 1);
						[1] = Color3.fromHSV(Hue, 1, 1);
					})
					
					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText();
				end
				
				local function ColorSliderInit()
					local Moving = false
					
					local function Update()
						if Opened and not Rainbow then
							local LowerBound = SliderHitbox.AbsoluteSize.Y
							local Position = math.clamp(Mouse.Y - SliderHitbox.AbsolutePosition.Y, 0, LowerBound);
							local Value = Position / LowerBound
							
							H = Value
							CurrentColor = Color3.fromHSV(H, S, V);
							ColorPreview.BackgroundColor3 = CurrentColor
							ColorGradient.UIGradient.Color = Utils.MakeGradient({
								[0] = Color3.new(1, 1, 1);
								[1] = Color3.fromHSV(H, 1, 1);
							});
							
							UpdateText();
							
							local Position = UDim2.new(0, 0, Value, 2)
							local Tween = Utils.Tween(SliderBar, "Linear", "Out", .05, {
								Position = Position
							});
							
							Callback(CurrentColor)
							CWait(Tween.Completed);
						end
					end
				
					AddConnection(CConnect(SliderHitbox.MouseButton1Down, function()
						Moving = true
						Update()
					end))
					
					AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
						if (Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving) then
							Moving = false
						end
					end))
					
					AddConnection(CConnect(Mouse.Move, Debounce(function()
						if Moving then
							Update()
						end
					end)))
				end
				local function ColorCanvasInit()
					local Moving = false
					
					local function Update()
						if Opened then
							local LowerBound = CanvasHitbox.AbsoluteSize.Y
							local YPosition = clamp(Mouse.Y - CanvasHitbox.AbsolutePosition.Y, 0, LowerBound)
							local YValue = YPosition / LowerBound
							local RightBound = CanvasHitbox.AbsoluteSize.X
							local XPosition = clamp(Mouse.X - CanvasHitbox.AbsolutePosition.X, 0, RightBound)
							local XValue = XPosition / RightBound
							
							S = XValue
							V = 1 - YValue
							
							CurrentColor = Color3.fromHSV(H, S, V);
							ColorPreview.BackgroundColor3 = CurrentColor
							UpdateText();
							
							local Position = UDim2.new(XValue, 2, YValue, 2);
							local Tween = Utils.Tween(CanvasBar, "Linear", "Out", .05, {
								Position = Position
							});
							Callback(CurrentColor);
							CWait(Tween.Completed);
						end
					end
				
					AddConnection(CConnect(CanvasHitbox.MouseButton1Down, function()
						Moving = true
						Update();
					end));
					
					AddConnection(CConnect(Services.UserInputService.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
							Moving = false
						end
					end));
					
					AddConnection(CConnect(Mouse.Move, Debounce(function()
						if Moving then
							Update();
						end
					end)));
				end
				
				ColorSliderInit();
				ColorCanvasInit();
				
				AddConnection(CConnect(Button.MouseButton1Click, function()
					if not Opened then
						Opened = true
						UpdateColor()
						RainbowToggle.Container.Switch.Position = Rainbow and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
						RainbowToggle.Container.BackgroundColor3 = Rainbow and self.ColorTheme or Colors.ElementBackground
						Overlay.Visible = true
						OverlayMain.Visible = false
						Utils.Intro(OverlayMain)
					end
				end))
				
				AddConnection(CConnect(ClosePicker.MouseButton1Click, Debounce(function()
					Button.BackgroundColor3 = CurrentColor
					Utils.Intro(OverlayMain)
					Overlay.Visible = false
					Opened = false
				end)))
				
				AddConnection(CConnect(RedTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(RedTextBox.Text)
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(Number / 255, CurrentColor.G, CurrentColor.B);
							UpdateColor();
							RedTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						RedTextBox.Text = ""
					end
				end))
				
				AddConnection(CConnect(GreenTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(GreenTextBox.Text)
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(CurrentColor.R, Number / 255, CurrentColor.B);
							UpdateColor();
							GreenTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						GreenTextBox.Text = ""
					end
				end))
				
				AddConnection(CConnect(BlueTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(BlueTextBox.Text);
						if Number then
							Number = clamp(floor(Number), 0, 255);
							CurrentColor = Color3new(CurrentColor.R, CurrentColor.G, Number / 255);
							UpdateColor();
							BlueTextBox.PlaceholderText = tostring(Number);
							Callback(CurrentColor);
						end
						BlueTextBox.Text = ""
					end
				end))
				
				ToggleFunction(RainbowToggle.Container, false, function(Callback)
					if Opened then
						Rainbow = Callback
					end
				end)
				
				AddConnection(CConnect(Services.RunService.RenderStepped, function()
					if Rainbow then
						local Hue = (tick() / 5) % 1
						CurrentColor = Color3.fromHSV(Hue, S, V);
						
						if Opened then
							UpdateHue(Hue);
						end
						
						Button.BackgroundColor3 = CurrentColor
						Callback(CurrentColor);
					end
				end));
								
				Button.BackgroundColor3 = DefaultColor
				SelectColor.Title.Text = Title
				SelectColor.Parent = Section.Options
			end
			
			function ElementLibrary.Dropdown(Title, Options, Callback)
				local DropdownElement = GuiObjects.Elements.Dropdown.DropdownElement:Clone()
				local DropdownSelection = GuiObjects.Elements.Dropdown.DropdownSelection:Clone()
				local TextButton = GuiObjects.Elements.Dropdown.TextButton
				local Button = DropdownElement.Button
				local Opened = false
				local Size = (TextButton.Size.Y.Offset + 5) * #Options
				
				local function ToggleDropdown()
					Opened = not Opened
					
					if (Opened) then
						DropdownSelection.Frame.Visible = true
						DropdownSelection.Visible = true
						
						Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, Size)
						});
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 180
						});
					else
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 0
						});
						CWait(Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, 0)
						}).Completed);
						
						DropdownSelection.Frame.Visible = false
						DropdownSelection.Visible = false
					end
				end

				for _, v in next, Options do
					local Clone = Clone(TextButton);
					
					AddConnection(CConnect(Clone.MouseButton1Click, function()
						DropdownElement.Title.Text = Title .. ": " .. v
						Callback(v);
						ToggleDropdown();
					end))
					
					Utils.Click(Clone, "BackgroundColor3")
					Clone.Text = v
					Clone.Parent = DropdownSelection.Container
				end
				
				AddConnection(CConnect(Button.MouseButton1Click, ToggleDropdown));
				
				DropdownElement.Title.Text = Title
				DropdownSelection.Visible = false
				DropdownSelection.Frame.Visible = false
				DropdownSelection.Size = UDim2.new(1, -10, 0, 0)
				DropdownElement.Parent = Section.Options
				DropdownSelection.Parent = Section.Options
			end
			
			return ElementLibrary
			
		end
		
		return PageLibrary
	end
		
	return WindowLibrary
end

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
end)
TracersSection.Dropdown("To", {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}, function(Callback)
	TracerOptions.To = Callback
end)
TracersSection.Dropdown("From", {"Top", "Bottom", "Left", "Right"}, function(Callback)
    local ViewportSize = Camera.ViewportSize
    TracerOptions.From = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.From = Callback == "Top" and Vector2new(ViewportSize.X / 2, ViewportSize.Y - ViewportSize.Y) or Callback == "Bottom" and Vector2new(ViewportSize.X / 2, ViewportSize.Y) or Callback == "Left" and Vector2new(ViewportSize.X - ViewportSize.X, ViewportSize.Y / 2) or Callback == "Right" and Vector2new(ViewportSize.X, ViewportSize.Y / 2);
        end
    end
end)

TracersSection.Slider("Tracer Transparency", {Min = 0, Max = 1, Default = TracerOptions.Transparency, Step = .1}, function(Callback)
    TracerOptions.Transparency = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.Transparency = Callback
        end
    end
end)
TracersSection.Slider("Tracer Thickness", {Min = 0, Max = 5, Default = TracerOptions.Thickness, Step = .1}, function(Callback)
    TracerOptions.Thickness = Callback
    for i, v in next, Drawings do
        if (v.Tracer) then
            v.Tracer.Thickness = Callback
        end
    end
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
end)
EspSection.Toggle("Show Names", EspOptions.Names, function(Callback)
    EspOptions.Names = Callback
end)
EspSection.Toggle("Show Health", EspOptions.Health, function(Callback)
    EspOptions.Health = Callback
end)
EspSection.Toggle("Show Distance", EspOptions.Distance, function(Callback)
    EspOptions.Distance = Callback
end)
EspSection.Slider("Render Distance", {Min = 0, Max = 7000, Default = EspOptions.RenderDistance, Step = 10}, function(Callback)
    EspOptions.RenderDistance = Callback
end)
EspSection.Dropdown("Team", {"Allies", "Enemies", "All"}, function(Callback)
    EspOptions.Team = Callback
end)
EspSection.Toggle("Box Esp", EspOptions.BoxEsp, function(Callback)
    EspOptions.BoxEsp = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Visible = Callback
        end
    end
end)
EspSection.Slider("Box Thickness", {Min = 0, Max = 5, Default = EspOptions.Transparency, Step = .1}, function(Callback)
    EspOptions.Thickness = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Thickness = Callback
        end
    end
end)
EspSection.Slider("Box Transparency", {Min = 0, Max = 1, Default = EspOptions.Transparency, Step = .1}, function(Callback)
    EspOptions.Transparency = Callback
    for i, v in next, Drawings do
        if (v.Box) then
            v.Box.Transparency = Callback
        end
    end
end)
EspSection.Toggle("Kill Script", false, function(Callback)
    KillScript();
end)

AimbotSection.Toggle("Silent Aim", AimbotOptions.SilentAim, function(Callback)
    AimbotOptions.SilentAim = Callback
end)
AimbotSection.Toggle("Wallbang", Wallbang, function(Callback)
    Wallbang = Callback
end)
AimbotSection.Dropdown("Aimbone", {"Head","Torso"}, function(Callback)
	if (Callback == "Torso") then
        AimBone = ISBB and "Chest" or "HumanoidRootPart"
    else
        AimBone = Callback
    end
end)
AimbotSection.Slider("Hit Chance", {Min = 0, Max = 100, Default = SilentAimHitChance, Step = 1}, function(Callback)
    SilentAimHitChance = Callback
end)
AimbotSection.Toggle("3rd P Aimlock", AimbotOptions.ThirdPerson, function(Callback)
    AimbotOptions.ThirdPerson = Callback
end)
AimbotSection.Toggle("1st P Aimlock", AimbotOptions.FirstPerson, function(Callback)
    AimbotOptions.FirstPerson = Callback
end)
AimbotSection.Dropdown("Team", {"Allies", "Enemies", "All"}, function(Callback)
    AimbotOptions.Team = Callback
end)
AimbotSection.Dropdown("Lock Type", {"Closest Cursor", "Closest Player"}, function(Callback)
    if (Callback == "Closest Cursor") then
        AimbotOptions.ClosestCharacter = false
        AimbotOptions.ClosestCursor = true       
    else
        AimbotOptions.ClosestCharacter = true
        AimbotOptions.ClosestCursor = false
    end
end)

ConfigSection.Toggle("Show Fov", AimbotOptions.ShowFov, function(Callback)
    AimbotOptions.ShowFov = Callback
    Drawings.SilentAim.Fov.Visible = Callback
end)
ConfigSection.ColorPicker("Fov Color", AimbotOptions.FovColor, function(Callback)
    Drawings.SilentAim.Fov.Color = Callback
    Drawings.SilentAim.Snaplines.Color = Callback
end)
ConfigSection.Slider("Fov Size", {Min = 70, Max = 500, Default = AimbotOptions.FovSize, Step = 10}, function(Callback)
    AimbotOptions.FovSize = Callback
    Drawings.SilentAim.Fov.Radius = Callback
end)
ConfigSection.Toggle("Enable Snaplines", AimbotOptions.Snaplines, function(Callback)
    AimbotOptions.Snaplines = Callback
end)

if (not isfile("fates-esp.json")) then
    Save();
end

CThread(function()
    while wait(15) do
        if (UI) then
            Save();
        else
            break;
        end
    end
end)();

return KillScript