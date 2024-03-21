$AccessKey = 'ASIAWMOEVQDJPDJ2GY36'
$SecretKey = 't1vOqUcimas2TjaTXeeB5Zv8SaT+QTiSX6rR+TTY'
$SessionToken = 'IQoJb3JpZ2luX2VjEA8aCXVzLWVhc3QtMSJHMEUCIA3pu1ON9Hfqgo3yBM1omryFGdgtRXb314AeAXE1q8hcAiEA+AwljBf2G2Kz5Ki3JWsq79MSODx6OYFGsJUidUVmVxMq9gIIRxABGgw0MzkwMzU5ODYxMzAiDLGeskd2BcXdWLNR9CrTAvHm92xV7fHexyelUfFfg+AFYbYfk3thtWL+box+jFAlMmTYjoI0/e98EjnDvaWWUYhrvXgmM+Gk6ciaAdR7JHhVCOFOvHchNq5jGfOUdh1+UEJa8aERjrzVV6yDrkJX9SvCAeKk1K7Cmt6HLfjOYq3wn1vJrTQrnFwnYw1PMDK2J8odsfh9Muc4x21/wUlXKK4gbcWCoq8lb9QPriY3ZBdaAMW5iXITjEOywqktWOCGEennhlUejANBEV4o6b2/Yw9vd2XFnFq4190kdR4o/UNVFa0gGyZ8Ok19mzjYWrge3dTjKn1kcgDYQtI+K6In764E+78kvHl8n1U7O8U6Fz+ZeVHqG88lr3Oyn1TVUcsnn84G6v8ITvnCSY1UfVGShgsacBmRhH5UjEzgDJ120/ljJBlgZLVrlsiep2JJVmKNFSpvRPC8WzincPVKVzyhvCO6CTC8gJSqBjqmAbI2/ypDZWMQiJiBFDeURsS4H5TFId9SV/SQHcHGusKDXZyWFc7SwUUSIYHI1NiknviDFD40D5pRl4u1u/PxanNraIWp+W/f/0fFj9Ofj9FGSlflN/49ARmjxhh26K+heMx1Hia0F8ILTLWhZSJF3GjxPfYKymBv7M9L+hzwCbKlUAdP40J+Y7fY5PDOzzdBJ9PZB6tJHzI63mpjiQiKdnvVI1hqSnc='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs 'CareMetx-Seasonal-Prod'
Initialize-AWSDefaults -ProfileName CareMetx-Seasonal-Prod


$AccessKey = 'ASIASWLY4YRETASKVI3M'
$SecretKey = 'DzCPfBfpujgNj1oph34p3VsBoTFBKbaRis4qt4To'
$SessionToken = 'IQoJb3JpZ2luX2VjEE4aCXVzLWVhc3QtMSJHMEUCIQCb+jXKzqEb58oOjYAEzmXQIAW5zmCtGdhQqBmEWu/0mgIgDlfbIK90EqdrGKlZSHMsVOtdUvWBZKnksBbVPorJZQoq9gIINxAAGgwxODU0NzQwMDgxMzciDFVcDT6SZGWB0FhQxSrTAqGXyLGVEEHUrTlV8LaUEj70DCL/juLCo7QDfqco3soJ2w7wZw5BK+na5qd4MIEbBdZ0NI+CJmtk/95UJYPDZJZKCpbDgWvusi+obV/i0mTUVL3WRYjvv9wLHdWtMpphJxVg5I6Un41kEX2v2QINzCukD7cdcA3krOy9pmu9chVtdS7EmH2P3FMHal/DhACfYL3drSWwiu5xpt4wurZJZpsqxWZaN4FxLTs/GQoC7SY06PnCPenPw3lvKVVF96kOI6j/6mD2zUHip59vRcmrCRO9yZ92pVIMtUnHpsRzSxIYyKDTnc7Sj8HDKZoqjy4/ZaWb+G8SdPaAQcozuWN9z/iwHvDX1lRYUenI1X2lPb+3TGKS5KKsDicnsPfcNSb0ZVE6qzhjhXhd0WYbN2MiwyjmbYSe9GEmB9JT9YERyXRXTToMpczYYKIsxHBVCL77c4TOZzD53YioBjqmAQPWWbCyrfX51d9//QcTUwH03Wuw9+goD6OxmTM50qXYm8BM0XgZ3cnhtx3sb1lfCKN3rYORTfvwmBf2/mKaEfsMteIkkQxRHWgs3mqi6HsKkzxvLhuAniWT1x1E2EB5RtAItiBI5SP6cuaFElQ500AC2MsjST+9oOWpAUFNEhXOczSMSSHN+yxxDLFvjnMi7amTeLefjrkUCVgj/RpiSOYQZ9HLSzU='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs 'NC-Connect-POC'
Initialize-AWSDefaults -ProfileName Set-DevTest1


