<#
.SYNOPSIS
    SHADOWIEX v14.2 - Professional PC Toolkit
.DESCRIPTION
    Herramienta profesional de diagnostico, reparacion, instalacion y activacion.
    Integracion completa con MAS (iex online + offline).
    Carpeta instaladores para Office y herramientas.
    6 pestanas: DIAGNOSTICO, REPARAR, INSTALAR, ACTIVAR, OPTIMIZAR, CONFIG
.NOTES
    Autor: WDPN (WalterShadow2001)
    Repositorio: github.com/WalterShadow2001/shadowiex
#>

# ============================================================================
#  SPLASH / CARGA EN CONSOLA
# ============================================================================
Clear-Host

$SplashArt = @(
"##                          ",
"        @@    @@@@@@        ",
"      @    @@@@@@@ @@       ",
"     @  @@ @@@@@@@@@  %     ",
"    @   @@@@@@@@@@    @     ",
"    @  @@@@@@@@@@@    @     ",
"     % @@@@@@@@@@@    @     ",
"     %    @@@@@@@@   @      ",
"       @    @@@@@  @@ %     ",
"   %@#@   @@@@%@@@  @ @@    ",
"      @ @@@@ @@@@% @@%      ",
"          %@ @@ @           "
)

foreach ($line in $SplashArt) {
    Write-Host $line -ForegroundColor Cyan
}
Write-Host ""
Write-Host "                       Professional PC Toolkit  v14.2" -ForegroundColor Gray
Write-Host ""

$LoadSteps = @(
    @{Text = "  [1/6] Verificando privilegios de administrador...";     Color = "Cyan"},
    @{Text = "  [2/6] Cargando ensamblados de interfaz...";             Color = "Cyan"},
    @{Text = "  [3/6] Detectando hardware del sistema...";              Color = "Cyan"},
    @{Text = "  [4/6] Escaneando carpeta de instaladores...";           Color = "Cyan"},
    @{Text = "  [5/6] Buscando MAS_AIO.cmd...";                        Color = "Cyan"},
    @{Text = "  [6/6] Iniciando interfaz grafica...";                   Color = "Cyan"}
)

for ($i = 0; $i -lt $LoadSteps.Count; $i++) {
    Write-Host $LoadSteps[$i].Text -ForegroundColor $LoadSteps[$i].Color
    $pct = [math]::Round(($i + 1) / $LoadSteps.Count * 100)
    $bar = "#" * [math]::Floor($pct / 5)
    $empty = "-" * (20 - $bar.Length)
    Write-Host "        [$bar$empty] $pct%" -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 400
}

Write-Host ""
Write-Host "  Todo listo. Abriendo SHADOWIEX..." -ForegroundColor Green
Start-Sleep -Milliseconds 600
Write-Host ""

# ============================================================================
#  ELEVACION A ADMINISTRADOR
# ============================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ($scriptPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"irm n9.cl/shadowiex | iex`"" -Verb RunAs
    }
    exit
}

# ============================================================================
#  CARGAR ENSAMBLADOS
# ============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
#  TEMA SHADOWIEX - FORMAL DARK
# ============================================================================
$Global:Theme = @{
    BG           = [System.Drawing.Color]::FromArgb(20, 20, 25)
    Surface      = [System.Drawing.Color]::FromArgb(30, 30, 38)
    SurfaceLight = [System.Drawing.Color]::FromArgb(42, 42, 52)
    SurfaceHover = [System.Drawing.Color]::FromArgb(52, 52, 64)
    Primary      = [System.Drawing.Color]::FromArgb(100, 110, 140)
    PrimaryHover = [System.Drawing.Color]::FromArgb(120, 130, 160)
    Secondary    = [System.Drawing.Color]::FromArgb(80, 100, 120)
    Accent       = [System.Drawing.Color]::FromArgb(160, 130, 180)
    Success      = [System.Drawing.Color]::FromArgb(76, 140, 100)
    Warning      = [System.Drawing.Color]::FromArgb(170, 140, 70)
    Danger       = [System.Drawing.Color]::FromArgb(160, 80, 80)
    Info         = [System.Drawing.Color]::FromArgb(80, 120, 160)
    TextMain     = [System.Drawing.Color]::FromArgb(210, 215, 225)
    TextMuted    = [System.Drawing.Color]::FromArgb(130, 135, 150)
    TextDim      = [System.Drawing.Color]::FromArgb(90, 95, 110)
    Border       = [System.Drawing.Color]::FromArgb(50, 55, 65)
    Highlight    = [System.Drawing.Color]::FromArgb(180, 185, 200)
}

$Global:Fonts = @{
    Title   = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    Header  = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    Normal  = New-Object System.Drawing.Font("Segoe UI", 9)
    Small   = New-Object System.Drawing.Font("Segoe UI", 8)
    Button  = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    Mono    = New-Object System.Drawing.Font("Consolas", 9)
}

# ============================================================================
#  DIRECTORIOS Y UTILIDADES
# ============================================================================
$Global:ScriptDir = $null
try { $Global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path } catch {}
if (-not $Global:ScriptDir) { $Global:ScriptDir = (Get-Location).Path }

$Global:InstaladoresDir = Join-Path $Global:ScriptDir "instaladores"
$Global:LogFile = Join-Path $env:TEMP "SHADOWIEX_log.txt"

# Icono ICO embebido (extraido a TEMP al inicio)
$Global:IconPath = $null
$cachedIco = Join-Path $env:TEMP "SHADOWIEX_LOGO.ico"
$localIco = Join-Path $Global:ScriptDir "SHADOWIEX_LOGO.ico"
if (Test-Path $localIco) {
    $Global:IconPath = $localIco
} elseif (Test-Path $cachedIco) {
    $Global:IconPath = $cachedIco
} else {
    try {
        $icoBytes = [System.Convert]::FromBase64String("
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")
        [System.IO.File]::WriteAllBytes($cachedIco, $icoBytes)
        if (Test-Path $cachedIco) { $Global:IconPath = $cachedIco }
    } catch {}
}

# Logo PNG - descargar desde GitHub si no existe (cache en TEMP)
$Global:LogoPath = $null
$localLogo = Join-Path $Global:ScriptDir "SHADOWIEX_LOGO.png"
$cachedLogo = Join-Path $env:TEMP "SHADOWIEX_LOGO.png"
if (Test-Path $localLogo) {
    $Global:LogoPath = $localLogo
} elseif (Test-Path $cachedLogo) {
    $Global:LogoPath = $cachedLogo
} else {
    try {
        [Net.ServicePointManager]::SecurityProtocol = 3072
        (New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/WalterShadow2001/shadowiex/main/SHADOWIEX_LOGO.png", $cachedLogo)
        if (Test-Path $cachedLogo) { $Global:LogoPath = $cachedLogo }
    } catch {}
}


# Tooltip global
$Global:ToolTip = New-Object System.Windows.Forms.ToolTip
$Global:ToolTip.InitialDelay = 300
$Global:ToolTip.ReshowDelay = 100
$Global:ToolTip.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
$Global:ToolTip.ForeColor = [System.Drawing.Color]::FromArgb(210, 215, 225)
$Global:ToolTip.IsBalloon = $false

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$ts] $Message" | Out-File $Global:LogFile -Append
}

# ============================================================================
#  MAS - BUSQUEDA Y DESPLIEGUE
# ============================================================================
$Global:MAS_File = $null

function Find-MAS {
    if ($Global:MAS_File -and (Test-Path $Global:MAS_File)) { return $Global:MAS_File }
    $searchPaths = @()
    try {
        $sd = $Global:ScriptDir
        if ($sd) {
            $searchPaths += Join-Path $sd "MAS_AIO.cmd"
            $searchPaths += Join-Path $sd "Microsoft-Activation-Scripts-master\MAS\Separate-Files-Version\Activators\MAS_AIO.cmd"
        }
    } catch {}
    $searchPaths += ".\MAS_AIO.cmd"
    try { $searchPaths += Join-Path ([Environment]::GetFolderPath("Desktop")) "MAS_AIO.cmd" } catch {}
    $searchPaths += Join-Path $env:TEMP "SHADOWIEX_MAS.cmd"
    try { $searchPaths += Join-Path $env:USERPROFILE "Downloads\MAS_AIO.cmd" } catch {}
    foreach ($p in $searchPaths) {
        if ($p -and (Test-Path $p)) { $Global:MAS_File = $p; return $p }
    }
    return $null
}

