# Import starych funkcji
. "C:\ścieżka\do\AxelusOptimizerPublic\AxelusOptimizer.ps1"


# ==========================================================
# Axelus Optimizer Modern GUI - WPF Version
# Author: Axelus
# ==========================================================

Add-Type -AssemblyName PresentationFramework

# --------------------------
# ADMIN CHECK
# --------------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Windows.MessageBox]::Show("Run PowerShell as Administrator!","Error","OK","Error")
    exit
}

# --------------------------
# FUNCTIONS
# --------------------------
function Set-PowerPlan {
    try {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > $null
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        return @{Text="Ultimate Performance Power Plan set!"; Success=$true}
    } catch { return @{Text="Failed to set Power Plan: $_"; Success=$false} }
}

function Disable-GameDVR {
    try {
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f
        return @{Text="Game DVR disabled!"; Success=$true}
    } catch { return @{Text="Failed to disable Game DVR: $_"; Success=$false} }
}

function Input-LatencyTweaks {
    try {
        reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
        return @{Text="Input & Latency optimized!"; Success=$true}
    } catch { return @{Text="Failed Input & Latency tweaks: $_"; Success=$false} }
}

function Network-Optimizations {
    try {
        netsh interface tcp set global autotuninglevel=normal
        netsh interface tcp set global ecncapability=disabled
        netsh interface tcp set global timestamps=disabled
        return @{Text="Network optimized!"; Success=$true}
    } catch { return @{Text="Failed Network optimizations: $_"; Success=$false} }
}

function Services-Debloat {
    $services = @("DiagTrack","MapsBroker","SysMain","WSearch","Fax","RetailDemo","XboxGipSvc","XboxNetApiSvc","XblAuthManager","XblGameSave")
    try {
        foreach ($svc in $services) {
            Get-Service -Name $svc -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne "Stopped"} | Stop-Service -Force
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
        return @{Text="Unnecessary services disabled!"; Success=$true}
    } catch { return @{Text="Failed to debloat services: $_"; Success=$false} }
}

function GPU-Tweaks {
    try {
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
        return @{Text="GPU & system tweaks applied!"; Success=$true}
    } catch { return @{Text="Failed GPU tweaks: $_"; Success=$false} }
}

# --------------------------
# WPF XAML
# --------------------------
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Axelus Optimizer" Height="550" Width="650"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E">
    <Grid Margin="10">
        <!-- Logo -->
        <TextBlock Text="AXELUS" Foreground="OrangeRed" FontSize="28" FontWeight="Bold" HorizontalAlignment="Left" VerticalAlignment="Top"/>

        <!-- Buttons Column -->
        <StackPanel Orientation="Vertical" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,60,0,0" Width="280" Spacing="15">
            <Button Name="btnPowerPlan" Content="Power Plan" Height="40" ToolTip="Sets Ultimate Performance power plan" />
            <Button Name="btnGameDVR" Content="Game DVR Off" Height="40" ToolTip="Disables Game DVR & background capture" />
            <Button Name="btnInputLatency" Content="Input/Latency" Height="40" ToolTip="Improves mouse/input latency" />
            <Button Name="btnNetwork" Content="Network" Height="40" ToolTip="Optimizes network settings" />
            <Button Name="btnServices" Content="Services" Height="40" ToolTip="Stops & disables unnecessary services" />
            <Button Name="btnGPU" Content="GPU Tweaks" Height="40" ToolTip="Applies GPU & system tweaks" />
            <Button Name="btnRestart" Content="Restart PC" Height="40" Background="Red" Foreground="White" FontWeight="Bold" ToolTip="Restarts the PC" />
        </StackPanel>

        <!-- Description Column -->
        <StackPanel Orientation="Vertical" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="320,60,0,0" Width="300" Spacing="15">
            <TextBlock Text="Sets Windows Ultimate Performance power plan for max CPU/GPU performance." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Disables Game DVR & background recording for smoother gaming." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Tweaks mouse & input latency for faster response." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Optimizes network settings like TCP autotuning & timestamps." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Stops unnecessary Windows services safe for gaming." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Enables GPU Hardware Scheduling for better frame delivery." Foreground="White" TextWrapping="Wrap"/>
            <TextBlock Text="Restarts the PC to apply all changes." Foreground="White" TextWrapping="Wrap"/>
        </StackPanel>

        <!-- Log Box -->
        <TextBox Name="logBox" Height="180" VerticalAlignment="Bottom" Margin="0,0,0,10" Background="Black" Foreground="White" FontFamily="Consolas" FontSize="12" IsReadOnly="True" TextWrapping="Wrap" AcceptsReturn="True" VerticalScrollBarVisibility="Auto"/>
    </Grid>
</Window>
"@

# --------------------------
# Load XAML
# --------------------------
$reader=(New-Object System.Xml.XmlNodeReader $XAML)
$Form=[Windows.Markup.XamlReader]::Load($reader)

# --------------------------
# Get Controls
# --------------------------
$logBox = $Form.FindName("logBox")
$btnPowerPlan = $Form.FindName("btnPowerPlan")
$btnGameDVR = $Form.FindName("btnGameDVR")
$btnInputLatency = $Form.FindName("btnInputLatency")
$btnNetwork = $Form.FindName("btnNetwork")
$btnServices = $Form.FindName("btnServices")
$btnGPU = $Form.FindName("btnGPU")
$btnRestart = $Form.FindName("btnRestart")

# --------------------------
# Log function
# --------------------------
function Log($result){
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = if ($result.Success) {"Lime"} else {"Red"}
    $logBox.Dispatcher.Invoke([action]{
        $logBox.AppendText("[$timestamp] $($result.Text)`r`n")
        $logBox.ScrollToEnd()
    })
}

# --------------------------
# Button Click Events
# --------------------------
$btnPowerPlan.Add_Click({Log (Set-PowerPlan)})
$btnGameDVR.Add_Click({Log (Disable-GameDVR)})
$btnInputLatency.Add_Click({Log (Input-LatencyTweaks)})
$btnNetwork.Add_Click({Log (Network-Optimizations)})
$btnServices.Add_Click({Log (Services-Debloat)})
$btnGPU.Add_Click({Log (GPU-Tweaks)})
$btnRestart.Add_Click({
    if ([System.Windows.MessageBox]::Show("Restart PC now?", "Restart", "YesNo") -eq "Yes") {
        Restart-Computer
    }
})

# --------------------------
# Show Window
# --------------------------
$Form.ShowDialog() | out-null

