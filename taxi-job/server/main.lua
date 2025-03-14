-- Taxi Job: Main Server Script
local ESX, QBCore = nil, nil
local onDutyDrivers = {}

-- Framework Detection and Initialization
if Config.UseESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    
    -- Register the job with ESX
    if ESX.RegisterUsableItem then
        -- If you want to add usable items for the taxi job
    end
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
    
    -- Register the job with QBCore
    if QBCore.Functions.CreateUseableItem then
        -- If you want to add usable items for the taxi job
    end
end

-- Update Driver Duty Status
RegisterNetEvent('taxi:updateDutyStatus')
AddEventHandler('taxi:updateDutyStatus', function(isOnDuty)
    local source = source
    
    if isOnDuty then
        -- Add to on duty drivers
        onDutyDrivers[tostring(source)] = true
        
        -- Start player transport for this driver
        TriggerClientEvent('taxi:startPlayerTransport', source)
        
        -- Debug message
        if Config.Debug then
            print('Driver ' .. source .. ' went on duty')
        end
    else
        -- Remove from on duty drivers
        onDutyDrivers[tostring(source)] = nil
        
        -- Stop player transport for this driver
        TriggerClientEvent('taxi:stopPlayerTransport', source)
        
        -- Debug message
        if Config.Debug then
            print('Driver ' .. source .. ' went off duty')
        end
    end
end)

-- Receive Payment
RegisterNetEvent('taxi:receivePayment')
AddEventHandler('taxi:receivePayment', function(amount)
    local source = source
    
    -- Validate the amount (basic anti-cheat)
    if amount <= 0 or amount > 10000 then -- Maximum reasonable fare
        -- Potential cheating, log or handle accordingly
        if Config.Debug then
            print('WARNING: Player ' .. source .. ' tried to receive an invalid payment amount: $' .. amount)
        end
        return
    end
    
    -- Process payment based on framework
    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
            
            -- Debug message
            if Config.Debug then
                print('Paid $' .. amount .. ' to driver ' .. source)
            end
        end
    elseif Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('cash', amount)
            
            -- Debug message
            if Config.Debug then
                print('Paid $' .. amount .. ' to driver ' .. source)
            end
        end
    else
        -- For servers without a framework, just send a notification
        TriggerClientEvent('taxi:paymentReceived', source, amount)
        
        -- Debug message
        if Config.Debug then
            print('Notified driver ' .. source .. ' of payment: $' .. amount)
        end
    end
end)

-- Player Disconnection Handling
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Remove from on duty drivers if they were on duty
    if onDutyDrivers[tostring(source)] then
        onDutyDrivers[tostring(source)] = nil
        
        -- Debug message
        if Config.Debug then
            print('Driver ' .. source .. ' disconnected, removed from duty')
        end
    end
end)

-- Get On Duty Drivers Count
function GetOnDutyDriversCount()
    local count = 0
    for _ in pairs(onDutyDrivers) do
        count = count + 1
    end
    return count
end

-- Get Random On Duty Driver
function GetRandomOnDutyDriver()
    local drivers = {}
    for driverId in pairs(onDutyDrivers) do
        table.insert(drivers, tonumber(driverId))
    end
    
    if #drivers > 0 then
        return drivers[math.random(1, #drivers)]
    end
    
    return nil
end

-- Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Initialize the resource
    print('Taxi Job started. Version: ' .. GetResourceMetadata(resourceName, 'version', 0))
    
    -- Reset on duty drivers
    onDutyDrivers = {}
end)

-- Resource Stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Clean up
    print('Taxi Job stopped')
end)