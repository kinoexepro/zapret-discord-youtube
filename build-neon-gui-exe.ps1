# Builds NeonZapret.exe and a ready-to-send zip archive on Windows 11.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $Root 'NeonZapret.ps1'
$exe = Join-Path $Root 'NeonZapret.exe'
$zip = Join-Path $Root 'NeonZapret-Windows11-2026.zip'
if (-not (Test-Path $source)) { throw 'NeonZapret.ps1 not found' }
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes((Get-Content -LiteralPath $source -Raw)))
$cs = @"
using System;
using System.Diagnostics;
class NeonZapret {
  [STAThread]
  static void Main() {
    var p = new ProcessStartInfo("powershell.exe", "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded");
    p.UseShellExecute = false;
    p.CreateNoWindow = true;
    Process.Start(p);
  }
}
"@
$tmp = Join-Path $env:TEMP 'NeonZapret.cs'
Set-Content -LiteralPath $tmp -Value $cs -Encoding UTF8
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) { $csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
& $csc /nologo /target:winexe /out:$exe $tmp
if (Test-Path $zip) { Remove-Item $zip -Force }
$items = @('NeonZapret.exe','NeonZapret.ps1','Start Neon Zapret GUI.bat','service.bat','general*.bat','bin','lists','utils','README.md','LICENSE.txt')
Compress-Archive -Path ($items | ForEach-Object { Join-Path $Root $_ }) -DestinationPath $zip -Force
Write-Host "Built $exe"
Write-Host "Built $zip"
