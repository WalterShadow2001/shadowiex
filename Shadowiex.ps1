<#
.SYNOPSIS
    Shadowiex - Herramienta de Configuración y Optimización del Sistema
.DESCRIPTION
    Una herramienta completa para instalar software, optimizar el sistema y gestionar activaciones de Windows y Office con interfaz profesional.
.NOTES
    Autor: WalterShadow2001
    Versión: 3.7 - Professional Edition (Corregido: Nombres y Rutas)
    Requiere: PowerShell 5.1 o superior, privilegios de administrador
#>

# Configuración inicial
 $ErrorActionPreference = "Stop"
 $ProgressPreference = 'SilentlyContinue'

# Variable global para controles de UI (Soluciona el error de Null Reference)
 $script:UIControls = @{}

# Verificar si se ejecuta como administrador
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Cargar ensamblados necesarios
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation
Add-Type -AssemblyName PresentationFramework

# Variables globales
 $global:InstallProgress = @{}
 $global:TotalSoftware = 0
 $global:InstalledSoftware = 0

# Clase para manejar el estado de instalación
class InstallationState {
    [string]$Name
    [string]$Status
    [int]$Progress
    [bool]$IsComplete
    
    InstallationState([string]$name) {
        $this.Name = $name
        $this.Status = "Pending"
        $this.Progress = 0
        $this.IsComplete = $false
    }
}

# Crear formulario principal con tema profesional
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "Shadowiex - Professional Edition"
 $form.Size = New-Object System.Drawing.Size(900, 600)
 $form.StartPosition = "CenterScreen"
 $form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
 $form.ForeColor = [System.Drawing.Color]::White

# --- CORRECCIÓN DE ICONOS Y LOGOS ---
try {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    
    # 1. Cargar Icono de la ventana (.ico)
    $iconPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.ico"
    if (Test-Path -Path $iconPath) {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    }

    # 2. Cargar Logo en PictureBox (.png)
    $logoPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.png"
    
    if (Test-Path -Path $logoPath) {
        $logoImage = [System.Drawing.Image]::FromFile($logoPath)
        $pictureBox = New-Object System.Windows.Forms.PictureBox
        $pictureBox.Image = $logoImage
        $pictureBox.Size = New-Object System.Drawing.Size(32, 32)
        $pictureBox.Location = New-Object System.Drawing.Point(10, 10)
        $form.Controls.Add($pictureBox)
    } else {
        Write-Host "Logo SHADOWIEX_LOGO.png no encontrado. Usando icono predeterminado."
        $icon = [System.Drawing.SystemIcons]::Application
        $pictureBox = New-Object System.Windows.Forms.PictureBox
        $pictureBox.Image = $icon.ToBitmap()
        $pictureBox.Size = New-Object System.Drawing.Size(32, 32)
        $pictureBox.Location = New-Object System.Drawing.Point(10, 10)
        $form.Controls.Add($pictureBox)
    }
}
catch {
    Write-Host "Error al cargar logo/icono: $($_.Exception.Message)"
}

# Añadir texto "CREADO POR WDPN"
 $createdByLabel = New-Object System.Windows.Forms.Label
 $createdByLabel.Text = "CREADO POR WDPN"
 $createdByLabel.Location = New-Object System.Drawing.Point(820, 560)
 $createdByLabel.Size = New-Object System.Drawing.Size(70, 20)
 $createdByLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
 $createdByLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
 $form.Controls.Add($createdByLabel)

