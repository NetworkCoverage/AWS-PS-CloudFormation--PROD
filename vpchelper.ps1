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
$AccountId = $LambdaInput.ResourceProperties.AccountId
$AcceptorRegion = $LambdaInput.ResourceProperties.AcceptorRegion
$RequestorRegion = $LambdaInput.ResourceProperties.RequestorRegion
$VpnDestinationCidr = $LambdaInput.ResourceProperties.VpnDestinationCidr
$Vpc1SubnetCidr = $LambdaInput.ResourceProperties.Vpc1SubnetCidr
$Vpc2SubnetCidr = $LambdaInput.ResourceProperties.Vpc2SubnetCidr

#Get Vpc Ids
$AcceptorVpc = Get-EC2Vpc -Region $AcceptorRegion -Filter @{Name ='tag:Name'; Values = 'VPC'}
$RequestorVpc = Get-EC2Vpc -Region $RequestorRegion -Filter @{Name ='tag:Name'; Values = 'VPC'} 

try {
    switch ($LambdaInput.RequestType) {
        'Create' {      
            #region peering
            #Loop until both transit gateways are available or 240 seconds has passed
            do {
                Start-Sleep -Seconds 5
                $TransitGateway = Get-EC2TransitGateway -Region $RequestorRegion  | Where-Object -Property State -EQ 'available' # Use -Filter to filter for state
                $PeerTransitGateway = Get-EC2TransitGateway -Region $AcceptorRegion  | Where-Object -Property State -EQ 'available' # Use -Filter to filter for state
                Write-Host 'Waiting for both transit gateways to become available'
                
            }
            until ($TransitGateway -and $PeerTransitGateway)
            Write-Host ('Transit gateways {0} and {1} are available' -f ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId), ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId))
        
            #Create the peering attachment
            $PeeringAttachmentParams = @{
                TransitGatewayId = $TransitGateway | Select-Object -ExpandProperty TransitGatewayId
                PeerAccountId =  $AccountId 
                PeerRegion = $AcceptorRegion
                PeerTransitGatewayId = $PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId
                Region = $RequestorRegion
            } 
            Write-Host ("Attempting to create a peering attachment with the following parameters: {0}" -f ($PeeringAttachmentParams | ConvertTo-Json))
            New-EC2TransitGatewayPeeringAttachment @PeeringAttachmentParams
        
            #Loop until both peering attachment goes into pending acceptance state
            while ((Get-EC2TransitGatewayPeeringAttachment -Region $AcceptorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Select-Object -ExpandProperty State) -ne 'pendingAcceptance') {
                Write-Host 'Waiting for peering attachment to enter pending acceptance state'
                Start-Sleep -Seconds 60        
            }
            $PeeringAttachment = Get-EC2TransitGatewayPeeringAttachment -Region $AcceptorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}
            Write-Host ('Transit gateway peering attachment {0} is now pending acceptance' -f $PeeringAttachment.TransitGatewayAttachmentId)
        
            #Approve the peering connection
            $ApproveParams = @{
                TransitGatewayAttachmentId = $PeeringAttachment.TransitGatewayAttachmentId
                Region = $AcceptorRegion
            }
            Write-Host ('Attempting to approve a peering attachment with the following parameters: {0}' -f ($ApproveParams | ConvertTo-Json))
            Approve-EC2TransitGatewayPeeringAttachment @ApproveParams
        
            #Loop until peering attachment becomes available
            while ((Get-EC2TransitGatewayPeeringAttachment -TransitGatewayAttachmentId $PeeringAttachment.TransitGatewayAttachmentId -Region $RequestorRegion  | Select-Object -ExpandProperty State) -ne 'available') {
                Write-Host ('Waiting for peering attachment {0} to become available' -f $PeeringAttachment.TransitGatewayAttachmentId)
                Start-Sleep -Seconds 60        
            }
            #endregion peering
        
            #region east
            #Create the vpc attachment in us-east
            $VpcAttachmentParams = @{
                TransitGatewayId = $TransitGateway | Select-Object -ExpandProperty TransitGatewayId
                SubnetId = Get-EC2Subnet -Region $RequestorRegion | Where-Object -Property VpcId -eq ($RequestorVpc | Select-Object -ExpandProperty VpcId) | Select-Object -ExpandProperty SubnetId
                VpcId = $RequestorVpc | Select-Object -ExpandProperty VpcId
                Region = $RequestorRegion
            }
            Write-Host ('Attempting to create a vpc attachment with the following parameters: {0}' -f ($VpcAttachmentParams | ConvertTo-Json))
            $VpcAttachment = New-EC2TransitGatewayVpcAttachment @VpcAttachmentParams
        
            #Loop until vpc attachment becomes available
            while ((Get-EC2TransitGatewayVpcAttachment -TransitGatewayAttachmentId $VpcAttachment.TransitGatewayAttachmentId -Region $RequestorRegion  | Select-Object -ExpandProperty State) -ne 'available') {
                Write-Host ('Waiting for vpc attachment {0} to become available' -f $VpcAttachment.TransitGatewayAttachmentId)
                Start-Sleep -Seconds 60        
            }
        
            #Enabling route propagation for the attachment in us-east
            $TransitGatewayRouteTableId = (Get-EC2TransitGatewayRouteTable -Region $RequestorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Select-Object -ExpandProperty TransitGatewayRouteTableId)
            $RouteTablePropagation = @{
                TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                TransitGatewayAttachmentId = $VpcAttachment.TransitGatewayAttachmentId
                Region = $RequestorRegion
            }
            Write-Host ('Attempting to enable a route table propagation with the following parameters: {0}' -f ($RouteTablePropagation  | ConvertTo-Json))
            Enable-EC2TransitGatewayRouteTablePropagation @RouteTablePropagation
        
            #Add peering routes to transit gateway route table in us-east
            $Vpc2SubnetCidr.Split(",") | ForEach-Object { 
                $TransitGatewayRoute = @{
                    TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayAttachmentId = Get-EC2TransitGatewayAttachment -Region $RequestorRegion -Filter @(@{Name= 'resource-type'; Values = 'peering'}, @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Region = $RequestorRegion
                }
                Write-Host ('Attempting to add the peering routes to the route table with the following parameters: {0}' -f ($TransitGatewayRoute  | ConvertTo-Json))
                New-EC2TransitGatewayRoute @TransitGatewayRoute
            }
        
            #Loop until vpn attachment becomes available
            while ((Get-EC2TransitGatewayAttachment -Region $RequestorRegion -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty State) -ne 'available') {
                Start-Sleep -Seconds 60
                Write-Host ('Waiting for vpn attachment {0} to become available' -f (Get-EC2TransitGatewayAttachment -Region $RequestorRegion -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId))
            }
        
            #Add vpn routes to transit gateway route table in us-east
            $VpnDestinationCidr | ForEach-Object { 
                $TransitGatewayRoute = @{
                    TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayAttachmentId = Get-EC2TransitGatewayAttachment -Region $RequestorRegion -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Region = $RequestorRegion
                }
                Write-Host ('Attempting to add the vpn routes to the routing table with the following parameters: {0}' -f ($TransitGatewayRoute  | ConvertTo-Json))
                New-EC2TransitGatewayRoute @TransitGatewayRoute
            }

            #Add routes to vpc route table
            $RouteTable = Get-EC2RouteTable -Region $RequestorRegion -Filter @{Name = 'vpc-id'; Values = ($RequestorVpc | Select-Object -ExpandProperty VpcId)}

            $EC2Route = @{
                RouteTableId = $RouteTable.RouteTableId
                DestinationCidrBlock = '0.0.0.0/0'
                GatewayId = Get-EC2InternetGateway -Region $RequestorRegion -Filter @{Name = 'attachment.vpc-id'; Values = ($RequestorVpc | Select-Object -ExpandProperty VpcId)}  | Select-Object -ExpandProperty InternetGatewayId
                Region = $RequestorRegion
            }
            Write-Host ('Attempting to add default route to vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
            New-EC2Route @EC2Route

            $VpnDestinationCidr | ForEach-Object {
                $EC2Route = @{
                    RouteTableId = $RouteTable.RouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayId = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)
                    Region = $RequestorRegion
                }
                Write-Host ('Attempting to add the vpn routes to the vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
                New-EC2Route @EC2Route
            }

            $EC2Route = @{
                RouteTableId = $RouteTable.RouteTableId
                DestinationCidrBlock = $AcceptorVpc.CidrBlock
                TransitGatewayId = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)
                Region = $RequestorRegion
            }
            Write-Host ('Attempting to add the peer vpc routes to the vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
            New-EC2Route @EC2Route
            #endregion east
        
            #region west
            #Create the vpc attachment in us-west
            $VpcAttachmentParams = @{
                TransitGatewayId = $PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId
                SubnetId = Get-EC2Subnet -Region $AcceptorRegion  | Where-Object -Property VpcId -eq ($AcceptorVpc | Select-Object -ExpandProperty VpcId)  | Select-Object -ExpandProperty SubnetId
                VpcId = $AcceptorVpc | Select-Object -ExpandProperty VpcId 
                Region = $AcceptorRegion
            }
            Write-Host ('Attempting to create a vpc attachment with the following parameters: {0}' -f ($VpcAttachmentParams | ConvertTo-Json))
            $VpcAttachment = New-EC2TransitGatewayVpcAttachment @VpcAttachmentParams
        
            #Loop until vpc attachment becomes available
            while ((Get-EC2TransitGatewayVpcAttachment -TransitGatewayAttachmentId $VpcAttachment.TransitGatewayAttachmentId -Region $AcceptorRegion  | Select-Object -ExpandProperty State) -ne 'available') {
                Write-Host ('Waiting for vpc attachment {0} to become available' -f $VpcAttachment.TransitGatewayAttachmentId)
                Start-Sleep -Seconds 60
            }
        
            #Enabling route propagation for the attachment in us-west
            $TransitGatewayRouteTableId = (Get-EC2TransitGatewayRouteTable -Region $AcceptorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Select-Object -ExpandProperty TransitGatewayRouteTableId)
            $RouteTablePropagation = @{
                TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                TransitGatewayAttachmentId = $VpcAttachment.TransitGatewayAttachmentId
                Region = $AcceptorRegion
            }
            Write-Host ('Attempting to enable a route table propagation from the vpc with the following parameters: {0}' -f ($RouteTablePropagation  | ConvertTo-Json))
            Enable-EC2TransitGatewayRouteTablePropagation @RouteTablePropagation
        
            <# No need to wait for peering attachment to become available because when it is available in the first region it wil be available in the other #>
        
            #Add peering routes to transit gateway route table in us-west
            $Vpc1SubnetCidr.Split(",") | ForEach-Object { 
                $TransitGatewayRoute = @{
                    TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayAttachmentId = Get-EC2TransitGatewayAttachment -Region $AcceptorRegion -Filter @(@{Name= 'resource-type'; Values = 'peering'}, @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Region = $AcceptorRegion
                }
                Write-Host ('Attempting to add the peering routes to the route table with the following parameters: {0}' -f ($TransitGatewayRoute  | ConvertTo-Json))
                New-EC2TransitGatewayRoute @TransitGatewayRoute
            }
        
            while ((Get-EC2TransitGatewayAttachment -Region $AcceptorRegion -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty State) -ne 'available') {
                Write-Host ('Waiting for vpn attachment {0} to become available' -f (Get-EC2TransitGatewayAttachment -Region $AcceptorRegion -Filter @(@{Name = 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId))
                Start-Sleep -Seconds 60
            }
        
            #Add vpn routes to transit gateway route table in us-west
            $VpnDestinationCidr | ForEach-Object { 
                $TransitGatewayRoute = @{
                    TransitGatewayRouteTableId = $TransitGatewayRouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayAttachmentId = Get-EC2TransitGatewayAttachment -Region $AcceptorRegion -Filter @(@{Name= 'resource-type'; Values = 'vpn'}, @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}) | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Region = $AcceptorRegion
                }
                Write-Host ('Attempting to add the vpn routes to the routing table with the following parameters: {0}' -f ($TransitGatewayRoute  | ConvertTo-Json))
                New-EC2TransitGatewayRoute @TransitGatewayRoute
            }
            

            #Add routes to vpc route table
            $RouteTable = Get-EC2RouteTable -Region $AcceptorRegion -Filter @{Name = 'vpc-id'; Values = ($AcceptorVpc | Select-Object -ExpandProperty VpcId )}

            $EC2Route = @{
                RouteTableId = $RouteTable.RouteTableId
                DestinationCidrBlock = '0.0.0.0/0'
                GatewayId = Get-EC2InternetGateway -Region $AcceptorRegion -Filter @{Name = 'attachment.vpc-id'; Values = ($AcceptorVpc | Select-Object -ExpandProperty VpcId)} | Select-Object -ExpandProperty InternetGatewayId
                Region = $AcceptorRegion
            }
            Write-Host ('Attempting to add default route to vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
            New-EC2Route @EC2Route

            
            $VpnDestinationCidr | ForEach-Object {
                $EC2Route = @{
                    RouteTableId = $RouteTable.RouteTableId
                    DestinationCidrBlock = $_
                    TransitGatewayId = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)
                    Region = $AcceptorRegion
                }
                Write-Host ('Attempting to add the vpn routes to the vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
                New-EC2Route @EC2Route
            }

            $EC2Route = @{
                RouteTableId = $RouteTable.RouteTableId
                DestinationCidrBlock = $RequestorVpc.CidrBlock
                TransitGatewayId = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)
                Region = $AcceptorRegion
            }
            Write-Host ('Attempting to add the peer vpc routes to the vpc routing table with the following parameters: {0}' -f ($EC2Route  | ConvertTo-Json))
            New-EC2Route @EC2Route            
            #endregion west
        
            #region tags
            #Add name tags to reources
            $AcceptorRegion, $RequestorRegion | ForEach-Object -Process {
                $TagParams = @{
                    Resource = Get-EC2TransitGatewayPeeringAttachment -Region $_  | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Tag = @{Key = 'Name' ; Value = 'Peering Attachment'} 
                    Region = $_
                }
                New-EC2Tag @TagParams
                
                $TagParams = @{
                    Resource = Get-EC2TransitGatewayVpcAttachment -Region $_  | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Tag = @{Key = 'Name' ; Value = 'Vpc Attachment'} 
                    Region = $_
                }
                New-EC2Tag @TagParams
        
                $TagParams = @{
                    Resource = Get-EC2TransitGatewayAttachment -Region $_ -Filter @{Name= 'resource-type'; Values = 'vpn'}  | Select-Object -ExpandProperty TransitGatewayAttachmentId 
                    Tag = @{Key = 'Name' ; Value = 'Vpn Attachment'} 
                    Region = $_
                }
                New-EC2Tag @TagParams
        
                $TagParams = @{
                    Resource = Get-EC2TransitGatewayRouteTable -Region $_  | Select-Object -ExpandProperty TransitGatewayRouteTableId
                    Tag = @{Key = 'Name' ; Value = 'Transit Gateway Route Table'} 
                    Region = $_
                }
                New-EC2Tag @TagParams

                $TagParams = @{
                    Resource = Get-EC2RouteTable -Region $_  | Select-Object -ExpandProperty RouteTableId
                    Tag = @{Key = 'Name' ; Value = 'Route Table'} 
                    Region = $_
                }
                New-EC2Tag @TagParams

                #Tag the default security group
                #Tag the security group rules

            }
            #endregion tags
        
            Signal-AWSCloudFormation -SignalType SUCCESS
        }
        'Update' {Signal-AWSCloudFormation -SignalType SUCCESS}
        'Delete' {
            $TransitGateway = Get-EC2TransitGateway -Region $RequestorRegion -Filter @{Name = 'tag:Name'; Values = 'Transit Gateway'}
            $PeerTransitGateway = Get-EC2TransitGateway -Region $AcceptorRegion -Filter @{Name = 'tag:Name'; Values = 'Transit Gateway'}
            Write-Host ('{0}`n{1}' -f ($TransitGateway  | ConvertTo-Json), ($PeerTransitGateway  | ConvertTo-Json))
            
            Write-Host ('Deleting peering attachment: {0}' -f (Get-EC2TransitGatewayPeeringAttachment -Region $RequestorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}).TransitGatewayAttachmentId)
            Get-EC2TransitGatewayPeeringAttachment -Region $RequestorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Remove-EC2TransitGatewayPeeringAttachment -Region $RequestorRegion -Force
            
            Write-Host ('Deleting vpc attachment {0} in region {1}' -f (Get-EC2TransitGatewayVpcAttachment -Region $RequestorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)}).TransitGatewayAttachmentId,  $RequestorRegion)
            Get-EC2TransitGatewayVpcAttachment -Region $RequestorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($TransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Remove-EC2TransitGatewayVpcAttachment -Region $RequestorRegion -Force

            Write-Host ('Deleting vpn attachment {0} in region {1}' -f (Get-EC2TransitGatewayVpcAttachment -Region $AcceptorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)}).TransitGatewayAttachmentId, $AcceptorRegion)
            Get-EC2TransitGatewayVpcAttachment -Region $AcceptorRegion -Filter @{Name = 'transit-gateway-id'; Values = ($PeerTransitGateway | Select-Object -ExpandProperty TransitGatewayId)} | Remove-EC2TransitGatewayVpcAttachment -Region $AcceptorRegion -Force
            Signal-AWSCloudFormation -SignalType SUCCESS
        }
    }
}
catch {
    Write-Host $_
    Signal-AWSCloudFormation -SignalType FAILED -Reason $_
}