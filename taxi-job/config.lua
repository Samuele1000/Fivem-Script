Config = {}

-- General Settings
Config.Debug = false -- Enable debug mode for additional console outputs
Config.UseESX = true -- Set to true if using ESX framework
Config.UseQBCore = false -- Set to true if using QBCore framework

-- Job Settings
Config.RequireJob = true -- Set to true if player needs taxi job to use the script
Config.JobName = 'taxi' -- Name of the job in your framework

-- Vehicle Settings
Config.TaxiVehicles = {
    {model = 'taxi', label = 'Standard Taxi'},
    {model = 'taxiold', label = 'Classic Taxi'},
    {model = 'cabby', label = 'Cabby'}
}
Config.VehicleSpawnPoints = {
    {coords = vector3(895.0, -179.0, 74.0), heading = 240.0},
    {coords = vector3(908.0, -176.0, 74.0), heading = 240.0},
    {coords = vector3(921.0, -163.0, 74.0), heading = 240.0}
}

-- Payment Settings
Config.BasePrice = 45 -- Base fare in dollars (starting fee)
Config.PricePerKM = 15 -- Additional cost per kilometer
Config.NPCTipChance = 55 -- Percentage chance of getting a tip from NPCs
Config.NPCTipMin = 5 -- Minimum tip amount
Config.NPCTipMax = 30 -- Maximum tip amount
Config.NightTimeSurcharge = 1.5 -- Multiplier for fares between 22:00 and 6:00
Config.WaitingRate = 0.5 -- Cost per minute when taxi is waiting/idle during a fare

