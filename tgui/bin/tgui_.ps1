## Copyright (c) 2020 Aleksej Komarov
## SPDX-License-Identifier: MIT

## Initial set-up
## --------------------------------------------------------

## Enable strict mode and stop of first cmdlet error
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

## Validates exit code of external commands
function Throw-On-Native-Failure {
  if (-not $?) {
    exit 1
  }
}

## Normalize current directory
$basedir = Split-Path $MyInvocation.MyCommand.Path
$basedir = Resolve-Path "$($basedir)\.."
Set-Location $basedir
[Environment]::CurrentDirectory = $basedir


## Functions
## --------------------------------------------------------

function yarn {
  $YarnRelease = Get-ChildItem -Filter ".yarn\releases\yarn-*.cjs" | Select-Object -First 1
  node ".yarn\releases\$YarnRelease" @Args
  Throw-On-Native-Failure
}

function Remove-Quiet {
  Remove-Item -ErrorAction SilentlyContinue @Args
}

function task-install {
  yarn install
}

## Runs webpack
function task-webpack {
  yarn run webpack-cli @Args
}

## Runs a development server
function task-dev-server {
  yarn node --experimental-modules "packages/tgui-dev-server/index.js" @Args
}

## Run a linter through all packages
function task-lint {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run eslint packages --ext ".js,.jsx,.ts,.tsx,.cjs,.mjs" @Args
  Write-Output "tgui: eslint check passed"
}

function task-test {
  yarn run jest
}

function task-prettier {
  npx prettier --check packages --write @Args
}

function task-polyfill {
  yarn tgui-polyfill:build
}

## Mr. Proper
function task-clean {
  ## Build artifacts
  Write-Output "tgui: cleaning build artifacts"
  Remove-Quiet -Recurse -Force "public\.tmp"
  Remove-Quiet -Force "public\*.map"
  Remove-Quiet -Force "public\*.hot-update.*"
  Write-Output "tgui: cleaning Yarn artifacts"
  ## Yarn artifacts
  Remove-Quiet -Recurse -Force ".yarn\cache"
  Remove-Quiet -Recurse -Force ".yarn\unplugged"
  Remove-Quiet -Recurse -Force ".yarn\webpack"
  Remove-Quiet -Force ".yarn\build-state.yml"
  Remove-Quiet -Force ".yarn\install-state.gz"
  Remove-Quiet -Force ".yarn\install-target"
  Remove-Quiet -Force ".pnp.*"
  Write-Output "tgui: cleaning NPM artifacts"
  ## NPM artifacts
  Get-ChildItem -Path "." -Include "node_modules" -Recurse -File:$false | Remove-Item -Recurse -Force
  Remove-Quiet -Force "package-lock.json"
  Write-Output "tgui: All artifacts cleaned"
}

## Validates current build against the build stored in git
function task-validate-build {
  $diff = git diff --text public/*
  if ($diff) {
    Write-Output "Error: our build differs from the build committed into git."
    Write-Output "Please rebuild tgui."
    exit 1
  }
  Write-Output "tgui: build is ok"
}

## Installs merge drivers and git hooks
function task-install-git-hooks () {
    Set-Location $global:basedir
    git config --replace-all merge.tgui-merge-bundle.driver "tgui/bin/tgui --merge=bundle %P %O %A %B %L"
    Write-Output "tgui: Merge drivers have been successfully installed!"
}

## Main
## --------------------------------------------------------

if ($Args.Length -gt 0) {
  if ($Args[0] -eq "--clean") {
    task-clean
    exit 0
  }

  if ($Args[0] -eq "--install-git-hooks") {
    task-install-git-hooks
    exit 0
  }

  if ($Args[0] -eq "--dev") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-dev-server @Rest
    exit 0
  }

  if ($Args[0] -eq "--lint") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint @Rest
    exit 0
  }

  if ($Args[0] -eq "--fix") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint --fix @Rest
    exit 0
  }

  ## Analyze the bundle
  if ($Args[0] -eq "--analyze") {
    task-install
    task-webpack --mode=production --analyze
    exit 0
  }

  ## Jest test
  if ($Args[0] -eq "--test") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-test @Rest
    exit 0
  }

  ## Continuous integration scenario
  if ($Args[0] -eq "--ci") {
    $Rest = $Args | Select-Object -Skip 1
    task-clean
    task-install
    task-prettier
    task-test @Rest
    task-lint
    task-webpack --mode=production
    task-validate-build
    exit 0
  }

  ## ## Run prettier
  if ($Args[0] -eq "--prettier") {
    $Rest = $Args | Select-Object -Skip 1
    task-prettier @Rest
    exit 0
  }

  ## ## Run prettier
  if ($Args[0] -eq "--tgui-polyfill") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-polyfill @Rest
    exit 0
  }
}

## Make a production webpack build
if ($Args.Length -eq 0) {
  task-install
  task-lint --fix
  task-prettier
  task-webpack --mode=production
  exit 0
}

## Run webpack with custom flags
task-install
task-webpack @Args
