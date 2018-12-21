<#
 Copyright (c) 2018 Michael 'Tex' Hex 
 Licensed under the Apache License, Version 2.0
 https://github.com/texhex/CmsMsg
#>

write-host "CmsMsg: ImportBase64PfxCertificate 1.03"

#This script requires PowerShell 5.1 or higher 
#requires -version 5.1

#Guard against common code errors
Set-StrictMode -version Latest

$ErrorActionPreference = 'Stop'

#Password used for the PFX file
#Set-Variable PFX_PASSWORD "CmsMsg42!" -option ReadOnly -Force


write-host "Please paste the Base64 encoded PFX certificate (CTRL+V) - an empty line will stop the input."
$inputList = New-Object System.Collections.ArrayList
$input = ""

Do
{
    $userInput = Read-Host -Prompt ":"

    if ( $userInput -ne $null )
    {
        $userInput = $userInput.Trim()

        if ( $userInput.Length -gt 0 )
        {    
            $inputList.Add($userInput) | Out-Null
        }
        else
        {
            $userInput = $null
        }
    }

}
while ( $userInput -ne $null )


if ( $inputList.Count -gt 0 )
{
    #We have some data we can work on    
    $base64Data = ""

    foreach ($input in $inputList) 
    {
        $base64Data += $input
    }

    write-host "Trying to Base64-decode the input..."
    $content = [System.Convert]::FromBase64String($base64Data)
    
    $tempFolder = [System.IO.Path]::GetTempPath()
    $pfxFilename = "$($tempFolder)temp.pfx"

    write-host "Writing PFX file to $pfxFilename..."
    Set-Content -Path $pfxFilename -Encoding Byte -Value $content

    $pwd = Get-Credential -Username "(PFX Password)" -Message 'Please enter the password to open the PFX file'

    write-host "Trying to import PFX file with the given password..."
    $cert = Import-PfxCertificate -FilePath $pfxFilename -CertStoreLocation "Cert:\CurrentUser\My" -Password $pwd.Password
    #Access denied. (Exception from HRESULT: 0x80090010) -> No access to cert store

    write-host "Cert [$($cert.Subject)] with Thumbprint [$($cert.Thumbprint)] imported to personal certificates"

    write-host "Deleting temporary PFX file..."
    Remove-Item -LiteralPath $pfxFilename -Force -ErrorAction Stop
}

write-host "Script finished"
