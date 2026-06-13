<#
.SYNOPSIS
    SHADOWIEX v14.1 - Professional PC Toolkit
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
$Logo = @"

     ███████╗███████╗███╗   ██╗████████╗
     ██╔════╝██╔════╝████╗  ██║╚══██╔══╝
     ███████╗█████╗  ██╔██╗ ██║   ██║
     ╚════██║██╔══╝  ██║╚██╗██║   ██║
     ███████║███████╗██║ ╚████║   ██║
     ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝

           Professional PC Toolkit
                 v14.1

"@
Write-Host $Logo -ForegroundColor DarkCyan

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
    Button  = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::SemiBold)
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
        [System.Drawing.Color]$ValueColor = $null
    )
    $Lbl = New-Object System.Windows.Forms.Label
    $Lbl.Text = $Label
    $Lbl.Location = New-Object System.Drawing.Point($X, $Y)
    $Lbl.Size = New-Object System.Drawing.Size($LabelW, 20)
    $Lbl.Font = $Global:Fonts.Normal
    $Lbl.ForeColor = $Global:Theme.TextMuted
    $Parent.Controls.Add($Lbl)

    $Val = New-Object System.Windows.Forms.Label
    $Val.Text = $Value
    $Val.Location = New-Object System.Drawing.Point($X + $LabelW, $Y)
    $Val.Size = New-Object System.Drawing.Size($ValueW, 20)
    $Val.Font = $Global:Fonts.Normal
    $Val.ForeColor = if ($ValueColor) { $ValueColor } else { $Global:Theme.TextMain }
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
$Global:Form.Text = "SHADOWIEX v14.1"
$Global:Form.Size = New-Object System.Drawing.Size(1100, 750)
$Global:Form.StartPosition = "CenterScreen"
$Global:Form.BackColor = $Global:Theme.BG
$Global:Form.ForeColor = $Global:Theme.TextMain
$Global:Form.MinimumSize = New-Object System.Drawing.Size(950, 650)
try {
    $iconPath = Join-Path $Global:ScriptDir "SHADOWIEX_LOGO.ico"
    if (Test-Path $iconPath) { $Global:Form.Icon = New-Object System.Drawing.Icon($iconPath) }
} catch {}

# ============================================================================
#  HEADER
# ============================================================================
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$HeaderPanel.Height = 60
$HeaderPanel.BackColor = $Global:Theme.Surface
$Global:Form.Controls.Add($HeaderPanel)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "SHADOWIEX"
$TitleLabel.Location = New-Object System.Drawing.Point(20, 12)
$TitleLabel.Size = New-Object System.Drawing.Size(180, 36)
$TitleLabel.Font = $Global:Fonts.Title
$TitleLabel.ForeColor = $Global:Theme.Highlight
$HeaderPanel.Controls.Add($TitleLabel)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v14.1 Professional"
$VersionLabel.Location = New-Object System.Drawing.Point(185, 25)
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
    $ProgF.Size = New-Object System.Drawing.Size(480, 160)
    $ProgF.BackColor = $Global:Theme.BG
    $ProgF.StartPosition = "CenterParent"
    $ProgF.FormBorderStyle = "FixedDialog"
    $ProgF.ControlBox = $false
    $ProgF.TopMost = $true
    $ProgL = New-Object System.Windows.Forms.Label
    $ProgL.Text = "Iniciando instalacion..."
    $ProgL.Location = New-Object System.Drawing.Point(15, 15)
    $ProgL.Size = New-Object System.Drawing.Size(440, 22)
    $ProgL.Font = $Global:Fonts.Normal
    $ProgL.ForeColor = $Global:Theme.TextMain
    $ProgF.Controls.Add($ProgL)
    $ProgBar = New-Object System.Windows.Forms.ProgressBar
    $ProgBar.Location = New-Object System.Drawing.Point(15, 45)
    $ProgBar.Size = New-Object System.Drawing.Size(440, 25)
    $ProgBar.Maximum = $Selected.Count
    $ProgBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $ProgBar.ForeColor = $Global:Theme.Primary
    $ProgF.Controls.Add($ProgBar)
    $ProgDetail = New-Object System.Windows.Forms.Label
    $ProgDetail.Text = ""
    $ProgDetail.Location = New-Object System.Drawing.Point(15, 78)
    $ProgDetail.Size = New-Object System.Drawing.Size(350, 20)
    $ProgDetail.Font = $Global:Fonts.Small
    $ProgDetail.ForeColor = $Global:Theme.TextMuted
    $ProgF.Controls.Add($ProgDetail)
    $CancelBtn = New-Btn -Text "CANCELAR" -X 370 -Y 108 -W 90 -H 30 -Color "Danger"
    $CancelBtn.Add_Click({ $Global:Cancelled = $true; $ProgF.Close() })
    $ProgF.Controls.Add($CancelBtn)
    $ProgF.Show()

    $Global:Cancelled = $false; $Step = 0; $OK = 0; $Fail = 0
    foreach ($CB in $Selected) {
        if ($Global:Cancelled) { break }
        $Step++; $AppID = $CB.Tag; $AppName = $CB.Text
        $ProgL.Text = "[$Step/$($Selected.Count)] $AppName"
        $ProgBar.Value = $Step
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
        $ProgDetail.Text = if ($Installed) { "OK" } else { "No encontrado - verifica manualmente" }
        if ($Installed) { $OK++ } else { $Fail++ }
    }
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
Add-InfoRow -Parent $ConfigScroll -Label "Winget:" -Value $(if($WG){"Instalado"}else{"No disponible"}) -X 20 -Y $toolsY -ValueColor $(if($WG){$Global:Theme.Success}else{$Global:Theme.Danger})
$toolsY += 26
Add-InfoRow -Parent $ConfigScroll -Label "Chocolatey:" -Value $(if($CH){"Instalado"}else{"No disponible"}) -X 20 -Y $toolsY -ValueColor $(if($CH){$Global:Theme.Success}else{$Global:Theme.Danger})
$toolsY += 26
Add-InfoRow -Parent $ConfigScroll -Label "MAS_AIO.cmd:" -Value $(if($masFound){"Encontrado"}else{"No encontrado"}) -X 20 -Y $toolsY -ValueColor $(if($masFound){$Global:Theme.Success}else{$Global:Theme.Warning})
$toolsY += 26
$instCount = 0
if (Test-Path $Global:InstaladoresDir) { $instCount = (Get-ChildItem -Path $Global:InstaladoresDir -Filter "*.exe" -EA 0 | Measure-Object).Count }
Add-InfoRow -Parent $ConfigScroll -Label "Instaladores:" -Value "$instCount archivos .exe" -X 20 -Y $toolsY -ValueColor $(if($instCount -gt 0){$Global:Theme.Success}else{$Global:Theme.Warning})
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