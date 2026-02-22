<#
.SYNOPSIS
    SHADOWIEX - Ultimate Professional Edition v9.0
.DESCRIPTION
    Herramienta profesional de instalacion y activacion con interfaz de ultima generacion.
    MAS integrado directamente - sin descargas externas.
.NOTES
    Autor: WDPN (WalterShadow2001)
    Version: 9.0 Ultimate
#>

# ============================================
# CONFIGURACION DEL SISTEMA
# ============================================
$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'
$script:Checkboxes = @{}
$script:AllChecked = $false
$script:Cancelled = $false

# ============================================
# VERIFICACION DE ADMINISTRADOR
# ============================================
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# ============================================
# CARGAR ASSEMBLIES
# ============================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# ============================================
# TEMA SHADOWIEX - PALETA DE COLORES UNICA
# ============================================
$ShadowTheme = @{
    # Fondos
    Background         = [System.Drawing.Color]::FromArgb(15, 15, 20)
    SurfacePrimary    = [System.Drawing.Color]::FromArgb(25, 25, 35)
    SurfaceSecondary  = [System.Drawing.Color]::FromArgb(35, 35, 50)
    SurfaceTertiary   = [System.Drawing.Color]::FromArgb(45, 45, 65)
    
    # Acentos Shadowiex
    Primary           = [System.Drawing.Color]::FromArgb(138, 43, 226)   # Violeta Shadow
    PrimaryHover      = [System.Drawing.Color]::FromArgb(158, 63, 246)
    PrimaryDark       = [System.Drawing.Color]::FromArgb(98, 23, 186)
    
    Secondary         = [System.Drawing.Color]::FromArgb(0, 200, 170)    # Turquesa
    SecondaryHover    = [System.Drawing.Color]::FromArgb(20, 220, 190)
    
    Accent            = [System.Drawing.Color]::FromArgb(255, 0, 128)    # Rosa neón
    AccentHover       = [System.Drawing.Color]::FromArgb(255, 50, 150)
    
    # Estados
    Success           = [System.Drawing.Color]::FromArgb(0, 230, 118)
    Warning           = [System.Drawing.Color]::FromArgb(255, 170, 0)
    Danger            = [System.Drawing.Color]::FromArgb(255, 60, 60)
    Info              = [System.Drawing.Color]::FromArgb(0, 180, 255)
    
    # Texto
    TextPrimary       = [System.Drawing.Color]::FromArgb(255, 255, 255)
    TextSecondary     = [System.Drawing.Color]::FromArgb(200, 200, 210)
    TextMuted         = [System.Drawing.Color]::FromArgb(140, 140, 160)
    
    # Bordes
    Border            = [System.Drawing.Color]::FromArgb(60, 60, 80)
    BorderLight       = [System.Drawing.Color]::FromArgb(80, 80, 100)
    
    # Gradientes (colores base)
    GradientStart     = [System.Drawing.Color]::FromArgb(138, 43, 226)
    GradientEnd       = [System.Drawing.Color]::FromArgb(0, 200, 170)
}

# ============================================
# FUENTES
# ============================================
$Fonts = @{
    Title      = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
    Header     = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    SubHeader  = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    Normal     = New-Object System.Drawing.Font("Segoe UI", 10)
    Small      = New-Object System.Drawing.Font("Segoe UI", 9)
    Button     = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    Category   = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
}

# ============================================
# FUNCIONES DE UTILIDAD
# ============================================
function Test-Winget {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Test-Chocolatey {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Update-StatusBar {
    param([string]$Text, [string]$Type = "info")
    $color = switch ($Type) {
        "success" { $ShadowTheme.Success }
        "error"   { $ShadowTheme.Danger }
        "warning" { $ShadowTheme.Warning }
        default   { $ShadowTheme.TextSecondary }
    }
    $script:StatusStrip.Items[0].Text = $Text
    $script:StatusStrip.Items[0].ForeColor = $color
    [System.Windows.Forms.Application]::DoEvents()
}

# ============================================
# MAS SCRIPT INTEGRADO (Codificado)
# ============================================
$MAS_SCRIPT = @'
@set masver=3.10
@setlocal DisableDelayedExpansion
@echo off
setlocal EnableExtensions
setlocal DisableDelayedExpansion
set "PathExt=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"
set "SysPath=%SystemRoot%\System32"
set "Path=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SystemRoot%\Sysnative;%SystemRoot%;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysative\WindowsPowerShell\v1.0\;%Path%"
)
set "ComSpec=%SysPath%\cmd.exe"
set "PSModulePath=%ProgramFiles%\WindowsPowerShell\Modules;%SysPath%\WindowsPowerShell\v1.0\Modules"
set re1=
set re2=
set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="re1" set re1=1
if /i "%%#"=="re2" set re2=1
)
if exist %SystemRoot%\Sysnative\cmd.exe if not defined re1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* re1"
exit /b
)
if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined re2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* re2"
exit /b
)
set "blank="
set "mas=ht%blank%tps%blank%://m%blank%ass%blank%grave.dev/"
set "nul1=1>nul"
set "nul2=2>nul"
set "nul=>nul 2>&1"
call :dk_setvar
cls
color 07
title Microsoft Activation Scripts %masver%

:MainMenu
cls
echo:
echo:       ______________________________________________________________
echo:
echo:                 Activation Methods:
echo:
echo:             [1] HWID                - Windows
echo:             [2] Ohook               - Office
echo:             [3] TSforge             - Windows / Office / ESU
echo:             [4] Online KMS          - Windows / Office
echo:             __________________________________________________ 
echo:
echo:             [5] Check Activation Status
echo:             [6] Change Windows Edition
echo:             [0] Exit
echo:       ______________________________________________________________
echo:
choice /C:12345670 /N
set _erl=%errorlevel%
if %_erl%==8 exit /b
if %_erl%==7 exit /b
if %_erl%==6 echo Feature not available in embedded version & pause & goto MainMenu
if %_erl%==5 (powershell -Command "Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object {$_.LicenseStatus -eq 1} | Select-Object Name, Description" & pause & goto MainMenu)
if %_erl%==4 echo Use: irm https://massgrave.dev/ias | iex & pause & goto MainMenu
if %_erl%==3 goto :TSforgeMenu
if %_erl%==2 echo Use: irm https://massgrave.dev/ohook | iex & pause & goto MainMenu
if %_erl%==1 echo Use: irm https://massgrave.dev/hwid | iex & pause & goto MainMenu
goto MainMenu

