local comp = {}

local function estimate_table(t)
	local k,v = 0,0
	for key,value in pairs(t) do
		k += tostring(key):len()
		if type(value) == "table" then
			local _k,_v = estimate_table(value)
			k += _k
			v += _v
		else
			v += tostring(value):len()
		end
	end
	return k+v,k,v
end

function comp.Test(t)
	return estimate_table(t)
end

function comp.Compress(...)
	local args = {...}
	local _args = {}
	for i, arg in ipairs(args) do
		if type(arg) == "number" then
			--Number Compression, If number < 8 and > -8
			if arg < 999999 and arg > -99999 then
				_args[i] = tostring(arg)
			else
				_args[i] = arg
			end
		else
			_args[i] = arg
		end
	end
	args = nil
	return unpack(_args)
end

return comp
