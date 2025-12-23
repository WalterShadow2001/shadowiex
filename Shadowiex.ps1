<#
.SYNOPSIS
    Shadowiex - Professional Edition (GitHub / Web Ready)
.DESCRIPTION
    Versión optimizada para ejecución vía "irm | iex". 
    Corrección de fuentes mediante variable separada para máxima compatibilidad.
.NOTES
    Autor: WalterShadow2001
    Versión: 6.0 - Web Safe
#>

# --- CONFIGURACIÓN INICIAL ---
 $ErrorActionPreference = "Stop"
 $ProgressPreference = 'SilentlyContinue'
 $script:UIControls = @{}

# Funciones de Verificación (Definidas PRIMERO)
function Test-Winget { 
    try { $null = winget --version; return $true } 
    catch { return $false } 
}

function Test-Chocolatey { 
    try { $null = choco --version; return $true } 
    catch { return $false } 
}

# Colores
 $colors = @{
    Background  = [System.Drawing.Color]::FromArgb(30, 30, 40)
    Panel       = [System.Drawing.Color]::FromArgb(45, 45, 55)
    Accent      = [System.Drawing.Color]::FromArgb(0, 120, 215)
    AccentHover = [System.Drawing.Color]::FromArgb(0, 90, 180)
    Text        = [System.Drawing.Color]::White
    TextSub     = [System.Drawing.Color]::FromArgb(180, 180, 180)
    Success     = [System.Drawing.Color]::FromArgb(16, 185, 129)
    Warning     = [System.Drawing.Color]::FromArgb(245, 159, 0)
    Danger      = [System.Drawing.Color]::FromArgb(239, 68, 68)
}

# Estilos de Fuente (Variables separadas para evitar errores de Parser al ejecutar desde web)
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

# --- FORMULARIO ---
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "Shadowiex - Professional Edition"
 $form.Size = New-Object System.Drawing.Size(960, 660)
 $form.StartPosition = "CenterScreen"
 $form.BackColor = $colors.Background
 $form.ForeColor = $colors.Text
 $form.MinimumSize = New-Object System.Drawing.Size(960, 660)

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
        $pictureBox.Size = New-Object System.Drawing.Size(50, 50)
        $pictureBox.Location = New-Object System.Drawing.Point(20, 15)
        $pictureBox.BackColor = [System.Drawing.Color]::Transparent
        $form.Controls.Add($pictureBox)
        
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Shadowiex Professional"
        $titleLabel.Location = New-Object System.Drawing.Point(80, 25)
        $titleLabel.Size = New-Object System.Drawing.Size(300, 35)
        # Uso de variable de estilo
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, $styleBold)
        $titleLabel.ForeColor = $colors.Text
        $form.Controls.Add($titleLabel)
    }
}
catch {}

# Footer
 $footerLabel = New-Object System.Windows.Forms.Label
 $footerLabel.Text = "CREADO POR WDPN"
 $footerLabel.Location = New-Object System.Drawing.Point(20, 600)
 $footerLabel.Size = New-Object System.Drawing.Size(250, 30)
 $footerLabel.ForeColor = $colors.TextSub
 $footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleItalic)
 $form.Controls.Add($footerLabel)

