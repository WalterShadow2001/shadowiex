<#
.SYNOPSIS
    Shadowiex - Professional Edition v7.0
.DESCRIPTION
    Versión mejorada con barras de progreso, mejor manejo de errores
    e integración con Microsoft Activation Scripts (MAS).
.NOTES
    Autor: WalterShadow2001
    Versión: 7.0 - Professional Enhanced
#>

# --- CONFIGURACIÓN INICIAL ---
 $ErrorActionPreference = "Continue"
 $ProgressPreference = 'SilentlyContinue'
 $script:UIControls = @{}
 $script:InstallationCancelled = $false

# Funciones de Verificación (Definidas PRIMERO)
function Test-Winget { 
    try { 
        $proc = Start-Process "winget" -ArgumentList "--version" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        return ($proc.ExitCode -eq 0)
    } 
    catch { return $false } 
}

function Test-Chocolatey { 
    try { 
        $proc = Start-Process "choco" -ArgumentList "--version" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        return ($proc.ExitCode -eq 0)
    } 
    catch { return $false } 
}

# Colores del tema
 $colors = @{
    Background  = [System.Drawing.Color]::FromArgb(25, 25, 35)
    Panel       = [System.Drawing.Color]::FromArgb(40, 40, 55)
    PanelLight  = [System.Drawing.Color]::FromArgb(55, 55, 75)
    Accent      = [System.Drawing.Color]::FromArgb(0, 122, 204)
    AccentHover = [System.Drawing.Color]::FromArgb(0, 95, 170)
    Text        = [System.Drawing.Color]::White
    TextSub     = [System.Drawing.Color]::FromArgb(180, 180, 190)
    Success     = [System.Drawing.Color]::FromArgb(46, 204, 113)
    Warning     = [System.Drawing.Color]::FromArgb(241, 196, 15)
    Danger      = [System.Drawing.Color]::FromArgb(231, 76, 60)
    Info        = [System.Drawing.Color]::FromArgb(52, 152, 219)
    Progress    = [System.Drawing.Color]::FromArgb(0, 200, 150)
}

# Estilos de Fuente
 $styleBold = [System.Drawing.FontStyle]::Bold
 $styleRegular = [System.Drawing.FontStyle]::Regular
 $styleItalic = [System.Drawing.FontStyle]::Italic

# Verificación de Administrador
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation

# --- FORMULARIO PRINCIPAL ---
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "Shadowiex Professional v7.0"
 $form.Size = New-Object System.Drawing.Size(1000, 720)
 $form.StartPosition = "CenterScreen"
 $form.BackColor = $colors.Background
 $form.ForeColor = $colors.Text
 $form.MinimumSize = New-Object System.Drawing.Size(900, 650)
 $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable

# --- LOGO E ICONO ---
try {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $iconPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.ico"
    if (Test-Path -Path $iconPath) { $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath) }

    $logoPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.png"
    if (Test-Path -Path $logoPath) {
        $logoImage = [System.Drawing.Image]::FromFile($logoPath)
        $pictureBox = New-Object System.Windows.Forms.PictureBox
        $pictureBox.Image = $logoImage
        $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
        $pictureBox.Size = New-Object System.Drawing.Size(55, 55)
        $pictureBox.Location = New-Object System.Drawing.Point(20, 12)
        $pictureBox.BackColor = [System.Drawing.Color]::Transparent
        $form.Controls.Add($pictureBox)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Shadowiex Professional"
        $titleLabel.Location = New-Object System.Drawing.Point(85, 22)
        $titleLabel.Size = New-Object System.Drawing.Size(350, 35)
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, $styleBold)
        $titleLabel.ForeColor = $colors.Text
        $form.Controls.Add($titleLabel)
    }
} catch {}

# Barra de estado superior
 $statusPanel = New-Object System.Windows.Forms.Panel
 $statusPanel.Location = New-Object System.Drawing.Point(0, 70)
 $statusPanel.Size = New-Object System.Drawing.Size(1000, 35)
 $statusPanel.BackColor = $colors.Panel
 $statusPanel.Dock = [System.Windows.Forms.DockStyle]::None
 $form.Controls.Add($statusPanel)

 $globalStatusLabel = New-Object System.Windows.Forms.Label
 $globalStatusLabel.Text = "Listo"
 $globalStatusLabel.Location = New-Object System.Drawing.Point(20, 8)
 $globalStatusLabel.Size = New-Object System.Drawing.Size(960, 20)
 $globalStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, $styleRegular)
 $globalStatusLabel.ForeColor = $colors.TextSub
 $statusPanel.Controls.Add($globalStatusLabel)

# Footer
 $footerLabel = New-Object System.Windows.Forms.Label
 $footerLabel.Text = "CREADO POR WDPN | v7.0 Professional"
 $footerLabel.Location = New-Object System.Drawing.Point(20, 655)
 $footerLabel.Size = New-Object System.Drawing.Size(300, 25)
 $footerLabel.ForeColor = $colors.TextSub
 $footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, $styleItalic)
 $form.Controls.Add($footerLabel)

# --- PESTAÑAS ---
 $tabControl = New-Object System.Windows.Forms.TabControl
 $tabControl.Location = New-Object System.Drawing.Point(0, 105)
 $tabControl.Size = New-Object System.Drawing.Size(984, 545)
 $tabControl.BackColor = $colors.Background
 $tabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons
 $tabControl.ItemSize = New-Object System.Drawing.Size(140, 38)
 $tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleBold)
 $tabControl.Padding = New-Object System.Drawing.Point(12, 4)

 $tabBasicSoftware = New-Object System.Windows.Forms.TabPage
 $tabBasicSoftware.Text = "Software Básico"
 $tabBasicSoftware.BackColor = $colors.Background
 $tabBasicSoftware.Padding = New-Object System.Windows.Forms.Padding(10)

 $tabInstallers = New-Object System.Windows.Forms.TabPage
 $tabInstallers.Text = "Instaladores"
 $tabInstallers.BackColor = $colors.Background
 $tabInstallers.Padding = New-Object System.Windows.Forms.Padding(10)

 $tabActivations = New-Object System.Windows.Forms.TabPage
 $tabActivations.Text = "Activaciones"
 $tabActivations.BackColor = $colors.Background
 $tabActivations.Padding = New-Object System.Windows.Forms.Padding(10)

 $tabSettings = New-Object System.Windows.Forms.TabPage
 $tabSettings.Text = "Configuración"
 $tabSettings.BackColor = $colors.Background
 $tabSettings.Padding = New-Object System.Windows.Forms.Padding(10)

 $tabControl.Controls.Add($tabBasicSoftware)
 $tabControl.Controls.Add($tabInstallers)
 $tabControl.Controls.Add($tabActivations)
 $tabControl.Controls.Add($tabSettings)
 $form.Controls.Add($tabControl)

