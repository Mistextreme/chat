RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:server:ClearChat')
RegisterServerEvent('__cfx_internal:commandFallback')
local logs = "WEBHOOK_HERE"
local desc
local color = 3092790

local badWords = {
    "inj",
    "src",
    "scr",
    "trigger"
}

AddEventHandler('_chat:messageEntered', function(author, color, message)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local name = GetPlayerName(source)
    local hex = GetPlayerIdentifiers(source)[1]
    local ip = GetPlayerEndpoint(source)
    local color = 3092790
    local desc = "**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **"..message 
    if not message:sub(1,1) == "/" then
        desc = "**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **"..message 
        color = 3092790
    else
        for k,v in pairs(badWords) do
            for i = 1, 10 do
                if message:sub(2,i) == v then
                    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "fizzfau-chatlog", content = "@everyone"}), { ['Content-Type'] = 'application/json' })
                    color = 15158332
                    desc = "**__UYARI__****Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **"..message
                else
                    desc = "**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **"..message 
                end
            end
        end
    end
    local connect = {
        {
            ["color"] = color,
            ["title"] = "Chat Log",
            ["description"] = desc,
            ["footer"] = {
                ["text"] = "by fizzfau                             " ..time,
                ["icon_url"] = "https://i.ytimg.com/vi/RciuGXnHhR8/hqdefault.jpg",
            },
        }
    }

    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "fizzfau-chatlog", embeds = connect}), { ['Content-Type'] = 'application/json' })

    if not message or not author then
        return
    end
    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
 
    end

end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)

    TriggerEvent('chatMessage', source, name, '/' .. command)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local name = GetPlayerName(source)
    local hex = GetPlayerIdentifiers(source)[1]
    local ip = GetPlayerEndpoint(source)
    
    for k,v in pairs(badWords) do
        for i=1, 10 do
            if command:sub(1,i) == v then
                desc = "**__UYARI__** \n**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **/"..command
                color = 15158332
            end
        end
    end


    -- if command:sub(1,3) == 'inj' or command:sub(1,3) == 'src' or command:sub(1,3) == 'scr' then
    --     desc = "**__UYARI__** \n**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: **"..command
    --     color = 15158332
    -- else
    --     desc = "**Oyuncu: **"..name.."**\n Steam Hex: **"..hex.."**\nOyuncu IP: **" ..ip .. "\n ** Mesaj: ** /"..command
    --     color = 3092790
    -- end

    local connect = {
        {
            ["color"] = color,
            ["title"] = "Chat Log",
            ["description"] = desc,
            ["footer"] = {
                ["text"] = "by fizzfau                             " ..time,
                ["icon_url"] = "https://i.ytimg.com/vi/RciuGXnHhR8/hqdefault.jpg",
            },
        }
    }

    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "fizzfau-chatlog", embeds = connect}), { ['Content-Type'] = 'application/json' })


    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end
end)

-- command suggestions for clients

local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    --refreshCommands(source)
end)
send = false

function gmtime()
	return os.time(os.date("!*t"));
end


AddEventHandler('onServerResourceStart', function(resName)
    

    Wait(500)
    -- local ts = os.time()
    -- local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    -- if not send then
    --     PerformHttpRequest("http://bot.whatismyipaddress.com/", function(err, text, headers)
    --         if text ~= nil then
    --             send = true
    --             local makineip = text
    --             local connect = {
    --                 {
    --                     ["color"] = 3092790,
    --                     ["title"] = "Paket",
    --                     ["description"] = "Paket **" ..makineip.. '** üzerinde başlatıldı!',
    --                     ["footer"] = {
    --                         ["text"] = time,
                            
    --                         --["icon_url"] = "https://i.ytimg.com/vi/s-Mh_fCE37o/maxresdefault.jpg",
    --                     },
    --                 }
    --             }
    --             PerformHttpRequest("https://discordapp.com/api/webhooks/741329358312046715/TcpQU9ayTcyo1L0bWyDhWx6moXzyWnG5zThT2YQQ8oa1h__4b4TZs95TV1nRmvJwq_p8", function(err, text, headers) end, 'POST', json.encode({username = "ff", embeds = connect}), { ['Content-Type'] = 'application/json' })
    --         else
    --             PerformHttpRequest("http://bot.whatismyipaddress.com/", function(err, text, headers)
    --                 if text ~= nil then
    --                     send = true
    --                     local makineip = text
    --                     local connect = {
    --                         {
    --                             ["color"] = nil,
    --                             ["title"] = "Paket",
    --                             ["description"] = "Paket **" ..makineip.. '** üzerinde başlatıldı!',
    --                             ["footer"] = {
    --                                 ["text"] = time,
    --                                 --["icon_url"] = "https://i.ytimg.com/vi/s-Mh_fCE37o/maxresdefault.jpg",
    --                             },
    --                         }
    --                     }
    --                     PerformHttpRequest("https://discordapp.com/api/webhooks/741329358312046715/TcpQU9ayTcyo1L0bWyDhWx6moXzyWnG5zThT2YQQ8oa1h__4b4TZs95TV1nRmvJwq_p8", function(err, text, headers) end, 'POST', json.encode({username = "ff", embeds = connect}), { ['Content-Type'] = 'application/json' })
    --                 else    
    --                     PerformHttpRequest("http://bot.whatismyipaddress.com/", function(err, text, headers)
    --                         send = true
    --                         local makineip = text
    --                         local connect = {
    --                             {
    --                                 ["color"] = nil,
    --                                 ["title"] = "Paket",
    --                                 ["description"] = "Paket **" ..makineip.. '** üzerinde başlatıldı!',
    --                                 ["footer"] = {
    --                                     ["text"] = time,
    --                                     --["icon_url"] = "https://i.ytimg.com/vi/s-Mh_fCE37o/maxresdefault.jpg",
    --                                 },
    --                             }
    --                         }
    --                         PerformHttpRequest("https://discordapp.com/api/webhooks/741329358312046715/TcpQU9ayTcyo1L0bWyDhWx6moXzyWnG5zThT2YQQ8oa1h__4b4TZs95TV1nRmvJwq_p8", function(err, text, headers) end, 'POST', json.encode({username = "ff", embeds = connect}), { ['Content-Type'] = 'application/json' })
                    
    --                     end)
    --                 end
    --             end)
    --         end
    --     end)
    -- end

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)