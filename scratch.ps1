$AccessKey = 'ASIASWLY4YREXTSZ4QQN'
$SecretKey = 'PdCl8n/ceicVBV2r1No4R+H3z/b3yZ1Y1nE2wFjo'
$SessionToken = 'IQoJb3JpZ2luX2VjEB0aCXVzLWVhc3QtMSJHMEUCIE8oBGFFotWodYSiYUq7ue8mKD4aGthF21AeOzijYO2MAiEA/R1grn5sC5F8Msbr9hArNTIcR43lB4JjA4hBFTHRLWEq9gIIZhAAGgwxODU0NzQwMDgxMzciDCu6FM8t7VzVG2EoyyrTAlFffM4pyUYM1hyvBn1sNKBh25HpVoi1YGpiFwmX1NfJmIuBxQSt5aArDz2i7ShZIwmR/OSDsRFdeSGOkbNyaektSnN51RPY3UzEw5kbNc68tS4FJwkxywO2ds0Wsjv/U5rnw/IstQCkM4lYd/zzr4uDD6zBqaOeRHxA9brIQ5iBw/z/hmZLyLdXD9OWBJocQUIz8Qrj9adWMbLzlVsV8a3+hFIilbk7XEmrO7g+C8qh+hL0U0knUO19gRmjpAV9vA4WtJ13okcgs+9n9PojfM/lKYv5Psv+JU8AVWsPevp7NjwA1pm5v0sZQXPkDST2vSdxaTrqytZuEqlOLn/eQZ8Eprqj0XHHzRPmMQoO5S2zDH+GWTJ7hkb4Ir5xIe8nP4dQqvviLdx3eiV13W5rqa+iZkI1b2eaAqdL4L/L+hiF0pyHKtuczByHeB8ySvyxMeN8KzCYvs+qBjqmAdMANxpR8jesOvfh3iNzrPqnzazY1VTVhfKv/OgmKrjrrPZkGRjx0ua1oXe0rDs5Bx670INju2ClaNR27XnsARZuCl9TCLejnt0o6MBUDyQG5+eKiVn/UZAlB7AXeK2/S/JM+boPjjhFe5HDvnnPjjGwwyXjsBxa40gYH1M/4G62yh+L5IG64XSXuYJZbXEPQWJSV+ie0ePy6LrWA2bAVjMoNdEWybY='
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -SessionToken $SessionToken -StoreAs 'NC-Connect-POC' 

Publish-AWSPowerShellLambda -Name 'bullseye-routing' -ScriptPath C:\Scripts\GitHub\Amazon-Connect-POC\awsconnect-lambda\awsconnect-lambda.ps1 -Profile nc-connect-poc

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

$Region = 'us-west-2'
$Subnet1Cidr = '10.1.0.0/24'
$Subnet2Cidr = '10.1.1.0/24'
$VpcCidr = '10.1.0.0/16'
$CreateTransitGateway = 'true'
$CustomerAbbreviation = 'mystack'

$Parameter = @(
    @{ParameterKey = 'CreateTransitGateway'; ParameterValue = $CreateTransitGateway},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'},
    @{ParameterKey = 'HelperS3Key'; ParameterValue = 'vpc-stack-helper.zip'},
    @{ParameterKey = 'NamingS3Key'; ParameterValue = 'vpc-stack-naming.zip'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'Subnet1Cidr'; ParameterValue = $Subnet1Cidr},
    @{ParameterKey = 'Subnet2Cidr'; ParameterValue = $Subnet2Cidr},
    @{ParameterKey = 'VpcCidr'; ParameterValue = $VpcCidr},
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
)
$CFNStack = @{
    StackName = 'my-stack-vpc'
    Capability = 'CAPABILITY_IAM'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-Stack.template'
    Region = $Region
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack

$Region = 'us-west-2'
$CustomerAbbreviation = 'mystack'
$SecurityGroupId = 'sg-07125ab6ebb601af3'
$Server1Ip = '10.1.0.5'
$Server1Name = 'mys-ad01'
$Server2Ip = '10.1.1.5'
$Server2Name = 'mys-ad02'
$Subnet1Id = 'subnet-0f827214a25498768'
$Subnet2Id = 'subnet-069c2e825cb45a2bd'
$VpcId = 'vpc-0bf1a958e5fd24121'

$Parameter = @(
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'InstanceType'; ParameterValue = 't3a.large'},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUsername'; ParameterValue = 'nctech'},
    @{ParameterKey = 'SecurityGroupId'; ParameterValue = $SecurityGroupId},
    @{ParameterKey = 'Server1Ip'; ParameterValue = $Server1Ip},
    @{ParameterKey = 'Server1Name'; ParameterValue = $Server1Name},
    @{ParameterKey = 'Server2Ip'; ParameterValue = $Server2Ip},
    @{ParameterKey = 'Server2Name'; ParameterValue = $Server2Name},
    @{ParameterKey = 'Subnet1Id'; ParameterValue = $Subnet1Id},
    @{ParameterKey = 'Subnet2Id'; ParameterValue = $Subnet2Id},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'S3Key'; ParameterValue = 'ad-stack-naming.zip'},
    @{ParameterKey = 'VpcId'; ParameterValue = $VpcId}
)
$CFNStack = @{
    StackName = 'my-stack-ad'
    Capability = 'CAPABILITY_IAM'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-AD-Stack.template'
    Region = $Region
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack 


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


ADServerName	TEST-DC01'},
AllocationId	eipalloc-0eb6baa8ad1f91121'},
BrokerInstanceType	t3a.large'},
BrokerIp	10.55.0.11'},
BrokerServerName	TEST-GW25'},
GatewayExternalFqdn	rds2.netcov.com'},
LatestAmiId	/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-Base	ami-0ab05a04b66a879af
S3Bucket	netcov-set-devtest1-internal-us-east-1'},
S3Key	win-acme.v2.2.4.1500.x64.pluggable.zip'},
SessionHostInstanceType	r6i.large'},
SessionHostServerName	TEST-SH25'},
SessionIp	10.55.0.10

#>