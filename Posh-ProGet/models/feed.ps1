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
        $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty' | ForEach-Object {
            $value = $JsonObject.$($_.Name)

            if ($_.Name -eq 'retentionRules') {
                $feed.$($_.Name) = [RetentionRule]::FromJson($value)
                continue
            }

            if ($_.Name -eq 'replication') {
                $feed.$($_.Name) = [ReplicationData]::FromJson($value)
                continue
            }

            if ($value) {
                $feed.$($_.Name) = $value
            }
        }
        return $feed
    }
}

class Connector {
    [string] $Name
    [string] $FeedType
    [string] $Url
    [string] $Username
    [string] $Password
    [int] $Timeout
    [string[]] $Filters
    [bool] $MetadataCacheEnabled
    [int] $MetadataCacheMinutes
    [int] $MetaDataCacheCount
}

class RetentionRule {
    [bool] $DeletePrereleaseVersions
    [bool] $DeleteCached
    $KeepVersionsCount
    $KeepUsedWithinDays
    $TriggerDownloadCount
    [string[]] $KeepPackageIds
    [string[]] $DeletePackageIds
    [string[]] $KeepVersions
    [string[]] $DeleteVersions
    $SizeTriggerKb
    [bool] $SizeExclusive

    static [RetentionRule] FromJson([object] $JsonObject) {
        $rule = [RetentionRule]::new()
        $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty' | ForEach-Object {
            $rule.$($_.Name) = $JsonObject.$($_.Name)
        }

        return $rule
    }
}

class ReplicationData {
    [string] $ClientMode
    [string] $ServerMode
    [string] $ClientToken
    [string] $ServerToken
    [string] $SourceUrl

    static [ReplicationData] FromJson([object] $JsonObject) {
        $replication = [ReplicationData]::new()
        $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty' | ForEach-Object {
            $replication.$($_.Name) = $JsonObject.$($_.Name)
        }

        return $replication
    }
}

class LicenseData {
    [string] $LicenseID
    [string] $Title
    [string[]] $Urls
    [bool] $Allowed
    [string[]] $AllowedFeeds
    [string[]] $BlockedFeeds
}