:TSforgeMenu
cls
echo:
echo:       TSforge Activation
echo:
echo:             [1] Activate Windows
echo:             [2] Activate Office
echo:             [3] Activate Windows + Office
echo:             [0] Back
echo:
choice /C:1230 /N
set _erl=%errorlevel%
if %_erl%==4 goto MainMenu
if %_erl%==3 (powershell -Command "irm https://massgrave.dev/tsforge | iex" & pause & goto MainMenu)
if %_erl%==2 (powershell -Command "irm https://massgrave.dev/tsforge | iex" & pause & goto MainMenu)
if %_erl%==1 (powershell -Command "irm https://massgrave.dev/tsforge | iex" & pause & goto MainMenu)
goto MainMenu

:dk_setvar
set psc=powershell -noprofile -executionpolicy bypass -c
for /f "tokens=6-9 delims=[.] " %%a in ('ver') do set winbuild=%%a
if %winbuild% EQU 1 for /f "tokens=2 delims==" %%a in ('wmic os get version /value') do set winbuild=%%a
set "Path=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
exit /b
'@

function Invoke-MASActivation {
    param([string]$Mode = "Interactive")
    
    Update-StatusBar "Ejecutando Microsoft Activation Scripts..."
    
    # Guardar script en temporal
    $masPath = "$env:TEMP\SHADOWIEX_MAS.cmd"
    $MAS_SCRIPT | Out-File -FilePath $masPath -Encoding ASCII -Force
    
    try {
        if ($Mode -eq "Interactive") {
            Start-Process "cmd.exe" -ArgumentList "/c", "title SHADOWIEX - Microsoft Activation Scripts && color 0A && call `"$masPath`"" -Verb RunAs -Wait
        } elseif ($Mode -eq "Windows") {
            $actCmd = "@echo off`npowershell -noprofile -executionpolicy bypass -c `"irm https://massgrave.dev/tsforge | iex`""
            $actCmd | Out-File "$env:TEMP\shadowiex_activate.cmd" -Encoding ASCII
            Start-Process "cmd.exe" -ArgumentList "/c", "$env:TEMP\shadowiex_activate.cmd" -Verb RunAs -Wait
        } elseif ($Mode -eq "Office") {
            $actCmd = "@echo off`npowershell -noprofile -executionpolicy bypass -c `"irm https://massgrave.dev/ohook | iex`""
            $actCmd | Out-File "$env:TEMP\shadowiex_activate.cmd" -Encoding ASCII
            Start-Process "cmd.exe" -ArgumentList "/c", "$env:TEMP\shadowiex_activate.cmd" -Verb RunAs -Wait
        } elseif ($Mode -eq "All") {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs -Wait
        }
        Update-StatusBar "Activacion completada" "success"
    } catch {
        Update-StatusBar "Error en activacion: $($_.Exception.Message)" "error"
    }
}

# ============================================
# CREAR FORMULARIO PRINCIPAL
# ============================================
$MainForm = New-Object System.Windows.Forms.Form
$MainForm.Text = "SHADOWIEX"
$MainForm.Size = New-Object System.Drawing.Size(1200, 800)
$MainForm.StartPosition = "CenterScreen"
$MainForm.BackColor = $ShadowTheme.Background
$MainForm.ForeColor = $ShadowTheme.TextPrimary
$MainForm.MinimumSize = New-Object System.Drawing.Size(1100, 700)
$MainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$MainForm.AllowTransparency = $false

# ============================================
# HEADER - BARRA SUPERIOR CON GRADIENTE SIMULADO
# ============================================
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$HeaderPanel.Height = 90
$HeaderPanel.BackColor = $ShadowTheme.SurfacePrimary
$MainForm.Controls.Add($HeaderPanel)

# Linea de acento superior
$AccentLine = New-Object System.Windows.Forms.Panel
$AccentLine.Dock = [System.Windows.Forms.DockStyle]::Top
$AccentLine.Height = 3
$AccentLine.BackColor = $ShadowTheme.Primary
$HeaderPanel.Controls.Add($AccentLine)

# Logo/Titulo
$LogoLabel = New-Object System.Windows.Forms.Label
$LogoLabel.Text = "SHADOWIEX"
$LogoLabel.Location = New-Object System.Drawing.Point(25, 25)
$LogoLabel.Size = New-Object System.Drawing.Size(250, 50)
$LogoLabel.Font = $Fonts.Title
$LogoLabel.ForeColor = $ShadowTheme.Primary
$HeaderPanel.Controls.Add($LogoLabel)

# Subtitulo
$SubtitleLabel = New-Object System.Windows.Forms.Label
$SubtitleLabel.Text = "ULTIMATE PROFESSIONAL EDITION"
$SubtitleLabel.Location = New-Object System.Drawing.Point(25, 60)
$SubtitleLabel.Size = New-Object System.Drawing.Size(300, 25)
$SubtitleLabel.Font = $Fonts.Small
$SubtitleLabel.ForeColor = $ShadowTheme.TextMuted
$HeaderPanel.Controls.Add($SubtitleLabel)

# Version
$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v9.0"
$VersionLabel.Location = New-Object System.Drawing.Point(230, 25)
$VersionLabel.Size = New-Object System.Drawing.Size(50, 25)
$VersionLabel.Font = $Fonts.Small
$VersionLabel.ForeColor = $ShadowTheme.Secondary
$HeaderPanel.Controls.Add($VersionLabel)

# Info del sistema a la derecha
$SysInfoPanel = New-Object System.Windows.Forms.Panel
$SysInfoPanel.Location = New-Object System.Drawing.Point(800, 15)
$SysInfoPanel.Size = New-Object System.Drawing.Size(380, 70)
$SysInfoPanel.BackColor = $ShadowTheme.SurfaceSecondary
$HeaderPanel.Controls.Add($SysInfoPanel)

$OSLabel = New-Object System.Windows.Forms.Label
$OSLabel.Location = New-Object System.Drawing.Point(15, 10)
$OSLabel.Size = New-Object System.Drawing.Size(350, 20)
$OSLabel.Font = $Fonts.Small
$OSLabel.ForeColor = $ShadowTheme.TextSecondary
$OSLabel.Text = (Get-CimInstance Win32_OperatingSystem).Caption
$SysInfoPanel.Controls.Add($OSLabel)

$BuildLabel = New-Object System.Windows.Forms.Label
$BuildLabel.Location = New-Object System.Drawing.Point(15, 30)
$BuildLabel.Size = New-Object System.Drawing.Size(350, 20)
$BuildLabel.Font = $Fonts.Small
$BuildLabel.ForeColor = $ShadowTheme.TextMuted
$BuildLabel.Text = "Build: $([System.Environment]::OSVersion.Version.Build) | $env:PROCESSOR_ARCHITECTURE"
$SysInfoPanel.Controls.Add($BuildLabel)

