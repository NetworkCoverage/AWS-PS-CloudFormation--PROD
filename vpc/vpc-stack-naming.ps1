# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWS.Tools.S3 module, add a "#Requires" statement
# indicating the module and version. If using an AWS.Tools.* module the AWS.Tools.Common module is also required.

#Requires -Modules @{ModuleName='AWS.Tools.Common'; ModuleVersion='4.1.518'}
#Requires -Modules @{ModuleName = 'AWS.Tools.EC2'; ModuleVersion = '4.1.518'}

function Signal-AWSCloudFormation {
    param (
        [System.String]
        [ValidateSet('SUCCESS', 'FAILED')]
        $SignalType = 'SUCCESS',

        [System.String]
        $Reason
    )
    #Format response to CloudFormation
    $Body = @{
        Status = $SignalType
        PhysicalResourceId = $LambdaContext.LogStreamName
        StackId = $LambdaInput.StackId
        RequestId = $LambdaInput.RequestId
        LogicalResourceId = $LambdaInput.LogicalResourceId
    }

    if ($SignalType -eq 'FAILED') {
        if (-not $PSBoundParameters.ContainsKey('Reason')) {
            $Body['Reason'] = ('See the details in CloudWatch Log Stream:`n[Group] {0}`n[Stream] {1}' -f $LambdaContext.LogGroupName, $LambdaContext.LogStreamName)        
        }
        else {
            $Body['Reason'] = $Reason
        }        
    }       
       
    Write-Host "Sending $SignalType response to CloudFormation"
    Invoke-WebRequest -Uri ([Uri]$LambdaInput.ResponseURL) -Method Put -Body (ConvertTo-Json -InputObject $body -Compress -Depth 5)
    exit  
}

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

#Parse input variables
$AvailabilityZone1 = $LambdaInput.ResourceProperties.AvailabilityZone1
$AvailabilityZone2 = $LambdaInput.ResourceProperties.AvailabilityZone2
$CustomerAbbreviation = $LambdaInput.ResourceProperties.CustomerAbbreviation
$CustomerGateway = $LambdaInput.ResourceProperties.CustomerGateway
$InternetGateway = $LambdaInput.ResourceProperties.InternetGateway
$Region = $LambdaInput.ResourceProperties.Region
$RouteTable = $LambdaInput.ResourceProperties.RouteTable
$SecurityGroup = $LambdaInput.ResourceProperties.SecurityGroup
$Subnet1 = $LambdaInput.ResourceProperties.Subnet1
$Subnet2 = $LambdaInput.ResourceProperties.Subnet2
$VpcId = $LambdaInput.ResourceProperties.Vpc
$VpnConnection = $LambdaInput.ResourceProperties.VpnConnection

if ($null -ne $LambdaInput.ResourceProperties.TransitGateway) {
    $TransitGateway = $LambdaInput.ResourceProperties.TransitGateway
}
if ($null -ne $LambdaInput.ResourceProperties.TransitGatewayAttachment) {
    $TransitGatewayAttachment = $LambdaInput.ResourceProperties.TransitGatewayAttachment
}
<# if ($null -ne $LambdaInput.ResourceProperties.TransitGatewayRouteTable) {
    $TransitGatewayRouteTable = $LambdaInput.ResourceProperties.TransitGatewayRouteTable
} #>
if ($null -ne $LambdaInput.ResourceProperties.VpnGateway) {
    $VpnGateway = $LambdaInput.ResourceProperties.VpnGateway
}


