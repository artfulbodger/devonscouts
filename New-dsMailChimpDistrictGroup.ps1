$members = Import-csv -Path 'C:\Users\Artfulbodger\Downloads\County Member Directory %28Updated%29.csv'
$ohs = $members | Where-Object {$_.Role -like '*Occasional Helper'}
Foreach ($oh in $ohs) {
  If($oh.EmailAddress1 -eq "") {}else{ 
  Remove-dsMailchimpMember -emailaddress $oh.EmailAddress1 -verbose}
}

$members | Group-Object -Property 'Role' | Where-Object {$_.Role -like '*Occasional Helper'}
$members | Where-Object {$_.Role -like '*Occasional Helper'}| Group-Object -Property 'Role'

$districts = $members | Group-Object -Property 'District' | Sort-Object -Property 'Name'

$listID = 'a512378808'
$mailchimpAPIKey = 'e8197bfcdd50c5ba7ea60786daabcc88-us13'
$dc='us13'
$user = 'anystring'
$pair = "${user}:${mailchimpAPIKey}"
$bytes = [Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)
$basicAuthValue = ('Basic {0}' -f $base64)
$headers = @{ Authorization = $basicAuthValue }
$districtgroupid='621a59f4bf'


Foreach ($district in $districts) {
  If ($($district.name) -ne ""){
    $data = @{
        name = $($district.name)
        } | ConvertTo-Json
    #$interests = Invoke-RestMethod -Uri "https://$dc.api.mailchimp.com/3.0/lists/$listID/interest-categories/$districtgroupid/interests" -Headers $headers -Method Get
    Invoke-RestMethod -Uri "https://$dc.api.mailchimp.com/3.0/lists/$listID/interest-categories/$districtgroupid/interests" -Headers $headers -Method Post -Body $data -ContentType 'application/json'
  }
}

$districts.name[0]|get-member