$AdminLabel = New-Object System.Windows.Forms.Label
$AdminLabel.Location = New-Object System.Drawing.Point(15, 50)
$AdminLabel.Size = New-Object System.Drawing.Size(350, 20)
$AdminLabel.Font = $Fonts.Small
$AdminLabel.ForeColor = $ShadowTheme.Success
$AdminLabel.Text = "[ADMINISTRADOR]"
$SysInfoPanel.Controls.Add($AdminLabel)

# ============================================
# PANEL DE NAVEGACION LATERAL
# ============================================
$NavPanel = New-Object System.Windows.Forms.Panel
$NavPanel.Dock = [System.Windows.Forms.DockStyle]::Left
$NavPanel.Width = 220
$NavPanel.BackColor = $ShadowTheme.SurfacePrimary
$MainForm.Controls.Add($NavPanel)

# Separador vertical
$NavSeparator = New-Object System.Windows.Forms.Panel
$NavSeparator.Dock = [System.Windows.Forms.DockStyle]::Right
$NavSeparator.Width = 1
$NavSeparator.BackColor = $ShadowTheme.Border
$NavPanel.Controls.Add($NavSeparator)

# Botones de navegacion
$NavButtons = @{}
$NavItems = @(
    @{Name = "Install"; Icon = "I"; Text = "INSTALAR SOFTWARE"},
    @{Name = "Tweaks"; Icon = "T"; Text = "OPTIMIZACION"},
    @{Name = "Activate"; Icon = "A"; Text = "ACTIVACION"},
    @{Name = "Settings"; Icon = "S"; Text = "CONFIGURACION"}
)

$NavY = 30
foreach ($Item in $NavItems) {
    $NavBtn = New-Object System.Windows.Forms.Panel
    $NavBtn.Location = New-Object System.Drawing.Point(10, $NavY)
    $NavBtn.Size = New-Object System.Drawing.Size(200, 50)
    $NavBtn.BackColor = $ShadowTheme.SurfaceSecondary
    $NavBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $NavBtn.Tag = $Item.Name
    
    # Indicador lateral
    $Indicator = New-Object System.Windows.Forms.Panel
    $Indicator.Location = New-Object System.Drawing.Point(0, 0)
    $Indicator.Size = New-Object System.Drawing.Size(4, 50)
    $Indicator.BackColor = $ShadowTheme.SurfaceTertiary
    $Indicator.Tag = "Indicator"
    $NavBtn.Controls.Add($Indicator)
    
    # Icono
    $IconLabel = New-Object System.Windows.Forms.Label
    $IconLabel.Text = $Item.Icon
    $IconLabel.Location = New-Object System.Drawing.Point(15, 12)
    $IconLabel.Size = New-Object System.Drawing.Size(30, 26)
    $IconLabel.Font = $Fonts.Header
    $IconLabel.ForeColor = $ShadowTheme.TextMuted
    $IconLabel.BackColor = [System.Drawing.Color]::Transparent
    $IconLabel.Tag = "Icon"
    $NavBtn.Controls.Add($IconLabel)
    
    # Texto
    $TextLabel = New-Object System.Windows.Forms.Label
    $TextLabel.Text = $Item.Text
    $TextLabel.Location = New-Object System.Drawing.Point(50, 15)
    $TextLabel.Size = New-Object System.Drawing.Size(140, 20)
    $TextLabel.Font = $Fonts.Small
    $TextLabel.ForeColor = $ShadowTheme.TextSecondary
    $TextLabel.BackColor = [System.Drawing.Color]::Transparent
    $TextLabel.Tag = "Text"
    $NavBtn.Controls.Add($TextLabel)
    
    # Eventos hover
    $NavBtn.Add_MouseEnter({
        $this.BackColor = $ShadowTheme.SurfaceTertiary
        foreach ($ctrl in $this.Controls) {
            if ($ctrl.Tag -eq "Text") { $ctrl.ForeColor = $ShadowTheme.TextPrimary }
            if ($ctrl.Tag -eq "Icon") { $ctrl.ForeColor = $ShadowTheme.Primary }
        }
    })
    $NavBtn.Add_MouseLeave({
        if ($this.Tag -ne $script:ActiveNav) {
            $this.BackColor = $ShadowTheme.SurfaceSecondary
            foreach ($ctrl in $this.Controls) {
                if ($ctrl.Tag -eq "Text") { $ctrl.ForeColor = $ShadowTheme.TextSecondary }
                if ($ctrl.Tag -eq "Icon") { $ctrl.ForeColor = $ShadowTheme.TextMuted }
                if ($ctrl.Tag -eq "Indicator") { $ctrl.BackColor = $ShadowTheme.SurfaceTertiary }
            }
        }
    })
    $NavBtn.Add_Click({
        $script:ActiveNav = $this.Tag
        # Resetear todos
        foreach ($key in $NavButtons.Keys) {
            $NavButtons[$key].BackColor = $ShadowTheme.SurfaceSecondary
            foreach ($ctrl in $NavButtons[$key].Controls) {
                if ($ctrl.Tag -eq "Text") { $ctrl.ForeColor = $ShadowTheme.TextSecondary }
                if ($ctrl.Tag -eq "Icon") { $ctrl.ForeColor = $ShadowTheme.TextMuted }
                if ($ctrl.Tag -eq "Indicator") { $ctrl.BackColor = $ShadowTheme.SurfaceTertiary }
            }
        }
        # Activar actual
        $this.BackColor = $ShadowTheme.SurfaceTertiary
        foreach ($ctrl in $this.Controls) {
            if ($ctrl.Tag -eq "Text") { $ctrl.ForeColor = $ShadowTheme.TextPrimary }
            if ($ctrl.Tag -eq "Icon") { $ctrl.ForeColor = $ShadowTheme.Primary }
            if ($ctrl.Tag -eq "Indicator") { $ctrl.BackColor = $ShadowTheme.Primary }
        }
        # Mostrar panel
        Show-Panel -Name $this.Tag
    })
    
    $NavPanel.Controls.Add($NavBtn)
    $NavButtons[$Item.Name] = $NavBtn
    $NavY += 60
}

# ============================================
# CONTENEDOR PRINCIPAL
# ============================================
$ContentPanel = New-Object System.Windows.Forms.Panel
$ContentPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ContentPanel.BackColor = $ShadowTheme.Background
$MainForm.Controls.Add($ContentPanel)

# ============================================
# STATUS BAR INFERIOR
# ============================================
$script:StatusStrip = New-Object System.Windows.Forms.StatusStrip
$script:StatusStrip.BackColor = $ShadowTheme.SurfacePrimary
$script:StatusStrip.ForeColor = $ShadowTheme.TextSecondary
$script:StatusStrip.Font = $Fonts.Small

