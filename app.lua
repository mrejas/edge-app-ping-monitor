function findFunction(id)
	for i, fun in ipairs(functions) do
		if fun.id == id then
			return functions[i]
		end
	end
end

function testAndReport()
	local msg = ''
	local numDown = 0
	for address in string.gmatch(cfg.addresses, '([^,]+)') do
    		local command = "ping " .. address .. " -c 1 -W 0.5 >/dev/null 2>&1"
		local r, e, checkRes = os.execute(command)
		if checkRes > 0 then
			numDown = numDown + 1
			msg = msg .. address .. ' is down. '
		else
			msg = msg .. address .. ' is up. '
		end
	end

	local statusFunction = findFunction(cfg.status_function)
	local statusTopic = statusFunction.meta.topic_read
	local payload = json:encode({ 
		value = numDown, 
		msg = msg, 
		timestamp = edge:time() })
	mq:pub(statusTopic, payload, false, 0)
end

function onStart()
	local t = timer:interval(cfg.interval, testAndReport)
end
