<#
        .SYNOPSIS
        Test .ps1 script to be used as a Windows Service.

        .DESCRIPTION
        Save as .ps1 and run.
        Script creates a file "%USERPROFILE%\Downloads\_TestService.txt" in the current users Downloads Folder
        By default this script will write a new line every 10 seconds

        .DESCRIPTION
        YOU MAY MODIFY THE FREQUENCY THIS SCRIPT WRITES A NEW LINE TO THE "_TestService.txt" FILE VIA:
        "HKLM:\SYSTEM\CurrentControlSet\Services\_TestService" AND "REGSZ with the name of FREQUENCY"

#>
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\_TestService"
$regName = 'Frequency'
$regValue = 10
if(Test-Path $registryPath)
{
    [int]$frequency = Get-ItemProperty -Path $registryPath -Name $regName | select -ExpandProperty Frequency
}
if(!(Test-Path $registryPath))
{
    New-Item $registryPath -Force | Out-Null
    Start-Sleep -Milliseconds 200        
    New-ItemProperty -Path $registryPath -Name $regName -Value $regValue -PropertyType String -Force | Out-Null
    Start-Sleep -Milliseconds 200
    [int]$frequency = Get-ItemProperty -Path $registryPath -Name $regName | select -ExpandProperty Frequency
}
Remove-Variable -Name firstLoop -Force -EA SilentlyContinue -WA SilentlyContinue | Out-Null
for($go = 1; $go -lt 2) # $go will always be less than 2, so this script will run until user intervention
{
    $d = Get-Date
    $p = "$($env:USERPROFILE)\Downloads\_TestService.txt" 
    [int]$frequency = Get-ItemProperty -Path $registryPath -Name $regName | select -ExpandProperty Frequency 
    if(Test-Path $p)
    {
        if($firstLoop -ne $false)
        {              
            Add-Content -Value "$($d) - Script Started" -Path $p -EA SilentlyContinue -WA SilentlyContinue 
            $firstLoop = $false           
        }
        else
        {  
            Add-Content -Value $d -Path $p -EA SilentlyContinue -WA SilentlyContinue
        }
    }

    if(!(Test-Path $p))
    {
        New-Item -Path $p -ItemType File -EA SilentlyContinue -WA SilentlyContinue | Out-Null
        if($firstLoop -ne $false)
        {              
            Add-Content -Value "$($d) - Script Started" -Path $p -EA SilentlyContinue -WA SilentlyContinue 
            $firstLoop = $false           
        }        
        else
        {           
            Add-Content -Value $d -Path $p -EA SilentlyContinue -WA SilentlyContinue
        }
    }     
    Start-Sleep -Seconds $frequency
}
