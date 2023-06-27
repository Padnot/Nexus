--Node/Client

local node = {}
node.__index = node
node.__metatable = function()
	return "Can not get metatable for node! | Node"
end

--Template
--Components
local _comp = script.Parent
	local _store = require(_comp.Storage)

--Utilities
local _utils = _comp.Parent.Utilities
	local _maid = require(_utils.Maid)

--Resources
local _res = _utils.Parent.Resources
	local _rm = _res.Remotes
		local _re = _rm.Events
		local _rf = _rm.Functions
	local _bn = _res.Binds
		local _be = _bn.Events
		local _bf = _bn.Events

if game:GetService("RunService"):IsClient() then
	--_comp.Host:Destroy() --Prevent host mentions
	node.Player = game.Players.LocalPlayer
	node.Character = node.Player.Character
	node.Player.CharacterAdded:Connect(function(c)
		node.Character = c
	end)
end


_be:ClearAllChildren()
_bf:ClearAllChildren()

function node.new(name,hostName,promise)
	if _store.Node[name] then promise:reject("Node name "..name.." already exists! | Node",debug.traceback()) return _store.Node[name] end
	local self = setmetatable({},node)

	self._events = {}
	self._functions = {}
	self.bindevents = {}
	self._bindfunctions = {}
	self._name = name
	self._type = "Node"
	self._maid = _maid.new()
	self._started = false
	self._initialized = false
	self._link = hostName
	self._promise = promise
	_store.Node[name] = self
	
	return self
end

function node:Start()
	self._started = true
end

function node:Init()
	self._initialized = true
end

function node:GetBindEvent(name)
	return self._bindevents[name]
end

function node:GetBindFunction(name)
	return self._bindfunctions[name]
end

function node:LinkHost(new)
	node._link = new
end

function node:RegisterBindEvent(name)
	self:Start()
	if self:GetBindEvent(name) then return self:GetBindEvent(name) end
	local bindevent = Instance.new("BindableEvent")
	bindevent.Name = name..self._name
	bindevent.Parent = _be
	self._bindevents[name] = bindevent
end

function node:ConnectBindEvent(name,callback)
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		self._maid:mark(name,bindevent.Event:Connect(callback))
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing bind-event) | Node",debug.traceback())
	end
end

function node:KitBindEvent(name,callback)
	self:RegisterBindEvent(name)
	self:ConnectBindEvent(name,callback)
end

function node:FireBindEvent(name,...)
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		bindevent:Fire(...)
	else
		self._promise:reject("Attempted to fire "..name.." (A non-existing bind-event) | Node",debug.traceback())
	end
end

function node:DisconnectBindEvent(name,destroy)
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		self._maid:clean(name)
		if destroy then bindevent:Destroy() self._bindevents[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing bind-event) | Node",debug.traceback())
	end
end

function node:RegisterBindFunction(name)
	self:Start()
	if self:GetBindFunction(name) then return self:GetBindFunction(name) end
	local bindfunction = Instance.new("BindableFunction")
	bindfunction.Name = name..self._name
	bindfunction.Parent = _bf
	self._bindfunctions[name] = bindfunction
end

function node:ConnectBindFunction(name,callback)
	local bindfunction : BindableFunction = self:GetFunction(name)
	if bindfunction then
		bindfunction.OnInvoke = callback
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing bind-function) | Node",debug.traceback())
	end
end

function node:KitBindFunction(name,callback)
	self:RegisterBindFunction(name)
	self:ConnectBindFunction(name,callback)
end

function node:InvokeBindFunction(name,...)
	local bindfunction : BindableFunction = self:GetFunction(name)
	if bindfunction then
		bindfunction:Invoke(...)
	else
		self._promise:reject("Attempted to invoke "..name.." (A non-existing bind-function) | Node",debug.traceback())
	end
end

function node:DisconnectBindFunction(name,destroy)
	local bindfunction : BindableFunction = self:GetBindFunction(name)
	if bindfunction then
		bindfunction.OnInvoke = function()end
		if destroy then bindfunction:Destroy() self._bindfunctions[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing bind-function) | Node",debug.traceback())
	end
end

local pattern = "(.+)%_.+"
local function filter(str : string,link : string)
	if link == "_nil" then
		return str:match(pattern)
	end
	local findLink = str:find(link)
	if str and link and findLink then
		return str:sub(1,findLink-1)
	end
end

function node:Update()
	self:Start()
	self._events = {}
	for _, event in ipairs(_re:GetChildren()) do
		local filtered = filter(event.Name,`_{self._link}`)
		if filtered then
			self._events[filtered] = event
		end
	end
	self.functions = {}
	for _, func in ipairs(_rf:GetChildren()) do
		local filtered = filter(func.Name,`_{self._link}`)
		if filtered then
			self._functions[filtered] = func
		end
	end
end

function node:GetEvent(name)
	self:Update()
	return self._events[name]
end

function node:GetFunction(name)
	self:Update()
	return self._functions[name]
end

function node:ConnectEvent(name,callback)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		self._maid:mark(name,event.OnClientEvent:Connect(callback))
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing event) | Node",debug.traceback())
	end
end

function node:FireEvent(name,...)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		event:FireServer(self._name,...)
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing event) | Node",debug.traceback())
	end
end

function node:DisconnectEvent(name,destroy)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		self._maid:clean(name)
		if destroy then event:Destroy() self._events[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing event) | Node",debug.traceback())
	end
end

function node:ConnectFunction(name,callback)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		func.OnClientInvoke = callback
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing function) | Node",debug.traceback())
	end
end

function node:InvokeFunction(name,ret,...)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		if ret then
			return func:InvokeServer(self._name,...)
		else
			func:InvokeServer(self._name,...)
		end
	else
		self._promise:reject("Attempted to invoke "..name.." (A non-existing function) | Node",debug.traceback())
	end
end

function node:DisconnectFunction(name,destroy)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		func.OnClientInvoke = function()end
		if destroy then func:Destroy() self._functions[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing function) | Node",debug.traceback())
	end
end

return node
