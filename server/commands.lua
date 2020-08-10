--[[ COMMANDS ]]--

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('temizle', function(source, args, rawCommand)
    TriggerClientEvent('chat:client:ClearChat', source)
end, false)

RegisterCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('chat:client:ClearChat', source)
end, false)

RegisterCommand('ooc', function(source, args, rawCommand, suggestions)
    local src = source
    local msg = rawCommand:sub(5)
    local suggestions = {}
	local source = tonumber(source)
    if player ~= false then
        local user = GetPlayerName(src)
        GetRPName(source, function(Firstname, Lastname)
            TriggerClientEvent('chat:addMessageOOC', -1, {
            template = '<div class="chat-message"><b>OOC '.. Firstname.. ' '.. Lastname.. ':</b> {1}</div>',
            args = { user, msg }
        })
    end)
    end
end, false)
--[[
RegisterCommand('duyuru', function(source, args, rawCommand)
    local src = source
    local msg = rawCommand:sub(7)
    if player ~= false then
        local user = GetPlayerName(src)
            TriggerClientEvent('chat:addMessages', -1, {
            template = '<div class="chat-message server"><b>WATCRP DUYURU:</b> {0}</div>',
            args = { msg }
        })
    end
end, false)
]]

function GetRPName(playerId, data)
	local Identifier = ESX.GetPlayerFromId(playerId).identifier

	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		data(result[1].firstname, result[1].lastname)

	end)
end