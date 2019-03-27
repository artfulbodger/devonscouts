#requires -module AzureAD
#requires -version 4
function Update-dsOffice365UsersfromCompass
{
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory)]$credential,
      [Parameter(Mandatory,HelpMessage='Member Directory Report from Compass')]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if($_ -notmatch "(\.csv)"){
                throw "The file specified in the path argument must be as csv file"
            }
            return $true 
        })][System.IO.FileInfo]$memberdirectory,
      [Parameter()]
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if($_ -notmatch "(\.csv)"){
                throw "The file specified in the path argument must be as csv file"
            }
            return $true 
        })][System.IO.FileInfo]$appointmentreport,
      [switch]$testdata
    )

    Begin
    {
        Try {
                Get-AzureADTenantDetail -ErrorAction Stop | Out-null
            } Catch {
                Connect-AzureAD -Credential $credential
            }
            New-dsEXOConnection
        $aduserlist = @()
        $memberslist = @()
        $emailaddressupdatecount = 0
        $roleupdatecount = 0
    }
    Process
    {
      #region Initial Data collection from AAD
        If($testdata){
          $adusers = Get-AzureADUser -Top 100 | Where-Object {$_.AssignedLicenses.Count -gt 0} | select-object GivenName, Surname, JobTitle, UserPrincipalName, mail
        } Else {
          $adusers = Get-AzureADUser -All $true | Where-Object {$_.AssignedLicenses.Count -gt 0} | select-object GivenName, Surname, JobTitle, UserPrincipalName, mail
        }
        Write-verbose -Message "Found $($adusers.count) Azure AD Users."
          $i = 1
          $indexcounter = 0
          Foreach ($user in $adusers) {
            Write-verbose -Message "Processing user $i of $($adusers.count)"  
            $member_no,$email = $null
            $rolelist = @()
              Try {
                $aadmail = Get-Mailbox $user.UserPrincipalName
                If($aadmail.forwardingsmtpaddress -eq $null){
                  $mail = [string]($aadmail.EmailAddresses | where-object -FilterScript {$_ -clike 'SMTP:*'}).substring(5)
                } else {
                  $mail = [string]($aadmail.forwardingsmtpaddress).substring(5)
                }
                # Get membership number from AAD user object
                Try {
                  $member_no = (Get-AzureADUserExtension -ObjectId $user.UserPrincipalName).get_item('extension_f78b8b10d59f499ca99da2acdc29191b_membership_number')
                } Catch {
              
                }               
                $aduserlist += [pscustomobject]@{
                  'Index' = $indexcounter
                  'Membership Number' = $member_no
                  'Firstname'=$user.GivenName
                  'Surname'=$user.Surname
                  'Role' = $user.JobTitle
                  'RoleList' = $rolelist
                  'Email' = $mail
                  'UPN' = $user.UserPrincipalName
                  'Source' = 'AAD'
                  }
                $indexcounter ++
              } Catch {
                Write-verbose -Message "$_.Exception.Message"
                  }
            $i ++
          }
       #endregion
    
      #region Membership Directory Report merge
      $memberslist = Import-CSV -Path $memberdirectory
      Write-Verbose -Message "Found $($memberslist.count) members in the directory file"
      Foreach($member in $memberslist)
      {
        $compassrole = $null
        If($aduserlist.'Membership Number' -contains $member.contact_number){
          Write-Verbose -Message "Found member $($member.contact_number) on AAD User List"
          $index = ($aduserlist | Where-Object {$_.'Membership Number' -eq $member.contact_number}).Index
          If ($member.primary_role -ne ''){
            $compassrole = $member.primary_role
          } else {
            $compassrole = $member.Role
          }
          # Check if roles match and update to Compass value if not
          If ($compassrole -ne $aduserlist[$index].role){
            write-verbose -Message "Role mismatch for member $($member.contact_number) (Compass:$($compassrole) vs AAD:$($aduserlist[$index].role))"
            $aduserlist[$index].role = $compassrole
            $aduserlist[$index].source = 'Compass Update'
          } else {
            Write-verbose -Message "Role matched for member $($member.contact_number) - no role update required"
          }
          #Check if email address matches and update to Compass value if not
          If ($member.EmailAddress1 -ne $aduserlist[$index].Email){
            If (-not ([string]::IsNullOrEmpty($member.EmailAddress1))){
              Write-Verbose -Message "Email address mismatch for member $($member.contact_number) (Compass:$($member.EmailAddress1) vs AAD:$($aduserlist[$index].Email))"
              $aduserlist[$index].Email = $member.EmailAddress1
              $aduserlist[$index].source = 'Compass Update'
            } else {
              Write-Verbose -Message "Email address empty for member $($member.contact_number) - no Email update possible"
            }
          } else {
            Write-Verbose -Message "Email address matched for member $($member.contact_number) - no Email update required"
          }
        }
      }
      #endregion
      
      #region Appointments report merge
      Foreach($appt in $appointmentreport){
        <#
          Iterate throgh all the appointment enteries and where the membership number matches add it to the id=ndex entry .rolelist array
          #>
      }
      #endregion
      
      #region Update AAD with Compass Updates
        
        Foreach ($aaduser in $aduserlist){
          If ($aaduser.source -eq 'Compass Update'){
            Try{
              Set-AzureADUser -ObjectId $aaduser.upn -JobTitle $aaduser.Role
              Write-Verbose -Message "AAD User role updated for user $($aaduser.upn) to $($aaduser.Role)"
            } Catch {
              Write-Error -Message "Failed to update Role for $($aaduser.upn)"
            }
            #Update Email address
            If ($aaduser.Email -notlike "*@devonscouts.org.uk"){
              # Update to external forwarding
              Try {
                Set-Mailbox $($aaduser.upn) -ForwardingAddress $null
                Start-Sleep -Seconds 1
                Set-Mailbox $($aaduser.upn) -ForwardingSmtpAddress "smtp:$($aaduser.Email)" -DeliverToMailboxAndForward $False -ErrorAction STOP
                $emailaddressupdatecount ++
                Write-Verbose -Message "Updated Forwarding Email address for $($aaduser.upn)"
              } Catch {
                Write-Error -Message "Failed to update Forwarding Email address for $($aaduser.upn)"
              }
            } else {
              # Update to remove forwarding
              Try {
                Set-Mailbox $($aaduser.upn) -ForwardingAddress $null
                $roleupdatecount ++
                Write-Verbose -Message "Removed Forwarding Email address for $($aaduser.upn)"
              } Catch {
                Write-Error -Message "Failed to remove Forwarding Email address for $($aaduser.upn)"
              }
            }
          }
        }
        
      #endregion
    }
    End
    {
      If($testdata){
        $aduserlist
      }
      Write-Host "Email addresses updated in O365: $($emailaddressupdatecount)"
      Write-Host "Roles updated in O365: $($roleupdatecount)"
    }
}