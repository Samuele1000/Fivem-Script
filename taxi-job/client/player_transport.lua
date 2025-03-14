-- Taxi Job: Player Transport
local activePlayerCalls = {}
local lastCallTime = 0
local isPlayerTransportActive = false

-- Start Player Transport
RegisterNetEvent('taxi:startPlayerTransport')
AddEventHandler('taxi:startPlayerTransport', function()
    if not Config.EnablePlayerTransport then return end
    if isPlayerTransportActive then return end
    
    isPlayerTransportActive = true
    
    -- Debug message
    if Config.Debug then
        print('Player Transport started')
    end
    
    -- Register events
    RegisterNetEvent('taxi:receivePlayerCall')
    AddEventHandler('taxi:receivePlayerCall', function(callData)
        ReceivePlayerCall(callData)
    end)
    
    -- Debug message
    if Config.Debug then
        print('Player Transport initialized')
    end
end)

-- Stop Player Transport
RegisterNetEvent('taxi:stopPlayerTransport')
AddEventHandler('taxi:stopPlayerTransport', function()
    isPlayerTransportActive = false
    
    -- Clean up any active calls
    for _, call in pairs(activePlayerCalls) do
        if call.blip and DoesBlipExist(call.blip) then
            RemoveBlip(call.blip)
        end
    end
    
    activePlayerCalls = {}
    
    -- Debug message
    if Config.Debug then
        print('Player Transport stopped')
    end
end)

-- Call Taxi (for players to use)
RegisterCommand('calltaxi', function(source, args, rawCommand)
    CallTaxi()
end, false)

-- Call Taxi Function
function CallTaxi()
    -- Check cooldown
    local currentTime = GetGameTimer()
    if (currentTime - lastCallTime) < Config.PlayerCallCooldown then
        local remainingTime = math.ceil((Config.PlayerCallCooldown - (currentTime - lastCallTime)) / 1000)
        ShowNotification('You must wait ' .. remainingTime .. ' seconds before calling another taxi')
        return
    end
    
    -- Get player position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Check if player is in a valid location (not in water, not in air)
    if IsEntityInWater(playerPed) or not IsEntityOnFoot(playerPed) then
        ShowNotification('You must be on foot and on land to call a taxi')
        return
    end
    
    -- Update last call time
    lastCallTime = currentTime
    
    -- Send call to server
    TriggerServerEvent('taxi:callTaxi', playerCoords)
    
    -- Notification
    ShowNotification('Taxi called. Please wait for a driver to accept your request')
    
    -- Debug message
    if Config.Debug then
        print('Player called a taxi at ' .. tostring(playerCoords))
    end
end

-- Receive Player Call
function ReceivePlayerCall(callData)
    -- Only process if we're on duty and in a taxi
    if not isOnDuty or not currentVehicle then
        return
    end
    
    -- Check if we already have too many active calls
    if #activePlayerCalls >= Config.MaxActivePlayerCalls then
        return
    end
    
    -- Create blip for the call
    local blip = nil
    if Config.ShowCustomerBlips then
        blip = AddBlipForCoord(callData.coords)
        SetBlipSprite(blip, Config.CustomerBlipSprite)
        SetBlipColour(blip, Config.CustomerBlipColor)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Taxi Request')
        EndTextCommandSetBlipName(blip)
    end
    
    -- Add to active calls
    table.insert(activePlayerCalls, {
        id = callData.id,
        source = callData.source,
        coords = callData.coords,
        blip = blip,
        time = GetGameTimer()
    })
    
    -- Notification
    ShowNotification('New taxi request received. Check your map for the location')
    
    -- Debug message
    if Config.Debug then
        print('Received taxi call from player ' .. callData.source)
    end
end

