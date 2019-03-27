

$memberlist = Import-CSV C:\Users\Artfulbodger\Documents\DataFixCompassO365Source.csv

Foreach ($member in $memberlist) {
  If ($($member.Email) -ne $null){
    If ($($member.Email).Contains('devonscouts.org.uk')){} else {
      Try {
        Set-Mailbox $($member.UPN) -ForwardingAddress $($member.Email) -DeliverToMailboxAndForward $False -ErrorAction STOP
      } Catch {
        Write-Host -Message "Failed to add forwarding address to $($adult.email) - $($_.Exception.Message)"
      }
    }
    
  }
  If (!([string]::IsNullOrEmpty($($member.DistrictGroup)))){
    Try {
              Add-DistributionGroupMember -Identity $($member.DistrictGroup) -Member $($member.UPN) -ErrorAction STOP
            } Catch {
              Write-host -Message "Failed to add $($adult.email) to $($group) - $($_.Exception.Message)"
            }
  }
}




