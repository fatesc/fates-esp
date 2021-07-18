local game = game
local table = table
local Tfind = table.find
local string = string
local gsub, sub = string.gsub, string.sub

local getconnections = function(...)
    if (not getconnections) then
        return {}
    end
    return getconnections(...);
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

local newcclosure = newcclosure or function(f)
    return f
end

local hookmetamethod = hookmetamethod or function(metatable, metamethod, func)
    setreadonly(metatable, false);
    local Old = metatable.metamethod
    metatable.metamethod = newcclosure(func);
    setreadonly(metatable, true);
    return Old
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

local ProtectedInstances = {}
local Methods = {
    "FindFirstChild",
    "FindFirstChildWhichIsA",
    "FindFirstChildOfClass",
    "IsA"
}
local mt = getrawmetatable(game);
local OldMetaMethods = {}
for i, v in next, mt do
    OldMetaMethods[i] = v
end
local MetaMethodHooks = {}

MetaMethodHooks.Namecall = function(...)
    local __Namecall = OldMetaMethods.__namecall;
    local Args = {...}
    local self = Args[1]

    if (checkcaller()) then
        return __Namecall(...);
    end

    local Method = getnamecallmethod();
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
    local __Index = OldMetaMethods.__index;

    if (checkcaller()) then
        return __Index(...);
    end
    local Instance_, Index = ...

    local SanitisedIndex = Index
    if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
        SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
    end
    local ProtectedInstance = Tfind(ProtectedInstances, Instance_)

    if (ProtectedInstance) then
        if (Tfind(Methods, SanitisedIndex)) then
            return newcclosure(function()
                return SanitisedIndex == "IsA" and false or nil
            end);
        end
        -- if (SanitisedIndex == "ClassName") then -- enable this if you want
            -- return ""
        -- end
    end

    return __Index(...);
end

MetaMethodHooks.NewIndex = function(...)
    local __NewIndex = OldMetaMethods.__newindex
    local Instance_, Index, Value = ...
    if (checkcaller()) then
        if (Index == "Parent") then
            local ProtectedInstance = Tfind(ProtectedInstances, Instance_)
            if (ProtectedInstance and typeof(Value) == 'Instance') then
                local Parents = GetAllParents(Value);
                for i, v in next, getconnections(Parents[1].ChildAdded) do
                    v.Disable(v);
                end
                local Ret;
                for i = 1, #Parents do
                    local Parent = Parents[i]
                    for i2, v in next, getconnections(Parent.DescendantAdded) do
                        v.Disable(v);
                    end
                    Ret = __NewIndex(...);
                    for i2, v in next, getconnections(Parent.DescendantAdded) do
                        v.Enable(v);
                    end
                end
                for i, v in next, getconnections(Parents[1].ChildAdded) do
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

local ProtectInstance = function(Instance_)
    if (not Tfind(ProtectedInstances, Instance_)) then
        ProtectedInstances[#ProtectedInstances + 1] = Instance_
    end
end

return ProtectInstance