# --- FUNCIONES UI HELPER MEJORADAS ---

function Create-ModernButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 190,
        [int]$height = 42,
        [scriptblock]$action,
        [object]$backColor = $null
    )
    
    if ($null -eq $backColor) { $btnColor = $colors.Accent } else { $btnColor = $backColor }
    
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Text = $text
    $button.BackColor = $btnColor
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, $styleBold)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.FlatAppearance.BorderSize = 0
    $button.Margin = New-Object System.Windows.Forms.Padding(3)
    
    if ($null -eq $backColor) {
        $button.FlatAppearance.MouseOverBackColor = $colors.AccentHover
    } else {
        $r = [Math]::Max(0, $backColor.R - 25)
        $g = [Math]::Max(0, $backColor.G - 25)
        $b = [Math]::Max(0, $backColor.B - 25)
        $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb($r, $g, $b)
    }
    
    if ($action) { $button.Add_Click($action) }
    return $button
}

function Create-ModernLabel {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 300,
        [bool]$isTitle = $false,
        [object]$foreColor = $null
    )
    
    $labelHeight = 22
    if ($isTitle) { $labelHeight = 32 }
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($width, $labelHeight)
    $label.ForeColor = if ($foreColor) { $foreColor } else { $colors.Text }
    
    if ($isTitle) {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 12.5, $styleBold)
    } else {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, $styleRegular)
    }
    return $label
}

function Create-ProgressBar {
    param (
        [int]$x,
        [int]$y,
        [int]$width = 350,
        [int]$height = 25
    )
    
    $progress = New-Object System.Windows.Forms.ProgressBar
    $progress.Location = New-Object System.Drawing.Point($x, $y)
    $progress.Size = New-Object System.Drawing.Size($width, $height)
    $progress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
    $progress.Minimum = 0
    $progress.Maximum = 100
    $progress.Value = 0
    
    return $progress
}

function Update-GlobalStatus {
    param ([string]$message, [object]$color = $null)
    if ($globalStatusLabel.InvokeRequired) {
        $globalStatusLabel.Invoke([Action]{ param($m, $c) $globalStatusLabel.Text = $m; if ($c) { $globalStatusLabel.ForeColor = $c } } ,$message, $color)
    } else {
        $globalStatusLabel.Text = $message
        if ($color) { $globalStatusLabel.ForeColor = $color }
    }
}

# --- FORMULARIO DE PROGRESO MEJORADO ---
function Show-ProgressDialog {
    param (
        [string]$title = "Procesando...",
        [int]$totalSteps = 1
    )
    
    $progForm = New-Object System.Windows.Forms.Form
    $progForm.Text = $title
    $progForm.Size = New-Object System.Drawing.Size(520, 200)
    $progForm.BackColor = $colors.Background
    $progForm.StartPosition = "CenterParent"
    $progForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $progForm.ControlBox = $false
    $progForm.TopMost = $true
    
    # Label de título
    $lblTitle = Create-ModernLabel -text $title -x 20 -y 15 -width 460 -isTitle $true
    $progForm.Controls.Add($lblTitle)
    
    # Label de estado actual
    $lblStatus = Create-ModernLabel -text "Iniciando..." -x 20 -y 55 -width 460
    $lblStatus.ForeColor = $colors.TextSub
    $progForm.Controls.Add($lblStatus)
    
    # Barra de progreso principal
    $progressBar = Create-ProgressBar -x 20 -y 85 -width 460 -height 28
    $progForm.Controls.Add($progressBar)
    
    # Label de porcentaje
    $lblPercent = Create-ModernLabel -text "0%" -x 20 -y 120 -width 100
    $lblPercent.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleBold)
    $lblPercent.ForeColor = $colors.Success
    $progForm.Controls.Add($lblPercent)
    
    # Label de paso actual
    $lblStep = Create-ModernLabel -text "Paso 0 de $totalSteps" -x 380 -y 120 -width 100
    $lblStep.ForeColor = $colors.TextSub
    $progForm.Controls.Add($lblStep)
    
    # Botón cancelar
    $btnCancel = Create-ModernButton -text "Cancelar" -x 380 -y 150 -width 100 -height 30 -backColor $colors.Danger -action {
        $script:InstallationCancelled = $true
        $progForm.Close()
    }
    $progForm.Controls.Add($btnCancel)
    
    return @{
        Form = $progForm
        ProgressBar = $progressBar
        LabelStatus = $lblStatus
        LabelPercent = $lblPercent
        LabelStep = $lblStep
        LabelTitle = $lblTitle
        TotalSteps = $totalSteps
        CurrentStep = 0
    }
}

function Update-ProgressDialog {
    param (
        $dialog,
        [string]$status,
        [int]$step = 0,
        [int]$percent = -1
    )
    
    if ($dialog.Form.IsDisposed) { return }
    
    if ($status) {
        $dialog.LabelStatus.Text = $status
    }
    
    if ($step -gt 0) {
        $dialog.CurrentStep = $step
        $dialog.LabelStep.Text = "Paso $step de $($dialog.TotalSteps)"
    }
    
    if ($percent -ge 0) {
        $dialog.ProgressBar.Value = [Math]::Min(100, $percent)
        $dialog.LabelPercent.Text = "$percent%"
    }
    
    $dialog.Form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

# --- LÓGICA DE INSTALACIÓN MEJORADA ---

function Install-Winget {
    param ($progressDialog)
    
    Update-ProgressDialog -dialog $progressDialog -status "Descargando Winget..." -percent 10
    
    try {
        $uri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $out = "$env:TEMP\Winget.msixbundle"
        
        # Descargar con timeout
        $webClient = New-Object System.Net.WebClient
        $downloadTask = $webClient.DownloadFileTaskAsync($uri, $out)
        
        # Esperar con timeout de 60 segundos
        $timeout = 60
        $start = Get-Date
        while (-not $downloadTask.IsCompleted -and ((Get-Date) - $start).TotalSeconds -lt $timeout) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 100
        }
        
        if (-not $downloadTask.IsCompleted) {
            $webClient.CancelAsync()
            return $false
        }
        
        Update-ProgressDialog -dialog $progressDialog -status "Instalando Winget..." -percent 50
        
        Add-AppxPackage -Path $out -ErrorAction Stop
        Update-ProgressDialog -dialog $progressDialog -status "Winget instalado correctamente" -percent 100
        
        Start-Sleep -Milliseconds 500
        return $true
    } catch { 
        Update-ProgressDialog -dialog $progressDialog -status "Error instalando Winget: $($_.Exception.Message)"
        Start-Sleep -Seconds 2
        return $false 
    }
}

