# Posh-Proget

> A Powershell module for interacting with a [ProGet](https://inedo.com/proget) API server.

## Installation

```powershell
$> Install-Module Posh-ProGet
```

## Usage

Create a session to interact with the API:

```powershell
$> $session = Get-ProGetSession 'http://my.proget.com:8624' 'myapikey'
```

Interact with the various functions:

```powershell
$> $feed = Get-ProGetFeed $session 'my-feed'
$> $feed.Active = $false
$> Set-ProGetFeed $session $feed
```

## Features

This module currently supports interacting with the following API objects:

* Feeds
* Connectors
* Licenses
* Assets (including folders)
* Server health

## Meta

Joshua Gilman - joshuagilman@gmail.com

Distributed under the MIT license. See LICENSE for more information.

https://github.com/jmgilman