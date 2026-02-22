<#
.SYNOPSIS
    Shadowiex - WinUtil Style Edition v8.0
.DESCRIPTION
    Interfaz moderna estilo Chris Titus WinUtil con mejoras en instalación y activación.
.NOTES
    Autor: WDPN (WalterShadow2001)
    Versión: 8.0 - WinUtil Style
#>

# --- CONFIGURACIÓN INICIAL ---
$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'
$script:UIControls = @{}
$script:AllChecked = $false

# Funciones de Verificación
function Test-Winget { 
    try { 
        $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetPath) { return $true }
        return $false
    } 
    catch { return $false } 
}

function Test-Chocolatey { 
    try { 
        $chocoPath = Get-Command choco -ErrorAction SilentlyContinue
        if ($chocoPath) { return $true }
        return $false
    } 
    catch { return $false } 
}

function Test-Admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($user)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- COLORES ESTILO WINUTIL ---
$theme = @{
    Background     = [System.Drawing.Color]::FromArgb(30, 30, 30)
    PanelDark      = [System.Drawing.Color]::FromArgb(45, 45, 45)
    PanelLight     = [System.Drawing.Color]::FromArgb(55, 55, 55)
    Border         = [System.Drawing.Color]::FromArgb(70, 70, 70)
    Accent         = [System.Drawing.Color]::FromArgb(0, 150, 136)
    AccentHover    = [System.Drawing.Color]::FromArgb(0, 121, 107)
    ButtonPrimary  = [System.Drawing.Color]::FromArgb(33, 150, 243)
    ButtonSuccess  = [System.Drawing.Color]::FromArgb(76, 175, 80)
    ButtonDanger   = [System.Drawing.Color]::FromArgb(244, 67, 54)
    ButtonWarning  = [System.Drawing.Color]::FromArgb(255, 152, 0)
    ButtonInfo     = [System.Drawing.Color]::FromArgb(0, 188, 212)
    TextPrimary    = [System.Drawing.Color]::White
    TextSecondary  = [System.Drawing.Color]::FromArgb(170, 170, 170)
    TextMuted      = [System.Drawing.Color]::FromArgb(120, 120, 120)
    Category       = [System.Drawing.Color]::FromArgb(100, 181, 246)
    Success        = [System.Drawing.Color]::FromArgb(129, 199, 132)
    Error          = [System.Drawing.Color]::FromArgb(239, 154, 154)
}

# Fuentes
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$fontHeader = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fontSubHeader = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$fontNormal = New-Object System.Drawing.Font("Segoe UI", 10)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 9)
$fontButton = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# --- FORMULARIO PRINCIPAL ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Shadowiex - WinUtil Style"
$form.Size = New-Object System.Drawing.Size(1100, 750)
$form.StartPosition = "CenterScreen"
$form.BackColor = $theme.Background
$form.ForeColor = $theme.TextPrimary
$form.MinimumSize = New-Object System.Drawing.Size(1000, 700)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable

