<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Update-dsMemberNumber
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory)][ValidateScript({Test-Path $_ -PathType 'Leaf'})] $csvfile
    )

    Begin
    {
        Try {
                Get-AzureADTenantDetail -ErrorAction Stop | Out-null
            } Catch {
                Connect-AzureAD
            }
        $memberlist= Import-csv -Path $csvfile
    }
    Process
    {
        Foreach($member in $memberlist) {
            Write-Verbose "Updating $($member.upn) to $($member.number)"
            Set-AzureADUserExtension -ObjectId $member.upn -ExtensionName "extension_f78b8b10d59f499ca99da2acdc29191b_membership_number" -ExtensionValue $member.number
        }
    }
    End
    {
    }
}