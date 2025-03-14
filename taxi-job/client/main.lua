-- Taxi Job: Main Client Script
local ESX, QBCore = nil, nil
local PlayerData = {}
local isOnDuty = false
local currentVehicle = nil
local currentFare = nil
local meterActive = false
local meterStart = 0
local startLocation = nil
local totalDistance = 0
local fareAmount = 0
local taxiBlip = nil
local taxiDepotBlip = nil

-- Framework Detection and Initialization
CreateThread(function()
    if Config.UseESX then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(0)
        end

        while ESX.GetPlayerData().job == nil do
            Wait(10)
        end

        PlayerData = ESX.GetPlayerData()
    elseif Config.UseQBCore then
        QBCore = exports['qb-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate')
        AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
    end

    -- Create taxi depot blip
    CreateTaxiDepotBlip()
    
    -- Initialize the taxi job
    InitializeTaxiJob()
 end)

-- Initialize Taxi Job
function InitializeTaxiJob()
    -- Register command to toggle duty
    RegisterCommand('taxiduty', function()
        ToggleDuty()
    end, false)

    -- Register keybind for UI
    if Config.UIEnabled then
        RegisterKeyMapping('taxiui', 'Toggle Taxi UI', 'keyboard', Config.UIKey)
        RegisterCommand('taxiui', function()
            ToggleTaxiUI()
        end, false)
    end

    -- Main loop for taxi job
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Check if player is near taxi depot
            local distanceToDepot = #(playerCoords - Config.TaxiDepotBlip.coords)
            
            if distanceToDepot < 30.0 then
                sleep = 0
                
                -- Draw marker at depot
                DrawMarker(1, Config.TaxiDepotBlip.coords.x, Config.TaxiDepotBlip.coords.y, Config.TaxiDepotBlip.coords.z - 1.0, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                -- Check if player is very close to depot
                if distanceToDepot < 3.0 then
                    -- Display help text
                    DisplayHelpText('Press ~INPUT_CONTEXT~ to access the taxi depot')
                    
                    -- Check for interaction key press
                    if IsControlJustReleased(0, 38) then -- E key
                        OpenTaxiMenu()
                    end
                end
            end
            
            -- If on duty and in a taxi, update the meter
            if isOnDuty and currentVehicle and meterActive then
                sleep = 0
                UpdateTaxiMeter()
            end
            
            Wait(sleep)
        end
    end)
    
    -- Register events
    RegisterNetEvent('taxi:toggleMeter')
    AddEventHandler('taxi:toggleMeter', function()
        ToggleMeter()
    end)
    
    RegisterNetEvent('taxi:resetMeter')
    AddEventHandler('taxi:resetMeter', function()
        ResetMeter()
    end)
    
    RegisterNetEvent('taxi:collectPayment')
    AddEventHandler('taxi:collectPayment', function()
        CollectPayment()
    end)
    
    -- Debug message
    if Config.Debug then
        print('Taxi job initialized')
    end
end

-- Toggle Duty Status
function ToggleDuty()
    if Config.RequireJob then
        local hasJob = false
        
        if Config.UseESX and PlayerData.job and PlayerData.job.name == Config.JobName then
            hasJob = true
        elseif Config.UseQBCore and PlayerData.job and PlayerData.job.name == Config.JobName then
            hasJob = true
        end
        
        if not hasJob then
            ShowNotification('You need to be a taxi driver to use this')
            return
        end
    end
    
    isOnDuty = not isOnDuty
    
    if isOnDuty then
        ShowNotification('You are now on duty as a taxi driver')
    else
        ShowNotification('You are now off duty')
        
        -- Clean up if going off duty
        if currentVehicle then
            -- Reset meter if active
            if meterActive then
                ResetMeter()
            end
        end
    end
    
    -- Trigger server event for duty status
    TriggerServerEvent('taxi:updateDutyStatus', isOnDuty)
    
    -- Update UI if enabled
    if Config.UIEnabled then
        SendNUIMessage({
            type = 'updateDuty',
            status = isOnDuty
        })
    end
end