# --- PESTAÑAS ---
 $tabControl = New-Object System.Windows.Forms.TabControl
 $tabControl.Location = New-Object System.Drawing.Point(0, 80)
 $tabControl.Size = New-Object System.Drawing.Size(944, 510)
 $tabControl.BackColor = $colors.Background
 $tabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons
 $tabControl.ItemSize = New-Object System.Drawing.Size(150, 40)
 $tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10.5, $styleBold)
 $tabControl.Padding = New-Object System.Drawing.Point(10, 5)

 $tabBasicSoftware = New-Object System.Windows.Forms.TabPage
 $tabBasicSoftware.Text = "Software Básico"
 $tabBasicSoftware.BackColor = $colors.Background
 $tabBasicSoftware.Padding = New-Object System.Windows.Forms.Padding(15)

 $tabInstallers = New-Object System.Windows.Forms.TabPage
 $tabInstallers.Text = "Instaladores"
 $tabInstallers.BackColor = $colors.Background
 $tabInstallers.Padding = New-Object System.Windows.Forms.Padding(15)

 $tabActivations = New-Object System.Windows.Forms.TabPage
 $tabActivations.Text = "Activaciones"
 $tabActivations.BackColor = $colors.Background
 $tabActivations.Padding = New-Object System.Windows.Forms.Padding(15)

 $tabSettings = New-Object System.Windows.Forms.TabPage
 $tabSettings.Text = "Configuración"
 $tabSettings.BackColor = $colors.Background
 $tabSettings.Padding = New-Object System.Windows.Forms.Padding(15)

 $tabControl.Controls.Add($tabBasicSoftware)
 $tabControl.Controls.Add($tabInstallers)
 $tabControl.Controls.Add($tabActivations)
 $tabControl.Controls.Add($tabSettings)
 $form.Controls.Add($tabControl)

# --- FUNCIONES UI HELPER ---

function Create-ModernButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 190,
        [int]$height = 45,
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
    # Uso de variable de estilo (Bold)
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleBold)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.FlatAppearance.BorderSize = 0
    
    if ($null -eq $backColor) {
        $button.FlatAppearance.MouseOverBackColor = $colors.AccentHover
    } else {
        $r = [Math]::Max(0, $backColor.R - 20)
        $g = [Math]::Max(0, $backColor.G - 20)
        $b = [Math]::Max(0, $backColor.B - 20)
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
        [bool]$isTitle = $false
    )
    
    $labelHeight = 25
    if ($isTitle) { $labelHeight = 35 }
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($width, $labelHeight)
    $label.ForeColor = $colors.Text
    
    if ($isTitle) {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 13, $styleBold)
    } else {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleRegular)
    }
    return $label
}

# --- LÓGICA DE INSTALACIÓN ---

function Install-Winget {
    try {
        $uri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $out = "$env:TEMP\Winget.msixbundle"
        Invoke-WebRequest -Uri $uri -OutFile $out
        Add-AppxPackage -Path $out
        return $true
    } catch { return $false }
}

function Install-Chocolatey {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        return $true
    } catch { return $false }
}

function Install-Software {
    param ([string]$id, [string]$name, [System.Windows.Forms.ProgressBar]$bar, [System.Windows.Forms.Label]$lbl)
    if (-not $bar -or -not $lbl) { return }
    $lbl.Text = "Instalando: $name..."
    $bar.Value = 10
    
    $success = $false
    
    $hasWinget = Test-Winget
    $hasChoco = Test-Chocolatey

    if ($hasWinget) {
        $proc = Start-Process "winget" -ArgumentList "install", "--id", $id, "--accept-source-agreements", "--accept-package-agreements", "-h" -NoNewWindow -PassThru -Wait
        if ($proc.ExitCode -eq 0) { $success = $true }
    }
    
    if ($success -eq $false) {
        if ($hasChoco) {
            $cid = $id.Split('.')[-1].ToLower()
            $proc = Start-Process "choco" -ArgumentList "install", $cid, "-y" -NoNewWindow -PassThru -Wait
            if ($proc.ExitCode -eq 0) { $success = $true }
        }
    }
    
    if ($success) {
        $lbl.Text = "Completado: $name"
        $bar.Value = 100
    } else {
        $lbl.Text = "Error: $name"
    }
}

function Download-And-Install {
    param ($url, $name, $dest, $bar, $lbl)
    $file = Join-Path $dest $name
    try {
        Copy-Item -Path $url -Destination $file -Force
        $p = Start-Process $file -ArgumentList "/S", "/quiet" -PassThru
        $p.WaitForExit()
        $lbl.Text = "Completado: $name"
        $bar.Value = 100
    } catch { $lbl.Text = "Error: $name" }
}