function Install-Chocolatey {
    param ($progressDialog)
    
    Update-ProgressDialog -dialog $progressDialog -status "Instalando Chocolatey..." -percent 10
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        
        $script = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        
        Update-ProgressDialog -dialog $progressDialog -status "Ejecutando instalación..." -percent 50
        
        Invoke-Expression $script
        
        Update-ProgressDialog -dialog $progressDialog -status "Chocolatey instalado" -percent 100
        Start-Sleep -Milliseconds 500
        return $true
    } catch { 
        Update-ProgressDialog -dialog $progressDialog -status "Error instalando Chocolatey"
        Start-Sleep -Seconds 2
        return $false 
    }
}

function Install-Software {
    param (
        [string]$id, 
        [string]$name, 
        $progressDialog,
        [int]$stepNumber,
        [int]$totalSteps
    )
    
    if ($script:InstallationCancelled) { return $false }
    
    $basePercent = [int](($stepNumber - 1) / $totalSteps * 100)
    $endPercent = [int]($stepNumber / $totalSteps * 100)
    
    Update-ProgressDialog -dialog $progressDialog -status "Instalando: $name" -step $stepNumber -percent $basePercent
    
    $success = $false
    $hasWinget = Test-Winget
    $hasChoco = Test-Chocolatey
    
    # Intentar con Winget primero
    if ($hasWinget) {
        Update-ProgressDialog -dialog $progressDialog -status "Instalando $name via Winget..." -percent ($basePercent + 10)
        
        try {
            $proc = Start-Process "winget" -ArgumentList "install", "--id", $id, "--accept-source-agreements", "--accept-package-agreements", "-h" -NoNewWindow -PassThru -Wait -ErrorAction Stop
            
            if ($proc.ExitCode -eq 0) { 
                $success = $true 
                Update-ProgressDialog -dialog $progressDialog -status "✓ $name instalado correctamente" -percent $endPercent
            }
        } catch {
            Update-ProgressDialog -dialog $progressDialog -status "Winget falló, intentando Chocolatey..."
        }
    }
    
    # Si falló, intentar con Chocolatey
    if (-not $success -and $hasChoco) {
        Update-ProgressDialog -dialog $progressDialog -status "Instalando $name via Chocolatey..." -percent ($basePercent + 30)
        
        try {
            $cid = $id.Split('.')[-1].ToLower()
            $proc = Start-Process "choco" -ArgumentList "install", $cid, "-y", "--force" -NoNewWindow -PassThru -Wait -ErrorAction Stop
            
            if ($proc.ExitCode -eq 0) { 
                $success = $true 
                Update-ProgressDialog -dialog $progressDialog -status "✓ $name instalado correctamente" -percent $endPercent
            }
        } catch {
            Update-ProgressDialog -dialog $progressDialog -status "Chocolatey también falló para $name"
        }
    }
    
    if (-not $success) {
        Update-ProgressDialog -dialog $progressDialog -status "✗ Error instalando: $name" -percent $endPercent
    }
    
    Start-Sleep -Milliseconds 300
    return $success
}

function Download-And-Install {
    param ($url, $name, $dest, $progressDialog, $stepNumber, $totalSteps)
    
    $basePercent = [int](($stepNumber - 1) / $totalSteps * 100)
    $endPercent = [int]($stepNumber / $totalSteps * 100)
    
    $file = Join-Path $dest $name
    
    Update-ProgressDialog -dialog $progressDialog -status "Instalando: $name" -step $stepNumber -percent $basePercent
    
    try {
        if (Test-Path $url) {
            Copy-Item -Path $url -Destination $file -Force
            Update-ProgressDialog -dialog $progressDialog -status "Ejecutando instalador..." -percent ($basePercent + 50)
            
            $p = Start-Process $file -ArgumentList "/S", "/quiet", "/norestart" -PassThru -Wait -ErrorAction Stop
            Update-ProgressDialog -dialog $progressDialog -status "✓ $name completado" -percent $endPercent
            return $true
        } else {
            Update-ProgressDialog -dialog $progressDialog -status "✗ Archivo no encontrado: $name"
            return $false
        }
    } catch { 
        Update-ProgressDialog -dialog $progressDialog -status "✗ Error: $($_.Exception.Message)"
        return $false 
    }
}

# --- FUNCIONES DE ACTIVACIÓN ---

function Open-MASActivation {
    Update-GlobalStatus "Abriendo Microsoft Activation Scripts..." $colors.Info
    
    try {
        # Buscar el archivo MAS_AIO.cmd
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $masPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not (Test-Path $masPath)) {
            # Intentar descargar desde GitHub
            Update-GlobalStatus "Descargando MAS desde GitHub..." $colors.Warning
            
            $masUrl = "https://github.com/massgravel/Microsoft-Activation-Scripts/raw/refs/heads/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
            
            try {
                Invoke-WebRequest -Uri $masUrl -OutFile $masPath -UseBasicParsing
                Update-GlobalStatus "MAS descargado correctamente" $colors.Success
            } catch {
                # URL alternativa
                $masUrl2 = "https://git.activated.win/Microsoft-Activation-Scripts/raw/refs/heads/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
                Invoke-WebRequest -Uri $masUrl2 -OutFile $masPath -UseBasicParsing
            }
        }
        
        if (Test-Path $masPath) {
            # Ejecutar MAS en una nueva ventana de CMD
            Start-Process "cmd.exe" -ArgumentList "/c", "title Microsoft Activation Scripts && color 07 && call `"$masPath`"" -Verb RunAs
            Update-GlobalStatus "MAS abierto en ventana separada" $colors.Success
        } else {
            [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar ni descargar MAS_AIO.cmd", "Error", 0, 16)
            Update-GlobalStatus "Error al abrir MAS" $colors.Danger
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
        Update-GlobalStatus "Error: $($_.Exception.Message)" $colors.Danger
    }
}

function Activate-WindowsTSforge {
    param ([bool]$windows = $true, [bool]$office = $true, [bool]$esu = $false)
    
    Update-GlobalStatus "Iniciando activación TSforge..." $colors.Info
    
    $progress = Show-ProgressDialog -title "Activación TSforge" -totalSteps 5
    
    try {
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        # Descargar MAS si no existe
        Update-ProgressDialog -dialog $progress -status "Verificando MAS..." -step 1 -percent 10
        
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $masPath = Join-Path $scriptRoot "MAS_AIO.cmd"
        
        if (-not (Test-Path $masPath)) {
            Update-ProgressDialog -dialog $progress -status "Descargando MAS..." -percent 20
            
            $masUrl = "https://github.com/massgravel/Microsoft-Activation-Scripts/raw/refs/heads/master/MAS/Separate-Files-Version/Activators/MAS_AIO.cmd"
            Invoke-WebRequest -Uri $masUrl -OutFile $masPath -UseBasicParsing
        }
        
        Update-ProgressDialog -dialog $progress -status "Preparando activación..." -step 2 -percent 30
        
        # Construir parámetros
        $params = @()
        if ($windows) { $params += "/Z-Windows" }
        if ($office) { $params += "/Z-Office" }
        if ($esu) { $params += "/Z-ESU" }
        
        $paramStr = $params -join " "
        
        Update-ProgressDialog -dialog $progress -status "Ejecutando activación..." -step 3 -percent 50
        
        # Crear script temporal
        $tmpCmd = "$env:TEMP\tsforge_act.cmd"
        "@echo off`ncall `"$masPath`" $paramStr" | Out-File $tmpCmd -Encoding ASCII
        
        Update-ProgressDialog -dialog $progress -status "Activando (esto puede tardar)..." -step 4 -percent 70
        
        $proc = Start-Process "cmd.exe" -ArgumentList "/c", $tmpCmd -NoNewWindow -PassThru -Wait
        
        Update-ProgressDialog -dialog $progress -status "Completado" -step 5 -percent 100
        
        Start-Sleep -Milliseconds 500
        $progress.Form.Close()
        
        [System.Windows.Forms.MessageBox]::Show("Proceso de activación completado.`nRevise la ventana de CMD para ver el resultado.", "TSforge", 0, 64)
        Update-GlobalStatus "Activación TSforge completada" $colors.Success
        
    } catch {
        $progress.Form.Close()
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
        Update-GlobalStatus "Error en activación" $colors.Danger
    }
}

