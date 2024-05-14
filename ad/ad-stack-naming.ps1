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

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

#Parse input variables
$CustomerAbbreviation = $LambdaInput.ResourceProperties.CustomerAbbreviation
$DhcpOptionsId = $LambdaInput.ResourceProperties.DhcpOptions
$DomainController1 = $LambdaInput.ResourceProperties.DomainController1
$DomainController2 = $LambdaInput.ResourceProperties.DomainController2
$Region = $LambdaInput.ResourceProperties.Region

try {
    if ($LambdaInput.RequestType -eq 'Create') {        

        $DhcpOptionName = '{0}-{1}-vpc01-dos01' -f $CustomerAbbreviation, $RegionCode
        New-EC2Tag -Resource $DhcpOptionsId -Tag @{Key = 'Name' ; Value = $DhcpOptionName} -Region $Region
        
        $Subnet1Name = ((Get-EC2Subnet -SubnetId ((Get-EC2Instance -InstanceId $DomainController1 -Region $Region).Instances.SubnetId) -Region $Region).Tags | Where-Object {$_.Key -eq 'Name'}).Value
        $Subnet2Name = ((Get-EC2Subnet -SubnetId ((Get-EC2Instance -InstanceId $DomainController2 -Region $Region).Instances.SubnetId) -Region $Region).Tags | Where-Object {$_.Key -eq 'Name'}).Value
        
        # Domain Controller 1 network interface tags
        $NetworkInterface = Get-EC2NetworkInterface -Region $Region | Where-Object {$_.Attachment.InstanceId -eq $DomainController1}
        $NetworkInterfaceName = '{0}-{1}-{2}-{3}-eni01' -f $CustomerAbbreviation, $Subnet1Name.Split('-')[1], $Subnet1Name.Split('-')[3], $Subnet1Name.Split('-')[4]
         
        New-EC2Tag -Resource $NetworkInterface.NetworkInterfaceId -Tag @{Key = "map-migrated"; Value ="d-server-03jpm34ivsp1f1"} -Region $Region
        New-EC2Tag -Resource $NetworkInterface.NetworkInterfaceId -Tag @{Key = 'Name' ; Value = $NetworkInterfaceName} -Region $Region
        
        $Description = 'Interface eth{0} for EC2 instance {1} ({2})' -f $NetworkInterface.Attachment.DeviceIndex, $DomainController1, ((Get-EC2Instance -InstanceId $DomainController1 -Region $Region).Instances.Tags | Where-Object {$_.Key -eq 'Name'} | Select-Object -ExpandProperty Value)
        Edit-EC2NetworkInterfaceAttribute -NetworkInterfaceId $NetworkInterface.NetworkInterfaceId -Description $Description -Region $Region

        # Domain Controller 1 volume tags
        $Volume = Get-EC2Volume -Filter @{Name = 'attachment.instance-id'; Values = $DomainController1} -Region $Region
        $VolumeName = '{0}-{1}-dc01-vol01' -f $CustomerAbbreviation, $Subnet1Name.Split('-')[1]

        New-EC2Tag -Resource $Volume.VolumeId -Tag @{Key = "map-migrated"; Value ="d-server-03jpm34ivsp1f1"} -Region $Region
        New-EC2Tag -Resource $Volume.VolumeId -Tag @{Key = 'Name' ; Value = $VolumeName} -Region $Region
        
        # Domain Controller 2 network interface tags
        $NetworkInterface = Get-EC2NetworkInterface -Region $Region | Where-Object {$_.Attachment.InstanceId -eq $DomainController2}
        $NetworkInterfaceName = '{0}-{1}-{2}-{3}-eni01' -f $CustomerAbbreviation, $Subnet2Name.Split('-')[1], $Subnet2Name.Split('-')[3], $Subnet2Name.Split('-')[4]
         
        New-EC2Tag -Resource $NetworkInterface.NetworkInterfaceId -Tag @{Key = "map-migrated"; Value ="d-server-03jpm34ivsp1f1"} -Region $Region
        New-EC2Tag -Resource $NetworkInterface.NetworkInterfaceId -Tag @{Key = 'Name' ; Value = $NetworkInterfaceName} -Region $Region  
        
        $Description = 'Interface eth{0} for EC2 instance {1} ({2})' -f $NetworkInterface.Attachment.DeviceIndex, $DomainController2, ((Get-EC2Instance -InstanceId $DomainController2 -Region $Region).Instances.Tags | Where-Object {$_.Key -eq 'Name'} | Select-Object -ExpandProperty Value)
        Edit-EC2NetworkInterfaceAttribute -NetworkInterfaceId $NetworkInterface.NetworkInterfaceId -Description $Description

        # Domain Controller 2 volume tags
        $Volume = Get-EC2Volume -Filter @{Name = 'attachment.instance-id'; Values = $DomainController2} -Region $Region
        $VolumeName = '{0}-{1}-dc01-vol01' -f $CustomerAbbreviation, $Subnet2Name.Split('-')[1]

        New-EC2Tag -Resource $Volume.VolumeId -Tag @{Key = "map-migrated"; Value ="d-server-03jpm34ivsp1f1"} -Region $Region
        New-EC2Tag -Resource $Volume.VolumeId -Tag @{Key = 'Name' ; Value = $VolumeName} -Region $Region
        
        Signal-AWSCloudFormation -SignalType SUCCESS
    }
    else {
        Signal-AWSCloudFormation -SignalType SUCCESS
    }
}
catch {
    Write-Host $_
    Signal-AWSCloudFormation -SignalType FAILED -Reason $_
}