param([switch]$TestOnly)
$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$aiDir=Join-Path $root 'AI'
$server=Get-ChildItem (Join-Path $aiDir 'runtime') -Filter llama-server.exe -Recurse | Select-Object -First 1
if (-not $server) { throw 'Motore AI portatile mancante. Estrai tutto lo ZIP.' }
$weightsDir=Join-Path $env:LOCALAPPDATA 'GENESIS47\AI'
New-Item -ItemType Directory -Path $weightsDir -Force | Out-Null
$model=Join-Path $weightsDir 'qwen2.5-0.5b-instruct-q4_k_m.gguf'
$expected='74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db'
if (!(Test-Path $model) -or (Get-FileHash $model -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
  Write-Host 'Primo avvio AI: download gratuito di 491 MB dal repository ufficiale Qwen.'
  $tmp="$model.download"
  $url='https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/6dd44a1/qwen2.5-0.5b-instruct-q4_k_m.gguf'
  & curl.exe -fL --retry 2 --connect-timeout 20 --max-time 240 $url -o $tmp
  if ($LASTEXITCODE -ne 0) { throw 'Download non riuscito. Il gioco normale rimane disponibile.' }
  if ((Get-FileHash $tmp -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    Remove-Item $tmp -Force
    throw 'Controllo di integrita del modello non superato.'
  }
  Move-Item $tmp $model -Force
}
if (Get-NetTCPConnection -LocalPort 17847 -State Listen -ErrorAction SilentlyContinue) { throw 'Porta AI 17847 occupata. Chiudi la precedente istanza.' }
$log=Join-Path $weightsDir 'server.log'
$errlog=Join-Path $weightsDir 'server-error.log'
$serverArgs=@('-m',('"' + $model + '"'),'--host','127.0.0.1','--port','17847','-c','1536','-t','3','-ngl','0','--alias','genesis-local')
$proc=Start-Process -FilePath $server.FullName -ArgumentList $serverArgs -WorkingDirectory $server.DirectoryName -PassThru -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError $errlog
try {
  $ready=$false
  for($i=0;$i -lt 100;$i++){
    if ($proc.HasExited) { throw "Avvio AI fallito. Leggi $errlog" }
    try {
      $h=Invoke-RestMethod 'http://127.0.0.1:17847/health' -TimeoutSec 2
      if ($h.status -eq 'ok') { $ready=$true;break }
    } catch {}
    Start-Sleep -Milliseconds 500
  }
  if (!$ready) { throw 'AI non pronta.' }
  Write-Host 'AI locale pronta. Nessuna API esterna.'
  if ($TestOnly) {
    $game=Start-Process -FilePath (Join-Path $root 'GENESIS47.exe') -ArgumentList '--headless','--','--portable-ai','--ai-test' -PassThru
    if (!$game.WaitForExit(120000)) { $game.Kill();throw 'Test AI timeout.' }
    if ($game.ExitCode -ne 0) { throw "Test AI: codice $($game.ExitCode)" }
    Write-Host 'AI_INTEGRATION_PASS'
  } else {
    $game=Start-Process -FilePath (Join-Path $root 'GENESIS47.exe') -ArgumentList '--','--portable-ai' -PassThru
    $game.WaitForExit()
  }
} finally {
  if (!$proc.HasExited) { Stop-Process -Id $proc.Id -ErrorAction SilentlyContinue }
}
