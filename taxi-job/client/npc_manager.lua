-- Taxi Job: NPC Manager
local activeNPCs = {}
local npcBlips = {}
local isNPCManagerActive = false

-- Start NPC Manager
RegisterNetEvent('taxi:startNPCManager')
AddEventHandler('taxi:startNPCManager', function()
    if not Config.EnableNPCPassengers then return end
    if isNPCManagerActive then return end
    
    isNPCManagerActive = true
    
    -- Debug message
    if Config.Debug then
        print('NPC Manager started')
    end
    
    -- Start the NPC manager thread
    CreateThread(function()
        while isNPCManagerActive do
            -- Only spawn NPCs if we're on duty, in a taxi, and don't have a current fare
            if isOnDuty and currentVehicle and not currentFare then
                -- Check if we can spawn more NPCs
                if #activeNPCs < Config.MaxActiveNPCs then
                    -- Random chance to spawn an NPC
                    if math.random(1, 100) <= 30 then -- 30% chance every check
                        SpawnRandomNPC()
                    end
                end
            end
            
            -- Check existing NPCs
            ManageExistingNPCs()
            
            -- Wait before next check
            Wait(5000) -- Check every 5 seconds
        end
    end)
end)

-- Stop NPC Manager
RegisterNetEvent('taxi:stopNPCManager')
AddEventHandler('taxi:stopNPCManager', function()
    isNPCManagerActive = false
    
    -- Clean up any active NPCs
    for _, npc in pairs(activeNPCs) do
        if DoesEntityExist(npc.ped) then
            DeleteEntity(npc.ped)
        end
        
        if npc.blip and DoesBlipExist(npc.blip) then
            RemoveBlip(npc.blip)
        end
    end
    
    activeNPCs = {}
    
    -- Debug message
    if Config.Debug then
        print('NPC Manager stopped')
    end
end)

