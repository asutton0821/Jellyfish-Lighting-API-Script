### Jellyfish Lighting API Script
##v1.0 
##Sw1ftC0d3r
##12/21/23
<# 

This script interfaces with Jellyfish Lighting Controller. It uses the built-in API to establish a websocket connection and run the various functions chosen.

The following functions are: 

Run-Command: The main function that runs the command provided by other functions
Set-PatternOnAllZones -patternName "Folder/File": Sets a pattern on all zones AND turns on all zones
Set-PatternOnZone -zoneName "Back" -patternName "Warm Cool/White": Sets a pattern on one specified zone
Get-Zones: Returns a list of all zones in a human-readable format
Get-Patterns: Returns a list of all patterns in a human readable format
Set-StateOnZone -zoneName "Back" -state 0: Sets the state on a zone (0 = off, 1 = on). Due to current limitations in the API, there is no way to currently get a running pattern on a zone. So the zone is set to Warm Cool/White. The pattern will have to be set back once turned on. 


#> 

###Authentication Variables, Change the IP to your controller IP address###
$IP = "127.0.0.1" 
$port = "9000" #default is 9000
############################################################################


$URL = "ws://$($IP):$($port)/ws"


Function Run-Command{
	
	Param(
		[parameter(Mandatory=$true)]
		[string]$jfURL,
		[parameter(Mandatory=$true)]
		[string]$jfCmd
	)
	
	Write-Host "Output, jfURL = "+$jfURL+ ", jfCmd = "+$jfUrl

Try{  
        $URL = $jfURL
        $WS = New-Object System.Net.WebSockets.ClientWebSocket                                                
        $CT = New-Object System.Threading.CancellationToken
        $WS.Options.UseDefaultCredentials = $true

        #Get connected
        $Conn = $WS.ConnectAsync($URL, $CT)
        While (!$Conn.IsCompleted) { 
            Start-Sleep -Milliseconds 100 
        }
        Write-Host "Connected to $($URL)"
        $Size = 999999999
        $Array = [byte[]] @(,0) * $Size

		

        #Send Starting Request
        $Command = [System.Text.Encoding]::UTF8.GetBytes($jfCmd)
        $Send = New-Object System.ArraySegment[byte] -ArgumentList @(,$Command)            
        $Conn = $WS.SendAsync($Send, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $CT)

        While (!$Conn.IsCompleted) { 
            #Write-Host "Sleeping for 100 ms"
            Start-Sleep -Milliseconds 100 
        }

        Write-Host "Finished Sending Request"

        #Start reading the received items
        While ($WS.State -eq 'Open') {                        

            $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(,$Array)
            $Conn = $WS.ReceiveAsync($Recv, $CT)
            While (!$Conn.IsCompleted) { 
                    #Write-Host "Sleeping for 100 ms"
                    Start-Sleep -Milliseconds 100 
            }

            #Write-Host "Finished Receiving Request"

            $string = [System.Text.Encoding]::utf8.GetString($Recv.array) | ConvertFrom-Json
			#Write-Host $string
			return $string
			$WS.Dispose()
			
    } 
}Finally {
		
		If ($WS) { 
        Write-Host "Closing websocket"
        $WS.Dispose()
    }
}

	
}


Function Get-Zones { 
	$jfCmd = '{"cmd": "toCtlrGet", "get": [["zones"]]}'
	$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	#Write-Host $commandOutput.zones 
	$zones = $commandOutput.zones
	$array = @()

	foreach($zone in $zones){
		Write-Host $zone 
		$newZoneString = [String]::Join($separator,$zone)
		$newZone = $newZoneString.replace("@{","")
		$newZone = $newZone.replace("=;",",")
		$newZone = $newZone.replace("=","")
		$newZone = $newZone.replace("}","")
		$newZone = $newZone.replace(", ",",")
		$array = $newZone.Split(",")
	}
	
	return $array
} 


Function Get-Patterns { 
	$jfCmd = '{"cmd": "toCtlrGet", "get": [["patternFileList"]]}'
	$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	Write-Host $commandOutput
	$patterns = $commandOutput.patternFileList
	$patternName = $patterns | select name
	$patternFolder = $patterns | select folders
	
	
	

	foreach($pattern in $patterns){
		
		Write-Host "$($pattern.folders)/$($pattern.name)"
	} 
} 


Function Set-PatternOnZone {
Param(

[parameter(Mandatory=$true)]
		[string]$zoneName,
		[parameter(Mandatory=$true)]
		[string]$patternName

)
	$jfCmd = '{"cmd":"toCtlrSet","runPattern":{"file":"'+$patternName+'","data":"","id":"","state":1,"zoneName":["'+$zoneName+'"]}}'
	Write-Host $jfCmd
	$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	
} 


Function Set-PatternOnAllZones {
Param(

		[parameter(Mandatory=$true)]
		[string]$patternName

)

	$zones = Get-Zones
	foreach($zone in $zones){
		$jfCmd = '{"cmd":"toCtlrSet","runPattern":{"file":"'+$patternName+'","data":"","id":"","state":1,"zoneName":["'+$zone+'"]}}'
		$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	}
	#$jfCmd = '{"cmd":"toCtlrSet","runPattern":{"file":"'+$patternName+'","data":"","id":"","state":1,"zoneName":["'+$zoneName+'"]}}'
	#Write-Host $jfCmd
	#$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	
} 

Function Set-StateOnZone {
Param(

[parameter(Mandatory=$true)]
		[string]$zoneName,
		[parameter(Mandatory=$true)]
		[int]$state

)
	$jfCmd = '{"cmd":"toCtlrSet","runPattern":{"file":"Warm Cool/White","data":"","id":"","state":'+$state+',"zoneName":["'+$zoneName+'"]}}'
	Write-Host $jfCmd
	$commandOutput = Run-Command -jfURL $URL -jfCmd $jfCmd
	
} 



#Set-PatternOnAllZones -patternName "Warm Cool/White"
#Set-PatternOnZone -zoneName "Back" -patternName "Warm Cool/White"
#Get-Zones
#Get-Patterns
#Set-StateOnZone -zoneName "Back" -state 0


