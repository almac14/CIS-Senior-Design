function Get-DriveSpace {
    <#
    .DESCRIPTION
    Gets the list of drives on the server and on other remote servers
    .PARAMETER ComputerNames
    List of computers to get drive info about
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string[]]$ComputerNames
    )

    Begin { }

    Process {
        $drives = [System.IO.DriveInfo]::GetDrives()

        $output = @()

        foreach ($drive in $drives) {
            $total = $drive.TotalSize / 1GB
            if ($total -eq 0) { #Skip drives with zero space
                continue
            }
            $driveTable = [ordered]@{
                ComputerName = $env:COMPUTERNAME
                Drive = $drive.Name
                UsedGB = [math]::Round(($drive.TotalSize - $drive.AvailableFreeSpace) / 1GB, 2)
                FreeGB = [math]::Round($drive.AvailableFreeSpace / 1GB, 2)
                TotalGB = [math]::Round($total)
                PercentFree = [math]::Round(($drive.AvailableFreeSpace/$drive.TotalSize)*100, 2)
            }
            $output += (New-Object psobject –Prop $driveTable)
        }

        foreach ($computerName in $ComputerNames) {
            
            $output += Invoke-Command -ComputerName $computerName -ArgumentList $computerName -ScriptBlock {
                param([string]$computerName)

                $drives = [System.IO.DriveInfo]::GetDrives()
                
                $remoteOutput = @()

                foreach ($drive in $drives) {
                    $total = $drive.TotalSize / 1GB
                    if ($total -eq 0) { #Skip drives with zero space
                        continue
                    }
                    $driveTable = [ordered]@{
                        ComputerName = $computerName
                        Drive = $drive.Name
                        UsedGB = [math]::Round(($drive.TotalSize - $drive.AvailableFreeSpace) / 1GB, 2)
                        FreeGB = [math]::Round($drive.AvailableFreeSpace / 1GB, 2)
                        TotalGB = [math]::Round($total, 2)
                        PercentFree = [math]::Round(($drive.AvailableFreeSpace/$drive.TotalSize)*100, 2)
                    }
                    $remoteOutput += (New-Object psobject –Prop $driveTable)
                }

                return $remoteOutput
            }
        }

        return $output | select ComputerName, Drive, UsedGB, FreeGB, TotalGB, PercentFree
    }

    End { }
}

#Get-DriveSpace -ComputerNames @("WIN-TDB4N5JL0G1", "WIN-29RPC41COL1") | Format-Table