Import-Module AWSLambdaPSCore
Get-Command -Module AWSLambdaPSCore
Get-AWSPowerShellLambdaTemplate

New-AWSPowerShellLambda -Template Basic -ScriptName 'Test'


$splat = @{
    Name = 'Test'
    ScriptPath = 'c:\Temp\Test\Test.ps1'
    ProfileName = 'Set-DevTest1'
}
Publish-AWSPowerShellLambda @splat

$InputData = @{
    AccountId = '262613313541'    
    AcceptorRegion = 'us-west-2'
    RequestorRegion = 'us-east-2'
} | ConvertTo-Json
$Result = Invoke-LMFunction -FunctionName 'Test' -LogType Tail -Payload $InputData

#"`n$($Result.Payload | ConvertTo-String)`n"
"`n$($Result.LogResult | ConvertTo-String)`n"


New-AWSPowerShellLambdaPackage -ScriptPath C:\Temp\Test\transitgatewayhelper.ps1 -OutputPackage C:\Temp\Test\transitgatewayhelper.zip
New-AWSPowerShellLambdaPackage -ScriptPath C:\Temp\Test\transitgatewayhelperv2.ps1 -OutputPackage C:\Temp\Test\transitgatewayhelperv2.zip
New-AWSPowerShellLambdaPackage -ScriptPath C:\Temp\Test\vpchelper.ps1 -OutputPackage C:\Temp\Test\vpchelper.zip
New-AWSPowerShellLambdaPackage -ScriptPath C:\Temp\Test\Test.ps1 -OutputPackage C:\Temp\Test\Test.zip


$AccountId = '262613313541'    
$AcceptorRegion = 'us-west-2'
$RequestorRegion = 'us-east-2'


$bucketname = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
$bucketname.ParameterKey = 'BucketName'
$bucketname.ParameterValue = 'globally-unique-bucket-name'

# project value for the project tag
$project = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
$project.ParameterKey = 'ProjectTag'
$project.ParameterValue = 'demo'

#region us-east-2
#region VPC
$Parameter = @(
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'}
    @{ParameterKey = 'Region1'; ParameterValue = 'us-east-2'}
    @{ParameterKey = 'Region2'; ParameterValue = 'us-west-2'}
    @{ParameterKey = 'S3Bucket'; ParameterValue = 'netcov-set-devtest1-internal-us-east-2'}
    @{ParameterKey = 'S3Key'; ParameterValue = 'vpchelper.zip'}
    @{ParameterKey = 'VPC1Cidr'; ParameterValue = '10.0.0.0/16'}
    @{ParameterKey = 'VPC1Subnet1Cidr'; ParameterValue = '10.0.0.0/24'}
    @{ParameterKey = 'VPC1Subnet2Cidr'; ParameterValue = '10.0.1.0/24'}
    @{ParameterKey = 'VPC2Cidr'; ParameterValue = '10.1.0.0/16'}
    @{ParameterKey = 'VPC2Subnet1Cidr'; ParameterValue = '10.1.0.0/24'}
    @{ParameterKey = 'VPC2Subnet2Cidr'; ParameterValue = '10.1.1.0/24'}
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
)

$CFNStackSet = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    ManagedExecution_Active = $true
    Capability = 'CAPABILITY_IAM'
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-east-2.s3.us-east-2.amazonaws.com/NetCov-VPC-StackSet-v2.template'
}
New-CFNStackSet @CFNStackSet -Region 'us-east-2'

