# ==========================================================
# Axelus Optimizer - GUI One-Liner Version
# ==========================================================

# REQUIRE ADMIN
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Run PowerShell as Administrator!" -ForegroundColor Red
    exit
}

Add-Type -AssemblyName PresentationFramework

# Download remote files from GitHub
$baseURL = "https://raw.githubusercontent.com/4xelus/AxelusOptimizerPublic/main/"
$optimizerScript = Invoke-WebRequest -UseBasicParsing ($baseURL + "AxelusOptimizer.ps1") | Select-Object -ExpandProperty Content
$xamlContent = Invoke-WebRequest -UseBasicParsing ($baseURL + "axelusGUI.xaml") | Select-Object -ExpandProperty Content

# Save scripts to temporary files
$tempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
Set-Content -Path $tempScript -Value $optimizerScript
$tempXAML = [System.IO.Path]::GetTempFileName() + ".xaml"
Set-Content -Path $tempXAML -Value $xamlContent

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader (Get-Content $tempXAML -Raw))
$Form = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$logBox = $Form.FindName("logBox")
$btnPowerPlan = $Form.FindName("btnPowerPlan")
$btnGameDVR = $Form.FindName("btnGameDVR")
$btnInputLatency = $Form.FindName("btnInputLatency")
$btnNetwork = $Form.FindName("btnNetwork")
$btnServices = $Form.FindName("btnServices")
$btnGPU = $Form.FindName("btnGPU")
$btnRestart = $Form.FindName("btnRestart")

# Logging helper
function Log($action) { $logBox.AppendText("$action`n"); $logBox.ScrollToEnd() }

# Execute functions from optimizer script
. $tempScript

# Button events
$btnPowerPlan.Add_Click({ Log (Set-PowerPlan) })
$btnGameDVR.Add_Click({ Log (Disable-GameDVR) })
$btnInputLatency.Add_Click({ Log (Input-LatencyTweaks) })
$btnNetwork.Add_Click({ Log (Network-Optimizations) })
$btnServices.Add_Click({ Log (Services-Debloat) })
$btnGPU.Add_Click({ Log (GPU-Tweaks) })
$btnRestart.Add_Click({ Restart-Computer })

# Show GUI
$Form.ShowDialog() | Out-Null

# Clean temp files
Remove-Item $tempScript -Force
Remove-Item $tempXAML -Force
