Param (
    [Parameter(Mandatory=$True)][String]$SourcePath
)


Get-ChildItem $SourcePath\*  -recurse -Include *.n3,*.ttl,*.xml,*.js,*.txt,*.css | ForEach-Object {
$content = $_ | Get-Content

Set-Content -PassThru $_.Fullname $content -Encoding UTF8 -Force}
