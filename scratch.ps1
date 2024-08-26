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
$CustomerAbbreviation = 'test'

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
    StackName = 'Stack-Test-VPC'
    Capability = 'CAPABILITY_IAM'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-Stack.template'
    Region = $Region
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack

$SecurityGroupId = 'sg-0e0e3a84cdd6b9650'
$Server1Ip = '10.1.0.5'
$Server1Name = 'TEST-AD01'
$Server2Ip = '10.1.1.5'
$Server2Name = 'TEST-AD02'
$Subnet1Id = 'subnet-07d400d38fb53938f'
$Subnet2Id = 'subnet-01135417f637e575b'
$VpcId = 'vpc-0b3971b986c54d177'

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
    @{ParameterKey = 'LocalAdminUserName'; ParameterValue = 'nctech'},
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
    StackName = 'Stack-Test-AD'
    Capability = 'CAPABILITY_IAM'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-AD-Stack.template'
    Region = $Region
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack 

$KeypairName = '{0}-ec2-keypair-{1}' -f $CustomerAbbreviation, $Region
$SessionHostNames = 'TEST-RDS01,TEST-RDS02,TEST-RDS03'
$AllocationId = 'eipalloc-0b6905971005d20b5'
$BrokerServerName = 'MYS-BK01'
$GatewayExternalFqdn = 'rds.netcov.com'

