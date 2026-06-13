<#
.SYNOPSIS
    SHADOWIEX v14.0 - Professional Edition
.DESCRIPTION
    Herramienta profesional de diagnostico, reparacion, instalacion y activacion.
    Integracion completa con MAS (iex online + offline).
    Carpeta instaladores para Office y herramientas.
    6 pestañas: DIAGNOSTICO, REPARAR, INSTALAR, ACTIVAR, OPTIMIZAR, CONFIG
.NOTES
    Autor: WDPN (WalterShadow2001)
    Repositorio: github.com/WalterShadow2001/shadowiex
#>

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

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
#  TEMA SHADOWIEX - DARK UI
# ============================================================================
$Global:Theme = @{
    BG           = [System.Drawing.Color]::FromArgb(15, 15, 20)
    Surface      = [System.Drawing.Color]::FromArgb(24, 24, 32)
    SurfaceLight = [System.Drawing.Color]::FromArgb(36, 36, 50)
    SurfaceHover = [System.Drawing.Color]::FromArgb(48, 48, 65)
    Primary      = [System.Drawing.Color]::FromArgb(139, 92, 246)
    PrimaryHover = [System.Drawing.Color]::FromArgb(167, 139, 250)
    PrimaryDark  = [System.Drawing.Color]::FromArgb(109, 62, 216)
    Secondary    = [System.Drawing.Color]::FromArgb(20, 184, 166)
    Accent       = [System.Drawing.Color]::FromArgb(236, 72, 153)
    Success      = [System.Drawing.Color]::FromArgb(34, 197, 94)
    Warning      = [System.Drawing.Color]::FromArgb(251, 191, 36)
    Danger       = [System.Drawing.Color]::FromArgb(239, 68, 68)
    Info         = [System.Drawing.Color]::FromArgb(59, 130, 246)
    TextMain     = [System.Drawing.Color]::White
    TextMuted    = [System.Drawing.Color]::FromArgb(156, 163, 175)
    TextDim      = [System.Drawing.Color]::FromArgb(100, 106, 120)
    Border       = [System.Drawing.Color]::FromArgb(50, 55, 70)
    BorderLight  = [System.Drawing.Color]::FromArgb(70, 75, 90)
}

$Global:Fonts = @{
    Title   = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
    Header  = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    Normal  = New-Object System.Drawing.Font("Segoe UI", 9.5)
    Small   = New-Object System.Drawing.Font("Segoe UI", 8.5)
    Button  = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    Mono    = New-Object System.Drawing.Font("Consolas", 9)
    BigIcon = New-Object System.Drawing.Font("Segoe UI", 28)
}

# ============================================================================
#  DIRECTORIO DEL SCRIPT Y UTILIDADES
# ============================================================================
$Global:ScriptDir = $null
try { $Global:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path } catch {}
if (-not $Global:ScriptDir) { $Global:ScriptDir = (Get-Location).Path }

$Global:InstaladoresDir = Join-Path $Global:ScriptDir "instaladores"
$Global:LogFile = Join-Path $env:TEMP "SHADOWIEX_log.txt"

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
        "No se encontro MAS_AIO.cmd`n`nDeseas descargar MAS desde GitHub?`n(Requiere conexion a internet)",
        "SHADOWIEX - MAS no encontrado",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($R -eq [System.Windows.Forms.MessageBoxButtons]::Yes) {
        Update-Status "Descargando MAS..."
        try {
            $url = "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
            $dest = Join-Path $env:TEMP "SHADOWIEX_MAS.cmd"
            [Net.ServicePointManager]::SecurityProtocol = 3072
            (New-Object System.Net.WebClient).DownloadFile($url, $dest)
            $Global:MAS_File = $dest
            Update-Status "MAS descargado correctamente" "success"
            Write-Log "MAS descargado a $dest"
            return $dest
        } catch { Update-Status "Error descargando MAS: $_" "error"; return $null }
    }
    return $null
}

# MAS Functions
function Invoke-MASInteractive {
    $f = Deploy-MAS
    if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`"" -Verb RunAs }
}
function Invoke-MAS_HWID {
    $f = Deploy-MAS
    if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /HWID" -Verb RunAs }
}
function Invoke-MAS_TSforge {
    $f = Deploy-MAS
    if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /Z-Windows" -Verb RunAs }
}
function Invoke-MAS_Ohook {
    $f = Deploy-MAS
    if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /Ohook" -Verb RunAs }
}
function Invoke-MAS_KMS {
    $f = Deploy-MAS
    if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`" /K-WindowsOffice" -Verb RunAs }
}

# MAS via iex (online directo)
function Invoke-MAS_iex {
    Update-Status "Ejecutando MAS via iex (online)..."
    try {
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"' -Verb RunAs
        Update-Status "MAS iex lanzado" "success"
    } catch { Update-Status "Error lanzando MAS iex" "error" }
}

