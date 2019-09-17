$BYOND_MAJOR=512
$BYOND_MINOR=1427
if(!(Test-Path -Path "C:/byond")){
    Invoke-WebRequest "http://www.byond.com/download/build/$BYOND_MAJOR/$BYOND_MAJOR.${BYOND_MINOR}_byond.zip" -o C:/byond.zip
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:/byond.zip", "C:/")
    Remove-Item C:/byond.zip
}

 Set-Location $env:APPVEYOR_BUILD_FOLDER

 &"C:/byond/bin/dm.exe" -max_errors 0 paradise.dme
exit $LASTEXITCODE 