# Crear control de pestañas
 $tabControl = New-Object System.Windows.Forms.TabControl
 $tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
 $tabControl.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons

 $tabBasicSoftware = New-Object System.Windows.Forms.TabPage
 $tabBasicSoftware.Text = "Software Básico"
 $tabBasicSoftware.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabBasicSoftware.ForeColor = [System.Drawing.Color]::White

 $tabInstallers = New-Object System.Windows.Forms.TabPage
 $tabInstallers.Text = "Instaladores Personalizados"
 $tabInstallers.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabInstallers.ForeColor = [System.Drawing.Color]::White

 $tabActivations = New-Object System.Windows.Forms.TabPage
 $tabActivations.Text = "Activaciones & Optimización"
 $tabActivations.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabActivations.ForeColor = [System.Drawing.Color]::White

 $tabSettings = New-Object System.Windows.Forms.TabPage
 $tabSettings.Text = "Configuración"
 $tabSettings.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabSettings.ForeColor = [System.Drawing.Color]::White

 $tabControl.Controls.Add($tabBasicSoftware)
 $tabControl.Controls.Add($tabInstallers)
 $tabControl.Controls.Add($tabActivations)
 $tabControl.Controls.Add($tabSettings)
 $form.Controls.Add($tabControl)

# Función para crear botones
function Create-ProfessionalButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 150,
        [int]$height = 30,
        [scriptblock]$action,
        [System.Drawing.Color]$backColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Text = $text
    $button.BackColor = $backColor
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $button.FlatAppearance.BorderSize = 0
    $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 100, 180)
    $button.Add_Click($action)
    
    return $button
}

function Create-ProfessionalLabel {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 250,
        [int]$height = 20,
        [System.Drawing.Font]$font = $null
    )
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($width, $height)
    $label.ForeColor = [System.Drawing.Color]::White
    if ($font) {
        $label.Font = $font
    } else {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    }
    return $label
}

# Funciones de utilidad (Winget/Choco)
function Test-Winget {
    try { $null = winget --version; return $true } catch { return $false }
}
function Test-Chocolatey {
    try { $null = choco --version; return $true } catch { return $false }
}

function Install-Winget {
    Write-Host "Instalando winget..."
    try {
        $latestWingetMsixBundleUri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $latestWingetMsixBundle = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundle -ErrorAction Stop
        Add-AppxPackage -Path $latestWingetMsixBundle -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "Error al instalar Winget: $($_.Exception.Message)"
        return $false
    }
}

function Install-Chocolatey {
    Write-Host "Instalando Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        return $true
    }
    catch {
        Write-Host "Error al instalar Chocolatey: $($_.Exception.Message)"
        return $false
    }
}

function Install-Software {
    param ([string]$id, [string]$name, [System.Windows.Forms.ProgressBar]$progressBar, [System.Windows.Forms.Label]$statusLabel)
    
    if (-not $progressBar -or -not $statusLabel) { return $false }
    
    $statusLabel.Text = "Instalando $name..."
    $progressBar.Value = 0
    
    if (Test-Winget) {
        try {
            $process = Start-Process -FilePath "winget" -ArgumentList "install", "--id", $id, "--accept-source-agreements", "--accept-package-agreements", "-h" -NoNewWindow -PassThru -Wait
            $progressBar.Value = 50
            if ($process.ExitCode -eq 0) {
                $statusLabel.Text = "$name instalado correctamente."
                $progressBar.Value = 100
                return $true
            }
        }
        catch { $statusLabel.Text = "Error con Winget. Intentando Chocolatey..." }
    }
    
    if (Test-Chocolatey) {
        try {
            $chocoId = $id.Split('.')[-1].ToLower()
            $process = Start-Process -FilePath "choco" -ArgumentList "install", $chocoId, "-y" -NoNewWindow -PassThru -Wait
            $progressBar.Value = 50
            if ($process.ExitCode -eq 0) {
                $statusLabel.Text = "$name instalado correctamente."
                $progressBar.Value = 100
                return $true
            }
        }
        catch { $statusLabel.Text = "Error al instalar $name" }
    }
    return $false
}

