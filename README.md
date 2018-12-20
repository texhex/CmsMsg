# CmsMsg

Example for using PowerShell CmsMessage cmdlets

## About

[Protect-CmsMessage](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/protect-cmsmessage?view=powershell-5.1) and [Unprotect-CmsMessage](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/unprotect-cmsmessage?view=powershell-5.1) are default PowerShell 5.1 cmdlets for asymmetric cryptography based on [RFC5652](https://tools.ietf.org/html/rfc5652).

In a nutshell, they use the public key from a certificate to encrypt data and use the private key of the same certificate to decrypt the data again. Since public keys can be distributed widely, this allows you to easily encrypt sensitive data and transfer the encrypted data using unsecure channels.

A good starting point to learn more about it are [PowerShell V5 New Feature: Protect/Unprotect-CmsMessage](https://rkeithhill.wordpress.com/2015/01/08/powershell-v5-new-feature-protectunprotect-cmsmessage/) by Keith Hill and [PowerShell: Encrypt and Decrypt Data by using Certificates (Public Key / Private Key)](https://sid-500.com/2017/10/29/powershell-encrypt-and-decrypt-data/) by Patrick Gruenauer.

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
    -KeyUsage KeyEncipherment, DataEncipherment, KeyAgreement 

write-host "New Cert [$($cert.Subject)] with Thumbprint [$($cert.Thumbprint)] created"
```



<!--
Not used:
[Creating certificate requests and certificates for vCenter Server 5.1 components (2037432)](https://kb.vmware.com/s/article/2037432)
[OpenSSL generate different types of self signed certificate](https://security.stackexchange.com/questions/44251/openssl-generate-different-types-of-self-signed-certificate)

Other notes:
[SSL and TLS Deployment Best Practices](https://github.com/ssllabs/research/wiki/SSL-and-TLS-Deployment-Best-Practices)

https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet

[How to create a self-signed certificate with openssl](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)

[Protect-CmsMessage (Api Docs)](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/protect-cmsmessage?view=powershell-5.1)

[PowerShell: Encrypt and Decrypt Data by using Certificates (Public Key / Private Key)](https://sid-500.com/2017/10/29/powershell-encrypt-and-decrypt-data/)

[PowerShell: Encrypt and store your Passwords and use them for Remote Authentication (Protect-CmsMessage)](https://sid-500.com/2018/02/24/powershell-encrypt-and-store-your-passwords-and-use-them-for-remote-authentication-protect-cmsmessage/)

[PowerShell Protect-CmsMessage Example Code, Limitations and Errors](https://cyber-defense.sans.org/blog/2015/08/23/powershell-protect-cmsmessage-example-code/comment-page-1/)

-->