function Deploy-MAS {
    $masPath = Find-MAS
    if ($masPath) { Update-Status "MAS encontrado: $(Split-Path $masPath -Leaf)" "success"; return $masPath }
    $R = [System.Windows.Forms.MessageBox]::Show(
        "No se encontro MAS_AIO.cmd`n`nDeseas descargarlo desde GitHub?`n(Requiere conexion a internet)",
        "SHADOWIEX", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($R -eq [System.Windows.Forms.MessageBoxButtons]::Yes) {
        Update-Status "Descargando MAS..."
        try {
            $url = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
            $dest = Join-Path $env:TEMP "SHADOWIEX_MAS.cmd"
            [Net.ServicePointManager]::SecurityProtocol = 3072
            (New-Object System.Net.WebClient).DownloadFile($url, $dest)
            $Global:MAS_File = $dest
            Update-Status "MAS descargado" "success"
            Write-Log "MAS descargado a $dest"
            return $dest
        } catch { Update-Status "Error descargando MAS" "error"; return $null }
    }
    return $null
}

function Invoke-MASInteractive { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`"" -Verb RunAs } }
function Invoke-MAS_HWID      { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /HWID" -Verb RunAs } }
function Invoke-MAS_TSforge   { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /Z-Windows" -Verb RunAs } }
function Invoke-MAS_Ohook     { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /Ohook" -Verb RunAs } }
function Invoke-MAS_KMS       { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /K-WindowsOffice" -Verb RunAs } }

function Invoke-MAS_iex {
    Update-Status "Ejecutando MAS via iex (online)..."
    try {
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"' -Verb RunAs
        Update-Status "MAS iex lanzado" "success"
    } catch { Update-Status "Error lanzando MAS iex" "error" }
}

# ============================================================================
#  COMPONENTES DE UI
# ============================================================================
function New-Btn {
    param(
        [string]$Text, [int]$X, [int]$Y, [int]$W = 200, [int]$H = 38,
        [string]$Color = "Primary", [scriptblock]$Action = $null,
        [string]$Tooltip = ""
    )
    $BtnColor = switch ($Color) {
        "Success"   { $Global:Theme.Success }
        "Danger"    { $Global:Theme.Danger }
        "Warning"   { $Global:Theme.Warning }
        "Secondary" { $Global:Theme.Secondary }
        "Accent"    { $Global:Theme.Accent }
        "Info"      { $Global:Theme.Info }
        "Highlight" { $Global:Theme.Highlight }
        default     { $Global:Theme.Primary }
    }
    $HoverColor = switch ($Color) {
        "Success"   { [System.Drawing.Color]::FromArgb(90, 160, 115) }
        "Danger"    { [System.Drawing.Color]::FromArgb(180, 100, 100) }
        "Warning"   { [System.Drawing.Color]::FromArgb(190, 160, 90) }
        default     { $Global:Theme.PrimaryHover }
    }
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = $Text
    $Btn.Location = New-Object System.Drawing.Point($X, $Y)
    $Btn.Size = New-Object System.Drawing.Size($W, $H)
    $Btn.BackColor = $BtnColor
    $Btn.ForeColor = [System.Drawing.Color]::White
    $Btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Btn.Font = $Global:Fonts.Button
    $Btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Btn.FlatAppearance.BorderSize = 0
    $Btn.FlatAppearance.MouseOverBackColor = $HoverColor
    if ($Tooltip -ne "") { $Global:ToolTip.SetToolTip($Btn, $Tooltip) }
    if ($Action) { $Btn.Add_Click($Action) }
    return $Btn
}

function New-Card {
    param([int]$X, [int]$Y, [int]$W = 240, [int]$H = 100)
    $Card = New-Object System.Windows.Forms.Panel
    $Card.Location = New-Object System.Drawing.Point($X, $Y)
    $Card.Size = New-Object System.Drawing.Size($W, $H)
    $Card.BackColor = $Global:Theme.Surface
    return $Card
}

function New-SectionTitle {
    param([string]$Text, [int]$X, [int]$Y, [int]$W = 400)
    $L = New-Object System.Windows.Forms.Label
    $L.Text = $Text
    $L.Location = New-Object System.Drawing.Point($X, $Y)
    $L.Size = New-Object System.Drawing.Size($W, 24)
    $L.Font = $Global:Fonts.Header
    $L.ForeColor = $Global:Theme.Highlight
    return $L
}

function New-DescLabel {
    param([string]$Text, [int]$X, [int]$Y, [int]$W = 220, [int]$H = 20)
    $L = New-Object System.Windows.Forms.Label
    $L.Text = $Text
    $L.Location = New-Object System.Drawing.Point($X, $Y)
    $L.Size = New-Object System.Drawing.Size($W, $H)
    $L.Font = $Global:Fonts.Small
    $L.ForeColor = $Global:Theme.TextMuted
    return $L
}

function Add-InfoRow {
    param(
        [System.Windows.Forms.Control]$Parent,
        [string]$Label, [string]$Value,
        [int]$X, [int]$Y,
        [int]$LabelW = 140, [int]$ValueW = 350,
        $ValueColor = $null
    )
    $Lbl = New-Object System.Windows.Forms.Label
    $Lbl.Text = $Label
    $Lbl.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $Lbl.Size = New-Object System.Drawing.Size($LabelW, 20)
    $Lbl.Font = $Global:Fonts.Normal
    $Lbl.ForeColor = $Global:Theme.TextMuted
    $Parent.Controls.Add($Lbl)

    $Val = New-Object System.Windows.Forms.Label
    $Val.Text = $Value
    $xPos = [int]$X + [int]$LabelW
    $Val.Location = New-Object System.Drawing.Point($xPos, [int]$Y)
    $Val.Size = New-Object System.Drawing.Size($ValueW, 20)
    $Val.Font = $Global:Fonts.Normal
    if ($ValueColor -ne $null -and $ValueColor -is [System.Drawing.Color]) {
        $Val.ForeColor = $ValueColor
    } else {
        $Val.ForeColor = $Global:Theme.TextMain
    }
    $Parent.Controls.Add($Val)
}

function Update-Status {
    param([string]$Text, [string]$Type = "info")
    $Color = switch ($Type) {
        "success" { $Global:Theme.Success }
        "error"   { $Global:Theme.Danger }
        "warning" { $Global:Theme.Warning }
        default   { $Global:Theme.TextMuted }
    }
    if ($Global:StatusLabel) {
        $Global:StatusLabel.Text = "  $Text"
        $Global:StatusLabel.ForeColor = $Color
    }
    [System.Windows.Forms.Application]::DoEvents()
}

function Test-Winget { try { $null = winget --version 2>$null; return $true } catch { return $false } }
function Test-Choco  { try { $null = choco --version 2>$null; return $true } catch { return $false } }

# ============================================================================
#  FORMULARIO PRINCIPAL
# ============================================================================
$Global:Form = New-Object System.Windows.Forms.Form
$Global:Form.Text = "SHADOWIEX v14.2"
$Global:Form.Size = New-Object System.Drawing.Size(1100, 750)
$Global:Form.StartPosition = "CenterScreen"
$Global:Form.BackColor = $Global:Theme.BG
$Global:Form.ForeColor = $Global:Theme.TextMain
$Global:Form.MinimumSize = New-Object System.Drawing.Size(950, 650)
try {
    if ($Global:IconPath -and (Test-Path $Global:IconPath)) {
        $Global:Form.Icon = New-Object System.Drawing.Icon($Global:IconPath)
    }
} catch {}

# ============================================================================
#  HEADER
# ============================================================================
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$HeaderPanel.Height = 60
$HeaderPanel.BackColor = $Global:Theme.Surface
$Global:Form.Controls.Add($HeaderPanel)

# Logo PNG in header
$LogoPB = New-Object System.Windows.Forms.PictureBox
$LogoPB.Location = New-Object System.Drawing.Point(15, 10)
$LogoPB.Size = New-Object System.Drawing.Size(40, 40)
$LogoPB.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$LogoPB.BackColor = [System.Drawing.Color]::Transparent
try {
    if ($Global:LogoPath -and (Test-Path $Global:LogoPath)) {
        $LogoPB.Image = New-Object System.Drawing.Bitmap($Global:LogoPath)
    }
} catch {}
$HeaderPanel.Controls.Add($LogoPB)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "SHADOWIEX"
$TitleLabel.Location = New-Object System.Drawing.Point(62, 12)
$TitleLabel.Size = New-Object System.Drawing.Size(180, 36)
$TitleLabel.Font = $Global:Fonts.Title
$TitleLabel.ForeColor = $Global:Theme.Highlight
$HeaderPanel.Controls.Add($TitleLabel)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v14.2 Professional"
$VersionLabel.Location = New-Object System.Drawing.Point(230, 25)
$VersionLabel.Size = New-Object System.Drawing.Size(130, 18)
$VersionLabel.Font = $Global:Fonts.Small
$VersionLabel.ForeColor = $Global:Theme.TextDim
$HeaderPanel.Controls.Add($VersionLabel)

$OSInfo = (Get-CimInstance Win32_OperatingSystem).Caption
$SysLabel = New-Object System.Windows.Forms.Label
$SysLabel.Text = $OSInfo
$SysLabel.Location = New-Object System.Drawing.Point(780, 10)
$SysLabel.Size = New-Object System.Drawing.Size(300, 18)
$SysLabel.Font = $Global:Fonts.Small
$SysLabel.ForeColor = $Global:Theme.TextDim
$SysLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($SysLabel)

$AdminLabel = New-Object System.Windows.Forms.Label
$AdminLabel.Text = "[ADMIN]"
$AdminLabel.Location = New-Object System.Drawing.Point(980, 30)
$AdminLabel.Size = New-Object System.Drawing.Size(100, 18)
$AdminLabel.Font = $Global:Fonts.Small
$AdminLabel.ForeColor = $Global:Theme.Success
$AdminLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($AdminLabel)

$AccentLine = New-Object System.Windows.Forms.Panel
$AccentLine.Dock = [System.Windows.Forms.DockStyle]::Bottom
$AccentLine.Height = 1
$AccentLine.BackColor = $Global:Theme.Border
$HeaderPanel.Controls.Add($AccentLine)

# ============================================================================
#  PANEL DE PESTANAS
# ============================================================================
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(0, 60)
$TabControl.Size = New-Object System.Drawing.Size(1100, 640)
$TabControl.BackColor = $Global:Theme.BG
$TabControl.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
$TabControl.ItemSize = New-Object System.Drawing.Size(110, 30)
$TabControl.Font = $Global:Fonts.Button
$TabControl.Padding = New-Object System.Drawing.Point(8, 2)

$TabDiag    = New-Object System.Windows.Forms.TabPage; $TabDiag.Text = "DIAGNOSTICO";  $TabDiag.BackColor = $Global:Theme.BG; $TabDiag.Padding = New-Object System.Windows.Forms.Padding(15)
$TabRepair  = New-Object System.Windows.Forms.TabPage; $TabRepair.Text = "REPARAR";     $TabRepair.BackColor = $Global:Theme.BG; $TabRepair.Padding = New-Object System.Windows.Forms.Padding(15)
$TabInstall = New-Object System.Windows.Forms.TabPage; $TabInstall.Text = "INSTALAR";    $TabInstall.BackColor = $Global:Theme.BG; $TabInstall.Padding = New-Object System.Windows.Forms.Padding(15)
$TabAct     = New-Object System.Windows.Forms.TabPage; $TabAct.Text = "ACTIVAR";      $TabAct.BackColor = $Global:Theme.BG; $TabAct.Padding = New-Object System.Windows.Forms.Padding(15)
$TabTweaks  = New-Object System.Windows.Forms.TabPage; $TabTweaks.Text = "OPTIMIZAR";   $TabTweaks.BackColor = $Global:Theme.BG; $TabTweaks.Padding = New-Object System.Windows.Forms.Padding(15)
$TabConfig  = New-Object System.Windows.Forms.TabPage; $TabConfig.Text = "CONFIG";       $TabConfig.BackColor = $Global:Theme.BG; $TabConfig.Padding = New-Object System.Windows.Forms.Padding(15)

$TabControl.Controls.AddRange(@($TabDiag, $TabRepair, $TabInstall, $TabAct, $TabTweaks, $TabConfig))
$Global:Form.Controls.Add($TabControl)

# ============================================================================
#  DIAGNOSTICO TAB
# ============================================================================
$DiagScroll = New-Object System.Windows.Forms.Panel
$DiagScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$DiagScroll.AutoScroll = $true
$DiagScroll.BackColor = $Global:Theme.BG
$TabDiag.Controls.Add($DiagScroll)

$btnFullDiag = New-Btn -Text "ESCANEO COMPLETO" -X 15 -Y 10 -W 200 -H 38 -Color "Success"
$btnFullDiag.Add_Click({
    Update-Status "Ejecutando diagnostico completo..."
    $outputBox = $Global:DiagOutputBox
    $outputBox.Text = ""
    $outputBox.Text += "=== SHADOWIEX DIAGNOSTICO COMPLETO ===`r`n"
    $outputBox.Text += "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"
    $outputBox.Text += "=" * 50 + "`r`n`r`n"

    # OS
    $outputBox.Text += "[SISTEMA OPERATIVO]`r`n"
    $OS = Get-CimInstance Win32_OperatingSystem
    $outputBox.Text += "  SO:              $($OS.Caption)`r`n"
    $outputBox.Text += "  Version:         $($OS.Version)`r`n"
    $outputBox.Text += "  Build:           $($OS.BuildNumber)`r`n"
    $outputBox.Text += "  Arquitectura:    $($OS.OSArchitecture)`r`n"
    $outputBox.Text += "  Instalado:       $($OS.InstallDate)`r`n"
    $outputBox.Text += "  Ultimo arranque: $($OS.LastBootUpTime)`r`n`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # CPU
    $outputBox.Text += "[PROCESADOR]`r`n"
    $CPU = Get-CimInstance Win32_Processor
    $outputBox.Text += "  Nombre:          $($CPU.Name)`r`n"
    $outputBox.Text += "  Nucleos:         $($CPU.NumberOfCores) / Hilos: $($CPU.NumberOfLogicalProcessors)`r`n"
    $outputBox.Text += "  Frecuencia max:  $($CPU.MaxClockSpeed) MHz`r`n"
    $cpuLoad = "N/A"
    try { $cpuLoad = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time' -EA Stop).CounterSamples.CookedValue, 1).ToString() + "%" } catch { $cpuLoad = "No disponible" }
    $outputBox.Text += "  Carga actual:    $cpuLoad`r`n`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # RAM
    $outputBox.Text += "[MEMORIA RAM]`r`n"
    $RAMTotal = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
    $OSRAM = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $RAMFree = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
    $RAMUsed = [math]::Round($OSRAM - $RAMFree, 2)
    $RAMpct = [math]::Round($RAMUsed / $OSRAM * 100, 1)
    $outputBox.Text += "  RAM fisica:      $RAMTotal GB`r`n"
    $outputBox.Text += "  RAM visible:     $OSRAM GB`r`n"
    $outputBox.Text += "  RAM usada:       $RAMUsed GB ($RAMpct%)`r`n"
    $outputBox.Text += "  RAM libre:       $RAMFree GB`r`n`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # GPU
    $outputBox.Text += "[TARJETA GRAFICA]`r`n"
    $GPUs = Get-CimInstance Win32_VideoController
    foreach ($GPU in $GPUs) {
        $vram = try { [math]::Round($GPU.AdapterRAM / 1GB, 2) } catch { "N/A" }
        $outputBox.Text += "  GPU:             $($GPU.Name)`r`n"
        $outputBox.Text += "  VRAM:            $vram GB`r`n"
        $outputBox.Text += "  Resolucion:      $($GPU.CurrentHorizontalResolution)x$($GPU.CurrentVerticalResolution)`r`n"
        $outputBox.Text += "  Driver:          $($GPU.DriverVersion)`r`n"
    }
    $outputBox.Text += "`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # Discos
    $outputBox.Text += "[DISCOS]`r`n"
    $Disks = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($D in $Disks) {
        $Total = [math]::Round($D.Size / 1GB, 2)
        $Free = [math]::Round($D.FreeSpace / 1GB, 2)
        $Used = [math]::Round(($D.Size - $D.FreeSpace) / 1GB, 2)
        $Pct = [math]::Round(($D.Size - $D.FreeSpace) / $D.Size * 100, 1)
        $outputBox.Text += "  Unidad $($D.DeviceID) - $($D.VolumeName)`r`n"
        $outputBox.Text += "    Total: $Total GB | Usado: $Used GB ($Pct%) | Libre: $Free GB`r`n"
    }
    $outputBox.Text += "`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # Red
    $outputBox.Text += "[RED]`r`n"
    try {
        $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($A in $Adapters) {
            $IP = try { (Get-NetIPAddress -InterfaceIndex $A.ifIndex -AddressFamily IPv4 -EA 0).IPAddress } catch { "N/A" }
            $outputBox.Text += "  Adaptador:       $($A.Name)`r`n"
            $outputBox.Text += "  Velocidad:       $($A.LinkSpeed)`r`n"
            $outputBox.Text += "  IP:              $IP`r`n"
        }
    } catch { $outputBox.Text += "  Error obteniendo info de red`r`n" }
    [System.Windows.Forms.Application]::DoEvents()

    # Windows Update
    $outputBox.Text += "`r`n[WINDOWS UPDATE]`r`n"
    try {
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Searcher = $Session.CreateUpdateSearcher()
        $Result = $Searcher.Search("IsInstalled=0 and Type='Software'")
        $outputBox.Text += "  Actualizaciones pendientes: $($Result.Updates.Count)`r`n"
        if ($Result.Updates.Count -gt 0) {
            foreach ($U in $Result.Updates) {
                $outputBox.Text += "    - $($U.Title)`r`n"
            }
        }
    } catch { $outputBox.Text += "  No se pudo verificar Windows Update`r`n" }
    [System.Windows.Forms.Application]::DoEvents()

    # Activacion
    $outputBox.Text += "`r`n[ESTADO DE ACTIVACION]`r`n"
    try {
        $products = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey }
        foreach ($p in $products) {
            $status = switch ($p.LicenseStatus) { 0 {"Sin activar"} 1 {"Activado"} 2 {"Periodo de gracia"} default {"Desconocido"} }
            $outputBox.Text += "  Producto:  $($p.Name)`r`n  Estado:    $status`r`n`r`n"
        }
    } catch { $outputBox.Text += "  No se pudo verificar`r`n" }
    [System.Windows.Forms.Application]::DoEvents()

    # Startup
    $outputBox.Text += "[PROGRAMAS DE INICIO]`r`n"
    $Startups = Get-CimInstance Win32_StartupCommand
    foreach ($S in $Startups) { $outputBox.Text += "  $($S.Name)`r`n" }
    $outputBox.Text += "`r`n"

    # Event log
    $outputBox.Text += "[ERRORES RECIENTES (ultimos 10)]`r`n"
    try {
        $Errors = Get-EventLog -LogName System -EntryType Error -Newest 10 -EA 0
        foreach ($E in $Errors) {
            $msg = $E.Message
            if ($msg.Length -gt 80) { $msg = $msg.Substring(0, 80) + "..." }
            $outputBox.Text += "  [$($E.TimeGenerated)] $($E.Source): $msg`r`n"
        }
    } catch { $outputBox.Text += "  No se pudo leer el log`r`n" }

    $outputBox.Text += "`r`n" + "=" * 50 + "`r`nDiagnostico completado`r`n"
    Update-Status "Diagnostico completado" "success"
    Write-Log "Diagnostico completo ejecutado"
})
$DiagScroll.Controls.Add($btnFullDiag)

