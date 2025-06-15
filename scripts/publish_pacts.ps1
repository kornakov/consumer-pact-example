<#
.SYNOPSIS
    Publish contracts to Pact Broker using Docker
.DESCRIPTION
    This script publishes contract files to a Pact Broker using the pact-cli Docker image
#>

# Strict mode
$ErrorActionPreference = "Stop"

# ---- Configuration ----
$BROKER_URL = "http://localhost:9292/"
$BROKER_USERNAME = "admin"
$BROKER_PASSWORD = "password"
$PACT_DIR = "pacts"  # Contracts directory
$DOCKER_IMAGE = "pactfoundation/pact-cli:latest"
$APP_VERSION = "1.0.0"  # App version
$BRANCH_NAME = "main"   # Git branch
$TAG_NAME = $null       # Optional tag

# ---- Validation ----
if (-not (Test-Path -Path $PACT_DIR -PathType Container)) {
    Write-Host "ERROR: Contracts directory '$PACT_DIR' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Publishing contracts from '$PACT_DIR' to broker '$BROKER_URL'" -ForegroundColor Cyan
Write-Host "Version: $APP_VERSION" -ForegroundColor Cyan
Write-Host "Branch: $BRANCH_NAME" -ForegroundColor Cyan

try {
    # Build Docker command
    $dockerArgs = @(
        "run",
        "--rm",
        "-v", "$(Get-Location)/$PACT_DIR`:/pacts",
        "-e", "PACT_BROKER_BASE_URL=$BROKER_URL",
        "-e", "PACT_BROKER_USERNAME=$BROKER_USERNAME",
        "-e", "PACT_BROKER_PASSWORD=$BROKER_PASSWORD",
        $DOCKER_IMAGE,
        "publish",
        "/pacts",
        "--consumer-app-version=$APP_VERSION",
        "--branch=$BRANCH_NAME"
    )

    if ($TAG_NAME) {
        $dockerArgs += "--tag"
        $dockerArgs += $TAG_NAME
    }

    # Execute Docker command
    & docker $dockerArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Docker command failed with exit code $LASTEXITCODE"
    }

    Write-Host "SUCCESS: Contracts published successfully" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to publish contracts: $_" -ForegroundColor Red
    exit 1
}