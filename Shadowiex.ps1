<#
.SYNOPSIS
    SHADOWIEX v15.0 - Professional PC Toolkit
.DESCRIPTION
    Herramienta profesional de diagnostico, reparacion, instalacion y activacion.
    Integracion completa con MAS (iex online + offline).
    Descargas directas Office C2R (es-MX) y herramientas.
    6 pestanas: DIAGNOSTICO, REPARAR, INSTALAR, ACTIVAR, OPTIMIZAR, CONFIG
.NOTES
    Autor: WDPN (WalterShadow2001)
    Repositorio: github.com/WalterShadow2001/shadowiex
#>

# ============================================================================
#  SPLASH / CARGA EN CONSOLA
# ============================================================================
Add-Type -AssemblyName System.Drawing
Clear-Host

# Renderizar logo embebido como ASCII (desde PNG con canal alfa)
$SplashLines = @()
try {
    $pngBytes = [System.Convert]::FromBase64String("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")
    $ms = New-Object System.IO.MemoryStream(,$pngBytes)
    $bmp = New-Object System.Drawing.Bitmap($ms)
    for ($y = 0; $y -lt $bmp.Height; $y++) {
        $line = ""
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            $px = $bmp.GetPixel($x, $y)
            # Usar canal alfa: opaco = bloque, transparente = espacio
            if ($px.A -gt 128) { $line += [char]0x2588 } else { $line += " " }
        }
        $SplashLines += $line
    }
    $bmp.Dispose(); $ms.Dispose()
} catch {}

foreach ($line in $SplashLines) {
    Write-Host $line -ForegroundColor White
}
Write-Host ""
Write-Host "                       Professional PC Toolkit  v15.0" -ForegroundColor Gray
Write-Host ""

