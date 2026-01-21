function Set-PowerPlan { 
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > $null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
}

function Disable-GameDVR {
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
}

function Input-LatencyTweaks {
    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
}

function Network-Optimizations {
    netsh interface tcp set global autotuninglevel=normal
    netsh interface tcp set global ecncapability=disabled
    netsh interface tcp set global timestamps=disabled
}

function Services-Debloat {
    $services = @("DiagTrack","MapsBroker","SysMain","WSearch","Fax","RetailDemo","XboxGipSvc","XboxNetApiSvc","XblAuthManager","XblGameSave")
    foreach ($svc in $services) {
        Get-Service -Name $svc -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne "Stopped"} | Stop-Service -Force
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function GPU-Tweaks {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
}

