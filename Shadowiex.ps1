<#
.SYNOPSIS
    SHADOWIEX v11.0 - Professional Edition
.DESCRIPTION
    Herramienta profesional de instalacion y activacion.
    Funciona correctamente desde web: irm n9.cl/shadowiex | iex
.NOTES
    Autor: WDPN (WalterShadow2001)
#>

# Verificar admin
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

# ============================================
# TEMA SHADOWIEX
# ============================================
$Global:Theme = @{
    BG          = [System.Drawing.Color]::FromArgb(18, 18, 24)
    Surface     = [System.Drawing.Color]::FromArgb(30, 30, 42)
    SurfaceLight= [System.Drawing.Color]::FromArgb(42, 42, 58)
    Primary     = [System.Drawing.Color]::FromArgb(139, 92, 246)
    PrimaryHover= [System.Drawing.Color]::FromArgb(167, 139, 250)
    Secondary   = [System.Drawing.Color]::FromArgb(20, 184, 166)
    Accent      = [System.Drawing.Color]::FromArgb(236, 72, 153)
    Success     = [System.Drawing.Color]::FromArgb(34, 197, 94)
    Warning     = [System.Drawing.Color]::FromArgb(251, 191, 36)
    Danger      = [System.Drawing.Color]::FromArgb(239, 68, 68)
    TextMain    = [System.Drawing.Color]::White
    TextMuted   = [System.Drawing.Color]::FromArgb(156, 163, 175)
    Border      = [System.Drawing.Color]::FromArgb(55, 65, 81)
}

$Global:Fonts = @{
    Title   = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
    Header  = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    Normal  = New-Object System.Drawing.Font("Segoe UI", 10)
    Small   = New-Object System.Drawing.Font("Segoe UI", 9)
    Button  = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
}

# ============================================
# FUNCIONES DE ACTIVACION MAS
# ============================================
function Invoke-MASInteractive {
    # Abre MAS en modo interactivo
    $masCmd = @'
@echo off
fltmc >nul || (powershell -c "Start-Process '%~f0' -Verb RunAs" & exit /b)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://massgrave.dev/ias | iex"
'@
    $tempFile = Join-Path $env:TEMP "MAS_Interactive.cmd"
    $masCmd | Out-File -FilePath $tempFile -Encoding ASCII
    Start-Process $tempFile -Verb RunAs
}

function Invoke-TSforge {
    # Activa Windows con TSforge
    $masCmd = @'
@echo off
fltmc >nul || (powershell -c "Start-Process '%~f0' -Verb RunAs" & exit /b)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://massgrave.dev/tsforge | iex"
'@
    $tempFile = Join-Path $env:TEMP "MAS_TSforge.cmd"
    $masCmd | Out-File -FilePath $tempFile -Encoding ASCII
    Start-Process $tempFile -Verb RunAs
}

function Invoke-Ohook {
    # Activa Office con Ohook
    $masCmd = @'
@echo off
fltmc >nul || (powershell -c "Start-Process '%~f0' -Verb RunAs" & exit /b)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://massgrave.dev/ohook | iex"
'@
    $tempFile = Join-Path $env:TEMP "MAS_Ohook.cmd"
    $masCmd | Out-File -FilePath $tempFile -Encoding ASCII
    Start-Process $tempFile -Verb RunAs
}

function Invoke-HWID {
    # Activa Windows con HWID
    $masCmd = @'
@echo off
fltmc >nul || (powershell -c "Start-Process '%~f0' -Verb RunAs" & exit /b)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://massgrave.dev/hwid | iex"
'@
    $tempFile = Join-Path $env:TEMP "MAS_HWID.cmd"
    $masCmd | Out-File -FilePath $tempFile -Encoding ASCII
    Start-Process $tempFile -Verb RunAs
}

function Invoke-KMS {
    # Activa con KMS Online
    $masCmd = @'
@echo off
fltmc >nul || (powershell -c "Start-Process '%~f0' -Verb RunAs" & exit /b)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://massgrave.dev/kms | iex"
'@
    $tempFile = Join-Path $env:TEMP "MAS_KMS.cmd"
    $masCmd | Out-File -FilePath $tempFile -Encoding ASCII
    Start-Process $tempFile -Verb RunAs
}