$LoadSteps = @(
    @{Text = "  [1/6] Verificando privilegios de administrador...";     Color = "Cyan"},
    @{Text = "  [2/6] Cargando ensamblados de interfaz...";             Color = "Cyan"},
    @{Text = "  [3/6] Detectando hardware del sistema...";              Color = "Cyan"},
    @{Text = "  [4/6] Cargando enlaces de descarga...";               Color = "Cyan"},
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

# ============================================================================
#  TEMA SHADOWIEX - FORMAL DARK
# ============================================================================
$Global:Theme = @{
    BG           = [System.Drawing.Color]::FromArgb(30, 30, 30)
    Surface      = [System.Drawing.Color]::FromArgb(37, 37, 37)
    SurfaceLight = [System.Drawing.Color]::FromArgb(45, 50, 58)
    SurfaceHover = [System.Drawing.Color]::FromArgb(55, 62, 72)
    Primary      = [System.Drawing.Color]::FromArgb(55, 65, 81)
    PrimaryHover = [System.Drawing.Color]::FromArgb(71, 85, 105)
    Secondary    = [System.Drawing.Color]::FromArgb(45, 55, 72)
    Accent       = [System.Drawing.Color]::FromArgb(59, 130, 246)
    Success      = [System.Drawing.Color]::FromArgb(96, 165, 250)
    Warning      = [System.Drawing.Color]::FromArgb(148, 163, 184)
    Danger       = [System.Drawing.Color]::FromArgb(203, 213, 225)
    Info         = [System.Drawing.Color]::FromArgb(59, 130, 246)
    TextMain     = [System.Drawing.Color]::FromArgb(241, 245, 249)
    TextMuted    = [System.Drawing.Color]::FromArgb(156, 163, 175)
    TextDim      = [System.Drawing.Color]::FromArgb(100, 106, 115)
    Border       = [System.Drawing.Color]::FromArgb(45, 50, 60)
    Highlight    = [System.Drawing.Color]::FromArgb(96, 165, 250)
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

$Global:LogFile = Join-Path $env:TEMP "SHADOWIEX_log.txt"

# Icono ICO (el splash ya lo extrajo a TEMP)
$Global:IconPath = $null
$cachedIco = Join-Path $env:TEMP "SHADOWIEX_LOGO.ico"
$localIco = Join-Path $Global:ScriptDir "SHADOWIEX_LOGO.ico"
if (Test-Path $localIco) {
    $Global:IconPath = $localIco
} elseif (Test-Path $cachedIco) {
    $Global:IconPath = $cachedIco
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
$Global:ToolTip.BackColor = [System.Drawing.Color]::FromArgb(16, 16, 22)
$Global:ToolTip.ForeColor = [System.Drawing.Color]::FromArgb(241, 245, 249)
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
    if ($Global:MAS_File -and (Test-Path $Global:MAS_File) -and (Get-Item $Global:MAS_File).Length -gt 1KB) { return $Global:MAS_File }
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
    try { $searchPaths += Join-Path $env:USERPROFILE "Downloads\MAS_AIO.cmd" } catch {}
    foreach ($p in $searchPaths) {
        if ($p -and (Test-Path $p) -and (Get-Item $p).Length -gt 1KB) { $Global:MAS_File = $p; return $p }
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
            # Borrar archivo viejo si existe (evita usar archivo corrupto cacheado)
            if (Test-Path $dest) { Remove-Item -Force $dest }
            [Net.ServicePointManager]::SecurityProtocol = 3072
            (New-Object System.Net.WebClient).DownloadFile($url, $dest)
            # Verificar que el archivo se descargo correctamente (>1KB)
            if ((Test-Path $dest) -and (Get-Item $dest).Length -gt 1KB) {
                $Global:MAS_File = $dest
                Update-Status "MAS descargado ($( [math]::Round((Get-Item $dest).Length/1KB, 1) ) KB)" "success"
                Write-Log "MAS descargado a $dest"
                return $dest
            } else {
                Update-Status "Error: descarga incompleta o fallida" "error"
                Write-Log "Error: MAS descarga incompleta"
                if (Test-Path $dest) { Remove-Item -Force $dest }
                return $null
            }
        } catch { Update-Status "Error descargando MAS: $_" "error"; return $null }
    }
    return $null
}

function Invoke-MASInteractive { $f = Deploy-MAS; if ($f) { Start-Process "cmd.exe" -ArgumentList "/c `"$f`"" -Verb RunAs } }
function Invoke-MAS_HWID      { $f = Deploy-MAS; if ($f) {
    $tmpScript = Join-Path $env:TEMP "SHADOWIEX_RunMAS.cmd"
    "@echo off & chcp 65001 >nul & call `"$f`" /HWID & pause" | Out-File $tmpScript -Encoding ASCII -Force
    Start-Process "cmd.exe" -ArgumentList "/c `"$tmpScript`"" -Verb RunAs
}}
function Invoke-MAS_TSforge   { $f = Deploy-MAS; if ($f) {
    $tmpScript = Join-Path $env:TEMP "SHADOWIEX_RunMAS.cmd"
    "@echo off & chcp 65001 >nul & call `"$f`" /TSforge & pause" | Out-File $tmpScript -Encoding ASCII -Force
    Start-Process "cmd.exe" -ArgumentList "/c `"$tmpScript`"" -Verb RunAs
}}
function Invoke-MAS_Ohook     { $f = Deploy-MAS; if ($f) {
    $tmpScript = Join-Path $env:TEMP "SHADOWIEX_RunMAS.cmd"
    "@echo off & chcp 65001 >nul & call `"$f`" /Ohook & pause" | Out-File $tmpScript -Encoding ASCII -Force
    Start-Process "cmd.exe" -ArgumentList "/c `"$tmpScript`"" -Verb RunAs
}}
function Invoke-MAS_KMS       { $f = Deploy-MAS; if ($f) {
    $tmpScript = Join-Path $env:TEMP "SHADOWIEX_RunMAS.cmd"
    "@echo off & chcp 65001 >nul & call `"$f`" /KMS & pause" | Out-File $tmpScript -Encoding ASCII -Force
    Start-Process "cmd.exe" -ArgumentList "/c `"$tmpScript`"" -Verb RunAs
}}

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

# Helper: aplicar bordes redondeados a un control
function Set-RoundedRegion {
    param($Control, [int]$Radius = 8)
    $W = $Control.Width; $H = $Control.Height; $R = $Radius
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0, 0, $R, $R, 180, 90)
    $path.AddArc($W - $R, 0, $R, $R, 270, 90)
    $path.AddArc($W - $R, $H - $R, $R, $R, 0, 90)
    $path.AddArc(0, $H - $R, $R, $R, 90, 90)
    $path.CloseFigure()
    $Control.Region = New-Object System.Drawing.Region($path)
}

function New-Btn {
    param(
        [string]$Text, [int]$X, [int]$Y, [int]$W = 200, [int]$H = 38,
        [string]$Color = "Primary", [scriptblock]$Action = $null,
        [string]$Tooltip = ""
    )
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = $Text
    $Btn.Location = New-Object System.Drawing.Point($X, $Y)
    $Btn.Size = New-Object System.Drawing.Size($W, $H)
    $Btn.BackColor = $Global:Theme.Primary
    $Btn.ForeColor = [System.Drawing.Color]::White
    $Btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Btn.Font = $Global:Fonts.Button
    $Btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Btn.FlatAppearance.BorderSize = 0
    $Btn.FlatAppearance.MouseOverBackColor = $Global:Theme.PrimaryHover
    if ($Tooltip -ne "") { $Global:ToolTip.SetToolTip($Btn, $Tooltip) }
    if ($Action) { $Btn.Add_Click($Action) }
    Set-RoundedRegion -Control $Btn -Radius 6
    return $Btn
}

function New-Card {
    param([int]$X, [int]$Y, [int]$W = 240, [int]$H = 100)
    $Card = New-Object System.Windows.Forms.Panel
    $Card.Location = New-Object System.Drawing.Point($X, $Y)
    $Card.Size = New-Object System.Drawing.Size($W, $H)
    $Card.BackColor = $Global:Theme.Surface
    Set-RoundedRegion -Control $Card -Radius 8
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
function Test-ChocoDir { Test-Path 'C:\ProgramData\chocolatey' }

# Mapa de IDs winget -> nombre de paquete en Chocolatey.
# Chocolatey usa nombres distintos (normalmente en minusculas, sin el prefijo del publisher),
# por lo que no podemos reusar el ID de winget directamente al hacer fallback.
# NOTA: WhatsApp NO existe como paquete oficial en Chocolatey (solo wrappers de terceros),
# por eso no aparece aqui. Se instala via Microsoft Store con el ID 9NKSQGP7F2NH.
$Global:ChocoIDMap = @{
    "Google.Chrome"                          = "googlechrome"
    "Mozilla.Firefox"                        = "firefox"
    "Opera.Opera"                            = "opera"
    "Microsoft.Edge"                         = "microsoft-edge"
    "BraveSoftware.BraveBrowser"             = "brave"
    "Git.Git"                                = "git"
    "GitHub.GitHubDesktop"                   = "github-desktop"
    "Microsoft.VisualStudioCode"             = "vscode"
    "Notepad++.Notepad++"                    = "notepadplusplus"
    "Python.Python.3.12"                     = "python312"
    "VideoLAN.VLC"                           = "vlc"
    "GIMP.GIMP"                              = "gimp"
    "Spotify.Spotify"                        = "spotify"
    "OBSProject.OBSStudio"                   = "obs-studio"
    "Discord.Discord"                        = "discord"
    "Telegram.TelegramDesktop"               = "telegram"
    "Zoom.Zoom"                              = "zoom"
    "7zip.7zip"                              = "7zip"
    "RARLab.WinRAR"                          = "winrar"
    "Microsoft.PowerToys"                    = "powertoys"
    "voidtools.Everything"                   = "everything"
    "LibreOffice.LibreOffice"                = "libreoffice-fresh"
    "PDF24.PDF24Creator"                     = "pdf24"
    "SumatraPDF.SumatraPDF"                  = "sumatrapdf"
    "Malwarebytes.Malwarebytes"              = "malwarebytes"
    "Microsoft.VCRedist.2015+.x64"           = "vcredist140"
    "Microsoft.VCRedist.2015+.x86"           = "vcredist140"
    "Microsoft.DotNet.DesktopRuntime.8"      = "dotnet-8.0-desktopruntime"
}

# Tercer fallback: si ni winget ni choco funcionan, abrir la pagina oficial de descarga.
# Para apps que no tienen paquete oficial en ningun gestor (p.ej. WhatsApp en choco).
$Global:WebFallbackMap = @{
    "9NKSQGP7F2NH"                           = "https://www.whatsapp.com/download"
}

function Get-ChocoID($WingetID) {
    if ($Global:ChocoIDMap.ContainsKey($WingetID)) { return $Global:ChocoIDMap[$WingetID] }
    return $null
}

function Get-WebFallback($AppID) {
    if ($Global:WebFallbackMap.ContainsKey($AppID)) { return $Global:WebFallbackMap[$AppID] }
    return $null
}

# Detecta si un ID corresponde a Microsoft Store (Store IDs son alfanumericos
# en mayusculas de ~10-14 chars, sin punto). En ese caso winget requiere --source msstore.
function Test-IsStoreID($AppID) {
    return ($AppID -match '^[A-Z0-9]{10,}$')
}

# ============================================================================
#  FORMULARIO PRINCIPAL
# ============================================================================
$Global:Form = New-Object System.Windows.Forms.Form
$Global:Form.Text = "SHADOWIEX v15.0"
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
$HeaderPanel.Height = 55
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
$TitleLabel.ForeColor = $Global:Theme.TextMain
$HeaderPanel.Controls.Add($TitleLabel)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v15.0 Professional"
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

# ============================================================================
#  PANEL DE PESTANAS
# ============================================================================
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(0, 55)
$TabControl.Size = New-Object System.Drawing.Size(1100, 645)
$TabControl.BackColor = $Global:Theme.BG
$TabControl.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
$TabControl.ItemSize = New-Object System.Drawing.Size(120, 32)
$TabControl.Font = $Global:Fonts.Button
$TabControl.Padding = New-Object System.Drawing.Point(10, 4)

$TabDiag    = New-Object System.Windows.Forms.TabPage; $TabDiag.Text = "DIAGNOSTICO";  $TabDiag.BackColor = $Global:Theme.BG; $TabDiag.Padding = New-Object System.Windows.Forms.Padding(20)
$TabRepair  = New-Object System.Windows.Forms.TabPage; $TabRepair.Text = "REPARAR";     $TabRepair.BackColor = $Global:Theme.BG; $TabRepair.Padding = New-Object System.Windows.Forms.Padding(20)
$TabInstall = New-Object System.Windows.Forms.TabPage; $TabInstall.Text = "INSTALAR";    $TabInstall.BackColor = $Global:Theme.BG; $TabInstall.Padding = New-Object System.Windows.Forms.Padding(20)
$TabAct     = New-Object System.Windows.Forms.TabPage; $TabAct.Text = "ACTIVAR";      $TabAct.BackColor = $Global:Theme.BG; $TabAct.Padding = New-Object System.Windows.Forms.Padding(20)
$TabTweaks  = New-Object System.Windows.Forms.TabPage; $TabTweaks.Text = "OPTIMIZAR";   $TabTweaks.BackColor = $Global:Theme.BG; $TabTweaks.Padding = New-Object System.Windows.Forms.Padding(20)
$TabConfig  = New-Object System.Windows.Forms.TabPage; $TabConfig.Text = "CONFIG";       $TabConfig.BackColor = $Global:Theme.BG; $TabConfig.Padding = New-Object System.Windows.Forms.Padding(20)

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

    # Ventana modal "Procesando..."
    $DiagPF = New-Object System.Windows.Forms.Form
    $DiagPF.Text = "SHADOWIEX - Diagnostico"
    $DiagPF.Size = New-Object System.Drawing.Size(360, 130)
    $DiagPF.BackColor = $Global:Theme.BG
    $DiagPF.StartPosition = "CenterParent"
    $DiagPF.FormBorderStyle = "FixedDialog"
    $DiagPF.ControlBox = $false
    $DiagPF.TopMost = $true
    $DiagPF.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Procesando diagnostico..."; Location = New-Object System.Drawing.Point(30, 25)
        Size = New-Object System.Drawing.Size(300, 24); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextMain
    }))
    $DiagPF.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "Esto puede tardar unos segundos."; Location = New-Object System.Drawing.Point(30, 55)
        Size = New-Object System.Drawing.Size(300, 18); Font = $Global:Fonts.Small; ForeColor = $Global:Theme.TextMuted
    }))
    # Spinner bar animada
    $DiagBarTrack = New-Object System.Windows.Forms.Panel
    $DiagBarTrack.Location = New-Object System.Drawing.Point(30, 82)
    $DiagBarTrack.Size = New-Object System.Drawing.Size(300, 6)
    $DiagBarTrack.BackColor = $Global:Theme.Surface
    $DiagPF.Controls.Add($DiagBarTrack)
    $DiagBarFill = New-Object System.Windows.Forms.Panel
    $DiagBarFill.Location = New-Object System.Drawing.Point(0, 0)
    $DiagBarFill.Size = New-Object System.Drawing.Size(0, 6)
    $DiagBarFill.BackColor = $Global:Theme.Primary
    $DiagBarTrack.Controls.Add($DiagBarFill)
    $DiagPF.Show()
    [System.Windows.Forms.Application]::DoEvents()

    $DiagStep = 0; $DiagTotal = 10; $DiagBarW = 300

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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
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
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
    [System.Windows.Forms.Application]::DoEvents()

    # Startup
    $outputBox.Text += "[PROGRAMAS DE INICIO]`r`n"
    $Startups = Get-CimInstance Win32_StartupCommand
    foreach ($S in $Startups) { $outputBox.Text += "  $($S.Name)`r`n" }
    $outputBox.Text += "`r`n"
    $DiagStep++; $DiagBarFill.Size = New-Object System.Drawing.Size([math]::Floor($DiagStep/$DiagTotal*$DiagBarW), 6)
    [System.Windows.Forms.Application]::DoEvents()

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

    # Cerrar ventana de procesando
    $DiagBarFill.Size = New-Object System.Drawing.Size($DiagBarW, 6)
    [System.Windows.Forms.Application]::DoEvents()
    $DiagPF.Close()

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
$cardW = 258; $cardH = 75; $cardGap = 10

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

$InstallLeftPanel.Controls.Add((New-SectionTitle -Text "GESTOR DE PAQUETES" -X 10 -Y 5 -W 300))

# --- Estado de winget y choco con botones de instalacion ---
$PkgY = 35
$HasW = Test-Winget; $HasC = Test-Choco; $HasCDir = Test-ChocoDir

# Winget status card
$WCard = New-Object System.Windows.Forms.Panel
$WCard.Location = New-Object System.Drawing.Point(10, $PkgY)
$WCard.Size = New-Object System.Drawing.Size(260, 55)
$WCard.BackColor = $Global:Theme.SurfaceLight
$InstallLeftPanel.Controls.Add($WCard)
$WCard.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "WINGET"; Location = New-Object System.Drawing.Point(10, 4)
    Size = New-Object System.Drawing.Size(80, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim
}))
$WStatusText = if ($HasW) { "Instalado" } else { "No encontrado" }
$WStatusColor = if ($HasW) { $Global:Theme.Success } else { $Global:Theme.Danger }
$WCard.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $WStatusText; Location = New-Object System.Drawing.Point(90, 5)
    Size = New-Object System.Drawing.Size(90, 16); Font = $Global:Fonts.Small; ForeColor = $WStatusColor
}))
if (-not $HasW) {
    $InstWBtn = New-Btn -Text "INSTALAR" -X 185 -Y 2 -W 65 -H 24 -Color "Primary"
    $InstWBtn.Font = $Global:Fonts.Small
    $InstWBtn.Add_Click({
        Update-Status "Instalando winget..."
        try {
            $WingetScript = @'
$progressPreference = 'silently'
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $env:TEMP\Microsoft.DesktopAppInstaller.msixbundle
Add-AppxPackage -Path $env:TEMP\Microsoft.DesktopAppInstaller.msixbundle
'@
            $WingetScript | Out-File (Join-Path $env:TEMP "SHADOWIEX_Winget.ps1") -Force
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:TEMP\SHADOWIEX_Winget.ps1`"" -Verb RunAs -Wait
            Update-Status "winget instalado - reinicia SHADOWIEX" "success"
            Write-Log "winget instalado"
        } catch { Update-Status "Error instalando winget" "error" }
    })
    $WCard.Controls.Add($InstWBtn)
}
$WCard.Controls.Add((New-DescLabel -Text "Gestor de paquetes de Microsoft" -X 10 -Y 28 -W 235 -H 16))

