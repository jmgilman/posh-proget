$ASSET_ENDPOINTS = @{
    list      = '/endpoints/{0}/dir/{1}'
    get       = '/endpoints/{0}/content/{1}'
    create    = '/endpoints/{0}/content/{1}'
    update    = '/endpoints/{0}/content/{1}'
    delete    = '/endpoints/{0}/delete/{1}'
    directory = '/endpoints/{0}/dir/{1}'
    export    = '/endpoints/{0}/export/{1}'
    import    = '/endpoints/{0}/import/{1}'
}

<#
.SYNOPSIS
    Returns a new Asset object with the optional properties set
.DESCRIPTION
    Returns a new instance of the Asset object. Additional properties in the form
    of a dictionary can be passed to initialize the object with the given
    property values.
.PARAMETER Properties
    A dictionary of property values to initialize the Asset with
.EXAMPLE
    $asset = New-AssetObject @{Name='my-asset'; Type='text/json'}
.OUTPUTS
    A new instance of the Asset object
#>
Function New-AssetObject {
    param(
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        $Properties
    )

    New-Object Asset -Property $Properties
}

<#
.SYNOPSIS
    Fetches a list of all assets contained within the given asset feed at the
    given ath
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    fetch all assets contained within the given feed name and located at the
    given relative path. Note that the relative path should omit the leading
    slash (i.e. 'sub/dir' instead of '/sub/dir').
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to fetch against
.PARAMETER Path
    The relative path in the feed to fetch against (defaults to root folder)
.PARAMETER Recursive
    Whether to recursively search the path or not
.EXAMPLE
    $assets = Get-Assets $session asset-feed sub/dir -Recursive
.INPUTS
    The session can be piped in by value
.OUTPUTS
    An array of Asset objects
