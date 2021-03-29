Function Join-Uri {
    <#
    .SYNOPSIS
        Joins two URI segments into a single absolute one
    .PARAMETER BaseUri
        The first URI segment
    .PARAMETER RelativeUri
        The second URI segment
    .EXAMPLE
        Join-Uri "http://my.website.com/" "path/to/page"
    .INPUTS
        The first URI segment can be piped in by type
    .OUTPUTS
        [string] The absolute Uri generated from the given segments
    #>
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [string] $BaseUri,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $RelativeUri
    )

    (New-Object -TypeName 'System.Uri' -ArgumentList ([System.Uri]$BaseUri), $RelativeUri).AbsoluteUri
}

Function Invoke-ProGetApi {
    <#
    .SYNOPSIS
        Invokes the given API endpoint using an existing session
    .DESCRIPTION
        This function is a small wrapper for sending REST requests to the ProGet
        Web API. It uses the connection and authentication information from an
        existing ProGetSession object (see New-ProgetSession) and sends a
        request to the given endpoint with the (optional) given payload. The
        return value comes directly from the Powershell Invoke-RestMethod 
        function.
    .PARAMETER Session
        An existing ProGetSession object used to connect to the API
    .PARAMETER EndPoint
        The API endpoint to send the request to
    .PARAMETER Method
        The type of HTTP request to use (defaults to GET)
    .Parameter ContentType
        The content type of the given payload (defaults to Json)
    .Parameter Data
        The payload to send to the endpoint. If the content type is set to JSON,
        the passed value should be a Powershell object which will be converted
        into JSON before being sent.
    .EXAMPLE
        $json = Invoke-ProGetApi -Session $Session -Endpoint '/api/management/feeds/list'
    .INPUTS
        The session can be piped in by type
    .OUTPUTS
        [object[]] The response from the API
    #>
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string] $EndPoint,
        [string] $Method = 'GET',
        [string] $ContentType = 'application/json',
        [object] $Data
    )

    if ($ContentType -eq 'application/json') {
        $Data = ConvertTo-Json $Data -Depth 3
    }

    $headers = @{
        'X-ApiKey' = $Session.ApiToken
    }
    $params = @{
        Method      = $Method
        Uri         = Join-Uri $Session.Address $EndPoint
        ContentType = $ContentType
        Headers     = $headers
        Body        = $Data
    }
    
    Invoke-RestMethod @params
}