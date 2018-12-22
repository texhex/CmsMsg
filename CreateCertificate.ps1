<#
 Copyright (c) 2018 Michael 'Tex' Hex 
 Licensed under the Apache License, Version 2.0
 https://github.com/texhex/CmsMsg
#>

write-host "CmsMsg: CreateCertificate 1.05"

#This script requires PowerShell 5.1 or higher 
#requires -version 5.1

#Guard against common code errors
Set-StrictMode -version Latest

#--CONFIG-----------------------

#Name to be used for the certificate (IssuedTo/Subject)
Set-Variable CERT_NAME "CmsMsgExample" -option ReadOnly -Force

#A description for this certificate (FriendlyName)
Set-Variable CERT_DESC "Example certificate for CmsMsg" -option ReadOnly -Force

#Password used for the PFX file
Set-Variable PFX_PASSWORD "CmsMsg42!" -option ReadOnly -Force

#-------------------------------

#Calculate NotBefore and NotAfter dates
#Set NotBefore to yesterday and NotAfter to 2099
$notBefore = (Get-Date).AddDays(-1)
$notAfter = Get-Date -Year 2099 -Month 12 -Day 31

#Create a self-signed certificate to be used for the CmsMessage cmdlets
#It will be stored in the current users Personal\Certificates store (see certmgr.msc)
$cert = New-SelfSignedCertificate `
    -DnsName $CERT_NAME `
    -FriendlyName $CERT_DESC `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyLength 3072 `
    -HashAlgorithm "Sha384" `
    -NotBefore $notBefore `
    -NotAfter $notAfter `
    -Type DocumentEncryptionCert `
    -KeyUsage KeyEncipherment, DataEncipherment

write-host "New Cert [$($cert.Subject)] with serial [$($cert.SerialNumber)] and thumbprint [$($cert.Thumbprint)] created"

$exportFolder = [environment]::GetFolderPath("mydocuments")
write-host "Exporting certificate files to $exportFolder..."

$fileNameNoExtension = "$($exportFolder)\$($cert.Subject)"

#Export public certificate to the current users document 
Export-Certificate -Cert $cert -FilePath "$($fileNameNoExtension).cer" | Out-Null

#Export private certificate as PFX - for this, we require a password
$pwd = ConvertTo-SecureString -String $PFX_PASSWORD -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "$($fileNameNoExtension).pfx" -Password $pwd | Out-Null

#Convert the PFX to Base64 in order to store it as text in a password manager 
$pfxFileBytes = Get-Content "$($fileNameNoExtension).pfx" -Encoding Byte -ReadCount 0 
[System.Convert]::ToBase64String($pfxFileBytes, [System.Base64FormattingOptions]::InsertLineBreaks) | Out-File "$($fileNameNoExtension).pfx-base64.txt"

#DELETE this certificate from the local store to ensure that an import is required which 
#is a good test if we were able to export the certificate correctly
write-host "Deleting certificate from certificate stores..."
Get-ChildItem "Cert:\CurrentUser\My\$($cert.Thumbprint)" | Remove-Item

#New-SelfSignedCert also creates a certificate in Intermediate Certification Authorities (CA)
#We delete this as well
Get-ChildItem "Cert:\CurrentUser\CA\$($cert.Thumbprint)" | Remove-Item

#Side note: For a list of all certificate stores and their names in PowerShell, see:
#https://stackoverflow.com/a/40441687


write-host "All done"
