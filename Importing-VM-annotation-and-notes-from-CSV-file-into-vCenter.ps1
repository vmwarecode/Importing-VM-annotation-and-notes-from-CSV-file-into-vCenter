function Import-VMAnnotation {  
 <#   
 .SYNOPSIS   
 Import VM information Annotation, Notes into VM Attributes  
 .DESCRIPTION   
 The function set Annotation, Notes on VM into vcenter, you will require Export-VMAnnotation function to export data into CSV file.  
 .NOTES    
 Author: Kunal Udapi   
 http://kunaludapi.blogspot.com   
 .PARAMETER N/a   
 No Parameters Required   
 .EXAMPLE   
 PS> Import-VMAnnotation -CSV c:\Temp\VMCMDB.csv   
 #>   
 [CmdletBinding()]  
 #####################################    
 ## ## Version: 1    
 ## Tested this script on successfully   
 ## 1) Powershell v4    
 ## 2) Windows 8.1  
 ## 3) vSphere 5.5 (vcenter, esxi)  
 ## 4) powercli 6.0  
 #####################################    
 Param (  
   [Parameter(Mandatory=$true, Position=0)]   
   [ValidateNotNullOrEmpty()]   
   [string]$CSV  
 )  
   Begin{  
    if (-not(Get-PSSnapin vmware.vimautomation.core -ErrorAction SilentlyContinue)) {   
     Add-PSSnapin vmware.vimautomation.core   
    } #if   
   } #Begin  
   Process{  
     $vmlist = Import-Csv $CSV  
     $NonRequiredProperties = ""  
     $properties = $vmlist | Get-Member -MemberType NoteProperty | Where-Object {($_.name -ne "VMName") -and ($_.name -ne "PowerState") -and ($_.name -ne "IPAddress") -and ($_.name -ne "FolderPath") -and ($_.name -ne "Notes")} | Select -ExpandProperty Name  
     $CustomAttributes = Get-CustomAttribute -TargetType VirtualMachine  
     foreach ($NotExist in $properties) {  
       if (!($CustomAttributes.Name -contains $Notexist)) {  
         Write-Host -BackgroundColor Yellow -ForegroundColor Black "###Custom Attribute `"$NotExist`" does not exist Creating it###"  
         [void](New-CustomAttribute -Name $NotExist -TargetType VirtualMachine)  
       } #if (-Not($CustomAttributes -contains $Notexist))  
       else {  
         Write-Host -BackgroundColor DarkGreen "###Custom Attribute `"$NotExist`" exists, Skipping it###"  
       } #else (!($CustomAttributes.Name -contains $Notexist))  
     } #foreach ($NotExist in $properties)  
     Foreach ($VMObj in $VMList) {  
       $vm = Get-VM $VMObj.VMName  
       #$VMObj.VMName  
       Write-Host -BackgroundColor DarkGreen "`t###Adding Notes and Annotation on Virtual Machine `"$Name`"###"  
       [void]($vm | Set-VM -Notes $($VMObj.notes) -Confirm:$false)  
       $Name = $vm.name  
       Foreach ($Prop in $properties) {  
         $PropValue = $VMObj.$prop        
           Write-Host -BackgroundColor Yellow -ForegroundColor Black "`t`t###Adding value `"$PropValue`" to Attribute `"$prop`"###"  
           [void]($VM | Set-Annotation -CustomAttribute $Prop -Value $Propvalue)  
       } #Foreach ($Prop in $properties)  
     } #Foreach ($VM in $VMList)  
   } #Process  
   End{  
   } #End  
 }  