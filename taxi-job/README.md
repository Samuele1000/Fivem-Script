# FiveM Taxi Job Script

A comprehensive and feature-rich taxi job script for FiveM servers, supporting both ESX and QBCore frameworks. This script provides a complete taxi driver experience with NPC passengers, player transport, fare calculation, and customizable options.

![Taxi Job](html/img/taxi-logo.png)

## Features

- **Framework Support**: Compatible with both ESX and QBCore frameworks
- **Taxi Meter System**: Accurate fare calculation based on distance traveled
- **NPC Passengers**: Random NPC passengers with customizable spawn locations and destinations
- **Player Transport**: Allow players to call taxis and be transported by taxi drivers
- **Multiple Taxi Vehicles**: Choose from different taxi vehicle models
- **Dynamic Pricing**: Base fare, per-kilometer rate, night time surcharge, and waiting rate
- **Tipping System**: NPCs can leave tips with configurable chance and amount
- **Duty System**: Toggle on/off duty status
- **Interactive UI**: Clean and functional taxi meter interface
- **Optimized Performance**: Sleep-based resource usage for minimal server impact

## Installation

1. Download the resource
2. Place the `taxi-job` folder in your server's resources directory
3. Add `ensure taxi-job` to your server.cfg
4. Configure the `config.lua` file to match your server's needs
5. Restart your server

## Configuration

The script is highly configurable through the `config.lua` file. Here are some key configuration options:

### General Settings

```lua
Config.Debug = false -- Enable debug mode for additional console outputs
Config.UseESX = true -- Set to true if using ESX framework
Config.UseQBCore = false -- Set to true if using QBCore framework
```

### Job Settings

```lua
Config.RequireJob = true -- Set to true if player needs taxi job to use the script
Config.JobName = 'taxi' -- Name of the job in your framework
```

### Vehicle Settings

```lua
Config.TaxiVehicles = {
    {model = 'taxi', label = 'Standard Taxi'},
    {model = 'taxiold', label = 'Classic Taxi'},
    {model = 'cabby', label = 'Cabby'}
}
```

### Payment Settings

```lua
Config.BasePrice = 45 -- Base fare in dollars (starting fee)
Config.PricePerKM = 15 -- Additional cost per kilometer
Config.NPCTipChance = 55 -- Percentage chance of getting a tip from NPCs
Config.NPCTipMin = 5 -- Minimum tip amount
Config.NPCTipMax = 30 -- Maximum tip amount
Config.NightTimeSurcharge = 1.5 -- Multiplier for fares between 22:00 and 6:00
Config.WaitingRate = 0.5 -- Cost per minute when taxi is waiting/idle during a fare
```

## Usage

### For Taxi Drivers

1. Go to the taxi depot (marked on the map)
2. Use the taxi menu to go on duty
3. Select a taxi vehicle
4. Pick up NPC passengers or wait for player calls
5. Use the taxi meter to track fares
6. Collect payment when the destination is reached

### For Players

1. Use the `/calltaxi` command to request a taxi
2. Wait for a taxi driver to accept your request
3. Tell the driver your destination
4. Pay the fare when you reach your destination

## Commands

- `/taxiduty` - Toggle on/off duty status
- `/taxiui` - Toggle the taxi meter UI
- `/calltaxi` - Call a taxi (for passengers)

## Dependencies

- ESX or QBCore framework (configurable)

## Performance

This script is optimized for performance with sleep-based loops that reduce resource usage when not actively needed. The NPC spawning system is designed to minimize entity creation and only spawn NPCs when appropriate conditions are met.

## Credits

Created by Simaatje69

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, bug reports, or feature requests, please open an issue on the GitHub repository.