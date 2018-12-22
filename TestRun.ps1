<#
 Copyright (c) 2018 Michael 'Tex' Hex 
 Licensed under the Apache License, Version 2.0
 https://github.com/texhex/CmsMsg
#>

write-host "CmsMsg: TestRun 1.02"

#Important: The current location (set-location) must be set to a file path or
#Protect-CmsMessage will not accept thumbprint searching ("..must resolve to a file system path.")


$clearText="Böttöm secret!"
$ciphertext=""
$plaintext=""

write-host "** Clear text ******************************"
write-host $clearText
write-host "********************************************"

#Encrypting data can be done:

#Using the thumbprint of a certificate that is installed
#  $ciphertext = Protect-CmsMessage -Content $cleartext -To "9B31F550C62FD2B70F50F21E11B8ADC97692D6D1"

#By reading a CER file and using that directly:
#  $cert=New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
#  $cert.Import("$myDocFolder\CN=CmsMsgExample.cer")
#  $ciphertext = Protect-CmsMessage -Content $cleartext -To $cert
#  write-host "Encrypted to [$($cert.Subject)] with Thumbprint [$($cert.Thumbprint)]:"

#By using a CER file directly
$myDocFolder = [environment]::GetFolderPath("mydocuments")
$cipherText = Protect-CmsMessage -Content $clearText -To "$myDocFolder\CN=CmsMsgExample.cer"


write-host "** Encoded CMS Message *********************"
write-host $cipherText
write-host "********************************************"

write-host "** Selected CMS Message Properties *********"
$msg=Get-CmsMessage -Content $cipherText

#Get the first recipient from this message
$firstRecipient=$msg.RecipientInfos[0]

write-host " "
write-host "First recipient type..: $($firstRecipient.RecipientIdentifier.Type.ToString())"
write-host "First recipient issuer: $($firstRecipient.RecipientIdentifier.Value.IssuerName)"
write-host "First recipient serial: $($firstRecipient.RecipientIdentifier.Value.SerialNumber)"
write-host " "
write-host "First recipient key encryption algorithm: $($firstRecipient.KeyEncryptionAlgorithm.Oid.FriendlyName)"
write-host "Content encryption algorithm used for this message: $($msg.ContentEncryptionAlgorithm.Oid.FriendlyName)"
write-host "********************************************"


#Decrypting data ONLY works when the certificate with the private key is installed. 
#Else, it will throw the error:
# "The enveloped-data message does not contain the specified recipient."
#In case you only have the public key installed (not the full certificate with the private key), it will throw:
# "Cannot find object or property."
$plaintext = Unprotect-CmsMessage -Content $ciphertext 

write-host "** Decrypted text **************************"
write-host $plainText
write-host "********************************************"


