<#
.SYNOPSIS
    Shadowiex - Herramienta de Configuración y Optimización del Sistema
.DESCRIPTION
    Una herramienta completa para instalar software, optimizar el sistema y gestionar activaciones de Windows y Office con interfaz profesional.
.NOTES
    Autor: WalterShadow2001
    Versión: 3.5 - Professional Edition (Corregido)
    Requiere: PowerShell 5.1 o superior, privilegios de administrador
#>

# Configuración inicial
 $ErrorActionPreference = "Stop"
 $ProgressPreference = 'SilentlyContinue'

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
 $form.Size = New-Object System.Drawing.Size(1000, 700)
 $form.StartPosition = "CenterScreen"
 $form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
 $form.ForeColor = [System.Drawing.Color]::White

# CORRECCIÓN: Eliminar la línea que causa el error de icono
# $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\icon.ico")

# Crear control de pestañas con tema oscuro profesional
 $tabControl = New-Object System.Windows.Forms.TabControl
 $tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
 $tabControl.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 45)
 $tabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons

# Crear pestañas con diseño mejorado
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

# Añadir pestañas al control
 $tabControl.Controls.Add($tabBasicSoftware)
 $tabControl.Controls.Add($tabInstallers)
 $tabControl.Controls.Add($tabActivations)
 $tabControl.Controls.Add($tabSettings)

# Añadir control de pestañas al formulario
 $form.Controls.Add($tabControl)

# Función para crear botones con estilo profesional
function Create-ProfessionalButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 180,
        [int]$height = 36,
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
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $button.FlatAppearance.BorderSize = 0
    $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(0, 100, 180)
    $button.Add_Click($action)
    
    return $button
}

# Función para crear labels con estilo profesional
function Create-ProfessionalLabel {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 300,
        [int]$height = 23,
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
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    }
    
    return $label
}

# Función para verificar si winget está instalado (optimizada)
function Test-Winget {
    try {
        $null = winget --version
        return $true
    }
    catch {
        return $false
    }
}

# Función para verificar si chocolatey está instalado (optimizada)
function Test-Chocolatey {
    try {
        $null = choco --version
        return $true
    }
    catch {
        return $false
    }
}

# Función para instalar winget si no está instalado (optimizada)
function Install-Winget {
    Write-Host "Instalando winget..."
    
    try {
        $latestWingetMsixBundleUri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $latestWingetMsixBundle = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundle -ErrorAction Stop
        Add-AppxPackage -Path $latestWingetMsixBundle -ErrorAction Stop
        
        if (Test-Winget) {
            Write-Host "Winget instalado correctamente."
            return $true
        }
        else {
            Write-Host "Error al instalar winget."
            return $false
        }
    }
    catch {
        Write-Host "Error al instalar Winget: $($_.Exception.Message)"
        return $false
    }
}

# Función para instalar chocolatey (optimizada)
function Install-Chocolatey {
    Write-Host "Instalando Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        if (Test-Chocolatey) {
            Write-Host "Chocolatey instalado correctamente."
            return $true
        }
        else {
            Write-Host "Error al instalar Chocolatey."
            return $false
        }
    }
    catch {
        Write-Host "Error al instalar Chocolatey: $($_.Exception.Message)"
        return $false
    }
}

