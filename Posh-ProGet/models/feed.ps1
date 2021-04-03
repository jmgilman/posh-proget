class Feed {
    [string] $Name
    [string[]] $AlternateNames
    [string] $FeedType
    [string] $Description
    [bool] $Active
    [bool] $CacheConnectors
    [string] $DropPath
    [string] $PackagePath
    [string] $PackageStore
    [bool] $AllowUnknownLicenses
    [string[]] $AllowedLicenses
    [string[]] $BlockedLicenses
    [bool] $SymbolServerEnabled
    [bool] $StripSymbols
    [bool] $StripSource
    [string[]] $Connectors
    [string[]] $VulnerabilitySources
    [RetentionRule[]] $RetentionRules
    [System.Collections.Generic.Dictionary[string, string]] $PackageFilters
    [System.Collections.Generic.Dictionary[string, string]] $PackageAccessRules
    [ReplicationData] $Replication
    [object] $Variables

    static [Feed] FromJson([object] $JsonObject) {
        $feed = [Feed]::new()

        if (!$JsonObject) {
            return $null
        }

        $properties = $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty'
        foreach ($property in $properties) {
            $value = $JsonObject.$($property.Name)

            if ($property.Name -eq 'retentionRules') {
                $feed.$($property.Name) = [RetentionRule]::FromJson($value)
                continue
            }

            if ($property.Name -eq 'replication') {
                $feed.$($property.Name) = [ReplicationData]::FromJson($value)
                continue
            }

            if ($value) {
                $feed.$($property.Name) = $value
            }
        }
        return $feed
    }
}

class Connector {
    [string] $Name
    [string] $FeedType
    [string] $Url = ''
    [string] $Username
    [string] $Password
    [int] $Timeout
    [string[]] $Filters
    [bool] $MetadataCacheEnabled
    [int] $MetadataCacheMinutes
    [int] $MetaDataCacheCount

    static [Connector] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([Connector]::new())
    }
}

class ConnectorHealth {
    [string] $Name
    [string] $Id
    [string] $Url
    [string] $State
    [string] $ErrorMessage
    [Nullable[DateTime]] $LastChecked = $null

    static [ConnectorHealth] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([ConnectorHealth]::new())
    }
}

class RetentionRule {
    [bool] $DeletePrereleaseVersions
    [bool] $DeleteCached
    [Nullable[int]] $KeepVersionsCount = $null
    [Nullable[int]] $KeepUsedWithinDays = $null
    [Nullable[int]] $TriggerDownloadCount = $null
    [string[]] $KeepPackageIds
    [string[]] $DeletePackageIds
    [string[]] $KeepVersions
    [string[]] $DeleteVersions
    [Nullable[int]] $SizeTriggerKb = $null
    [bool] $SizeExclusive

    static [RetentionRule] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([RetentionRule]::new())
    }
}

class ReplicationData {
    [string] $ClientMode
    [string] $ServerMode
    [string] $ClientToken
    [string] $ServerToken
    [string] $SourceUrl

    static [ReplicationData] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([ReplicationData]::new())
    }
}

class LicenseData {
    [string] $LicenseID
    [string] $Title = ''
    [string[]] $Urls
    [bool] $Allowed
    [string[]] $AllowedFeeds = @()
    [string[]] $BlockedFeeds = @()

    static [LicenseData] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([LicenseData]::new())
    }
}