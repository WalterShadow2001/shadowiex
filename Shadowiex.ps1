<#
.SYNOPSIS
    SHADOWIEX v10.0 - Professional Edition
.NOTES
    Autor: WDPN (WalterShadow2001)
#>

# Verificar admin
 $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $p = $MyInvocation.MyCommand.Path
    if ($p) { Start-Process powershell "-NoProfile -EP Bypass -File `"$p`"" -Verb RunAs }
    else { Start-Process powershell "-NoProfile -EP Bypass -Command `"irm n9.cl/shadowiex | iex`"" -Verb RunAs }
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Tema
 $t = @{
    BG = [System.Drawing.Color]::FromArgb(18, 18, 24)
    Surface = [System.Drawing.Color]::FromArgb(30, 30, 42)
    Primary = [System.Drawing.Color]::FromArgb(139, 92, 246)
    Secondary = [System.Drawing.Color]::FromArgb(20, 184, 166)
    Success = [System.Drawing.Color]::FromArgb(34, 197, 94)
    Warning = [System.Drawing.Color]::FromArgb(251, 191, 36)
    Danger = [System.Drawing.Color]::FromArgb(239, 68, 68)
    Text = [System.Drawing.Color]::White
    Muted = [System.Drawing.Color]::FromArgb(156, 163, 175)
}
 $fTitle = [System.Drawing.Font]::new("Segoe UI", 24, "Bold")
 $fHeader = [System.Drawing.Font]::new("Segoe UI", 13, "Bold")
 $fNorm = [System.Drawing.Font]::new("Segoe UI", 10)
 $fBtn = [System.Drawing.Font]::new("Segoe UI", 10, "Bold")
 $fSmall = [System.Drawing.Font]::new("Segoe UI", 9)

# Funciones MAS
function Invoke-MASActivation {
    param($Mode)
    $url = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/Activate.ps1"
    try {
        $s = Invoke-RestMethod $url -UseBasicParsing -TimeoutSec 30
        $f = "$env:TEMP\mas_act.ps1"
        $s | Out-File $f -Encoding UTF8
        $arg = switch($Mode) {
            "HWID" { "/HWID" }
            "Ohook" { "/Ohook" }
            "TSforge" { "/TSforge" }
            "KMS" { "/K-WindowsOffice" }
            default { "" }
        }
        Start-Process powershell "-NoProfile -EP Bypass -Command `"& '$f' $arg`"" -Verb RunAs -Wait
        return $true
    } catch { return $false }
}

function Open-MASMenu {
    $m = @'
Write-Host "=== MICROSOFT ACTIVATION SCRIPTS ===" -F Cyan
Write-Host "[1] HWID - Windows Permanente" -F Green
Write-Host "[2] Ohook - Office" -F Green  
Write-Host "[3] TSforge - Windows/Office/ESU" -F Green
Write-Host "[4] KMS - Windows/Office" -F Green
Write-Host "[5] Ver Estado" -F Yellow
Write-Host "[0] Salir" -F Gray
 $c = Read-Host "Opcion"
switch($c) {
    "1" { irm https://massgrave.dev/hwid | iex }
    "2" { irm https://massgrave.dev/ohook | iex }
    "3" { irm https://massgrave.dev/tsforge | iex }
    "4" { irm https://massgrave.dev/kms | iex }
    "5" { slmgr /dli; pause }
    "0" { exit }
}
'@
    $f = "$env:TEMP\mas_menu.ps1"
    $m | Out-File $f -Encoding UTF8
    Start-Process powershell "-NoProfile -EP Bypass -File '$f'" -Verb RunAs
}

# Formulario
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "SHADOWIEX"
 $form.Size = [System.Drawing.Size]::new(950, 650)
 $form.BackColor = $t.BG
 $form.ForeColor = $t.Text
 $form.StartPosition = "CenterScreen"

# Header
 $hp = New-Object System.Windows.Forms.Panel
 $hp.Dock = "Top"
 $hp.Height = 70
 $hp.BackColor = $t.Surface
 $form.Controls.Add($hp)

 $tl = New-Object System.Windows.Forms.Label
 $tl.Text = "SHADOWIEX"
 $tl.Location = [System.Drawing.Point]::new(20, 15)
 $tl.Size = [System.Drawing.Size]::new(200, 40)
 $tl.Font = $fTitle
 $tl.ForeColor = $t.Primary
 $hp.Controls.Add($tl)

 $vl = New-Object System.Windows.Forms.Label
 $vl.Text = "v10.0"
 $vl.Location = [System.Drawing.Point]::new(195, 28)
 $vl.Size = [System.Drawing.Size]::new(50, 20)
 $vl.Font = $fSmall
 $vl.ForeColor = $t.Secondary
 $hp.Controls.Add($vl)

# Tabs
 $tc = New-Object System.Windows.Forms.TabControl
 $tc.Location = [System.Drawing.Point]::new(0, 70)
 $tc.Size = [System.Drawing.Size]::new(950, 530)
 $tc.BackColor = $t.BG
 $tc.Appearance = "FlatButtons"
 $tc.ItemSize = [System.Drawing.Size]::new(120, 35)
 $tc.Font = $fBtn

 $t1 = New-Object System.Windows.Forms.TabPage
 $t1.Text = "INSTALAR"
 $t1.BackColor = $t.BG

 $t2 = New-Object System.Windows.Forms.TabPage
 $t2.Text = "OPTIMIZAR"
 $t2.BackColor = $t.BG

 $t3 = New-Object System.Windows.Forms.TabPage
 $t3.Text = "ACTIVAR"
 $t3.BackColor = $t.BG

 $t4 = New-Object System.Windows.Forms.TabPage
 $t4.Text = "CONFIG"
 $t4.BackColor = $t.BG

 $tc.Controls.AddRange(@($t1, $t2, $t3, $t4))
 $form.Controls.Add($tc)

# === PESTANA ACTIVAR ===
 $ah = New-Object System.Windows.Forms.Label
 $ah.Text = "ACTIVACION DE WINDOWS Y OFFICE"
 $ah.Location = [System.Drawing.Point]::new(20, 15)
 $ah.Size = [System.Drawing.Size]::new(500, 30)
 $ah.Font = $fHeader
 $ah.ForeColor = $t.Text
 $t3.Controls.Add($ah)

 $ad = New-Object System.Windows.Forms.Label
 $ad.Text = "MAS integrado - Descarga scripts de activacion desde massgrave.dev"
 $ad.Location = [System.Drawing.Point]::new(20, 45)
 $ad.Size = [System.Drawing.Size]::new(600, 20)
 $ad.Font = $fSmall
 $ad.ForeColor = $t.Muted
 $t3.Controls.Add($ad)

# Crear funcion de boton
function New-ABtn {
    param($txt, $x, $y, $col, $desc, $act)
    $p = New-Object System.Windows.Forms.Panel
    $p.Location = [System.Drawing.Point]::new($x, $y)
    $p.Size = [System.Drawing.Size]::new(210, 90)
    $p.BackColor = $t.Surface
    $t3.Controls.Add($p)
    
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $txt
    $b.Location = [System.Drawing.Point]::new(10, 10)
    $b.Size = [System.Drawing.Size]::new(190, 40)
    $b.BackColor = $t.$col
    $b.ForeColor = [System.Drawing.Color]::White
    $b.FlatStyle = "Flat"
    $b.Font = $fBtn
    $b.Cursor = "Hand"
    $b.Add_Click($act)
    $p.Controls.Add($b)
    
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $desc
    $l.Location = [System.Drawing.Point]::new(10, 55)
    $l.Size = [System.Drawing.Size]::new(190, 30)
    $l.Font = $fSmall
    $l.ForeColor = $t.Muted
    $p.Controls.Add($l)
}

# Botones
New-ABtn "MAS INTERACTIVO" 20 80 "Success" "Menu completo de activacion" {
    Open-MASMenu
}

New-ABtn "ACTIVAR WINDOWS" 240 80 "Primary" "HWID - Activacion permanente" {
    $r = Invoke-MASActivation "HWID"
    if (-not $r) { Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://massgrave.dev/hwid | iex`"" -Verb RunAs }
}

New-ABtn "ACTIVAR OFFICE" 460 80 "Primary" "Ohook - Activacion Office" {
    $r = Invoke-MASActivation "Ohook"
    if (-not $r) { Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://massgrave.dev/ohook | iex`"" -Verb RunAs }
}

New-ABtn "TSFORGE TODO" 680 80 "Success" "Windows + Office + ESU" {
    $r = Invoke-MASActivation "TSforge"
    if (-not $r) { Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://massgrave.dev/tsforge | iex`"" -Verb RunAs }
}

New-ABtn "KMS ONLINE" 20 180 "Secondary" "Activacion KMS Windows/Office" {
    $r = Invoke-MASActivation "KMS"
    if (-not $r) { Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://massgrave.dev/kms | iex`"" -Verb RunAs }
}

New-ABtn "VER ESTADO" 240 180 "Secondary" "Ver estado de activacion" {
    $w = cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1
    [System.Windows.Forms.MessageBox]::Show($w, "Estado Windows")
}

New-ABtn "ACTIVATED.WIN" 460 180 "Warning" "Activador online alternativo" {
    Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
}

New-ABtn "WINUTIL" 680 180 "Warning" "Chris Titus Windows Utility" {
    Start-Process powershell "-NoProfile -EP Bypass -Command `"irm https://christitus.com/win | iex`"" -Verb RunAs
}

# Status bar
 $ss = New-Object System.Windows.Forms.StatusStrip
 $ss.BackColor = $t.Surface
 $sl = New-Object System.Windows.Forms.ToolStripStatusLabel
 $sl.Text = "SHADOWIEX v10.0 - Listo"
 $sl.ForeColor = $t.Muted
 $ss.Items.Add($sl)
 $form.Controls.Add($ss)

[void]$form.ShowDialog()
