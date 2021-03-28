Function Join-Uri {
    param(
        [string] $BaseUri,
        [string] $RelativeUri
    )

    (New-Object -TypeName 'System.Uri' -ArgumentList ([System.Uri]$BaseUri), $RelativeUri).AbsoluteUri
}

Function Invoke-ProGetApi {
    param(
        [ProGetSession] $Session,
        [string] $EndPoint,
        [string] $Method = 'GET',
        [string] $ContentType = 'application/json',
        [object[]] $Data
    )

    $headers = @{
        'X-ApiKey' = $Session.ApiToken
    }
    $params = @{
        Method      = $Method
        Uri         = Join-Uri $Session.Address $EndPoint
        ContentType = $ContentType
        Headers     = $headers
    }
    
    Invoke-RestMethod @params
}