$btnCopyDiag = New-Btn -Text "COPIAR RESULTADO" -X 225 -Y 10 -W 160 -H 38 -Color "Secondary"
$btnCopyDiag.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($Global:DiagOutputBox.Text)
    Update-Status "Resultado copiado al portapapeles" "success"
})
$DiagScroll.Controls.Add($btnCopyDiag)

# Quick info cards
$DiagY = 65
$cardW = 248; $cardH = 70; $cardGap = 8

# CPU Card
$CardCPU = New-Card -X 15 -Y $DiagY -W $cardW -H $cardH
$DiagScroll.Controls.Add($CardCPU)
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "CPU"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(50, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
$CPUName = try { (Get-CimInstance Win32_Processor).Name } catch { "N/A" }
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = $CPUName; Location = New-Object System.Drawing.Point(10, 25); Size = New-Object System.Drawing.Size(228, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
$cpuCores = try { "$((Get-CimInstance Win32_Processor).NumberOfCores)C / $((Get-CimInstance Win32_Processor).NumberOfLogicalProcessors)T" } catch { "N/A" }
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = $cpuCores; Location = New-Object System.Drawing.Point(10, 43); Size = New-Object System.Drawing.Size(228, 16); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim}))

# RAM Card
$CardRAM = New-Card -X (15 + $cardW + $cardGap) -Y $DiagY -W $cardW -H $cardH
$DiagScroll.Controls.Add($CardRAM)
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "RAM"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(50, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
$TotalRAM = try { [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1) } catch { 0 }
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Total: $TotalRAM GB"; Location = New-Object System.Drawing.Point(10, 25); Size = New-Object System.Drawing.Size(228, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
$FreeRAM = try { [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1) } catch { 0 }
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Libre: $FreeRAM GB"; Location = New-Object System.Drawing.Point(10, 43); Size = New-Object System.Drawing.Size(228, 16); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim}))

# Disk Card
$CardDisk = New-Card -X (15 + ($cardW + $cardGap) * 2) -Y $DiagY -W $cardW -H $cardH
$DiagScroll.Controls.Add($CardDisk)
$CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "DISCO PRINCIPAL"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(130, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
$DiskC = try { Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" } } catch { $null }
if ($DiskC) {
    $DiskTotal = [math]::Round($DiskC.Size / 1GB, 1)
    $DiskFree = [math]::Round($DiskC.FreeSpace / 1GB, 1)
    $DiskPct = [math]::Round(($DiskC.Size - $DiskC.FreeSpace) / $DiskC.Size * 100, 1)
    $CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Total: $DiskTotal GB | Usado: $DiskPct%"; Location = New-Object System.Drawing.Point(10, 25); Size = New-Object System.Drawing.Size(228, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
    $CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Libre: $DiskFree GB"; Location = New-Object System.Drawing.Point(10, 43); Size = New-Object System.Drawing.Size(228, 16); Font = $Global:Fonts.Small; ForeColor = if($DiskPct -gt 85){$Global:Theme.Danger}else{$Global:Theme.TextDim}}))
}

# Network Card
$CardNet = New-Card -X (15 + ($cardW + $cardGap) * 3) -Y $DiagY -W $cardW -H $cardH
$DiagScroll.Controls.Add($CardNet)
$CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "RED"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(50, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
try {
    $NetAdapt = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Adaptador: $($NetAdapt.Name)"; Location = New-Object System.Drawing.Point(10, 25); Size = New-Object System.Drawing.Size(228, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Velocidad: $($NetAdapt.LinkSpeed)"; Location = New-Object System.Drawing.Point(10, 43); Size = New-Object System.Drawing.Size(228, 16); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim}))
} catch {
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Sin adaptador activo"; Location = New-Object System.Drawing.Point(10, 25); Size = New-Object System.Drawing.Size(228, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
}

# Output box
$DiagY2 = 155
$DiagScroll.Controls.Add((New-SectionTitle -Text "RESULTADO DEL DIAGNOSTICO" -X 15 -Y $DiagY2))
$Global:DiagOutputBox = New-Object System.Windows.Forms.TextBox
$Global:DiagOutputBox.Multiline = $true
$Global:DiagOutputBox.ReadOnly = $true
$Global:DiagOutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$Global:DiagOutputBox.Location = New-Object System.Drawing.Point(15, ($DiagY2 + 28))
$Global:DiagOutputBox.Size = New-Object System.Drawing.Size(1050, 380)
$Global:DiagOutputBox.BackColor = $Global:Theme.Surface
$Global:DiagOutputBox.ForeColor = $Global:Theme.TextMuted
$Global:DiagOutputBox.Font = $Global:Fonts.Mono
$Global:DiagOutputBox.Text = "Presiona 'ESCANEO COMPLETO' para iniciar el diagnostico del sistema."
$DiagScroll.Controls.Add($Global:DiagOutputBox)

# ============================================================================
#  REPARAR TAB
# ============================================================================
$RepairScroll = New-Object System.Windows.Forms.Panel
$RepairScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$RepairScroll.AutoScroll = $true
$RepairScroll.BackColor = $Global:Theme.BG
$TabRepair.Controls.Add($RepairScroll)

$RepairScroll.Controls.Add((New-SectionTitle -Text "HERRAMIENTAS DE REPARACION" -X 15 -Y 10))

$RepairTools = @(
    @{Name="SFC /SCANNOW"; Desc="Verifica y repara archivos de sistema"; Color="Success"; Action={
        Update-Status "Ejecutando SFC /scannow..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''SFC /scannow - Esto puede tardar varios minutos...'' -ForegroundColor Cyan; sfc /scannow; Write-Host ''`nPresiona Enter para cerrar...'' -ForegroundColor Yellow; Read-Host"' -Verb RunAs
        Update-Status "SFC /scannow iniciado" "success"; Write-Log "SFC /scannow ejecutado"
    }},
    @{Name="DISM RESTOREHEALTH"; Desc="Repara imagen de Windows"; Color="Success"; Action={
        Update-Status "Ejecutando DISM RestoreHealth..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''DISM /Online /Cleanup-Image /RestoreHealth...'' -ForegroundColor Cyan; DISM /Online /Cleanup-Image /RestoreHealth; Write-Host ''`nPresiona Enter...'' -ForegroundColor Yellow; Read-Host"' -Verb RunAs
        Update-Status "DISM iniciado" "success"; Write-Log "DISM RestoreHealth ejecutado"
    }},
    @{Name="CHECK DISK (C:)"; Desc="Verifica errores en disco C:"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Se requiere reinicio para chkdsk.`nContinuar?", "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) { Update-Status "Programando chkdsk..."; Start-Process cmd.exe -ArgumentList '/c echo y | chkdsk C: /f /r' -Verb RunAs; Write-Log "CHKDSK programado" }
    }},
    @{Name="REPARAR STORE"; Desc="Re-registra Microsoft Store"; Color="Info"; Action={
        Update-Status "Reparando Windows Store..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\"}; Write-Host ''Listo. Presiona Enter...'' -ForegroundColor Green; Read-Host"' -Verb RunAs
        Update-Status "Store reparada" "success"; Write-Log "Windows Store reparada"
    }},
    @{Name="REPARAR WIN UPDATE"; Desc="Resetea componentes de Windows Update"; Color="Info"; Action={
        Update-Status "Reparando Windows Update..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "net stop wuauserv; net stop bits; ren %systemroot%\SoftwareDistribution SoftwareDistribution.bak; ren %systemroot%\system32\catroot2 catroot2.bak; net start wuauserv; net start bits; Write-Host ''Windows Update reparado. Presiona Enter...'' -ForegroundColor Green; Read-Host"' -Verb RunAs
        Update-Status "Windows Update reparado" "success"; Write-Log "Windows Update reparado"
    }},
    @{Name="RESETEAR RED"; Desc="Resetea TCP/IP, Winsock y DNS"; Color="Secondary"; Action={
        Update-Status "Reseteando red..."
        try { netsh int ip reset 2>&1 | Out-Null; netsh winsock reset 2>&1 | Out-Null; ipconfig /flushdns 2>&1 | Out-Null
            Update-Status "Red reseteada - reinicia para aplicar" "success"; Write-Log "Red reseteada" }
        catch { Update-Status "Error reseteando red" "error" }
    }},
    @{Name="REPARAR ARRANQUE"; Desc="Repara registro de arranque BCD"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Reparar registro de arranque (BCD)?", "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) { Update-Status "Reparando arranque..."; Start-Process cmd.exe -ArgumentList '/c bootrec /fixmbr && bootrec /fixboot && bootrec /scanos && bootrec /rebuildbcd && pause' -Verb RunAs; Write-Log "Reparacion de arranque" }
    }},
    @{Name="LIMPIAR TEMPORALES"; Desc="Elimina archivos temporales"; Color="Secondary"; Action={
        Update-Status "Limpiando temporales..."
        try { $before = (Get-PSDrive C).Used; Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0; Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            $after = (Get-PSDrive C).Used; $freed = [math]::Round(($before - $after) / 1MB, 1)
            Update-Status "Temporales limpiados (~$freed MB)" "success"; Write-Log "Temporales: $freed MB" }
        catch { Update-Status "Error" "error" }
    }},
    @{Name="LIMPIAR DNS"; Desc="Limpia cache de resolucion DNS"; Color="Secondary"; Action={
        Update-Status "Limpiando DNS..."; ipconfig /flushdns 2>&1 | Out-Null; Update-Status "DNS limpiada" "success"; Write-Log "DNS limpiada"
    }},
    @{Name="REPARAR ICONOS"; Desc="Reconstruye cache de iconos"; Color="Info"; Action={
        Update-Status "Reparando iconos..."
        try { Stop-Process -Name explorer -Force -EA 0; Start-Sleep -Seconds 2; Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -EA 0; Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -EA 0; Start-Process explorer.exe; Update-Status "Iconos reconstruidos" "success"; Write-Log "Iconos reparados" }
        catch { Update-Status "Error" "error" }
    }},
    @{Name="VERIFICAR DRIVERS"; Desc="Busca drivers con problemas"; Color="Info"; Action={
        Update-Status "Verificando drivers..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -Command "Get-WindowsDriver -Online | Where-Object {$_.Status -ne ''OK''} | Format-Table Driver, ProviderName, Date, Version, Status -AutoSize; Write-Host ''Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "Verificacion de drivers iniciada" "success"; Write-Log "Verificacion drivers"
    }},
    @{Name="COMPONENT STORE"; Desc="Limpia y analiza Component Store"; Color="Warning"; Action={
        Update-Status "Ejecutando DISM Component Store..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -Command "DISM /Online /Cleanup-Image /StartComponentCleanup; DISM /Online /Cleanup-Image /AnalyzeComponentStore; Write-Host ''Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "Component Store iniciado" "success"; Write-Log "DISM Component Store"
    }}
)

$RY = 40; $RX = 15; $RCol = 0
foreach ($Tool in $RepairTools) {
    $Card = New-Card -X $RX -Y $RY -W 248 -H 90
    $RepairScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $Tool.Name -X 10 -Y 10 -W 228 -H 36 -Color $Tool.Color
    $CurrAct = $Tool.Action
    $Btn.Add_Click({ & $CurrAct }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $Tool.Desc -X 10 -Y 55 -W 228 -H 18))
    $RCol++
    if ($RCol -ge 4) { $RCol = 0; $RX = 15; $RY += 98 } else { $RX += 256 }
}

# ============================================================================
#  INSTALAR TAB
# ============================================================================
$InstallLeftPanel = New-Object System.Windows.Forms.Panel
$InstallLeftPanel.Location = New-Object System.Drawing.Point(0, 0)
$InstallLeftPanel.Size = New-Object System.Drawing.Size(560, 580)
$InstallLeftPanel.AutoScroll = $true
$InstallLeftPanel.BackColor = $Global:Theme.BG
$TabInstall.Controls.Add($InstallLeftPanel)

$InstallLeftPanel.Controls.Add((New-SectionTitle -Text "INSTALAR APLICACIONES (WINGET / CHOCO)" -X 10 -Y 5))

$SoftwareData = @{
    "NAVEGADORES" = @(
        @{ID="Google.Chrome"; Name="Google Chrome"},
        @{ID="Mozilla.Firefox"; Name="Mozilla Firefox"},
        @{ID="Opera.Opera"; Name="Opera GX"},
        @{ID="Microsoft.Edge"; Name="Microsoft Edge"},
        @{ID="BraveSoftware.BraveBrowser"; Name="Brave"}
    )
    "DESARROLLO" = @(
        @{ID="Git.Git"; Name="Git"},
        @{ID="GitHub.GitHubDesktop"; Name="GitHub Desktop"},
        @{ID="Microsoft.VisualStudioCode"; Name="VS Code"},
        @{ID="Notepad++.Notepad++"; Name="Notepad++"},
        @{ID="Python.Python.3.12"; Name="Python 3.12"}
    )
    "MULTIMEDIA" = @(
        @{ID="VideoLAN.VLC"; Name="VLC"},
        @{ID="GIMP.GIMP"; Name="GIMP"},
        @{ID="Spotify.Spotify"; Name="Spotify"},
        @{ID="OBSProject.OBSStudio"; Name="OBS Studio"}
    )
    "COMUNICACION" = @(
        @{ID="Discord.Discord"; Name="Discord"},
        @{ID="Telegram.TelegramDesktop"; Name="Telegram"},
        @{ID="WhatsApp.WhatsApp"; Name="WhatsApp"},
        @{ID="Zoom.Zoom"; Name="Zoom"}
    )
    "UTILIDADES" = @(
        @{ID="7zip.7zip"; Name="7-Zip"},
        @{ID="RARLab.WinRAR"; Name="WinRAR"},
        @{ID="Microsoft.PowerToys"; Name="PowerToys"},
        @{ID="voidtools.Everything"; Name="Everything"}
    )
    "OFIMATICA" = @(
        @{ID="LibreOffice.LibreOffice"; Name="LibreOffice"},
        @{ID="PDF24.PDF24Creator"; Name="PDF24 Creator"},
        @{ID="SumatraPDF.SumatraPDF"; Name="Sumatra PDF"}
    )
    "SEGURIDAD" = @(
        @{ID="Malwarebytes.Malwarebytes"; Name="Malwarebytes"}
    )
    "RUNTIMES" = @(
        @{ID="Microsoft.VCRedist.2015+.x64"; Name="VC++ x64"},
        @{ID="Microsoft.VCRedist.2015+.x86"; Name="VC++ x86"},
        @{ID="Microsoft.DotNet.DesktopRuntime.8"; Name=".NET 8"}
    )
}

$Global:AllCheckboxes = @()
$YPos = 30

foreach ($Cat in $SoftwareData.Keys) {
    $CatPanel = New-Object System.Windows.Forms.Panel
    $CatPanel.Location = New-Object System.Drawing.Point(5, $YPos)
    $CatPanel.Size = New-Object System.Drawing.Size(530, 24)
    $CatPanel.BackColor = $Global:Theme.Surface
    $InstallLeftPanel.Controls.Add($CatPanel)
    $CatLabel = New-Object System.Windows.Forms.Label
    $CatLabel.Text = "  $Cat"
    $CatLabel.Location = New-Object System.Drawing.Point(2, 2)
    $CatLabel.Size = New-Object System.Drawing.Size(300, 20)
    $CatLabel.Font = $Global:Fonts.Header
    $CatLabel.ForeColor = $Global:Theme.TextDim
    $CatPanel.Controls.Add($CatLabel)

    $YPos += 26
    $XPos = 15
    foreach ($App in $SoftwareData[$Cat]) {
        $CB = New-Object System.Windows.Forms.CheckBox
        $CB.Text = $App.Name
        $CB.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CB.Size = New-Object System.Drawing.Size(165, 22)
        $CB.Font = $Global:Fonts.Normal
        $CB.ForeColor = $Global:Theme.TextMain
        $CB.BackColor = $Global:Theme.BG
        $CB.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $CB.Tag = $App.ID
        $CB.Add_CheckedChanged({
            $Count = ($Global:AllCheckboxes | Where-Object { $_.Checked }).Count
            $Global:CountLabel.Text = "$Count seleccionados"
        })
        $InstallLeftPanel.Controls.Add($CB)
        $Global:AllCheckboxes += $CB
        $XPos += 170
        if ($XPos -gt 500) { $XPos = 15; $YPos += 24 }
    }
    $YPos += 32
}

# --- Panel derecho ---
$InstallRightPanel = New-Object System.Windows.Forms.Panel
$InstallRightPanel.Location = New-Object System.Drawing.Point(565, 0)
$InstallRightPanel.Size = New-Object System.Drawing.Size(510, 580)
$InstallRightPanel.AutoScroll = $true
$InstallRightPanel.BackColor = $Global:Theme.Surface
$TabInstall.Controls.Add($InstallRightPanel)

$InstallRightPanel.Controls.Add((New-SectionTitle -Text "ACCIONES" -X 15 -Y 10 -W 200))

$Global:CountLabel = New-Object System.Windows.Forms.Label
$Global:CountLabel.Text = "0 seleccionados"
$Global:CountLabel.Location = New-Object System.Drawing.Point(15, 36)
$Global:CountLabel.Size = New-Object System.Drawing.Size(200, 20)
$Global:CountLabel.Font = $Global:Fonts.Normal
$Global:CountLabel.ForeColor = $Global:Theme.TextMuted
$InstallRightPanel.Controls.Add($Global:CountLabel)

$Global:AllChecked = $false
$ToggleBtn = New-Btn -Text "SELECCIONAR TODO" -X 15 -Y 62 -W 200 -H 34 -Color "Secondary"
$ToggleBtn.Add_Click({
    $Global:AllChecked = -not $Global:AllChecked
    $ToggleBtn.Text = if ($Global:AllChecked) { "QUITAR TODO" } else { "SELECCIONAR TODO" }
    foreach ($CB in $Global:AllCheckboxes) { $CB.Checked = $Global:AllChecked }
})
$InstallRightPanel.Controls.Add($ToggleBtn)

$InstallBtn = New-Btn -Text "INSTALAR SELECCIONADOS" -X 15 -Y 106 -W 200 -H 38 -Color "Success"
$InstallBtn.Add_Click({
    $Selected = $Global:AllCheckboxes | Where-Object { $_.Checked }
    if ($Selected.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Selecciona al menos un programa.", "SHADOWIEX"); return }
    $HasWinget = Test-Winget; $HasChoco = Test-Choco
    if (-not $HasWinget -and -not $HasChoco) {
        $R = [System.Windows.Forms.MessageBox]::Show("No se encontro winget ni chocolatey.`nInstalar Chocolatey?", "SHADOWIEX", 4)
        if ($R -ne 6) { return }
        Update-Status "Instalando Chocolatey..."
        try { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); $HasChoco = $true; Update-Status "Chocolatey instalado" "success" } catch { Update-Status "Error instalando Chocolatey" "error"; return }
    }

    # Progress dialog con tema dark
    $ProgF = New-Object System.Windows.Forms.Form
    $ProgF.Text = "SHADOWIEX - Instalando"
    $ProgF.Size = New-Object System.Drawing.Size(520, 185)
    $ProgF.BackColor = $Global:Theme.BG
    $ProgF.StartPosition = "CenterParent"
    $ProgF.FormBorderStyle = "FixedDialog"
    $ProgF.ControlBox = $false
    $ProgF.TopMost = $true

    # Header line
    $ProgF.Controls.Add((New-Object System.Windows.Forms.Panel -Property @{
        Location = New-Object System.Drawing.Point(20, 10)
        Size     = New-Object System.Drawing.Size(480, 1)
        BackColor = $Global:Theme.Border
    }))

    # Title label
    $ProgTitle = New-Object System.Windows.Forms.Label
    $ProgTitle.Text = "Instalacion en progreso"
    $ProgTitle.Location = New-Object System.Drawing.Point(20, 18)
    $ProgTitle.Size = New-Object System.Drawing.Size(480, 22)
    $ProgTitle.Font = $Global:Fonts.Header
    $ProgTitle.ForeColor = $Global:Theme.Highlight
    $ProgF.Controls.Add($ProgTitle)

    # Current app label
    $ProgL = New-Object System.Windows.Forms.Label
    $ProgL.Text = "Iniciando instalacion..."
    $ProgL.Location = New-Object System.Drawing.Point(20, 46)
    $ProgL.Size = New-Object System.Drawing.Size(480, 20)
    $ProgL.Font = $Global:Fonts.Normal
    $ProgL.ForeColor = $Global:Theme.TextMain
    $ProgF.Controls.Add($ProgL)

    # Custom progress bar (Panel-based, works on dark theme)
    $ProgTrack = New-Object System.Windows.Forms.Panel
    $ProgTrack.Location = New-Object System.Drawing.Point(20, 72)
    $ProgTrack.Size = New-Object System.Drawing.Size(400, 18)
    $ProgTrack.BackColor = $Global:Theme.Surface
    $ProgF.Controls.Add($ProgTrack)

    $ProgFill = New-Object System.Windows.Forms.Panel
    $ProgFill.Location = New-Object System.Drawing.Point(0, 0)
    $ProgFill.Size = New-Object System.Drawing.Size(0, 18)
    $ProgFill.BackColor = $Global:Theme.Primary
    $ProgTrack.Controls.Add($ProgFill)

    # Progress counter label (right of bar)
    $ProgCount = New-Object System.Windows.Forms.Label
    $ProgCount.Text = "0 / $($Selected.Count)"
    $ProgCount.Location = New-Object System.Drawing.Point(428, 72)
    $ProgCount.Size = New-Object System.Drawing.Size(70, 18)
    $ProgCount.Font = $Global:Fonts.Small
    $ProgCount.ForeColor = $Global:Theme.TextMuted
    $ProgCount.TextAlign = "MiddleRight"
    $ProgF.Controls.Add($ProgCount)

    # Detail label
    $ProgDetail = New-Object System.Windows.Forms.Label
    $ProgDetail.Text = ""
    $ProgDetail.Location = New-Object System.Drawing.Point(20, 96)
    $ProgDetail.Size = New-Object System.Drawing.Size(400, 18)
    $ProgDetail.Font = $Global:Fonts.Small
    $ProgDetail.ForeColor = $Global:Theme.TextMuted
    $ProgF.Controls.Add($ProgDetail)

    # Separator line
    $ProgF.Controls.Add((New-Object System.Windows.Forms.Panel -Property @{
        Location = New-Object System.Drawing.Point(20, 122)
        Size     = New-Object System.Drawing.Size(480, 1)
        BackColor = $Global:Theme.Border
    }))

    # Cancel button (bottom-right, properly inside window)
    $CancelBtn = New-Btn -Text "CANCELAR" -X 400 -Y 132 -W 100 -H 32 -Color "Danger"
    $CancelBtn.Add_Click({ $Global:Cancelled = $true; $ProgF.Close() })
    $ProgF.Controls.Add($CancelBtn)
    $ProgF.Show()

    $Global:Cancelled = $false; $Step = 0; $OK = 0; $Fail = 0
    $TrackWidth = 400
    foreach ($CB in $Selected) {
        if ($Global:Cancelled) { break }
        $Step++; $AppID = $CB.Tag; $AppName = $CB.Text
        $ProgL.Text = "[$Step/$($Selected.Count)] $AppName"
        $ProgCount.Text = "$Step / $($Selected.Count)"
        # Animate progress fill
        $fillW = [math]::Max(0, [math]::Floor($Step / $Selected.Count * $TrackWidth))
        $ProgFill.Size = New-Object System.Drawing.Size($fillW, 18)
        $ProgDetail.Text = "Buscando via winget..."
        [System.Windows.Forms.Application]::DoEvents()
        $Installed = $false
        if ($HasWinget) {
            try { $Proc = Start-Process "winget" -ArgumentList "install","--id",$AppID,"--accept-source-agreements","--accept-package-agreements","-h" -NoNewWindow -PassThru -Wait -EA 0; if ($Proc.ExitCode -eq 0) { $Installed = $true } } catch {}
        }
        if (-not $Installed -and $HasChoco) {
            $ProgDetail.Text = "Intentando via chocolatey..."
            [System.Windows.Forms.Application]::DoEvents()
            try { $ChocoID = ($AppID -replace '\.','').ToLower(); $Proc = Start-Process "choco" -ArgumentList "install",$ChocoID,"-y","--force" -NoNewWindow -PassThru -Wait -EA 0; if ($Proc.ExitCode -eq 0) { $Installed = $true } } catch {}
        }
        if ($Installed) {
            $ProgDetail.Text = "Completado"; $ProgDetail.ForeColor = $Global:Theme.Success; $OK++
        } else {
            $ProgDetail.Text = "No encontrado - verifica manualmente"; $ProgDetail.ForeColor = $Global:Theme.Warning; $Fail++
        }
    }
    # Final fill
    $ProgFill.Size = New-Object System.Drawing.Size($TrackWidth, 18)
    $ProgFill.BackColor = $Global:Theme.Success
    $ProgF.Close()
    if ($Global:Cancelled) { Update-Status "Instalacion cancelada" "warning" }
    else { Update-Status "Completado: $OK OK, $Fail fallidos" "success"; [System.Windows.Forms.MessageBox]::Show("Instalacion completada`n`nExitosos: $OK`nFallidos: $Fail", "SHADOWIEX") }
    Write-Log "Instalacion: $OK OK, $Fail fallidos"
})
$InstallRightPanel.Controls.Add($InstallBtn)

