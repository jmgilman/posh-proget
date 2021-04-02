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
        $health = [ServerHealth]::new()

        if (!$JsonObject) {
            return $health
        }

        $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty' | ForEach-Object {
            $health.$($_.Name) = $JsonObject.$($_.Name)
        }

        return $health
    }
}