$CFNStackInstance = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    StackInstanceRegion = 'us-east-2', 'us-west-2'
}
New-CFNStackInstance @CFNStackInstance -Region 'us-east-2'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    RetainStack = $false
    StackInstanceRegion = 'us-east-2', 'us-west-2'
    Force = $true
}
Remove-CFNStackInstance @CFNStackInstance -Region 'us-east-2'
Get-Date

$CFNStackSet = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Force = $true
}
Remove-CFNStackSet @CFNStackSet -Region 'us-east-2'
#endregion VPC

#region AD Stack
$Parameter = @(
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'}
    #@{ParameterKey = 'ADServer2Ip'; ParameterValue = '8.8.8.8'}
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'}
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'}
    @{ParameterKey = 'DomainFQDN'; ParameterValue = 'corp.test.com'}
    @{ParameterKey = 'DomainNetBIOS'; ParameterValue = 'TEST'}
    @{ParameterKey = 'InstanceType'; ParameterValue = 't3a.large'}
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base'}
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'}
    @{ParameterKey = 'LocalAdminUsername'; ParameterValue = 'nctech'}
    @{ParameterKey = 'Server1IP'; ParameterValue = '10.0.0.15'}
    @{ParameterKey = 'Server1Name'; ParameterValue = 'TEST-SRV01'}
    @{ParameterKey = 'Server2IP'; ParameterValue = '10.1.0.15'}
    @{ParameterKey = 'Server2Name'; ParameterValue = 'TEST-SRV02'}
)
$CFNStackSet = @{
    StackSetName = 'AD-StackSet-Test-MR'
    ManagedExecution_Active = $true
    Capability = 'CAPABILITY_IAM'
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-east-2.s3.us-east-2.amazonaws.com/NetCov-AD-StackSet.template'
}
New-CFNStackSet @CFNStackSet -Region 'us-east-2'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    StackInstanceRegion = 'us-east-2', 'us-west-2' 
}
New-CFNStackInstance @CFNStackInstance -Region 'us-east-2'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    RetainStack = $false
    StackInstanceRegion = 'us-east-2', 'us-west-2' 
    Force = $true
}
Remove-CFNStackInstance @CFNStackInstance -Region 'us-east-2'
Get-Date

$CFNStackSet = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Force = $true
}
Remove-CFNStackSet @CFNStackSet -Region 'us-east-2'
#endregion AD Stack

#region RDS Stack
#endregion RDS Stack
#endregion us-east-2


#region us-east-1
#region VPC Stack
$Parameter = @(
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'}
    @{ParameterKey = 'Region1'; ParameterValue = 'us-east-1'}
    @{ParameterKey = 'Region2'; ParameterValue = 'us-west-1'}
    @{ParameterKey = 'S3Bucket'; ParameterValue = 'netcov-set-devtest1-internal-us-east-1'}
    @{ParameterKey = 'S3Key'; ParameterValue = 'vpchelper.zip'}
    @{ParameterKey = 'VPC1Cidr'; ParameterValue = '10.55.0.0/16'}
    @{ParameterKey = 'VPC1Subnet1Cidr'; ParameterValue = '10.55.0.0/24'}
    @{ParameterKey = 'VPC1Subnet2Cidr'; ParameterValue = '10.55.1.0/24'}
    @{ParameterKey = 'VPC2Cidr'; ParameterValue = '10.44.0.0/16'}
    @{ParameterKey = 'VPC2Subnet1Cidr'; ParameterValue = '10.44.0.0/24'}
    @{ParameterKey = 'VPC2Subnet2Cidr'; ParameterValue = '10.44.1.0/24'}
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
)

$CFNStackSet = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    ManagedExecution_Active = $true
    Capability = 'CAPABILITY_IAM'
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-east-2.s3.us-east-2.amazonaws.com/NetCov-VPC-StackSet-v2.template'
}
New-CFNStackSet @CFNStackSet -Region 'us-east-1'