function Activate-WithMassgrave {
    Update-GlobalStatus "Abriendo activador massgrave..." $colors.Info
    
    try {
        # Ejecutar el comando de activación
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
        Update-GlobalStatus "Activador massgrave iniciado" $colors.Success
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
        Update-GlobalStatus "Error al abrir activador" $colors.Danger
    }
}

function Activate-WithWinUtil {
    Update-GlobalStatus "Abriendo WinUtil (Chris Titus)..." $colors.Info
    
    try {
        Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://christitus.com/win | iex`"" -Verb RunAs
        Update-GlobalStatus "WinUtil iniciado" $colors.Success
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
        Update-GlobalStatus "Error al abrir WinUtil" $colors.Danger
    }
}

# --- FUNCIONES DE UTILIDADES ---

function Initialize-Installers {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $dir = Join-Path $root "instaladores"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $dir) { return Get-ChildItem $dir -Filter "*.exe" }
    return @()
}

function Download-InstallersFromGitHub {
    param ($dest)
    
    $progress = Show-ProgressDialog -title "Descargando Instaladores" -totalSteps 4
    $progress.Form.Show()
    [System.Windows.Forms.Application]::DoEvents()
    
    try {
        Update-ProgressDialog -dialog $progress -status "Conectando a GitHub..." -step 1 -percent 10
        
        $url = "https://github.com/WalterShadow2001/shadowiex/archive/refs/heads/main.zip"
        $zip = "$env:TEMP\shadowiex.zip"
        $ext = "$env:TEMP\shadowiex_ext"
        
        Update-ProgressDialog -dialog $progress -status "Descargando archivos..." -step 2 -percent 30
        Invoke-WebRequest $url -OutFile $zip -UseBasicParsing
        
        Update-ProgressDialog -dialog $progress -status "Extrayendo archivos..." -step 3 -percent 60
        if (Test-Path $ext) { Remove-Item $ext -Recurse -Force }
        Expand-Archive $zip $ext -Force
        
        $src = Join-Path $ext "shadowiex-main\instaladores"
        if (Test-Path $src) { 
            Copy-Item "$src\*.exe" $dest -Force -ErrorAction SilentlyContinue
        }
        
        Update-ProgressDialog -dialog $progress -status "Limpiando temporales..." -step 4 -percent 90
        Remove-Item $zip, $ext -Recurse -Force -ErrorAction SilentlyContinue
        
        Update-ProgressDialog -dialog $progress -status "Completado" -percent 100
        Start-Sleep -Milliseconds 500
        $progress.Form.Close()
        
        [System.Windows.Forms.MessageBox]::Show("Instaladores descargados correctamente.", "Éxito", 0, 64)
        return $true
    } catch {
        $progress.Form.Close()
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
        return $false
    }
}

# --- DATA SOFTWARE ---
 $softwareCategories = @{
    "Navegadores" = @(
        @{id="Google.Chrome";n="Google Chrome";i="🌐"},
        @{id="Mozilla.Firefox";n="Mozilla Firefox";i="🦊"},
        @{id="Opera.Opera";n="Opera GX";i="🎭"},
        @{id="Microsoft.Edge";n="Microsoft Edge";i="🔵"},
        @{id="BraveSoftware.BraveBrowser";n="Brave Browser";i="🦁"}
    )
    "Desarrollo" = @(
        @{id="Git.Git";n="Git";i="📁"},
        @{id="GitHub.GitHubDesktop";n="GitHub Desktop";i="🐙"},
        @{id="Microsoft.VisualStudioCode";n="VS Code";i="🔧"},
        @{id="Notepad++.Notepad++";n="Notepad++";i="📝"},
        @{id="Python.Python.3";n="Python 3";i="🐍"},
        @{id="Oracle.JDK.17";n="Oracle JDK 17";i="☕"}
    )
    "Multimedia" = @(
        @{id="VideoLAN.VLC";n="VLC Media Player";i="🎵"},
        @{id="GIMP.GIMP";n="GIMP";i="🎨"},
        @{id="IrfanSkiljan.IrfanView";n="IrfanView";i="🖼️"},
        @{id="Spotify.Spotify";n="Spotify";i="🎧"},
        @{id="KDE.Kdenlive";n="Kdenlive";i="🎬"}
    )
    "Comunicación" = @(
        @{id="Zoom.Zoom";n="Zoom";i="📞"},
        @{id="Microsoft.Teams";n="Microsoft Teams";i="👥"},
        @{id="Discord.Discord";n="Discord";i="💬"},
        @{id="Telegram.TelegramDesktop";n="Telegram";i="📱"},
        @{id="WhatsApp.WhatsApp";n="WhatsApp Desktop";i="💬"},
        @{id="Slack.Slack";n="Slack";i="📋"}
    )
    "Utilidades" = @(
        @{id="7zip.7zip";n="7-Zip";i="🗜️"},
        @{id="Adobe.Acrobat.Reader.64-bit";n="Adobe Reader";i="📄"},
        @{id="RARLab.WinRAR";n="WinRAR";i="🗜️"},
        @{id="TeamViewer.TeamViewer";n="TeamViewer";i="👥"},
        @{id="Rufus.Rufus";n="Rufus";i="🔧"},
        @{id="Balena.Etcher";n="Etcher";i="💾"},
        @{id="REALiX.HWiNFO";n="HWiNFO";i="📊"}
    )
    "Runtimes" = @(
        @{id="Oracle.JavaRuntimeEnvironment";n="Java Runtime";i="☕"},
        @{id="Microsoft.DotNet.Runtime.6";n=".NET 6 Runtime";i="🟢"},
        @{id="Microsoft.DotNet.Runtime.7";n=".NET 7 Runtime";i="🟢"},
        @{id="Microsoft.DotNet.DesktopRuntime.6";n=".NET 6 Desktop";i="🟢"},
        @{id="Microsoft.VCRedist.2015+.x64";n="Visual C++ Redist";i="🔴"},
        @{id="Microsoft.DirectX";n="DirectX End-User";i="🎮"}
    )
}

