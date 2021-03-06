ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler("chatMessage", function(source, color, message)
    local src = source
    args = stringsplit(message, " ")
    CancelEvent()
    if string.find(args[1], "/") then
        local cmd = args[1]
        table.remove(args, 1)
        
        --TriggerClientEvent('chat:addMessage', src, {
            --template = '<div class="chat-message server"><b>SYSTEM:</b> Invalid usage. For a list of all commands, type /help.</div>',
            --args = { message }
        --})
    else
        --TriggerClientEvent('chat:addMessage', -1, {
            --template = '<div class="chat-message"><b>OOC {0}</b>: {1}</div>',
            --args = { GetPlayerName(src), message }
        --})
    end
end)

RegisterServerEvent('chat:server:ServerPSA')
AddEventHandler('chat:server:ServerPSA', function(message)
    TriggerClientEvent('chat:addMessages', -1, {
        template = '<div class="chat-message server">SUNUCU: {0}</div>',
        args = { message }
    })
    CancelEvent()
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			name = identity['name'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height'],
			job = identity['job'],
            group = identity['group'],
            number = identity['phone_number']
		}
	else
		return nil
	end
end