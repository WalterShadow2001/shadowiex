# Shadowiex - Herramienta de Configuración y Optimización del Sistema
# Verificar si se ejecuta como administrador, si no reiniciar con privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Cargar ensamblados necesarios para la GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# Crear formulario principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Shadowiex - Herramienta de Configuración y Optimización del Sistema"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::White

# Crear control de pestañas
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill

# Crear pestañas
$tabBasicSoftware = New-Object System.Windows.Forms.TabPage
$tabBasicSoftware.Text = "Software Básico"

$tabInstallers = New-Object System.Windows.Forms.TabPage
$tabInstallers.Text = "Instaladores"

$tabActivations = New-Object System.Windows.Forms.TabPage
$tabActivations.Text = "Activaciones y Optimizaciones"

# Añadir pestañas al control de pestañas
$tabControl.Controls.Add($tabBasicSoftware)
$tabControl.Controls.Add($tabInstallers)
$tabControl.Controls.Add($tabActivations)

# Añadir control de pestañas al formulario
$form.Controls.Add($tabControl)

# Función para crear un botón con estilo
function Create-StyledButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 200,
        [int]$height = 40,
        [scriptblock]$action
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Text = $text
    $button.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $button.Add_Click($action)
    
    return $button
}

# Función para verificar si winget está instalado
function Check-WingetInstalled {
    try {
        $wingetVersion = winget --version
        return $true
    }
    catch {
        return $false
    }
}

# Función para verificar si chocolatey está instalado
function Check-ChocolateyInstalled {
    try {
        $chocoVersion = choco --version
        return $true
    }
    catch {
        return $false
    }
}

# Función para instalar winget si no está instalado
function Install-Winget {
    Write-Host "Instalando winget..."
    $progressPreference = 'silentlyContinue'
    
    $latestWingetMsixBundleUri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $latestWingetMsixBundle = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    
    try {
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundle
        Add-AppxPackage -Path $latestWingetMsixBundle
        
        # Verificar si la instalación fue exitosa
        if (Check-WingetInstalled) {
            Write-Host "Winget instalado correctamente."
            return $true
        }
        else {
            Write-Host "Error al instalar winget."
            return $false
        }
    }
    catch {
        Write-Host "Error al instalar Winget: $_"
        return $false
    }
}

# Función para instalar chocolatey
function Install-Chocolatey {
    Write-Host "Instalando Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Verificar si la instalación fue exitosa
        if (Check-ChocolateyInstalled) {
            Write-Host "Chocolatey instalado correctamente."
            return $true
        }
        else {
            Write-Host "Error al instalar Chocolatey."
            return $false
        }
    }
    catch {
        Write-Host "Error al instalar Chocolatey: $_"
        return $false
    }
}

# Función para instalar software usando winget o chocolatey
function Install-Software {
    param (
        [string]$id,
        [string]$name
    )
    
    Write-Host "Instalando $name..."
    
    # Intentar instalar con Winget primero si está disponible
    if (Check-WingetInstalled) {
        winget install --id $id --accept-source-agreements --accept-package-agreements -h | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$name instalado correctamente con Winget."
            return $true
        }
        else {
            Write-Host "Error al instalar $name con Winget. Intentando con Chocolatey..."
        }
    }
    
    # Si Winget no está disponible o falló, intentar con Chocolatey
    if (Check-ChocolateyInstalled) {
        # Convertir ID de Winget a ID de Chocolatey (pueden ser diferentes)
        # Para simplificar, usamos el mismo ID, pero en un caso real podrías tener un mapeo
        $chocoId = $id.Split('.')[-1].ToLower()
        
        choco install $chocoId -y | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$name instalado correctamente con Chocolatey."
            return $true
        }
        else {
            Write-Host "Error al instalar $name con Chocolatey."
            return $false
        }
    }
    else {
        Write-Host "No se pudo instalar $name. Ni Winget ni Chocolatey están disponibles."
        return $false
    }
}

