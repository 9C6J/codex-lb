# Use only before the first successful deployment: never rotate a live DB key.
$ErrorActionPreference = 'Stop'
$path = Join-Path $PSScriptRoot 'vars.yml'
$lines = Get-Content -LiteralPath $path
$keyLine = @($lines | Where-Object { $_ -match '^encryption_key_b64:' })
if ($keyLine.Count -ne 1) { throw 'Expected one encryption key field' }
$bytes = New-Object byte[] 32
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
$fernet = [Convert]::ToBase64String($bytes).Replace('+','-').Replace('/','_')
$wrapped = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($fernet))
$decoded = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($wrapped))
if ([Convert]::FromBase64String($decoded.Replace('-','+').Replace('_','/')).Length -ne 32) {
    throw 'Invalid key encoding'
}
$lines = $lines -replace '^encryption_key_b64:.*$', ('encryption_key_b64: ' + $wrapped)
[IO.File]::WriteAllLines($path, $lines, [Text.UTF8Encoding]::new($false))
Write-Output 'Initial key encoding repaired without displaying the key.'
