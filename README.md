# CmsMsg

And example for using PowerShell CmsMessage cmdlets

## About

[Protect-CmsMessage](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/protect-cmsmessage?view=powershell-5.1) and [Unprotect-CmsMessage](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/unprotect-cmsmessage?view=powershell-5.1) are default PowerShell 5.1 cmdlets for asymmetric cryptography based on [RFC5652](https://tools.ietf.org/html/rfc5652).

In a nutshell, they use the public key from a certificate to encrypt data and use the private key of the same certificate to decrypt the data again. Since public keys can be distributed widely, this allows you to encrypt sensitive information and transfer the encrypted data using unsecure channels.

A good starting point to learn more about it are [PowerShell V5 New Feature: Protect/Unprotect-CmsMessage](https://rkeithhill.wordpress.com/2015/01/08/powershell-v5-new-feature-protectunprotect-cmsmessage/) by Keith Hill and [PowerShell: Encrypt and Decrypt Data by using Certificates (Public Key / Private Key)](https://sid-500.com/2017/10/29/powershell-encrypt-and-decrypt-data/) by Patrick Gruenauer.

## Limitations

The CmdMessage cmdlets have several limitations. They only support “text” (XML, CSV etc.) files, so if you have binary data, you will need to Base64 encode it first. Also, the operation only works reliable for small amounts of data and is rather slow.

For details, please see “Limitations, Performance and Error Messages” in [PowerShell Protect-CmsMessage Example Code, Limitations and Errors]( https://cyber-defense.sans.org/blog/2015/08/23/powershell-protect-cmsmessage-example-code/comment-page-1/) by Jason Fossen.

## Creating the certificate

To begin, we need a certificate and the easiest way is to create a self-signed one. For this command, the following notes apply:

* The CmsMessage cmdlets require some additional properties that the certificate has to offer. For that, the parameters `Type` and `KeyUsage` are used

* By default, `New-SelfSignedCertificate` will create a certificate that is valid two years. We change this end date to 2099, given that we need to take care of certificate distribution ourselves anyway.

* Also, the *Valid from* date will be set to yesterday to ensure that the certificate will also immediately work on machines that are in a different time zone where “today” is still “yesterday”

* The certificate will use an RSA public key. 2048-bit keys are today (End 2018) considered sufficient secure (see [SSL and TLS Deployment Best Practices]( https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)). As this certificate might be used for several years, we change this to 3072-bit to be safe although it will cost some extra CPU cycles.

* The hash algorithm will be set to SHA-384 as OWASP recommends in their [TLS Cipher Cheat Sheet](https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet)

This is command used in [CreateCertficate.ps1](/CreateCertificate.ps1):

```powershell
$notBefore = (Get-Date).AddDays(-1)
$notAfter = Get-Date -Year 2099 -Month 12 -Day 31

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
```

Once you have run [CreateCertficate.ps1](/CreateCertificate.ps1), it will create the following files in your *Documents* folder. Please note that the script will overwrite these files without warning.

* The file `CN=CmsMsgExample.cer` which **only** contains the public key of this certificate and can be freely distributed
* The file `CN=CmsMsgExample.pfx` which is an export of the entire certificate, so it contains both the public and private key
* The file `CN=CmsMsgExample.pfx-base64.txt` which is the same as the PFX file, but Base64 encoded so you can store the certificate in password safes

Only the CER file should be distributed, the PFX files are required to be kept private.



## Importing the certificate

After running the creation script, you have the required certificate to start using the CmsMessage cmdlets. In order to decrypt any data, that was encrypted with the generated CER file, you need to have the full certificate (PFX - public and private) in your local certificate store. 

The first option to do this is to import the PFX file using the build-in certificate management:

* Start `CertMgr.msc`
* Go to *Personal* -> *Certificates*
* Right click the right panel where the certificates are listed (without selecting any existing certificate), then select *All Tasks* -> *Import...*
* Follow the instructions of the wizard and when prompted, select the PFX file the script has created
* Please note that you need to select the PFX file, **not** the CER file. By default, the file open dialog will not show PFX files, so you need to select “Personal information exchange” (PFX) in that dialog
* If the wizard asks you for a password, the default password the script uses is *CmsMsg42!*
* If the wizard does **not** ask you for a password, you selected the wrong file

Please note however, that you will need some sort of backup in case your device breaks down and the certificate is lost. You can of course store the PFX file in a safe place (e.g. on the network or on a NAS), but the security of the PFX file is then depending on the security of that system and/or your backup system.

The recommended way is to **DELETE** the PFX file and store the text (Base64-encoded) representation of the PFX file in a password safe, for example KeePass to add another layer of protection. To do this, open `CN=CmsMsgExample.pfx-base64.txt` and copy the content of it to your password manager.

To import this Base64-encoded text, do the following:

* Open `CN=CmsMsgExample.pfx-base64.txt` with a text editor and copy the entire text to your clipboard (CTRL+A followed by CTRL+C)
* Start `ImportBase64PfxCertificate.ps1` and paste the text (CTRL+V). When done, press RETURN once to stop the input
* Enter the password for this PFX file; the default password the script uses is *CmsMsg42!*
* The certificate is imported in your certificate store *Personal* -> *Certificates* (use `CertMgr.msc` to view it)
* Open it and make sure it shows “You have a private key for this certificate”








## Contributions

Any constructive contribution is very welcome. If you encounter a bug or found something that is not correct, please create a [new issue](https://github.com/texhex/CmsMsg/issues/new).

## License

Copyright © 2018 [Michael Hex](http://www.texhex.info/). Licensed under the **Apache 2 License**. For details, please see LICENSE.txt.

<!--
Not used:
[Creating certificate requests and certificates for vCenter Server 5.1 components (2037432)](https://kb.vmware.com/s/article/2037432)
[OpenSSL generate different types of self signed certificate](https://security.stackexchange.com/questions/44251/openssl-generate-different-types-of-self-signed-certificate)

Other notes:
[How to create a self-signed certificate with openssl](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)


[PowerShell: Encrypt and store your Passwords and use them for Remote Authentication (Protect-CmsMessage)](https://sid-500.com/2018/02/24/powershell-encrypt-and-store-your-passwords-and-use-them-for-remote-authentication-protect-cmsmessage/)
-->