# Panel superior con título
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$headerPanel.Height = 80
$headerPanel.BackColor = $theme.PanelDark
$form.Controls.Add($headerPanel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "SHADOWIEX"
$titleLabel.Location = New-Object System.Drawing.Point(20, 15)
$titleLabel.Size = New-Object System.Drawing.Size(300, 40)
$titleLabel.Font = $fontTitle
$titleLabel.ForeColor = $theme.Accent
$headerPanel.Controls.Add($titleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Professional Installation & Activation Tool"
$subtitleLabel.Location = New-Object System.Drawing.Point(20, 50)
$subtitleLabel.Size = New-Object System.Drawing.Size(400, 25)
$subtitleLabel.Font = $fontSmall
$subtitleLabel.ForeColor = $theme.TextSecondary
$headerPanel.Controls.Add($subtitleLabel)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "v8.0"
$versionLabel.Location = New-Object System.Drawing.Point(280, 15)
$versionLabel.Size = New-Object System.Drawing.Size(60, 25)
$versionLabel.Font = $fontSmall
$versionLabel.ForeColor = $theme.TextMuted
$headerPanel.Controls.Add($versionLabel)

# Barra de estado inferior
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$statusPanel.Height = 35
$statusPanel.BackColor = $theme.PanelDark
$form.Controls.Add($statusPanel)

$script:statusLabel = New-Object System.Windows.Forms.Label
$script:statusLabel.Text = "Listo"
$script:statusLabel.Location = New-Object System.Drawing.Point(15, 8)
$script:statusLabel.Size = New-Object System.Drawing.Size(800, 20)
$script:statusLabel.Font = $fontSmall
$script:statusLabel.ForeColor = $theme.TextSecondary
$statusPanel.Controls.Add($script:statusLabel)

$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "WDPN | github.com/WalterShadow2001"
$footerLabel.Location = New-Object System.Drawing.Point(850, 8)
$footerLabel.Size = New-Object System.Drawing.Size(220, 20)
$footerLabel.Font = $fontSmall
$footerLabel.ForeColor = $theme.TextMuted
$footerLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$statusPanel.Controls.Add($footerLabel)

# --- PANEL DE NAVEGACIÓN IZQUIERDO ---
$navPanel = New-Object System.Windows.Forms.Panel
$navPanel.Location = New-Object System.Drawing.Point(0, 80)
$navPanel.Size = New-Object System.Drawing.Size(200, 635)
$navPanel.BackColor = $theme.PanelDark
$form.Controls.Add($navPanel)

$navButtons = @()
$navItems = @("Instalar", "Tweaks", "Activar", "Config")

$navY = 20
foreach ($item in $navItems) {
    $navBtn = New-Object System.Windows.Forms.Button
    $navBtn.Text = $item
    $navBtn.Location = New-Object System.Drawing.Point(10, $navY)
    $navBtn.Size = New-Object System.Drawing.Size(180, 45)
    $navBtn.BackColor = $theme.PanelLight
    $navBtn.ForeColor = $theme.TextPrimary
    $navBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $navBtn.Font = $fontButton
    $navBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $navBtn.FlatAppearance.BorderSize = 0
    $navBtn.Tag = $item
    
    $navBtn.Add_MouseEnter({
        $this.BackColor = $theme.Accent
    })
    $navBtn.Add_MouseLeave({
        if ($this.Tag -ne $script:activeNav) {
            $this.BackColor = $theme.PanelLight
        }
    })
    
    $navPanel.Controls.Add($navBtn)
    $navButtons += $navBtn
    $navY += 55
}

# --- CONTENEDOR PRINCIPAL ---
$mainContainer = New-Object System.Windows.Forms.Panel
$mainContainer.Location = New-Object System.Drawing.Point(200, 80)
$mainContainer.Size = New-Object System.Drawing.Size(900, 635)
$mainContainer.BackColor = $theme.Background
$form.Controls.Add($mainContainer)

# --- FUNCIONES AUXILIARES ---

function Update-Status {
    param ([string]$text, [string]$type = "info")
    $color = switch ($type) {
        "success" { $theme.Success }
        "error" { $theme.Error }
        "warning" { $theme.ButtonWarning }
        default { $theme.TextSecondary }
    }
    $script:statusLabel.Text = $text
    $script:statusLabel.ForeColor = $color
    [System.Windows.Forms.Application]::DoEvents()
}

function New-CategoryPanel {
    param ([string]$title, [int]$y)
    
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(15, $y)
    $panel.Size = New-Object System.Drawing.Size(860, 30)
    $panel.BackColor = $theme.PanelLight
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $title.ToUpper()
    $label.Location = New-Object System.Drawing.Point(10, 5)
    $label.Size = New-Object System.Drawing.Size(300, 20)
    $label.Font = $fontSubHeader
    $label.ForeColor = $theme.Category
    $panel.Controls.Add($label)
    
    return $panel
}

function New-AppCheckbox {
    param ([string]$text, [int]$x, [int]$y, [int]$width = 280, [int]$height = 32)
    
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $text
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.Size = New-Object System.Drawing.Size($width, $height)
    $checkbox.Font = $fontNormal
    $checkbox.ForeColor = $theme.TextPrimary
    $checkbox.BackColor = $theme.Background
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $checkbox.FlatAppearance.BorderColor = $theme.Border
    $checkbox.FlatAppearance.CheckedBackColor = $theme.Accent
    
    return $checkbox
}

function New-ActionButton {
    param (
        [string]$text, 
        [int]$x, 
        [int]$y, 
        [int]$width = 180, 
        [int]$height = 40,
        [string]$style = "primary"
    )
    
    $color = switch ($style) {
        "success" { $theme.ButtonSuccess }
        "danger" { $theme.ButtonDanger }
        "warning" { $theme.ButtonWarning }
        "info" { $theme.ButtonInfo }
        default { $theme.ButtonPrimary }
    }
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.BackColor = $color
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = $fontButton
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.FlatAppearance.BorderSize = 0
    
    $button.Add_MouseEnter({
        $r = [Math]::Max(0, $this.BackColor.R - 20)
        $g = [Math]::Max(0, $this.BackColor.G - 20)
        $b = [Math]::Max(0, $this.BackColor.B - 20)
        $this.BackColor = [System.Drawing.Color]::FromArgb($r, $g, $b)
    })
    $button.Add_MouseLeave({
        $this.BackColor = $color
    })
    
    return $button
}

function Show-Progress {
    param ([string]$title, [int]$max = 100)
    
    $progForm = New-Object System.Windows.Forms.Form
    $progForm.Text = $title
    $progForm.Size = New-Object System.Drawing.Size(500, 180)
    $progForm.BackColor = $theme.Background
    $progForm.StartPosition = "CenterParent"
    $progForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $progForm.ControlBox = $false
    $progForm.TopMost = $true
    
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = $title
    $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
    $titleLabel.Size = New-Object System.Drawing.Size(440, 25)
    $titleLabel.Font = $fontHeader
    $titleLabel.ForeColor = $theme.TextPrimary
    $progForm.Controls.Add($titleLabel)
    
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Iniciando..."
    $statusLabel.Location = New-Object System.Drawing.Point(20, 50)
    $statusLabel.Size = New-Object System.Drawing.Size(440, 20)
    $statusLabel.Font = $fontNormal
    $statusLabel.ForeColor = $theme.TextSecondary
    $progForm.Controls.Add($statusLabel)
    
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 80)
    $progressBar.Size = New-Object System.Drawing.Size(440, 30)
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progressBar.Minimum = 0
    $progressBar.Maximum = $max
    $progForm.Controls.Add($progressBar)
    
    $cancelBtn = New-ActionButton -text "Cancelar" -x 380 -y 120 -width 80 -height 28 -style "danger"
    $cancelBtn.Add_Click({
        $script:cancelled = $true
        $progForm.Close()
    })
    $progForm.Controls.Add($cancelBtn)
    
    return @{
        Form = $progForm
        Progress = $progressBar
        Status = $statusLabel
        Max = $max
    }
}

function Update-Progress {
    param ($dialog, [string]$status, [int]$value)
    if ($dialog.Form.IsDisposed) { return }
    $dialog.Status.Text = $status
    $dialog.Progress.Value = [Math]::Min($value, $dialog.Max)
    $dialog.Form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

# --- PANEL DE INSTALACIÓN ---
$script:installPanel = New-Object System.Windows.Forms.Panel
$script:installPanel.Location = New-Object System.Drawing.Point(0, 0)
$script:installPanel.Size = New-Object System.Drawing.Size(900, 635)
$script:installPanel.BackColor = $theme.Background
$script:installPanel.Visible = $false
$mainContainer.Controls.Add($script:installPanel)

# Scroll panel para software
$softwareScroll = New-Object System.Windows.Forms.Panel
$softwareScroll.Location = New-Object System.Drawing.Point(0, 0)
$softwareScroll.Size = New-Object System.Drawing.Size(880, 520)
$softwareScroll.BackColor = $theme.Background
$softwareScroll.AutoScroll = $true
$script:installPanel.Controls.Add($softwareScroll)

$script:allCheckboxes = @()
$yPos = 15

$softwareList = @{
    "NAVEGADORES" = @(
        @{id="Google.Chrome"; name="Google Chrome"},
        @{id="Mozilla.Firefox"; name="Mozilla Firefox"},
        @{id="Opera.Opera"; name="Opera GX"},
        @{id="Microsoft.Edge"; name="Microsoft Edge"},
        @{id="BraveSoftware.BraveBrowser"; name="Brave Browser"}
    )
    "DESARROLLO" = @(
        @{id="Git.Git"; name="Git"},
        @{id="GitHub.GitHubDesktop"; name="GitHub Desktop"},
        @{id="Microsoft.VisualStudioCode"; name="Visual Studio Code"},
        @{id="Notepad++.Notepad++"; name="Notepad++"},
        @{id="Python.Python.3.12"; name="Python 3.12"},
        @{id="Oracle.JDK.21"; name="Java JDK 21"}
    )
    "MULTIMEDIA" = @(
        @{id="VideoLAN.VLC"; name="VLC Media Player"},
        @{id="GIMP.GIMP"; name="GIMP"},
        @{id="Spotify.Spotify"; name="Spotify"},
        @{id="Audacity.Audacity"; name="Audacity"},
        @{id="OBSProject.OBSStudio"; name="OBS Studio"}
    )
    "COMUNICACION" = @(
        @{id="Discord.Discord"; name="Discord"},
        @{id="Telegram.TelegramDesktop"; name="Telegram"},
        @{id="WhatsApp.WhatsApp"; name="WhatsApp Desktop"},
        @{id="Zoom.Zoom"; name="Zoom"},
        @{id="Microsoft.Teams"; name="Microsoft Teams"}
    )
    "UTILIDADES" = @(
        @{id="7zip.7zip"; name="7-Zip"},
        @{id="RARLab.WinRAR"; name="WinRAR"},
        @{id="Microsoft.PowerToys"; name="PowerToys"},
        @{id="voidtools.Everything"; name="Everything"},
        @{id="REALiX.HWiNFO"; name="HWiNFO"}
    )
    "RUNTIMES" = @(
        @{id="Microsoft.VCRedist.2015+.x64"; name="Visual C++ 2015-2022 x64"},
        @{id="Microsoft.VCRedist.2015+.x86"; name="Visual C++ 2015-2022 x86"},
        @{id="Microsoft.DotNet.DesktopRuntime.8"; name=".NET 8 Desktop Runtime"},
        @{id="Oracle.JavaRuntimeEnvironment"; name="Java Runtime"}
    )
}

foreach ($category in $softwareList.Keys) {
    $catPanel = New-CategoryPanel -title $category -y $yPos
    $softwareScroll.Controls.Add($catPanel)
    $yPos += 35
    
    $xPos = 20
    foreach ($app in $softwareList[$category]) {
        $cb = New-AppCheckbox -text $app.name -x $xPos -y $yPos
        $cb.Tag = $app.id
        $softwareScroll.Controls.Add($cb)
        $script:allCheckboxes += $cb
        
        $xPos += 290
        if ($xPos -gt 600) {
            $xPos = 20
            $yPos += 35
        }
    }
    $yPos += 45
}

# Panel de botones inferior
$installBtnPanel = New-Object System.Windows.Forms.Panel
$installBtnPanel.Location = New-Object System.Drawing.Point(0, 530)
$installBtnPanel.Size = New-Object System.Drawing.Size(880, 100)
$installBtnPanel.BackColor = $theme.PanelDark
$script:installPanel.Controls.Add($installBtnPanel)

$script:selCountLabel = New-Object System.Windows.Forms.Label
$script:selCountLabel.Text = "Seleccionados: 0"
$script:selCountLabel.Location = New-Object System.Drawing.Point(20, 15)
$script:selCountLabel.Size = New-Object System.Drawing.Size(200, 20)
$script:selCountLabel.Font = $fontNormal
$script:selCountLabel.ForeColor = $theme.TextSecondary
$installBtnPanel.Controls.Add($script:selCountLabel)

$script:toggleAllBtn = New-ActionButton -text "Seleccionar Todo" -x 20 -y 45 -width 160 -style "info"
$script:toggleAllBtn.Add_Click({
    $script:AllChecked = -not $script:AllChecked
    foreach ($cb in $script:allCheckboxes) {
        $cb.Checked = $script:AllChecked
    }
    $script:toggleAllBtn.Text = if ($script:AllChecked) { "Deseleccionar Todo" } else { "Seleccionar Todo" }
    Update-SelectionCount
})
$installBtnPanel.Controls.Add($script:toggleAllBtn)

$installSelectedBtn = New-ActionButton -text "Instalar Seleccionados" -x 200 -y 45 -width 180 -style "success"
$installSelectedBtn.Add_Click({
    $selected = $script:allCheckboxes | Where-Object { $_.Checked }
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No hay aplicaciones seleccionadas.", "Aviso", 0, 48)
        return
    }
    
    $hasWinget = Test-Winget
    $hasChoco = Test-Chocolatey
    
    if (-not $hasWinget -and -not $hasChoco) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Winget no esta disponible.`n`nDesea instalar Chocolatey como alternativa?",
            "Gestor no encontrado",
            4, 32
        )
        if ($result -ne 6) { return }
        
        Update-Status "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $hasChoco = $true
            Update-Status "Chocolatey instalado" "success"
        } catch {
            Update-Status "Error instalando Chocolatey" "error"
            return
        }
    }
    
    $script:cancelled = $false
    $prog = Show-Progress -title "Instalando Aplicaciones" -max $selected.Count
    $prog.Form.Show()
    
    $step = 0
    $successCount = 0
    $failCount = 0
    
    foreach ($cb in $selected) {
        if ($script:cancelled) { break }
        $step++
        $appId = $cb.Tag
        $appName = $cb.Text
        
        Update-Progress -dialog $prog -status "Instalando: $appName" -value $step
        Update-Status "Instalando: $appName"
        
        $installed = $false
        
        if ($hasWinget) {
            try {
                $proc = Start-Process "winget" -ArgumentList "install","--id",$appId,"--accept-source-agreements","--accept-package-agreements","-h" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                if ($proc.ExitCode -eq 0) { $installed = $true }
            } catch {}
        }
        
        if (-not $installed -and $hasChoco) {
            try {
                $chocoId = $appId.Split('.')[-1].ToLower()
                $proc = Start-Process "choco" -ArgumentList "install",$chocoId,"-y","--force" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                if ($proc.ExitCode -eq 0) { $installed = $true }
            } catch {}
        }
        
        if ($installed) { $successCount++ } else { $failCount++ }
    }
    
    $prog.Form.Close()
    
    if ($script:cancelled) {
        Update-Status "Instalacion cancelada" "warning"
    } else {
        Update-Status "Completado: $successCount exitosos, $failCount fallidos" "success"
        [System.Windows.Forms.MessageBox]::Show("Instalacion completada.`n`nExitosos: $successCount`nFallidos: $failCount", "Resultado", 0, 64)
    }
})
$installBtnPanel.Controls.Add($installSelectedBtn)

