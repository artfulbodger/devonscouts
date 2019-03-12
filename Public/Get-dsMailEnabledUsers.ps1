$credential = Get-Credential
Connect-MsolService -Credential $credential
Connect-AzureAD -Credential $credential
$aduserlist = @()
Write-host "getting users"
$userlist = get-msoluser -All | Select-object Title, FirstName, LastName, UserPrincipalName, Licenses, isLicensed, WhenCreated
Write-host "checking users $($userlist.count)"
Foreach ($user in $userlist) {
  $datecreated = $user.WhenCreated.Date
  $batchdate = get-date "15/10/2017"
  If($datecreated -eq $batchdate) {
    Try {
      $member_no = (Get-AzureADUserExtension -ObjectId $user.UserPrincipalName).get_item('extension_f78b8b10d59f499ca99da2acdc29191b_membership_number')
    } Catch {
      $member_no = 'Unknown'
    }
    $aduserlist += [pscustomobject]@{'Firstname'=$user.FirstName; 'Surname'=$user.LastName; 'Role' = $user.Title; 'UPN' = $user.UserPrincipalName; 'Membership Number' = $member_no; 'Created' = $datecreated}   
  } else {
    Continue
  }
}

$aduserlist | Export-CSV -Path 'C:\Users\Artfulbodger\OneDrive - Devonshire County Scout Council\County\JAM\Email Templates\EXOStatus.csv' -NoTypeInformation