$Parameter = @(
    @{ParameterKey = 'ADServerName'; ParameterValue = 'TEST-DC01'},
    @{ParameterKey = 'AllocationId'; ParameterValue = $AllocationId},
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.xlarge'},
    @{ParameterKey = 'BrokerNamingS3Key'; ParameterValue = 'bk-stack-naming.zip'},
    @{ParameterKey = 'BrokerServerName'; ParameterValue = $BrokerServerName},
    @{ParameterKey = 'BrokerSubnetId'; ParameterValue = $Subnet2Id},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUsername'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'GatewayExternalFqdn'; ParameterValue = $GatewayExternalFqdn},
    @{ParameterKey = 'KeyPairName'; ParameterValue = $KeypairName},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUsername'; ParameterValue = 'nctech'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'SecurityGroupId'; ParameterValue = $SecurityGroupId},
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'},
    @{ParameterKey = 'SessionHostNames'; ParameterValue = $SessionHostNames},
    @{ParameterKey = 'SessionHostNamingS3Key'; ParameterValue = 'sh-stack-naming.zip'},
    @{ParameterKey = 'SessionHostSubnetId'; ParameterValue = $Subnet1Id},
    @{ParameterKey = 'VpcId'; ParameterValue = $VpcId},
    @{ParameterKey = 'WinAcmeS3Key'; ParameterValue = 'win-acme.v2.2.4.1500.x64.pluggable.zip'}
    
)
$CFNStack = @{
    StackName = 'Stack-Test-RD'
    Capability = 'CAPABILITY_IAM', 'CAPABILITY_AUTO_EXPAND'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-RD-Stack.template' 
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



$CFNStack = @{
    StackName = 's3test'
    DisableRollback = $true
    Capability = 'CAPABILITY_IAM'
    TemplateBody = '{
        "AWSTemplateFormatVersion": "2010-09-09",
        "Resources": {
            "Instance": {
                "Type" : "AWS::EC2::Instance",
                "Metadata": {
                    "AWS::CloudFormation::Init": {
                        "config": {
                            "files": {
                                "c:\\cfn\\cfn-hup.conf": {
                                    "content": {
                                        "Fn::Join": [
                                            "",
                                            [
                                                "[main]\n",
                                                "stack=", {"Ref" : "AWS::StackId"}, "\n",
                                                "region=", {"Ref" : "AWS::Region"}, "\n"
                                            ]
                                        ]
                                    }
                                },
                                "c:\\cfn\\hooks.d\\cfn-auto-reloader.conf": {
                                    "content": {
                                        "Fn::Join": [
                                            "",
                                            [
                                                "[cfn-auto-reloader-hook]\n",
                                                "triggers=post.update\n",
                                                "path=Resources.Instance.Metadata.AWS::CloudFormation::Init\n",
                                                "action=cfn-init.exe -v -s ", {"Ref" : "AWS::StackId"}, " -r Instance", " --region ", {"Ref" : "AWS::Region"}, "\n"
                                            ]
                                        ]
                                    }
                                },
                                c:\\cfn\\test.zip: {
                                    "source": {
                                        "Fn::Join": [
                                            "/",
                                            [
                                                "https://s3.amazonaws.com",
                                                "netcov-set-devtest1-internal-us-east-2",
                                                "win-acme.v2.2.4.1500.x64.pluggable.zip"
                                            ]
                                        ]
                                    }
                                },
                                "c:\\cfn\\win-acme.zip": {
                                    "source": "https://netcov-set-devtest1-internal-us-east-2.s3.us-east-2.amazonaws.com/win-acme.v2.2.4.1500.x64.pluggable.zip"
                                }                          
                            },
                            "commands": {
                                "a-signal-success" : { 
                                    "command" : { "Fn::Join" : ["", ["cfn-signal.exe --stack ", {"Ref" : "AWS::StackId"}, " --resource Instance --region ", {"Ref" : "AWS::Region"}]]}
                                }
                            },
                            "services": {
                                "windows": {
                                    "cfn-hup": {
                                        "enabled": "true",
                                        "ensureRunning": "true",
                                        "files": [
                                            "c:\\cfn\\cfn-hup.conf",
                                            "c:\\cfn\\hooks.d\\cfn-auto-reloader.conf"
                                        ]
                                    }
                                }
                            }
                        }
                    }
                },
                "Properties" : {
                    "ImageId" : "ami-087fc1aada380df36",
                    "InstanceType" : "t3a.small",
                    "KeyName" : "test-kp",
                    "SecurityGroupIds" : ["sg-004c0d7ef6c4c17e9"],
                    "SubnetId" : "subnet-0378190d02648f3f8",
                    "Tags" : [
                        {"Key": "Name", "Value": "S3TEST"}                    
                    ], 
                    "UserData": { 
                        "Fn::Base64" : { 
                            "Fn::Join" : [
                                "", 
                                [
                                    "<script>\n",                  
                                    "cfn-init.exe -v -s ", {"Ref" : "AWS::StackId"}, " -r Instance --region ", {"Ref" : "AWS::Region"}, "\n",
                                    "</script>"       
                                ]
                            ]
                        }
                    }
                },
                "CreationPolicy" : {
                    "ResourceSignal" : {
                        "Timeout" : "PT10M"
                    }
                }
            }          
        }
    }'
    Region = 'us-east-2'
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack




$AllocationId = 'eipalloc-040dcf4c5c1a8ee4f'
$BrokerServerName = 'NC-BK51'
$CreateTransitGateway = 'false'
$CustomerAbbreviation = 'test'
$GatewayExternalFqdn = 'rdpfarm.netcov.com'
$Region = 'us-east-1'
$SessionHostNames = 'NC-RDS51,NC-RDS52,NC-RDS53'
$Server1Ip = '10.55.0.5'
$Server1Name = 'NC-AD51'
$Server2Ip = '10.55.1.5'
$Server2Name = 'NC-AD52'
$Subnet1Cidr = '10.55.0.0/24'
$Subnet2Cidr = '10.55.1.0/24'
$VpcCidr = '10.55.0.0/16'

$Parameter = @(
    @{ParameterKey = 'AdInstanceType'; ParameterValue = 't3a.large'},
    @{ParameterKey = 'AdNamingS3Key'; ParameterValue = 'ad-stack-naming.zip'},
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'},
    @{ParameterKey = 'ADServer2Ip'; ParameterValue = ''},
    @{ParameterKey = 'ADServerName'; ParameterValue = 'TEST-DC01'},
    @{ParameterKey = 'AllocationId'; ParameterValue = $AllocationId},
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.xlarge'},
    @{ParameterKey = 'BrokerNamingS3Key'; ParameterValue = 'bk-stack-naming.zip'},
    @{ParameterKey = 'BrokerServerName'; ParameterValue = $BrokerServerName},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'},
    @{ParameterKey = 'CreateTransitGateway'; ParameterValue = $CreateTransitGateway},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'GatewayExternalFqdn'; ParameterValue = $GatewayExternalFqdn},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUserName'; ParameterValue = 'nctech'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'Server1Ip'; ParameterValue = $Server1Ip},
    @{ParameterKey = 'Server1Name'; ParameterValue = $Server1Name},
    @{ParameterKey = 'Server2Ip'; ParameterValue = $Server2Ip},
    @{ParameterKey = 'Server2Name'; ParameterValue = $Server2Name},
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'},
    @{ParameterKey = 'SessionHostNames'; ParameterValue = $SessionHostNames},
    @{ParameterKey = 'SessionHostNamingS3Key'; ParameterValue = 'sh-stack-naming.zip'},
    @{ParameterKey = 'Subnet1Cidr'; ParameterValue = $Subnet1Cidr},
    @{ParameterKey = 'Subnet2Cidr'; ParameterValue = $Subnet2Cidr},
    @{ParameterKey = 'VpcCidr'; ParameterValue = $VpcCidr},
    @{ParameterKey = 'VpcHelperS3Key'; ParameterValue = 'vpc-stack-helper.zip'},
    @{ParameterKey = 'VpcNamingS3Key'; ParameterValue = 'vpc-stack-naming.zip'},
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
    @{ParameterKey = 'WinAcmeS3Key'; ParameterValue = 'win-acme.v2.2.4.1500.x64.pluggable.zip'}
)
$CFNStack = @{
    StackName = 'Stack-NetCov'
    Capability = 'CAPABILITY_IAM', 'CAPABILITY_AUTO_EXPAND'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-AD-RDS-Main-Stack.template' 
    Region = $Region
    ProfileName = 'set-devtest2-internal'
}
New-CFNStack @CFNStack 



