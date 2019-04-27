#Authors: Sandino Dos Santos
function ScheduleTask{

    <#
    .DESCRIPTION
    Adds the task to the task scheduler to run at specified time
    
    #>
    [CmdletBinding()]
    param (
    )

    Begin {
     
    }
 Process 
    {
        
        

        #creates: the job title that will appear in the task scheduler
        $jobname = "Server Health Check"
        write-host "Task name: " $jobname

        #location where the script should be retrieve run to be executed
        $script =  "-ExecutionPolicy Bypass -file C:\Project6\CompletedScript\Main.ps1"
        
        #creates a new task and designat the program to run the script 
        $action = New-ScheduledTaskAction –Execute "powershell.exe" -Argument  "$script"

       
        #sets the time when the scheduled program should be executed
        $trigger = New-ScheduledTaskTrigger -Daily -At 12:30pm
        write-host "Time task will run: " $time

        #adds a quick description to the task scheduler description box
        $Description="Enable run time of task at specified time"

        #add a message to the message dialog box
        $msg = "Enter the username and password that will run the task"; 

        #creates the conditions under which the script will run
        #$settings = #New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd
        $settings = Register-ScheduledTask -TaskName $jobname -Action $action -Trigger $trigger -RunLevel Highest -Description $Description

     }
    
    End {}
}