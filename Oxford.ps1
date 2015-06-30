function Invoke-Oxford
{
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[string] $OxfordKey,
[string] $Api,
[string] $Lang = 'en',
[string] $Detect = $true,
[string] $InFile
)
Process
{
$endpoint = 'api.projectoxford.ai';
$uri = "https://" + $endpoint + $Api + "?language=$Lang&detect=$Detect&subscription-key=$OxfordKey";
$h = @{
    Uri     = $uri;
    };

if ($InFile) {
    $h += @{
        InFile        = $InFile;
        ContentType   = 'application/octet-stream';
        Method        = 'POST'
        };
    }

Invoke-RestMethod @h
}
}


function Get-Text
{
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
[string] $Image,
[Parameter(Mandatory=$true)]
[string] $OxfordKey
)
Process
{
$api = '/vision/v1/ocr';
$response = Invoke-Oxford -OxfordKey $OxfordKey -Api $api -InFile $Image

# get all the text returned

$text = "";

foreach ($r in $response.regions) {
    foreach ($l in $r.lines) {
        $once = $false;
        foreach ($w in $l.words) {
            if ($once) { $text += " "; }
            $text += $w.text;
            $once = $true;
        }
        $text += "`r`n";
    }
}

return $text;
}
}
