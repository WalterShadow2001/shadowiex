<#
.SYNOPSIS
    Shadowiex - Professional Edition (Rediseño UI Moderno)
.DESCRIPTION
    Herramienta de configuración con interfaz moderna estilo "Dark Glass", optimizada para legibilidad y experiencia de usuario.
.NOTES
    Autor: WalterShadow2001
    Versión: 4.0 - Modern UI
#>

# --- CONFIGURACIÓN INICIAL Y TEMAS ---
 $ErrorActionPreference = "Stop"
 $ProgressPreference = 'SilentlyContinue'
 $script:UIControls = @{}

# Paleta de Colores "Shadow Modern"
 $colors = @{
    Background  = [System.Drawing.Color]::FromArgb(30, 30, 40)       # Fondo oscuro profundo
    Panel       = [System.Drawing.Color]::FromArgb(45, 45, 55)       # Paneles secundarios
    Accent      = [System.Drawing.Color]::FromArgb(0, 120, 215)      # Azul brillante (Acción)
    AccentHover = [System.Drawing.Color]::FromArgb(0, 90, 180)       # Azul oscuro (Hover)
    Text        = [System.Drawing.Color]::White
    TextSub     = [System.Drawing.Color]::FromArgb(180, 180, 180)
    Success     = [System.Drawing.Color]::FromArgb(13, 188, 121)      # Verde
    Danger      = [System.Drawing.Color]::FromArgb(235, 77, 75)       # Rojo
}

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

# Cargar Ensamblados
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation

# --- FORMULARIO PRINCIPAL ---
 $form = New-Object System.Windows.Forms.Form
 $form.Text = "Shadowiex - Professional Edition"
 $form.Size = New-Object System.Drawing.Size(950, 650)
 $form.StartPosition = "CenterScreen"
 $form.BackColor = $colors.Background
 $form.ForeColor = $colors.Text
 $form.MinimumSize = New-Object System.Drawing.Size(950, 650)

# --- CARGA DE LOGO E ICONO ---
try {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    
    # Cargar Icono de la Ventana
    $iconPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.ico"
    if (Test-Path -Path $iconPath) {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
    }

    # Cargar Logo (PictureBox) más grande y centrado en el header
    $logoPath = Join-Path -Path $scriptRoot -ChildPath "SHADOWIEX_LOGO.png"
    if (Test-Path -Path $logoPath) {
        $logoImage = [System.Drawing.Image]::FromFile($logoPath)
        $pictureBox = New-Object System.Windows.Forms.PictureBox
        $pictureBox.Image = $logoImage
        $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom # Ajustar imagen
        $pictureBox.Size = New-Object System.Drawing.Size(48, 48) # Más grande
        $pictureBox.Location = New-Object System.Drawing.Point(15, 15)
        $pictureBox.BackColor = [System.Drawing.Color]::Transparent
        $form.Controls.Add($pictureBox)
        
        # Título junto al logo
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Shadowiex Professional"
        $titleLabel.Location = New-Object System.Drawing.Point(75, 25)
        $titleLabel.Size = New-Object System.Drawing.Size(300, 30)
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = $colors.Text
        $form.Controls.Add($titleLabel)
    }
}
catch {
    Write-Warning "No se pudo cargar el logo/icono. Asegúrese de que SHADOWIEX_LOGO.png y .ico estén en la carpeta del script."
}

# --- FOOTER (CREADO POR WDPN) ---
# Posicionado a la izquierda para asegurar visibilidad y estilo
 $footerLabel = New-Object System.Windows.Forms.Label
 $footerLabel.Text = "CREADO POR WDPN"
 $footerLabel.Location = New-Object System.Drawing.Point(15, 590)
 $footerLabel.Size = New-Object System.Drawing.Size(200, 30)
 $footerLabel.ForeColor = $colors.TextSub
 $footerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
 $form.Controls.Add($footerLabel)

# --- CONTROL DE PESTAÑAS (TAB CONTROL) ---
 $tabControl = New-Object System.Windows.Forms.TabControl
 $tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
 $tabControl.BackColor = $colors.Background
 $tabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons # Estilo Botón
 $tabControl.ItemSize = New-Object System.Drawing.Size(140, 35) # Pestañas más grandes y cómodas
 $tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
 $tabControl.Padding = New-Object System.Drawing.Point(10, 5)

# Definir Pestañas
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

# --- FUNCIONES UI HELPER ---

function Create-ModernButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 180, # Ancho predeterminado más amplio
        [int]$height = 40,  # Alto más cómodo para click
        [scriptblock]$action,
        [System.Drawing.Color]$backColor = $null
    )
    
    $btnColor = if ($null -eq $backColor) { $colors.Accent } else { $backColor }
    
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Text = $text
    $button.BackColor = $btnColor
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Semibold)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    # Efecto Plano
    $button.FlatAppearance.BorderSize = 0
    $button.FlatAppearance.MouseOverBackColor = if($backColor) { 
        # Si es un color especial (Rojo/Verde), oscurecerlo manualmente
        [System.Drawing.Color]::FromArgb($backColor.R - 20, $backColor.G - 20, $backColor.B - 20)
    } else { 
        $colors.AccentHover 
    }
    
    $button.Add_Click($action)
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
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($width, if($isTitle){30}else{20})
    $label.ForeColor = $colors.Text
    
    if ($isTitle) {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    } else {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    }
    return $label
}

