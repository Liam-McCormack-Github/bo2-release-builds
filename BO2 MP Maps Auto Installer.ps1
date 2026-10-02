# Installs the BO2 multiplayer maps for zombies, and the menu mod, into Plutonium.
#
# Everything comes from GitHub releases. For each file it takes the NEWEST published release
# that has a file of that name - drafts are ignored, pre-releases are not - so a future release
# only has to attach zm_<map>.zip / mod_to_launch_mp_maps_in_zombies.zip and this picks it up.
# Maps and mod can ship in the same release or separate ones.
#
# Re-running it compares version.json with that release's usermap_versions.json.
# Older releases/installations use the original release-asset stamp check.
# Matching versions are skipped, and newer local builds are kept.
#
# EXPRESS installs everything into %LOCALAPPDATA%\Plutonium\storage\t6 without asking, and only
# asks for a folder when that one is missing. CUSTOM always asks for the folder and what to install.

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Repo = "Liam-McCormack-Github/bo2-release-builds"
$ModAsset = "mod_to_launch_mp_maps_in_zombies.zip"
$VersionsAsset = "usermap_versions.json"

$Maps = [ordered]@{
	zm_la = "Aftermath"; zm_dockside = "Cargo"; zm_carrier = "Carrier"; zm_castaway = "Cove"
	zm_bridge = "Detour"; zm_dig = "Dig"; zm_downhill = "Downhill"; zm_drone = "Drone"
	zm_concert = "Encore"; zm_express = "Express"; zm_frostbite = "Frost"; zm_skate = "Grind"
	zm_hijacked = "Hijacked"; zm_hydro = "Hydro"; zm_magma = "Magma"; zm_meltdown = "Meltdown"
	zm_mirage = "Mirage"; zm_nuketown_2020 = "Nuketown 2025"; zm_overflow = "Overflow"
	zm_nightclub = "Plaza"; zm_pod = "Pod"; zm_raid = "Raid"; zm_paintball = "Rush"
	zm_slums = "Slums"; zm_village = "Standoff"; zm_studio = "Studio"; zm_takeoff = "Takeoff"
	zm_turbine = "Turbine"; zm_uplink = "Uplink"; zm_vertigo = "Vertigo"; zm_socotra = "Yemen"
}

function Say( $text, $color = "Gray" ) { Write-Host $text -ForegroundColor $color }

function Fail( $text )
{
	Say ""
	Say "  $text" Red
	Say ""
	exit 1
}

function Size( $bytes )
{
	if ( $bytes -lt 1GB ) { return "{0:N0} MB" -f ( $bytes / 1MB ) }
	return "{0:N1} GB" -f ( $bytes / 1GB )
}

Say ""
Say "  ================================================" Cyan
Say "    BO2 Multiplayer Maps in Zombies - Auto Installer" Cyan
Say "  ================================================" Cyan
Say ""

if ( Get-Process -Name "plutonium*" -ErrorAction SilentlyContinue )
{
	Fail "Plutonium is running. Close the game and the launcher, then run this again."
}

# --- Express or custom ------------------------------------------------------------------------

Say "  How do you want to install?" White
Say ""
Say "    1   EXPRESS - everything, into Plutonium's usual folder (recommended)" Green
Say "    2   CUSTOM  - choose the folder and which maps"
Say ""
$Mode = ( Read-Host "  Type a number and press Enter" ).Trim()
if ( $Mode -ne "1" -and $Mode -ne "2" )
{
	Say "  Nothing installed."
	exit 0
}

$DefaultT6 = Join-Path $env:LOCALAPPDATA "Plutonium\storage\t6"

# A folder the user typed: Plutonium's own folder, its storage\t6, or anywhere they insist on.
function ResolveT6( $typed )
{
	$typed = $typed.Trim().Trim( '"' )
	if ( $typed -eq "" ) { return $null }
	$inner = Join-Path $typed "storage\t6"
	if ( Test-Path $inner ) { return $inner }
	return $typed
}

function AskT6
{
	Say ""
	Say "  Where is your Plutonium t6 folder?" White
	Say "  Usually: $DefaultT6" DarkGray
	Say "  (Press Enter to use that, or paste another folder.)" DarkGray
	$typed = Read-Host "  Folder"
	if ( $typed.Trim() -eq "" ) { $typed = $DefaultT6 }
	$dir = ResolveT6 $typed
	if ( -not ( Test-Path $dir ) )
	{
		$ok = Read-Host "  '$dir' does not exist. Create it? (y/n)"
		if ( $ok.Trim().ToLower() -ne "y" ) { Fail "No install folder - nothing installed." }
	}
	return $dir
}

