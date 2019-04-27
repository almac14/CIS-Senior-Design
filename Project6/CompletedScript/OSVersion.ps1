#Author: Alec Bonnell
function Get-OS {
    <#
    .DESCRIPTION
    Gets the System information and displays the computer name, the name of the OS, the OS architecture, the OS version, and the OS build number for the host and other servers
    .PARAMETER ComputerNames
    An array of strings for the computer names
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False)]
        [string[]]$ComputerNames
    )

    Begin {}

    Process {
        #The results array that will store the OS information as PS objects
        $results = @()
        
        #Gets the host info
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem

        #Stores the relevant host info into a custom object
        $osList = [PSCustomObject]@{
            ComputerName = $osInfo.PSComputerName
            OSName = $osInfo.Caption
            OSArchitecture = $osInfo.OSArchitecture
            OSVersion = $osInfo.Version
            OSBuildNumber = $osInfo.BuildNumber
        }

        #Adds the host info object into the results array
        $results += $osList
        
        #Loop through the ComputerNames
        ForEach($computerName in $ComputerNames) {
            #Runs the command on the server to get the system information
            $serverReturn = Invoke-Command -ComputerName $computerName -ScriptBlock {
                $serverWmi = Get-WmiObject -Class Win32_OperatingSystem
                return $serverWmi
            }

            #Stores the relevant server info into a custom object
            $serverData = [PSCustomObject]@{
                ComputerName = $serverReturn.PSComputerName
                OSName = $serverReturn.Caption
                OSArchitecture = $serverReturn.OSArchitecture
                OSVersion = $serverReturn.Version
                OSBuildNumber = $serverReturn.BuildNumber
            }

            #Adds the server info object into the results array
            $results += $serverData
        }

        #Return the results array of objects
        return $results

    }

    End {}
}