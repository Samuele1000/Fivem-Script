-- Taxi Job: Utility Functions

-- Create Taxi Depot Blip
function CreateTaxiDepotBlip()
    if taxiDepotBlip and DoesBlipExist(taxiDepotBlip) then
        RemoveBlip(taxiDepotBlip)
    end
    
    taxiDepotBlip = AddBlipForCoord(Config.TaxiDepotBlip.coords)
    SetBlipSprite(taxiDepotBlip, Config.TaxiDepotBlip.sprite)
    SetBlipColour(taxiDepotBlip, Config.TaxiDepotBlip.color)
    SetBlipScale(taxiDepotBlip, Config.TaxiDepotBlip.scale)
    SetBlipAsShortRange(taxiDepotBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.TaxiDepotBlip.name)
    EndTextCommandSetBlipName(taxiDepotBlip)
    
    -- Debug message
    if Config.Debug then
        print('Created taxi depot blip at ' .. tostring(Config.TaxiDepotBlip.coords))
    end
end

-- Show Notification
function ShowNotification(message)
    if Config.NotificationType == 'native' then
        -- Native GTA notification
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentString(message)
        EndTextCommandThefeedPostTicker(true, false)
    elseif Config.NotificationType == 'mythic' then
        -- Mythic Notifications
        exports['mythic_notify']:DoHudText('inform', message)
    elseif Config.NotificationType == 'esx' then
        -- ESX Notification
        ESX.ShowNotification(message)
    elseif Config.NotificationType == 'qbcore' then
        -- QBCore Notification
        QBCore.Functions.Notify(message, 'primary')
    end
end

-- Display Help Text
function DisplayHelpText(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Toggle Taxi UI
function ToggleTaxiUI()
    if not Config.UIEnabled then return end
    
    SendNUIMessage({
        type = 'toggleUI'
    })
    
    -- Debug message
    if Config.Debug then
        print('Toggled taxi UI')
    end
end

-- Update Taxi UI
function UpdateTaxiUI(data)
    if not Config.UIEnabled then return end
    
    SendNUIMessage({
        type = 'updateUI',
        data = data
    })
    
    -- Debug message
    if Config.Debug then
        print('Updated taxi UI with data: ' .. json.encode(data))
    end
end

-- Start Meter
function StartMeter()
    if meterActive then return end
    
    meterActive = true
    meterStart = GetGameTimer()
    startLocation = GetEntityCoords(PlayerPedId())
    totalDistance = 0
    fareAmount = Config.BasePrice
    
    -- Update UI
    if Config.UIEnabled then
        UpdateTaxiUI({
            meterActive = true,
            fare = fareAmount
        })
    end
    
    -- Notification
    ShowNotification('Meter started. Base fare: $' .. Config.BasePrice)
    
    -- Debug message
    if Config.Debug then
        print('Started taxi meter')
    end
end

-- Stop Meter
function StopMeter()
    if not meterActive then return end
    
    meterActive = false
    
    -- Update UI
    if Config.UIEnabled then
        UpdateTaxiUI({
            meterActive = false,
            fare = fareAmount
        })
    end
    
    -- Notification
    ShowNotification('Meter stopped. Final fare: $' .. fareAmount)
    
    -- Debug message
    if Config.Debug then
        print('Stopped taxi meter. Final fare: $' .. fareAmount)
    end
end

-- Reset Meter
function ResetMeter()
    meterActive = false
    meterStart = 0
    startLocation = nil
    totalDistance = 0
    fareAmount = 0
    
    -- Update UI
    if Config.UIEnabled then
        UpdateTaxiUI({
            meterActive = false,
            fare = 0
        })
    end
    
    -- Notification
    ShowNotification('Meter reset')
    
    -- Debug message
    if Config.Debug then
        print('Reset taxi meter')
    end
end

-- Update Taxi Meter
function UpdateTaxiMeter()
    if not meterActive then return end
    
    local playerPed = PlayerPedId()
    local currentLocation = GetEntityCoords(playerPed)
    
    -- Calculate distance traveled since last update
    local distanceTraveled = #(currentLocation - startLocation) / 1000.0 -- Convert to kilometers
    
    -- Update total distance
    totalDistance = totalDistance + distanceTraveled
    
    -- Update fare amount based on distance
    local distanceFare = distanceTraveled * Config.PricePerKM
    fareAmount = fareAmount + distanceFare
    
    -- Round fare to nearest whole number
    fareAmount = math.floor(fareAmount + 0.5)
    
    -- Update UI
    if Config.UIEnabled then
        UpdateTaxiUI({
            meterActive = true,
            fare = fareAmount,
            distance = totalDistance
        })
    end
    
    -- Update start location for next calculation
    startLocation = currentLocation
end

-- Collect Payment
function CollectPayment()
    if not meterActive and fareAmount > 0 then
        -- Trigger server event to receive payment
        TriggerServerEvent('taxi:receivePayment', fareAmount)
        
        -- Notification
        ShowNotification('Payment collected: $' .. fareAmount)
        
        -- Reset meter
        ResetMeter()
        
        -- Debug message
        if Config.Debug then
            print('Collected payment: $' .. fareAmount)
        end
    else
        ShowNotification('No fare to collect')
    end
end

-- Check if Spawn Point is Clear
function IsSpawnPointClear(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(coords - vehicleCoords)
            
            if distance < radius then
                return false
            end
        end
    end
    
    return true
end

-- Display Confirmation Message (for non-framework servers)
function DisplayConfirmationMessage(message)
    AddTextEntry('TAXI_CONFIRM', message .. '\nPress ~g~Y~s~ to confirm or ~r~N~s~ to cancel')
    DisplayHelpTextThisFrame('TAXI_CONFIRM', false)
    
    local startTime = GetGameTimer()
    while GetGameTimer() - startTime < 10000 do -- 10 second timeout
        if IsControlJustPressed(0, 246) then -- Y key
            return true
        elseif IsControlJustPressed(0, 306) then -- N key
            return false
        end
        Wait(0)
    end
    
    return false -- Timeout
end

-- Open Native Menu (for non-framework servers)
function OpenNativeMenu(title, options)
    local index = 0
    local selected = 0
    
    while selected == 0 do
        Wait(0)
        
        -- Draw title
        SetTextFont(4)
        SetTextScale(0.5, 0.5)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(title)
        DrawText(0.5, 0.1)
        
        -- Draw options
        for i, option in ipairs(options) do
            local yPos = 0.15 + (i * 0.05)
            
            if i == index then
                -- Selected option
                DrawRect(0.5, yPos, 0.3, 0.04, 52, 152, 219, 150)
            else
                -- Unselected option
                DrawRect(0.5, yPos, 0.3, 0.04, 0, 0, 0, 150)
            end
            
            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextDropShadow()
            SetTextEdge(4, 0, 0, 0, 255)
            SetTextOutline()
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString(option)
            DrawText(0.5, yPos - 0.015)
        end
        
        -- Navigation
        if IsControlJustPressed(0, 172) then -- Up arrow
            if index > 1 then
                index = index - 1
            else
                index = #options
            end
            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        elseif IsControlJustPressed(0, 173) then -- Down arrow
            if index < #options then
                index = index + 1
            else
                index = 1
            end
            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        elseif IsControlJustPressed(0, 176) then -- Enter key
            selected = index
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        elseif IsControlJustPressed(0, 177) then -- Backspace
            selected = -1
            PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        end
    end
    
    return selected
end