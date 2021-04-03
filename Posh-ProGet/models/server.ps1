class ServerHealth {
    [string] $ApplicationName
    [string] $ReleaseNumber
    [string] $VersionNumber
    [string[]] $ExtensionsInstalled
    [string] $ServiceStatus
    [string] $ServiceStatusDetail
    [string] $LicenseStatus
    [string] $LicenseStatusDetail
    [string] $ReplicationHealth

    static [ServerHealth] FromJson([object] $JsonObject) {
        return JsonToClass $JsonObject ([ServerHealth]::new())
    }
}