#>
Function Get-Assets {
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
        [string] $FeedName,
        [Parameter(
            Position = 3
        )]
        [string] $Path = '',
        [switch] $Recursive = $false
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint (($ASSET_ENDPOINTS.list -f $FeedName, $Path) + "?recursive=$Recursive") `
            -Transform { [Asset]::FromJson($_) }
    }
    catch {
        Write-Error "Unable to list assets: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Fetches the contents of an asset from the given feed at the given path
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    fetch the asset contents at the given path from the given asset feed.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to fetch against
.PARAMETER Path
    The relative path in the feed to the asset
.EXAMPLE
    $asset_contents = Get-Asset $session asset-feed path/to/asset.zip
.INPUTS
    The session can be piped in by value
.OUTPUTS
    The contents of the requested asset
#>
Function Get-Asset {
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
        [string] $FeedName,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Path
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($ASSET_ENDPOINTS.get -f $FeedName, $Path)
    }
    catch {
        Write-Error "Unable to get asset: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Creates a new asset in the given asset feed
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    creates a new asset in the given feed at the given path
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to place the asset in
.PARAMETER Path
    The relative path in the feed to the new asset
.PARAMETER ContentType
    The type of the content in the new asset (i.e. 'text/plain')
.PARAMETER Content
    The content of the new asset
.PARAMETER InFile
    The local path to the asset file to upload. This overrides anything set in
    the Content parameter.
.EXAMPLE
    New-Asset -Session $session `
              -FeedName asset-feed `
              -Path README.md `
              -ContentType 'text/plain' `
              -InFile ./README.md
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function New-Asset {
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
        [string] $FeedName,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Path,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $ContentType,
        [object] $Content,
        [string] $InFile
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($ASSET_ENDPOINTS.create -f $FeedName, $Path) `
            -Method PUT `
            -ContentType $ContentType `
            -Data $Content `
            -InFile $InFile
    }
    catch {
        Write-Error "Unable to create new asset: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Creates a new asset directory in the given asset feed
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    creates a new asset directory in the given feed with the given path
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to create the directory in
.PARAMETER Path
    The relative path in the feed to the new folder
.EXAMPLE
    New-AssetDirectory -Session $session `
                       -FeedName asset-feed `
                       -Path my/subdir
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function New-AssetDirectory {
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
        [string] $FeedName,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Path
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($ASSET_ENDPOINTS.directory -f $FeedName, $Path) `
            -Method POST
    }
    catch {
        Write-Error "Unable to create new asset directory: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Update an asset in the given asset feed
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    update an asset in the given feed at the given path
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to which the asset belongs
.PARAMETER Path
    The relative path in the feed to the asset
.PARAMETER ContentType
    The type of the content in the asset (i.e. 'text/plain')
.PARAMETER Content
    The modified contents of the asset
.PARAMETER InFile
    The local path to the modified asset file to upload. This overrides anything 
    set in the Content parameter.
.EXAMPLE
    Set-Asset -Session $session `
              -FeedName asset-feed `
              -Path README-updated.md `
              -ContentType 'text/plain' `
              -InFile ./README.md
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function Set-Asset {
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
        [string] $FeedName,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Path,
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $ContentType,
        [object] $Content,
        [string] $InFile
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($ASSET_ENDPOINTS.update -f $FeedName, $Path) `
            -Method PATCH `
            -ContentType $ContentType `
            -Data $Content `
            -InFile $InFile
    }
    catch {
        Write-Error "Unable to upate asset: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Removes an asset from the given feed at the given path
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    removes the asset at the given path from the given asset feed.
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed the asset belongs to
.PARAMETER Path
    The relative path in the feed to the asset
.EXAMPLE
    Remove-Asset $session asset-feed path/to/asset.zip
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function Remove-Asset {
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
        [string] $FeedName,
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [string] $Path
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint ($ASSET_ENDPOINTS.delete -f $FeedName, $Path) `
            -Method POST
    }
    catch {
        Write-Error "Unable to remove asset: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Exports the contents of an asset directory into an archive file
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    exports the contents of the given path in the given asset feed as an archive
    file. 
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed for exporting
.PARAMETER Path
    The relative path in the feed to export
.PARAMETER OutFile
    An optional local path to output the archive to
.PARAMETER Format
    The format of the archive file: either zip or tgz
.PARAMETER Recursive
    Whether to export all subdirectories under the path
.EXAMPLE
    Export-AssetDirectory $session asset-feed -OutFile feed.zip -Recursive 
.INPUTS
    The session can be piped in by value
.OUTPUTS
    The raw contents of the archive file if OutFile was not specified
#>
Function Export-AssetDirectory {
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
        [string] $FeedName,
        [Parameter(
            Position = 3
        )]
        [string] $Path,
        [string] $OutFile,
        [ValidateSet('zip', 'tgz')]
        [string] $Format = 'zip',
        [switch] $Recursive = $false
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint (($ASSET_ENDPOINTS.export -f $FeedName, $Path) + "?format=$Format&recursive=$Recursive") `
            -OutFile $OutFile
    }
    catch {
        Write-Error "Unable to export asset directory: $($_.ErrorDetails.Message)"
        return
    }
}

<#
.SYNOPSIS
    Imports an archive file into an asset directory
.DESCRIPTION
    Uses the given ProGet session to connect to the assets API endpoint and 
    imports the contents of an archive file into the given path. 
.PARAMETER Session
    An existing ProGetSession object used to connect to the API
.PARAMETER FeedName
    The name of the asset feed to import the archive to
.PARAMETER Path
    The relative path in the feed where the contents will be imported
.PARAMETER InFile
    The local path to the archive file to import.
.PARAMETER Format
    The format of the archive file: either zip or tgz
.PARAMETER Overwrite
    Whether to overwrite any files or folders already present at the given path
.EXAMPLE
    Import-AssetDirectory -Session $session `
                          -FeedName asset-feed `
                          -Path sub/dir `
                          -InFile ./archive.zip
.INPUTS
    The session can be piped in by value
.OUTPUTS
    None
#>
Function Import-AssetDirectory {
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
        [string] $FeedName,
        [Parameter(
            Position = 3
        )]
        [string] $Path = '',
        [Parameter(
            Mandatory = $true,
            Position = 4
        )]
        [string] $InFile,
        [ValidateSet('zip', 'tgz')]
        [string] $Format = 'zip',
        [switch] $Overwrite = $false
    )
    
    try {
        Invoke-ProGetApi `
            -Session $Session `
            -Endpoint (($ASSET_ENDPOINTS.import -f $FeedName, $Path) + "?format=$Format&overwrite=$Overwrite") `
            -Method POST `
            -InFile $InFile
    }
    catch {
        Write-Error "Unable to import asset directory: $($_.ErrorDetails.Message)"
        return
    }
}