$CFNStackInstance = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    StackInstanceRegion = 'us-east-1', 'us-west-1'
}
New-CFNStackInstance @CFNStackInstance -Region 'us-east-1'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    RetainStack = $false
    StackInstanceRegion = 'us-east-1', 'us-west-1'
    Force = $true
}
Remove-CFNStackInstance @CFNStackInstance -Region 'us-east-1'
Get-Date

$CFNStackSet = @{
    StackSetName = 'VPC-StackSet-Test-MR'
    Force = $true
}
Remove-CFNStackSet @CFNStackSet -Region 'us-east-1'
#endregion VPC Stack

#region AD Stack
$Parameter = @(
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'}
    #@{ParameterKey = 'ADServer2Ip'; ParameterValue = ''}
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'}
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'}
    @{ParameterKey = 'DomainFQDN'; ParameterValue = 'corp.test.com'}
    @{ParameterKey = 'DomainNetBIOS'; ParameterValue = 'TEST'}
    @{ParameterKey = 'InstanceType'; ParameterValue = 't3a.large'}
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base'}
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'}
    @{ParameterKey = 'LocalAdminUsername'; ParameterValue = 'nctech'}
    @{ParameterKey = 'Server1IP'; ParameterValue = '10.55.0.5'}
    @{ParameterKey = 'Server1Name'; ParameterValue = 'TEMP-SRV01'}
    @{ParameterKey = 'Server2IP'; ParameterValue = '10.44.0.5'}
    @{ParameterKey = 'Server2Name'; ParameterValue = 'TEMP-SRV02'}
)
$CFNStackSet = @{
    StackSetName = 'AD-StackSet-Test-MR'
    ManagedExecution_Active = $true
    Capability = 'CAPABILITY_IAM'
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-east-1.s3.amazonaws.com/NetCov-AD-StackSet.template'
}
New-CFNStackSet @CFNStackSet -Region 'us-east-1'


$CFNStackInstance = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    StackInstanceRegion = 'us-east-1', 'us-west-1'
}
New-CFNStackInstance @CFNStackInstance -Region 'us-east-1'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    RetainStack = $false
    StackInstanceRegion = 'us-east-1', 'us-west-1'
    Force = $true
}
Remove-CFNStackInstance @CFNStackInstance -Region 'us-east-1'

$CFNStackSet = @{
    StackSetName = 'AD-StackSet-Test-MR'
    Force = $true
}
Remove-CFNStackSet @CFNStackSet -Region 'us-east-1'
#endregion AD Stack

#region RDS Stack
$Parameter = @(
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.large'}
    @{ParameterKey = 'BrokerIp'; ParameterValue = '10.55.0.6'}
    @{ParameterKey = 'BrokerServerName'; ParameterValue = 'TEST-BK01'}
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base'}
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'}
    @{ParameterKey = 'SessionHostServerName'; ParameterValue = 'TEST-SH01'}
    @{ParameterKey = 'SessionIp'; ParameterValue = '10.55.0.7'}
)

$CFNStackSet = @{
    StackSetName = 'RDS-StackSet-Test-MR'
    ManagedExecution_Active = $true
    Capability = 'CAPABILITY_IAM'
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-east-1.s3.amazonaws.com/NetCov-RDS-StackSet.template'
}
New-CFNStackSet @CFNStackSet -Region 'us-east-1'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'RDS-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    StackInstanceRegion = 'us-east-1'
}
New-CFNStackInstance @CFNStackInstance -Region 'us-east-1'
Get-Date

$CFNStackInstance = @{
    StackSetName = 'RDS-StackSet-Test-MR'
    Account = '262613313541'
    OperationPreference = @{RegionConcurrencyType = 'PARALLEL'}
    RetainStack = $false
    StackInstanceRegion = 'us-east-1'
    Force = $true
}
Remove-CFNStackInstance @CFNStackInstance -Region 'us-east-1'

$CFNStackSet = @{
    StackSetName = 'RDS-StackSet-Test-MR'
    Force = $true
}
Remove-CFNStackSet @CFNStackSet -Region 'us-east-1'
#endregion RDS Stack
#endregion us-east-1



