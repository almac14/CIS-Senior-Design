#Authors: Sandino Dos Santos, Alec Bonnell
function Get-Time{

    <#
    .DESCRIPTION
    Displays the computer name and time and timezone for the host server and compare the other servers to the host server
    Display format ComputerName   DayofWeek, Month day, Year Hour:minute:second 
    .PARAMETER ComputerNames
    An array of strings for the computer names
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False)]
        [string[]]$ComputerNames
    )

    Begin {
     
    }

    Process 
    {
        #This will store the dates in an array
        $dates = @()

        #Get the date/time info for the host server
        $hostDate = Get-Date

        #This is the format of the table
        $dateList = [PSCustomObject][ordered]@{
            ComputerName = $env:COMPUTERNAME
            DateString = $hostDate.DateTime
            DayOfWeek = [string]$hostDate.DayOfWeek
            Day = $hostDate.Day
            Month = $hostDate.Month
            Year = $hostDate.Year
            Hour = $hostDate.Hour
            Minute = $hostDate.Minute
            Second = $hostDate.Second
            UnixTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalSeconds
            StandardTimeZone = ([System.TimeZone]::CurrentTimeZone).StandardName
            DaylightTimeZone = ([System.TimeZone]::CurrentTimeZone).DaylightName
        }

        #Add the list to the dates array
        $dates += $dateList

        #Loop through the ComputerNames
        ForEach($computerName in $ComputerNames) {

            #Runs the command on the server to get the time information
            $serverReturn = Invoke-Command -ComputerName $computerName -ScriptBlock {

                #Get the date/time info from the server
                $serverDate = Get-Date

                #Get the information
                $dateList = [PSCustomObject][ordered]@{
                    ComputerName = $env:COMPUTERNAME
                    DateString = $serverDate.DateTime
                    DayOfWeek = [string]$serverDate.DayOfWeek
                    Day = $serverDate.Day
                    Month = $serverDate.Month
                    Year = $serverDate.Year
                    Hour = $serverDate.Hour
                    Minute = $serverDate.Minute
                    Second = $serverDate.Second
                    UnixTime = [int64](([datetime]::UtcNow)-(get-date "1/1/1970")).TotalSeconds
                    StandardTimeZone = ([System.TimeZone]::CurrentTimeZone).StandardName
                    DaylightTimeZone = ([System.TimeZone]::CurrentTimeZone).DaylightName
                }

                #return the information to the host server
                return $dateList
            }

            #Adds the server info object into the results array
            $dates += $serverReturn

        }

        #return all of the info
        return $dates | select ComputerName, DateString, DayOfWeek, Day, Month, Year, Hour, Minute, Second, UnixTime, StandardTimeZone, DaylightTimeZone
      }
    
    End {}
}