# Función para descargar e instalar instaladores personalizados
function Download-And-Install {
    param (
        [string]$url,
        [string]$fileName,
        [string]$downloadPath
    )
    
    $filePath = Join-Path -Path $downloadPath -ChildPath $fileName
    
    try {
        # Descargar el archivo
        Write-Host "Descargando $fileName..."
        Invoke-WebRequest -Uri $url -OutFile $filePath
        
        # Instalar el archivo
        Write-Host "Instalando $fileName..."
        Start-Process -FilePath $filePath -ArgumentList "/S", "/quiet", "/norestart" -Wait
        
        Write-Host "$fileName instalado correctamente."
        return $true
    }
    catch {
        Write-Host "Error al descargar o instalar $fileName. Error: $_"
        return $false
    }
}

# Función para crear un punto de restauración
function Create-RestorePoint {
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "Punto de Restauración de Shadowiex" -RestorePointType "APPLICATION_INSTALL"
    Write-Host "Punto de restauración creado correctamente."
}

# Función para limpiar archivos temporales
function Clean-TempFiles {
    Write-Host "Limpiando archivos temporales..."
    
    # Limpiar carpeta Temp de Windows
    Get-ChildItem -Path "$env:windir\Temp" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    
    # Limpiar carpeta Temp del usuario
    Get-ChildItem -Path "$env:TEMP" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    
    # Limpiar Prefetch
    Get-ChildItem -Path "$env:windir\Prefetch" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    
    # Limpiar carpeta SoftwareDistribution
    Stop-Service -Name wuauserv -Force
    Get-ChildItem -Path "$env:windir\SoftwareDistribution" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv
    
    Write-Host "Archivos temporales limpiados correctamente."
}

# Función para optimizar la red
function Optimize-Network {
    Write-Host "Optimizando la red..."
    
    # Usar rutas completas para los comandos del sistema
    $netshPath = "$env:SystemRoot\System32\netsh.exe"
    $ipconfigPath = "$env:SystemRoot\System32\ipconfig.exe"
    
    # Restablecer pila TCP/IP
    Start-Process -FilePath $netshPath -ArgumentList "int ip reset" -Wait -NoNewWindow
    
    # Restablecer catálogo Winsock
    Start-Process -FilePath $netshPath -ArgumentList "winsock reset" -Wait -NoNewWindow
    
    # Vaciar caché DNS
    Start-Process -FilePath $ipconfigPath -ArgumentList "/flushdns" -Wait -NoNewWindow
    
    # Establecer DNS a Google DNS
    $networkInterfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($interface in $networkInterfaces) {
        Set-DnsClientServerAddress -InterfaceIndex $interface.ifIndex -ServerAddresses ("8.8.8.8", "8.8.4.4")
    }
    
    Write-Host "Red optimizada correctamente."
}

# Función para optimizar el sistema
function Optimize-System {
    Write-Host "Optimizando el sistema..."
    
    # Deshabilitar servicios innecesarios
    $servicesToDisable = @(
        "DiagTrack",                # Experiencias del usuario conectado y telemetría
        "dmwappushservice",         # Servicio de enrutamiento de mensajes de inserción WAP
        "MapsBroker",               # Administrador de mapas descargados
        "lfsvc",                    # Servicio de geolocalización
        "SharedAccess",             # Uso compartido de conexión a Internet
        "lltdsvc",                  # Asignador de descubrimiento de topología de nivel de vínculo
        "RemoteRegistry",           # Registro remoto
        "RetailDemo"                # Servicio de demostración en tienda
    )
    
    foreach ($service in $servicesToDisable) {
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    }
    
    # Usar rutas completas para los comandos del sistema
    $powercfgPath = "$env:SystemRoot\System32\powercfg.exe"
    
    # Deshabilitar hibernación para liberar espacio en disco
    Start-Process -FilePath $powercfgPath -ArgumentList "/h", "off" -Wait -NoNewWindow
    
    # Establecer plan de energía a alto rendimiento
    Start-Process -FilePath $powercfgPath -ArgumentList "/setactive", "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -Wait -NoNewWindow
    
    Write-Host "Sistema optimizado correctamente."
}

