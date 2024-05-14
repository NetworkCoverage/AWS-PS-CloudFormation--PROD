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

#Requires -Modules @{ModuleName = 'AWS.Tools.Common'; ModuleVersion = '4.1.320'}
#Requires -Modules @{ModuleName = 'AWS.Tools.EC2'; ModuleVersion = '4.1.320'}

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

$ErrorActionPreference = 'Stop'

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
            $Body['Reason'] = ("See the details in CloudWatch Log Stream:`n[Group] {0}`n[Stream] {1}" -f $LambdaContext.LogGroupName, $LambdaContext.LogStreamName)        
        }
        else {
            $Body['Reason'] = $Reason
        }        
    }   
       
    Write-Host "Sending $SignalType response to CloudFormation"
    Invoke-WebRequest -Uri ([Uri]$LambdaInput.ResponseURL) -Method Put -Body (ConvertTo-Json -InputObject $body -Compress -Depth 5)
    exit    
}

#Parse input variables
$Region = $LambdaInput.ResourceProperties.Region
$RouteTableId = $LambdaInput.ResourceProperties.RouteTable
#$VpnConnectionId = $LambdaInput.ResourceProperties.VpnConnection
$VpnDestinationCidr = $LambdaInput.ResourceProperties.VpnDestinationCidr
$VpcId = $LambdaInput.ResourceProperties.VpcId

if ($null -ne $LambdaInput.ResourceProperties.TransitGateway) {
    $TransitGatewayId = $LambdaInput.ResourceProperties.TransitGateway
}

<# if ($null -ne $LambdaInput.ResourceProperties.VpnGateway) {
    $VpnGatewayId = $LambdaInput.ResourceProperties.VpnGateway
} #>

try {
    switch ($LambdaInput.RequestType) {
        'Create' {
            if ($TransitGatewayId) {          
                $TransitGatewayRouteTable = Get-EC2TransitGatewayRouteTable -Filter @{Name = 'transit-gateway-id'; Values = $TransitGatewayId} -Region $Region                 
                #Add vpn routes to transit gateway route table in us-east
                $VpnDestinationCidr | ForEach-Object { 
                    $TransitGatewayRoute = @{
                        TransitGatewayRouteTableId = $TransitGatewayRouteTable.TransitGatewayRouteTableId
                        DestinationCidrBlock = $_
                        TransitGatewayAttachmentId = (Get-EC2TransitGatewayAttachment -Region $Region -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = $TransitGatewayId})).TransitGatewayAttachmentId 
                        Region = $Region
                    }
                    Write-Host ('Attempting to add the vpn routes to the routing table with the following parameters: {0}' -f ($TransitGatewayRoute  | ConvertTo-Json))
                    New-EC2TransitGatewayRoute @TransitGatewayRoute
                }
                
                $VpnDestinationCidr | ForEach-Object {
                    $EC2Route = @{
                        RouteTableId = $RouteTableId
                        DestinationCidrBlock = $_
                        TransitGatewayId = ($TransitGatewayId)
                        Region = $Region
                    }
                    Write-Host ('Attempting to add the vpn routes to the vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
                    New-EC2Route @EC2Route
                }
            }

            <# if ($VpnGatewayId) {
                #Add vpn routes to a static route for a VPN connection between an existing virtual private gateway and a VPN customer gateway.
                $VpnDestinationCidr | ForEach-Object { 
                    New-EC2VpnConnectionRoute -VpnConnectionId $VpnConnectionId  -DestinationCidrBlock $_ -Region $Region
                }
            }                
            
            $DefaultRouteTable = Get-EC2RouteTable -Region $Region -Filter @{Name = 'vpc-id'; Values = $VpcId}  | Where-Object -FilterScript {$_.Associations.Main -eq $true}
            
            # Set new route table as main
            $Params = @{
                AssociationId = $DefaultRouteTable.Associations.RouteTableAssociationId
                RouteTableId = $RouteTableId
                Region = $Region
            }
            Set-EC2RouteTableAssociation @Params
            
            # Delete default routing table
            Remove-EC2RouteTable -RouteTableId $DefaultRouteTable.RouteTableId -Region $Region -Force #>

            $DefaultSecurityGroup = Get-EC2SecurityGroup -Filter @(@{Name = 'vpc-id'; Values = $VpcId}, @{Name = 'group-name'; Values = 'default'}) -Region $Region
            
            # Remove inbound and outbound rules from default security group
            Get-EC2SecurityGroupRule -Filter @{Name = 'group-id'; Values = $DefaultSecurityGroup.GroupId} -Region $Region | ForEach-Object -Process {
                if ($_.IsEgress -eq $true) {
                    Revoke-EC2SecurityGroupEgress -GroupId $DefaultSecurityGroup.GroupId -SecurityGroupRuleId $_.SecurityGroupRuleId -Force -Region $Region
                }
                else {
                    Revoke-EC2SecurityGroupIngress -GroupId $DefaultSecurityGroup.GroupId -SecurityGroupRuleId $_.SecurityGroupRuleId -Force -Region $Region
                }
            }

            # Signal completion
            Signal-AWSCloudFormation -SignalType SUCCESS
        }
        'Update' {Signal-AWSCloudFormation -SignalType SUCCESS}
        'Delete' {Signal-AWSCloudFormation -SignalType SUCCESS}
    }
    
}
catch {
    Write-Host $_
    Signal-AWSCloudFormation -SignalType FAILED -Reason $_
}