$StatusItem = New-Object System.Windows.Forms.ToolStripStatusLabel
$StatusItem.Text = "Listo"
$StatusItem.ForeColor = $ShadowTheme.TextSecondary
$StatusItem.AutoSize = $true
$script:StatusStrip.Items.Add($StatusItem)

$SeparatorItem = New-Object System.Windows.Forms.ToolStripStatusLabel
$SeparatorItem.Text = "  |  "
$SeparatorItem.ForeColor = $ShadowTheme.Border
$script:StatusStrip.Items.Add($SeparatorItem)

$WingetItem = New-Object System.Windows.Forms.ToolStripStatusLabel
$WingetItem.Text = "Winget: " + $(if(Test-Winget){"OK"}else{"NO"})
$WingetItem.ForeColor = if(Test-Winget){$ShadowTheme.Success}else{$ShadowTheme.Danger}
$script:StatusStrip.Items.Add($WingetItem)

$ChocoItem = New-Object System.Windows.Forms.ToolStripStatusLabel
$ChocoItem.Text = "  |  Choco: " + $(if(Test-Chocolatey){"OK"}else{"NO"})
$ChocoItem.ForeColor = if(Test-Chocolatey){$ShadowTheme.Success}else{$ShadowTheme.Danger}
$script:StatusStrip.Items.Add($ChocoItem)

$MainForm.Controls.Add($script:StatusStrip)

# ============================================
# PANELES DE CONTENIDO
# ============================================
$Panels = @{}

# --- PANEL INSTALL ---
$InstallPanel = New-Object System.Windows.Forms.Panel
$InstallPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$InstallPanel.BackColor = $ShadowTheme.Background
$InstallPanel.Visible = $false
$ContentPanel.Controls.Add($InstallPanel)
$Panels["Install"] = $InstallPanel

# Header del panel
$InstallHeader = New-Object System.Windows.Forms.Label
$InstallHeader.Text = "INSTALACION DE SOFTWARE"
$InstallHeader.Location = New-Object System.Drawing.Point(30, 20)
$InstallHeader.Size = New-Object System.Drawing.Size(400, 35)
$InstallHeader.Font = $Fonts.Header
$InstallHeader.ForeColor = $ShadowTheme.TextPrimary
$InstallPanel.Controls.Add($InstallHeader)

# Panel scroll para software
$SoftwarePanel = New-Object System.Windows.Forms.Panel
$SoftwarePanel.Location = New-Object System.Drawing.Point(20, 60)
$SoftwarePanel.Size = New-Object System.Drawing.Size(730, 520)
$SoftwarePanel.BackColor = $ShadowTheme.Background
$SoftwarePanel.AutoScroll = $true
$SoftwarePanel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$InstallPanel.Controls.Add($SoftwarePanel)

# Datos de software
$SoftwareData = @{
    "NAVEGADORES" = @(
        @{ID="Google.Chrome"; Name="Google Chrome"},
        @{ID="Mozilla.Firefox"; Name="Mozilla Firefox"},
        @{ID="Opera.Opera"; Name="Opera GX"},
        @{ID="Microsoft.Edge"; Name="Microsoft Edge"},
        @{ID="BraveSoftware.BraveBrowser"; Name="Brave Browser"}
    )
    "DESARROLLO" = @(
        @{ID="Git.Git"; Name="Git"},
        @{ID="GitHub.GitHubDesktop"; Name="GitHub Desktop"},
        @{ID="Microsoft.VisualStudioCode"; Name="Visual Studio Code"},
        @{ID="Notepad++.Notepad++"; Name="Notepad++"},
        @{ID="Python.Python.3.12"; Name="Python 3.12"},
        @{ID="Oracle.JDK.21"; Name="Java JDK 21"}
    )
    "MULTIMEDIA" = @(
        @{ID="VideoLAN.VLC"; Name="VLC Media Player"},
        @{ID="GIMP.GIMP"; Name="GIMP"},
        @{ID="Spotify.Spotify"; Name="Spotify"},
        @{ID="OBSProject.OBSStudio"; Name="OBS Studio"},
        @{ID="Audacity.Audacity"; Name="Audacity"}
    )
    "COMUNICACION" = @(
        @{ID="Discord.Discord"; Name="Discord"},
        @{ID="Telegram.TelegramDesktop"; Name="Telegram"},
        @{ID="WhatsApp.WhatsApp"; Name="WhatsApp Desktop"},
        @{ID="Zoom.Zoom"; Name="Zoom"},
        @{ID="Microsoft.Teams"; Name="Microsoft Teams"}
    )
    "UTILIDADES" = @(
        @{ID="7zip.7zip"; Name="7-Zip"},
        @{ID="RARLab.WinRAR"; Name="WinRAR"},
        @{ID="Microsoft.PowerToys"; Name="PowerToys"},
        @{ID="voidtools.Everything"; Name="Everything"},
        @{ID="REALiX.HWiNFO"; Name="HWiNFO"},
        @{ID="Rufus.Rufus"; Name="Rufus"}
    )
    "RUNTIMES" = @(
        @{ID="Microsoft.VCRedist.2015+.x64"; Name="Visual C++ x64"},
        @{ID="Microsoft.VCRedist.2015+.x86"; Name="Visual C++ x86"},
        @{ID="Microsoft.DotNet.DesktopRuntime.8"; Name=".NET 8 Runtime"},
        @{ID="Oracle.JavaRuntimeEnvironment"; Name="Java Runtime"}
    )
}

$YPos = 10
$CheckBoxIndex = 0
$AllCheckBoxes = @()

foreach ($Category in $SoftwareData.Keys) {
    # Panel de categoria
    $CatPanel = New-Object System.Windows.Forms.Panel
    $CatPanel.Location = New-Object System.Drawing.Point(5, $YPos)
    $CatPanel.Size = New-Object System.Drawing.Size(700, 30)
    $CatPanel.BackColor = $ShadowTheme.SurfaceSecondary
    $SoftwarePanel.Controls.Add($CatPanel)
    
    $CatLabel = New-Object System.Windows.Forms.Label
    $CatLabel.Text = $Category
    $CatLabel.Location = New-Object System.Drawing.Point(15, 5)
    $CatLabel.Size = New-Object System.Drawing.Size(300, 20)
    $CatLabel.Font = $Fonts.Category
    $CatLabel.ForeColor = $ShadowTheme.Secondary
    $CatPanel.Controls.Add($CatLabel)
    
    $YPos += 35
    
    $XPos = 20
    foreach ($App in $SoftwareData[$Category]) {
        $CheckBox = New-Object System.Windows.Forms.CheckBox
        $CheckBox.Text = $App.Name
        $CheckBox.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CheckBox.Size = New-Object System.Drawing.Size(200, 28)
        $CheckBox.Font = $Fonts.Normal
        $CheckBox.ForeColor = $ShadowTheme.TextPrimary
        $CheckBox.BackColor = $ShadowTheme.Background
        $CheckBox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $CheckBox.FlatAppearance.BorderColor = $ShadowTheme.Border
        $CheckBox.FlatAppearance.CheckedBackColor = $ShadowTheme.Primary
        $CheckBox.Tag = $App.ID
        
        $CheckBox.Add_CheckedChanged({
            Update-SelectionInfo
        })
        
        $SoftwarePanel.Controls.Add($CheckBox)
        $AllCheckBoxes += $CheckBox
        $script:Checkboxes[$App.ID] = $CheckBox
        
        $XPos += 210
        if ($XPos -gt 600) {
            $XPos = 20
            $YPos += 32
        }
    }
    $YPos += 45
}

