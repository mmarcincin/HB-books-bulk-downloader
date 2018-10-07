#HB books bulk downloader 0.1 by https://github.com/mmarcincin
#$links = "links.txt"
$invocation = (Get-Variable MyInvocation).Value
$DownloadDirectory = Split-Path $invocation.MyCommand.Path
$links = "$($DownloadDirectory)\links.txt"
$DownloadDirectory = "$($DownloadDirectory)\downloads"
#$DownloadDirectory = "downloads"
$temp = "$DownloadDirectory\temp"

write-host Download directory`: $DownloadDirectory`n

$ConCountr1=0
#Test Internet connection
While (!(Test-Connection -ComputerName humblebundle.com -count 1 -Quiet -ErrorAction SilentlyContinue )) {
	Write-Host -ForegroundColor Red "Waiting for internet connection to continue..."
	Start-Sleep -Seconds 10
	$ConCountr1 +=1
	If ($ConCountr1 -ge 12) {
		Write-Host -ForegroundColor Red "Script terminated because of no internet connection/humblebundle response for 120 seconds."
		Start-Sleep -Seconds 5
		return
	}
}


If (!(Test-Path $DownloadDirectory)){
	New-Item -ItemType directory -Path $DownloadDirectory | Out-Null
}

If (!(Test-Path $temp)){
	New-Item -ItemType directory -Path $temp | Out-Null
}
Remove-Item "$temp\*" -Recurse


If (!(Test-Path $links)){
	New-Item -ItemType file -Path $links | Out-Null
}


$currentDownload = 0
$downloadCount = Get-Content $links | Measure-Object -Line | Select -ExpandProperty Lines

Get-Content $links | Foreach-Object {
	$currentDownload++
	$host.ui.RawUI.WindowTitle = "D: " + $currentDownload + "/" + $downloadCount
	
	$ie = new-object -ComObject "InternetExplorer.Application"
	$requestUri = $_
	#$requestUri = "https://www.humblebundle.com/downloads?key=EX7qGbKUfTTEm8vY"
	#$requestUri
	#$ie.visible = $true
	$ie.silent = $true
	$ie.navigate($requestUri)
	#while($ie.Busy) { Start-Sleep -Milliseconds 100 }
	while($ie.Busy -or $ie.ReadyState -ne "4") { Start-Sleep -Milliseconds 100 }
	
	while (($ie.Document.getElementsByClassName("whitebox-redux").length -eq "0") -or ($ie.Document.getElementsByClassName("whitebox-redux")[0].innerText.length -eq "0") -or ($ie.Document.getElementsByClassName("icn").length -eq "0") -or ($ie.Document.getElementsByClassName("icn")[0].innerText.length -eq "0")) { Start-Sleep -Milliseconds 100 }
	
	$doc = $ie.Document
	$docTitle = $doc.getElementsByTagName("title")[0].innerText.trim()
	$bundleName = $docTitle.substring(0, $docTitle.lastIndexOf("(") - 1)
	$bundleName = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($bundleName))
	$bundleTitle = $bundleName -replace '[^a-zA-Z0-9/_/''/\-/ ]', '_'
	$bundleTitle = $bundleTitle -replace '/', '_'
	write-host ==============================================================
	write-host $currentDownload "/" $downloadCount - $bundleTitle
	write-host $requestUri
	write-host --------------------------------------------------------------
	
	If (!(Test-Path $temp\$bundleTitle)){
			New-Item -ItemType directory -Path $temp\$bundleTitle | Out-Null
		}
	
	$hb = $doc.getElementsByClassName("icn")
	for ($i = 0; $i -lt $hb.length; $i++) {
		$curTitle = $hb[$i].parentNode
		$humbleName = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($curTitle.getAttribute("data-human-name")))
		$humbleTitle = $humbleName -replace '[^a-zA-Z0-9/_/''/\-/ ]', '_'
		$humbleTitle = $humbleTitle -replace '/', '_'
		
		$chunkLength = $hb.length
		$chunkNumber = $i+1
		$host.ui.RawUI.WindowTitle = "D: " + $currentDownload + "/" + $downloadCount +" `| "+ $chunkNumber + "/" + $chunkLength
		
		write-host `n$chunkNumber / $chunkLength - $humbleTitle
		
		If (!(Test-Path $DownloadDirectory\$bundleTitle\$humbleTitle)){
			New-Item -ItemType directory -Path $temp\$bundleTitle\$humbleTitle | Out-Null
		}
		
		if ($curTitle.getElementsByClassName("download-buttons")[0].innerHTML.length -gt "0") {
			$downLabels = $curTitle.getElementsByClassName("download-buttons")[0].getElementsByClassName("label")
			for ($j = 0; $j -lt $downLabels.length; $j++) {
				$curLabel = $downLabels[$j].innerHTML
				
				$downLink = $downLabels[$j].parentNode.getElementsByClassName("a")[0].href
				$downName = $downLink.split("?")[0].split("/")
				$downTitle = $downName[$downName.length-1]
				write-host $curLabel - $downTitle
				$wc = New-Object System.Net.WebClient
				$downDest = "$temp\$bundleTitle\$humbleTitle\$downTitle"
				#$downDest
				If (!(Test-Path $DownloadDirectory\$bundleTitle\$humbleTitle\$downTitle)){
					$wc.DownloadFile($downLink, $downDest)
				} else {
					write-host File downloaded already, skipping...
				}
			}
			If (!(Test-Path $DownloadDirectory\$bundleTitle)){
			New-Item -ItemType directory -Path $DownloadDirectory\$bundleTitle | Out-Null
			}
			Move-Item -Path $temp\$bundleTitle\* -Destination $DownloadDirectory\$bundleTitle
		}
	}
	Remove-Item "$temp\*" -Recurse
	write-host ==============================================================
	$ie.quit()
	Start-Sleep -Seconds 2
}
$host.ui.RawUI.WindowTitle = "D: " + $currentDownload + "/" + $downloadCount +" `| Finished"
pause
