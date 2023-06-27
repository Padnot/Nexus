--Host/Server

local host = {}
host.__index = host
host.__metatable = function()
	return "Can not get metatable for host! | Host"
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

function host.new(name,nodeName,promise)
	if _store.Host[name] then promise:reject("Host name "..name.." already exists! | Host",debug.traceback()) return _store.Host[name] end
	local self = setmetatable({},host)
	
	self._events = {}
	self._functions = {}
	self.bindevents = {}
	self._bindfunctions = {}
	self._name = name
	self._type = "Host"
	self._maid = _maid.new()
	self._started = false
	self._initialized = false
	self._link = nodeName
	self._promise = promise
	self._FALSE_FIRE_HOOK = nil
	
	_store.Host[name] = self
	return self
end

function host:Start()
	self._started = true
end

function host:LinkFalseFire(f)
	if not f then return end
	if type(f) ~= "function" then return end
	self._FALSE_FIRE_HOOK = f --USED TO SECURE FALSE FIRE, PLEASE DO NOT SET UNLESS YOU KNOW THE USAGE
end

function host:LinkNode(new)
	self._link = new
end

function host:GetBindEvent(name)
	return self._bindevents[name]
end

function host:GetBindFunction(name)
	return self._bindfunctions[name]
end

function host:RegisterBindEvent(name)
	self:Start()
	if self:GetBindEvent(name) then return self:GetBindEvent(name) end
	local bindevent = Instance.new("BindableEvent")
	bindevent.Name = name..`_{self._name}`
	bindevent.Parent = _be
	self._bindevents[name] = bindevent
end

function host:ConnectBindEvent(name,callback)
	self:Start()
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		self._maid:mark(name,bindevent.Event:Connect(callback))
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing bind-event) | Host",debug.traceback())
	end
end

function host:KitBindEvent(name,callback)
	self:RegisterBindEvent(name)
	self:ConnectBindEvent(name,callback)
end

function host:FireBindEvent(name,...)
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		bindevent:Fire(...)
	else
		self._promise:reject("Attempted to fire "..name.." (A non-existing bind-event) | Host",debug.traceback())
	end
end

function host:DisconnectBindEvent(name,destroy)
	local bindevent : BindableEvent = self:GetBindEvent(name)
	if bindevent then
		self._maid:clean(name)
		if destroy then bindevent:Destroy() self._bindevents[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing bind-event) | Host",debug.traceback())
	end
end

function host:RegisterBindFunction(name)
	self:Start()
	if self:GetBindFunction(name) then return self:GetBindFunction(name) end
	local bindfunction = Instance.new("BindableFunction")
	bindfunction.Name = name..`_{self._name}`
	bindfunction.Parent = _bf
	self._bindfunctions[name] = bindfunction
end

function host:ConnectBindFunction(name,ret,callback)
	local bindfunction : BindableFunction = self:GetFunction(name)
	if bindfunction then
		bindfunction.OnInvoke = function(...)
			if ret then
				return callback(...)
			else
				callback(...)
			end
		end
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing bind-function) | Host",debug.traceback())
	end
end

function host:KitBindFunction(name,ret,callback)
	self:RegisterBindFunction(name)
	self:ConnectBindFunction(name,ret,callback)
end

function host:InvokeBindFunction(name,...)
	local bindfunction : BindableFunction = self:GetFunction(name)
	if bindfunction then
		bindfunction:Invoke(...)
	else
		self._promise:reject("Attempted to invoke "..name.." (A non-existing bind-function) | Host",debug.traceback())
	end
end

function host:DisconnectBindFunction(name,destroy)
	local bindfunction : BindableFunction = self:GetBindFunction(name)
	if bindfunction then
		bindfunction.OnInvoke = function()end
		if destroy then bindfunction:Destroy() self._bindfunctions[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing bind-function) | Host",debug.traceback())
	end
end

function host:GetEvent(name)
	return self._events[name]
end

function host:GetFunction(name)
	return self._functions[name]
end

function host:RegisterEvent(name)
	self:Start()
	if self:GetEvent(name) then return self:GetEvent(name) end
	local event = Instance.new("RemoteEvent")
	event.Name = name..`_{self._name}`
	event.Parent = _re
	self._events[name] = event
end

function host:ConnectEvent(name,callback)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		local connection = event.OnServerEvent:Connect(function(p,node,...)
			if node == self._link or self._link == nil then
				callback(p,...)
			else
				if self._FALSE_FIRE_HOOK then self._FALSE_FIRE_HOOK(p,node,name) end
				self._promise:reject(`Node {node} attempted to fire Host {self._name}! | Host {debug.traceback()}`)
			end
		end)
		self._maid:mark(name,connection)
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing event) | Host",debug.traceback())
	end
end

function host:KitEvent(name,callback)
	self:RegisterEvent(name)
	self:ConnectEvent(name,callback)
end

function host:FireEvent(name,obj,...)
	local event : RemoteEvent = self:GetEvent(name)
	if type(obj) == "string" and obj:lower() == "all" then
		return self._promise:reject("Using obj arguments with 'all' is deprecated, use FireEventAll instead.")
	end
	if event then
		event:FireClient(obj,...)
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing event) | Host",debug.traceback())
	end
end

function host:FireEventAll(name,...)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		event:FireAllClients(...)
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing event) | Host",debug.traceback())
	end
end

function host:DisconnectEvent(name,destroy)
	local event : RemoteEvent = self:GetEvent(name)
	if event then
		self._maid:clean(name)
		if destroy then event:Destroy() self._events[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing event) | Host",debug.traceback())
	end
end

function host:RegisterFunction(name)
	self:Start()
	if self:GetFunction(name) then return self:GetFunction(name) end
	local func = Instance.new("RemoteFunction")
	func.Name = name..`_{self._name}`
	func.Parent = _rf
	self._functions[name] = func
end

function host:ConnectFunction(name,ret,callback)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		func.OnServerInvoke = function(p,node,...)
			if node == self._link or self._link == nil then
				if ret then
					return callback(p,...)
				else
					callback(p,...)
				end
			else
				if self._FALSE_FIRE_HOOK then self._FALSE_FIRE_HOOK(p,name) end
				self._promise:reject(`Node {node} attempted to invoke Host {self._name}! | Host {debug.traceback()}`)
			end
		end
	else
		self._promise:reject("Attempted to connect "..name.." (A non-existing function) | Host",debug.traceback())
	end
end

function host:KitFunction(name,ret,callback)
	self:RegisterFunction(name)
	self:ConnectFunction(name,ret,callback)
end

function host:InvokeFunction(name,ret,...)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		if ret then
			return func:InvokeClient(...)
		else
			func:InvokeClient(...)
		end
	else
		self._promise:reject("Attempted to invoke "..name.." (A non-existing function) | Host",debug.traceback())
	end
end

function host:DisconnectFunction(name,destroy)
	local func : RemoteFunction = self:GetFunction(name)
	if func then
		func.OnServerInvoke = function()end
		if destroy then func:Destroy() self._functions[name] = nil end
	else
		self._promise:reject("Attempted to disconnect "..name.." (A non-existing function) | Host",debug.traceback())
	end
end

return host