# Actualizar contador de seleccionados
foreach ($cb in $script:allCheckboxes) {
    $cb.Add_CheckedChanged({
        Update-SelectionCount
    })
}

function Update-SelectionCount {
    $count = ($script:allCheckboxes | Where-Object { $_.Checked }).Count
    $script:selCountLabel.Text = "Seleccionados: $count"
    $script:toggleAllBtn.Text = if ($count -eq $script:allCheckboxes.Count) { "Deseleccionar Todo" } else { "Seleccionar Todo" }
    $script:AllChecked = ($count -eq $script:allCheckboxes.Count)
}

# --- PANEL DE TWEAKS ---
$script:tweaksPanel = New-Object System.Windows.Forms.Panel
$script:tweaksPanel.Location = New-Object System.Drawing.Point(0, 0)
$script:tweaksPanel.Size = New-Object System.Drawing.Size(900, 635)
$script:tweaksPanel.BackColor = $theme.Background
$script:tweaksPanel.Visible = $false
$mainContainer.Controls.Add($script:tweaksPanel)

$headerTweaks = New-Object System.Windows.Forms.Label
$headerTweaks.Text = "OPTIMIZACIONES DEL SISTEMA"
$headerTweaks.Location = New-Object System.Drawing.Point(20, 15)
$headerTweaks.Size = New-Object System.Drawing.Size(400, 30)
$headerTweaks.Font = $fontHeader
$headerTweaks.ForeColor = $theme.Accent
$script:tweaksPanel.Controls.Add($headerTweaks)

