--Nexus/Framework

local nexus = {}

nexus.Started = false
nexus.Initialized = false

--Template


--Utilities
local _utils = script.Utilities
	local _promise = require(_utils.Promise)
	local _type = require(_utils.Type)

--Resources
local _res = script.Resources
	local _rm = _res.Remotes
		local _re = _rm.Events
		local _rf = _rm.Functions
	local _bn = _res.Binds
		local _be = _bn.Events
		local _bf = _bn.Events

--Components
local _comp = script.Components
	local _host = require(_comp.Host)
	local _node = require(_comp.Node)
	local _store = require(_comp.Storage)	
	local _proxy = require(_comp.Proxy)

--Default configurations
local DEFAULT_TIMEOUT = 5 --timeout for any fetch
local DEPEND_START = true --returns _p:reject if nexus is called when not started

nexus.Promise = nil

function nexus.GetUtilities()
	return _comp:GetChildren()
end
nexus.Utilities = {}
for _, util in ipairs(nexus.GetUtilities()) do
	nexus.Utilities[util.Name] = util
end

--[=[

nexus:Start(fn : function) -> nil

Starts Nexus if Nexus has not started and DEPEND_START is set to true

```lua
local nexus = require(path.to.Nexus)

nexus:Start()
```

]=]--

function nexus.Start(fn)
	if not nexus.Started then
		if fn then fn() end
		nexus.Started = true
		if nexus.Promise == nil then nexus.Promise = _promise.new() :: _promise.promise end
		return nexus.Promise :: _type.promise
	else
		nexus.Promise:reject("Cannot start Nexus, Nexus already started! | Nexus",debug.traceback())
	end
end


--[=[

nexus:Initialize(fn : function) -> nil

Initializes Nexus if not already initialized

```lua
local nexus = require(path.to.Nexus)
nexus:Initialize()
```

]=]--

local _is_server = game:GetService("RunService"):IsServer()




function nexus.Initialize(fn)
	if nexus.Initialized then
		nexus.Promise:reject("Cannot initialize Nexus, Nexus already initialized! | Nexus",debug.traceback())
		return
	end
	if not nexus.Started then
		nexus.Promise:reject("Cannot initialize Nexus, Nexus is not started! | Nexus",debug.traceback())
		return
	end
	if fn then fn() end
	nexus.Initialized = true
	
	if _is_server then
		nexus.Host = nexus.LoadHost("NEXUS_HOST","NEXUS_NODE")
		nexus.Host:KitFunction("GetProxy",true,function(_,name)
			local proxy = nexus.GetProxy(name)
			if proxy then
				local proxs = proxy._clientProxy
				for i, v in pairs(proxs) do
					if type(v) == "function" then
						proxy._clientCallback[i] = v
						proxy._clientProxy[i] = true else continue
					end
				end
				return proxy._clientProxy
			end
		end)
	else
		nexus.Node = nexus.LoadNode("NEXUS_NODE","NEXUS_HOST")
	end
end

function nexus.Yield(property,to)
	if not nexus.Started then
		nexus.Start():catch(warn)
	end
	if not nexus.Initialized then
		nexus.Initialize()
	end
	local timeout = DEFAULT_TIMEOUT + os.time()
	while nexus[property] ~= to and os.time() ~= timeout do
		task.wait()
	end
end
local empty : {} = {}
function nexus.GetProxy(name,timeout)
	nexus.Yield("Initialized",true)
	if _is_server then
		timeout = timeout or DEFAULT_TIMEOUT
		local timeout_time = os.time() + timeout
		while _store.Proxy[name] == nil and os.time() ~= timeout_time do task.wait() end
		return _store.Proxy[name]._serverProxy :: {any : any}
	else
		if _store.Proxy[name] then return _store.Proxy[name] end
		local client = nexus.Node:InvokeFunction("GetProxy",true,name)
		if _store.Proxy[name] == nil and client then 
			_proxy.new(name,nexus.Promise)
		end
		local proxyNode = nexus.GetNode(name.."_ProxyNode")
		for i,v in pairs(client) do
			client[i] = function(...)
				local class = select(1,...)
				if class ~= client then 
					--. Fire
					proxyNode:FireEvent("ProxyFunction",i,false,class,...)
				else
					--: Fire
					proxyNode:FireEvent("ProxyFunction",i,true,class,...)
				end
			end
		end
		
		_store.Proxy[name] = client
		return client
	end
end

function nexus.LoadProxy(name)
	nexus.Yield("Initialized",true)
	if not nexus.Started and DEPEND_START then
		return nexus.Promise:reject("Cannot load Proxy, Nexus is not started! | Nexus",debug.traceback())
	end
	if _is_server then
		return _proxy.new(name,nexus.Promise)
	else
		_proxy.new(name,nexus.Promise)
		return nexus.GetProxy(name) :: {},{}
	end
end

--Start By checking arg and sanity-types
--Used to handle when a type is improperly connected, such as attempt to spoof
function nexus.CheckType(argsTable : {}, typeTable : {},hook : "function"|nil)
	for i = 1, #argsTable do
		if type(argsTable[1]) ~= type(typeTable[i]) then
			if hook then
				hook(`Invalid Argument {i}, type {type(typeTable[i])} expected, got type {type(argsTable[i])}`)
			end
			return false
		end
	end
	return true
end
--same case but typeof instd of type
function nexus.CheckTypeOf(argsTable : {}, typeTable : {},hook : (status : string) -> ()|nil)
	for i = 1, #argsTable do
		if typeof(argsTable[1]) ~= typeof(typeTable[i]) then
			if hook then
				hook(`Invalid Argument {i}, type {typeof(typeTable[i])} expected, got type {typeof(argsTable[i])}`)
			end
			return false
		end
	end
	return true
end

function nexus.GetHost(name,timeout)
	nexus.Yield("Initialized",true)
	if not nexus.Started and DEPEND_START then
		return nexus.Promise:reject("Cannot get Host, Nexus is not started! | Nexus",debug.traceback()) :: _type.host
	end
	timeout = timeout or DEFAULT_TIMEOUT
	local timeout_time = os.time() + timeout
	while _store.Host[name] == nil and os.time() ~= timeout_time do task.wait() end
	return _store.Host[name] :: _type.host
end

function nexus.LoadHost(name,nodeName)
	nexus.Yield("Initialized",true)
	if not nexus.Started and DEPEND_START then
		return nexus.Promise:reject("Cannot load Host, Nexus is not started! | Nexus",debug.traceback())
	end
	return _host.new(name,nodeName,nexus.Promise) :: _type.host
end

function nexus.GetNode(name,timeout)
	nexus.Yield("Initialized",true)
	if not nexus.Started and DEPEND_START then
		return nexus.Promise:reject("Cannot get Node, Nexus is not started! | Nexus",debug.traceback()) :: _type.node
	end
	timeout = timeout or DEFAULT_TIMEOUT
	local timeout_time = os.time() + timeout
	while _store.Node[name] == nil and os.time() ~= timeout_time do task.wait() end
	return _store.Node[name] :: _type.node
end

function nexus.LoadNode(name,hostName)
	nexus.Yield("Initialized",true)
	if not nexus.Started and DEPEND_START then
		return nexus.Promise:reject("Cannot load Node, Nexus is not started! | Nexus",debug.traceback())
	end
	return _node.new(name,hostName,nexus.Promise) :: _type.node
end

return nexus