# --- POBLAR TABS ---

function Populate-SoftwareTab {
    $tabBasicSoftware.Controls.Clear()
    
    # Panel con scroll
    $pnl = New-Object System.Windows.Forms.Panel
    $pnl.AutoScroll = $true
    $pnl.Location = New-Object System.Drawing.Point(10, 10)
    $pnl.Size = New-Object System.Drawing.Size(920, 380)
    $pnl.BackColor = $colors.Panel
    $pnl.Padding = New-Object System.Windows.Forms.Padding(10)
    $tabBasicSoftware.Controls.Add($pnl)

    $global:allCheckboxes = @()
    $y = 10
    $font = New-Object System.Drawing.Font("Segoe UI", 9.5, $styleRegular)

    foreach ($cat in $softwareCategories.Keys) {
        # Título de categoría
        $lbl = Create-ModernLabel -text "■ $cat" -x 10 -y $y -isTitle $true
        $lbl.ForeColor = $colors.Accent
        $pnl.Controls.Add($lbl)
        $y += 38
        
        foreach ($sw in $softwareCategories[$cat]) {
            $cb = New-Object System.Windows.Forms.CheckBox
            $cb.Text = "$($sw.i)  $($sw.n)"
            $cb.Location = New-Object System.Drawing.Point(25, $y)
            $cb.Size = New-Object System.Drawing.Size(550, 28)
            $cb.Font = $font
            $cb.ForeColor = $colors.Text
            $cb.BackColor = $colors.Panel
            $cb.Padding = New-Object System.Windows.Forms.Padding(5)
            $cb.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $pnl.Controls.Add($cb)
            $global:allCheckboxes += @{cb=$cb; id=$sw.id; n=$sw.n}
            $y += 32
        }
        $y += 15
    }

    # Panel de botones inferior
    $btnPanel = New-Object System.Windows.Forms.Panel
    $btnPanel.Location = New-Object System.Drawing.Point(10, 400)
    $btnPanel.Size = New-Object System.Drawing.Size(920, 60)
    $btnPanel.BackColor = $colors.PanelLight
    $tabBasicSoftware.Controls.Add($btnPanel)

    $btnInstall = Create-ModernButton -text "📦 Instalar Selección" -x 15 -y 10 -width 180 -action {
        $sel = $global:allCheckboxes | Where-Object { $_.cb.Checked }
        if ($sel.Count -eq 0) { 
            [System.Windows.Forms.MessageBox]::Show("Seleccione al menos un programa para instalar.", "Información", 0, 48)
            return 
        }
        
        $wg = Test-Winget
        $ch = Test-Chocolatey
        
        if (-not $wg -and -not $ch) { 
            $result = [System.Windows.Forms.MessageBox]::Show(
                "No se encontró Winget ni Chocolatey.`n`n¿Desea instalar Winget ahora?", 
                "Gestores no encontrados", 
                4, 32
            )
            if ($result -eq 6) { # Sí
                $prog = Show-ProgressDialog -title "Instalando Winget" -totalSteps 1
                $prog.Form.Show()
                [System.Windows.Forms.Application]::DoEvents()
                
                $installed = Install-Winget -progressDialog $prog
                $prog.Form.Close()
                
                if (-not $installed) {
                    $result2 = [System.Windows.Forms.MessageBox]::Show(
                        "Winget falló. ¿Instalar Chocolatey?", 
                        "Alternativa", 
                        4, 32
                    )
                    if ($result2 -eq 6) {
                        $prog = Show-ProgressDialog -title "Instalando Chocolatey" -totalSteps 1
                        $prog.Form.Show()
                        [System.Windows.Forms.Application]::DoEvents()
                        Install-Chocolatey -progressDialog $prog
                        $prog.Form.Close()
                    }
                }
            }
        }
        
        $script:InstallationCancelled = $false
        $progress = Show-ProgressDialog -title "Instalando Software" -totalSteps $sel.Count
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        $step = 0
        foreach ($s in $sel) { 
            if ($script:InstallationCancelled) { break }
            $step++
            Install-Software -id $s.id -name $s.n -progressDialog $progress -stepNumber $step -totalSteps $sel.Count
        }
        
        $progress.Form.Close()
        
        if (-not $script:InstallationCancelled) {
            [System.Windows.Forms.MessageBox]::Show("Instalación completada.", "Shadowiex", 0, 64)
            Update-GlobalStatus "Instalación completada" $colors.Success
        } else {
            Update-GlobalStatus "Instalación cancelada por el usuario" $colors.Warning
        }
    }
    $btnPanel.Controls.Add($btnInstall)
    
    $btnSelAll = Create-ModernButton -text "✓ Seleccionar Todo" -x 210 -y 10 -width 150 -backColor $colors.Panel -action {
        foreach($i in $global:allCheckboxes){ $i.cb.Checked = $true }
        Update-GlobalStatus "Todo seleccionado" $colors.Info
    }
    $btnPanel.Controls.Add($btnSelAll)
    
    $btnDesel = Create-ModernButton -text "✗ Deseleccionar" -x 375 -y 10 -width 150 -backColor $colors.Panel -action {
        foreach($i in $global:allCheckboxes){ $i.cb.Checked = $false }
        Update-GlobalStatus "Selección limpiada" $colors.Info
    }
    $btnPanel.Controls.Add($btnDesel)
    
    # Contador de seleccionados
    $lblCount = Create-ModernLabel -text "Seleccionados: 0" -x 540 -y 18 -width 150
    $lblCount.ForeColor = $colors.TextSub
    $btnPanel.Controls.Add($lblCount)
    
    # Actualizar contador cuando cambie la selección
    foreach ($item in $global:allCheckboxes) {
        $item.cb.Add_CheckedChanged({
            $count = ($global:allCheckboxes | Where-Object { $_.cb.Checked }).Count
            $lblCount.Text = "Seleccionados: $count"
        })
    }
}