function Activate-WindowsAndOffice {
    try {
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $scr = Join-Path $root "TSforge_Activation.cmd"
        if (-not (Test-Path $scr)) {
            Invoke-WebRequest "https://github.com/WalterShadow2001/shadowiex/raw/main/TSforge_Activation.cmd" -OutFile $scr
        }
        $tmp = "$env:TEMP\act.cmd"
        "@echo off`nset _actwin=1`nset _actoff=1`ncall `"$scr`"" | Out-File $tmp -Encoding ASCII
        Start-Process "cmd.exe" -ArgumentList "/c", $tmp -Wait -NoNewWindow
        [System.Windows.Forms.MessageBox]::Show("Proceso finalizado.", "Shadowiex", 0, 64)
    } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error", 0, 16) }
}

function Initialize-Installers {
    $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    $dir = Join-Path $root "instaladores"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $dir) { return Get-ChildItem $dir -Filter "*.exe" }
    return @()
}

function Download-InstallersFromGitHub {
    param ($dest)
    try {
        $url = "https://github.com/WalterShadow2001/shadowiex/archive/refs/heads/main.zip"
        $zip = "$env:TEMP\shadowiex.zip"
        $ext = "$env:TEMP\shadowiex_ext"
        Invoke-WebRequest $url -OutFile $zip
        if (Test-Path $ext) { Remove-Item $ext -Recurse -Force }
        Expand-Archive $zip $ext -Force
        $src = Join-Path $ext "shadowiex-main\instaladores"
        if (Test-Path $src) { Copy-Item "$src\*.exe" $dest -Force }
        Remove-Item $zip, $ext -Recurse -Force
        [System.Windows.Forms.MessageBox]::Show("Instaladores descargados.", "Éxito", 0, 64)
    } catch { [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Error", 0, 16) }
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
    
    $pnl = New-Object System.Windows.Forms.Panel
    $pnl.AutoScroll = $true
    $pnl.Location = New-Object System.Drawing.Point(15, 50)
    $pnl.Size = New-Object System.Drawing.Size(870, 360)
    $pnl.BackColor = $colors.Panel
    $pnl.Padding = New-Object System.Windows.Forms.Padding(10)
    $tabBasicSoftware.Controls.Add($pnl)

    $global:allCheckboxes = @()
    $y = 10
    $font = New-Object System.Drawing.Font("Segoe UI", 10, $styleRegular)

    foreach ($cat in $softwareCategories.Keys) {
        $lbl = Create-ModernLabel -text $cat -x 10 -y $y -isTitle $true
        $pnl.Controls.Add($lbl)
        $y += 45
        foreach ($sw in $softwareCategories[$cat]) {
            $cb = New-Object System.Windows.Forms.CheckBox
            $cb.Text = "$($sw.i)  $($sw.n)"
            $cb.Location = New-Object System.Drawing.Point(20, $y)
            $cb.Size = New-Object System.Drawing.Size(500, 30)
            $cb.Font = $font
            $cb.ForeColor = $colors.Text
            $cb.BackColor = $colors.Panel
            $cb.Padding = New-Object System.Windows.Forms.Padding(5)
            $pnl.Controls.Add($cb)
            $global:allCheckboxes += @{cb=$cb; id=$sw.id; n=$sw.n}
            $y += 35
        }
        $y += 20
    }

    $btnInstall = Create-ModernButton -text "Instalar Selección" -x 15 -y 425 -width 220 -action {
        $sel = $global:allCheckboxes | Where-Object { $_.cb.Checked }
        if ($sel.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Seleccione software.", "Info", 0, 48); return }
        
        $wg = Test-Winget; $ch = Test-Chocolatey
        if (-not $wg -and -not $ch) { 
            if (-not (Install-Winget)) { Install-Chocolatey }
        }
        
        $pf = New-Object System.Windows.Forms.Form
        $pf.Text = "Instalando..."
        $pf.Size = New-Object System.Drawing.Size(450, 130)
        $pf.BackColor = $colors.Background
        $pf.StartPosition = "CenterParent"
        $pf.FormBorderStyle = "FixedDialog"
        $l = Create-ModernLabel -text "Iniciando..." -x 20 -y 20
        $b = New-Object System.Windows.Forms.ProgressBar; $b.Location = "20, 50"; $b.Width = 390
        $pf.Controls.AddRange(@($l, $b))
        $pf.Show()

        foreach ($s in $sel) { 
            $pf.Refresh()
            Install-Software -id $s.id -name $s.n -bar $b -lbl $l 
        }
        $pf.Close()
        [System.Windows.Forms.MessageBox]::Show("Instalación finalizada.", "Shadowiex", 0, 64)
    }
    $tabBasicSoftware.Controls.Add($btnInstall)
    
    $btnSelAll = Create-ModernButton -text "Seleccionar Todo" -x 255 -y 425 -width 160 -backColor $colors.Panel -action {
        foreach($i in $global:allCheckboxes){ $i.cb.Checked = $true }
    }
    $tabBasicSoftware.Controls.Add($btnSelAll)
    
    $btnDesel = Create-ModernButton -text "Deseleccionar" -x 425 -y 425 -width 160 -backColor $colors.Panel -action {
        foreach($i in $global:allCheckboxes){ $i.cb.Checked = $false }
    }
    $tabBasicSoftware.Controls.Add($btnDesel)
}

function Populate-InstallersTab {
    $tabInstallers.Controls.Clear()
    $lblTitle = Create-ModernLabel -text "Gestor de Instaladores Personalizados" -x 15 -y 10 -isTitle $true
    $tabInstallers.Controls.Add($lblTitle)

    $list = New-Object System.Windows.Forms.ListBox
    $list.Location = "15, 60"
    $list.Size = "600, 320"
    $list.BackColor = $colors.Panel
    $list.ForeColor = $colors.Text
    $list.Font = New-Object System.Drawing.Font("Segoe UI", 10, $styleRegular)
    $list.HorizontalScrollbar = $true
    $tabInstallers.Controls.Add($list)
    $script:UIControls['List'] = $list

    $refreshAction = {
        $l = $script:UIControls['List']; 
        if($l){ 
            $l.Items.Clear()
            foreach($f in Initialize-Installers){ $l.Items.Add($f.Name) }
        }
    }

    $btnRefresh = Create-ModernButton -text "Actualizar Lista" -x 630 -y 60 -width 160 -action $refreshAction
    $tabInstallers.Controls.Add($btnRefresh)

    $btnDl = Create-ModernButton -text "Descargar de GitHub" -x 630 -y 115 -width 160 -action {
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        Download-InstallersFromGitHub -dest $root
        Start-Sleep -Seconds 1
        & $refreshAction
    }
    $tabInstallers.Controls.Add($btnDl)
    
    $btnInstall = Create-ModernButton -text "Instalar Seleccionado" -x 15 -y 400 -width 200 -action {
        $l = $script:UIControls['List']
        if($l.SelectedIndex -eq -1) { [System.Windows.Forms.MessageBox]::Show("Seleccione uno.", "Info", 0, 48); return }
        
        $itemName = $l.SelectedItem
        $root = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
        $file = Join-Path (Join-Path $root "instaladores") $itemName
        
        if (Test-Path $file) {
            Start-Process $file -ArgumentList "/S" -Wait
            [System.Windows.Forms.MessageBox]::Show("Instalador ejecutado.", "Listo", 0, 64)
        } else {
            [System.Windows.Forms.MessageBox]::Show("Archivo no encontrado.", "Error", 0, 16)
        }
    }
    $tabInstallers.Controls.Add($btnInstall)
}

function Populate-ActivationsTab {
    $tabActivations.Controls.Clear()
    
    $btnAct = Create-ModernButton -text "Activar Windows y Office" -x 20 -y 60 -width 240 -backColor $colors.Success -action { Activate-WindowsAndOffice }
    $tabActivations.Controls.Add($btnAct)

    $btnWin = Create-ModernButton -text "Script Activated.Win" -x 280 -y 60 -width 240 -action {
        try { iex(iwr "https://get.activated.win") } catch { [System.Windows.Forms.MessageBox]::Show("Error.", "Err", 0, 16) }
    }
    $tabActivations.Controls.Add($btnWin)

    $btnTitus = Create-ModernButton -text "WinUtil (Chris Titus)" -x 540 -y 60 -width 240 -action {
        try { iwr -useb "https://christitus.com/win" | iex } catch { [System.Windows.Forms.MessageBox]::Show("Error.", "Err", 0, 16) }
    }
    $tabActivations.Controls.Add($btnTitus)
    
    $lblOpt = Create-ModernLabel -text "Optimización del Sistema" -x 20 -y 140 -isTitle $true
    $tabActivations.Controls.Add($lblOpt)
    
    $btnNet = Create-ModernButton -text "Optimizar Red" -x 20 -y 190 -width 180 -action {
        netsh int ip reset; netsh winsock reset; ipconfig /flushdns; [System.Windows.Forms.MessageBox]::Show("Red optimizada.", "Listo", 0, 64)
    }
    $tabActivations.Controls.Add($btnNet)
    
    $btnSys = Create-ModernButton -text "Optimizar Servicios" -x 220 -y 190 -width 180 -action {
        $srv = "DiagTrack","dmwappushservice","MapsBroker","SharedAccess"
        foreach($s in $srv){ Set-Service $s -StartupType Disabled -EA SilentlyContinue; Stop-Service $s -Force -EA SilentlyContinue }
        [System.Windows.Forms.MessageBox]::Show("Servicios optimizados.", "Listo", 0, 64)
    }
    $tabActivations.Controls.Add($btnSys)
    
    $btnClean = Create-ModernButton -text "Limpiar Temporales" -x 420 -y 190 -width 180 -backColor $colors.Warning -action {
        Remove-Item "$env:TEMP\*" -Recurse -Force -EA SilentlyContinue
        Remove-Item "$env:windir\Temp\*" -Recurse -Force -EA SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show("Temporales limpiados.", "Listo", 0, 64)
    }
    $tabActivations.Controls.Add($btnClean)
}

function Populate-SettingsTab {
    $tabSettings.Controls.Clear()
    $lbl = Create-ModernLabel -text "Configuración" -x 20 -y 20 -isTitle $true
    $tabSettings.Controls.Add($lbl)
    
    $sw = Test-Winget; $sc = Test-Chocolatey
    $statusW = if($sw){"Instalado"}else{"No encontrado"}
    $statusC = if($sc){"Instalado"}else{"No encontrado"}
    
    $tabSettings.Controls.Add((Create-ModernLabel -text "Winget: $statusW" -x 20 -y 80))
    $tabSettings.Controls.Add((Create-ModernLabel -text "Chocolatey: $statusC" -x 20 -y 120))

    $btnUp = Create-ModernButton -text "Actualizar Script" -x 20 -y 180 -width 220 -action {
        try {
            $u = "https://github.com/WalterShadow2001/shadowiex/raw/main/Shadowiex.ps1"
            $t = "$env:TEMP\Shadowiex.ps1"
            Invoke-WebRequest -Uri $u -OutFile $t
            Copy-Item $t $PSCommandPath -Force
            [System.Windows.Forms.MessageBox]::Show("Actualizado. Reinicie.", "Info", 0, 64)
            $form.Close()
        } catch { [System.Windows.Forms.MessageBox]::Show("Error actualizando.", "Err", 0, 16) }
    }
    $tabSettings.Controls.Add($btnUp)
}

Populate-SoftwareTab
Populate-InstallersTab
Populate-ActivationsTab
Populate-SettingsTab

[void]$form.ShowDialog()
