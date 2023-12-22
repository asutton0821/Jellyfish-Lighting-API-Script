# Jellyfish Lighting API Script

This small PowerShell script uses WebSocket calls to directly interface with the Jellyfish Lighting API to get zone and pattern info, set patterns on all or one zone, and turn off a zone. 

## Usage

Below are some examples of the different methods you can use. 

```powershell
Set-PatternOnAllZones -patternName "Warm Cool/White" #Sets a pattern on all zones based on the folder/file name of the pattern
Set-PatternOnZone -zoneName "Back" -patternName "Warm Cool/White" #Sets a pattern on one zone based on zone name and folder/file name of pattern 
Get-Zones #Returns a human-readable list of zones
Get-Patterns #Returns a human-readable list of patterns in the "folder/file" format
Set-StateOnZone -zoneName "Back" -state 0 #Sets the state on a zone. Due to the current limitations of the JFL API, a pattern has to be set to turn off the zone. Since there is no way to currently get running pattern, Warm Cool/White is set, then the zone is turned off. Once turned back on, another pattern will need to  be set using the "Set-PatternOnZone" method
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Roadmap

- Once API limitation issues are resolved, add ability to get state/pattern info from zone
- Create HomeAssistant and HomeBridge Plugin that allows control from Smart Home devices (currently only supported on Amazon Echo Devices) 


## API Source Documentation 

https://jellyfishlighting.com/api/

https://github.com/parkerjfl/JellyfishLightingAPIExplorer/blob/main/Jellyfish%20Lighting%20API%20Documentation%20(1).pdf
