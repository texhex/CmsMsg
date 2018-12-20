﻿<#
 CmsMsg: CreateCertificate 1.0
 Copyright (c) 2018 Michael 'Tex' Hex 
 Licensed under the Apache License, Version 2.0. 

 https://github.com/texhex/CmsMsg
#>

#This script requires PowerShell 5.1 or higher 
#requires -version 5.1

#Guard against common code errors
Set-StrictMode -version Latest

#Password used for the PFX file
Set-Variable PFX_PASSWORD "Secure42!" -option ReadOnly -Force

#Calculate NotBefore and NotAfter dates:
#Set NotBefore to yesterday and NotAfter to 2099
$notBefore = (Get-Date).AddDays(-1)
$notAfter = Get-Date -Year 2099 -Month 12 -Day 31

#Create a self-signed certificate to be used for the CmsMessage cmdlets
#It will be stored in the current users Personal\Certificates store (see certmgr.msc)
$cert = New-SelfSignedCertificate `
    -DnsName "CmsMsgExample" `
    -FriendlyName "Example certificate for CmsMsg" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyLength 3072 `
    -HashAlgorithm "Sha384" `
    -NotBefore $notBefore `
    -NotAfter $notAfter `
    -Type DocumentEncryptionCert `
    -KeyUsage KeyEncipherment, DataEncipherment

write-host "New Cert [$($cert.Subject)] with Thumbprint [$($cert.Thumbprint)] created"

$exportFolder = [environment]::GetFolderPath("mydocuments")
write-host "Exporting certificate to $exportFolder..."


$fileNameNoExtension = "$($exportFolder)\$($cert.Subject)"

#Export public certificate to the current users document 
Export-Certificate -Cert $cert -FilePath "$($fileNameNoExtension).cer" | Out-Null

#Export private certificate as PFX - for this, we require a password
$pwd = ConvertTo-SecureString -String $PFX_PASSWORD -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "$($fileNameNoExtension).pfx" -Password $pwd | Out-Null

#Finally, convert the PFX to Base64 in order to store it as text in a password manager 
$pfxBase64 = Get-Content "$($fileNameNoExtension).pfx" -Encoding Byte -ReadCount 0 
[System.Convert]::ToBase64String($pfxBase64, [System.Base64FormattingOptions]::InsertLineBreaks) | Out-File "$($fileNameNoExtension).pfx-base64.txt"


#Create PFX from Base64
$pfxBase64Encoded = Get-Content "$($fileNameNoExtension).pfx-base64.txt" -ReadCount 0 
[System.Convert]::FromBase64String($pfxBase64Encoded) | Set-Content -Path "$($fileNameNoExtension).pfx2" -Encoding Byte
 

write-host "All done"