# Choco status card
$CCard = New-Object System.Windows.Forms.Panel
$CCard.Location = New-Object System.Drawing.Point(280, $PkgY)
$CCard.Size = New-Object System.Drawing.Size(265, 55)
$CCard.BackColor = $Global:Theme.SurfaceLight
$InstallLeftPanel.Controls.Add($CCard)
$CCard.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "CHOCOLATEY"; Location = New-Object System.Drawing.Point(10, 4)
    Size = New-Object System.Drawing.Size(100, 18); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim
}))
if ($HasC) { $CStatusText = "Instalado"; $CStatusColor = $Global:Theme.Success } elseif ($HasCDir) { $CStatusText = "Roto"; $CStatusColor = $Global:Theme.Warning } else { $CStatusText = "No encontrado"; $CStatusColor = $Global:Theme.Danger }
$CCard.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = $CStatusText; Location = New-Object System.Drawing.Point(110, 5)
    Size = New-Object System.Drawing.Size(90, 16); Font = $Global:Fonts.Small; ForeColor = $CStatusColor
}))
if (-not $HasC) {
    $CBtnText = if ($HasCDir) { "REPARAR" } else { "INSTALAR" }
    $InstCBtn = New-Btn -Text $CBtnText -X 195 -Y 2 -W 75 -H 24 -Color "Primary"
    $InstCBtn.Font = $Global:Fonts.Small
    $CIsBroken = $HasCDir
    $InstCBtn.Add_Click({
        if ($CIsBroken) {
            Update-Status "Reparando Chocolatey..."
            try {
                $ChocoScript = @'
if (Test-Path 'C:\ProgramData\chocolatey') { Remove-Item -Recurse -Force 'C:\ProgramData\chocolatey' }
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
'@
                $ChocoScript | Out-File (Join-Path $env:TEMP "SHADOWIEX_Choco.ps1") -Force
                Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:TEMP\SHADOWIEX_Choco.ps1`"" -Verb RunAs -Wait
                Update-Status "Chocolatey reparado - reinicia SHADOWIEX" "success"
                Write-Log "Chocolatey reparado"
            } catch { Update-Status "Error reparando Chocolatey" "error" }
        } else {
            Update-Status "Instalando Chocolatey..."
            try {
                $ChocoScript = @'
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
'@
                $ChocoScript | Out-File (Join-Path $env:TEMP "SHADOWIEX_Choco.ps1") -Force
                Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:TEMP\SHADOWIEX_Choco.ps1`"" -Verb RunAs -Wait
                Update-Status "Chocolatey instalado - reinicia SHADOWIEX" "success"
                Write-Log "Chocolatey instalado"
            } catch { Update-Status "Error instalando Chocolatey" "error" }
        }
    }.GetNewClosure())
    $CCard.Controls.Add($InstCBtn)
}
$CCard.Controls.Add((New-DescLabel -Text "Gestor de paquetes alternativo" -X 10 -Y 28 -W 250 -H 16))