$tweaks = @(
    @{name="Essential Tweaks"; desc="Aplicar tweaks esenciales de rendimiento"; action={
        Update-Status "Aplicando tweaks esenciales..."
        $prog = Show-Progress -title "Aplicando Tweaks" -max 5
        $prog.Form.Show()
        
        Update-Progress -dialog $prog -status "Configurando servicios..." -value 1
        $services = @("DiagTrack","dmwappushservice","WMPNetworkSvc")
        foreach ($s in $services) {
            try { Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue } catch {}
        }
        
        Update-Progress -dialog $prog -status "Configurando telemetria..." -value 2
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
        } catch {}
        
        Update-Progress -dialog $prog -status="Desactivando Cortana..." -value 3
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
        } catch {}
        
        Update-Progress -dialog $prog -status "Configurando energia..." -value 4
        try { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c } catch {}
        
        Update-Progress -dialog $prog -status "Completado" -value 5
        $prog.Form.Close()
        Update-Status "Tweaks aplicados correctamente" "success"
    }}
    @{name="Desactivar Telemetria"; desc="Desactiva completamente la telemetria de Windows"; action={
        Update-Status "Desactivando telemetria..."
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v AllowBuildPreview /t REG_DWORD /d 0 /f | Out-Null
            Stop-Service "DiagTrack" -Force -ErrorAction SilentlyContinue
            Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
            Update-Status "Telemetria desactivada" "success"
        } catch {
            Update-Status "Error desactivando telemetria" "error"
        }
    }}
    @{name="Desactivar Windows Defender"; desc="Desactiva temporalmente Windows Defender"; action={
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Esto desactivara Windows Defender temporalmente.`n`nContinuar?",
            "Confirmar",
            4, 48
        )
        if ($result -eq 6) {
            try {
                Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
                Update-Status "Windows Defender desactivado" "warning"
            } catch {
                Update-Status "No se pudo desactivar Defender. Use Defender Control." "error"
            }
        }
    }}
    @{name="Activar Windows Defender"; desc="Reactiva Windows Defender"; action={
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
            Update-Status "Windows Defender activado" "success"
        } catch {
            Update-Status "Error activando Defender" "error"
        }
    }}
    @{name="Limpiar Archivos Temporales"; desc="Elimina archivos temporales del sistema"; action={
        Update-Status "Limpiando archivos temporales..."
        $prog = Show-Progress -title "Limpiando" -max 3
        $prog.Form.Show()
        
        Update-Progress -dialog $prog -status "Limpiando TEMP usuario..." -value 1
        Get-ChildItem "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        
        Update-Progress -dialog $prog -status "Limpiando TEMP Windows..." -value 2
        Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        
        Update-Progress -dialog $prog -status "Completado" -value 3
        $prog.Form.Close()
        Update-Status "Archivos temporales eliminados" "success"
    }}
    @{name="Optimizar Red"; desc="Resetea la configuracion de red"; action={
        Update-Status "Optimizando red..."
        try {
            netsh int ip reset | Out-Null
            netsh winsock reset | Out-Null
            ipconfig /flushdns | Out-Null
            Update-Status "Red optimizada - Reinicie el equipo" "success"
        } catch {
            Update-Status "Error optimizando red" "error"
        }
    }}
)

