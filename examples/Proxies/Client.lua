--Localscript
local nexus = require(game:GetService("ReplicatedStorage"):WaitForChild("Nexus"))
local client = nexus.GetProxy("ProxyTest")

client:Hi("Usage #1") --Will print YOURNAME, Usage #1 on the server.
