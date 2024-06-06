#!/bin/bash
adminPass=Password1
profileHostname="sdp-controllers.mydomain.com"
publicHostname=$(curl --silent http://169.254.169.254/latest/meta-data/public-hostname)

cz-seed \
    --dhcp-ipv4 eth0 \
    --profile-hostname "$profileHostname" \
    --hostname "$publicHostname" \
    --admin-hostname "$publicHostname" \
    --ntp-server 169.254.169.123 \
    --admin-password $adminPass > /home/cz/seed.json


# login
response=$(curl --insecure --location --request POST "https://$publicHostname:8443/admin/login" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--data '{
  "providerName": "local",
  "username": "admin",
  "password": "grea+Night68",
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
        "customername"
    ],
    "adminProvider": true,
    "type": "Saml",
    "enforceWindowsNetworkProfileAsDomain": false,
    "claimMappings": [
        {
        "attributeName": "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups",
        "claimName": "cg_customername",
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

# full admin role
fullrole=$(curl --insecure --location --request POST "https://$publicHostname:8443/admin/administrative-roles" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
    "name": "CustomerName Full Administration Template",
    "notes": "CustomerName Administrative Role that has full access for US only.",
    "tags": [
      "customername"
    ],
    "privileges": [
      {
        "type": "All",
        "target": "IpPool",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername",
            "default"
          ]
        }
      },
      {
        "type": "All",
        "target": "OtpSeed",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Policy",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "RegisteredDevice",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "RingfenceRule",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "SessionInfo",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Site",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "TokenRecord",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "TrustedCertificate",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "UserClaimScript",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "UserLicense",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "Create",
        "target": "All",
        "scope": {
          "all": false,
          "ids": [],
          "tags": []
        },
        "defaultTags": [
          "customername"
        ]
      },
      {
        "type": "View",
        "target": "AdminMessage",
        "scope": {
          "all": false,
          "ids": [],
          "tags": []
        }
      },
      {
        "type": "All",
        "target": "AllocatedIp",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Appliance",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customernamefulladmin",
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "ApplianceCustomization",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Blacklist",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "ClientProfile",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Condition",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "CriteriaScript",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "DeviceClaimScript",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Entitlement",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "EntitlementScript",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "FailedAuthentication",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "Fido2Device",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "All",
        "target": "IdentityProvider",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      }
    ]
  }')

fullroleid=$(echo $fullrole | jq -r '.id')

# full admin policy
curl --insecure --location --request POST "https://$publicHostname:8443/admin/policies" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
      "name": "CustomerName Full Administration",
      "notes": "CustomerName Full Administration Policy",
      "tags": [
        "customername"
      ],
      "expression": "//Generated by criteria builder, Operator: and\nvar result = false;\nif/*identity-provider*/(claims.user.ag.identityProviderId === \"ff265e89-04ea-485b-a3d1-2fd090c7d696\")/*end identity-provider*/ { result = true; } else { return false; }\nif/*claims.user.cg_alku*/(claims.user.cg_alku && claims.user.cg_alku.indexOf(\"Appgate-MultiTenant-Admins-CompliantAccess\") >= 0)/*end claims.user.cg_alku*/ { result = true; } else { return false; }\nreturn result;",
      "type": "Admin",
      "administrativeRoles": [
        "54ff882d-cc4a-4120-92ef-3f4f4bf51d93"
      ]
    }'


# view admin role
viewrole=$(curl --insecure --location --request POST "https://$publicHostname:8443/admin/administrative-roles" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
    "name": "CustomerName View Administration Template",
    "notes": "",
    "tags": [
      "customername"
    ],
    "privileges": [
      {
        "type": "Export",
        "target": "ClientProfile",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "View",
        "target": "Policy",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "View",
        "target": "AdminMessage",
        "scope": {
          "all": false,
          "ids": [],
          "tags": []
        }
      },
      {
        "type": "Delete",
        "target": "Fido2Device",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "Delete",
        "target": "OtpSeed",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "CheckStatus",
        "target": "Appliance",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "Reboot",
        "target": "Appliance",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      },
      {
        "type": "View",
        "target": "All",
        "scope": {
          "all": false,
          "ids": [],
          "tags": [
            "customername"
          ]
        }
      }
    ]
  }')

