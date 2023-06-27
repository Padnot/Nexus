--Signal

local con = {}
con.__index = con

local signal = {}
signal.__index = signal

local _store = require(script.Parent.Parent.Components.Storage)

function signal:GetSignal(name)
	return _store.Signal[name]
end

function con.new(f)
	local self = setmetatable({},con)
	self._callback = f
	return self
end

function con:Disconnect()
	self._callback = nil
end

function con:Fire(...)
	if self._callback then
		self._callback(...)
	end
end

export type sig = {
	GetSignal : (self : signal|{}) -> signal|nil,
	new : (name) -> signal, 
	Connect : (self : signal,f : () -> ()) -> {Disconnect : () -> ()},
	Fire : (self : signal,...any) -> (),
	GetConnections : (self : signal) -> (),
	DisconnectAll : (self : signal) -> (),
	Wait : (self : signal) -> any,
}

function signal.new(name)
	if signal:GetSignal(name) then return signal:GetSignal(name) end
	local self = setmetatable({},signal)
	self._connections = {}
	self._parallels = {}
	_store.Signal[name] = self
	return self :: sig
end

function signal:Connect(f)
	self._connections[tostring(f)] = con.new(f)
	return {Disconnect = self._connections[tostring(f)].Disconnect}
end

function signal:Fire(...)
	for _, f in pairs(self._connections) do
		f:Fire(...)
	end
end

function signal:Wait()
	local cor = coroutine.running()
	local cn
	cn = self:Connect(function(...)
		cn:Disconnect()
		task.spawn(cor,...)
	end)
	return coroutine.yield()
end

function signal:GetConnections()
	return self._connections
end

function signal:DisconnectAll()
	for i in pairs(self:GetConnections()) do
		self._connections[i] = nil
	end
end

return signal
