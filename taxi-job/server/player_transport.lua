-- Taxi Job: Player Transport Server Script
local activePlayerCalls = {}
local callIdCounter = 0

-- Call Taxi
RegisterNetEvent('taxi:callTaxi')
AddEventHandler('taxi:callTaxi', function(coords)
    local source = source
    
    -- Generate a unique call ID
    callIdCounter = callIdCounter + 1
    
    -- Create call data
    local callData = {
        id = callIdCounter,
        source = source,
        coords = coords,
        time = os.time()
    }
    
    -- Add to active calls
    table.insert(activePlayerCalls, callData)
    
    -- Debug message
    if Config.Debug then
        print('Player ' .. source .. ' called a taxi at ' .. tostring(coords))
    end
    
    -- Broadcast to all on-duty taxi drivers
    for driverId, _ in pairs(onDutyDrivers) do
        TriggerClientEvent('taxi:receivePlayerCall', tonumber(driverId), callData)
    end
    
    -- If no drivers are on duty, notify the player
    if GetOnDutyDriversCount() == 0 then
        TriggerClientEvent('taxi:noDriversAvailable', source)
    end
end)

-- Accept Call
RegisterNetEvent('taxi:acceptCall')
AddEventHandler('taxi:acceptCall', function(playerSource)
    local source = source
    
    -- Validate that the driver is on duty
    if not onDutyDrivers[tostring(source)] then
        return
    end
    
    -- Validate that the player exists
    if not GetPlayerPing(playerSource) then
        TriggerClientEvent('taxi:playerNotFound', source)
        return
    end
    
    -- Remove the call from active calls
    for i, call in ipairs(activePlayerCalls) do
        if call.source == playerSource then
            table.remove(activePlayerCalls, i)
            break
        end
    end
    
    -- Notify the player that their call was accepted
    TriggerClientEvent('taxi:callAccepted', playerSource, source)
    
    -- Debug message
    if Config.Debug then
        print('Driver ' .. source .. ' accepted call from player ' .. playerSource)
    end
end)

-- Pickup Player
RegisterNetEvent('taxi:pickupPlayer')
AddEventHandler('taxi:pickupPlayer', function(playerSource)
    local source = source
    
    -- Validate that the driver is on duty
    if not onDutyDrivers[tostring(source)] then
        return
    end
    
    -- Validate that the player exists
    if not GetPlayerPing(playerSource) then
        TriggerClientEvent('taxi:playerNotFound', source)
        return
    end
    
    -- Notify the player that they've been picked up
    TriggerClientEvent('taxi:pickedUp', playerSource, source)
    
    -- Debug message
    if Config.Debug then
        print('Driver ' .. source .. ' picked up player ' .. playerSource)
    end
end)

-- Drop Off Player
RegisterNetEvent('taxi:dropOffPlayer')
AddEventHandler('taxi:dropOffPlayer', function(playerSource, fare)
    local source = source
    
    -- Validate that the driver is on duty
    if not onDutyDrivers[tostring(source)] then
        return
    end
    
    -- Validate that the player exists
    if not GetPlayerPing(playerSource) then
        TriggerClientEvent('taxi:playerNotFound', source)
        return
    end
    
    -- Validate the fare amount (basic anti-cheat)
    if fare <= 0 or fare > 10000 then -- Maximum reasonable fare
        -- Potential cheating, log or handle accordingly
        if Config.Debug then
            print('WARNING: Driver ' .. source .. ' tried to charge an invalid fare amount: $' .. fare)
        end
        return
    end
    
    -- Notify the player that they've been dropped off and how much they owe
    TriggerClientEvent('taxi:droppedOff', playerSource, fare)
    
    -- Process payment based on framework
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(playerSource)
        local xDriver = ESX.GetPlayerFromId(source)
        
        if xPlayer and xDriver then
            -- Check if player has enough money
            if xPlayer.getMoney() >= fare then
                xPlayer.removeMoney(fare)
                xDriver.addMoney(fare)
                
                -- Notify both parties
                TriggerClientEvent('taxi:paymentComplete', playerSource, fare)
                TriggerClientEvent('taxi:paymentReceived', source, fare)
            else
                -- Not enough money
                TriggerClientEvent('taxi:insufficientFunds', playerSource)
                TriggerClientEvent('taxi:paymentFailed', source)
            end
        end
    elseif Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(playerSource)
        local Driver = QBCore.Functions.GetPlayer(source)
        
        if Player and Driver then
            -- Check if player has enough money
            if Player.Functions.GetMoney('cash') >= fare then
                Player.Functions.RemoveMoney('cash', fare)
                Driver.Functions.AddMoney('cash', fare)
                
                -- Notify both parties
                TriggerClientEvent('taxi:paymentComplete', playerSource, fare)
                TriggerClientEvent('taxi:paymentReceived', source, fare)
            else
                -- Not enough money
                TriggerClientEvent('taxi:insufficientFunds', playerSource)
                TriggerClientEvent('taxi:paymentFailed', source)
            end
        end
    else
        -- For servers without a framework, just notify both parties
        TriggerClientEvent('taxi:paymentComplete', playerSource, fare)
        TriggerClientEvent('taxi:paymentReceived', source, fare)
    end
    
    -- Debug message
    if Config.Debug then
        print('Driver ' .. source .. ' dropped off player ' .. playerSource .. ' with fare $' .. fare)
    end
end)

-- Clean up expired calls
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local currentTime = os.time()
        
        for i, call in ipairs(activePlayerCalls) do
            -- Check if call has expired (5 minutes)
            if (currentTime - call.time) > 300 then
                -- Remove from active calls
                table.remove(activePlayerCalls, i)
                
                -- Notify the player that no drivers accepted their call
                TriggerClientEvent('taxi:callExpired', call.source)
                
                -- Debug message
                if Config.Debug then
                    print('Taxi call from player ' .. call.source .. ' expired')
                end
            end
        end
    end
end)

-- Player Disconnection Handling
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Remove any active calls from this player
    for i, call in ipairs(activePlayerCalls) do
        if call.source == source then
            table.remove(activePlayerCalls, i)
            
            -- Debug message
            if Config.Debug then
                print('Player ' .. source .. ' disconnected, removed their taxi call')
            end
            
            break
        end
    end
end)