# --- Lista de programas ---
$PkgY = 92
$InstallLeftPanel.Controls.Add((New-SectionTitle -Text "PROGRAMAS DISPONIBLES" -X 10 -Y $PkgY -W 300))
$PkgY += 28

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
        @{ID="9NKSQGP7F2NH"; Name="WhatsApp"},
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
$YPos = $PkgY

foreach ($Cat in $SoftwareData.Keys) {
    $CatPanel = New-Object System.Windows.Forms.Panel
    $CatPanel.Location = New-Object System.Drawing.Point(5, $YPos)
    $CatPanel.Size = New-Object System.Drawing.Size(535, 22)
    $CatPanel.BackColor = $Global:Theme.Surface
    $InstallLeftPanel.Controls.Add($CatPanel)
    $CatLabel = New-Object System.Windows.Forms.Label
    $CatLabel.Text = "  $Cat"
    $CatLabel.Location = New-Object System.Drawing.Point(2, 1)
    $CatLabel.Size = New-Object System.Drawing.Size(300, 18)
    $CatLabel.Font = $Global:Fonts.Header
    $CatLabel.ForeColor = $Global:Theme.TextDim
    $CatPanel.Controls.Add($CatLabel)

    $YPos += 25
    $XPos = 12
    foreach ($App in $SoftwareData[$Cat]) {
        $CB = New-Object System.Windows.Forms.CheckBox
        $CB.Text = $App.Name
        $CB.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CB.Size = New-Object System.Drawing.Size(168, 20)
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
        $XPos += 172
        if ($XPos -gt 520) { $XPos = 12; $YPos += 22 }
    }
    $YPos += 28
}

# --- Panel derecho ---
$InstallRightPanel = New-Object System.Windows.Forms.Panel
$InstallRightPanel.Location = New-Object System.Drawing.Point(565, 0)
$InstallRightPanel.Size = New-Object System.Drawing.Size(510, 580)
$InstallRightPanel.AutoScroll = $true
$InstallRightPanel.BackColor = $Global:Theme.Surface
$TabInstall.Controls.Add($InstallRightPanel)

$InstallRightPanel.Controls.Add((New-SectionTitle -Text "ACCIONES" -X 15 -Y 10 -W 200))

# --- Ruta de descarga ---
$DlPathLabel = New-Object System.Windows.Forms.Label
$DlPathLabel.Text = "Ruta de descarga:"
$DlPathLabel.Location = New-Object System.Drawing.Point(15, 36)
$DlPathLabel.Size = New-Object System.Drawing.Size(120, 18)
$DlPathLabel.Font = $Global:Fonts.Small
$DlPathLabel.ForeColor = $Global:Theme.TextDim
$InstallRightPanel.Controls.Add($DlPathLabel)

$Global:DownloadPath = [Environment]::GetFolderPath('Desktop')
$DlPathBox = New-Object System.Windows.Forms.TextBox
$DlPathBox.Text = $Global:DownloadPath
$DlPathBox.Location = New-Object System.Drawing.Point(15, 54)
$DlPathBox.Size = New-Object System.Drawing.Size(350, 22)
$DlPathBox.Font = $Global:Fonts.Small
$DlPathBox.ForeColor = $Global:Theme.TextMain
$DlPathBox.BackColor = $Global:Theme.Surface
$DlPathBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$InstallRightPanel.Controls.Add($DlPathBox)

$BrowseBtn = New-Btn -Text "..." -X 370 -Y 52 -W 40 -H 26 -Color "Secondary"
$BrowseBtn.Font = $Global:Fonts.Small
$BrowseBtn.Add_Click({
    $FBD = New-Object System.Windows.Forms.FolderBrowserDialog
    $FBD.Description = "Selecciona donde guardar las descargas"
    $FBD.SelectedPath = $Global:DownloadPath
    if ($FBD.ShowDialog() -eq 'OK') {
        $Global:DownloadPath = $FBD.SelectedPath
        $DlPathBox.Text = $FBD.SelectedPath
        Write-Log "Ruta de descarga: $($FBD.SelectedPath)"
    }
})
$InstallRightPanel.Controls.Add($BrowseBtn)

# --- Contador y botones ---
$Global:CountLabel = New-Object System.Windows.Forms.Label
$Global:CountLabel.Text = "0 seleccionados"
$Global:CountLabel.Location = New-Object System.Drawing.Point(420, 36)
$Global:CountLabel.Size = New-Object System.Drawing.Size(70, 18)
$Global:CountLabel.Font = $Global:Fonts.Small
$Global:CountLabel.ForeColor = $Global:Theme.TextMuted
$Global:CountLabel.TextAlign = "MiddleRight"
$InstallRightPanel.Controls.Add($Global:CountLabel)

$Global:AllChecked = $false
$ToggleBtn = New-Btn -Text "SELECCIONAR TODO" -X 415 -Y 54 -W 90 -H 24 -Color "Secondary"
$ToggleBtn.Font = $Global:Fonts.Small
$ToggleBtn.Add_Click({
    $Global:AllChecked = -not $Global:AllChecked
    $ToggleBtn.Text = if ($Global:AllChecked) { "QUITAR TODO" } else { "SELECC.TODO" }
    foreach ($CB in $Global:AllCheckboxes) { $CB.Checked = $Global:AllChecked }
})
$InstallRightPanel.Controls.Add($ToggleBtn)

