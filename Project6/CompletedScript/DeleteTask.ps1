function Delete-ScheduledTask {
    <#
    .DESCRIPTION
    Deletes a task from the task scheduler
    .PARAMETER TaskName
    The name of the task you want to delete
    #>
    [CmdletBinding()]
    param (
        #VM computer names parameter
        [Parameter(Mandatory=$True)]
        [string]$TaskName
    )

    BEGIN {}

    PROCESS {
        Unregister-ScheduledTask -TaskName $TaskName
    }

    END {}
}