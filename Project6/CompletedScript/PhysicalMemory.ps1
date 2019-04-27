Function Get-Memory {
[cmdletbinding()]
Param(
    [Parameter(Mandatory=$False)]
    [string[]]$ComputerNames
)

BEGIN{}

PROCESS{
    
    $output = @()

    #Gets the system information
    $os = Get-Ciminstance Win32_OperatingSystem -ComputerName $env:COMPUTERNAME
    $pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)
    
    #Add system info to a custom object
    $list = [PSCustomObject]@{
        ComputerName = $os.PSComputerName
        FreeGB = [math]::Round($os.FreePhysicalMemory/1mb,2)
        TotalGB = [int]($os.TotalVisibleMemorySize/1mb)
        PctFree = $pctFree
    }

    #Add the object to the output array
    $output += $list

    #Loop through the ComputerNames
    ForEach($computerName in $ComputerNames) {
        #Runs the command on the server to get the system information
        $serverReturn = Invoke-Command -ComputerName $computerName -ScriptBlock {
            $os = Get-Ciminstance Win32_OperatingSystem -ComputerName $env:COMPUTERNAME
            return $os
        }
        $pctFree = [math]::Round(($serverReturn.FreePhysicalMemory/$serverReturn.TotalVisibleMemorySize)*100,2)

        #Stores the relevant server info into a custom object
        $serverInfo = [PSCustomObject]@{
            ComputerName = $serverReturn.PSComputerName
            FreeGB = [math]::Round($serverReturn.FreePhysicalMemory/1mb,2)
            TotalGB = [int]($serverReturn.TotalVisibleMemorySize/1mb)
            PctFree = $pctFree
        }

        #Adds the server info object into the results array
        $output += $serverInfo
    }

    #return the custom array
    return $output

}

END{}

}