$tweakY = 55
$tweakX = 20
$col = 0

foreach ($tweak in $tweaks) {
    $tweakPanel = New-Object System.Windows.Forms.Panel
    $tweakPanel.Location = New-Object System.Drawing.Point($tweakX, $tweakY)
    $tweakPanel.Size = New-Object System.Drawing.Size(280, 80)
    $tweakPanel.BackColor = $theme.PanelDark
    $script:tweaksPanel.Controls.Add($tweakPanel)
    
    $tweakBtn = New-ActionButton -text $tweak.name -x 5 -y 5 -width 270 -height 35 -style "primary"
    $tweakBtn.Add_Click($tweak.action)
    $tweakPanel.Controls.Add($tweakBtn)
    
    $tweakDesc = New-Object System.Windows.Forms.Label
    $tweakDesc.Text = $tweak.desc
    $tweakDesc.Location = New-Object System.Drawing.Point(10, 45)
    $tweakDesc.Size = New-Object System.Drawing.Size(260, 30)
    $tweakDesc.Font = $fontSmall
    $tweakDesc.ForeColor = $theme.TextMuted
    $tweakPanel.Controls.Add($tweakDesc)
    
    $col++
    if ($col -ge 3) {
        $col = 0
        $tweakX = 20
        $tweakY += 90
    } else {
        $tweakX += 290
    }
}