# ============================================================================
#  COMPONENTES DE UI REUTILIZABLES
# ============================================================================
function New-Btn {
    param(
        [string]$Text, [int]$X, [int]$Y, [int]$W = 200, [int]$H = 42,
        [string]$Color = "Primary", [scriptblock]$Action = $null,
        [string]$Tooltip = ""
    )
    $BtnColor = switch ($Color) {
        "Success"      { $Global:Theme.Success }
        "Danger"       { $Global:Theme.Danger }
        "Warning"      { $Global:Theme.Warning }
        "Secondary"    { $Global:Theme.Secondary }
        "Accent"       { $Global:Theme.Accent }
        "Info"         { $Global:Theme.Info }
        "PrimaryDark"  { $Global:Theme.PrimaryDark }
        default        { $Global:Theme.Primary }
    }
    $HoverColor = switch ($Color) {
        "Success"      { [System.Drawing.Color]::FromArgb(46, 217, 104) }
        "Danger"       { [System.Drawing.Color]::FromArgb(249, 88, 88) }
        "Warning"      { [System.Drawing.Color]::FromArgb(255, 211, 66) }
        "Secondary"    { [System.Drawing.Color]::FromArgb(40, 204, 186) }
        default        { $Global:Theme.PrimaryHover }
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
    if ($Tooltip) { $Btn.ToolTipText = $Tooltip }
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
    $L.Size = New-Object System.Drawing.Size($W, 25)
    $L.Font = $Global:Fonts.Header
    $L.ForeColor = $Global:Theme.Primary
    return $L
}

function New-DescLabel {
    param([string]$Text, [int]$X, [int]$Y, [int]$W = 220)
    $L = New-Object System.Windows.Forms.Label
    $L.Text = $Text
    $L.Location = New-Object System.Drawing.Point($X, $Y)
    $L.Size = New-Object System.Drawing.Size($W, 20)
    $L.Font = $Global:Fonts.Small
    $L.ForeColor = $Global:Theme.TextMuted
    return $L
}

function New-InfoRow {
    param([string]$Label, [string]$Value, [int]$X, [int]$Y, [int]$LabelW = 160, [int]$ValueW = 320)
    $Lbl = New-Object System.Windows.Forms.Label
    $Lbl.Text = $Label
    $Lbl.Location = New-Object System.Drawing.Point($X, $Y)
    $Lbl.Size = New-Object System.Drawing.Size($LabelW, 22)
    $Lbl.Font = $Global:Fonts.Normal
    $Lbl.ForeColor = $Global:Theme.TextMuted
    $Val = New-Object System.Windows.Forms.Label
    $Val.Text = $Value
    $Val.Location = New-Object System.Drawing.Point($X + $LabelW, $Y)
    $Val.Size = New-Object System.Drawing.Size($ValueW, 22)
    $Val.Font = $Global:Fonts.Normal
    $Val.ForeColor = $Global:Theme.TextMain
    return @($Lbl, $Val)
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
function Test-Choco { try { $null = choco --version 2>$null; return $true } catch { return $false } }

# ============================================================================
#  FORMULARIO PRINCIPAL
# ============================================================================
$Global:Form = New-Object System.Windows.Forms.Form
$Global:Form.Text = "SHADOWIEX v14.0 - Professional PC Toolkit"
$Global:Form.Size = New-Object System.Drawing.Size(1100, 750)
$Global:Form.StartPosition = "CenterScreen"
$Global:Form.BackColor = $Global:Theme.BG
$Global:Form.ForeColor = $Global:Theme.TextMain
$Global:Form.MinimumSize = New-Object System.Drawing.Size(950, 650)
$Global:Form.Icon = $null
try {
    $iconPath = Join-Path $Global:ScriptDir "SHADOWIEX_LOGO.ico"
    if (Test-Path $iconPath) { $Global:Form.Icon = New-Object System.Drawing.Icon($iconPath) }
} catch {}

# ============================================================================
#  HEADER
# ============================================================================
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$HeaderPanel.Height = 70
$HeaderPanel.BackColor = $Global:Theme.Surface
$Global:Form.Controls.Add($HeaderPanel)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "SHADOWIEX"
$TitleLabel.Location = New-Object System.Drawing.Point(20, 14)
$TitleLabel.Size = New-Object System.Drawing.Size(180, 38)
$TitleLabel.Font = $Global:Fonts.Title
$TitleLabel.ForeColor = $Global:Theme.Primary
$HeaderPanel.Controls.Add($TitleLabel)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v14.0 Professional"
$VersionLabel.Location = New-Object System.Drawing.Point(195, 28)
$VersionLabel.Size = New-Object System.Drawing.Size(140, 20)
$VersionLabel.Font = $Global:Fonts.Small
$VersionLabel.ForeColor = $Global:Theme.TextMuted
$HeaderPanel.Controls.Add($VersionLabel)

$OSInfo = (Get-CimInstance Win32_OperatingSystem).Caption
$SysLabel = New-Object System.Windows.Forms.Label
$SysLabel.Text = $OSInfo
$SysLabel.Location = New-Object System.Drawing.Point(780, 12)
$SysLabel.Size = New-Object System.Drawing.Size(300, 20)
$SysLabel.Font = $Global:Fonts.Small
$SysLabel.ForeColor = $Global:Theme.TextMuted
$SysLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($SysLabel)

$AdminLabel = New-Object System.Windows.Forms.Label
$AdminLabel.Text = "[ADMINISTRADOR]"
$AdminLabel.Location = New-Object System.Drawing.Point(960, 35)
$AdminLabel.Size = New-Object System.Drawing.Size(120, 20)
$AdminLabel.Font = $Global:Fonts.Small
$AdminLabel.ForeColor = $Global:Theme.Success
$AdminLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($AdminLabel)

$AccentLine = New-Object System.Windows.Forms.Panel
$AccentLine.Dock = [System.Windows.Forms.DockStyle]::Bottom
$AccentLine.Height = 2
$AccentLine.BackColor = $Global:Theme.Primary
$HeaderPanel.Controls.Add($AccentLine)

# ============================================================================
#  PANEL DE PESTANAS
# ============================================================================
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(0, 70)
$TabControl.Size = New-Object System.Drawing.Size(1100, 630)
$TabControl.BackColor = $Global:Theme.BG
$TabControl.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
$TabControl.ItemSize = New-Object System.Drawing.Size(110, 32)
$TabControl.Font = $Global:Fonts.Button
$TabControl.Padding = New-Object System.Drawing.Point(8, 2)

$TabDiag    = New-Object System.Windows.Forms.TabPage; $TabDiag.Text = "DIAGNOSTICO";    $TabDiag.BackColor = $Global:Theme.BG; $TabDiag.Padding = New-Object System.Windows.Forms.Padding(15)
$TabRepair  = New-Object System.Windows.Forms.TabPage; $TabRepair.Text = "REPARAR";       $TabRepair.BackColor = $Global:Theme.BG; $TabRepair.Padding = New-Object System.Windows.Forms.Padding(15)
$TabInstall = New-Object System.Windows.Forms.TabPage; $TabInstall.Text = "INSTALAR";      $TabInstall.BackColor = $Global:Theme.BG; $TabInstall.Padding = New-Object System.Windows.Forms.Padding(15)
$TabAct     = New-Object System.Windows.Forms.TabPage; $TabAct.Text = "ACTIVAR";        $TabAct.BackColor = $Global:Theme.BG; $TabAct.Padding = New-Object System.Windows.Forms.Padding(15)
$TabTweaks  = New-Object System.Windows.Forms.TabPage; $TabTweaks.Text = "OPTIMIZAR";     $TabTweaks.BackColor = $Global:Theme.BG; $TabTweaks.Padding = New-Object System.Windows.Forms.Padding(15)
$TabConfig  = New-Object System.Windows.Forms.TabPage; $TabConfig.Text = "CONFIG";         $TabConfig.BackColor = $Global:Theme.BG; $TabConfig.Padding = New-Object System.Windows.Forms.Padding(15)

$TabControl.Controls.AddRange(@($TabDiag, $TabRepair, $TabInstall, $TabAct, $TabTweaks, $TabConfig))
$Global:Form.Controls.Add($TabControl)

# ============================================================================
#  DIAGNOSTICO TAB - Scroll panel
# ============================================================================
$DiagScroll = New-Object System.Windows.Forms.Panel
$DiagScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$DiagScroll.AutoScroll = $true
$DiagScroll.BackColor = $Global:Theme.BG
$TabDiag.Controls.Add($DiagScroll)

$TabDiag.Controls.Add($DiagScroll)

# -- Boton de escaneo completo
$btnFullDiag = New-Btn -Text "ESCANEO COMPLETO" -X 15 -Y 10 -W 220 -H 44 -Color "Success" -Tooltip "Ejecuta diagnostico completo del sistema"
$btnFullDiag.Add_Click({
    Update-Status "Ejecutando diagnostico completo..."
    $outputBox = $Global:DiagOutputBox
    $outputBox.Text = ""
    $outputBox.Text += "=== SHADOWIEX DIAGNOSTICO COMPLETO ===`r`n"
    $outputBox.Text += "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"
    $outputBox.Text += "=" * 50 + "`r`n`r`n"

    # OS Info
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
    $outputBox.Text += "  Carga actual:    $([math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1))%`r`n`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # RAM
    $outputBox.Text += "[MEMORIA RAM]`r`n"
    $RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $RAMTotal = [math]::Round($RAM.Sum / 1GB, 2)
    $OSRAM = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $RAMFree = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
    $outputBox.Text += "  RAM fisica:      $RAMTotal GB`r`n"
    $outputBox.Text += "  RAM visible:     $OSTotal GB`r`n"
    $outputBox.Text += "  RAM usada:       $([math]::Round($OSRAM - $RAMFree, 2)) GB`r`n"
    $outputBox.Text += "  RAM libre:       $RAMFree GB`r`n"
    $outputBox.Text += "  Uso:             $([math]::Round(($OSRAM - $RAMFree) / $OSRAM * 100, 1))%`r`n`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # GPU
    $outputBox.Text += "[TARJETA GRAFICA]`r`n"
    $GPUs = Get-CimInstance Win32_VideoController
    foreach ($GPU in $GPUs) {
        $outputBox.Text += "  GPU:             $($GPU.Name)`r`n"
        $outputBox.Text += "  VRAM:            $([math]::Round($GPU.AdapterRAM / 1GB, 2)) GB`r`n"
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
        $outputBox.Text += "    FS: $($D.FileSystem)`r`n"
    }
    $outputBox.Text += "`r`n"
    [System.Windows.Forms.Application]::DoEvents()

    # Red
    $outputBox.Text += "[RED]`r`n"
    try {
        $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($A in $Adapters) {
            $outputBox.Text += "  Adaptador:       $($A.Name)`r`n"
            $outputBox.Text += "  Velocidad:       $($A.LinkSpeed)`r`n"
            $IP = (Get-NetIPAddress -InterfaceIndex $A.ifIndex -AddressFamily IPv4 -EA 0).IPAddress
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

    # Activation Status
    $outputBox.Text += "`r`n[ESTADO DE ACTIVACION]`r`n"
    try {
        $licensing = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey }
        foreach ($l in $licensing) {
            $status = switch ($l.LicenseStatus) {
                0 { "Sin activar" }
                1 { "Activado" }
                2 { "Periodo de gracia" }
                default { "Desconocido ($($l.LicenseStatus))" }
            }
            $outputBox.Text += "  Producto:  $($l.Name)`r`n"
            $outputBox.Text += "  Estado:    $status`r`n"
        }
    } catch { $outputBox.Text += "  No se pudo verificar`r`n" }
    [System.Windows.Forms.Application]::DoEvents()

    # Startup Programs
    $outputBox.Text += "`r`n[PROGRAMAS DE INICIO]`r`n"
    $Startups = Get-CimInstance Win32_StartupCommand
    foreach ($S in $Startups) {
        $outputBox.Text += "  $($S.Name) - $($S.Command)`r`n"
    }
    $outputBox.Text += "`r`n"

    # Event Log Errors (last 10)
    $outputBox.Text += "[ERRORES RECIENTES DEL SISTEMA (ultimos 10)]`r`n"
    try {
        $Errors = Get-EventLog -LogName System -EntryType Error -Newest 10 -EA 0
        foreach ($E in $Errors) {
            $outputBox.Text += "  [$($E.TimeGenerated)] $($E.Source): $($E.Message.Substring(0, [math]::Min(80, $E.Message.Length)))`r`n"
        }
    } catch { $outputBox.Text += "  No se pudo leer el log de eventos`r`n" }

    $outputBox.Text += "`r`n" + "=" * 50 + "`r`n"
    $outputBox.Text += "Diagnostico completado`r`n"
    Update-Status "Diagnostico completado" "success"
    Write-Log "Diagnostico completo ejecutado"
})
$DiagScroll.Controls.Add($btnFullDiag)

# -- Quick Info Cards
$DiagY = 70

# CPU Card
$CardCPU = New-Card -X 15 -Y $DiagY -W 240 -H 75
$DiagScroll.Controls.Add($CardCPU)
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "CPU"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(60, 20)
    Font = $Global:Fonts.Header; ForeColor = $Global:Theme.Secondary
}))
$CPUName = (Get-CimInstance Win32_Processor).Name
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $CPUName; Location = New-Object System.Drawing.Point(10, 28); Size = New-Object System.Drawing.Size(220, 20)
    Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
}))
$CPUInfo = "$((Get-CimInstance Win32_Processor).NumberOfCores) nucleos / $((Get-CimInstance Win32_Processor).NumberOfLogicalProcessors) hilos"
$CardCPU.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $CPUInfo; Location = New-Object System.Drawing.Point(10, 48); Size = New-Object System.Drawing.Size(220, 18)
    Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim
}))

