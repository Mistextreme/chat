local chatInputActive = false
local chatInputActivating = false
local chatHidden = true
local chatLoaded = false
local chatVisibilityToggle = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
-- RegisterNetEvent('chat:addMessageOOC')
RegisterNetEvent('chat:addMessages')
RegisterNetEvent('chat:addMessageHack')
RegisterNetEvent('chat:addMessageUpdate')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:client:ClearChat')
RegisterNetEvent('chat:toggleChat')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')

--deprecated, use chat:addMessage
AddEventHandler('chatMessage', function(author, color, text)
  local args = { text }
  if author ~= "" then
    table.insert(args, 1, author)
    print(text)
  end
  if(not chatVisibilityToggle)then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = args
      }
    })
  end
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  print(msg)
  if(not chatVisibilityToggle)then
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = { 0, 0, 0 },
        multiline = true,
        args = { msg }
      }
    })
  end
end)

AddEventHandler('chat:addMessage', function(message)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

-- AddEventHandler('chat:addMessageOOC', function(message)
--   if(not chatVisibilityToggle)then
--     SendNUIMessage({
--       type = 'ON_MESSAGE',
--       message = message
--     })
--   end
-- end)

AddEventHandler('chat:addMessages', function(message)
  PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
  --TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'bassdrop', 0.1)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addMessageHack', function(message)
  PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 0)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addMessageUpdate', function(message)
  PlaySoundFrontend(-1, "HACKING_CLICK_GOOD", 0)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
  for _, suggestion in ipairs(suggestions) do
    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      suggestion = suggestion
    })
  end
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

RegisterNetEvent('chat:resetSuggestions')
AddEventHandler('chat:resetSuggestions', function()
  SendNUIMessage({
    type = 'ON_COMMANDS_RESET'
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:client:ClearChat', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

AddEventHandler('chat:toggleChat',function()
  chatVisibilityToggle = not chatVisibilityToggle
  local state = (chatVisibilityToggle == true) and "^1kapandı" or "^2aktif edildi"

  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
        color = {255,255,255},
        multiline = true,
        template = '<div class="chat-message"><b>Chat</b> {0}</div>',
        args = { state }
      }
    })
end)

-- RegisterCommand("chat",function()
--   TriggerEvent('chat:toggleChat')
--   TriggerEvent('chat:addSuggestion', 'chat', 'OOC Chati aktif eder/kapatır')
-- end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    local r, g, b = 0, 0x99, 255

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
    end
  end

  cb('ok')
end)

local function refreshCommands()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()

    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
        if IsAceAllowed(('command.%s'):format(command.name)) then
            table.insert(suggestions, {
                name = '/' .. command.name,
                help = ''
            })
        end
    end

    TriggerEvent('chat:addSuggestions', suggestions)
  end
end

local function refreshThemes()
  local themes = {}

  for resIdx = 0, GetNumResources() - 1 do
    local resource = GetResourceByFindIndex(resIdx)

    if GetResourceState(resource) == 'started' then
      local numThemes = GetNumResourceMetadata(resource, 'chat_theme')

      if numThemes > 0 then
        local themeName = GetResourceMetadata(resource, 'chat_theme')
        local themeData = json.decode(GetResourceMetadata(resource, 'chat_theme_extra') or 'null')

        if themeName and themeData then
          themeData.baseUrl = 'nui://' .. resource .. '/'
          themes[themeName] = themeData
        end
      end
    end
  end

  SendNUIMessage({
    type = 'ON_UPDATE_THEMES',
    themes = themes
  })
end

AddEventHandler('onClientResourceStart', function(resName)
  Wait(500)

  refreshCommands()
  refreshThemes()
end)

AddEventHandler('onClientResourceStop', function(resName)
  Wait(500)

  refreshCommands()
  refreshThemes()
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init');

  refreshCommands()
  refreshThemes()

  chatLoaded = true

  cb('ok')
end)

Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, 245) then
        SetNuiFocus(true)

        chatInputActivating = false
      end
    end

    if chatLoaded then
      local shouldBeHidden = false

      if IsScreenFadedOut() or IsPauseMenuActive() then
        shouldBeHidden = true
      end

      if (shouldBeHidden and not chatHidden) or (not shouldBeHidden and chatHidden) then
        chatHidden = shouldBeHidden

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          shouldHide = shouldBeHidden
        })
      end
    end
  end
end)

RegisterCommand('911', function(source, args, rawCommand)
  local source = GetPlayerServerId(PlayerId())
  local name = GetPlayerName(PlayerId())
  local caller = GetPlayerServerId(PlayerId())
  local msg = rawCommand:sub(4)
  TriggerServerEvent('chat:server:911source', source, caller, msg)
  TriggerServerEvent('911', source, caller, msg)
  ExecuteCommand('e telefonlakonuş')
  Citizen.Wait(3500)
  ExecuteCommand('e c')
end, false)

RegisterCommand('311', function(source, args, rawCommand)
  local source = GetPlayerServerId(PlayerId())
  local name = GetPlayerName(PlayerId())
  local caller = GetPlayerServerId(PlayerId())
  local msg = rawCommand:sub(4)
  TriggerServerEvent(('chat:server:311source'), source, caller, msg)
  TriggerServerEvent('311', source, caller, msg)
  ExecuteCommand('e telefonlakonuş')
  Citizen.Wait(3500)
  ExecuteCommand('e c')
end, false)


RegisterNetEvent('chat:EmergencySend911r')
AddEventHandler('chat:EmergencySend911r', function(fal, caller, msg)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
      TriggerEvent('chat:addMessage', {
      template = '<div class="chat-message emergency">911r | ({1}) {0}: {2} </div>',
      args = {caller, fal, msg}
      });
  end
end)

RegisterNetEvent('chat:EmergencySend311r')
AddEventHandler('chat:EmergencySend311r', function(fal, caller, msg)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
      TriggerEvent('chat:addMessage', {
      template = '<div class="chat-message nonemergency">311r | ({1}) {0}: {2} </div>',
      args = {caller, fal, msg}
      });
  end
end)

RegisterNetEvent('chat:EmergencySend911')
AddEventHandler('chat:EmergencySend911', function(fal, caller, msg)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
      TriggerEvent('chat:addMessage', {
      template = '<div class="chat-message emergency">911 | ({1}) {0}: {2} </div>',
      args = {caller, fal, msg}
      });
  end
end)

RegisterNetEvent('chat:EmergencySend311')
AddEventHandler('chat:EmergencySend311', function(fal, caller, msg)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
      TriggerEvent('chat:addMessage', {
      template = '<div class="chat-message nonemergency">311 | ({1}) {0}: {2} </div>',
      args = {caller, fal, msg}
      });
  end
end)

RegisterCommand('911r', function(target, args, rawCommand)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
      local source = GetPlayerServerId(PlayerId())
      local target = tonumber(args[1])
      local msg = rawCommand:sub(8)
      TriggerServerEvent(('chat:server:911r'), target, source, msg)
      TriggerServerEvent('911r', target, source, msg)
  end
end, false)

RegisterCommand('311r', function(target, args, rawCommand)
  if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then 
      local source = GetPlayerServerId(PlayerId())
      local target = tonumber(args[1])
      local msg = rawCommand:sub(8)
      TriggerServerEvent(('chat:server:311r'), target, source, msg)
      TriggerServerEvent('311r', target, source, msg)
  end
end, false)