# --- PANEL DE ACTIVACION ---
$script:activatePanel = New-Object System.Windows.Forms.Panel
$script:activatePanel.Location = New-Object System.Drawing.Point(0, 0)
$script:activatePanel.Size = New-Object System.Drawing.Size(900, 635)
$script:activatePanel.BackColor = $theme.Background
$script:activatePanel.Visible = $false
$mainContainer.Controls.Add($script:activatePanel)

$headerActivate = New-Object System.Windows.Forms.Label
$headerActivate.Text = "ACTIVACION DE WINDOWS Y OFFICE"
$headerActivate.Location = New-Object System.Drawing.Point(20, 15)
$headerActivate.Size = New-Object System.Drawing.Size(500, 30)
$headerActivate.Font = $fontHeader
$headerActivate.ForeColor = $theme.Accent
$script:activatePanel.Controls.Add($headerActivate)

$descActivate = New-Object System.Windows.Forms.Label
$descActivate.Text = "Herramientas de activacion para Windows y Microsoft Office"
$descActivate.Location = New-Object System.Drawing.Point(20, 45)
$descActivate.Size = New-Object System.Drawing.Size(500, 20)
$descActivate.Font = $fontSmall
$descActivate.ForeColor = $theme.TextMuted
$script:activatePanel.Controls.Add($descActivate)

# Funcion para encontrar MAS
function Find-MAS {
    # Buscar en diferentes ubicaciones
    $paths = @(
        Join-Path $PWD.Path "MAS_AIO.cmd"
        Join-Path $PWD.Path "mas\MAS_AIO.cmd"
        Join-Path $PSScriptRoot "MAS_AIO.cmd"
        Join-Path $PSScriptRoot "mas\MAS_AIO.cmd"
    )
    
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    
    return $null
}

function Download-MAS {
    param ($destPath)
    
    Update-Status "Descargando MAS..."
    
    try {
        $urls = @(
            "https://github.com/massgravel/Microsoft-Activation-Scripts/raw/refs/heads/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd",
            "https://git.activated.win/Microsoft-Activation-Scripts/raw/refs/heads/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
        )
        
        foreach ($url in $urls) {
            try {
                Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing -TimeoutSec 30
                if (Test-Path $destPath) {
                    Update-Status "MAS descargado correctamente" "success"
                    return $true
                }
            } catch { continue }
        }
        
        return $false
    } catch {
        return $false
    }
}