# RAM Card
$CardRAM = New-Card -X 265 -Y $DiagY -W 240 -H 75
$DiagScroll.Controls.Add($CardRAM)
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "RAM"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(60, 20)
    Font = $Global:Fonts.Header; ForeColor = $Global:Theme.Secondary
}))
$TotalRAM = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Total: $TotalRAM GB"; Location = New-Object System.Drawing.Point(10, 28); Size = New-Object System.Drawing.Size(220, 20)
    Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
}))
$FreeRAM = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
$CardRAM.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Libre: $FreeRAM GB"; Location = New-Object System.Drawing.Point(10, 48); Size = New-Object System.Drawing.Size(220, 18)
    Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim
}))

# Disk Card
$CardDisk = New-Card -X 515 -Y $DiagY -W 240 -H 75
$DiagScroll.Controls.Add($CardDisk)
$CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "DISCO PRINCIPAL"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(160, 20)
    Font = $Global:Fonts.Header; ForeColor = $Global:Theme.Secondary
}))
$DiskC = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
if ($DiskC) {
    $DiskTotal = [math]::Round($DiskC.Size / 1GB, 1)
    $DiskFree = [math]::Round($DiskC.FreeSpace / 1GB, 1)
    $DiskPct = [math]::Round(($DiskC.Size - $DiskC.FreeSpace) / $DiskC.Size * 100, 1)
    $CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Total: $DiskTotal GB | Usado: $DiskPct%"; Location = New-Object System.Drawing.Point(10, 28); Size = New-Object System.Drawing.Size(220, 20)
        Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
    }))
    $CardDisk.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Libre: $DiskFree GB"; Location = New-Object System.Drawing.Point(10, 48); Size = New-Object System.Drawing.Size(220, 18)
        Font = $Global:Fonts.Small; ForeColor = if($DiskPct -gt 85){$Global:Theme.Danger}else{$Global:Theme.TextDim}
    }))
}

# Network Card
$CardNet = New-Card -X 765 -Y $DiagY -W 300 -H 75
$DiagScroll.Controls.Add($CardNet)
$CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "RED"; Location = New-Object System.Drawing.Point(10, 5); Size = New-Object System.Drawing.Size(60, 20)
    Font = $Global:Fonts.Header; ForeColor = $Global:Theme.Secondary
}))
try {
    $NetAdapt = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Adaptador: $($NetAdapt.Name)"; Location = New-Object System.Drawing.Point(10, 28); Size = New-Object System.Drawing.Size(280, 20)
        Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
    }))
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Velocidad: $($NetAdapt.LinkSpeed)"; Location = New-Object System.Drawing.Point(10, 48); Size = New-Object System.Drawing.Size(280, 18)
        Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextDim
    }))
} catch {
    $CardNet.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "No se detecto adaptador"; Location = New-Object System.Drawing.Point(10, 28); Size = New-Object System.Drawing.Size(280, 20)
        Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
    }))
}

# Output Box
$DiagY2 = 165
$DiagScroll.Controls.Add((New-SectionTitle -Text "RESULTADO DEL DIAGNOSTICO" -X 15 -Y $DiagY2))
$Global:DiagOutputBox = New-Object System.Windows.Forms.TextBox
$Global:DiagOutputBox.Multiline = $true
$Global:DiagOutputBox.ReadOnly = $true
$Global:DiagOutputBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$Global:DiagOutputBox.Location = New-Object System.Drawing.Point(15, ($DiagY2 + 30))
$Global:DiagOutputBox.Size = New-Object System.Drawing.Size(1050, 360)
$Global:DiagOutputBox.BackColor = $Global:Theme.Surface
$Global:DiagOutputBox.ForeColor = $Global:Theme.Success
$Global:DiagOutputBox.Font = $Global:Fonts.Mono
$Global:DiagOutputBox.Text = "Presiona 'ESCANEO COMPLETO' para iniciar el diagnostico del sistema."
$DiagScroll.Controls.Add($Global:DiagOutputBox)

# Boton copiar resultado
$btnCopyDiag = New-Btn -Text "COPIAR RESULTADO" -X 15 -Y ($DiagY2 + 400) -W 180 -H 36 -Color "Secondary"
$btnCopyDiag.Add_Click({
    [System.Windows.Forms.Clipboard]::SetText($Global:DiagOutputBox.Text)
    Update-Status "Resultado copiado al portapapeles" "success"
})
$DiagScroll.Controls.Add($btnCopyDiag)

# ============================================================================
#  REPARAR TAB
# ============================================================================
$RepairScroll = New-Object System.Windows.Forms.Panel
$RepairScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$RepairScroll.AutoScroll = $true
$RepairScroll.BackColor = $Global:Theme.BG
$TabRepair.Controls.Add($RepairScroll)

$RepairScroll.Controls.Add((New-SectionTitle -Text "HERRAMIENTAS DE REPARACION DE WINDOWS" -X 15 -Y 10))

