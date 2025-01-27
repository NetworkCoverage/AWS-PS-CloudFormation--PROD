#!/bin/bash
if [[ $(sudo cz-config status | jq -r .roles.controller.status) == "healthy" ]]; then 
   publicHostname=$(curl --silent http://169.254.169.254/latest/meta-data/public-hostname)
   response=$(curl --insecure --location --request POST "https://$publicHostname:8443/admin/login" \
   --header "Content-Type: application/json" \
   --header "Accept: application/vnd.appgate.peer-v19+json" \
   --data '{
       "providerName": "local",
       "username": "admin",
       "password": "Password1",
       "deviceId": "4c07bc67-57ea-42dd-b702-c2d6c45419fd"
   }')

   token=$(echo $response | jq -r '.token')

   # identity provider
   curl --insecure --location --request POST "https://$publicHostname:8443/admin/identity-providers" \
   --header "Content-Type: application/json" \
   --header "Accept: application/vnd.appgate.peer-v19+json" \
   --header "Authorization: Bearer $token" \
   --data '{
       "name": "CustomerName Admin",
       "notes": "CustomerName Admin SAML IDP",
       "tags": [
           "CustomerName"
       ],
       "adminProvider": true,
       "type": "Saml",
       "enforceWindowsNetworkProfileAsDomain": false,
       "claimMappings": [
           {
           "attributeName": "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups",
           "claimName": "cg_CustomerName",
           "list": true,
           "encrypt": false
           },
           {
           "attributeName": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
           "claimName": "email",
           "list": false,
           "encrypt": false
           },
           {
           "attributeName": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname",
           "claimName": "lastname",
           "list": false,
           "encrypt": false
           },
           {
           "attributeName": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname",
           "claimName": "firstname",
           "list": false,
           "encrypt": false
           },
           {
           "attributeName": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
           "claimName": "username",
           "list": false,
           "encrypt": false
           }
       ],
       "redirectUrl": "https://login.microsoftonline.com/899559e3-e33e-4d06-9dc9-dd8845ad727e/saml2",
       "forceAuthn": false,
       "audience": "NCAppgateGlobalAdmin-Identifier",
       "issuer": "https://sts.windows.net/899559e3-e33e-4d06-9dc9-dd8845ad727e/",
       "providerCertificate": "-----BEGIN CERTIFICATE-----\nMIIC8DCCAdigAwIBAgIQTcMe/2VUIqpBnMPhVhYC8DANBgkqhkiG9w0BAQsFADA0\nMTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZp\nY2F0ZTAeFw0yMzExMTMxOTQ1MjRaFw0yNjExMTMxOTQ1MjVaMDQxMjAwBgNVBAMT\nKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjAN\nBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxR1i84yPqNDL4jEysuKfkNBv/c3E\nDGkFv2B81gYyh89UTzvG4FEz9Jsfr1q1XsN9vzZNvWz82f/R3ZUPTtEpUbhBRzFl\nnaWelX2C9d4wggSkwgzlqpC7EKbzatjEdaXRC4ns+JWJyceEEr9ZzeZwW+GJWeJp\nBMG1056NgpkC4wJDe94rMJ4V0dJ9T4rbeN3gQNzP7tKexIgBDWwO8NLi0xr+YphO\n4dyI3jM/pc6X/cvo7u8cdtuuFS6vR3QJXJptbukjfP8CWRCi6wzgT/HqT4iYoDLH\nWTYtuZyWYL9/AalRiTqBiwSVYFLGf9Y12RuLSYMLM2rDVt0brPt6C0cnbQIDAQAB\nMA0GCSqGSIb3DQEBCwUAA4IBAQBqYtXo6cvWjrzdI9QrHIcpRRfXIVEzV7Q5lbUP\n01zqLpxM34MlBGKYn+VkUbAqdtCxcmL5ifWYylb2rYwdMfSzbbj5gC2OnSyXDkSv\nFxXzWXvEkWPyKJyaDRzjejQUrY60xEm/OKcCGhH25IxaJVVxFivHEMFJD0TOZm+d\nFwsKdcALQahfW6XQqawmAizM4b+5gctHiL8cMEVH3Qht/R9hGm1kE37XPVqezcgE\ndaS99pd+ovDK4FmHXrFGT41ilgwyJv+eE0C7qrywZHH+k/FtkdyCaHnPGq8UTHir\nsvFjf+7RrqM98+FI3AMiI1BrKghzI/5pwZwxNGOgvJRzEO/e\n-----END CERTIFICATE-----"
   }'

   # remove the cronjob
    sudo crontab -l > mycron
    grep -v post-install.sh mycron > mycron.new
    sudo crontab mycron.new
    rm mycron
    rm mycron.new
fi





   # view admin policy
   curl --insecure --location --request POST "https://$publicHostname:8443/admin/policies" \
   --header "Content-Type: application/json" \
   --header "Accept: application/vnd.appgate.peer-v19+json" \
   --header "Authorization: Bearer $token" \
   --data '{
       "name": "CustomerName View Administration",
       "notes": "CustomerName View Administration Policy",
       "tags": [
           "customername"
       ],
       "expression": "//Generated by criteria builder, Operator: and\nvar result = false;\nif/*identity-provider*/(claims.user.ag.identityProviderId === \"'"$idpid"'\")/*end identity-provider*/ { result = true; } else { return false; }\nif/*claims.user.cg_customername*/(claims.user.cg_customername && claims.user.cg_customername.indexOf(\"Appgate-MultiTenant-ViewAdmins-CompliantAccess\") >= 0)/*end claims.user.cg_customername*/ { result = true; } else { return false; }\nreturn result;",
       "type": "Admin",
       "administrativeRoles": [
           "'"$viewroleid"'"
       ]
   }'