# --- INSTALADORES LOCALES ---
$InstY = 165
$InstallRightPanel.Controls.Add((New-SectionTitle -Text "INSTALADORES LOCALES" -X 15 -Y $InstY -W 300))
$InstY += 28

$InstDesc = New-DescLabel -Text "Archivos .exe de la carpeta 'instaladores'" -X 15 -Y $InstY -W 460
$InstallRightPanel.Controls.Add($InstDesc)
$InstY += 24

$Global:InstaladoresExes = @()
if (Test-Path $Global:InstaladoresDir) {
    $Exes = Get-ChildItem -Path $Global:InstaladoresDir -Filter "*.exe" -EA 0 | Sort-Object Name
    if ($Exes) {
        foreach ($Exe in $Exes) {
            $Global:InstaladoresExes += $Exe
            $Card = New-Object System.Windows.Forms.Panel
            $Card.Location = New-Object System.Drawing.Point(15, $InstY)
            $Card.Size = New-Object System.Drawing.Size(470, 44)
            $Card.BackColor = $Global:Theme.SurfaceLight
            $InstallRightPanel.Controls.Add($Card)

            $FileName = $Exe.Name
            $FileSize = [math]::Round($Exe.Length / 1MB, 1)
            $Card.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
                Text = "$FileName ($FileSize MB)"; Location = New-Object System.Drawing.Point(10, 12)
                Size = New-Object System.Drawing.Size(330, 20); Font = $Global:Fonts.Normal; ForeColor = $Global:Theme.TextMain
            }))

            # Capture variables correctly for closure
            $ExeFullName = $Exe.FullName
            $ExeDisplayName = $Exe.Name
            $RunBtn = New-Btn -Text "EJECUTAR" -X 350 -Y 6 -W 105 -H 32 -Color "Primary"
            $RunBtn.Add_Click({
                Update-Status "Ejecutando: $($ExeDisplayName)"
                Start-Process $ExeFullName -Verb RunAs
                Write-Log "Ejecutado: $ExeDisplayName"
            })
            $Card.Controls.Add($RunBtn)
            $InstY += 50
        }
    } else {
        $InstallRightPanel.Controls.Add((New-DescLabel -Text "No se encontraron archivos .exe" -X 15 -Y $InstY -W 400))
    }
} else {
    $InstallRightPanel.Controls.Add((New-DescLabel -Text "Carpeta 'instaladores' no encontrada" -X 15 -Y $InstY -W 400 -H 20))
    $warnLbl = New-DescLabel -Text "Coloca los .exe junto al script en /instaladores/" -X 15 -Y ($InstY + 18) -W 400 -H 20
    $warnLbl.ForeColor = $Global:Theme.TextDim
    $InstallRightPanel.Controls.Add($warnLbl)
}