veiewroleid=$(echo $viewrole | jq -r '.id')

# view admin policy
curl --insecure --location --request POST "https://$publicHostname:8443/admin/policies" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
      "name": "CustomerName View Administration",
      "notes": "CustomerName View Administration Policy"",
      "tags": [
        "customername"
      ],
      "expression": "//Generated by criteria builder, Operator: and\nvar result = false;\nif/*identity-provider*/(claims.user.ag.identityProviderId === \"ff265e89-04ea-485b-a3d1-2fd090c7d696\")/*end identity-provider*/ { result = true; } else { return false; }\nif/*claims.user.cg_alku*/(claims.user.cg_alku && claims.user.cg_alku.indexOf(\"Appgate-MultiTenant-ViewAdmins-CompliantAccess\") >= 0)/*end claims.user.cg_alku*/ { result = true; } else { return false; }\nreturn result;",
      "type": "Admin",
      "administrativeRoles": [
        "eb3aed8b-c4ef-42b2-9c68-384ff259b6ad"
      ]      
    }'


##### gateway commands

response=$(curl --insecure --location --request POST "https://ec2-18-205-213-157.compute-1.amazonaws.com:8443/admin/login" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--data '{
  "providerName": "local",
  "username": "admin",
  "password": "Password1",
  "deviceId": "4c07bc67-57ea-42dd-b702-c2d6c45419fd"
}')

token=$(echo $response | jq -r '.token')
echo $token

appliance=$(curl --insecure --location --request POST "https://ec2-18-205-213-157.compute-1.amazonaws.com:8443/admin/appliances" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
    "name": "test",
    "hostname": "test.example.com",
    "site": "8a4add9e-0e99-4bb1-949c-c9faf9a49ad4",
    "gateway": {
        "enabled": true,
        "suspended": false,
        "vpn": {
            "allowDestinations": [
                {
                    "address": null,
                    "netmask": null,
                    "nic": "eth0"
                }
            ],
            "weight": 100,
            "localWeight": null
        }
    },
    "networking": {
        "dnsServers": [],
        "dnsDomains": [],
        "hosts": [],
        "nics": [
            {
                "enabled": true,
                "name": "eth0",
                "mtu": null,
                "ipv4": {
                    "dhcp": {
                        "enabled": true,
                        "dns": true,
                        "routers": true,
                        "ntp": false,
                        "mtu": false
                    },
                    "static": [],
                    "virtualIp": null
                },
                "ipv6": {
                    "dhcp": {
                        "enabled": false,
                        "dns": true,
                        "routers": true,
                        "ntp": false,
                        "mtu": false
                    },
                    "static": [],
                    "virtualIp": null
                }
            }
        ],
        "routes": []
    },
    "sshServer": {
        "enabled": true,
        "passwordAuthentication": true,
        "port": 22,
        "allowSources": [
            {
                "address": "0.0.0.0",
                "netmask": 0
            },
            {
                "address": "::",
                "netmask": 0
            }
        ]
    },
    "clientInterface": {
        "hostname": "test.example.com",
        "localHostname": null,
        "dtlsPort": 443,
        "httpsPort": 443,
        "proxyProtocol": false,
        "allowSources": [
            {
                "address": "0.0.0.0",
                "netmask": 0
            },
            {
                "address": "::",
                "netmask": 0
            }
        ],
        "overrideSpaMode": null
    }
}')

id=$(echo $appliance | jq -r '.id')
echo $id

curl --insecure --location --request POST "https://ec2-18-205-213-157.compute-1.amazonaws.com:8443/admin/appliances/$id/export" \
--header "Content-Type: application/json" \
--header "Accept: application/vnd.appgate.peer-v19+json" \
--header "Authorization: Bearer $token" \
--data '{
  "provideCloudSSHKey": true,
  "validityDays": 1
}' > /home/cz/seed.json