# ============================================
# FORMULARIO PRINCIPAL
# ============================================
$Global:Form = New-Object System.Windows.Forms.Form
$Form.Text = "SHADOWIEX"
$Form.Size = New-Object System.Drawing.Size(1000, 700)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = $Global:Theme.BG
$Form.ForeColor = $Global:Theme.TextMain
$Form.MinimumSize = New-Object System.Drawing.Size(800, 600)

# ============================================
# HEADER
# ============================================
$HeaderPanel = New-Object System.Windows.Forms.Panel
$HeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$HeaderPanel.Height = 75
$HeaderPanel.BackColor = $Global:Theme.Surface
$Form.Controls.Add($HeaderPanel)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "SHADOWIEX"
$TitleLabel.Location = New-Object System.Drawing.Point(20, 18)
$TitleLabel.Size = New-Object System.Drawing.Size(200, 40)
$TitleLabel.Font = $Global:Fonts.Title
$TitleLabel.ForeColor = $Global:Theme.Primary
$HeaderPanel.Controls.Add($TitleLabel)

$VersionLabel = New-Object System.Windows.Forms.Label
$VersionLabel.Text = "v11.0 PROFESSIONAL"
$VersionLabel.Location = New-Object System.Drawing.Point(200, 35)
$VersionLabel.Size = New-Object System.Drawing.Size(150, 20)
$VersionLabel.Font = $Global:Fonts.Small
$VersionLabel.ForeColor = $Global:Theme.TextMuted
$HeaderPanel.Controls.Add($VersionLabel)

# Info del sistema
$OSInfo = (Get-CimInstance Win32_OperatingSystem).Caption
$SysLabel = New-Object System.Windows.Forms.Label
$SysLabel.Text = $OSInfo
$SysLabel.Location = New-Object System.Drawing.Point(700, 15)
$SysLabel.Size = New-Object System.Drawing.Size(280, 20)
$SysLabel.Font = $Global:Fonts.Small
$SysLabel.ForeColor = $Global:Theme.TextMuted
$SysLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($SysLabel)

$AdminLabel = New-Object System.Windows.Forms.Label
$AdminLabel.Text = "[ADMINISTRADOR]"
$AdminLabel.Location = New-Object System.Drawing.Point(850, 35)
$AdminLabel.Size = New-Object System.Drawing.Size(130, 20)
$AdminLabel.Font = $Global:Fonts.Small
$AdminLabel.ForeColor = $Global:Theme.Success
$AdminLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$HeaderPanel.Controls.Add($AdminLabel)

# Linea decorativa
$AccentLine = New-Object System.Windows.Forms.Panel
$AccentLine.Dock = [System.Windows.Forms.DockStyle]::Bottom
$AccentLine.Height = 3
$AccentLine.BackColor = $Global:Theme.Primary
$HeaderPanel.Controls.Add($AccentLine)

# ============================================
# PANEL DE PESTAÑAS
# ============================================
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Location = New-Object System.Drawing.Point(0, 75)
$TabControl.Size = New-Object System.Drawing.Size(1000, 585)
$TabControl.BackColor = $Global:Theme.BG
$TabControl.Appearance = [System.Windows.Forms.TabAppearance]::FlatButtons
$TabControl.ItemSize = New-Object System.Drawing.Size(120, 35)
$TabControl.Font = $Global:Fonts.Button
$TabControl.Padding = New-Object System.Drawing.Point(10, 2)

# Crear pestañas
$TabInstall = New-Object System.Windows.Forms.TabPage
$TabInstall.Text = "INSTALAR"
$TabInstall.BackColor = $Global:Theme.BG
$TabInstall.Padding = New-Object System.Windows.Forms.Padding(15)

$TabTweaks = New-Object System.Windows.Forms.TabPage
$TabTweaks.Text = "OPTIMIZAR"
$TabTweaks.BackColor = $Global:Theme.BG
$TabTweaks.Padding = New-Object System.Windows.Forms.Padding(15)

