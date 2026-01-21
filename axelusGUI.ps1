Add-Type -AssemblyName PresentationFramework

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\AxelusOptimizer.ps1"

$XAMLPath = "$scriptDir\axelusGUI.xaml"
$reader = (New-Object System.Xml.XmlNodeReader (Get-Content $XAMLPath -Raw))
$Form = [Windows.Markup.XamlReader]::Load($reader)

$logBox = $Form.FindName("logBox")
$btnPowerPlan = $Form.FindName("btnPowerPlan")
$btnGameDVR = $Form.FindName("btnGameDVR")
$btnInputLatency = $Form.FindName("btnInputLatency")
$btnNetwork = $Form.FindName("btnNetwork")
$btnServices = $Form.FindName("btnServices")
$btnGPU = $Form.FindName("btnGPU")
$btnRestart = $Form.FindName("btnRestart")

function Log($Action) {
    $logBox.AppendText("$Action`r`n")
    $logBox.ScrollToEnd()
}

$btnPowerPlan.Add_Click({ Log (Set-PowerPlan) })
$btnGameDVR.Add_Click({ Log (Disable-GameDVR) })
$btnInputLatency.Add_Click({ Log (Input-LatencyTweaks) })
$btnNetwork.Add_Click({ Log (Network-Optimizations) })
$btnServices.Add_Click({ Log (Services-Debloat) })
$btnGPU.Add_Click({ Log (GPU-Tweaks) })
$btnRestart.Add_Click({ Restart-Computer })

$Form.ShowDialog() | Out-Null

