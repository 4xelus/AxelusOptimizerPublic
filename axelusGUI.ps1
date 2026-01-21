# Wczytanie funkcji i XAML relatywnie
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\AxelusOptimizer.ps1"

$XAMLPath = "$scriptDir\axelusGUI.xaml"
$reader = (New-Object System.Xml.XmlNodeReader (Get-Content $XAMLPath -Raw))
$Form = [Windows.Markup.XamlReader]::Load($reader)

# Przyciski
$logBox = $Form.FindName("logBox")
$btnPowerPlan = $Form.FindName("btnPowerPlan")
$btnGameDVR = $Form.FindName("btnGameDVR")
$btnInputLatency = $Form.FindName("btnInputLatency")
$btnNetwork = $Form.FindName("btnNetwork")
$btnServices = $Form.FindName("btnServices")
$btnGPU = $Form.FindName("btnGPU")
$btnRestart = $Form.FindName("btnRestart")

# Funkcja logowania
function Log($Action) { $logBox.AppendText("$Action`r`n") }

# Kliknięcia
$btnPowerPlan.Add_Click({ Log (Set-PowerPlan) })
$btnGameDVR.Add_Click({ Log (Disable-GameDVR) })
$btnInputLatency.Add_Click({ Log (Input-LatencyTweaks) })
$btnNetwork.Add_Click({ Log (Network-Optimizations) })
$btnServices.Add_Click({ Log (Services-Debloat) })
$btnGPU.Add_Click({ Log (GPU-Tweaks) })
$btnRestart.Add_Click({ Restart-Computer })

# Pokaż GUI
$Form.ShowDialog() | Out-Null

