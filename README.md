# Nexus

Hello, Thank you for your interest in looking up my game framework, I will show you what this framework does in the simplest term.

This game framework isn't exactly as useful as Knit, BridgeNet2 or any other general / connection game framework, as this is my very first framework. By now, you might be wondering, why should I use this? The main function of nexus that It is used to lessen directory references (such as replicatedstorage:WaitForChild, serverscriptservice.modules etc.), and heres how you can do it.

.GetProxy and .LoadProxy, These are functions to return a proxy, which is the equivalent of modules

Server Code:
```lua
--Script A (Server)
local nexus = require(game.ReplicatedStorage:WaitForChild("Nexus")) --Assuming it was placed there

local server,client = nexus.LoadProxy("MyProxy")
--Server is the server-instance of what is equivalent of a module
function server:SayHi()
  print("Hi!")
end

function client:SayHelloInServer(plr)
  print(plr.Name,"Fired hello!")
end

--Script B
--Assuming nexus has been required.
local server = nexus.GetProxy("MyProxy") --Same name as registered in loadproxy
server:SayHi() --Prints Hi on script a
```

Client Code:
```lua
--Assuming nexus has been required
local client = nexus.GetProxy("MyProxy")
client:SayHelloInServer() --prints client name, Fired Hello in script a.
```

This simplifies process of requiring modules and the process of client-server communication, although for specific security reasons, a client can-not replicate a proxy to the server.

There are other features such as nodes and hosts

# Background
When creating this framework, I had a few cores on why i designed it this way. I will break down and simplify each cores best I can.

-Readability.
The main modules and everything related to this code was formatted and designed to be a little nicer to read, not bombarded with tons of comments explaining the usage. This is also the primary reason I made this framework. When reading other open-sourced frameworks such as that Knit, I was a little bit confused on how the system overall works, I know there's a documentation about how every function works, I just really want to see the background processes and try to learn from that point.