$AllocationId = 'eipalloc-0576a7f7b5c35be19' #'eipalloc-0b6905971005d20b5'
$BrokerServerName = 'MYS-BK01'
$CreateTransitGateway = 'false'
$CustomerAbbreviation = 'test'
$GatewayExternalFqdn = 'rds-uw2.netcov.com' #'rds.netcov.com'
$Region = 'us-west-2'
$SessionHostNames = 'TEST-RDS01,TEST-RDS02,TEST-RDS03'
$Server1Ip = '10.1.0.5'
$Server1Name = 'TEST-AD01'
$Server2Ip = '10.1.1.5'
$Server2Name = 'TEST-AD02'
$Subnet1Cidr = '10.1.0.0/24'
$Subnet2Cidr = '10.1.1.0/24'
$VpcCidr = '10.1.0.0/16'

$Parameter = @(
    @{ParameterKey = 'AdInstanceType'; ParameterValue = 't3a.large'},
    @{ParameterKey = 'AdNamingS3Key'; ParameterValue = 'ad-stack-naming.zip'},
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'},
    @{ParameterKey = 'ADServer2Ip'; ParameterValue = ''},
    @{ParameterKey = 'ADServerName'; ParameterValue = 'TEST-DC01'},
    @{ParameterKey = 'AllocationId'; ParameterValue = $AllocationId},
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.xlarge'},
    @{ParameterKey = 'BrokerNamingS3Key'; ParameterValue = 'bk-stack-naming.zip'},
    @{ParameterKey = 'BrokerServerName'; ParameterValue = $BrokerServerName},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'},
    @{ParameterKey = 'CreateTransitGateway'; ParameterValue = $CreateTransitGateway},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'GatewayExternalFqdn'; ParameterValue = $GatewayExternalFqdn},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUserName'; ParameterValue = 'nctech'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'Server1Ip'; ParameterValue = $Server1Ip},
    @{ParameterKey = 'Server1Name'; ParameterValue = $Server1Name},
    @{ParameterKey = 'Server2Ip'; ParameterValue = $Server2Ip},
    @{ParameterKey = 'Server2Name'; ParameterValue = $Server2Name},
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'},
    @{ParameterKey = 'SessionHostNames'; ParameterValue = $SessionHostNames},
    @{ParameterKey = 'SessionHostNamingS3Key'; ParameterValue = 'sh-stack-naming.zip'},
    @{ParameterKey = 'Subnet1Cidr'; ParameterValue = $Subnet1Cidr},
    @{ParameterKey = 'Subnet2Cidr'; ParameterValue = $Subnet2Cidr},
    @{ParameterKey = 'VpcCidr'; ParameterValue = $VpcCidr},
    @{ParameterKey = 'VpcHelperS3Key'; ParameterValue = 'vpc-stack-helper.zip'},
    @{ParameterKey = 'VpcNamingS3Key'; ParameterValue = 'vpc-stack-naming.zip'},
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
    @{ParameterKey = 'WinAcmeS3Key'; ParameterValue = 'win-acme.v2.2.4.1500.x64.pluggable.zip'}
)
$CFNStack = @{
    StackName = 'Stack-Test'
    Capability = 'CAPABILITY_IAM', 'CAPABILITY_AUTO_EXPAND'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-AD-RDS-Main-Stack.template' 
    Region = $Region
    ProfileName = 'set-devtest2-internal'
}
New-CFNStack @CFNStack 


