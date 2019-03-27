$compasslist = Import-csv -path 'C:\Users\Artfulbodger\Downloads\County Appointments Report %28Beta%29.csv' | where-object {$_.Role -notlike '*Occasional Helper'}
$listID = 'a512378808'
$mailchimpAPIKey = 'e8197bfcdd50c5ba7ea60786daabcc88-us13'
$dc='us13'
$user = 'anystring'
$pair = "${user}:${mailchimpAPIKey}"
$bytes = [Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [Convert]::ToBase64String($bytes)
$basicAuthValue = ('Basic {0}' -f $base64)
$headers = @{ Authorization = $basicAuthValue }
$mailchimplist = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$($listID))" -Headers $headers -Method GET
Foreach ($member in $compasslist) {
  

}