-- NPC Passenger Settings
Config.EnableNPCPassengers = true -- Enable/disable NPC passengers
Config.NPCSpawnDistance = 100.0 -- Distance to spawn NPCs from player
Config.MaxActiveNPCs = 3 -- Maximum number of active NPC requests at once
Config.NPCWaitTime = 60000 -- Time in ms that an NPC will wait for pickup before cancelling
Config.NPCSpawnLocations = {
    -- Downtown
    {coords = vector3(293.0, -761.0, 29.0), destinations = {
        {coords = vector3(-255.0, -983.0, 31.0), name = 'Legion Square'},
        {coords = vector3(121.0, -880.0, 31.0), name = 'Parking Garage'},
    }},
    -- Vinewood
    {coords = vector3(355.0, 440.0, 146.0), destinations = {
        {coords = vector3(-725.0, 33.0, 43.0), name = 'Eclipse Towers'},
        {coords = vector3(-1037.0, -247.0, 37.0), name = 'Rockford Hills'},
    }},
    -- Airport
    {coords = vector3(-1034.0, -2733.0, 20.0), destinations = {
        {coords = vector3(115.0, -1365.0, 29.0), name = 'Downtown Cab Co'},
        {coords = vector3(-838.0, -1211.0, 7.0), name = 'Vespucci Beach'},
    }},
    -- Sandy Shores
    {coords = vector3(1959.0, 3742.0, 32.0), destinations = {
        {coords = vector3(1777.0, 3326.0, 41.0), name = 'Sandy Shores Airfield'},
        {coords = vector3(2384.0, 4277.0, 36.0), name = 'Grand Senora Desert'},
    }},
    -- Paleto Bay
    {coords = vector3(126.0, 6607.0, 31.0), destinations = {
        {coords = vector3(-93.0, 6410.0, 31.0), name = 'Paleto Bay Sheriff'},
        {coords = vector3(161.0, 6636.0, 31.0), name = 'Paleto Bay Bank'},
        {coords = vector3(-15.0, 6500.0, 31.0), name = 'Paleto Gas Station'},
    }},
    -- Chumash
    {coords = vector3(-3175.0, 1125.0, 20.0), destinations = {
        {coords = vector3(-3029.0, 368.0, 14.0), name = 'Chumash Pier'},
        {coords = vector3(-3244.0, 931.0, 17.0), name = 'Chumash Plaza'},
    }},
    -- Grapeseed
    {coords = vector3(1684.0, 4822.0, 42.0), destinations = {
        {coords = vector3(2539.0, 4668.0, 34.0), name = 'McKenzie Airfield'},
        {coords = vector3(1687.0, 4929.0, 42.0), name = 'Grapeseed Main Street'},
    }},
    -- La Mesa
    {coords = vector3(826.0, -1290.0, 28.0), destinations = {
        {coords = vector3(970.0, -1620.0, 30.0), name = 'Lester\'s Factory'},
        {coords = vector3(708.0, -1164.0, 23.0), name = 'La Mesa PDM'},
    }},
    -- Del Perro
    {coords = vector3(-1614.0, -1073.0, 13.0), destinations = {
        {coords = vector3(-1850.0, -1232.0, 13.0), name = 'Del Perro Pier'},
        {coords = vector3(-1361.0, -1137.0, 4.0), name = 'Del Perro Beach'},
    }},
    -- Mirror Park
    {coords = vector3(1200.0, -503.0, 65.0), destinations = {
        {coords = vector3(1158.0, -326.0, 69.0), name = 'Mirror Park Lake'},
        {coords = vector3(980.0, -709.0, 57.0), name = 'Mirror Park Shops'},
    }},
    -- Davis
    {coords = vector3(149.0, -1655.0, 29.0), destinations = {
        {coords = vector3(216.0, -1835.0, 27.0), name = 'Davis Mega Mall'},
        {coords = vector3(114.0, -1961.0, 20.0), name = 'Davis Quik-E-Mart'},
    }},
    -- Harmony
    {coords = vector3(546.0, 2662.0, 42.0), destinations = {
        {coords = vector3(1898.0, 3715.0, 32.0), name = 'Sandy Shores Main Street'},
        {coords = vector3(252.0, 2595.0, 44.0), name = 'Harmony Repairs'},
    }},
    -- Vespucci Canals
    {coords = vector3(-1161.0, -1495.0, 4.0), destinations = {
        {coords = vector3(-1045.0, -1397.0, 5.0), name = 'Vespucci Canals Bridge'},
        {coords = vector3(-1226.0, -1574.0, 4.0), name = 'Vespucci Mask Shop'},
    }},
    -- Richman
    {coords = vector3(-1322.0, 137.0, 57.0), destinations = {
        {coords = vector3(-1462.0, 180.0, 55.0), name = 'Richman Hotel'},
        {coords = vector3(-1147.0, 363.0, 71.0), name = 'Richman Mansions'},
    }},
    -- Pacific Bluffs
    {coords = vector3(-2023.0, -351.0, 48.0), destinations = {
        {coords = vector3(-2153.0, -448.0, 49.0), name = 'Pacific Bluffs Country Club'},
        {coords = vector3(-1877.0, -309.0, 49.0), name = 'Pacific Bluffs Apartments'},
    }},
    -- Tataviam Mountains
    {coords = vector3(2213.0, -2610.0, 6.0), destinations = {
        {coords = vector3(2727.0, -2530.0, 13.0), name = 'Port of South Los Santos'},
        {coords = vector3(2113.0, -2282.0, 21.0), name = 'Cypress Flats'},
    }},
    -- El Burro Heights
    {coords = vector3(1384.0, -2079.0, 52.0), destinations = {
        {coords = vector3(1643.0, -2242.0, 106.0), name = 'El Burro Heights Lookout'},
        {coords = vector3(1160.0, -1647.0, 36.0), name = 'Murrieta Oil Field'},
    }},
    -- Hawick
    {coords = vector3(307.0, -205.0, 54.0), destinations = {
        {coords = vector3(239.0, -45.0, 69.0), name = 'Hawick Apartments'},
        {coords = vector3(455.0, -146.0, 59.0), name = 'Hawick Shopping Center'},
    }},
    -- Pillbox Hill
    {coords = vector3(20.0, -730.0, 31.0), destinations = {
        {coords = vector3(236.0, -410.0, 47.0), name = 'Pillbox Hill Medical Center'},
        {coords = vector3(-149.0, -841.0, 31.0), name = 'Arcadius Business Center'},
    }},
    -- Strawberry
    {coords = vector3(232.0, -1757.0, 29.0), destinations = {
        {coords = vector3(296.0, -2018.0, 20.0), name = 'Strawberry Apartments'},
        {coords = vector3(54.0, -1873.0, 22.0), name = 'Strawberry Avenue'},
    }},
    -- Cypress Flats
    {coords = vector3(812.0, -2202.0, 29.0), destinations = {
        {coords = vector3(1073.0, -1952.0, 31.0), name = 'Cypress Flats Factory'},
        {coords = vector3(861.0, -2352.0, 30.0), name = 'Cypress Flats Warehouse'},
    }},
    -- Little Seoul
    {coords = vector3(-658.0, -857.0, 24.0), destinations = {
        {coords = vector3(-819.0, -1073.0, 11.0), name = 'Little Seoul Plaza'},
        {coords = vector3(-565.0, -708.0, 33.0), name = 'Little Seoul Apartments'},
    }},
    -- Rockford Hills
    {coords = vector3(-810.0, -108.0, 37.0), destinations = {
        {coords = vector3(-1193.0, -196.0, 39.0), name = 'Rockford Hills City Hall'},
        {coords = vector3(-590.0, -92.0, 33.0), name = 'Rockford Hills Luxury Autos'},
    }},
    -- Burton
    {coords = vector3(-365.0, -57.0, 54.0), destinations = {
        {coords = vector3(-273.0, -321.0, 30.0), name = 'Burton Apartments'},
        {coords = vector3(-429.0, 261.0, 83.0), name = 'Burton Hillside'},
    }},
    -- Morningwood
    {coords = vector3(-1384.0, -477.0, 31.0), destinations = {
        {coords = vector3(-1507.0, -383.0, 41.0), name = 'Morningwood Boulevard'},
        {coords = vector3(-1244.0, -629.0, 27.0), name = 'Morningwood Plaza'},
    }},
    -- Textile City
    {coords = vector3(429.0, -800.0, 29.0), destinations = {
        {coords = vector3(533.0, -1292.0, 29.0), name = 'Textile City Factory'},
        {coords = vector3(228.0, -992.0, 29.0), name = 'Textile City Parking'},
    }},
    -- Rancho
    {coords = vector3(361.0, -1831.0, 27.0), destinations = {
        {coords = vector3(533.0, -1760.0, 29.0), name = 'Rancho Projects'},
        {coords = vector3(192.0, -2027.0, 18.0), name = 'Rancho Industrial'},
    }},
    -- Chamberlain Hills
    {coords = vector3(-213.0, -1617.0, 34.0), destinations = {
        {coords = vector3(-145.0, -1515.0, 31.0), name = 'Chamberlain Hills Apartments'},
        {coords = vector3(-43.0, -1747.0, 29.0), name = 'Chamberlain Gas Station'},
    }},
    -- La Puerta
    {coords = vector3(-1045.0, -2222.0, 13.0), destinations = {
        {coords = vector3(-1034.0, -1447.0, 5.0), name = 'La Puerta Marina'},
        {coords = vector3(-1149.0, -2036.0, 13.0), name = 'La Puerta Freeway'},
    }},
    -- Palomino Highlands
    {coords = vector3(2589.0, 328.0, 108.0), destinations = {
        {coords = vector3(2339.0, 2569.0, 47.0), name = 'Palomino Highlands Lookout'},
        {coords = vector3(2770.0, 1568.0, 24.0), name = 'Palomino Beach'},
    }},
    -- North Chumash
    {coords = vector3(-2531.0, 2339.0, 33.0), destinations = {
        {coords = vector3(-2295.0, 1747.0, 199.0), name = 'Mount Josiah'},
        {coords = vector3(-2812.0, 1449.0, 100.0), name = 'Raton Canyon'},
    }},
    -- Tongva Hills
    {coords = vector3(-1873.0, 2088.0, 140.0), destinations = {
        {coords = vector3(-2397.0, 2430.0, 3.0), name = 'Tongva Hills Lake'},
        {coords = vector3(-1604.0, 1677.0, 88.0), name = 'Tongva Hills Vineyard'},
    }},
    -- Great Chaparral
    {coords = vector3(-386.0, 2598.0, 88.0), destinations = {
        {coords = vector3(-265.0, 2735.0, 62.0), name = 'Great Chaparral Gas Station'},
        {coords = vector3(-518.0, 2608.0, 75.0), name = 'Great Chaparral Motel'},
    }},
    -- Zancudo
    {coords = vector3(-2101.0, 3132.0, 32.0), destinations = {
        {coords = vector3(-2437.0, 3268.0, 32.0), name = 'Fort Zancudo Entrance'},
        {coords = vector3(-1889.0, 3095.0, 32.0), name = 'Zancudo River'},
    }},
    -- Alamo Sea
    {coords = vector3(712.0, 4175.0, 40.0), destinations = {
        {coords = vector3(1301.0, 4318.0, 38.0), name = 'Alamo Sea Shore'},
        {coords = vector3(739.0, 4170.0, 40.0), name = 'Alamo Sea Motel'},
    }},
    -- Chiliad Mountain
    {coords = vector3(425.0, 5614.0, 766.0), destinations = {
        {coords = vector3(501.0, 5604.0, 795.0), name = 'Mount Chiliad Peak'},
        {coords = vector3(80.0, 5400.0, 678.0), name = 'Chiliad Mountain Trail'},
    }},
    -- Braddock Pass
    {coords = vector3(2272.0, 5370.0, 168.0), destinations = {
        {coords = vector3(2121.0, 4784.0, 40.0), name = 'Braddock Farm'},
        {coords = vector3(2483.0, 5391.0, 109.0), name = 'Braddock Tunnel'},
    }},
    -- Cassidy Creek
    {coords = vector3(-708.0, 4442.0, 17.0), destinations = {
        {coords = vector3(-996.0, 4832.0, 274.0), name = 'Cassidy Creek Overlook'},
        {coords = vector3(-677.0, 4263.0, 76.0), name = 'Cassidy Creek Trail'},
    }},
    -- Procopio Beach
    {coords = vector3(712.0, 7057.0, 6.0), destinations = {
        {coords = vector3(236.0, 6854.0, 18.0), name = 'Procopio Promenade'},
        {coords = vector3(1039.0, 7137.0, 7.0), name = 'Procopio Truck Stop'},
    }},
    -- Paleto Cove
    {coords = vector3(-1609.0, 5255.0, 3.0), destinations = {
        {coords = vector3(-1464.0, 5416.0, 23.0), name = 'Paleto Cove Lookout'},
        {coords = vector3(-1785.0, 5162.0, 9.0), name = 'Paleto Cove Beach'},
    }},
    -- Catfish View
    {coords = vector3(3387.0, 5508.0, 23.0), destinations = {
        {coords = vector3(3801.0, 4462.0, 5.0), name = 'Catfish View Pier'},
        {coords = vector3(3293.0, 5189.0, 18.0), name = 'Catfish View Trail'},
    }},
    -- Humane Labs
    {coords = vector3(3619.0, 3731.0, 28.0), destinations = {
        {coords = vector3(3524.0, 3648.0, 27.0), name = 'Humane Labs Entrance'},
        {coords = vector3(3801.0, 3913.0, 31.0), name = 'Humane Labs Parking'},
    }},
    -- Tataviam Mountains
    {coords = vector3(2636.0, 1673.0, 26.0), destinations = {
        {coords = vector3(2803.0, 1588.0, 24.0), name = 'Tataviam Beach'},
        {coords = vector3(2518.0, 1641.0, 33.0), name = 'Tataviam Gas Station'},
    }},
    -- East Vinewood
    {coords = vector3(1133.0, 266.0, 81.0), destinations = {
        {coords = vector3(1301.0, 158.0, 82.0), name = 'East Vinewood Theater'},
        {coords = vector3(1039.0, 383.0, 94.0), name = 'East Vinewood Hills'},
    }},
    -- Downtown Vinewood
    {coords = vector3(638.0, 1.0, 82.0), destinations = {
        {coords = vector3(620.0, 268.0, 103.0), name = 'Vinewood Plaza'},
        {coords = vector3(766.0, -32.0, 78.0), name = 'Vinewood Boulevard'},
    }},
    -- Galileo Observatory
    {coords = vector3(-438.0, 1076.0, 327.0), destinations = {
        {coords = vector3(-594.0, 1146.0, 322.0), name = 'Observatory Entrance'},
        {coords = vector3(-370.0, 998.0, 329.0), name = 'Observatory Lookout'},
    }},
    -- Banham Canyon
    {coords = vector3(-2544.0, 1303.0, 239.0), destinations = {
        {coords = vector3(-2214.0, 1143.0, 270.0), name = 'Banham Canyon View'},
        {coords = vector3(-2714.0, 1359.0, 152.0), name = 'Banham Canyon Drive'},
    }},
    -- Lago Zancudo
    {coords = vector3(-935.0, 2998.0, 36.0), destinations = {
        {coords = vector3(-1112.0, 2700.0, 18.0), name = 'Zancudo Bridge'},
        {coords = vector3(-782.0, 3185.0, 77.0), name = 'Lago Zancudo Lookout'},
    }},
    -- San Chianski Mountain Range
    {coords = vector3(2884.0, 3599.0, 52.0), destinations = {
        {coords = vector3(2564.0, 3645.0, 101.0), name = 'San Chianski Peak'},
        {coords = vector3(3026.0, 3473.0, 15.0), name = 'San Chianski Shore'},
    }},
    -- Senora National Park
    {coords = vector3(1475.0, 3839.0, 31.0), destinations = {
        {coords = vector3(1711.0, 3681.0, 34.0), name = 'Senora Park Entrance'},
        {coords = vector3(1343.0, 3997.0, 30.0), name = 'Senora Desert Airstrip'},
    }},
    -- Grand Senora Desert
    {coords = vector3(2634.0, 3255.0, 55.0), destinations = {
        {coords = vector3(2314.0, 3144.0, 48.0), name = 'Yellow Jack Inn'},
        {coords = vector3(2883.0, 3512.0, 52.0), name = 'Grand Senora Gas Station'},
    }},
    -- RON Alternates Wind Farm
    {coords = vector3(2354.0, 1830.0, 101.0), destinations = {
        {coords = vector3(2503.0, 2019.0, 167.0), name = 'Wind Farm Lookout'},
        {coords = vector3(2162.0, 1623.0, 75.0), name = 'Wind Farm Road'},
    }}

}

-- Player Transport Settings
Config.EnablePlayerTransport = true -- Enable/disable player transport
Config.PlayerCallCooldown = 60000 -- Cooldown between player calls (ms)
Config.MaxActivePlayerCalls = 5 -- Maximum number of active player calls

-- Blip Settings
Config.TaxiDepotBlip = {
    coords = vector3(903.0, -170.0, 74.0),
    sprite = 198,
    color = 5,
    scale = 1.0,
    name = 'Taxi Depot'
}
Config.ShowCustomerBlips = true -- Show blips for customers on the map
Config.CustomerBlipSprite = 280
Config.CustomerBlipColor = 5

-- UI Settings
Config.UIEnabled = true -- Enable the custom UI
Config.UIKey = 'F7' -- Key to toggle the UI

-- Notification Settings
Config.NotificationType = 'native' -- Options: 'native', 'mythic', 'esx', 'qbcore'

-- Locale Settings (for future multi-language support)
Config.Locale = 'en'