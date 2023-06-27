local Type = {}

--Components

export type host = {
	new : (name : string,nodeName : string) -> host,
	Start : (self : host) -> (),
	LinkNode : (self : host, nodeName : string) -> (),
	GetBindEvents : (self : host, name : string) -> BindableEvent,
	GetBindFunctions : (self : host, name : string) -> BindableFunction,
	RegisterBindEvent : (self : host, name : string) -> (),
	RegisterBindFunction : (self : host, name : string) -> (),
	ConnectBindEvent : (self : host, name : string,callback : (...any) -> ()) -> (),
	ConnectBindFunction : (self : host,ret : boolean,name : string,callback : (...any) -> (any)) -> () | any,
	KitBindEvent : (self : host, name : string,callback : (...any) -> ()) -> (),
	KitBindFunction : (self : host,ret : boolean,name : string,callback : (...any) -> (any)) -> () | any,
	FireBindEvent : (self : host, name : string, ...any) -> (),
	InvokeBindFunction : (self : host, ret : boolean, name : string, ...any) -> () | any,
	DisconnectBindEvent : (self : host, name : string, destroy : boolean | nil) -> (),
	DisconnectBindFunction : (self : host, name : string, destroy : boolean | nil) -> (),
	LinkFalseFire : (self : host, callback : (player : Player, node : node, connection : any) -> ()) -> (),
	GetEvents : (self : host, name : string) -> ableEvent,
	GetFunctions : (self : host, name : string) -> ableFunction,
	RegisterEvent : (self : host, name : string) -> (),
	RegisterFunction : (self : host, name : string) -> (),
	ConnectEvent : (self : host, name : string,callback : (player : Player, ...any) -> ()) -> (),
	ConnectFunction : (self : host,ret : boolean,name : string,callback : (player : Player, ...any) -> ()) -> () | any,
	KitEvent : (self : host, name : string,callback : (player : Player, ...any) -> ()) -> (),
	KitFunction : (self : host,ret : boolean,name : string,callback : (player : Player, ...any) -> ()) -> () | any,
	FireEvent : (self : host, name : string, ...any) -> (),
	FireEventAll : (self : host, name : string, ...any) -> (),
	InvokeFunction : (self : host, ret : boolean, name : string, ...any) -> () | any,
	DisconnectEvent : (self : host, name : string, destroy : boolean | nil) -> (),
	DisconnectFunction : (self : host, name : string, destroy : boolean | nil) -> ()	
}

export type node = {
	new : (name : string,hostName : string) -> node,
	Start : (self : node) -> (),
	LinkHost : (self : node, hostName : string) -> (),
	GetBindEvents : (self : node, name : string) -> BindableEvent,
	GetBindFunctions : (self : node, name : string) -> BindableFunction,
	RegisterBindEvent : (self : node, name : string) -> (),
	RegisterBindFunction : (self : node, name : string) -> (),
	ConnectBindEvent : (self : node, name : string,callback : (...any) -> ()) -> (),
	ConnectBindFunction : (self : node,ret : boolean,name : string,callback :(...any) -> ()) -> () | any,
	KitBindEvent : (self : node, name : string,callback : (...any) -> ()) -> (),
	KitBindFunction : (self : node,ret : boolean,name : string,callback : (...any) -> any) -> () | any,
	FireBindEvent : (self : node, name : string, ...any) -> (),
	InvokeBindFunction : (self : node, ret : boolean, name : string, ...any) -> () | any,
	DisconnectBindEvent : (self : node, name : string, destroy : boolean | nil) -> (),
	DisconnectBindFunction : (self : node, name : string, destroy : boolean | nil) -> (),
	GetEvents : (self : node, name : string) -> ableEvent,
	GetFunctions : (self : node, name : string) -> ableFunction,
	ConnectEvent : (self : node, name : string,callback : (...any) -> ()) -> (),
	ConnectFunction : (self : node,ret : boolean,name : string,callback : (...any) -> any) -> () | any,
	FireEvent : (self : node, name : string, ...any) -> (),
	InvokeFunction : (self : node, ret : boolean, name : string, ...any) -> () | any,
	DisconnectEvent : (self : node, name : string, destroy : boolean | nil) -> (),
	DisconnectFunction : (self : node, name : string, destroy : boolean | nil) -> ()	
}

--I don't think i need to typecheck this because its an internal module

export type proxy = {
	
}

--Utilities

export type promise = {
	resolve : (self : promise,resolvingValue : any) -> (),
	reject : (self : promise,rejectingValue : any) -> (),
	andThen : (self : promise,callback : (resolvedValue : any) -> ()) -> promise,
	catch : (self : promise,callback : (rejectedValue : any) -> ()) -> promise,
	finally : (self: promise,callback : (finalizedValue : any) -> ()) -> promise
}

export type maid = {
	GetMaid : (self : {}|maid,name : string) -> maid | nil,
	new : (name : string) -> maid,
	mark : (self : maid,_task : RBXScriptSignal | () -> ()) -> (),
	clear : (self : maid) -> (),
	destroy : (self : maid) -> ()
}

export type sig = {
	GetSignal : (self : signal|{}) -> signal|nil,
	new : (name) -> signal, 
	Connect : (self : signal,f : () -> ()) -> {Disconnect : () -> ()},
	Fire : (self : signal,...any) -> (),
	GetConnections : (self : signal) -> (),
	DisconnectAll : (self : signal) -> (),
	Wait : (self : signal) -> any,
}

return Type
