$FEED_ENDPOINTS = @{
    list   = '/api/management/{0}/list'
    get    = '/api/management/{0}/get/{1}'
    create = '/api/management/{0}/create'
    update = '/api/management/{0}/update/{1}'
    delete = '/api/management/{0}/delete/{1}'
}

<#
.SYNOPSIS
    Returns a new Feed object with the optional properties set
.DESCRIPTION
    Returns a new instance of the Feed object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the Feed with
.EXAMPLE
    $feed = New-FeedObject @{Name='chocolatey-feed'; FeedType='chocolatey'}
.OUTPUTS
    A new instance of the Feed object
#>
Function New-FeedObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object Feed -Property $Properties
}

<#
.SYNOPSIS
    Returns a new Connector object with the optional properties set
.DESCRIPTION
    Returns a new instance of the Connector object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the Connector with
.EXAMPLE
    $conn = New-ConnectorObject @{Name='chocolatey-conn'; FeedType='chocolatey'}
.OUTPUTS
    A new instance of the Connector object
#>
Function New-ConnectorObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object Connector -Property $Properties
}

<#
.SYNOPSIS
    Returns a new RetentionRule object with the optional properties set
.DESCRIPTION
    Returns a new instance of the RetentionRule object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the RetentionRule with
.EXAMPLE
    $rule = New-RetentionRuleObject @{DeleteCached=$true; KeepVersionsCount=10}
.OUTPUTS
    A new instance of the RetentionRule object
#>
Function New-RetentionRuleObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object RetentionRule -Property $Properties
}

<#
.SYNOPSIS
    Returns a new ReplicationData object with the optional properties set
.DESCRIPTION
    Returns a new instance of the ReplicationData object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the ReplicationData with
.EXAMPLE
    $rep = New-ReplicationDataObject @{ClientMode='mirror'; ServerMode='readonly'}
.OUTPUTS
    A new instance of the ReplicationData object
#>
Function New-ReplicationDataObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object ReplicationData -Property $Properties
}

<#
.SYNOPSIS
    Returns a new LicenseData object with the optional properties set
.DESCRIPTION
    Returns a new instance of the LicenseData object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the LicenseData with
.EXAMPLE
    $lic = New-LicenseDataObject @{LicenseId='myid'}
.OUTPUTS
    A new instance of the LicenseData object
#>
Function New-LicenseDataObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object LicenseData -Property $Properties
}

<#
.SYNOPSIS
    Fetches a list of all feeds from the ProGet API
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    all feeds, returning them as an array of Feed objects.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.EXAMPLE
    $feeds = Get-Feeds $session
.INPUTS
    The session can be piped in by value
.OUTPUTS
    An array of Feed objects