try {
    if ($LambdaInput.RequestType -eq 'Create') {
        switch ($Region) {
            'us-east-1' {$RegionCode = 'use1'}
            'us-east-2' {$RegionCode = 'use2'}
            'us-west-1' {$RegionCode = 'usw1'}
            'us-west-2' {$RegionCode = 'usw2'}
            'ap-east-1' {$RegionCode = 'ape1'}
            'ap-south-1' {$RegionCode = 'aps1'}
            'ap-northeast-3' {$RegionCode = 'apne3'}
            'ap-northeast-2' {$RegionCode = 'apne2'}
            'ap-southeast-1' {$RegionCode = 'apse1'}
            'ap-southeast-2' {$RegionCode = 'apse2'}
            'ap-northeast-1' {$RegionCode = 'apne1'}
            'ca-central-1' {$RegionCode = 'cac1'}
            'eu-central-1' {$RegionCode = 'euc1'}
            'eu-west-1' {$RegionCode = 'euw1'}
            'eu-west-2' {$RegionCode = 'euw2'}
            'eu-west-3' {$RegionCode = 'euw3'}
            'eu-north-1' {$RegionCode = 'eun1'}
            'us-gov-east-1' {$RegionCode = 'usge1'}
            'us-gov-west-1' {$RegionCode = 'usgw1'}
        }

        $VpcName = '{0}-{1}-vpc01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $VpcId -Tag @{Key = 'Name' ; Value = $VpcName} -Region $Region

        $Subnet1Name = '{0}-{1}{2}-vpc01-pub-sn01' -f $CustomerAbbreviation, $RegionCode, $AvailabilityZone1[-1]
        New-EC2Tag -Resource $Subnet1 -Tag @{Key = 'Name' ; Value = $Subnet1Name} -Region $Region

        $Subnet2Name = '{0}-{1}{2}-vpc01-pub-sn02' -f $CustomerAbbreviation, $RegionCode, $AvailabilityZone2[-1]
        New-EC2Tag -Resource $Subnet2 -Tag @{Key = 'Name' ; Value = $Subnet2Name} -Region $Region

        $InternetGatewayName = '{0}-{1}-vpc01-igw01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $InternetGateway -Tag @{Key = 'Name' ; Value = $InternetGatewayName} -Region $Region

        # Default route table
        $DefaultRouteTable = Get-EC2RouteTable -Region $Region -Filter @{Name = 'vpc-id'; Values = $VpcId}  | Where-Object -FilterScript {$_.Associations.Main -eq $true}
        $RouteTableName = '{0}-{1}-vpc01-default-rt' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $DefaultRouteTable.RouteTableId -Tag @{Key = 'Name' ; Value = $RouteTableName} -Region $Region
        
        $RouteTableName = '{0}-{1}-vpc01-pub-rt01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $RouteTable -Tag @{Key = 'Name' ; Value = $RouteTableName} -Region $Region

        if ($TransitGateway) {
            $TransitGatewayName = '{0}-{1}-tgw01' -f $CustomerAbbreviation, $RegionCode
            New-EC2Tag -Resource $TransitGateway -Tag @{Key = 'Name' ; Value = $TransitGatewayName} -Region $Region
            
            $TransitGatewayAttachmentName = '{0}-{1}-vpc01-tgw01-att01'  -f $CustomerAbbreviation, $RegionCode
            New-EC2Tag -Resource $TransitGatewayAttachment -Tag @{Key = 'Name' ; Value = $TransitGatewayAttachmentName} -Region $Region

            $VpnTransitGatewayAttachment = Get-EC2TransitGatewayAttachment -Region $Region -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = $TransitGateway}) 
            for ($i = 0; $i -lt $VpnTransitGatewayAttachment.Count; $i++) {
                $VpnTransitGatewayAttachmentName =  '{0}-{1}-vpn01-tgw01-att{2:d2}' -f $CustomerAbbreviation, $RegionCode, ($i + 2)
                New-EC2Tag -Resource $VpnTransitGatewayAttachment.TransitGatewayAttachmentId -Tag @{Key = 'Name' ; Value = $VpnTransitGatewayAttachmentName} -Region $Region 
            }
             
            $TransitGatewayRouteTable = Get-EC2TransitGatewayRouteTable -Filter @{Name = 'transit-gateway-id'; Values = $TransitGateway} -Region $Region
            $TransitGatewayRouteTableName = '{0}-{1}-tgw01-rt01' -f $CustomerAbbreviation, $RegionCode
            Write-Host ('Applying name tag {0} to transit gateway route table {0}' -f $TransitGatewayRouteTableName, ($TransitGatewayRouteTable | ConvertTo-Json -Depth 3))
            New-EC2Tag -Resource $TransitGatewayRouteTable.TransitGatewayRouteTableId -Tag @{Key = 'Name' ; Value = $TransitGatewayRouteTableName} -Region $Region
        }

        if ($VpnGateway) {
            $VpnGatewayName = '{0}-{1}-vpc01-vgw01' -f $CustomerAbbreviation, $RegionCode
            New-EC2Tag -Resource $VpnGateway -Tag @{Key = 'Name' ; Value = $VpnGatewayName} -Region $Region
        }

        $CustomerGatewayName = '{0}-{1}-cgw01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $CustomerGateway -Tag @{Key = 'Name' ; Value = $CustomerGatewayName} -Region $Region

        $VpnConnectionName = '{0}-{1}-{2}-vpn01' -f $CustomerAbbreviation, $RegionCode, $(if ($TransitGateway) {'tgw01'} else {'cgw01'})
        New-EC2Tag -Resource $VpnConnection -Tag @{Key = 'Name' ; Value = $VpnConnectionName} -Region $Region

        $DefaultSecurityGroup = Get-EC2SecurityGroup -Filter @(@{Name = 'vpc-id'; Values = $VpcId}, @{Name = 'group-name'; Values = 'default'}) -Region $Region
        $SecurityGroupName = '{0}-{1}-vpc01-default-sg' -f $CustomerAbbreviation, $RegionCode
        Write-Host ("Attempting to tag the vpc {0} default security group: {1}" -f ($DefaultSecurityGroup | ConvertTo-Json -Depth 3), $VpcId)
        New-EC2Tag -Resource $DefaultSecurityGroup.GroupId -Tag @{Key = 'Name' ; Value = $SecurityGroupName} -Region $Region

        # Security group name tag
        $SecurityGroupName = '{0}-{1}-vpc01-sg01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $SecurityGroup -Tag @{Key = 'Name' ; Value = $SecurityGroupName} -Region $Region
        
        # DHCP option set
        $DefaultDhcpOption = Get-EC2DhcpOption -DhcpOptionsId (Get-EC2Vpc -VpcId $VpcId -Region $Region).DhcpOptionsId -Region $Region
        $DhcpOptionName = '{0}-{1}-vpc01-default-dos' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $DefaultDhcpOption.DhcpOptionsId -Tag @{Key = 'Name' ; Value = $DhcpOptionName} -Region $Region

        Signal-AWSCloudFormation -SignalType SUCCESS
    }
    else {Signal-AWSCloudFormation -SignalType SUCCESS}
}
catch {
    Write-Host $_
    Signal-AWSCloudFormation -SignalType FAILED -Reason $_
}