-- Accept Player Call
function AcceptPlayerCall(callIndex)
    local call = activePlayerCalls[callIndex]
    
    -- Notify the player that their call was accepted
    TriggerServerEvent('taxi:acceptCall', call.source)
    
    -- Update blip
    if call.blip and DoesBlipExist(call.blip) then
        SetBlipColour(call.blip, 2) -- Green
        SetBlipRoute(call.blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Taxi Pickup')
        EndTextCommandSetBlipName(call.blip)
    end
    
    -- Set as current fare
    currentFare = {
        type = 'player',
        source = call.source,
        pickupCoords = call.coords,
        state = 'pickup'
    }
    
    -- Remove from active calls
    table.remove(activePlayerCalls, callIndex)
    
    -- Remove other call blips
    for _, otherCall in pairs(activePlayerCalls) do
        if otherCall.blip and DoesBlipExist(otherCall.blip) then
            RemoveBlip(otherCall.blip)
        end
    end
    
    -- Clear active calls
    activePlayerCalls = {}
    
    -- Notification
    ShowNotification('You accepted the taxi request. Go to the marked location to pick up the passenger')
    
    -- Debug message
    if Config.Debug then
        print('Accepted taxi call from player ' .. call.source)
    end
end

-- Cancel Player Call
function CancelPlayerCall(callIndex)
    local call = activePlayerCalls[callIndex]
    
    -- Remove blip
    if call.blip and DoesBlipExist(call.blip) then
        RemoveBlip(call.blip)
    end
    
    -- Remove from active calls
    table.remove(activePlayerCalls, callIndex)
    
    -- Notification
    ShowNotification('Taxi request ignored')
    
    -- Debug message
    if Config.Debug then
        print('Ignored taxi call from player ' .. call.source)
    end
end

-- Pickup Player
function PickupPlayer()
    if not currentFare or currentFare.type ~= 'player' or currentFare.state ~= 'pickup' then
        return
    end
    
    -- Notify the player that they've been picked up
    TriggerServerEvent('taxi:pickupPlayer', currentFare.source)
    
    -- Update fare state
    currentFare.state = 'transport'
    
    -- Start meter
    StartMeter()
    
    -- Remove pickup blip
    if currentFare.blip and DoesBlipExist(currentFare.blip) then
        RemoveBlip(currentFare.blip)
        currentFare.blip = nil
    end
    
    -- Notification
    ShowNotification('Passenger picked up. Ask them for their destination')
    
    -- Debug message
    if Config.Debug then
        print('Picked up player ' .. currentFare.source)
    end
end

-- Drop Off Player
function DropOffPlayer()
    if not currentFare or currentFare.type ~= 'player' or currentFare.state ~= 'transport' then
        return
    end
    
    -- Calculate fare based on meter
    local finalFare = fareAmount
    
    -- Stop meter
    StopMeter()
    
    -- Notify the player that they've been dropped off and how much they owe
    TriggerServerEvent('taxi:dropOffPlayer', currentFare.source, finalFare)
    
    -- Notification
    ShowNotification('Passenger dropped off. Fare: $' .. finalFare)
    
    -- Clear current fare
    currentFare = nil
    
    -- Debug message
    if Config.Debug then
        print('Dropped off player, fare: $' .. finalFare)
    end
end

-- Check for Player Pickup
CreateThread(function()
    while true do
        local sleep = 1000
        
        if isOnDuty and currentVehicle and currentFare and currentFare.type == 'player' and currentFare.state == 'pickup' then
            sleep = 0
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distanceToPickup = #(playerCoords - currentFare.pickupCoords)
            
            if distanceToPickup < 30.0 then
                -- Draw marker at pickup location
                DrawMarker(1, currentFare.pickupCoords.x, currentFare.pickupCoords.y, currentFare.pickupCoords.z - 1.0, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                -- Check if player is very close to pickup and stopped
                if distanceToPickup < 10.0 and GetEntitySpeed(currentVehicle) < 0.5 then
                    -- Display help text
                    DisplayHelpText('Press ~INPUT_CONTEXT~ to pick up passenger')
                    
                    -- Check for interaction key press
                    if IsControlJustReleased(0, 38) then -- E key
                        PickupPlayer()
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Check for Player Drop Off
CreateThread(function()
    while true do
        local sleep = 1000
        
        if isOnDuty and currentVehicle and currentFare and currentFare.type == 'player' and currentFare.state == 'transport' then
            sleep = 0
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check if vehicle is stopped
            if GetEntitySpeed(currentVehicle) < 0.5 then
                -- Display help text
                DisplayHelpText('Press ~INPUT_CONTEXT~ to drop off passenger')
                
                -- Check for interaction key press
                if IsControlJustReleased(0, 38) then -- E key
                    DropOffPlayer()
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Manage Player Calls
CreateThread(function()
    while true do
        local sleep = 1000
        
        if isOnDuty and currentVehicle and #activePlayerCalls > 0 and not currentFare then
            sleep = 0
            
            -- Display help text for the first call
            DisplayHelpText('Press ~INPUT_CONTEXT~ to accept or ~INPUT_FRONTEND_RRIGHT~ to reject the taxi request')
            
            -- Check for interaction key press
            if IsControlJustReleased(0, 38) then -- E key
                AcceptPlayerCall(1)
            elseif IsControlJustReleased(0, 194) then -- Backspace key
                CancelPlayerCall(1)
            end
        end
        
        Wait(sleep)
    end
end)

-- Clean up expired calls
CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds
        
        local currentTime = GetGameTimer()
        
        for i, call in pairs(activePlayerCalls) do
            -- Check if call has expired (5 minutes)
            if (currentTime - call.time) > 300000 then
                -- Remove blip
                if call.blip and DoesBlipExist(call.blip) then
                    RemoveBlip(call.blip)
                end
                
                -- Remove from active calls
                table.remove(activePlayerCalls, i)
                
                -- Debug message
                if Config.Debug then
                    print('Taxi call from player ' .. call.source .. ' expired')
                end
            end
        end
    end
end)