if ( $Mode -eq "1" -and ( Test-Path $DefaultT6 ) )
{
	$T6 = $DefaultT6
}
else
{
	if ( $Mode -eq "1" )
	{
		Say ""
		Say "  Could not find Plutonium at $DefaultT6." Yellow
		Say "  If Plutonium is not installed yet: install it from plutonium.pw, run Black Ops II once, then run this again." Yellow
	}
	$T6 = AskT6
}

Say ""
Say "  Installing into: $T6" Cyan
Say ""

$UsermapsDir = Join-Path $T6 "usermaps"
$ModsDir = Join-Path $T6 "mods"
New-Item -ItemType Directory -Force $UsermapsDir, $ModsDir | Out-Null

$ManifestPath = Join-Path $T6 "mp_maps_installer.json"
$Installed = @{}
if ( Test-Path $ManifestPath )
{
	try
	{
		( Get-Content $ManifestPath -Raw | ConvertFrom-Json ).PSObject.Properties | ForEach-Object { $Installed[$_.Name] = $_.Value }
	}
	catch { }
}

# --- Newest release per file ------------------------------------------------------------------

Say "  Checking GitHub for the latest release..."
try
{
	$releases = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases?per_page=100" -Headers @{ "User-Agent" = "bo2-mp-maps-installer" }
}
catch
{
	Fail "Could not reach GitHub: $( $_.Exception.Message )"
}

$Assets = @{}
foreach ( $release in ( $releases | Where-Object { -not $_.draft } | Sort-Object { [datetime]$_.published_at } -Descending ) )
{
    $versions = $null
    $manifestAsset = $release.assets | Where-Object { $_.name -eq $VersionsAsset -and $_.state -eq "uploaded" } | Select-Object -First 1
    $hasNewMaps = @( $release.assets | Where-Object { $Maps.Contains( [IO.Path]::GetFileNameWithoutExtension( $_.name ) ) -and -not $Assets.ContainsKey( $_.name ) } ).Count -gt 0
    if ( $manifestAsset -and $hasNewMaps )
    {
        try
        {
            $candidate = Invoke-RestMethod $manifestAsset.browser_download_url -Headers @{ "User-Agent" = "bo2-mp-maps-installer" }
            if ( $candidate.schema_version -eq 1 ) { $versions = $candidate.maps }
        }
        catch { Say "  Version manifest unavailable for $( $release.tag_name ); using release asset checks." Yellow }
    }
	foreach ( $asset in $release.assets )
	{
		# An asset still uploading is listed too, in a state other than "uploaded".
		if ( $asset.state -eq "uploaded" -and -not $Assets.ContainsKey( $asset.name ) )
		{
            $version = $null
            $mapName = [IO.Path]::GetFileNameWithoutExtension( $asset.name )
            if ( $versions -and $Maps.Contains( $mapName ) )
            {
                $record = $versions.PSObject.Properties[$mapName]
                if ( $record )
                {
                    $candidate = $record.Value
                    if ( $candidate.map -eq $mapName -and $candidate.build_id -and $candidate.timestamp -gt 0 -and
                         ( -not $candidate.asset_id -or $candidate.asset_id -eq $asset.id ) ) { $version = $candidate }
                }
            }
			$Assets[$asset.name] = [pscustomobject]@{
				Name = $asset.name
				Url = $asset.browser_download_url
				Size = [int64]$asset.size
				Stamp = "$( $asset.id ):$( $asset.updated_at )"
				Tag = $release.tag_name
                Version = $version
			}
		}
	}
}

$ModInfo = $Assets[$ModAsset]
$MapKeys = @( $Maps.Keys | Where-Object { $Assets.ContainsKey( "$_.zip" ) } )
if ( $MapKeys.Count -eq 0 -and $null -eq $ModInfo )
{
	Fail "No maps or mod found in the releases of $Repo."
}

function MapStatus( $name, $asset )
{
    $folder = Join-Path $UsermapsDir $name
    if ( -not ( Test-Path -LiteralPath ( Join-Path $folder "$name.ff" ) ) -or
         -not ( Test-Path -LiteralPath ( Join-Path $folder "$name.iwd" ) ) ) { return "missing" }
    if ( $asset.Version )
    {
        $localPath = Join-Path $folder "version.json"
        if ( Test-Path -LiteralPath $localPath )
        {
            try
            {
                $local = Get-Content -LiteralPath $localPath -Raw | ConvertFrom-Json
                if ( $local.schema_version -eq 1 -and $local.map -eq $name -and $local.build_id -and $local.timestamp -gt 0 )
                {
                    if ( $local.build_id -eq $asset.Version.build_id -and $local.timestamp -eq $asset.Version.timestamp ) { return "current" }
                    if ( [int64]$local.timestamp -gt [int64]$asset.Version.timestamp ) { return "newer" }
                    return "outdated"
                }
            }
            catch { }
        }
    }
    # Releases/installs predating version.json still use the original asset stamp.
    if ( $Installed[$name] -eq $asset.Stamp ) { return "current" }
    return "unknown"
}

