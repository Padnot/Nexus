--Serverscript -> Server
local nexus = require(game:GetService("ReplicatedStorage"):WaitForChild("Nexus"))
local server, client = nexus.LoadProxy("ProxyTest")

function client:Hi(plr, message)
  print(plr, message)
end