# Función para activar Windows y Office
function Activate-WindowsAndOffice {
    # Obtener la ruta base del script de manera confiable
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    
    # Definir rutas para los scripts de activación
    $tsforgeScript = Join-Path -Path $scriptRoot -ChildPath "TSforge_Activation.cmd"
    
    # Verificar si el script existe
    if (-not (Test-Path -Path $tsforgeScript)) {
        Write-Host "Descargando script de activación TSforge..."
        $tsforgeUrl = "https://github.com/WalterShadow2001/shadowiex/raw/main/TSforge_Activation.cmd"
        
        try {
            # Descargar el script directamente
            Invoke-WebRequest -Uri $tsforgeUrl -OutFile $tsforgeScript
            
            if (Test-Path -Path $tsforgeScript) {
                Write-Host "Script de activación TSforge descargado correctamente."
            } else {
                Write-Host "Error: No se pudo descargar el script de activación."
                return
            }
        } catch {
            Write-Host "Error al descargar el script de activación: $_"
            return
        }
    }
    
    # Ejecutar el script de activación
    try {
        Write-Host "Ejecutando script de activación..."
        if (Test-Path -Path $tsforgeScript) {
            # Configurar los parámetros para activar Windows y Office
            $tempBatchFile = Join-Path -Path $env:TEMP -ChildPath "activate_temp.cmd"
            
            # Crear un archivo batch temporal que configure las variables y ejecute el script
            @"
@echo off
set _actwin=1
set _actoff=1
call "$tsforgeScript"
"@ | Out-File -FilePath $tempBatchFile -Encoding ASCII
            
            # Ejecutar el archivo batch temporal (corregido)
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$tempBatchFile" -Wait -NoNewWindow
            
            # Limpiar el archivo temporal
            if (Test-Path -Path $tempBatchFile) {
                Remove-Item -Path $tempBatchFile -Force
            }
            
            Write-Host "Activación completada."
        } else {
            Write-Host "Error: No se encontró el script de activación en la ruta: $tsforgeScript"
        }
    } catch {
        Write-Host "Error al ejecutar el script de activación: $_"
    }
}

# Función para ejecutar script de activación desde activated.win
function Run-ActivatedWin {
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://get.activated.win")
        Write-Host "Script de activated.win ejecutado correctamente."
    }
    catch {
        Write-Host "Error al ejecutar el script de activated.win. Error: $_"
    }
}

# Función para ejecutar script de Chris Titus
function Run-ChrisTitusScript {
    try {
        Invoke-Expression (Invoke-RestMethod -Uri "https://christitus.com/win")
        Write-Host "Script de Chris Titus ejecutado correctamente."
    }
    catch {
        Write-Host "Error al ejecutar el script de Chris Titus. Error: $_"
    }
}



# Función para gestionar los instaladores
# Función para gestionar los instaladores
function Initialize-Installers {
    # Obtener la ruta base del script de manera confiable
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    
    $instaladoresPath = Join-Path -Path $scriptRoot -ChildPath "instaladores"
    
    # Crear directorio si no existe
    if (-not (Test-Path -Path $instaladoresPath)) {
        Write-Host "Creando directorio de instaladores..."
        New-Item -ItemType Directory -Path $instaladoresPath -Force | Out-Null
    }
    
    # Verificar si hay instaladores
    $instaladores = Get-ChildItem -Path $instaladoresPath -Filter "*.exe" -ErrorAction SilentlyContinue
    
    if (-not $instaladores -or $instaladores.Count -eq 0) {
        Write-Host "No se encontraron instaladores en la carpeta $instaladoresPath."
        
        # Opcionalmente, descargar instaladores desde GitHub
        $descargarInstaladores = $true
        if ($descargarInstaladores) {
            Write-Host "Descargando instaladores desde GitHub..."
            Download-InstallersFromGitHub -destinationPath $instaladoresPath
            
            # Verificar nuevamente después de la descarga
            $instaladores = Get-ChildItem -Path $instaladoresPath -Filter "*.exe" -ErrorAction SilentlyContinue
        }
    }
    
    if (-not $instaladores -or $instaladores.Count -eq 0) {
        Write-Host "No se encontraron instaladores en la carpeta después de intentar descargarlos."
        return $null
    } else {
        Write-Host "Instaladores encontrados: $($instaladores.Count)"
        return $instaladores
    }
}