# Botones de activacion
$activateButtons = @(
    @{name="MAS Interactivo"; desc="Abre MAS en modo interactivo con menu completo"; style="success"; action={
        Update-Status "Buscando MAS..."
        
        $masPath = Find-MAS
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $downloadPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not $masPath) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "MAS_AIO.cmd no encontrado en la carpeta.`n`nDesea descargarlo automaticamente?",
                "MAS no encontrado",
                4, 32
            )
            if ($result -eq 6) {
                if (-not (Download-MAS -destPath $downloadPath)) {
                    Update-Status "Error descargando MAS" "error"
                    return
                }
                $masPath = $downloadPath
            } else {
                return
            }
        }
        
        if ($masPath -and (Test-Path $masPath)) {
            Update-Status "Abriendo MAS..."
            Start-Process "cmd.exe" -ArgumentList "/c", "title MAS - Microsoft Activation Scripts && color 07 && call `"$masPath`"" -Verb RunAs
            Update-Status "MAS abierto en ventana separada" "success"
        } else {
            Update-Status "No se pudo encontrar MAS" "error"
        }
    }}
    @{name="Activar Windows"; desc="Activacion automatica de Windows con TSforge"; style="primary"; action={
        Update-Status "Preparando activacion de Windows..."
        
        $masPath = Find-MAS
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $downloadPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not $masPath) {
            if (-not (Download-MAS -destPath $downloadPath)) {
                Update-Status "Error descargando MAS" "error"
                return
            }
            $masPath = $downloadPath
        }
        
        if ($masPath -and (Test-Path $masPath)) {
            $tmpCmd = "$env:TEMP\mas_activate.cmd"
            "@echo off`ncall `"$masPath`" /Z-Windows" | Out-File $tmpCmd -Encoding ASCII
            
            Update-Status "Ejecutando activacion..."
            Start-Process "cmd.exe" -ArgumentList "/c", $tmpCmd -Verb RunAs -Wait
            Update-Status "Activacion de Windows completada" "success"
        }
    }}
    @{name="Activar Office"; desc="Activacion automatica de Microsoft Office"; style="primary"; action={
        Update-Status "Preparando activacion de Office..."
        
        $masPath = Find-MAS
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $downloadPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not $masPath) {
            if (-not (Download-MAS -destPath $downloadPath)) {
                Update-Status "Error descargando MAS" "error"
                return
            }
            $masPath = $downloadPath
        }
        
        if ($masPath -and (Test-Path $masPath)) {
            $tmpCmd = "$env:TEMP\mas_activate.cmd"
            "@echo off`ncall `"$masPath`" /Z-Office" | Out-File $tmpCmd -Encoding ASCII
            
            Update-Status "Ejecutando activacion..."
            Start-Process "cmd.exe" -ArgumentList "/c", $tmpCmd -Verb RunAs -Wait
            Update-Status "Activacion de Office completada" "success"
        }
    }}
    @{name="Activar Todo"; desc="Activar Windows + Office automaticamente"; style="success"; action={
        Update-Status "Preparando activacion completa..."
        
        $masPath = Find-MAS
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $downloadPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not $masPath) {
            if (-not (Download-MAS -destPath $downloadPath)) {
                Update-Status "Error descargando MAS" "error"
                return
            }
            $masPath = $downloadPath
        }
        
        if ($masPath -and (Test-Path $masPath)) {
            $tmpCmd = "$env:TEMP\mas_activate.cmd"
            "@echo off`ncall `"$masPath`" /Z-Windows /Z-Office" | Out-File $tmpCmd -Encoding ASCII
            
            Update-Status "Ejecutando activacion..."
            Start-Process "cmd.exe" -ArgumentList "/c", $tmpCmd -Verb RunAs -Wait
            Update-Status "Activacion completa finalizada" "success"
        }
    }}
    @{name="Activated.Win"; desc="Alternativa: get.activated.win"; style="warning"; action={
        Update-Status "Abriendo activated.win..."
        try {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
            Update-Status "Activador abierto" "success"
        } catch {
            Update-Status "Error abriendo activador" "error"
        }
    }}
    @{name="WinUtil"; desc="Chris Titus Tech Windows Utility"; style="info"; action={
        Update-Status "Abriendo WinUtil..."
        try {
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://christitus.com/win | iex`"" -Verb RunAs
            Update-Status "WinUtil abierto" "success"
        } catch {
            Update-Status "Error abriendo WinUtil" "error"
        }
    }}
)

$actY = 80
$actX = 20
$actCol = 0

foreach ($btn in $activateButtons) {
    $actPanel = New-Object System.Windows.Forms.Panel
    $actPanel.Location = New-Object System.Drawing.Point($actX, $actY)
    $actPanel.Size = New-Object System.Drawing.Size(280, 85)
    $actPanel.BackColor = $theme.PanelDark
    $script:activatePanel.Controls.Add($actPanel)
    
    $actBtn = New-ActionButton -text $btn.name -x 5 -y 5 -width 270 -height 40 -style $btn.style
    $actBtn.Add_Click($btn.action)
    $actPanel.Controls.Add($actBtn)
    
    $actDesc = New-Object System.Windows.Forms.Label
    $actDesc.Text = $btn.desc
    $actDesc.Location = New-Object System.Drawing.Point(10, 50)
    $actDesc.Size = New-Object System.Drawing.Size(260, 30)
    $actDesc.Font = $fontSmall
    $actDesc.ForeColor = $theme.TextMuted
    $actPanel.Controls.Add($actDesc)
    
    $actCol++
    if ($actCol -ge 3) {
        $actCol = 0
        $actX = 20
        $actY += 95
    } else {
        $actX += 290
    }
}

# --- PANEL DE CONFIGURACION ---
$script:configPanel = New-Object System.Windows.Forms.Panel
$script:configPanel.Location = New-Object System.Drawing.Point(0, 0)
$script:configPanel.Size = New-Object System.Drawing.Size(900, 635)
$script:configPanel.BackColor = $theme.Background
$script:configPanel.Visible = $false
$mainContainer.Controls.Add($script:configPanel)

$headerConfig = New-Object System.Windows.Forms.Label
$headerConfig.Text = "CONFIGURACION"
$headerConfig.Location = New-Object System.Drawing.Point(20, 15)
$headerConfig.Size = New-Object System.Drawing.Size(300, 30)
$headerConfig.Font = $fontHeader
$headerConfig.ForeColor = $theme.Accent
$script:configPanel.Controls.Add($headerConfig)

# Estado de gestores
$wg = Test-Winget
$ch = Test-Chocolatey

