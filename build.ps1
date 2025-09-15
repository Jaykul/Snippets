Set-Location $PSScriptRoot/source/predictor
dotnet publish -o ../lib
Set-Location $PSScriptRoot
Build-Module