<# 
https://netcov-set-devtest1-internal-us-east-1.s3.amazonaws.com/NetCov-RDS-BK-SH-GW-SSL-StackSet.template

RDS-GW-SSH-StackSet-Test-MR-v29


ADServerName	TEST-DC01	-
AllocationId	eipalloc-0eb6baa8ad1f91121	-
BrokerInstanceType	t3a.large	-
BrokerIp	10.55.0.11	-
BrokerServerName	TEST-GW25	-
GatewayExternalFqdn	rds2.netcov.com	-
LatestAmiId	/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base	ami-0ab05a04b66a879af
S3Bucket	netcov-set-devtest1-internal-us-east-1	-
S3Key	win-acme.v2.2.4.1500.x64.pluggable.zip	-
SessionHostInstanceType	r6i.large	-
SessionHostServerName	TEST-SH25	-
SessionIp	10.55.0.10

#>


$AccessKey = 'ASIA5A4YXHZ2VAOAT6E6'
$SecretKey = 'nHOq6SjOeLOvte9mVp3LDX5CCN3SnqKz2eGcMOUs'
$SessionToken = 'IQoJb3JpZ2luX2VjEM7//////////wEaCXVzLWVhc3QtMSJHMEUCIF2gZosX9vLrNMfkIZt8HGhnSdC6xA5jY99ewtfBz6YIAiEAyEgRR34xEr3ZuYJBpImIHYiE2PitwWrUu0AZRI0V5oIq/gII9v//////////ARACGgw4OTUyODQxMDA3MjUiDLAFcGVCjUL0PEx+RyrSAjrNY91L8VnjbDp4XzFTWYY0oe0+W0/lAl9l/5qfd6bhs8yQ9Ii7GXWBQyV1k6mEDWSktqOSHRC0m2ebu0UeL+BBV5SnE7Nf4J8qqoJAhLPyTV8lCb5RgBsW+k3aLTpNB/uIwtgWtuSexNsfgwkxxQM/AfH3tBzO0wt1CHKf/hhpL+Lthcfc+ABzRaH6E/EeZcIGEOiVDKsJASbJnsn4vNgvSQ4MP0p1UNCls28APq1NZQXOiut5DbeXKhFhVwliQ0hCC2+6Wc8MGWJiPXi1ssWY2LYHgH6ga35plULFi1Yf0dpdHTSDEzVE94AyrI+BqblNeVBanyBhmbXzp1rNQ138DVpnUSW9QArKJnAiAF13UIau8oWK9OzeaEXu02VjNWNgNIwDHRcmys/OjCWxm2noMWLvV3QuwGuJFR8sb3kMYWd3Uzupj04ddGV4eCp3eMokMMr6uaMGOqYB68Leh+2V8wvWdp2LFzDMnH4h8ghHCVsbtMC1qy/TFjQQ6/1bIoMQk5uIqS0CIO8ueLT+t+qJFd5Sf7nN3UbAa6CIFB7sPUo2rSgy5zzqqylrmZjdO3dQlnM5iH52g5hkAaX7frAmb7656jzJ/AevACmkycTiNkaCEjpeIUipEwHsS/o++/3ZsZ/lXOep8o9Rj8nS7f29I82vIiVyTGxrA8O/xELXUA=='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs Set-NetCov1
Initialize-AWSDefaults -ProfileName Set-NetCov1

