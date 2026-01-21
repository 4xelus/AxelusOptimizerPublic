# ==========================================================
# Axelus Optimizer Modern GUI - WPF Version
# ==========================================================
Add-Type -AssemblyName PresentationFramework

# ADMIN CHECK
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Windows.MessageBox]::Show("Run PowerShell as Administrator!","Error","OK","Error")
    exit
}

# IMPORT CORE FUNCTIONS
. "C:\ścieżka\do\AxelusOptimizerPublic\AxelusOptimizer.ps1"

# XAML GUI
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Axelus Optimizer" Height="550" Width="650"
        WindowStartupLocation="CenterScreen" Background="#1E1E1E">
    <Grid Margin="10">
        <TextBlock Text="AXELUS" Foreground="OrangeRed" FontSize="28" FontWeight="Bold" HorizontalAlignment="Left" VerticalAlignment="Top"/>

        <!-- Buttons -->
        <StackPanel Orientation="Vertical" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,60,0,0" Width="280" Spacing="15">
            <Button Name="btnPowerPlan" Content="Power Plan" Height="40" ToolTip="Sets Ultimate Performance power plan"/>
            <Button Name="btnGameDVR" Content="Game DVR Off" Height="40" ToolTip="Disables Game DVR"/>
            <Button Name="btnInputLatency" Content="Input/Latency" Height="40" ToolTip="Improves mouse/input latency"/>
            <Button Name="btnNetwork" Content="Network" Height="40" ToolTip="Optimizes network settings"/>
            <Button Name="btnServices" Content="Services" Height="40" ToolTip="Stops unnecessary services"/>
            <Button Name="btnGPU" Content="GPU Tweaks" Height="40" ToolTip="Enables GPU tweaks"/>
            <Button Name="btnRestart" Content="Restart PC" Height="40" Background="Red" Foreground="White" FontWeight="Bold" ToolTip="Restarts PC"/>
        </StackPanel>

        <!-- Descriptions -->
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

# LOAD XAML
$reader=(New-Object System.Xml.XmlNodeReader $XAML)
$Form=[Windows.Markup.XamlReader]::Load($reader)

# GET CONTROLS
$logBox = $Form.FindName("logBox")
$btnPowerPlan = $Form.FindName("btnPowerPlan")
$btnGameDVR = $Form.FindName("btnGameDVR")
$btnInputLatency = $Form.FindName("btnInputLatency")
$btnNetwork = $Form.FindName("btnNetwork")
$btnServices = $Form.FindName("btnServices")
$btnGPU = $Form.FindName("btnGPU")
$btnRestart = $Form.FindName("btnRestart")

# LOG FUNCTION
function Log($result){
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logBox.Dispatcher.Invoke([action]{
        $color = if ($result.Success) {"Lime"} else {"Red"}
        $logBox.AppendText("[$timestamp] $($result.Text)`r`n")
        $logBox.ScrollToEnd()
    })
}

# BUTTON EVENTS
$btnPowerPlan.Add_Click({Log (Set-PowerPlan)})
$btnGameDVR.Add_Click({Log (Disable-GameDVR)})
$btnInputLatency.Add_Click({Log (Input-LatencyTweaks)})
$btnNetwork.Add_Click({Log (Network-Optimizations)})
$btnServices.Add_Click({Log (Services-Debloat)})
$btnGPU.Add_Click({Log (GPU-Tweaks)})
$btnRestart.Add_Click({
    if ([System.Windows.MessageBox]::Show("Restart PC now?","Restart","YesNo") -eq "Yes") { Restart-Computer }
})

# SHOW WINDOW
$Form.ShowDialog() | out-null