$InstallBtn = New-Btn -Text "INSTALAR SELECCIONADOS" -X 15 -Y 84 -W 220 -H 34 -Color "Success"
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
    $ProgF.Size = New-Object System.Drawing.Size(520, 230)
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
    $CancelBtn = New-Btn -Text "CANCELAR" -X 400 -Y 178 -W 100 -H 34 -Color "Danger"
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
            # Si el ID es de Microsoft Store, hay que indicar --source msstore
            $WingetArgs = @("install","--id",$AppID,"--accept-source-agreements","--accept-package-agreements","-h")
            if (Test-IsStoreID $AppID) {
                $WingetArgs += @("--source","msstore")
                $ProgDetail.Text = "Instalando desde Microsoft Store..."
                [System.Windows.Forms.Application]::DoEvents()
            }
            try { $Proc = Start-Process "winget" -ArgumentList $WingetArgs -NoNewWindow -PassThru -Wait -EA 0; if ($Proc.ExitCode -eq 0) { $Installed = $true } } catch {}
        }
        if (-not $Installed -and $HasChoco) {
            $ChocoID = Get-ChocoID $AppID
            if ($ChocoID) {
                $ProgDetail.Text = "Intentando via chocolatey ($ChocoID)..."
                [System.Windows.Forms.Application]::DoEvents()
                try { $Proc = Start-Process "choco" -ArgumentList "install",$ChocoID,"-y","--force" -NoNewWindow -PassThru -Wait -EA 0; if ($Proc.ExitCode -eq 0) { $Installed = $true } } catch {}
            } else {
                Write-Log "No hay mapeo choco para '$AppID' - se omite fallback choco"
            }
        }
        # Tercer fallback: abrir la pagina oficial de descarga en el navegador
        if (-not $Installed) {
            $WebURL = Get-WebFallback $AppID
            if ($WebURL) {
                $ProgDetail.Text = "Abriendo pagina de descarga oficial..."
                $ProgDetail.ForeColor = $Global:Theme.Warning
                [System.Windows.Forms.Application]::DoEvents()
                try {
                    Start-Process $WebURL
                    Write-Log "Abierta pagina de descarga para '$AppName': $WebURL"
                    $ProgDetail.Text = "Pagina oficial abierta"
                    # No marcamos como Installed=true porque el usuario debe instalar manualmente,
                    # pero tampoco lo contamos como fallo completo.
                    $Fail--   # descontamos el fallo que se va a sumar abajo
                } catch {
                    Write-Log "Error abriendo pagina para '$AppName': $_"
                }
            }
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

# --- DESCARGAS DIRECTAS: OFFICE C2R (ES-MX) + OPTIMIZER ---
$DlY = 126
$InstallRightPanel.Controls.Add((New-SectionTitle -Text "OFFICE C2R - ESPANOL MEXICO" -X 15 -Y $DlY -W 400))
$DlY += 24
$InstallRightPanel.Controls.Add((New-DescLabel -Text "Enlaces oficiales Microsoft via massgrave.dev (es-MX)" -X 15 -Y $DlY -W 460))
$DlY += 22

# Datos de Office organizados por version (solo x64, los mas utiles)
$OfficeDownloads = @{
    "Microsoft 365" = @(
        @{Name="Microsoft 365 Apps (ProPlus)"; PID="O365ProPlusRetail"},
        @{Name="Microsoft 365 Business"; PID="O365BusinessRetail"},
        @{Name="Microsoft 365 Familia"; PID="O365HomePremRetail"},
        @{Name="Microsoft 365 Education"; PID="O365EduCloudRetail"}
    )
    "Office 2024" = @(
        @{Name="Office 2024 Profesional Plus"; PID="ProPlus2024Retail"},
        @{Name="Office 2024 Hogar"; PID="Home2024Retail"},
        @{Name="Office 2024 Hogar y Negocio"; PID="HomeBusiness2024Retail"}
    )
    "Office 2021" = @(
        @{Name="Office 2021 Profesional Plus"; PID="ProPlus2021Retail"},
        @{Name="Office 2021 Profesional"; PID="Professional2021Retail"},
        @{Name="Office 2021 Hogar y Estudiantes"; PID="HomeStudent2021Retail"},
        @{Name="Office 2021 Personal"; PID="Personal2021Retail"}
    )
    "Office 2019" = @(
        @{Name="Office 2019 Profesional Plus"; PID="ProPlus2019Retail"},
        @{Name="Office 2019 Profesional"; PID="Professional2019Retail"},
        @{Name="Office 2019 Hogar y Estudiantes"; PID="HomeStudent2019Retail"}
    )
    "Office 2016" = @(
        @{Name="Office 2016 Profesional Plus"; PID="ProPlusRetail"},
        @{Name="Office 2016 Profesional"; PID="ProfessionalRetail"},
        @{Name="Office 2016 Hogar y Estudiantes"; PID="HomeStudentRetail"}
    )
}

foreach ($Ver in $OfficeDownloads.Keys) {
    # Version header
    $VerPanel = New-Object System.Windows.Forms.Panel
    $VerPanel.Location = New-Object System.Drawing.Point(15, $DlY)
    $VerPanel.Size = New-Object System.Drawing.Size(470, 22)
    $VerPanel.BackColor = $Global:Theme.Surface
    Set-RoundedRegion -Control $VerPanel -Radius 6
    $InstallRightPanel.Controls.Add($VerPanel)
    $VerPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
        Text = "  $Ver"; Location = New-Object System.Drawing.Point(2, 1)
        Size = New-Object System.Drawing.Size(300, 16); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim
    }))
    $DlY += 23

    foreach ($Item in $OfficeDownloads[$Ver]) {
        $Card = New-Object System.Windows.Forms.Panel
        $Card.Location = New-Object System.Drawing.Point(15, $DlY)
        $Card.Size = New-Object System.Drawing.Size(470, 36)
        $Card.BackColor = $Global:Theme.SurfaceLight
        Set-RoundedRegion -Control $Card -Radius 6
        $InstallRightPanel.Controls.Add($Card)

        $Card.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
            Text = $Item.Name; Location = New-Object System.Drawing.Point(10, 7)
            Size = New-Object System.Drawing.Size(290, 20); Font = $Global:Fonts.Normal; ForeColor = $Global:Theme.TextMain
        }))

        # Capturar variables para closure
        $DL_PID = $Item.PID
        $DL_Name = $Item.Name

        $DLBtn = New-Btn -Text "DESCARGAR" -X 375 -Y 2 -W 88 -H 28 -Color "Primary"
        $DLBtn.Font = $Global:Fonts.Small
        $DLBtn.Add_Click({
            $Url = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=$($DL_PID)&platform=x64&language=es-mx&version=O16GA"
            $DestPath = Join-Path $Global:DownloadPath "$($DL_PID)_x64_es-mx.exe"
            Update-Status "Descargando $($DL_Name)..."
            Write-Log "Descarga Office: $($DL_Name) ($($DL_PID))"
            try {
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                $WC = New-Object System.Net.WebClient
                $WC.DownloadFile($Url, $DestPath)
                Update-Status "Descargado: $($DL_Name) - ejecutando..." "success"
                Write-Log "Ejecutando: $DestPath"
                Start-Process $DestPath -Verb RunAs
            } catch {
                Update-Status "Error descargando $($DL_Name)" "error"
                [System.Windows.Forms.MessageBox]::Show("Error al descargar:`n$($_.Exception.Message)", "SHADOWIEX - Error")
            }
        }.GetNewClosure())
        $Card.Controls.Add($DLBtn)
        $DlY += 38
    }
    $DlY += 4
}

# --- OPTIMIZER ---
$DlY += 2
$InstallRightPanel.Controls.Add((New-Object System.Windows.Forms.Panel -Property @{
    Location = New-Object System.Drawing.Point(15, $DlY)
    Size = New-Object System.Drawing.Size(470, 1)
    BackColor = $Global:Theme.Border
}))
$DlY += 8
$InstallRightPanel.Controls.Add((New-SectionTitle -Text "HERRAMIENTAS EXTRAS" -X 15 -Y $DlY -W 300))
$DlY += 24

$OptCard = New-Object System.Windows.Forms.Panel
$OptCard.Location = New-Object System.Drawing.Point(15, $DlY)
$OptCard.Size = New-Object System.Drawing.Size(470, 42)
$OptCard.BackColor = $Global:Theme.SurfaceLight
Set-RoundedRegion -Control $OptCard -Radius 6
$InstallRightPanel.Controls.Add($OptCard)
$OptCard.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
    Text = "Optimizer v16.7 (github.com/hellzerg)"; Location = New-Object System.Drawing.Point(10, 3)
    Size = New-Object System.Drawing.Size(320, 18); Font = $Global:Fonts.Normal; ForeColor = $Global:Theme.TextMain
}))
$OptCard.Controls.Add((New-DescLabel -Text "Optimizador de Windows - Limpieza y rendimiento" -X 10 -Y 21 -W 320 -H 16))