function Download-And-Install {
    param ([string]$url, [string]$fileName, [string]$downloadPath, [System.Windows.Forms.ProgressBar]$progressBar, [System.Windows.Forms.Label]$statusLabel)
    
    if (-not $progressBar -or -not $statusLabel) { return $false }
    
    $filePath = Join-Path -Path $downloadPath -ChildPath $fileName
    try {
        $statusLabel.Text = "Descargando/Instalando $fileName..."
        $progressBar.Value = 0
        
        # Si la URL es una ruta local (archivo ya existe), no descargar
        if ($url -match "^[\w]:\\.+") {
            Copy-Item -Path $url -Destination $filePath -Force
        } else {
            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
        }
        
        $progressBar.Value = 50
        $process = Start-Process -FilePath $filePath -ArgumentList "/S", "/quiet", "/norestart" -PassThru
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            $statusLabel.Text = "$name instalado correctamente."
            $progressBar.Value = 100
            return $true
        } else {
            if ($process.ExitCode -eq 1641 -or $process.ExitCode -eq 3010) { return $true }
            return $false
        }
    }
    catch { return $false }
}

# Funciones de Optimización y Activación
function Create-RestorePoint {
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
        Checkpoint-Computer -Description "Punto de Restauración de Shadowiex" -RestorePointType "APPLICATION_INSTALL" -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Punto de restauración creado.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
}