function Populate-InstallersTab {
    $tabInstallers.Controls.Clear()
    
    $lblTitle = Create-ModernLabel -text "Gestor de Instaladores Personalizados" -x 15 -y 10 -isTitle $true
    $tabInstallers.Controls.Add($lblTitle)

    # Lista de instaladores
    $list = New-Object System.Windows.Forms.ListBox
    $list.Location = New-Object System.Drawing.Point(15, 50)
    $list.Size = New-Object System.Drawing.Size(650, 340)
    $list.BackColor = $colors.Panel
    $list.ForeColor = $colors.Text
    $list.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleRegular)
    $list.HorizontalScrollbar = $true
    $list.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $tabInstallers.Controls.Add($list)
    $script:UIControls['List'] = $list

    $refreshAction = {
        $l = $script:UIControls['List']
        if($l) { 
            $l.Items.Clear()
            $files = Initialize-Installers
            foreach($f in $files){ $l.Items.Add($f.Name) }
            Update-GlobalStatus "Lista actualizada: $($files.Count) instaladores" $colors.Info
        }
    }

    # Panel de botones
    $btnPanel = New-Object System.Windows.Forms.Panel
    $btnPanel.Location = New-Object System.Drawing.Point(680, 50)
    $btnPanel.Size = New-Object System.Drawing.Size(180, 350)
    $btnPanel.BackColor = $colors.PanelLight
    $tabInstallers.Controls.Add($btnPanel)

    $btnRefresh = Create-ModernButton -text "🔄 Actualizar Lista" -x 10 -y 15 -width 160 -action $refreshAction
    $btnPanel.Controls.Add($btnRefresh)

    $btnDl = Create-ModernButton -text "⬇️ Descargar GitHub" -x 10 -y 65 -width 160 -action {
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        Download-InstallersFromGitHub -dest $root
        Start-Sleep -Milliseconds 500
        & $refreshAction
    }
    $btnPanel.Controls.Add($btnDl)
    
    $btnInstall = Create-ModernButton -text "▶️ Instalar" -x 10 -y 115 -width 160 -backColor $colors.Success -action {
        $l = $script:UIControls['List']
        if($l.SelectedIndex -eq -1) { 
            [System.Windows.Forms.MessageBox]::Show("Seleccione un instalador de la lista.", "Información", 0, 48)
            return 
        }
        
        $itemName = $l.SelectedItem
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $file = Join-Path (Join-Path $root "instaladores") $itemName
        
        if (Test-Path $file) {
            $progress = Show-ProgressDialog -title "Instalando $itemName" -totalSteps 1
            $progress.Form.Show()
            [System.Windows.Forms.Application]::DoEvents()
            
            Update-ProgressDialog -dialog $progress -status "Ejecutando instalador..." -step 1 -percent 50
            
            try {
                Start-Process $file -ArgumentList "/S", "/quiet" -Wait -ErrorAction Stop
                Update-ProgressDialog -dialog $progress -status "Completado" -percent 100
                Start-Sleep -Milliseconds 500
                $progress.Form.Close()
                [System.Windows.Forms.MessageBox]::Show("Instalador ejecutado correctamente.", "Listo", 0, 64)
            } catch {
                $progress.Form.Close()
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", 0, 16)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Archivo no encontrado.", "Error", 0, 16)
        }
    }
    $btnPanel.Controls.Add($btnInstall)
    
    $btnInstallAll = Create-ModernButton -text "📦 Instalar Todo" -x 10 -y 165 -width 160 -backColor $colors.Warning -action {
        $l = $script:UIControls['List']
        if ($l.Items.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No hay instaladores en la lista.", "Información", 0, 48)
            return
        }
        
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $dir = Join-Path $root "instaladores"
        $files = Get-ChildItem $dir -Filter "*.exe"
        
        $progress = Show-ProgressDialog -title "Instalando Todos" -totalSteps $files.Count
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        $step = 0
        foreach ($f in $files) {
            $step++
            $filePath = Join-Path $dir $f.Name
            Download-And-Install -url $filePath -name $f.Name -dest $dir -progressDialog $progress -stepNumber $step -totalSteps $files.Count
        }
        
        $progress.Form.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación de todos los archivos completada.", "Listo", 0, 64)
    }
    $btnPanel.Controls.Add($btnInstallAll)
    
    # Cargar lista inicial
    & $refreshAction
}

