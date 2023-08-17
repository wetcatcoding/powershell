<#
Script checks status of all DFS folders in a namespace.
 
Need variable quantifier for test-path UnauthorizedAccessException
?breakup $dfstext.targetpath to get systemname and check for AD account / DNS
#>
#variables
$log = ".\DFS-namespace-scan_$((get-date).ToString("yyyyMMdd-HHmm")).csv"
$DFSshares = Get-DfsnFolder -path '\\tmw.com\dfs\*'
#log headers
Write-Output "DFS Path,DFS Target Path,DFS Hostname, DFS State,test-path, AD Account,test-path,test-connection" | Add-Content $log
 
function GetHostName{
  param ([string] $FilePath)
  return $FilePath -split "\\" | Where {  $_ -ne ""  } | Select -first 1
}
 
#execution
foreach($dfsshare in $DFSshares){
    $dfstext = Get-DfsnFolderTarget -path $dfsshare.path
        $dfspath = $dfstext.Path
        $dfstargetpath = $dfstext.targetpath
        $dfsstate = $dfstext.state
    $dfstest = test-path $dfsshare.path
    $dfshost = GetHostName $dfstargetpath
    try {
        Get-adcomputer $dfshost -ErrorAction Stop | Out-Null
        $dfsadhost = "True"
    }
    catch {
         $dfsadhost = "False"
    }
    $dfsping = test-connection $dfshost -count 1 -quiet
    Write-Host $dfspath $dfstargetpath $dfshost $dfsstate $dfsadhost $dfstest $dfsping
    Write-Output "$dfspath,$dfstargetpath,$dfshost,$dfsstate,$dfstest,$dfsadhost,$dfstest,$dfsping" | Add-Content $log
}
