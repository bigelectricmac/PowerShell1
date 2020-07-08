<#
.SYNOPSIS
  Easy add/remove users from Azure Group
.DESCRIPTION
  This script will prompt for group display name and UPN of user. Will ask if the user is to be added or removed from the group
  Then will perform the appropriate action - then displays whether user is in the group or not to confirm action. 
.INPUTS
  As prompted for Group DisplayName, User UPN and action to be performed. 
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Sean McNamara sean.mcnamara@unisys.com / sean@sean-mcnamara.me
  Creation Date:  07/8/2020
  
.LINK
  http://M365Musings.blogspot.com/

.EXAMPLE
  .\Change-GroupMembership.ps1
#>

$GroupName = Read-Host "Please enter Group Name"
Write-Host "$GroupName will be the group added to."
$AADGroup = Get-AzureADGroup -searchstring $GroupName
$UserName = Read-Host "User UPN, Please"
$UserData = get-azureaduser -objectid $UserName | select userprincipalname,objectid

$Action = Read-Host "R to remove user, A to add user to or from $Groupname Group"

#Ngetting current membership of group. 
$Membership = Get-AzureADGroupMember -Objectid $AADGroup.objectid

if ($Action -match 'A') 
    {
        If($Membership.UserPrincipalName -contains $UserData.UserPrincipalName) 
        {
            Write-Host "User $UserName is already a member of $GroupName, no action needed."
            Exit 0
        }
        else 
        {
            Write-Host "Adding $UserName to $GroupName..." -ForegroundColor Green
            Add-AzureADGroupMember -Objectid  $AADGroup.objectid  -RefObjectId  $UserData.objectid
        }
    }
elseif ($Action -match 'R') 
    {
        If($Membership.UserPrincipalName -notcontains $UserData.UserPrincipalName)
        {
            Write-Host "User $UserName is not a member of $GroupName, no action needed."
            Exit 0
        }
        else 
        {
            Write-Host "Removing $UserName From $GroupName..." -ForegroundColor Green
            Remove-AzureADGroupMember -Objectid  $AADGroup.objectid  -Memberid  $UserData.objectid
        } 
    }
else 
    {
    Write-Host "There is an error - Unexpected Input. Retry the script again."-ForegroundColor Yellow
    exit 1
    }

# Check group membership to confirm action above. 
Write-Host "Checking $GroupName membership for user $UserName..."
$NewMembership = Get-AzureADGroupMember -Objectid $AADGroup.objectid
If($NewMembership.UserPrincipalName -contains $UserData.UserPrincipalName)
    {
        Write-Host "User $UserName exists in $GroupName" -ForegroundColor Green
    }
Else {Write-Host "User $UserName is not a member of $GroupName" -ForegroundColor Green}
