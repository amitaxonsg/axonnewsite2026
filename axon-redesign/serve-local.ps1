param(
  [int]$Port = 8000,
  [string]$Root = (Get-Location).Path
)

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$contentTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
  ".json" = "application/json; charset=utf-8"
  ".webp" = "image/webp"
}

function Send-HttpResponse {
  param(
    [System.IO.Stream]$Stream,
    [string]$Method,
    [int]$StatusCode,
    [string]$StatusText,
    [string]$ContentType,
    [byte[]]$Body
  )

  if ($null -eq $Body) {
    $Body = [byte[]]::new(0)
  }

  $headers = @(
    "HTTP/1.1 $StatusCode $StatusText"
    "Content-Type: $ContentType"
    "Content-Length: $($Body.Length)"
    "Connection: close"
    ""
    ""
  ) -join "`r`n"

  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headers)
  $Stream.Write($headerBytes, 0, $headerBytes.Length)
  if ($Method -ne "HEAD" -and $Body.Length -gt 0) {
    $Stream.Write($Body, 0, $Body.Length)
  }
}

function Send-TextResponse {
  param(
    [System.IO.Stream]$Stream,
    [string]$Method,
    [int]$StatusCode,
    [string]$StatusText,
    [string]$Text
  )

  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  Send-HttpResponse $Stream $Method $StatusCode $StatusText "text/plain; charset=utf-8" $bytes
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)

try {
  $listener.Start()
  Write-Host "Serving $resolvedRoot at http://localhost:$Port/"

  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $client.ReceiveTimeout = 5000
      $client.SendTimeout = 5000
      $stream = $client.GetStream()
      $stream.ReadTimeout = 5000
      $stream.WriteTimeout = 5000
      $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      if ([string]::IsNullOrWhiteSpace($requestLine)) {
        continue
      }

      while ($true) {
        $headerLine = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($headerLine)) {
          break
        }
      }

      $parts = $requestLine.Split(" ")
      if ($parts.Count -lt 2) {
        Send-TextResponse $stream "GET" 400 "Bad Request" "Bad request"
        continue
      }

      $method = $parts[0].ToUpperInvariant()
      if ($method -ne "GET" -and $method -ne "HEAD") {
        Send-TextResponse $stream $method 405 "Method Not Allowed" "Method not allowed"
        continue
      }

      $target = $parts[1].Split("?")[0]
      $requestPath = [System.Uri]::UnescapeDataString($target.TrimStart("/"))
      if ([string]::IsNullOrWhiteSpace($requestPath)) {
        $requestPath = "index.html"
      }

      $requestPath = $requestPath -replace "/", [System.IO.Path]::DirectorySeparatorChar
      $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $requestPath))

      if (-not $candidatePath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        Send-TextResponse $stream $method 403 "Forbidden" "Forbidden"
        continue
      }

      if ([System.IO.Directory]::Exists($candidatePath)) {
        $candidatePath = Join-Path $candidatePath "index.html"
      }

      if (-not [System.IO.File]::Exists($candidatePath)) {
        Send-TextResponse $stream $method 404 "Not Found" "Not found"
        continue
      }

      $extension = [System.IO.Path]::GetExtension($candidatePath).ToLowerInvariant()
      $contentType = if ($contentTypes.ContainsKey($extension)) { $contentTypes[$extension] } else { "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($candidatePath)
      Send-HttpResponse $stream $method 200 "OK" $contentType $bytes
    }
    catch {
      Write-Warning "Request failed: $($_.Exception.Message)"
    }
    finally {
      $client.Close()
    }
  }
}
finally {
  $listener.Stop()
}