# Función para descargar instaladores desde GitHub
function Download-InstallersFromGitHub {
    param (
        [string]$destinationPath
    )
    
    try {
        # Verificar y crear el directorio de destino si no existe
        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        }
        
        # URL del repositorio de GitHub con los instaladores
        $repoUrl = "https://github.com/WalterShadow2001/shadowiex/archive/refs/heads/main.zip"
        $tempZip = Join-Path -Path $env:TEMP -ChildPath "shadowiex-instaladores.zip"
        $extractPath = Join-Path -Path $env:TEMP -ChildPath "shadowiex-extract"
        
        # Descargar el archivo ZIP del repositorio
        Invoke-WebRequest -Uri $repoUrl -OutFile $tempZip
        
        # Limpiar directorio de extracción temporal si existe
        if (Test-Path -Path $extractPath) {
            Remove-Item -Path $extractPath -Recurse -Force
        }
        
        # Extraer el archivo
        Expand-Archive -Path $tempZip -DestinationPath $extractPath -Force
        
        # Copiar los instaladores al directorio de destino
        $sourceDir = Join-Path -Path $extractPath -ChildPath "shadowiex-main\instaladores"
        if (Test-Path -Path $sourceDir) {
            $instaladores = Get-ChildItem -Path $sourceDir -Filter "*.exe" -ErrorAction SilentlyContinue
            foreach ($instalador in $instaladores) {
                Copy-Item -Path $instalador.FullName -Destination $destinationPath -Force
                Write-Host "Copiado: $($instalador.Name)"
            }
        } else {
            Write-Host "Error: No se encontró el directorio de instaladores en el archivo descargado."
        }
        
        # Limpiar archivos temporales
        Remove-Item -Path $tempZip -Force
        Remove-Item -Path $extractPath -Recurse -Force
        
        Write-Host "Descarga de instaladores completada."
    } catch {
        Write-Host "Error al descargar instaladores desde GitHub: $_"
    }
}

# Definir categorías de software y sus aplicaciones
$softwareCategories = @{
    "Navegadores" = @(
        @{id = "Google.Chrome"; name = "Google Chrome"},
        @{id = "Mozilla.Firefox"; name = "Mozilla Firefox"},
        @{id = "Opera.Opera"; name = "Opera"},
        @{id = "Microsoft.Edge"; name = "Microsoft Edge"},
        @{id = "BraveSoftware.BraveBrowser"; name = "Navegador Brave"}
    )
    "Desarrollo" = @(
        @{id = "Git.Git"; name = "Git"},
        @{id = "GitHub.GitHubDesktop"; name = "GitHub Desktop"},  # Corregido el ID de GitHub Desktop
        @{id = "Microsoft.VisualStudioCode"; name = "Visual Studio Code"},
        @{id = "Notepad++.Notepad++"; name = "Notepad++"}
    )
    "Multimedia" = @(
        @{id = "VideoLAN.VLC"; name = "VLC Media Player"},
        @{id = "GIMP.GIMP"; name = "GIMP"},
        @{id = "IrfanSkiljan.IrfanView"; name = "IrfanView"}
    )
    "Comunicación" = @(
        @{id = "Zoom.Zoom"; name = "Zoom"},
        @{id = "Microsoft.Teams"; name = "Microsoft Teams"},
        @{id = "Discord.Discord"; name = "Discord"},
        @{id = "Telegram.TelegramDesktop"; name = "Telegram"},
        @{id = "WhatsApp.WhatsApp"; name = "WhatsApp Desktop"},
        @{id = "Slack.Slack"; name = "Slack"}
    )
    "Utilidades" = @(
        @{id = "7zip.7zip"; name = "7-Zip"},
        @{id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Reader"},
        @{id = "RARLab.WinRAR"; name = "WinRAR"},
        @{id = "TeamViewer.TeamViewer"; name = "TeamViewer"},
        @{id = "Rufus.Rufus"; name = "Rufus"}
    )
    "Runtimes" = @(
        @{id = "Oracle.JavaRuntimeEnvironment"; name = "Java Runtime Environment"},
        @{id = "Microsoft.DotNet.Runtime.6"; name = ".NET Runtime 6"},
        @{id = "Microsoft.DotNet.Runtime.7"; name = ".NET Runtime 7"},
        @{id = "Microsoft.DotNet.Framework"; name = ".NET Framework"}
    )
}

# Poblar pestaña de Software Básico
$basicSoftwareLabel = New-Object System.Windows.Forms.Label
$basicSoftwareLabel.Text = "Seleccione el software a instalar:"
$basicSoftwareLabel.Location = New-Object System.Drawing.Point(20, 20)
$basicSoftwareLabel.Size = New-Object System.Drawing.Size(300, 20)
$tabBasicSoftware.Controls.Add($basicSoftwareLabel)

# Limpiar los controles existentes en la pestaña de software básico
$tabBasicSoftware.Controls.Clear()
$tabBasicSoftware.Controls.Add($basicSoftwareLabel)

# Crear un panel con scroll para contener las categorías y checkboxes
$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.AutoScroll = $true
$scrollPanel.Location = New-Object System.Drawing.Point(20, 50)
$scrollPanel.Size = New-Object System.Drawing.Size(500, 400)
$tabBasicSoftware.Controls.Add($scrollPanel)

# Lista para almacenar todos los checkboxes y sus IDs correspondientes
$global:allCheckboxes = @()

# Posición vertical inicial
$yPos = 10

# Crear checkboxes agrupados por categoría
foreach ($category in $softwareCategories.Keys) {
    # Crear etiqueta para la categoría
    $categoryLabel = New-Object System.Windows.Forms.Label
    $categoryLabel.Text = $category
    $categoryLabel.Location = New-Object System.Drawing.Point(10, $yPos)
    $categoryLabel.Size = New-Object System.Drawing.Size(480, 20)
    $categoryLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $scrollPanel.Controls.Add($categoryLabel)
    
    $yPos += 25
    
    # Crear checkboxes para cada software en la categoría
    foreach ($software in $softwareCategories[$category]) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $software.name
        $checkbox.Location = New-Object System.Drawing.Point(30, $yPos)
        $checkbox.Size = New-Object System.Drawing.Size(450, 20)
        $checkbox.Tag = $software.id  # Guardar el ID en la propiedad Tag
        $scrollPanel.Controls.Add($checkbox)
        
        # Añadir el checkbox a la lista global
        $global:allCheckboxes += @{checkbox = $checkbox; id = $software.id; name = $software.name}
        
        $yPos += 25
    }
    
    $yPos += 15  # Espacio adicional entre categorías
}