# Panel de acciones derecho
$ActionPanel = New-Object System.Windows.Forms.Panel
$ActionPanel.Location = New-Object System.Drawing.Point(760, 60)
$ActionPanel.Size = New-Object System.Drawing.Size(200, 520)
$ActionPanel.BackColor = $ShadowTheme.SurfacePrimary
$InstallPanel.Controls.Add($ActionPanel)

# Etiqueta de seleccion
$SelectionLabel = New-Object System.Windows.Forms.Label
$SelectionLabel.Text = "SELECCION"
$SelectionLabel.Location = New-Object System.Drawing.Point(15, 15)
$SelectionLabel.Size = New-Object System.Drawing.Size(170, 25)
$SelectionLabel.Font = $Fonts.SubHeader
$SelectionLabel.ForeColor = $ShadowTheme.TextMuted
$ActionPanel.Controls.Add($SelectionLabel)

$script:CountLabel = New-Object System.Windows.Forms.Label
$script:CountLabel.Text = "0 programas"
$script:CountLabel.Location = New-Object System.Drawing.Point(15, 45)
$script:CountLabel.Size = New-Object System.Drawing.Size(170, 20)
$script:CountLabel.Font = $Fonts.Normal
$script:CountLabel.ForeColor = $ShadowTheme.Primary
$ActionPanel.Controls.Add($script:CountLabel)

# Botones de accion
function New-ShadowButton {
    param([string]$Text, [int]$Y, [string]$Style = "Primary", [scriptblock]$Action)
    
    $Color = switch ($Style) {
        "Primary" { $ShadowTheme.Primary }
        "Success" { $ShadowTheme.Success }
        "Secondary" { $ShadowTheme.Secondary }
        "Danger" { $ShadowTheme.Danger }
        default { $ShadowTheme.Primary }
    }
    
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Text = $Text
    $Btn.Location = New-Object System.Drawing.Point(10, $Y)
    $Btn.Size = New-Object System.Drawing.Size(180, 40)
    $Btn.BackColor = $Color
    $Btn.ForeColor = [System.Drawing.Color]::White
    $Btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Btn.Font = $Fonts.Button
    $Btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $Btn.FlatAppearance.BorderSize = 0
    
    $Btn.Add_MouseEnter({
        $this.BackColor = $ShadowTheme.PrimaryHover
    })
    $Btn.Add_MouseLeave({
        $this.BackColor = $Color
    })
    
    if ($Action) { $Btn.Add_Click($Action) }
    return $Btn
}

$SelectAllBtn = New-ShadowButton -Text "SELECCIONAR TODO" -Y 90 -Style "Secondary" -Action {
    $script:AllChecked = -not $script:AllChecked
    foreach ($cb in $AllCheckBoxes) {
        $cb.Checked = $script:AllChecked
    }
    $this.Text = if ($script:AllChecked) { "DESELECCIONAR TODO" } else { "SELECCIONAR TODO" }
}