function IsCurrent( $name, $asset )
{
    if ( $Maps.Contains( $name ) ) { return ( MapStatus $name $asset ) -in @( "current", "newer" ) }
    return ( Test-Path -LiteralPath ( Join-Path $ModsDir $name ) ) -and $Installed[$name] -eq $asset.Stamp
}

# --- Menu -------------------------------------------------------------------------------------

$allSize = ( $MapKeys | ForEach-Object { $Assets["$_.zip"].Size } | Measure-Object -Sum ).Sum
if ( $ModInfo ) { $allSize += $ModInfo.Size }

$choice = "1"
if ( $Mode -eq "1" )
{
	Say "  Express: all $( $MapKeys.Count ) maps + the menu mod, about $( Size $allSize ) to download." Green
}
else
{
	Say ""
	Say "  What do you want to install?" White
	Say ""
	Say "    1   EVERYTHING - all $( $MapKeys.Count ) maps + the menu mod   (about $( Size $allSize ) download)" Green
	Say "    2   Let me pick the maps (the menu mod comes with them)"
	Say "    3   Only the menu mod"
	Say "    4   Quit"
	Say ""
	$choice = ( Read-Host "  Type a number and press Enter" ).Trim()
}

$picked = @()
$withMod = $true
switch ( $choice )
{
	"1" { $picked = $MapKeys }
	"2"
	{
		Say ""
		for ( $i = 0; $i -lt $MapKeys.Count; $i++ )
		{
			$key = $MapKeys[$i]
			$line = "    {0,2}   {1,-15}" -f ( $i + 1 ), $Maps[$key]
			$color = "Gray"
            switch ( MapStatus $key $Assets["$key.zip"] )
            {
                "current" { $line += "  (up to date)"; $color = "DarkGray" }
                "newer" { $line += "  (newer local build)"; $color = "Cyan" }
                "outdated" { $line += "  (update available)"; $color = "Yellow" }
                "unknown" { $line += "  (installed; version unknown)"; $color = "Yellow" }
            }
			Say $line $color
		}
		Say ""
		Say "  Type the numbers you want, separated by spaces (example: 1 4 13)"
		$typed = Read-Host "  Maps"
		foreach ( $part in ( $typed -split "[\s,]+" | Where-Object { $_ -ne "" } ) )
		{
			$n = 0
			if ( [int]::TryParse( $part, [ref]$n ) -and $n -ge 1 -and $n -le $MapKeys.Count )
			{
				$picked += $MapKeys[$n - 1]
			}
			else
			{
				Say "  Ignoring '$part' - not a number from the list." Yellow
			}
		}
		$picked = @( $picked | Select-Object -Unique )
		if ( $picked.Count -eq 0 ) { Fail "No maps picked." }
	}
	"3" { }
	default { Say "  Nothing installed."; exit 0 }
}

# --- Work list --------------------------------------------------------------------------------

$jobs = @()
if ( $withMod -and $ModInfo )
{
	$jobs += [pscustomobject]@{ Key = "mod_to_launch_mp_maps_in_zombies"; Label = "Menu mod"; Asset = $ModInfo; Dest = $ModsDir }
}
foreach ( $key in $picked )
{
	$jobs += [pscustomobject]@{ Key = $key; Label = $Maps[$key]; Asset = $Assets["$key.zip"]; Dest = $UsermapsDir }
}

$todo = @( $jobs | Where-Object { -not ( IsCurrent $_.Key $_.Asset ) } )
foreach ( $job in $todo )
{
    if ( $Maps.Contains( $job.Key ) -and ( MapStatus $job.Key $job.Asset ) -eq "outdated" )
    {
        Say "  $( $job.Label ): update available." Yellow
    }
}
foreach ( $job in ( $jobs | Where-Object { IsCurrent $_.Key $_.Asset } ) )
{
    if ( $Maps.Contains( $job.Key ) -and ( MapStatus $job.Key $job.Asset ) -eq "newer" )
    {
        Say "  $( $job.Label ) has a newer local build; keeping it." Cyan
    }
    else { Say "  $( $job.Label ) is already up to date." DarkGray }
}
if ( $todo.Count -eq 0 )
{
	Say ""
	Say "  Everything you picked is already installed and up to date." Green
	exit 0
}

