function refresh-path {
    $env:Path =
        [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
        [System.Environment]::GetEnvironmentVariable("Path","User")
}

function run-winutil {
    $winutilCfg = '{
      "WPFInstall": [
        "WPFInstallvesktop",
        "WPFInstallstarship",
        "WPFInstallthunderbird",
        "WPFInstallnuget",
        "WPFInstallvscode",
        "WPFInstallnushell",
        "WPFInstallpowershell",
        "WPFInstallripgrep",
        "WPFInstallalacritty",
        "WPFInstallteams",
        "WPFInstallneovim",
        "WPFInstallputty",
        "WPFInstallterminal",
        "WPFInstallepicgames",
        "WPFInstallbitwarden",
        "WPFInstallventoy",
        "WPFInstallpowertoys",
        "WPFInstallZenBrowser",
        "WPFInstallsteam",
        "WPFInstallfirefox",
        "WPFInstallgit",
        "WPFInstallgithubcli",
        "WPFInstallvlc",
        "WPFInstallmatrix",
        "WPFInstallvscodium",
        "WPFInstallfzf",
        "WPFInstallitch",
        "WPFInstallspotify",
        "WPFInstallpython3",
        "WPFInstalledge",
        "WPFInstallbat",
        "WPFInstallslack",
        "WPFInstalldockerdesktop"
      ],
      "WPFTweaks": [
        "WPFTweaksRestorePoint",
        "WPFTweaksDiskCleanup",
        "WPFTweaksDisableNotifications",
        "WPFTweaksRemoveEdge",
        "WPFTweaksPowershell7",
        "WPFTweaksEndTaskOnTaskbar",
        "WPFTweaksDeleteTempFiles",
        "WPFTweaksUTC",
        "WPFTweaksPowershell7Tele",
        "WPFTweaksAH",
        "WPFTweaksServices",
        "WPFTweaksConsumerFeatures",
        "WPFTweaksRemoveCopilot",
        "WPFTweaksEdgeDebloat",
        "WPFTweaksWifi",
        "WPFTweaksTele",
        "WPFTweaksHiber",
        "WPFTweaksHome",
        "WPFTweaksRemoveOnedrive",
        "WPFTweaksRightClickMenu",
        "WPFTweaksRazerBlock",
        "WPFTweaksRecallOff",
        "WPFTweaksLoc",
        "WPFTweaksDVR",
        "WPFTweaksStorage",
        "WPFTweaksDisableExplorerAutoDiscovery"
      ],
      "WPFToggle": [
        "WPFToggleTaskView_0",
        "WPFToggleHiddenFiles_1",
        "WPFToggleBingSearch_0",
        "WPFToggleSnapSuggestion_1",
        "WPFToggleHideSettingsHome_1",
        "WPFToggleSnapWindow_1",
        "WPFToggleStartMenuRecommendations_0",
        "WPFToggleMouseAcceleration_1",
        "WPFToggleTaskbarWidgets_0",
        "WPFToggleTaskbarSearch_0",
        "WPFToggleTaskbarAlignment_0",
        "WPFToggleNumLock_0",
        "WPFToggleStickyKeys_0",
        "WPFToggleDetailedBSoD_1",
        "WPFToggleShowExt_1",
        "WPFToggleDarkMode_1",
        "WPFToggleVerboseLogon_1",
        "WPFToggleSnapFlyout_1"
      ],
      "WPFFeature": [
        "WPFFeatureEnableLegacyRecovery",
        "WPFFeatureDisableSearchSuggestions",
        "WPFFeaturesSandbox",
        "WPFFeaturewsl",
        "WPFFeatureshyperv"
      ]
    }'

    $tempFile = New-TemporaryFile
    $winutilCfg | Out-File -FilePath $tempFile

    # manual install
    # irm https://christitus.com/win | iex

    # let x = curl https://api.github.com/repos/upidapi/winutil-cli/releases | from json
    # curl -L $"https://github.com/upidapi/winutil-cli/releases/download/($x.0.tag_name)/winutil.ps1" | save script.ps1

    $tagName = (Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/upidapi/winutil-cli/releases" | ConvertFrom-Json)[0].tag_name

    $downloadUrl = "https://github.com/upidapi/winutil-cli/releases/download/$($tagName)/winutil.ps1"

    # Invoke-WebRequest -Uri $downloadUrl -OutFile "script.ps1"
    & ([scriptblock]::Create($(irm $downloadUrl))) -Config $tempFile -Run

    # irm christitus.com/win -Config $tempFile -Run -Debug | iex
    # iex "& { $(irm christitus.com/win) }
    # iex "& { $(irm christitus.com/windev) } -Config $tempFile -Run"
}


function set-display-res {
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name DisplaySettings -Force
    Set-DisplayResolution -Width 1920 -Height 1200
}

function set-default-browser {
    choco install SetDefaultBrowser -y

    $browserName = "Firefox"
    $regex = "HKLM ([^\n\r]+)\r\n  name: " + [regex]::Escape($browserName) + "\r\n"
    $output = SetDefaultBrowser | Out-String

    if ($output -match $regex) {
        $hklm = $Matches[1]  # Captured value is likely a Browser ID

        SetDefaultBrowser HKLM $hklm
    } else {
        Write-Warning "Failed to find the HKLM for the browser"
    }
}


function disable-startup-apps {
    $32bit = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $32bitRunOnce = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $64bit = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    $64bitRunOnce = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce"
    $currentLOU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $currentLOURunOnce = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

    $paths = $32bit,$32bitRunOnce,$64bit,$64bitRunOnce,$currentLOU,$currentLOURunOnce

    $regStartList = Get-Item -path $paths |
        Where-Object {$_.ValueCount -ne 0} |
        Select-Object  property,name

    foreach ($regData in $regStartList) {
        $regName = $regData.Name

        $regNumber = ($regName).IndexOf("\")
        $regLocation = ($regName).Insert("$regNumber",":")
        if ($regLocation -like "*HKEY_LOCAL_MACHINE*"){
            $regLocation = $regLocation.Replace("HKEY_LOCAL_MACHINE","HKLM")
        }
        if ($regLocation -like "*HKEY_CURRENT_USER*"){
            $regLocation = $regLocation.Replace("HKEY_CURRENT_USER","HKCU")
        }

        # currently it removes the links
        # could instead figure out how to set them to disabled
        foreach($disable in $regData.Property) {
            if (Get-ItemProperty -Path "$reglocation" -name "$disable" -ErrorAction SilentlyContinue) {
                Write-Host "Disabling" $disable
                Remove-ItemProperty -Path "$reglocation" -Name "$disable"
            } else {
                Write-Host "Could not find" $disable
            }
        }
    }
}

function setup-shared-drives {
    # REF: https://braheezy.github.io/posts/some-things-virtiofs-and-windows/
    Invoke-WebRequest https://github.com/winfsp/winfsp/releases/download/v1.10/winfsp-1.10.22006.msi -OutFile winfsp-1.10.22006.msi
    winfsp-1.10.22006.msi /qn /norestart

    # pnputil /install /add-driver E:\viofs\w11\amd64\viofs.inf

    cp E:\viofs\w11\amd64\virtiofs.exe C:\Windows\virtiofs.exe
    New-Service `
        -Name "VirtioFsSvc" `
        -BinaryPathName "C:\Windows\virtiofs.exe" `
        -DisplayName "Virtio FS Service" `
        -Description "Enables Windows virtual machines to access directories on the host that have been shared with them using virtiofs." `
        -StartupType Automatic `
        -DependsOn "WinFsp.Launcher"

    Start-Service VirtioFsSvc
}


Set-ExecutionPolicy Unrestricted -Force

# not needed use the auto resize vm instead
Write-Host
Write-Host "Setting display res"
set-display-res

Write-Host
Write-Host "Running winutil"
run-winutil

Write-Host
Write-Host "Activating windows and ms office"
& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /Ohook

Write-Host
Write-Host "Setting default browser"
set-default-browser


Write-Host
Write-Host "Disabling startup apps"
disable-startup-apps

Write-Host
Write-Host "Installing drivers"
# you may have to restart after this
pnputil /add-driver E:\*.inf /install /subdirs 

Write-Host
Write-Host "Installing guest tools"
E:\VIRTIO_WIN_GUEST_TOOLS.EXE -silent

# install spice guest tools
choco install spice-agent -y

choco install winfsp -y # Idk if this is needed
choco install qemu-guest-agent -y

Write-Host
Write-Host "Setting up shared drives"
setup-shared-drives

# restart-computer