$RepairTools = @(
    @{Name="SFC /SCANNOW"; Desc="Verifica y repara archivos de sistema corruptos"; Color="Success"; Action={
        Update-Status "Ejecutando SFC /scannow (puede tardar varios minutos)..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''Iniciando SFC /scannow...'' -ForegroundColor Cyan; sfc /scannow; Write-Host ''`nPresiona Enter para cerrar...'' -ForegroundColor Yellow; Read-Host"' -Verb RunAs
        Update-Status "SFC /scannow iniciado en nueva ventana" "success"
        Write-Log "SFC /scannow ejecutado"
    }},
    @{Name="DISM RESTOREHEALTH"; Desc="Repara la imagen de Windows desde Windows Update"; Color="Success"; Action={
        Update-Status "Ejecutando DISM RestoreHealth..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Write-Host ''Iniciando DISM...'' -ForegroundColor Cyan; DISM /Online /Cleanup-Image /RestoreHealth; Write-Host ''`nPresiona Enter para cerrar...'' -ForegroundColor Yellow; Read-Host"' -Verb RunAs
        Update-Status "DISM RestoreHealth iniciado" "success"
        Write-Log "DISM RestoreHealth ejecutado"
    }},
    @{Name="CHECK DISK (C:)"; Desc="Verifica y repara errores en el disco C:"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Se requiere reinicio para completar chkdsk.`nContinuar?", "SHADOWIEX", 4)
        if ($R -eq 6) {
            Update-Status "Programando chkdsk C: /f /r..."
            Start-Process cmd.exe -ArgumentList '/c echo y | chkdsk C: /f /r' -Verb RunAs
            Write-Log "CHKDSK C: /f /r programado"
        }
    }},
    @{Name="REPARAR WINDOWS STORE"; Desc="Re-registra y repara la Microsoft Store"; Color="Info"; Action={
        Update-Status "Reparando Windows Store..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -Execution Policy Bypass -Command "Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\"}; Write-Host ''Store reparada. Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "Reparacion de Store iniciada" "success"
        Write-Log "Windows Store reparada"
    }},
    @{Name="REPARAR WINDOWS UPDATE"; Desc="Resetea los componentes de Windows Update"; Color="Info"; Action={
        Update-Status "Reparando Windows Update..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "net stop wuauserv; net stop bits; ren %systemroot%\SoftwareDistribution SoftwareDistribution.bak; ren %systemroot%\system32\catroot2 catroot2.bak; net start wuauserv; net start bits; Write-Host ''Windows Update reparado. Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "Windows Update reparado" "success"
        Write-Log "Windows Update reparado"
    }},
    @{Name="RESETEAR RED COMPLETO"; Desc="Resetea TCP/IP, Winsock y DNS"; Color="Secondary"; Action={
        Update-Status "Reseteando red..."
        try {
            netsh int ip reset | Out-Null
            netsh winsock reset | Out-Null
            ipconfig /flushdns | Out-Null
            ipconfig /release | Out-Null
            ipconfig /renew | Out-Null
            Update-Status "Red reseteada - reinicia para aplicar" "success"
            Write-Log "Red reseteada"
        } catch { Update-Status "Error reseteando red" "error" }
    }},
    @{Name="REPARAR ARRANQUE"; Desc="Repara el sector de arranque de Windows (BCD)"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Esto reparara el registro de arranque (BCD).`nSe ejecutara en ventana nueva.`nContinuar?", "SHADOWIEX", 4)
        if ($R -eq 6) {
            Update-Status "Reparando arranque..."
            Start-Process cmd.exe -ArgumentList '/c bootrec /fixmbr && bootrec /fixboot && bootrec /scanos && bootrec /rebuildbcd && pause' -Verb RunAs
            Write-Log "Reparacion de arranque ejecutada"
        }
    }},
    @{Name="LIMPIAR TEMPORALES"; Desc="Elimina archivos temporales del sistema y usuario"; Color="Secondary"; Action={
        Update-Status "Limpiando temporales..."
        try {
            $before = (Get-PSDrive C).Used
            Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Get-ChildItem "C:\Windows\Prefetch\*" -Force -EA 0 | Remove-Item -Force -EA 0
            $after = (Get-PSDrive C).Used
            $freed = [math]::Round(($before - $after) / 1MB, 1)
            Update-Status "Temporales limpiados (~$freed MB liberados)" "success"
            Write-Log "Temporales limpiados: $freed MB"
        } catch { Update-Status "Error limpiando" "error" }
    }},
    @{Name="LIMPIAR DNS CACHE"; Desc="Limpia la cache de resolucion DNS"; Color="Secondary"; Action={
        Update-Status "Limpiando DNS..."
        ipconfig /flushdns | Out-Null
        Update-Status "DNS cache limpiada" "success"
        Write-Log "DNS cache limpiada"
    }},
    @{Name="REPARAR ICONOS"; Desc="Reconstruye la cache de iconos de Windows"; Color="Info"; Action={
        Update-Status "Reparando iconos..."
        try {
            Stop-Process -Name explorer -Force -EA 0
            Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -EA 0
            Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -EA 0
            Start-Process explorer.exe
            Update-Status "Cache de iconos reconstruida" "success"
            Write-Log "Iconos reparados"
        } catch { Update-Status "Error reparando iconos" "error" }
    }},
    @{Name="VERIFICAR INTEGRIDAD DE DRIVERS"; Desc="Busca drivers con problemas o firmas invalidas"; Color="Info"; Action={
        Update-Status "Verificando drivers..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -Command "Get-WindowsDriver -Online | Where-Object {$_.Status -ne ''OK''} | Format-Table Driver, ProviderName, Date, Version, Status -AutoSize; Write-Host ''Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "Verificacion de drivers iniciada" "success"
        Write-Log "Verificacion de drivers"
    }},
    @{Name="REPARAR REGISTRO (DISM)"; Desc="Escanea y repara el componente store del registro"; Color="Warning"; Action={
        Update-Status "Ejecutando DISM Component Store scan..."
        Start-Process powershell.exe -ArgumentList '-NoProfile -Command "DISM /Online /Cleanup-Image /StartComponentCleanup; DISM /Online /Cleanup-Image /AnalyzeComponentStore; Write-Host ''Presiona Enter...''; Read-Host"' -Verb RunAs
        Update-Status "DISM Component Store iniciado" "success"
        Write-Log "DISM Component Store ejecutado"
    }}
)

$RY = 45; $RX = 15; $RCol = 0
foreach ($Tool in $RepairTools) {
    $Card = New-Card -X $RX -Y $RY -W 250 -H 95
    $RepairScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $Tool.Name -X 10 -Y 10 -W 230 -H 40 -Color $Tool.Color
    $CurrentAction = $Tool.Action
    $Btn.Add_Click({ & $CurrentAction }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $Tool.Desc -X 10 -Y 58 -W 230))
    $RCol++
    if ($RCol -ge 4) { $RCol = 0; $RX = 15; $RY += 105 } else { $RX += 260 }
}

# ============================================================================
#  INSTALAR TAB
# ============================================================================

# --- Panel izquierdo: Winget/Choco Software ---
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
        @{ID="Malwarebytes.Malwarebytes"; Name="Malwarebytes"},
        @{ID="VideoLAN.VLC"; Name="VLC (Codecs)"}
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
    $CatPanel.Size = New-Object System.Drawing.Size(530, 26)
    $CatPanel.BackColor = $Global:Theme.Surface
    $InstallLeftPanel.Controls.Add($CatPanel)
    $CatLabel = New-Object System.Windows.Forms.Label
    $CatLabel.Text = "  $Cat"
    $CatLabel.Location = New-Object System.Drawing.Point(2, 3)
    $CatLabel.Size = New-Object System.Drawing.Size(300, 20)
    $CatLabel.Font = $Global:Fonts.Header
    $CatLabel.ForeColor = $Global:Theme.Secondary
    $CatPanel.Controls.Add($CatLabel)

    $YPos += 28
    $XPos = 15

    foreach ($App in $SoftwareData[$Cat]) {
        $CB = New-Object System.Windows.Forms.CheckBox
        $CB.Text = $App.Name
        $CB.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CB.Size = New-Object System.Drawing.Size(165, 24)
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
        if ($XPos -gt 500) { $XPos = 15; $YPos += 26 }
    }
    $YPos += 36
}

# --- Panel derecho: Acciones + Instaladores locales ---
$InstallRightPanel = New-Object System.Windows.Forms.Panel
$InstallRightPanel.Location = New-Object System.Drawing.Point(565, 0)
$InstallRightPanel.Size = New-Object System.Drawing.Size(510, 580)
$InstallRightPanel.AutoScroll = $true
$InstallRightPanel.BackColor = $Global:Theme.Surface
$TabInstall.Controls.Add($InstallRightPanel)

# Acciones de instalacion
$InstallRightPanel.Controls.Add((New-SectionTitle -Text "ACCIONES" -X 15 -Y 10 -W 200))

$Global:CountLabel = New-Object System.Windows.Forms.Label
$Global:CountLabel.Text = "0 seleccionados"
$Global:CountLabel.Location = New-Object System.Drawing.Point(15, 38)
$Global:CountLabel.Size = New-Object System.Drawing.Size(200, 22)
$Global:CountLabel.Font = $Global:Fonts.Normal
$Global:CountLabel.ForeColor = $Global:Theme.Primary
$InstallRightPanel.Controls.Add($Global:CountLabel)

$Global:AllChecked = $false
$ToggleBtn = New-Btn -Text "SELECCIONAR TODO" -X 15 -Y 68 -W 200 -H 38 -Color "Secondary"
$ToggleBtn.Add_Click({
    $Global:AllChecked = -not $Global:AllChecked
    $ToggleBtn.Text = if ($Global:AllChecked) { "QUITAR TODO" } else { "SELECCIONAR TODO" }
    foreach ($CB in $Global:AllCheckboxes) { $CB.Checked = $Global:AllChecked }
})
$InstallRightPanel.Controls.Add($ToggleBtn)

$InstallBtn = New-Btn -Text "INSTALAR SELECCIONADOS" -X 15 -Y 116 -W 200 -H 42 -Color "Success"
$InstallBtn.Add_Click({
    $Selected = $Global:AllCheckboxes | Where-Object { $_.Checked }
    if ($Selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecciona al menos un programa.", "SHADOWIEX")
        return
    }
    $HasWinget = Test-Winget
    $HasChoco = Test-Choco
    if (-not $HasWinget -and -not $HasChoco) {
        $R = [System.Windows.Forms.MessageBox]::Show("No se encontro winget ni chocolatey.`nInstalar Chocolatey?", "SHADOWIEX", 4)
        if ($R -ne 6) { return }
        Update-Status "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $HasChoco = $true
            Update-Status "Chocolatey instalado" "success"
        } catch { Update-Status "Error instalando Chocolatey" "error"; return }
    }
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
    $ProgBar.Size = New-Object System.Drawing.Size(440, 28)
    $ProgBar.Maximum = $Selected.Count
    $ProgBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $ProgF.Controls.Add($ProgBar)
    $ProgDetail = New-Object System.Windows.Forms.Label
    $ProgDetail.Text = ""
    $ProgDetail.Location = New-Object System.Drawing.Point(15, 80)
    $ProgDetail.Size = New-Object System.Drawing.Size(440, 22)
    $ProgDetail.Font = $Global:Fonts.Small
    $ProgDetail.ForeColor = $Global:Theme.TextMuted
    $ProgF.Controls.Add($ProgDetail)
    $CancelBtn = New-Btn -Text "CANCELAR" -X 370 -Y 110 -W 90 -H 32 -Color "Danger"
    $CancelBtn.Add_Click({ $Global:Cancelled = $true; $ProgF.Close() })
    $ProgF.Controls.Add($CancelBtn)
    $ProgF.Show()
    $Global:Cancelled = $false; $Step = 0; $OK = 0; $Fail = 0
    foreach ($CB in $Selected) {
        if ($Global:Cancelled) { break }
        $Step++
        $AppID = $CB.Tag; $AppName = $CB.Text
        $ProgL.Text = "[$Step/$($Selected.Count)] Instalando: $AppName"
        $ProgBar.Value = $Step
        $ProgDetail.Text = "Buscando via winget..."
        [System.Windows.Forms.Application]::DoEvents()
        $Installed = $false
        if ($HasWinget) {
            try {
                $Proc = Start-Process "winget" -ArgumentList "install","--id",$AppID,"--accept-source-agreements","--accept-package-agreements","-h" -NoNewWindow -PassThru -Wait -EA 0
                if ($Proc.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        if (-not $Installed -and $HasChoco) {
            $ProgDetail.Text = "Intentando via chocolatey..."
            [System.Windows.Forms.Application]::DoEvents()
            try {
                $ChocoID = ($AppID -replace '\.','').ToLower()
                $Proc = Start-Process "choco" -ArgumentList "install",$ChocoID,"-y","--force" -NoNewWindow -PassThru -Wait -EA 0
                if ($Proc.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        $ProgDetail.Text = if ($Installed) { "Exitoso" } else { "Fallido - verifica manualmente" }
        if ($Installed) { $OK++ } else { $Fail++ }
    }
    $ProgF.Close()
    if ($Global:Cancelled) { Update-Status "Instalacion cancelada" "warning" }
    else {
        Update-Status "Completado: $OK OK, $Fail fallidos" "success"
        [System.Windows.Forms.MessageBox]::Show("Instalacion completada`n`nExitosos: $OK`nFallidos: $Fail", "SHADOWIEX")
    }
    Write-Log "Instalacion: $OK exitosos, $Fail fallidos"
})
$InstallRightPanel.Controls.Add($InstallBtn)

# --- SECCION: INSTALADORES LOCALES ---
$InstY = 180
$InstallRightPanel.Controls.Add((New-SectionTitle -Text "INSTALADORES LOCALES (CARPETA)" -X 15 -Y $InstY -W 400))
$InstY += 30

$InstDesc = New-Object System.Windows.Forms.Label
$InstDesc.Text = "Archivos .exe encontrados en la carpeta 'instaladores'"
$InstDesc.Location = New-Object System.Drawing.Point(15, $InstY)
$InstDesc.Size = New-Object System.Drawing.Size(470, 20)
$InstDesc.Font = $Global:Fonts.Small
$InstDesc.ForeColor = $Global:Theme.TextMuted
$InstallRightPanel.Controls.Add($InstDesc)
$InstY += 28

# Escanear carpeta instaladores
$Global:InstaladoresExes = @()
if (Test-Path $Global:InstaladoresDir) {
    $Exes = Get-ChildItem -Path $Global:InstaladoresDir -Filter "*.exe" -EA 0 | Sort-Object Name
    if ($Exes) {
        foreach ($Exe in $Exes) {
            $Global:InstaladoresExes += $Exe
            $Card = New-Object System.Windows.Forms.Panel
            $Card.Location = New-Object System.Drawing.Point(15, $InstY)
            $Card.Size = New-Object System.Drawing.Size(470, 50)
            $Card.BackColor = $Global:Theme.SurfaceLight
            $InstallRightPanel.Controls.Add($Card)

            $FileName = $Exe.Name
            $FileSize = [math]::Round($Exe.Length / 1MB, 1)
            $ExeLabel = New-Object System.Windows.Forms.Label
            $ExeLabel.Text = "$FileName ($FileSize MB)"
            $ExeLabel.Location = New-Object System.Drawing.Point(10, 5)
            $ExeLabel.Size = New-Object System.Drawing.Size(320, 20)
            $ExeLabel.Font = $Global:Fonts.Normal
            $ExeLabel.ForeColor = $Global:Theme.TextMain
            $Card.Controls.Add($ExeLabel)

            $ExePath = $Exe.FullName
            $RunBtn = New-Btn -Text "EJECUTAR" -X 340 -Y 5 -W 110 -H 34 -Color "Primary"
            $RunBtn.Add_Click({
                Update-Status "Ejecutando: $($using:Exe.Name)"
                Start-Process $using:ExePath -Verb RunAs
                Write-Log "Ejecutado instalador: $($using:Exe.Name)"
            }.GetNewClosure())
            $Card.Controls.Add($RunBtn)

            $InstY += 58
        }
    } else {
        $NoExeLabel = New-Object System.Windows.Forms.Label
        $NoExeLabel.Text = "No se encontraron archivos .exe en la carpeta instaladores/"
        $NoExeLabel.Location = New-Object System.Drawing.Point(15, $InstY)
        $NoExeLabel.Size = New-Object System.Drawing.Size(460, 20)
        $NoExeLabel.Font = $Global:Fonts.Normal
        $NoExeLabel.ForeColor = $Global:Theme.TextMuted
        $InstallRightPanel.Controls.Add($NoExeLabel)
    }
} else {
    $NoDirLabel = New-Object System.Windows.Forms.Label
    $NoDirLabel.Text = "Carpeta 'instaladores' no encontrada junto al script"
    $NoDirLabel.Location = New-Object System.Drawing.Point(15, $InstY)
    $NoDirLabel.Size = New-Object System.Drawing.Size(460, 20)
    $NoDirLabel.Font = $Global:Fonts.Normal
    $NoDirLabel.ForeColor = $Global:Theme.Warning
    $InstallRightPanel.Controls.Add($NoDirLabel)
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

# MAS Status
$masStatus = Find-MAS
$masStatusText = if ($masStatus) { "MAS_AIO.cmd detectado - Listo para activar" } else { "MAS no encontrado localmente - Se descargara al activar" }
$masStatusColor = if ($masStatus) { $Global:Theme.Success } else { $Global:Theme.Warning }
$ActScroll.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $masStatusText; Location = New-Object System.Drawing.Point(15, 40); Size = New-Object System.Drawing.Size(500, 20)
    Font = $Global:Fonts.Small; ForeColor = $masStatusColor
}))

# Check activation status button
$btnCheckAct = New-Btn -Text "VERIFICAR ACTIVACION" -X 15 -Y 65 -W 220 -H 42 -Color "Info" -Tooltip "Muestra el estado de activacion actual"
$btnCheckAct.Add_Click({
    Update-Status "Verificando activacion..."
    $output = ""
    $products = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey }
    if ($products) {
        foreach ($p in $products) {
            $status = switch ($p.LicenseStatus) {
                0 { "[SIN ACTIVAR]" }
                1 { "[ACTIVADO]" }
                2 { "[PERIODO DE GRACIA]" }
                5 { "[NOTIFICACION]" }
                6 { "[ACTIVACION EXTENDIDA]" }
                default { "[DESCONOCIDO: $($p.LicenseStatus)]" }
            }
            $color = switch ($p.LicenseStatus) {
                1 { $Global:Theme.Success }
                default { $Global:Theme.Danger }
            }
            $output += "$($p.Name)`r`n  Estado: $status`r`n  Clave parcial: $($p.PartialProductKey)`r`n`r`n"
        }
    } else {
        $output = "No se encontraron productos con clave de activacion."
    }
    $diagForm = New-Object System.Windows.Forms.Form
    $diagForm.Text = "SHADOWIEX - Estado de Activacion"
    $diagForm.Size = New-Object System.Drawing.Size(500, 350)
    $diagForm.BackColor = $Global:Theme.BG
    $diagForm.StartPosition = "CenterParent"
    $diagForm.TopMost = $true
    $txtBox = New-Object System.Windows.Forms.TextBox
    $txtBox.Multiline = $true
    $txtBox.ReadOnly = $true
    $txtBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $txtBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $txtBox.BackColor = $Global:Theme.Surface
    $txtBox.ForeColor = $Global:Theme.TextMain
    $txtBox.Font = $Global:Fonts.Mono
    $txtBox.Text = $output
    $diagForm.Controls.Add($txtBox)
    [void]$diagForm.ShowDialog()
    Update-Status "Verificacion completada" "success"
    Write-Log "Verificacion de activacion ejecutada"
})
$ActScroll.Controls.Add($btnCheckAct)

# MAS Online iex button
$btnMASiex = New-Btn -Text "MAS ONLINE (iex)" -X 250 -Y 65 -W 220 -H 42 -Color "Accent" -Tooltip "Ejecuta MAS directamente desde internet via iex"
$btnMASiex.Add_Click({ Invoke-MAS_iex })
$ActScroll.Controls.Add($btnMASiex)

# Activation cards
$ActList = @(
    @{Name="MAS INTERACTIVO"; Desc="Menu completo MAS (offline/local)"; Color="Success"; Action={Invoke-MASInteractive}},
    @{Name="HWID - WINDOWS"; Desc="Activacion permanente Windows 10/11"; Color="Primary"; Action={Invoke-MAS_HWID}},
    @{Name="OHOOK - OFFICE"; Desc="Activacion para Microsoft Office"; Color="Primary"; Action={Invoke-MAS_Ohook}},
    @{Name="TSFORGE"; Desc="Windows / Office / ESU (todos)"; Color="Secondary"; Action={Invoke-MAS_TSforge}},
    @{Name="KMS ONLINE"; Desc="Activacion KMS Windows + Office"; Color="Secondary"; Action={Invoke-MAS_KMS}}
)

$AY = 125; $AX = 15; $ACol = 0
foreach ($A in $ActList) {
    $Card = New-Card -X $AX -Y $AY -W 240 -H 95
    $ActScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $A.Name -X 10 -Y 10 -W 220 -H 40 -Color $A.Color
    $CurrAct = $A.Action
    $Btn.Add_Click({
        Update-Status "Abriendo activador..."
        & $CurrAct
        Update-Status "Activador lanzado" "success"
    }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $A.Desc -X 10 -Y 58 -W 220))
    $ACol++
    if ($ACol -ge 4) { $ACol = 0; $AX = 15; $AY += 105 } else { $AX += 250 }
}