# --- LÓGICA DE SOFTWARE E INSTALACIÓN ---
# (Mantiene la lógica robusta anterior)

function Test-Winget { try { $null = winget --version; return $true } catch { return $false } }
function Test-Chocolatey { try { $null = choco --version; return $true } catch { return $false } }

function Install-Winget {
    try {
        $uri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $out = "$env:TEMP\Winget.msixbundle"
        Invoke-WebRequest -Uri $uri -OutFile $out
        Add-AppxPackage -Path $out
    } catch {}
}

function Install-Chocolatey {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } catch {}
}

function Install-Software {
    param ([string]$id, [string]$name, [System.Windows.Forms.ProgressBar]$bar, [System.Windows.Forms.Label]$lbl)
    if (-not $bar -or -not $lbl) { return }
    $lbl.Text = "Instalando: $name..."
    $bar.Value = 10
    if (Test-Winget) {
        $proc = Start-Process "winget" -ArgumentList "install", "--id", $id, "--accept-source-agreements", "--accept-package-agreements", "-h" -NoNewWindow -PassThru -Wait
        if ($proc.ExitCode -eq 0) { $lbl.Text = "Completado: $name"; $bar.Value = 100; return }
    }
    if (Test-Chocolatey) {
        $cid = $id.Split('.')[-1].ToLower()
        $proc = Start-Process "choco" -ArgumentList "install", $cid, "-y" -NoNewWindow -PassThru -Wait
        if ($proc.ExitCode -eq 0) { $lbl.Text = "Completado: $name"; $bar.Value = 100; return }
    }
    $lbl.Text = "Falló: $name"
}