# Función para instalar software (CORREGIDA - con validaciones adicionales)
function Install-Software {
    param (
        [string]$id,
        [string]$name,
        [System.Windows.Forms.ProgressBar]$progressBar,
        [System.Windows.Forms.Label]$statusLabel
    )
    
    # Validar que los controles no sean $null
    if (-not $progressBar -or -not $statusLabel) {
        Write-Host "Error: Controles de progreso o estado son nulos"
        return $false
    }
    
    $statusLabel.Text = "Instalando $name..."
    $progressBar.Value = 0
    
    # Intentar instalar con Winget primero
    if (Test-Winget) {
        try {
            $process = Start-Process -FilePath "winget" -ArgumentList "install", "--id", $id, "--accept-source-agreements", "--accept-package-agreements", "-h" -NoNewWindow -PassThru -Wait
            $progressBar.Value = 50
            
            if ($process.ExitCode -eq 0) {
                $statusLabel.Text = "$name instalado correctamente con Winget."
                $progressBar.Value = 100
                return $true
            }
            else {
                $statusLabel.Text = "Error con Winget. Intentando Chocolatey..."
            }
        }
        catch {
            $statusLabel.Text = "Error con Winget. Intentando Chocolatey..."
        }
    }
    
    # Si Winget falló o no está disponible, intentar con Chocolatey
    if (Test-Chocolatey) {
        try {
            $chocoId = $id.Split('.')[-1].ToLower()
            $process = Start-Process -FilePath "choco" -ArgumentList "install", $chocoId, "-y" -NoNewWindow -PassThru -Wait
            $progressBar.Value = 50
            
            if ($process.ExitCode -eq 0) {
                $statusLabel.Text = "$name instalado correctamente con Chocolatey."
                $progressBar.Value = 100
                return $true
            }
            else {
                $statusLabel.Text = "Error al instalar $name"
                return $false
            }
        }
        catch {
            $statusLabel.Text = "Error al instalar $name"
            return $false
        }
    }
    else {
        $statusLabel.Text = "No se pudo instalar $name. Ni Winget ni Chocolatey están disponibles."
        return $false
    }
}