-- Open Taxi Menu
function OpenTaxiMenu()
    if Config.UseESX then
        local elements = {}
        
        -- Duty toggle option
        table.insert(elements, {label = (isOnDuty and 'Go Off Duty' or 'Go On Duty'), value = 'duty'})
        
        -- Vehicle options if on duty
        if isOnDuty then
            table.insert(elements, {label = 'Get Taxi Vehicle', value = 'vehicle'})
            
            if currentVehicle then
                table.insert(elements, {label = 'Return Vehicle', value = 'return'})
            end
        end
        
        ESX.UI.Menu.CloseAll()
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'taxi_menu', {
            title = 'Taxi Depot',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            if data.current.value == 'duty' then
                ToggleDuty()
                menu.close()
                Wait(500) -- Short delay before reopening with updated options
                OpenTaxiMenu()
            elseif data.current.value == 'vehicle' then
                OpenVehicleMenu()
            elseif data.current.value == 'return' then
                ReturnVehicle()
                menu.close()
            end
        end, function(data, menu)
            menu.close()
        end)
    elseif Config.UseQBCore then
        -- QBCore menu implementation
        local menuItems = {}
        
        -- Duty toggle option
        menuItems[#menuItems+1] = {
            header = "Taxi Depot",
            isMenuHeader = true
        }
        
        menuItems[#menuItems+1] = {
            header = isOnDuty and "Go Off Duty" or "Go On Duty",
            params = {
                event = "taxi:toggleDuty"
            }
        }
        
        -- Vehicle options if on duty
        if isOnDuty then
            menuItems[#menuItems+1] = {
                header = "Get Taxi Vehicle",
                params = {
                    event = "taxi:openVehicleMenu"
                }
            }
            
            if currentVehicle then
                menuItems[#menuItems+1] = {
                    header = "Return Vehicle",
                    params = {
                        event = "taxi:returnVehicle"
                    }
                }
            end
        end
        
        exports['qb-menu']:openMenu(menuItems)
        
        -- Register events for QBCore menu
        RegisterNetEvent('taxi:toggleDuty')
        AddEventHandler('taxi:toggleDuty', function()
            ToggleDuty()
            Wait(500)
            TriggerEvent('taxi:openDepotMenu')
        end)
        
        RegisterNetEvent('taxi:openVehicleMenu')
        AddEventHandler('taxi:openVehicleMenu', function()
            OpenVehicleMenu()
        end)
        
        RegisterNetEvent('taxi:returnVehicle')
        AddEventHandler('taxi:returnVehicle', function()
            ReturnVehicle()
        end)
        
        RegisterNetEvent('taxi:openDepotMenu')
        AddEventHandler('taxi:openDepotMenu', function()
            OpenTaxiMenu()
        end)
    else
        -- Native menu for non-framework servers
        if isOnDuty then
            if not currentVehicle then
                if DisplayConfirmationMessage('Get a taxi vehicle?') then
                    OpenVehicleMenu()
                end
            else
                if DisplayConfirmationMessage('Return your current vehicle?') then
                    ReturnVehicle()
                end
            end
        else
            if DisplayConfirmationMessage('Go on duty as a taxi driver?') then
                ToggleDuty()
            end
        end
    end
end

-- Open Vehicle Selection Menu
function OpenVehicleMenu()
    if Config.UseESX then
        local elements = {}
        
        for i, vehicle in ipairs(Config.TaxiVehicles) do
            table.insert(elements, {label = vehicle.label, value = vehicle.model})
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'taxi_vehicle', {
            title = 'Select Taxi Vehicle',
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            SpawnTaxiVehicle(data.current.value)
            menu.close()
        end, function(data, menu)
            menu.close()
            OpenTaxiMenu()
        end)
    elseif Config.UseQBCore then
        -- QBCore menu implementation
        local menuItems = {}
        
        menuItems[#menuItems+1] = {
            header = "Select Taxi Vehicle",
            isMenuHeader = true
        }
        
        for i, vehicle in ipairs(Config.TaxiVehicles) do
            menuItems[#menuItems+1] = {
                header = vehicle.label,
                params = {
                    event = "taxi:spawnVehicle",
                    args = {
                        model = vehicle.model
                    }
                }
            }
        end
        
        menuItems[#menuItems+1] = {
            header = "⬅ Go Back",
            params = {
                event = "taxi:openDepotMenu"
            }
        }
        
        exports['qb-menu']:openMenu(menuItems)
        
        -- Register event for QBCore vehicle spawn
        RegisterNetEvent('taxi:spawnVehicle')
        AddEventHandler('taxi:spawnVehicle', function(data)
            SpawnTaxiVehicle(data.model)
        end)
    else
        -- Native menu for non-framework servers
        local options = {}
        for i, vehicle in ipairs(Config.TaxiVehicles) do
            options[i] = vehicle.label
        end
        
        local selectedIndex = OpenNativeMenu('Select Taxi Vehicle', options)
        if selectedIndex > 0 then
            SpawnTaxiVehicle(Config.TaxiVehicles[selectedIndex].model)
        end
    end
end

-- Spawn Taxi Vehicle
function SpawnTaxiVehicle(model)
    -- Check if player already has a vehicle
    if currentVehicle then
        ShowNotification('You already have a taxi vehicle out')
        return
    end
    
    -- Find an available spawn point
    local spawnPoint = nil
    for _, point in ipairs(Config.VehicleSpawnPoints) do
        if IsSpawnPointClear(point.coords, 3.0) then
            spawnPoint = point
            break
        end
    end
    
    if not spawnPoint then
        ShowNotification('All spawn points are blocked. Please try again later')
        return
    end
    
    -- Request the model
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    local attempts = 0
    while not HasModelLoaded(hash) and attempts < 30 do
        attempts = attempts + 1
        Wait(100)
    end
    
    if not HasModelLoaded(hash) then
        ShowNotification('Failed to load vehicle model')
        return
    end
    
    -- Spawn the vehicle
    local vehicle = CreateVehicle(hash, spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, spawnPoint.heading, true, false)
    
    -- Set as mission entity so it can be deleted properly
    SetEntityAsMissionEntity(vehicle, true, true)
    
    -- Set vehicle properties
    SetVehicleNumberPlateText(vehicle, 'TAXI' .. tostring(math.random(100, 999)))
    SetVehicleColours(vehicle, 88, 88) -- Yellow taxi color
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleEngineOn(vehicle, true, true, false)
    
    -- Store the vehicle
    currentVehicle = vehicle
    
    -- Teleport player into vehicle
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
    -- Notification
    ShowNotification('You have received a taxi vehicle')
    
    -- Clean up
    SetModelAsNoLongerNeeded(hash)
    
    -- If NPC passengers are enabled, start the NPC manager
    if Config.EnableNPCPassengers then
        TriggerEvent('taxi:startNPCManager')
    end
end

-- Return Vehicle
function ReturnVehicle()
    if not currentVehicle then
        ShowNotification('You don\'t have a taxi vehicle