$OptBtn = New-Btn -Text "DESCARGAR" -X 375 -Y 4 -W 88 -H 30 -Color "Accent"
$OptBtn.Font = $Global:Fonts.Small
$OptBtn.Add_Click({
    $OptUrl = "https://github.com/hellzerg/optimizer/releases/download/16.7/Optimizer-16.7.exe"
    $OptDest = Join-Path $Global:DownloadPath "Optimizer-16.7.exe"
    Update-Status "Descargando Optimizer v16.7..."
    Write-Log "Descarga: Optimizer v16.7"
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $WC = New-Object System.Net.WebClient
        $WC.DownloadFile($OptUrl, $OptDest)
        Update-Status "Optimizer descargado - ejecutando..." "success"
        Write-Log "Ejecutando: $OptDest"
        Start-Process $OptDest -Verb RunAs
    } catch {
        Update-Status "Error descargando Optimizer" "error"
        [System.Windows.Forms.MessageBox]::Show("Error al descargar:`n$($_.Exception.Message)", "SHADOWIEX - Error")
    }
})
$OptCard.Controls.Add($OptBtn)

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
$InfoPanel.Controls.Add((New-DescLabel -Text "Distribuir Shadowiex.ps1 junto con MAS_AIO.cmd | Descargas Office directo desde Microsoft (es-MX)" -X 15 -Y 28 -W 720 -H 16))

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
    @{Name="CHRIS TITUS TOOL"; Desc="Herramienta de optimizacion de Chris Titus"; Color="Primary"; Action={
        Update-Status "Lanzando Chris Titus WinUtil..."
        try {
            Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm christitus.com/win | iex"' -Verb RunAs
            Update-Status "Chris Titus Tool lanzado" "success"; Write-Log "Chris Titus Tool lanzado"
        } catch { Update-Status "Error lanzando Chris Titus Tool" "error" }
    }},
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

# --- Seccion: REMOVER ANTIVIRUS ---
$AVSectionY = if ($TCol -eq 0) { $TweakY } else { $TweakY + 98 }
$AVSectionY += 15
$TweakScroll.Controls.Add((New-SectionTitle -Text "REMOVER ANTIVIRUS (DESINSTALACION FORZADA)" -X 15 -Y $AVSectionY))

$AVTools = @(
    @{Name="AVAST CLEAR"; Desc="Desinstalacion forzada de Avast (Modo Seguro recomendado)"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "AVAST CLEAR - Desinstalador oficial forzado`n`nAVISO: Se recomienda reiniciar en Modo Seguro antes de ejecutar.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando Avast Clear..."
            $avDest = Join-Path $env:TEMP "SHADOWIEX_avast_clear.exe"
            try {
                if (Test-Path $avDest) { Remove-Item -Force $avDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                # URL oficial desde la pagina de soporte de Avast
                (New-Object System.Net.WebClient).DownloadFile("https://honzik.avcdn.net/setup/avast-av/release/avast_av_clear.exe", $avDest)
                if ((Test-Path $avDest) -and (Get-Item $avDest).Length -gt 100KB) {
                    Update-Status "Avast Clear descargado - ejecutando..." "success"; Write-Log "Avast Clear ejecutado"
                    Start-Process $avDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $avDest) { Remove-Item -Force $avDest }
                Write-Log "Avast Clear fallback a pagina oficial"
                Start-Process "https://www.avast.com/en-us/uninstall-utility"
            }
        }
    }},
    @{Name="AVG CLEAR"; Desc="Desinstalacion forzada de AVG Antivirus"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "AVG CLEAR - Desinstalador oficial forzado`n`nAVISO: Se recomienda reiniciar en Modo Seguro antes de ejecutar.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando AVG Clear..."
            $avgDest = Join-Path $env:TEMP "SHADOWIEX_avg_clear.exe"
            try {
                if (Test-Path $avgDest) { Remove-Item -Force $avgDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                (New-Object System.Net.WebClient).DownloadFile("https://honzik.avcdn.net/setup/avast-av/release/avast_av_clear.exe", $avgDest)
                if ((Test-Path $avgDest) -and (Get-Item $avgDest).Length -gt 100KB) {
                    Update-Status "AVG Clear descargado - ejecutando..." "success"; Write-Log "AVG Clear ejecutado"
                    Start-Process $avgDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $avgDest) { Remove-Item -Force $avgDest }
                Write-Log "AVG Clear fallback a pagina oficial"
                Start-Process "https://support.avg.com/SupportArticle/virus-removal-tool"
            }
        }
    }},
    @{Name="MCAFEE MCPR"; Desc="McAfee Consumer Product Removal Tool"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "MCAFEE MCPR - Herramienta de remocion oficial`n`nEste proceso eliminara completamente McAfee del sistema.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando McAfee MCPR..."
            $mcDest = Join-Path $env:TEMP "SHADOWIEX_MCPR.exe"
            try {
                if (Test-Path $mcDest) { Remove-Item -Force $mcDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                (New-Object System.Net.WebClient).DownloadFile("https://download.mcafee.com/molbin/aff/landingpages/mcpr/MCPR.exe", $mcDest)
                if ((Test-Path $mcDest) -and (Get-Item $mcDest).Length -gt 100KB) {
                    Update-Status "McAfee MCPR descargado - ejecutando..." "success"; Write-Log "McAfee MCPR ejecutado"
                    Start-Process $mcDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $mcDest) { Remove-Item -Force $mcDest }
                Write-Log "McAfee MCPR fallback a pagina oficial"
                Start-Process "https://service.mcafee.com/webcenter/portal/McAfee/article/TS101331"
            }
        }
    }},
    @{Name="KASPERSKY REMOVE"; Desc="kavremover - Herramienta oficial de Kaspersky"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "KASPERSKY KAVREMOVER - Herramienta de remocion oficial`n`nEste proceso eliminara completamente Kaspersky del sistema.`nPuede requerir reinicio.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando Kaspersky kavremover..."
            $ksDest = Join-Path $env:TEMP "SHADOWIEX_kavremover.exe"
            try {
                if (Test-Path $ksDest) { Remove-Item -Force $ksDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                (New-Object System.Net.WebClient).DownloadFile("https://media.kaspersky.com/utilities/VirusUtilities/EN/kavremover.exe", $ksDest)
                if ((Test-Path $ksDest) -and (Get-Item $ksDest).Length -gt 100KB) {
                    Update-Status "Kaspersky kavremover descargado - ejecutando..." "success"; Write-Log "Kaspersky kavremover ejecutado"
                    Start-Process $ksDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $ksDest) { Remove-Item -Force $ksDest }
                Write-Log "Kaspersky kavremover fallback a pagina oficial"
                Start-Process "https://support.kaspersky.com/common/uninstall/1464"
            }
        }
    }},
    @{Name="NORTON REMOVE"; Desc="Norton Remove and Reinstall Tool"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "NORTON REMOVE AND REINSTALL - Herramienta oficial`n`nEste proceso eliminara completamente Norton del sistema.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando Norton Remove..."
            $nrDest = Join-Path $env:TEMP "SHADOWIEX_Norton_Removal.exe"
            try {
                if (Test-Path $nrDest) { Remove-Item -Force $nrDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                (New-Object System.Net.WebClient).DownloadFile("https://service.symantec.com/EXTERNAL/fresh/dispatch-main/v1/asset/nrntool/latest", $nrDest)
                if ((Test-Path $nrDest) -and (Get-Item $nrDest).Length -gt 100KB) {
                    Update-Status "Norton Remove descargado - ejecutando..." "success"; Write-Log "Norton Remove ejecutado"
                    Start-Process $nrDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $nrDest) { Remove-Item -Force $nrDest }
                Write-Log "Norton Remove fallback a pagina oficial"
                Start-Process "https://support.norton.com/sp/en/us/home/current/solutions/v93402178_EndUserProfile_en_us"
            }
        }
    }},
    @{Name="ESET REMOVER"; Desc="ESET Uninstaller Tool oficial"; Color="Danger"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show(
            "ESET UNINSTALLER - Herramienta de remocion oficial`n`nEste proceso eliminara completamente productos ESET del sistema.`nPuede requerir reinicio en Modo Seguro.`n`nDeseas continuar?",
            "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($R -eq 6) {
            Update-Status "Descargando ESET Uninstaller..."
            $esDest = Join-Path $env:TEMP "SHADOWIEX_ESET_Uninstaller.exe"
            try {
                if (Test-Path $esDest) { Remove-Item -Force $esDest }
                [Net.ServicePointManager]::SecurityProtocol = 3072
                (New-Object System.Net.WebClient).DownloadFile("https://download.eset.com/com/eset/tools/uninstaller/ESETUninstaller.exe", $esDest)
                if ((Test-Path $esDest) -and (Get-Item $esDest).Length -gt 100KB) {
                    Update-Status "ESET Uninstaller descargado - ejecutando..." "success"; Write-Log "ESET Uninstaller ejecutado"
                    Start-Process $esDest -Verb RunAs
                } else { throw "descarga incompleta" }
            } catch {
                Update-Status "Descarga directa fallida - abriendo pagina oficial..." "warning"
                if (Test-Path $esDest) { Remove-Item -Force $esDest }
                Write-Log "ESET Uninstaller fallback a pagina oficial"
                Start-Process "https://support.eset.com/en/kb141/install-eset-uninstaller-tool"
            }
        }
    }}
)

