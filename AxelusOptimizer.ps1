Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --------------------------
# Sprawdzenie admina
# --------------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Windows.Forms.MessageBox]::Show("Run PowerShell as Administrator!","Error","OK","Error")
    exit
}

# --------------------------
# FUNKCJE OPTIMALIZACJI
# --------------------------
function Set-PowerPlan {
    Write-Host "Setting Ultimate Performance Power Plan..."
    try {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > $null
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        return "Power Plan set successfully!"
    } catch { return "Failed to set Power Plan: $_" }
}

function Disable-GameDVR {
    Write-Host "Disabling Game DVR & Background Capture..."
    try {
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
        return "Game DVR disabled!"
    } catch { return "Failed to disable Game DVR: $_" }
}

function Input-LatencyTweaks {
    Write-Host "Applying Input & Latency Optimizations..."
    try {
        reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
        return "Input & Latency optimized!"
    } catch { return "Failed Input & Latency tweaks: $_" }
}

function Network-Optimizations {
    Write-Host "Applying Network Optimizations..."
    try {
        netsh interface tcp set global autotuninglevel=normal
        netsh interface tcp set global ecncapability=disabled
        netsh interface tcp set global timestamps=disabled
        return "Network optimized!"
    } catch { return "Failed Network optimizations: $_" }
}

function Services-Debloat {
    Write-Host "Disabling unnecessary services..."
    $services = @("DiagTrack","MapsBroker","SysMain","WSearch","Fax","RetailDemo","XboxGipSvc","XboxNetApiSvc","XblAuthManager","XblGameSave")
    try {
        foreach ($svc in $services) {
            Get-Service -Name $svc -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne "Stopped"} | Stop-Service -Force
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        return "Unnecessary services disabled!"
    } catch { return "Failed to debloat services: $_" }
}

function GPU-Tweaks {
    Write-Host "Applying GPU & System Tweaks..."
    try {
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
        return "GPU & system tweaks applied!"
    } catch { return "Failed GPU tweaks: $_" }
}

# --------------------------
# GUI
# --------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Axelus Optimizer GUI"
$form.Size = New-Object System.Drawing.Size(550,520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Log textbox
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.Location = New-Object System.Drawing.Point(20,310)
$logBox.Size = New-Object System.Drawing.Size(500,160)
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.BackColor = [System.Drawing.Color]::Black
$logBox.ForeColor = [System.Drawing.Color]::Lime
$form.Controls.Add($logBox)

# Funkcja log
function Log($text) {
    $logBox.AppendText("[$(Get-Date -Format 'HH:mm:ss')] $text`r`n")
    $logBox.Refresh()
}

# Lista przycisków i funkcji
$buttons = @(
    @{Text="Power Plan"; Func={Log (Set-PowerPlan)}; Tip="Sets Ultimate Performance power plan"},
    @{Text="Game DVR Off"; Func={Log (Disable-GameDVR)}; Tip="Disables Game DVR & Background Capture"},
    @{Text="Input/Latency"; Func={Log (Input-LatencyTweaks)}; Tip="Improves mouse/input latency"},
    @{Text="Network"; Func={Log (Network-Optimizations)}; Tip="Optimizes network settings for gaming"},
    @{Text="Services"; Func={Log (Services-Debloat)}; Tip="Stops and disables non-essential services"},
    @{Text="GPU Tweaks"; Func={Log (GPU-Tweaks)}; Tip="Applies GPU scheduling tweaks"}
)

$y = 20
foreach ($btn in $buttons) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $btn.Text
    $button.Size = New-Object System.Drawing.Size(200,40)
    $button.Location = New-Object System.Drawing.Point(170,$y)
    $button.Add_Click($btn.Func)
    $tooltip = New-Object System.Windows.Forms.ToolTip
    $tooltip.SetToolTip($button,$btn.Tip)
    $form.Controls.Add($button)
    $y += 50
}

# Restart PC button
$restartBtn = New-Object System.Windows.Forms.Button
$restartBtn.Text = "Restart PC"
$restartBtn.Size = New-Object System.Drawing.Size(200,40)
$restartBtn.Location = New-Object System.Drawing.Point(170,$y)
$restartBtn.BackColor = [System.Drawing.Color]::Red
$restartBtn.ForeColor = [System.Drawing.Color]::White
$restartBtn.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Restart PC now?", "Restart", [System.Windows.Forms.MessageBoxButtons]::YesNo) -eq [System.Windows.Forms.DialogResult]::Yes) {
        Restart-Computer
    }
})
$form.Controls.Add($restartBtn)

# Start GUI
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

