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
        return JsonToClass $JsonObject ([Asset]::new())
    }
}