#>
Function Get-Feeds {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.list -f 'feeds') `
            -Transform { [Feed]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to list feeds: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches a list of all connectors from the ProGet API
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    all connectors, returning them as an array of Connector objects.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.EXAMPLE
    $conns = Get-Connectors $session
.INPUTS
    The session can be piped in by value
.OUTPUTS
    An array of Connector objects
#>
Function Get-Connectors {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.list -f 'connectors') `
            -Transform { [Connector]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to list connectors: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches a list of all licenses from the ProGet API
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    all licenses, returning them as an array of LicenseData objects.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.EXAMPLE
    $lics = Get-Licenses $session
.INPUTS
    The session can be piped in by value
.OUTPUTS
    An array of LicenseData objects
#>
Function Get-Licenses {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.list -f 'licenses') `
            -Transform { [LicenseData]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to list licenses $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches a feed with the given name
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    the given feed, returning it as a Feed object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Name
    The name of the feed to get
.EXAMPLE
    $feed = Get-Feed $session chocolatey-feed
.INPUTS
    The session can be piped in by value
.OUTPUTS
    A Feed object
#>
Function Get-Feed {
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
        [string] $Name
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.get -f 'feeds', $Name) `
            -Transform { [Feed]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to get feed: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches a connector with the given name
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    the given connector, returning it as a Connector object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Name
    The name of the connector to get
.EXAMPLE
    $conn = Get-Connector $session chocolatey-connector
.INPUTS
    The session can be piped in by value
.OUTPUTS
    A Connector object
#>
Function Get-Connector {
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
        [string] $Name
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.get -f 'connectors', $Name) `
            -Transform { [Connector]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to get connector: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches a license with the given ID
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and fetch
    the given license, returning it as a LicenseData object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER LicenseID
    The ID of the license to get
.EXAMPLE
    $lic = Get-License $session MIT-CMU
.INPUTS
    The session can be piped in by value
.OUTPUTS
    A LicenseData object
#>
Function Get-License {
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
        [string] $LicenseID
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($FEED_ENDPOINTS.get -f 'licenses', $LicenseID) `
            -Transform { [LicenseData]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to get license: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Creates a new feed using the given Feed object
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    create a new feed using the properties passed in the given Feed object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Feed
    The Feed object to create the new feed with
.EXAMPLE
    $feed = New-FeedObject @{Name='chocolatey-feed'; FeedType='chocolatey'}
    New-Feed $session $feed
.INPUTS
    The session and feed can be piped in by value
.OUTPUTS
    The newly created Feed object
#>
Function New-Feed {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [Feed] $Feed
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.create -f 'feeds') `
            -Method POST `
            -Data $Feed `
            -Transform { [Feed]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to create new feed: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Creates a new connector using the given Connector object
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    create a new connector using the properties passed in the given Connector object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Connector
    The Connector object to create the new connector with
.EXAMPLE
    $conn = New-ConnectorObject @{Name='chocolatey-connector'; FeedType='chocolatey'}
    New-Connector $session $conn
.INPUTS
    The session and connector can be piped in by value
.OUTPUTS
    The newly created Connector object
#>
Function New-Connector {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [Connector] $Connector
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.create -f 'connectors') `
            -Method POST `
            -Data $Connector `
            -Transform { [Connector]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to create new connector: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Creates a new license using the given License object
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    create a new license using the properties passed in the given LicenseData 
    object.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER LicenseData
    The LicenseData object to create the new license with
.EXAMPLE
    $lic = New-LicenseDataObject @{LicenseID='my-license'; Title="My Licnse"; Urls=@('https://mysite.com/license.html')}
    New-License $session $lic
.INPUTS
    The session and license can be piped in by value
.OUTPUTS
    The newly created LicenseData object
#>
Function New-License {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [LicenseData] $LicenseData
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.create -f 'licenses') `
            -Method POST `
            -Data $LicenseData `
            -Transform { [LicenseData]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to create new license: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Updates an existing feed using the given Feed object
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    update a feed using the given Feed object. Note that the Name property of
    the Feed object is what determines which feed is updated in the backend.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Feed
    The Feed object to use for updating
.EXAMPLE
    $feed = Get-Feed $session chocolatey-feed
    $feed.Name = 'chocolatey-feed-2'
    Set-Feed $session $feed
.INPUTS
    The session and feed can be piped in by value
.OUTPUTS
    The updated Feed object
#>
Function Set-Feed {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [Feed] $Feed
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.update -f 'feeds', $Feed.Name) `
            -Method POST `
            -Data $Feed `
            -Transform { [Feed]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to update feed: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Updates an existing license using the given LicenseData object
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    update a license using the given LicenseData object. Note that the LicenseID
    property of the LicenseData object is what determines which license is 
    updated in the backend.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER LicenseData
    The LicenseData object to use for updating
.EXAMPLE
    $lic = Get-License $session my-license
    $lic.Allowed = $true
    Set-License $session $lic
.INPUTS
    The session and license can be piped in by value
.OUTPUTS
    The updated LicenseData object
#>
Function Set-License {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 1
        )]
        [ProGetSession] $Session,
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 2
        )]
        [LicenseData] $LicenseData
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.update -f 'licenses', $LicenseData.LicenseID) `
            -Method POST `
            -Data $LicenseData `
            -Transform { [LicenseData]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to update license: $($_.ErrorDetails.Message)"
        return
    }
}


<#
.SYNOPSIS
    Removes the given feed
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    removes the feed with the given feed name.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Name
    The name of the feed to remove
.EXAMPLE
    Remove-Feed $session chocolatey-feed
.INPUTS
    The session can be piped in by value
.OUTPUTS
    True if successful, otherwise false
#>
Function Remove-Feed {
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
        [string] $Name
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.delete -f 'feeds', $Name) `
            -Method POST
    }
    catch {
        Write-Error "Unable to delete feed: $($_.ErrorDetails.Message)"
        return $false
    }

    return $true
}

<#
.SYNOPSIS
    Removes the given connector
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    removes the connector with the given connector name.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER Name
    The name of the connector to remove
.EXAMPLE
    Remove-Connector $session chocolatey-connector
.INPUTS
    The session can be piped in by value
.OUTPUTS
    True if successful, otherwise false
#>
Function Remove-Connector {
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
        [string] $Name
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.delete -f 'connectors', $Name) `
            -Method POST
    }
    catch {
        Write-Error "Unable to delete connector: $($_.ErrorDetails.Message)"
        return $false
    }

    return $true
}

<#
.SYNOPSIS
    Removes the given license
.DESCRIPTION
    Uses the given ProGet session to connect to the feeds API endpoint and
    removes the license with the given license ID.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER LicenseID
    The ID of the license to remove
.EXAMPLE
    Remove-License $session my-license
.INPUTS
    The session can be piped in by value
.OUTPUTS
    True if successful, otherwise false
#>
Function Remove-License {
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
        [string] $LicenseID
    )

    try {
        Invoke-ProGetApi `
            -Session $Session `
            -EndPoint ($FEED_ENDPOINTS.delete -f 'licenses', $LicenseID) `
            -Method POST
    }
    catch {
        Write-Error "Unable to delete license: $($_.ErrorDetails.Message)"
        return $false
    }

    return $true
}