<# Use this script for offboarding users.
Consider adding an option for multiple users
@Authors: Sean Bachiller, Rabiya Amodwala
#>

function main {
    $User = Read-Host "Enter the USERNAME of the person to offboard"
    try {
    #Verify user exists
        $adUser = Get-ADUser -Identity $User -ErrorAction Stop
    #Hide from address lists - this is conditional since I don't have Exchange schemas to test
        if (Get-ADObject -Filter 'lDAPDisplayName -like "msExchHideFromAddressLists"' -SearchBase (Get-ADRootDSE).schemaNamingContext) {
        $adUser | Set-ADUser -Replace @{msExchHideFromAddressLists=$true}
    }
    #Clear manager
        $adUser | Set-ADUser -Clear manager
        $adUser | Set-ADUser -Enabled $false
    #Remove groups
        $keep = 'CN=Domain Users,CN=Users,DC=sbllc,DC=org' #change
        $groups = Get-ADUser -Identity $User -properties memberof | select -expand memberof
        $groups.Where({$_ -notin ($keep)}) |
        % { Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false } 
    #Move to Offboarded OU
        $adUser | Move-ADObject -TargetPath "OU=Offboarded,DC=sbllc,DC=org"
        Write-Host -ForegroundColor Green "Successfully offboarded $User"
        pause
    } catch {
        throw
    }
}
main
