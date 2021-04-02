class Asset {
    [string] $Name
    [string] $Parent
    [string] $Type
    [string] $Content
    [string] $Created
    [string] $Modified
    [int] $Size
    [string] $md5
    [string] $Sha1
    [string] $Sha256
    [string] $Sha512

    static [Asset] FromJson([object] $JsonObject) {
        $asset = [Asset]::new()

        if (!$JsonObject) {
            return $null
        }

        $JsonObject | Get-Member | Where-Object MemberType -EQ 'NoteProperty' | ForEach-Object {
            $asset.$($_.Name) = $JsonObject.$($_.Name)
        }

        return $asset
    }
}