# ============================================================================
#  ACTIVAR TAB
# ============================================================================
$ActScroll = New-Object System.Windows.Forms.Panel
$ActScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$ActScroll.AutoScroll = $true
$ActScroll.BackColor = $Global:Theme.BG
$TabAct.Controls.Add($ActScroll)

$ActScroll.Controls.Add((New-SectionTitle -Text "ACTIVACION DE WINDOWS Y OFFICE" -X 15 -Y 10))

$masStatus = Find-MAS
$masText = if ($masStatus) { "MAS_AIO.cmd detectado" } else { "MAS no encontrado - se descargara al activar" }
$masColor = if ($masStatus) { $Global:Theme.Success } else { $Global:Theme.Warning }
$ActScroll.Controls.Add((New-DescLabel -Text $masText -X 15 -Y 38 -W 400 -H 18))

# Check activation
$btnCheckAct = New-Btn -Text "VERIFICAR ACTIVACION" -X 15 -Y 60 -W 200 -H 38 -Color "Info"
$btnCheckAct.Add_Click({
    Update-Status "Verificando activacion..."
    $output = ""
    $products = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey }
    if ($products) {
        foreach ($p in $products) {
            $status = switch ($p.LicenseStatus) { 0 {"[SIN ACTIVAR]"} 1 {"[ACTIVADO]"} 2 {"[GRACIA]"} default {"[?]"} }
            $output += "$($p.Name)`r`n  Estado: $status`r`n  Clave parcial: $($p.PartialProductKey)`r`n`r`n"
        }
    } else { $output = "No se encontraron productos con clave." }
    $diagForm = New-Object System.Windows.Forms.Form
    $diagForm.Text = "SHADOWIEX - Activacion"
    $diagForm.Size = New-Object System.Drawing.Size(500, 350)
    $diagForm.BackColor = $Global:Theme.BG
    $diagForm.StartPosition = "CenterParent"
    $diagForm.TopMost = $true
    $txtBox = New-Object System.Windows.Forms.TextBox
    $txtBox.Multiline = $true; $txtBox.ReadOnly = $true
    $txtBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $txtBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $txtBox.BackColor = $Global:Theme.Surface; $txtBox.ForeColor = $Global:Theme.TextMain
    $txtBox.Font = $Global:Fonts.Mono; $txtBox.Text = $output
    $diagForm.Controls.Add($txtBox)
    [void]$diagForm.ShowDialog()
    Update-Status "Verificacion completada" "success"
    Write-Log "Verificacion de activacion"
})
$ActScroll.Controls.Add($btnCheckAct)

