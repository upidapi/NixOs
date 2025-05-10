function refresh-path {
    $env:Path = 
        [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
        [System.Environment]::GetEnvironmentVariable("Path","User")
}


# winutil tweaks
Set-ExecutionPolicy Unrestricted -Scope Process -Force
irm https://christitus.com/win | iex

# set the res of display
Install-Module -Name DisplaySettings
Set-DisplayResolution -Width 1920 -Height 1200


# change browser to firefox
choco install SetDefaultBrowser -y
SetDefaultBrowser firefox

