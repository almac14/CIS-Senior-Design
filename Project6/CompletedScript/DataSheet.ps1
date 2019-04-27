#author: Sandino, Alec, Corey, Alex, Justin
function Get-DataSheet{

    
    [CmdletBinding()]
    #takes in a list of computer where the script should run
    param (
        [Parameter(Mandatory=$False)]
        [string[]]$ComputerNames,
		[string]$Comment="None"
    )
	
    Begin{}

	Process{
        $ErrorActionPreference = "Inquire"

        #Get all the paths for each powershell 
        $AppScriptPath       = "$PSScriptRoot\VersionData.ps1"
        $IPScriptPath        = "$PSScriptRoot\IPAddress.ps1"
        $DriveScriptPath     = "$PSScriptRoot\DriveSpace.ps1"
        $OSScriptPath        = "$PSScriptRoot\OSVersion.ps1"
        $MemoryScriptPath    = "$PSScriptRoot\PhysicalMemory.ps1"
        $ServicesScriptPath  = "$PSScriptRoot\Services.ps1"
        $TimeScriptPath      = "$PSScriptRoot\DateTime.ps1"
		
		. "$PSScriptRoot\Config.ps1"
		
        $serviceFilter = Get-Content $config.ServicePath

        #Those powershell script run in the background as a job
        $frag1 = Start-Job -ArgumentList $AppScriptPath, $config.BaseLinePath, $ComputerNames -ScriptBlock{
             #takes in Application version baseline file as a mandatory parameter
             param (
                [Parameter(Mandatory = $true)][String]$AppScriptPath,
                [Parameter(Mandatory = $false)][String]$BaseLinePath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )
            .$AppScriptPath
			
            return Get-VersionData -ComputerNames $ComputerNames -BaseLinePath $BaseLinePath | convertto-json -Compress
        }
	    
        #Collect all the IP's Addresses of all computer the tool will be executed in
        $frag2 = Start-Job -ArgumentList $IPScriptPath,$ComputerNames -ScriptBlock{
            #Takes in the IPScriptPath as a mandatory parameter where the script file is located
            param(
                [Parameter(Mandatory = $true)][String]$IPScriptPath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$IPScriptPath

            #Run the script
            return Get-IPs -ComputerNames $ComputerNames | convertto-json -Compress
        }

        #This part will collected information about the drivespaces and all of this information is collect as a background service
        $frag3 = Start-Job -ArgumentList $DriveScriptPath,$ComputerNames -ScriptBlock{
             #Takes in the $DriveScriptPath as a mandatory parameter where the script file is located
            param(
                [Parameter(Mandatory = $true)][String]$DriveScriptPath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$DriveScriptPath

            #Run the script
            return Get-DriveSpace -ComputerNames $ComputerNames | convertto-json -Compress
        }

        #This part will collected information about the OS version and all of this information is collect as a background service
        $frag4 = Start-Job -ArgumentList $OSScriptPath,$ComputerNames -ScriptBlock{
            #Takes in the $OSScriptPath as a mandatory parameter where the script file is located
            param(
                [Parameter(Mandatory = $true)][String]$OSScriptPath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$OSScriptPath

            #Run the script
            return Get-OS -ComputerNames $ComputerNames | convertto-json -Compress
        }

        #Collect information about memory spaces
        $frag5 = Start-Job -ArgumentList $MemoryScriptPath,$ComputerNames -ScriptBlock{
            #Takes in the $MemoryScriptPath as a mandatory parameter where the script file is located
            param(
                [Parameter(Mandatory = $true)][String]$MemoryScriptPath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$MemoryScriptPath

            #Run the script
            return Get-Memory -ComputerNames $ComputerNames | convertto-json -Compress
        }

         #Collect information about services currently active in computer 
        $frag6 = Start-Job -ArgumentList $ServicesScriptPath,$serviceFilter,$ComputerNames -ScriptBlock{
            #Get the arguments from ArgumentList
            param(
                [Parameter(Mandatory = $true)][String]$ServicesScriptPath,
                [Parameter(Mandatory = $false)][String[]]$serviceFilter,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$ServicesScriptPath

            #Run the script
            return Get-Services -ComputerNames $ComputerNames -Filter $serviceFilter | select * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName| convertto-json -Compress
        }

        #Collect information pertaining to the time and timezone the each server is currently in
        $frag7 = Start-Job -ArgumentList $TimeScriptPath,$ComputerNames -ScriptBlock{
            #Get the arguments from ArgumentList
            param(
                [Parameter(Mandatory = $true)][String]$TimeScriptPath,
                [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

            #Load in the script from the specified path
            .$TimeScriptPath

            #Run the script
            return Get-Time -ComputerNames $ComputerNames | convertto-json -Compress
        }
		
        <# This is where the result of all of the jobs will be collect and set to the variable result# #>
        $result1 = Receive-Job -Wait -Job $frag1
        $result2 = Receive-Job -Wait -Job $frag2
        $result3 = Receive-Job -Wait -Job $frag3
        $result4 = Receive-Job -Wait -Job $frag4
        $result5 = Receive-Job -Wait -Job $frag5
        $result6 = Receive-Job -Wait -Job $frag6
        $result7 = Receive-Job -Wait -Job $frag7
		
        
        <# if any of the script fail an error will be throw in the report and this is where the errors are throw #>
        if($result1 -eq $null){
            $result1 = '[{"Error":"Error"}]'
        }
        if($result2 -eq $null){
            $result2 = '[{"Error":"Error"}]'
        }
        if($result3 -eq $null){
            $result3 = '[{"Error":"Error"}]'
        }
        if($result4 -eq $null){
            $result4 = '[{"Error":"Error"}]'
        }
        if($result5 -eq $null){
            $result5 = '[{"Error":"Error"}]'
        }
        if($result6 -eq $null){
            $result6 = '[{"Error":"Error"}]'
        }
        if($result7 -eq $null){
            $result7 = '[{"Error":"Error"}]'
        }
		
		if($result1[0] -ne "[") {
                $result1 = "[" + $result1 + "]"
        }
		if($result2[0] -ne "[") {
                $result2 = "[" + $result2 + "]"
        }
		if($result3[0] -ne "[") {
                $result3 = "[" + $result3 + "]"
        }
		if($result4[0] -ne "[") {
                $result4 = "[" + $result4 + "]"
        }
		if($result5[0] -ne "[") {
                $result5 = "[" + $result5 + "]"
        }
		if($result6[0] -ne "[") {
                $result6 = "[" + $result6 + "]"
        }
		if($result7[0] -ne "[") {
                $result7 = "[" + $result7 + "]"
        }

        #Include baseline file information
        if($baselineJSON = Import-Csv -Path $config.BaseLinePath -Header "Name", "Version"){
            $baselineJSON = $baselineJSON | ConvertTo-Json -Compress
        }
        else{
            $baselineJSON = '[{"Name":"Name","Version":"Version"}]'
        }
        if($serviceJSON = Import-Csv -Path $config.ServicePath -Header "Service"){
            $serviceJSON = $serviceJSON | ConvertTo-Json -Compress
        }
        else{
            $serviceJSON = '[{"Service":""}]'
        }

        #capture the current time and date of the server and save it to the variable time
        $time = Get-Date

        #Using time as a reference the file name is parsed into different sections that will ultimately make up the filename:year,month,day,hour,minute.seconds
        $fileName = "$($time.Year)$($time.Month.ToString("D2"))$($time.Day.ToString("D2"))T$($time.Hour.ToString("D2"))$($time.Minute.ToString("D2"))$($time.Second.ToString("D2"))"

        #using time variable all of the information will be stored in a json
        $date = @{ "DateTime"=$time.DateTime } | convertto-json -Compress
        
        #All of the information collect up to this point is then stored with a comprenhensible name in a json format 
        $allJSON = "var reportTime = $date;`nvar versionData = $result1;`nvar ipData = $result2;`nvar driveData = $result3;`nvar osData = $result4;`nvar memoryData = $result5;`nvar servicesData = $result6;`nvar timeData = $result7;`nvar comment = `"$Comment`";`nvar appBaseline = $baselineJSON;`nvar serviceBaseline = $serviceJSON;"
        
        #Once all the data is collected is stored in a f
        $allJSON | Out-File "$($config.ReportsFolder)\$fileName.js"
			
			
        return $fileName 
    }
    End{}
}