-- Spawn Random NPC
function SpawnRandomNPC()
    -- Get player position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Select a random spawn location from config
    local spawnLocation = Config.NPCSpawnLocations[math.random(1, #Config.NPCSpawnLocations)]
    
    -- Check if spawn location is too close to player
    if #(playerCoords - spawnLocation.coords) < Config.NPCSpawnDistance then
        return -- Too close, try again later
    end
    
    -- Select a random destination from this spawn location
    local destination = spawnLocation.destinations[math.random(1, #spawnLocation.destinations)]
    
    -- Create the NPC
    local pedModel = GetRandomPedModel()
    RequestModel(pedModel)
    
    local attempts = 0
    while not HasModelLoaded(pedModel) and attempts < 30 do
        attempts = attempts + 1
        Wait(100)
    end
    
    if not HasModelLoaded(pedModel) then
        if Config.Debug then
            print('Failed to load NPC model')
        end
        return
    end
    
    -- Create the ped
    local ped = CreatePed(4, pedModel, spawnLocation.coords.x, spawnLocation.coords.y, spawnLocation.coords.z, 0.0, true, true)
    
    -- Set ped properties
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedCanRagdoll(ped, false)
    SetPedConfigFlag(ped, 185, true) -- Disable weapon drops
    SetPedConfigFlag(ped, 108, true) -- Disable melee combat
    
    -- Make the ped wait
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
    
    -- Create blip if enabled
    local blip = nil
    if Config.ShowCustomerBlips then
        blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, Config.CustomerBlipSprite)
        SetBlipColour(blip, Config.CustomerBlipColor)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Taxi Customer')
        EndTextCommandSetBlipName(blip)
    end
    
    -- Add to active NPCs
    local npcData = {
        ped = ped,
        blip = blip,
        spawnTime = GetGameTimer(),
        pickedUp = false,
        destination = destination,
        fare = CalculateNPCFare(spawnLocation.coords, destination.coords)
    }
    
    table.insert(activeNPCs, npcData)
    
    -- Debug message
    if Config.Debug then
        print('Spawned NPC at ' .. tostring(spawnLocation.coords) .. ' going to ' .. destination.name)
    end
    
    -- Clean up
    SetModelAsNoLongerNeeded(pedModel)
end

-- Manage Existing NPCs
function ManageExistingNPCs()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
    
    for i, npc in pairs(activeNPCs) do
        if DoesEntityExist(npc.ped) then
            local npcCoords = GetEntityCoords(npc.ped)
            local distanceToNPC = #(playerCoords - npcCoords)
            
            -- Check if NPC has been waiting too long
            if not npc.pickedUp and (GetGameTimer() - npc.spawnTime) > Config.NPCWaitTime then
                -- NPC has waited too long, delete them
                if Config.Debug then
                    print('NPC waited too long, removing')
                end
                
                DeleteEntity(npc.ped)
                
                if npc.blip and DoesBlipExist(npc.blip) then
                    RemoveBlip(npc.blip)
                end
                
                table.remove(activeNPCs, i)
            elseif not npc.pickedUp and distanceToNPC < 30.0 then
                -- Player is close to NPC, show notification if not already shown
                if not npc.notificationShown then
                    ShowNotification('A potential customer is nearby. Stop to pick them up')
                    npc.notificationShown = true
                end
                
                -- Check if player stopped near NPC
                if distanceToNPC < 10.0 and playerVehicle == currentVehicle and GetEntitySpeed(playerVehicle) < 0.5 then
                    -- Pick up the NPC
                    PickUpNPC(i, npc)
                end
            elseif npc.pickedUp then
                -- NPC is in the taxi, check if we're at the destination
                local distanceToDestination = #(playerCoords - npc.destination.coords)
                
                if distanceToDestination < 30.0 and not npc.destinationNotificationShown then
                    ShowNotification('You are approaching the destination')
                    npc.destinationNotificationShown = true
                end
                
                if distanceToDestination < 10.0 and GetEntitySpeed(playerVehicle) < 0.5 then
                    -- Drop off the NPC
                    DropOffNPC(i, npc)
                end
            end
        else
            -- NPC entity doesn't exist anymore, clean up
            if npc.blip and DoesBlipExist(npc.blip) then
                RemoveBlip(npc.blip)
            end
            
            table.remove(activeNPCs, i)
        end
    end
end

-- Pick Up NPC
function PickUpNPC(index, npc)
    -- Clear current tasks
    ClearPedTasks(npc.ped)
    
    -- Get into the vehicle
    local vehicle = currentVehicle
    TaskEnterVehicle(npc.ped, vehicle, -1, 2, 1.0, 1, 0)
    
    -- Update NPC data
    npc.pickedUp = true
    activeNPCs[index] = npc
    
    -- Set as current fare
    currentFare = {
        type = 'npc',
        ped = npc.ped,
        destination = npc.destination,
        fare = npc.fare
    }
    
    -- Start the meter
    StartMeter()
    
    -- Update blip to destination
    if npc.blip and DoesBlipExist(npc.blip) then
        RemoveBlip(npc.blip)
    end
    
    if Config.ShowCustomerBlips then
        npc.blip = AddBlipForCoord(npc.destination.coords)
        SetBlipSprite(npc.blip, 162) -- Destination sprite
        SetBlipColour(npc.blip, 5)
        SetBlipRoute(npc.blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Taxi Destination: ' .. npc.destination.name)
        EndTextCommandSetBlipName(npc.blip)
    end
    
    -- Notification
    ShowNotification('Customer picked up. Take them to ' .. npc.destination.name)
    
    -- Debug message
    if Config.Debug then
        print('Picked up NPC going to ' .. npc.destination.name)
    end
end

-- Drop Off NPC
function DropOffNPC(index, npc)
    -- Get out of the vehicle
    TaskLeaveVehicle(npc.ped, currentVehicle, 0)
    Wait(2000) -- Wait for NPC to exit vehicle
    
    -- Make NPC walk away
    TaskWanderStandard(npc.ped, 10.0, 10)
    
    -- Set NPC to no longer be a mission entity so it can despawn naturally
    SetEntityAsNoLongerNeeded(npc.ped)
    
    -- Remove blip
    if npc.blip and DoesBlipExist(npc.blip) then
        RemoveBlip(npc.blip)
    end
    
    -- Calculate final fare
    local finalFare = currentFare.fare
    
    -- Add random tip?
    local tipAmount = 0
    if math.random(1, 100) <= Config.NPCTipChance then
        tipAmount = math.random(Config.NPCTipMin, Config.NPCTipMax)
        finalFare = finalFare + tipAmount
    end
    
    -- Stop meter
    StopMeter()
    
    -- Pay the player
    TriggerServerEvent('taxi:receivePayment', finalFare)
    
    -- Notification
    if tipAmount > 0 then
        ShowNotification('Customer dropped off. Fare: $' .. finalFare - tipAmount .. ' + $' .. tipAmount .. ' tip')
    else
        ShowNotification('Customer dropped off. Fare: $' .. finalFare)
    end
    
    -- Remove from active NPCs
    table.remove(activeNPCs, index)
    
    -- Clear current fare
    currentFare = nil
    
    -- Debug message
    if Config.Debug then
        print('Dropped off NPC, received $' .. finalFare)
    end
end

-- Calculate NPC Fare
function CalculateNPCFare(startCoords, endCoords)
    -- Calculate distance
    local distance = #(startCoords - endCoords) / 1000.0 -- Convert to kilometers
    
    -- Calculate fare based on distance
    local fare = Config.BasePrice + (distance * Config.PricePerKM)
    
    -- Round to nearest whole number
    fare = math.floor(fare + 0.5)
    
    return fare
end

-- Get Random Ped Model
function GetRandomPedModel()
    local pedModels = {
        'a_f_m_beach_01',
        'a_f_m_bevhills_01',
        'a_f_m_bevhills_02',
        'a_f_m_bodybuild_01',
        'a_f_m_business_02',
        'a_f_y_business_01',
        'a_f_y_business_02',
        'a_f_y_business_03',
        'a_f_y_business_04',
        'a_m_m_business_01',
        'a_m_m_eastsa_01',
        'a_m_m_eastsa_02',
        'a_m_m_farmer_01',
        'a_m_m_fatlatin_01',
        'a_m_m_genfat_01',
        'a_m_m_genfat_02',
        'a_m_m_golfer_01',
        'a_m_m_hasjew_01',
        'a_m_m_hillbilly_01',
        'a_m_m_hillbilly_02',
        'a_m_m_indian_01',
        'a_m_m_ktown_01',
        'a_m_m_malibu_01',
        'a_m_m_mexcntry_01',
        'a_m_m_mexlabor_01',
        'a_m_m_og_boss_01',
        'a_m_m_paparazzi_01',
        'a_m_m_polynesian_01',
        'a_m_m_prolhost_01',
        'a_m_m_rurmeth_01',
        'a_m_m_salton_01',
        'a_m_m_salton_02',
        'a_m_m_salton_03',
        'a_m_m_salton_04',
        'a_m_m_skater_01',
        'a_m_m_skidrow_01',
        'a_m_m_socenlat_01',
        'a_m_m_soucent_01',
        '