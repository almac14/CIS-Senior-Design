function Get-Services {
   <#
    .DESCRIPTION
    Gets a list of the names, states, and start modes of all services on the local server and VMs
    .PARAMETER ComputerNames
    A list of computer names to get the services from
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory=$false)]
        [string[]]$ComputerNames,
        [parameter(Mandatory=$false)]
        [string[]]$Filter
    )

    Begin { }

    Process {

        $name = $env:COMPUTERNAME
        <#| Where-Object {$_.state -eq 'Stopped' -and $_.StartMode -eq 'Auto'}#> 
        Get-WmiObject -Class Win32_Service | Select-Object @{ l="ComputerName";e={$name} },Name,State,StartMode,DisplayName,@{ l="Ignore";e={$Filter.Contains($_.Name)} } | Write-Output


        ForEach($computerName in $ComputerNames){
            Invoke-Command -ComputerName $computerName -ArgumentList $computerName,$Filter -ScriptBlock {
                Param(
                    [string]$computerName,
                    [string[]]$Filter
                )
                return Get-WmiObject -class Win32_Service | Select-Object @{ l="ComputerName";e={$computerName} },Name,State,StartMode,DisplayName,@{ l="Ignore";e={$Filter.Contains($_.Name)} }
            }
        }

        
    }

    End { }
}

#Get-Services -ComputerNames @("WIN-TDB4N5JL0G1", "WIN-29RPC41COL1State")