function Download-And-Install {
    param ($url, $name, $dest, $bar, $lbl)
    $file = Join-Path $dest $name
    try {
        Copy-Item -Path $url -Destination $file -Force
        $p = Start-Process $file -ArgumentList "/S", "/quiet" -PassThru
        $p.WaitForExit()
        $lbl.Text = "Completado: $name"
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
        [System.Windows.Forms.MessageBox]::Show("Proceso de activación finalizado.", "Shadowiex", 0, 64)
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
    "Navegadores" = @(@{id="Google.Chrome";n="Google Chrome";i="🌐"}, @{id="Mozilla.Firefox";n="Firefox";i="🦊"})
    "Utilidades"   = @(@{id="7zip.7zip";n="7-Zip";i="🗜️"}, @{id="Notepad++.Notepad++";n="Notepad++";i="📝"})
    "Desarrollo"   = @(@{id="Git.Git";n="Git";i="📁"}, @{id="Microsoft.VisualStudioCode";n="VS Code";i="🔧"})
    # Añade más categorías aquí...
}

# --- POBLAR TABS ---

function Populate-SoftwareTab {
    $tabBasicSoftware.Controls.Clear()
    
    # Panel Scroll
    $pnl = New-Object System.Windows.Forms.Panel
    $pnl.AutoScroll = $true
    $pnl.Location = New-Object System.Drawing.Point(10, 50)
    $pnl.Size = New-Object System.Drawing.Size(880, 400)
    $pnl.BackColor = $colors.Panel
    $tabBasicSoftware.Controls.Add($pnl)

    $global:allCheckboxes = @()
    $y = 15
    $font = New-Object System.Drawing.Font("Segoe UI", 9.5)

    foreach ($cat in $softwareCategories.Keys) {
        $lbl = Create-ModernLabel -text $cat -x 10 -y $y -isTitle $true
        $pnl.Controls.Add($lbl)
        $y += 35
        foreach ($sw in $softwareCategories[$cat]) {
            $cb = New-Object System.Windows.Forms.CheckBox
            $cb.Text = "$($sw.i) $($sw.n)"
            $cb.Location = New-Object System.Drawing.Point(20, $y)
            $cb.Size = New-Object System.Drawing.Size(400, 25)
            $cb.Font = $font
            $cb.ForeColor = $colors.Text
            $cb.BackColor = $colors.Panel
            $pnl.Controls.Add($cb)
            $global:allCheckboxes += @{cb=$cb; id=$sw.id; n=$sw.n}
            $y += 30
        }
        $y += 15
    }

    # Botón Instalar
    $btnInstall = Create-ModernButton -text "Instalar Selección" -x 10 -y 470 -width 200 -action {
        $sel = $global:allCheckboxes | Where-Object { $_.cb.Checked }
        if ($sel.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Selecciona algo.", "Info", 0, 48); return }
        if (-not (Test-Winget)) { Install-Winget }
        
        # Progreso
        $pf = New-Object System.Windows.Forms.Form
        $pf.Text = "Instalando..."
        $pf.Size = New-Object System.Drawing.Size(400, 120)
        $pf.BackColor = $colors.Background
        $pf.StartPosition = "CenterParent"
        $pf.FormBorderStyle = "FixedDialog"
        $l = Create-ModernLabel -text "Iniciando..." -x 20 -y 20
        $b = New-Object System.Windows.Forms.ProgressBar; $b.Location = "20, 50"; $b.Width = 350
        $pf.Controls.AddRange(@($l, $b))
        $pf.Show()

        foreach ($s in $sel) { Install-Software -id $s.id -name $s.n -bar $b -lbl $l }
        $pf.Close()
        [System.Windows.Forms.MessageBox]::Show("Fin.", "Shadowiex", 0, 64)
    }
    $tabBasicSoftware.Controls.Add($btnInstall)
    
    $btnSelAll = Create-ModernButton -text "Seleccionar Todo" -x 230 -y 470 -width 150 -backColor $colors.Panel -action {
        foreach($i in $global:allCheckboxes){ $i.cb.Checked = $true }
    }
    $tabBasicSoftware.Controls.Add($btnSelAll)
}

function Populate-InstallersTab {
    $tabInstallers.Controls.Clear()
    $lblTitle = Create-ModernLabel -text "Gestor de Instaladores Offline" -x 10 -y 10 -isTitle $true
    $tabInstallers.Controls.Add($lblTitle)

    $list = New-Object System.Windows.Forms.ListBox
    $list.Location = "10, 50"
    $list.Size = "600, 300"
    $list.BackColor = $colors.Panel
    $list.ForeColor = $colors.Text
    $list.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $tabInstallers.Controls.Add($list)
    $script:UIControls['List'] = $list

    $btnRefresh = Create-ModernButton -text "Actualizar Lista" -x 630 -y 50 -width 150 -action {
        $l = $script:UIControls['List']; $l.Items.Clear()
        foreach($f in Initialize-Installers){ $l.Items.Add($f.Name) }
    }
    $tabInstallers.Controls.Add($btnRefresh)

    $btnDl = Create-ModernButton -text "Descargar de GitHub" -x 630 -y 100 -width 150 -action {
        Download-InstallersFromGitHub -dest (if($PSScriptRoot){$PSScriptRoot}else{$PWD.Path})
        Start-Sleep 1; & $btnRefresh.PerformClick() # Trick to refresh
        $l = $script:UIControls['List']; $l.Items.Clear()
        foreach($f in Initialize-Installers){ $l.Items.Add($f.Name) }
    }
    $tabInstallers.Controls.Add($btnDl)
}

function Populate-ActivationsTab {
    $tabActivations.Controls.Clear()
    
    # Grid Layout Buttons
    $btnAct = Create-ModernButton -text "Activar Windows y Office" -x 20 -y 50 -width 220 -action { Activate-WindowsAndOffice }
    $tabActivations.Controls.Add($btnAct)

    $btnWin = Create-ModernButton -text "Script Activated.Win" -x 260 -y 50 -width 220 -action {
        try { iex(iwr "https://get.activated.win") } catch { [System.Windows.Forms.MessageBox]::Show("Error", "Err", 0, 16) }
    }
    $tabActivations.Controls.Add($btnWin)

    $btnTitus = Create-ModernButton -text "Script Chris Titus" -x 500 -y 50 -width 220 -action {
        try { iex(iwr "https://christitus.com/win") } catch { [System.Windows.Forms.MessageBox]::Show("Error", "Err", 0, 16) }
    }
    $tabActivations.Controls.Add($btnTitus)

    $lblInfo = Create-ModernLabel -text "Sistema optimizado." -x 20 -y 150 -width 800 -isTitle $false
    $tabActivations.Controls.Add($lblInfo)
}

function Populate-SettingsTab {
    $tabSettings.Controls.Clear()
    $lbl = Create-ModernLabel -text "Preferencias del Sistema" -x 10 -y 10 -isTitle $true
    $tabSettings.Controls.Add($lbl)
    
    $lblWg = Create-ModernLabel -text "Winget: $(if(Test-Winget){'Instalado'}else{'No instalado'})" -x 20 -y 60
    $tabSettings.Controls.Add($lblWg)

    $btnUp = Create-ModernButton -text "Actualizar Script" -x 20 -y 120 -width 200 -action {
        try {
            $u = "https://github.com/WalterShadow2001/shadowiex/raw/main/Shadowiex.ps1"
            $t = "$env:TEMP\Shadowiex.ps1"
            iwr $u -OutFile $t
            Copy-Item $t $PSCommandPath -Force
            [System.Windows.Forms.MessageBox]::Show("Actualizado. Reinicia.", "Info", 0, 64)
            $form.Close()
        } catch { [System.Windows.Forms.MessageBox]::Show("Error", "Err", 0, 16) }
    }
    $tabSettings.Controls.Add($btnUp)
}

# --- INIT ---
Populate-SoftwareTab
Populate-InstallersTab
Populate-ActivationsTab
Populate-SettingsTab

# Fix para el botón de refresco en Installers (referencia tardía)
 $tabInstallers.Controls[2].Add_Click({
    $l = $script:UIControls['List']; $l.Items.Clear()
    foreach($f in Initialize-Installers){ $l.Items.Add($f.Name) }
}).GetNewClosure()

[void]$form.ShowDialog()
