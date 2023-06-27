--Proxy/Library

local proxy = {}
proxy.__index = proxy

--Components
local _comp = script.Parent
	local _store = require(_comp.Storage)
	local _host = require(_comp.Host)
	local _node = require(_comp.Node)

--Utilities
local _utils = _comp.Parent.Utilities
	local _maid = require(_utils.Maid)



local _is_server = game:GetService("RunService"):IsServer()

function proxy.new(name,promise)
	if _store.Host[name] then promise:reject("Proxy name "..name.." already exists! | Proxy",debug.traceback()) return _store.Proxy[name] end
	local self = setmetatable({},proxy)
	if _is_server then
		self._host = _host.new(`{name}_ProxyHost`,`{name}_ProxyNode`,promise)

		self._host:KitEvent("ProxyFunction",function(plr,name,classbool,...)
			local find = self._clientCallback[name]
			if find then
				find(if classbool then {} else select(1,...),plr,...)
			end
		end)
	else
		self._node = _node.new(`{name}_ProxyNode`,`{name}_ProxyHost`,promise)
	end
	
	self._serverProxy = {}
	self._clientProxy = {}
	
	self._clientCallback = {}
	
	self._promise = promise
	
	
	
	_store.Proxy[name] = self
	return self._serverProxy,self._clientProxy
end 


return proxy
