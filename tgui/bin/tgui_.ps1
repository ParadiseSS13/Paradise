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

## Minifies tgui/html assets
function task-setup {
  yarn run build:helpers
  Write-Output "tgui: html helpers minified"
  yarn run build:style
  Write-Output "tgui: html styles minified"
}

## Runs rspack
function task-rspack {
  yarn run rspack @Args
}

## Runs a development server
function task-dev-server {
  yarn node --experimental-modules "packages/tgui-dev-server/index.js" @Args
}

## Run a linter through all packages
function task-lint {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run eslint packages @Args
  Write-Output "tgui: eslint check passed"
}

function task-test {
  yarn run jest
}

function task-prettier {
  npx prettier --check packages @Args
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
  Remove-Quiet -Recurse -Force ".yarn\rspack"
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
    Write-Output "::error file=tgui/public/tgui.bundle.js,title=Rebuild tgui bundle::Our build differs from the build committed into git."
    exit 1
  }
  Write-Output "tgui: build is ok"
}

## Installs merge drivers and git hooks
function task-install-git-hooks () {
  Write-Output "tgui: WARNING: tgui bundle merge drivers are deprecated. Please modify .gitattributes to continue using them"
  Set-Location $global:basedir
  git config --replace-all merge.tgui-merge-bundle.driver "tgui/bin/tgui --merge=bundle %P %A"
  Write-Output "tgui: Merge drivers have been successfully installed!"
}

function task-editor-sdk () {
  yarn dlx @yarnpkg/sdks vscode
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
    task-rspack --mode=production --analyze
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
    task-setup
    task-rspack --mode=production
    task-validate-build
    exit 0
  }

  ## ## Run prettier
  if ($Args[0] -eq "--prettier") {
    $Rest = $Args | Select-Object -Skip 1
    task-prettier --write
    exit 0
  }

  if ($Args[0] -eq "--sdks") {
    task-editor-sdk
    exit 0
  }
}

## Make a production rspack build
if ($Args.Length -eq 0) {
  task-install
  task-lint --fix
  task-setup
  task-rspack --mode=production
  exit 0
}

## Run rspack with custom flags
task-install
task-setup
task-rspack @Args
