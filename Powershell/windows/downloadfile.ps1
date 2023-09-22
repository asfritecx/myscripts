<#
- Downloads a file from the URL state in $downloadLink with TLS. 
#>

################## Change the variables here as needed ##################
[string]$savepath = "C:\temp"
[string]$downloadspath = "$savepath\filepath"
[string]$downloadName = "downloadedfile.txt"
[string]$downloadLink = "https://downloadurl.com/container/downloadedfile.txt"

################## Ensure Dependencies/Path is created ##################
mkdir $savepath -ErrorAction SilentlyContinue 
mkdir $downloadspath -ErrorAction SilentlyContinue

################## Check for administrator rights ##################
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
[String]$isadmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
    
if ($isadmin.Equals("False")) {
    
    Write-Output " "
    Write-Output "Please Run as Admin!!!"
    pause 
    exit
}

try {

    Clear-Host

    $uri = [System.Uri]::new($downloadLink)
    $domain = $uri.Host
    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = 'SilentlyContinue'
    Write-Host "Downloading From $domain...Please Wait..."
    Invoke-WebRequest "$($downloadLink)" -OutFile "$downloadspath\$downloadName"      
}

catch {
    Write-Host " "
    Write-Host "An Error Occurred" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Error information: " -ForegroundColor Red -BackgroundColor Black
    Write-Host " "
    Write-Host "  $_" -ForegroundColor Red -BackgroundColor Black
    Pause
}

Write-Host "Download Completed and file stored in : $downloadspath\$downloadName"
exit