# Info panel
$InfoPanel = New-Object System.Windows.Forms.Panel
$InfoPanel.Location = New-Object System.Drawing.Point(15, 350)
$InfoPanel.Size = New-Object System.Drawing.Size(750, 65)
$InfoPanel.BackColor = $Global:Theme.Surface
$ActScroll.Controls.Add($InfoPanel)

$InfoLabel = New-Object System.Windows.Forms.Label
$InfoLabel.Text = "HWID: Win10/11 permanente | TSforge: Todos los Windows | Ohook: Office completo"
$InfoLabel.Location = New-Object System.Drawing.Point(15, 10)
$InfoLabel.Size = New-Object System.Drawing.Size(720, 20)
$InfoLabel.Font = $Global:Fonts.Small
$InfoLabel.ForeColor = $Global:Theme.TextMuted
$InfoPanel.Controls.Add($InfoLabel)

$InfoLabel2 = New-Object System.Windows.Forms.Label
$InfoLabel2.Text = "Distribuir Shadowiex.ps1 junto con la carpeta 'instaladores' y MAS_AIO.cmd"
$InfoLabel2.Location = New-Object System.Drawing.Point(15, 35)
$InfoLabel2.Size = New-Object System.Drawing.Size(720, 20)
$InfoLabel2.Font = $Global:Fonts.Small
$InfoLabel2.ForeColor = $Global:Theme.Secondary
$InfoPanel.Controls.Add($InfoLabel2)

