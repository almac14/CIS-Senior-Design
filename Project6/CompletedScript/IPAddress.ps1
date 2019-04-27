#Author: Alec Bonnell
function Get-IPs {
    <#
    .DESCRIPTION
    Displays the computer name and the network IP address for the host server and other servers
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False)]
        [string[]]$ComputerNames
    )

    Begin {}

    Process {
        #Make sure that Get-NetIPAddress is loaded
        #Import-Module NetTCPIP

        #Create the output array
        $output = @()

        #Create the ipList to be added to the output array
        $ipList = [PSCustomObject][ordered]@{
            ComputerName = $env:COMPUTERNAME
            IPAddress = (Get-NetIPAddress | ? {$_.ValidLifetime -ne [TimeSpan]::MaxValue}).IPAddress
        }

        #Add the list to the output array
        $output += $ipList
        
        #Run script for each other computer
        foreach($computerName in $ComputerNames){

            #Runs the command on the server to get the ip information
            $serverReturn = Invoke-Command -ComputerName $computerName -ScriptBlock {

                #Get the information
                $ipList = [PSCustomObject][ordered]@{
                    ComputerName = $env:COMPUTERNAME
                    IPAddress = (Get-NetIPAddress | ? {$_.ValidLifetime -ne [TimeSpan]::MaxValue}).IPAddress
                }

                #return the information to the host server
                return $ipList
            }

            #Adds the server info object into the results array
            $output += $serverReturn

        }

        #Return the output result
        #Write-Output -NoEnumerate $output
        return $output | select ComputerName, IPAddress
    }

    End {}
}