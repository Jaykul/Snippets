# Use this file to override the default parameter values used by the `Build-Module`
# command when building the module (see `Get-Help Build-Module -Full` for details).
@{
    ModuleManifest           = "./Source/Snippets.psd1"
    OutputDirectory          = "../Modules"
    VersionedOutputDirectory = $true
    CopyDirectories          = @('snippets', './lib/*.dll','Snippets.format.ps1xml', 'Snippets.types.ps1xml')
}
