[CmdletBinding()]
param (
[switch]$SkipOpenReports,
[string]$Comment="None"
)

. "$PSScriptRoot\Config.ps1"
. "$PSScriptRoot\DataSheet.ps1"

$computerNames = Get-Content $config.ComputerNamesFile

$newFile = Get-DataSheet -ErrorAction Inquire $computerNames -Comment $Comment

$reports = Get-Content $config.ReportsFile
$reports[$reports.Length - 1] = "`"$newFile`",`n];"
$reports | Set-Content $config.ReportsFile

& "$PSScriptRoot\DeleteOldReports.ps1" -y

if (!$SkipOpenReports) {
	Invoke-Item "$PSScriptRoot\Data Sheet\index.html"
}