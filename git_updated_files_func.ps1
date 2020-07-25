#$baseLocation = "C:\sosys\SOSYS_OFFICER_PORTAL"
#$copyLocation = "C:\update"
# "C:\sosys\SOSYS_OFFICER_PORTAL" "C:\update" "7cbdb654863f84aa9c630027eb77353fbbaa8d5b" "b43f66ea63745dfcdffd521cf928849d95251c83"
$dateFormatStr = (get-date -format "yyyy_MM_dd_HH").toString()
$csFiles = "csFIles.txt"
$filesLogs = "logs.txt"
$errorLogs = "error.txt"
$ErrorActionPreference = "Stop"

Function create-file($file){
    if(-not ([System.IO.File]::Exists($file))){
        New-Item -Path $file -ItemType "file"
    }
}

Function copy-changeddll($baseLocation, $childPath, $copyLocation){
    $loc = $baseLocation
    foreach($i in $childPath.split("\").split("/")){
        $loc = $loc+"\"+$i
        if([System.IO.Directory]::Exists($loc)){
            
        }
    }
}

Function copy-changedfiles($baseLocation, $copyLocation, $newHash, $oldHash){
    try
    {
        $copyLocation = Join-Path -path $copyLocation -childpath $dateFormatStr
        if(-not(Test-Path $copyLocation)){
            New-Item -Path $copyLocation -ItemType "directory"
        }
        $errorLogLocation = Join-Path -Path $copyLocation -ChildPath $errorLogs
        create-file($errorLogLocation)
        if(-not(Test-Path $baseLocation)){
            throw "Cannot continue!! Souce directory doesn't exists" 
        }
        $csFileLocation = Join-Path -path $copyLocation -childpath $csFiles
        create-file($csFileLocation)
        $filesLogsLocation = Join-Path -path $copyLocation -childpath $filesLogs
        create-file($filesLogsLocation)
        cd $baseLocation

        $filesChanged = git diff --name-only $newHash $oldHash
        [string[]]$arrayOfFiles = $filesChanged
        foreach ($i in $arrayOfFiles) {
            try{
                $curpath = Join-Path -path $baseLocation -childpath $i
	            if($curpath -like "*.cs*"){
                    if($curpath -like "*ashx.cs*"){
                        Copy-Item $curpath -Destination $copyLocation
                    }
                    else {
                        Add-Content $csFileLocation $curpath
                    }
                    copy-changeddll $baseLocation $i $copyLocation
                } else {
                    Copy-Item $curpath -Destination $copyLocation
                }
                Add-Content $filesLogsLocation $curpath
            } Catch [System.Management.Automation.ActionPreferenceStopException] {
                Write-Output "Error: $($error[0])"
                Add-Content $errorLogLocation $error[0]
            }
        }
    } Catch [System.Management.Automation.ActionPreferenceStopException] {
        Write-Output "Error: $($error[0])"
        Add-Content $errorLogLocation $error[0]
    }
}