<# Use this script for offboarding users.
Consider adding a feature to offboard multiple users (maybe from csv).
@Authors: Sean Bachiller, Rabiya Amodwala
#>

function main {
$User1 = Read-Host "Enter the USERNAME of the person to offboard:"
    if (@(Get-ADUser -Filter { SamAccountName -eq $User1 }).Count -eq 0) {
        Write-Warning -Message "User $User1 does not exist."
    }
    else {
    #Remove manager 
    Set-ADUser -Identity $User1 -Clear manager
    #Remove groups
    $keep = @('CN=Domain Users,CN=Users,DC=sbllc,DC=org') #change
    $groups.Where({$_ -notin ($keep)}) |
    % { Remove-ADGroupMember -Identity $_ -Members $User1 }
    #Hide from address lists
    Set-ADObject -Identity $User1 -Replace @{msExchHideFromAddressLists=$true}
    #Disable account
    Set-ADUser -Identity $User1 -Enabled $false
    exit
    }
}
main

