#==============================================================================#
#VersionData.ps1                                                               #
#Author: Corey S. Pollock                                                      #
#Created: 11-12-2018                                                           #
#Updated: 04-23-2019                                                           #
#Shows installed application names and their version numbers.                  #
#*Able to import a baseline file to compare the version numbers against.       #
#==============================================================================#

function Get-VersionData{

    [CmdletBinding()]
    param ([Parameter(Mandatory = $false)][String]$BaseLinePath,
           [Parameter(Mandatory = $false)][Boolean]$ShowIgnored,
           [Parameter(Mandatory = $false)][String[]]$ComputerNames
            )

    Begin{}

Process{
        $apps = @()
        $bin = @()
        [boolean]$ign = $false
                
        #We need to look for applications both using 'Wow6432Node' and not using 'Wow6432Node' to get 64 bit AND 32 bit information
        Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object{
              
              $ign = $false
              $output = [PSCustomObject]@{
				ComputerName = $env:COMPUTERNAME
                Name = $($_.DisplayName)
                Version = $($_.DisplayVersion)
                Status = "-"
              }
              #Checking to see if the current application is bloat
              if($output.Name -like '*Redistributable*'){
                    $ign = $true
              }elseif($output.Name -like '*Minimum Runtime*'){
                    $ign = $true
              }elseif($output.Name -like '*Additional Runtime*'){
                    $ign = $true
              }elseif($output.Name -like '*Update for*'){
                    $ign = $true
              }#elseif($output.Name -like '* Component*'){
              #      $ign = $true
              #}
              
              #Checking to see if the current application is a duplicate entry
              foreach($element in $apps){
                    if($element.Name -eq $($_.DisplayName))
                    {
                       $ign = $true
                    }
              }
              #If the current application entry isn't null and it isn't an undesired entry (e.g bloat or duplicate), add it to the apps array
              if($output.Name -ne $null){
                if($ign -eq $false){
                    $apps += $output
                }
              }
              #If we ignored the entry, add it to a "bin" that can be displayed if the user requests   
              if($ign -eq $true){
                $bin += $($_.DisplayName)
              } 
        }
        Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object{
              
              $ign = $false
              $output = [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Name = $($_.DisplayName)
                Version = $($_.DisplayVersion)
                Status = "-"
              }
              if($output.Name -like '*Redistributable*'){
                    $ign = $true
              }elseif($output.Name -like '*Minimum Runtime*'){
                    $ign = $true
              }elseif($output.Name -like '*Additional Runtime*'){
                    $ign = $true
              }elseif($output.Name -like '*Update for*'){
                    $ign = $true
              }#elseif($output.Name -like '* Component*'){
              #      $ign = $true
              #}
     
              foreach($element in $apps){
                    if($element.Name -eq $($_.DisplayName))
                    {
                       $ign = $true
                    }
              }
                         
              if($output.Name -ne $null){
                if($ign -eq $false){
                    $apps += $output
                }
              }
              
              if($ign -eq $true){
                $bin += $($_.DisplayName)
              }              
        }
        
        #Display bin
        if($ShowIgnored -eq $true){
            Write-Host 'Ignored: ' `n
            foreach($element in $bin){
                Write-Host $element `n
            }
        }
      
        #Checking to see if a baseline file was provided
        if($BaseLinePath){
            #Testing file path
            if(Test-Path $BaseLinePath){
                #Making sure file type is compatible
                if(($BaseLinePath -match ".csv") -or ($BaseLinePath -match ".txt")){
                    #Importing csv
                    if($baseLine = Import-Csv -Path $BaseLinePath -Header "Name", "Version"){
                        Write-Host "Successfully imported $BaseLinePath"
                    }else{
                        return("Failed to import $BaseLinePath") 
                    }
                }else{
                    return("File type invalid.")
                }
            }else{
                return("$BaseLinePath not found.")
            }
        }else{
            return $apps
        }
        
        #Checking to see if all baseline file entries were found on this computer
        foreach($objectA in $baseLine){
        [boolean]$match = $false
            foreach($objectB in $apps){
                if($objectB.Name -like "*Notepad++ (64-bit x64)*"){
                    continue
                elseif($objectA.Name -match $objectB.Name){
                        $match = $true
                }
                }
            }
            if($match -eq $false){
                Write-Host $objectB.Name " not found on this system."
            }
        }

        #Comparing data taken from system to baseline file
        foreach($objectA in $apps){
            [boolean]$match = $false
            if($objectA.Version -eq $null){
                continue
            }else{
                foreach($objectB in $baseLine){
   
                    #Hardcoded fix for Notepad++. The -match operator has trouble parsing '++'.
                    if(!($objectA.Name -like "*Notepad++ (64-bit x64)*") -and ($objectB.Name -like "*Notepad++ (64-bit x64)*")){
                        continue
                    }elseif(($objectA.Name -like "*Notepad++ (64-bit x64)*") -and ($objectB.Name -like "*Notepad++ (64-bit x64)*")){
                        $match = $true
                        [long]$num1 = $objectA.Version -replace '[.]', ''
                        [long]$num2 = $objectB.Version -replace '[.]', ''
                        if($num1 -eq $num2){
                            $objectA.Status = 'OK'
                        }elseif($num1 -lt $num2){
                            $objectA.Status = 'Out-of-Date'
                        }elseif($num1 -gt $num2){
                            $objectA.Status = 'Ahead'
                        }
                    }elseif($objectA.Name -match $objectB.Name){
                        $match = $true
                        [long]$num1 = $objectA.Version -replace '[.]', ''
                        [long]$num2 = $objectB.Version -replace '[.]', ''
                        if($num1 -eq $num2){
                            $objectA.Status = 'OK'
                        }elseif($num1 -lt $num2){
                            $objectA.Status = 'Out-of-Date'
                        }elseif($num1 -gt $num2){
                            $objectA.Status = 'Ahead'
                        }
                    }
                }
            }
            if($match -eq $false){
                $objectA.Status = 'DNE'
            }
        }

        ###############
        ### VM Loop ###
        ###############

        foreach($vm in $ComputerNames){

            #Runs the command on the VM to get the ip information
            $vmReturn = Invoke-Command -ComputerName $vm -ArgumentList $baseLine -ScriptBlock{
                
                #Get baseline data from input argument of invoke-command
                $baseLine = $args

                $apps = @()
                $bin = @()
                [boolean]$ign = $false
                
                #We need to look for applications both using 'Wow6432Node' and not using 'Wow6432Node' to get 64 bit AND 32 bit information
                Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object{
              
                      $ign = $false
                      $output = [PSCustomObject]@{
				        ComputerName = $env:COMPUTERNAME
                        Name = $($_.DisplayName)
                        Version = $($_.DisplayVersion)
                        Status = "-"
                      }
                      #Checking to see if the current application is bloat
                      if($output.Name -like '*Redistributable*'){
                            $ign = $true
                      }elseif($output.Name -like '*Minimum Runtime*'){
                            $ign = $true
                      }elseif($output.Name -like '*Additional Runtime*'){
                            $ign = $true
                      }elseif($output.Name -like '*Update for*'){
                            $ign = $true
                      }#elseif($output.Name -like '* Component*'){
                      #      $ign = $true
                      #}
              
                      #Checking to see if the current application is a duplicate entry
                      foreach($element in $apps){
                            if($element.Name -eq $($_.DisplayName))
                            {
                               $ign = $true
                            }
                      }
                      #If the current application entry isn't null and it isn't an undesired entry (e.g bloat or duplicate), add it to the apps array
                      if($output.Name -ne $null){
                        if($ign -eq $false){
                            $apps += $output
                        }
                      }
                      #If we ignored the entry, add it to a "bin" that can be displayed if the user requests   
                      if($ign -eq $true){
                        $bin += $($_.DisplayName)
                      } 
                }
                Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object{
              
                      $ign = $false
                      $output = [PSCustomObject]@{
                        ComputerName = $env:COMPUTERNAME
                        Name = $($_.DisplayName)
                        Version = $($_.DisplayVersion)
                        Status = "-"
                      }
                      if($output.Name -like '*Redistributable*'){
                            $ign = $true
                      }elseif($output.Name -like '*Minimum Runtime*'){
                            $ign = $true
                      }elseif($output.Name -like '*Additional Runtime*'){
                            $ign = $true
                      }elseif($output.Name -like '*Update for*'){
                            $ign = $true
                      }#elseif($output.Name -like '* Component*'){
                      #      $ign = $true
                      #}
     
                      foreach($element in $apps){
                            if($element.Name -eq $($_.DisplayName))
                            {
                               $ign = $true
                            }
                      }
                         
                      if($output.Name -ne $null){
                        if($ign -eq $false){
                            $apps += $output
                        }
                      }
              
                      if($ign -eq $true){
                        $bin += $($_.DisplayName)
                      }              
                }
        
                #Display bin
                if($ShowIgnored -eq $true){
                    Write-Host 'Ignored: ' `n
                    foreach($element in $bin){
                        Write-Host $element `n
                    }
                }
                
                ### Different to sever code ###
                #Return the version data if there is no baseline
                if($baseLine -eq $null){
                    return $apps
                }
           
                #Checking to see if all baseline file entries were found on this computer
                foreach($objectA in $baseLine){
                    [boolean]$match = $false
                    foreach($objectB in $apps){
                        if($objectB.Name -like "*Notepad++ (64-bit x64)*"){
                            continue
                        elseif($objectA.Name -match $objectB.Name){
                            $match = $true
                        }
                        }
                    }
                    if($match -eq $false){
                        Write-Host $objectB.Name " not found on this system." 
                    }
                }

                #Comparing data taken from system to baseline file
                foreach($objectA in $apps){
                    [boolean]$match = $false
                    if($objectA.Version -eq $null){
                        continue
                    }else{
                        foreach($objectB in $baseLine){

                            #Hardcoded fix for Notepad++. The -match operator has trouble parsing '++'.
                            if(!($objectA.Name -like "*Notepad++ (64-bit x64)*") -and ($objectB.Name -like "*Notepad++ (64-bit x64)*")){
                                continue
                            }elseif(($objectA.Name -like "*Notepad++ (64-bit x64)*") -and ($objectB.Name -like "*Notepad++ (64-bit x64)*")){
                                $match = $true
                                [long]$num1 = $objectA.Version -replace '[.]', ''
                                [long]$num2 = $objectB.Version -replace '[.]', ''
                                if($num1 -eq $num2){
                                    $objectA.Status = 'OK'
                                }elseif($num1 -lt $num2){
                                    $objectA.Status = 'Out-of-Date'
                                }elseif($num1 -gt $num2){
                                    $objectA.Status = 'Ahead'
                                }
                            }elseif($objectA.Name -match $objectB.Name){
                                $match = $true
                                [long]$num1 = $objectA.Version -replace '[.]', ''
                                [long]$num2 = $objectB.Version -replace '[.]', ''
                                if($num1 -eq $num2){
                                    $objectA.Status = 'OK'
                                }elseif($num1 -lt $num2){
                                    $objectA.Status = 'Out-of-Date'
                                }elseif($num1 -gt $num2){
                                    $objectA.Status = 'Ahead'
                                }
                            }
                        }
                    }
                    if($match -eq $false){
                        $objectA.Status = 'DNE'
                    }
                }

                return $apps
            }

            #Adds the VM info object into the results object
            $apps += $vmReturn
        }


        #Return the data
        return $apps | select ComputerName, Name, Version, Status
        }
End{}
}


#FOOT NOTES:
#Can also get 'Publisher' and 'InstallDate' information
#Baseline file must be either .csv or .txt. Must be properly formatted e.g:
#
#Name,Version
#Name,1.5.8
#app2Name,1.10.32
#...
#
#ShowIgnored parameter is a boolean. Acceptable values are '$true' or '1' for true. '$false' or '0' for false. Not specifying will result in false
#Need to develop a dynamic fix for applications that have '++' (not just Notepad)