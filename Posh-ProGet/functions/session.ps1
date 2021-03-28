Function New-ProGetSession {
    param(
        [string] $Address,
        [string] $ApiToken
    )

    [ProGetSession]::new($Address, $ApiToken)
}