$TabActivate = New-Object System.Windows.Forms.TabPage
$TabActivate.Text = "ACTIVAR"
$TabActivate.BackColor = $Global:Theme.BG
$TabActivate.Padding = New-Object System.Windows.Forms.Padding(15)

$TabConfig = New-Object System.Windows.Forms.TabPage
$TabConfig.Text = "CONFIG"
$TabConfig.BackColor = $Global:Theme.BG
$TabConfig.Padding = New-Object System.Windows.Forms.Padding(15)

$TabControl.Controls.AddRange(@($TabInstall, $TabTweaks, $TabActivate, $TabConfig))
$Form.Controls.Add($TabControl)

# ============================================
# FUNCIONES DE UTILIDAD
# ============================================
function New-Btn {
    param($Text, $X, $Y, $W=180, $H=40, $Color="Primary", $Action=$null)
    
    $BtnColor = switch($Color) {
        "Success" { $Global:Theme.Success }
        "Danger" { $Global:Theme.Danger }
        "Warning" { $Global:Theme.Warning }
        "Secondary" { $Global:Theme.Secondary }
        default { $Global:Theme.Primary }
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
    
    if ($Action) { 
        $Btn.Add_Click($Action) 
    }
    
    return $Btn
}

function Update-Status {
    param($Text, $Type="info")
    $Color = switch($Type) {
        "success" { $Global:Theme.Success }
        "error" { $Global:Theme.Danger }
        "warning" { $Global:Theme.Warning }
        default { $Global:Theme.TextMuted }
    }
    $Global:StatusLabel.Text = $Text
    $Global:StatusLabel.ForeColor = $Color
    [System.Windows.Forms.Application]::DoEvents()
}

function Test-Winget {
    try { $null = winget --version 2>$null; return $true } 
    catch { return $false }
}

function Test-Choco {
    try { $null = choco --version 2>$null; return $true } 
    catch { return $false }
}

# ============================================
# PESTAÑA INSTALAR
# ============================================
$InstallScroll = New-Object System.Windows.Forms.Panel
$InstallScroll.Location = New-Object System.Drawing.Point(10, 10)
$InstallScroll.Size = New-Object System.Drawing.Size(750, 480)
$InstallScroll.BackColor = $Global:Theme.BG
$InstallScroll.AutoScroll = $true
$TabInstall.Controls.Add($InstallScroll)

$ActionPanel = New-Object System.Windows.Forms.Panel
$ActionPanel.Location = New-Object System.Drawing.Point(770, 10)
$ActionPanel.Size = New-Object System.Drawing.Size(200, 480)
$ActionPanel.BackColor = $Global:Theme.Surface
$TabInstall.Controls.Add($ActionPanel)

# Software data
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
    "RUNTIMES" = @(
        @{ID="Microsoft.VCRedist.2015+.x64"; Name="VC++ x64"},
        @{ID="Microsoft.VCRedist.2015+.x86"; Name="VC++ x86"},
        @{ID="Microsoft.DotNet.DesktopRuntime.8"; Name=".NET 8"}
    )
}

$Global:AllCheckboxes = @()
$YPos = 5

foreach ($Cat in $SoftwareData.Keys) {
    # Categoria header
    $CatPanel = New-Object System.Windows.Forms.Panel
    $CatPanel.Location = New-Object System.Drawing.Point(5, $YPos)
    $CatPanel.Size = New-Object System.Drawing.Size(720, 28)
    $CatPanel.BackColor = $Global:Theme.Surface
    $InstallScroll.Controls.Add($CatPanel)
    
    $CatLabel = New-Object System.Windows.Forms.Label
    $CatLabel.Text = $Cat
    $CatLabel.Location = New-Object System.Drawing.Point(10, 5)
    $CatLabel.Size = New-Object System.Drawing.Size(300, 18)
    $CatLabel.Font = $Global:Fonts.Header
    $CatLabel.ForeColor = $Global:Theme.Secondary
    $CatPanel.Controls.Add($CatLabel)
    
    $YPos += 32
    
    # Apps
    $XPos = 15
    foreach ($App in $SoftwareData[$Cat]) {
        $CB = New-Object System.Windows.Forms.CheckBox
        $CB.Text = $App.Name
        $CB.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CB.Size = New-Object System.Drawing.Size(170, 26)
        $CB.Font = $Global:Fonts.Normal
        $CB.ForeColor = $Global:Theme.TextMain
        $CB.BackColor = $Global:Theme.BG
        $CB.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $CB.Tag = $App.ID
        
        $CB.Add_CheckedChanged({
            $Count = ($Global:AllCheckboxes | Where-Object { $_.Checked }).Count
            $Global:CountLabel.Text = "$Count seleccionados"
            $Global:ToggleBtn.Text = if ($Count -eq $Global:AllCheckboxes.Count) { "QUITAR TODO" } else { "SELECCIONAR TODO" }
        })
        
        $InstallScroll.Controls.Add($CB)
        $Global:AllCheckboxes += $CB
        
        $XPos += 175
        if ($XPos -gt 550) { $XPos = 15; $YPos += 28 }
    }
    $YPos += 38
}