$wgLabel = New-Object System.Windows.Forms.Label
$wgLabel.Text = "Winget: " + $(if($wg){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$wgLabel.Location = New-Object System.Drawing.Point(20, 60)
$wgLabel.Size = New-Object System.Drawing.Size(300, 25)
$wgLabel.Font = $fontNormal
$wgLabel.ForeColor = if($wg){$theme.Success}else{$theme.Error}
$script:configPanel.Controls.Add($wgLabel)

$chLabel = New-Object System.Windows.Forms.Label
$chLabel.Text = "Chocolatey: " + $(if($ch){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$chLabel.Location = New-Object System.Drawing.Point(20, 90)
$chLabel.Size = New-Object System.Drawing.Size(300, 25)
$chLabel.Font = $fontNormal
$chLabel.ForeColor = if($ch){$theme.Success}else{$theme.Error}
$script:configPanel.Controls.Add($chLabel)

if (-not $wg) {
    $instWgBtn = New-ActionButton -text "Instalar Winget" -x 350 -y 55 -width 150 -style "info"
    $instWgBtn.Add_Click({
        Update-Status "Instalando Winget..."
        try {
            $uri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
            $out = "$env:TEMP\Winget.msixbundle"
            Invoke-WebRequest -Uri $uri -OutFile $out -UseBasicParsing
            Add-AppxPackage -Path $out
            Update-Status "Winget instalado correctamente" "success"
        } catch {
            Update-Status "Error instalando Winget" "error"
        }
    })
    $script:configPanel.Controls.Add($instWgBtn)
}

if (-not $ch) {
    $instChBtn = New-ActionButton -text "Instalar Chocolatey" -x 350 -y 85 -width 150 -style "info"
    $instChBtn.Add_Click({
        Update-Status "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Update-Status "Chocolatey instalado correctamente" "success"
        } catch {
            Update-Status "Error instalando Chocolatey" "error"
        }
    })
    $script:configPanel.Controls.Add($instChBtn)
}

# Informacion del sistema
$sysInfoLabel = New-Object System.Windows.Forms.Label
$sysInfoLabel.Text = "INFORMACION DEL SISTEMA"
$sysInfoLabel.Location = New-Object System.Drawing.Point(20, 140)
$sysInfoLabel.Size = New-Object System.Drawing.Size(300, 25)
$sysInfoLabel.Font = $fontSubHeader
$sysInfoLabel.ForeColor = $theme.Category
$script:configPanel.Controls.Add($sysInfoLabel)

$osInfo = Get-CimInstance Win32_OperatingSystem
$sysLabels = @(
    "Sistema: $($osInfo.Caption)",
    "Version: $($osInfo.Version)",
    "Arquitectura: $env:PROCESSOR_ARCHITECTURE",
    "Usuario: $env:USERNAME",
    "Equipo: $env:COMPUTERNAME"
)

$sysY = 175
foreach ($info in $sysLabels) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $info
    $lbl.Location = New-Object System.Drawing.Point(20, $sysY)
    $lbl.Size = New-Object System.Drawing.Size(500, 20)
    $lbl.Font = $fontNormal
    $lbl.ForeColor = $theme.TextSecondary
    $script:configPanel.Controls.Add($lbl)
    $sysY += 25
}

# Creditos
$creditsLabel = New-Object System.Windows.Forms.Label
$creditsLabel.Text = "Shadowiex v8.0 - WinUtil Style Edition"
$creditsLabel.Location = New-Object System.Drawing.Point(20, 350)
$creditsLabel.Size = New-Object System.Drawing.Size(400, 25)
$creditsLabel.Font = $fontSubHeader
$creditsLabel.ForeColor = $theme.Accent
$script:configPanel.Controls.Add($creditsLabel)

$authorLabel = New-Object System.Windows.Forms.Label
$authorLabel.Text = "Creado por WDPN | github.com/WalterShadow2001"
$authorLabel.Location = New-Object System.Drawing.Point(20, 380)
$authorLabel.Size = New-Object System.Drawing.Size(400, 20)
$authorLabel.Font = $fontSmall
$authorLabel.ForeColor = $theme.TextMuted
$script:configPanel.Controls.Add($authorLabel)

# --- NAVEGACION ---
$script:activeNav = "Instalar"
$script:installPanel.Visible = $true

foreach ($navBtn in $navButtons) {
    $navBtn.Add_Click({
        $script:activeNav = $this.Tag
        
        # Resetear colores
        foreach ($n in $navButtons) {
            $n.BackColor = $theme.PanelLight
        }
        $this.BackColor = $theme.Accent
        
        # Mostrar panel correspondiente
        $script:installPanel.Visible = ($this.Tag -eq "Instalar")
        $script:tweaksPanel.Visible = ($this.Tag -eq "Tweaks")
        $script:activatePanel.Visible = ($this.Tag -eq "Activar")
        $script:configPanel.Visible = ($this.Tag -eq "Config")
        
        Update-Status "Panel: $($this.Tag)"
    })
}

# Activar primer boton
$navButtons[0].BackColor = $theme.Accent

# Mostrar formulario
Update-Status "Listo - Shadowiex v8.0 WinUtil Style"
[void]$form.ShowDialog()