# MAS iex
$btnMASiex = New-Btn -Text "MAS ONLINE (iex)" -X 225 -Y 60 -W 200 -H 38 -Color "Accent"
$btnMASiex.Add_Click({ Invoke-MAS_iex })
$ActScroll.Controls.Add($btnMASiex)

# Activation cards
$ActList = @(
    @{Name="MAS INTERACTIVO"; Desc="Menu completo MAS (offline)"; Color="Success"; Action={Invoke-MASInteractive}},
    @{Name="HWID - WINDOWS"; Desc="Activacion permanente Win 10/11"; Color="Primary"; Action={Invoke-MAS_HWID}},
    @{Name="OHOOK - OFFICE"; Desc="Activacion Microsoft Office"; Color="Primary"; Action={Invoke-MAS_Ohook}},
    @{Name="TSFORGE"; Desc="Windows / Office / ESU"; Color="Secondary"; Action={Invoke-MAS_TSforge}},
    @{Name="KMS ONLINE"; Desc="Activacion KMS Win+Office"; Color="Secondary"; Action={Invoke-MAS_KMS}}
)

$AY = 115; $AX = 15; $ACol = 0
foreach ($A in $ActList) {
    $Card = New-Card -X $AX -Y $AY -W 248 -H 90
    $ActScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $A.Name -X 10 -Y 10 -W 228 -H 36 -Color $A.Color
    $CurrAct = $A.Action
    $Btn.Add_Click({ Update-Status "Abriendo activador..."; & $CurrAct; Update-Status "Activador lanzado" "success" }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $A.Desc -X 10 -Y 55 -W 228 -H 18))
    $ACol++
    if ($ACol -ge 4) { $ACol = 0; $AX = 15; $AY += 98 } else { $AX += 256 }
}

