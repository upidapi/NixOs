function Invoke-InSubShell {
    param(
        [ScriptBlock]$ScriptBlock,
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )

    # Create a temporary PowerShell script file
    $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
    $ScriptBlock | Out-File -FilePath $tempFile -Encoding UTF8

    try {
        # Run the temporary script in a new PowerShell process with arguments
        $argList = $Args | ForEach-Object { "'$_'" } -join ' '
        $process = Start-Process powershell `
            -NoNewWindow -Wait -PassThru `
            -ArgumentList "-NoProfile -File `"$tempFile`" $argList"

        return $process.ExitCode
    }
    finally {
        # Clean up temporary file
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
}


$script = "Write-Output 'test'"
Invoke-InSubShell ([Scriptblock]::Create($script))
