#Author: Justin Slater

[CmdletBinding()]
param (
#The cut off for keeping reports. All reports older than $AgeInDays days are deleted.
[int]$AgeInDays = 7,
#Specific reports to delete. These may be older than the number of days to keep reports.
[string[]]$Reports = @(),
#Don't ask for confirmation to delete files.
[switch]$Y
)

if ($AgeInDays -lt 0) {
    Write-Error "Invalid age: $AgeInDays"
    return
}

#Check if caller set $Reports and didn't set $AgeInDays
if (!$PSBoundParameters.ContainsKey("AgeInDays") -and $PSBoundParameters.ContainsKey("Reports")) {
    #This means that the caller only wants to delete specific reports
    $AgeInDays = -1
}

. "$PSScriptRoot\Config.ps1"

$reportList = Get-ChildItem "$($config.ReportsFolder)\*.js"

$numFound = 0
$allReportFiles = New-Object System.Collections.Generic.HashSet[string]
$filesToDelete = New-Object System.Collections.Generic.HashSet[string]

foreach ($r in $reportList) {
    $name = $r.Name.Substring(0, $r.Name.Length - 3)
    [void]$allReportFiles.add($name)
    $date = [DateTime]::ParseExact($name, "yyyyMMddTHHmmss", $null)
    if ($AgeInDays -ge 0 -and ([DateTime]::Now - $date).TotalDays -gt $AgeInDays -or $Reports.Contains($name)) {
        if ($Reports.Contains($name)) {
            $numFound++            
        }
        [void]$filesToDelete.Add($name)
        Write-Host "$name ($date): delete"
    } else {
        Write-Host "$name ($date): keep"
    }
}

if ($numFound -ne $Reports.Length) {
    Write-Host "Warning: The following reports were not found:"
}

foreach ($r in $Reports) {
    if (!$filesToDelete.Contains($r)) {
        Write-Host $r
    }
}

if ($filesToDelete.Count -eq 0) {
    Write-Host "No files to delete"
    return
}

if ($Y -or (Read-Host -Prompt "Would you like to delete these files (Y/N)") -eq "y") {
    foreach ($r in $filesToDelete) {
        Remove-Item "$($config.ReportsFolder)\$r.js"
    }

    $reportsFile = Get-Content $config.ReportsFile
    $reportsFile | Where-Object { 
        if ($_.StartsWith("var") -or $_.StartsWith("];")) {
            return $true
        }

        $r = $_.Substring(1, $_.Length - 3)  
        !$filesToDelete.Contains($r) -and $allReportFiles.Contains($r) #Remove deleted files and files that no longer exist
    } | 
    Set-Content $config.ReportsFile
} else {
    Write-Host "No action taken"
}