# Crear botón de instalación para software básico
$installBasicSoftwareButton = Create-StyledButton -text "Instalar Software Seleccionado" -x 550 -y 50 -action {
    # Verificar si winget está instalado, si no intentar instalarlo automáticamente
    if (-not (Check-WingetInstalled)) {
        Write-Host "Winget no está instalado. Intentando instalarlo automáticamente..."
        $progressBar.Value = 0
        $progressBar.Maximum = 2
        $progressBar.Visible = $true
        
        if (Install-Winget) {
            Write-Host "Winget instalado correctamente."
            $progressBar.Value = 1
        } else {
            Write-Host "No se pudo instalar Winget. Intentando instalar Chocolatey como alternativa..."
            
            if (-not (Check-ChocolateyInstalled)) {
                if (Install-Chocolatey) {
                    Write-Host "Chocolatey instalado correctamente."
                    $progressBar.Value = 1
                } else {
                    Write-Host "Error al instalar Chocolatey."
                    [System.Windows.Forms.MessageBox]::Show("No se pudo instalar ni Winget ni Chocolatey. Por favor, instale uno de ellos manualmente e intente nuevamente.", "Error de Instalación", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    $progressBar.Visible = $false
                    return
                }
            } else {
                Write-Host "Chocolatey ya está instalado."
                $progressBar.Value = 1
            }
        }
    }
    
    # Recopilar software seleccionado
    $selectedSoftware = $global:allCheckboxes | Where-Object { $_.checkbox.Checked }
    
    if ($selectedSoftware.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Por favor, seleccione al menos un software para instalar.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $progressBar.Value = 0
    $progressBar.Maximum = $selectedSoftware.Count
    $progressBar.Visible = $true
    
    foreach ($software in $selectedSoftware) {
        Install-Software -id $software.id -name $software.name
        $progressBar.Value += 1
    }
    
    $progressBar.Visible = $false
    [System.Windows.Forms.MessageBox]::Show("Instalación del software seleccionado completada.", "Instalación Completa", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabBasicSoftware.Controls.Add($installBasicSoftwareButton)

# Crear botones para seleccionar/deseleccionar todo
$selectAllButton = Create-StyledButton -text "Seleccionar Todo" -x 550 -y 100 -width 150 -height 30 -action {
    foreach ($item in $global:allCheckboxes) {
        $item.checkbox.Checked = $true
    }
}
$tabBasicSoftware.Controls.Add($selectAllButton)

$deselectAllButton = Create-StyledButton -text "Deseleccionar Todo" -x 550 -y 140 -width 150 -height 30 -action {
    foreach ($item in $global:allCheckboxes) {
        $item.checkbox.Checked = $false
    }
}
$tabBasicSoftware.Controls.Add($deselectAllButton)

# Crear barra de progreso para instalaciones
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(550, 180)
$progressBar.Size = New-Object System.Drawing.Size(200, 20)
$progressBar.Visible = $false
$tabBasicSoftware.Controls.Add($progressBar)

# Modificar la inicialización de la pestaña de instaladores
$installersList = New-Object System.Windows.Forms.CheckedListBox
$installersList.Location = New-Object System.Drawing.Point(20, 50)
$installersList.Size = New-Object System.Drawing.Size(500, 300)
$tabInstallers.Controls.Add($installersList)

# Botón para refrescar la lista de instaladores
$refreshButton = Create-StyledButton -text "Actualizar Lista" -x 550 -y 50 -width 150 -height 30 -action {
    $instaladores = Initialize-Installers
    if ($instaladores) {
        $installersList.Items.Clear()
        foreach ($instalador in $instaladores) {
            $installersList.Items.Add($instalador.Name)
        }
    }
}
$tabInstallers.Controls.Add($refreshButton)

# Crear botón para seleccionar carpeta de descarga
$downloadFolderLabel = New-Object System.Windows.Forms.Label
$downloadFolderLabel.Text = "Carpeta de Descarga:"
$downloadFolderLabel.Location = New-Object System.Drawing.Point(400, 50)
$downloadFolderLabel.Size = New-Object System.Drawing.Size(100, 20)
$tabInstallers.Controls.Add($downloadFolderLabel)

$downloadFolderTextBox = New-Object System.Windows.Forms.TextBox
$downloadFolderTextBox.Location = New-Object System.Drawing.Point(400, 70)
$downloadFolderTextBox.Size = New-Object System.Drawing.Size(250, 20)
$downloadFolderTextBox.Text = [Environment]::GetFolderPath("Desktop")
$tabInstallers.Controls.Add($downloadFolderTextBox)

$selectFolderButton = Create-StyledButton -text "Examinar..." -x 660 -y 70 -width 100 -height 20 -action {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Seleccionar carpeta de descarga"
    $folderBrowser.SelectedPath = $downloadFolderTextBox.Text
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $downloadFolderTextBox.Text = $folderBrowser.SelectedPath
    }
}
$tabInstallers.Controls.Add($selectFolderButton)

# Crear botón de instalación para instaladores personalizados
$installCustomInstallersButton = Create-StyledButton -text "Instalar Seleccionados" -x 400 -y 100 -action {
    $selectedIndices = $installersList.CheckedIndices
    if ($selectedIndices.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Por favor, seleccione al menos un instalador.", "Sin Selección", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $downloadPath = $downloadFolderTextBox.Text
    if (-not (Test-Path $downloadPath)) {
        [System.Windows.Forms.MessageBox]::Show("La carpeta de destino no existe. Por favor, seleccione una carpeta válida.", "Carpeta Inválida", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    $installersProgressBar.Value = 0
    $installersProgressBar.Maximum = $selectedIndices.Count
    $installersProgressBar.Visible = $true
    
    # Obtener la ruta base del script de manera confiable
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $instaladoresPath = Join-Path -Path $scriptRoot -ChildPath "instaladores"
    $instaladores = Get-ChildItem -Path $instaladoresPath -Filter "*.exe" -ErrorAction SilentlyContinue
    
    foreach ($index in $selectedIndices) {
        $installerName = $installersList.Items[$index].ToString()
        $installer = $instaladores | Where-Object { $_.Name -eq $installerName } | Select-Object -First 1
        
        if ($installer) {
            try {
                # Copiar el archivo al destino
                $destinationPath = Join-Path $downloadPath $installer.Name
                Copy-Item -Path $installer.FullName -Destination $destinationPath -Force
                
                # Intentar instalar el archivo
                if ($installer.Name -like "*Optimizer*.exe") {
                    Start-Process -FilePath $destinationPath -Wait
                } else {
                    Start-Process -FilePath $destinationPath -ArgumentList "/S", "/quiet", "/norestart" -Wait
                }
                
                [System.Windows.Forms.MessageBox]::Show("Instalación de $($installer.Name) completada.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Error al instalar $($installer.Name): $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar el instalador: $installerName", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
        $installersProgressBar.Value += 1
    }
    
    $installersProgressBar.Visible = $false
    [System.Windows.Forms.MessageBox]::Show("Proceso de instalación completado.", "Instalación Completa", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabInstallers.Controls.Add($installCustomInstallersButton)

# Crear barra de progreso para instaladores personalizados
$installersProgressBar = New-Object System.Windows.Forms.ProgressBar
$installersProgressBar.Location = New-Object System.Drawing.Point(400, 150)
$installersProgressBar.Size = New-Object System.Drawing.Size(200, 20)
$installersProgressBar.Visible = $false
$tabInstallers.Controls.Add($installersProgressBar)

# Poblar pestaña de Activaciones y Optimizaciones
$activationsLabel = New-Object System.Windows.Forms.Label
$activationsLabel.Text = "Activaciones y Optimizaciones del Sistema:"
$activationsLabel.Location = New-Object System.Drawing.Point(20, 20)
$activationsLabel.Size = New-Object System.Drawing.Size(300, 20)
$tabActivations.Controls.Add($activationsLabel)

# Crear botones de activación
$activateButton = Create-StyledButton -text "Activar Windows y Office" -x 50 -y 50 -width 200 -height 40 -action {
    Activate-WindowsAndOffice
}
$tabActivations.Controls.Add($activateButton)

$activatedWinButton = Create-StyledButton -text "Ejecutar Script Activated.Win" -x 20 -y 100 -action {
    Run-ActivatedWin
    [System.Windows.Forms.MessageBox]::Show("Script de Activated.Win ejecutado.", "Ejecución de Script", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($activatedWinButton)

$chrisTitusButton = Create-StyledButton -text "Ejecutar Script de Chris Titus" -x 20 -y 150 -action {
    Run-ChrisTitusScript
    [System.Windows.Forms.MessageBox]::Show("Script de Chris Titus ejecutado.", "Ejecución de Script", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($chrisTitusButton)

# Crear botones de optimización
$optimizeNetworkButton = Create-StyledButton -text "Optimizar Red" -x 250 -y 50 -action {
    Optimize-Network
    [System.Windows.Forms.MessageBox]::Show("Optimización de red completada.", "Optimización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($optimizeNetworkButton)

$optimizeSystemButton = Create-StyledButton -text "Optimizar Sistema" -x 250 -y 100 -action {
    Optimize-System
    [System.Windows.Forms.MessageBox]::Show("Optimización del sistema completada.", "Optimización", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($optimizeSystemButton)

$cleanTempButton = Create-StyledButton -text "Limpiar Archivos Temporales" -x 250 -y 150 -action {
    Clean-TempFiles
    [System.Windows.Forms.MessageBox]::Show("Archivos temporales limpiados.", "Limpieza", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($cleanTempButton)

$createRestorePointButton = Create-StyledButton -text "Crear Punto de Restauración" -x 250 -y 200 -action {
    Create-RestorePoint
    [System.Windows.Forms.MessageBox]::Show("Punto de restauración creado.", "Protección del Sistema", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
$tabActivations.Controls.Add($createRestorePointButton)

# Mostrar el formulario
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()

# Eliminar la lista antigua de software y la lista de verificación
$basicSoftwareChecklist.Items.Clear()
$basicSoftwareChecklist.Dispose()

# Limpiar los controles existentes en la pestaña de software básico
$tabBasicSoftware.Controls.Clear()

# Crear los nuevos botones organizados por categoría
Create-SoftwareButtons



# Llamar a la función para crear los botones después de crear el formulario
Create-SoftwareButtons

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls.Add($createRestorePointButton)

$tabActivations.Controls