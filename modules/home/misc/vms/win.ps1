function refresh-path {
    $env:Path =
        [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
        [System.Environment]::GetEnvironmentVariable("Path","User")
}


function run-winutil {
    $winutilCfg = '{
        "WPFTweaks":  [
                          "WPFTweaksRestorePoint",
                          "WPFTweaksDisableNotifications",
                          "WPFTweaksRemoveEdge",
                          "WPFTweaksPowershell7",
                          "WPFTweaksEndTaskOnTaskbar",
                          "WPFTweaksDeleteTempFiles",
                          "WPFTweaksUTC",
                          "WPFTweaksRazerBlock",
                          "WPFTweaksPowershell7Tele",
                          "WPFTweaksAH",
                          "WPFTweaksServices",
                          "WPFTweaksConsumerFeatures",
                          "WPFTweaksDiskCleanup",
                          "WPFTweaksRemoveCopilot",
                          "WPFTweaksEdgeDebloat",
                          "WPFTweaksWifi",
                          "WPFTweaksTele",
                          "WPFTweaksHiber",
                          "WPFTweaksHome",
                          "WPFTweaksRemoveOnedrive",
                          "WPFTweaksRightClickMenu",
                          "WPFTweaksRecallOff",
                          "WPFTweaksLoc",
                          "WPFTweaksDVR",
                          "WPFTweaksStorage",
                          "WPFTweaksDisableExplorerAutoDiscovery"
                      ],
        "Install":  [
                        {
                            "winget":  "Vencord.Vesktop",
                            "choco":  "na"
                        },
                        {
                            "winget":  "Mozilla.Thunderbird",
                            "choco":  "thunderbird"
                        },
                        {
                            "winget":  "Microsoft.NuGet",
                            "choco":  "nuget.commandline"
                        },
                        {
                            "winget":  "Microsoft.VisualStudioCode",
                            "choco":  "vscode"
                        },
                        {
                            "winget":  "Nushell.Nushell",
                            "choco":  "nushell"
                        },
                        {
                            "winget":  "Microsoft.PowerShell",
                            "choco":  "powershell-core"
                        },
                        {
                            "winget":  "BurntSushi.ripgrep.MSVC",
                            "choco":  "ripgrep"
                        },
                        {
                            "winget":  "Alacritty.Alacritty",
                            "choco":  "alacritty"
                        },
                        {
                            "winget":  "Microsoft.Teams",
                            "choco":  "microsoft-teams"
                        },
                        {
                            "winget":  "Neovim.Neovim",
                            "choco":  "neovim"
                        },
                        {
                            "winget":  "PuTTY.PuTTY",
                            "choco":  "putty"
                        },
                        {
                            "winget":  "Microsoft.WindowsTerminal",
                            "choco":  "microsoft-windows-terminal"
                        },
                        {
                            "winget":  "EpicGames.EpicGamesLauncher",
                            "choco":  "epicgameslauncher"
                        },
                        {
                            "winget":  "Bitwarden.Bitwarden",
                            "choco":  "bitwarden"
                        },
                        {
                            "winget":  "Ventoy.Ventoy",
                            "choco":  "ventoy"
                        },
                        {
                            "winget":  "Microsoft.PowerToys",
                            "choco":  "powertoys"
                        },
                        {
                            "winget":  "Zen-Team.Zen-Browser",
                            "choco":  "na"
                        },
                        {
                            "winget":  "Valve.Steam",
                            "choco":  "steam-client"
                        },
                        {
                            "winget":  "Mozilla.Firefox",
                            "choco":  "firefox"
                        },
                        {
                            "winget":  "Git.Git",
                            "choco":  "git"
                        },
                        {
                            "winget":  "GitHub.cli",
                            "choco":  "git;gh"
                        },
                        {
                            "winget":  "VideoLAN.VLC",
                            "choco":  "vlc"
                        },
                        {
                            "winget":  "Element.Element",
                            "choco":  "element-desktop"
                        },
                        {
                            "winget":  "VSCodium.VSCodium",
                            "choco":  "vscodium"
                        },
                        {
                            "winget":  "junegunn.fzf",
                            "choco":  "fzf"
                        },
                        {
                            "winget":  "ItchIo.Itch",
                            "choco":  "itch"
                        },
                        {
                            "winget":  "Spotify.Spotify",
                            "choco":  "spotify"
                        },
                        {
                            "winget":  "Python.Python.3.12",
                            "choco":  "python"
                        },
                        {
                            "winget":  "Microsoft.Edge",
                            "choco":  "microsoft-edge"
                        },
                        {
                            "winget":  "sharkdp.bat",
                            "choco":  "bat"
                        },
                        {
                            "winget":  "SlackTechnologies.Slack",
                            "choco":  "slack"
                        },
                        {
                            "winget":  "Docker.DockerDesktop",
                            "choco":  "docker-desktop"
                        },
                        {
                            "winget":  "starship",
                            "choco":  "starship"
                        }
                    ],
        "WPFInstall":  [
                           "WPFInstallvesktop",
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
                           "WPFInstalldockerdesktop",
                           "WPFInstallstarship"
                       ],
        "WPFFeature":  [
                           "WPFFeatureEnableLegacyRecovery",
                           "WPFFeatureDisableSearchSuggestions",
                           "WPFFeaturesSandbox",
                           "WPFFeaturewsl",
                           "WPFFeatureshyperv"
                       ]
    }'

    Write-Host
    Write-Host "Running winutil"

    $tempFile = New-TemporaryFile
    $winutilCfg | Out-File -FilePath $tempFile

    # manual install
    # irm https://christitus.com/win | iex


    # irm christitus.com/win -Config $tempFile -Run -Debug | iex
    # iex "& { $(irm christitus.com/win) } 
    iex "& { $(irm christitus.com/windev) } -Config $tempFile -Run"
}


# not needed use the auto resize vm instead
# function set-display-res {
#     Write-Host
#     Write-Host "Setting display res"
#     Install-Module -Name DisplaySettings
#     Set-DisplayResolution -Width 1920 -Height 1200
# }

# change default browser to firefox
function set-default-browser {
    Write-Host
    Write-Host "Setting default browser"
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
    Write-Host
    Write-Host "Disabling startup apps"

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


Set-ExecutionPolicy Unrestricted -Scope Process -Force

run-winutil

# Write-Host "Activating windows and ms office"
& ([ScriptBlock]::Create((irm https://get.activated.win))) /HWID /Ohook 

set-default-browser

# install spice guest tools
choco install spice-agent -y

disable-startup-apps

choco install winfsp -y
choco install qemu-guest-agent -y

pnputil /add-driver E:\*.inf /install /subdirs

# REF: https://braheezy.github.io/posts/some-things-virtiofs-and-windows/
Invoke-WebRequest https://github.com/winfsp/winfsp/releases/download/v1.10/winfsp-1.10.22006.msi -OutFile winfsp-1.10.22006.msi
winfsp-1.10.22006.msi /qn /norestart

pnputil /install /add-driver E:\viofs\w11\amd64\viofs.inf

cp E:\viofs\w11\amd64\virtiofs.exe C:\Windows\virtiofs.exe
New-Service `
    -Name "VirtioFsSvc" `
    -BinaryPathName "C:\Windows\virtiofs.exe" `
    -DisplayName "Virtio FS Service" `
    -Description "Enables Windows virtual machines to access directories on the host that have been shared with them using virtiofs." `
    -StartupType Automatic `
    -DependsOn "WinFsp.Launcher"