$AllocationId = 'eipalloc-01552f463f75840eb' #'eipalloc-050c322a603a72992'
$BrokerServerName = 'NCI-GW05'
$CreateTransitGateway = 'true'
$CustomerAbbreviation = 'nci'
$GatewayExternalFqdn = 'remote-use2.netcov.com' #'remote.netcov.com'
$Region = 'us-east-2'
$SessionHostNames = 'NCI-RDS10,NCI-RDS11,NCI-TL04'
$Server1Ip = '10.0.0.5'
$Server1Name = 'NCI-AD01'
$Server2Ip = '10.0.1.5'
$Server2Name = 'NCI-AD02'
$Subnet1Cidr = '10.0.0.0/24'
$Subnet2Cidr = '10.0.1.0/24'
$VpcCidr = '10.0.0.0/16'

$Parameter = @(
    @{ParameterKey = 'AdInstanceType'; ParameterValue = 't3a.large'},
    @{ParameterKey = 'AdNamingS3Key'; ParameterValue = 'ad-stack-naming.zip'},
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'},
    @{ParameterKey = 'ADServer2Ip'; ParameterValue = ''},
    @{ParameterKey = 'ADServerName'; ParameterValue = 'TEST-DC01'},
    @{ParameterKey = 'AllocationId'; ParameterValue = $AllocationId},
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.xlarge'},
    @{ParameterKey = 'BrokerNamingS3Key'; ParameterValue = 'bk-stack-naming.zip'},
    @{ParameterKey = 'BrokerServerName'; ParameterValue = $BrokerServerName},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'},
    @{ParameterKey = 'CreateTransitGateway'; ParameterValue = $CreateTransitGateway},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'GatewayExternalFqdn'; ParameterValue = $GatewayExternalFqdn},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUserName'; ParameterValue = 'nctech'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'Server1Ip'; ParameterValue = $Server1Ip},
    @{ParameterKey = 'Server1Name'; ParameterValue = $Server1Name},
    @{ParameterKey = 'Server2Ip'; ParameterValue = $Server2Ip},
    @{ParameterKey = 'Server2Name'; ParameterValue = $Server2Name},
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'},
    @{ParameterKey = 'SessionHostNames'; ParameterValue = $SessionHostNames},
    @{ParameterKey = 'SessionHostNamingS3Key'; ParameterValue = 'sh-stack-naming.zip'},
    @{ParameterKey = 'Subnet1Cidr'; ParameterValue = $Subnet1Cidr},
    @{ParameterKey = 'Subnet2Cidr'; ParameterValue = $Subnet2Cidr},
    @{ParameterKey = 'VpcCidr'; ParameterValue = $VpcCidr},
    @{ParameterKey = 'VpcHelperS3Key'; ParameterValue = 'vpc-stack-helper.zip'},
    @{ParameterKey = 'VpcNamingS3Key'; ParameterValue = 'vpc-stack-naming.zip'},
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
    @{ParameterKey = 'WinAcmeS3Key'; ParameterValue = 'win-acme.v2.2.4.1500.x64.pluggable.zip'}
)
$CFNStack = @{
    StackName = 'Stack-NetCov'
    Capability = 'CAPABILITY_IAM', 'CAPABILITY_AUTO_EXPAND'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-AD-RDS-Main-Stack.template' 
    Region = $Region
    ProfileName = 'set-devtest2-internal'
}
New-CFNStack @CFNStack 


$AllocationId = <# 'eipalloc-040d7c9bbd5eaa4e8' #> 'eipalloc-01b4b0b170f7d457b'
$BrokerServerName = 'NCI-GW15'
$CreateTransitGateway = 'false'
$CustomerAbbreviation = 'nci'
$GatewayExternalFqdn = <# 'rdp-uw1.netcov.com' #> 'rdp.netcov.com'
$Region = 'us-west-1'
$SessionHostNames = 'NCI-RDS30,NCI-RDS31,NCI-TL34'
$Server1Ip = '10.44.0.5'
$Server1Name = 'NCI-AD15'
$Server2Ip = '10.44.1.5'
$Server2Name = 'NCI-AD20'
$Subnet1Cidr = '10.44.0.0/24'
$Subnet2Cidr = '10.44.1.0/24'
$VpcCidr = '10.44.0.0/16'