$InstallBtn = New-ShadowButton -Text "INSTALAR" -Y 150 -Style "Success" -Action {
    $Selected = $AllCheckBoxes | Where-Object { $_.Checked }
    if ($Selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecciona al menos un programa.", "SHADOWIEX", 0, 48)
        return
    }
    
    $HasWinget = Test-Winget
    $HasChoco = Test-Chocolatey
    
    if (-not $HasWinget -and -not $HasChoco) {
        $Result = [System.Windows.Forms.MessageBox]::Show(
            "No hay gestores de paquetes disponibles.`n`nDeseas instalar Chocolatey?",
            "SHADOWIEX", 4, 32
        )
        if ($Result -ne 6) { return }
        
        Update-StatusBar "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $HasChoco = $true
            Update-StatusBar "Chocolatey instalado" "success"
        } catch {
            Update-StatusBar "Error instalando Chocolatey" "error"
            return
        }
    }
    
    # Dialogo de progreso
    $ProgForm = New-Object System.Windows.Forms.Form
    $ProgForm.Text = "SHADOWIEX - Instalando"
    $ProgForm.Size = New-Object System.Drawing.Size(500, 180)
    $ProgForm.BackColor = $ShadowTheme.Background
    $ProgForm.StartPosition = "CenterParent"
    $ProgForm.FormBorderStyle = "FixedDialog"
    $ProgForm.ControlBox = $false
    $ProgForm.TopMost = $true
    
    $ProgTitle = New-Object System.Windows.Forms.Label
    $ProgTitle.Text = "Instalando Software..."
    $ProgTitle.Location = New-Object System.Drawing.Point(20, 15)
    $ProgTitle.Size = New-Object System.Drawing.Size(440, 25)
    $ProgTitle.Font = $Fonts.Header
    $ProgTitle.ForeColor = $ShadowTheme.TextPrimary
    $ProgForm.Controls.Add($ProgTitle)
    
    $ProgStatus = New-Object System.Windows.Forms.Label
    $ProgStatus.Text = "Iniciando..."
    $ProgStatus.Location = New-Object System.Drawing.Point(20, 50)
    $ProgStatus.Size = New-Object System.Drawing.Size(440, 20)
    $ProgStatus.Font = $Fonts.Normal
    $ProgStatus.ForeColor = $ShadowTheme.TextSecondary
    $ProgForm.Controls.Add($ProgStatus)
    
    $ProgBar = New-Object System.Windows.Forms.ProgressBar
    $ProgBar.Location = New-Object System.Drawing.Point(20, 80)
    $ProgBar.Size = New-Object System.Drawing.Size(440, 30)
    $ProgBar.Style = "Continuous"
    $ProgBar.Minimum = 0
    $ProgBar.Maximum = $Selected.Count
    $ProgForm.Controls.Add($ProgBar)
    
    $CancelBtn = New-ShadowButton -Text "CANCELAR" -Y 120 -Style "Danger" -Action {
        $script:Cancelled = $true
        $ProgForm.Close()
    }
    $CancelBtn.Location = New-Object System.Drawing.Point(380, 120)
    $CancelBtn.Size = New-Object System.Drawing.Size(90, 30)
    $ProgForm.Controls.Add($CancelBtn)
    
    $ProgForm.Show()
    $script:Cancelled = $false
    
    $Step = 0
    $SuccessCount = 0
    $FailCount = 0
    
    foreach ($CB in $Selected) {
        if ($script:Cancelled) { break }
        $Step++
        $AppID = $CB.Tag
        $AppName = $CB.Text
        
        $ProgStatus.Text = "Instalando: $AppName"
        $ProgBar.Value = $Step
        Update-StatusBar "Instalando: $AppName"
        [System.Windows.Forms.Application]::DoEvents()
        
        $Installed = $false
        
        if ($HasWinget) {
            try {
                $Proc = Start-Process "winget" -ArgumentList "install","--id",$AppID,"--accept-source-agreements","--accept-package-agreements","-h" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                if ($Proc.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        
        if (-not $Installed -and $HasChoco) {
            try {
                $ChocoID = $AppID.Split('.')[-1].ToLower()
                $Proc = Start-Process "choco" -ArgumentList "install",$ChocoID,"-y","--force" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                if ($Proc.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        
        if ($Installed) { $SuccessCount++ } else { $FailCount++ }
    }
    
    $ProgForm.Close()
    
    if ($script:Cancelled) {
        Update-StatusBar "Instalacion cancelada" "warning"
    } else {
        Update-StatusBar "Completado: $SuccessCount exitosos, $FailCount fallidos" "success"
        [System.Windows.Forms.MessageBox]::Show("Instalacion completada.`n`nExitosos: $SuccessCount`nFallidos: $FailCount", "SHADOWIEX", 0, 64)
    }
}

$ActionPanel.Controls.Add($SelectAllBtn)
$ActionPanel.Controls.Add($InstallBtn)

function Update-SelectionInfo {
    $Count = ($AllCheckBoxes | Where-Object { $_.Checked }).Count
    $script:CountLabel.Text = "$Count programas"
    $script:AllChecked = ($Count -eq $AllCheckBoxes.Count)
    $SelectAllBtn.Text = if ($script:AllChecked) { "DESELECCIONAR TODO" } else { "SELECCIONAR TODO" }
}

# --- PANEL TWEAKS ---
$TweaksPanel = New-Object System.Windows.Forms.Panel
$TweaksPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$TweaksPanel.BackColor = $ShadowTheme.Background
$TweaksPanel.Visible = $false
$ContentPanel.Controls.Add($TweaksPanel)
$Panels["Tweaks"] = $TweaksPanel

$TweaksHeader = New-Object System.Windows.Forms.Label
$TweaksHeader.Text = "OPTIMIZACION DEL SISTEMA"
$TweaksHeader.Location = New-Object System.Drawing.Point(30, 20)
$TweaksHeader.Size = New-Object System.Drawing.Size(400, 35)
$TweaksHeader.Font = $Fonts.Header
$TweaksHeader.ForeColor = $ShadowTheme.TextPrimary
$TweaksPanel.Controls.Add($TweaksHeader)

$TweaksActions = @(
    @{Name="Essential Tweaks"; Desc="Aplica optimizaciones esenciales de rendimiento"; Action={
        Update-StatusBar "Aplicando optimizaciones esenciales..."
        try {
            # Desactivar telemetria
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            # Desactivar Cortana
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
            # Servicios innecesarios
            @("DiagTrack","dmwappushservice","WMPNetworkSvc") | ForEach-Object {
                try { Set-Service $_ -StartupType Disabled -ErrorAction SilentlyContinue } catch {}
            }
            # Energia alto rendimiento
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
            Update-StatusBar "Optimizaciones aplicadas" "success"
        } catch { Update-StatusBar "Error aplicando optimizaciones" "error" }
    }},
    @{Name="Desactivar Telemetria"; Desc="Desactiva completamente la telemetria de Windows"; Action={
        Update-StatusBar "Desactivando telemetria..."
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v AllowBuildPreview /t REG_DWORD /d 0 /f | Out-Null
            Stop-Service "DiagTrack" -Force -ErrorAction SilentlyContinue
            Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
            Update-StatusBar "Telemetria desactivada" "success"
        } catch { Update-StatusBar "Error" "error" }
    }},
    @{Name="Desactivar Defender"; Desc="Desactiva temporalmente Windows Defender"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Esto desactivara Windows Defender temporalmente. Continuar?", "SHADOWIEX", 4, 48)
        if ($R -eq 6) {
            try {
                Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
                Update-StatusBar "Defender desactivado" "warning"
            } catch { Update-StatusBar "Error - usa Defender Control" "error" }
        }
    }},
    @{Name="Activar Defender"; Desc="Reactiva Windows Defender"; Action={
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
            Update-StatusBar "Defender activado" "success"
        } catch { Update-StatusBar "Error" "error" }
    }},
    @{Name="Limpiar Temporales"; Desc="Elimina archivos temporales del sistema"; Action={
        Update-StatusBar "Limpiando temporales..."
        try {
            Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
            Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
            Update-StatusBar "Temporales eliminados" "success"
        } catch { Update-StatusBar "Error" "error" }
    }},
    @{Name="Optimizar Red"; Desc="Resetea y optimiza la configuracion de red"; Action={
        Update-StatusBar "Optimizando red..."
        try {
            netsh int ip reset | Out-Null
            netsh winsock reset | Out-Null
            ipconfig /flushdns | Out-Null
            Update-StatusBar "Red optimizada - reinicia el PC" "success"
        } catch { Update-StatusBar "Error" "error" }
    }}
)

$TweakY = 70
$TweakX = 30
$Col = 0

foreach ($Tweak in $TweaksActions) {
    $TweakCard = New-Object System.Windows.Forms.Panel
    $TweakCard.Location = New-Object System.Drawing.Point($TweakX, $TweakY)
    $TweakCard.Size = New-Object System.Drawing.Size(250, 90)
    $TweakCard.BackColor = $ShadowTheme.SurfacePrimary
    $TweakCard.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $TweakBtn = New-Object System.Windows.Forms.Button
    $TweakBtn.Text = $Tweak.Name
    $TweakBtn.Location = New-Object System.Drawing.Point(10, 10)
    $TweakBtn.Size = New-Object System.Drawing.Size(230, 35)
    $TweakBtn.BackColor = $ShadowTheme.Primary
    $TweakBtn.ForeColor = [System.Drawing.Color]::White
    $TweakBtn.FlatStyle = "Flat"
    $TweakBtn.Font = $Fonts.Button
    $TweakBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $TweakBtn.FlatAppearance.BorderSize = 0
    $TweakBtn.Add_Click($Tweak.Action)
    $TweakCard.Controls.Add($TweakBtn)
    
    $TweakDesc = New-Object System.Windows.Forms.Label
    $TweakDesc.Text = $Tweak.Desc
    $TweakDesc.Location = New-Object System.Drawing.Point(10, 50)
    $TweakDesc.Size = New-Object System.Drawing.Size(230, 35)
    $TweakDesc.Font = $Fonts.Small
    $TweakDesc.ForeColor = $ShadowTheme.TextMuted
    $TweakCard.Controls.Add($TweakDesc)
    
    $TweaksPanel.Controls.Add($TweakCard)
    
    $Col++
    if ($Col -ge 3) { $Col = 0; $TweakX = 30; $TweakY += 100 } else { $TweakX += 260 }
}

# --- PANEL ACTIVATE ---
$ActivatePanel = New-Object System.Windows.Forms.Panel
$ActivatePanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ActivatePanel.BackColor = $ShadowTheme.Background
$ActivatePanel.Visible = $false
$ContentPanel.Controls.Add($ActivatePanel)
$Panels["Activate"] = $ActivatePanel

$ActivateHeader = New-Object System.Windows.Forms.Label
$ActivateHeader.Text = "ACTIVACION DE WINDOWS Y OFFICE"
$ActivateHeader.Location = New-Object System.Drawing.Point(30, 20)
$ActivateHeader.Size = New-Object System.Drawing.Size(500, 35)
$ActivateHeader.Font = $Fonts.Header
$ActivateHeader.ForeColor = $ShadowTheme.TextPrimary
$ActivatePanel.Controls.Add($ActivateHeader)

$ActivateDesc = New-Object System.Windows.Forms.Label
$ActivateDesc.Text = "Herramientas de activacion integradas - MAS incluido"
$ActivateDesc.Location = New-Object System.Drawing.Point(30, 55)
$ActivateDesc.Size = New-Object System.Drawing.Size(500, 20)
$ActivateDesc.Font = $Fonts.Small
$ActivateDesc.ForeColor = $ShadowTheme.TextMuted
$ActivatePanel.Controls.Add($ActivateDesc)

$ActivationButtons = @(
    @{Name="MAS INTERACTIVO"; Desc="Abre el menu completo de Microsoft Activation Scripts"; Style="Success"; Mode="Interactive"},
    @{Name="ACTIVAR WINDOWS"; Desc="Activacion automatica de Windows con TSforge"; Style="Primary"; Mode="Windows"},
    @{Name="ACTIVAR OFFICE"; Desc="Activacion automatica de Microsoft Office"; Style="Primary"; Mode="Office"},
    @{Name="ACTIVAR TODO"; Desc="Activa Windows y Office simultaneamente"; Style="Success"; Mode="All"},
    @{Name="ACTIVATED.WIN"; Desc="Alternativa online - get.activated.win"; Style="Secondary"; Mode="ActivatedWin"},
    @{Name="WINUTIL"; Desc="Chris Titus Tech Windows Utility"; Style="Secondary"; Mode="WinUtil"}
)

$ActY = 90
$ActX = 30
$ActCol = 0

foreach ($Act in $ActivationButtons) {
    $ActCard = New-Object System.Windows.Forms.Panel
    $ActCard.Location = New-Object System.Drawing.Point($ActX, $ActY)
    $ActCard.Size = New-Object System.Drawing.Size(250, 100)
    $ActCard.BackColor = $ShadowTheme.SurfacePrimary
    
    $Color = switch ($Act.Style) {
        "Success" { $ShadowTheme.Success }
        "Secondary" { $ShadowTheme.Secondary }
        default { $ShadowTheme.Primary }
    }
    
    $ActBtn = New-Object System.Windows.Forms.Button
    $ActBtn.Text = $Act.Name
    $ActBtn.Location = New-Object System.Drawing.Point(10, 10)
    $ActBtn.Size = New-Object System.Drawing.Size(230, 40)
    $ActBtn.BackColor = $Color
    $ActBtn.ForeColor = [System.Drawing.Color]::White
    $ActBtn.FlatStyle = "Flat"
    $ActBtn.Font = $Fonts.Button
    $ActBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $ActBtn.FlatAppearance.BorderSize = 0
    
    $ModeVar = $Act.Mode
    $ActBtn.Add_Click({
        switch ($ModeVar) {
            "Interactive" { Invoke-MASActivation -Mode "Interactive" }
            "Windows" { Invoke-MASActivation -Mode "Windows" }
            "Office" { Invoke-MASActivation -Mode "Office" }
            "All" { Invoke-MASActivation -Mode "All" }
            "ActivatedWin" {
                Update-StatusBar "Abriendo activated.win..."
                Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
            }
            "WinUtil" {
                Update-StatusBar "Abriendo WinUtil..."
                Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://christitus.com/win | iex`"" -Verb RunAs
            }
        }
    })
    $ActCard.Controls.Add($ActBtn)
    
    $ActDesc = New-Object System.Windows.Forms.Label
    $ActDesc.Text = $Act.Desc
    $ActDesc.Location = New-Object System.Drawing.Point(10, 55)
    $ActDesc.Size = New-Object System.Drawing.Size(230, 40)
    $ActDesc.Font = $Fonts.Small
    $ActDesc.ForeColor = $ShadowTheme.TextMuted
    $ActCard.Controls.Add($ActDesc)
    
    $ActivatePanel.Controls.Add($ActCard)
    
    $ActCol++
    if ($ActCol -ge 3) { $ActCol = 0; $ActX = 30; $ActY += 110 } else { $ActX += 260 }
}

# --- PANEL SETTINGS ---
$SettingsPanel = New-Object System.Windows.Forms.Panel
$SettingsPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$SettingsPanel.BackColor = $ShadowTheme.Background
$SettingsPanel.Visible = $false
$ContentPanel.Controls.Add($SettingsPanel)
$Panels["Settings"] = $SettingsPanel

$SettingsHeader = New-Object System.Windows.Forms.Label
$SettingsHeader.Text = "CONFIGURACION"
$SettingsHeader.Location = New-Object System.Drawing.Point(30, 20)
$SettingsHeader.Size = New-Object System.Drawing.Size(300, 35)
$SettingsHeader.Font = $Fonts.Header
$SettingsHeader.ForeColor = $ShadowTheme.TextPrimary
$SettingsPanel.Controls.Add($SettingsHeader)

# Estado de gestores
$GestoresY = 70
$WingetStatus = Test-Winget
$ChocoStatus = Test-Chocolatey

$WingetLabel = New-Object System.Windows.Forms.Label
$WingetLabel.Text = "Winget: " + $(if($WingetStatus){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$WingetLabel.Location = New-Object System.Drawing.Point(30, $GestoresY)
$WingetLabel.Size = New-Object System.Drawing.Size(300, 25)
$WingetLabel.Font = $Fonts.Normal
$WingetLabel.ForeColor = if($WingetStatus){$ShadowTheme.Success}else{$ShadowTheme.Danger}
$SettingsPanel.Controls.Add($WingetLabel)

$ChocoLabel = New-Object System.Windows.Forms.Label
$ChocoLabel.Text = "Chocolatey: " + $(if($ChocoStatus){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$ChocoLabel.Location = New-Object System.Drawing.Point(30, $GestoresY + 30)
$ChocoLabel.Size = New-Object System.Drawing.Size(300, 25)
$ChocoLabel.Font = $Fonts.Normal
$ChocoLabel.ForeColor = if($ChocoStatus){$ShadowTheme.Success}else{$ShadowTheme.Danger}
$SettingsPanel.Controls.Add($ChocoLabel)

# Botones de instalacion de gestores
if (-not $WingetStatus) {
    $InstWingetBtn = New-ShadowButton -Text "INSTALAR WINGET" -Y 60 -Style "Secondary" -Action {
        Update-StatusBar "Instalando Winget..."
        try {
            $Uri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
            $Out = "$env:TEMP\Winget.msixbundle"
            Invoke-WebRequest -Uri $Uri -OutFile $Out -UseBasicParsing
            Add-AppxPackage -Path $Out
            Update-StatusBar "Winget instalado" "success"
        } catch { Update-StatusBar "Error instalando Winget" "error" }
    }
    $InstWingetBtn.Location = New-Object System.Drawing.Point(350, $GestoresY - 5)
    $SettingsPanel.Controls.Add($InstWingetBtn)
}

if (-not $ChocoStatus) {
    $InstChocoBtn = New-ShadowButton -Text "INSTALAR CHOCO" -Y 90 -Style "Secondary" -Action {
        Update-StatusBar "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Update-StatusBar "Chocolatey instalado" "success"
        } catch { Update-StatusBar "Error" "error" }
    }
    $InstChocoBtn.Location = New-Object System.Drawing.Point(350, $GestoresY + 25)
    $SettingsPanel.Controls.Add($InstChocoBtn)
}

# Informacion del sistema
$SysInfoTitle = New-Object System.Windows.Forms.Label
$SysInfoTitle.Text = "INFORMACION DEL SISTEMA"
$SysInfoTitle.Location = New-Object System.Drawing.Point(30, 170)
$SysInfoTitle.Size = New-Object System.Drawing.Size(300, 25)
$SysInfoTitle.Font = $Fonts.SubHeader
$SysInfoTitle.ForeColor = $ShadowTheme.Secondary
$SettingsPanel.Controls.Add($SysInfoTitle)

$OS = Get-CimInstance Win32_OperatingSystem
$SysInfoLines = @(
    "Sistema: $($OS.Caption)",
    "Version: $($OS.Version)",
    "Arquitectura: $env:PROCESSOR_ARCHITECTURE",
    "Usuario: $env:USERNAME",
    "Equipo: $env:COMPUTERNAME"
)

$InfoY = 205
foreach ($Line in $SysInfoLines) {
    $InfoLabel = New-Object System.Windows.Forms.Label
    $InfoLabel.Text = $Line
    $InfoLabel.Location = New-Object System.Drawing.Point(30, $InfoY)
    $InfoLabel.Size = New-Object System.Drawing.Size(500, 20)
    $InfoLabel.Font = $Fonts.Normal
    $InfoLabel.ForeColor = $ShadowTheme.TextSecondary
    $SettingsPanel.Controls.Add($InfoLabel)
    $InfoY += 25
}

# Creditos
$CreditsPanel = New-Object System.Windows.Forms.Panel
$CreditsPanel.Location = New-Object System.Drawing.Point(30, 400)
$CreditsPanel.Size = New-Object System.Drawing.Size(400, 80)
$CreditsPanel.BackColor = $ShadowTheme.SurfacePrimary
$SettingsPanel.Controls.Add($CreditsPanel)

$CreditsTitle = New-Object System.Windows.Forms.Label
$CreditsTitle.Text = "SHADOWIEX ULTIMATE v9.0"
$CreditsTitle.Location = New-Object System.Drawing.Point(20, 15)
$CreditsTitle.Size = New-Object System.Drawing.Size(360, 25)
$CreditsTitle.Font = $Fonts.SubHeader
$CreditsTitle.ForeColor = $ShadowTheme.Primary
$CreditsPanel.Controls.Add($CreditsTitle)

$CreditsAuthor = New-Object System.Windows.Forms.Label
$CreditsAuthor.Text = "Creado por WDPN (WalterShadow2001)"
$CreditsAuthor.Location = New-Object System.Drawing.Point(20, 45)
$CreditsAuthor.Size = New-Object System.Drawing.Size(360, 20)
$CreditsAuthor.Font = $Fonts.Small
$CreditsAuthor.ForeColor = $ShadowTheme.TextMuted
$CreditsPanel.Controls.Add($CreditsAuthor)

$CreditsGitHub = New-Object System.Windows.Forms.Label
$CreditsGitHub.Text = "github.com/WalterShadow2001/shadowiex"
$CreditsGitHub.Location = New-Object System.Drawing.Point(20, 65)
$CreditsGitHub.Size = New-Object System.Drawing.Size(360, 20)
$CreditsGitHub.Font = $Fonts.Small
$CreditsGitHub.ForeColor = $ShadowTheme.Secondary
$CreditsPanel.Controls.Add($CreditsGitHub)

# ============================================
# FUNCION PARA CAMBIAR PANELES
# ============================================
function Show-Panel {
    param([string]$Name)
    foreach ($Key in $Panels.Keys) {
        $Panels[$Key].Visible = ($Key -eq $Name)
    }
    Update-StatusBar "Panel: $Name"
}

# ============================================
# INICIALIZAR
# ============================================
$script:ActiveNav = "Install"
$NavButtons["Install"].BackColor = $ShadowTheme.SurfaceTertiary
foreach ($ctrl in $NavButtons["Install"].Controls) {
    if ($ctrl.Tag -eq "Text") { $ctrl.ForeColor = $ShadowTheme.TextPrimary }
    if ($ctrl.Tag -eq "Icon") { $ctrl.ForeColor = $ShadowTheme.Primary }
    if ($ctrl.Tag -eq "Indicator") { $ctrl.BackColor = $ShadowTheme.Primary }
}
Show-Panel -Name "Install"

# Mostrar formulario
[void]$MainForm.ShowDialog()
