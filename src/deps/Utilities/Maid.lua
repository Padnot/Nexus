--Maid
local maid = {}
maid.__index = maid

function maid.new(name)
	local self = setmetatable({},maid)
	self._tasks = {}
	return self
end

function maid:mark(name,_task)
	if self._tasks[name] then
		table.insert(self._tasks[name],_task)
		return
	end
	if type(_task) ~= "function" and typeof(_task) ~= "RBXScriptConnection" then
		warn("Task must be a function or a connection/signal! | Maid",debug.traceback())
		return
	end
	self._tasks[name] = {_task}
end

function maid:clean(name)
	local _taskTable = self._tasks[name]
	if not _taskTable then return warn("Task can not be found! | Maid",debug.traceback()) end
	for _, _task in ipairs(_taskTable) do
		if type(_task) == "function" then
			_task()
		elseif typeof(_task) == "RBXScriptConnection" then
			_task:Disconnect()
		end
	end
end

function maid:clear()
	for _, _taskTable in pairs(self._tasks) do
		for _, _task in ipairs(_taskTable) do
			if type(_task) == "function" then
				_task()
			elseif typeof(_task) == "RBXScriptConnection" then
				_task:Disconnect()
			end
		end
	end
	self._tasks = {}
end

function maid:destroy()
	self:clear()
	self._tasks = nil
	self = nil
end

return maid
