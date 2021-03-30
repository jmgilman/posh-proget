$SERVER_ENDPOINTS = @{
    health = '/health'
}

<#
.SYNOPSIS
    Queries the server health of the ProGet server
.DESCRIPTION
    Uses the given ProGet session to connect to the ProGet server and returns
    a ServerHealth object with the health details of the server.
.PARAMETER Session
    An existing ProGetSession object used to connect to the server
.EXAMPLE
    $health = Get-ServerHealth $session
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function Get-ServerHealth {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session
    )

    #try {
    Invoke-ProGetApi `
        -Session $Session `
        -Endpoint $SERVER_ENDPOINTS.health `
        -Transform { [ServerHealth]::FromJson($_) }
    #}
    #catch {
    #    Write-Error "Unable to get server health: $($_.ErrorDetails.Message)"
    #    return
    #}
}