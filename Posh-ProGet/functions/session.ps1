Function New-Session {
    param(
        [string] $Address,
        [string] $ApiToken
    )

    [ProGetSession]::new($Address, $ApiToken)
}