# Panel de acciones
$SelTitle = New-Object System.Windows.Forms.Label
$SelTitle.Text = "ACCIONES"
$SelTitle.Location = New-Object System.Drawing.Point(15, 15)
$SelTitle.Size = New-Object System.Drawing.Size(170, 25)
$SelTitle.Font = $Global:Fonts.Header
$SelTitle.ForeColor = $Global:Theme.TextMuted
$ActionPanel.Controls.Add($SelTitle)

$Global:CountLabel = New-Object System.Windows.Forms.Label
$Global:CountLabel.Text = "0 seleccionados"
$Global:CountLabel.Location = New-Object System.Drawing.Point(15, 45)
$Global:CountLabel.Size = New-Object System.Drawing.Size(170, 20)
$Global:CountLabel.Font = $Global:Fonts.Normal
$Global:CountLabel.ForeColor = $Global:Theme.Primary
$ActionPanel.Controls.Add($Global:CountLabel)

$Global:ToggleBtn = New-Btn -Text "SELECCIONAR TODO" -X 10 -Y 80 -W 180 -Color "Secondary"
$Global:ToggleBtn.Add_Click({
    $Select = -not $Global:AllChecked
    $Global:AllChecked = $Select
    foreach ($CB in $Global:AllCheckboxes) { $CB.Checked = $Select }
})
$ActionPanel.Controls.Add($Global:ToggleBtn)