function Populate-ActivationsTab {
    $tabActivations.Controls.Clear()
    
    # Sección de Activación MAS
    $lblMas = Create-ModernLabel -text "Microsoft Activation Scripts (MAS)" -x 20 -y 15 -isTitle $true
    $lblMas.ForeColor = $colors.Accent
    $tabActivations.Controls.Add($lblMas)
    
    $lblMasDesc = Create-ModernLabel -text "Activación completa de Windows y Office con múltiples métodos" -x 20 -y 50 -width 600
    $lblMasDesc.ForeColor = $colors.TextSub
    $tabActivations.Controls.Add($lblMasDesc)
    
    $btnOpenMAS = Create-ModernButton -text "🖥️ Abrir MAS (Interactivo)" -x 20 -y 80 -width 200 -backColor $colors.Success -action {
        Open-MASActivation
    }
    $tabActivations.Controls.Add($btnOpenMAS)
    
    $btnTSforgeWin = Create-ModernButton -text "🔑 Activar Windows (TSforge)" -x 235 -y 80 -width 200 -action {
        Activate-WindowsTSforge -windows $true -office $false
    }
    $tabActivations.Controls.Add($btnTSforgeWin)
    
    $btnTSforgeAll = Create-ModernButton -text "🔑 Activar Windows + Office" -x 450 -y 80 -width 200 -backColor $colors.Info -action {
        Activate-WindowsTSforge -windows $true -office $true
    }
    $tabActivations.Controls.Add($btnTSforgeAll)
    
    # Sección de Otros Activadores
    $lblOther = Create-ModernLabel -text "Otros Métodos de Activación" -x 20 -y 140 -isTitle $true
    $lblOther.ForeColor = $colors.Accent
    $tabActivations.Controls.Add($lblOther)
    
    $btnMassgrave = Create-ModernButton -text "⚡ Activated.Win" -x 20 -y 175 -width 200 -backColor $colors.Danger -action {
        Activate-WithMassgrave
    }
    $tabActivations.Controls.Add($btnMassgrave)
    
    $btnWinUtil = Create-ModernButton -text "🛠️ WinUtil (Chris Titus)" -x 235 -y 175 -width 200 -action {
        Activate-WithWinUtil
    }
    $tabActivations.Controls.Add($btnWinUtil)
    
    # Separador
    $sepLine = New-Object System.Windows.Forms.Panel
    $sepLine.Location = New-Object System.Drawing.Point(20, 235)
    $sepLine.Size = New-Object System.Drawing.Size(700, 2)
    $sepLine.BackColor = $colors.PanelLight
    $tabActivations.Controls.Add($sepLine)
    
    # Sección de Optimización
    $lblOpt = Create-ModernLabel -text "Optimización del Sistema" -x 20 -y 260 -isTitle $true
    $lblOpt.ForeColor = $colors.Accent
    $tabActivations.Controls.Add($lblOpt)
    
    $btnNet = Create-ModernButton -text "🌐 Optimizar Red" -x 20 -y 295 -width 170 -action {
        $progress = Show-ProgressDialog -title "Optimizando Red" -totalSteps 4
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        Update-ProgressDialog -dialog $progress -status "Reseteando IP..." -step 1 -percent 25
        netsh int ip reset | Out-Null
        
        Update-ProgressDialog -dialog $progress -status "Reseteando Winsock..." -step 2 -percent 50
        netsh winsock reset | Out-Null
        
        Update-ProgressDialog -dialog $progress -status "Limpiando DNS..." -step 3 -percent 75
        ipconfig /flushdns | Out-Null
        
        Update-ProgressDialog -dialog $progress -status "Completado" -step 4 -percent 100
        Start-Sleep -Milliseconds 500
        $progress.Form.Close()
        
        [System.Windows.Forms.MessageBox]::Show("Red optimizada correctamente.`nSe recomienda reiniciar el equipo.", "Listo", 0, 64)
        Update-GlobalStatus "Red optimizada" $colors.Success
    }
    $tabActivations.Controls.Add($btnNet)
    
    $btnSys = Create-ModernButton -text "⚙️ Optimizar Servicios" -x 200 -y 295 -width 170 -action {
        $progress = Show-ProgressDialog -title "Optimizando Servicios" -totalSteps 1
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        Update-ProgressDialog -dialog $progress -status "Deshabilitando servicios innecesarios..." -step 1 -percent 50
        
        $srv = @("DiagTrack", "dmwappushservice", "MapsBroker", "SharedAccess")
        $disabled = 0
        foreach($s in $srv) {
            try {
                Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue
                Stop-Service $s -Force -ErrorAction SilentlyContinue
                $disabled++
            } catch {}
        }
        
        Update-ProgressDialog -dialog $progress -status "Completado" -percent 100
        Start-Sleep -Milliseconds 500
        $progress.Form.Close()
        
        [System.Windows.Forms.MessageBox]::Show("$disabled servicios optimizados.", "Listo", 0, 64)
        Update-GlobalStatus "Servicios optimizados" $colors.Success
    }
    $tabActivations.Controls.Add($btnSys)
    
    $btnClean = Create-ModernButton -text "🗑️ Limpiar Temporales" -x 380 -y 295 -width 170 -backColor $colors.Warning -action {
        $progress = Show-ProgressDialog -title "Limpiando Temporales" -totalSteps 2
        $progress.Form.Show()
        [System.Windows.Forms.Application]::DoEvents()
        
        Update-ProgressDialog -dialog $progress -status "Limpiando carpeta TEMP del usuario..." -step 1 -percent 25
        $removed1 = 0
        try {
            Get-ChildItem "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $removed1 = 1
        } catch {}
        
        Update-ProgressDialog -dialog $progress -status "Limpiando carpeta TEMP de Windows..." -step 2 -percent 75
        $removed2 = 0
        try {
            Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $removed2 = 1
        } catch {}
        
        Update-ProgressDialog -dialog $progress -status "Completado" -percent 100
        Start-Sleep -Milliseconds 500
        $progress.Form.Close()
        
        [System.Windows.Forms.MessageBox]::Show("Archivos temporales limpiados.", "Listo", 0, 64)
        Update-GlobalStatus "Temporales limpiados" $colors.Success
    }
    $tabActivations.Controls.Add($btnClean)
    
    $btnDisk = Create-ModernButton -text "💿 Limpiar Disco" -x 560 -y 295 -width 170 -action {
        Start-Process "cleanmgr.exe" -ArgumentList "/d C" -Wait
        Update-GlobalStatus "Limpieza de disco completada" $colors.Success
    }
    $tabActivations.Controls.Add($btnDisk)
    
    # Sección de Windows Defender
    $lblDef = Create-ModernLabel -text "Windows Defender" -x 20 -y 360 -isTitle $true
    $lblDef.ForeColor = $colors.Accent
    $tabActivations.Controls.Add($lblDef)
    
    $btnDefEnable = Create-ModernButton -text "🛡️ Activar Defender" -x 20 -y 395 -width 170 -backColor $colors.Success -action {
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
            [System.Windows.Forms.MessageBox]::Show("Windows Defender activado.", "Listo", 0, 64)
            Update-GlobalStatus "Defender activado" $colors.Success
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)`n`nEs posible que necesite permisos de administrador.", "Error", 0, 16)
        }
    }
    $tabActivations.Controls.Add($btnDefEnable)
    
    $btnDefDisable = Create-ModernButton -text "⚠️ Desactivar Defender" -x 200 -y 395 -width 170 -backColor $colors.Danger -action {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "¿Está seguro de que desea desactivar Windows Defender?`n`nEsto dejará su equipo vulnerable.", 
            "Confirmar", 
            4, 48
        )
        if ($result -eq 6) { # Sí
            try {
                Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
                [System.Windows.Forms.MessageBox]::Show("Windows Defender desactivado temporalmente.`n`nNota: Puede reactivarse automáticamente.", "Listo", 0, 64)
                Update-GlobalStatus "Defender desactivado" $colors.Warning
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)`n`nEs posible que necesite usar una herramienta externa como Defender Control.", "Error", 0, 16)
            }
        }
    }
    $tabActivations.Controls.Add($btnDefDisable)
    
    $btnDefControl = Create-ModernButton -text "🔧 Defender Control" -x 380 -y 395 -width 170 -action {
        try {
            # Descargar Defender Control si no existe
            $dcPath = "$env:TEMP\DefenderControl.exe"
            if (-not (Test-Path $dcPath)) {
                $dcUrl = "https://www.sordum.org/files/download/d-control/DefenderControl.zip"
                $zipPath = "$env:TEMP\DefenderControl.zip"
                Invoke-WebRequest -Uri $dcUrl -OutFile $zipPath -UseBasicParsing
                Expand-Archive $zipPath "$env:TEMP\DefenderControl" -Force
                $dcPath = Get-ChildItem "$env:TEMP\DefenderControl" -Recurse -Filter "*.exe" | Select-Object -First 1 -ExpandProperty FullName
            }
            if (Test-Path $dcPath) {
                Start-Process $dcPath
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error descargando Defender Control.", "Error", 0, 16)
        }
    }
    $tabActivations.Controls.Add($btnDefControl)
}

