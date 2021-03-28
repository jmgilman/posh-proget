class ProGetSession {
    [string] $Address
    [string] $ApiToken

    ProGetSession([string] $Address, [string] $ApiToken) {
        $this.Address = $Address
        $this.ApiToken = $ApiToken
    }
}