$AccessKey = 'ASIATU265IEVCZA5J3F2'
$SecretKey = 'R9ZJmyRC1HmxbiFarx+IaIrJjwliSxmBZUilW4Vl'
$SessionToken = 'IQoJb3JpZ2luX2VjEM7//////////wEaCXVzLWVhc3QtMSJHMEUCIB/FlXA2AGXYWulCqg+lvjARQSuC+ez2ZRRqCyilHHMZAiEA8gd0y2Tz6gTKh2FYJReW6O8l/bGCw6dFwkBn21ahZMMq/gII9v//////////ARABGgwyNTA5MTc3NjU0MTgiDN0FiZgldCIhW0vNgSrSAhCMcjv+mgEiWC4AtgBYwtoZDlkm2kasonUsbYzi/tkxMzJbvbDPRBVJxm+4M2VLYDcFANjcLW2xY1tguajTPc4TW5CuOsJ6/gvrhunRHyOsUAqt/7xLn7MG1tDxc89XO0ifWPQUxXQkza4q/ZkCkhG7x6WqwWo2/uoy9imJCUETOo00cPPmpbMev5GkOjER2O4GUvfSH2K+r2D+YI+9TWOCd9HYJVLap6iPGDfmyiqNRbOqDE8HgmM3rOHLnE4P7sQ5BezdQyQua/y73O9sriO9K3Eym+UFwg9EORJpDjJznld8GvD4DIpvLw26bZHJI5vayxkNVKngoWkqh8trtxA3Bq9xv2+0YluOB/4oKQ72OQkN9JwkUeQf/QkhaEVpiMy8W8U48PpInp+gDbjO2BfmCudTfuh1ze8NCJHIEkRAhmSjz7r8XXTrrDLJEUi5QTe1MKz9uaMGOqYBYWck+TBRafw3F/6sDdKFiFPPUhzT2hFXO1xITamPAT3XtQ68UW8n4ywVDgxCDtgwu3j84xPSj/o/JOX+EWyPHqEICGREZnwaCHROtUW+7FkczuN+rl06XlO4Mr6aYoqrUA5opuHBx7XJd/etMA3M2SxhNzcvlr15ViNVI+LV8tDWuAdqkB37y503DQZ7FDb9QmrLnJjSMZx0VJEv6/VM+Ji4gWkqWg=='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs Set-BBIProd
Initialize-AWSDefaults -ProfileName Set-BBIProd

$AccessKey = 'ASIAR3UGODU7KRT5EVWJ'
$SecretKey = 'gDVtCqvh34/Zl75/6LemVt3ERrvgr7A5JidH3VYr'
$SessionToken = 'IQoJb3JpZ2luX2VjEM7//////////wEaCXVzLWVhc3QtMSJHMEUCIBmvBp33dvcGWQEyDacmbo7t7bsJ43OM7Z8N5pkpjB7iAiEAywoCYgT+FsC/MpIoNsZQYalkmMtNYnccbvJp9jcmjy8q/gII9///////////ARAAGgwxMjgwNTcyMjA0MTQiDNjAzlDIPsHG+66SMirSAlWNF3nT0L3s8ClXTebRpK/cxOavl/P2VxTxnYOv8PSj5529OZi2MqDJCYHxabcGRZ3SfLz7iwDoQShdzT2PfOXBL6cJidw49++vmhWULfI6fQVdb0dfWCAohsUdbnw2WXv+g7SrK1jYTiT9NOhmrWTjz9kuwTH5QJ+zV5N9rmS9XAjiTwSF6f2OWBUK0B18Ve7uYVMtIwnbMLT/O4XVNMjH5y0k8PZUFGdNvWj5xHSYvE4rzV93/lnf76HG8mz1+Q6CdCcSFBwQqZjjY2mOkhtWARklob2O610JKqMh8a5/ojXK5RQf1w4XfwS+/SFoJHdSl04i7cSGBqHIbmTcshV0r/ngFmrdXlt3YGSolTr2euUiCGQAvGTn7Qf9WXmbfibY19Y2ohBcvwqXCHr5ublg5vGiCNZn5hA1XspzmvMXuuKCNNiXuLHKaLoTVCzrJ/b0MIqDuqMGOqYBzYGYdgEs2nXKJFrRA5zFq96KaLqafWmpQVkMktMc1q9DeA5TG8LcIdZmrvUok8Ld5obXOZ1+/TiWfSedCyIH2phVcpXWrJU87MLDVbjqFA6Xqp58FPHiJbasXez487k7MH35Z/evi+MuTc7VGoYD1LeXdMpGElPZ8z58h6a5QU/+oLpw9/koeImwL7uVE5XfVUpWsjc/LIDOJ0OUEQEDbZAADUGn0A=='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs Set-NETRProd
Initialize-AWSDefaults -ProfileName Set-NETRProd