# Info panel
$InfoPanel = New-Object System.Windows.Forms.Panel
$InfoPanel.Location = New-Object System.Drawing.Point(15, 330)
$InfoPanel.Size = New-Object System.Drawing.Size(750, 50)
$InfoPanel.BackColor = $Global:Theme.Surface
$ActScroll.Controls.Add($InfoPanel)
$InfoPanel.Controls.Add((New-DescLabel -Text "HWID: Win10/11 permanente | TSforge: Todos los Windows | Ohook: Office completo" -X 15 -Y 8 -W 720 -H 16))
$InfoPanel.Controls.Add((New-DescLabel -Text "Distribuir Shadowiex.ps1 junto con la carpeta 'instaladores' y MAS_AIO.cmd" -X 15 -Y 28 -W 720 -H 16))

# ============================================================================
#  OPTIMIZAR TAB
# ============================================================================
$TweakScroll = New-Object System.Windows.Forms.Panel
$TweakScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$TweakScroll.AutoScroll = $true
$TweakScroll.BackColor = $Global:Theme.BG
$TabTweaks.Controls.Add($TweakScroll)

$TweakScroll.Controls.Add((New-SectionTitle -Text "OPTIMIZACION DEL SISTEMA" -X 15 -Y 10))

$TweaksList = @(
    @{Name="ESSENTIAL TWEAKS"; Desc="Optimizaciones de rendimiento"; Color="Success"; Action={
        Update-Status "Aplicando Essential Tweaks..."
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
            @("DiagTrack","dmwappushservice","WMPNetworkSvc","WerSvc") | ForEach-Object { try { Set-Service $_ -StartupType Disabled -EA 0 } catch {} }
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
            Set-Service SysMain -StartupType Disabled -EA 0; Stop-Service SysMain -Force -EA 0
            Update-Status "Essential Tweaks aplicados" "success"; Write-Log "Essential Tweaks aplicados"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="DESACTIVAR TELEMETRIA"; Desc="Detiene telemetria completa"; Color="Primary"; Action={
        Update-Status "Desactivando telemetria..."
        try { reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null; @("DiagTrack","dmwappushservice") | ForEach-Object { Stop-Service $_ -Force -EA 0; Set-Service $_ -StartupType Disabled -EA 0 }; Update-Status "Telemetria desactivada" "success"; Write-Log "Telemetria desactivada" } catch { Update-Status "Error" "error" }
    }},
    @{Name="DESACTIVAR DEFENDER"; Desc="Desactiva Windows Defender"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Desactivar Windows Defender?`n`nEsto reduce la seguridad del sistema.", "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) { try { Set-MpPreference -DisableRealtimeMonitoring $true -EA 0; Set-MpPreference -MAPSReporting 0 -EA 0; Update-Status "Defender desactivado" "warning"; Write-Log "Defender desactivado" } catch { Update-Status "Error" "error" } }
    }},
    @{Name="ACTIVAR DEFENDER"; Desc="Reactiva Windows Defender"; Color="Success"; Action={
        try { Set-MpPreference -DisableRealtimeMonitoring $false -EA 0; Set-MpPreference -MAPSReporting 1 -EA 0; Update-Status "Defender activado" "success"; Write-Log "Defender activado" } catch { Update-Status "Error" "error" }
    }},
    @{Name="LIMPIAR TEMPORALES"; Desc="Elimina archivos temporales"; Color="Secondary"; Action={
        Update-Status "Limpiando temporales..."
        try { $before = (Get-PSDrive C).Used; Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0; Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0; $after = (Get-PSDrive C).Used; $freed = [math]::Round(($before - $after) / 1MB, 1); Update-Status "Temporales limpiados (~$freed MB)" "success"; Write-Log "Temporales: $freed MB" } catch { Update-Status "Error" "error" }
    }},
    @{Name="OPTIMIZAR RED"; Desc="Resetea TCP/IP, Winsock, DNS"; Color="Secondary"; Action={
        Update-Status "Optimizando red..."
        try { netsh int ip reset 2>&1 | Out-Null; netsh winsock reset 2>&1 | Out-Null; ipconfig /flushdns 2>&1 | Out-Null; Update-Status "Red optimizada - reinicia" "success"; Write-Log "Red optimizada" } catch { Update-Status "Error" "error" }
    }},
    @{Name="DESACTIVAR SERVICIOS"; Desc="Desactiva servicios innecesarios"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Desactivar servicios innecesarios?`nSysMain, WSearch, Xbox, DiagTrack, etc.", "SHADOWIEX", 4)
        if ($R -eq 6) { Update-Status "Desactivando servicios..."; @("SysMain","WSearch","XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","DiagTrack","dmwappushservice","PhoneSvc","WMPNetworkSvc") | ForEach-Object { try { Set-Service $_ -StartupType Disabled -EA 0; Stop-Service $_ -Force -EA 0 } catch {} }; Update-Status "Servicios deshabilitados" "success"; Write-Log "Servicios deshabilitados" }
    }},
    @{Name="HABILITAR SERVICIOS"; Desc="Re-habilita servicios de Windows"; Color="Info"; Action={
        Update-Status "Habilitando servicios..."; @("SysMain","WSearch","DiagTrack","dmwappushservice") | ForEach-Object { try { Set-Service $_ -StartupType Automatic -EA 0; Start-Service $_ -EA 0 } catch {} }; Update-Status "Servicios rehabilitados" "success"; Write-Log "Servicios rehabilitados"
    }},
    @{Name="DESACTIVAR ANIMACIONES"; Desc="Desactiva animaciones visuales"; Color="Primary"; Action={
        Update-Status "Desactivando animaciones..."
        try { Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -EA 0; Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -EA 0; Update-Status "Animaciones desactivadas" "success"; Write-Log "Animaciones desactivadas" } catch { Update-Status "Error" "error" }
    }},
    @{Name="LIMPIAR CACHE ICONOS"; Desc="Reconstruye cache de iconos"; Color="Info"; Action={
        Update-Status "Limpiando cache de iconos..."
        try { Stop-Process -Name explorer -Force -EA 0; Start-Sleep -Seconds 2; Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -EA 0; Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -EA 0; Start-Process explorer.exe; Update-Status "Cache reconstruida" "success"; Write-Log "Cache iconos limpiada" } catch { Update-Status "Error" "error" }
    }},
    @{Name="VACIAR PAPELERA"; Desc="Vacia papelera de reciclaje"; Color="Secondary"; Action={
        Update-Status "Vaciando papelera..."; Clear-RecycleBin -Force -EA 0; Update-Status "Papelera vaciada" "success"; Write-Log "Papelera vaciada"
    }},
    @{Name="ADMIN. ARRANQUE"; Desc="Abre gestor de arranque del sistema"; Color="Primary"; Action={
        Update-Status "Abriendo administrador de arranque..."; Start-Process taskmgr.exe -ArgumentList "/0 /startup"; Write-Log "Admin arranque abierto"
    }}
)

$TweakY = 40; $TweakX = 15; $TCol = 0
foreach ($T in $TweaksList) {
    $Card = New-Card -X $TweakX -Y $TweakY -W 248 -H 90
    $TweakScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $T.Name -X 10 -Y 10 -W 228 -H 36 -Color $T.Color
    $CurrTweakAction = $T.Action
    $Btn.Add_Click({ & $CurrTweakAction }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $T.Desc -X 10 -Y 55 -W 228 -H 18))
    $TCol++
    if ($TCol -ge 4) { $TCol = 0; $TweakX = 15; $TweakY += 98 } else { $TweakX += 256 }
}

# ============================================================================
#  CONFIG TAB
# ============================================================================
$ConfigScroll = New-Object System.Windows.Forms.Panel
$ConfigScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$ConfigScroll.AutoScroll = $true
$ConfigScroll.BackColor = $Global:Theme.BG
$TabConfig.Controls.Add($ConfigScroll)

$WG = Test-Winget; $CH = Test-Choco; $masFound = Find-MAS

$ConfigScroll.Controls.Add((New-SectionTitle -Text "HERRAMIENTAS DISPONIBLES" -X 15 -Y 10))

$toolsY = 38
$wgVal = if($WG){"Instalado"}else{"No disponible"}
$wgClr = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}
Add-InfoRow -Parent $ConfigScroll -Label "Winget:" -Value $wgVal -X 20 -Y $toolsY -ValueColor $wgClr
$toolsY += 26
$chVal = if($CH){"Instalado"}else{"No disponible"}
$chClr = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}
Add-InfoRow -Parent $ConfigScroll -Label "Chocolatey:" -Value $chVal -X 20 -Y $toolsY -ValueColor $chClr
$toolsY += 26
$masVal = if($masFound){"Encontrado"}else{"No encontrado"}
$masClr = if($masFound){$Global:Theme.Success}else{$Global:Theme.Warning}
Add-InfoRow -Parent $ConfigScroll -Label "MAS_AIO.cmd:" -Value $masVal -X 20 -Y $toolsY -ValueColor $masClr
$toolsY += 26
$instCount = 0
if (Test-Path $Global:InstaladoresDir) { $instCount = (Get-ChildItem -Path $Global:InstaladoresDir -Filter "*.exe" -EA 0 | Measure-Object).Count }
$instVal = "$instCount archivos .exe"
$instClr = if($instCount -gt 0){$Global:Theme.Success}else{$Global:Theme.Warning}
Add-InfoRow -Parent $ConfigScroll -Label "Instaladores:" -Value $instVal -X 20 -Y $toolsY -ValueColor $instClr
$toolsY += 36

$ConfigScroll.Controls.Add((New-SectionTitle -Text "INFORMACION DEL SISTEMA" -X 15 -Y $toolsY))
$toolsY += 28

$OS = Get-CimInstance Win32_OperatingSystem; $CS = Get-CimInstance Win32_ComputerSystem; $MB = Get-CimInstance Win32_BaseBoard

$sysData = @(
    @{L="Sistema:"; V=$OS.Caption},
    @{L="Version:"; V="Build $($OS.BuildNumber) ($($OS.OSArchitecture))"},
    @{L="Fabricante:"; V=$CS.Manufacturer},
    @{L="Modelo:"; V=$CS.Model},
    @{L="Placa Base:"; V="$($MB.Manufacturer) $($MB.Product)"},
    @{L="Procesador:"; V=$(try{(Get-CimInstance Win32_Processor).Name}catch{"N/A"})},
    @{L="RAM Total:"; V="$([math]::Round($CS.TotalPhysicalMemory / 1GB, 2)) GB"},
    @{L="Usuario:"; V="$env:USERDOMAIN\$env:USERNAME"},
    @{L="Equipo:"; V=$env:COMPUTERNAME},
    @{L="Instalado:"; V=$(try{$OS.InstallDate.ToString("yyyy-MM-dd")}catch{"N/A"})},
    @{L="Ultimo Arranque:"; V=$(try{$OS.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")}catch{"N/A"})}
)
foreach ($s in $sysData) {
    Add-InfoRow -Parent $ConfigScroll -Label $s.L -Value $s.V -X 20 -Y $toolsY
    $toolsY += 24
}

$toolsY += 12
$ConfigScroll.Controls.Add((New-SectionTitle -Text "ACCIONES RAPIDAS" -X 15 -Y $toolsY))
$toolsY += 28

$quickBtns = @(
    @{N="MSINFO32"; X=15; C="Info"; A={Start-Process msinfo32.exe}},
    @{N="DISCOS"; X=145; C="Info"; A={Start-Process diskmgmt.msc}},
    @{N="DISPOSITIVOS"; X=275; C="Info"; A={Start-Process devmgmt.msc}},
    @{N="REGEDIT"; X=405; C="Warning"; A={Start-Process regedit.exe}},
    @{N="SERVICIOS"; X=15; C="Secondary"; Y=38; A={Start-Process services.msc}},
    @{N="TAREAS"; X=145; C="Secondary"; Y=38; A={Start-Process taskmgr.exe}},
    @{N="EVENTOS"; X=275; C="Secondary"; Y=38; A={Start-Process eventvwr.msc}},
    @{N="LIMPIEZA DISCO"; X=405; C="Success"; Y=38; A={Start-Process cleanmgr.exe}}
)
foreach ($qb in $quickBtns) {
    $qy = if ($qb.Y) { $toolsY + $qb.Y } else { $toolsY }
    $btn = New-Btn -Text $qb.N -X $qb.X -Y $qy -W 120 -H 32 -Color $qb.C
    $currQBAction = $qb.A
    $btn.Add_Click({ & $currQBAction }.GetNewClosure())
    $ConfigScroll.Controls.Add($btn)
}

$toolsY += 82
$CreditPanel = New-Object System.Windows.Forms.Panel
$CreditPanel.Location = New-Object System.Drawing.Point(15, $toolsY)
$CreditPanel.Size = New-Object System.Drawing.Size(500, 70)
$CreditPanel.BackColor = $Global:Theme.Surface
$ConfigScroll.Controls.Add($CreditPanel)
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "SHADOWIEX v14.1 Professional PC Toolkit"; Location = New-Object System.Drawing.Point(15, 10); Size = New-Object System.Drawing.Size(470, 20); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Creado por WDPN (WalterShadow2001)"; Location = New-Object System.Drawing.Point(15, 32); Size = New-Object System.Drawing.Size(470, 16); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted}))
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "github.com/WalterShadow2001/shadowiex"; Location = New-Object System.Drawing.Point(15, 50); Size = New-Object System.Drawing.Size(470, 16); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim}))

# ============================================================================
#  STATUS BAR
# ============================================================================
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = $Global:Theme.Surface
$StatusStrip.Font = $Global:Fonts.Small
$StatusStrip.Padding = New-Object System.Windows.Forms.Padding(0, 0, 10, 0)

$Global:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$Global:StatusLabel.Text = "  Listo"
$Global:StatusLabel.ForeColor = $Global:Theme.TextMuted
$StatusStrip.Items.Add($Global:StatusLabel)

$Sep1 = New-Object System.Windows.Forms.ToolStripStatusLabel
$Sep1.Text = "  |"; $Sep1.ForeColor = $Global:Theme.Border
$StatusStrip.Items.Add($Sep1)

$WGStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$WGStatus.Text = "  Winget: $(if($WG){'OK'}else{'NO'})"; $WGStatus.ForeColor = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($WGStatus)

$CHStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$CHStatus.Text = "  Choco: $(if($CH){'OK'}else{'NO'})"; $CHStatus.ForeColor = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($CHStatus)

$MASStatusBar = New-Object System.Windows.Forms.ToolStripStatusLabel
$MASStatusBar.Text = "  MAS: $(if($masFound){'OK'}else{'--'})"; $MASStatusBar.ForeColor = if($masFound){$Global:Theme.Success}else{$Global:Theme.Warning}
$StatusStrip.Items.Add($MASStatusBar)

$InstStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$InstStatus.Text = "  Instaladores: $instCount"; $InstStatus.ForeColor = if($instCount -gt 0){$Global:Theme.Success}else{$Global:Theme.TextDim}
$StatusStrip.Items.Add($InstStatus)

$Global:Form.Controls.Add($StatusStrip)

# ============================================================================
#  INICIAR
# ============================================================================
Write-Log "SHADOWIEX v14.1 iniciado"
Update-Status "SHADOWIEX v14.1 Professional - Listo"
[void]$Global:Form.ShowDialog()