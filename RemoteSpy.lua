-- RemoteSpy Hooking Core for Murderer Duel aimbot
-- Based on richie0866/remote-spy hooking pattern
-- Load with: loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/gametil/murderer-duel/main/RemoteSpy.lua"))()

local FireServer = Instance.new("RemoteEvent").FireServer
local InvokeServer = Instance.new("RemoteFunction").InvokeServer
local IsA = game.IsA
local refs = {}

-- Serializer (from remote-spy's codify.ts)
local function codify(v, lvl)
	lvl = lvl or 0
	local t = typeof(v)
	if t == "string" then
		return string.format("%q", v)
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Vector3" then
		return string.format("Vector3.new(%.3f, %.3f, %.3f)", v.X, v.Y, v.Z)
	elseif t == "CFrame" then
		local c = v:GetComponents()
		return string.format("CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f)", table.unpack(c))
	elseif t == "Instance" then
		return v:GetFullName()
	elseif t == "table" then
		local parts = {}
		for k, val in pairs(v) do
			table.insert(parts, string.format("[%s]=%s", codify(k, lvl+1), codify(val, lvl+1)))
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	elseif t == "Ray" then
		return string.format("Ray.new(%s, %s)", codify(v.Origin), codify(v.Direction))
	elseif t == "Color3" then
		return string.format("Color3.new(%.3f, %.3f, %.3f)", v.R, v.G, v.B)
	else
		return tostring(v) .. " --[[" .. t .. "]]"
	end
end

local function onRemoteFired(self, method, args)
	local info = {}
	for i = 1, select("#", args) do
		info[i] = codify(select(i, args))
	end
	local params = table.concat(info, ", ")
	print(string.format("[SPY] %s :: %s(%s)", self:GetFullName(), method, params))
end

-- Hook RemoteEvent.FireServer
refs.FireServer = hookfunction(FireServer, function(self, ...)
	if self and typeof(self) == "Instance" and IsA(self, "RemoteEvent") then
		onRemoteFired(self, "FireServer", { ... })
	end
	return refs.FireServer(self, ...)
end)

-- Hook RemoteFunction.InvokeServer
refs.InvokeServer = hookfunction(InvokeServer, function(self, ...)
	if self and typeof(self) == "Instance" and IsA(self, "RemoteFunction") then
		onRemoteFired(self, "InvokeServer", { ... })
	end
	return refs.InvokeServer(self, ...)
end)

-- Hook __namecall (catches FireServer/InvokeServer called via : syntax)
refs.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	if IsA(self, "RemoteEvent") and method == "FireServer" then
		onRemoteFired(self, "FireServer", { ... })
	elseif IsA(self, "RemoteFunction") and method == "InvokeServer" then
		onRemoteFired(self, "InvokeServer", { ... })
	end
	return refs.__namecall(self, ...)
end)

print("[SPY] RemoteSpy hooks active — all remotes logged to console")
