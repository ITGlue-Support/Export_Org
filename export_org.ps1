$Org_ID = Read-Host "Enter the Organization ID: "
$API_Key = Read-Host "Enter the API key: "
$destination = Read-Host "Enter the destination path: "


function exoprt_single_Org{

	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/vnd.api+json")
	$headers.Add("x-api-key", "$API_Key")

	$body = @"
	{
  		"data": {
    		"type`": `"exports",
    		"attributes": {
      		"organization-id": $Org_ID,
      		"include-logs": true
    			}
  		}
	}
"@
    try{

	    $export_data = Invoke-RestMethod 'https://api.itglue.com/exports' -Method 'POST' -Headers $headers -Body $body
	
	    Write-Host "Exproting the data...!!"
	    check_status_download
        }
    catch{

        Write-Host "Unable to export data. Please check if there is an existing export!"
    
    }

}

function check_status_download {
	start-sleep -second 30

	$check_status = Invoke-RestMethod "https://api.itglue.com/exports/$($export_data.data.id)" -Method 'GET' -Headers $headers
	if ($($check_status.data.attributes.'export-status') -eq "completed"){

		Write-Host "Backup for the Org $($check_status.data.attributes.'organization-name') is ready!"
		Invoke-RestMethod -Uri $check_status.data.attributes.'download-url' -OutFile $destination

	}
	else{
		Write-Host "Will check the status again after 20 mins!"

		check_status_download
	 }

}

exoprt_single_Org
