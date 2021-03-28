$FEED_ENDPOINTS = @{
    list = '/api/management/feeds/list'
}

Function Get-Feeds {
    param(
        [ProGetSession] $Session
    )
    
    $json = Invoke-ProGetApi -Session $Session -Endpoint $FEED_ENDPOINTS.list
    $json | ForEach-Object {
        [Feed]::FromJson($_)
    }
}