$AVY = $AVSectionY + 30; $AVX = 15; $AVCol = 0
foreach ($AV in $AVTools) {
    $Card = New-Card -X $AVX -Y $AVY -W 248 -H 90
    $TweakScroll.Controls.Add($Card)
    $Btn = New-Btn -Text $AV.Name -X 10 -Y 10 -W 228 -H 36 -Color $AV.Color
    $CurrAVAction = $AV.Action
    $Btn.Add_Click({ & $CurrAVAction }.GetNewClosure())
    $Card.Controls.Add($Btn)
    $Card.Controls.Add((New-DescLabel -Text $AV.Desc -X 10 -Y 55 -W 228 -H 18))
    $AVCol++
    if ($AVCol -ge 4) { $AVCol = 0; $AVX = 15; $AVY += 98 } else { $AVX += 256 }
}

# --- Seccion: REMOVER OFFICE ---
$OfficeSectionY = if ($AVCol -eq 0) { $AVY } else { $AVY + 98 }
$OfficeSectionY += 15
$TweakScroll.Controls.Add((New-SectionTitle -Text "REMOVER OFFICE (DESINSTALACION FORZADA)" -X 15 -Y $OfficeSectionY))

$OfficeRemoveY = $OfficeSectionY + 30
# Card 1: Force Clean
$OC1 = New-Card -X 15 -Y $OfficeRemoveY -W 248 -H 90
$TweakScroll.Controls.Add($OC1)
$BtnOC1 = New-Btn -Text "OFFICE FORCE CLEAN" -X 10 -Y 10 -W 228 -H 36 -Color "Danger"
$BtnOC1.Add_Click({
    $R = [System.Windows.Forms.MessageBox]::Show(
        "OFFICE FORCE CLEAN - Desinstalacion forzada de Microsoft Office`n`nEste proceso eliminara TODAS las instalaciones de Office (C2R y MSI),`nlimpiara registros y archivos residuales.`n`nAVISO: Se requiere reinicio despues del proceso.`n`nDeseas continuar?",
        "SHADOWIEX", 4, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($R -eq 6) {
        Update-Status "Generando script de limpieza Office..."
        try {
            $scriptContent = @'
# SHADOWIEX - Office Force Clean v1.0
$Host.UI.RawUI.WindowTitle = "SHADOWIEX - Office Force Clean"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SHADOWIEX - Office Force Clean" -ForegroundColor Cyan
Write-Host "  Desinstalacion forzada de Office" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- PASO 1: Cerrar procesos de Office ---
Write-Host "[1/7] Cerrando procesos de Office..." -ForegroundColor Yellow
$officeProcs = @("WINWORD","EXCEL","OUTLOOK","POWERPNT","MSACCESS","ONENOTE","MSPUB","MSQUERY",
                 "LYNC","SKYPE","TEAMS","CLICKTORUN","OFFICETELEMETRY","MSOSYNC","GROOVE",
                 "ONEDRIVE","WINPROJ","VISIO","MSMPENG","MSASCUI","SECHEALTH")
$killed = 0
$officeProcs | ForEach-Object {
    try { $p = Get-Process -Name $_ -EA 0; if ($p) { Stop-Process -Name $_ -Force -EA 0; $killed++ } } catch {}
}
Start-Sleep -Seconds 2
Write-Host "  Procesos cerrados: $killed" -ForegroundColor Gray

# --- PASO 2: Detener servicios de Office ---
Write-Host "[2/7] Deteniendo servicios de Office..." -ForegroundColor Yellow
$officeSvcs = @("ClickToRunSvc","osppsvc","OfficeSvc","ose64","ose")
$officeSvcs | ForEach-Object {
    try { Stop-Service -Name $_ -Force -EA 0; Set-Service -Name $_ -StartupType Disabled -EA 0 } catch {}
}
Start-Sleep -Seconds 1

# --- PASO 3: Desinstalar Office ClickToRun ---
Write-Host "[3/7] Desinstalando Office ClickToRun..." -ForegroundColor Yellow
$ctrExe = "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
if (Test-Path $ctrExe) {
    Write-Host "  C2R detectado: $ctrExe" -ForegroundColor Gray
    try {
        Stop-Process -Name "OfficeClickToRun" -Force -EA 0
        Start-Sleep -Seconds 2
        # Leer productos instalados
        $regPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
        if (Test-Path $regPath) {
            $products = (Get-ItemProperty $regPath -EA 0).ProductReleaseIds
            if ($products) {
                Write-Host "  Productos C2R: $products" -ForegroundColor Gray
            }
        }
        # Ejecutar desinstalacion C2R
        $proc = Start-Process $ctrExe -ArgumentList "scenario=install scenariosubtype=uninstall level=1" -Wait -PassThru -EA 0
        if ($proc.ExitCode -eq 0) { Write-Host "  C2R desinstalado correctamente" -ForegroundColor Green }
        else { Write-Host "  C2R proceso terminado (codigo: $($proc.ExitCode))" -ForegroundColor DarkYellow }
    } catch { Write-Host "  Error desinstalando C2R: $_" -ForegroundColor Red }
} else {
    Write-Host "  ClickToRun no encontrado" -ForegroundColor Gray
}

# --- PASO 4: Desinstalar Office MSI ---
Write-Host "[4/7] Buscando instalaciones Office MSI..." -ForegroundColor Yellow
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$msiCount = 0
$uninstallPaths | ForEach-Object {
    Get-ItemProperty $_ -EA 0 | Where-Object {
        $_.DisplayName -match "Microsoft Office" -and $_.DisplayName -notmatch "Viewer|Compatibility|Update|Shared"
    } | ForEach-Object {
        $name = $_.DisplayName
        $uninstallStr = $_.UninstallString
        Write-Host "  Encontrado: $name" -ForegroundColor Gray
        if ($uninstallStr) {
            try {
                if ($uninstallStr -match "msiexec.*\{([A-F0-9\-]+)\}") {
                    $guid = $Matches[1]
                    Write-Host "    MSI desinstalando ($guid)..." -ForegroundColor DarkGray
                    Start-Process msiexec.exe -ArgumentList "/x `"$guid`" /qn /norestart" -Wait -EA 0
                } elseif ($uninstallStr -match "msiexec") {
                    $cmd = $uninstallStr -replace "/I","/X"
                    $cmd += " /qn /norestart"
                    Start-Process cmd -ArgumentList "/c `"$cmd`"" -Wait -EA 0
                } else {
                    $cmd = $uninstallStr
                    if ($cmd -notmatch "/quiet|/qn") { $cmd += " /quiet /norestart" }
                    Start-Process cmd -ArgumentList "/c `"$cmd`"" -Wait -EA 0
                }
                $msiCount++
                Write-Host "    Desinstalado" -ForegroundColor Green
            } catch { Write-Host "    Error: $_" -ForegroundColor Red }
        }
    }
}
if ($msiCount -eq 0) { Write-Host "  No se encontraron instalaciones MSI" -ForegroundColor Gray }

# --- PASO 5: Limpiar registros de Office ---
Write-Host "[5/7] Limpiando registros de Office..." -ForegroundColor Yellow
$regKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Office",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office",
    "HKCU:\SOFTWARE\Microsoft\Office",
    "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$regCleaned = 0
foreach ($rk in $regKeys) {
    try { Remove-Item -Path $rk -Recurse -Force -EA 0; $regCleaned++ } catch {}
}
# Limpiar entradas especificas de Office en Uninstall
$uninstallPaths | ForEach-Object {
    Get-ItemProperty $_ -EA 0 | Where-Object { $_.DisplayName -match "Microsoft Office" } | ForEach-Object {
        $keyPath = $_.PSPath
        try { Remove-Item -Path $keyPath -Recurse -Force -EA 0; $regCleaned++ } catch {}
    }
}
Write-Host "  Registros limpiados: $regCleaned" -ForegroundColor Gray

# --- PASO 6: Limpiar archivos residuales ---
Write-Host "[6/7] Eliminando archivos residuales..." -ForegroundColor Yellow
$folders = @(
    "$env:ProgramFiles\Microsoft Office",
    "${env:ProgramFiles(x86)}\Microsoft Office",
    "$env:ProgramFiles\Microsoft Office 15",
    "$env:ProgramFiles\Microsoft Office 16",
    "$env:ProgramFiles\Microsoft Office\root",
    "${env:ProgramFiles(x86)}\Microsoft Office\root",
    "$env:CommonProgramFiles\Microsoft Shared\ClickToRun",
    "${env:CommonProgramFiles(x86)}\Microsoft Shared\ClickToRun",
    "$env:CommonProgramFiles\microsoft shared\Office16",
    "${env:CommonProgramFiles(x86)}\microsoft shared\Office16",
    "$env:LOCALAPPDATA\Microsoft\Office",
    "$env:LOCALAPPDATA\Microsoft\Office16.0",
    "$env:APPDATA\Microsoft\Office",
    "$env:APPDATA\Microsoft\Templates",
    "$env:ProgramData\Microsoft\Office",
    "$env:ProgramData\Microsoft\ClickToRun"
)
$folderCount = 0
$sizeFreed = 0
foreach ($f in $folders) {
    if (Test-Path $f) {
        try {
            $size = (Get-ChildItem $f -Recurse -Force -EA 0 | Measure-Object -Property Length -Sum -EA 0).Sum
            $sizeFreed += $size
            Remove-Item -Path $f -Recurse -Force -EA 0
            $folderCount++
        } catch {}
    }
}
$freedMB = [math]::Round($sizeFreed / 1MB, 1)
Write-Host "  Carpetas eliminadas: $folderCount (~$freedMB MB)" -ForegroundColor Gray

# --- PASO 7: Resumen ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Procesos cerrados:    $killed" -ForegroundColor White
Write-Host "  Instalaciones MSI:    $msiCount" -ForegroundColor White
Write-Host "  Registros limpiados:  $regCleaned" -ForegroundColor White
Write-Host "  Carpetas eliminadas:  $folderCount (~$freedMB MB)" -ForegroundColor White
Write-Host ""
Write-Host "  IMPORTANTE: Reinicia el equipo para completar la limpieza." -ForegroundColor Yellow
Write-Host ""
Read-Host "Presiona Enter para cerrar"
'@
            $scriptPath = Join-Path $env:TEMP "SHADOWIEX_OfficeForceClean.ps1"
            $scriptContent | Out-File $scriptPath -Encoding UTF8 -Force
            Update-Status "Ejecutando Office Force Clean..." "success"
            Write-Log "Office Force Clean ejecutado"
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        } catch { Update-Status "Error: $_" "error" }
    }
}.GetNewClosure())
$OC1.Controls.Add($BtnOC1)
$OC1.Controls.Add((New-DescLabel -Text "Elimina Office C2R+MSI, registros y archivos" -X 10 -Y 55 -W 228 -H 18))

# Card 2: Official Microsoft Tool
$OC2 = New-Card -X 271 -Y $OfficeRemoveY -W 248 -H 90
$TweakScroll.Controls.Add($OC2)
$BtnOC2 = New-Btn -Text "OFFICE TOOL OFICIAL" -X 10 -Y 10 -W 228 -H 36 -Color "Secondary"
$BtnOC2.Add_Click({
    Update-Status "Abriendo herramienta oficial Microsoft..."
    try {
        Start-Process "https://aka.ms/OfficeUninstall"
        Write-Log "Office official uninstall tool abierto"
    } catch { Update-Status "Error abriendo herramienta" "error" }
})
$OC2.Controls.Add($BtnOC2)
$OC2.Controls.Add((New-DescLabel -Text "Abre la herramienta oficial de Microsoft para desinstalar Office" -X 10 -Y 55 -W 228 -H 18))

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
$CreditPanel.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "SHADOWIEX v15.0 Professional PC Toolkit"; Location = New-Object System.Drawing.Point(15, 10); Size = New-Object System.Drawing.Size(470, 20); Font = $Global:Fonts.Header; ForeColor = $Global:Theme.TextDim}))
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

# Leyenda derecha - Creado por
$CreditSpring = New-Object System.Windows.Forms.ToolStripStatusLabel
$CreditSpring.Spring = $true
$StatusStrip.Items.Add($CreditSpring)

$CreditLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$CreditLabel.Text = "Creado por Walter D.P.  "
$CreditLabel.ForeColor = $Global:Theme.Primary
$CreditLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Italic)
$CreditLabel.Alignment = [System.Windows.Forms.ToolStripItemAlignment]::Right
$StatusStrip.Items.Add($CreditLabel)

$Global:Form.Controls.Add($StatusStrip)

# ============================================================================
#  INICIAR
# ============================================================================
Write-Log "SHADOWIEX v15.0 iniciado"
Update-Status "SHADOWIEX v15.0 Professional - Listo"
[void]$Global:Form.ShowDialog()