function Optimize-System {
    try {
        $servicesToDisable = @("DiagTrack", "dmwappushservice", "MapsBroker", "lfsvc", "SharedAccess", "lltdsvc", "RemoteRegistry", "RetailDemo")
        foreach ($service in $servicesToDisable) {
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        }
        Start-Process -FilePath "$env:SystemRoot\System32\powercfg.exe" -ArgumentList "/h", "off" -Wait -NoWindow -ErrorAction Stop
        Start-Process -FilePath "$env:SystemRoot\System32\powercfg.exe" -ArgumentList "/setactive", "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -Wait -NoWindow -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Sistema optimizado.", "Optimización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
}

function Clean-TempFiles {
    try {
        Get-ChildItem -Path "$env:windir\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:TEMP" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:windir\Prefetch" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show("Archivos temporales limpiados.", "Limpieza", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
}

function Activate-WindowsAndOffice {
    try {
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $tsforgeScript = Join-Path -Path $scriptRoot -ChildPath "TSforge_Activation.cmd"
        
        if (-not (Test-Path -Path $tsforgeScript)) {
            # CORREGIDO: URL del repo shadowiex
            $tsforgeUrl = "https://github.com/WalterShadow2001/shadowiex/raw/main/TSforge_Activation.cmd"
            Invoke-WebRequest -Uri $tsforgeUrl -OutFile $tsforgeScript -ErrorAction Stop
        }
        
        $tempBatchFile = Join-Path -Path $env:TEMP -ChildPath "activate_temp.cmd"
        "@echo off`nset _actwin=1`nset _actoff=1`ncall `"$tsforgeScript`"" | Out-File -FilePath $tempBatchFile -Encoding ASCII
        
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$tempBatchFile" -Wait -NoNewWindow
        Remove-Item -Path $tempBatchFile -Force
        [System.Windows.Forms.MessageBox]::Show("Activación completada.", "Activación", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
}

# Gestión de Instaladores
function Initialize-Installers {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $instaladoresPath = Join-Path -Path $scriptRoot -ChildPath "instaladores"
    
    if (-not (Test-Path -Path $instaladoresPath)) {
        New-Item -ItemType Directory -Path $instaladoresPath -Force | Out-Null
    }
    
    if (Test-Path -Path $instaladoresPath) {
        return Get-ChildItem -Path $instaladoresPath -Filter "*.exe" -ErrorAction SilentlyContinue
    }
    return @()
}

function Download-InstallersFromGitHub {
    param ([string]$destinationPath)
    
    try {
        if (-not (Test-Path -Path $destinationPath)) { New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null }
        
        # CORREGIDO: URL actualizada al nombre real del repositorio 'shadowiex'
        $repoUrl = "https://github.com/WalterShadow2001/shadowiex/archive/refs/heads/main.zip"
        $tempZip = Join-Path -Path $env:TEMP -ChildPath "shadowiex-instaladores.zip"
        $extractPath = Join-Path -Path $env:TEMP -ChildPath "shadowiex-extract"
        
        Invoke-WebRequest -Uri $repoUrl -OutFile $tempZip -ErrorAction Stop
        
        if (Test-Path -Path $extractPath) { Remove-Item -Path $extractPath -Recurse -Force }
        Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
        
        # CORREGIDO: Ruta dentro del zip extraído
        $sourceDir = Join-Path -Path $extractPath -ChildPath "shadowiex-main\instaladores"
        if (Test-Path -Path $sourceDir) {
            $instaladores = Get-ChildItem -Path $sourceDir -Filter "*.exe" -ErrorAction SilentlyContinue
            foreach ($instalador in $instaladores) {
                Copy-Item -Path $instalador.FullName -Destination $destinationPath -Force
            }
        }
        
        Remove-Item -Path $tempZip -Force
        Remove-Item -Path $extractPath -Recurse -Force
        [System.Windows.Forms.MessageBox]::Show("Descarga de instaladores completada.", "Descarga", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
}

# Datos de Software
 $softwareCategories = @{
    "Navegadores" = @(
        @{id = "Google.Chrome"; name = "Google Chrome"; icon = "🌐"},
        @{id = "Mozilla.Firefox"; name = "Mozilla Firefox"; icon = "🦊"},
        @{id = "Opera.Opera"; name = "Opera"; icon = "🎭"},
        @{id = "Microsoft.Edge"; name = "Microsoft Edge"; icon = "🔵"},
        @{id = "BraveSoftware.BraveBrowser"; name = "Navegador Brave"; icon = "🦁"}
    )
    "Desarrollo" = @(
        @{id = "Git.Git"; name = "Git"; icon = "📁"},
        @{id = "GitHub.GitHubDesktop"; name = "GitHub Desktop"; icon = "🐙"},
        @{id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code"; icon = "🔧"},
        @{id = "Notepad++.Notepad++"; name = "Notepad++"; icon = "📝"}
    )
    "Multimedia" = @(
        @{id = "VideoLAN.VLC"; name = "VLC Media Player"; icon = "🎵"},
        @{id = "GIMP.GIMP"; name = "GIMP"; icon = "🎨"},
        @{id = "IrfanSkiljan.IrfanView"; name = "IrfanView"; icon = "🖼️"}
    )
    "Comunicación" = @(
        @{id = "Zoom.Zoom"; name = "Zoom"; icon = "📞"},
        @{id = "Microsoft.Teams"; name = "Microsoft Teams"; icon = "👥"},
        @{id = "Discord.Discord"; name = "Discord"; icon = "💬"},
        @{id = "Telegram.TelegramDesktop"; name = "Telegram"; icon = "📱"},
        @{id = "WhatsApp.WhatsApp"; name = "WhatsApp Desktop"; icon = "💬"},
        @{id = "Slack.Slack"; name = "Slack"; icon = "📋"}
    )
    "Utilidades" = @(
        @{id = "7zip.7zip"; name = "7-Zip"; icon = "🗜️"},
        @{id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Reader"; icon = "📄"},
        @{id = "RARLab.WinRAR"; name = "WinRAR"; icon = "🗜️"},
        @{id = "TeamViewer.TeamViewer"; name = "TeamViewer"; icon = "👥"},
        @{id = "Rufus.Rufus"; name = "Rufus"; icon = "🔧"}
    )
    "Runtimes" = @(
        @{id = "Oracle.JavaRuntimeEnvironment"; name = "Java Runtime Environment"; icon = "☕"},
        @{id = "Microsoft.DotNet.Runtime.6"; name = ".NET Runtime 6"; icon = "🟢"},
        @{id = "Microsoft.DotNet.Runtime.7"; name = ".NET Runtime 7"; icon = "🟢"},
        @{id = "Microsoft.DotNet.Framework"; name = ".NET Framework"; icon = "🟢"}
    )
}

# --- POBLAR PESTAÑAS ---

function Populate-SoftwareTab {
    $tabBasicSoftware.Controls.Clear()
    $titleLabel = Create-ProfessionalLabel -text "Seleccione el software a instalar:" -x 15 -y 10 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabBasicSoftware.Controls.Add($titleLabel)
    
    $scrollPanel = New-Object System.Windows.Forms.Panel
    $scrollPanel.AutoScroll = $true
    $scrollPanel.Location = New-Object System.Drawing.Point(15, 40)
    $scrollPanel.Size = New-Object System.Drawing.Size(860, 380)
    $scrollPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
    $tabBasicSoftware.Controls.Add($scrollPanel)
    
    $global:allCheckboxes = @()
    $yPos = 10
    
    # Fuente corregida para iconos: Segoe UI Symbol soporta mejor los emojis
    $emojiFont = New-Object System.Drawing.Font("Segoe UI Symbol", 9, [System.Drawing.FontStyle]::Regular)
    
    foreach ($category in $softwareCategories.Keys) {
        $categoryLabel = Create-ProfessionalLabel -text $category -x 10 -y $yPos -font (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold))
        $scrollPanel.Controls.Add($categoryLabel)
        $yPos += 25
        
        foreach ($software in $softwareCategories[$category]) {
            $checkbox = New-Object System.Windows.Forms.CheckBox
            $checkbox.Text = "$($software.icon) $($software.name)"
            $checkbox.Location = New-Object System.Drawing.Point(25, $yPos)
            $checkbox.Size = New-Object System.Drawing.Size(820, 20)
            $checkbox.Tag = $software.id
            $checkbox.ForeColor = [System.Drawing.Color]::White
            $checkbox.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
            $checkbox.Font = $emojiFont
            $scrollPanel.Controls.Add($checkbox)
            $global:allCheckboxes += @{checkbox = $checkbox; id = $software.id; name = $software.name}
            $yPos += 25
        }
        $yPos += 10
    }
    
    $installButton = Create-ProfessionalButton -text "Instalar Software Seleccionado" -x 15 -y 430 -width 180 -action {
        $selectedSoftware = $global:allCheckboxes | Where-Object { $_.checkbox.Checked }
        if ($selectedSoftware.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Seleccione al menos un software.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        if (-not (Test-Winget)) { if (-not (Install-Winget)) { if (-not (Install-Chocolatey)) { return } } }
        
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Instalando Software"
        $progressForm.Size = New-Object System.Drawing.Size(450, 150)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
        $progressForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $progressLabel = Create-ProfessionalLabel -text "Instalando software..." -x 15 -y 15 -width 420
        $progressForm.Controls.Add($progressLabel)
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(15, 40)
        $progressBar.Size = New-Object System.Drawing.Size(420, 20)
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $progressForm.Controls.Add($progressBar)
        $statusLabel = Create-ProfessionalLabel -text "" -x 15 -y 70 -width 420
        $progressForm.Controls.Add($statusLabel)
        $progressForm.Show()
        
        $global:TotalSoftware = $selectedSoftware.Count
        $global:InstalledSoftware = 0
        foreach ($software in $selectedSoftware) {
            Install-Software -id $software.id -name $software.name -progressBar $progressBar -statusLabel $statusLabel
            $global:InstalledSoftware++
        }
        $progressForm.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación completada: $global:InstalledSoftware de $global:TotalSoftware", "Completado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $tabBasicSoftware.Controls.Add($installButton)
    
    $selectAllButton = Create-ProfessionalButton -text "Seleccionar Todo" -x 205 -y 430 -width 120 -height 30 -action {
        foreach ($item in $global:allCheckboxes) { $item.checkbox.Checked = $true }
    }
    $tabBasicSoftware.Controls.Add($selectAllButton)
    
    $deselectAllButton = Create-ProfessionalButton -text "Deseleccionar Todo" -x 335 -y 430 -width 120 -height 30 -action {
        foreach ($item in $global:allCheckboxes) { $item.checkbox.Checked = $false }
    }
    $tabBasicSoftware.Controls.Add($deselectAllButton)
}

function Populate-InstallersTab {
    $tabInstallers.Controls.Clear()
    
    $titleLabel = Create-ProfessionalLabel -text "Gestor de Instaladores Personalizados" -x 15 -y 10 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabInstallers.Controls.Add($titleLabel)
    
    # Crear lista y guardarla en variable global de UI
    $installersList = New-Object System.Windows.Forms.ListBox
    $installersList.Location = New-Object System.Drawing.Point(15, 40)
    $installersList.Size = New-Object System.Drawing.Size(860, 150)
    $installersList.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
    $installersList.ForeColor = [System.Drawing.Color]::White
    $installersList.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiExtended
    $tabInstallers.Controls.Add($installersList)
    $script:UIControls['InstallersList'] = $installersList
    
    $refreshButton = Create-ProfessionalButton -text "Actualizar Lista" -x 15 -y 200 -width 120 -height 30 -action {
        $listBox = $script:UIControls['InstallersList']
        if ($null -eq $listBox) { return }
        
        $installers = Initialize-Installers
        $listBox.Items.Clear()
        
        if ($installers -and $installers.Count -gt 0) {
            foreach ($instalador in $installers) {
                if ($instalador -and $instalador.Name) {
                    $listBox.Items.Add($instalador.Name)
                }
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("No se encontraron instaladores en la carpeta local.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    }
    $tabInstallers.Controls.Add($refreshButton)
    
    $downloadFolderLabel = Create-ProfessionalLabel -text "Carpeta de Descarga:" -x 145 -y 200
    $tabInstallers.Controls.Add($downloadFolderLabel)
    
    $downloadFolderTextBox = New-Object System.Windows.Forms.TextBox
    $downloadFolderTextBox.Location = New-Object System.Drawing.Point(265, 200)
    $downloadFolderTextBox.Size = New-Object System.Drawing.Size(240, 23)
    $downloadFolderTextBox.Text = [Environment]::GetFolderPath("Desktop")
    $downloadFolderTextBox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
    $downloadFolderTextBox.ForeColor = [System.Drawing.Color]::White
    $tabInstallers.Controls.Add($downloadFolderTextBox)
    
    $selectFolderButton = Create-ProfessionalButton -text "Examinar..." -x 515 -y 200 -width 80 -height 23 -action {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Seleccionar carpeta de descarga"
        $folderBrowser.SelectedPath = $downloadFolderTextBox.Text
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $downloadFolderTextBox.Text = $folderBrowser.SelectedPath
        }
    }
    $tabInstallers.Controls.Add($selectFolderButton)
    
    $installButton = Create-ProfessionalButton -text "Instalar Seleccionados" -x 155 -y 240 -width 180 -height 35 -action {
        $listBox = $script:UIControls['InstallersList']
        if ($null -eq $listBox) { return }
        
        $selectedIndices = $listBox.SelectedIndices
        if ($selectedIndices.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Seleccione al menos un instalador.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        $downloadPath = $downloadFolderTextBox.Text
        if (-not (Test-Path $downloadPath)) {
            [System.Windows.Forms.MessageBox]::Show("La carpeta de destino no existe.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        $installers = Initialize-Installers
        if (-not $installers -or $installers.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No se encontraron instaladores.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Instalando Programas"
        $progressForm.Size = New-Object System.Drawing.Size(450, 130)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
        $progressForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $progressLabel = Create-ProfessionalLabel -text "Instalando programas..." -x 15 -y 15 -width 420
        $progressForm.Controls.Add($progressLabel)
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(15, 40)
        $progressBar.Size = New-Object System.Drawing.Size(420, 20)
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $progressForm.Controls.Add($progressBar)
        $statusLabel = Create-ProfessionalLabel -text "" -x 15 -y 70 -width 420
        $progressForm.Controls.Add($statusLabel)
        $progressForm.Show()
        
        foreach ($index in $selectedIndices) {
            if ($index -ge 0 -and $index -lt $listBox.Items.Count) {
                $installerName = $listBox.Items[$index].ToString()
                $installer = $installers | Where-Object { $_.Name -eq $installerName } | Select-Object -First 1
                
                if ($installer) {
                    Copy-Item -Path $installer.FullName -Destination $downloadPath -Force
                    Download-And-Install -url $installer.FullName -fileName $installer.Name -downloadPath $downloadPath -progressBar $progressBar -statusLabel $statusLabel
                }
            }
        }
        $progressForm.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación completada.", "Completado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $tabInstallers.Controls.Add($installButton)
    
    $downloadFromGitHubButton = Create-ProfessionalButton -text "Descargar desde GitHub" -x 345 -y 240 -width 150 -height 35 -action {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Seleccionar carpeta para guardar instaladores"
        $folderBrowser.SelectedPath = [Environment]::GetFolderPath("Desktop")
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            Download-InstallersFromGitHub -destinationPath $folderBrowser.SelectedPath
            Start-Sleep -Seconds 1
            $listBox = $script:UIControls['InstallersList']
            if ($listBox) {
                $installers = Initialize-Installers
                $listBox.Items.Clear()
                foreach ($instalador in $installers) { if ($instalador.Name) { $listBox.Items.Add($instalador.Name) } }
            }
        }
    }
    $tabInstallers.Controls.Add($downloadFromGitHubButton)
}

function Populate-ActivationsTab {
    $tabActivations.Controls.Clear()
    $titleLabel = Create-ProfessionalLabel -text "Activaciones y Optimización del Sistema" -x 15 -y 10 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabActivations.Controls.Add($titleLabel)
    
    $activateButton = Create-ProfessionalButton -text "Activar Windows y Office" -x 20 -y 45 -width 160 -height 30 -action { Activate-WindowsAndOffice }
    $tabActivations.Controls.Add($activateButton)
    
    $activatedWinButton = Create-ProfessionalButton -text "Ejecutar Script Activated.Win" -x 20 -y 85 -width 160 -height 30 -action {
        try { Invoke-Expression (Invoke-RestMethod -Uri "https://get.activated.win") } catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
    }
    $tabActivations.Controls.Add($activatedWinButton)
    
    $chrisTitusButton = Create-ProfessionalButton -text "Ejecutar Script de Chris Titus" -x 20 -y 125 -width 160 -height 30 -action {
        try { Invoke-Expression (Invoke-RestMethod -Uri "https://christitus.com/win") } catch { [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
    }
    $tabActivations.Controls.Add($chrisTitusButton)
    
    $optimizeNetworkButton = Create-ProfessionalButton -text "Optimizar Red" -x 200 -y 45 -width 160 -height 30 -action {
        try { Start-Process "$env:SystemRoot\System32\netsh.exe" -ArgumentList "int ip reset" -Wait -NoWindow; Start-Process "$env:SystemRoot\System32\netsh.exe" -ArgumentList "winsock reset" -Wait -NoWindow; Start-Process "$env:SystemRoot\System32\ipconfig.exe" -ArgumentList "/flushdns" -Wait -NoWindow; [System.Windows.Forms.MessageBox]::Show("Red optimizada.", "Listo", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) } catch { [System.Windows.Forms.MessageBox]::Show("Error", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
    }
    $tabActivations.Controls.Add($optimizeNetworkButton)
    
    $optimizeSystemButton = Create-ProfessionalButton -text "Optimizar Sistema" -x 200 -y 85 -width 160 -height 30 -action { Optimize-System }
    $tabActivations.Controls.Add($optimizeSystemButton)
    
    $cleanTempButton = Create-ProfessionalButton -text "Limpiar Archivos Temporales" -x 200 -y 125 -width 160 -height 30 -action { Clean-TempFiles }
    $tabActivations.Controls.Add($cleanTempButton)
    
    $createRestorePointButton = Create-ProfessionalButton -text "Crear Punto de Restauración" -x 200 -y 165 -width 160 -height 30 -action { Create-RestorePoint }
    $tabActivations.Controls.Add($createRestorePointButton)
    
    $systemInfoLabel = Create-ProfessionalLabel -text "Información del Sistema" -x 380 -y 45 -font (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold))
    $tabActivations.Controls.Add($systemInfoLabel)
    
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $processorInfo = Get-CimInstance Win32_Processor
    $infoText = "Sistema: $($osInfo.Caption)`nVersión: $($osInfo.Version)`nCPU: $($processorInfo.Name)`nRAM: $([math]::Round($osInfo.TotalVisibleMemorySize / 1MB)) GB"
    $infoLabel = Create-ProfessionalLabel -text $infoText -x 380 -y 75 -width 490 -height 120
    $tabActivations.Controls.Add($infoLabel)
}

function Populate-SettingsTab {
    $tabSettings.Controls.Clear()
    $titleLabel = Create-ProfessionalLabel -text "Configuración del Sistema" -x 15 -y 10 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($titleLabel)
    
    $wingetLabel = Create-ProfessionalLabel -text "Configuración de Winget:" -x 20 -y 40 -font (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($wingetLabel)
    $wingetStatus = if (Test-Winget) { "Instalado" } else { "No Instalado" }
    $wingetStatusLabel = Create-ProfessionalLabel -text "Estado: $wingetStatus" -x 20 -y 60
    $tabSettings.Controls.Add($wingetStatusLabel)
    $installWingetButton = Create-ProfessionalButton -text "Instalar Winget" -x 20 -y 80 -width 120 -height 30 -action { Install-Winget; $wingetStatusLabel.Text = "Estado: Instalado" }
    $tabSettings.Controls.Add($installWingetButton)
    
    $chocoLabel = Create-ProfessionalLabel -text "Configuración de Chocolatey:" -x 20 -y 120 -font (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($chocoLabel)
    $chocoStatus = if (Test-Chocolatey) { "Instalado" } else { "No Instalado" }
    $chocoStatusLabel = Create-ProfessionalLabel -text "Estado: $chocoStatus" -x 20 -y 140
    $tabSettings.Controls.Add($chocoStatusLabel)
    $installChocoButton = Create-ProfessionalButton -text "Instalar Chocolatey" -x 20 -y 160 -width 120 -height 30 -action { Install-Chocolatey; $chocoStatusLabel.Text = "Estado: Instalado" }
    $tabSettings.Controls.Add($installChocoButton)
    
    $updateLabel = Create-ProfessionalLabel -text "Actualizar Shadowiex:" -x 20 -y 240 -font (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($updateLabel)
    $updateButton = Create-ProfessionalButton -text "Actualizar desde GitHub" -x 20 -y 260 -width 150 -height 30 -action {
        try {
            # CORREGIDO: URL shadowiex
            $updateUrl = "https://github.com/WalterShadow2001/shadowiex/raw/main/Shadowiex.ps1"
            $tempFile = "$env:TEMP\Shadowiex.ps1"
            Invoke-WebRequest -Uri $updateUrl -OutFile $tempFile -ErrorAction Stop
            Copy-Item -Path $tempFile -Destination $PSCommandPath -Force
            [System.Windows.Forms.MessageBox]::Show("Script actualizado. Reinicie.", "Actualización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            $form.Close()
        } catch { [System.Windows.Forms.MessageBox]::Show("Error al actualizar: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) }
    }
    $tabSettings.Controls.Add($updateButton)
}

# Inicializar
Populate-SoftwareTab
Populate-InstallersTab
Populate-ActivationsTab
Populate-SettingsTab

 $form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