# ============================================================================
#  OPTIMIZAR TAB
# ============================================================================
$TweakScroll = New-Object System.Windows.Forms.Panel
$TweakScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$TweakScroll.AutoScroll = $true
$TweakScroll.BackColor = $Global:Theme.BG
$TabTweaks.Controls.Add($TweakScroll)

$TweakScroll.Controls.Add((New-SectionTitle -Text "OPTIMIZACION Y AJUSTES DEL SISTEMA" -X 15 -Y 10))

$TweaksList = @(
    @{Name="ESSENTIAL TWEAKS"; Desc="Optimizaciones esenciales de rendimiento"; Color="Success"; Action={
        Update-Status "Aplicando Essential Tweaks..."
        try {
            # Disable Telemetry
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            # Disable Cortana
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
            # Disable Services
            @("DiagTrack","dmwappushservice","WMPNetworkSvc","WerSvc") | ForEach-Object {
                try { Set-Service $_ -StartupType Disabled -EA 0 } catch {}
            }
            # Power Plan: High Performance
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
            # Disable Superfetch
            Set-Service SysMain -StartupType Disabled -EA 0
            Stop-Service SysMain -Force -EA 0
            Update-Status "Essential Tweaks aplicados" "success"
            Write-Log "Essential Tweaks aplicados"
        } catch { Update-Status "Error aplicando tweaks" "error" }
    }},
    @{Name="DESACTIVAR TELEMETRIA"; Desc="Detiene y desactiva la telemetria completa"; Color="Primary"; Action={
        Update-Status "Desactivando telemetria..."
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            @("DiagTrack","dmwappushservice") | ForEach-Object {
                Stop-Service $_ -Force -EA 0
                Set-Service $_ -StartupType Disabled -EA 0
            }
            Update-Status "Telemetria desactivada" "success"
            Write-Log "Telemetria desactivada"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="DESACTIVAR DEFENDER"; Desc="Desactiva Windows Defender temporalmente"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Desactivar Windows Defender?`n`nADVERTENCIA: Esto reduce la seguridad del sistema.", "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            try {
                Set-MpPreference -DisableRealtimeMonitoring $true -EA 0
                Set-MpPreference -MAPSReporting 0 -EA 0
                Set-MpPreference -SubmitSamplesConsent 2 -EA 0
                Update-Status "Defender desactivado" "warning"
                Write-Log "Defender desactivado"
            } catch { Update-Status "Error - ejecuta como admin" "error" }
        }
    }},
    @{Name="ACTIVAR DEFENDER"; Desc="Reactiva Windows Defender completamente"; Color="Success"; Action={
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -EA 0
            Set-MpPreference -MAPSReporting 1 -EA 0
            Update-Status "Defender activado" "success"
            Write-Log "Defender activado"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="LIMPIAR TEMPORALES"; Desc="Elimina archivos temporales del sistema"; Color="Secondary"; Action={
        Update-Status "Limpiando temporales..."
        try {
            $before = (Get-PSDrive C).Used
            Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Get-ChildItem "C:\Windows\Prefetch\*" -Force -EA 0 | Remove-Item -Force -EA 0
            $after = (Get-PSDrive C).Used
            $freed = [math]::Round(($before - $after) / 1MB, 1)
            Update-Status "Temporales limpiados (~$freed MB)" "success"
            Write-Log "Temporales limpiados: $freed MB"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="OPTIMIZAR RED"; Desc="Resetea TCP/IP, Winsock y DNS cache"; Color="Secondary"; Action={
        Update-Status "Optimizando red..."
        try {
            netsh int ip reset | Out-Null
            netsh winsock reset | Out-Null
            ipconfig /flushdns | Out-Null
            Update-Status "Red optimizada - reinicia para aplicar" "success"
            Write-Log "Red optimizada"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="DESHABILITAR SERVICIOS INUTILES"; Desc="Desactiva servicios innecesarios para rendimiento"; Color="Warning"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Desactivar servicios innecesarios?`n`nServicios: SysMain, WSearch (indice), Xbox, DiagTrack, etc.", "SHADOWIEX", 4)
        if ($R -eq 6) {
            Update-Status "Desactivando servicios..."
            @("SysMain","WSearch","XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","DiagTrack","dmwappushservice","PhoneSvc","PimIndexMaintenance","MessagingService","WMPNetworkSvc") | ForEach-Object {
                try { Set-Service $_ -StartupType Disabled -EA 0; Stop-Service $_ -Force -EA 0 } catch {}
            }
            Update-Status "Servicios deshabilitados" "success"
            Write-Log "Servicios innecesarios deshabilitados"
        }
    }},
    @{Name="HABILITAR SERVICIOS"; Desc="Re-habilita los servicios de Windows"; Color="Info"; Action={
        Update-Status "Habilitando servicios..."
        @("SysMain","WSearch","DiagTrack","dmwappushservice") | ForEach-Object {
            try { Set-Service $_ -StartupType Automatic -EA 0; Start-Service $_ -EA 0 } catch {}
        }
        Update-Status "Servicios rehabilitados" "success"
        Write-Log "Servicios rehabilitados"
    }},
    @{Name="DESACTIVAR ANIMACIONES"; Desc="Desactiva animaciones visuales para mas velocidad"; Color="Primary"; Action={
        Update-Status "Desactivando animaciones..."
        try {
            $path = "HKCU:\Control Panel\Desktop\WindowMetrics"
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -EA 0
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -EA 0
            # Disable transparency
            Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -EA 0
            Update-Status "Animaciones desactivadas" "success"
            Write-Log "Animaciones desactivadas"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="LIMPIAR CACHE DE ICONOS"; Desc="Reconstruye la cache de iconos del sistema"; Color="Info"; Action={
        Update-Status "Limpiando cache de iconos..."
        try {
            Stop-Process -Name explorer -Force -EA 0
            Start-Sleep -Seconds 2
            Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -EA 0
            Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -EA 0
            Start-Process explorer.exe
            Update-Status "Cache de iconos reconstruida" "success"
            Write-Log "Cache de iconos limpiada"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="VACIAR PAPELERA"; Desc="Vacia la papelera de reciclaje"; Color="Secondary"; Action={
        Update-Status "Vaciando papelera..."
        Clear-RecycleBin -Force -EA 0
        Update-Status "Papelera vaciada" "success"
        Write-Log "Papelera vaciada"
    }},
    @{Name="OPTIMIZAR ARRANQUE"; Desc="Abre el administrador de tareas en la pestaña de arranque"; Color="Primary"; Action={
        Update-Status "Abriendo administrador de arranque..."
        Start-Process taskmgr.exe -ArgumentList "/0 /startup"
        Write-Log "Administrador de arranque abierto"
    }}
)

$TweakY = 40; $TweakX = 15; $TCol = 0
foreach ($T in $TweaksList) {
    $Card = New-Card -X $TweakX -Y $TweakY -W 245 -H 95
    $TweakScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $T.Name -X 10 -Y 10 -W 225 -H 40 -Color $T.Color
    $CurrTweakAction = $T.Action
    $Btn.Add_Click({ & $CurrTweakAction }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $T.Desc -X 10 -Y 58 -W 225))
    $TCol++
    if ($TCol -ge 4) { $TCol = 0; $TweakX = 15; $TweakY += 105 } else { $TweakX += 255 }
}

# ============================================================================
#  CONFIG TAB
# ============================================================================
$ConfigScroll = New-Object System.Windows.Forms.Panel
$ConfigScroll.Dock = [System.Windows.Forms.DockStyle]::Fill
$ConfigScroll.AutoScroll = $true
$ConfigScroll.BackColor = $Global:Theme.BG
$TabConfig.Controls.Add($ConfigScroll)

$WG = Test-Winget
$CH = Test-Choco
$masFound = Find-MAS

# -- Herramientas disponibles
$ConfigScroll.Controls.Add((New-SectionTitle -Text "HERRAMIENTAS DISPONIBLES" -X 15 -Y 10))

$toolsY = 40
$toolItems = @(
    @{Label = "Winget:"; Value = if($WG){"[INSTALADO]"}else{"[NO DISPONIBLE]"}; Color = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}},
    @{Label = "Chocolatey:"; Value = if($CH){"[INSTALADO]"}else{"[NO DISPONIBLE]"}; Color = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}},
    @{Label = "MAS_AIO.cmd:"; Value = if($masFound){"[ENCONTRADO]"}else{"[NO ENCONTRADO]"}; Color = if($masFound){$Global:Theme.Success}else{$Global:Theme.Warning}},
    @{Label = "Instaladores:"; Value = if(Test-Path $Global:InstaladoresDir){"[CARPETA OK] - $($Global:InstaladoresExes.Count) archivos"}else{"[NO ENCONTRADA]"}; Color = if(Test-Path $Global:InstaladoresDir){$Global:Theme.Success}else{$Global:Theme.Warning}}
)

foreach ($t in $toolItems) {
    $row = New-InfoRow -Label $t.Label -Value $t.Value -X 20 -Y $toolsY -LabelW 130 -ValueW 400
    $row[1].ForeColor = $t.Color
    $ConfigScroll.Controls.Add($row[0])
    $ConfigScroll.Controls.Add($row[1])
    $toolsY += 28
}

# -- Informacion del Sistema
$SysTitle = New-SectionTitle -Text "INFORMACION DEL SISTEMA" -X 15 -Y ($toolsY + 15)
$ConfigScroll.Controls.Add($SysTitle)

$OS = Get-CimInstance Win32_OperatingSystem
$CS = Get-CimInstance Win32_ComputerSystem
$MB = Get-CimInstance Win32_BaseBoard

$sysY = $toolsY + 45
$sysInfo = @(
    @{Label = "Sistema:"; Value = $OS.Caption },
    @{Label = "Version:"; Value = "Build $($OS.BuildNumber) ($($OS.OSArchitecture))" },
    @{Label = "Fabricante:"; Value = $CS.Manufacturer },
    @{Label = "Modelo:"; Value = $CS.Model },
    @{Label = "Placa Base:"; Value = "$($MB.Manufacturer) $($MB.Product)" },
    @{Label = "Procesador:"; Value = (Get-CimInstance Win32_Processor).Name },
    @{Label = "RAM Total:"; Value = "$([math]::Round($CS.TotalPhysicalMemory / 1GB, 2)) GB" },
    @{Label = "Usuario:"; Value = "$env:USERDOMAIN\$env:USERNAME" },
    @{Label = "Equipo:"; Value = $env:COMPUTERNAME },
    @{Label = "Instalado:"; Value = $OS.InstallDate.ToString("yyyy-MM-dd") },
    @{Label = "Ultimo Arranque:"; Value = $OS.LastBootUpTime.ToString("yyyy-MM-dd HH:mm") }
)

foreach ($s in $sysInfo) {
    $row = New-InfoRow -Label $s.Label -Value $s.Value -X 20 -Y $sysY -LabelW 130 -ValueW 500
    $ConfigScroll.Controls.Add($row[0])
    $ConfigScroll.Controls.Add($row[1])
    $sysY += 26
}

# -- Botones utiles
$btnY = $sysY + 15
$ConfigScroll.Controls.Add((New-SectionTitle -Text "ACCIONES RAPIDAS" -X 15 -Y $btnY))
$btnY += 30

$btnSysInfo = New-Btn -Text "MSINFO32" -X 15 -Y $btnY -W 130 -H 36 -Color "Info"
$btnSysInfo.Add_Click({ Start-Process msinfo32.exe })
$ConfigScroll.Controls.Add($btnSysInfo)

$btnDiskMgmt = New-Btn -Text "DISCOSS" -X 155 -Y $btnY -W 130 -H 36 -Color "Info"
$btnDiskMgmt.Add_Click({ Start-Process diskmgmt.msc })
$ConfigScroll.Controls.Add($btnDiskMgmt)

$btnDevMgmt = New-Btn -Text "ADMINISTRADOR DISPOSITIVOS" -X 295 -Y $btnY -W 200 -H 36 -Color "Info"
$btnDevMgmt.Add_Click({ Start-Process devmgmt.msc })
$ConfigScroll.Controls.Add($btnDevMgmt)

$btnRegedit = New-Btn -Text "REGEDIT" -X 505 -Y $btnY -W 130 -H 36 -Color "Warning"
$btnRegedit.Add_Click({ Start-Process regedit.exe })
$ConfigScroll.Controls.Add($btnRegedit)

$btnY += 46
$btnServices = New-Btn -Text "SERVICIOS" -X 15 -Y $btnY -W 130 -H 36 -Color "Secondary"
$btnServices.Add_Click({ Start-Process services.msc })
$ConfigScroll.Controls.Add($btnServices)

$btnTaskMgr = New-Btn -Text "ADMIN. TAREAS" -X 155 -Y $btnY -W 130 -H 36 -Color "Secondary"
$btnTaskMgr.Add_Click({ Start-Process taskmgr.exe })
$ConfigScroll.Controls.Add($btnTaskMgr)

$btnEventViewer = New-Btn -Text "VISOR EVENTOS" -X 295 -Y $btnY -W 200 -H 36 -Color "Secondary"
$btnEventViewer.Add_Click({ Start-Process eventvwr.msc })
$ConfigScroll.Controls.Add($btnEventViewer)

$btnCleanMgr = New-Btn -Text "LIMPIEZA DISCO" -X 505 -Y $btnY -W 130 -H 36 -Color "Success"
$btnCleanMgr.Add_Click({ Start-Process cleanmgr.exe })
$ConfigScroll.Controls.Add($btnCleanMgr)

# -- Credits
$btnY += 60
$CreditPanel = New-Object System.Windows.Forms.Panel
$CreditPanel.Location = New-Object System.Drawing.Point(15, $btnY)
$CreditPanel.Size = New-Object System.Drawing.Size(500, 80)
$CreditPanel.BackColor = $Global:Theme.Surface
$ConfigScroll.Controls.Add($CreditPanel)

$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "SHADOWIEX v14.0 Professional PC Toolkit"; Location = New-Object System.Drawing.Point(15, 12)
    Size = New-Object System.Drawing.Size(470, 22); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.Primary
}))
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Creado por WDPN (WalterShadow2001)"; Location = New-Object System.Drawing.Point(15, 38)
    Size = New-Object System.Drawing.Size(470, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
}))
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "github.com/WalterShadow2001/shadowiex"; Location = New-Object System.Drawing.Point(15, 56)
    Size = New-Object System.Drawing.Size(470, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.Secondary
}))

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
$Sep1.Text = "  |"
$Sep1.ForeColor = $Global:Theme.Border
$StatusStrip.Items.Add($Sep1)

$WGStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$WGStatus.Text = "  Winget: $(if($WG){'OK'}else{'NO'})"
$WGStatus.ForeColor = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($WGStatus)

$CHStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$CHStatus.Text = "  Choco: $(if($CH){'OK'}else{'NO'})"
$CHStatus.ForeColor = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($CHStatus)

$MASStatusBar = New-Object System.Windows.Forms.ToolStripStatusLabel
$MASStatusBar.Text = "  MAS: $(if($masFound){'OK'}else{'--'})"
$MASStatusBar.ForeColor = if($masFound){$Global:Theme.Success}else{$Global:Theme.Warning}
$StatusStrip.Items.Add($MASStatusBar)

$InstStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$InstStatus.Text = "  Instaladores: $(if(Test-Path $Global:InstaladoresDir){$Global:InstaladoresExes.Count}else{0})"
$InstStatus.ForeColor = if(Test-Path $Global:InstaladoresDir){$Global:Theme.Success}else{$Global:Theme.TextDim}
$StatusStrip.Items.Add($InstStatus)

$Global:Form.Controls.Add($StatusStrip)

# ============================================================================
#  INICIAR APLICACION
# ============================================================================
Write-Log "SHADOWIEX v14.0 iniciado"
Update-Status "SHADOWIEX v14.0 Professional - Listo"
[void]$Global:Form.ShowDialog()