# Función para descargar e instalar instaladores personalizados (optimizada)
function Download-And-Install {
    param (
        [string]$url,
        [string]$fileName,
        [string]$downloadPath,
        [System.Windows.Forms.ProgressBar]$progressBar,
        [System.Windows.Forms.Label]$statusLabel
    )
    
    # Validar que los controles no sean $null
    if (-not $progressBar -or -not $statusLabel) {
        Write-Host "Error: Controles de progreso o estado son nulos"
        return $false
    }
    
    $filePath = Join-Path -Path $downloadPath -ChildPath $fileName
    
    try {
        $statusLabel.Text = "Descargando $fileName..."
        $progressBar.Value = 0
        
        Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
        $progressBar.Value = 50
        
        $statusLabel.Text = "Instalando $fileName..."
        $process = Start-Process -FilePath $filePath -ArgumentList "/S", "/quiet", "/norestart" -PassThru
        $process.WaitForExit()
        
        if ($process.ExitCode -eq 0) {
            $statusLabel.Text = "$fileName instalado correctamente."
            $progressBar.Value = 100
            return $true
        }
        else {
            $statusLabel.Text = "Error en la instalación de $fileName. Código: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        $statusLabel.Text = "Error en la instalación"
        return $false
    }
}

# Función para crear un punto de restauración (optimizada)
function Create-RestorePoint {
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
        Checkpoint-Computer -Description "Punto de Restauración de Shadowiex" -RestorePointType "APPLICATION_INSTALL" -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Punto de restauración creado correctamente.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error al crear punto de restauración: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para limpiar archivos temporales (optimizada)
function Clean-TempFiles {
    try {
        $status = "Limpiando archivos temporales..."
        Write-Host $status
        
        # Limpiar carpeta Temp de Windows
        Get-ChildItem -Path "$env:windir\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        # Limpiar carpeta Temp del usuario
        Get-ChildItem -Path "$env:TEMP" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        # Limpiar Prefetch
        Get-ChildItem -Path "$env:windir\Prefetch" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        # Limpiar carpeta SoftwareDistribution
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:windir\SoftwareDistribution" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        
        [System.Windows.Forms.MessageBox]::Show("Archivos temporales limpiados correctamente.", "Limpieza", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error al limpiar archivos: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para optimizar la red (optimizada)
function Optimize-Network {
    try {
        $status = "Optimizando la red..."
        Write-Host $status
        
        $netshPath = "$env:SystemRoot\System32\netsh.exe"
        $ipconfigPath = "$env:SystemRoot\System32\ipconfig.exe"
        
        # Restablecer pila TCP/IP
        Start-Process -FilePath $netshPath -ArgumentList "int ip reset" -Wait -NoNewWindow -ErrorAction Stop
        
        # Restablecer catálogo Winsock
        Start-Process -FilePath $netshPath -ArgumentList "winsock reset" -Wait -NoNewWindow -ErrorAction Stop
        
        # Vaciar caché DNS
        Start-Process -FilePath $ipconfigPath -ArgumentList "/flushdns" -Wait -NoNewWindow -ErrorAction Stop
        
        # Establecer DNS a Google DNS
        $networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($interface in $networkInterfaces) {
            Set-DnsClientServerAddress -InterfaceIndex $interface.ifIndex -ServerAddresses ("8.8.8.8", "8.8.4.4") -ErrorAction Stop
        }
        
        [System.Windows.Forms.MessageBox]::Show("Red optimizada correctamente.", "Optimización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error al optimizar red: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para optimizar el sistema (optimizada)
function Optimize-System {
    try {
        $status = "Optimizando el sistema..."
        Write-Host $status
        
        # Deshabilitar servicios innecesarios
        $servicesToDisable = @(
            "DiagTrack", "dmwappushservice", "MapsBroker", "lfsvc", 
            "SharedAccess", "lltdsvc", "RemoteRegistry", "RetailDemo"
        )
        
        foreach ($service in $servicesToDisable) {
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        }
        
        $powercfgPath = "$env:SystemRoot\System32\powercfg.exe"
        
        # Deshabilitar hibernación
        Start-Process -FilePath $powercfgPath -ArgumentList "/h", "off" -Wait -NoNewWindow -ErrorAction Stop
        
        # Establecer plan de energía a alto rendimiento
        Start-Process -FilePath $powercfgPath -ArgumentList "/setactive", "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -Wait -NoNewWindow -ErrorAction Stop
        
        [System.Windows.Forms.MessageBox]::Show("Sistema optimizado correctamente.", "Optimización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error al optimizar sistema: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para activar Windows y Office (optimizada)
function Activate-WindowsAndOffice {
    try {
        $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $tsforgeScript = Join-Path -Path $scriptRoot -ChildPath "TSforge_Activation.cmd"
        
        if (-not (Test-Path -Path $tsforgeScript)) {
            $tsforgeUrl = "https://github.com/WalterShadow2001/shadowiex/raw/main/TSforge_Activation.cmd"
            Invoke-WebRequest -Uri $tsforgeUrl -OutFile $tsforgeScript -ErrorAction Stop
        }
        
        $tempBatchFile = Join-Path -Path $env:TEMP -ChildPath "activate_temp.cmd"
        
        "@echo off
set _actwin=1
set _actoff=1
call `"$tsforgeScript`"" | Out-File -FilePath $tempBatchFile -Encoding ASCII
        
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$tempBatchFile" -Wait -NoNewWindow
        Remove-Item -Path $tempBatchFile -Force
        
        [System.Windows.Forms.MessageBox]::Show("Activación completada.", "Activación", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error al activar: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para ejecutar script de activated.win
function Run-ActivatedWin {
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://get.activated.win")
        [System.Windows.Forms.MessageBox]::Show("Script de Activated.Win ejecutado.", "Script Ejecutado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para ejecutar script de Chris Titus
function Run-ChrisTitusScript {
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://christitus.com/win")
        [System.Windows.Forms.MessageBox]::Show("Script de Chris Titus ejecutado.", "Script Ejecutado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Función para gestionar los instaladores personalizados
function Initialize-Installers {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $instaladoresPath = Join-Path -Path $scriptRoot -ChildPath "instaladores"
    
    if (-not (Test-Path -Path $instaladoresPath)) {
        New-Item -ItemType Directory -Path $instaladoresPath -Force | Out-Null
    }
    
    # Validar que la ruta exista antes de intentar obtener archivos
    if (Test-Path -Path $instaladoresPath) {
        return Get-ChildItem -Path $instaladoresPath -Filter "*.exe" -ErrorAction SilentlyContinue
    }
    else {
        return $null
    }
}

# Función para descargar instaladores desde GitHub
function Download-InstallersFromGitHub {
    param ([string]$destinationPath)
    
    try {
        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        }
        
        $repoUrl = "https://github.com/WalterShadow2001/shadowiex/archive/refs/heads/main.zip"
        $tempZip = Join-Path -Path $env:TEMP -ChildPath "shadowiex-instaladores.zip"
        $extractPath = Join-Path -Path $env:TEMP -ChildPath "shadowiex-extract"
        
        Invoke-WebRequest -Uri $repoUrl -OutFile $tempZip -ErrorAction Stop
        
        if (Test-Path -Path $extractPath) {
            Remove-Item -Path $extractPath -Recurse -Force
        }
        
        Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
        
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
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Definir categorías de software con información adicional
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

# Poblar pestaña de Software Básico con diseño mejorado
function Populate-SoftwareTab {
    $tabBasicSoftware.Controls.Clear()
    
    # Título
    $titleLabel = Create-ProfessionalLabel -text "Seleccione el software a instalar:" -x 20 -y 15 -font (New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold))
    $tabBasicSoftware.Controls.Add($titleLabel)
    
    # Panel con scroll
    $scrollPanel = New-Object System.Windows.Forms.Panel
    $scrollPanel.AutoScroll = $true
    $scrollPanel.Location = New-Object System.Drawing.Point(20, 50)
    $scrollPanel.Size = New-Object System.Drawing.Size(940, 450)
    $scrollPanel.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
    $tabBasicSoftware.Controls.Add($scrollPanel)
    
    $global:allCheckboxes = @()
    $yPos = 10
    
    foreach ($category in $softwareCategories.Keys) {
        # Etiqueta de categoría
        $categoryLabel = Create-ProfessionalLabel -text $category -x 10 -y $yPos -font (New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold))
        $scrollPanel.Controls.Add($categoryLabel)
        
        $yPos += 30
        
        foreach ($software in $softwareCategories[$category]) {
            # Checkbox con icono
            $checkbox = New-Object System.Windows.Forms.CheckBox
            $checkbox.Text = "$($software.icon) $($software.name)"
            $checkbox.Location = New-Object System.Drawing.Point(30, $yPos)
            $checkbox.Size = New-Object System.Drawing.Size(900, 25)
            $checkbox.Tag = $software.id
            $checkbox.ForeColor = [System.Drawing.Color]::White
            $checkbox.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
            $scrollPanel.Controls.Add($checkbox)
            
            $global:allCheckboxes += @{checkbox = $checkbox; id = $software.id; name = $software.name}
            
            $yPos += 30
        }
        
        $yPos += 15
    }
    
    # Botones de acción
    $installButton = Create-ProfessionalButton -text "Instalar Software Seleccionado" -x 20 -y 520 -width 220 -action {
        $selectedSoftware = $global:allCheckboxes | Where-Object { $_.checkbox.Checked }
        
        if ($selectedSoftware.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Por favor, seleccione al menos un software para instalar.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Verificar e instalar winget/chocolatey si es necesario
        if (-not (Test-Winget)) {
            if (-not (Install-Winget)) {
                if (-not (Install-Chocolatey)) {
                    [System.Windows.Forms.MessageBox]::Show("No se pudo instalar ni Winget ni Chocolatey. Por favor, instale uno de ellos manualmente.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    return
                }
            }
        }
        
        # Crear formulario de progreso
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Instalando Software"
        $progressForm.Size = New-Object System.Drawing.Size(500, 200)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
        $progressForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        
        $progressLabel = Create-ProfessionalLabel -text "Instalando software..." -x 20 -y 20 -width 460
        $progressForm.Controls.Add($progressLabel)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(20, 50)
        $progressBar.Size = New-Object System.Drawing.Size(460, 20)
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $progressForm.Controls.Add($progressBar)
        
        $statusLabel = Create-ProfessionalLabel -text "" -x 20 -y 80 -width 460
        $progressForm.Controls.Add($statusLabel)
        
        $progressForm.Show()
        
        # Instalar software
        $global:TotalSoftware = $selectedSoftware.Count
        $global:InstalledSoftware = 0
        
        foreach ($software in $selectedSoftware) {
            Install-Software -id $software.id -name $software.name -progressBar $progressBar -statusLabel $statusLabel
            $global:InstalledSoftware++
        }
        
        $progressForm.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación completada. Software instalado: $global:InstalledSoftware de $global:TotalSoftware", "Instalación Completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $tabBasicSoftware.Controls.Add($installButton)
    
    $selectAllButton = Create-ProfessionalButton -text "Seleccionar Todo" -x 250 -y 520 -width 150 -height 30 -action {
        foreach ($item in $global:allCheckboxes) {
            $item.checkbox.Checked = $true
        }
    }
    $tabBasicSoftware.Controls.Add($selectAllButton)
    
    $deselectAllButton = Create-ProfessionalButton -text "Deseleccionar Todo" -x 410 -y 520 -width 150 -height 30 -action {
        foreach ($item in $global:allCheckboxes) {
            $item.checkbox.Checked = $false
        }
    }
    $tabBasicSoftware.Controls.Add($deselectAllButton)
}

# Poblar pestaña de Instaladores Personalizados
function Populate-InstallersTab {
    $tabInstallers.Controls.Clear()
    
    $titleLabel = Create-ProfessionalLabel -text "Gestor de Instaladores Personalizados" -x 20 -y 15 -font (New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold))
    $tabInstallers.Controls.Add($titleLabel)
    
    # Lista de instaladores
    $installersList = New-Object System.Windows.Forms.ListBox
    $installersList.Location = New-Object System.Drawing.Point(20, 50)
    $installersList.Size = New-Object System.Drawing.Size(940, 200)
    $installersList.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
    $installersList.ForeColor = [System.Drawing.Color]::White
    $installersList.SelectionMode = [System.Windows.Forms.SelectionMode]::MultiExtended
    $tabInstallers.Controls.Add($installersList)
    
    # Botón de refresco
    $refreshButton = Create-ProfessionalButton -text "Actualizar Lista" -x 20 -y 260 -width 150 -height 30 -action {
        $installers = Initialize-Installers
        $installersList.Items.Clear()
        
        # Validar que $installers no sea $null antes de intentar acceder a sus propiedades
        if ($installers -and $installers.Count -gt 0) {
            foreach ($instalador in $installers) {
                # Validar que el instalador tenga la propiedad Name
                if ($instalador -and $instalador.Name) {
                    $installersList.Items.Add($instalador.Name)
                }
            }
        }
    }
    $tabInstallers.Controls.Add($refreshButton)
    
    # Carpeta de descarga
    $downloadFolderLabel = Create-ProfessionalLabel -text "Carpeta de Descarga:" -x 200 -y 260
    $tabInstallers.Controls.Add($downloadFolderLabel)
    
    $downloadFolderTextBox = New-Object System.Windows.Forms.TextBox
    $downloadFolderTextBox.Location = New-Object System.Drawing.Point(320, 260)
    $downloadFolderTextBox.Size = New-Object System.Drawing.Size(300, 23)
    $downloadFolderTextBox.Text = [Environment]::GetFolderPath("Desktop")
    $downloadFolderTextBox.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 70)
    $downloadFolderTextBox.ForeColor = [System.Drawing.Color]::White
    $tabInstallers.Controls.Add($downloadFolderTextBox)
    
    $selectFolderButton = Create-ProfessionalButton -text "Examinar..." -x 630 -y 260 -width 100 -height 23 -action {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Seleccionar carpeta de descarga"
        $folderBrowser.SelectedPath = $downloadFolderTextBox.Text
        
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $downloadFolderTextBox.Text = $folderBrowser.SelectedPath
        }
    }
    $tabInstallers.Controls.Add($selectFolderButton)
    
    # Botón de instalación
    $installButton = Create-ProfessionalButton -text "Instalar Seleccionados" -x 200 -y 300 -width 220 -height 40 -action {
        $selectedIndices = $installersList.SelectedIndices
        if ($selectedIndices.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Por favor, seleccione al menos un instalador.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
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
        
        # Crear formulario de progreso
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Instalando Programas"
        $progressForm.Size = New-Object System.Drawing.Size(500, 150)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
        $progressForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        
        $progressLabel = Create-ProfessionalLabel -text "Instalando programas..." -x 20 -y 20 -width 460
        $progressForm.Controls.Add($progressLabel)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(20, 50)
        $progressBar.Size = New-Object System.Drawing.Size(460, 20)
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
        $progressForm.Controls.Add($progressBar)
        
        $statusLabel = Create-ProfessionalLabel -text "" -x 20 -y 80 -width 460
        $progressForm.Controls.Add($statusLabel)
        
        $progressForm.Show()
        
        foreach ($index in $selectedIndices) {
            # Validar que el índice esté dentro del rango
            if ($index -ge 0 -and $index -lt $installersList.Items.Count) {
                $installerName = $installersList.Items[$index].ToString()
                $installer = $installers | Where-Object { $_.Name -eq $installerName } | Select-Object -First 1
                
                if ($installer) {
                    $destinationPath = Join-Path $downloadPath $installer.Name
                    Copy-Item -Path $installer.FullName -Destination $destinationPath -Force
                    
                    Download-And-Install -url $installer.FullName -fileName $installer.Name -downloadPath $downloadPath -progressBar $progressBar -statusLabel $statusLabel
                }
            }
        }
        
        $progressForm.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación completada.", "Instalación Completada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    $tabInstallers.Controls.Add($installButton)
    
    # Botón de descarga desde GitHub
    $downloadFromGitHubButton = Create-ProfessionalButton -text "Descargar desde GitHub" -x 440 -y 300 -width 180 -height 40 -action {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Seleccionar carpeta para guardar instaladores"
        $folderBrowser.SelectedPath = [Environment]::GetFolderPath("Desktop")
        
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            Download-InstallersFromGitHub -destinationPath $folderBrowser.SelectedPath
        }
    }
    $tabInstallers.Controls.Add($downloadFromGitHubButton)
}

# Poblar pestaña de Activaciones y Optimización
function Populate-ActivationsTab {
    $tabActivations.Controls.Clear()
    
    $titleLabel = Create-ProfessionalLabel -text "Activaciones y Optimización del Sistema" -x 20 -y 15 -font (New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold))
    $tabActivations.Controls.Add($titleLabel)
    
    # Botones de activación
    $activateButton = Create-ProfessionalButton -text "Activar Windows y Office" -x 30 -y 60 -width 200 -height 40 -action {
        Activate-WindowsAndOffice
    }
    $tabActivations.Controls.Add($activateButton)
    
    $activatedWinButton = Create-ProfessionalButton -text "Ejecutar Script Activated.Win" -x 30 -y 110 -width 200 -height 40 -action {
        Run-ActivatedWin
    }
    $tabActivations.Controls.Add($activatedWinButton)
    
    $chrisTitusButton = Create-ProfessionalButton -text "Ejecutar Script de Chris Titus" -x 30 -y 160 -width 200 -height 40 -action {
        Run-ChrisTitusScript
    }
    $tabActivations.Controls.Add($chrisTitusButton)
    
    # Botones de optimización
    $optimizeNetworkButton = Create-ProfessionalButton -text "Optimizar Red" -x 250 -y 60 -width 200 -height 40 -action {
        Optimize-Network
    }
    $tabActivations.Controls.Add($optimizeNetworkButton)
    
    $optimizeSystemButton = Create-ProfessionalButton -text "Optimizar Sistema" -x 250 -y 110 -width 200 -height 40 -action {
        Optimize-System
    }
    $tabActivations.Controls.Add($optimizeSystemButton)
    
    $cleanTempButton = Create-ProfessionalButton -text "Limpiar Archivos Temporales" -x 250 -y 160 -width 200 -height 40 -action {
        Clean-TempFiles
    }
    $tabActivations.Controls.Add($cleanTempButton)
    
    $createRestorePointButton = Create-ProfessionalButton -text "Crear Punto de Restauración" -x 250 -y 210 -width 200 -height 40 -action {
        Create-RestorePoint
    }
    $tabActivations.Controls.Add($createRestorePointButton)
    
    # Información del sistema
    $systemInfoLabel = Create-ProfessionalLabel -text "Información del Sistema" -x 470 -y 60 -font (New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold))
    $tabActivations.Controls.Add($systemInfoLabel)
    
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $processorInfo = Get-CimInstance Win32_Processor
    
    $infoText = @"
Sistema Operativo: $($osInfo.Caption)
Versión: $($osInfo.Version)
Arquitectura: $($osInfo.OSArchitecture)
Procesador: $($processorInfo.Name)
Memoria RAM: $([math]::Round($osInfo.TotalVisibleMemorySize / 1MB)) GB
Disco Duro: $([math]::Round((Get-PSDrive C).Used / 1GB)) GB / $([math]::Round((Get-PSDrive C).Free / 1GB)) GB libres
"@
    
    $infoLabel = Create-ProfessionalLabel -text $infoText -x 470 -y 90 -width 480 -height 150
    $tabActivations.Controls.Add($infoLabel)
}

# Poblar pestaña de Configuración
function Populate-SettingsTab {
    $tabSettings.Controls.Clear()
    
    $titleLabel = Create-ProfessionalLabel -text "Configuración del Sistema" -x 20 -y 15 -font (New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($titleLabel)
    
    # Configuración de winget
    $wingetLabel = Create-ProfessionalLabel -text "Configuración de Winget:" -x 30 -y 50 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($wingetLabel)
    
    $wingetStatus = if (Test-Winget) { "Instalado" } else { "No Instalado" }
    $wingetStatusLabel = Create-ProfessionalLabel -text "Estado: $wingetStatus" -x 30 -y 75
    $tabSettings.Controls.Add($wingetStatusLabel)
    
    $installWingetButton = Create-ProfessionalButton -text "Instalar Winget" -x 30 -y 100 -width 150 -height 30 -action {
        Install-Winget
        $wingetStatusLabel.Text = "Estado: Instalado"
    }
    $tabSettings.Controls.Add($installWingetButton)
    
    # Configuración de Chocolatey
    $chocoLabel = Create-ProfessionalLabel -text "Configuración de Chocolatey:" -x 30 -y 140 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($chocoLabel)
    
    $chocoStatus = if (Test-Chocolatey) { "Instalado" } else { "No Instalado" }
    $chocoStatusLabel = Create-ProfessionalLabel -text "Estado: $chocoStatus" -x 30 -y 165
    $tabSettings.Controls.Add($chocoStatusLabel)
    
    $installChocoButton = Create-ProfessionalButton -text "Instalar Chocolatey" -x 30 -y 190 -width 150 -height 30 -action {
        Install-Chocolatey
        $chocoStatusLabel.Text = "Estado: Instalado"
    }
    $tabSettings.Controls.Add($installChocoButton)
    
    # Limpiar caché
    $clearCacheButton = Create-ProfessionalButton -text "Limpiar Caché" -x 30 -y 240 -width 150 -height 30 -action {
        try {
            if (Test-Winget) {
                winget cache reset
                [System.Windows.Forms.MessageBox]::Show("Caché de Winget limpiado.", "Limpieza", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("Winget no está instalado.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    $tabSettings.Controls.Add($clearCacheButton)
    
    # Actualizar Shadowiex
    $updateLabel = Create-ProfessionalLabel -text "Actualizar Shadowiex:" -x 30 -y 290 -font (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold))
    $tabSettings.Controls.Add($updateLabel)
    
    $updateButton = Create-ProfessionalButton -text "Actualizar desde GitHub" -x 30 -y 315 -width 150 -height 30 -action {
        try {
            $updateUrl = "https://github.com/WalterShadow2001/shadowiex/raw/main/Shadowiex.ps1"
            $tempFile = "$env:TEMP\Shadowiex.ps1"
            
            Invoke-WebRequest -Uri $updateUrl -OutFile $tempFile -ErrorAction Stop
            Copy-Item -Path $tempFile -Destination $PSCommandPath -Force
            
            [System.Windows.Forms.MessageBox]::Show("Shadowiex actualizado. Reinicie el programa.", "Actualización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            $form.Close()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error al actualizar: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    $tabSettings.Controls.Add($updateButton)
}

# Poblar todas las pestañas
Populate-SoftwareTab
Populate-InstallersTab
Populate-ActivationsTab
Populate-SettingsTab

# Evento de carga del formulario
 $form.Add_Shown({$form.Activate()})

# Mostrar el formulario
[void]$form.ShowDialog()