# Each zip is deleted once it is unpacked, so the peak is everything unpacked plus the biggest zip.
$need = ( $todo | ForEach-Object { $_.Asset.Size } | Measure-Object -Sum ).Sum * 1.1 + ( $todo | ForEach-Object { $_.Asset.Size } | Measure-Object -Maximum ).Maximum
$drive = New-Object System.IO.DriveInfo ( [System.IO.Path]::GetPathRoot( $T6 ) )
if ( $drive.AvailableFreeSpace -lt $need )
{
	Fail "Not enough disk space on $( $drive.Name ): need about $( Size $need ), have $( Size $drive.AvailableFreeSpace )."
}

# --- Download and unpack ----------------------------------------------------------------------

Add-Type -AssemblyName System.IO.Compression.FileSystem
$TempDir = Join-Path $env:TEMP "bo2-mp-maps-installer"
New-Item -ItemType Directory -Force $TempDir | Out-Null
$curl = Get-Command "curl.exe" -ErrorAction SilentlyContinue

$n = 0
$failed = @()
foreach ( $job in $todo )
{
	$n++
	$zip = Join-Path $TempDir $job.Asset.Name
	$zipStamp = "$zip.stamp"

	# A half-done zip is only resumed if it is the same release asset. Every release names its zips
	# alike, so resuming across releases splices an old file onto a new one - right size, corrupt.
	if ( ( Test-Path $zip ) -and ( -not ( Test-Path $zipStamp ) -or ( Get-Content $zipStamp -Raw ).Trim() -ne $job.Asset.Stamp ) )
	{
		Remove-Item $zip -Force
	}
	Set-Content $zipStamp $job.Asset.Stamp

	Say ""
	Say "  [$n/$( $todo.Count )] $( $job.Label )  ($( Size $job.Asset.Size ), release $( $job.Asset.Tag ))" Cyan

	try
	{
		if ( $curl )
		{
			# -C - resumes a download a previous run left half done.
			& $curl.Source -L --fail --retry 3 --progress-bar -C - -o $zip $job.Asset.Url
			if ( $LASTEXITCODE -ne 0 ) { throw "download failed (curl exit $LASTEXITCODE)" }
		}
		else
		{
			Say "  Downloading... (no progress bar, this can take a while)"
			Invoke-WebRequest $job.Asset.Url -OutFile $zip -UseBasicParsing
		}

		if ( ( Get-Item $zip ).Length -ne $job.Asset.Size )
		{
			Remove-Item $zip -Force
			throw "download was incomplete"
		}

		Say "  Unpacking..."
		$target = Join-Path $job.Dest $job.Key
		if ( Test-Path $target ) { Remove-Item $target -Recurse -Force }
		[System.IO.Compression.ZipFile]::ExtractToDirectory( $zip, $job.Dest )
		Remove-Item $zip, $zipStamp -Force

		$Installed[$job.Key] = $job.Asset.Stamp
		$Installed | ConvertTo-Json | Set-Content $ManifestPath -Encoding UTF8
		Say "  Done." Green
	}
	catch
	{
		Say "  FAILED: $( $_.Exception.Message )" Red
		$failed += $job.Label

		# A full-size zip that failed is bad, and a re-run would resume onto it and fail again.
		# Only a short one - a download cut off part way - is worth keeping to resume.
		if ( ( Test-Path $zip ) -and ( Get-Item $zip ).Length -ge $job.Asset.Size )
		{
			Remove-Item $zip, $zipStamp -Force -ErrorAction SilentlyContinue
		}
	}
}

# --- How to play ------------------------------------------------------------------------------

Say ""
Say "  ================================================" Cyan
if ( $failed.Count -gt 0 )
{
	Say "  These did not install: $( $failed -join ', ' )" Red
	Say "  Run this again to retry - finished ones are skipped." Yellow
}
else
{
	Say "  All done!" Green
}
Say ""
Say "  HOW TO PLAY" White
Say "    1. Start Plutonium and launch Black Ops II ZOMBIES."
Say "    2. Main menu > MODS > load 'MP Maps in Zombies'."
Say "    3. Use the new QUICK LAUNCH button > USERMAPS and pick a map."
Say ""
Say "  No DLC needed - every map carries its own textures." Green
Say ""