$Parameter = @(
    @{ParameterKey = 'AdInstanceType'; ParameterValue = 't3a.large'},
    @{ParameterKey = 'AdNamingS3Key'; ParameterValue = 'ad-stack-naming.zip'},
    @{ParameterKey = 'ADServer1Ip'; ParameterValue = '192.168.6.5'},
    @{ParameterKey = 'ADServer2Ip'; ParameterValue = ''},
    @{ParameterKey = 'ADServerName'; ParameterValue = 'TEST-DC01'},
    @{ParameterKey = 'AllocationId'; ParameterValue = $AllocationId},
    @{ParameterKey = 'BrokerInstanceType'; ParameterValue = 't3a.xlarge'},
    @{ParameterKey = 'BrokerNamingS3Key'; ParameterValue = 'bk-stack-naming.zip'},
    @{ParameterKey = 'BrokerServerName'; ParameterValue = $BrokerServerName},
    @{ParameterKey = 'CustomerAbbreviation'; ParameterValue = $CustomerAbbreviation},
    @{ParameterKey = 'CustomerGatewayIpAddress'; ParameterValue = '38.122.194.242'},
    @{ParameterKey = 'CreateTransitGateway'; ParameterValue = $CreateTransitGateway},
    @{ParameterKey = 'DomainAdminPassword'; ParameterValue = 'f@ncyCar53'},
    @{ParameterKey = 'DomainAdminUserName'; ParameterValue = 'Administrator'},
    @{ParameterKey = 'DomainDNSName'; ParameterValue = 'corp.test.com'},
    @{ParameterKey = 'DomainNetBIOSName'; ParameterValue = 'TEST'},
    @{ParameterKey = 'GatewayExternalFqdn'; ParameterValue = $GatewayExternalFqdn},
    @{ParameterKey = 'LatestAmiId'; ParameterValue = '/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base'},
    @{ParameterKey = 'LocalAdminPassword'; ParameterValue = 'darkD!me83'},
    @{ParameterKey = 'LocalAdminUserName'; ParameterValue = 'nctech'},
    @{ParameterKey = 'S3Bucket'; ParameterValue = ('netcov-set-devtest1-internal-{0}' -f $Region)},
    @{ParameterKey = 'Server1Ip'; ParameterValue = $Server1Ip},
    @{ParameterKey = 'Server1Name'; ParameterValue = $Server1Name},
    @{ParameterKey = 'Server2Ip'; ParameterValue = $Server2Ip},
    @{ParameterKey = 'Server2Name'; ParameterValue = $Server2Name},
    @{ParameterKey = 'SessionHostInstanceType'; ParameterValue = 'r6i.large'},
    @{ParameterKey = 'SessionHostNames'; ParameterValue = $SessionHostNames},
    @{ParameterKey = 'SessionHostNamingS3Key'; ParameterValue = 'sh-stack-naming.zip'},
    @{ParameterKey = 'Subnet1Cidr'; ParameterValue = $Subnet1Cidr},
    @{ParameterKey = 'Subnet2Cidr'; ParameterValue = $Subnet2Cidr},
    @{ParameterKey = 'VpcCidr'; ParameterValue = $VpcCidr},
    @{ParameterKey = 'VpcHelperS3Key'; ParameterValue = 'vpc-stack-helper.zip'},
    @{ParameterKey = 'VpcNamingS3Key'; ParameterValue = 'vpc-stack-naming.zip'},
    @{ParameterKey = 'VpnDestinationCidr'; ParameterValue = '192.168.6.0/24'}
    @{ParameterKey = 'WinAcmeS3Key'; ParameterValue = 'win-acme.v2.2.4.1500.x64.pluggable.zip'}
)
$CFNStack = @{
    StackName = 'Stack-NetCov'
    Capability = 'CAPABILITY_IAM', 'CAPABILITY_AUTO_EXPAND'
    DisableRollback = $true
    Parameter = $Parameter
    TemplateURL = 'https://netcov-set-devtest1-internal-us-west-1.s3.us-west-1.amazonaws.com/NetCov-VPC-AD-RDS-Main-Stack.template' 
    Region = $Region
    ProfileName = 'set-devtest1-internal'
}
New-CFNStack @CFNStack