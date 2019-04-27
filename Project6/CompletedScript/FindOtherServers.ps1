[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$OutFile
)

([adsi]"WinNT://$((Get-WmiObject Win32_ComputerSystem).Domain)").Children | #Get all objects on the domain
    
    Where-Object {$_.schemaclassname -eq "computer"} | #Filter out objects that aren't computers
    
    Select-Object -Property @{Name="Name"; Expression={ $_.Path.Split("/")[3] } } | #Convert paths to computer names
    
    Out-String -Stream | #Convert to string array
    
    ForEach-Object { $_.trim() } | #Get rid of extra whitespace
    
    Where-Object { $_.Length -ne 0 } | #Filter out empty lines
    
    Select-Object -Skip 2 | #Skip first 2 lines to remove table header 
    
    Out-File $OutFile #Output array to file