function Populate-SettingsTab {
    $tabSettings.Controls.Clear()
    
    $lbl = Create-ModernLabel -text "Configuración del Sistema" -x 20 -y 15 -isTitle $true
    $tabSettings.Controls.Add($lbl)
    
    # Estado de gestores
    $sw = Test-Winget
    $sc = Test-Chocolatey
    $statusW = if($sw){"✓ Instalado"}else{"✗ No encontrado"}
    $statusC = if($sc){"✓ Instalado"}else{"✗ No encontrado"}
    $colorW = if($sw){$colors.Success}else{$colors.Danger}
    $colorC = if($sc){$colors.Success}else{$colors.Danger}
    
    $tabSettings.Controls.Add((Create-ModernLabel -text "Winget:" -x 20 -y 60 -width 100))
    $lblW = Create-ModernLabel -text $statusW -x 130 -y 60 -foreColor $colorW
    $tabSettings.Controls.Add($lblW)
    
    $tabSettings.Controls.Add((Create-ModernLabel -text "Chocolatey:" -x 20 -y 90 -width 100))
    $lblC = Create-ModernLabel -text $statusC -x 130 -y 90 -foreColor $colorC
    $tabSettings.Controls.Add($lblC)
    
    # Botones de instalación de gestores
    if (-not $sw) {
        $btnInstW = Create-ModernButton -text "📥 Instalar Winget" -x 300 -y 55 -width 160 -action {
            $progress = Show-ProgressDialog -title "Instalando Winget" -totalSteps 1
            $progress.Form.Show()
            [System.Windows.Forms.Application]::DoEvents()
            
            $result = Install-Winget -progressDialog $progress
            $progress.Form.Close()
            
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Winget instalado correctamente.", "Éxito", 0, 64)
                Populate-SettingsTab
            } else {
                [System.Windows.Forms.MessageBox]::Show("Error instalando Winget.", "Error", 0, 16)
            }
        }
        $tabSettings.Controls.Add($btnInstW)
    }
    
    if (-not $sc) {
        $btnInstC = Create-ModernButton -text "📥 Instalar Chocolatey" -x 300 -y 85 -width 160 -action {
            $progress = Show-ProgressDialog -title "Instalando Chocolatey" -totalSteps 1
            $progress.Form.Show()
            [System.Windows.Forms.Application]::DoEvents()
            
            $result = Install-Chocolatey -progressDialog $progress
            $progress.Form.Close()
            
            if ($result) {
                [System.Windows.Forms.MessageBox]::Show("Chocolatey instalado correctamente.", "Éxito", 0, 64)
                Populate-SettingsTab
            } else {
                [System.Windows.Forms.MessageBox]::Show("Error instalando Chocolatey.", "Error", 0, 16)
            }
        }
        $tabSettings.Controls.Add($btnInstC)
    }
    
    # Separador
    $sepLine = New-Object System.Windows.Forms.Panel
    $sepLine.Location = New-Object System.Drawing.Point(20, 130)
    $sepLine.Size = New-Object System.Drawing.Size(700, 2)
    $sepLine.BackColor = $colors.PanelLight
    $tabSettings.Controls.Add($sepLine)
    
    # Actualización del script
    $lblUpdate = Create-ModernLabel -text "Actualización del Script" -x 20 -y 150 -isTitle $true
    $tabSettings.Controls.Add($lblUpdate)
    
    $btnUp = Create-ModernButton -text "🔄 Actualizar Script" -x 20 -y 190 -width 200 -action {
        try {
            $progress = Show-ProgressDialog -title "Actualizando Script" -totalSteps 2
            $progress.Form.Show()
            [System.Windows.Forms.Application]::DoEvents()
            
            Update-ProgressDialog -dialog $progress -status "Descargando última versión..." -step 1 -percent 30
            
            $u = "https://github.com/WalterShadow2001/shadowiex/raw/main/Shadowiex.ps1"
            $t = "$env:TEMP\Shadowiex.ps1"
            Invoke-WebRequest -Uri $u -OutFile $t -UseBasicParsing
            
            Update-ProgressDialog -dialog $progress -status "Instalando..." -step 2 -percent 70
            Copy-Item $t $PSCommandPath -Force
            
            Update-ProgressDialog -dialog $progress -status "Completado" -percent 100
            Start-Sleep -Milliseconds 500
            $progress.Form.Close()
            
            [System.Windows.Forms.MessageBox]::Show("Script actualizado correctamente.`nLa aplicación se cerrará.", "Info", 0, 64)
            $form.Close()
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error actualizando: $($_.Exception.Message)", "Error", 0, 16)
        }
    }
    $tabSettings.Controls.Add($btnUp)
    
    # Información del sistema
    $lblSys = Create-ModernLabel -text "Información del Sistema" -x 20 -y 250 -isTitle $true
    $tabSettings.Controls.Add($lblSys)
    
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $tabSettings.Controls.Add((Create-ModernLabel -text "Sistema: $($osInfo.Caption)" -x 20 -y 285 -width 400))
    $tabSettings.Controls.Add((Create-ModernLabel -text "Versión: $($osInfo.Version)" -x 20 -y 310 -width 400))
    $tabSettings.Controls.Add((Create-ModernLabel -text "Arquitectura: $env:PROCESSOR_ARCHITECTURE" -x 20 -y 335 -width 400))
    
    # Créditos
    $lblCredits = Create-ModernLabel -text "Shadowiex Professional v7.0" -x 20 -y 400 -isTitle $true
    $lblCredits.ForeColor = $colors.Accent
    $tabSettings.Controls.Add($lblCredits)
    
    $lblAuthor = Create-ModernLabel -text "Creado por WDPN (WalterShadow2001)" -x 20 -y 435 -width 300
    $lblAuthor.ForeColor = $colors.TextSub
    $tabSettings.Controls.Add($lblAuthor)
    
    $lblGitHub = Create-ModernLabel -text "GitHub: github.com/WalterShadow2001/shadowiex" -x 20 -y 460 -width 350
    $lblGitHub.ForeColor = $colors.Info
    $tabSettings.Controls.Add($lblGitHub)
}

# --- INICIALIZACIÓN ---
Populate-SoftwareTab
Populate-InstallersTab
Populate-ActivationsTab
Populate-SettingsTab

Update-GlobalStatus "Shadowiex Professional v7.0 - Listo" $colors.Success

[void]$form.ShowDialog()