$InstallBtn = New-Btn -Text "INSTALAR" -X 10 -Y 130 -W 180 -Color "Success"
$InstallBtn.Add_Click({
    $Selected = $Global:AllCheckboxes | Where-Object { $_.Checked }
    if ($Selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Selecciona al menos un programa.", "SHADOWIEX")
        return
    }
    
    $HasWinget = Test-Winget
    $HasChoco = Test-Choco
    
    if (-not $HasWinget -and -not $HasChoco) {
        $R = [System.Windows.Forms.MessageBox]::Show(
            "No hay gestores disponibles. Instalar Chocolatey?",
            "SHADOWIEX", 4)
        if ($R -ne 6) { return }
        
        Update-Status "Instalando Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $HasChoco = $true
            Update-Status "Chocolatey instalado" "success"
        } catch {
            Update-Status "Error instalando Chocolatey" "error"
            return
        }
    }
    
    # Progreso
    $ProgF = New-Object System.Windows.Forms.Form
    $ProgF.Text = "SHADOWIEX - Instalando"
    $ProgF.Size = New-Object System.Drawing.Size(450, 150)
    $ProgF.BackColor = $Global:Theme.BG
    $ProgF.StartPosition = "CenterParent"
    $ProgF.FormBorderStyle = "FixedDialog"
    $ProgF.ControlBox = $false
    $ProgF.TopMost = $true
    
    $ProgL = New-Object System.Windows.Forms.Label
    $ProgL.Text = "Iniciando..."
    $ProgL.Location = New-Object System.Drawing.Point(15, 15)
    $ProgL.Size = New-Object System.Drawing.Size(400, 20)
    $ProgL.Font = $Global:Fonts.Normal
    $ProgL.ForeColor = $Global:Theme.TextMain
    $ProgF.Controls.Add($ProgL)
    
    $ProgBar = New-Object System.Windows.Forms.ProgressBar
    $ProgBar.Location = New-Object System.Drawing.Point(15, 45)
    $ProgBar.Size = New-Object System.Drawing.Size(400, 25)
    $ProgBar.Maximum = $Selected.Count
    $ProgF.Controls.Add($ProgBar)
    
    $CancelBtn = New-Btn -Text "CANCELAR" -X 340 -Y 80 -W 80 -H 30 -Color "Danger"
    $CancelBtn.Add_Click({ $Global:Cancelled = $true; $ProgF.Close() })
    $ProgF.Controls.Add($CancelBtn)
    
    $ProgF.Show()
    $Global:Cancelled = $false
    
    $Step = 0
    $OK = 0
    $Fail = 0
    
    foreach ($CB in $Selected) {
        if ($Global:Cancelled) { break }
        $Step++
        $AppID = $CB.Tag
        $AppName = $CB.Text
        
        $ProgL.Text = "Instalando: $AppName"
        $ProgBar.Value = $Step
        Update-Status "Instalando: $AppName"
        [System.Windows.Forms.Application]::DoEvents()
        
        $Installed = $false
        
        if ($HasWinget) {
            try {
                $P = Start-Process "winget" -ArgumentList "install","--id",$AppID,"--accept-source-agreements","--accept-package-agreements","-h" -NoNewWindow -PassThru -Wait -EA 0
                if ($P.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        
        if (-not $Installed -and $HasChoco) {
            try {
                $ChocoID = $AppID.Split('.')[-1].ToLower()
                $P = Start-Process "choco" -ArgumentList "install",$ChocoID,"-y","--force" -NoNewWindow -PassThru -Wait -EA 0
                if ($P.ExitCode -eq 0) { $Installed = $true }
            } catch {}
        }
        
        if ($Installed) { $OK++ } else { $Fail++ }
    }
    
    $ProgF.Close()
    
    if ($Global:Cancelled) {
        Update-Status "Cancelado" "warning"
    } else {
        Update-Status "Completado: $OK OK, $Fail fallidos" "success"
        [System.Windows.Forms.MessageBox]::Show("Instalacion completada`n`nExitosos: $OK`nFallidos: $Fail", "SHADOWIEX")
    }
})
$ActionPanel.Controls.Add($InstallBtn)

# ============================================
# PESTAÑA OPTIMIZAR
# ============================================
$TweaksList = @(
    @{Name="Essential Tweaks"; Desc="Optimizaciones esenciales"; Action={
        Update-Status "Aplicando tweaks..."
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f | Out-Null
            @("DiagTrack","dmwappushservice") | ForEach-Object { 
                try { Set-Service $_ -StartupType Disabled -EA 0 } catch {} 
            }
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
            Update-Status "Tweaks aplicados" "success"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="Desactivar Telemetria"; Desc="Desactiva telemetria completa"; Action={
        try {
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
            Stop-Service "DiagTrack" -Force -EA 0
            Set-Service "DiagTrack" -StartupType Disabled -EA 0
            Update-Status "Telemetria desactivada" "success"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="Desactivar Defender"; Desc="Desactiva Defender temporalmente"; Action={
        $R = [System.Windows.Forms.MessageBox]::Show("Desactivar Windows Defender?", "SHADOWIEX", 4)
        if ($R -eq 6) {
            try {
                Set-MpPreference -DisableRealtimeMonitoring $true -EA 0
                Update-Status "Defender desactivado" "warning"
            } catch { Update-Status "Error - usa Defender Control" "error" }
        }
    }},
    @{Name="Activar Defender"; Desc="Reactiva Windows Defender"; Action={
        try {
            Set-MpPreference -DisableRealtimeMonitoring $false -EA 0
            Update-Status "Defender activado" "success"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="Limpiar Temporales"; Desc="Elimina archivos temporales"; Action={
        Update-Status "Limpiando..."
        try {
            Get-ChildItem "$env:TEMP\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Get-ChildItem "$env:windir\Temp\*" -Recurse -Force -EA 0 | Remove-Item -Recurse -Force -EA 0
            Update-Status "Temporales eliminados" "success"
        } catch { Update-Status "Error" "error" }
    }},
    @{Name="Optimizar Red"; Desc="Resetea configuracion de red"; Action={
        Update-Status "Optimizando red..."
        try {
            netsh int ip reset | Out-Null
            netsh winsock reset | Out-Null
            ipconfig /flushdns | Out-Null
            Update-Status "Red optimizada - reinicia" "success"
        } catch { Update-Status "Error" "error" }
    }}
)

$TweakY = 20
$TweakX = 20
$Col = 0

foreach ($T in $TweaksList) {
    $Card = New-Object System.Windows.Forms.Panel
    $Card.Location = New-Object System.Drawing.Point($TweakX, $TweakY)
    $Card.Size = New-Object System.Drawing.Size(230, 85)
    $Card.BackColor = $Global:Theme.Surface
    $TabTweaks.Controls.Add($Card)
    
    $Btn = New-Btn -Text $T.Name -X 10 -Y 10 -W 210 -Color "Primary"
    $ActionRef = $T.Action
    $Btn.Add_Click($ActionRef)
    $Card.Controls.Add($Btn)
    
    $Desc = New-Object System.Windows.Forms.Label
    $Desc.Text = $T.Desc
    $Desc.Location = New-Object System.Drawing.Point(10, 55)
    $Desc.Size = New-Object System.Drawing.Size(210, 25)
    $Desc.Font = $Global:Fonts.Small
    $Desc.ForeColor = $Global:Theme.TextMuted
    $Card.Controls.Add($Desc)
    
    $Col++
    if ($Col -ge 3) { $Col = 0; $TweakX = 20; $TweakY += 95 } else { $TweakX += 240 }
}

# ============================================
# PESTAÑA ACTIVAR - CON MAS INTEGRADO
# ============================================
$ActivateHeader = New-Object System.Windows.Forms.Label
$ActivateHeader.Text = "ACTIVACION DE WINDOWS Y OFFICE"
$ActivateHeader.Location = New-Object System.Drawing.Point(20, 15)
$ActivateHeader.Size = New-Object System.Drawing.Size(500, 30)
$ActivateHeader.Font = $Global:Fonts.Header
$ActivateHeader.ForeColor = $Global:Theme.TextMain
$TabActivate.Controls.Add($ActivateHeader)

$ActivateDesc = New-Object System.Windows.Forms.Label
$ActivateDesc.Text = "Microsoft Activation Scripts (MAS) integrado"
$ActivateDesc.Location = New-Object System.Drawing.Point(20, 45)
$ActivateDesc.Size = New-Object System.Drawing.Size(500, 20)
$ActivateDesc.Font = $Global:Fonts.Small
$ActivateDesc.ForeColor = $Global:Theme.TextMuted
$TabActivate.Controls.Add($ActivateDesc)

# Botones de activacion MAS
$ActList = @(
    @{Name="MAS INTERACTIVO"; Desc="Menu completo de activacion"; Color="Success"; Action={Invoke-MASInteractive}},
    @{Name="ACTIVAR WINDOWS"; Desc="Activacion Windows TSforge"; Color="Primary"; Action={Invoke-TSforge}},
    @{Name="ACTIVAR OFFICE"; Desc="Activacion Office Ohook"; Color="Primary"; Action={Invoke-Ohook}},
    @{Name="HWID ACTIVATION"; Desc="Activacion digital Windows 10/11"; Color="Secondary"; Action={Invoke-HWID}},
    @{Name="KMS ONLINE"; Desc="Activacion KMS Windows/Office"; Color="Secondary"; Action={Invoke-KMS}}
)

$ActY = 80
$ActX = 20
$ActCol = 0

foreach ($A in $ActList) {
    $Card = New-Object System.Windows.Forms.Panel
    $Card.Location = New-Object System.Drawing.Point($ActX, $ActY)
    $Card.Size = New-Object System.Drawing.Size(230, 90)
    $Card.BackColor = $Global:Theme.Surface
    $TabActivate.Controls.Add($Card)
    
    $Btn = New-Btn -Text $A.Name -X 10 -Y 10 -W 210 -Color $A.Color
    
    # Crear closure correcto para cada boton
    $CurrentAction = $A.Action
    $Btn.Add_Click({
        param($sender, $e)
        Update-Status "Abriendo activador..."
        & $CurrentAction
        Update-Status "Activador abierto" "success"
    }.GetNewClosure())
    $Card.Controls.Add($Btn)
    
    $Desc = New-Object System.Windows.Forms.Label
    $Desc.Text = $A.Desc
    $Desc.Location = New-Object System.Drawing.Point(10, 55)
    $Desc.Size = New-Object System.Drawing.Size(210, 30)
    $Desc.Font = $Global:Fonts.Small
    $Desc.ForeColor = $Global:Theme.TextMuted
    $Card.Controls.Add($Desc)
    
    $ActCol++
    if ($ActCol -ge 3) { $ActCol = 0; $ActX = 20; $ActY += 100 } else { $ActX += 240 }
}

# Info adicional
$InfoPanel = New-Object System.Windows.Forms.Panel
$InfoPanel.Location = New-Object System.Drawing.Point(20, 400)
$InfoPanel.Size = New-Object System.Drawing.Size(740, 60)
$InfoPanel.BackColor = $Global:Theme.Surface
$TabActivate.Controls.Add($InfoPanel)

$InfoLabel = New-Object System.Windows.Forms.Label
$InfoLabel.Text = "MAS se ejecuta directamente desde massgrave.dev - Codigo abierto y seguro"
$InfoLabel.Location = New-Object System.Drawing.Point(15, 10)
$InfoLabel.Size = New-Object System.Drawing.Size(710, 20)
$InfoLabel.Font = $Global:Fonts.Small
$InfoLabel.ForeColor = $Global:Theme.TextMuted
$InfoPanel.Controls.Add($InfoLabel)

$InfoLabel2 = New-Object System.Windows.Forms.Label
$InfoLabel2.Text = "HWID: Windows 10/11 | TSforge: Todos los Windows | Ohook: Office"
$InfoLabel2.Location = New-Object System.Drawing.Point(15, 32)
$InfoLabel2.Size = New-Object System.Drawing.Size(710, 20)
$InfoLabel2.Font = $Global:Fonts.Small
$InfoLabel2.ForeColor = $Global:Theme.Secondary
$InfoPanel.Controls.Add($InfoLabel2)

# ============================================
# PESTAÑA CONFIG
# ============================================
$ConfigHeader = New-Object System.Windows.Forms.Label
$ConfigHeader.Text = "CONFIGURACION DEL SISTEMA"
$ConfigHeader.Location = New-Object System.Drawing.Point(20, 15)
$ConfigHeader.Size = New-Object System.Drawing.Size(400, 30)
$ConfigHeader.Font = $Global:Fonts.Header
$ConfigHeader.ForeColor = $Global:Theme.TextMain
$TabConfig.Controls.Add($ConfigHeader)

# Estado gestores
$WG = Test-Winget
$CH = Test-Choco

$WGLabel = New-Object System.Windows.Forms.Label
$WGLabel.Text = "Winget: " + $(if($WG){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$WGLabel.Location = New-Object System.Drawing.Point(20, 60)
$WGLabel.Size = New-Object System.Drawing.Size(250, 22)
$WGLabel.Font = $Global:Fonts.Normal
$WGLabel.ForeColor = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}
$TabConfig.Controls.Add($WGLabel)

$CHLabel = New-Object System.Windows.Forms.Label
$CHLabel.Text = "Chocolatey: " + $(if($CH){"[INSTALADO]"}else{"[NO DISPONIBLE]"})
$CHLabel.Location = New-Object System.Drawing.Point(20, 85)
$CHLabel.Size = New-Object System.Drawing.Size(250, 22)
$CHLabel.Font = $Global:Fonts.Normal
$CHLabel.ForeColor = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}
$TabConfig.Controls.Add($CHLabel)

# Info sistema
$SysTitle = New-Object System.Windows.Forms.Label
$SysTitle.Text = "INFORMACION DEL SISTEMA"
$SysTitle.Location = New-Object System.Drawing.Point(20, 130)
$SysTitle.Size = New-Object System.Drawing.Size(300, 25)
$SysTitle.Font = $Global:Fonts.Header
$SysTitle.ForeColor = $Global:Theme.Secondary
$TabConfig.Controls.Add($SysTitle)

$OS = Get-CimInstance Win32_OperatingSystem
$InfoLines = @(
    "Sistema: $($OS.Caption)",
    "Version: $($OS.Version)",
    "Arquitectura: $env:PROCESSOR_ARCHITECTURE",
    "Usuario: $env:USERNAME",
    "Equipo: $env:COMPUTERNAME"
)

$InfoY = 160
foreach ($Line in $InfoLines) {
    $L = New-Object System.Windows.Forms.Label
    $L.Text = $Line
    $L.Location = New-Object System.Drawing.Point(20, $InfoY)
    $L.Size = New-Object System.Drawing.Size(500, 20)
    $L.Font = $Global:Fonts.Normal
    $L.ForeColor = $Global:Theme.TextMuted
    $TabConfig.Controls.Add($L)
    $InfoY += 24
}

# Creditos
$CreditPanel = New-Object System.Windows.Forms.Panel
$CreditPanel.Location = New-Object System.Drawing.Point(20, 320)
$CreditPanel.Size = New-Object System.Drawing.Size(350, 80)
$CreditPanel.BackColor = $Global:Theme.Surface
$TabConfig.Controls.Add($CreditPanel)

$CreditTitle = New-Object System.Windows.Forms.Label
$CreditTitle.Text = "SHADOWIEX v11.0 PROFESSIONAL"
$CreditTitle.Location = New-Object System.Drawing.Point(15, 15)
$CreditTitle.Size = New-Object System.Drawing.Size(320, 22)
$CreditTitle.Font = $Global:Fonts.Header
$CreditTitle.ForeColor = $Global:Theme.Primary
$CreditPanel.Controls.Add($CreditTitle)

$CreditAuthor = New-Object System.Windows.Forms.Label
$CreditAuthor.Text = "Creado por WDPN (WalterShadow2001)"
$CreditAuthor.Location = New-Object System.Drawing.Point(15, 42)
$CreditAuthor.Size = New-Object System.Drawing.Size(320, 18)
$CreditAuthor.Font = $Global:Fonts.Small
$CreditAuthor.ForeColor = $Global:Theme.TextMuted
$CreditPanel.Controls.Add($CreditAuthor)

$CreditGit = New-Object System.Windows.Forms.Label
$CreditGit.Text = "github.com/WalterShadow2001/shadowiex"
$CreditGit.Location = New-Object System.Drawing.Point(15, 60)
$CreditGit.Size = New-Object System.Drawing.Size(320, 18)
$CreditGit.Font = $Global:Fonts.Small
$CreditGit.ForeColor = $Global:Theme.Secondary
$CreditPanel.Controls.Add($CreditGit)

# ============================================
# STATUS BAR
# ============================================
$StatusStrip = New-Object System.Windows.Forms.StatusStrip
$StatusStrip.BackColor = $Global:Theme.Surface
$StatusStrip.Font = $Global:Fonts.Small

$Global:StatusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$Global:StatusLabel.Text = "Listo"
$Global:StatusLabel.ForeColor = $Global:Theme.TextMuted
$StatusStrip.Items.Add($Global:StatusLabel)

$Sep = New-Object System.Windows.Forms.ToolStripStatusLabel
$Sep.Text = "  |  "
$Sep.ForeColor = $Global:Theme.Border
$StatusStrip.Items.Add($Sep)

$WGStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$WGStatus.Text = "Winget: " + $(if($WG){"OK"}else{"NO"})
$WGStatus.ForeColor = if($WG){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($WGStatus)

$CHStatus = New-Object System.Windows.Forms.ToolStripStatusLabel
$CHStatus.Text = "  Choco: " + $(if($CH){"OK"}else{"NO"})
$CHStatus.ForeColor = if($CH){$Global:Theme.Success}else{$Global:Theme.Danger}
$StatusStrip.Items.Add($CHStatus)

$Form.Controls.Add($StatusStrip)

# Mostrar
$Global:AllChecked = $false
Update-Status "SHADOWIEX v11.0 - Listo"
[void]$Form.ShowDialog()
